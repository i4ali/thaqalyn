//
//  JourneyCatalog.swift
//  Thaqalayn
//
//  Static registry of the seasonal Journeys shown in the Journey hub, plus the
//  per-journey status (active / coming-soon / ended) computed by bucketing the
//  current Hijri date against each journey's content-start month. Reuses the
//  existing IslamicCalendarManager season logic; adds no new date constants of
//  its own beyond each journey's content-start month.
//

import SwiftUI

/// A journey's state relative to the current Hijri date.
enum JourneyStatus: Equatable {
    /// In season — openable. `line` is the existing season-status string.
    case active(line: String)
    /// Season is still ahead this Hijri year — locked, with a countdown.
    case comingSoon(daysUntil: Int, startsLabel: String)
    /// Season already passed this Hijri year — locked. `daysUntil` counts to next
    /// year's return so the hub can sort ended journeys by soonest and flag the
    /// nearest one as "next up".
    case ended(daysUntil: Int, returnsLabel: String)

    var isActive: Bool { if case .active = self { return true } else { return false } }
}

/// One journey in the hub. Static registry — see `JourneyDescriptor.all`.
struct JourneyDescriptor: Identifiable {
    /// Stable id — matches the deep-link id and notification "journey" key.
    let id: String
    let eyebrow: String          // e.g. "30-Day Journey"
    let title: String            // e.g. "Ramadan"
    let sfSymbol: String         // e.g. "moon.stars.fill"
    /// Hijri month the journey's content begins (Ramadan=9, Dhul-Hijjah=12, Muharram=1).
    let contentStartMonth: Int
    /// True when this journey's `isActive()` season window is open.
    let isActive: () -> Bool
    /// The existing season-status string for the active card line.
    let statusLine: () -> String
    /// The existing journey screen, reused untouched inside a full-screen cover.
    let destination: () -> AnyView
    /// When true, `sfSymbol` is a custom asset name (template image), not an SF Symbol.
    var iconIsCustomAsset: Bool = false
    /// Optional custom status (for journeys whose schedule isn't a single content month,
    /// e.g. Fatimiyya's two windows). When set, `status(using:)` uses it verbatim.
    var statusOverride: ((IslamicCalendarManager) -> JourneyStatus)? = nil

    static let all: [JourneyDescriptor] = [
        JourneyDescriptor(
            id: "ramadan", eyebrow: "30-Day Journey", title: "Ramadan",
            sfSymbol: "moon.stars.fill", contentStartMonth: 9,
            isActive: { IslamicCalendarManager.shared.isRamadanSeason() },
            statusLine: { IslamicCalendarManager.shared.ramadanSeasonStatus() },
            destination: { AnyView(RamadanJourneyView()) }
        ),
        JourneyDescriptor(
            id: "hajj", eyebrow: "10-Day Journey", title: "Dhul-Hijjah",
            sfSymbol: "building.columns.fill", contentStartMonth: 12,
            isActive: { IslamicCalendarManager.shared.isHajjSeason() },
            statusLine: { IslamicCalendarManager.shared.hajjSeasonStatus() },
            destination: { AnyView(HajjJourneyView()) }
        ),
        JourneyDescriptor(
            id: "muharram", eyebrow: "10-Day Journey", title: "Muharram",
            sfSymbol: "flame.fill", contentStartMonth: 1,
            isActive: { IslamicCalendarManager.shared.isMuharramSeason() },
            statusLine: { IslamicCalendarManager.shared.muharramSeasonStatus() },
            destination: { AnyView(MuharramJourneyView()) }
        ),
        JourneyDescriptor(
            id: "fatimiyya", eyebrow: "Mourning of az-Zahrā (AS)", title: "Fatimiyya",
            sfSymbol: "tulip", contentStartMonth: 5,
            isActive: { IslamicCalendarManager.shared.isFatimiyyaSeason() },
            statusLine: { IslamicCalendarManager.shared.fatimiyyaSeasonStatus() },
            destination: { AnyView(FatimiyyaJourneyView()) },
            iconIsCustomAsset: true,
            statusOverride: { cal in
                if cal.isFatimiyyaSeason() { return .active(line: cal.fatimiyyaSeasonStatus()) }
                let icalendar = cal.islamicCalendar
                guard let year = cal.currentIslamicDate().year else {
                    preconditionFailure("Hijri year unavailable for fatimiyya")
                }
                func hijri(_ y: Int, _ m: Int, _ d: Int) -> Date {
                    guard let date = icalendar.date(from: DateComponents(year: y, month: m, day: d)) else {
                        preconditionFailure("Could not form Hijri date for fatimiyya")
                    }
                    return date
                }
                func daysBetween(_ a: Date, _ b: Date) -> Int {
                    let c = Calendar.current
                    return max(0, c.dateComponents([.day], from: c.startOfDay(for: a), to: c.startOfDay(for: b)).day ?? 0)
                }
                func medium(_ d: Date) -> String {
                    let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none
                    f.locale = Locale(identifier: CommentaryLanguageManager.shared.selectedLanguage == .urdu ? "ur" : "en")
                    return f.string(from: d)
                }
                let now = cal.now
                let firstStart  = hijri(year, 5, 8)
                let secondStart = hijri(year, 6, 1)
                let lang = CommentaryLanguageManager.shared.selectedLanguage
                if now < firstStart {
                    return .comingSoon(daysUntil: daysBetween(now, firstStart), startsLabel: JourneyStrings.firstFatimiyya(medium(firstStart), lang))
                }
                if now < secondStart {
                    return .comingSoon(daysUntil: daysBetween(now, secondStart), startsLabel: JourneyStrings.secondFatimiyya(medium(secondStart), lang))
                }
                let nextReturn = hijri(year + 1, 5, 8)
                return .ended(daysUntil: daysBetween(now, nextReturn),
                              returnsLabel: JourneyStrings.returns(medium(nextReturn), lang))
            }
        ),
    ]

    static func byId(_ id: String) -> JourneyDescriptor? { all.first { $0.id == id } }
}

extension JourneyDescriptor {
    /// Status for the current Hijri date. Bucketing: active → in season;
    /// else if this Hijri year's content-start is still ahead → coming soon;
    /// else (it already began this year and we're not active) → ended.
    func status(using cal: IslamicCalendarManager = .shared) -> JourneyStatus {
        if let statusOverride { return statusOverride(cal) }
        if isActive() { return .active(line: statusLine()) }

        let icalendar = cal.islamicCalendar
        guard let year = cal.currentIslamicDate().year else {
            preconditionFailure("Hijri year unavailable for \(id)")
        }
        guard let thisYearStart = icalendar.date(
            from: DateComponents(year: year, month: contentStartMonth, day: 1)
        ) else {
            preconditionFailure("Could not form Hijri content-start for \(id)")
        }

        let now = cal.now
        let lang = CommentaryLanguageManager.shared.selectedLanguage
        if now < thisYearStart {
            return .comingSoon(
                daysUntil: Self.daysBetween(now, thisYearStart),
                startsLabel: JourneyStrings.begins(Self.medium(thisYearStart), lang)
            )
        }
        guard let nextYearStart = icalendar.date(
            from: DateComponents(year: year + 1, month: contentStartMonth, day: 1)
        ) else {
            preconditionFailure("Could not form next Hijri content-start for \(id)")
        }
        return .ended(daysUntil: Self.daysBetween(now, nextYearStart),
                      returnsLabel: JourneyStrings.returns(Self.medium(nextYearStart), lang))
    }

    private static func daysBetween(_ a: Date, _ b: Date) -> Int {
        let c = Calendar.current
        let d = c.dateComponents([.day], from: c.startOfDay(for: a), to: c.startOfDay(for: b)).day ?? 0
        return max(0, d)
    }

    private static func medium(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none
        f.locale = Locale(identifier: CommentaryLanguageManager.shared.selectedLanguage == .urdu ? "ur" : "en")
        return f.string(from: date)
    }
}
