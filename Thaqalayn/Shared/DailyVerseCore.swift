//
//  DailyVerseCore.swift
//  Thaqalayn
//
//  The pure date -> verse selection, shared by the app (via DailyVerseProvider)
//  and the ThaqalaynWidgets timeline. No @MainActor, no app singletons; the
//  bundle to read daily_verses.json from is injected. See DailyVerseProvider.swift
//  for the design notes on WHY selection works the way it does.
//
//  Target membership: Thaqalayn AND ThaqalaynWidgets.
//

import Foundation

// MARK: - Models (moved from QuranModels.swift)

/// The whole pool, decoded from daily_verses.json.
struct DailyVersePool: Codable {
    let version: Int
    let themes: [String]
    let verses: [DailyVerseEntry]
    let sacredDays: [SacredDay]
}

/// One curated reference. Carries no verse text - Arabic, translations and
/// tafsir all hydrate from quran_data.json at read time.
struct DailyVerseEntry: Codable, Identifiable {
    let id: Int
    let surah: Int
    let verse: Int
    /// Vocabulary key. Drives the no-two-days-running spacing rule.
    let themeKey: String
    let themeEn: String
    let themeUr: String
    let themeAr: String
}

/// A Hijri date that overrides the pool.
struct SacredDay: Codable {
    let month: Int   // Hijri month, 1-12
    let day: Int     // Hijri day, 1-30
    let surah: Int
    let verse: Int
    let occasionEn: String, occasionUr: String, occasionAr: String
    let themeEn: String, themeUr: String, themeAr: String
}

/// What a surface renders. `occasion` is non-nil only on a sacred day.
struct DailyVerseSelection: Equatable {
    let surah: Int
    let verse: Int
    /// The vocabulary key, or nil on a sacred day (which is not drawn from the pool).
    /// This is the axis the no-two-days-running rule is enforced on - NOT `themeEn`,
    /// which is a per-verse display label and is near-unique, so comparing it would
    /// silently pass even when the rule is broken.
    let themeKey: String?
    let themeEn: String, themeUr: String, themeAr: String
    let occasionEn: String?, occasionUr: String?, occasionAr: String?

    var id: String { "\(surah):\(verse)" }

    init(entry: DailyVerseEntry) {
        surah = entry.surah; verse = entry.verse
        themeKey = entry.themeKey
        themeEn = entry.themeEn; themeUr = entry.themeUr; themeAr = entry.themeAr
        occasionEn = nil; occasionUr = nil; occasionAr = nil
    }

    init(sacred: SacredDay) {
        surah = sacred.surah; verse = sacred.verse
        themeKey = nil
        themeEn = sacred.themeEn; themeUr = sacred.themeUr; themeAr = sacred.themeAr
        occasionEn = sacred.occasionEn; occasionUr = sacred.occasionUr; occasionAr = sacred.occasionAr
    }
}

// MARK: - Selector

/// Pure date -> verse selection. A `final class` only so the permutation cache
/// can mutate behind a `let` handle; it holds no other state. Not thread-safe:
/// each consumer owns its instance (the app's provider is @MainActor, the widget
/// timeline provider is called serially), which is exactly how it is used.
final class DailyVerseSelector {
    let pool: [DailyVerseEntry]
    let sacredDays: [SacredDay]

    /// Permuting the pool is microseconds, but we do it up to 30 times per foreground
    /// while scheduling, so cache it. Keyed by cycle because a cycle's opening theme
    /// depends on the previous cycle's closing theme (see `permutation(cycle:)`).
    private var permutationCache: [Int: [Int]] = [:]

    /// Fixed forever. Moving it reshuffles every user's year.
    static let epoch: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    }()

    init(bundle: Bundle) {
        guard let url = bundle.url(forResource: "daily_verses", withExtension: "json") else {
            fatalError("daily_verses.json missing from bundle")
        }
        let decoded: DailyVersePool
        do {
            decoded = try JSONDecoder().decode(DailyVersePool.self, from: Data(contentsOf: url))
        } catch {
            fatalError("Failed to parse daily_verses.json: \(error)")
        }
        guard !decoded.verses.isEmpty else {
            fatalError("daily_verses.json must contain at least one verse")
        }
        self.pool = decoded.verses
        self.sacredDays = decoded.sacredDays
    }

    /// The verse for any date. Pure - writes no state, has no side effects.
    func verse(for date: Date) -> DailyVerseSelection {
        if let sacred = sacredDay(for: date) {
            return DailyVerseSelection(sacred: sacred)
        }
        return DailyVerseSelection(entry: pooledEntry(for: date))
    }

    // MARK: - Sacred days

    private func sacredDay(for date: Date) -> SacredDay? {
        // Same two lines as IslamicCalendarManager.islamicCalendar, inlined so the
        // widget target does not need that (app-only) manager.
        var calendar = Calendar(identifier: .islamicUmmAlQura)
        calendar.timeZone = TimeZone.current
        let hijri = calendar.dateComponents([.month, .day], from: date)
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
