//
//  NotificationsView.swift
//  Thaqalayn
//
//  Notification inbox showing recent notifications
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [NotificationItem] = []
    @State private var navigateToVerse: (surah: Int, verse: Int)?

    var body: some View {
        emeraldBody
            .preferredColorScheme(themeManager.colorScheme)
            .onAppear {
                loadNotifications()
                Task {
                    await NotificationInboxStore.sweepDelivered(from: UNUserNotificationCenter.current())
                    loadNotifications()
                }
            }
    }

    private func handleTap(_ notification: NotificationItem) {
        // Mark as read
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            saveNotifications()
        }

        // Journey-start notification → open the journey tab
        if notification.type == .journey, let journeyId = notification.journeyId {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(
                    name: .navigateToJourney,
                    object: nil,
                    userInfo: ["journey": journeyId]
                )
            }
            return
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

    private var emeraldBody: some View {
        NavigationView {
            ZStack {
                EmeraldBackground()

                if notifications.isEmpty {
                    // Empty state
                    VStack(spacing: 18) {
                        EmIconChip(sfSymbol: "bell.slash.fill", size: 72)

                        Text("All Caught Up")
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)

                        Text("Notifications will appear here when you receive them.")
                            .font(EmType.serif(18, .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            EmHeading(eyebrow: "Your Inbox", title: "Notifications")
                                .padding(.bottom, 4)

                            LazyVStack(spacing: 12) {
                                ForEach(notifications) { notification in
                                    NotificationCard(notification: notification) {
                                        handleTap(notification)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !notifications.isEmpty {
                        Button("Clear All") {
                            clearAllNotifications()
                            saveNotifications()
                        }
                        .font(EmType.serif(17, .semiBold))
                        .foregroundColor(themeManager.destructive)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(EmType.serif(18, .semiBold))
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private func loadNotifications() {
        notifications = NotificationInboxStore.load()
    }

    private func saveNotifications() {
        NotificationInboxStore.save(notifications)
    }

    private func clearAllNotifications() {
        notifications.removeAll()
        saveNotifications()   // persist the cleared state so it survives navigation
    }

}

struct NotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: onTap) {
            EmCard(cornerRadius: 18) {
                HStack(alignment: .top, spacing: 14) {
                    EmIconChip(sfSymbol: notification.type.icon, size: 46)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(alignment: .top, spacing: 8) {
                            Text(notification.title)
                                .font(EmType.serif(19, .semiBold))
                                .foregroundColor(themeManager.primaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: 0)

                            if !notification.isRead {
                                Circle()
                                    .fill(themeManager.accentColor)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 7)
                            }
                        }

                        Text(notification.message)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)

                        Text(formatTimestamp(notification.timestamp))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .padding(.top, 1)
                    }

                    Spacer(minLength: 0)
                }
                .padding(16)
            }
        }
        .buttonStyle(EmPressStyle())
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
