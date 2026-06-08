//
//  HadithScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 1: Hadith of Thaqalayn
//

import SwiftUI

struct HadithScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var currentPage: Int
    @State private var isVisible = false
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .peach)

            // Ambient drifting gold embers behind the card
            FloatingEmbers()
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 1.2).delay(0.5), value: isVisible)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 40) {
                    // Title with glow
                    Text("Hadith of Thaqalayn")
                        .onbHeroTitle()
                        .foregroundColor(themeManager.primaryText)
                        .overlay(
                            GeometryReader { geometry in
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.5),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: geometry.size.width * 0.4)
                                .offset(x: shimmerOffset * geometry.size.width * 1.5)
                                .blendMode(.overlay)
                            }
                            .mask(
                                Text("Hadith of Thaqalayn")
                                    .onbHeroTitle()
                            )
                        )
                        .background(
                            Ellipse()
                                .fill(Color(hex: "ECD49A").opacity(0.16))
                                .frame(width: 200, height: 70)
                                .blur(radius: 20)
                                .scaleEffect(glowPulse ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                                    value: glowPulse
                                )
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: isVisible)

                    VStack(spacing: 24) {
                        // Arabic Hadith
                        Text("إني تارك فيكم الثقلين:\nكتاب الله وعترتي أهل بيتي،\nما إن تمسكتم بهما\nلن تضلوا بعدي أبداً")
                            .font(.system(size: 26, weight: .medium, design: .serif))
                            .foregroundColor(themeManager.primaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, 30)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 30)
                            .animation(Animation.easeOut(duration: 0.8).delay(0.6), value: isVisible)

                        // Divider
                        Capsule()
                            .fill(Color(hex: "ECD49A"))
                            .frame(width: 60, height: 3)
                            .opacity(isVisible ? 1 : 0)
                            .scaleEffect(x: isVisible ? 1 : 0, y: 1)
                            .animation(Animation.easeOut(duration: 0.5).delay(0.9), value: isVisible)

                        // English Translation
                        VStack(spacing: 12) {
                            Text("\"I am leaving among you two weighty things:")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.primaryText)

                            Text("the Book of Allah and my progeny,")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.primaryText)

                            Text("the people of my household.")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.primaryText)

                            Text("As long as you hold fast to them,")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.primaryText)

                            Text("you shall never go astray.\"")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                        }
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.8).delay(1.1), value: isVisible)

                        // Attribution
                        Text("— Prophet Muhammad ﷺ")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(1.4), value: isVisible)
                    }
                    .onboardingCard()
                    .padding(.horizontal, 22)
                }

                Spacer()

                // Tap to continue hint
                VStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)

                    Text("Swipe or tap to continue")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .opacity(isVisible ? 0.7 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(1.7), value: isVisible)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isVisible = true
            startTitleAnimations()

            // Auto-advance after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentPage = 1
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentPage = 1
            }
        }
    }

    private func startTitleAnimations() {
        // Start glow pulse after initial fade-in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            glowPulse = true
        }
        // Start shimmer after initial animation
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

// MARK: - Geometric Pattern Background

struct GeometricPatternBackground: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            // Subtle gradient
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Very subtle geometric pattern overlay
            Canvas { context, size in
                let spacing: CGFloat = 40
                let lineWidth: CGFloat = 0.5

                for x in stride(from: 0, through: size.width, by: spacing) {
                    for y in stride(from: 0, through: size.height, by: spacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x + spacing, y: y + spacing))

                        context.stroke(
                            path,
                            with: .color(themeManager.strokeColor.opacity(0.1)),
                            lineWidth: lineWidth
                        )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Floating Embers (ambient gold bokeh)

/// A self-contained ambient layer of soft gold embers that drift slowly
/// upward with a gentle sideways sway, materialising and dissolving via a
/// height-based opacity envelope so they loop seamlessly. Rendered in a single
/// GPU-drawn `Canvas` driven by `TimelineView` for a smooth, cheap effect.
/// Honours Reduce Motion by falling back to a faint static scatter.
private struct FloatingEmbers: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Ember {
        let baseX: Double        // 0...1 fraction of width
        let startY: Double       // 0...1 initial vertical fraction
        let radius: Double       // glow radius in points
        let speed: Double        // vertical fraction of height per second
        let swayAmp: Double      // horizontal sway in points
        let swayFreq: Double     // radians per second
        let phase: Double        // per-ember phase offset
        let peakOpacity: Double
        let twinkleFreq: Double
    }

    // Generated once and shared — stable across redraws.
    private static let embers: [Ember] = (0..<16).map { _ in
        let r = Double.random(in: 3...13)
        return Ember(
            baseX: .random(in: 0.04...0.96),
            startY: .random(in: 0...1),
            radius: r,
            speed: .random(in: 0.05...0.085),       // ~12–20s top-to-bottom
            swayAmp: .random(in: 6...22),
            swayFreq: .random(in: 0.15...0.45),
            phase: .random(in: 0...(2 * .pi)),
            peakOpacity: 0.12 + (r / 13) * 0.38,     // larger embers glow brighter
            twinkleFreq: .random(in: 0.3...0.9)
        )
    }

    var body: some View {
        Group {
            if reduceMotion {
                Canvas { context, size in
                    draw(context, size: size, t: 0)
                }
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        draw(context, size: size, t: t)
                    }
                }
            }
        }
        .blendMode(.screen)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func draw(_ context: GraphicsContext, size: CGSize, t: TimeInterval) {
        let gold = Color(hex: "ECD49A")
        let w = Double(size.width)
        let h = Double(size.height)

        for e in Self.embers {
            // Drift upward, wrapping seamlessly from top back to bottom.
            var p = (e.startY - e.speed * t).truncatingRemainder(dividingBy: 1)
            if p < 0 { p += 1 }

            let y = p * h
            let x = e.baseX * w + sin(t * e.swayFreq + e.phase) * e.swayAmp

            // Fade in low, fade out near the top, plus a faint twinkle.
            let envelope = sin(p * .pi)
            let twinkle = 0.78 + 0.22 * sin(t * e.twinkleFreq + e.phase)
            let opacity = max(0, e.peakOpacity * envelope * twinkle)

            let r = CGFloat(e.radius)
            let cx = CGFloat(x)
            let cy = CGFloat(y)

            // Soft halo
            context.fill(
                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                with: .radialGradient(
                    Gradient(colors: [gold.opacity(opacity * 0.6), .clear]),
                    center: CGPoint(x: cx, y: cy),
                    startRadius: 0,
                    endRadius: r
                )
            )

            // Bright core
            let cr = r * 0.32
            context.fill(
                Path(ellipseIn: CGRect(x: cx - cr, y: cy - cr, width: cr * 2, height: cr * 2)),
                with: .color(gold.opacity(min(opacity * 1.5, 0.9)))
            )
        }
    }
}

#Preview {
    HadithScreen(currentPage: .constant(0))
}
