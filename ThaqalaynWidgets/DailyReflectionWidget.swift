//
//  DailyReflectionWidget.swift
//  ThaqalaynWidgets
//
//  The Daily Reflection home-screen widget: one verse anchors the day and
//  unfolds through it (verse -> gems -> doorway -> night), with five prayer
//  beats on Ja'fari timings when a location is cached. All content is bundled;
//  the timeline is precomputed for the whole day at local midnight.
//
//  No premium signals of any kind on the widget, ever (design decision).
//

import WidgetKit
import SwiftUI

// MARK: - Timeline

struct ReflectionEntry: TimelineEntry {
    let date: Date
    let beat: WidgetBeat
    let selection: DailyVerseSelection
    let verse: WidgetVerseEntry?
    /// The whole day's prayer times (nil without a location); the large
    /// prayer beat renders them as a five-time strip.
    let times: DayPrayerTimes?
    /// Today's journeys (slot 0 = afternoon, slot 1 = evening, other kind);
    /// doorway beats render and deep-link by slot.
    let journeys: [WidgetDoorway]
    /// Tomorrow's exact Fajr (nil without a location); the night beat shows it.
    let tomorrowFajr: Date?
    /// Days since the selector epoch; doorway essence lines rotate with it.
    let dayIndex: Int

    func journey(slot: Int) -> WidgetDoorway? {
        guard !journeys.isEmpty else { return nil }
        return journeys[min(slot, journeys.count - 1)]
    }

    /// Gallery / placeholder snapshot: a gem day built from bundled data.
    static var sample: ReflectionEntry {
        let pooled = WidgetContent.selector.pool.first { $0.surah == 39 && $0.verse == 10 }
            ?? WidgetContent.selector.pool[0]
        let selection = DailyVerseSelection(entry: pooled)
        let verse = WidgetContent.verses[selection.id]
        return ReflectionEntry(date: Date(), beat: .gem(index: 0),
                               selection: selection,
                               verse: verse,
                               times: nil,
                               journeys: [verse?.doorway ?? WidgetContent.catalog.first].compactMap { $0 },
                               tomorrowFajr: nil,
                               dayIndex: 0)
    }
}

struct DailyReflectionProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReflectionEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (ReflectionEntry) -> Void) {
        completion(.sample)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReflectionEntry>) -> Void) {
        let now = Date()
        let today = WidgetContent.content(for: now)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: today.dayStart)
            ?? now.addingTimeInterval(86_400)
        let tomorrow = WidgetContent.content(for: nextMidnight.addingTimeInterval(3_600))

        var entries = today.schedule.map {
            ReflectionEntry(date: $0.date, beat: $0.beat,
                            selection: today.selection, verse: today.entry,
                            times: today.times, journeys: today.journeys,
                            tomorrowFajr: tomorrow.times?.fajr,
                            dayIndex: today.dayIndex)
        }

        // Safety margin: tomorrow's morning (through its verse beat), in case
        // iOS defers the after-midnight reload.
        for model in tomorrow.schedule {
            switch model.beat {
            case .verse:
                entries.append(ReflectionEntry(date: model.date, beat: model.beat,
                                               selection: tomorrow.selection, verse: tomorrow.entry,
                                               times: tomorrow.times, journeys: tomorrow.journeys,
                                               tomorrowFajr: nil,
                                               dayIndex: tomorrow.dayIndex))
            case .prayer(let name, _, _) where name == "Fajr":
                entries.append(ReflectionEntry(date: model.date, beat: model.beat,
                                               selection: tomorrow.selection, verse: tomorrow.entry,
                                               times: tomorrow.times, journeys: tomorrow.journeys,
                                               tomorrowFajr: nil,
                                               dayIndex: tomorrow.dayIndex))
            default:
                break
            }
        }

        // Anchor the timeline at "now": WidgetKit should pick the latest past
        // entry itself, but the simulator (and occasionally a lazy device
        // reload) renders entry zero - so make entry zero BE the active beat.
        var anchored = entries.filter { $0.date > now }
        if let active = entries.last(where: { $0.date <= now }) {
            anchored.insert(ReflectionEntry(date: now, beat: active.beat,
                                            selection: active.selection,
                                            verse: active.verse,
                                            times: active.times,
                                            journeys: active.journeys,
                                            tomorrowFajr: active.tomorrowFajr,
                                            dayIndex: active.dayIndex), at: 0)
        }

        completion(Timeline(entries: anchored,
                            policy: .after(nextMidnight.addingTimeInterval(60))))
    }
}

// MARK: - Entry view

struct DailyReflectionEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ReflectionEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall: SmallReflectionView(entry: entry)
            case .systemLarge: MediumLargeReflectionView(entry: entry, showsArabic: true)
            default: MediumLargeReflectionView(entry: entry, showsArabic: false)
            }
        }
        .containerBackground(for: .widget) { WidgetTheme.background }
        .widgetURL(entry.deepLinkURL)
    }
}

extension ReflectionEntry {
    var deepLinkURL: URL? {
        switch beat {
        case .verse, .gem, .night:
            return URL(string: "thaqalayn://verse?surah=\(selection.surah)&verse=\(selection.verse)")
        case .doorway(let slot):
            guard let doorway = journey(slot: slot) else { return URL(string: "thaqalayn://") }
            let host = doorway.kind == "experience" ? "experience" : "deepdive"
            return URL(string: "thaqalayn://\(host)?id=\(doorway.id)")
        case .prayer:
            return URL(string: "thaqalayn://")
        }
    }

    /// The day-verse reference, shown only on beats whose content IS the
    /// day's verse. Doorways are their own items and prayer beats cite their
    /// own narration source, so a verse reference there would mislead.
    var reference: String? {
        switch beat {
        case .doorway, .prayer:
            return nil
        case .verse, .gem, .night:
            if let name = verse?.englishName { return "\(name) \(selection.surah):\(selection.verse)" }
            return "\(selection.surah):\(selection.verse)"
        }
    }

    var chipText: String {
        switch beat {
        case .verse: return selection.occasionEn ?? "Today's verse"
        case .gem(let index):
            guard let gems = verse?.gems, gems.indices.contains(index) else { return "Gem" }
            return gems[index].title
        case .doorway: return "Go deeper"
        case .prayer: return "Prayer time"
        case .night: return "Night"
        }
    }

    /// The lit concept dot advances through the day.
    var litDots: Int {
        switch beat {
        case .verse: return 0
        case .gem(let index): return index + 1
        case .doorway, .night, .prayer: return verse?.gems.count ?? 0
        }
    }
}

// MARK: - Small

private struct SmallReflectionView: View {
    let entry: ReflectionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            beatContent

            Spacer(minLength: 2)

            if let reference = entry.reference {
                Text(reference.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundColor(WidgetTheme.gold.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // Every beat shows ONE complete thought; nothing truncated mid-sentence.
    @ViewBuilder
    private var beatContent: some View {
        switch entry.beat {
        case .prayer(let name, let time, _):
            Image(systemName: "moon.stars")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(WidgetTheme.gold)
            Spacer(minLength: 2)
            Text(name)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(WidgetTheme.text)
            Text(time, style: .time)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(WidgetTheme.dim)

        case .gem(let index):
            // The gem's reflective line carries the beat; the dots show the
            // day advancing.
            if let gems = entry.verse?.gems, gems.indices.contains(index) {
                HStack(spacing: 4) {
                    ForEach(0..<gems.count, id: \.self) { dot in
                        Circle()
                            .fill(dot < entry.litDots
                                  ? WidgetTheme.gold : WidgetTheme.gold.opacity(0.25))
                            .frame(width: 4, height: 4)
                    }
                }
                Spacer(minLength: 2)
                Text(gems[index].line ?? gems[index].insight)
                    .font(.system(size: 12.5, design: .serif))
                    .foregroundColor(WidgetTheme.text)
                    .lineLimit(5)
                    .minimumScaleFactor(0.7)
            } else {
                themeBlock
            }

        case .doorway(let slot):
            let doorway = entry.journey(slot: slot)
            eyebrow(doorway?.kind == "deepDive" ? "Deep Dive" : "Inside the Surah")
            Spacer(minLength: 2)
            // The essence line is the content; the journey name is the address.
            Text(doorway?.essence(dayIndex: entry.dayIndex)?.text
                 ?? doorway?.name
                 ?? (doorway?.kind == "deepDive" ? "Deep Dive" : "Inside the Surah"))
                .font(.system(size: 12.5, design: .serif))
                .foregroundColor(WidgetTheme.text)
                .lineLimit(4)
                .minimumScaleFactor(0.8)
            HStack(spacing: 4) {
                Text((doorway?.name ?? "").uppercased())
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .tracking(1.2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundColor(WidgetTheme.gold)

        case .verse:
            reflectionBlock(entry.verse?.morning)

        case .night:
            reflectionBlock(entry.verse?.night)
        }
    }

    /// The authored reflection carries the beat; a verse without one falls
    /// back to the theme block so the widget is never blank.
    @ViewBuilder
    private func reflectionBlock(_ reflection: String?) -> some View {
        if let reflection {
            if let occasion = entry.selection.occasionEn {
                eyebrow(occasion)
            }
            Text(reflection)
                .font(.system(size: 13, design: .serif))
                .foregroundColor(WidgetTheme.text)
                .lineLimit(5)
                .minimumScaleFactor(0.75)
        } else {
            themeBlock
        }
    }

    /// Arabic theme + English theme, with the occasion as context on sacred days.
    @ViewBuilder
    private var themeBlock: some View {
        if let occasion = entry.selection.occasionEn {
            eyebrow(occasion)
        }
        Text(entry.selection.themeAr)
            .font(.system(size: entry.selection.occasionEn == nil ? 24 : 20, weight: .medium, design: .serif))
            .foregroundColor(WidgetTheme.text)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .environment(\.layoutDirection, .rightToLeft)
        Spacer(minLength: 2)
        Text(entry.selection.themeEn)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(WidgetTheme.dim)
            .lineLimit(2)
    }

    private func eyebrow(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 8, weight: .semibold, design: .monospaced))
            .tracking(1.2)
            .foregroundColor(WidgetTheme.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

// MARK: - Medium / Large

private struct MediumLargeReflectionView: View {
    let entry: ReflectionEntry
    let showsArabic: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                WidgetChip(text: entry.chipText)
                Spacer(minLength: 8)
                if let reference = entry.reference {
                    Text(reference.uppercased())
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(WidgetTheme.dim)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            beatContent

            Spacer(minLength: 0)

            HStack(alignment: .center) {
                if let gems = entry.verse?.gems, !gems.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(0..<gems.count, id: \.self) { index in
                            Circle()
                                .fill(index < entry.litDots
                                      ? WidgetTheme.gold : WidgetTheme.gold.opacity(0.25))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                Spacer(minLength: 8)
                Text("THAQALAYN")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .tracking(2.2)
                    .foregroundColor(WidgetTheme.dim.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var beatContent: some View {
        switch entry.beat {
        case .verse:
            VStack(alignment: .leading, spacing: showsArabic ? 10 : 6) {
                arabicLineIfLarge
                if let morning = entry.verse?.morning {
                    // The reflection is the day's thought; the translation
                    // stays as its anchor (dim single line on medium).
                    Text(entry.verse?.translation ?? entry.selection.themeEn)
                        .font(.system(size: showsArabic ? 16 : 11, design: .serif).italic())
                        .foregroundColor(showsArabic ? WidgetTheme.text : WidgetTheme.dim)
                        .lineLimit(showsArabic ? 5 : 1)
                        .minimumScaleFactor(0.85)
                    Text(morning)
                        .font(showsArabic
                              ? .system(size: 15, design: .serif)
                              : .system(size: 14, design: .serif).italic())
                        .foregroundColor(WidgetTheme.text)
                        .lineLimit(showsArabic ? 4 : 3)
                        .minimumScaleFactor(0.85)
                } else {
                    Text(entry.verse?.translation ?? entry.selection.themeEn)
                        .font(.system(size: showsArabic ? 16 : 14, design: .serif).italic())
                        .foregroundColor(WidgetTheme.text)
                        .lineLimit(showsArabic ? 8 : 3)
                        .minimumScaleFactor(0.85)
                }
            }

        case .gem(let index):
            VStack(alignment: .leading, spacing: showsArabic ? 9 : 5) {
                arabicLineIfLarge
                if let translation = entry.verse?.translation {
                    Text(translation)
                        .font(.system(size: showsArabic ? 12.5 : 11, design: .serif).italic())
                        .foregroundColor(WidgetTheme.dim)
                        .lineLimit(showsArabic ? 2 : 1)
                }
                if let gems = entry.verse?.gems, gems.indices.contains(index) {
                    Text(gems[index].line ?? gems[index].insight)
                        .font(.system(size: showsArabic ? 15 : 13, design: .serif))
                        .foregroundColor(WidgetTheme.text)
                        .lineLimit(showsArabic ? 6 : 3)
                        .minimumScaleFactor(0.9)
                    if showsArabic, gems.count > 1 {
                        gemMap(gems: gems, current: index)
                            .padding(.top, 2)
                    }
                }
            }

        case .doorway(let slot):
            let doorway = entry.journey(slot: slot)
            let essence = doorway?.essence(dayIndex: entry.dayIndex)
            VStack(alignment: .leading, spacing: showsArabic ? 9 : 6) {
                // The essence line leads; the journey name is the address in
                // the tease row below.
                Text(essence?.text ?? doorway?.name ?? entry.selection.themeEn)
                    .font(.system(size: showsArabic ? 15 : 13, design: .serif).italic())
                    .foregroundColor(WidgetTheme.text.opacity(0.92))
                    .lineLimit(showsArabic ? 5 : 3)
                if showsArabic, let source = essence?.source {
                    Text(source.uppercased())
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(WidgetTheme.dim)
                        .lineLimit(1)
                }
                teaseRow(for: doorway)
            }

        case .prayer(let name, let time, let lineIndex):
            VStack(alignment: .leading, spacing: showsArabic ? 9 : 6) {
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars")
                        .font(.system(size: showsArabic ? 17 : 14, weight: .medium))
                        .foregroundColor(WidgetTheme.gold)
                    Text(name)
                        .font(.system(size: showsArabic ? 21 : 17, weight: .semibold, design: .serif))
                        .foregroundColor(WidgetTheme.text)
                    Text(time, style: .time)
                        .font(.system(size: showsArabic ? 14 : 12, weight: .medium, design: .monospaced))
                        .foregroundColor(WidgetTheme.dim)
                }
                if let line = WidgetContent.salahLine(at: lineIndex) {
                    Text(line.en)
                        .font(.system(size: showsArabic ? 15 : 12.5, design: .serif).italic())
                        .foregroundColor(WidgetTheme.text.opacity(0.92))
                        .lineLimit(showsArabic ? 4 : 2)
                    if showsArabic {
                        Text(line.source.uppercased())
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .tracking(1.2)
                            .foregroundColor(WidgetTheme.dim)
                            .lineLimit(1)
                    }
                }
                if showsArabic, let times = entry.times {
                    prayerStrip(times: times, currentAdhan: time)
                        .padding(.top, 6)
                }
            }

        case .night:
            VStack(alignment: .leading, spacing: showsArabic ? 9 : 5) {
                arabicLineIfLarge
                Text(entry.verse?.night ?? entry.verse?.translation ?? entry.selection.themeEn)
                    .font(.system(size: showsArabic ? 14.5 : 12.5, design: .serif).italic())
                    .foregroundColor(WidgetTheme.text.opacity(0.92))
                    .lineLimit(showsArabic ? 5 : 2)
                if let fajr = entry.tomorrowFajr {
                    HStack(spacing: 5) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 10, weight: .medium))
                        Text("FAJR")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .tracking(1.2)
                        Text(fajr, style: .time)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(WidgetTheme.gold)
                }
            }
        }
    }

    @ViewBuilder
    private var arabicLineIfLarge: some View {
        if showsArabic, let arabic = entry.verse?.arabic {
            Text(arabic)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(WidgetTheme.text)
                .lineSpacing(4)
                .lineLimit(4)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
        }
    }

    @ViewBuilder
    private func teaseRow(for doorway: WidgetDoorway?) -> some View {
        if let doorway {
            let kind = doorway.kind == "experience" ? "INSIDE THE SURAH" : "DEEP DIVE"
            HStack(spacing: 5) {
                Text(doorway.name.map { "\($0.uppercased()) - \(kind)" } ?? kind)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(1.4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundColor(WidgetTheme.gold)
        }
    }

    /// Large only: the day's gem titles as a map, the current one lit gold.
    private func gemMap(gems: [WidgetGem], current: Int) -> some View {
        gems.enumerated().reduce(Text("")) { built, item in
            let (index, gem) = item
            let title = Text(gem.title.uppercased())
                .foregroundColor(index == current ? WidgetTheme.gold : WidgetTheme.dim)
            let separator = index < gems.count - 1
                ? Text("  \u{00B7}  ").foregroundColor(WidgetTheme.dim.opacity(0.6))
                : Text("")
            return built + title + separator
        }
        .font(.system(size: 8, weight: .semibold, design: .monospaced))
        .tracking(0.8)
        .lineLimit(2)
    }

    /// Large only: the whole day's timetable under the current prayer beat.
    /// Past prayers dim, the sounding one gold, the rest stay readable.
    private func prayerStrip(times: DayPrayerTimes, currentAdhan: Date) -> some View {
        HStack(spacing: 0) {
            ForEach(times.all.indices, id: \.self) { index in
                let prayer = times.all[index]
                VStack(spacing: 2) {
                    Text(prayer.name.uppercased())
                        .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                        .tracking(0.6)
                    Text(prayer.date, style: .time)
                        .font(.system(size: 10.5, weight: .medium))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(
                    prayer.date == currentAdhan ? WidgetTheme.gold
                    : prayer.date < currentAdhan ? WidgetTheme.dim.opacity(0.6)
                    : WidgetTheme.text.opacity(0.85))
            }
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(WidgetTheme.gold.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - Widget

struct DailyReflectionWidget: Widget {
    let kind: String = "DailyReflectionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyReflectionProvider()) { entry in
            DailyReflectionEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Reflection")
        .description("One verse that unfolds through your day, with prayer times on Shia timings.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview("Medium gem", as: .systemMedium) {
    DailyReflectionWidget()
} timeline: {
    ReflectionEntry.sample
}

#Preview("Large gem", as: .systemLarge) {
    DailyReflectionWidget()
} timeline: {
    ReflectionEntry.sample
}
