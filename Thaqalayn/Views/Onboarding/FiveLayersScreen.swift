//
//  FiveLayersScreen.swift
//  Thaqalayn
//
//  Onboarding: Five Layers of Wisdom.
//  A glanceable, passive redesign - the five tafsir layers shown as a single
//  colour-coded stack (icon + name + a 2-3 word tag), labelled "Five lenses" to
//  frame them as five parallel angles on one verse (not a difficulty ramp). No
//  tap-to-expand, no paragraphs to read.
//

import SwiftUI

struct FiveLayersScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false

    private let gold = Color(hex: "ECD49A")

    /// One lens: the tafsir layer, its Phosphor icon, name, a short tag, and the
    /// accent chip that colour-codes it (matching the reading view's layers).
    private struct Lens {
        let icon: String
        let title: String
        let tag: String
        let chip: ThemeManager.ChipColor
    }

    private let lenses: [Lens] = [
        Lens(icon: "ph-bank-fill",                 title: "Foundation",     tag: "the basics",          chip: ThemeManager.chipFoundation),
        Lens(icon: "ph-books-fill",                title: "Classical Shia", tag: "Tabatabai & Tabrisi", chip: ThemeManager.chipKnowledge),
        Lens(icon: "ph-globe-hemisphere-west-fill", title: "Contemporary",   tag: "modern & scientific", chip: ThemeManager.chipProgress),
        Lens(icon: "ph-star-fill",                 title: "Ahlul Bayt",     tag: "the 14 Infallibles",  chip: ThemeManager.chipBrand),
        Lens(icon: "ph-scales-fill",               title: "Comparative",    tag: "Shia & Sunni",        chip: ThemeManager.chipComparative),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            header
                .padding(.bottom, 30)

            stackWithAxis
                .padding(.horizontal, 26)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .mauve))
        .onAppear { isVisible = true }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            // Gold "layers" badge crowning the header - mirrors the Gems screen's
            // HeroChip treatment, with a glyph that reads as the five-layer stack
            // below it.
            HeroChip(palette: ThemeManager.chipGold, pulseDuration: 2.4) {
                Image(systemName: "square.3.layers.3d")
                    .font(.system(size: 36, weight: .semibold))
            }
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.05), value: isVisible)
            .padding(.bottom, 8)

            Text("5 Layers of Wisdom")
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

            Text("See every verse from every angle.")
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)
        }
    }

    // MARK: - "Five lenses" axis + the colour-coded stack

    private var stackWithAxis: some View {
        HStack(spacing: 14) {
            Text("Five lenses")
                .font(.system(size: 10.5, weight: .bold))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundColor(gold)
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: 20)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: isVisible)

            VStack(spacing: 0) {
                ForEach(Array(lenses.enumerated()), id: \.offset) { index, lens in
                    stratum(lens, isLast: index == lenses.count - 1)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 22)
                        .animation(.easeOut(duration: 0.55).delay(0.45 + Double(index) * 0.1), value: isVisible)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(gold.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 10)
        }
    }

    /// One flush stratum in the stack: icon, name, and tag, with the accent
    /// colour drawn as a leading strip (an overlay, so it takes the row's own
    /// height rather than greedily filling the stack).
    private func stratum(_ lens: Lens, isLast: Bool) -> some View {
        HStack(spacing: 13) {
            PhosphorIcon(name: lens.icon, size: 22)
                .foregroundColor(lens.chip.fg)
                .frame(width: 30)

            Text(lens.title)
                .onbCardTitle()
                .foregroundColor(themeManager.primaryText)

            Spacer(minLength: 8)

            Text(lens.tag)
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .padding(.leading, 18)
        .padding(.trailing, 15)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(lens.chip.fg)
                .frame(width: 3)
        }
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(gold.opacity(0.08))
                    .frame(height: 1)
            }
        }
    }
}

extension TafsirLayer {
    var color: Color {
        switch self {
        case .foundation:
            return Color.blue
        case .classical:
            return Color.purple
        case .contemporary:
            return Color.green
        case .ahlulBayt:
            return Color.orange
        case .comparative:
            return Color.indigo
        }
    }
}

#Preview {
    FiveLayersScreen()
}
