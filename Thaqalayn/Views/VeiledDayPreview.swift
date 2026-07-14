//
//  VeiledDayPreview.swift
//  Thaqalayn
//
//  The veiled preview a non-subscriber lands on when they open a locked journey day.
//  The app has one veil: this mirrors the Deep Dive veil (DeepDiveView.veilPage) so a
//  gated day and a gated descent feel like the same gesture. It shows the day's theme
//  and its opening line - a real taste, not a wall - then names what waits beneath, and
//  never a lock (house rule). Its one button opens the contextual paywall.
//
//  Always dark, like the dive: it reuses DeepDivePalette regardless of the app theme,
//  because a premium reveal is a cinematic moment, not a themed screen.
//

import SwiftUI

/// Local fade + rise reveal, matching DeepDiveView's `reveal`. Disabled under reduce-motion.
private extension View {
    func revealDay(_ shown: Bool, _ delay: Double = 0, reduce: Bool) -> some View {
        opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 20)
            .animation(reduce ? nil : .easeOut(duration: 0.7).delay(delay), value: shown)
    }
}

struct VeiledDayPreview: View {
    /// Localized unit label shown as the eyebrow, e.g. "Muharram · Day 3" or
    /// "Arbaeen · Station 3" - built by the caller so each journey names its own unit.
    let dayLabel: String
    /// Localized theme title + its Arabic.
    let theme: String
    let themeArabic: String
    /// The day's opening line (its localized tafsir focus) - the taste that is shown for real.
    let openingLine: String
    /// How many verses wait beneath the veil (named, not shown).
    let verseCount: Int
    /// Arbaeen calls its units "stations", not "days" - swaps the unit noun in the copy.
    var unitIsStation: Bool = false
    /// The journey cover, blurred behind the veil so something is felt to be there.
    let coverAssetName: String
    /// Drives the paywall the unlock button opens - carries this journey's art + name.
    let paywallContext: PaywallContext

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var reading = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var showingPaywall = false
    @State private var shown = false

    private var s: CGFloat { reading.scale }
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                veiledArt(size: geo.size)

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 74)
                        header
                        Spacer(minLength: 34)
                        veilSection
                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: 480)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity, minHeight: geo.size.height)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)

                closeButton
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(context: paywallContext)
        }
        .onAppear {
            if reduceMotion { shown = true }
            else { withAnimation(.easeOut(duration: 0.6)) { shown = true } }
        }
    }

    // MARK: The taste - theme + opening line

    private var header: some View {
        VStack(spacing: 0) {
            Text(dayLabel.uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(3)
                .foregroundColor(DeepDivePalette.gold)
                .multilineTextAlignment(.center)
                .revealDay(shown, 0, reduce: reduceMotion)

            Text(themeArabic)
                .font(EmType.arabic(34))
                .foregroundColor(DeepDivePalette.goldBright)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.top, 18)
                .revealDay(shown, 0.12, reduce: reduceMotion)

            Text(theme)
                .font(EmType.serif(28))
                .foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .padding(.top, 10)
                .revealDay(shown, 0.24, reduce: reduceMotion)

            hairline.padding(.vertical, 24).revealDay(shown, 0.34, reduce: reduceMotion)

            // Reading content - scales with the reading text-size control.
            Text(openingLine)
                .font(EmType.serifItalic(17 * s))
                .foregroundColor(Color(white: 0.74))
                .multilineTextAlignment(.center)
                .lineSpacing(5 * s)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .revealDay(shown, 0.44, reduce: reduceMotion)
        }
    }

    // MARK: The veil - what waits beneath

    private var veilSection: some View {
        VStack(spacing: 0) {
            Text(JourneyStrings.dayVeilEyebrow(station: unitIsStation, lang).uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(4)
                .foregroundColor(DeepDivePalette.gold)
                .multilineTextAlignment(.center)
                .revealDay(shown, 0.54, reduce: reduceMotion)

            VStack(alignment: .leading, spacing: 15) {
                ForEach(Array(beneath.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .firstTextBaseline, spacing: 14) {
                        Circle()
                            .fill(DeepDivePalette.gold.opacity(0.8))
                            .frame(width: 5, height: 5)
                        Text(line)
                            .font(EmType.serif(18 * s, .medium))
                            .foregroundColor(DeepDivePalette.cream.opacity(0.66))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            .padding(.top, 22)
            .revealDay(shown, 0.64, reduce: reduceMotion)

            hairline.padding(.vertical, 26).revealDay(shown, 0.74, reduce: reduceMotion)

            unlockButton.revealDay(shown, 0.82, reduce: reduceMotion)

            Text("\(JourneyStrings.premium(lang)) \u{00B7} \(JourneyStrings.veilNote(lang))")
                .font(.system(size: 11))
                .foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
                .revealDay(shown, 0.82, reduce: reduceMotion)
        }
    }

    /// What lies beneath, named in plain words. Every day carries these three.
    private var beneath: [String] {
        [JourneyStrings.dayVeilDua(lang),
         JourneyStrings.dayVeilVerses(verseCount, lang),
         JourneyStrings.dayVeilReflection(station: unitIsStation, lang)]
    }

    private var unlockButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            showingPaywall = true
        } label: {
            Text(JourneyStrings.dayVeilCta(station: unitIsStation, lang))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(.sRGB, red: 11.0 / 255.0, green: 20.0 / 255.0,
                                       blue: 15.0 / 255.0, opacity: 1))
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(
                        LinearGradient(colors: [DeepDivePalette.goldBright, DeepDivePalette.gold],
                                       startPoint: .top, endPoint: .bottom))
                )
                .shadow(color: DeepDivePalette.gold.opacity(0.35), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(EmPressStyle())
    }

    // MARK: Chrome

    /// The journey cover, blurred until only its shape survives - the same treatment the
    /// dive veil gives its cover, so the two veils read as one.
    private func veiledArt(size: CGSize) -> some View {
        Image(coverAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            // Overscan before blurring: a blur samples past its bounds, so without the
            // extra material the frame picks up a dark vignette at every edge.
            .scaleEffect(1.22)
            .blur(radius: 44, opaque: true)
            .frame(width: size.width, height: size.height)
            .clipped()
            // Heavier than the dive's 0.46: this veil also carries the theme + opening
            // line as overlaid text, which needs the extra contrast.
            .overlay(Color.black.opacity(0.52))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .ignoresSafeArea()
    }

    private var closeButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DeepDivePalette.cream)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(DeepDivePalette.gold.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 8)
    }

    private var hairline: some View {
        Rectangle().fill(DeepDivePalette.gold.opacity(0.3)).frame(width: 26, height: 1)
    }
}
