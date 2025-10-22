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
}
