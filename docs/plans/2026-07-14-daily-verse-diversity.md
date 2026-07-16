# Daily Verse Diversity Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the 50-verse, four-day-looping daily verse with a single 365-entry theme-tagged pool served by a seeded permutation, shared by the push notification and the Today card.

**Architecture:** One reference-only JSON pool (`daily_verses.json`) holding 365 `{surah, verse, themeKey, themeEn/Ur/Ar}` entries plus a sacred-day override table. A new stateless `DailyVerseProvider` maps any `Date` to a selection: a Hijri `(month, day)` override wins, otherwise a per-cycle order built by seeded greedy selection from the largest remaining theme bucket, which guarantees no two adjacent days share a theme. Verse text hydrates at read time from the existing 6,236-verse `quran_data.json`. Because selection is a pure function of the date, it survives reinstall, computes any future day for the 30-day notification window, and keeps the push and the Today card in sync with no shared mutable state.

> **Implementation note, added during execution.** The original plan specified "shuffle, then repair adjacent theme collisions by swapping with a later verse." **That is broken and must not be reinstated.** A forward-only repair runs out of swap candidates near the end of the array, so every cycle ended with broken spacing in its final days. Independently, permuting each cycle in isolation never checked the seam between one year's last day and the next year's first, colliding in 24% of cycles. Both were found by `scripts/daily_verses/simulate.py`, not by the build. The shipped algorithm is greedy-by-largest-remaining-bucket, seeded with the previous cycle's closing theme. See Task 6.

**Tech Stack:** Swift 5 / SwiftUI, `UNUserNotificationCenter`, `Calendar(identifier: .islamicUmmAlQura)`, Python 3 for the content pipeline.

**Design doc:** `docs/plans/2026-07-14-daily-verse-diversity-design.md`

---

## House rules for whoever executes this

Read these before Task 1. They override the generic habits you might bring.

- **There is no XCTest target and you must not create one.** iOS work in this repo ships without automated Swift tests. The gate for every Swift task is a green `xcodebuild` **plus** a removable `#if DEBUG` verification harness that asserts the behaviour and prints its results. Task 8 builds that harness; it is the closest thing to a test suite this feature gets, and it is where the real guarantees are proven.
- **The Python content pipeline is different.** `validate.py` is a genuine test surface with real assertions. Write it **before** the content it validates.
- **Do not run `git commit`.** The user commits their own work. Where this plan says **Checkpoint**, stop, state what changed, and let the user commit.
- **Do not run the simulator.** The user does install/launch/screenshot verification themselves. You stop at a green `xcodebuild`.
- **Never run more than two subagents at once.** Task 5 fans out content authoring; batch it in waves of two.
- **Trust `xcodebuild`, not SourceKit.** "Cannot find type in scope" on a newly created Swift file is a stale-index artefact, not a real error.
- **Wrap every `#Preview` in `#if DEBUG`.** An unwrapped preview that references DEBUG-only symbols passes the simulator build and then fails Archive with exit 65.
- **Plain English spelling, no transliteration diacritics.** Write `Qur'an`, `Shi'a`, `Ashura`, `Ghadeer`, `Dhul-Hijjah`. Never `Qurʾān`, `ʿĀshūrāʾ`, `Dhū al-Ḥijjah`. This applies to every English string you author, including JSON theme labels and What's New copy.
- **No em dashes** in any prose or copy. Use a plain dash.

**The build command, used at every gate:**

```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
xcodebuild -scheme Thaqalayn \
  -destination 'id=00CE7494-2523-4F1B-AF96-30D7969096C1' \
  build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`. That UDID is the iPhone 16 Pro simulator. Use `id=`, never `name=`.

---

## Task 1: Approve the theme vocabulary and the sacred-day table

These are content gates. Everything downstream depends on them, and neither can be changed cheaply once 365 verses are authored against them. **Do not start Task 2 until the user has signed off on both.**

**Files:** none yet. This task produces a decision.

**Step 1: Present the theme vocabulary**

Eighteen keys, roughly 20 verses each across 365. The spacing guarantee in Task 7 depends on no single theme dominating; at 20/365 (5.5%) the margin is enormous.

```
tawhid              mercy               patience            gratitude
trust               repentance          prayer              remembrance
knowledge           justice             charity             character
family              hardship-and-ease   creation            hereafter
guidance            striving
```

**Step 2: Present the sacred-day table**

Nineteen overrides, leaving 346 days to the pool. The design doc's first draft had three colliding refs (37:107, 33:23 and 76:8 each served two occasions); this table resolves them.

| Hijri date | Occasion | Ref |
| --- | --- | --- |
| 10 Muharram | Ashura | 3:169 |
| 20 Safar | Arbaeen | 22:27 |
| 28 Safar | Passing of the Prophet | 3:144 |
| 17 Rabi' al-Awwal | Mawlid an-Nabi | 21:107 |
| 3 Jumada al-Thani | Martyrdom of Sayyida Fatima | 33:33 |
| 13 Rajab | Birth of Imam Ali | 2:207 |
| 27 Rajab | Mab'ath | 96:1 |
| 3 Sha'ban | Birth of Imam Husayn | 42:23 |
| 15 Sha'ban | Birth of Imam al-Mahdi | 28:5 |
| 1 Ramadan | Start of the fast | 2:183 |
| 15 Ramadan | Birth of Imam Hasan | 21:73 |
| 21 Ramadan | Martyrdom of Imam Ali | 33:23 |
| 23 Ramadan | Laylat al-Qadr | 97:1 |
| 1 Shawwal | Eid al-Fitr | 87:14 |
| 9 Dhul-Hijjah | Arafah | 2:198 |
| 10 Dhul-Hijjah | Eid al-Adha | 37:107 |
| 18 Dhul-Hijjah | Ghadeer | 5:67 |
| 24 Dhul-Hijjah | Mubahala | 3:61 |
| 25 Dhul-Hijjah | Surah al-Insan | 76:8 |

**Step 3: Flag the two judgement calls for the user**

1. **Dates vary by narration.** 17 Rabi' al-Awwal (Mawlid), 3 Jumada al-Thani (Fatimiyya) and 15 Ramadan are the ones most likely to need adjusting to the user's preference.
2. **`islamicUmmAlQura` may land a day off** local moon-sighting. This is pre-existing, but naming occasions in notification titles makes it visible for the first time. The user should know before we ship it.

**Step 4: STOP. Get explicit approval on both tables.**

---

## Task 2: Write the validator (before any content exists)

The validator is the test. It runs against a pool that does not exist yet and must fail loudly.

**Files:**
- Create: `scripts/daily_verses/validate.py`

**Step 1: Write the validator**

```python
#!/usr/bin/env python3
"""Validate daily_verses.json against quran_data.json.

Run:  python3 scripts/daily_verses/validate.py
Exit: 0 if the pool is shippable, 1 otherwise.
"""
import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POOL = ROOT / "Thaqalayn" / "Data" / "daily_verses.json"
QURAN = ROOT / "Thaqalayn" / "Thaqalayn" / "Data" / "quran_data.json"

EXPECTED_COUNT = 365
# The theme-spacing pass in DailyVerseProvider can always succeed while no theme
# holds more than half the pool. We bound it far tighter to keep the year varied.
MAX_THEME_SHARE = 1 / 3

errors = []


def err(msg):
    errors.append(msg)


def load_quran_index(path):
    """-> {(surah, verse): {"arabicText", "translation", "translationUrdu", ...}}

    quran_data.json is {"surahs": [...meta...], "verses": {"<surah>": {"<verse>": {...}}}}.
    Verified 2026-07-14: 6236 verses, 100% English and 100% Urdu coverage.
    """
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    index = {}
    for surah_key, verses in data["verses"].items():
        for verse_key, v in verses.items():
            index[(int(surah_key), int(verse_key))] = v
    return index


def main():
    if not POOL.exists():
        print(f"FAIL: {POOL} does not exist")
        return 1

    pool_doc = json.loads(POOL.read_text(encoding="utf-8"))
    quran = load_quran_index(QURAN)
    if not quran:
        print(f"FAIL: could not index {QURAN} - check its shape")
        return 1

    vocab = set(pool_doc.get("themes", []))
    verses = pool_doc.get("verses", [])
    sacred = pool_doc.get("sacredDays", [])

    if not vocab:
        err("themes vocabulary is empty")

    # --- pool size ---
    if len(verses) != EXPECTED_COUNT:
        err(f"expected {EXPECTED_COUNT} verses, found {len(verses)}")

    # --- refs resolve, with BOTH translations ---
    seen_refs = set()
    for e in verses:
        ref = (e["surah"], e["verse"])
        label = f'{e["surah"]}:{e["verse"]} (id {e.get("id")})'

        if ref in seen_refs:
            err(f"duplicate ref in pool: {label}")
        seen_refs.add(ref)

        v = quran.get(ref)
        if v is None:
            err(f"ref does not exist in quran_data.json: {label}")
            continue
        if not (v.get("translation") or "").strip():
            err(f"empty English translation: {label}")
        if not (v.get("translationUrdu") or "").strip():
            err(f"empty Urdu translation: {label}")

        # --- theme integrity ---
        if e.get("themeKey") not in vocab:
            err(f'themeKey "{e.get("themeKey")}" not in vocabulary: {label}')
        for field in ("themeEn", "themeUr", "themeAr"):
            if not (e.get(field) or "").strip():
                err(f"missing {field}: {label}")

    # --- theme balance: the spacing pass needs no theme to dominate ---
    counts = Counter(e.get("themeKey") for e in verses)
    for theme, n in counts.most_common():
        if verses and n / len(verses) > MAX_THEME_SHARE:
            err(f'theme "{theme}" is {n}/{len(verses)} of the pool, over the {MAX_THEME_SHARE:.0%} cap')

    unused = vocab - set(counts)
    if unused:
        err(f"themes declared but never used: {sorted(unused)}")

    # --- sacred days ---
    seen_days, seen_sacred_refs = set(), set()
    for s in sacred:
        key = (s["month"], s["day"])
        label = f'{s["day"]}/{s["month"]} {s.get("occasionEn")}'
        if key in seen_days:
            err(f"duplicate sacred day: {label}")
        seen_days.add(key)

        if not (1 <= s["month"] <= 12) or not (1 <= s["day"] <= 30):
            err(f"sacred day out of Hijri range: {label}")

        ref = (s["surah"], s["verse"])
        if ref not in quran:
            err(f'sacred-day ref does not exist: {s["surah"]}:{s["verse"]} ({label})')
        if ref in seen_sacred_refs:
            err(f'two occasions share the same verse {s["surah"]}:{s["verse"]} ({label})')
        seen_sacred_refs.add(ref)

        # A sacred verse must NOT also sit in the pool, or it could appear twice in a year.
        if ref in seen_refs:
            err(f'sacred-day ref {s["surah"]}:{s["verse"]} is also in the pool ({label})')

        for field in ("occasionEn", "occasionUr", "occasionAr",
                      "themeEn", "themeUr", "themeAr"):
            if not (s.get(field) or "").strip():
                err(f"missing {field}: {label}")

    # --- report ---
    if errors:
        print(f"FAIL: {len(errors)} problem(s)\n")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(f"OK: {len(verses)} verses, {len(counts)} themes, {len(sacred)} sacred days")
    print(f"    theme spread: min {min(counts.values())}, max {max(counts.values())}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

**Step 2: Run it and confirm it fails**

```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
source .venv/bin/activate
python3 scripts/daily_verses/validate.py
```

Expected: `FAIL: .../daily_verses.json does not exist`, exit 1. That is correct. If it prints anything else, the paths are wrong.

**Step 3: Re-confirm the corpus (already verified, but cheap to re-check)**

This was checked on 2026-07-14 and the result is the reason the feature is viable:

```
total verses: 6236
english field: translation | urdu field: translationUrdu
EN coverage: 6236/6236 (100.0%)
UR coverage: 6236/6236 (100.0%)
```

Confirm it still holds:

```bash
python3 -c "
import sys; sys.path.insert(0, 'scripts/daily_verses')
from validate import load_quran_index, QURAN
q = load_quran_index(QURAN)
print('verses:', len(q))
print('EN:', sum(1 for v in q.values() if (v.get('translation') or '').strip()))
print('UR:', sum(1 for v in q.values() if (v.get('translationUrdu') or '').strip()))
"
```

Expected: `6236 / 6236 / 6236`. Anything less and the Urdu half of the feature is compromised - **stop and tell the user** rather than authoring around it.

**Checkpoint.** Validator exists and fails correctly. Tell the user; let them commit.

---

## Task 3: Write the assembler and seed the sacred days

**Files:**
- Create: `scripts/daily_verses/assemble.py`
- Create: `scripts/daily_verses/batches/sacred_days.json`
- Create: `scripts/daily_verses/batches/README.md`

**Step 1: Write `assemble.py`**

```python
#!/usr/bin/env python3
"""Merge authored batches into Thaqalayn/Data/daily_verses.json.

Batches live in scripts/daily_verses/batches/:
  batch_*.json      -> {"verses": [...]}          appended in filename order
  sacred_days.json  -> {"sacredDays": [...]}

Ids are assigned here, not by the authors, so batches never collide.
Run:  python3 scripts/daily_verses/assemble.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BATCHES = Path(__file__).resolve().parent / "batches"
OUT = ROOT / "Thaqalayn" / "Data" / "daily_verses.json"

THEMES = [
    "tawhid", "mercy", "patience", "gratitude",
    "trust", "repentance", "prayer", "remembrance",
    "knowledge", "justice", "charity", "character",
    "family", "hardship-and-ease", "creation", "hereafter",
    "guidance", "striving",
]


def main():
    verses = []
    for path in sorted(BATCHES.glob("batch_*.json")):
        doc = json.loads(path.read_text(encoding="utf-8"))
        got = doc.get("verses", [])
        verses.extend(got)
        print(f"  {path.name}: {len(got)}")

    sacred_path = BATCHES / "sacred_days.json"
    sacred = json.loads(sacred_path.read_text(encoding="utf-8"))["sacredDays"] \
        if sacred_path.exists() else []

    # Ids are positional and assigned centrally.
    for i, v in enumerate(verses):
        v["id"] = i

    doc = {
        "version": 1,
        "themes": THEMES,
        "verses": verses,
        "sacredDays": sacred,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"\nwrote {OUT.relative_to(ROOT)}: {len(verses)} verses, {len(sacred)} sacred days")


if __name__ == "__main__":
    main()
```

**Step 2: Author `batches/sacred_days.json`**

Nineteen entries from the Task 1 table. Trilingual. `occasion*` is the notification title, `theme*` is the subtitle. Plain English spelling.

```json
{
  "sacredDays": [
    {
      "month": 1, "day": 10,
      "surah": 3, "verse": 169,
      "occasionEn": "Ashura", "occasionUr": "عاشورا", "occasionAr": "عاشوراء",
      "themeEn": "The martyrs are alive",
      "themeUr": "شہدا زندہ ہیں",
      "themeAr": "الشهداء أحياء"
    },
    {
      "month": 12, "day": 18,
      "surah": 5, "verse": 67,
      "occasionEn": "Ghadeer", "occasionUr": "غدیر", "occasionAr": "الغدير",
      "themeEn": "Convey what has been revealed",
      "themeUr": "جو نازل ہوا اسے پہنچا دیں",
      "themeAr": "بلغ ما أنزل إليك"
    }
  ]
}
```

Fill in the remaining seventeen from the Task 1 table in the same shape.

**Step 3: Assemble and validate**

```bash
python3 scripts/daily_verses/assemble.py
python3 scripts/daily_verses/validate.py
```

Expected: `FAIL`, reporting `expected 365 verses, found 0`, and **no** sacred-day errors. If a sacred-day ref fails to resolve, fix it now.

**Checkpoint.**

---

## Task 4: Author the 365 verses

**Files:**
- Create: `scripts/daily_verses/batches/batch_01.json` .. `batch_10.json`

**Step 1: Assign theme quotas**

Ten batches. Each batch is handed a quota so the finished pool is balanced without any single author seeing the whole thing. Eighteen themes over 365 entries is roughly 20 each; give each batch two themes at ~18-19 verses apiece, and a final batch that tops up to exactly 365.

Track the running total. `assemble.py` assigns ids, so authors must **not** write an `id` field.

**Step 2: Author, in waves of at most two subagents**

Never more than two at a time. Each subagent gets one batch, its theme quota, and this brief:

> Author N daily-verse references for the Thaqalayn iOS app. Return JSON: `{"verses": [{"surah": int, "verse": int, "themeKey": str, "themeEn": str, "themeUr": str, "themeAr": str}]}`. No `id` field.
>
> **Curation bar.** The verse must read standalone, with no surrounding context. It must not be a mid-sentence fragment. It must not be a ritual or legal technicality. It must not be a verse of punishment or threat lifted out of its setting. It should be something a person would want to wake up to.
>
> **Constraints.** Every ref must exist and have both an English and an Urdu translation in `Thaqalayn/Thaqalayn/Data/quran_data.json` - check before you commit to a ref. Use only the assigned `themeKey`s. `themeEn` is a short human label for the theme as it applies to *this* verse (for example `"Hardship and ease"`), not a restatement of the key.
>
> **English style.** Plain spelling, no transliteration diacritics: write `Qur'an`, not `Qurʾān`. No em dashes.
>
> **Do not reuse** any ref in the sacred-day table (`scripts/daily_verses/batches/sacred_days.json`); the validator rejects overlap.

**Step 3: Assemble and validate after each wave**

```bash
python3 scripts/daily_verses/assemble.py
python3 scripts/daily_verses/validate.py
```

Fix what it reports before starting the next wave. Duplicate refs across batches are the common failure; the validator catches them.

**Step 4: Final validation**

```bash
python3 scripts/daily_verses/validate.py
```

Expected:

```
OK: 365 verses, 18 themes, 19 sacred days
    theme spread: min 18, max 22
```

**Checkpoint.** This is the biggest content artefact in the feature. Let the user review a sample before moving to Swift.

---

## Task 5: Models

**Files:**
- Modify: `Thaqalayn/Models/QuranModels.swift` (delete lines 664-707, add the new models)

**Step 1: Delete the old models**

Remove `IslamicMonthVerseData`, `IslamicMonth` and the old `DailyVerseEntry` (`QuranModels.swift:664-707`). Keep `NotificationPreferences` - it is in the same block and is still used.

The new `DailyVerseEntry` **reuses the same type name** with different fields, so the old one has to go in this task or the build breaks on a redeclaration.

**Step 2: Add the new models**

```swift
// MARK: - Daily Verse

/// The whole pool, decoded from daily_verses.json.
struct DailyVersePool: Codable {
    let version: Int
    let themes: [String]
    let verses: [DailyVerseEntry]
    let sacredDays: [SacredDay]
}

/// One curated reference. Carries no verse text - Arabic, translations and
/// tafsir all hydrate from quran_data.json at read time.
struct DailyVerseEntry: Codable, Identifiable {
    let id: Int
    let surah: Int
    let verse: Int
    /// Vocabulary key. Drives the no-two-days-running spacing rule.
    let themeKey: String
    let themeEn: String
    let themeUr: String
    let themeAr: String
}

/// A Hijri date that overrides the pool.
struct SacredDay: Codable {
    let month: Int   // Hijri month, 1-12
    let day: Int     // Hijri day, 1-30
    let surah: Int
    let verse: Int
    let occasionEn: String, occasionUr: String, occasionAr: String
    let themeEn: String, themeUr: String, themeAr: String
}

/// What a surface renders. `occasion` is non-nil only on a sacred day.
struct DailyVerseSelection: Equatable {
    let surah: Int
    let verse: Int
    let themeEn: String, themeUr: String, themeAr: String
    let occasionEn: String?, occasionUr: String?, occasionAr: String?

    var id: String { "\(surah):\(verse)" }

    func theme(_ language: CommentaryLanguage) -> String {
        switch language {
        case .arabic: return themeAr
        case .urdu:   return themeUr
        default:      return themeEn
        }
    }

    /// nil on an ordinary day.
    func occasion(_ language: CommentaryLanguage) -> String? {
        switch language {
        case .arabic: return occasionAr
        case .urdu:   return occasionUr
        default:      return occasionEn
        }
    }

    init(entry: DailyVerseEntry) {
        surah = entry.surah; verse = entry.verse
        themeEn = entry.themeEn; themeUr = entry.themeUr; themeAr = entry.themeAr
        occasionEn = nil; occasionUr = nil; occasionAr = nil
    }

    init(sacred: SacredDay) {
        surah = sacred.surah; verse = sacred.verse
        themeEn = sacred.themeEn; themeUr = sacred.themeUr; themeAr = sacred.themeAr
        occasionEn = sacred.occasionEn; occasionUr = sacred.occasionUr; occasionAr = sacred.occasionAr
    }
}
```

**Step 3: Build**

The build **will fail** here - `NotificationManager`, `SettingsView` and `DailyVerseScreen` still reference the deleted types. That is expected. Tasks 6 through 11 repair them. Do not try to make this task build green on its own; note the failures and move on.

---

## Task 6: `DailyVerseProvider`

**Files:**
- Create: `Thaqalayn/Services/DailyVerseProvider.swift`

**Step 1: Write the provider**

```swift
//
//  DailyVerseProvider.swift
//  Thaqalayn
//
//  Single source of truth for "today's verse". Feeds both the daily-verse push
//  and the Today-tab card, so the two can never disagree.
//
//  Selection is a pure function of the date:
//    1. If the date's Hijri (month, day) matches a sacred day, that verse wins.
//    2. Otherwise the pool is permuted once per 365-day cycle with a seeded
//       shuffle, then repaired so no two adjacent days share a theme, and the
//       day's position in the cycle indexes into it.
//
//  Statelessness is the point. It survives reinstall, it lets the notification
//  scheduler ask "what is the verse 27 days from now", and it keeps the push and
//  the card in sync without any shared mutable state.
//

import Foundation
import Combine

@MainActor
final class DailyVerseProvider: ObservableObject {
    static let shared = DailyVerseProvider()

    @Published private(set) var today: DailyVerseSelection

    private let pool: [DailyVerseEntry]
    private let sacredDays: [SacredDay]

    /// Permuting 365 entries is microseconds, but we do it up to 30 times per
    /// foreground while scheduling, so cache the current cycle's order.
    private var cachedCycle: Int?
    private var cachedOrder: [Int] = []

    /// Fixed forever. Moving it reshuffles every user's year.
    private static let epoch: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    }()

    private init() {
        guard let url = Bundle.main.url(forResource: "daily_verses", withExtension: "json") else {
            fatalError("daily_verses.json missing from bundle")
        }
        let decoded: DailyVersePool
        do {
            decoded = try JSONDecoder().decode(DailyVersePool.self, from: Data(contentsOf: url))
        } catch {
            fatalError("Failed to parse daily_verses.json: \(error)")
        }
        guard !decoded.verses.isEmpty else {
            fatalError("daily_verses.json must contain at least one verse")
        }
        self.pool = decoded.verses
        self.sacredDays = decoded.sacredDays
        self.today = DailyVerseSelection(entry: decoded.verses[0])   // replaced immediately
        self.today = verse(for: IslamicCalendarManager.shared.now)
    }

    // MARK: - Public

    /// The verse for any date. Pure - no state written, no side effects.
    func verse(for date: Date) -> DailyVerseSelection {
        if let sacred = sacredDay(for: date) {
            return DailyVerseSelection(sacred: sacred)
        }
        return DailyVerseSelection(entry: pooledEntry(for: date))
    }

    /// Called when the app becomes active across a date boundary.
    func refreshIfDayChanged() {
        let resolved = verse(for: IslamicCalendarManager.shared.now)
        if resolved != today { today = resolved }
    }

    // MARK: - Sacred days

    private func sacredDay(for date: Date) -> SacredDay? {
        let hijri = IslamicCalendarManager.shared.islamicCalendar
            .dateComponents([.month, .day], from: date)
        guard let month = hijri.month, let day = hijri.day else { return nil }
        return sacredDays.first { $0.month == month && $0.day == day }
    }

    // MARK: - The permutation

    private func pooledEntry(for date: Date) -> DailyVerseEntry {
        let n = pool.count
        let index = dayIndex(for: date)
        let order = permutation(cycle: index / n)
        return pool[order[index % n]]
    }

    /// Whole days from the epoch, in the user's own timezone. A timezone move can
    /// shift a user by a day; that is harmless and self-corrects.
    private func dayIndex(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let start = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: Self.epoch, to: start).day ?? 0
        return max(0, days)
    }

    private func permutation(cycle: Int) -> [Int] {
        if cachedCycle == cycle { return cachedOrder }

        var order = Array(0..<pool.count)
        var rng = SplitMix64(seed: UInt64(bitPattern: Int64(cycle)) &+ 0x9E37_79B9_7F4A_7C15)
        var i = order.count - 1
        while i > 0 {
            let j = Int(rng.next() % UInt64(i + 1))
            order.swapAt(i, j)
            i -= 1
        }
        spaceThemes(&order)

        cachedCycle = cycle
        cachedOrder = order
        return order
    }

    private func themeKey(_ index: Int) -> String { pool[index].themeKey }

    /// Break up adjacent same-theme pairs in place. For each collision, swap the
    /// offender with the nearest later entry that fits between its new neighbours.
    /// Scanning forward means a displaced entry gets re-checked when we reach it,
    /// so a single pass converges. With 18 themes over 365 entries collisions are
    /// rare and a candidate always exists; validate.py caps theme dominance to
    /// keep it that way, and the DEBUG harness in DailyVerseDebug asserts it.
    private func spaceThemes(_ order: inout [Int]) {
        guard order.count > 1 else { return }
        var i = 1
        while i < order.count {
            guard themeKey(order[i]) == themeKey(order[i - 1]) else { i += 1; continue }

            var j = i + 1
            var repaired = false
            while j < order.count {
                let candidate = themeKey(order[j])
                let fitsBefore = candidate != themeKey(order[i - 1])
                let fitsAfter = (i + 1 >= order.count) || candidate != themeKey(order[i + 1])
                if fitsBefore && fitsAfter {
                    order.swapAt(i, j)
                    repaired = true
                    break
                }
                j += 1
            }
            if !repaired { break }   // pool too theme-skewed; the validator prevents this
            i += 1
        }
    }
}

/// Deterministic, portable PRNG. Seeding by cycle makes the year's order identical
/// on every device and across reinstalls, and different every year. Swift's own
/// RandomNumberGenerator gives no such cross-version stability guarantee.
private struct SplitMix64 {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
```

**Step 2: Confirm the `IslamicCalendarManager` surface**

The provider leans on `IslamicCalendarManager.shared.islamicCalendar` (a `Calendar`) and `.now`. Both exist (`IslamicCalendarManager.swift:24`, `:35`). If `islamicCalendar` is not accessible, make it so - `NotificationManager.selectVerseForDay` already uses it the same way.

---

## Task 7: The verification harness

This is where the guarantees are proven. There is no test target, so the harness is DEBUG-only code that the app can run and that is trivially removable.

**Files:**
- Create: `Thaqalayn/Services/DailyVerseDebug.swift`

**Step 1: Write the harness**

```swift
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

        // --- 1. No verse repeats within a 365-day cycle (ignoring sacred days,
        //        which deliberately recur once a year and are not drawn from the pool).
        var refs: [String] = []
        for offset in 0..<365 {
            let selection = provider.verse(for: day(offset))
            if selection.occasion(.english) == nil { refs.append(selection.id) }
        }
        let unique = Set(refs)
        check("no verse repeats in 365 days",
              unique.count == refs.count,
              "\(refs.count - unique.count) duplicate(s)")

        // --- 2. No two consecutive days share a theme.
        var adjacentCollisions = 0
        for offset in 1..<730 {
            let a = provider.verse(for: day(offset - 1))
            let b = provider.verse(for: day(offset))
            if a.theme(.english) == b.theme(.english) { adjacentCollisions += 1 }
        }
        check("no two consecutive days share a theme (730 days)",
              adjacentCollisions == 0,
              "\(adjacentCollisions) collision(s)")

        // --- 3. Determinism: the same date always yields the same verse.
        let probe = day(97)
        check("selection is deterministic",
              provider.verse(for: probe) == provider.verse(for: probe))

        // --- 4. Year 2 is not a replay of year 1.
        let y1 = (0..<365).map { provider.verse(for: day($0)).id }
        let y2 = (365..<730).map { provider.verse(for: day($0)).id }
        check("year 2 is a different order from year 1", y1 != y2)

        // --- 5. Sacred days win, and their titles are populated.
        //        10 Muharram, wherever it falls in the next two years.
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

        // --- 6. Every selection hydrates. A ref that does not resolve is a silent
        //        blank notification, which is the worst failure mode here.
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

        // --- 7. Urdu is actually present, since the push now promises it.
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
```

**Step 2: Build**

```bash
xcodebuild -scheme Thaqalayn -destination 'id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -5
```

Still failing on the old call sites. Expected. Tasks 8-11 fix them.

---

## Task 8: `NotificationManager` - selection and the 30-day window

**Files:**
- Modify: `Thaqalayn/Services/NotificationManager.swift`

**Step 1: Delete the old selection machinery**

Remove `verseData`, `loadVerseData()` (`:56-70`), `selectTodayVerse()` (`:111-130`), `currentMonthData()` (`:133-137`), `selectVerseForDay(dayOffset:)` (`:307-325`), and the dead `sendTestNotification()` (`:336-354`, zero call sites).

**Step 2: Replace the scheduling window**

```swift
    /// iOS caps an app at 64 pending notification requests, and that budget is
    /// shared with streak_reminder, gentle_nudge, milestone_*, near_completion_*,
    /// arafah_reminder and journey_start_*. Thirty days of verses leaves headroom
    /// while still covering a user who does not open the app for a month - which
    /// is exactly the user this notification exists for. Raise this and iOS will
    /// silently start dropping requests.
    private static let scheduleWindowDays = 30
    private static let dailyVersePrefix = "daily_verse_"

    private static let dayKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func identifier(for date: Date) -> String {
        dailyVersePrefix + dayKeyFormatter.string(from: date)
    }

    /// (Re)schedule the rolling daily-verse window.
    ///
    /// Cancel-all-then-re-add, rather than an incremental diff: the content is baked
    /// in at schedule time, so a change to time / language / includeTafsir has to
    /// rewrite every pending request anyway. Thirty rebuilds on a foreground is
    /// cheap (the pool is in memory and getVerse is an in-memory lookup).
    private func scheduleDailyVerseNotifications() async {
        await cancelDailyVerseNotifications()

        var calendar = Calendar.current
        calendar.timeZone = .current
        let today = calendar.startOfDay(for: Date())

        for offset in 0..<Self.scheduleWindowDays {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            await scheduleNotification(on: date)
        }
    }

    /// Removes every pending daily-verse request, whatever its date key.
    func cancelDailyVerseNotifications() async {
        let pending = await notificationCenter.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(Self.dailyVersePrefix) }
        guard !ids.isEmpty else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func scheduleNotification(on date: Date) async {
        var calendar = Calendar.current
        calendar.timeZone = .current

        let time = calendar.dateComponents([.hour, .minute], from: preferences.time)
        var target = calendar.dateComponents([.year, .month, .day], from: date)
        target.hour = time.hour
        target.minute = time.minute

        // Today's slot may already have passed.
        guard let fireDate = calendar.date(from: target), fireDate > Date() else { return }

        let selection = await MainActor.run { DailyVerseProvider.shared.verse(for: date) }
        guard let content = await buildNotificationContent(for: selection) else { return }

        let trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier(for: date),
                                            content: content,
                                            trigger: trigger)
        do {
            try await notificationCenter.add(request)
        } catch {
            print("❌ NotificationManager: failed to schedule \(Self.identifier(for: date)) - \(error)")
        }
    }
```

**Step 3: Fix the `cancelDailyVerseNotifications()` call sites**

It is now `async`. `performRefresh()` (`:229-245`) already runs in an async context, so `await` it there. Check for any other caller.

---

## Task 9: `NotificationManager` - trilingual content

**Files:**
- Modify: `Thaqalayn/Services/NotificationManager.swift` (replace `buildNotificationContent`, `:142-201`)

**Step 1: Replace the content builder**

```swift
    private func buildNotificationContent(for selection: DailyVerseSelection) async -> UNMutableNotificationContent? {
        let language = preferences.language

        let verse = await MainActor.run {
            DataManager.shared.getVerse(surah: selection.surah, verse: selection.verse)
        }
        guard let verse else {
            print("❌ NotificationManager: could not hydrate \(selection.id)")
            return nil
        }

        let content = UNMutableNotificationContent()

        // On a sacred day the occasion replaces the generic title.
        content.title = selection.occasion(language) ?? Self.verseOfTheDayTitle(language)
        // The theme lives in the subtitle so the body is nothing but the verse.
        content.subtitle = selection.theme(language)

        var body = verse.arabicText
        if let translation = Self.translation(from: verse, for: language), !translation.isEmpty {
            body += "\n\n" + translation
        }
        if preferences.includeTafsir, let tafsir = verse.tafsir {
            let text = tafsir.content(for: TafsirLayer.foundation, language: language)
            if !text.isEmpty {
                body += "\n\n💡 " + String(text.prefix(150)) + "..."
            }
        }
        content.body = body

        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "DAILY_VERSE"
        content.userInfo = [
            "surah": selection.surah,
            "verse": selection.verse,
            "type": "daily_verse"
        ]
        return content
    }

    private static func verseOfTheDayTitle(_ language: CommentaryLanguage) -> String {
        switch language {
        case .arabic: return "آية اليوم"
        case .urdu:   return "آیتِ روز"
        default:      return "Verse of the Day"
        }
    }

    /// An Arabic reader already has the verse itself in the body, so we do not
    /// repeat it as a "translation". Urdu falls back to English if the Urdu
    /// translation is missing, though validate.py should make that unreachable.
    private static func translation(from verse: VerseWithTafsir,
                                    for language: CommentaryLanguage) -> String? {
        switch language {
        case .arabic: return nil
        case .urdu:   return verse.translationUrdu ?? verse.translation
        default:      return verse.translation
        }
    }
```

The hardcoded `"\n\n📚 Tap to explore the 5-layer tafsir"` is **deleted**. iOS shows roughly four lines on the lock screen; that CTA was spending one of them restating the tap gesture.

**Step 2: Build**

```bash
xcodebuild -scheme Thaqalayn -destination 'id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -5
```

`NotificationManager` should now be clean. `SettingsView`, `DailyVerseScreen` and `TodayView` will still fail.

---

## Task 10: `SettingsView`

**Files:**
- Modify: `Thaqalayn/Views/SettingsView.swift` (`:279-298`, `:701-709`, `:933-935`)

**Step 1: Repoint the two previews**

Both preview blocks call `notificationManager.selectTodayVerse()` + `.currentMonthData()`. Replace with:

```swift
    let selection = DailyVerseProvider.shared.today
    // ... render selection.theme(languageManager.selectedLanguage)
    // On a sacred day, selection.occasion(...) is non-nil - show it as the header.
```

`verse.theme` was a plain `String`; it is now `selection.theme(_:)`. The verse reference and Arabic still come from `DataManager.getVerse`.

**Step 2: Collapse the duplicate section**

`SettingsView` carries a near-duplicate daily-verse section at roughly `:220-280` and `:640-728` (the second is `emeraldDailyVerseSection`). Collapse the shared body into one helper rather than fixing the same code twice.

**Step 3: Replace the language toggle with a picker**

`:933-935` today:

```swift
    private func toggleNotificationLanguage() {
        notificationManager.preferences.language =
            notificationManager.preferences.language == .english ? .urdu : .english
    }
```

Arabic is unreachable through this. Replace with a picker over `CommentaryLanguage.supportedTafsirLanguages` (`.english, .urdu, .arabic`; French has no tafsir content and is correctly excluded). Match the styling of the other Settings controls in both themes.

---

## Task 11: `DailyVerseScreen` and `TodayView`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift:49-95`
- Modify: `Thaqalayn/Views/TodayView.swift:65, 115, 129, 157-160, 210-230, 353, 728`
- Delete: `Thaqalayn/Services/DailyMessageProvider.swift`

**Step 1: `DailyVerseScreen`**

Swap `notificationManager.selectTodayVerse()` / `currentMonthData()` for `DailyVerseProvider.shared.today`. `todayVerse.theme` (`:95`) becomes `selection.theme(languageManager.selectedLanguage)`.

**Step 2: `TodayView`**

Swap `DailyMessageProvider.shared` for `DailyVerseProvider.shared` (`:65`, `:728`). `refreshIfDayChanged()` exists on the new provider with the same signature, so `:115` and `:129` are unchanged.

The card at `:353` takes `message: DailyMessage`. It now takes `selection: DailyVerseSelection`. Two consequences:

- **The English fallback at `:210-214` goes away.** The old pool inlined its own `english`, so the card fell back to it when `getVerse` missed. The new pool has no inlined text. `validate.py` guarantees every ref resolves, so hydrate from `DataManager` and log if it ever misses:

```swift
    guard let verse = dataManager.getVerse(surah: selection.surah, verse: selection.verse) else {
        print("⚠️ TodayView: daily verse \(selection.id) did not hydrate")
        return nil
    }
```

- **The card gains Urdu.** `verse.translationUrdu` is now available where the old `DailyMessage` had nothing. Render it for Urdu readers.

**Step 3: Honour the reading text-size control**

Per `CLAUDE.md`, the card's **verse Arabic and translation are reading content** and must scale with `ReadingSettingsManager.shared`. Check what the existing card does and preserve it; if it does not scale, add it:

```swift
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    // ...
    .font(EmType.serif(17 * readingSettings.scale, .medium))
    .lineSpacing(5 * readingSettings.scale)
```

The theme label, the verse reference and any caption stay **fixed** - the control's scope is body reading content, not chrome.

**Step 4: Delete `DailyMessageProvider.swift`**

**Step 5: Build**

```bash
xcodebuild -scheme Thaqalayn -destination 'id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`. This is the first green build since Task 5.

**Checkpoint.** The feature now compiles end to end.

---

## Task 12: Run the verification harness

**Step 1: Wire a temporary debug trigger**

Call `DailyVerseDebug.runAll()` from a DEBUG-only entry point - a `.task {}` on `ContentView` guarded by `#if DEBUG`, or a hidden button in Settings.

**Step 2: Run the app once and read the console**

Expected:

```
=== DailyVerseProvider verification ===
  PASS  no verse repeats in 365 days
  PASS  no two consecutive days share a theme (730 days)
  PASS  selection is deterministic
  PASS  year 2 is a different order from year 1
  PASS  10 Muharram overrides the pool
  PASS  10 Muharram serves 3:169
  PASS  10 Muharram occurs within the next 2 years
  PASS  every ref hydrates from quran_data.json
  PASS  every ref has an Urdu translation
=== 9 passed, 0 failed ===
```

**Any failure here is a real bug, not a flaky test.** In particular:

- *"no two consecutive days share a theme"* failing means `spaceThemes` hit its `break` - the pool is too theme-skewed. Rebalance the content; do not loosen the check.
- *"every ref has an Urdu translation"* failing means `validate.py` and the app disagree about `quran_data.json`. The app is right; fix the validator.

**Step 3: Remove the temporary trigger.** Leave `DailyVerseDebug.swift` in place - it is DEBUG-only and is the only regression check this feature has.

**Checkpoint.** Hand the build to the user for simulator verification. Do **not** run `simctl` yourself.

---

## Task 13: Delete the retired files

Only after Task 12 is green.

**Files:**
- Delete: `Thaqalayn/Thaqalayn/Data/islamic_month_verses.json`
- Delete: `Thaqalayn/Data/daily_messages.json`
- Confirm deleted: `Thaqalayn/Services/DailyMessageProvider.swift` (Task 11)
- Confirm deleted: `IslamicMonthVerseData`, `IslamicMonth`, old `DailyVerseEntry` (Task 5)
- Confirm deleted: `sendTestNotification()` (Task 8)

**Step 1: Prove nothing still references them**

```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
grep -rn "islamic_month_verses\|daily_messages\|DailyMessageProvider\|DailyMessage\b\|IslamicMonthVerseData\|selectTodayVerse\|currentMonthData\|sendTestNotification" \
  --include="*.swift" Thaqalayn/
```

Expected: no output.

**Step 2: Delete, then build**

```bash
rm Thaqalayn/Thaqalayn/Data/islamic_month_verses.json Thaqalayn/Data/daily_messages.json
xcodebuild -scheme Thaqalayn -destination 'id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`. These are synced folders, so no `pbxproj` edit is needed.

**Checkpoint.**

---

## Task 14: Announce it in What's New

`CLAUDE.md` requires every user-facing feature to surface on the Today tab spotlight.

**Files:**
- Modify: `Thaqalayn/Models/WhatsNewItem.swift`
- Modify: `Thaqalayn/Views/WhatsNewCard.swift:35-52`
- Modify: `Thaqalayn/Views/TodayView.swift`

**Step 1: Add a destination case**

`WhatsNewDestination` only has `.deepDive` and `.surahExperience`; neither can reach notification settings. Add:

```swift
    /// Open the Settings sheet, where the daily verse is configured.
    case settings
```

**Step 2: Handle it in `WhatsNewCard.open()`**

`SettingsView` is already presented as a sheet from `TodayView:121`, so this needs a closure, not a router change. Add an `onOpenSettings: () -> Void` parameter to `WhatsNewCard`, and in `open()`:

```swift
        case .settings:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { onOpenSettings() }
```

`TodayView` passes `{ showingSettings = true }`, matching the 0.12s acknowledge-then-navigate convention the other cases use.

**Step 3: Add the announcement**

Trilingual, plain spelling, no em dash.

```swift
        WhatsNewItem(
            id: "dailyVerse-365",
            sfSymbol: "sparkles",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 14).date ?? .distantPast,
            destination: .settings,
            titleEN: "A new verse every day, all year",
            titleUR: "ہر دن ایک نئی آیت، سارا سال",
            titleAR: "آية جديدة كل يوم، طوال العام",
            blurbEN: "The daily verse now draws from 365 hand-picked ayat, so you will not see the same one twice in a year. Sacred days still bring their own verse.",
            blurbUR: "...",
            blurbAR: "...",
            ctaEN: "Set your time",
            ctaUR: "...",
            ctaAR: "..."
        ),
```

**Step 4: Build**

```bash
xcodebuild -scheme Thaqalayn -destination 'id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`.

**Checkpoint. Feature complete.** Hand to the user for simulator verification.

---

## What is deliberately not here

- **No XCTest target.** Task 7's DEBUG harness is the substitute, by house rule.
- **No CloudKit schema deploy.** Nothing in this feature is synced; the pool ships in the bundle and selection is stateless.
- **No migration.** There is no persisted state encoding the old selection, so users simply start receiving the new pool on update.
- **No de-duplication against `daily_challenges.json` / `daily_crosswords.json`.** Explicitly ruled out in the design.
- **No Muharram 1-10 arc.** Considered and deferred; the Muharram journey already covers that ground.
