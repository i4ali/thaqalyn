//
//  DeepDiveBackground.swift
//  Thaqalayn
//
//  The progress-driven "descent" background for an immersive Deep Dive.
//  Ports the visual math from MajlisYaqeen.jsx: the BG_STOPS colour ramp, the
//  VIG_STOPS vignette-opacity ramp, the piecewise-linear interp()/lerpColor()
//  helpers, and the rising gold light-"motes" (16 small drifting dots).
//
//  Self-contained: SwiftUI + Foundation only, no app-specific types.
//

import SwiftUI

// MARK: - Palette + interpolation math

/// Colours and the two progress ramps (background + vignette) that drive the
/// descent, plus the piecewise-linear interpolation used to sample them.
enum DeepDivePalette {

    // Fixed accent colours (from MajlisYaqeen.jsx). Built explicitly in sRGB so
    // this file needs no Color(hex:) helper.
    static let gold       = Color(.sRGB, red: 201.0/255.0, green: 165.0/255.0, blue:  92.0/255.0, opacity: 1) // #C9A55C
    static let goldBright = Color(.sRGB, red: 227.0/255.0, green: 195.0/255.0, blue: 126.0/255.0, opacity: 1) // #E3C37E
    static let cream      = Color(.sRGB, red: 236.0/255.0, green: 231.0/255.0, blue: 219.0/255.0, opacity: 1) // #ECE7DB
    static let mute       = Color(.sRGB, red: 143.0/255.0, green: 154.0/255.0, blue: 140.0/255.0, opacity: 1) // #8F9A8C

    /// Background colour stops (BG_STOPS). `p` is the descent progress 0...1;
    /// r/g/b are already normalised to 0...1 (hex value divided by 255).
    static let bgStops: [(p: CGFloat, r: Double, g: Double, b: Double)] = [
        (0.00, 15.0/255.0, 23.0/255.0, 18.0/255.0), // #0F1712
        (0.32, 11.0/255.0, 17.0/255.0, 13.0/255.0), // #0B110D
        (0.55,  7.0/255.0, 10.0/255.0,  8.0/255.0), // #070A08
        (0.72,  4.0/255.0,  6.0/255.0,  5.0/255.0), // #040605
        (0.82,  2.0/255.0,  4.0/255.0,  3.0/255.0), // #020403
        (0.90,  6.0/255.0, 16.0/255.0, 11.0/255.0), // #06100B
        (1.00, 11.0/255.0, 20.0/255.0, 15.0/255.0), // #0B140F
    ]

    /// Vignette-opacity stops (VIG_STOPS): how dark the outer vignette gets at
    /// each depth. `o` is the black opacity 0...1.
    static let vigStops: [(p: CGFloat, o: Double)] = [
        (0.00, 0.32),
        (0.55, 0.60),
        (0.82, 0.94),
        (1.00, 0.50),
    ]

    /// Piecewise-linear background colour at descent progress `p` (clamped 0...1).
    static func bg(_ p: CGFloat) -> Color {
        let cp = min(max(p, 0), 1)
        let stops = bgStops
        for i in 0 ..< (stops.count - 1) {
            let a = stops[i], b = stops[i + 1]
            if cp >= a.p && cp <= b.p {
                let span = b.p - a.p
                let t = span > 0 ? Double((cp - a.p) / span) : 0
                return Color(.sRGB,
                             red:   a.r + (b.r - a.r) * t,
                             green: a.g + (b.g - a.g) * t,
                             blue:  a.b + (b.b - a.b) * t,
                             opacity: 1)
            }
        }
        let last = stops[stops.count - 1]
        return Color(.sRGB, red: last.r, green: last.g, blue: last.b, opacity: 1)
    }

    /// Piecewise-linear vignette opacity at descent progress `p` (clamped 0...1).
    static func vignette(_ p: CGFloat) -> Double {
        let cp = min(max(p, 0), 1)
        let stops = vigStops
        for i in 0 ..< (stops.count - 1) {
            let a = stops[i], b = stops[i + 1]
            if cp >= a.p && cp <= b.p {
                let span = b.p - a.p
                let t = span > 0 ? Double((cp - a.p) / span) : 0
                return a.o + (b.o - a.o) * t
            }
        }
        return stops[stops.count - 1].o
    }
}

// MARK: - Rising motes (shared)

/// Slow rising gold light-motes over a transparent background. Extracted from
/// `DeepDiveBackground` so both the immersive descent and the onboarding
/// `DeepDiveScreen` share one implementation. Honours Reduce Motion (a static
/// scatter with no per-frame redraw).
struct DeepDiveMotes: View {
    /// How many motes to draw. The immersive background uses 16.
    let count: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Random mote parameters, generated ONCE so they stay stable across redraws.
    @State private var motes: [Mote]

    init(count: Int = 16) {
        self.count = count
        _motes = State(initialValue: DeepDiveMotes.makeMotes(count))
    }

    var body: some View {
        Group {
            if reduceMotion {
                // Reduce Motion: draw the motes once at fixed scattered positions,
                // with no animation and no per-frame redraw.
                moteCanvas(time: nil)
            } else {
                // Continuous slow rise: each mote loops on its own 16-36s period,
                // phase-staggered, forever.
                TimelineView(.animation) { timeline in
                    moteCanvas(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            }
        }
        .allowsHitTesting(false)
    }

    /// Draws all motes. `time == nil` -> static placement (Reduce Motion).
    private func moteCanvas(time: Double?) -> some View {
        Canvas { ctx, size in
            for mote in motes {
                // Vertical fraction: animated rise from just below the bottom
                // (1.08) up to just above the top (-0.08); static scatter otherwise.
                let yFrac: CGFloat = time.map { 1.08 - 1.16 * mote.phase(at: $0) } ?? mote.seed
                let x = mote.x * size.width
                let y = yFrac * size.height
                let d = mote.size
                let rect = CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d)
                ctx.fill(Path(ellipseIn: rect),
                         with: .color(DeepDivePalette.goldBright.opacity(mote.opacity)))
            }
        }
        .blur(radius: 0.3)
        .allowsHitTesting(false)
    }

    /// One rising light-mote. Parameters mirror the JSX `motes` state.
    private struct Mote: Identifiable {
        let id = UUID()
        let x: CGFloat          // horizontal position, 0...1 of width
        let size: CGFloat       // diameter, 1...3 pt
        let duration: Double    // rise period, 16...36 s
        let delay: Double       // CSS-style negative stagger, -30...0 s
        let opacity: Double     // 0.06...0.22
        let seed: CGFloat       // fixed vertical placement (0...1) for Reduce Motion

        /// Loop phase 0...1 at absolute `time`. A negative `delay` shifts the
        /// phase so the motes are already spread out rather than starting in unison.
        func phase(at time: Double) -> CGFloat {
            let cycles = (time - delay) / duration
            return CGFloat(cycles - cycles.rounded(.down))
        }
    }

    /// Generates the motes' random parameters once.
    private static func makeMotes(_ count: Int) -> [Mote] {
        (0 ..< count).map { _ in
            Mote(
                x: CGFloat.random(in: 0 ... 1),
                size: CGFloat.random(in: 1 ... 3),
                duration: Double.random(in: 16 ... 36),
                delay: -Double.random(in: 0 ... 30),
                opacity: Double.random(in: 0.06 ... 0.22),
                seed: CGFloat.random(in: 0 ... 1)
            )
        }
    }
}

// MARK: - Descent background view

/// Immersive background whose colour + vignette deepen as `progress` (0...1)
/// advances, with slow rising gold motes drifting up the screen.
struct DeepDiveBackground: View {
    /// Descent progress, 0 (surface) ... 1 (deepest).
    var progress: CGFloat

    var body: some View {
        ZStack {
            // Base fill: interpolated background colour. Animates smoothly when
            // progress changes so discrete jumps cross-fade.
            DeepDivePalette.bg(progress)
                .animation(.linear(duration: 0.4), value: progress)

            // Rising gold light-motes (shared implementation).
            DeepDiveMotes()

            // Vignette on top: transparent core, darkening toward the edges,
            // centred slightly above the middle.
            GeometryReader { geo in
                let vig = DeepDivePalette.vignette(progress)
                let maxDim = max(geo.size.width, geo.size.height)
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.30),
                        .init(color: Color.black.opacity(vig), location: 1.0),
                    ]),
                    center: UnitPoint(x: 0.5, y: 0.42),
                    startRadius: 0,
                    endRadius: maxDim * 0.72
                )
                .animation(.linear(duration: 0.4), value: progress)
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Descent 0.0 / 0.5 / 1.0") {
    HStack(spacing: 0) {
        ForEach([0.0, 0.5, 1.0] as [CGFloat], id: \.self) { p in
            ZStack {
                DeepDiveBackground(progress: p)
                VStack {
                    Spacer()
                    Text(String(format: "%.1f", Double(p)))
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.bottom, 28)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
    }
    .ignoresSafeArea()
}
#endif
