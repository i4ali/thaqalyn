//
//  DailyCrosswordManager.swift
//  Thaqalayn
//
//  Manages daily-crossword completion and streak tracking. Streak-only:
//  no reward points and no badges are awarded.
//
//  Mirrors DailyChallengeManager.swift exactly: same singleton shape, same UserDefaults
//  persistence approach, same day-key helpers. Daily Challenge is local-only (no Supabase
//  sync) — this manager is therefore local-only too.
//

import Foundation
import SwiftUI

@MainActor
final class DailyCrosswordManager: ObservableObject {
    static let shared = DailyCrosswordManager()

    @Published private(set) var streak = DailyCrosswordStreak()
    @Published private(set) var lastCompletion: DailyCrosswordCompletion?
    @Published private(set) var isCompletedToday = false

    // MARK: - UserDefaults keys

    private let dStreak       = "dcw_streak"
    private let dCompletion   = "dcw_lastCompletion"
    private let dCompletedDay = "dcw_completedDayKey"

    // MARK: - Init

    private init() {
        load()
        refreshForToday()
    }

    // MARK: - Day-key helpers (identical to DailyChallengeManager)

    static func dayKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    private var todayKey: String { Self.dayKey() }

    private var yesterdayKey: String {
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date())!
        return Self.dayKey(for: yesterday)
    }

    // MARK: - Completion

    func complete(seconds: Int, usedHint: Bool) {
        guard !isCompletedToday else { return }

        let today    = todayKey
        let yesterday = yesterdayKey

        streak = DailyCrosswordStreak.next(streak, todayKey: today, yesterdayKey: yesterday)

        let puzzleId = DailyCrosswordProvider.shared.today.id

        lastCompletion = DailyCrosswordCompletion(
            dayKey:       today,
            puzzleId:     puzzleId,
            seconds:      seconds,
            usedHint:     usedHint,
            completedAt:  Date()
        )
        isCompletedToday = true

        save()
    }

    // MARK: - Day-rollover refresh

    /// Recomputes isCompletedToday by comparing the stored completed-day key to today's key.
    /// Call on app foreground / scenePhase active so the card clears when the day rolls over.
    func refreshForToday() {
        let stored = UserDefaults.standard.string(forKey: dCompletedDay)
        isCompletedToday = (stored == todayKey)
    }

    // MARK: - Persistence

    private func load() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: dStreak),
           let s = try? JSONDecoder().decode(DailyCrosswordStreak.self, from: data) {
            streak = s
        }
        if let data = d.data(forKey: dCompletion),
           let c = try? JSONDecoder().decode(DailyCrosswordCompletion.self, from: data) {
            lastCompletion = c
        }
    }

    private func save() {
        let d = UserDefaults.standard
        if let data = try? JSONEncoder().encode(streak) {
            d.set(data, forKey: dStreak)
        }
        if let c = lastCompletion, let data = try? JSONEncoder().encode(c) {
            d.set(data, forKey: dCompletion)
        }
        d.set(todayKey, forKey: dCompletedDay)
    }
}
