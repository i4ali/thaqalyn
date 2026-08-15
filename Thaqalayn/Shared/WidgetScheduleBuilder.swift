//
//  WidgetScheduleBuilder.swift
//  Thaqalayn
//
//  Pure (date, prayer times, content shape) -> widget timeline entries.
//  The unfolding day: the verse holds the morning, one gem lands after Zohr,
//  and from Asr onward the doorway (today's journey or deep dive) owns the
//  reflection beats until the night close. Prayer beats interleave at the
//  adhan minutes and revert 45 minutes later - except Fajr, which reverts
//  at sunrise. Every day has a doorway: the verse's linked journey when one
//  exists, else the catalog rotation (resolved by WidgetContent).
//
//  Target membership: Thaqalayn AND ThaqalaynWidgets (tested from ThaqalaynTests).
//

import Foundation

enum WidgetBeat: Equatable {
    case verse                       // dayStart -> Zohr (and pre-Fajr hours)
    case gem(index: Int)             // after Zohr
    /// Journey promo beats. `slot` indexes the day's journeys: 0 = afternoon
    /// (the verse-linked journey, or the rotation pick), 1 = evening (the
    /// OTHER kind - a deep dive on experience days and vice versa - so theme
    /// dives like Ikhlas and Taqwa get airtime every day).
    case doorway(slot: Int)
    case night                       // after the Isha beat ends
    /// `salahLineIndex` indexes the bundled salah-lines pool; the view layer
    /// resolves the text (the builder never sees the strings).
    case prayer(name: String, time: Date, salahLineIndex: Int)
}

struct WidgetTimelineEntryModel: Equatable {
    let date: Date          // when this entry becomes current
    let beat: WidgetBeat
}

struct WidgetScheduleBuilder {

    /// How long a prayer beat owns the widget before reverting to the day-part
    /// beat (Fajr instead reverts at sunrise).
    static let prayerHold: TimeInterval = 45 * 60

    /// The gem the day features. Rotates by Gregorian year so a verse's day
    /// reads differently each year - this is why every gem gets an authored line.
    static func featuredGemIndex(for date: Date, gemCount: Int) -> Int {
        guard gemCount > 0 else { return 0 }
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        return max(0, cal.component(.year, from: date) - 2000) % gemCount
    }

    /// Deterministic pick from a rotating pool (essence lines, etc.).
    static func rotationIndex(dayIndex: Int, count: Int) -> Int {
        count > 0 ? dayIndex % count : 0
    }

    /// - Parameters:
    ///   - dayStart: local midnight; entry 0 shows the verse from here (the
    ///     pre-Fajr hours belong to the NEW day's verse).
    ///   - dayIndex: whole days since the daily-verse epoch; drives the salah
    ///     line rotation so consecutive days advance through the pool.
    ///   - times: nil = no cached location; prayer beats are simply omitted
    ///     and the reflection beats land at fixed hours.
    ///   - featuredGemIndex: the gem the post-Zohr beat shows; the year
    ///     rotation pick from `featuredGemIndex(for:gemCount:)`.
    ///   - salahLineCount: size of the salah-lines pool.
    static func schedule(for dayStart: Date,
                         dayIndex: Int,
                         times: DayPrayerTimes?,
                         featuredGemIndex: Int,
                         salahLineCount: Int) -> [WidgetTimelineEntryModel] {
        let lineCount = max(1, salahLineCount)
        func line(_ ordinal: Int) -> Int { (dayIndex * 5 + ordinal) % lineCount }

        var entries: [WidgetTimelineEntryModel] = [.init(date: dayStart, beat: .verse)]

        if let t = times {
            entries.append(.init(date: t.fajr,
                                 beat: .prayer(name: "Fajr", time: t.fajr, salahLineIndex: line(0))))
            entries.append(.init(date: t.sunrise, beat: .verse))
            entries.append(.init(date: t.dhuhr,
                                 beat: .prayer(name: "Zohr", time: t.dhuhr, salahLineIndex: line(1))))
            entries.append(.init(date: t.dhuhr.addingTimeInterval(prayerHold),
                                 beat: .gem(index: featuredGemIndex)))
            entries.append(.init(date: t.asr,
                                 beat: .prayer(name: "Asr", time: t.asr, salahLineIndex: line(2))))
            entries.append(.init(date: t.asr.addingTimeInterval(prayerHold),
                                 beat: .doorway(slot: 0)))
            entries.append(.init(date: t.maghrib,
                                 beat: .prayer(name: "Maghrib", time: t.maghrib, salahLineIndex: line(3))))
            entries.append(.init(date: t.maghrib.addingTimeInterval(prayerHold),
                                 beat: .doorway(slot: 1)))
            entries.append(.init(date: t.isha,
                                 beat: .prayer(name: "Isha", time: t.isha, salahLineIndex: line(4))))
            entries.append(.init(date: t.isha.addingTimeInterval(prayerHold),
                                 beat: .night))
        } else {
            // Fixed local hours, derived by offset from midnight. On a DST
            // switch day these drift by an hour; harmless for content beats.
            entries.append(.init(date: dayStart.addingTimeInterval(12.0 * 3600),
                                 beat: .gem(index: featuredGemIndex)))
            entries.append(.init(date: dayStart.addingTimeInterval(16.0 * 3600),
                                 beat: .doorway(slot: 0)))
            entries.append(.init(date: dayStart.addingTimeInterval(19.5 * 3600),
                                 beat: .doorway(slot: 1)))
            entries.append(.init(date: dayStart.addingTimeInterval(22.5 * 3600),
                                 beat: .night))
        }

        // Drop entries that would repeat the beat already on screen, and keep
        // the sequence strictly ascending.
        var out: [WidgetTimelineEntryModel] = []
        for entry in entries {
            if let last = out.last {
                if entry.beat == last.beat { continue }
                if entry.date <= last.date { continue }
            }
            out.append(entry)
        }
        return out
    }
}
