# Drop transliteration diacritics from English (Journey area - phase 1)

Date: 2026-07-09
Status: Approved (design), pending implementation plan

## Goal

Remove academic Arabic transliteration diacritics from **English-facing** text in the app, because the user finds them visually undesirable (e.g. the "What's New" card reading "Sūrah Āl ʿImrān"). This is **phase 1**, scoped to the Journey area (the whole immersive surface). Later phases extend the same tool to the rest of the app. Arabic and Urdu content is **out of scope** and must remain untouched.

## Decisions (locked with the user)

1. **Scope** = the whole journey/immersive area, so no half-stripped state where a card reads "Sūrah Āl ʿImrān" while the screen inside reads "Surah Al Imran".
2. **ʿayn (`ʿ`) / hamza (`ʾ`)** = convert to a straight apostrophe `'` when it sits **between two letters**, otherwise **remove** (dropped at word start/end, since `'Imran` looks wrong).
3. **Clipped spellings** = apply a short **curated exception list** for words whose mechanical result reads non-standard (e.g. `ʿĪd`→`Eid`, not `Id`). The user reviews and approves the list **before** anything is applied. Everything else is a pure mechanical strip.
4. **Pronunciation guides** = the romanized `transliteration` / `tr:` fields are stripped too, for a consistent diacritic-free look.

## Approach

A single reusable, checked-in Python script: `scripts/strip_diacritics.py`. Hand-editing ~1,600 occurrences across ~20 files is slow and guarantees inconsistency (the same token, e.g. `al-Ṣādiq`, recurs across 4+ files). A tested script also makes phase 2 (rest of the app) a matter of pointing it at more files.

The script has two modes:
- **Report mode** - extract every unique diacritic-bearing token in the in-scope files and print `original → mechanical result`. Used to build the exception list for user review. Writes nothing.
- **Apply mode** - apply approved exceptions (whole-word) first, then the mechanical character rules, then write files back as UTF-8 verbatim.

## Character rules

| From | To |
|---|---|
| `ā Ā` `ī Ī` `ū Ū` | `a A` `i I` `u U` (drop macron) |
| `ḥ Ḥ` `ṣ Ṣ` `ḍ Ḍ` `ṭ Ṭ` `ẓ Ẓ` | `h H` `s S` `d D` `t T` `z Z` (drop underdot) |
| `ʿ` ayn (U+02BF), `ʾ` hamza (U+02BE) | straight `'` when between two letters; removed at word boundaries |

Uppercase `Ḍ`/`Ẓ` are not currently present but are mapped anyway for robustness in later phases.

Worked examples:
- `Sūrah Āl ʿImrān` → `Surah Al Imran`
- `Qurʾān` → `Qur'an`
- `duʿāʾ` → `du'a`
- `Shīʿa` → `Shi'a`
- `Karbalāʾ` → `Karbala`
- `al-Anʿām` → `al-An'am`
- `Allāhumma ṣalli ʿalā Muḥammad` → `Allahumma salli ala Muhammad`

"Between two letters" uses the Unicode letter property, so it holds regardless of whether adjacent macron/underdot letters are stripped first (`ā` and `a` are both letters).

## Curated exceptions

Built from real data, not assumptions (e.g. `Kaʿba` turned out not to even be present in the journey content). Report mode surfaces the candidate tokens; the reviewed exception table (originals → conventional spelling) is applied as whole-word, case-aware replacements before the mechanical pass. Known anchor: `ʿĪd`→`Eid`, which already matches the house spelling used plainly in `hajj_journey.json` and `ramadan_journey.json`.

## Scope (file list)

Seasonal journeys (JSON, `Thaqalayn/Data/`):
- `ramadan_journey.json` (0 diacritics), `hajj_journey.json` (0), `muharram_journey.json` (2), `fatimiyya_journey.json` (167), `arbaeen_journey.json` (147)

Deep Dives + Inside the Sūrah (inline Swift, `Thaqalayn/Content/`):
- `YaqinDeepDive.swift`, `SabrDeepDive.swift`
- `SurahFatihaDive.swift`, `SurahBaqaraDive.swift`, `SurahAliImranDive.swift`, `SurahYusufDive.swift`

Chrome / catalogs / onboarding / spotlights:
- `Services/DeepDiveCatalog.swift`, `Services/SurahExperienceCatalog.swift` (incl. coming-soon card copy)
- `Views/Onboarding/DeepDiveScreen.swift`, `Views/Onboarding/SurahExperienceScreen.swift`
- `Views/DeepDive/DeepDiveView.swift` (the two `"Āmīn"` UI strings only)
- `Models/WhatsNewItem.swift` (journey/sūrah entries - includes the card that prompted this work)
- `Utilities/JourneyStrings.swift`

## Safety

- **Arabic/Urdu untouched by construction.** The script rewrites only the specific Latin codepoints above. Real Arabic/Urdu script is in U+0600-06FF, a different block, so `arabic:`, `titleAr:`, and real `ur:`/`ar:` fields cannot be affected. This is also what guarantees "English only." (Yūsuf's `ur/ar` are English placeholder duplicates and will strip too, which is intended.)
- **No Unicode normalization.** Targeted `.replace()` only, UTF-8 written verbatim - no NFC normalization - protecting the authored verse Arabic that must stay byte-identical to `quran_data.json`.
- **Existing apostrophes left alone.** Only ayn/hamza are converted. Prose possessives/contractions (mixed straight/curly in the repo today) are not diacritics and are not touched. New conversions use straight `'`. The pre-existing curly/straight inconsistency is noted as optional future cleanup, not bundled here.

## Verification

1. `xcodebuild` (scheme Thaqalayn, `id=` destination) - confirm nothing broke.
2. `grep` - confirm zero target diacritics remain in the in-scope files (minus any deliberate keeps).
3. Byte-diff the `arabic:` fields before/after - prove they are unchanged.
4. Eyeball the diff of the two densest files (`SurahAliImranDive.swift`, `fatimiyya_journey.json`).

Visual QA in the simulator is done by the user.

## Gate before any file changes

Hand the user the report-mode output + proposed exception table for sign-off. Only then apply, build, and report diff stats.

## Later phases (out of scope now)

Same script, pointed at the rest of the app: tafsir JSONs, daily challenges/duas/foods, prophetic parallels, and remaining views. Urdu/Arabic transliteration handling (if ever wanted) would be a separate decision.
