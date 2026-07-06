# Daily Challenge expansion (72 -> 365) - COMPLETE

**Done 2026-06-30.** `Thaqalayn/Data/daily_challenges.json` is now 365 (dc_001-072 preserved
byte-for-byte; dc_073-365 appended, trilingual, interleaved by format+topic). Built by
`assemble.py` from `daily_challenges_wip.json`; `validate.py` passes (0 errors). Not committed.
This file documents how it was built; the notes below are the original resume plan.
Design rationale: `docs/plans/2026-06-29-daily-challenge-expand-365-design.md`.

## Goal
Append 293 new questions (`dc_073`-`dc_365`) to `Thaqalayn/Data/daily_challenges.json`,
keeping the existing 72 (`dc_001`-`dc_072`) byte-for-byte unchanged. Full trilingual
(en/ur/ar), conservative well-attested Twelver Shia facts.

## Single source of truth
**`scripts/challenges/daily_challenges_wip.json`** - a JSON array of 293 entries, each:
`{n, format, topic, prompt_en, options_en, correctIndex, answer_en, explanation_en,
arabicText, source, ur, ar}` where `ur`/`ar` are `{prompt, options, answer, explanation}`
or `null` if not yet translated. `n` is the stable 0..292 index.
(`_scratch_backup/` is a raw copy of the working files as a fallback.)

## Status
- English: all 293 authored, validated, exact + semantic dedup done (0 issues).
- Translation: **n0-256 fully done (ur+ar) = 257/293**. Remaining: **Arabic for n257-292** (chunks `batch_8b/8c/8d_en.json`, 12 each) + **Urdu for n280-292** (`batch_9_en.json`, 13). Urdu for n257-279 already done.
  - Batch-size caps: Urdu <= ~35 objects; **Arabic on Qur'an-content (n253+) must be <= ~12 objects** with minimal prose tashkeel - else it blows the 32k output-token cap (it failed at 35 and 59).
  - Run one agent at a time (user request for this task; CLAUDE.md standing rule is max two).
  - Use the dedicated `urdu-translator` / `arabic-translator` agents. Conventions: localized
    numerals (ur ۰-۹ / ar ٠-٩), keep `ﷺ`, render `(a)` as علیہ السلام/عليه السلام etc.,
    keep `____` blanks, render answer-revealing prompts so they stay fair questions.

## Steps to finish
1. From `daily_challenges_wip.json`, gather entries where `ur` or `ar` is null (n175..292).
   Split into <=35-object chunks; translate each via the specialist agent; fill `ur`/`ar` back in by `n`.
2. Verify every entry has non-null `ur` and `ar`, option arrays same length as `options_en`, no empties.
3. **Assemble** the final objects (build `LocalizedText {en,ur,ar}` for prompt/options/answer/explanation;
   carry over format/topic/correctIndex/arabicText/source). Then **interleave by format**
   (round-robin MC -> trueFalse -> flashcard -> fillInBlank, rotating topic) and assign ids
   `dc_073`..`dc_365`.
4. Load existing `Thaqalayn/Data/daily_challenges.json` (72), append the 293, write back with
   `json.dump(..., ensure_ascii=False, indent=2)` and NO trailing newline (verified byte-identical
   round-trip for the existing 72).
5. Write & run `scripts/challenges/validate.py` (mirror of the Swift `DailyChallenge` decode contract):
   count==365, ids unique/sequential, per-format schema (MC=4 opts/idx 0-3; fillInBlank=3 opts/idx 0-2;
   trueFalse no opts/idx in {0,1}; flashcard has answer/no idx), correctIndex in range, trilingual
   completeness (non-empty en/ur/ar everywhere), no duplicate normalized prompts, valid topics.
6. Do NOT commit (user commits). No xcodebuild needed (data-only; file already bundled).

## Targets (full bank of 365)
Topics: quran 100, ahlulbayt 95, practice 70, event 55, dua 45.
Formats stay ~even (MC 100 / TF 93 / FC 97 / FIB 75) so the daily rotation varies; that is why
step 3 interleaves formats when assigning ids. Indexing is `dayOfYear % 365` -> each shown once/year;
no code change (user chose "expand", not "re-index").
