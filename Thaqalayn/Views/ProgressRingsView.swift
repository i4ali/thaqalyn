//
//  ProgressRingsView.swift
//  Thaqalayn
//
//  Main view for the Progress tab displaying Apple Watch-style progress rings
//

import SwiftUI

struct ProgressRingsView: View {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var ramadanManager = RamadanJourneyManager.shared
    @StateObject private var hajjManager = HajjJourneyManager.shared
    @StateObject private var muharramManager = MuharramJourneyManager.shared
    @ObservedObject private var quizStore = QuizStore.shared
    @ObservedObject private var quizResults = QuizResultsStore.shared

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

    /// Passages fully read across the Quran, and the total, from the ruku index.
    private var passageCounts: (read: Int, total: Int) {
        guard let index = dataManager.passageIndex else { return (0, 0) }
        let readKeys = progressManager.readVerseKeys
        var read = 0, total = 0
        for surah in 1...totalSurahs {
            let refs = index.passages(forSurah: surah)
            total += refs.count
            read += PassageProgress.readCount(refs, readVerseKeys: readKeys)
        }
        return (read, total)
    }

    /// Quizzes shipped across the Quran; the card is hidden until there is at least one.
    private var shippedQuizzes: Int { quizStore.shippedQuizCount() }

    var body: some View {
        emeraldContent
    }

    // MARK: - Emerald Content

    private var emeraldContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                emeraldHeader
                emeraldRingsCard
                emeraldStatsGrid
                if shippedQuizzes > 0 { emeraldQuiz }
                if progressManager.stats.currentStreak > 0 { emeraldStreak }
                emeraldBadges
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 120)
        }
    }

    private var emeraldHeader: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(ProgressTabStrings.yourJourneyEyebrow.uppercased()).emEyebrow(size: 11, tracking: 3).foregroundColor(themeManager.accentColor)
            Text(ProgressTabStrings.progressTitle).font(EmType.serif(40, .semiBold)).foregroundColor(themeManager.primaryText)
            Text(ProgressTabStrings.progressSubtitle).font(.system(size: 13.5)).foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emeraldRingsCard: some View {
        EmCard(glow: true) {
            VStack(spacing: 16) {
                ProgressRingsStack(
                    quranProgress: quranProgress,
                    surahProgress: surahProgress,
                    ramadanProgress: seasonalProgress,
                    showRamadanRing: showSeasonalRing
                )
                .padding(.vertical, 8)
                RingLegend(showRamadanRing: showSeasonalRing, seasonalLabel: ProgressTabStrings.seasonal(seasonalLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
    }

    private var emeraldStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            emeraldStat(sf: "book.closed.fill", value: "\(progressManager.stats.totalVersesRead)", label: ProgressTabStrings.versesRead, sub: ProgressTabStrings.ofTotal(totalQuranVerses))
            emeraldStat(sf: "checkmark.seal.fill", value: "\(progressManager.stats.totalSurahsCompleted)", label: ProgressTabStrings.surahsComplete, sub: ProgressTabStrings.ofTotal(totalSurahs))
            emeraldStat(sf: "text.book.closed.fill", value: "\(passageCounts.read)", label: ProgressTabStrings.passagesRead, sub: ProgressTabStrings.ofTotal(passageCounts.total))
            emeraldStat(sf: "sparkles", value: formatSawab(progressManager.stats.totalSawab), label: ProgressTabStrings.totalSawab, sub: ProgressTabStrings.blessingsEarned)
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

    private var emeraldQuiz: some View {
        EmCard {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    if quizResults.takenCount > 0 {
                        Text(ProgressTabStrings.quizzesTaken(quizResults.takenCount, of: shippedQuizzes))
                            .font(EmType.serif(20, .semiBold)).foregroundColor(themeManager.primaryText)
                        Text(ProgressTabStrings.quizzesShipped(shippedQuizzes))
                            .font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
                    } else {
                        Text(ProgressTabStrings.noQuizzesYet)
                            .font(EmType.serif(20, .semiBold)).foregroundColor(themeManager.primaryText)
                        Text(ProgressTabStrings.quizzesHint)
                            .font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
                    }
                }
                Spacer()
                if let average = quizResults.averageBestScore {
                    HStack(spacing: 16) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(ProgressTabStrings.fullMarks.uppercased()).emEyebrow(size: 10, tracking: 1).foregroundColor(themeManager.tertiaryText)
                            Text("\(quizResults.fullMarksCount)").font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.accentBright)
                        }
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(ProgressTabStrings.averageScore.uppercased()).emEyebrow(size: 10, tracking: 1).foregroundColor(themeManager.tertiaryText)
                            Text(ProgressTabStrings.averageValue(average, of: 5)).font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.accentBright)
                        }
                    }
                }
            }
            .padding(16)
        }
        .accessibilityElement(children: .combine)
    }

    private var emeraldStreak: some View {
        EmCard {
            HStack(spacing: 12) {
                PhosphorIcon(name: "ph-flame-fill", size: 28).foregroundColor(themeManager.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ProgressTabStrings.dayStreak(progressManager.stats.currentStreak)).font(EmType.serif(20, .semiBold)).foregroundColor(themeManager.primaryText)
                    Text(ProgressTabStrings.keepItGoing).font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(ProgressTabStrings.best.uppercased()).emEyebrow(size: 10, tracking: 1).foregroundColor(themeManager.tertiaryText)
                    Text("\(progressManager.stats.longestStreak)").font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.accentBright)
                }
            }
            .padding(16)
        }
    }

    private var emeraldBadges: some View {
        VStack(alignment: .leading, spacing: 12) {
            EmDivider(label: ProgressTabStrings.badgesDivider(progressManager.badges.count, 24))
            if progressManager.badges.isEmpty {
                EmCard {
                    VStack(spacing: 12) {
                        Image(systemName: "star.slash").font(.system(size: 40)).foregroundColor(themeManager.tertiaryText)
                        Text(ProgressTabStrings.noBadgesYet).font(EmType.serif(18, .semiBold)).foregroundColor(themeManager.primaryText)
                        Text(ProgressTabStrings.earnBadgesHint).font(.system(size: 12.5)).foregroundColor(themeManager.tertiaryText).multilineTextAlignment(.center)
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
                Text(ProgressTabStrings.badgeLabel(badge))
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center).lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14).padding(.horizontal, 6)
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

#Preview {
    ZStack {
        AdaptiveModernBackground()
        ProgressRingsView()
    }
}
