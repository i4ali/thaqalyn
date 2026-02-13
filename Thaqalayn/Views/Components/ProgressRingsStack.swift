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

    // Fixed vibrant colors (Apple Watch style)
    private let quranGradient = LinearGradient(
        colors: [Color(hex: "FF2D55"), Color(hex: "FF6B6B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let surahGradient = LinearGradient(
        colors: [Color(hex: "30D158"), Color(hex: "34C759")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let quizGradient = LinearGradient(
        colors: [Color(hex: "0A84FF"), Color(hex: "5AC8FA")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let ramadanGradient = LinearGradient(
        colors: [Color(hex: "FFD60A"), Color(hex: "FFCC00")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            // Outer ring - Quran Reading (240pt, 20pt width)
            ProgressRingView(
                progress: quranProgress,
                gradient: quranGradient,
                lineWidth: 20,
                size: 240,
                shadowColor: Color(hex: "FF2D55")
            )

            // Middle ring - Surah Completion (180pt, 18pt width)
            ProgressRingView(
                progress: surahProgress,
                gradient: surahGradient,
                lineWidth: 18,
                size: 180,
                shadowColor: Color(hex: "30D158")
            )

            // Inner ring - Quiz Progress (120pt, 16pt width)
            ProgressRingView(
                progress: quizProgress,
                gradient: quizGradient,
                lineWidth: 16,
                size: 120,
                shadowColor: Color(hex: "0A84FF")
            )

            // Innermost ring - Ramadan (60pt, 14pt width) - Seasonal only
            if showRamadanRing {
                ProgressRingView(
                    progress: ramadanProgress,
                    gradient: ramadanGradient,
                    lineWidth: 14,
                    size: 60,
                    shadowColor: Color(hex: "FFD60A")
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
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 16) {
            LegendItem(color: Color(hex: "FF2D55"), label: "Quran")
            LegendItem(color: Color(hex: "30D158"), label: "Surahs")
            LegendItem(color: Color(hex: "0A84FF"), label: "Quizzes")

            if showRamadanRing {
                LegendItem(color: Color(hex: "FFD60A"), label: "Ramadan")
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
