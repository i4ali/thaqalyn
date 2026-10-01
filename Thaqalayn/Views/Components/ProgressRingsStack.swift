//
//  ProgressRingsStack.swift
//  Thaqalayn
//
//  Combines two/three concentric rings with Apple Watch styling
//

import SwiftUI

struct ProgressRingsStack: View {
    let quranProgress: Double      // Verses read / 6236
    let surahProgress: Double      // Surahs completed / 114
    let ramadanProgress: Double    // Ramadan days / 30
    let showRamadanRing: Bool

    @StateObject private var themeManager = ThemeManager.shared

    // Ring gradients (Apple Watch style). Every stop is a theme token, so they
    // adapt across themes.
    private var quranGradient: LinearGradient {
        LinearGradient(
            colors: [themeManager.accentColor, themeManager.accentColorDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var surahGradient: LinearGradient {
        LinearGradient(
            colors: [themeManager.semanticGreen, themeManager.semanticGreen.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var ramadanGradient: LinearGradient {
        LinearGradient(
            colors: [themeManager.accentBright, themeManager.accentColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            // Outer ring - Quran Reading (240pt, 20pt width)
            ProgressRingView(
                progress: quranProgress,
                gradient: quranGradient,
                lineWidth: 20,
                size: 240,
                shadowColor: themeManager.accentColor
            )

            // Middle ring - Surah Completion (180pt, 18pt width)
            ProgressRingView(
                progress: surahProgress,
                gradient: surahGradient,
                lineWidth: 18,
                size: 180,
                shadowColor: themeManager.semanticGreen
            )

            // Inner ring - seasonal journey (120pt, 16pt width) - seasonal only
            if showRamadanRing {
                ProgressRingView(
                    progress: ramadanProgress,
                    gradient: ramadanGradient,
                    lineWidth: 16,
                    size: 120,
                    shadowColor: themeManager.accentBright
                )
            }

            // Center display - Quran reading percentage
            VStack(spacing: 2) {
                Text("\(Int(quranProgress * 100))%")
                    .font(.system(size: showRamadanRing ? 18 : 24, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)

                Text(ProgressTabStrings.quran)
                    .font(.system(size: showRamadanRing ? 10 : 12, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.secondaryText)
            }
        }
        .frame(width: 240, height: 240)
    }
}

// MARK: - Ring Legend

struct RingLegend: View {
    let showRamadanRing: Bool
    var seasonalLabel: String = "Ramadan"
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 16) {
            LegendItem(color: themeManager.accentColor, label: ProgressTabStrings.quran)
            LegendItem(color: themeManager.semanticGreen, label: ProgressTabStrings.surahs)

            if showRamadanRing {
                LegendItem(color: themeManager.accentBright, label: seasonalLabel)
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(themeManager.secondaryText)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 24) {
            ProgressRingsStack(
                quranProgress: 0.45,
                surahProgress: 0.25,
                ramadanProgress: 0.6,
                showRamadanRing: true
            )

            RingLegend(showRamadanRing: true)
        }
    }
}
