//
//  WidgetContent.swift
//  ThaqalaynWidgets
//
//  The widget's one-stop data source. Loads the three bundled files once
//  (daily_verses.json for selection, widget_daily.json for hydrated text,
//  salah_lines.json for prayer beats) and turns any date into that day's
//  selection, verse content, and timeline schedule. Zero network, zero
//  app-process dependencies; the only cross-process input is the cached
//  location in the App Group.
//

import Foundation

// MARK: - Bundled file models

struct WidgetGem: Codable {
    let title: String
    let insight: String
    let icon: String
    let colorHex: String
    let line: String?       // authored reflective line; falls back to insight
}

struct EssenceLine: Codable {
    let text: String
    let source: String?     // "Imam Ali - al-Kafi" | nil for takeaway lines
}

struct WidgetDoorway: Codable {
    let kind: String        // "experience" | "deepDive"
    let id: String
    let name: String?       // display title, e.g. "Surah al-Tawba" / "Sabr · Patience"
    let lines: [EssenceLine]?  // essence lines; rotate by dayIndex

    func essence(dayIndex: Int) -> EssenceLine? {
        guard let lines, !lines.isEmpty else { return nil }
        return lines[WidgetScheduleBuilder.rotationIndex(dayIndex: dayIndex, count: lines.count)]
    }
}

struct WidgetVerseEntry: Codable {
    let surah: Int
    let verse: Int
    let englishName: String
    let arabic: String
    let translation: String
    let gems: [WidgetGem]
    let doorway: WidgetDoorway?
    let morning: String?    // authored morning reflection
    let night: String?      // authored night close
}

private struct WidgetDailyFile: Codable {
    let version: Int
    let verses: [String: WidgetVerseEntry]
    let catalog: [WidgetDoorway]?
}

struct SalahLine: Codable {
    let en: String
    let source: String
}

private struct SalahLinesFile: Codable {
    let version: Int
    let lines: [SalahLine]
}

// MARK: - Content store

enum WidgetContent {

    /// Bundle.main inside the extension IS the widget bundle.
    static let selector = DailyVerseSelector(bundle: .main)

    private static let dailyFile = decode(WidgetDailyFile.self, resource: "widget_daily")

    static let verses: [String: WidgetVerseEntry] = dailyFile?.verses ?? [:]

    /// Every journey and deep dive, in rotation order (experiences and dives
    /// interleaved by the hydration script; coming-soon dives excluded there).
    static let catalog: [WidgetDoorway] = dailyFile?.catalog ?? []

    static let catalogExperiences: [WidgetDoorway] = catalog.filter { $0.kind == "experience" }
    static let catalogDives: [WidgetDoorway] = catalog.filter { $0.kind == "deepDive" }

    static let salahLines: [SalahLine] = {
        decode(SalahLinesFile.self, resource: "salah_lines")?.lines ?? []
    }()

    struct DayContent {
        let selection: DailyVerseSelection
        let entry: WidgetVerseEntry?
        let schedule: [WidgetTimelineEntryModel]
        let dayStart: Date
        /// Days since the selector epoch; views rotate essence lines with it.
        let dayIndex: Int
        /// The day's five prayer times, when a location is cached (feeds the
        /// large widget's timetable strip).
        let times: DayPrayerTimes?
        /// Today's journeys: slot 0 (afternoon) is the verse's linked doorway
        /// or the catalog rotation pick; slot 1 (evening) is the OTHER kind,
        /// so both a surah journey and a theme dive surface every day.
        let journeys: [WidgetDoorway]
    }

    /// Everything the timeline provider needs for the day containing `date`.
    static func content(for date: Date) -> DayContent {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let dayStart = calendar.startOfDay(for: date)

        let selection = selector.verse(for: date)
        let entry = verses[selection.id]

        // Prayer times from the cached location, if the app ever captured one.
        // The DEVICE timezone picks the civil day (timezone travel: recompute
        // with cached coordinates in the new zone on the next reload).
        let times: DayPrayerTimes? = WidgetLocationStore().load().flatMap { loc in
            PrayerTimesEngine().times(latitude: loc.latitude, longitude: loc.longitude,
                                      timeZone: .current, containing: date)
        }

        let days = calendar.dateComponents([.day], from: DailyVerseSelector.epoch, to: dayStart).day ?? 0
        let dayIndex = max(0, days)
        let schedule = WidgetScheduleBuilder.schedule(
            for: dayStart,
            dayIndex: dayIndex,
            times: times,
            featuredGemIndex: WidgetScheduleBuilder.featuredGemIndex(
                for: dayStart, gemCount: entry?.gems.count ?? 1),
            salahLineCount: salahLines.count)

        var journeys: [WidgetDoorway] = []
        if let primary = entry?.doorway
            ?? (catalog.isEmpty ? nil : catalog[dayIndex % catalog.count]) {
            journeys.append(primary)
            // Evening slot: rotate the other kind so dives and experiences
            // both get daily airtime.
            let pool = primary.kind == "experience" ? catalogDives : catalogExperiences
            if !pool.isEmpty {
                var evening = pool[dayIndex % pool.count]
                if evening.id == primary.id {
                    evening = pool[(dayIndex + 1) % pool.count]
                }
                journeys.append(evening)
            }
        }

        return DayContent(selection: selection, entry: entry,
                          schedule: schedule, dayStart: dayStart, dayIndex: dayIndex,
                          times: times, journeys: journeys)
    }

    static func salahLine(at index: Int) -> SalahLine? {
        guard !salahLines.isEmpty else { return nil }
        return salahLines[index % salahLines.count]
    }

    private static func decode<T: Decodable>(_ type: T.Type, resource: String) -> T? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
