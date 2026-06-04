//
//  ProgressRingsStack.swift
//  Thaqalayn
//
//  Combines three/four concentric rings with Apple Watch styling
//

import SwiftUI

struct ProgressRingsStack: View {
    let quranProgress: Double      // Verses read / 6236
    let surahProgress: Double      // Surahs completed / 114
    let quizProgress: Double       // Quizzes completed / 114
    let ramadanProgress: Double    // Ramadan days / 30
    let showRamadanRing: Bool

    @StateObject private var themeManager = ThemeManager.shared

    // Theme-aware vibrant ring gradients (Apple Watch style).
    // Both stops are derived from the same semantic token so they auto-adapt across themes.
    private var quranGradient: LinearGradient {
        LinearGradient(
            colors: themeManager.isMidnightEmerald ? [themeManager.accentColor, themeManager.accentColorDeep] : [themeManager.semanticRed, themeManager.semanticRed.opacity(0.85)],
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

    private var quizGradient: LinearGradient {
        LinearGradient(
            colors: themeManager.isMidnightEmerald ? [themeManager.primaryText, themeManager.primaryText.opacity(0.7)] : [themeManager.semanticBlue, themeManager.semanticBlue.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var ramadanGradient: LinearGradient {
        LinearGradient(
            colors: themeManager.isMidnightEmerald ? [themeManager.accentBright, themeManager.accentColor] : [themeManager.semanticYellow, themeManager.semanticYellow.opacity(0.85)],
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
                shadowColor: themeManager.isMidnightEmerald ? themeManager.accentColor : themeManager.semanticRed
            )

            // Middle ring - Surah Completion (180pt, 18pt width)
            ProgressRingView(
                progress: surahProgress,
                gradient: surahGradient,
                lineWidth: 18,
                size: 180,
                shadowColor: themeManager.semanticGreen
            )

            // Inner ring - Quiz Progress (120pt, 16pt width)
            ProgressRingView(
                progress: quizProgress,
                gradient: quizGradient,
                lineWidth: 16,
                size: 120,
                shadowColor: themeManager.isMidnightEmerald ? themeManager.primaryText : themeManager.semanticBlue
            )

            // Innermost ring - Ramadan (60pt, 14pt width) - Seasonal only
            if showRamadanRing {
                ProgressRingView(
                    progress: ramadanProgress,
                    gradient: ramadanGradient,
                    lineWidth: 14,
                    size: 60,
                    shadowColor: themeManager.isMidnightEmerald ? themeManager.accentBright : themeManager.semanticYellow
                )
            }

            // Center display - Quran reading percentage
            VStack(spacing: 2) {
                Text("\(Int(quranProgress * 100))%")
                    .font(.system(size: showRamadanRing ? 18 : 24, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)

                Text("Quran")
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
            LegendItem(color: themeManager.isMidnightEmerald ? themeManager.accentColor : themeManager.semanticRed, label: "Quran")
            LegendItem(color: themeManager.semanticGreen, label: "Surahs")
            LegendItem(color: themeManager.isMidnightEmerald ? themeManager.primaryText : themeManager.semanticBlue, label: "Quizzes")

            if showRamadanRing {
                LegendItem(color: themeManager.isMidnightEmerald ? themeManager.accentBright : themeManager.semanticYellow, label: seasonalLabel)
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
                quizProgress: 0.15,
                ramadanProgress: 0.6,
                showRamadanRing: true
            )

            RingLegend(showRamadanRing: true)
        }
    }
}
