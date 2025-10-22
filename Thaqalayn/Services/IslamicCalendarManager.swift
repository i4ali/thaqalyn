//
//  IslamicCalendarManager.swift
//  Thaqalayn
//
//  Service for Islamic (Hijri) calendar integration
//  Provides current Islamic date and month metadata
//

import Foundation

class IslamicCalendarManager {
    static let shared = IslamicCalendarManager()

    private init() {}

    // MARK: - Islamic Calendar

    /// Get the Islamic (Hijri) calendar
    var islamicCalendar: Calendar {
        var calendar = Calendar(identifier: .islamicUmmAlQura)
        calendar.timeZone = TimeZone.current
        return calendar
    }

    /// Get current Islamic date components
    func currentIslamicDate() -> DateComponents {
        let now = Date()
        let components = islamicCalendar.dateComponents([.year, .month, .day, .weekday], from: now)
        return components
    }

    /// Get current Islamic month number (1-12)
    func currentIslamicMonth() -> Int {
        return currentIslamicDate().month ?? 1
    }

    /// Get current Islamic day of month
    func currentIslamicDay() -> Int {
        return currentIslamicDate().day ?? 1
    }

    /// Get current Islamic year
    func currentIslamicYear() -> Int {
        return currentIslamicDate().year ?? 1445
    }

    // MARK: - Month Information

    /// Get Islamic month name for a given month number
    func monthName(for monthNumber: Int) -> String {
        let monthNames = [
            1: "Muharram",
            2: "Safar",
            3: "Rabi' al-Awwal",
            4: "Rabi' al-Thani",
            5: "Jumada al-Awwal",
            6: "Jumada al-Thani",
            7: "Rajab",
            8: "Sha'ban",
            9: "Ramadan",
            10: "Shawwal",
            11: "Dhul-Qa'dah",
            12: "Dhul-Hijjah"
        ]
        return monthNames[monthNumber] ?? "Unknown"
    }

    /// Get Arabic Islamic month name for a given month number
    func arabicMonthName(for monthNumber: Int) -> String {
        let monthNames = [
            1: "محرم",
            2: "صفر",
            3: "ربيع الأول",
            4: "ربيع الآخر",
            5: "جمادى الأولى",
            6: "جمادى الآخرة",
            7: "رجب",
            8: "شعبان",
            9: "رمضان",
            10: "شوال",
            11: "ذو القعدة",
            12: "ذو الحجة"
        ]
        return monthNames[monthNumber] ?? "غير معروف"
    }

    /// Format Islamic date as string
    func formattedIslamicDate() -> String {
        let components = currentIslamicDate()
        guard let month = components.month,
              let day = components.day,
              let year = components.year else {
            return "Unknown"
        }

        let monthName = self.monthName(for: month)
        return "\(day) \(monthName), \(year) AH"
    }

    /// Get day of week in Islamic calendar
    func islamicDayOfWeek() -> String {
        let components = currentIslamicDate()
        guard let weekday = components.weekday else {
            return "Unknown"
        }

        let dayNames = [
            1: "Sunday",
            2: "Monday",
            3: "Tuesday",
            4: "Wednesday",
            5: "Thursday",
            6: "Friday",
            7: "Saturday"
        ]
        return dayNames[weekday] ?? "Unknown"
    }

    // MARK: - Verification

    /// Check if current month is Ramadan (month 9)
    func isRamadan() -> Bool {
        return currentIslamicMonth() == 9
    }

    /// Check if current month is Muharram (month 1)
    func isMuharram() -> Bool {
        return currentIslamicMonth() == 1
    }

    /// Check if current month is Dhul-Hijjah (month 12)
    func isDhulHijjah() -> Bool {
        return currentIslamicMonth() == 12
    }

    /// Check if current month is one of the four sacred months
    func isSacredMonth() -> Bool {
        let sacredMonths = [1, 7, 11, 12] // Muharram, Rajab, Dhul-Qa'dah, Dhul-Hijjah
        return sacredMonths.contains(currentIslamicMonth())
    }

    // MARK: - Date Formatting

    /// Get full formatted date with both Gregorian and Islamic calendars
    func fullFormattedDate() -> String {
        let gregorianFormatter = DateFormatter()
        gregorianFormatter.dateStyle = .medium
        gregorianFormatter.timeStyle = .none

        let gregorianDate = gregorianFormatter.string(from: Date())
        let islamicDate = formattedIslamicDate()

        return "\(gregorianDate) | \(islamicDate)"
    }
}
