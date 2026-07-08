//
//  SurahExperienceScreen.swift
//  Thaqalayn
//
//  Onboarding screen: a teaser for the immersive "Inside the Sūrah" feature -
//  entering a whole chapter and living its full arc, first verse to last (the
//  sibling of the Deep Dive teaser, which descends through a single theme).
//  Conveys the feature's breadth by cross-fading a hero through the catalog's
//  featured sūrahs (Yūsuf, Yāsīn, al-Raḥmān, al-Mulk), each with its one-line
//  story. English-only, matching the rest of onboarding. Reuses the shared
//  DeepDivePalette + DeepDiveMotes for fidelity with the real feature.
//

import SwiftUI

struct SurahExperienceScreen: View {
    @StateObject private var themeManager = ThemeManager.shared

    @State private var isVisible = false      // staggered entrance
    @State private var haloPulse = false      // hero glow breathes
    @State private var index = 0              // which sūrah the hero shows

    /// Featured sūrahs a user can step inside (drawn from the real
    /// "Inside the Sūrah" catalog - `SurahExperienceDescriptor.all`).
    private let surahs: [(ar: String, en: String, story: String)] = [
        ("يُوسُف",      "Sūrah Yūsuf",     "The most beautiful of stories - loss, patience, reunion."),
        ("يس",          "Sūrah Yāsīn",     "The heart of the Qur'an - and what it keeps asking you."),
        ("الرَّحْمَٰن",  "Sūrah al-Raḥmān", "One question, asked thirty-one times."),
        ("الْمُلْك",     "Sūrah al-Mulk",   "The protector - whose hand holds the kingdom."),
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

    // MARK: - Background (a gentler read of the descent ramp, top -> bottom)

    private var descentBackground: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: DeepDivePalette.bg(0.00), location: 0.0),
                .init(color: DeepDivePalette.bg(0.32), location: 0.35),
                .init(color: DeepDivePalette.bg(0.55), location: 0.64),
                .init(color: DeepDivePalette.bg(0.82), location: 1.0),
            ]),
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
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
            Text("Inside the Sūrah")
                .onbEyebrow()
                .foregroundColor(DeepDivePalette.gold)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -16)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

            Text("Step inside\na whole sūrah")
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

    // MARK: - Cross-fading sūrah hero (always-on motion + breadth of sūrahs)

    private var surahHero: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [DeepDivePalette.goldBright.opacity(0.20), .clear],
                    center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .scaleEffect(haloPulse ? 1.08 : 0.96)
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true),
                           value: haloPulse)

            VStack(spacing: 12) {
                Text(surahs[index].ar)
                    .font(EmType.arabic(68))
                    .foregroundColor(DeepDivePalette.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(surahs[index].en.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(3)
                    .foregroundColor(DeepDivePalette.gold)
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
        Text("Find sūrah experiences in the Journey tab")
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
