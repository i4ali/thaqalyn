//
//  SurahExperienceScreen.swift
//  Thaqalayn
//
//  Onboarding screen: a teaser for the immersive "Inside the Surah" feature -
//  entering a whole chapter and living its full arc, first verse to last (the
//  sibling of the Deep Dive teaser, which descends through a single theme).
//  Conveys the feature's breadth by cross-fading a hero through the catalog's
//  featured surahs (Yusuf, Yasin, al-Rahman, al-Mulk), each with its one-line
//  story. English-only, matching the rest of onboarding. Reuses the shared
//  DeepDivePalette + DeepDiveMotes for fidelity with the real feature.
//

import SwiftUI

struct SurahExperienceScreen: View {
    @StateObject private var themeManager = ThemeManager.shared

    @State private var isVisible = false      // staggered entrance
    @State private var haloPulse = false      // hero glow breathes
    @State private var index = 0              // which surah the hero shows

    /// Featured surahs a user can step inside (drawn from the real
    /// "Inside the Surah" catalog - `SurahExperienceDescriptor.all`).
    private let surahs: [(ar: String, en: String, story: String)] = [
        ("يُوسُف",      "Surah Yusuf",     "The most beautiful of stories - loss, patience, reunion."),
        ("يس",          "Surah Yasin",     "The heart of the Qur'an - and what it keeps asking you."),
        ("الرَّحْمَٰن",  "Surah al-Rahman", "One question, asked thirty-one times."),
        ("الْمُلْك",     "Surah al-Mulk",   "The protector - whose hand holds the kingdom."),
    ]

    /// Advances the cross-fading hero every 2.6s.
    private let cycle = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()

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
                index = (index + 1) % surahs.count
            }
        }
    }

    // MARK: - Background
    // The shared Midnight Emerald onboarding background, for one consistent
    // theme across the whole onboarding flow (the feature's own descent ramp
    // read as a different, browner theme here).

    private var descentBackground: some View {
        OnboardingBackground(tilt: .lavender)
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 20)
            surahHero
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
            Text("Inside the Surah")
                .onbEyebrow()
                .foregroundColor(Color(hex: "ECD49A"))
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -16)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

            Text("Step inside\na whole surah")
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 26)
                .animation(.easeOut(duration: 0.6).delay(0.28), value: isVisible)

            Text("Not scattered verses, but one chapter lived from the first word to the last - its story, its turns, the questions it keeps asking you.")
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

    // MARK: - Cross-fading surah hero (always-on motion + breadth of surahs)

    private var surahHero: some View {
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
                Text(surahs[index].ar)
                    .font(EmType.arabic(68))
                    .foregroundColor(Color(hex: "F1E8D6"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(surahs[index].en.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(3)
                    .foregroundColor(Color(hex: "ECD49A"))
                Text(surahs[index].story)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .padding(.horizontal, 24)
            }
            .id(index)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(y: 20)),
                removal: .opacity.combined(with: .offset(y: -20))))
        }
        .frame(height: 250)
        .scaleEffect(isVisible ? 1 : 0.82)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.7, dampingFraction: 0.72).delay(0.55), value: isVisible)
    }

    // MARK: - Footer

    private var footer: some View {
        Text("Find surah experiences in the Journey tab")
            .onbCaption()
            .foregroundColor(themeManager.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.9), value: isVisible)
    }
}

#if DEBUG
#Preview {
    SurahExperienceScreen()
}
#endif
