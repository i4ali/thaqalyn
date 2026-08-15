# Widget Reflection Content Redesign - Design

**Date**: 2026-08-11
**Status**: Approved
**Builds on**: `2026-08-11-daily-reflection-widget-design.md` (the widget itself, built and uncommitted)

## Problem

Outside the prayer beats (which work well and are untouched), the Daily Reflection
widget's beats mostly show labels, not content:

- Small gem beat shows only the gem *title* ("God's Presence").
- Doorway beats lead with the journey/dive *name* plus a teaser line regex-extracted
  from the journey's orientation promise - a cliffhanger written for another context,
  not a takeaway.
- The small verse beat shows the theme *word* (Arabic + English).
- The night beat repeats the translation.

Titles and teasers give the user nothing to reflect on. Every beat should carry one
complete, standalone reflective thought - a morale booster anchored in the day's
verse, its gems, or the featured journey - the way the approved salah lines already do.

## Decisions (user-approved)

1. **Voice: anchored reflections.** Warm second-person reflective lines, every line
   anchored in the verse, journey, or a narration, citing when it quotes. Not
   sourced-quotes-only, not free-floating coaching copy.
2. **Scale: full per-verse authoring.** Every pool verse (~384 = 365 + sacred days)
   gets a morning reflection, one reflective line per gem, and a night close.
   Every journey/dive (27) gets 2-3 essence lines. ~2,000 lines, agent-authored.
3. **Structure: unchanged.** Same beat skeleton (verse -> gem -> doorways -> night,
   prayers interleaved), same deep links, same dots/chips. Only the words change.
4. **Pipeline: dedicated authoring file merged at hydration.** New
   `Thaqalayn/Data/widget_reflections.json` is the single authored source;
   `scripts/generate_widget_daily.py` merges it into `widget_daily.json` and fails
   loudly on any coverage gap.

## Content spec per beat

All lines: plain English spelling (no transliteration diacritics), no em dash,
length-capped so nothing truncates mid-sentence (~<=110 chars for reflections,
~<=90 chars + attribution for essence lines; exact caps locked during the pilot).
Narration quotes may only be narrations already present and cited in the app's
content - agents never introduce unverified quotes.

### Verse beat (midnight -> Zohr, incl. pre-Fajr)
- Small: authored **morning reflection** (replaces theme-word block); verse
  reference below; occasion stays as eyebrow on sacred days.
- Medium: morning reflection + dim single-line translation.
- Large: Arabic + translation + morning reflection.

### Gem beat (after Zohr)
- The authored **per-gem reflective line** leads on all families (small drops the
  bare title; chip still shows the featured gem's title).
- Large keeps Arabic and the gem map.
- **Featured gem rotates by year**: `featuredIndex = yearsSinceEpoch % gemCount`
  (replaces hardcoded index 0). One gem beat per day as before, but a verse's day
  reads differently each year - this is why all per-gem lines get authored.

### Doorway beats (after Asr, slot 0; after Maghrib, slot 1)
- Hierarchy flips: **essence line leads, journey name becomes the footer**
  (e.g. `SABR - DEEP DIVE >`).
- 2-3 essence lines per journey/dive: a narration quote from inside the journey
  with attribution, or its distilled takeaway (no source). Rotated by dayIndex.
- Deep links unchanged.

### Night beat (after Isha)
- Authored **night close** replaces the repeated translation - written as a
  closing of the day's verse thought. Large keeps Arabic + tomorrow's Fajr.

### Prayer beats
- Untouched.

## Data schema

`Thaqalayn/Data/widget_reflections.json` (authored source of truth):

```json
{
  "version": 1,
  "verses": {
    "2:115": {
      "morning": { "en": "Wherever you turn today, you are already facing Him." },
      "gems": [ { "en": "..." }, { "en": "..." }, { "en": "..." }, { "en": "..." } ],
      "night":   { "en": "The day is closing. Nothing done in sincerity was out of His sight." }
    }
  },
  "journeys": {
    "sabr": { "lines": [
      { "en": "Patience is to faith what the head is to the body.", "source": "Imam Ali - al-Kafi" }
    ] }
  }
}
```

- `gems` is parallel to the verse's tafsir `concepts` order.
- `{ "en": ... }` objects leave room for UR/AR later (matches `salah_lines.json`);
  the widget stays English for now.

## Pipeline changes (`scripts/generate_widget_daily.py`)

- Load `widget_reflections.json`; merge into `widget_daily.json`:
  - verse entries gain `"reflections": { "morning", "night" }`;
  - each gem gains `"line"`;
  - doorway/catalog entries replace the teaser `"line"` with
    `"lines": [ { text, source } ]`.
- Delete `extract_hooks()` (the orientation-promise regex).
- Fail-loud validation: every pool verse has morning/night and a gem-line count
  matching its concepts count; every available catalog journey/dive has >=2 lines;
  char caps; no diacritics (reuse `strip_diacritics.py` logic as a check); no em dash.

## Swift changes

- `WidgetContent.swift`: `WidgetGem` gains `line`; `WidgetVerseEntry` gains
  `reflections`; `WidgetDoorway.line` becomes `lines: [EssenceLine]` with a
  `line(for dayIndex:)` picker. Featured-gem index computed here and passed into
  the schedule call; `WidgetScheduleBuilder` gains the featured-index parameter,
  beat logic otherwise untouched.
- `DailyReflectionWidget.swift`: per-beat view bodies swap to the new fields per
  the content spec. Deep links, dots, chips, prayer beats, `AccessoryWidgets.swift`
  untouched. Sample/placeholder entries show a reflection, not a title.
- Tests: existing 15 stay green (schedule tests updated for the new parameter);
  new tests for reflections decoding, essence-line rotation, and year-based gem
  rotation across the epoch boundary.

## New content stays in sync automatically (user requirement)

New journeys, deep dives, and pool verses must flow into the widget programmatically:

- **Build-time detection**: `generate_widget_daily.py` already runs as a build phase
  on every build and discovers new catalog entries/pool verses by itself. After the
  initial authoring completes, the build phase runs in `--require-full` mode, so a
  new journey/dive/verse **without** widget reflection lines FAILS THE BUILD with a
  message naming exactly what is missing. New content cannot silently ship with a
  bare-title widget; the requirement is enforced, not remembered.
- **Delta authoring workflow**: `make_reflection_batches.py --missing-only` emits
  input batches for ONLY the uncovered entries; one agent authors them, the merge
  script validates, the build goes green. One command to see the gap, one wave to
  close it.
- **At the source**: the `inside-the-surah` and `theme-deep-dive` skills gain a
  mandatory step - authoring the new journey's 2-3 widget essence lines is part of
  creating the journey itself, so the build gate normally never trips.

Authored copy cannot be machine-generated at build time (and should not be - it is
reviewed religious content); this detect-fail-author loop is the programmatic
guarantee around it.

## Authoring process and quality gates

Order: journeys first (worst offender, smallest set), then a pilot, then fan-out.

1. **Journey essence lines** (27 items, ~70 lines): agents read each journey's
   `Content/*.swift` and produce 2-3 lines, preferring narrations the journey
   already quotes (with citation). Waves of 2 agents max. Full user review.
2. **Pipeline + Swift wired end-to-end** with journeys + a ~25-verse pilot batch;
   build and device-check all three families to lock char caps.
3. **Per-verse fan-out**: remaining ~360 verses in batches of ~24, waves of 2.
   Agent input: verse Arabic + translation, gems, themeKey, occasion (sacred days
   are authored occasion-aware). Style guide in the prompt: anchored second-person
   voice, no theological claims beyond the verse/gems, no invented quotes,
   respectful death language, plain spelling, caps.
4. **Quality gates**: automated gate script (coverage, caps, diacritics, em dash,
   banned patterns) on every merge + in hydration; a quality-check agent pass per
   batch for tone and anchoredness; user spot-checks samples.
5. **Finish**: regenerate `widget_daily.json`, full test suite, device pass across
   families and beats.

## Out of scope

- Prayer beats, accessory widgets, schedule timing, deep-link scheme.
- Urdu/Arabic widget localization (schema is ready for it).
- Any premium signaling on the widget (standing rule: none, ever).
