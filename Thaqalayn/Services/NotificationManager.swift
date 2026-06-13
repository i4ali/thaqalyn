//
//  NotificationManager.swift
//  Thaqalayn
//
//  Service for managing daily verse notifications
//  Handles permissions, scheduling, and verse selection based on Islamic calendar
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
    private var verseData: IslamicMonthVerseData?
    private let progressManager = ProgressManager.shared

    // UserDefaults keys
    private let preferencesKey = "notificationPreferences"

    private init() {
        // Load preferences
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(NotificationPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = NotificationPreferences()
        }

        // Load verse data
        loadVerseData()

        // Check permission status
        Task {
            await checkPermissionStatus()
        }
    }

    // MARK: - Data Loading

    private func loadVerseData() {
        guard let url = Bundle.main.url(forResource: "islamic_month_verses", withExtension: "json") else {
            print("❌ NotificationManager: Could not find islamic_month_verses.json in bundle")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.verseData = try decoder.decode(IslamicMonthVerseData.self, from: data)
        } catch {
            print("❌ NotificationManager: Error loading verse data - \(error)")
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

    // MARK: - Verse Selection

    /// Select today's verse based on Islamic calendar
    func selectTodayVerse() -> DailyVerseEntry? {
        guard let verseData = verseData else {
            print("❌ NotificationManager: Verse data not loaded")
            return nil
        }

        let monthNumber = islamicCalendar.currentIslamicMonth()
        let dayOfMonth = islamicCalendar.currentIslamicDay()

        guard let monthData = verseData.months.first(where: { $0.month == monthNumber }) else {
            print("❌ NotificationManager: Could not find month \(monthNumber)")
            return nil
        }

        // Rotate through verses using day of month
        let verseIndex = (dayOfMonth - 1) % monthData.verses.count
        let selectedVerse = monthData.verses[verseIndex]

        return selectedVerse
    }

    /// Get Islamic month data for current month
    func currentMonthData() -> IslamicMonth? {
        guard let verseData = verseData else { return nil }
        let monthNumber = islamicCalendar.currentIslamicMonth()
        return verseData.months.first(where: { $0.month == monthNumber })
    }

    // MARK: - Notification Content

    /// Build notification content for a verse
    private func buildNotificationContent(for verseEntry: DailyVerseEntry) async -> UNMutableNotificationContent? {
        let content = UNMutableNotificationContent()

        // Load verse data (DataManager is @MainActor)
        let verse = await MainActor.run {
            DataManager.shared.getVerse(surah: verseEntry.surah, verse: verseEntry.verse)
        }

        guard let verse = verse else {
            print("❌ NotificationManager: Could not load verse \(verseEntry.surah):\(verseEntry.verse)")
            return nil
        }

        // Get month name
        let monthData = currentMonthData()
        let monthName = monthData?.name ?? islamicCalendar.monthName(for: islamicCalendar.currentIslamicMonth())

        // Title
        content.title = "Verse of the Day - \(monthName)"

        // Body
        var body = ""

        // Arabic text
        body += verse.arabicText + "\n\n"

        // Translation
        body += verse.translation

        // Optional: Add brief tafsir snippet if enabled
        if preferences.includeTafsir {
            if let tafsir = verse.tafsir {
                let tafsirText = tafsir.content(for: TafsirLayer.foundation, language: preferences.language)
                let snippet = String(tafsirText.prefix(150))
                body += "\n\n💡 \(snippet)..."
            }
        }

        body += "\n\n📚 Tap to explore the 5-layer tafsir"

        content.body = body

        // Sound
        content.sound = .default

        // Badge
        content.badge = 1

        // Category
        content.categoryIdentifier = "DAILY_VERSE"

        // User info for deep linking
        content.userInfo = [
            "surah": verseEntry.surah,
            "verse": verseEntry.verse,
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
            cancelDailyVerseNotifications()
        }

        // Seasonal one-shots are idempotent (fixed identifiers, handledYears
        // dedup for journey catch-ups) — safe to re-arm on every refresh.
        if islamicCalendar.isHajjSeason() {
            await scheduleArafahReminder()
        }
        await scheduleJourneyStartNotifications()
    }

    // MARK: - Notification Scheduling

    /// (Re)schedule the rolling 7-day daily-verse window.
    private func scheduleDailyVerseNotifications() async {
        cancelDailyVerseNotifications()
        for dayOffset in 0..<7 {
            await scheduleNotification(for: dayOffset)
        }
    }

    /// Schedule a notification for a specific day offset
    private func scheduleNotification(for dayOffset: Int) async {
        // Calculate target date (add dayOffset days to today)
        let targetDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()

        // Get hour and minute from user preferences
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)

        // Extract all components from target date and override time
        var targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
        targetComponents.hour = timeComponents.hour
        targetComponents.minute = timeComponents.minute

        // For today, only schedule if time hasn't passed
        if dayOffset == 0 {
            let now = Date()
            if let notificationTime = Calendar.current.date(from: targetComponents),
               notificationTime <= now {
                return
            }
        }

        // Get verse for that day (simulate by using dayOffset to select verse)
        guard let verse = selectVerseForDay(dayOffset: dayOffset) else {
            print("❌ NotificationManager: Could not select verse for day \(dayOffset)")
            return
        }

        // Build content
        guard let content = await buildNotificationContent(for: verse) else {
            print("❌ NotificationManager: Could not build content for day \(dayOffset)")
            return
        }

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: targetComponents, repeats: false)

        // Create request
        let identifier = "daily_verse_\(dayOffset)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule
        do {
            try await notificationCenter.add(request)
        } catch {
            print("❌ NotificationManager: Error scheduling notification - \(error)")
        }
    }

    /// Select verse for a specific day offset (used for scheduling future notifications)
    private func selectVerseForDay(dayOffset: Int) -> DailyVerseEntry? {
        guard let verseData = verseData else { return nil }

        // Calculate Islamic date for target day
        let targetDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        let islamicComponents = islamicCalendar.islamicCalendar.dateComponents([.month, .day], from: targetDate)

        guard let monthNumber = islamicComponents.month,
              let dayOfMonth = islamicComponents.day else {
            return nil
        }

        guard let monthData = verseData.months.first(where: { $0.month == monthNumber }) else {
            return nil
        }

        let verseIndex = (dayOfMonth - 1) % monthData.verses.count
        return monthData.verses[verseIndex]
    }

    /// Identifier-scoped: never touches seasonal or progress notifications.
    func cancelDailyVerseNotifications() {
        let identifiers = (0..<7).map { "daily_verse_\($0)" }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Testing

    /// Send a test notification immediately (for testing purposes)
    func sendTestNotification() async {
        guard let verse = selectTodayVerse() else {
            return
        }

        guard let content = await buildNotificationContent(for: verse) else {
            return
        }

        // Schedule for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            print("❌ NotificationManager: Error scheduling test notification - \(error)")
        }
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

