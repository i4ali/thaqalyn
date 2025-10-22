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

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 50) {
                // App icon with glow
                ZStack {
                    // Glow effect
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(themeManager.accentGradient.opacity(0.3))
                            .frame(width: 140 - CGFloat(index * 20), height: 140 - CGFloat(index * 20))
                            .blur(radius: 10)
                            .scaleEffect(isVisible ? 1 : 0.5)
                            .opacity(isVisible ? 1 : 0)
                            .animation(
                                Animation.easeOut(duration: 1.0).delay(Double(index) * 0.2),
                                value: isVisible
                            )
                    }

                    // App icon representation
                    Text("ثقلين")
                        .font(.system(size: 48, weight: .light, design: .default))
                        .foregroundColor(themeManager.primaryText)
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: isVisible)
                }
                .frame(height: 150)

                // Mission statement
                VStack(spacing: 24) {
                    Text("This app brings those teachings to your fingertips")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.8), value: isVisible)

                    Text("Through authentic Shia scholarship, connecting you with the Quran and the wisdom of the Ahlul Bayt")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 40)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.8).delay(1.1), value: isVisible)
                }

                // Feature highlights
                VStack(spacing: 16) {
                    HighlightRow(
                        icon: "book.closed.fill",
                        text: "Complete Quranic text with English translation",
                        isVisible: isVisible,
                        delay: 1.4
                    )

                    HighlightRow(
                        icon: "sparkles",
                        text: "5 layers of authentic Shia commentary",
                        isVisible: isVisible,
                        delay: 1.6
                    )

                    HighlightRow(
                        icon: "bell.fill",
                        text: "Daily verses aligned with Islamic calendar",
                        isVisible: isVisible,
                        delay: 1.8
                    )

                    HighlightRow(
                        icon: "heart.fill",
                        text: "Save and sync bookmarks across devices",
                        isVisible: isVisible,
                        delay: 2.0
                    )
                }
                .padding(.horizontal, 30)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
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

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(themeManager.accentGradient)
                )
                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 8)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .animation(Animation.easeOut(duration: 0.6).delay(delay), value: isVisible)
    }
}

#Preview {
    MissionScreen()
}
