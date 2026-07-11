//
//  MissionScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 2: App Mission.
//  A "manifesto" screen - a punchy claim (this is not just another Quran app)
//  that resolves into four gold-verb beats: Reflect, Journey, Descend, and
//  Beside (the Ahlul Bayt). The two weighty things - the Book and the Ahlul
//  Bayt - are the app's namesake (Hadith of Thaqalayn), crowned here by the
//  ثقلين wordmark. English-only, matching the rest of onboarding.
//

import SwiftUI

struct MissionScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var glowPulse = false
    @State private var shimmer: CGFloat = -1

    private let gold = Color(hex: "ECD49A")
    private let wordmark = "ثقلين"

    /// A single manifesto beat: a gold verb and the line it governs.
    private struct Beat {
        let verb: String
        let line: String
    }

    private let beats: [Beat] = [
        Beat(verb: "Reflect", line: "on a verse until it stays with you."),
        Beat(verb: "Journey", line: "through the seasons of faith, day by day."),
        Beat(verb: "Descend", line: "layer by layer, into the words you thought you knew."),
        Beat(verb: "Walk",    line: "beside the Ahlul Bayt, who never leave the Quran's side."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 0) {
                // Brand wordmark (ثقلين = "the two weighty things"), centered and
                // crowned by a gently breathing gold glow, with two doves - the
                // two weighty things - wheeling slowly through it. No .blur and
                // no .blendMode here: both used to escape the paged TabView's
                // compositor as a full-width luminance band.
                ZStack {
                    Ellipse()
                        .fill(RadialGradient(
                            colors: [gold.opacity(0.20), gold.opacity(0.07), .clear],
                            center: .center, startRadius: 0, endRadius: 105))
                        .frame(width: 230, height: 170)
                        .scaleEffect(glowPulse ? 1.06 : 0.92)
                        .opacity(glowPulse ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: glowPulse)

                    ThaqalaynDovesLayer()

                    Text(wordmark)
                        .font(EmType.arabic(54))
                        .foregroundColor(gold)
                        .overlay(
                            // Gold sweep that travels across the letters.
                            GeometryReader { geo in
                                LinearGradient(
                                    colors: [.clear, Color(hex: "FFF4D2").opacity(0.75), .clear],
                                    startPoint: .leading, endPoint: .trailing)
                                    .frame(width: geo.size.width * 0.55)
                                    .offset(x: shimmer * geo.size.width * 1.7)
                            }
                            .mask(Text(wordmark).font(EmType.arabic(54)))
                        )
                        .scaleEffect(isVisible ? 1 : 0.6)
                        .opacity(isVisible ? 0.95 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.62).delay(0.12), value: isVisible)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 132)

                // Manifesto headline
                Text("This was never meant to be just another Quran app.")
                    .font(EmType.serif(30))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 22)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 22)
                    .animation(.easeOut(duration: 0.6).delay(0.30), value: isVisible)

                // Four gold-verb beats
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(Array(beats.enumerated()), id: \.offset) { index, beat in
                        if index > 0 {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [gold.opacity(0.30), .clear],
                                    startPoint: .leading, endPoint: .trailing))
                                .frame(height: 1)
                                .opacity(isVisible ? 1 : 0)
                                .animation(.easeOut(duration: 0.5).delay(0.55 + Double(index) * 0.14), value: isVisible)
                        }

                        BeatRow(verb: beat.verb, line: beat.line, gold: gold,
                                lineColor: Color(hex: "F1E8D6").opacity(0.88))
                            .opacity(isVisible ? 1 : 0)
                            .offset(x: isVisible ? 0 : -24)
                            .animation(.easeOut(duration: 0.55).delay(0.50 + Double(index) * 0.14), value: isVisible)
                    }
                }
                .padding(.top, 44)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 34)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .lavender))
        .onAppear {
            isVisible = true
            glowPulse = true
            startShimmer()
        }
    }

    /// Kicks off a repeating gold sweep across the wordmark, after the
    /// entrance settles.
    private func startShimmer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: false)) {
                shimmer = 1
            }
        }
    }
}

// MARK: - Beat Row

private struct BeatRow: View {
    let verb: String
    let line: String
    let gold: Color
    let lineColor: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(verb)
                .font(EmType.serif(29))
                .foregroundColor(gold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 132, alignment: .leading)

            Text(line)
                .font(EmType.serifItalic(20))
                .foregroundColor(lineColor)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - The two doves

/// Two ivory doves - the two weighty things of the wordmark - wheeling slowly
/// on a wide ellipse through the ثقلين glow. Same Canvas + TimelineView idiom
/// as ShrineDovesLayer on screen 1, radically simplified: two birds, one
/// orbit, gentle flap. Drawn beneath the wordmark text so they pass behind
/// the letters. Honours Reduce Motion with a static pair.
private struct ThaqalaynDovesLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate = Date()

    private static let ivory = Color(hex: "F3EAD6")

    var body: some View {
        Group {
            if reduceMotion {
                Canvas { context, size in
                    Self.draw(context, size: size, t: 1.2, animated: false)
                }
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let t = timeline.date.timeIntervalSince(startDate)
                        Self.draw(context, size: size, t: t, animated: true)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private static func draw(_ context: GraphicsContext, size: CGSize, t: Double, animated: Bool) {
        let cx = size.width / 2
        let cy = size.height / 2
        let rx = min(size.width * 0.40, 150)
        let ry = size.height * 0.34

        for i in 0..<2 {
            // Opposite points of one shared orbit.
            let theta = t * 0.32 + Double(i) * .pi
            let x = cx + cos(theta) * rx
            let y = cy + sin(theta) * ry
            // Heading from the orbit tangent, for a gentle bank.
            let bank = max(-0.4, min(0.4, cos(theta) * 0.35))
            // Depth cue: slightly smaller and fainter on the "far" half.
            let depth = 0.72 + 0.28 * (sin(theta) + 1) / 2
            let ds = 8.5 * depth
            let alpha = 0.30 + 0.35 * depth
            let lift = animated
                ? sin(t * 9 + Double(i) * 2.1) * ds * 0.45
                : ds * 0.2

            var ctx = context
            ctx.translateBy(x: x, y: y)
            ctx.rotate(by: .radians(bank))

            var wings = Path()
            wings.move(to: CGPoint(x: -ds, y: -lift))
            wings.addQuadCurve(to: .zero, control: CGPoint(x: -ds * 0.45, y: ds * 0.22))
            wings.addQuadCurve(to: CGPoint(x: ds, y: -lift), control: CGPoint(x: ds * 0.45, y: ds * 0.22))
            ctx.stroke(
                wings,
                with: .color(ivory.opacity(alpha)),
                style: StrokeStyle(lineWidth: max(1.0, ds * 0.22), lineCap: .round)
            )
            ctx.fill(
                Path(ellipseIn: CGRect(x: -ds * 0.18, y: -ds * 0.06, width: ds * 0.36, height: ds * 0.24)),
                with: .color(ivory.opacity(alpha))
            )
        }
    }
}

#Preview {
    MissionScreen()
}
