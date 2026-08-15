# Widget Reflection Content Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.
> Design doc: `docs/plans/2026-08-11-widget-reflection-content-design.md` (read it first).
> Builds on the (uncommitted) Daily Reflection widget: `docs/plans/2026-08-11-daily-reflection-widget-plan.md`.

**Goal:** Replace titles/teasers on the widget's verse, gem, doorway, and night beats with authored anchored reflections (~2,000 lines), merged from a new `widget_reflections.json` into `widget_daily.json` at build time.

**Architecture:** Agents author reflections into per-batch staging files; `scripts/build_widget_reflections.py` merges + validates them into `Thaqalayn/Data/widget_reflections.json` (the reviewed source of truth); `scripts/generate_widget_daily.py` merges that into `widget_daily.json`. Swift models gain optional reflection fields with view-level fallbacks; the featured gem rotates by Gregorian year; doorway essence lines rotate by day index.

**Tech Stack:** Python 3 (`source .venv/bin/activate`), WidgetKit + SwiftUI, XCTest, subagent authoring in waves of max 2 (CLAUDE.md cap).

**Hard rules that apply to every task:**
- NEVER commit without asking first via AskUserQuestion (CLAUDE.md). Every "Commit" step below is gated on that.
- No em dashes; plain English spelling, no transliteration diacritics (`scripts/strip_diacritics.py` rules).
- Respectful death language: never "dying"/"died" for the Prophet or Imams.
- Narration quotes ONLY if the narration already appears, cited, in the app's content. No invented or newly-sourced quotes.
- No premium signals on the widget, ever. Widget fonts stay fixed (documented exemption from the reading-scale rule).
- Editing JSON that carries Arabic: use Python scripts, not the Edit tool (NFC renormalization hazard).

**Verified facts (do not re-derive):**
- Beats: `WidgetBeat` in `Thaqalayn/Shared/WidgetScheduleBuilder.swift`; only `.gem(index: 0)` is scheduled today; `gemCount` param is otherwise unused.
- `WidgetContent.content(for:)` (`ThaqalaynWidgets/WidgetContent.swift`) resolves selection, entry, schedule, journeys (slot 0 afternoon / slot 1 evening, other kind).
- Views: `ThaqalaynWidgets/DailyReflectionWidget.swift`. Small gem beat shows gem *title*; doorways show name + teaser `line`; night repeats translation; small verse beat shows themeAr/themeEn.
- Hydration: `scripts/generate_widget_daily.py`. `extract_hooks()` regex-pulls journey orientation promises for doorway `line`. Output keyed `"surah:verse"`, ~380 unique entries; `catalog` = interleaved experiences+dives (coming-soon dives excluded).
- Pool: `Thaqalayn/Data/daily_verses.json` (365 verses + 19 sacredDays, some duplicate surah:verse keys). Gems: `Thaqalayn/Thaqalayn/Data/tafsir_<n>.json` `quickOverview.concepts` (note doubled path).
- Tests: `ThaqalaynTests/*` run via the `Thaqalayn` scheme; 15 currently green.
- Test command: `xcodebuild test -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ThaqalaynTests 2>&1 | tail -5`
- Build command: `xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -sdk iphonesimulator build 2>&1 | tail -3`
- CRITICAL: `generate_widget_daily.py` runs as a "Generate Widget Daily Content" run-script build phase on EVERY build of `ThaqalaynWidgetsExtension` (which the app scheme builds), and a non-zero exit FAILS THE BUILD. Therefore the script's default mode must stay lenient until authoring is complete; strictness is an opt-in flag the build phase adopts only in Task 9.

---

### Task 1: Batch tooling - `make_reflection_batches.py` + `build_widget_reflections.py`

**Files:**
- Create: `scripts/make_reflection_batches.py`
- Create: `scripts/build_widget_reflections.py`
- Create (generated): `Thaqalayn/Data/widget_reflections.json` (empty skeleton at first)
- Staging dir: `scratch/reflection_batches/` (gitignored already via scratch rule)

**Step 1: Write `scripts/make_reflection_batches.py`**

Emits agent input files. For every unique pool key (dedup like the generator): key, arabic, translation, themeKey, themeEn, occasionEn (sacred days), gems `[{title, insight}]`. Sort keys by (surah, verse). Split into batches of 24: `scratch/reflection_batches/input_batch_01.json` ... Also emit `input_journeys.json`: for each catalog journey/dive (reuse `extract_catalog` + availability filter by importing from `generate_widget_daily.py` or copying the two functions), the id, kind, name, and the path to its `Thaqalayn/Content/*.swift` file (match by scanning Content files for `id: "<ident>"`).

```python
#!/usr/bin/env python3
"""Emit authoring-batch input files for widget reflections.

Usage: python3 scripts/make_reflection_batches.py [--batch-size 24] [--missing-only]
Writes scratch/reflection_batches/input_batch_NN.json and input_journeys.json.

--missing-only: emit ONLY pool verses / catalog journeys not yet covered by
Thaqalayn/Data/widget_reflections.json. This is the DELTA WORKFLOW for new
content: when a new journey/dive/verse lands, run this, author the one small
batch, merge, and the strict build gate goes green again.
"""
```

(Implementation mirrors `generate_widget_daily.py`'s loading; ~90 lines. Batches contain full context so authoring agents never open tafsir files themselves.)

**Step 2: Run it**

Run: `source .venv/bin/activate && python3 scripts/make_reflection_batches.py`
Expected: `OK: 16 verse batches (380 verses), 27 journeys` (numbers may vary by 1-2).

**Step 3: Write `scripts/build_widget_reflections.py`**

Merges staging outputs into `Thaqalayn/Data/widget_reflections.json` and validates. Contract:

- Staging outputs: `scratch/reflection_batches/out_batch_NN.json` with shape `{"verses": {"2:115": {"morning": {"en": "..."}, "gems": [{"en": "..."}, ...], "night": {"en": "..."}}}}`; `out_journeys.json` with `{"journeys": {"sabr": {"lines": [{"en": "...", "source": "Imam Ali - al-Kafi"}]}}}` (`source` null for takeaway lines).
- Merge: existing `widget_reflections.json` + all staging files present (staging wins on key collision). Write sorted keys, `ensure_ascii=False, indent=1`.
- Validate every merged entry (fail non-zero, print every violation):
  - key exists in the pool; gems array length == that verse's tafsir concepts count.
  - caps: morning/night <= 110 chars, gem lines <= 100, essence text <= 90, source <= 48.
  - forbidden chars anywhere: em dash, macron/under-dot diacritics (`āīūḥṣḍṭẓ` + uppercase), `ʿ`, `ʾ`.
  - journey ids exist in the catalog; each has 2-3 lines.
  - WARN (not fail) on "dying"/"died"/"passed away" - flag for manual review.
- `--require-full`: additionally fail unless ALL pool keys and ALL catalog ids are covered.

**Step 4: Run on empty staging**

Run: `python3 scripts/build_widget_reflections.py`
Expected: `OK: 0 verses, 0 journeys merged` and a valid skeleton `{"version": 1, "verses": {}, "journeys": {}}` written.
Run: `python3 scripts/build_widget_reflections.py --require-full`
Expected: FAIL listing all missing keys (proves the coverage check works).

**Step 5: Commit** (ask first): `"Widget reflections: batch + merge/validation tooling"`

---

### Task 2: `generate_widget_daily.py` - merge reflections, drop teaser extraction

**Files:**
- Modify: `scripts/generate_widget_daily.py`
- Regenerate: `Thaqalayn/Data/widget_daily.json`

**Step 1: Edit the script**

- Load `Thaqalayn/Data/widget_reflections.json`.
- DELETE `extract_hooks()`, `HOOK_OVERRIDES`, `HOOK_MAX_CHARS`, `doorway_line()` and their call sites.
- Doorway/catalog entries: replace `"line": ...` with `"lines": [{"text": l["en"], "source": l.get("source")} for l in journeys[ident]["lines"]]`, or `"lines": []` when the ident has no authored lines yet (views fall back to the name).
- Verse entries: add `"morning"` and `"night"` (from `reflections["verses"][key]`, `["en"]` values) and give each gem `"line"` (zip by index). If a verse has no reflections entry, omit the fields.
- DEFAULT MODE IS LENIENT (the build phase runs this on every build - it must not fail mid-authoring): count and print `partial: N verses without reflections, M journeys without lines`. New flag `--require-full` fails on any missing verse reflections or any journey with <2 lines. The build phase keeps calling the script with no flag until Task 9.
- Bump output `"version": 2`.

**Step 2: Run (reflections file is still empty)**

Run: `python3 scripts/generate_widget_daily.py`
Expected: `OK: ~380 verses hydrated ... partial: ~380 verses without reflections, ~26 journeys without lines`. Then `python3 scripts/generate_widget_daily.py --require-full` must FAIL listing the gaps (proves strict mode). Full app build must still SUCCEED (build phase runs lenient mode).

**Step 3: Commit** (ask first): `"Widget hydration: merge authored reflections, drop teaser extraction"` (script only; JSON regenerates in Task 7).

---

### Task 3: Shared Swift - featured-gem year rotation + essence rotation (TDD)

**Files:**
- Modify: `Thaqalayn/Shared/WidgetScheduleBuilder.swift`
- Modify: `ThaqalaynTests/WidgetScheduleBuilderTests.swift`

**Step 1: Write the failing tests** (append to `WidgetScheduleBuilderTests`)

```swift
func testFeaturedGemIndexRotatesByYear() {
    var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
    let d2026 = cal.date(from: DateComponents(year: 2026, month: 8, day: 11))!
    let d2027 = cal.date(from: DateComponents(year: 2027, month: 8, day: 11))!
    XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2026, gemCount: 4), 2) // 26 % 4
    XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2027, gemCount: 4), 3)
    XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2026, gemCount: 1), 0)
    XCTAssertEqual(WidgetScheduleBuilder.featuredGemIndex(for: d2026, gemCount: 0), 0) // never crashes
}

func testRotationIndexIsSafe() {
    XCTAssertEqual(WidgetScheduleBuilder.rotationIndex(dayIndex: 9723, count: 3), 9723 % 3)
    XCTAssertEqual(WidgetScheduleBuilder.rotationIndex(dayIndex: 5, count: 0), 0)
}

func testScheduleEmitsFeaturedGemIndex() {
    // Update an existing with-times schedule test's construction to pass
    // featuredGemIndex: 2 and assert the post-Zohr beat is .gem(index: 2).
}
```

**Step 2: Run tests** - expect FAIL (`featuredGemIndex` undefined).

**Step 3: Implement**

In `WidgetScheduleBuilder`: replace the `gemCount: Int` parameter with `featuredGemIndex: Int`, emit `.gem(index: featuredGemIndex)` at the post-Zohr slot (both timed and no-location branches), and add:

```swift
/// The gem the day features. Rotates by Gregorian year so a verse's day
/// reads differently each year - this is why every gem gets an authored line.
static func featuredGemIndex(for date: Date, gemCount: Int) -> Int {
    guard gemCount > 0 else { return 0 }
    var cal = Calendar(identifier: .gregorian); cal.timeZone = .current
    return max(0, cal.component(.year, from: date) - 2000) % gemCount
}

/// Deterministic pick from a rotating pool (essence lines, etc.).
static func rotationIndex(dayIndex: Int, count: Int) -> Int {
    count > 0 ? dayIndex % count : 0
}
```

Fix the existing call site in `WidgetContent.content(for:)`:

```swift
let schedule = WidgetScheduleBuilder.schedule(
    for: dayStart, dayIndex: dayIndex, times: times,
    featuredGemIndex: WidgetScheduleBuilder.featuredGemIndex(
        for: dayStart, gemCount: entry?.gems.count ?? 1),
    salahLineCount: salahLines.count)
```

Update every other existing test that passed `gemCount:` to pass `featuredGemIndex: 0` so their expectations are unchanged.

**Step 4: Run tests** - expect all PASS (15 existing + new).

**Step 5: Commit** (ask first): `"Widget: featured gem rotates by year; rotation helpers"`

---

### Task 4: Widget models - reflection fields with graceful fallbacks

**Files:**
- Modify: `ThaqalaynWidgets/WidgetContent.swift`

**Step 1: Update models**

```swift
struct WidgetGem: Codable {
    let title: String
    let insight: String
    let icon: String
    let colorHex: String
    let line: String?            // authored reflective line; falls back to insight
}

struct EssenceLine: Codable {
    let text: String
    let source: String?          // "Imam Ali - al-Kafi" | nil for takeaway lines
}

struct WidgetDoorway: Codable {
    let kind: String
    let id: String
    let name: String?
    let lines: [EssenceLine]?    // essence lines; rotate by dayIndex

    func essence(dayIndex: Int) -> EssenceLine? {
        guard let lines, !lines.isEmpty else { return nil }
        return lines[WidgetScheduleBuilder.rotationIndex(dayIndex: dayIndex, count: lines.count)]
    }
}

struct WidgetVerseEntry: Codable {
    // existing fields...
    let morning: String?         // authored morning reflection
    let night: String?           // authored night close
}
```

`DayContent` gains `let dayIndex: Int` (already computed in `content(for:)` - store it) so views can rotate essence lines.

**Step 2: Build** (widget compiles; views still use old fields where they exist - fix compile errors from the `line` -> `lines` rename by temporarily using `essence(dayIndex:)?.text` where `doorway.line` was used; Task 5 does the real view work).

Run the build command. Expected: `BUILD SUCCEEDED`.

**Step 3: Commit** (ask first): `"Widget: reflection model fields + essence rotation"`

---

### Task 5: Widget views - reflections lead every beat

**Files:**
- Modify: `ThaqalaynWidgets/DailyReflectionWidget.swift`

`ReflectionEntry` gains `let dayIndex: Int` (thread it from `DayContent` in the provider, `0` in `.sample`). All fallbacks below are view-level (`??`), so a stale/partial `widget_daily.json` degrades to today's behavior, never blank.

**Step 1: Small views** (`SmallReflectionView.beatContent` + `themeBlock`)

- `.verse` / `.night`: replace `themeBlock`'s theme-word display with the reflection: `entry.verse?.morning` (verse) / `entry.verse?.night` (night), fallback `entry.selection.themeEn`. Serif, size 13, `lineLimit(5)`, `minimumScaleFactor(0.75)`. Keep the occasion eyebrow on sacred days and the reference footer.
- `.gem(index)`: keep the dots row; replace the title text with `gems[index].line ?? gems[index].insight`, serif 12.5, `lineLimit(5)`, `minimumScaleFactor(0.7)`.
- `.doorway(slot)`: keep the kind eyebrow; body becomes the essence text (`doorway?.essence(dayIndex:)?.text`, fallback `doorway?.name`), serif 12.5, `lineLimit(4)`; footer row: `(doorway?.name ?? "").uppercased()` mono 8pt gold + chevron (replaces the big name).

**Step 2: Medium/large views** (`MediumLargeReflectionView.beatContent`)

- `.verse`: large keeps Arabic + translation, then adds the morning reflection (serif 15, text color) as the lead line below; medium shows morning reflection (serif 14 italic) with the translation as ONE dim line above it. Fallback when `morning == nil`: current rendering.
- `.gem(index)`: swap `gems[index].insight` for `gems[index].line ?? insight`. Keep dim translation line and (large) the gem map.
- `.doorway(slot)`: essence text leads (serif italic, 15/13 as sizes are today), then on large an attribution line if `essence.source != nil` (mono caps 8pt dim, same style as the salah line source), then the tease row. Change `teaseRow` to `"\(name.uppercased()) - \(kindLabel)"` + chevron (name first - the name is now the footer, not the headline). Delete the big `doorway?.name` headline text.
- `.night`: replace the repeated translation with `entry.verse?.night ?? translation`. Keep Arabic (large) and the Fajr row.
- Chips unchanged (`chipText` already shows gem title / "Go deeper" / "Night").

**Step 3: Sample + previews**

`ReflectionEntry.sample` stays on 39:10; nothing else needed (it renders whatever fields exist). Check both `#Preview`s still compile.

**Step 4: Build**, then eyeball in simulator with partial data absent (fields nil -> old behavior). Expected: `BUILD SUCCEEDED`, widget renders as before (no reflections exist yet - fallbacks prove themselves).

**Step 5: Commit** (ask first): `"Widget: reflection-first beat views with fallbacks"`

---

### Task 6: Author journey essence lines (27 journeys) - USER REVIEW GATE

**Step 1: Dispatch 2 authoring agents (one wave, max 2 concurrent per CLAUDE.md)**

Split `scratch/reflection_batches/input_journeys.json` roughly in half (agent A: experiences; agent B: dives + remainder). Each agent prompt:

> Read `scratch/reflection_batches/input_journeys.json`, entries [your half]. For each journey id, open its `Thaqalayn/Content/<file>.swift` and author 2-3 widget essence lines into `scratch/reflection_batches/out_journeys_<A|B>.json` (shape: `{"journeys": {"<id>": {"lines": [{"en": ..., "source": ...}]}}}`).
>
> An essence line is the journey's distilled takeaway or its strongest quoted narration - a complete thought that lands on a home-screen widget with no context. RULES:
> - Prefer a narration the journey file itself quotes WITH its citation; `source` = "<speaker> - <book>" exactly as the journey cites it. If quoting, quote faithfully.
> - Otherwise write the journey's core takeaway in warm second person; `source`: null. No cliffhangers, no "discover/find out" teaser language, no questions.
> - <= 90 chars per line text, <= 48 chars per source. Plain spelling (no diacritics: no ā ī ū ḥ ṣ ḍ ṭ ẓ ʿ ʾ), no em dash, straight apostrophes only.
> - Never "dying"/"died" for the Prophet or Imams.
> - Return only the count written.

**Step 2: Merge + validate**

Run: `python3 scripts/build_widget_reflections.py`
Expected: `OK: 0 verses, 27 journeys merged`, zero violations. Fix any violation by editing the staging file and re-running (Python, not the Edit tool).

**Step 3: STOP - user review gate.** Present all ~70 lines grouped by journey. This is authored religious content; it proceeds only on explicit approval, like the salah lines did.

**Step 4: Commit after approval** (ask first): `"Widget reflections: journey essence lines (27 journeys, reviewed)"`

---

### Task 7: Pilot - batch 01 + end-to-end wiring - USER REVIEW GATE

**Step 1: Dispatch 1 authoring agent for `input_batch_01.json`** (24 verses). Prompt template (reused for all verse batches):

> Read `scratch/reflection_batches/input_batch_NN.json`. For each verse write into `scratch/reflection_batches/out_batch_NN.json` (shape in the file header): a `morning` line, one line per gem (same order/count as the input gems), and a `night` line. All `{"en": "..."}`.
>
> VOICE - anchored reflection: warm second person where natural, each line a complete standalone thought a person reads on their home screen. Anchored means: the line says only what THIS verse and THIS gem's insight support - no generic positivity, no theological claims beyond the input, no invented quotes or attributions.
> - `morning`: sets the verse's thought for the day ahead.
> - gem lines: the gem's insight recast as one reflective line (<= 100 chars) - what it means for the reader today, not a definition.
> - `night`: closes the day's thought - completion, mercy, rest; reads well after Isha.
> - If `occasionEn` is present, morning and night must be occasion-aware (it is a sacred day).
> - Caps: morning/night <= 110 chars. Plain spelling (no ā ī ū ḥ ṣ ḍ ṭ ẓ ʿ ʾ), no em dash, straight apostrophes. Never "dying"/"died" for the Prophet or Imams.
> - Return only the count written.

**Step 2: Merge, validate, hydrate, test**

```bash
python3 scripts/build_widget_reflections.py
python3 scripts/generate_widget_daily.py   # expect: partial: ~356 verses without reflections, 0 journeys without lines
xcodebuild test ... -only-testing:ThaqalaynTests 2>&1 | tail -5   # all green
```

**Step 3: Simulator/device eyeball.** Build the app, add all three widget sizes. Check a pilot verse day and a non-pilot day (fallback rendering), every beat (small: reflection fits without ugly shrinking; doorway footer reads well; large attribution line). Adjust font sizes/lineLimits or the char caps NOW - after this gate the caps are frozen.

**Step 4: STOP - user review gate.** Show the pilot batch's lines (~120) + screenshots. Get approval of voice and layout before the fan-out.

**Step 5: Commit after approval** (ask first): `"Widget reflections: pilot batch + end-to-end hydration"`

---

### Task 8: Fan-out - remaining ~15 batches in waves of 2

Repeat per wave (2 batches at a time, ~8 waves):

**Step 1:** Dispatch 2 authoring agents (batch NN, NN+1) with the Task 7 prompt.
**Step 2:** Run `python3 scripts/build_widget_reflections.py`; fix violations via Python edits to staging; re-run until clean.
**Step 3:** Dispatch 1 quality-check agent on the wave's ~48 verses:

> Read `Thaqalayn/Data/widget_reflections.json` entries [keys of this wave] and `scratch/reflection_batches/input_batch_NN.json` (+NN+1) for their source gems. Flag any line that is: (a) not supported by its verse/gem input (over-claiming), (b) generic filler that could sit under any verse, (c) teaser/cliffhanger phrasing, (d) awkward or preachy, (e) disrespectful phrasing about the Prophet/Imams. Return a JSON list of {key, field, reason} - empty if clean.

**Step 4:** Re-author flagged lines (small follow-up agent or directly), re-validate.
**Step 5:** After every 2-3 waves, checkpoint-commit (ask first): `"Widget reflections: batches NN-MM"`.

Progress marker: `python3 scripts/build_widget_reflections.py --require-full` - the missing-key list shrinking to zero is the done signal.

---

### Task 9: Full hydration + suite + spot-check

**Step 1:** `python3 scripts/build_widget_reflections.py --require-full` - expect `OK` with full coverage.
**Step 2:** `python3 scripts/generate_widget_daily.py --require-full` - expect `OK: ~380 verses hydrated ...`, `partial: 0`.
**Step 3:** Flip the "Generate Widget Daily Content" run-script build phase (ThaqalaynWidgetsExtension target, pbxproj) to invoke the script WITH `--require-full`, so any future coverage regression fails the build instead of silently shipping fallbacks. Build to verify: `BUILD SUCCEEDED`.
**Step 4:** Full test suite - all green.
**Step 5:** Spot-check protocol for the user: 15 random verses' full line sets + all sacred-day entries (19) printed for review. Sacred days get a full read; the rest is sampling.
**Step 6: Commit** (ask first): `"Widget reflections: full pool authored + hydrated (v2, strict build gate)"`

---

### Task 10: Device pass + wrap-up

**Step 1: Device pass** (physical device): all three sizes across a day's beats (morning reflection, featured gem line, both doorway essence lines with attribution, night close), a sacred day (Hijri override -> occasion-aware lines), fallback day removed (all verses covered now), deep links from every beat unchanged.
**Step 2: New-content sync test** (proves the user's automation requirement end to end): temporarily add a fake dive descriptor to `DeepDiveCatalog.swift` (`available: true`) -> build must FAIL naming the missing widget lines; run `make_reflection_batches.py --missing-only` -> exactly that dive is emitted; add 2 staging lines, merge, rebuild -> SUCCEEDS. Revert the fake dive.
**Step 3: Update the content-creation skills** so new journeys ship with their lines: in `~/.claude/skills/inside-the-surah/SKILL.md` and `~/.claude/skills/theme-deep-dive/SKILL.md`, add a mandatory implementation step - "author the journey's 2-3 widget essence lines into `Thaqalayn/Data/widget_reflections.json` (via a staging file + `scripts/build_widget_reflections.py`); the widget build gate fails without them" - placed with each skill's existing implement/build steps.
**Step 4:** What's New: the widget's existing catalog entry (from the widget build) still describes the feature correctly - verify blurb, no new entry needed (content redesign, not a new feature).
**Step 5:** Update `docs/plans/2026-08-11-daily-reflection-widget-design.md` status note pointing to the content redesign doc.
**Step 6:** Final commit slicing + `/bump-version` per the usual ship flow (ask first, as always).

---

## Task order and dependencies

1 -> 2 (script edits build on tooling contract). 3 -> 4 -> 5 (Swift chain). 6 needs 1 only; 7 needs ALL of 2, 5, 6. 8 needs 7's approved voice. 9 -> 10 close out.

Sensible sequence: 1, 2, 3, 4, 5, 6 (gate), 7 (gate), 8, 9, 10.
Authoring concurrency: never more than 2 agents in flight, ever (CLAUDE.md).
