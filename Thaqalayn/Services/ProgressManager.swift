//
//  ProgressManager.swift
//  Thaqalayn
//
//  Service for managing reading progress, streaks, and badges
//

import Foundation
import SwiftUI

@MainActor
class ProgressManager: ObservableObject {
    static let shared = ProgressManager()

    // MARK: - Published Properties

    @Published var verseProgress: [VerseProgress] = []
    @Published var streak: ReadingStreak = ReadingStreak()
    @Published var badges: [BadgeAward] = []
    @Published var stats: ProgressStats = ProgressStats()
    @Published var preferences: ProgressPreferences = ProgressPreferences()
    @Published var pendingBadge: BadgeAward? = nil // For showing badge celebration

    // MARK: - UserDefaults Keys

    private let verseProgressKey = "verseProgress"
    private let streakKey = "readingStreak"
    private let badgesKey = "badgeAwards"
    private let statsKey = "progressStats"
    private let preferencesKey = "progressPreferences"

    // MARK: - Initialization

    private init() {
        loadProgress()
    }

    // MARK: - Data Persistence

    func loadProgress() {
        // Load verse progress
        if let data = UserDefaults.standard.data(forKey: verseProgressKey),
           let decoded = try? JSONDecoder().decode([VerseProgress].self, from: data) {
            self.verseProgress = decoded
        }

        // Load streak
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let decoded = try? JSONDecoder().decode(ReadingStreak.self, from: data) {
            self.streak = decoded
        }

        // Load badges
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let decoded = try? JSONDecoder().decode([BadgeAward].self, from: data) {
            self.badges = decoded
        }

        // Load stats
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(ProgressStats.self, from: data) {
            self.stats = decoded
        }

        // Load preferences
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(ProgressPreferences.self, from: data) {
            self.preferences = decoded
        }

        // Update today's verse count and streak on load
        updateTodayVersesCount()
        updateStreakOnLoad()
    }

    private func saveProgress() {
        // Save verse progress
        if let encoded = try? JSONEncoder().encode(verseProgress) {
            UserDefaults.standard.set(encoded, forKey: verseProgressKey)
        }

        // Save streak
        if let encoded = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(encoded, forKey: streakKey)
        }

        // Save badges
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }

        // Save stats
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }

        // Save preferences
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }

    // MARK: - Verse Progress Tracking

    func markVerseAsRead(surahNumber: Int, verseNumber: Int) {
        let verseKey = "\(surahNumber):\(verseNumber)"

        // Check if already marked
        var isNewRead = false
        if let existingIndex = verseProgress.firstIndex(where: { $0.verseKey == verseKey }) {
            // Update existing
            var updated = verseProgress[existingIndex]
            updated = VerseProgress(
                id: updated.id,
                surahNumber: surahNumber,
                verseNumber: verseNumber,
                readDate: Date(),
                isRead: true
            )
            verseProgress[existingIndex] = updated
        } else {
            // Add new
            let progress = VerseProgress(
                surahNumber: surahNumber,
                verseNumber: verseNumber
            )
            verseProgress.append(progress)
            isNewRead = true
        }

        // Update stats
        stats.totalVersesRead = verseProgress.filter { $0.isRead }.count
        updateTodayVersesCount()
        stats.lastReadDate = Date()

        // Award sawab for verse reading (10 sawab per verse, based on hadith)
        if isNewRead {
            stats.totalSawab += 10
            print("✨ ProgressManager: +10 sawab earned! Total: \(stats.totalSawab)")
        }

        // Update streak
        updateStreak()

        // Check for surah completion and badges
        checkSurahCompletion(surahNumber: surahNumber)

        // Save changes
        saveProgress()

        print("✅ ProgressManager: Marked verse \(verseKey) as read")
    }

    func unmarkVerseAsRead(surahNumber: Int, verseNumber: Int) {
        let verseKey = "\(surahNumber):\(verseNumber)"

        if let index = verseProgress.firstIndex(where: { $0.verseKey == verseKey }) {
            verseProgress.remove(at: index)

            // Update stats
            stats.totalVersesRead = verseProgress.filter { $0.isRead }.count
            updateTodayVersesCount()

            // Deduct sawab for unmarking verse
            stats.totalSawab = max(0, stats.totalSawab - 10)

            saveProgress()

            print("✅ ProgressManager: Unmarked verse \(verseKey)")
        }
    }

    func isVerseRead(surahNumber: Int, verseNumber: Int) -> Bool {
        let verseKey = "\(surahNumber):\(verseNumber)"
        return verseProgress.contains(where: { $0.verseKey == verseKey && $0.isRead })
    }

    func getVerseProgress(surahNumber: Int, verseNumber: Int) -> VerseProgress? {
        let verseKey = "\(surahNumber):\(verseNumber)"
        return verseProgress.first(where: { $0.verseKey == verseKey })
    }

    // MARK: - Surah Completion

    func getSurahCompletion(surahNumber: Int) -> (read: Int, total: Int) {
        let surahVerses = verseProgress.filter { $0.surahNumber == surahNumber && $0.isRead }
        let totalVerses = DataManager.shared.getSurah(number: surahNumber)?.surah.versesCount ?? 0
        return (read: surahVerses.count, total: totalVerses)
    }

    func isSurahCompleted(surahNumber: Int) -> Bool {
        let completion = getSurahCompletion(surahNumber: surahNumber)
        return completion.read == completion.total && completion.total > 0
    }

    private func checkSurahCompletion(surahNumber: Int) {
        guard isSurahCompleted(surahNumber: surahNumber) else { return }

        // Check if badge already awarded
        let alreadyAwarded = badges.contains(where: {
            $0.surahNumber == surahNumber && $0.badgeType == .surahCompletion
        })

        if !alreadyAwarded, let surah = DataManager.shared.getSurah(number: surahNumber)?.surah {
            // Award badge
            let badge = BadgeAward(
                surahNumber: surahNumber,
                surahName: surah.englishName,
                arabicName: surah.arabicName,
                badgeType: .surahCompletion
            )
            badges.append(badge)
            stats.totalSurahsCompleted += 1

            // Award sawab for badge
            let badgeSawab = badge.badgeType.sawabValue
            stats.totalSawab += badgeSawab
            print("✨ ProgressManager: +\(badgeSawab) sawab earned from \(badge.badgeType.title)! Total: \(stats.totalSawab)")

            // Set pending badge for celebration
            if preferences.celebrationsEnabled {
                pendingBadge = badge
            }

            // Check milestone badges
            checkMilestoneBadges()

            saveProgress()

            print("🎉 ProgressManager: Surah \(surahNumber) completed! Badge awarded.")
        }
    }

    private func checkMilestoneBadges() {
        let completedSurahs = stats.totalSurahsCompleted

        // Check for milestone badges
        let milestones: [(count: Int, type: BadgeType)] = [
            (10, .milestone10),
            (25, .milestone25),
            (50, .milestone50),
            (114, .allSurahs)
        ]

        for milestone in milestones {
            if completedSurahs == milestone.count {
                let alreadyAwarded = badges.contains(where: { $0.badgeType == milestone.type })
                if !alreadyAwarded {
                    let badge = BadgeAward(
                        surahNumber: 0,
                        surahName: milestone.type.title,
                        arabicName: milestone.type.subtitle,
                        badgeType: milestone.type
                    )
                    badges.append(badge)

                    // Award sawab for milestone badge
                    let badgeSawab = badge.badgeType.sawabValue
                    stats.totalSawab += badgeSawab
                    print("✨ ProgressManager: +\(badgeSawab) sawab earned from \(milestone.type.title)! Total: \(stats.totalSawab)")

                    if preferences.celebrationsEnabled {
                        pendingBadge = badge
                    }

                    print("🎉 ProgressManager: Milestone badge awarded: \(milestone.type.title)")
                }
            }
        }
    }

    // MARK: - Streak Management

    private func updateStreakOnLoad() {
        guard let lastRead = streak.lastReadDate else { return }

        let calendar = Calendar.current
        let now = Date()

        // Check if streak should be broken
        if let daysSince = calendar.dateComponents([.day], from: lastRead, to: now).day {
            if daysSince > 1 {
                // Streak broken
                streak.currentStreak = 0
                streak.streakStartDate = nil
                print("📉 ProgressManager: Streak broken (last read \(daysSince) days ago)")
            }
        }

        // Update stats
        stats.currentStreak = streak.currentStreak
        stats.longestStreak = streak.longestStreak

        saveProgress()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let now = Date()

        if let lastRead = streak.lastReadDate {
            // Check if this is a new day
            if calendar.isDate(lastRead, inSameDayAs: now) {
                // Same day - no streak change
                return
            }

            // Check if this is the next day
            if let daysSince = calendar.dateComponents([.day], from: lastRead, to: now).day {
                if daysSince == 1 {
                    // Continue streak
                    streak.currentStreak += 1
                    if streak.currentStreak > streak.longestStreak {
                        streak.longestStreak = streak.currentStreak
                    }

                    // Check for streak badges
                    checkStreakBadges()

                    print("🔥 ProgressManager: Streak continued! Current: \(streak.currentStreak)")
                } else if daysSince > 1 {
                    // Streak broken - start new
                    streak.currentStreak = 1
                    streak.streakStartDate = now
                    print("📉 ProgressManager: Streak broken. Starting fresh.")
                }
            }
        } else {
            // First read ever
            streak.currentStreak = 1
            streak.longestStreak = 1
            streak.streakStartDate = now
            print("🎉 ProgressManager: First reading streak started!")
        }

        streak.lastReadDate = now

        // Update stats
        stats.currentStreak = streak.currentStreak
        stats.longestStreak = streak.longestStreak
        stats.lastReadDate = now
    }

    private func checkStreakBadges() {
        let streakMilestones: [(days: Int, type: BadgeType)] = [
            (7, .streak7),
            (30, .streak30),
            (100, .streak100)
        ]

        for milestone in streakMilestones {
            if streak.currentStreak == milestone.days {
                let alreadyAwarded = badges.contains(where: { $0.badgeType == milestone.type })
                if !alreadyAwarded {
                    let badge = BadgeAward(
                        surahNumber: 0,
                        surahName: milestone.type.title,
                        arabicName: milestone.type.subtitle,
                        badgeType: milestone.type
                    )
                    badges.append(badge)

                    // Award sawab for streak badge
                    let badgeSawab = badge.badgeType.sawabValue
                    stats.totalSawab += badgeSawab
                    print("✨ ProgressManager: +\(badgeSawab) sawab earned from \(milestone.type.title)! Total: \(stats.totalSawab)")

                    if preferences.celebrationsEnabled {
                        pendingBadge = badge
                    }

                    print("🔥 ProgressManager: Streak badge awarded: \(milestone.type.title)")
                }
            }
        }
    }

    // MARK: - Today's Verses Count

    private func updateTodayVersesCount() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todayVerses = verseProgress.filter { progress in
            calendar.isDate(progress.readDate, inSameDayAs: today)
        }

        stats.versesReadToday = todayVerses.count
    }

    // MARK: - Progress Stats

    func getProgressStats() -> ProgressStats {
        return stats
    }

    func getWeeklyProgress() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var weeklyData: [Int] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                weeklyData.append(0)
                continue
            }

            let dayStart = calendar.startOfDay(for: date)
            let versesOnDay = verseProgress.filter { progress in
                calendar.isDate(progress.readDate, inSameDayAs: dayStart)
            }.count

            weeklyData.append(versesOnDay)
        }

        return weeklyData
    }

    func getMonthlyProgress() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var monthlyData: [Int] = []

        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                monthlyData.append(0)
                continue
            }

            let dayStart = calendar.startOfDay(for: date)
            let versesOnDay = verseProgress.filter { progress in
                calendar.isDate(progress.readDate, inSameDayAs: dayStart)
            }.count

            monthlyData.append(versesOnDay)
        }

        return monthlyData
    }

    func getRecentActivity(limit: Int = 10) -> [VerseProgress] {
        return verseProgress
            .sorted { $0.readDate > $1.readDate }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Badge Management

    func getBadges() -> [BadgeAward] {
        return badges.sorted { $0.awardedDate > $1.awardedDate }
    }

    func dismissPendingBadge() {
        pendingBadge = nil
    }

    // MARK: - Preferences

    func updatePreferences(_ newPreferences: ProgressPreferences) {
        self.preferences = newPreferences
        saveProgress()
    }

    // MARK: - Reset Progress

    func resetProgress() {
        verseProgress.removeAll()
        streak = ReadingStreak()
        badges.removeAll()
        stats = ProgressStats()
        pendingBadge = nil

        saveProgress()

        print("🔄 ProgressManager: Progress reset")
    }
}
