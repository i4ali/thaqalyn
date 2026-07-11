//
//  DeepDiveScreen.swift
//  Thaqalayn
//
//  Onboarding screen (tag 3): a teaser for the immersive Deep Dive feature.
//  Explains the feature - take a single theme (a virtue, a word from the Qur'an,
//  a question of the heart) and descend through it, layer by layer - and
//  conveys its breadth by cycling a hero through example themes (Certainty,
//  Patience, Gratitude, Reliance, Sincerity). English-only, matching the rest of
//  onboarding. Reuses DeepDivePalette + DeepDiveMotes for fidelity with the real feature.
//

import SwiftUI

struct DeepDiveScreen: View {
    @StateObject private var themeManager = ThemeManager.shared

    @State private var isVisible = false      // staggered entrance
    @State private var haloPulse = false      // hero glow breathes
    @State private var themeIndex = 0         // which theme the hero shows

    /// Example themes a user can dive into (drawn from the real Deep Dive catalog).
    private let themes: [(ar: String, en: String)] = [
        ("يَقِين",   "Certainty"),
        ("صَبْر",    "Patience"),
        ("شُكْر",    "Gratitude"),
        ("تَوَكُّل", "Reliance"),
        ("إِخْلَاص", "Sincerity"),
    ]

    /// Advances the cycling hero every 2.2s.
    private let cycle = Timer.publish(every: 2.2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            descentBackground
            DeepDiveMotes(count: 14)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isVisible = true
            haloPulse = true
        }
        .onReceive(cycle) { _ in
            withAnimation(.easeInOut(duration: 0.7)) {
                themeIndex = (themeIndex + 1) % themes.count
            }
        }
    }

    // MARK: - Background
    // The shared Midnight Emerald onboarding background. (This screen used to
    // preview the feature's own descent ramp, but its near-black stops plus the
    // warm halo read as a different, browner theme inside the onboarding flow.)

    private var descentBackground: some View {
        OnboardingBackground(tilt: .peach)
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 20)
            themeHero
                .frame(maxWidth: .infinity)
            Spacer(minLength: 20)
            footer
        }
        .padding(.horizontal, 34)
        .padding(.top, 62)
        .padding(.bottom, 68)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Deep Dive")
                .onbEyebrow()
                .foregroundColor(Color(hex: "ECD49A"))
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -16)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

            Text("Dive deep into\na single theme")
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 26)
                .animation(.easeOut(duration: 0.6).delay(0.28), value: isVisible)

            Text("A virtue, a word from the Qur'an, a question of the heart - explored layer by layer in an immersive descent.")
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
                .padding(.top, 14)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.42), value: isVisible)
        }
    }

    // MARK: - Cycling theme hero (the always-on motion + breadth of themes)

    private var themeHero: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "ECD49A").opacity(0.15), .clear],
                    center: .center, startRadius: 0, endRadius: 135))
                .frame(width: 270, height: 270)
                .scaleEffect(haloPulse ? 1.08 : 0.96)
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true),
                           value: haloPulse)

            VStack(spacing: 12) {
                Text(themes[themeIndex].ar)
                    .font(EmType.arabic(78))
                    .foregroundColor(Color(hex: "F1E8D6"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(themes[themeIndex].en.uppercased())
                    .font(.system(size: 15, weight: .bold))
                    .tracking(3.5)
                    .foregroundColor(Color(hex: "ECD49A"))
            }
            .id(themeIndex)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(y: 20)),
                removal: .opacity.combined(with: .offset(y: -20))))
        }
        .frame(height: 190)
        .scaleEffect(isVisible ? 1 : 0.82)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.7, dampingFraction: 0.72).delay(0.55), value: isVisible)
    }

    // MARK: - Footer

    private var footer: some View {
        Text("Find Deep Dives in the Journey tab")
            .onbCaption()
            .foregroundColor(themeManager.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.9), value: isVisible)
    }
}

#if DEBUG
#Preview {
    DeepDiveScreen()
}
#endif
