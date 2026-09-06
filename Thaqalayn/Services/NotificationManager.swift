//
//  NotificationManager.swift
//  Thaqalayn
//
//  Service for managing daily verse notifications
//  Handles permissions and scheduling. Verse selection lives in DailyVerseProvider,
//  which the Today-tab card reads from too, so the push and the card always agree.
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var preferences: NotificationPreferences {
        didSet {
            savePreferences()
            // Full refresh: re-times dailies AND seasonal one-shots (they all
            // fire at preferences.time); disabling cancels only the dailies.
            Task { await refreshAllSchedules() }
        }
    }

    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined

    private let islamicCalendar = IslamicCalendarManager.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    private let progressManager = ProgressManager.shared

    // UserDefaults keys
    private let preferencesKey = "notificationPreferences"

    /// iOS caps an app at 64 pending notification requests, and that budget is shared
    /// with streak_reminder, gentle_nudge, milestone_*, near_completion_*,
    /// arafah_reminder and journey_start_*. Thirty days of verses leaves headroom
    /// while still covering a user who does not open the app for a month - which is
    /// exactly the user this notification exists for. Raise this and iOS will start
    /// silently dropping requests.
    private static let scheduleWindowDays = 30
    private static let dailyVersePrefix = "daily_verse_"

    private static let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func identifier(for date: Date) -> String {
        dailyVersePrefix + dayKeyFormatter.string(from: date)
    }

    private init() {
        // Load preferences
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(NotificationPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = NotificationPreferences()
        }

        // Check permission status
        Task {
            await checkPermissionStatus()
        }
    }

    // MARK: - Preferences

    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }

    // MARK: - Permissions

    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.permissionStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("❌ NotificationManager: Error requesting permission - \(error)")
            return false
        }
    }

    func checkPermissionStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.permissionStatus = settings.authorizationStatus
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Notification Content

    private func buildNotificationContent(for selection: DailyVerseSelection) async -> UNMutableNotificationContent? {
        let verse = await MainActor.run {
            DataManager.shared.getVerse(surah: selection.surah, verse: selection.verse)
        }
        guard let verse else {
            print("❌ NotificationManager: could not hydrate \(selection.id)")
            return nil
        }

        let content = UNMutableNotificationContent()

        // On a sacred day the occasion replaces the generic title.
        content.title = selection.occasionEn ?? "Verse of the Day"
        // The theme lives in the subtitle so the body is nothing but the verse.
        // iOS shows roughly four body lines on the lock screen; spending one on a
        // "tap to explore" CTA only restated the tap gesture, so it is gone.
        content.subtitle = selection.themeEn

        var body = verse.arabicText
        if !verse.translation.isEmpty {
            body += "\n\n" + verse.translation
        }
        // The first gem's core insight stands in for the old foundation commentary.
        if preferences.includeTafsir,
           let insight = verse.tafsir?.quickOverview?.concepts.first?.coreInsight,
           !insight.isEmpty {
            body += "\n\n💡 " + String(insight.prefix(150)) + "..."
        }
        content.body = body

        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "DAILY_VERSE"
        content.userInfo = [
            "surah": selection.surah,
            "verse": selection.verse,
            "type": "daily_verse"
        ]

        return content
    }

    // MARK: - Lifecycle Refresh

    private var refreshChain: Task<Void, Never>?

    /// Single entry point for app activation: re-check permission, clear the
    /// stale icon badge, sweep delivered notifications into the inbox, and
    /// refresh every schedule. Called on cold launch and every foregrounding.
    func handleAppBecameActive() async {
        await checkPermissionStatus()
        try? await notificationCenter.setBadgeCount(0)
        await NotificationInboxStore.sweepDelivered(from: notificationCenter)
        await refreshAllSchedules()
    }

    /// Serialized so overlapping triggers (didSet + scenePhase) can't
    /// interleave their cancel/add sequences.
    func refreshAllSchedules() async {
        let previous = refreshChain
        let task = Task {
            await previous?.value
            await self.performRefresh()
        }
        refreshChain = task
        await task.value
    }

    private func performRefresh() async {
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        if preferences.enabled {
            await scheduleDailyVerseNotifications()
        } else {
            await cancelDailyVerseNotifications()
        }

        // Seasonal one-shots are idempotent (fixed identifiers, handledYears
        // dedup for journey catch-ups) — safe to re-arm on every refresh.
        if islamicCalendar.isHajjSeason() {
            await scheduleArafahReminder()
        }
        await scheduleJourneyStartNotifications()
    }

    // MARK: - Notification Scheduling

    /// (Re)schedule the rolling daily-verse window.
    ///
    /// Cancel-all-then-re-add rather than an incremental diff: content is baked into
    /// each request at schedule time, so a change to time / includeTafsir
    /// has to rewrite every pending request anyway. Thirty rebuilds on a foreground
    /// is cheap - the pool is in memory and getVerse is an in-memory lookup.
    private func scheduleDailyVerseNotifications() async {
        await cancelDailyVerseNotifications()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<Self.scheduleWindowDays {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            await scheduleNotification(on: date)
        }
    }

    private func scheduleNotification(on date: Date) async {
        let calendar = Calendar.current

        let timeComponents = calendar.dateComponents([.hour, .minute], from: preferences.time)
        var targetComponents = calendar.dateComponents([.year, .month, .day], from: date)
        targetComponents.hour = timeComponents.hour
        targetComponents.minute = timeComponents.minute

        // Today's slot may already have passed.
        guard let fireDate = calendar.date(from: targetComponents), fireDate > Date() else { return }

        let selection = DailyVerseProvider.shared.verse(for: date)
        guard let content = await buildNotificationContent(for: selection) else { return }

        let trigger = UNCalendarNotificationTrigger(dateMatching: targetComponents, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier(for: date),
                                            content: content,
                                            trigger: trigger)
        do {
            try await notificationCenter.add(request)
        } catch {
            print("❌ NotificationManager: failed to schedule \(Self.identifier(for: date)) - \(error)")
        }
    }

    /// Removes every pending daily-verse request whatever its date key. Prefix-scoped,
    /// so it never touches seasonal or progress notifications.
    func cancelDailyVerseNotifications() async {
        let pending = await notificationCenter.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { $0.hasPrefix(Self.dailyVersePrefix) }
        guard !identifiers.isEmpty else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Pending Notifications

    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }

    /// Print all pending notifications (for debugging)
    func printPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        for request in requests {
            print("NotificationManager: \(request.identifier)")
        }
    }

    // MARK: - Progress Notifications

    /// Schedule a streak reminder notification
    @MainActor
    func scheduleStreakReminder() async {
        // Only schedule if progress notifications are enabled
        guard progressManager.preferences.notificationsEnabled else { return }

        // Check if user has a current streak
        let currentStreak = progressManager.streak.currentStreak
        guard currentStreak > 0 else { return }

        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Schedule for tomorrow at the user's preferred notification time
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Going! 🔥"
        content.body = "You're on a \(currentStreak)-day reading streak. Don't break it today!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "STREAK_REMINDER"

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )

        // Schedule
        do {
            try await notificationCenter.add(request)
            print("✅ NotificationManager: Streak reminder scheduled")
        } catch {
            print("❌ NotificationManager: Error scheduling streak reminder - \(error)")
        }
    }

    /// Schedule a milestone celebration notification
    @MainActor
    func scheduleMilestoneCelebration(milestone: String) async {
        // Only schedule if progress notifications are enabled
        guard progressManager.preferences.notificationsEnabled else { return }

        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Congratulations! 🎉"
        content.body = milestone
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MILESTONE"

        // Schedule for 5 seconds from now (immediate celebration)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "milestone_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        // Schedule
        do {
            try await notificationCenter.add(request)
            print("✅ NotificationManager: Milestone notification scheduled")
        } catch {
            print("❌ NotificationManager: Error scheduling milestone notification - \(error)")
        }
    }

    /// Schedule-ahead re-engagement nudge: armed on every read for +2 days at
    /// the preferred time (fixed identifier replaces the previous one), so it
    /// only ever fires if the user actually stays away.
    @MainActor
    func scheduleGentleNudge() async {
        // Only schedule if progress notifications are enabled
        guard progressManager.preferences.notificationsEnabled else { return }

        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Fire in 2 days at the preferred time
        let target = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: target)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "We miss you! 📖"
        content.body = "It's been 2 days since your last reading. Come back to continue your journey through the Quran."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "GENTLE_NUDGE"

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "gentle_nudge",
            content: content,
            trigger: trigger
        )

        // Schedule
        do {
            try await notificationCenter.add(request)
            print("✅ NotificationManager: Gentle nudge scheduled")
        } catch {
            print("❌ NotificationManager: Error scheduling gentle nudge - \(error)")
        }
    }

    /// Schedule encouragement for nearly completed surah
    @MainActor
    func scheduleNearCompletionEncouragement(surahNumber: Int, surahName: String, versesRemaining: Int) async {
        // Only schedule if progress notifications are enabled
        guard progressManager.preferences.notificationsEnabled else { return }

        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Almost There! 🌟"
        content.body = "You're almost done with Surah \(surahName)! Only \(versesRemaining) verses remaining."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "NEAR_COMPLETION"

        // Schedule for 1 hour from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "near_completion_\(surahNumber)",
            content: content,
            trigger: trigger
        )

        // Schedule
        do {
            try await notificationCenter.add(request)
            print("✅ NotificationManager: Near completion encouragement scheduled")
        } catch {
            print("❌ NotificationManager: Error scheduling encouragement - \(error)")
        }
    }

    // MARK: - Hajj Season Notifications

    /// Schedule a single reminder for the Day of Arafah (9 Dhul-Hijjah).
    /// Only scheduled when notifications are already authorized and we are in Hajj season.
    /// Deep-links to Quran 2:198 (the verse naming Arafat) via the existing verse deep-link path.
    @MainActor
    func scheduleArafahReminder() async {
        // Only during the Hajj season window
        guard islamicCalendar.isHajjSeason() else { return }

        // Check permission (do NOT request it here — that is owned by the daily-verse opt-in flow)
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Resolve the Gregorian date of 9 Dhul-Hijjah for the current Islamic year
        let hijriCalendar = islamicCalendar.islamicCalendar
        var hijriComponents = DateComponents()
        hijriComponents.year = islamicCalendar.currentIslamicYear()
        hijriComponents.month = 12
        hijriComponents.day = 9

        guard let arafahDate = hijriCalendar.date(from: hijriComponents) else {
            print("❌ NotificationManager: Could not resolve the date of Arafah")
            return
        }

        // Fire on the day of Arafah at the user's preferred notification time
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: arafahDate)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        // Skip if Arafah has already passed this Islamic year
        if let fireDate = Calendar.current.date(from: dateComponents), fireDate <= Date() {
            return
        }

        // Build content
        let content = UNMutableNotificationContent()
        content.title = "Day of Arafah 🤲"
        content.body = "Today is the Day of Arafah, the greatest day of supplication. Recite the Du'a of Imam al-Husayn (AS) and seek Allah's mercy. Tap to continue your Dhul-Hijjah Journey."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "ARAFAH_REMINDER"
        content.userInfo = [
            "surah": 2,
            "verse": 198,
            "type": "arafah_reminder"
        ]

        // Idempotent: replace any existing pending Arafah reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["arafah_reminder"])

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "arafah_reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("✅ NotificationManager: Arafah reminder scheduled")
        } catch {
            print("❌ NotificationManager: Error scheduling Arafah reminder - \(error)")
        }
    }

    // MARK: - Journey-Start Notifications

    private let journeyHandledYearsKey = "journeyStartHandledYears"

    private func loadJourneyHandledYears() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: journeyHandledYearsKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveJourneyHandledYears(_ map: [String: Int]) {
        if let encoded = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(encoded, forKey: journeyHandledYearsKey)
        }
    }

    private func makeJourneyContent(_ journey: JourneyAnnouncement) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = journey.title
        content.body = journey.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "JOURNEY_START"
        content.userInfo = ["type": "journey_start", "journey": journey.id]
        return content
    }

    /// Schedule "the Journey is open" notifications for all journeys.
    /// Mirrors `scheduleArafahReminder()`'s guards: only if already authorized;
    /// never requests permission. Safe to call on every refresh
    /// (idempotent calendar identifier; handledYears dedups catch-ups).
    @MainActor
    func scheduleJourneyStartNotifications() async {
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let nowDate = Date()
        let comps = islamicCalendar.currentIslamicDate()
        guard let iYear = comps.year,
              let iMonth = comps.month,
              let iDay = comps.day else { return }

        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)
        let prefHour = timeComps.hour ?? 9
        let prefMinute = timeComps.minute ?? 0

        var handled = loadJourneyHandledYears()

        for journey in JourneyAnnouncement.all {
            let decision = journeyScheduleDecision(
                journey: journey,
                now: nowDate,
                islamicYear: iYear,
                islamicMonth: iMonth,
                islamicDay: iDay,
                preferredHour: prefHour,
                preferredMinute: prefMinute,
                islamicCalendar: islamicCalendar.islamicCalendar,
                handledCycleYear: handled[journey.id]
            )

            let identifier = "journey_start_\(journey.id)"

            if let fireDate = decision.calendarFireDate {
                let dateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute], from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: makeJourneyContent(journey),
                    trigger: trigger
                )
                do {
                    try await notificationCenter.add(request)
                    print("✅ NotificationManager: journey-start scheduled (\(journey.id))")
                } catch {
                    print("❌ NotificationManager: journey-start calendar add (\(journey.id)) - \(error)")
                }
            }

            if decision.fireCatchUpNow {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: makeJourneyContent(journey),
                    trigger: trigger
                )
                do {
                    try await notificationCenter.add(request)
                    print("✅ NotificationManager: journey-start catch-up (\(journey.id))")
                } catch {
                    print("❌ NotificationManager: journey-start catch-up add (\(journey.id)) - \(error)")
                }
            }

            if let markYear = decision.markHandledCycleYear {
                handled[journey.id] = markYear
            }
        }

        saveJourneyHandledYears(handled)
    }

    /// Cancel progress-related notifications (covers the dynamic
    /// near_completion_<surah> and milestone_<uuid> identifiers too).
    func cancelProgressNotifications() async {
        let prefixes = ["streak_reminder", "gentle_nudge", "near_completion_", "milestone_"]
        let pending = await notificationCenter.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { id in
            prefixes.contains { id.hasPrefix($0) }
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("✅ NotificationManager: Progress notifications cancelled")
    }

    /// Cancel the pending near-completion encouragement for a surah
    /// (called when the surah is completed before the trigger fires).
    func cancelNearCompletion(surahNumber: Int) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["near_completion_\(surahNumber)"]
        )
    }
}

