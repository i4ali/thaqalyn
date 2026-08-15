//
//  AccessoryWidgets.swift
//  ThaqalaynWidgets
//
//  Lock screen accessories: (a) Hijri date + today's theme word,
//  (b) next prayer + time. Both self-contained - the Hijri conversion is the
//  same two-line Umm al-Qura calendar the daily-verse selector uses (no
//  IslamicCalendarManager import; that manager is app-only).
//

import WidgetKit
import SwiftUI

// MARK: - Hijri date + theme

struct HijriEntry: TimelineEntry {
    let date: Date
    let hijriLine: String
    let theme: String
}

struct HijriDateProvider: TimelineProvider {

    /// Plain-spelling English month names, Umm al-Qura numbering.
    static let monthNames = [
        "Muharram", "Safar", "Rabi al-Awwal", "Rabi al-Thani",
        "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
        "Ramadan", "Shawwal", "Dhu al-Qa'dah", "Dhu al-Hijjah",
    ]

    static func entry(for date: Date) -> HijriEntry {
        var hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        hijriCalendar.timeZone = .current
        let parts = hijriCalendar.dateComponents([.year, .month, .day], from: date)
        let month = monthNames[((parts.month ?? 1) - 1 + 12) % 12]
        let line = "\(parts.day ?? 1) \(month) \(parts.year ?? 0)"
        let selection = WidgetContent.selector.verse(for: date)
        return HijriEntry(date: date, hijriLine: line,
                          theme: selection.occasionEn ?? selection.themeEn)
    }

    func placeholder(in context: Context) -> HijriEntry { Self.entry(for: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (HijriEntry) -> Void) {
        completion(Self.entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HijriEntry>) -> Void) {
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let dayStart = calendar.startOfDay(for: now)

        // Today plus two midnight flips of margin; reload just after midnight.
        var entries = [Self.entry(for: now)]
        for offset in 1...2 {
            if let midnight = calendar.date(byAdding: .day, value: offset, to: dayStart) {
                entries.append(Self.entry(for: midnight.addingTimeInterval(60)))
            }
        }
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: dayStart)
            ?? now.addingTimeInterval(86_400)
        completion(Timeline(entries: entries,
                            policy: .after(nextMidnight.addingTimeInterval(60))))
    }
}

struct HijriDateAccessoryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: HijriEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Text("\(entry.hijriLine) - \(entry.theme)")
            default:
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.hijriLine)
                        .font(.headline)
                        .widgetAccentable()
                    Text(entry.theme)
                        .font(.caption)
                        .opacity(0.8)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .containerBackground(for: .widget) { Color.clear }
        .widgetURL(URL(string: "thaqalayn://"))
    }
}

struct HijriDateAccessory: Widget {
    let kind: String = "HijriDateAccessory"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HijriDateProvider()) { entry in
            HijriDateAccessoryView(entry: entry)
        }
        .configurationDisplayName("Hijri Date")
        .description("Today's Hijri date and the daily verse theme.")
        .supportedFamilies([.accessoryInline, .accessoryRectangular])
    }
}

// MARK: - Next prayer

struct NextPrayerEntry: TimelineEntry {
    let date: Date
    let name: String?
    let time: Date?

    var hasLocation: Bool { name != nil && time != nil }
}

struct NextPrayerProvider: TimelineProvider {

    static func upcomingPrayers(from now: Date, location: WidgetLocation) -> [(String, Date)] {
        let engine = PrayerTimesEngine()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        var prayers: [(String, Date)] = []
        for offset in 0...1 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now),
                  let times = engine.times(latitude: location.latitude,
                                           longitude: location.longitude,
                                           timeZone: .current, containing: day) else { continue }
            prayers.append(contentsOf: times.all)
        }
        return prayers.filter { $0.1 > now }.sorted { $0.1 < $1.1 }
    }

    func placeholder(in context: Context) -> NextPrayerEntry {
        NextPrayerEntry(date: Date(), name: "Maghrib", time: Date().addingTimeInterval(3_600))
    }

    func getSnapshot(in context: Context, completion: @escaping (NextPrayerEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextPrayerEntry>) -> Void) {
        let now = Date()
        guard let location = WidgetLocationStore().load() else {
            // No location captured: a single "set up" entry, retried twice a day.
            let entry = NextPrayerEntry(date: now, name: nil, time: nil)
            completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(12 * 3_600))))
            return
        }

        let upcoming = Self.upcomingPrayers(from: now, location: location)
        guard let first = upcoming.first else {
            completion(Timeline(entries: [NextPrayerEntry(date: now, name: nil, time: nil)],
                                policy: .after(now.addingTimeInterval(3_600))))
            return
        }

        // Entry now -> first upcoming prayer; at each adhan, flip to the next.
        var entries = [NextPrayerEntry(date: now, name: first.0, time: first.1)]
        for (index, prayer) in upcoming.enumerated() where index + 1 < upcoming.count {
            let next = upcoming[index + 1]
            entries.append(NextPrayerEntry(date: prayer.1, name: next.0, time: next.1))
        }
        let lastCovered = upcoming.last?.1 ?? now.addingTimeInterval(86_400)
        completion(Timeline(entries: entries, policy: .after(lastCovered)))
    }
}

struct NextPrayerAccessoryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NextPrayerEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                if let name = entry.name, let time = entry.time {
                    Text("\(name) \(time, style: .time)")
                } else {
                    Text("Set up in Thaqalayn")
                }
            case .accessoryCircular:
                VStack(spacing: 0) {
                    if let name = entry.name, let time = entry.time {
                        Text(name)
                            .font(.system(size: 11, weight: .semibold))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .widgetAccentable()
                        Text(time, style: .time)
                            .font(.system(size: 11))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    } else {
                        Image(systemName: "location.slash")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            default:
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEXT PRAYER")
                        .font(.system(size: 10, weight: .semibold))
                        .opacity(0.7)
                    if let name = entry.name, let time = entry.time {
                        Text(name)
                            .font(.headline)
                            .widgetAccentable()
                        Text(time, style: .time)
                            .font(.caption)
                            .opacity(0.8)
                    } else {
                        Text("Set up in Thaqalayn")
                            .font(.headline)
                            .widgetAccentable()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .containerBackground(for: .widget) { Color.clear }
        .widgetURL(URL(string: "thaqalayn://"))
    }
}

struct NextPrayerAccessory: Widget {
    let kind: String = "NextPrayerAccessory"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextPrayerProvider()) { entry in
            NextPrayerAccessoryView(entry: entry)
        }
        .configurationDisplayName("Next Prayer")
        .description("The next prayer and its time on Shia timings.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}
