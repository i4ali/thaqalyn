//
//  MissionScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 2: App Mission
//

import SwiftUI

struct MissionScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // App icon with glow
                ZStack {
                    // Glow effect
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color(hex: "ECD49A").opacity(0.16))
                            .frame(width: 140 - CGFloat(index * 20), height: 140 - CGFloat(index * 20))
                            .blur(radius: 10)
                            .scaleEffect(isVisible ? 1 : 0.5)
                            .opacity(isVisible ? 1 : 0)
                            .animation(
                                Animation.easeOut(duration: 1.0).delay(Double(index) * 0.2),
                                value: isVisible
                            )
                    }

                    // App icon representation with shimmer
                    Text("ثقلين")
                        .font(.system(size: 48, weight: .light, design: .default))
                        .foregroundColor(themeManager.primaryText)
                        .overlay(
                            GeometryReader { geometry in
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.6),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: geometry.size.width * 0.5)
                                .offset(x: shimmerOffset * geometry.size.width * 1.5)
                                .blendMode(.overlay)
                            }
                            .mask(
                                Text("ثقلين")
                                    .font(.system(size: 48, weight: .light, design: .default))
                            )
                        )
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: isVisible)
                }
                .frame(height: 150)

                // Mission statement
                VStack(spacing: 24) {
                    Text("The Quran & Ahlul Bayt, at your fingertips")
                        .onbHeroTitle()
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.8), value: isVisible)

                    Text("Authentic Shia scholarship to read, understand, and journey through the Quran — and the wisdom of the Ahlul Bayt")
                        .onbBody()
                        .foregroundColor(themeManager.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 40)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.8).delay(1.1), value: isVisible)
                }

                // Feature highlights
                VStack(spacing: 12) {
                    HighlightRow(
                        icon: "book.closed.fill",
                        text: "The complete Quran in English, Urdu & Arabic",
                        isVisible: isVisible,
                        delay: 1.4,
                        chip: ThemeManager.chipGold
                    )

                    HighlightRow(
                        icon: "sparkles",
                        text: "5 layers of authentic Shia commentary",
                        isVisible: isVisible,
                        delay: 1.6,
                        chip: ThemeManager.chipGold
                    )

                    HighlightRow(
                        icon: "books.vertical.fill",
                        text: "Stories, parallels & Du'as of the Ahlul Bayt",
                        isVisible: isVisible,
                        delay: 1.8,
                        chip: ThemeManager.chipGold
                    )

                    HighlightRow(
                        icon: "map.fill",
                        text: "Seasonal journeys for Ramadan, Muharram, Hajj & more",
                        isVisible: isVisible,
                        delay: 2.0,
                        chip: ThemeManager.chipGold
                    )
                }
                .padding(.horizontal, 30)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .lavender))
        .onAppear {
            isVisible = true
            startShimmerAnimation()
        }
    }

    private func startShimmerAnimation() {
        // Start shimmer after initial animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 1.0
            }
        }
    }
}

// MARK: - Highlight Row

struct HighlightRow: View {
    @StateObject private var themeManager = ThemeManager.shared
    let icon: String
    let text: String
    let isVisible: Bool
    let delay: Double
    let chip: ThemeManager.ChipColor

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(chip.fg)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 10).fill(chip.bg))

            Text(text)
                .onbRowTitle()
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onboardingRow()
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .animation(Animation.easeOut(duration: 0.6).delay(delay), value: isVisible)
    }
}

#Preview {
    MissionScreen()
}
