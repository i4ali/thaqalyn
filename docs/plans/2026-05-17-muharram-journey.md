# Muharram Journey Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship a seasonal "Muharram Journey" feature — a 10-day reflective journey through the themes/values of Karbala culminating on Ashura — as a somber-toned sibling of the existing Dhul-Hijjah (Hajj) Journey.

**Architecture:** Parallel duplication of the Hajj Journey feature (commit 3147740) with tonal adaptations. New `Muharram*` data model, season-detection API, manager, two views, plus tab/premium/onboarding/progress-ring wiring. No notification, no badge, no celebration, no `ProgressManager` involvement.

**Tech Stack:** SwiftUI, iOS, `@MainActor` singletons, `UserDefaults` (JSON-encoded persistence), bundled JSON resource, Xcode synced folder groups (drop files into folders — no `.pbxproj` edits needed).

**Source of truth for design:** `docs/plans/2026-05-17-muharram-journey-design.md`

---

## Conventions for this plan (read first)

**No XCTest target exists in this iOS project.** Ramadan and Hajj shipped without unit tests; the approved design scoped verification as: (1) Phase 0 content-review gate, (2) `xcodebuild` compile success, (3) manual season-window check via a *temporary, reverted* Hijri date override, (4) manual tone/premium pass. Each task below therefore uses **Build-verify + Manual-verify** instead of a TDD red/green loop. This is a deliberate, approved deviation — do not scaffold a test target.

**No auto-commit.** The project owner commits. Every "Checkpoint" lists a *suggested* commit the owner may run — do not run `git commit` yourself.

**Mirror, don't transcribe.** For large view/manager files, the executor must `Read` the named Hajj sibling file in full and create the Muharram file by mirroring its structure, applying only the explicitly listed deltas. This is DRY and avoids drift from stale transcriptions.

**No fallback logic** (CLAUDE.md): JSON-load failure must throw/surface a clear error, never silently degrade.

**Build command** (confirm scheme first with `xcodebuild -list -project Thaqalayn.xcodeproj`):

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build 2>&1 | tail -30
```
Expected on success: `** BUILD SUCCEEDED **`.

**Temporary date-override technique** (for season-window manual checks): in `IslamicCalendarManager.currentIslamicDate()`, temporarily hardcode the returned `month`/`day`/`year` to the value under test, build to simulator, observe the tab/header, then **revert the override** before the task's Checkpoint. The override must never be committed.

---

## PHASE 0 — Content draft + owner review gate (NO CODE)

> Hard gate. No Swift file in Phases 1–3 may be created or edited until the owner signs off on Phase 0 output.

### Task 0.1: Research & draft the 10-day content

**Files:**
- Create: `Thaqalayn/Data/muharram_journey.json`
- Create: `docs/plans/2026-05-17-muharram-journey-content-review.md` (human-readable review doc)

**Step 1: Confirm the JSON schema from the Hajj sibling**

Run: `Read Thaqalayn/Data/hajj_journey.json` (study structure) and `Read Thaqalayn/Models/QuranModels.swift` around the Hajj model block (search `HajjJourneyData`).

The Muharram JSON must decode into the Phase 1 models. Required shape:

```json
{
  "days": [
    {
      "id": "day1",
      "dayNumber": 1,
      "theme": "Awakening to the Cause of Husayn (AS)",
      "themeArabic": "…",
      "icon": "<SF Symbol name>",
      "dua": {
        "arabic": "…",
        "transliteration": "…",
        "english": "…",
        "source": "Mafatih al-Jinan, …"
      },
      "verses": [
        { "id": "d1v1", "surahNumber": 2, "verseNumber": 156, "relevanceNote": "…" }
      ],
      "tafsirFocus": "…",
      "reflection": "…"
    }
  ]
}
```

**Step 2: Draft all 10 days** following the approved arc (design doc §"The 10-theme content arc"):

1. Intention & awakening to Husayn's (AS) cause
2. Truth over comfort — refusal of bay'ah to Yazid
3. Migration for principle (Medina → Mecca → Iraq)
4. Loyalty & true companionship (the Ansar of Husayn)
5. Patience (sabr) under trial — the water cut off
6. Dignity over humiliation ("hayhāt minna-dh-dhilla")
7. Sacrifice — the offering of sons and brothers
8. Steadfastness of the women — Sayyida Zaynab (AS)
9. The night of Ashura — worship and resolve (Layla Ashura)
10. **Ashura** — the supreme sacrifice and its eternal message

Rules for content:
- **Authentic Shia sources only.** Duas/ziyarat from **Mafatih al-Jinan** (incl. Ziyarat Ashura / Ziyarat Warith where fitting). Narrative grounded in reliable maqtal (al-Lohoof of Sayyid ibn Tawus / Nafasul Mahmoom). Quranic verses must be **real references** that genuinely connect to the theme; `relevanceNote` explains the connection.
- 2–3 verses per day. Arabic must be correct and complete; provide transliteration + English.
- `tafsirFocus`: 3–5 sentences tying the day's theme to the tafsir/Quranic lens.
- `reflection`: a short introspective azadari prompt (mournful, not celebratory).
- Tone: somber throughout. Day 10 = Ashura, the emotional summit. No "Mubarak"/celebratory language anywhere.
- Use `WebSearch` to verify dua wording, verse numbers, and maqtal facts. Do not invent sources.

**Step 3: Write the review doc** `docs/plans/2026-05-17-muharram-journey-content-review.md`: for each day, render theme (EN + AR), the dua (AR/translit/EN) **with its exact source citation**, each verse reference + relevance note, tafsirFocus, reflection. This is what the owner reads to approve.

**Step 4: Build-verify the JSON parses**

Run:
```bash
python3 -c "import json,sys; d=json.load(open('Thaqalayn/Data/muharram_journey.json')); assert len(d['days'])==10, len(d['days']); [print(x['dayNumber'], x['id'], x['theme']) for x in d['days']]"
```
Expected: prints 10 lines (dayNumber 1..10), no assertion/JSON error.

**Step 5: Checkpoint — OWNER REVIEW GATE**

Present `docs/plans/2026-05-17-muharram-journey-content-review.md` to the owner. **Stop. Do not proceed to Phase 1 until the owner explicitly approves or supplies corrections.** Apply any corrections to the JSON and review doc, re-run Step 4, re-present.

Suggested owner commit after sign-off:
```bash
git add Thaqalayn/Data/muharram_journey.json docs/plans/2026-05-17-muharram-journey-content-review.md
git commit -m "content: Muharram Journey 10-day content (reviewed)"
```

---

## PHASE 1 — Data layer (no UI)

### Task 1.1: Muharram models

**Files:**
- Modify: `Thaqalayn/Models/QuranModels.swift` (append after the Hajj models block; find `struct HajjJourneyProgress`)

**Step 1: Read the Hajj models** — `Read` the `// MARK: - Hajj Journey Models` block in `Thaqalayn/Models/QuranModels.swift` to match conventions exactly.

**Step 2: Append the Muharram models**

```swift
// MARK: - Muharram Journey Models

struct MuharramJourneyData: Codable {
    let days: [MuharramDay]
}

struct MuharramDay: Codable, Identifiable {
    let id: String
    let dayNumber: Int
    let theme: String
    let themeArabic: String
    let icon: String
    let dua: MuharramDua
    let verses: [MuharramVerse]
    let tafsirFocus: String
    let reflection: String
}

struct MuharramDua: Codable {
    let arabic: String
    let transliteration: String
    let english: String
    let source: String?
}

struct MuharramVerse: Codable, Identifiable {
    let id: String
    let surahNumber: Int
    let verseNumber: Int
    let relevanceNote: String

    var verseReference: String {
        "Quran \(surahNumber):\(verseNumber)"
    }
}

struct MuharramJourneyProgress: Codable {
    var observedDays: Set<Int>
    var lastObservedDate: Date?
    var year: Int

    init(
        observedDays: Set<Int> = [],
        lastObservedDate: Date? = nil,
        year: Int = 0
    ) {
        self.observedDays = observedDays
        self.lastObservedDate = lastObservedDate
        self.year = year
    }

    var completionPercentage: Double {
        Double(observedDays.count) / 10.0
    }
}
```
> Note vs Hajj: `observedDays`/`lastObservedDate` naming; **no `isCompleted`** property (no badge path).

**Step 3: Build-verify** — run the build command. Expected: `** BUILD SUCCEEDED **`.

**Step 4: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Models/QuranModels.swift
git commit -m "feat(muharram): add Muharram Journey data models"
```

### Task 1.2: Muharram season-detection API

**Files:**
- Modify: `Thaqalayn/Services/IslamicCalendarManager.swift` (add after the `// MARK: - Hajj Season Detection` block)

**Step 1: Read** the Hajj season block (`isHajjSeason`, `currentHajjDay`, `daysUntilHajj`, `hajjSeasonStatus`) to match style.

**Step 2: Add the Muharram API**

```swift
// MARK: - Muharram Season Detection

/// Muharram Journey window:
/// - Last days of Dhul-Hijjah (month 12, day >= 25) as a lead-in countdown
/// - Muharram (month 1) days 1-10 content + days 11-12 quiet grace (no new content)
/// Hajj season is month 12 day <= 13; Ramadan is months 8-10 — all mutually exclusive.
func isMuharramSeason() -> Bool {
    let month = currentIslamicMonth()
    let day = currentIslamicDay()

    switch month {
    case 12: // Dhul-Hijjah lead-in (does not collide with Hajj's day <= 13)
        return day >= 25
    case 1:  // Muharram: 10 content days + 11-12 quiet grace
        return day <= 12
    default:
        return false
    }
}

/// Current Muharram Journey day (1-10), nil during lead-in and the 11-12 grace.
func currentMuharramDay() -> Int? {
    guard currentIslamicMonth() == 1 else { return nil }
    let day = currentIslamicDay()
    return (1...10).contains(day) ? day : nil
}

/// Days until Muharram (only meaningful during late Dhul-Hijjah).
func daysUntilMuharram() -> Int? {
    guard currentIslamicMonth() == 12 else { return nil }
    let day = currentIslamicDay()
    return max(0, 30 - day + 1)
}

/// Somber status line for the Muharram Journey header.
func muharramSeasonStatus() -> String {
    let month = currentIslamicMonth()
    let day = currentIslamicDay()

    switch month {
    case 12:
        if let daysUntil = daysUntilMuharram(), daysUntil > 0 {
            return "\(daysUntil) day\(daysUntil == 1 ? "" : "s") until Muharram"
        }
        return "Muharram begins soon"
    case 1:
        if day == 10 {
            return "Ashura — Ya Husayn (AS)"
        }
        if day <= 10 {
            return "Day \(day) of Muharram"
        }
        if day <= 12 {
            return "The mourning continues — Ya Husayn (AS)"
        }
        return ""
    default:
        return ""
    }
}
```

**Step 3: Build-verify** — build command → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify season boundaries** — using the temporary date-override technique, set `currentIslamicDate()` to each pair and confirm `isMuharramSeason()` behavior by adding a temporary `print(isMuharramSeason(), currentMuharramDay() as Any, muharramSeasonStatus())` at app launch (or check via the tab in later phases). Verify:

| Override (month, day) | isMuharramSeason | currentMuharramDay | Notes |
|---|---|---|---|
| (12, 24) | false | nil | before lead-in |
| (12, 25) | true | nil | lead-in starts; status "N days until Muharram" |
| (12, 13) | false | nil | Hajj-tail day — must NOT be Muharram |
| (1, 1) | true | 1 | "Day 1 of Muharram" |
| (1, 10) | true | 10 | "Ashura — Ya Husayn (AS)" |
| (1, 12) | true | nil | grace; status "The mourning continues…" |
| (1, 13) | false | nil | window closed |

**Revert the override.** Remove the temporary print.

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Services/IslamicCalendarManager.swift
git commit -m "feat(muharram): add Muharram season detection"
```

### Task 1.3: MuharramJourneyManager

**Files:**
- Create: `Thaqalayn/Services/MuharramJourneyManager.swift`

**Step 1: Read** `Thaqalayn/Services/HajjJourneyManager.swift` in full — this is the structural blueprint.

**Step 2: Create the manager** by mirroring `HajjJourneyManager` with these exact deltas:
- Type `MuharramJourneyManager`, `static let shared`, `@MainActor`, `ObservableObject`.
- JSON resource: `"muharram_journey"`; decode into `MuharramJourneyData`; `@Published var days`, `isLoading`, `errorMessage`.
- Persistence: `private let progressKey = "muharramJourneyProgress"`; `@Published var progress: MuharramJourneyProgress`; load/save via `JSONEncoder/JSONDecoder` exactly as Hajj.
- Annual reset: `checkYearReset()` keyed on `IslamicCalendarManager.shared.currentIslamicYear()` → resets to `MuharramJourneyProgress(year: currentYear)`.
- API: `isDayObserved(_:) -> Bool`, `markDayObserved(_:)`, `unmarkDayObserved(_:)` (set `lastObservedDate = Date()` on mark), `completionPercentage`.
- JSON load failure: surface via `errorMessage` and `print`, exactly as Hajj — **no fallback content**.
- **REMOVE entirely** (do not port): `checkForCompletionBadge()`, any `ProgressManager` reference, any `pendingBadge`, any "completed/champion" wording.

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify** — add a temporary launch snippet: `MuharramJourneyManager.shared` then `print(MuharramJourneyManager.shared.days.count, MuharramJourneyManager.shared.errorMessage as Any)`. Expected: `10 nil`. Toggle `markDayObserved(3)` / `unmarkDayObserved(3)` and confirm `completionPercentage` moves 0.1 ↔ 0.0 and persists across an app relaunch. **Remove the snippet.**

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Services/MuharramJourneyManager.swift
git commit -m "feat(muharram): add MuharramJourneyManager (no badge path)"
```

### Task 1.4: Premium gating

**Files:**
- Modify: `Thaqalayn/Services/PremiumManager.swift` (add beside `canAccessHajjDay`)

**Step 1: Read** `canAccessHajjDay` for exact convention.

**Step 2: Add**

```swift
/// Check if user can access a Muharram Journey day
/// - Day 1 is always free
/// - Days 2-10 require premium
func canAccessMuharramDay(_ dayNumber: Int) -> Bool {
    if dayNumber == 1 {
        return true
    }
    return isPremium
}
```

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Services/PremiumManager.swift
git commit -m "feat(muharram): premium gating (day 1 free, 2-10 premium)"
```

---

## PHASE 2 — Views

### Task 2.1: MuharramJourneyView

**Files:**
- Create: `Thaqalayn/Views/MuharramJourneyView.swift`

**Step 1: Read** `Thaqalayn/Views/HajjJourneyView.swift` in full.

**Step 2: Create** `MuharramJourneyView.swift` by mirroring `HajjJourneyView` structure (NavigationView → ZStack → AdaptiveModernBackground → header + LazyVStack of day cards → hidden NavigationLink to detail; `.preferredColorScheme`, `.darkScreenAura()`, `PaywallView` sheet). Apply these exact deltas:
- All types/managers → Muharram equivalents (`MuharramJourneyManager.shared`, `MuharramDay`, `MuharramJourneyView`, `MuharramDayCard`, `MuharramJourneyHeader`, `MuharramDayDetailView`).
- Card state: `isObserved: journeyManager.isDayObserved(day.dayNumber)`; `isCurrentDay: calendarManager.currentMuharramDay() == day.dayNumber`; `isLocked: !premiumManager.canAccessMuharramDay(day.dayNumber)`.
- Header copy: title **"Muharram Journey"**; status from `calendarManager.muharramSeasonStatus()`; progress label **"\(count) of 10 days observed"**. **REMOVE** the Hajj "Journey Complete! … badge earned" block entirely — no completion banner.
- Header icon: `flame.fill`.
- Tone: no green "completed" celebratory gradient framing for the whole journey; per-day observed check is fine (use a subdued check, not festive). Keep premium lock UI identical to Hajj.

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify** — temporarily render `MuharramJourneyView()` (or use the date override from Task 1.2 with (1,3) once the tab exists; for now host it in a temporary `#Preview` or swap into ContentView root). Confirm: 10 day cards, header shows "Day 3 of Muharram", "X of 10 days observed", **no completion banner**, days 2–10 show lock when `isPremium == false`. Revert any temporary hosting.

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Views/MuharramJourneyView.swift
git commit -m "feat(muharram): MuharramJourneyView (somber, no completion banner)"
```

### Task 2.2: MuharramDayDetailView

**Files:**
- Create: `Thaqalayn/Views/MuharramDayDetailView.swift`

**Step 1: Read** `Thaqalayn/Views/HajjDayDetailView.swift` in full.

**Step 2: Create** `MuharramDayDetailView.swift` mirroring `HajjDayDetailView` (ScrollView → day header, dua section, verses section with `MuharramVerseCard` → "Full Tafsir" deep-link to `SurahDetailView`, tafsir-focus card, reflection card, toggle button; back toolbar item). Deltas:
- All types → Muharram equivalents; `let day: MuharramDay`.
- Section labels: keep "TODAY'S DUA" (or "DUA / ZIYARAT"), "TODAY'S VERSES", "TAFSIR FOCUS", "REFLECTION".
- Toggle button: text **"Mark as observed"** / observed state shows a subdued filled check + "Observed" — **not** a festive green "Completed!"; calls `journeyManager.markDayObserved/​unmarkDayObserved`.
- **Day 10 (Ashura) special treatment:** when `day.dayNumber == 10`, use a distinct somber visual emphasis on the day header (e.g. deeper/elegiac accent, "Ashura" prominent, the mournful theme). Keep it dignified, not decorative.
- Verse "Full Tafsir" navigation: identical mechanism to Hajj (`SurahDetailView` with target verse).
- Remove any Hajj badge/celebration remnants if present in the detail file.

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify** — navigate into Day 1 and Day 10. Confirm: dua renders RTL with AmiriQuran, verses list with relevance notes, "Full Tafsir" navigates to the correct verse, "Mark as observed" toggles and persists, Day 10 shows the somber Ashura treatment, no celebratory UI.

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Views/MuharramDayDetailView.swift
git commit -m "feat(muharram): MuharramDayDetailView (Ashura treatment, observed wording)"
```

---

## PHASE 3 — Integration

### Task 3.1: MainTabView conditional tab

**Files:**
- Modify: `Thaqalayn/Views/MainTabView.swift`

**Step 1: Read** the Hajj tab block (`isHajjSeason` computed prop ~lines 21–23; conditional tab ~lines 81–90).

**Step 2: Add**, mirroring the Hajj tab:

```swift
// near the other season computed props
private var isMuharramSeason: Bool {
    IslamicCalendarManager.shared.isMuharramSeason()
}
```

```swift
// after the Hajj conditional tab block, inside TabView
if isMuharramSeason {
    MuharramJourneyView()
        .tabItem {
            Label {
                Text("Muharram")
            } icon: {
                Image(systemName: "flame.fill")
            }
        }
        .tag(6)
}
```
> Ramadan/Hajj/Muharram windows are mutually exclusive, so at most one seasonal tab is ever present.

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify** — using the Task 1.2 date-override technique, set (1, 3): the **Muharram** tab appears, Ramadan/Hajj tabs absent. Set (12, 13): no Muharram tab (Hajj-tail). Set (1, 13): no Muharram tab. **Revert override.**

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Views/MainTabView.swift
git commit -m "feat(muharram): conditional Muharram tab"
```

### Task 3.2: Onboarding card

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift`

**Step 1: Read** the Dhul-Hijjah `SeasonalFeatureExpandedCard` block (~lines 87–102).

**Step 2: Add** a Muharram card mirroring it, somber framing, e.g.:

```swift
SeasonalFeatureExpandedCard(
    icon: "flame.fill",
    iconColors: [ThemeManager.chipBrand.fg, ThemeManager.chipFeatured.fg],
    title: "Muharram Journey",
    badge: "Seasonal",
    badgeColor: ThemeManager.chipKnowledge.fg,
    features: [
        ("book.closed.fill", "Daily duas & ziyarat from Mafatih al-Jinan"),
        ("text.book.closed.fill", "Curated verses on Karbala's enduring lessons"),
        ("heart.fill", "The path of Imam Husayn (AS) to Ashura"),
        ("checkmark.circle.fill", "Observe the 10 days of azadari")
    ],
    isVisible: showFeatureCards,
    delay: 0.2
)
```
> Match the exact init signature/labels found in Step 1; adjust SF Symbols if those names differ in this codebase.

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify** — open the onboarding "Special Seasons" screen; the Muharram card renders with somber copy alongside the others.

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift
git commit -m "feat(muharram): onboarding seasonal card"
```

### Task 3.3: Shared seasonal progress ring

**Files:**
- Modify: `Thaqalayn/Views/ProgressRingsView.swift`

**Step 1: Read** `ProgressRingsView.swift` — note `isRamadanSeason`/`isHajjSeason`, `hasSeasonalRing`, `seasonalRingLabel`, `seasonalRingProgress`.

**Step 2: Extend** the shared seasonal-ring slot to include Muharram (mutually exclusive, so simple OR / precedence):
- Add `private var isMuharramSeason: Bool { IslamicCalendarManager.shared.isMuharramSeason() }`.
- Add `@StateObject private var muharramManager = MuharramJourneyManager.shared`.
- `hasSeasonalRing` → include `|| isMuharramSeason`.
- `seasonalRingLabel` → if `isMuharramSeason` return `"Muharram"` (keep Hajj/Ramadan branches).
- `seasonalRingProgress` → if `isMuharramSeason` return `muharramManager.completionPercentage`.
- Keep it quiet — no extra celebratory styling; reuse the existing ring rendering unchanged.

**Step 3: Build-verify** → `** BUILD SUCCEEDED **`.

**Step 4: Manual-verify** — date-override (1, 5), observe a couple of days in the Muharram tab, open the Progress tab: the seasonal ring shows label "Muharram" with the correct %. Confirm Ramadan/Hajj overrides still behave. **Revert override.**

**Step 5: Checkpoint** — suggested owner commit:
```bash
git add Thaqalayn/Views/ProgressRingsView.swift
git commit -m "feat(muharram): include Muharram in shared seasonal progress ring"
```

---

## PHASE 4 — Final end-to-end verification

### Task 4.1: Full boundary + tone pass

**Step 1: Confirm not-touched files are clean** — `git diff --stat` must show **no** changes to `Thaqalayn/Services/NotificationManager.swift`, `Thaqalayn/ContentView.swift`, `Thaqalayn/Services/ProgressManager.swift`. If any appear, revert them.

**Step 2: Full build** → `** BUILD SUCCEEDED **`, no new warnings introduced by Muharram files.

**Step 3: Boundary matrix** (date-override, then revert): re-run the Task 1.2 table end-to-end through the actual UI — tab presence, header status text, current-day highlight only on days 1–10, grace text on 11–12, mutual exclusivity vs Hajj (12,13) and Ramadan (e.g. 9,15).

**Step 4: Tone & access pass** (override (1,10) Ashura):
- No "Champion"/badge/celebration/sawab anywhere; no completion banner.
- "X of 10 days observed", "Mark as observed".
- Day 10 somber Ashura treatment present.
- `isPremium=false`: Day 1 free, Days 2–10 locked → `PaywallView`. `isPremium=true`: all open.
- Search the codebase: `grep -rn "Muharram" Thaqalayn/` shows only the intended surfaces.

**Step 5: Confirm override reverted** — `git diff Thaqalayn/Services/IslamicCalendarManager.swift` shows only the legitimate Task 1.2 additions, no hardcoded date.

**Step 6: Checkpoint** — suggested owner commit:
```bash
git add -A
git commit -m "feat(muharram): Muharram Journey feature complete (verified)"
```

---

## Done criteria

- Phase 0 content owner-approved before any Swift wiring.
- Build succeeds; boundary matrix passes through the UI.
- Somber tone verified; premium parity verified; not-touched files untouched.
- Date override fully reverted and never committed.
- All commits performed by the owner (Claude did not auto-commit).
