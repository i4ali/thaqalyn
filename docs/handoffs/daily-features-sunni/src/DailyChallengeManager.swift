//
//  DailyChallengeManager.swift
//  Thaqalayn
//
//  Manages daily-challenge completion and streak tracking. Streak-only:
//  no reward points and no badges are awarded.
//

import Foundation
import SwiftUI

@MainActor
final class DailyChallengeManager: ObservableObject {
    static let shared = DailyChallengeManager()

    @Published private(set) var streak = DailyChallengeStreak()
    @Published private(set) var lastCompletion: DailyChallengeCompletion?

    private let streakKey = "dailyChallengeStreak"
    private let completionKey = "dailyChallengeLastCompletion"

    private init() { load() }

    // MARK: - Day key

    static func dayKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var isCompletedToday: Bool { lastCompletion?.dayKey == Self.dayKey() }

    // MARK: - Completion

    /// MC / true-false / fill-in.
    func complete(challenge: DailyChallenge, wasCorrect: Bool) {
        guard !isCompletedToday else { return }
        recordCompletion(challenge: challenge, wasCorrect: wasCorrect)
    }

    /// Flashcards are self-graded — always counts as done. (gotIt informs nothing scoring-wise in v1.)
    func completeFlashcard(challenge: DailyChallenge, gotIt: Bool) {
        guard !isCompletedToday else { return }
        recordCompletion(challenge: challenge, wasCorrect: gotIt)
    }

    private func recordCompletion(challenge: DailyChallenge, wasCorrect: Bool) {
        let key = Self.dayKey()
        lastCompletion = DailyChallengeCompletion(
            dayKey: key, challengeId: challenge.id, format: challenge.format,
            wasCorrect: wasCorrect, completedAt: Date()
        )
        updateStreak(forNewCompletionDayKey: key)

        save()
    }

    // MARK: - Streak (pure static transition + instance wrapper)

    /// Pure streak-transition function. Used by both recordCompletion and the DEBUG self-check.
    static func nextStreak(
        _ s: DailyChallengeStreak,
        todayKey: String,
        yesterdayKey: String
    ) -> DailyChallengeStreak {
        var result = s
        if s.lastCompletedDayKey == todayKey {
            // Already counted today — no-op (defensive guard)
            return result
        } else if s.lastCompletedDayKey == yesterdayKey {
            result.currentStreak += 1
        } else {
            result.currentStreak = 1   // first ever, or chain broken
        }
        result.longestStreak = max(result.longestStreak, result.currentStreak)
        result.lastCompletedDayKey = todayKey
        return result
    }

    private func updateStreak(forNewCompletionDayKey today: String) {
        let cal = Calendar.current
        let yesterday = Self.dayKey(for: cal.date(byAdding: .day, value: -1, to: Date())!)
        streak = Self.nextStreak(streak, todayKey: today, yesterdayKey: yesterday)
    }

    // MARK: - Persistence

    private func load() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: streakKey),
           let s = try? JSONDecoder().decode(DailyChallengeStreak.self, from: data) { streak = s }
        if let data = d.data(forKey: completionKey),
           let c = try? JSONDecoder().decode(DailyChallengeCompletion.self, from: data) { lastCompletion = c }
    }

    private func save() {
        let d = UserDefaults.standard
        if let data = try? JSONEncoder().encode(streak) { d.set(data, forKey: streakKey) }
        if let c = lastCompletion, let data = try? JSONEncoder().encode(c) { d.set(data, forKey: completionKey) }
    }
}

// MARK: - DEBUG streak self-check

#if DEBUG
extension DailyChallengeManager {
    /// Pure-logic check of the streak transitions. Callable from a DEBUG button; remove before ship.
    static func _selfCheckStreak() {
        // Helper: apply nextStreak with explicit day strings
        func apply(_ s: DailyChallengeStreak, today: String, yesterday: String) -> DailyChallengeStreak {
            nextStreak(s, todayKey: today, yesterdayKey: yesterday)
        }

        let blank = DailyChallengeStreak()

        // Case 1: Fresh user completes day "2024-01-01" → current streak becomes 1
        let case1 = apply(blank, today: "2024-01-01", yesterday: "2023-12-31")
        assert(case1.currentStreak == 1, "Fresh + first day should yield streak 1")
        assert(case1.longestStreak == 1, "Longest should also be 1")
        assert(case1.lastCompletedDayKey == "2024-01-01", "lastCompletedDayKey should be today")

        // Case 2: current streak 1, last completed yesterday → should become 2
        let case2 = apply(case1, today: "2024-01-02", yesterday: "2024-01-01")
        assert(case2.currentStreak == 2, "Continuing streak should yield 2")
        assert(case2.longestStreak == 2, "Longest should track up")

        // Case 3: gap of 2 days → reset to 1
        let case3 = apply(case2, today: "2024-01-04", yesterday: "2024-01-03")
        assert(case3.currentStreak == 1, "Gap of 2 days should reset to 1")
        assert(case3.longestStreak == 2, "Longest should be preserved across reset")

        // Case 4: same-day call → no double-count
        let case4 = apply(case3, today: "2024-01-04", yesterday: "2024-01-03")
        assert(case4.currentStreak == 1, "Same-day re-call should not increment streak")

        print("DailyChallengeManager._selfCheckStreak: all assertions passed")
    }
}
#endif
