//
//  WidgetShowcaseScreen.swift
//  Thaqalayn
//
//  Onboarding: the Daily Reflection home-screen widget. Shows a faithful mock
//  of the medium widget and the add-a-widget steps, so new installs learn the
//  widget exists (fresh installs never see its What's New card). English by
//  design like the rest of onboarding; the localized explainer with the
//  prayer-times location capture stays in WidgetExplainerView (Settings).
//

import SwiftUI

struct WidgetShowcaseScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var litDots = 1

    private let dotTimer = Timer.publish(every: 1.8, on: .main, in: .common).autoconnect()

    // Mirrors ThaqalaynWidgets/WidgetTheme.swift (the app target cannot import
    // the widget extension, and the widget always renders in the house look).
    private enum MockPalette {
        static let bgTop = Color(hex: "14332A")
        static let bgBottom = Color(hex: "0A1D18")
        static let text = Color(hex: "ECE5D3")
        static let dim = Color(hex: "9AA896")
        static let gold = Color(hex: "CFA96A")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                VStack(spacing: 36) {
                    // Header
                    VStack(spacing: 16) {
                        HeroChip(palette: ThemeManager.chipProgress) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 34, weight: .semibold))
                        }
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                        Text("On Your Home Screen")
                            .onbHeroTitle()
                            .foregroundColor(themeManager.primaryText)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                        Text("One verse that unfolds through your day, as a widget")
                            .onbBody()
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                    }

                    // Widget mock (medium size, gem beat)
                    widgetMock
                        .padding(.horizontal, 24)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.7), value: isVisible)

                    // The unfolding day
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeManager.chipProgress.fg)

                            Text("It moves with your day")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)

                            Spacer()
                        }

                        Text("The verse arrives in the morning, a hidden gem opens after midday, and the evening becomes a doorway into a journey. Add your location later in Settings and it also marks the five prayers on Shia (Ja'fari) timings.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .lineSpacing(3)
                    }
                    .onboardingRow()
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.9), value: isVisible)

                    // How to add it
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.square.on.square")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ThemeManager.chipGold.fg)

                            Text("Add it in seconds")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)

                            Spacer()
                        }

                        Text("Touch and hold your Home Screen, tap the + button, search for Thaqalayn, and choose a size.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .lineSpacing(3)
                    }
                    .onboardingRow()
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
        .onReceive(dotTimer) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                litDots = litDots % 4 + 1
            }
        }
    }

    // MARK: - Widget mock

    // A faithful still of the medium Daily Reflection widget on a gem beat,
    // built with real content from the daily pool (Ayat al-Kursi). The lit
    // dot advances on a timer to show how the day unfolds.
    private var widgetMock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text("The Throne Verse")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.6)
                    .foregroundColor(MockPalette.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(MockPalette.gold.opacity(0.14))
                    )

                Spacer(minLength: 8)

                Text("AL-BAQARA 2:255")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundColor(MockPalette.dim)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 5) {
                Text("Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence.")
                    .font(.system(size: 11, design: .serif).italic())
                    .foregroundColor(MockPalette.dim)
                    .lineLimit(1)

                Text("The greatest verse in the Qur'an is a portrait of sovereignty: all knowledge, all power, His.")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(MockPalette.text)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 8)

            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < litDots
                                  ? MockPalette.gold : MockPalette.gold.opacity(0.25))
                            .frame(width: 4, height: 4)
                    }
                }

                Spacer(minLength: 8)

                Text("THAQALAYN")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .tracking(2.2)
                    .foregroundColor(MockPalette.dim.opacity(0.8))
            }
        }
        .padding(16)
        .frame(height: 158)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [MockPalette.bgTop, MockPalette.bgBottom],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(MockPalette.gold.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 10)
        )
    }
}

#Preview {
    WidgetShowcaseScreen()
}
