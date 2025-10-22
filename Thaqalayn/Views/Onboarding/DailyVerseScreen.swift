//
//  DailyVerseScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 4: Daily Spiritual Connection
//

import SwiftUI

struct DailyVerseScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var dataManager = DataManager.shared
    @Binding var notificationsEnabled: Bool
    @State private var isVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(themeManager.accentGradient.opacity(0.2))
                                .frame(width: 90, height: 90)
                                .blur(radius: 10)

                            Image(systemName: "bell.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    Circle()
                                        .fill(themeManager.accentGradient)
                                )
                                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 12)
                        }
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                        Text("Your Daily Companion")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                        Text("Start each day with a meaningful verse")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                    }

                    // Notification preview card
                    if let todayVerse = notificationManager.selectTodayVerse(),
                       let monthData = notificationManager.currentMonthData(),
                       let verse = dataManager.getVerse(surah: todayVerse.surah, verse: todayVerse.verse) {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Verse of the Day")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.secondaryText)

                                    Text(monthData.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.primaryText)
                                }

                                Spacer()

                                Image(systemName: "star.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.yellow)
                            }

                            // Verse content
                            VStack(alignment: .leading, spacing: 12) {
                                // Arabic text
                                Text(verse.arabicText)
                                    .font(.system(size: 20, weight: .medium, design: .serif))
                                    .foregroundColor(themeManager.primaryText)
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)

                                // Translation
                                Text(verse.translation)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(themeManager.secondaryText)
                                    .lineSpacing(4)

                                // Reference
                                Text("Surah \(todayVerse.surah), Verse \(todayVerse.verse)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(themeManager.tertiaryText)

                                // Theme tag
                                HStack {
                                    Text(todayVerse.theme)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(themeManager.accentGradient)
                                        )

                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 12)
                        .padding(.horizontal, 24)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.7), value: isVisible)
                    }

                    // Islamic calendar explanation
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))

                            Text("Based on Islamic Calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)

                            Spacer()
                        }

                        Text("Verses are carefully selected for each Islamic month, ensuring spiritual relevance throughout the year.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .lineSpacing(3)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.secondaryBackground.opacity(0.5))
                    )
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.9), value: isVisible)

                    // Enable button
                    VStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                notificationsEnabled.toggle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: notificationsEnabled ? "checkmark.circle.fill" : "bell.badge.fill")
                                    .font(.system(size: 20, weight: .semibold))

                                Text(notificationsEnabled ? "Notifications Enabled" : "Enable Daily Verses")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(notificationsEnabled ?
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : themeManager.purpleGradient)
                            )
                            .shadow(
                                color: (notificationsEnabled ? Color.green : Color(red: 0.39, green: 0.4, blue: 0.95)).opacity(0.4),
                                radius: 12
                            )
                        }

                        if !notificationsEnabled {
                            Text("You can always enable this later in Settings")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(1.1), value: isVisible)
                }

                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
        }
    }
}

#Preview {
    DailyVerseScreen(notificationsEnabled: .constant(false))
}
