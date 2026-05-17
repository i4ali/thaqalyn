//
//  SeasonalFeaturesScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Seasonal Features (Ramadan Journey, etc.)
//

import SwiftUI

struct SeasonalFeaturesScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var showFeatureCards = false
    @State private var starsPulse = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with animated moon icon
            VStack(spacing: 20) {
                // Animated moon and stars
                ZStack {
                    // Stars background
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: CGFloat([10, 8, 12, 9, 11][index])))
                            .foregroundColor(.yellow.opacity(0.6))
                            .offset(
                                x: CGFloat([-40, 35, -25, 45, -50][index]),
                                y: CGFloat([-35, -40, 30, 25, -10][index])
                            )
                            .opacity(starsPulse ? 1.0 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: [1.8, 2.2, 1.5, 2.0, 2.4][index])
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: starsPulse
                            )
                    }

                    HeroChip(palette: ThemeManager.chipKnowledge,
                             iconColor: ThemeManager.chipBrand.fg) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 38, weight: .semibold))
                    }
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                // Title
                Text("Special Seasons")
                    .onbHeroTitle()
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                // Subtitle
                Text("Unique experiences for blessed months")
                    .onbBody()
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }
            .padding(.top, 60)
            .padding(.bottom, 32)

            // Feature cards
            VStack(spacing: 20) {
                // Ramadan Journey card - expanded
                SeasonalFeatureExpandedCard(
                    icon: "moon.stars.fill",
                    iconColors: [ThemeManager.chipBrand.fg, ThemeManager.chipFeatured.fg],
                    title: "Ramadan Journey",
                    badge: "Seasonal",
                    badgeColor: ThemeManager.chipKnowledge.fg,
                    features: [
                        ("hands.sparkles.fill", "Daily duas from Mafatih al-Jinan"),
                        ("book.pages.fill", "Curated Quranic verses with tafsir"),
                        ("heart.text.square.fill", "Reflections and spiritual guidance"),
                        ("checkmark.circle.fill", "Track your 30-day progress")
                    ],
                    isVisible: showFeatureCards,
                    delay: 0
                )

                // Future seasons - expanded
                SeasonalFeatureExpandedCard(
                    icon: "calendar.badge.clock",
                    iconColors: [ThemeManager.chipFoundation.fg, ThemeManager.chipComparative.fg],
                    title: "More Coming Soon",
                    badge: "Future",
                    badgeColor: ThemeManager.chipFoundation.fg,
                    features: [
                        ("drop.fill", "Muharram commemorations & Ashura"),
                        ("mountain.2.fill", "Dhul-Hijjah & Hajj season"),
                        ("sparkles", "Rajab & Sha'ban preparations"),
                        ("star.fill", "Special nights & occasions")
                    ],
                    isVisible: showFeatureCards,
                    delay: 0.2
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            // Bottom message
            Text("The Ramadan tab appears automatically\nduring the blessed month")
                .onbCaption()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
                .opacity(showFeatureCards ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(0.6), value: showFeatureCards)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .lavender))
        .onAppear {
            isVisible = true
            starsPulse = true

            // Show feature cards after initial animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showFeatureCards = true
                }
            }
        }
    }
}

// MARK: - Seasonal Feature Expanded Card

struct SeasonalFeatureExpandedCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    let icon: String
    let iconColors: [Color]
    let title: String
    let badge: String
    let badgeColor: Color
    let features: [(icon: String, text: String)]
    let isVisible: Bool
    let delay: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: iconColors.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: iconColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                // Title and badge
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .onbCardTitle()
                        .foregroundColor(themeManager.primaryText)

                    Text(badge)
                        .onbPill()
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(badgeColor.gradient)
                        )
                }

                Spacer()
            }

            // Feature list
            VStack(alignment: .leading, spacing: 10) {
                ForEach(features.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Image(systemName: features[index].icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: iconColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 20)

                        Text(features[index].text)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .onboardingCard()
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .animation(Animation.easeOut(duration: 0.5).delay(delay), value: isVisible)
    }
}

#Preview {
    SeasonalFeaturesScreen()
}
