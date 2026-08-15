//
//  WidgetScheduleBuilderTests.swift
//  ThaqalaynTests
//
//  The schedule builder is pure: (dayStart, dayIndex, times?, featured gem,
//  salah pool size) -> timeline entries. These tests pin the day shape: verse
//  in the morning, ONE gem after Zohr, then the doorway (today's journey or
//  deep dive) owns the reflection beats from Asr until the night close.
//

import XCTest
@testable import Thaqalayn

final class WidgetScheduleBuilderTests: XCTestCase {

    private let dayStart = Date(timeIntervalSince1970: 1_786_600_800)  // arbitrary midnight-ish anchor
    private func h(_ hours: Double) -> Date { dayStart.addingTimeInterval(hours * 3600) }

    private var fakeTimes: DayPrayerTimes {
        DayPrayerTimes(fajr: h(4.5), sunrise: h(6), dhuhr: h(12.25),
                       asr: h(16), maghrib: h(19.75), isha: h(21))
    }

    private func schedule(times: DayPrayerTimes?, featuredGemIndex: Int = 0,
                          dayIndex: Int = 9700,
                          salahLineCount: Int = 100) -> [WidgetTimelineEntryModel] {
        WidgetScheduleBuilder.schedule(for: dayStart, dayIndex: dayIndex, times: times,
                                       featuredGemIndex: featuredGemIndex,
                                       salahLineCount: salahLineCount)
    }

    private func isPrayer(_ beat: WidgetBeat) -> Bool {
        if case .prayer = beat { return true }
        return false
    }

    func testDayWithPrayerTimesHasElevenEntriesInOrder() {
        let s = schedule(times: fakeTimes)
        // verse, Fajr, verse(sunrise), Zohr, gem0, Asr, doorway, Maghrib, doorway, Isha, night
        XCTAssertEqual(s.count, 11)
        XCTAssertEqual(s[0].beat, .verse)
        XCTAssertEqual(s[0].date, dayStart)
        guard case .prayer(let n1, _, _) = s[1].beat else { return XCTFail("expected Fajr") }
        XCTAssertEqual(n1, "Fajr")
        XCTAssertEqual(s[2].beat, .verse)
        XCTAssertEqual(s[2].date, fakeTimes.sunrise)
        guard case .prayer(let n3, _, _) = s[3].beat else { return XCTFail("expected Zohr") }
        XCTAssertEqual(n3, "Zohr")
        XCTAssertEqual(s[4].beat, .gem(index: 0))
        guard case .prayer(let n5, _, _) = s[5].beat else { return XCTFail("expected Asr") }
        XCTAssertEqual(n5, "Asr")
        XCTAssertEqual(s[6].beat, .doorway(slot: 0))
        guard case .prayer(let n7, _, _) = s[7].beat else { return XCTFail("expected Maghrib") }
        XCTAssertEqual(n7, "Maghrib")
        XCTAssertEqual(s[8].beat, .doorway(slot: 1))
        guard case .prayer(let n9, _, _) = s[9].beat else { return XCTFail("expected Isha") }
        XCTAssertEqual(n9, "Isha")
        XCTAssertEqual(s[10].beat, .night)
        XCTAssertEqual(s.filter { isPrayer($0.beat) }.count, 5)
    }

    func testDoorwaySlotsOwnAsrThroughEvening() {
        // Two journey slots: the afternoon journey after Asr, the OTHER-kind
        // journey (dive on experience days) after Maghrib.
        let s = schedule(times: fakeTimes)
        let doorways = s.compactMap { entry -> Int? in
            if case .doorway(let slot) = entry.beat { return slot }
            return nil
        }
        XCTAssertEqual(doorways, [0, 1])
        XCTAssertEqual(s[6].date, fakeTimes.asr.addingTimeInterval(45 * 60))
        XCTAssertEqual(s[8].date, fakeTimes.maghrib.addingTimeInterval(45 * 60))
    }

    func testOnlyGemZeroIsScheduled() {
        let gems = schedule(times: fakeTimes, featuredGemIndex: 0).compactMap {
            if case .gem(let index) = $0.beat { return index }
            return nil
        }
        XCTAssertEqual(gems, [0], "exactly one gem beat, index 0 when 0 is featured")
    }

    func testPrayerBeatsHoldRoughly45MinutesExceptFajr() {
        let s = schedule(times: fakeTimes)
        for (i, entry) in s.enumerated() {
            guard case .prayer(let name, _, _) = entry.beat, i + 1 < s.count else { continue }
            let hold = s[i + 1].date.timeIntervalSince(entry.date)
            if name == "Fajr" {
                XCTAssertEqual(s[i + 1].date, fakeTimes.sunrise, "Fajr holds until sunrise")
            } else {
                XCTAssertEqual(hold, 45 * 60, accuracy: 1, "\(name) should hold 45 minutes")
            }
        }
    }

    func testDayWithoutLocationHasNoPrayerBeats() {
        let s = schedule(times: nil)
        XCTAssertEqual(s.map(\.beat),
                       [.verse, .gem(index: 0), .doorway(slot: 0), .doorway(slot: 1), .night])
        XCTAssertEqual(s.map(\.date), [dayStart, h(12), h(16), h(19.5), h(22.5)])
        XCTAssertFalse(s.contains { isPrayer($0.beat) })
    }

    func testSalahLineRotationIsDeterministic() {
        func lineIndices(dayIndex: Int) -> [Int] {
            schedule(times: fakeTimes, dayIndex: dayIndex).compactMap {
                if case .prayer(_, _, let line) = $0.beat { return line }
                return nil
            }
        }
        let today = lineIndices(dayIndex: 9700)
        XCTAssertEqual(today, lineIndices(dayIndex: 9700), "same day -> same lines")
        XCTAssertEqual(today, [0, 1, 2, 3, 4].map { (9700 * 5 + $0) % 100 })
        let tomorrow = lineIndices(dayIndex: 9701)
        XCTAssertEqual(tomorrow, [0, 1, 2, 3, 4].map { (9701 * 5 + $0) % 100 })
        XCTAssertNotEqual(today, tomorrow)
    }

    func testEntriesAreStrictlyAscendingAndStartAtOrBeforeMidnight() {
        for s in [schedule(times: fakeTimes), schedule(times: nil),
                  schedule(times: fakeTimes, featuredGemIndex: 3)] {
            XCTAssertLessThanOrEqual(s[0].date, dayStart)
            for i in 1..<s.count {
                XCTAssertGreaterThan(s[i].date, s[i - 1].date)
            }
        }
    }

    func testFeaturedGemIndexRotatesByYear() {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
        let d2026 = cal.date(from: DateComponents(year: 2026, month: 8, day: 11))!
        let d2027 = cal.date(from: DateComponents(year: 2027, month: 8, day: 11))!
        XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2026, gemCount: 4), 2) // 26 % 4
        XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2027, gemCount: 4), 3)
        XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2026, gemCount: 1), 0)
        XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2026, gemCount: 0), 0) // never crashes
    }

    func testRotationIndexIsSafe() {
        XCTAssertEqual(WidgetScheduleBuilder.rotationIndex(dayIndex: 9723, count: 3), 9723 % 3)
        XCTAssertEqual(WidgetScheduleBuilder.rotationIndex(dayIndex: 5, count: 0), 0)
    }

    func testScheduleEmitsFeaturedGemIndex() {
        let s = WidgetScheduleBuilder.schedule(for: dayStart, dayIndex: 9700, times: fakeTimes,
                                               featuredGemIndex: 2, salahLineCount: 100)
        XCTAssertEqual(s[4].beat, .gem(index: 2), "the post-Zohr slot carries the featured gem")
        let gems = s.compactMap { entry -> Int? in
            if case .gem(let index) = entry.beat { return index }
            return nil
        }
        XCTAssertEqual(gems, [2], "exactly one gem beat, carrying the featured index")
    }
}
