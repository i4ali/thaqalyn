# Daily Reflection Widget Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.
> Design doc: `docs/plans/2026-08-11-daily-reflection-widget-design.md` (read it first).

**Goal:** A `ThaqalaynWidgets` extension showing one daily verse that unfolds through the day (verse, then its gems, then a doorway) with five prayer beats on Ja'fari timings, from bundled data only.

**Architecture:** A build-time Python script hydrates the 384-verse daily pool (Arabic + translation + gems + doorway copy) into `widget_daily.json`. The widget reuses the app's date-to-verse selection by extracting it into a pure `DailyVerseSelector` shared with the app. A `PrayerTimesEngine` (adhan-swift, `.tehran` method) computes adhan times from a location cached in an App Group by the app. A pure `WidgetScheduleBuilder` turns (date, location, content) into ~10 timeline entries.

**Tech Stack:** WidgetKit + SwiftUI (iOS 18.2), adhan-swift via SPM, Python 3 for the generation script, XCTest.

**Hard rules from CLAUDE.md that apply here:**
- No em dashes in any authored copy. Plain English spelling, no transliteration diacritics (`scripts/strip_diacritics.py` rules).
- No premium signals of any kind in widget UI (design decision; also no lock icons anywhere, ever).
- New user-facing feature => one entry in `WhatsNewCatalog.all` (EN/UR/AR + destination). Included as Task 11.
- Python work uses `source .venv/bin/activate`.
- The reading text-size rule (`ReadingSettingsManager`) applies to in-app reading views only; WidgetKit cannot observe app state, and widget text is glanceable chrome, so widget fonts are fixed. This is a deliberate, documented exemption.
- Editing files with Arabic: the Edit tool renormalizes to NFC. Prefer Python scripts for surgical edits inside JSON that carries Arabic.

**Verified facts this plan relies on (do not re-derive):**
- `DailyVerseProvider.verse(for:)` is a pure function of the date (`Thaqalayn/Services/DailyVerseProvider.swift`). Epoch 2000-01-01 UTC. Selection = sacred-day Hijri override, else seeded theme-spaced permutation.
- Gems coverage is 384/384: every entry in `Thaqalayn/Data/daily_verses.json` (365 `verses` + 19 `sacredDays`) has non-empty `quickOverview.concepts` in `Thaqalayn/Thaqalayn/Data/tafsir_<surah>.json` (note the doubled `Thaqalayn/Thaqalayn/` path).
- `VerseConcept` fields: `title`, `icon`, `colorHex`, `coreInsight`, `whyItMatters`, plus `_urdu`/`_ar` variants (`Thaqalayn/Models/QuranModels.swift:165`).
- Verse text: `quran_data.json` top-level `verses[surah][verse] = {arabicText, translation, ...}` (string keys).
- `SurahExperienceCatalog.swift` / `DeepDiveCatalog.swift` descriptors carry `subtitle: LocalizedText(en: "...")` one-liners and (for experiences) `surahNumber`.
- `thaqalayn://verse?surah=X&verse=Y` and `thaqalayn://journey?id=X` already work end to end (`ThaqalaynApp.handleDeepLink` -> NotificationCenter -> `MainTabView` -> `DeepLinkRouter`).
- No test target, no widget target, no App Group exists yet. Bundle id `MAHR.Partner.Thaqalayn`, team `2J2GCJ25MK`, deployment target iOS 18.2.

---

### Task 1: Generate `widget_daily.json` (build-time hydration script)

**Files:**
- Create: `scripts/generate_widget_daily.py`
- Create (generated): `Thaqalayn/Data/widget_daily.json`

**Step 1: Write the script**

```python
#!/usr/bin/env python3
"""Hydrate the daily-verse pool into widget_daily.json for the widget target.

Reads (all existing, never modified):
  Thaqalayn/Data/daily_verses.json           - the 365 + 19 pool
  Thaqalayn/Thaqalayn/Data/quran_data.json   - Arabic + translation
  Thaqalayn/Thaqalayn/Data/tafsir_<n>.json   - quickOverview gems
  Thaqalayn/Services/SurahExperienceCatalog.swift - doorway copy (regex extract)
  Thaqalayn/Services/DeepDiveCatalog.swift        - doorway copy (regex extract)

Writes:
  Thaqalayn/Data/widget_daily.json - keyed "surah:verse", one object per pool verse.

Fails loudly (non-zero exit) if any pool verse lacks text or gems.
"""
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "Thaqalayn" / "Data"
TAFSIR_DIR = ROOT / "Thaqalayn" / "Thaqalayn" / "Data"

# themeKey -> deep dive id, for doorway evenings on theme-matched days.
# Only map where the pairing is obvious; unmapped themes simply have no dive doorway.
THEME_TO_DIVE = {
    "sabr": "sabr", "shukr": "shukr", "tawakkul": "tawakkul",
    "yaqin": "yaqin", "taqwa": "taqwa", "ikhlas": "ikhlas", "salah": "salah",
}

def load(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)

def extract_catalog(path, needs_surah):
    """Regex-extract (id, surahNumber?, subtitle-en) from a Swift catalog file.
    Swift string literals in these files use straight quotes; the copy inside may
    use curly quotes, which the regex tolerates because it only anchors on the
    straight delimiters."""
    src = Path(path).read_text(encoding="utf-8")
    out = {}
    # Each descriptor: id: "x" ... [surahNumber: N ...] subtitle: LocalizedText(en: "..."
    pattern = re.compile(
        r'id:\s*"([^"]+)"(?:(?!id:\s*").)*?'
        + (r'surahNumber:\s*(\d+)(?:(?!id:\s*").)*?' if needs_surah else r'()')
        + r'subtitle:\s*LocalizedText\(\s*en:\s*"((?:[^"\\]|\\.)*)"',
        re.DOTALL,
    )
    for m in pattern.finditer(src):
        ident, surah, subtitle = m.group(1), m.group(2), m.group(3)
        out[ident] = {"surah": int(surah) if surah else None,
                      "subtitle": subtitle.replace('\\"', '"')}
    return out

def main():
    pool = load(DATA / "daily_verses.json")
    quran = load(TAFSIR_DIR / "quran_data.json")["verses"]
    entries = pool["verses"] + pool["sacredDays"]

    experiences = extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "SurahExperienceCatalog.swift", True)
    dives = extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift", False)
    surah_to_exp = {v["surah"]: (k, v["subtitle"])
                    for k, v in experiences.items() if v["surah"]}

    assert len(surah_to_exp) >= 18, f"expected >=18 experiences, got {len(surah_to_exp)}"
    assert len(dives) >= 8, f"expected >=8 deep dives, got {len(dives)}"

    tafsir_cache, out, errors = {}, {}, []
    for e in entries:
        s, v = e["surah"], e["verse"]
        key = f"{s}:{v}"
        if key in out:
            continue
        if s not in tafsir_cache:
            tafsir_cache[s] = load(TAFSIR_DIR / f"tafsir_{s}.json")
        verse_text = quran.get(str(s), {}).get(str(v))
        tv = tafsir_cache[s].get(str(v))
        qo = (tv or {}).get("quickOverview", {})
        concepts = qo.get("concepts") or []
        if not verse_text:
            errors.append(f"{key}: no verse text"); continue
        if not concepts:
            errors.append(f"{key}: no gems"); continue

        doorway = None
        if s in surah_to_exp:
            exp_id, subtitle = surah_to_exp[s]
            doorway = {"kind": "experience", "id": exp_id, "line": subtitle}
        elif e.get("themeKey") in THEME_TO_DIVE:
            dive_id = THEME_TO_DIVE[e["themeKey"]]
            if dive_id in dives:
                doorway = {"kind": "deepDive", "id": dive_id,
                           "line": dives[dive_id]["subtitle"]}

        out[key] = {
            "surah": s, "verse": v,
            "arabic": verse_text["arabicText"].lstrip("﻿"),
            "translation": verse_text["translation"],
            "gems": [{
                "title": c["title"],
                "insight": c["coreInsight"],
                "icon": c.get("icon", "sparkles"),
                "colorHex": c.get("colorHex", "#CFA96A"),
            } for c in concepts],
            "doorway": doorway,
        }

    if errors:
        print("HYDRATION FAILED:\n" + "\n".join(errors)); sys.exit(1)

    result = {"version": 1, "verses": out}
    with open(DATA / "widget_daily.json", "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=1)
    doorways = sum(1 for x in out.values() if x["doorway"])
    print(f"OK: {len(out)} verses hydrated, {doorways} with doorways")

if __name__ == "__main__":
    main()
```

**Step 2: Run it and inspect**

Run: `source .venv/bin/activate && python3 scripts/generate_widget_daily.py`
Expected: `OK: <n> verses hydrated, <m> with doorways` where n is 380-384 (the 384 pool slots contain a few duplicate surah:verse pairs across pool and sacred days; dedup by key is correct). If it prints `HYDRATION FAILED`, stop and investigate; do not weaken the assertions.

Spot-check: `python3 -c "import json; d=json.load(open('Thaqalayn/Data/widget_daily.json'))['verses']; print(d['39:10']['gems'][3]); print(d['9:1']['doorway'] if '9:1' in d else 'no 9:1')"`
Expected: the "Beyond Measure" gem; a doorway for 9:1 pointing at `surah-tawba` (if 9:1 is in the pool).

**Step 3: Commit**

```bash
git add scripts/generate_widget_daily.py Thaqalayn/Data/widget_daily.json
git commit -m "Widget: build-time hydration script + widget_daily.json"
```

---

### Task 2: Xcode targets, App Group, SPM package (manual Xcode step)

This task is GUI work in Xcode. Do it in one sitting, then verify with a build.

**Step 1: Add the widget extension target**
- Xcode > File > New > Target > "Widget Extension".
- Product Name: `ThaqalaynWidgets`. UNCHECK "Include Configuration App Intent" (static configuration). Team `2J2GCJ25MK`. Embed in `Thaqalayn`.
- Set its iOS Deployment Target to 18.2 (match the app).
- Delete the template's placeholder widget Swift file content later (Task 7 replaces it); keep the target's `ThaqalaynWidgetsBundle.swift` file itself.

**Step 2: Add the unit test target**
- File > New > Target > "Unit Testing Bundle". Product Name: `ThaqalaynTests`, Target to be Tested: `Thaqalayn`.

**Step 3: App Group on both targets**
- Thaqalayn target > Signing & Capabilities > + Capability > App Groups > add `group.MAHR.Partner.Thaqalayn`.
- Repeat for `ThaqalaynWidgets`.

**Step 4: Add adhan-swift**
- File > Add Package Dependencies > `https://github.com/batoulapps/adhan-swift` > Up to Next Major.
- Add the `Adhan` library product to BOTH `Thaqalayn` and `ThaqalaynWidgets` targets.

**Step 5: Bundle resources for the widget target**
- Select `Thaqalayn/Data/daily_verses.json` and `Thaqalayn/Data/widget_daily.json` in the navigator > File inspector > Target Membership: check `ThaqalaynWidgets` (keep `Thaqalayn` checked for daily_verses.json; widget_daily.json is widget-only, do NOT add it to the app target).

**Step 6: Verify**

Run: `xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -sdk iphonesimulator build 2>&1 | tail -3`
Expected: `BUILD SUCCEEDED`.

**Step 7: Commit**

```bash
git add Thaqalayn.xcodeproj Thaqalayn/Thaqalayn.entitlements ThaqalaynWidgets
git commit -m "Widget: ThaqalaynWidgets + ThaqalaynTests targets, App Group, adhan-swift"
```

---

### Task 3: Extract `DailyVerseSelector` (shared, pure) with a characterization test

The widget needs the date-to-verse selection without `@MainActor`, `Bundle.main` app assumptions, or the rest of `QuranModels.swift`. Extract it; prove the refactor changed nothing with a golden test written BEFORE the refactor.

**Files:**
- Create: `Thaqalayn/Shared/DailyVerseCore.swift` (target membership: BOTH `Thaqalayn` and `ThaqalaynWidgets`)
- Modify: `Thaqalayn/Services/DailyVerseProvider.swift` (delegate to the selector)
- Modify: `Thaqalayn/Models/QuranModels.swift` (delete the four moved structs)
- Test: `ThaqalaynTests/DailyVerseSelectorTests.swift`

**Step 1: Write the characterization test against the CURRENT provider**

```swift
import XCTest
@testable import Thaqalayn

@MainActor
final class DailyVerseSelectorTests: XCTestCase {
    /// Golden snapshot of today's behavior. Captured from DailyVerseProvider
    /// BEFORE the refactor; the refactored selector must reproduce it exactly.
    func testSelectionMatchesGoldenDates() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let dates = (0..<400).map { offset in
            cal.date(byAdding: .day, value: offset,
                     to: cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!)!
        }
        let got = dates.map { DailyVerseProvider.shared.verse(for: $0).id }
        // Print once, paste the first 10 below, then assert the full sequence hash.
        print("GOLDEN10:", got.prefix(10))
        print("GOLDENHASH:", got.joined(separator: ",").hashValue)
        XCTAssertEqual(got.count, 400)
    }
}
```

**Step 2: Run it, capture the golden values**

Run: `xcodebuild test -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ThaqalaynTests/DailyVerseSelectorTests 2>&1 | grep -E "GOLDEN|passed|failed"`
Expected: PASS, with GOLDEN10 and GOLDENHASH printed. Paste both into the test as hard assertions (replace the prints), re-run, PASS again. Note: the hash assertion must use the literal string of ids, not `hashValue` across processes; store the first 10 ids and the full joined string's SHA via `Insecure.MD5` or simply assert all 400 ids against a stored `[String]` literal written to a fixture file `ThaqalaynTests/Fixtures/daily_verse_golden.json`. The fixture route is the robust one; use it.

**Step 3: Create `Thaqalayn/Shared/DailyVerseCore.swift`**

Move, verbatim, from their current locations (cut, do not copy):
- `DailyVersePool`, `DailyVerseEntry`, `SacredDay`, `DailyVerseSelection` (from `QuranModels.swift:666-760`; keep the `CommentaryLanguage` helper methods behind `#if canImport(UIKit)`-free compilation by ALSO moving the `CommentaryLanguage` enum if it has no app-only dependencies; if it does, replace the two helper methods with plain-property access in the widget and leave the helpers in an `extension DailyVerseSelection` that stays in `QuranModels.swift`).
- `SplitMix64` (from `DailyVerseProvider.swift`).

Then add the pure selector, lifted from `DailyVerseProvider` (same code, no `@MainActor`, calendar injected):

```swift
/// Pure date -> verse selection. Shared by the app (via DailyVerseProvider)
/// and the widget timeline. See DailyVerseProvider.swift for the design notes.
struct DailyVerseSelector {
    let pool: [DailyVerseEntry]
    let sacredDays: [SacredDay]
    private var permutationCache = NSMutableDictionary()  // cycle -> [Int]

    static let epoch: Date = { /* moved verbatim */ }()

    init(bundle: Bundle) {
        // decode daily_verses.json from the given bundle (fatalError on failure,
        // exactly as DailyVerseProvider.init does today)
    }

    func verse(for date: Date) -> DailyVerseSelection { /* moved verbatim */ }
    // sacredDay(for:), pooledEntry(for:), dayIndex(for:), permutation(cycle:),
    // spacedOrder(cycle:previousTheme:) all move verbatim.
}
```

Implementation notes:
- The Hijri lookup inside `sacredDay(for:)` must not reference `IslamicCalendarManager` (app-only). Inline the same two lines: `var c = Calendar(identifier: .islamicUmmAlQura); c.timeZone = .current`.
- Cache mutation inside a `struct` method: make the cache a `final class Box` field or make the selector a `final class`. A `final class` is simpler; do that.

**Step 4: Refactor `DailyVerseProvider` to delegate**

`DailyVerseProvider` keeps its API (`shared`, `today`, `verse(for:)`, `refreshIfDayChanged`) but its `init` builds a `DailyVerseSelector(bundle: .main)` and `verse(for:)` forwards to it. Delete the moved private methods and `SplitMix64` from the provider file.

**Step 5: Run the characterization test**

Same command as Step 2. Expected: PASS against the pre-refactor fixture. If it fails, the extraction changed behavior; fix the extraction, never the fixture.

**Step 6: Full build + commit**

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -sdk iphonesimulator build 2>&1 | tail -3
git add -A && git commit -m "Widget: extract pure DailyVerseSelector, golden-tested"
```

---

### Task 4: `PrayerTimesEngine` (shared) with known-value tests

**Files:**
- Create: `Thaqalayn/Shared/PrayerTimesEngine.swift` (membership: both targets)
- Test: `ThaqalaynTests/PrayerTimesEngineTests.swift`

**Step 1: Write the failing test**

```swift
import XCTest
@testable import Thaqalayn

final class PrayerTimesEngineTests: XCTestCase {
    // Reference: adhan-swift .tehran method, Qum (34.64, 50.88), 2026-08-11.
    // Fill expected values by running once and cross-checking against a trusted
    // Shia timetable source for that city/date (tolerance 3 minutes), then pin.
    func testQumTimesAreSane() throws {
        let engine = PrayerTimesEngine()
        let times = try XCTUnwrap(engine.times(
            latitude: 34.64, longitude: 50.88,
            timeZone: TimeZone(identifier: "Asia/Tehran")!,
            date: DateComponents(year: 2026, month: 8, day: 11)))
        XCTAssertLessThan(times.fajr, times.sunrise)
        XCTAssertLessThan(times.sunrise, times.dhuhr)
        XCTAssertLessThan(times.dhuhr, times.asr)
        XCTAssertLessThan(times.asr, times.maghrib)
        XCTAssertLessThan(times.maghrib, times.isha)
    }

    func testMaghribIsAfterSunset() throws {
        // Ja'fari maghrib is delayed past astronomical sunset; the .tehran
        // method encodes this (4.5 degree angle). Guard it stays configured.
        let engine = PrayerTimesEngine()
        let t = try XCTUnwrap(engine.times(
            latitude: 51.5, longitude: -0.12,
            timeZone: TimeZone(identifier: "Europe/London")!,
            date: DateComponents(year: 2026, month: 8, day: 11)))
        XCTAssertGreaterThan(t.maghrib.timeIntervalSince(t.sunset), 5 * 60)
    }
}
```

**Step 2: Run to verify failure** (type does not exist). **Step 3: Implement**

```swift
import Foundation
import Adhan

struct DayPrayerTimes {
    let fajr: Date, sunrise: Date, dhuhr: Date, asr: Date
    let sunset: Date, maghrib: Date, isha: Date
    var all: [(name: String, date: Date)] {
        [("Fajr", fajr), ("Zohr", dhuhr), ("Asr", asr),
         ("Maghrib", maghrib), ("Isha", isha)]
    }
}

/// Ja'fari prayer times. Method: Tehran Institute of Geophysics
/// (Fajr 17.7, Isha 14, Maghrib 4.5 degrees) via adhan-swift.
struct PrayerTimesEngine {
    func times(latitude: Double, longitude: Double,
               timeZone: TimeZone, date: DateComponents) -> DayPrayerTimes? {
        let coords = Coordinates(latitude: latitude, longitude: longitude)
        let params = CalculationMethod.tehran.params
        guard let pt = PrayerTimes(coordinates: coords, date: date, calculationParameters: params),
              let sun = SolarTime(date: date, coordinates: coords) else { return nil }
        var cal = Calendar(identifier: .gregorian); cal.timeZone = timeZone
        let sunset = cal.date(from: sun.sunset) ?? pt.maghrib
        return DayPrayerTimes(fajr: pt.fajr, sunrise: pt.sunrise, dhuhr: pt.dhuhr,
                              asr: pt.asr, sunset: sunset, maghrib: pt.maghrib, isha: pt.isha)
    }
}
```

Note: check adhan-swift's actual API surface when implementing (`SolarTime` may differ by version); if sunset is awkward to obtain, `sunrise`/`maghrib` ordering assertions are enough - drop the sunset field and the second test's sunset comparison, and assert `maghrib > dhuhr` instead. Do not hand-roll solar math if the package builds fine.

**Step 4: Run tests, expect PASS. Step 5: Commit** (`"Widget: PrayerTimesEngine, Ja'fari .tehran method"`).

---

### Task 5: App Group location store + app-side capture UI

**Files:**
- Create: `Thaqalayn/Shared/WidgetLocationStore.swift` (membership: both targets)
- Create: `Thaqalayn/Services/PrayerLocationService.swift` (app only)
- Create: `Thaqalayn/Views/WidgetExplainerView.swift` (app only)
- Modify: `Thaqalayn/Views/SettingsView.swift` (one new row)
- Test: `ThaqalaynTests/WidgetLocationStoreTests.swift`

**Step 1: Failing test for the store**

```swift
final class WidgetLocationStoreTests: XCTestCase {
    func testRoundTrip() {
        let defaults = UserDefaults(suiteName: "test.widget.location")!
        defaults.removePersistentDomain(forName: "test.widget.location")
        let store = WidgetLocationStore(defaults: defaults)
        XCTAssertNil(store.load())
        store.save(latitude: 34.64, longitude: 50.88, timeZoneId: "Asia/Tehran")
        let loc = store.load()
        XCTAssertEqual(loc?.latitude, 34.64)
        XCTAssertEqual(loc?.timeZoneId, "Asia/Tehran")
    }
}
```

**Step 2: Run (fails). Step 3: Implement the store**

```swift
import Foundation

struct WidgetLocation: Codable, Equatable {
    let latitude: Double, longitude: Double, timeZoneId: String
}

/// The ONLY data that crosses the App Group. Nothing else, ever (design decision).
struct WidgetLocationStore {
    static let suiteName = "group.MAHR.Partner.Thaqalayn"
    private let defaults: UserDefaults
    init(defaults: UserDefaults? = UserDefaults(suiteName: WidgetLocationStore.suiteName)) {
        self.defaults = defaults ?? .standard
    }
    func load() -> WidgetLocation? {
        guard let data = defaults.data(forKey: "widgetPrayerLocation") else { return nil }
        return try? JSONDecoder().decode(WidgetLocation.self, from: data)
    }
    func save(latitude: Double, longitude: Double, timeZoneId: String) {
        let loc = WidgetLocation(latitude: latitude, longitude: longitude, timeZoneId: timeZoneId)
        defaults.set(try? JSONEncoder().encode(loc), forKey: "widgetPrayerLocation")
    }
}
```

**Step 4: `PrayerLocationService` (app side).** `NSObject, CLLocationManagerDelegate, ObservableObject`. One public method `captureOnce()`: request when-in-use authorization (the `Info.plist` string already exists), take one `requestLocation()` fix, then `WidgetLocationStore().save(latitude:longitude:timeZoneId: TimeZone.current.identifier)` and `WidgetCenter.shared.reloadAllTimelines()`. Publish a simple `status` enum (`idle/locating/saved/denied`) for the UI. No continuous updates, no background modes.

**Step 5: `WidgetExplainerView` (app side).** A simple sheet, both theme variants, matching existing view patterns (copy structure from a small existing sheet view):
- Title "The Daily Reflection Widget", 2-3 lines on what it shows, the standard iOS "long-press the Home Screen > + > Thaqalayn" add instructions.
- A "Enable Prayer Times" button driving `PrayerLocationService.captureOnce()` with the status shown; on `.saved`, show the resolved city-free confirmation "Prayer times enabled".
- All copy EN/UR/AR via the app's existing localization pattern; plain spelling, no em dashes.

**Step 6: Settings row.** In `SettingsView`, add a "Daily Reflection Widget" row opening `WidgetExplainerView` (sheet). Match surrounding row style exactly.

**Step 7: Build + run tests + commit** (`"Widget: App Group location store + capture UI"`).

---

### Task 6: Salah lines pool (the only new content)

**Files:**
- Create: `Thaqalayn/Data/salah_lines.json` (membership: `ThaqalaynWidgets` only)

**Step 1: Author the pool.** Structure:

```json
{"version": 1, "lines": [
  {"en": "Prayer is the ascent of the believer.", "source": "attributed, widely narrated"},
  {"en": "Establish prayer to remember Me.", "source": "Qur'an 20:14"}
]}
```

Content rules (non-negotiable):
- ~100 lines. Mix: (a) Qur'anic lines about salah (safest, cite surah:verse), (b) well-known, verifiable hadith from standard Shia sources (al-Kafi, Nahj al-Balagha, Sahifa Sajjadiyya, Bihar) with the source named, (c) NO invented attributions. If a beloved line cannot be sourced confidently, mark `"source": "attributed"` or drop it.
- One sentence each, widget-sized (under ~110 characters), plain spelling, no diacritics, no em dashes.
- Respectful-language rule applies (never "dying" for the Prophet or Imams).

**Step 2: Run the diacritics check:** `python3 scripts/strip_diacritics.py --report Thaqalayn/Data/salah_lines.json` - expect zero findings (or apply).

**Step 3: STOP - user curation gate.** Present the 100 lines to the user for review before proceeding. This is authored religious content; it ships only after explicit approval.

**Step 4: Commit after approval** (`"Widget: salah lines pool (~100 curated lines)"`).

---

### Task 7: `WidgetScheduleBuilder` + content store (pure, tested)

**Files:**
- Create: `ThaqalaynWidgets/WidgetContent.swift` (widget target only)
- Create: `Thaqalayn/Shared/WidgetScheduleBuilder.swift` (membership: both, so it is testable from `ThaqalaynTests`)
- Test: `ThaqalaynTests/WidgetScheduleBuilderTests.swift`

**Step 1: Define the model + failing tests**

```swift
enum WidgetBeat: Equatable {
    case verse                       // sunrise -> Zohr
    case gem(index: Int)             // afternoon beats
    case doorway                     // evening, when the day has one
    case night                       // after Isha beat ends
    case prayer(name: String, time: Date, salahLine: String)
}

struct WidgetTimelineEntryModel: Equatable {
    let date: Date          // when this entry becomes current
    let beat: WidgetBeat
}
```

Tests (write all, watch them fail):

```swift
final class WidgetScheduleBuilderTests: XCTestCase {
    // Helpers build a fixed date + a fake DayPrayerTimes.
    func testDayWithPrayerTimesHasTenBeatsInOrder()      // 5 prayer + verse + 2 gems + evening + night
    func testPrayerBeatsHoldRoughly45MinutesExceptFajr() // fajr holds until sunrise
    func testDayWithoutLocationHasNoPrayerBeats()        // verse/gems/evening/night only, starting at 08:00
    func testDoorwayDayUsesDoorwayForEveningBeat()
    func testGemIndicesNeverExceedGemCount()             // 2-gem verse: evening falls back to last gem
    func testSalahLineRotationIsDeterministic()          // same date -> same lines; day+1 -> advanced
    func testEntriesAreStrictlyAscendingAndStartAtOrBeforeMidnight()
}
```

**Step 2: Implement `WidgetScheduleBuilder`.** Pure function:

```swift
struct WidgetScheduleBuilder {
    /// gems.count is 1-4; salahLines is the full pool; times nil = no location.
    static func schedule(for dayStart: Date,
                         dayIndex: Int,
                         times: DayPrayerTimes?,
                         gemCount: Int,
                         hasDoorway: Bool,
                         salahLineCount: Int) -> [WidgetTimelineEntryModel]
}
```

Rules (from the design doc): entry 0 at `dayStart` shows `.verse` (pre-Fajr hours belong to the verse of the NEW day). With times: prayer beats at each adhan; Fajr reverts to `.verse` at sunrise; other prayers revert 45 minutes after adhan to the day-part beat (first gem after Zohr, next gem after Asr, evening after Maghrib as `.doorway` if `hasDoorway` else last gem, `.night` 45 min after Isha). Without times: `.verse` at dayStart, gem 1 at 12:00, gem 2 at 16:00, evening at 19:30, night at 22:30. Salah line index = `(dayIndex * 5 + prayerOrdinal) % salahLineCount` (returned as index; the view layer resolves text). Clamp gem indices to `gemCount - 1`; skip duplicate-index beats rather than repeating them.

**Step 3: Run tests, make them pass. Step 4: `WidgetContent.swift`** (widget target): loads `widget_daily.json` + `salah_lines.json` + `daily_verses.json` once (static let), exposes `content(for date: Date)` returning the selection (via `DailyVerseSelector(bundle: .main)` - `Bundle.main` inside the extension IS the widget bundle), the hydrated verse entry, and the schedule. **Step 5: Commit** (`"Widget: schedule builder + content store, tested"`).

---

### Task 8: Widget views (small / medium / large) + timeline provider

**Files:**
- Modify/Create in `ThaqalaynWidgets/`: `ThaqalaynWidgetsBundle.swift`, `DailyReflectionWidget.swift`, `WidgetTheme.swift`

**Step 1: `WidgetTheme.swift`.** Hardcode the Midnight Emerald palette (do NOT import ThemeManager): background `LinearGradient` `#14332A -> #0A1D18` at 155 degrees, text `#ECE5D3`, dim `#9AA896`, gold `#CFA96A`, gold-dim 16% opacity. Chip = mono-style caps 9pt tracking 1.4 gold on gold-dim capsule with gold 30% border.

**Step 2: `DailyReflectionWidget.swift`.** `TimelineProvider` (not AppIntent):
- `timeline(in:)`: `let now = Date()`; build today's schedule (+ tomorrow through its verse beat) from `WidgetContent`; map to entries; policy `.after(nextMidnight.addingTimeInterval(60))`.
- Entry view switches on family:
  - **systemSmall**: theme word (from `DailyVerseSelection.themeEn`; Arabic script theme `themeAr` as the large element), reference `<surah>:<verse>` bottom. Prayer beats: prayer name large + time.
  - **systemMedium**: per the approved mockups. Top row chip (gem title / "Go deeper" / "Prayer time") + reference (`al-<name> s:v` - surah English name is in `widget_daily.json`? It is NOT; render plain `s:v`, or add `englishName` to the hydration script output in Task 1 - do add it: one line, rerun script). Verse beat: translation italic serif. Gem beat: translation 1 line + insight. Doorway: doorway line + tease row with chevron. Prayer: crescent SFSymbol `moon.stars`, name, time, salah line italic. Bottom row: concept dots (filled = current gem index) + THAQALAYN wordmark caps.
  - **systemLarge**: medium + Arabic line (trailing-aligned, `.environment(\.layoutDirection, .rightToLeft)` for the Arabic text block only) above the translation, and on doorway beats the full tease row.
- Fonts: system serif design (`.fontDesign(.serif)`) for verse/insight lines, monospaced caps for chips/refs. Fixed sizes (documented exemption from the reading-scale rule).
- `widgetURL`: verse/gem beats -> `thaqalayn://verse?surah=S&verse=V`; doorway -> `thaqalayn://experience?id=X` or `thaqalayn://deepdive?id=X`; prayer/night -> `thaqalayn://` (just opens the app).
- Preview provider: one gem-day snapshot from bundled data (pick 39:10) so the gallery always looks right.
- No premium UI anywhere. No lock glyphs anywhere.

**Step 3: Build for the widget scheme, then run on simulator** (`xcodebuild -scheme ThaqalaynWidgets -sdk iphonesimulator build`). Add the widget in the simulator (long-press Home Screen) and eyeball all three sizes against the approved mockups.

**Step 4: Commit** (`"Widget: DailyReflectionWidget small/medium/large + timeline"`).

---

### Task 9: Lock screen accessories

**Files:**
- Create: `ThaqalaynWidgets/AccessoryWidgets.swift` (register both in the bundle)

**Step 1:** Two additional widgets in `ThaqalaynWidgetsBundle`:
- `HijriDateAccessory` (`accessoryInline` + `accessoryRectangular`): "28 Safar 1448 - <theme word>". Hijri string via `Calendar(identifier: .islamicUmmAlQura)` components + a small month-name table (EN); do not import `IslamicCalendarManager`.
- `NextPrayerAccessory` (`accessoryInline` + `accessoryCircular` + `accessoryRectangular`): next prayer name + time from `PrayerTimesEngine` + `WidgetLocationStore`; if no location, render "Set up in Thaqalayn" once (inline) - tapping any accessory opens the app.
- Timelines: Hijri reloads at midnight; next-prayer entries flip at each adhan.

**Step 2:** Build, add both accessories to the simulator lock screen, verify. **Step 3: Commit** (`"Widget: Hijri + next-prayer lock screen accessories"`).

---

### Task 10: Deep link routes for experiences and dives

**Files:**
- Modify: `Thaqalayn/ThaqalaynApp.swift:40-55` (two new hosts)
- Modify: `Thaqalayn/Views/MainTabView.swift` (two new `.onReceive` handlers, mirror the `navigateToJourney` one at line 150)

**Step 1:** In `handleDeepLink`, add hosts `experience` and `deepdive` parsing `?id=`, posting `NavigateToSurahExperience` / `NavigateToDeepDive` notifications (define the `Notification.Name` constants next to the existing ones).

**Step 2:** In `MainTabView`, on receive: switch to the Journeys tab (tag 4) and set `DeepLinkRouter.shared.pendingSurahExperienceId` / `pendingDeepDiveId` (JourneyHubView already consumes both).

**Step 3: Manual verification** on simulator: `xcrun simctl openurl booted "thaqalayn://experience?id=surah-tawba"` opens the al-Tawba experience; same for `thaqalayn://deepdive?id=sabr`; existing `thaqalayn://verse?surah=39&verse=10` still works.

**Step 4: Commit** (`"Widget: experience + deep dive URL routes"`).

---

### Task 11: What's New entry (mandatory for every user-facing feature)

**Files:**
- Modify: `Thaqalayn/Models/WhatsNewItem.swift` (one new entry in `WhatsNewCatalog.all` + a `WhatsNewDestination` case)
- Modify: `Thaqalayn/Views/WhatsNewCard.swift` (`open()` handles the new case by presenting `WidgetExplainerView`)

**Step 1:** Add `case widgetExplainer` to `WhatsNewDestination` and handle it in `WhatsNewCard.open()`. Add the catalog entry: title/blurb/CTA in EN/UR/AR (no em dashes; plain spelling), e.g. EN title "The Daily Reflection Widget", blurb: one verse that unfolds through your day, its gems one at a time, and the five prayer times on Shia timings, right on your Home Screen. CTA "Set it up".

**Step 2:** Build, verify the card renders on the Today tab and opens the explainer. **Step 3: Commit** (`"Widget: What's New entry + explainer destination"`).

---

### Task 12: Device pass + release checklist

**Step 1: Device pass** (physical device):
- All three home-screen sizes across a full day (use time changes or `IslamicCalendarManager.debugNowOverride` for content; prayer beats need real clock or a debug schedule offset).
- Sacred-day rendering (override Hijri date to 10 Muharram; expect 3:169).
- No-location fallback: fresh install, never grant location; widget must show reflection beats only, accessories degrade gracefully.
- Deep links from every beat land on the right screens, including cold launch.
- Both lock screen accessories in light and dark lock screen contexts.

**Step 2: Release checklist**
- Re-run `scripts/generate_widget_daily.py` and commit the refreshed JSON whenever tafsir/catalog/daily_verses data changes (add a line to the release ritual; a stale file is silent).
- App Store Connect: widget extension inherits the app's provisioning; verify archive includes `ThaqalaynWidgets.appex`.
- No CloudKit schema impact (no CloudKit in this feature). Supabase untouched.

**Step 3: Final commit + version bump** per the usual `/bump-version` flow when shipping.

---

## Task order and dependencies

1 (script) and 6 (salah lines) are independent of Xcode work. 2 blocks everything Swift. 3 blocks 7. 4 and 5 block 7 only via the schedule's prayer input. 8 needs 3+4+5+7. 9 needs 4+5. 10 and 11 are independent of 8-9. 12 is last.

Sensible sequence: 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 6 (curation gate can run in parallel from early on), 12.
