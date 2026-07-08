//
//  JourneyModeToggle.swift
//  Thaqalayn
//
//  The segmented "Read & Tafsir | Journey" control attached under a sūrah's
//  Quran-list card (browse + search), for sūrahs that have a built "Inside the
//  Sūrah" experience. The Read tab pushes the reading view; the Journey tab
//  opens the immersive dive (premium-gated). The Journey tab is alive - a
//  breathing glow, a diagonal light-sweep, and embers rising behind the label -
//  to signal an experience waiting behind the tap. No icon, no arrow.
//
//  Pure chrome: fixed sizes, no reading-scale. Theme-adaptive (Midnight Emerald
//  + standard); the handoff's gold-on-dark palette is intentionally ignored in
//  favour of the app's own accent. Ambient motion is disabled under Reduce
//  Motion (the Journey tab keeps a soft static glow).
//
//  Recreated from design_handoff_immersive_journey_tab (variant 5a).
//

import SwiftUI

/// The split-toggle region under a sūrah card. Squared top + rounded bottom with
/// a hairline top divider so the card and the toggle read as one card - matching
/// the `squaredBottom` treatment on `ModernSurahCard`.
struct JourneyModeToggle<ReadDestination: View>: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    let descriptor: SurahExperienceDescriptor
    /// True when the experience is premium-gated for this user - surfaces a PREMIUM chip.
    let locked: Bool
    /// The reading view for this sūrah; the Read tab pushes it.
    @ViewBuilder var readDestination: () -> ReadDestination
    /// Fired when the Journey tab is tapped (the caller runs the premium check).
    let onJourney: () -> Void
    /// False when the row draws a single combined border around card + toggle,
    /// so this region must not stroke its own (seam-creating) outline.
    var showsOuterBorder = true

    /// Matches `ModernSurahCard`'s fill so the card and toggle read as one surface.
    private var surfaceFill: Color { tm.isMidnightEmerald ? tm.glassSurface : .white }

    /// Card-continuation shape: squared top (meets the card above), rounded bottom.
    private var regionShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 20,
                               bottomTrailingRadius: 20, topTrailingRadius: 0,
                               style: .continuous)
    }

    var body: some View {
        VStack(spacing: 8) {
            if locked {
                HStack(spacing: 0) { Spacer(minLength: 0); premiumChip }
            }
            // Segmented track (recessed) holding the two equal-width tabs.
            HStack(spacing: 8) {
                readTab
                journeyTab
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tm.glassSurfaceRecessed)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tm.strokeColor, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background(regionShape.fill(surfaceFill))
        .overlay {
            if showsOuterBorder {
                regionShape.stroke(tm.strokeColor, lineWidth: 1)
            }
        }
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }

    // MARK: Read tab (inactive - pushes the reading view)

    private var readTab: some View {
        PressableNavLink {
            readDestination()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 13, weight: .semibold))
                Text(JourneyStrings.readAndTafsir(lang))
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1).minimumScaleFactor(0.8)
            }
            .foregroundColor(tm.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
    }

    // MARK: Journey tab (active - animated, opens the dive)

    private var journeyTab: some View {
        Button(action: onJourney) {
            AnimatedJourneyTab(label: JourneyStrings.journey(lang),
                               gradient: tm.accentGradient,
                               glowColor: tm.accentColor)
        }
        .buttonStyle(EmPressStyle())
    }

    /// "PREMIUM" chip in the app's accent-chip treatment - never a lock glyph.
    private var premiumChip: some View {
        Text(JourneyStrings.premium(lang).uppercased())
            .font(.system(size: 9, weight: .bold)).tracking(1.4)
            .foregroundColor(tm.accentColor)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(tm.accentChip))
            .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
    }
}

// MARK: - The living Journey tab

/// The filled accent "Journey" tab, alive with three layered ambient animations:
/// a breathing glow, a diagonal light-sweep, and embers rising behind the label.
/// No icon, no arrow. All motion halts under Reduce Motion.
private struct AnimatedJourneyTab: View {
    let label: String
    let gradient: LinearGradient
    let glowColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false
    @State private var sweepPhase: CGFloat = 0

    /// Dark ink for the label sitting on the warm accent fill (handoff #14150D).
    private let ink = Color(hex: "14150D")
    /// Warm highlight shared by the sweep and the embers (handoff #FFF6DC).
    private let warmLight = Color(hex: "FFF6DC")
    private let shape = RoundedRectangle(cornerRadius: 11, style: .continuous)

    var body: some View {
        Text(label)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(ink)
            .lineLimit(1).minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(shape.fill(gradient))
            .overlay { if !reduceMotion { lightSweep } }
            .overlay { if !reduceMotion { embers } }
            .overlay(innerGlow)
            .clipShape(shape)
            .shadow(color: glowColor.opacity(breathe ? 0.5 : 0.24),
                    radius: breathe ? 16 : 9, x: 0, y: breathe ? 6 : 4)
            .onAppear(perform: startAmbient)
    }

    private func startAmbient() {
        guard !reduceMotion else { return }
        // Breathing glow - 3.6s full cycle (1.8s each way).
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            breathe = true
        }
        // Light-sweep drift - 3.6s, resets off-screen so the loop is seamless.
        withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: false)) {
            sweepPhase = 1
        }
    }

    /// Warm inner glow that swells with the breath (approximates the CSS inset glow).
    private var innerGlow: some View {
        shape
            .stroke(warmLight.opacity(reduceMotion ? 0.10 : (breathe ? 0.20 : 0.05)), lineWidth: 6)
            .blur(radius: 7)
            .clipShape(shape)
            .allowsHitTesting(false)
    }

    /// A narrow bright band, skewed ~-18°, passing left -> right across the tab.
    private var lightSweep: some View {
        GeometryReader { geo in
            let w = geo.size.width
            Rectangle()
                .fill(LinearGradient(
                    colors: [warmLight.opacity(0), warmLight.opacity(0.55), warmLight.opacity(0)],
                    startPoint: .leading, endPoint: .trailing))
                .frame(width: w * 0.38)
                // skewX(-18deg): x' = x + tan(-18°)*y
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: -0.3249, d: 1, tx: 0, ty: 0))
                .offset(x: -0.53 * w + sweepPhase * 1.44 * w)
        }
        .allowsHitTesting(false)
    }

    /// Three faint embers drifting up behind the label, giving warmth/depth.
    private var embers: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                RisingEmber(color: warmLight, size: 3.0, driftX: 14, riseY: -10, duration: 3.2, delay: 0.15, peak: 0.9)
                    .position(x: w * 0.22, y: h - 8)
                RisingEmber(color: warmLight, size: 2.0, driftX: -12, riseY: -12, duration: 3.8, delay: 0.55, peak: 0.8)
                    .position(x: w * 0.50, y: h - 6)
                RisingEmber(color: warmLight, size: 2.5, driftX: 8, riseY: -14, duration: 3.4, delay: 1.1, peak: 1.0)
                    .position(x: w * 0.72, y: h - 9)
            }
        }
        .allowsHitTesting(false)
    }
}

/// One ember: fades in, drifts up-and-sideways, fades out - looping forever.
private struct RisingEmber: View {
    let color: Color
    let size: CGFloat
    let driftX: CGFloat   // end x offset
    let riseY: CGFloat    // end y offset (negative = up)
    let duration: Double
    let delay: Double     // staggers the loop start
    let peak: Double      // brightest opacity mid-drift

    private struct Drift: Equatable {
        var x: CGFloat = 0
        var y: CGFloat = 6   // starts just below the anchor
        var opacity: Double = 0
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .keyframeAnimator(initialValue: Drift(), repeating: true) { view, v in
                view.offset(x: v.x, y: v.y).opacity(v.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0, duration: delay)
                    CubicKeyframe(peak, duration: duration * 0.30)
                    CubicKeyframe(0, duration: duration * 0.70)
                }
                KeyframeTrack(\.x) {
                    LinearKeyframe(0, duration: delay)
                    LinearKeyframe(driftX, duration: duration)
                }
                KeyframeTrack(\.y) {
                    LinearKeyframe(6, duration: delay)
                    LinearKeyframe(riseY, duration: duration)
                }
            }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 0) {
            JourneyModeToggle(
                descriptor: SurahExperienceDescriptor.byId("surah-yusuf")!,
                locked: true,
                readDestination: { Text("Reading view") },
                onJourney: {}
            )
        }
        .padding()
    }
}
#endif
