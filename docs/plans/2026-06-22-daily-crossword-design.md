# Daily Crossword — Design

_Status: IMPLEMENTED on branch `daily-crossword` (2026-06-22) — builds green, runs on simulator (uncommitted). Mockups in `mockups/daily-crossword/`; content pipeline in `scripts/crossword/`. The cloud-sync phase was dropped (local-only). Later change (2026-06-22): both this feature AND Daily Challenge are now **streak-only** — sawab + badges removed per the user (a word game shouldn't earn sawab); the 🔥 streaks are kept. So the "Rewards" sections below are superseded — no sawab, no badges._

## Goal

Add a **Daily Crossword** as a new daily-engagement feature alongside the existing Daily
Challenge — a compact, all-thematic mini puzzle that reinforces Islamic vocabulary
(Qur'an, Ahlul Bayt, practice, history, places) and feeds the app's streak/sawab/badge loop.

## Puzzle model — all-thematic criss-cross

A true fully-interlocked 5×5 crossword is a **word-square** and requires thousands of
5-letter words; with curated Islamic terms (even padded with ~80 wholesome English words)
it is infeasible (0 valid grids — see `mockups/daily-crossword/content/feasibility.py`).

We therefore use a **criss-cross / word-cross**: ~6 interlocking words with clean black
space around them, every answer a real term from the bank. Footprint stays compact
(~5–7 cells per side), phone-friendly. Prototype: `crisscross.py` → `board_crisscross.png`.

- Grid letters: **Latin / transliterated** (SALAH, IMAM, KAABA…) → standard A–Z keyboard.
- ~6 answers/puzzle, mixed lengths 3–6, all from the curated bank.
- Not every cell is a crossing (that's what makes curated content feasible).

## Placement & UX

Mirrors the Daily Challenge pattern (`DailyChallengeCard` / `DailyChallengeView`).

1. **Today card** (`DailyCrosswordCard`) — a standalone `EmCard` under the Daily Challenge
   card in `TodayView` / `EmeraldTodayView`. Three states (reuse the existing pattern):
   - **Locked** (free user) → taps to `PaywallView`.
   - **Pending** (premium, not done) → taps to play sheet; subline shows `🔥 streak · teaser`.
   - **Done** (premium, solved today) → non-tappable; shows streak + sawab earned.
   - Chrome is fixed-size (no `ReadingSettingsManager` scaling), like `DailyChallengeCard`.
2. **Play screen** (`DailyCrosswordView`, sheet) — the grid, a tap-to-select cell + on-screen
   A–Z keyboard, a clue bar with ‹ › to move between entries, active answer highlighted in
   gold, 🔥 streak + timer in the header. Mockup: `mockups/daily-crossword/board.png` (centre phone).
3. **Solved screen** — gold seal, time, streak, **+sawab**, optional milestone badge unlock,
   "Done" CTA. Reuses `ProgressManager` rewards.

Theme: Midnight Emerald via `Em*` components (`EmCard`, `EmIconChip`, `EmGoldCTA`,
`EmPressStyle`, `EmType.serif`), gold-on-emerald palette, `Haptics.press()` feedback.
Light theme: legacy variant, mirroring `DailyChallengeCard.legacyCard`.

## Content pipeline

- **`bank.json`** — curated terms: `{answer (A–Z), clue_en, clue_ur, clue_ar, theme}`.
  EN authored now (~96 terms); UR/AR via `urdu-translator` / `arabic-translator` agents.
- **Generator** (`crisscross.py`) — assembles valid criss-crosses; clean placement
  (≥1 crossing, no parallel touching, free ends → every run is a real word).
- **Pre-generate & bundle**: produce a large batch (≥365 distinct) offline → `daily_crosswords.json`
  bundled in `Thaqalayn/Data/`. **No on-device generation.**
- **Daily selection**: deterministic by day-of-year (same puzzle for everyone on a given day),
  exactly like `DailyChallengeProvider` (`dayOfYear % count`, cached, `refreshIfDayChanged()`).

## Swift architecture (mirrors Daily Challenge)

- **Models** `DailyCrosswordModels.swift`: `DailyCrossword` (id, size, cells, entries),
  `CrosswordEntry` (number, direction, answer, clue `LocalizedText`, cells), `CrosswordCell`
  (row, col, solution, number?), `DailyCrosswordCompletion` (dayKey, time, sawab), `DailyCrosswordStreak`.
- **`DailyCrosswordProvider.swift`** — loads `daily_crosswords.json`, exposes `today`, `refreshIfDayChanged()`.
- **`DailyCrosswordManager.swift`** (`@MainActor`) — completion, streak, sawab; awards badges via
  `ProgressManager`; persists to `UserDefaults`; cloud sync per
  `docs/BOOKMARK_SYNC_ARCHITECTURE.md` (match how Daily Challenge persists/syncs).
- **Views** `DailyCrosswordCard.swift`, `DailyCrosswordView.swift`, `DailyCrosswordStrings.swift`
  (trilingual UI strings via `CommentaryLanguageManager`, RTL-aware).
- **Gating** `PremiumManager.canAccessDailyCrossword()` → `isPremium`.
- **Rewards** new `BadgeType` cases for crossword milestones (first solve, 7/30/100-day streak);
  sawab on solve. Separate crossword streak from the challenge streak.

## Open implementation questions (resolve in plan)

- Clue text scaling: treat as UI chrome (fixed) like Daily Challenge prompts, or scale with
  `ReadingSettingsManager`? Lean fixed for parity; confirm.
- Hints (reveal letter/word) and their sawab impact — include v1 or defer.
- Exact bundle size / refresh cadence for the pre-generated set; repeat policy after the set cycles.
- Onboarding teaser screen (defer to a later pass; Daily Challenge has one).

## Out of scope (v1)

Arabic-script grids, user-created puzzles, leaderboards, multiplayer.
