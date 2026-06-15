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
    @StateObject private var hajjManager = HajjJourneyManager.shared
    @StateObject private var muharramManager = MuharramJourneyManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }

    private let totalQuranVerses = 6236
    private let totalSurahs = 114

    private var isRamadanSeason: Bool {
        IslamicCalendarManager.shared.isRamadanSeason()
    }

    private var isHajjSeason: Bool {
        IslamicCalendarManager.shared.isHajjSeason()
    }

    private var isMuharramSeason: Bool {
        IslamicCalendarManager.shared.isMuharramSeason()
    }

    // Ramadan, Hajj, and Muharram seasons are mutually exclusive; share the single seasonal ring slot.
    private var showSeasonalRing: Bool {
        isRamadanSeason || isHajjSeason || isMuharramSeason
    }

    private var seasonalLabel: String {
        if isHajjSeason { return "Hajj" }
        if isMuharramSeason { return "Muharram" }
        return "Ramadan"
    }

    private var seasonalProgress: Double {
        if isRamadanSeason {
            return ramadanManager.completionPercentage
        } else if isHajjSeason {
            return hajjManager.completionPercentage
        } else if isMuharramSeason {
            return muharramManager.completionPercentage
        }
        return 0
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

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldContent } else { legacyContent }
    }

    private var legacyContent: some View {
        ScrollView {
            VStack(spacing: WarmSpacing.generous) {
                // Header
                headerSection

                // Progress Rings
                ringsSection

                // Ring Legend
                RingLegend(showRamadanRing: showSeasonalRing, seasonalLabel: ProgressTabStrings.seasonal(seasonalLabel, lang))
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
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }

    // MARK: - Emerald Content

    private var emeraldContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                emeraldHeader
                emeraldRingsCard
                emeraldStatsGrid
                if progressManager.stats.currentStreak > 0 { emeraldStreak }
                emeraldBadges
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 120)
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }

    private var emeraldHeader: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(ProgressTabStrings.yourJourneyEyebrow(lang).uppercased()).emEyebrow(lang, size: 11, tracking: 3).foregroundColor(themeManager.accentColor)
            Text(ProgressTabStrings.progressTitle(lang)).font(EmType.serif(40, .semiBold)).foregroundColor(themeManager.primaryText)
            Text(ProgressTabStrings.progressSubtitle(lang)).font(.system(size: 13.5)).foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emeraldRingsCard: some View {
        EmCard(glow: true) {
            VStack(spacing: 16) {
                ProgressRingsStack(
                    quranProgress: quranProgress,
                    surahProgress: surahProgress,
                    quizProgress: quizProgress,
                    ramadanProgress: seasonalProgress,
                    showRamadanRing: showSeasonalRing
                )
                .padding(.vertical, 8)
                RingLegend(showRamadanRing: showSeasonalRing, seasonalLabel: ProgressTabStrings.seasonal(seasonalLabel, lang))
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
    }

    private var emeraldStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            emeraldStat(sf: "book.closed.fill", value: "\(progressManager.stats.totalVersesRead)", label: ProgressTabStrings.versesRead(lang), sub: ProgressTabStrings.ofTotal(totalQuranVerses, lang))
            emeraldStat(sf: "checkmark.seal.fill", value: "\(progressManager.stats.totalSurahsCompleted)", label: ProgressTabStrings.surahsComplete(lang), sub: ProgressTabStrings.ofTotal(totalSurahs, lang))
            emeraldStat(sf: "questionmark.circle.fill", value: "\(quizManager.completedSurahCount)", label: ProgressTabStrings.quizzesDone(lang), sub: ProgressTabStrings.surahsTested(lang))
            emeraldStat(sf: "sparkles", value: formatSawab(progressManager.stats.totalSawab), label: ProgressTabStrings.totalSawab(lang), sub: ProgressTabStrings.blessingsEarned(lang))
        }
    }

    private func emeraldStat(sf: String, value: String, label: String, sub: String) -> some View {
        EmCard {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: sf).font(.system(size: 16)).foregroundColor(themeManager.accentColor)
                Text(value).font(EmType.serif(30, .semiBold)).foregroundColor(themeManager.accentBright)
                Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(themeManager.primaryText)
                Text(sub).font(.system(size: 11, weight: .medium)).foregroundColor(themeManager.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }

    private var emeraldStreak: some View {
        EmCard {
            HStack(spacing: 12) {
                PhosphorIcon(name: "ph-flame-fill", size: 28).foregroundColor(themeManager.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ProgressTabStrings.dayStreak(progressManager.stats.currentStreak, lang)).font(EmType.serif(20, .semiBold)).foregroundColor(themeManager.primaryText)
                    Text(ProgressTabStrings.keepItGoing(lang)).font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(ProgressTabStrings.best(lang).uppercased()).emEyebrow(lang, size: 10, tracking: 1).foregroundColor(themeManager.tertiaryText)
                    Text("\(progressManager.stats.longestStreak)").font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.accentBright)
                }
            }
            .padding(16)
        }
    }

    private var emeraldBadges: some View {
        VStack(alignment: .leading, spacing: 12) {
            EmDivider(label: ProgressTabStrings.badgesDivider(progressManager.badges.count, 24, lang))
            if progressManager.badges.isEmpty {
                EmCard {
                    VStack(spacing: 12) {
                        Image(systemName: "star.slash").font(.system(size: 40)).foregroundColor(themeManager.tertiaryText)
                        Text(ProgressTabStrings.noBadgesYet(lang)).font(EmType.serif(18, .semiBold)).foregroundColor(themeManager.primaryText)
                        Text(ProgressTabStrings.earnBadgesHint(lang)).font(.system(size: 12.5)).foregroundColor(themeManager.tertiaryText).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 32).padding(.horizontal, 16)
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(progressManager.badges.sorted(by: { $0.awardedDate > $1.awardedDate })) { badge in
                        emeraldBadgeTile(badge)
                    }
                }
            }
        }
    }

    private func emeraldBadgeTile(_ badge: BadgeAward) -> some View {
        EmCard {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(themeManager.accentChip).frame(width: 52, height: 52)
                        .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 1))
                    Image(systemName: badge.badgeType.icon).font(.system(size: 22, weight: .semibold)).foregroundColor(themeManager.accentBright)
                }
                Text(ProgressTabStrings.badgeLabel(badge, lang))
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center).lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14).padding(.horizontal, 6)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: WarmSpacing.small) {
            Text(ProgressTabStrings.yourProgress(lang))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryText)

            Text(ProgressTabStrings.trackJourney(lang))
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
                ramadanProgress: seasonalProgress,
                showRamadanRing: showSeasonalRing
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
                iconColor: themeManager.semanticRed,
                title: ProgressTabStrings.versesRead(lang),
                value: "\(progressManager.stats.totalVersesRead)",
                subtitle: ProgressTabStrings.ofTotal(totalQuranVerses, lang)
            )

            RingsStatCard(
                icon: "checkmark.seal.fill",
                iconColor: themeManager.semanticGreen,
                title: ProgressTabStrings.surahsComplete(lang),
                value: "\(progressManager.stats.totalSurahsCompleted)",
                subtitle: ProgressTabStrings.ofTotal(totalSurahs, lang)
            )

            RingsStatCard(
                icon: "questionmark.circle.fill",
                iconColor: themeManager.semanticBlue,
                title: ProgressTabStrings.quizzesDone(lang),
                value: "\(quizManager.completedSurahCount)",
                subtitle: ProgressTabStrings.surahsTested(lang)
            )

            RingsStatCard(
                icon: "sparkles",
                iconColor: themeManager.semanticYellow,
                title: ProgressTabStrings.totalSawab(lang),
                value: formatSawab(progressManager.stats.totalSawab),
                subtitle: ProgressTabStrings.blessingsEarned(lang)
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
                Text(ProgressTabStrings.dayStreak(progressManager.stats.currentStreak, lang))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)

                Text(ProgressTabStrings.keepItGoing(lang))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(ProgressTabStrings.best(lang))
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
                Text(ProgressTabStrings.badges(lang))
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

                    Text(ProgressTabStrings.noBadgesYet(lang))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.secondaryText)

                    Text(ProgressTabStrings.earnBadgesHint(lang))
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
                    .shadow(color: themeManager.isDarkMode ? iconColor.opacity(0.5) : .clear, radius: 8)

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
    @StateObject private var languageManager = CommentaryLanguageManager.shared

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

            Text(ProgressTabStrings.badgeLabel(badge, languageManager.selectedLanguage))
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
