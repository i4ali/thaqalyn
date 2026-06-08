//
//  JourneyAnnouncements.swift
//  Thaqalayn
//
//  Data-driven table + a pure, side-effect-free scheduling decision for
//  "Journey is open" notifications. The decision function takes an injected
//  "now" and Hijri date so it is verifiable without a test harness.
//

import Foundation

/// One seasonal Journey that gets a "tab is now available" announcement.
struct JourneyAnnouncement {
    /// Stable id — also the deep-link `id` and the notification identifier suffix.
    let id: String
    /// Notification title.
    let title: String
    /// Notification body.
    let body: String
    /// Hijri month the tab appears (lead-in start). 8=Sha'ban, 11=Dhul-Qa'dah, 12=Dhul-Hijjah.
    let leadInHijriMonth: Int
    /// Hijri day the tab appears.
    let leadInHijriDay: Int
    /// True when the lead-in falls in the Hijri year *before* the content month
    /// (Muharram: lead-in 25 Dhul-Hijjah of year C-1, content Muharram of year C).
    let leadInIsPreviousHijriYear: Bool
    /// `MainTabView` tab tag this journey deep-links to.
    let tabTag: Int
    /// Whether the given Islamic (month, day) is inside this journey's announce
    /// window — narrower than the season window: it excludes the post-content
    /// grace tail so a late catch-up never fires on Eid etc.
    let isWithinAnnounceWindow: (_ islamicMonth: Int, _ islamicDay: Int) -> Bool

    /// The Hijri year of this journey's *content* month for the cycle `now`
    /// belongs to (the dedup key). See spec §3.
    func cycleYear(currentIslamicYear: Int, currentIslamicMonth: Int) -> Int {
        guard leadInIsPreviousHijriYear else {
            return currentIslamicYear // Ramadan / Hajj: lead-in & content share the year.
        }
        // Muharram: content year == current year only when we are already in
        // Muharram (month 1); otherwise the next Muharram is next Hijri year.
        return currentIslamicYear + (currentIslamicMonth == 1 ? 0 : 1)
    }

    /// The Hijri year the lead-in date itself falls in, for a given cycle year.
    func leadInHijriYear(forCycleYear cycleYear: Int) -> Int {
        leadInIsPreviousHijriYear ? cycleYear - 1 : cycleYear
    }
}

/// Outcome of the pure scheduling decision.
struct JourneyScheduleDecision: Equatable {
    /// If non-nil, ensure an idempotent calendar notification exists at this date.
    let calendarFireDate: Date?
    /// If true, fire the ~5s catch-up now.
    let fireCatchUpNow: Bool
    /// If non-nil, persist `handledYears[id] = this value`.
    let markHandledCycleYear: Int?

    static let noop = JourneyScheduleDecision(
        calendarFireDate: nil, fireCatchUpNow: false, markHandledCycleYear: nil
    )
}

extension JourneyAnnouncement {
    /// The canonical journeys. Adding a future journey = append one row here
    /// (+ its conditional tab in `MainTabView`); the scheduler is unchanged.
    static let all: [JourneyAnnouncement] = [
        JourneyAnnouncement(
            id: "ramadan",
            title: "🌙 The Ramadan Journey is open",
            body: "The blessed month draws near. Step into your Ramadan Journey through the Quran. Tap to begin.",
            leadInHijriMonth: 8, leadInHijriDay: 25,
            leadInIsPreviousHijriYear: false,
            tabTag: 4,
            isWithinAnnounceWindow: { month, day in
                (month == 8 && day >= 25) || month == 9 // Sha'ban 25-30 or all Ramadan; NOT Shawwal.
            }
        ),
        JourneyAnnouncement(
            id: "hajj",
            title: "🕋 The Dhul-Hijjah Journey is open",
            body: "The sacred days of Hajj approach. Begin your 10-day Dhul-Hijjah Journey. Tap to enter.",
            leadInHijriMonth: 11, leadInHijriDay: 25,
            leadInIsPreviousHijriYear: false,
            tabTag: 5,
            isWithinAnnounceWindow: { month, day in
                (month == 11 && day >= 25) || (month == 12 && day <= 10) // NOT the 11-13 tail.
            }
        ),
        JourneyAnnouncement(
            id: "muharram",
            title: "The Muharram Journey is open",
            body: "The month of Imam al-Husayn (AS) approaches. Walk the first ten days of Muharram in remembrance. Tap to begin.",
            leadInHijriMonth: 12, leadInHijriDay: 25,
            leadInIsPreviousHijriYear: true,
            tabTag: 6,
            isWithinAnnounceWindow: { month, day in
                (month == 12 && day >= 25) || (month == 1 && day <= 10) // NOT the 11-12 grace.
            }
        ),
        JourneyAnnouncement(
            id: "fatimiyya",
            title: "The Fatimiyya mourning has begun",
            body: "The days of az-Zahrā (AS). Walk the Ayyam-e-Fatimiyya through the Quran. Tap to begin.",
            leadInHijriMonth: 5, leadInHijriDay: 8,
            leadInIsPreviousHijriYear: false,
            tabTag: 4,
            isWithinAnnounceWindow: { month, day in
                month == 5 && day >= 8 && day <= 15
            }
        )
    ]
}

/// Pure, side-effect-free scheduling decision. The only calendar use is the
/// deterministic Hijri→Gregorian conversion via the injected `islamicCalendar`.
///
/// - Parameters:
///   - now: the current instant.
///   - islamicYear/Month/Day: the Hijri date of `now`.
///   - preferredHour/Minute: the user's notification time.
///   - islamicCalendar: an Umm al-Qura `Calendar` for Hijri→Gregorian.
///   - handledCycleYear: the cycleYear already committed for this journey, or nil.
func journeyScheduleDecision(
    journey: JourneyAnnouncement,
    now: Date,
    islamicYear: Int,
    islamicMonth: Int,
    islamicDay: Int,
    preferredHour: Int,
    preferredMinute: Int,
    islamicCalendar: Calendar,
    handledCycleYear: Int?
) -> JourneyScheduleDecision {
    let cycleYear = journey.cycleYear(
        currentIslamicYear: islamicYear,
        currentIslamicMonth: islamicMonth
    )
    let leadInHYear = journey.leadInHijriYear(forCycleYear: cycleYear)

    var hijri = DateComponents()
    hijri.year = leadInHYear
    hijri.month = journey.leadInHijriMonth
    hijri.day = journey.leadInHijriDay
    guard let leadInDay = islamicCalendar.date(from: hijri) else {
        return .noop
    }

    var gregorian = Calendar.current
    gregorian.timeZone = .current
    var fireComps = gregorian.dateComponents([.year, .month, .day], from: leadInDay)
    fireComps.hour = preferredHour
    fireComps.minute = preferredMinute
    let fireDate = gregorian.date(from: fireComps) ?? leadInDay

    if fireDate > now {
        // (Re)materialize the calendar notification — idempotent, wipe-recoverable.
        // Mark handled only the first time we commit this cycle.
        let mark = (handledCycleYear == cycleYear) ? nil : cycleYear
        return JourneyScheduleDecision(
            calendarFireDate: fireDate,
            fireCatchUpNow: false,
            markHandledCycleYear: mark
        )
    }

    // Lead-in instant has passed.
    if journey.isWithinAnnounceWindow(islamicMonth, islamicDay),
       handledCycleYear != cycleYear {
        return JourneyScheduleDecision(
            calendarFireDate: nil,
            fireCatchUpNow: true,
            markHandledCycleYear: cycleYear
        )
    }
    return .noop
}

