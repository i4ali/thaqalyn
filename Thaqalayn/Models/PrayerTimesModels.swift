//
//  PrayerTimesModels.swift
//  Thaqalayn
//
//  Data models for Islamic prayer times and athan
//

import Foundation

// MARK: - Prayer Time Enum

enum PrayerTime: String, CaseIterable, Codable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    var icon: String {
        switch self {
        case .fajr: return "moon.stars.fill"
        case .sunrise: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.fill"
        }
    }

    var description: String {
        switch self {
        case .fajr: return "Dawn prayer"
        case .sunrise: return "Sun rises"
        case .dhuhr: return "Noon prayer"
        case .asr: return "Afternoon prayer"
        case .maghrib: return "Sunset prayer"
        case .isha: return "Night prayer"
        }
    }

    /// Returns true if this is an actual prayer (not sunrise)
    var isPrayer: Bool {
        return self != .sunrise
    }

    /// Returns the next prayer time in sequence
    var next: PrayerTime? {
        let all = PrayerTime.allCases
        guard let currentIndex = all.firstIndex(of: self),
              currentIndex < all.count - 1 else {
            return .fajr // After Isha, next is Fajr
        }
        return all[currentIndex + 1]
    }
}

// MARK: - Prayer Times Data

struct PrayerTimesData: Codable {
    let date: Date
    let latitude: Double
    let longitude: Double
    let timezone: String
    let times: [PrayerTime: Date]

    /// Get the current prayer (last prayer that has passed)
    func currentPrayer(at date: Date = Date()) -> PrayerTime? {
        let sortedPrayers = PrayerTime.allCases
            .filter { $0.isPrayer }
            .compactMap { prayer -> (PrayerTime, Date)? in
                guard let time = times[prayer] else { return nil }
                return (prayer, time)
            }
            .sorted { $0.1 < $1.1 }

        // Find the last prayer that has passed
        for (prayer, time) in sortedPrayers.reversed() {
            if time <= date {
                return prayer
            }
        }

        // If no prayer has passed today, return yesterday's Isha
        return .isha
    }

    /// Get the next upcoming prayer
    func nextPrayer(at date: Date = Date()) -> PrayerTime? {
        let sortedPrayers = PrayerTime.allCases
            .filter { $0.isPrayer }
            .compactMap { prayer -> (PrayerTime, Date)? in
                guard let time = times[prayer] else { return nil }
                return (prayer, time)
            }
            .sorted { $0.1 < $1.1 }

        // Find the first prayer that hasn't happened yet
        for (prayer, time) in sortedPrayers {
            if time > date {
                return prayer
            }
        }

        // If all prayers have passed, next is tomorrow's Fajr
        return .fajr
    }

    /// Get time remaining until next prayer
    func timeUntilNextPrayer(at date: Date = Date()) -> TimeInterval? {
        guard let nextPrayer = nextPrayer(at: date),
              let nextPrayerTime = times[nextPrayer] else {
            return nil
        }

        // If next prayer is today
        if nextPrayerTime > date {
            return nextPrayerTime.timeIntervalSince(date)
        }

        // If next prayer is tomorrow (Fajr), add 24 hours
        return nextPrayerTime.timeIntervalSince(date) + 86400
    }
}

// MARK: - Prayer Preferences

struct PrayerPreferences: Codable {
    var enabled: Bool
    var notificationsEnabled: Bool
    var athanEnabled: [PrayerTime: Bool]
    var selectedAcalculationMethod: CalculationMethod
    var asrJuristicMethod: AsrJuristicMethod
    var highLatitudeRule: HighLatitudeRule
    var madhhabAdjustments: [PrayerTime: Int] // Minutes to add/subtract

    init(
        enabled: Bool = false,
        notificationsEnabled: Bool = false,
        athanEnabled: [PrayerTime: Bool] = [:],
        calculationMethod: CalculationMethod = .jafari,
        asrJuristicMethod: AsrJuristicMethod = .shafii,
        highLatitudeRule: HighLatitudeRule = .middleOfNight,
        madhhabAdjustments: [PrayerTime: Int] = [:]
    ) {
        self.enabled = enabled
        self.notificationsEnabled = notificationsEnabled
        self.athanEnabled = athanEnabled.isEmpty ? Dictionary(uniqueKeysWithValues: PrayerTime.allCases.filter { $0.isPrayer }.map { ($0, true) }) : athanEnabled
        self.selectedAcalculationMethod = calculationMethod
        self.asrJuristicMethod = asrJuristicMethod
        self.highLatitudeRule = highLatitudeRule
        self.madhhabAdjustments = madhhabAdjustments
    }
}

// MARK: - Calculation Method

enum CalculationMethod: String, CaseIterable, Codable {
    case jafari = "jafari"
    case mwl = "mwl"
    case isna = "isna"
    case egypt = "egypt"
    case makkah = "makkah"
    case karachi = "karachi"
    case tehran = "tehran"

    var displayName: String {
        switch self {
        case .jafari: return "Shia Ithna Ashari (Jafari)"
        case .mwl: return "Muslim World League"
        case .isna: return "Islamic Society of North America"
        case .egypt: return "Egyptian General Authority"
        case .makkah: return "Umm Al-Qura University, Makkah"
        case .karachi: return "University of Islamic Sciences, Karachi"
        case .tehran: return "Institute of Geophysics, Tehran"
        }
    }

    var description: String {
        switch self {
        case .jafari: return "Preferred method for Shia Muslims"
        case .mwl: return "Standard method used worldwide"
        case .isna: return "Used in North America"
        case .egypt: return "Used in Egypt and some Arab countries"
        case .makkah: return "Used in Saudi Arabia"
        case .karachi: return "Used in Pakistan and South Asia"
        case .tehran: return "Used in Iran"
        }
    }

    // Calculation parameters
    var fajrAngle: Double {
        switch self {
        case .jafari: return 16.0
        case .mwl: return 18.0
        case .isna: return 15.0
        case .egypt: return 19.5
        case .makkah: return 18.5
        case .karachi: return 18.0
        case .tehran: return 17.7
        }
    }

    var ishaAngle: Double? {
        switch self {
        case .jafari: return 14.0
        case .mwl: return 17.0
        case .isna: return 15.0
        case .egypt: return 17.5
        case .karachi: return 18.0
        case .tehran: return 14.0
        case .makkah: return nil // Uses fixed minutes
        }
    }

    var ishaMinutes: Int? {
        switch self {
        case .makkah: return 90
        default: return nil
        }
    }

    var maghribAngle: Double? {
        switch self {
        case .jafari: return 4.0
        default: return nil
        }
    }

    var usesJafariMidnight: Bool {
        return self == .jafari || self == .tehran
    }
}

// MARK: - Asr Juristic Method

enum AsrJuristicMethod: String, CaseIterable, Codable {
    case shafii = "shafii"
    case hanafi = "hanafi"

    var displayName: String {
        switch self {
        case .shafii: return "Shafi'i, Maliki, Ja'fari, Hanbali"
        case .hanafi: return "Hanafi"
        }
    }

    var description: String {
        switch self {
        case .shafii: return "Shadow length = object length + noon shadow"
        case .hanafi: return "Shadow length = 2 × object length + noon shadow"
        }
    }

    var shadowFactor: Double {
        switch self {
        case .shafii: return 1.0
        case .hanafi: return 2.0
        }
    }
}

// MARK: - High Latitude Rule

enum HighLatitudeRule: String, CaseIterable, Codable {
    case middleOfNight = "middleOfNight"
    case seventhOfNight = "seventhOfNight"
    case twilightAngle = "twilightAngle"
    case none = "none"

    var displayName: String {
        switch self {
        case .middleOfNight: return "Middle of Night"
        case .seventhOfNight: return "One-Seventh of Night"
        case .twilightAngle: return "Angle-Based Method"
        case .none: return "None"
        }
    }

    var description: String {
        switch self {
        case .middleOfNight: return "For extreme latitudes"
        case .seventhOfNight: return "For extreme latitudes"
        case .twilightAngle: return "For extreme latitudes"
        case .none: return "Standard calculation"
        }
    }
}

// MARK: - Athan Audio

enum AthanAudio: String, CaseIterable, Codable {
    case mecca = "athan_mecca"
    case medina = "athan_medina"
    case standard = "athan_standard"
    case none = "none"

    var displayName: String {
        switch self {
        case .mecca: return "Mecca Style"
        case .medina: return "Medina Style"
        case .standard: return "Standard"
        case .none: return "None (Silent)"
        }
    }

    var fileName: String? {
        switch self {
        case .none: return nil
        default: return "\(self.rawValue).mp3"
        }
    }
}

// MARK: - Athan Preferences

struct AthanPreferences: Codable {
    var selectedAudio: AthanAudio
    var volume: Float

    init(
        selectedAudio: AthanAudio = .mecca,
        volume: Float = 0.8
    ) {
        self.selectedAudio = selectedAudio
        self.volume = volume
    }
}

// MARK: - Location Data

struct LocationData: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let city: String?
    let country: String?
    let timezone: String
    let lastUpdated: Date

    init(latitude: Double, longitude: Double, city: String? = nil, country: String? = nil, timezone: String = TimeZone.current.identifier, lastUpdated: Date = Date()) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.country = country
        self.timezone = timezone
        self.lastUpdated = lastUpdated
    }

    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        return lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.timezone == rhs.timezone
    }
}
