//
//  DailyVerseDebug.swift
//  Thaqalayn
//
//  DEBUG-only verification for DailyVerseProvider. There is no XCTest target in
//  this project; this stands in for one. Delete the file and nothing else breaks.
//
//  Run from a debug entry point:  DailyVerseDebug.runAll()
//

#if DEBUG
import Foundation

enum DailyVerseDebug {

    @MainActor
    static func runAll() {
        print("=== DailyVerseProvider verification ===")
        var passed = 0, failed = 0

        func check(_ name: String, _ condition: Bool, _ detail: @autoclosure () -> String = "") {
            if condition {
                passed += 1
                print("  PASS  \(name)")
            } else {
                failed += 1
                print("  FAIL  \(name)  \(detail())")
            }
        }

        let provider = DailyVerseProvider.shared
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let start = calendar.startOfDay(for: Date())

        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: start)!
        }

        // 1. No verse repeats within a 365-day cycle. Sacred days are excluded:
        //    they recur once a year by design and are never drawn from the pool.
        var refs: [String] = []
        for offset in 0..<365 {
            let selection = provider.verse(for: day(offset))
            if selection.occasion(.english) == nil { refs.append(selection.id) }
        }
        let unique = Set(refs)
        check("no verse repeats in 365 days",
              unique.count == refs.count,
              "\(refs.count - unique.count) duplicate(s)")

        // 2. No two consecutive days share a theme. Compare themeKey, NOT themeEn:
        //    themeEn is a per-verse display label and is near-unique, so comparing it
        //    would pass even when the rule is broken. A sacred day has no themeKey and
        //    is exempt - it interrupts the pool rather than being drawn from it.
        //    730 days deliberately spans a cycle seam, which is where the naive
        //    implementation used to break.
        var adjacentCollisions = 0
        for offset in 1..<730 {
            let a = provider.verse(for: day(offset - 1))
            let b = provider.verse(for: day(offset))
            guard let keyA = a.themeKey, let keyB = b.themeKey else { continue }
            if keyA == keyB { adjacentCollisions += 1 }
        }
        check("no two consecutive days share a theme (730 days, spans a seam)",
              adjacentCollisions == 0,
              "\(adjacentCollisions) collision(s)")

        // 3. Determinism: the same date always yields the same verse.
        let probe = day(97)
        check("selection is deterministic",
              provider.verse(for: probe) == provider.verse(for: probe))

        // 4. Year 2 is not a replay of year 1.
        let y1 = (0..<365).map { provider.verse(for: day($0)).id }
        let y2 = (365..<730).map { provider.verse(for: day($0)).id }
        check("year 2 is a different order from year 1", y1 != y2)

        // 5. Sacred days win, and their titles are populated.
        var foundAshura = false
        for offset in 0..<730 {
            let date = day(offset)
            let hijri = IslamicCalendarManager.shared.islamicCalendar
                .dateComponents([.month, .day], from: date)
            guard hijri.month == 1, hijri.day == 10 else { continue }
            let selection = provider.verse(for: date)
            foundAshura = true
            check("10 Muharram overrides the pool",
                  selection.occasion(.english) != nil,
                  "got no occasion")
            check("10 Muharram serves 3:169", selection.id == "3:169", "got \(selection.id)")
            break
        }
        check("10 Muharram occurs within the next 2 years", foundAshura)

        // 6. Every selection hydrates. A ref that does not resolve is a silent blank
        //    notification, which is the worst failure mode this feature has.
        var unhydrated: [String] = []
        for offset in 0..<400 {
            let selection = provider.verse(for: day(offset))
            if DataManager.shared.getVerse(surah: selection.surah, verse: selection.verse) == nil {
                unhydrated.append(selection.id)
            }
        }
        check("every ref hydrates from quran_data.json",
              unhydrated.isEmpty,
              "missing: \(unhydrated.prefix(5))")

        // 7. Urdu is actually present, since the push now promises it.
        var missingUrdu: [String] = []
        for offset in 0..<400 {
            let selection = provider.verse(for: day(offset))
            let verse = DataManager.shared.getVerse(surah: selection.surah, verse: selection.verse)
            if (verse?.translationUrdu ?? "").isEmpty { missingUrdu.append(selection.id) }
        }
        check("every ref has an Urdu translation",
              missingUrdu.isEmpty,
              "missing: \(missingUrdu.prefix(5))")

        print("=== \(passed) passed, \(failed) failed ===")
    }
}
#endif
