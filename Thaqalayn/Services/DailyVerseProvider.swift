//
//  DailyVerseProvider.swift
//  Thaqalayn
//
//  Single source of truth for "today's verse". Feeds both the daily-verse push
//  and the Today-tab card, so the two can never disagree.
//
//  Selection is a pure function of the date:
//    1. If the date's Hijri (month, day) matches a sacred day, that verse wins.
//    2. Otherwise the pool is permuted once per cycle with a seeded shuffle, then
//       repaired so no two adjacent days share a theme, and the day's position in
//       the cycle indexes into it.
//
//  Statelessness is the point. It survives reinstall, it lets the notification
//  scheduler ask "what is the verse 27 days from now", and it keeps the push and
//  the card in sync without any shared mutable state.
//

import Foundation
import Combine

@MainActor
final class DailyVerseProvider: ObservableObject {
    static let shared = DailyVerseProvider()

    @Published private(set) var today: DailyVerseSelection

    private let pool: [DailyVerseEntry]
    private let sacredDays: [SacredDay]

    /// Permuting the pool is microseconds, but we do it up to 30 times per foreground
    /// while scheduling, so cache it. Keyed by cycle because a cycle's opening theme
    /// depends on the previous cycle's closing theme (see `permutation(cycle:)`).
    private var permutationCache: [Int: [Int]] = [:]

    /// Fixed forever. Moving it reshuffles every user's year.
    private static let epoch: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    }()

    private init() {
        guard let url = Bundle.main.url(forResource: "daily_verses", withExtension: "json") else {
            fatalError("daily_verses.json missing from bundle")
        }
        let decoded: DailyVersePool
        do {
            decoded = try JSONDecoder().decode(DailyVersePool.self, from: Data(contentsOf: url))
        } catch {
            fatalError("Failed to parse daily_verses.json: \(error)")
        }
        guard let first = decoded.verses.first else {
            fatalError("daily_verses.json must contain at least one verse")
        }

        self.pool = decoded.verses
        self.sacredDays = decoded.sacredDays
        self.today = DailyVerseSelection(entry: first)   // placeholder, replaced on the next line
        self.today = verse(for: IslamicCalendarManager.shared.now)
    }

    // MARK: - Public

    /// The verse for any date. Pure - writes no state, has no side effects.
    func verse(for date: Date) -> DailyVerseSelection {
        if let sacred = sacredDay(for: date) {
            return DailyVerseSelection(sacred: sacred)
        }
        return DailyVerseSelection(entry: pooledEntry(for: date))
    }

    /// Called when the app becomes active across a date boundary.
    func refreshIfDayChanged() {
        let resolved = verse(for: IslamicCalendarManager.shared.now)
        if resolved != today { today = resolved }
    }

    // MARK: - Sacred days

    private func sacredDay(for date: Date) -> SacredDay? {
        let hijri = IslamicCalendarManager.shared.islamicCalendar
            .dateComponents([.month, .day], from: date)
        guard let month = hijri.month, let day = hijri.day else { return nil }
        return sacredDays.first { $0.month == month && $0.day == day }
    }

    // MARK: - The permutation

    private func pooledEntry(for date: Date) -> DailyVerseEntry {
        let n = pool.count
        let index = dayIndex(for: date)
        let order = permutation(cycle: index / n)
        return pool[order[index % n]]
    }

    /// Whole days from the epoch, in the user's own timezone. A timezone move can
    /// shift a user by a day; that is harmless and self-corrects.
    private func dayIndex(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let start = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: Self.epoch, to: start).day ?? 0
        return max(0, days)
    }

    /// The pool order for a cycle.
    ///
    /// Built forward from the lowest uncached cycle, because a cycle's FIRST day must
    /// not repeat the theme of the previous cycle's LAST day. Without that link the
    /// "never two days running on the same theme" guarantee would quietly break once a
    /// year, at the seam between one pass through the pool and the next.
    ///
    /// Today this means building ~26 orders on first use (365 elements each, a few
    /// microseconds); every later call is a dictionary hit.
    private func permutation(cycle: Int) -> [Int] {
        if let cached = permutationCache[cycle] { return cached }

        var start = cycle
        while start > 0 && permutationCache[start - 1] == nil { start -= 1 }

        for current in start...cycle {
            let previousTheme = current > 0
                ? permutationCache[current - 1].flatMap { $0.last }.map(themeKey)
                : nil
            permutationCache[current] = spacedOrder(cycle: current, previousTheme: previousTheme)
        }
        return permutationCache[cycle] ?? Array(0..<pool.count)
    }

    private func themeKey(_ index: Int) -> String { pool[index].themeKey }

    /// Build a cycle's order: theme-spaced, verse-randomised.
    ///
    /// Greedy by largest remaining theme bucket. This is the standard construction for
    /// "rearrange so no two neighbours match", and it provably succeeds while no theme
    /// holds more than half the pool - validate.py caps any theme at a third, and the real
    /// spread is around 20 of 365. Ties are broken with the seeded RNG, and each bucket is
    /// pre-shuffled, so WHICH verse a theme contributes is unpredictable even though the
    /// theme rotation itself is even. Even rotation is a feature: a plain shuffle can put
    /// three mercy verses inside one week without ever placing two adjacent.
    ///
    /// `previousTheme` is the last day of the previous cycle, so the guarantee holds across
    /// the year seam and not just inside a year.
    ///
    /// A shuffle-then-repair pass was tried first and rejected: repairing a collision by
    /// scanning FORWARD for a swap candidate runs out of candidates near the end of the
    /// array, so every cycle ended with broken spacing in its final days. simulate.py
    /// caught it - see the note there before changing any of this.
    private func spacedOrder(cycle: Int, previousTheme: String?) -> [Int] {
        var rng = SplitMix64(seed: UInt64(bitPattern: Int64(cycle)) &+ 0x9E37_79B9_7F4A_7C15)

        var buckets: [String: [Int]] = [:]
        for index in pool.indices {
            buckets[pool[index].themeKey, default: []].append(index)
        }
        // Sorted keys keep the shuffle order identical on every device.
        for key in buckets.keys.sorted() {
            var members = buckets[key]!
            var i = members.count - 1
            while i > 0 {
                let j = Int(rng.next() % UInt64(i + 1))
                members.swapAt(i, j)
                i -= 1
            }
            buckets[key] = members
        }

        var result: [Int] = []
        result.reserveCapacity(pool.count)
        var last = previousTheme

        while result.count < pool.count {
            let available = buckets.filter { !$0.value.isEmpty && $0.key != last }
            guard let maxCount = available.values.map(\.count).max() else {
                // Only `last` still has entries. Unreachable while the validator's
                // theme cap holds; appending the remainder keeps this total rather
                // than crashing if someone ships a badly skewed pool.
                for key in buckets.keys.sorted() {
                    result.append(contentsOf: buckets[key]!)
                }
                break
            }
            let tied = available.filter { $0.value.count == maxCount }.keys.sorted()
            let chosen = tied[Int(rng.next() % UInt64(tied.count))]
            result.append(buckets[chosen]!.removeFirst())
            last = chosen
        }
        return result
    }
}

/// Deterministic, portable PRNG. Seeding by cycle makes the year's order identical
/// on every device and across reinstalls, and different every year. Swift's own
/// RandomNumberGenerator offers no such cross-version stability guarantee.
private struct SplitMix64 {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
