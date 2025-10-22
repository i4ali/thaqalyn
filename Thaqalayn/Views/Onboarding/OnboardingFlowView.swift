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
    @State private var selectedTheme: ThemeVariant?
    @State private var notificationsEnabled = false

    private let totalPages = 5

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

                // Screen 4: Daily Verse
                DailyVerseScreen(notificationsEnabled: $notificationsEnabled)
                    .tag(3)

                // Screen 5: Final Setup
                FinalScreen(
                    selectedTheme: $selectedTheme,
                    onComplete: {
                        completeOnboarding()
                    }
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Skip button (hidden on last page)
            if currentPage < totalPages - 1 {
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
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.colorScheme)
    }

    private func completeOnboarding() {
        // Apply selected theme if any
        if let theme = selectedTheme {
            themeManager.setTheme(theme)
        }

        // Apply notification preferences
        if notificationsEnabled {
            Task {
                await NotificationManager.shared.requestPermission()
                NotificationManager.shared.preferences.enabled = true
            }
        }

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasShownWelcome")

        // Dismiss
        dismiss()
    }
}

#Preview {
    OnboardingFlowView()
}
