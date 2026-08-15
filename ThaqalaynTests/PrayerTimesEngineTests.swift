//
//  PrayerTimesEngineTests.swift
//  ThaqalaynTests
//
//  Known-value guards for the Ja'fari prayer-time engine (.tehran method).
//

import XCTest
@testable import Thaqalayn

final class PrayerTimesEngineTests: XCTestCase {

    // Reference: adhan-swift .tehran method, Qum (34.64, 50.88), 2026-08-11.
    func testQumTimesAreSane() throws {
        let engine = PrayerTimesEngine()
        let times = try XCTUnwrap(engine.times(
            latitude: 34.64, longitude: 50.88,
            date: DateComponents(year: 2026, month: 8, day: 11)))
        XCTAssertLessThan(times.fajr, times.sunrise)
        XCTAssertLessThan(times.sunrise, times.dhuhr)
        XCTAssertLessThan(times.dhuhr, times.asr)
        XCTAssertLessThan(times.asr, times.maghrib)
        XCTAssertLessThan(times.maghrib, times.isha)
    }

    func testMaghribIsDelayedPastSunset() throws {
        // Ja'fari maghrib is delayed past astronomical sunset; the .tehran method
        // encodes this (sun 4.5 degrees below the horizon). adhan-swift keeps
        // SolarTime internal, so compare against .muslimWorldLeague maghrib,
        // which IS astronomical sunset. Guards that .tehran stays configured.
        let engine = PrayerTimesEngine()
        let london = DateComponents(year: 2026, month: 8, day: 11)
        let jafari = try XCTUnwrap(engine.times(latitude: 51.5, longitude: -0.12, date: london))
        let sunset = try XCTUnwrap(PrayerTimesEngine.astronomicalSunsetForTesting(
            latitude: 51.5, longitude: -0.12, date: london))
        XCTAssertGreaterThan(jafari.maghrib.timeIntervalSince(sunset), 5 * 60)
    }

    func testDayContainingMomentCrossesTimezonesCorrectly() throws {
        // 2026-08-11 22:00 in Tehran is already 2026-08-11; the same instant in
        // Auckland is 2026-08-12. The convenience must resolve the civil day in
        // the given timezone, not the device's.
        let engine = PrayerTimesEngine()
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let moment = utc.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 18, minute: 30))!

        let tehranDay = try XCTUnwrap(engine.times(
            latitude: 35.69, longitude: 51.42,
            timeZone: TimeZone(identifier: "Asia/Tehran")!, containing: moment))
        let tehranExplicit = try XCTUnwrap(engine.times(
            latitude: 35.69, longitude: 51.42,
            date: DateComponents(year: 2026, month: 8, day: 11)))
        XCTAssertEqual(tehranDay.fajr, tehranExplicit.fajr)

        let aucklandDay = try XCTUnwrap(engine.times(
            latitude: -36.85, longitude: 174.76,
            timeZone: TimeZone(identifier: "Pacific/Auckland")!, containing: moment))
        let aucklandExplicit = try XCTUnwrap(engine.times(
            latitude: -36.85, longitude: 174.76,
            date: DateComponents(year: 2026, month: 8, day: 12)))
        XCTAssertEqual(aucklandDay.fajr, aucklandExplicit.fajr)
    }

    func testAllListsFivePrayersInOrder() throws {
        let engine = PrayerTimesEngine()
        let times = try XCTUnwrap(engine.times(
            latitude: 34.64, longitude: 50.88,
            date: DateComponents(year: 2026, month: 8, day: 11)))
        XCTAssertEqual(times.all.map(\.name), ["Fajr", "Zohr", "Asr", "Maghrib", "Isha"])
        XCTAssertEqual(times.all.map(\.date), times.all.map(\.date).sorted())
    }
}
