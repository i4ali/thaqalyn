//
//  PrayerTimesManager.swift
//  Thaqalayn
//
//  Service for calculating Islamic prayer times using Jafari method
//  Based on astronomical calculations from praytimes.org
//

import Foundation
import SwiftUI

class PrayerTimesManager: ObservableObject {
    static let shared = PrayerTimesManager()

    @Published var preferences: PrayerPreferences {
        didSet {
            savePreferences()
            calculatePrayerTimes()
        }
    }

    @Published var athanPreferences: AthanPreferences {
        didSet {
            saveAthanPreferences()
        }
    }

    @Published var prayerTimes: PrayerTimesData?
    @Published var isCalculating: Bool = false

    private let locationManager = LocationManager.shared
    private let preferencesKey = "prayerPreferences"
    private let athanPreferencesKey = "athanPreferences"

    // Constants for calculations
    private let pi = Double.pi

    private init() {
        // Load preferences
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(PrayerPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = PrayerPreferences()
        }

        if let data = UserDefaults.standard.data(forKey: athanPreferencesKey),
           let decoded = try? JSONDecoder().decode(AthanPreferences.self, from: data) {
            self.athanPreferences = decoded
        } else {
            self.athanPreferences = AthanPreferences()
        }

        // Calculate prayer times on init
        if locationManager.currentLocation != nil {
            calculatePrayerTimes()
        }
    }

    // MARK: - Preferences

    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }

    private func saveAthanPreferences() {
        if let encoded = try? JSONEncoder().encode(athanPreferences) {
            UserDefaults.standard.set(encoded, forKey: athanPreferencesKey)
        }
    }

    // MARK: - Prayer Times Calculation

    func calculatePrayerTimes(for date: Date = Date()) {
        guard let location = locationManager.currentLocation else {
            print("⚠️ PrayerTimesManager: No location available for calculation")
            return
        }

        isCalculating = true

        // Perform calculation on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let times = self.computePrayerTimes(
                date: date,
                latitude: location.latitude,
                longitude: location.longitude,
                timezone: self.getTimezoneOffset(for: date)
            )

            DispatchQueue.main.async {
                self.prayerTimes = PrayerTimesData(
                    date: date,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    timezone: location.timezone,
                    times: times
                )
                self.isCalculating = false

                // Schedule notifications if enabled
                if self.preferences.notificationsEnabled {
                    self.schedulePrayerNotifications()
                }
            }
        }
    }

    private func computePrayerTimes(date: Date, latitude: Double, longitude: Double, timezone: Double) -> [PrayerTime: Date] {
        // Julian date
        let jd = julianDate(date: date)

        // Equation of time
        let eqt = equationOfTime(julianDate: jd)

        // Sun declination
        let decl = sunDeclination(julianDate: jd)

        // Calculate prayer times
        let fajrTime = calculateTime(angle: preferences.selectedAcalculationMethod.fajrAngle, time: 0, direction: .ccw, declination: decl, latitude: latitude)
        let sunriseTime = calculateTime(angle: 0.833, time: 0, direction: .ccw, declination: decl, latitude: latitude)
        let dhuhrTime = calculateDhuhr(equation: eqt)
        let asrTime = calculateAsr(factor: preferences.asrJuristicMethod.shadowFactor, time: dhuhrTime, declination: decl, latitude: latitude)

        var maghribTime: Double
        if let maghribAngle = preferences.selectedAcalculationMethod.maghribAngle {
            maghribTime = calculateTime(angle: maghribAngle, time: 0, direction: .cw, declination: decl, latitude: latitude)
        } else {
            maghribTime = calculateTime(angle: 0.833, time: 0, direction: .cw, declination: decl, latitude: latitude)
        }

        var ishaTime: Double
        if let ishaAngle = preferences.selectedAcalculationMethod.ishaAngle {
            ishaTime = calculateTime(angle: ishaAngle, time: 0, direction: .cw, declination: decl, latitude: latitude)
        } else if let ishaMinutes = preferences.selectedAcalculationMethod.ishaMinutes {
            ishaTime = maghribTime + Double(ishaMinutes) / 60.0
        } else {
            ishaTime = calculateTime(angle: 18.0, time: 0, direction: .cw, declination: decl, latitude: latitude)
        }

        // Apply timezone and longitude adjustment
        var times: [PrayerTime: Double] = [
            .fajr: fajrTime,
            .sunrise: sunriseTime,
            .dhuhr: dhuhrTime,
            .asr: asrTime,
            .maghrib: maghribTime,
            .isha: ishaTime
        ]

        // Adjust times
        for prayer in PrayerTime.allCases {
            if var time = times[prayer] {
                time = time + timezone - longitude / 15.0

                // Apply madhhab adjustments
                if let adjustment = preferences.madhhabAdjustments[prayer] {
                    time += Double(adjustment) / 60.0
                }

                times[prayer] = time
            }
        }

        // Convert to Date objects
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        var prayerDates: [PrayerTime: Date] = [:]
        for (prayer, time) in times {
            let hours = Int(floor(time))
            let minutes = Int(floor((time - Double(hours)) * 60))

            dateComponents.hour = hours
            dateComponents.minute = minutes
            dateComponents.second = 0

            if let prayerDate = calendar.date(from: dateComponents) {
                prayerDates[prayer] = prayerDate
            }
        }

        return prayerDates
    }

    // MARK: - Astronomical Calculations

    private func julianDate(date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = Double(components.year!)
        let month = Double(components.month!)
        let day = Double(components.day!)

        if month <= 2 {
            let year = year - 1
            let month = month + 12
        }

        let a = floor(year / 100)
        let b = 2 - a + floor(a / 4)

        return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + b - 1524.5
    }

    private func sunDeclination(julianDate: Double) -> Double {
        let t = 2 * pi * (julianDate - 2451545.0) / 365.25
        let declination = 0.37877 + 23.264 * sin(t) - 0.3812 * cos(t) + 0.04 * sin(2 * t) - 0.155 * cos(2 * t)
        return declination
    }

    private func equationOfTime(julianDate: Double) -> Double {
        let t = 2 * pi * (julianDate - 2451545.0) / 365.25
        return (0.004297 + 0.107029 * cos(t) - 1.837877 * sin(t) - 0.837378 * cos(2 * t) - 2.34 * sin(2 * t)) * 60.0
    }

    private enum TimeDirection {
        case ccw // Counter-clockwise (morning)
        case cw  // Clockwise (evening)
    }

    private func calculateTime(angle: Double, time: Double, direction: TimeDirection, declination: Double, latitude: Double) -> Double {
        let latRad = latitude * pi / 180.0
        let declRad = declination * pi / 180.0
        let angleRad = angle * pi / 180.0

        let cosH = (sin(-angleRad) - sin(latRad) * sin(declRad)) / (cos(latRad) * cos(declRad))

        if cosH > 1 || cosH < -1 {
            // Extreme latitude case
            return time
        }

        let h = acos(cosH) * 180.0 / pi

        if direction == .ccw {
            return 12 - h / 15.0
        } else {
            return 12 + h / 15.0
        }
    }

    private func calculateDhuhr(equation: Double) -> Double {
        return 12.0 + equation / 60.0
    }

    private func calculateAsr(factor: Double, time: Double, declination: Double, latitude: Double) -> Double {
        let latRad = latitude * pi / 180.0
        let declRad = declination * pi / 180.0

        let angle = -atan(1.0 / (factor + tan(latRad - declRad))) * 180.0 / pi

        return calculateTime(angle: angle, time: time, direction: .cw, declination: declination, latitude: latitude)
    }

    private func getTimezoneOffset(for date: Date) -> Double {
        let timezone = TimeZone.current
        let offset = Double(timezone.secondsFromGMT(for: date)) / 3600.0
        return offset
    }

    // MARK: - Notification Scheduling

    private func schedulePrayerNotifications() {
        guard let prayerTimes = prayerTimes else { return }

        // This will be implemented when we extend NotificationManager
        print("✅ PrayerTimesManager: Prayer times calculated, ready for notifications")
        print("   Fajr: \(formatTime(prayerTimes.times[.fajr]!))")
        print("   Sunrise: \(formatTime(prayerTimes.times[.sunrise]!))")
        print("   Dhuhr: \(formatTime(prayerTimes.times[.dhuhr]!))")
        print("   Asr: \(formatTime(prayerTimes.times[.asr]!))")
        print("   Maghrib: \(formatTime(prayerTimes.times[.maghrib]!))")
        print("   Isha: \(formatTime(prayerTimes.times[.isha]!))")
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
