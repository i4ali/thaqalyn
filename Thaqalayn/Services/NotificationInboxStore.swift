//
//  NotificationInboxStore.swift
//  Thaqalayn
//
//  Persists real delivered notifications for the in-app inbox.
//  Items are recorded from the UNUserNotificationCenterDelegate (foreground
//  presentation + taps) and swept from Notification Center on app activation,
//  so background deliveries appear too. Replaces the old fake seeded inbox.
//

import Foundation
import SwiftUI
import UserNotifications

struct NotificationItem: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    let surahNumber: Int?
    let verseNumber: Int?
    var journeyId: String? = nil

    enum NotificationType: String, Codable {
        case dailyVerse
        case streak
        case milestone
        case nudge
        case nearCompletion
        case journey

        var icon: String {
            switch self {
            case .dailyVerse: return "book.fill"
            case .streak: return "flame.fill"
            case .milestone: return "star.fill"
            case .nudge: return "heart.fill"
            case .nearCompletion: return "checkmark.circle.fill"
            case .journey: return "map.fill"
            }
        }

        @MainActor
        func color(theme: ThemeManager) -> Color {
            switch self {
            case .dailyVerse: return theme.semanticBlue
            case .streak: return .orange
            case .milestone: return .green
            case .nudge: return theme.semanticRed
            case .nearCompletion: return .purple
            case .journey: return theme.accentColor
            }
        }
    }
}

@MainActor
enum NotificationInboxStore {
    private static let storageKey = "notificationHistoryV2"
    /// Cap inbox growth — oldest entries fall off.
    private static let maxItems = 50

    static func load() -> [NotificationItem] {
        // One-time cleanup: the old key only ever held fake seeded samples.
        UserDefaults.standard.removeObject(forKey: "notificationHistory")
        UserDefaults.standard.removeObject(forKey: "didSeedNotificationSamples")

        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([NotificationItem].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.timestamp > $1.timestamp }
    }

    static func save(_ items: [NotificationItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    /// Record a single delivered/tapped notification (deduped by id).
    static func record(_ notification: UNNotification) {
        var items = load()
        let item = makeItem(from: notification)
        guard !items.contains(where: { $0.id == item.id }) else { return }
        items.insert(item, at: 0)
        save(Array(items.prefix(maxItems)))
    }

    /// Pull anything still sitting in Notification Center into the inbox
    /// (catches background deliveries the delegate never saw).
    static func sweepDelivered(from center: UNUserNotificationCenter) async {
        let delivered = await center.deliveredNotifications()
        guard !delivered.isEmpty else { return }

        var items = load()
        var changed = false
        for notification in delivered {
            let item = makeItem(from: notification)
            if !items.contains(where: { $0.id == item.id }) {
                items.insert(item, at: 0)
                changed = true
            }
        }
        if changed {
            items.sort { $0.timestamp > $1.timestamp }
            save(Array(items.prefix(maxItems)))
        }
    }

    private static func makeItem(from notification: UNNotification) -> NotificationItem {
        let request = notification.request
        let content = request.content
        let userInfo = content.userInfo

        let type: NotificationItem.NotificationType
        switch content.categoryIdentifier {
        case "STREAK_REMINDER": type = .streak
        case "MILESTONE": type = .milestone
        case "GENTLE_NUDGE": type = .nudge
        case "NEAR_COMPLETION": type = .nearCompletion
        case "JOURNEY_START": type = .journey
        default: type = .dailyVerse // DAILY_VERSE + ARAFAH_REMINDER (verse deep-link)
        }

        return NotificationItem(
            id: "\(request.identifier)|\(Int(notification.date.timeIntervalSince1970))",
            title: content.title,
            message: content.body,
            type: type,
            timestamp: notification.date,
            isRead: false,
            surahNumber: userInfo["surah"] as? Int,
            verseNumber: userInfo["verse"] as? Int,
            journeyId: userInfo["journey"] as? String
        )
    }
}
