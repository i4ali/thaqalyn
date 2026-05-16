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

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var preferences: NotificationPreferences {
        didSet {
            savePreferences()
            if preferences.enabled {
                Task {
                    await scheduleNotifications()
                }
            } else {
                cancelAllNotifications()
            }
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

    // MARK: - Notification Scheduling

    /// Schedule notifications for the next 7 days
    func scheduleNotifications() async {
        // Check permission first
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("⚠️ NotificationManager: Not authorized to schedule notifications")
            return
        }

        // Cancel existing notifications
        cancelAllNotifications()

        // Schedule for next 7 days
        for dayOffset in 0..<7 {
            await scheduleNotification(for: dayOffset)
        }

        // cancelAllNotifications() above also clears any pending Arafah reminder;
        // re-arm it during Hajj season so it survives daily-verse rescheduling.
        if islamicCalendar.isHajjSeason() {
            await scheduleArafahReminder()
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

    /// Cancel all scheduled notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
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

    /// Schedule a gentle nudge if user hasn't read in 2+ days
    @MainActor
    func scheduleGentleNudge() async {
        // Only schedule if progress notifications are enabled
        guard progressManager.preferences.notificationsEnabled else { return }

        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        // Check if user hasn't read in 2+ days
        guard let lastRead = progressManager.stats.lastReadDate else { return }
        let daysSinceLastRead = Calendar.current.dateComponents([.day], from: lastRead, to: Date()).day ?? 0
        guard daysSinceLastRead >= 2 else { return }

        // Schedule for tomorrow at preferred time
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "We miss you! 📖"
        content.body = "It's been \(daysSinceLastRead) days since your last reading. Come back to continue your journey through the Quran."
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

    /// Cancel progress-related notifications
    func cancelProgressNotifications() {
        let identifiers = [
            "streak_reminder",
            "gentle_nudge"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("✅ NotificationManager: Progress notifications cancelled")
    }
}

