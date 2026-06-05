//
//  HeroChip.swift
//  Thaqalayn
//
//  Variant C reskin: 88x88 pastel "chip" badge with a breathing amber halo.
//  Wraps each screen's existing hero icon (SF Symbol Image OR PhosphorIcon);
//  the host screen keeps its own entrance animation on this view.
//

import SwiftUI

struct HeroChip<Icon: View>: View {
    let palette: ThemeManager.ChipColor
    /// Pass nil to tint the icon with `palette.fg`; pass a color to override
    /// (used by Seasonal: plum chip + peach icon).
    var iconColor: Color? = nil
    /// Matches the breathing cadence the screen's old glow Circle used.
    var pulseDuration: Double = 2.5
    @ViewBuilder var icon: () -> Icon

    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill((iconColor ?? palette.fg).opacity(0.34))
                .frame(width: 120, height: 120)
                .blur(radius: 10)
                .scaleEffect(pulse ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: pulseDuration).repeatForever(autoreverses: true),
                    value: pulse
                )

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke((iconColor ?? palette.fg).opacity(0.22), lineWidth: 1)
                )
                .frame(width: 88, height: 88)

            icon()
                .foregroundColor(iconColor ?? palette.fg)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { pulse = true }
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackground(tilt: .lavender)
        HeroChip(palette: ThemeManager.chipKnowledge) {
            Image(systemName: "sparkles").font(.system(size: 38, weight: .semibold))
        }
    }
}
