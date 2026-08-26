//
//  ProgressTabStrings.swift
//  Thaqalayn
//
//  Copy for the Progress tab - header, stat cards, streak, badges, and the
//  ring legend. Badge "titles" are spiritual ranks; surah-completion badges
//  keep the surah name.
//

import Foundation

enum ProgressTabStrings {
    // Header
    static let yourJourneyEyebrow = "Your Journey"
    static let progressTitle = "Progress"
    static let progressSubtitle = "A record of your time with the Qur'an"
    static let yourProgress = "Your Progress"
    static let trackJourney = "Track your Quran journey"

    // Stats
    static let versesRead = "Verses Read"
    static let surahsComplete = "Surahs Complete"
    static let quizzesDone = "Quizzes Done"
    static let totalSawab = "Total Sawab"
    static func ofTotal(_ n: Int) -> String { "of \(n)" }
    static let surahsTested = "surahs tested"
    static let blessingsEarned = "blessings earned"

    // Streak
    static func dayStreak(_ n: Int) -> String { "\(n) Day Streak" }
    static let keepItGoing = "Keep it going!"
    static let best = "Best"

    // Badges
    static let badges = "Badges"
    static func badgesDivider(_ count: Int, _ total: Int) -> String {
        "Badges · \(count) of \(total)"
    }
    static let noBadgesYet = "No badges yet"
    static let earnBadgesHint = "Complete surahs and build streaks to earn badges."
    /// Badge tile label: surah-completion badges show the surah name; rank badges
    /// use the English transliteration.
    static func badgeLabel(_ badge: BadgeAward) -> String {
        if badge.badgeType == .surahCompletion { return badge.surahName }
        return badge.badgeType.title
    }

    // Ring legend / center
    static let quran = "Quran"
    static let surahs = "Surahs"
    static let quizzes = "Quizzes"
    /// The seasonal ring label ("Ramadan" / "Hajj" / "Muharram"), shown as-is.
    static func seasonal(_ raw: String) -> String { raw }
}
