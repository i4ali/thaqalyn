# Surah Experience ("Inside the Sūrah") - Design Spec

**Date:** 2026-07-07
**Status:** Approved design, pending implementation plan
**Feature:** An immersive per-surah experience, sibling to the theme Deep Dives (Yaqīn, Ṣabr), that reveals a surah's soul as a guided narrative descent.

## 1. Purpose

When a user opens the experience for a surah, it takes them on a guided narrative journey: what this surah is really about, its central theme and arc, told as a story through its landmark verses and the best gems from the tafsir. The user comes away *understanding* the surah as a whole, not verse-by-verse.

The content is a package assembled after deep understanding of the ENTIRE surah - every verse's tafsir digested - so one dive delivers concentrated value. This is an understanding experience, not a devotional one: there is no closing duʿā beat (that belongs to the theme dives).

## 2. Decisions summary

| Decision | Choice |
|---|---|
| Core purpose | Reveal the surah's soul (guided narrative journey) |
| Coverage | 4 pilots: Yūsuf (12), Yāsīn (36), Al-Raḥmān (55), Al-Mulk (67); validate before scaling |
| Format | Same `DeepDiveView` engine; acts come from the surah's own movements |
| Content model | Narrative descent (mirrors the proven Ṣabr template), minus the duʿā, plus a new closing beat; depth varies with surah size |
| Content source | Tafsir-grounded, hand-crafted; distilled from the app's own 5-layer tafsir data, polished to the Yaqīn/Ṣabr bar, user approves each script |
| Placement | Journeys hub (new third section) + split-row strip on that surah's row in the Quran-tab list (mockup: `mockups/surah-experience/option-e-splitrow.png`). No entry inside `SurahDetailView` itself |
| Gating | All four premium (`PremiumManager`), Premium chip, no lock icons |
| Naming | Hub section header "Inside the Sūrah"; card eyebrow "SŪRAH JOURNEY" |

## 3. Architecture

Zero engine changes except one new closing beat. Each surah experience IS a `DeepDive` value.

### Model
- Reuse `DeepDive` / `DeepDiveSection` (Thaqalayn/Models/DeepDive.swift) as-is.
- The existing beat types (`open, orientation, verse, depths, act, narration, climax, reflectionPrompt`) express the narrative-descent template. The `dua` beat is NOT used by surah experiences.
- **New beat type: `closing`** - the final screen. Restates the surah's name and essence, offers **"Read the full sūrah"** as the primary action (dismisses the dive and opens `SurahDetailView` for that surah) and a plain "Done" to close. Rendered by `DeepDiveView`; Yaqīn/Ṣabr are untouched (they keep their `dua` ending).
- Acts are the surah's own movements (e.g., Yūsuf: The Dream / The Test / The Reunion) via the existing `ActInfo`.

### Content files
- One Swift file per surah in `Thaqalayn/Content/`: `SurahYusufDive.swift` (`extension DeepDive { static let surahYusuf }`), likewise `SurahYasinDive.swift`, `SurahRahmanDive.swift`, `SurahMulkDive.swift`.
- Xcode synced folders: drop files in, no pbxproj edits.

### Catalog
- New `Thaqalayn/Services/SurahExperienceCatalog.swift` with a `SurahExperienceDescriptor` mirroring `DeepDiveDescriptor`:
  - `id` (e.g., `surah-yusuf`), `title: LocalizedText`, `titleAr`, `sfSymbol`, `subtitle: LocalizedText`, `available: Bool`, `dive: DeepDive?`
  - Plus `surahNumber: Int` for the surah-header lookup (`bySurahNumber(_:)`).
- Kept separate from `DeepDiveDescriptor.all` so theme dives and surah experiences don't mix in one registry.

### Discovery
1. **Journeys hub** (`JourneyHubView`): a third section under Deep Dives, header "Inside the Sūrah". Cards follow the `DeepDiveCard` pattern (thin variant showing the surah's Arabic name + number), eyebrow "SŪRAH JOURNEY", Premium/Soon pills as applicable. Tap → same `fullScreenCover` → `DeepDiveView`.
2. **Quran-tab surah list** (`HomeView`): for surahs 12/36/55/67 with a built experience, the surah's list card grows an attached strip below the main row - moon icon, "INSIDE THE SŪRAH" eyebrow, "An immersive journey", PREMIUM chip, chevron (chosen from mockups: `mockups/surah-experience/option-e-splitrow.png`). The main row still opens the surah; the strip opens the experience directly from the list. Premium check applies on the strip. There is NO entry point inside `SurahDetailView` itself - the list strip and the hub are the two paths.

### Gating
- `PremiumManager.canAccessSurahExperience(id)`: requires `isPremium` for all four pilots.
- Premium chip in the app's accent style on cards and the surah-header banner; never a lock icon. Locked taps route to `PaywallView`.
- Deep-link support follows the Deep Dive pattern if/when needed (ids are stable).

### What's New
- One entry in `WhatsNewCatalog.all` (Thaqalayn/Models/WhatsNewItem.swift) with EN/UR/AR title/blurb/CTA and a new `WhatsNewDestination` case routing to the Journeys hub's new section (handled once in `WhatsNewCard.open()`).

### Persistence
- None. In-memory `@State` only, resets on dismiss - matching Deep Dives.

## 4. Content model - the beat template

**Depth scales with the surah.** The template below is a grammar, not a fixed count. Beat count, verse-beat count, and movement count vary with the surah's size and richness:

- Short surahs (Mulk): ~10-13 beats, ~4 verse beats, ~7-8 minutes.
- Long/rich surahs (Yūsuf, Yāsīn): ~16-24 beats, ~6-10 verse beats, ~15-20 minutes.
- Movements default to 3; a surah that genuinely demands 4+ may use more. The model supports it (`acts: [ActInfo]` is an array; sections carry an `act: Int`), but the `DeepDiveView` stepper/act-mapping assumes 3 movements (close = act 4) and needs a small generalization check during implementation before any dive uses a non-3 count.
- The distillation step (section 5) proposes each surah's depth (beat count, movements, landmark verses) in the surah brief; the user approves it with the script.

Baseline shape, one screen per beat on the scroll-snap descent:

1. **OPEN** - a single-image hook that drops the user into the surah's world.
2. **ORIENTATION** - why the surah came down (revelation context), what it claims to be, and its faḍāʾil in one breath (e.g., Yāsīn: "the heart of the Qur'an"). Only faḍāʾil we can cite; no invented virtues.
3. **ACT I** divider - first movement, named from the surah itself, with a bridge verse.
4. **VERSE** beats (4-10 across the acts, scaled to the surah) - each landmark ayah with real recitation audio (`VerseRecitationButton`) + its single best tafsir gem distilled to one screen.
5. **DEPTHS** - the "map of the surah": 3 expandable stations showing its arc (e.g., Yūsuf: three descents, three rises).
6. **ACT II / ACT III** dividers - the descent continues.
7. **NARRATION** - one verified Ahlul Bayt narration about the surah or its heart, with citation.
8. **CLIMAX** - the payoff: the surah's soul stated in one unforgettable line.
9. **REFLECTION PROMPT** - turns the theme on the reader.
10. **CLOSING** - quiet outro restating the surah's name and essence; primary action "Read the full sūrah" (→ `SurahDetailView`), secondary "Done".

No DUA beat. No TTS Listen button is needed anywhere (no duʿā/ziyārat text is displayed; verse beats use real recitation).

Example arc (Yūsuf): OPEN "A boy tells his father a dream..." → ORIENTATION (Year of Sorrow; "the most beautiful of stories") → ACT I The Dream (12:4) → DEPTHS map → VERSE the well/the shirt (12:18) → ACT II The Test (12:24, the burhān) → VERSE prison (12:42) → VERSE the king's dream → ACT III The Reunion (12:92 "no blame upon you today") → NARRATION Imam al-Ṣādiq (as) on Yūsuf's forgiveness (ʿIlal al-Sharāʾiʿ) → CLIMAX → REFLECTION → CLOSING.

## 5. Authoring workflow (per surah)

The defining requirement: **the package is built from total understanding of the surah.** The distillation step must digest every verse's full tafsir - all 5 layers (foundation, Al-Mizan/Tabatabai, Makarem Shirazi, Ahlul Bayt narrations, comparative) - not just the eventual landmark verses. The dive is the concentrated result of that full read.

1. **Distill** - an agent reads the surah's complete `tafsir_{N}.json` (every verse, all layers; large surahs may need chunked passes) plus `quran_data.json`, and produces a *surah brief*: the arc, candidate landmark verses ranked with rationale, the best gem per candidate verse with layer/source attribution, candidate Ahlul Bayt narrations with citations, revelation context, citable faḍāʾil.
2. **Draft** - from the brief, the full English beat script is written: hand-polished narrative copy at the Yaqīn/Ṣabr bar, not pasted tafsir.
3. **User approves** each surah's English script in chat before any Swift is written.
4. **Translate** - Urdu + Arabic via the existing translator-agent pattern; Qur'anic Arabic taken verbatim from `quran_data.json` and validated against it; narration citations preserved in all three languages.
5. **Build** - the approved script becomes the `extension DeepDive` content file.

Agents run in waves of at most two (Yūsuf + Yāsīn, then Raḥmān + Mulk).

### Editorial rules
- Every verse beat anchored to a single surah:ayah for recitation.
- No em dashes anywhere in copy.
- All reading copy scales with `ReadingSettingsManager.shared.scale`; chrome (labels, eyebrows, refs, pills) stays fixed.
- Sources cited for every narration and every faḍāʾil claim; verified Yūsuf narrations with sources are already on file.
- Trilingual EN/UR/AR via `LocalizedText`; card chrome strings via `JourneyStrings`.

## 6. Verification

- Gate = green `xcodebuild` (scheme Thaqalayn, standard destination). No test target.
- User performs simulator install/launch/visual verification themselves.
- Content gate = user approves each surah's English script in chat before translation and build.
- `#Preview` blocks wrapped in `#if DEBUG` (Archive-safe).

## 7. Rollout

1. Engine-side plumbing (closing beat, catalog, hub section, surah-header banner, gating, What's New) ships with the first approved surah.
2. Content lands surah by surah: **Yūsuf first** (strongest narrative fit, verified narrations on file), then Yāsīn, then Raḥmān + Mulk.
3. After the first, each surah is a content-only change (one Swift file + a catalog flag), exactly like adding Ṣabr was.

## 8. Out of scope

- Progress/completion persistence.
- Audio ambience or verse-art imagery.
- The other 110 surahs (pending pilot validation).
- Any `SurahDetailView` (reading-view) changes; the surah-side entry lives on the list row only.
- Duʿā/TTS ending (deliberately excluded for this format).
