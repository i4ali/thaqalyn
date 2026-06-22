# Daily Crossword Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a premium **Daily Crossword** — a compact all-thematic criss-cross mini — as a standalone daily-engagement feature on the Today screen, mirroring the existing Daily Challenge.

**Architecture:** Content is pre-generated offline (Python: curated term bank → criss-cross generator → bundled `daily_crosswords.json`) and selected deterministically by day-of-year on device. Swift layer mirrors Daily Challenge exactly: `Models` + `Provider` (load/pick) + `Manager` (completion/streak/sawab/badges, `@MainActor`, UserDefaults + cloud sync) + `Card`/`View`/`Strings`. Theming via Midnight Emerald `Em*` components; premium-gated; rewards via `ProgressManager`.

**Tech Stack:** SwiftUI, Combine (`ObservableObject` singletons), Supabase (sync), Python 3 stdlib (content tooling). Build target: iOS Simulator iPhone 16 Pro.

---

## Project conventions (READ FIRST — these override the skill defaults)

- **No XCTest.** This app ships without a test target. The verification gate for Swift work is:
  1. **Build:** `xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -8` → expect `** BUILD SUCCEEDED **`.
  2. **Preview/behavior:** add a **removable `#if DEBUG` `#Preview` matrix** to each new view (English/Urdu × Emerald/Light × states) and verify visually (Xcode preview or the `run` skill on the simulator).
- **Python tooling DOES get real checks** — runnable `assert`-based validators (stdlib only). Always `source .venv/bin/activate` first.
- **SourceKit "cannot find type in scope" on new files is a stale-index false positive** — trust `xcodebuild`, not the IDE squiggles.
- **Xcode 16 synced folders:** new files dropped into `Thaqalayn/Models|Services|Views|Data/` are auto-included. **No `.pbxproj` edits.**
- **Do NOT auto-commit.** The user commits themselves. Each "Checkpoint" below is a logical stopping point for the user to review & commit — do not run `git commit`.
- **Reading-scale rule (CLAUDE.md):** card/header/clue chrome stays fixed-size (like `DailyChallengeCard`). Do not wire `ReadingSettingsManager` into crossword chrome.
- **No fallback logic** (CLAUDE.md): fail fast with clear errors; no silent degradation.

**Reference files to imitate (read before each phase):**
`Thaqalayn/Models/DailyChallengeModels.swift`, `Thaqalayn/Services/DailyChallengeProvider.swift`,
`Thaqalayn/Services/DailyChallengeManager.swift`, `Thaqalayn/Views/DailyChallengeCard.swift`,
`Thaqalayn/Views/DailyChallengeView.swift`, `Thaqalayn/Views/DailyChallengeStrings.swift`,
`Thaqalayn/Views/EmeraldComponents.swift`, `docs/BOOKMARK_SYNC_ARCHITECTURE.md`.
Visual target: `mockups/daily-crossword/board.png` (play screen = centre phone).

---

## Phase 0 — Content pipeline (Python, offline)

Prototype already exists in `mockups/daily-crossword/content/` (`bank.json`, `crisscross.py`,
`feasibility.py`). This phase promotes it to a maintained tool and produces the bundled JSON.

### Task 0.1: Promote content tooling to `scripts/crossword/`

**Files:**
- Create dir: `scripts/crossword/`
- Move: `mockups/daily-crossword/content/bank.json` → `scripts/crossword/bank.json`
- Move: `mockups/daily-crossword/content/crisscross.py` → `scripts/crossword/generate.py`
- Keep `mockups/daily-crossword/` as the design/mockup record.

**Step 1:** `mkdir -p scripts/crossword && git mv` (or `mv`) the two files above.
**Step 2:** In `generate.py`, delete the HTML `render()` / `FONT` block (review-only) and replace the `__main__` with the app-export in Task 0.3.
**Checkpoint:** user reviews & commits.

### Task 0.2: Add trilingual clues to the bank

**Files:** Modify `scripts/crossword/bank.json` — each entry gains `clue_ur` and `clue_ar`
(rename existing `clue` → `clue_en`).

**Step 1:** Rename `clue` → `clue_en` across the file.
**Step 2:** Dispatch the `urdu-translator` agent over the EN clues → fill `clue_ur`; dispatch
`arabic-translator` → fill `clue_ar`. (Names/places transliterate; keep term names intact.)
**Step 3:** Validate: every entry has non-empty `clue_en/_ur/_ar` and `answer` is `[A-Z]{3,6}`.

```bash
source .venv/bin/activate
python3 -c "
import json
b=json.load(open('scripts/crossword/bank.json'))['entries']
import re
for e in b:
    assert re.fullmatch(r'[A-Z]{3,6}', e['answer']), e
    for k in ('clue_en','clue_ur','clue_ar'): assert e.get(k), (e['answer'],k)
print(len(b),'entries OK')
"
```
Expected: `96 entries OK` (or current count).
**Checkpoint:** user reviews & commits.

### Task 0.3: Generate the bundled app JSON

**Files:**
- Modify: `scripts/crossword/generate.py` — emit the **app schema** (below) instead of HTML.
- Create: `Thaqalayn/Data/daily_crosswords.json` (output; bundled).

**App schema** (one object per puzzle; sparse cells = only letter cells; blocked cells absent):
```json
{
  "id": "dcw_0001",
  "rows": 7, "cols": 6,
  "entries": [
    {"num": 1, "dir": "A", "answer": "KAABA",
     "clue": {"en": "...", "ur": "...", "ar": "..."},
     "cells": [[0,0],[0,1],[0,2],[0,3],[0,4]]}
  ],
  "cellNumbers": {"0,0": 1, "2,0": 2}
}
```
Grid letters are derivable from `entries[].answer` + `cells`; the Swift loader rebuilds the cell map.

**Step 1:** Update `generate(count=400, target=6, max_dim=7, seed=…)` to produce ≥365 **distinct**
puzzles (dedupe by sorted word-set + dims). Carry each entry's trilingual clue from the bank into
`clue:{en,ur,ar}`.
**Step 2:** Write the JSON array to `Thaqalayn/Data/daily_crosswords.json` (UTF-8, `ensure_ascii=False`).
**Step 3:** Run:
```bash
source .venv/bin/activate && python3 scripts/crossword/generate.py
```
Expected: `wrote N puzzles to Thaqalayn/Data/daily_crosswords.json` with N ≥ 365.
**Checkpoint:** user reviews & commits.

### Task 0.4: Validator (the content "test")

**Files:** Create `scripts/crossword/validate.py`.

**Step 1:** Write a stdlib validator asserting, for every puzzle: (a) every `entries[].answer`
exists in the bank; (b) at every shared cell, across & down letters agree; (c) no two entries
share an identical `(dir, cells)`; (d) `cellNumbers` matches entry start cells; (e) ids unique;
(f) each puzzle has ≥1 crossing. Print `ALL N PUZZLES VALID`.
**Step 2:** Run `python3 scripts/crossword/validate.py` → expect `ALL N PUZZLES VALID`.
**Checkpoint:** user reviews & commits. **Gate for Phase 1.**

---

## Phase 1 — Models + Provider (data layer)

### Task 1.1: `DailyCrosswordModels.swift`

**Files:** Create `Thaqalayn/Models/DailyCrosswordModels.swift`. (Imitate `DailyChallengeModels.swift`; reuse its `LocalizedText` if it is shared — otherwise define one here.)

```swift
import Foundation

/// One interlocking entry (across or down).
struct CrosswordEntry: Codable, Identifiable, Hashable {
    let num: Int
    let dir: String            // "A" or "D"
    let answer: String         // A–Z solution, uppercased
    let clue: LocalizedText    // {en, ur, ar}
    let cells: [[Int]]         // [[row,col], …], length == answer.count
    var id: String { "\(num)\(dir)" }
    var isAcross: Bool { dir == "A" }
    func cell(at i: Int) -> CellPos { CellPos(r: cells[i][0], c: cells[i][1]) }
}

struct CellPos: Hashable, Codable { let r: Int; let c: Int }

/// A full daily puzzle.
struct DailyCrossword: Codable, Identifiable {
    let id: String
    let rows: Int
    let cols: Int
    let entries: [CrosswordEntry]
    let cellNumbers: [String: Int]   // "r,c" -> number

    /// Solution letter for every filled cell, rebuilt from entries.
    var solution: [CellPos: Character] {
        var m: [CellPos: Character] = [:]
        for e in entries {
            let a = Array(e.answer)
            for (i, rc) in e.cells.enumerated() { m[CellPos(r: rc[0], c: rc[1])] = a[i] }
        }
        return m
    }
    func number(at p: CellPos) -> Int? { cellNumbers["\(p.r),\(p.c)"] }
}

/// Completion record for one day.
struct DailyCrosswordCompletion: Codable {
    let dayKey: String          // "yyyy-MM-dd"
    let puzzleId: String
    let seconds: Int
    let usedHint: Bool
    let sawabEarned: Int
    let completedAt: Date
}

/// Persisted streak stats (separate from the Daily Challenge streak).
struct DailyCrosswordStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDayKey: String? = nil

    static func next(_ s: DailyCrosswordStreak, todayKey: String, yesterdayKey: String) -> DailyCrosswordStreak {
        var n = s
        if s.lastCompletedDayKey == todayKey { return n }            // already counted
        n.currentStreak = (s.lastCompletedDayKey == yesterdayKey) ? s.currentStreak + 1 : 1
        n.longestStreak = max(n.longestStreak, n.currentStreak)
        n.lastCompletedDayKey = todayKey
        return n
    }
}
```

**Verify:** Build (command above) → `BUILD SUCCEEDED`. If `LocalizedText` already exists and is
internal, do not redefine — reuse it. **Checkpoint.**

### Task 1.2: `DailyCrosswordProvider.swift`

**Files:** Create `Thaqalayn/Services/DailyCrosswordProvider.swift`. Imitate `DailyChallengeProvider.swift` (same day-of-year selection + caching + `refreshIfDayChanged()`).

```swift
import Foundation

@MainActor
final class DailyCrosswordProvider: ObservableObject {
    static let shared = DailyCrosswordProvider()

    @Published private(set) var today: DailyCrossword

    private let all: [DailyCrossword]
    private var cachedDayOfYear: Int

    private init() {
        all = Self.load()
        precondition(!all.isEmpty, "daily_crosswords.json missing or empty")
        cachedDayOfYear = Self.dayOfYear()
        today = all[cachedDayOfYear % all.count]
    }

    func refreshIfDayChanged() {
        let d = Self.dayOfYear()
        guard d != cachedDayOfYear else { return }
        cachedDayOfYear = d
        today = all[d % all.count]
    }

    private static func load() -> [DailyCrossword] {
        guard let url = Bundle.main.url(forResource: "daily_crosswords", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("daily_crosswords.json not found in bundle")   // fail fast, no fallback
        }
        return try! JSONDecoder().decode([DailyCrossword].self, from: data)
    }

    private static func dayOfYear() -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }
}
```

**Verify:** Build → `BUILD SUCCEEDED`. (Confirm the existing provider uses the same
`ordinality(of: .day…)` call; match it.) **Checkpoint.**

---

## Phase 2 — Manager (completion, streak, sawab, persistence)

### Task 2.1: `DailyCrosswordManager.swift`

**Files:** Create `Thaqalayn/Services/DailyCrosswordManager.swift`. Imitate `DailyChallengeManager.swift` (UserDefaults keys, `isCompletedToday`, `complete(...)`, day-key helpers). Read that file first and mirror its structure precisely.

Key surface:
```swift
@MainActor
final class DailyCrosswordManager: ObservableObject {
    static let shared = DailyCrosswordManager()

    @Published private(set) var streak = DailyCrosswordStreak()
    @Published private(set) var lastCompletion: DailyCrosswordCompletion?
    @Published private(set) var isCompletedToday = false

    private let dStreak = "dcw_streak"
    private let dCompletion = "dcw_lastCompletion"
    private let dCompletedDay = "dcw_completedDayKey"

    // base + bonuses; mirror Daily Challenge sawab magnitudes
    static let baseSawab = 20
    static let speedBonus = 10      // solved under threshold
    static let noHintBonus = 10

    func complete(seconds: Int, usedHint: Bool) { /* compute sawab, update streak,
        set isCompletedToday, persist, ProgressManager.shared.awardDailyCrosswordBadge(...),
        scheduleSync() */ }

    func refreshForToday() { /* recompute isCompletedToday from stored dayKey */ }
}
```

**Step 1:** Implement day-key helpers (`yyyy-MM-dd`, today/yesterday) identical to Daily Challenge.
**Step 2:** Implement `complete`: guard `!isCompletedToday`; sawab = base + (speed if `seconds<=120`) + (noHint if `!usedHint`); `streak = .next(...)`; build & store `DailyCrosswordCompletion`; set `isCompletedToday=true`; call `ProgressManager.shared.awardDailyCrosswordBadge` for milestones; persist; `scheduleSync()` (stub until Phase 8).
**Step 3:** Load persisted state in `init`; `refreshForToday()` clears `isCompletedToday` when the day rolls over.

**Verify:** Build → `BUILD SUCCEEDED`. **Checkpoint.**

---

## Phase 3 — Premium gate + ProgressManager badges

### Task 3.1: Premium accessor

**Files:** Modify `Thaqalayn/Services/PremiumManager.swift` — add, next to `canAccessDailyChallenge()`:
```swift
func canAccessDailyCrossword() -> Bool { isPremium }
```
**Verify:** Build. **Checkpoint.**

### Task 3.2: Badge types + award method

**Files:** Modify `Thaqalayn/Services/ProgressManager.swift` (and its `BadgeType` enum).

**Step 1:** Add `BadgeType` cases with `title`/`subtitle`/`icon`/`color`/`sawabValue`
(mirror the Daily Challenge badge tuples):
- `crosswordFirst` (icon `square.grid.3x3.fill`, +50)
- `crossword7` (`flame.fill`, +150)
- `crossword30` (`bolt.fill`, +600)
- `crossword100` (`crown.fill`, +2500)

**Step 2:** Add `awardDailyCrosswordBadge(currentStreak:)` mirroring `awardDailyChallengeBadge`
(idempotent guard, append `BadgeAward`, add `sawabValue`, set `pendingBadge` if celebrations on,
`saveProgress()`, `scheduleSync()`). Award `crosswordFirst` on any solve; streak badges at ≥7/30/100.

**Verify:** Build → `BUILD SUCCEEDED`. **Checkpoint.**

---

## Phase 4 — Trilingual UI strings

### Task 4.1: `DailyCrosswordStrings.swift`

**Files:** Create `Thaqalayn/Views/DailyCrosswordStrings.swift`. Imitate `DailyChallengeStrings.swift` exactly (static funcs taking `CommentaryLanguage`).

Provide: `dailyCrossword`, `premiumLabel`, `lockedTagline`, `teaser` (e.g. "6 words to solve"),
`doneForToday`, `sawabEarned(_:_:)`, `across`, `down`, `solved`, `comeBackTomorrow`,
`hint`, `clear`, `nextClue`/`prevClue` (accessibility labels). EN/UR/AR each.

**Verify:** Build. **Checkpoint.**

---

## Phase 5 — Today card + wiring

### Task 5.1: `DailyCrosswordCard.swift`

**Files:** Create `Thaqalayn/Views/DailyCrosswordCard.swift`. **Copy `DailyChallengeCard.swift`
and adapt**: icon `square.grid.3x3.fill`; strings → `DailyCrosswordStrings`; managers →
`DailyCrosswordManager` / `DailyCrosswordProvider`; gate → `canAccessDailyCrossword()`; sheet →
`DailyCrosswordView`. Keep both `emeraldCard` and `legacyCard`, the three states
(locked/pending/done), `EmPressStyle.gentle`, `Haptics.press()`, fixed-size chrome, RTL env.

**Step 1:** Copy & adapt as above.
**Step 2:** Add the `#if DEBUG` `#Preview` matrix (locked/pending/done × EN/UR × Emerald/Light),
copying the structure from `DailyChallengeCard.swift`.

**Verify:** Build → `BUILD SUCCEEDED`; open previews → card matches `mockups/daily-crossword/board.png`
(left phone, the NEW card). **Checkpoint.**

### Task 5.2: Place the card in Today

**Files:** Modify `Thaqalayn/Views/TodayView.swift` — add `DailyCrosswordCard()` directly **after**
`DailyChallengeCard()` in BOTH the `EmeraldTodayView` stack and the `legacyContent` stack
(around the current `DailyChallengeCard` usage, ~line 168). Add `provider.refreshIfDayChanged()` /
`manager.refreshForToday()` wherever Daily Challenge does the same on appear/active.

**Verify:** Build; run on the simulator (or `run` skill) → Today shows the new card under Daily
Challenge in both themes. **Checkpoint.**

---

## Phase 6 — Play screen (the puzzle)

### Task 6.1: `DailyCrosswordView.swift` — scaffold + grid

**Files:** Create `Thaqalayn/Views/DailyCrosswordView.swift`. Visual target:
`mockups/daily-crossword/board.png` (centre phone). Use `Em*` components + theme colors.

State machine:
```swift
@State private var entered: [CellPos: Character] = [:]   // user input
@State private var selected: CellPos                      // active cell
@State private var acrossMode = true                      // direction toggle
@State private var seconds = 0
@State private var usedHint = false
@State private var solved = false
```
Derived: `activeEntry` = the entry of `selected` in the current direction; `activeCells` = its cells
(highlighted gold). Tapping a cell selects it; tapping the selected cell **toggles** direction if
the cell belongs to both an across and a down entry.

**Step 1:** Header: close (✕), centered title (`DailyCrosswordStrings.dailyCrossword`) with
`🔥 streak` + `mm:ss` timer; right hint button.
**Step 2:** Grid: `LazyVGrid`/manual grid sized `rows×cols`; filled cells = letter tiles (entered
letter, small number top-left, gold highlight when in `activeCells`, brighter border when
`selected`); absent cells = transparent blanks. Letter font fixed-size (chrome).
**Step 3:** Timer via `Timer.publish` (pause when `solved`).

**Verify:** Build; preview with a sample puzzle (use `DailyCrosswordProvider.shared.today`) → grid
renders, selection highlight works. **Checkpoint.**

### Task 6.2: Clue bar + entry navigation

**Step 1:** Below the grid, a clue bar (gold-chip): ‹ prev, current clue text
(`activeEntry.clue.localized(lang)` with `num`+dir+length), next ›. Tapping ‹/› moves to the
prev/next entry (ordered Across then Down) and selects its first empty cell.
**Step 2:** Tapping a grid cell sets `selected` (+ toggles direction on repeat tap).

**Verify:** Build; preview → clue updates with selection; ‹/› cycles entries. **Checkpoint.**

### Task 6.3: On-screen keyboard + input logic

**Step 1:** Render an A–Z keyboard (QWERTY rows + ⌫), dark keys per mockup.
**Step 2:** Key press → set `entered[selected]`, advance `selected` to the next cell of
`activeEntry` (stop at end); ⌫ clears current/steps back.
**Step 3:** After each input, check completion: `solved = (entered == puzzle.solution)` (compare
only filled cells). On `solved`, stop timer and present the solved sheet (Task 7).

**Verify:** Build; run on simulator → can type, advance, backspace, and completing all cells
triggers solved. **Checkpoint.**

### Task 6.4: Hint (optional v1 — keep minimal)

**Step 1:** Hint button reveals the correct letter for `selected` (sets `entered`, `usedHint=true`).
Mark `usedHint` so the no-hint sawab bonus is withheld. (No per-letter economy in v1.)

**Verify:** Build. **Checkpoint.**

---

## Phase 7 — Solved screen + reward

### Task 7.1: Completion view

**Files:** Add a `solvedOverlay`/sheet inside `DailyCrosswordView.swift` (visual target:
`mockups/daily-crossword/board.png`, right phone).

**Step 1:** On solve, call `DailyCrosswordManager.shared.complete(seconds:usedHint:)` exactly once.
**Step 2:** Show gold seal, `Solved!` (serif), time `mm:ss`, `🔥 streak`, `+sawab` pill, optional
badge-unlock toast (driven by `ProgressManager.pendingBadge`), `EmGoldCTA` "Done" → dismiss.
**Step 3:** Dismiss returns to Today; the card now renders the **done** state.

**Verify:** Build; run → solving shows the reward, sawab/streak update, Today card flips to done.
**Checkpoint.**

---

## Phase 8 — Cloud sync

### Task 8.1: Persist completion/streak to Supabase

**Files:** Modify `DailyCrosswordManager.swift`; add service methods alongside the Daily Challenge
ones. Follow `docs/BOOKMARK_SYNC_ARCHITECTURE.md` and **mirror exactly how Daily Challenge syncs**
(observers for auth state, offline-first local write, debounced `scheduleSync()`, three-step
delete→upload→download, user-isolation cleanup on sign-out/switch).

**Step 1:** Confirm whether Daily Challenge syncs its completion/streak or relies on
`ProgressManager` sync. **Match that choice** — do not invent a new pattern.
**Step 2:** If a dedicated table is needed, add the schema + RLS (new migration under the
Supabase project) keyed by user id + `dayKey`.
**Step 3:** Wire `scheduleSync()`, auth observers, and sign-out cleanup.

**Verify:** Build; sign in on the simulator, solve, confirm row upserts (Supabase MCP `execute_sql`
or `/users-premium`-style check); sign out → local crossword state cleared. **Checkpoint.**

---

## Phase 9 — Polish & final verification

### Task 9.1: RTL, haptics, accessibility, day-rollover

**Step 1:** Verify Urdu/Arabic: clue bar + strings RTL via `.environment(\.layoutDirection,…)`;
grid stays LTR (Latin letters). Haptics on key/solve via `Haptics`.
**Step 2:** Day rollover: `refreshIfDayChanged()` + `refreshForToday()` on `scenePhase == .active`.
**Step 3:** VoiceOver labels for cells (number + clue) and keys.

**Verify:** Build; run EN/UR/AR × Emerald/Light. **Checkpoint.**

### Task 9.2: Full regression build + DEBUG-matrix audit

**Step 1:** Build clean:
`xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' build 2>&1 | tail -8`
→ `** BUILD SUCCEEDED **`.
**Step 2:** Confirm all new `#Preview`/`#if DEBUG` scaffolding is self-contained and removable
(no production code depends on it).
**Step 3:** Smoke test on simulator: fresh premium user → solve → streak 1, sawab, badge; free
user → locked → paywall.
**Checkpoint:** user reviews & commits.

---

## Bonus (defer unless requested)

- Onboarding teaser screen (mirror `Onboarding/DailyChallengeScreen.swift`).
- Secondary Explore entry (`ExploreView` item → opens today's crossword).
- Larger/Friday "special" puzzles; hint economy; share-result card.
