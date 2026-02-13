//
//  ProgressRingsView.swift
//  Thaqalayn
//
//  Main view for the Progress tab displaying Apple Watch-style progress rings
//

import SwiftUI

struct ProgressRingsView: View {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var quizManager = QuizManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var ramadanManager = RamadanJourneyManager.shared

    private let totalQuranVerses = 6236
    private let totalSurahs = 114

    private var isRamadanSeason: Bool {
        IslamicCalendarManager.shared.isRamadanSeason()
    }

    // Progress calculations
    private var quranProgress: Double {
        Double(progressManager.stats.totalVersesRead) / Double(totalQuranVerses)
    }

    private var surahProgress: Double {
        Double(progressManager.stats.totalSurahsCompleted) / Double(totalSurahs)
    }

    private var quizProgress: Double {
        Double(quizManager.completedSurahCount) / Double(totalSurahs)
    }

    private var ramadanProgress: Double {
        ramadanManager.completionPercentage
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WarmSpacing.generous) {
                // Header
                headerSection

                // Progress Rings
                ringsSection

                // Ring Legend
                RingLegend(showRamadanRing: isRamadanSeason)
                    .padding(.top, WarmSpacing.small)

                // Stats Grid
                statsGridSection

                // Current Streak section
                if progressManager.stats.currentStreak > 0 {
                    streakSection
                }

                // Badge Collection
                badgeCollectionSection

                Spacer(minLength: 100)
            }
            .padding(.horizontal, WarmSpacing.generous)
            .padding(.top, WarmSpacing.large)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: WarmSpacing.small) {
            Text("Your Progress")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryText)

            Text("Track your Quran journey")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Rings Section

    private var ringsSection: some View {
        VStack(spacing: WarmSpacing.medium) {
            ProgressRingsStack(
                quranProgress: quranProgress,
                surahProgress: surahProgress,
                quizProgress: quizProgress,
                ramadanProgress: ramadanProgress,
                showRamadanRing: isRamadanSeason
            )
            .padding(.vertical, WarmSpacing.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WarmSpacing.regular)
        .background(
            RoundedRectangle(cornerRadius: WarmRadius.large)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: WarmRadius.large)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }

    // MARK: - Stats Grid Section

    private var statsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: WarmSpacing.regular),
            GridItem(.flexible(), spacing: WarmSpacing.regular)
        ], spacing: WarmSpacing.regular) {
            RingsStatCard(
                icon: "book.fill",
                iconColor: Color(hex: "FF2D55"),
                title: "Verses Read",
                value: "\(progressManager.stats.totalVersesRead)",
                subtitle: "of \(totalQuranVerses)"
            )

            RingsStatCard(
                icon: "checkmark.seal.fill",
                iconColor: Color(hex: "30D158"),
                title: "Surahs Complete",
                value: "\(progressManager.stats.totalSurahsCompleted)",
                subtitle: "of \(totalSurahs)"
            )

            RingsStatCard(
                icon: "questionmark.circle.fill",
                iconColor: Color(hex: "0A84FF"),
                title: "Quizzes Done",
                value: "\(quizManager.completedSurahCount)",
                subtitle: "surahs tested"
            )

            RingsStatCard(
                icon: "sparkles",
                iconColor: Color(hex: "FFD60A"),
                title: "Total Sawab",
                value: formatSawab(progressManager.stats.totalSawab),
                subtitle: "blessings earned"
            )
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        HStack(spacing: WarmSpacing.medium) {
            Image(systemName: "flame.fill")
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FF9500"), Color(hex: "FF2D55")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("\(progressManager.stats.currentStreak) Day Streak")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)

                Text("Keep it going!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Best")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.tertiaryText)

                Text("\(progressManager.stats.longestStreak)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
            }
        }
        .padding(WarmSpacing.regular)
        .background(
            RoundedRectangle(cornerRadius: WarmRadius.medium)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: WarmRadius.medium)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }

    // MARK: - Badge Collection Section

    private var badgeCollectionSection: some View {
        VStack(alignment: .leading, spacing: WarmSpacing.regular) {
            HStack {
                Text("Badges")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)

                Spacer()

                Text("\(progressManager.badges.count)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(themeManager.secondaryText)
            }

            if progressManager.badges.isEmpty {
                VStack(spacing: WarmSpacing.regular) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.tertiaryText.opacity(0.5))

                    Text("No badges yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.secondaryText)

                    Text("Complete surahs and build streaks to earn badges!")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(themeManager.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WarmSpacing.huge)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: WarmRadius.medium)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: WarmRadius.medium)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: WarmSpacing.medium) {
                    ForEach(progressManager.badges.sorted(by: { $0.awardedDate > $1.awardedDate })) { badge in
                        ProgressBadgeCard(badge: badge)
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func formatSawab(_ value: Int) -> String {
        if value >= 1000000 {
            return String(format: "%.1fM", Double(value) / 1000000)
        } else if value >= 1000 {
            return String(format: "%.1fK", Double(value) / 1000)
        } else {
            return "\(value)"
        }
    }
}

// MARK: - Stat Card

struct RingsStatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: WarmSpacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)

                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryText)

            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(themeManager.primaryText)

            Text(subtitle)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(WarmSpacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: WarmRadius.medium)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: WarmRadius.medium)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Badge Card

struct ProgressBadgeCard: View {
    let badge: BadgeAward
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: badge.badgeType.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(badgeColor)
            }

            Text(badge.badgeType == .surahCompletion ? badge.surahName : badge.badgeType.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WarmSpacing.regular)
        .padding(.horizontal, WarmSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: WarmRadius.small)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: WarmRadius.small)
                        .stroke(badgeColor.opacity(0.3), lineWidth: 1.5)
                )
        )
    }

    private var badgeColor: Color {
        switch badge.badgeType.color {
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "gold": return .yellow
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    ZStack {
        AdaptiveModernBackground()
        ProgressRingsView()
    }
}
