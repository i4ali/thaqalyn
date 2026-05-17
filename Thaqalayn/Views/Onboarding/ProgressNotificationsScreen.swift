//
//  ProgressNotificationsScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 5: Reading Progress & Motivation
//

import SwiftUI

struct ProgressNotificationsScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var progressNotificationsEnabled: Bool
    @State private var isVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        // Icon - Flame for streak
                        HeroChip(palette: ThemeManager.chipBrand) {
                            PhosphorIcon(name: "ph-flame-fill", size: 44)
                        }
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                        Text("Stay Motivated")
                            .onbHeroTitle()
                            .foregroundColor(themeManager.primaryText)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                        Text("Build your reading streak and earn badges")
                            .onbBody()
                            .foregroundColor(themeManager.secondaryText)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                    }

                    // Feature cards
                    VStack(spacing: 16) {
                        ProgressFeatureCard(
                            icon: "chart.bar.fill",
                            color: .blue,
                            chip: ThemeManager.chipFoundation,
                            title: "Track Your Progress",
                            description: "See your daily verse count and reading streaks"
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.6).delay(0.7), value: isVisible)

                        ProgressFeatureCard(
                            icon: "flame.fill",
                            color: .orange,
                            chip: ThemeManager.chipBrand,
                            title: "Build Streaks",
                            description: "Read daily to maintain your streak and reach new milestones"
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.6).delay(0.8), value: isVisible)

                        ProgressFeatureCard(
                            icon: "trophy.fill",
                            color: .yellow,
                            chip: ThemeManager.chipFeatured,
                            title: "Earn Badges",
                            description: "Complete surahs and hit milestones to unlock achievements"
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.6).delay(0.9), value: isVisible)
                    }
                    .padding(.horizontal, 24)

                    // Enable button
                    VStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                progressNotificationsEnabled.toggle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: progressNotificationsEnabled ? "checkmark.circle.fill" : "bell.badge.fill")
                                    .font(.system(size: 20, weight: .semibold))

                                Text(progressNotificationsEnabled ? "Reminders Enabled" : "Enable Progress Reminders")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(progressNotificationsEnabled ?
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : themeManager.accentGradient)
                            )
                            .shadow(
                                color: (progressNotificationsEnabled ? Color.green : themeManager.accentColor).opacity(0.4),
                                radius: 12
                            )
                        }

                        if !progressNotificationsEnabled {
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
        .background(OnboardingBackground(tilt: .sage))
        .onAppear {
            isVisible = true
        }
    }
}

struct ProgressFeatureCard: View {
    let icon: String
    let color: Color
    let chip: ThemeManager.ChipColor
    let title: String
    let description: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(chip.bg)
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(chip.fg)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .onbRowTitle()
                    .foregroundColor(themeManager.primaryText)

                Text(description)
                    .onbBody()
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .onboardingRow()
    }
}

#Preview {
    ProgressNotificationsScreen(progressNotificationsEnabled: .constant(false))
}
