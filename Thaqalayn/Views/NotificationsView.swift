//
//  NotificationsView.swift
//  Thaqalayn
//
//  Notification inbox showing recent notifications
//

import SwiftUI

struct NotificationItem: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    let surahNumber: Int?
    let verseNumber: Int?

    enum NotificationType: String, Codable {
        case dailyVerse
        case streak
        case milestone
        case nudge
        case nearCompletion

        var icon: String {
            switch self {
            case .dailyVerse: return "book.fill"
            case .streak: return "flame.fill"
            case .milestone: return "star.fill"
            case .nudge: return "heart.fill"
            case .nearCompletion: return "checkmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .dailyVerse: return Color(red: 0.39, green: 0.4, blue: 0.95)
            case .streak: return .orange
            case .milestone: return .green
            case .nudge: return Color(red: 0.93, green: 0.28, blue: 0.6)
            case .nearCompletion: return .purple
            }
        }
    }
}

struct NotificationsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [NotificationItem] = []
    @State private var navigateToVerse: (surah: Int, verse: Int)?

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if notifications.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 64))
                            .foregroundColor(themeManager.tertiaryText)

                        Text("No Notifications")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)

                        Text("You're all caught up!\nNotifications will appear here when you receive them.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(notifications) { notification in
                                NotificationCard(notification: notification) {
                                    // Mark as read
                                    if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                        notifications[index].isRead = true
                                        saveNotifications()
                                    }

                                    // Navigate if it has verse info
                                    if let surah = notification.surahNumber,
                                       let verse = notification.verseNumber {
                                        dismiss()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            NotificationCenter.default.post(
                                                name: .navigateToVerse,
                                                object: nil,
                                                userInfo: ["surah": surah, "verse": verse]
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !notifications.isEmpty {
                        Button("Clear All") {
                            notifications.removeAll()
                            saveNotifications()
                        }
                        .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .onAppear {
            loadNotifications()
            addSampleNotifications()
        }
    }

    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: "notificationHistory"),
           let decoded = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            notifications = decoded.sorted { $0.timestamp > $1.timestamp }
        }
    }

    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "notificationHistory")
        }
    }

    private func addSampleNotifications() {
        // Only add samples if empty (for demo purposes)
        guard notifications.isEmpty else { return }

        let samples: [NotificationItem] = [
            NotificationItem(
                id: UUID().uuidString,
                title: "Verse of the Day - Muharram",
                message: "وَإِذْ قَالَ رَبُّكَ لِلْمَلَائِكَةِ إِنِّي جَاعِلٌ فِي الْأَرْضِ خَلِيفَةً\n\nAnd when your Lord said to the angels, 'Indeed I am going to set a viceroy on the earth.'",
                type: .dailyVerse,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false,
                surahNumber: 2,
                verseNumber: 30
            ),
            NotificationItem(
                id: UUID().uuidString,
                title: "Keep Your Streak Going! 🔥",
                message: "You're on a 7-day reading streak. Don't break it today!",
                type: .streak,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                surahNumber: nil,
                verseNumber: nil
            ),
            NotificationItem(
                id: UUID().uuidString,
                title: "Congratulations! 🎉",
                message: "You've completed 5 surahs! Keep up the amazing work.",
                type: .milestone,
                timestamp: Date().addingTimeInterval(-86400),
                isRead: true,
                surahNumber: nil,
                verseNumber: nil
            )
        ]

        notifications = samples
        saveNotifications()
    }
}

struct NotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: notification.type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(notification.type.color)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)

                        Spacer()

                        if !notification.isRead {
                            Circle()
                                .fill(Color(red: 0.39, green: 0.4, blue: 0.95))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text(notification.message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Text(formatTimestamp(notification.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                notification.isRead
                                    ? themeManager.strokeColor
                                    : Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3),
                                lineWidth: notification.isRead ? 1 : 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatTimestamp(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    NotificationsView()
}
