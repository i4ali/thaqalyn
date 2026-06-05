//
//  FiveLayersScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 3: Five Layers of Wisdom
//

import SwiftUI

struct FiveLayersScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var selectedLayer: TafsirLayer?

    private let layers: [(layer: TafsirLayer, emoji: String, title: String, description: String)] = [
        (.foundation, "ph-bank-fill", "Foundation", "Simple explanations and historical context"),
        (.classical, "ph-books-fill", "Classical Shia", "Tabatabai, Tabrisi, traditional scholars"),
        (.contemporary, "ph-globe-hemisphere-west-fill", "Contemporary", "Modern perspectives and scientific analysis"),
        (.ahlulBayt, "ph-star-fill", "Ahlul Bayt", "Hadith from the 14 Infallibles"),
        (.comparative, "ph-scales-fill", "Comparative", "Balanced Shia and Sunni scholarly analysis")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HeroChip(palette: ThemeManager.chipGold) {
                    Image(systemName: "square.stack.3d.up.fill").font(.system(size: 38, weight: .semibold))
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isVisible)

                Text("5 Layers of Wisdom")
                    .onbHeroTitle()
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                Text("Tap each layer to explore")
                    .onbBody()
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)
            }
            .padding(.top, 80)
            .padding(.bottom, 30)

            // Layers stack
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(layers.enumerated()), id: \.offset) { index, item in
                        LayerCard(
                            layer: item.layer,
                            emoji: item.emoji,
                            title: item.title,
                            description: item.description,
                            index: index,
                            isExpanded: selectedLayer == item.layer,
                            isVisible: isVisible,
                            chip: [ThemeManager.chipFoundation, ThemeManager.chipKnowledge, ThemeManager.chipProgress, ThemeManager.chipBrand, ThemeManager.chipComparative][index],
                            onTap: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedLayer = selectedLayer == item.layer ? nil : item.layer
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .mauve))
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Layer Card

struct LayerCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    let layer: TafsirLayer
    let emoji: String
    let title: String
    let description: String
    let index: Int
    let isExpanded: Bool
    let isVisible: Bool
    let chip: ThemeManager.ChipColor
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 14) {
                    // Layer icon
                    PhosphorIcon(name: emoji, size: 28)
                        .foregroundColor(chip.fg)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(chip.bg))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .onbCardTitle()
                            .foregroundColor(themeManager.primaryText)

                        if !isExpanded {
                            Text(description)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }

                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(description)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4)

                        // Layer-specific details
                        Text(layerDetails)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                            .lineSpacing(3)

                        // Badge
                        HStack {
                            Text(layer.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(chip.fg)
                                )

                            Spacer()
                        }
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                isExpanded ? chip.fg.opacity(0.5) : Color(hex: "ECD49A").opacity(0.10),
                                lineWidth: isExpanded ? 2 : 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 8)
            )
            .shadow(color: isExpanded ? chip.fg.opacity(0.18) : Color.clear, radius: isExpanded ? 12 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .animation(Animation.easeOut(duration: 0.6).delay(0.6 + Double(index) * 0.1), value: isVisible)
    }

    private var layerDetails: String {
        switch layer {
        case .foundation:
            return "Perfect for beginners. Clear explanations of verses with historical context and basic Islamic principles."
        case .classical:
            return "Dive deep into traditional Shia scholarship with insights from Allamah Tabatabai's Al-Mizan and Sheikh Tabrisi's Majma al-Bayan."
        case .contemporary:
            return "Modern Islamic scholars provide fresh perspectives, addressing contemporary issues and scientific connections."
        case .ahlulBayt:
            return "Authentic narrations and spiritual wisdom from the Prophet and the 14 Infallibles (peace be upon them)."
        case .comparative:
            return "Unique to Thaqalayn: Balanced analysis comparing Shia and Sunni scholarly interpretations with academic integrity."
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
