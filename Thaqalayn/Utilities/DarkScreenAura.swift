//
//  DarkScreenAura.swift
//  Thaqalayn
//
//  View modifier that overlays radial glows + sparse stars behind content
//  when the active theme is .nightSanctuary. No-op in light theme.
//

import SwiftUI

struct DarkScreenAuraModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    let glowOpacity: Double
    let starCount: Int

    func body(content: Content) -> some View {
        // Midnight Emerald provides its own background (EmeraldBackground) with a
        // gold glow, so the legacy aura (lilac glow + star field) is disabled for it.
        // The middle branch is retained for any future non-emerald dark theme.
        if themeManager.isMidnightEmerald {
            content
        } else if themeManager.selectedTheme == .nightSanctuary {
            content.background(auraLayer.ignoresSafeArea())
        } else {
            content
        }
    }

    private var auraLayer: some View {
        ZStack {
            // Top-left peach glow (~360pt radius)
            RadialGradient(
                colors: [themeManager.accentColor.opacity(glowOpacity), .clear],
                center: .init(x: 0.15, y: 0.05),
                startRadius: 0,
                endRadius: 360
            )

            // Bottom-right lilac glow
            RadialGradient(
                colors: [themeManager.semanticLilac.opacity(0.16), .clear],
                center: .init(x: 0.85, y: 0.95),
                startRadius: 0,
                endRadius: 360
            )

            // Deterministic star field
            StarField(count: starCount)
        }
    }
}

private struct StarField: View {
    let count: Int

    /// Deterministic positions seeded by index — no random per render.
    /// Mirrors the mock's pattern: positions = (i*47 % 90, i*79 % 100), size = 2.5 if i%3==0 else 1.5.
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let big = i % 3 == 0
                    let size: CGFloat = big ? 2.5 : 1.5
                    let opacity: Double = 0.10 + Double(i % 5) * 0.05
                    let x = CGFloat((i * 79) % 100) / 100.0 * proxy.size.width
                    let y = CGFloat((i * 47) % 90)  / 100.0 * proxy.size.height

                    Circle()
                        .fill(Color.white)
                        .frame(width: size, height: size)
                        .opacity(opacity)
                        .position(x: x, y: y)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

extension View {
    /// Overlays a dark-only aura layer (radial glows + sparse stars) behind the content.
    /// In light mode this returns the receiver unchanged.
    func darkScreenAura(glowOpacity: Double = 0.32, starCount: Int = 14) -> some View {
        modifier(DarkScreenAuraModifier(glowOpacity: glowOpacity, starCount: starCount))
    }
}

#if DEBUG
#Preview("Aura — dark") {
    Text("Aura preview")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.071, green: 0.051, blue: 0.039))
        .foregroundColor(.white)
        .darkScreenAura()
        .environmentObject(ThemeManager.darkPreview)
}
#endif
