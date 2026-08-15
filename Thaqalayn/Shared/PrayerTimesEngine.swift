//
//  PrayerTimesEngine.swift
//  Thaqalayn
//
//  Ja'fari (Shia) prayer times. Method: Tehran Institute of Geophysics
//  (Fajr 17.7 degrees, Isha 14 degrees, Maghrib at 4.5 degrees below the
//  horizon - i.e. delayed past astronomical sunset) via adhan-swift.
//
//  All returned Dates are absolute instants; render them with a formatter
//  set to the location's timezone.
//
//  Target membership: Thaqalayn AND ThaqalaynWidgets.
//

import Foundation
import Adhan

struct DayPrayerTimes {
    let fajr: Date, sunrise: Date, dhuhr: Date, asr: Date, maghrib: Date, isha: Date

    /// The five daily prayers in order, with display names (Shia naming).
    var all: [(name: String, date: Date)] {
        [("Fajr", fajr), ("Zohr", dhuhr), ("Asr", asr),
         ("Maghrib", maghrib), ("Isha", isha)]
    }
}

struct PrayerTimesEngine {

    /// Times for an explicit civil day (year, month, day).
    func times(latitude: Double, longitude: Double, date: DateComponents) -> DayPrayerTimes? {
        let coords = Coordinates(latitude: latitude, longitude: longitude)
        let params = CalculationMethod.tehran.params
        guard let pt = PrayerTimes(coordinates: coords, date: date,
                                   calculationParameters: params) else { return nil }
        return DayPrayerTimes(fajr: pt.fajr, sunrise: pt.sunrise, dhuhr: pt.dhuhr,
                              asr: pt.asr, maghrib: pt.maghrib, isha: pt.isha)
    }

    /// Times for the civil day that contains `moment` in `timeZone`. The
    /// timezone decides WHICH day is computed; the times themselves are
    /// absolute instants regardless.
    func times(latitude: Double, longitude: Double,
               timeZone: TimeZone, containing moment: Date) -> DayPrayerTimes? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let day = calendar.dateComponents([.year, .month, .day], from: moment)
        return times(latitude: latitude, longitude: longitude, date: day)
    }

    /// Astronomical sunset, exposed for tests only. adhan-swift keeps SolarTime
    /// internal; the Muslim World League method places maghrib exactly at
    /// sunset, so its maghrib IS the astronomical sunset.
    static func astronomicalSunsetForTesting(latitude: Double, longitude: Double,
                                             date: DateComponents) -> Date? {
        let coords = Coordinates(latitude: latitude, longitude: longitude)
        let params = CalculationMethod.muslimWorldLeague.params
        return PrayerTimes(coordinates: coords, date: date,
                           calculationParameters: params)?.maghrib
    }
}
