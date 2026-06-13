//
//  OnboardingFlowView.swift
//  Thaqalayn
//
//  Story-driven onboarding flow coordinator
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var notificationsEnabled = false
    @State private var progressNotificationsEnabled = false

    private let totalPages = 10

    var body: some View {
        ZStack {
            // Background
            themeManager.primaryBackground
                .ignoresSafeArea()

            // Main content
            TabView(selection: $currentPage) {
                // Screen 1: Hadith
                HadithScreen(currentPage: $currentPage)
                    .tag(0)

                // Screen 2: Mission
                MissionScreen()
                    .tag(1)

                // Screen 3: Five Layers
                FiveLayersScreen()
                    .tag(2)

                // Screen 4: Quick Gems
                QuickGemsScreen()
                    .tag(3)

                // Screen 5: Progress Tracking
                ProgressTrackingScreen()
                    .tag(4)

                // Screen 6: Quiz Feature
                QuizFeatureScreen()
                    .tag(5)

                // Screen 7: Seasonal Features (Ramadan Journey)
                SeasonalFeaturesScreen()
                    .tag(6)

                // Screen 8: Daily Verse
                DailyVerseScreen(notificationsEnabled: $notificationsEnabled)
                    .tag(7)

                // Screen 9: Progress Notifications
                ProgressNotificationsScreen(progressNotificationsEnabled: $progressNotificationsEnabled)
                    .tag(8)

                // Screen 10: Final Setup (account only — theme picker removed)
                FinalScreen(
                    onComplete: {
                        completeOnboarding()
                    }
                )
                .tag(9)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Skip button (hidden on first page — it auto-advances and shows
            // "Swipe or tap to continue" — and on the last page)
            if currentPage > 0 && currentPage < totalPages - 1 {
                VStack {
                    HStack {
                        Spacer()

                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.secondaryText)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(themeManager.glassEffect)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }

                    Spacer()
                }
            }
        }
        .darkScreenAura()
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.colorScheme)
    }

    private func completeOnboarding() {
        // Apply notification preferences
        if notificationsEnabled || progressNotificationsEnabled {
            Task {
                await NotificationManager.shared.requestPermission()
                NotificationManager.shared.preferences.enabled = notificationsEnabled
            }
        }

        // Apply progress notification preferences (via updatePreferences so they persist)
        let progressManager = ProgressManager.shared
        var progressPrefs = progressManager.preferences
        progressPrefs.notificationsEnabled = progressNotificationsEnabled
        progressPrefs.celebrationsEnabled = progressNotificationsEnabled
        progressManager.updatePreferences(progressPrefs)

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasShownWelcome")

        // Dismiss
        dismiss()
    }
}

#Preview {
    OnboardingFlowView()
}
