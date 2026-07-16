# Daily Challenge: expand the question bank to 365

Date: 2026-06-29

## Motivation

The Daily Challenge selects the day's question with `index = dayOfYear % all.count`
(`DailyChallengeProvider.swift:61-62`). With only **72** questions
(`Thaqalayn/Data/daily_challenges.json`), the bank repeats every **72 days** - a daily
user sees each question ~5x per year. The Daily Crossword, by contrast, has **365**
puzzles (`index = dayOfYear % 365`) and repeats only annually. This closes that gap so
the challenge matches the crossword's once-a-year cadence.

## Decisions (confirmed with user)

1. **Accuracy:** conservative, well-attested Shia facts only - same bar as the existing
   72. Cite Qur'an / well-known hadith where natural; avoid contested or obscure claims.
2. **Languages:** full trilingual (en + ur + ar) for every field, matching the existing 72.
3. **Scope:** keep `dc_001`-`dc_072` byte-for-byte unchanged; append `dc_073`-`dc_365`
   (293 new questions).

## Why 365 (no indexing change)

At exactly 365, `dayOfYear` (1..365) maps to indices 1,2,...,364,0 - every question is
shown **exactly once per year**, matching the crossword. No code change required. Two
pre-existing quirks remain (identical to the crossword, accepted as-is):
- `dc_001` only surfaces on day-of-year 365.
- A leap year's Dec 31 (`366 % 365 = 1`) repeats Jan 1's question once.

The user chose "expand," not "re-index," so `DailyChallengeProvider` is untouched.

## Schema (from `DailyChallengeModels.swift`)

Each `DailyChallenge`: `id`, `format`, `topic`, `prompt` (LocalizedText), optional
`options` ([LocalizedText]), optional `correctIndex` (Int), optional `answer`
(LocalizedText), optional `explanation` (LocalizedText), optional `arabicText` (String,
verbatim - never translated), optional `source` (String). `LocalizedText` = `{en, ur?, ar?}`
with English fallback. Per-format contract:
- `multipleChoice`: 4 options, `correctIndex` in 0..3, no `answer`.
- `fillInBlank`: 3 options, `correctIndex` in 0..2, no `answer`.
- `trueFalse`: no options, `correctIndex` in {0,1} (1 = true), no `answer`.
- `flashcard`: no options, no `correctIndex`, has `answer`.

## Target distribution (full bank of 365)

| Topic | Now | Add | Total |   | Format | Now | Add | Total |
|-------|----:|----:|------:|---|--------|----:|----:|------:|
| quran      | 20 | 80 | 100 |   | multipleChoice | 18 | ~74 | ~92 |
| ahlulbayt  | 18 | 77 |  95 |   | trueFalse      | 18 | ~73 | ~91 |
| practice   | 11 | 59 |  70 |   | flashcard      | 18 | ~73 | ~91 |
| event      | 14 | 41 |  55 |   | fillInBlank    | 18 | ~73 | ~91 |
| dua        |  9 | 36 |  45 |   |                |    |     |     |
| **Total**  | 72 | 293| 365 |   |                |    |     | 365 |

Formats are kept roughly even so the final ID ordering can rotate
`MC -> TF -> flashcard -> fillInBlank` and keep day-to-day variety (the existing 72
already follow this rotation). Format mix is biased per topic where it fits content
better (fill-in-blank concentrated in quran/dua for ayat/duʿā phrases).

Sub-buckets for breadth: quran (structure/meta-facts; named ayat & Qur'anic figures);
ahlulbayt (the 14 Infallibles, biographical facts, titles, works); practice (salah,
taharah/wudu/ghusl, sawm, hajj, zakat, khums); event (Islamic-calendar dates & historical
events); dua (famous duʿās/ziyārāt, their context and key phrases).

## Generation pipeline

1. **Author English** via ~10 parallel dedupe-aware subagents, each owning a
   non-overlapping topic/sub-bucket and given the full list of existing 72 prompts +
   one exemplar per format. Each writes an English-only intermediate JSON
   (`prompt_en`, `options_en`, `correctIndex`, `answer_en`, `explanation_en`,
   `arabicText`, `source`) to the scratchpad. Arabic verse/duʿā text is authored
   verbatim here (never machine-translated).
2. **Checkpoint:** consolidate, run a dedupe + count check, show the user a sample +
   stats before spending translation effort.
3. **Translate** to Urdu + Arabic via the dedicated `urdu-translator` /
   `arabic-translator` agents in batches, matching the existing 72's conventions
   (localized numerals, transliteration-plus-gloss, honorifics, verbatim Arabic).
4. **Assemble** final objects (build `LocalizedText` from en/ur/ar), round-robin
   interleave by format (then topic), assign ids `dc_073`-`dc_365`, and append to
   `daily_challenges.json` (the 72 preserved; re-dump verified byte-identical for them).
5. **Validate** with a new `scripts/challenges/validate.py` (mirrors the crossword
   validator): count == 365, ids unique & sequential, per-format schema, `correctIndex`
   ranges, trilingual completeness (non-empty en/ur/ar everywhere), no duplicate
   normalized prompts, valid topics.

## Gates

- `scripts/challenges/validate.py` passing is the gate (mirrors the Swift decode
  contract + our trilingual requirement). No XCTest. No code changed, so no build risk
  from new files; data file is already bundled and edited in place.
- Design doc saved here; not committed (user handles commits).
