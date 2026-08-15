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
//  The selection itself lives in Shared/DailyVerseCore.swift (DailyVerseSelector),
//  shared verbatim with the ThaqalaynWidgets target; this class is the app-facing
//  observable wrapper around it.
//

import Foundation
import Combine

@MainActor
final class DailyVerseProvider: ObservableObject {
    static let shared = DailyVerseProvider()

    @Published private(set) var today: DailyVerseSelection

    private let selector: DailyVerseSelector

    private init() {
        selector = DailyVerseSelector(bundle: .main)
        today = selector.verse(for: IslamicCalendarManager.shared.now)
    }

    // MARK: - Public

    /// The verse for any date. Pure - writes no state, has no side effects.
    func verse(for date: Date) -> DailyVerseSelection {
        selector.verse(for: date)
    }

    /// Called when the app becomes active across a date boundary.
    func refreshIfDayChanged() {
        let resolved = verse(for: IslamicCalendarManager.shared.now)
        if resolved != today { today = resolved }
    }
}
