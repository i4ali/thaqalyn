# Design: Daily Challenge

**Date:** 2026-06-21
**Status:** Approved (brainstorming → ready for implementation plan)
**Approach:** A — Standalone daily-challenge subsystem

A single, bite-sized, rotating challenge on the **Today** screen — playful, daily, and
habit-forming — built as a self-contained subsystem that reuses the app's existing
gamification primitives (sawab, badges) without touching the per-surah quiz system.

## Decisions (from brainstorming)

| Question | Decision |
|---|---|
| Core shape | **One rotating daily challenge** (a single ~30s item per day) |
| Content source | **New curated, broad pool** (Quran, du'a, Ahlul Bayt, events, practice) |
| Formats | **Multiple choice · True/False · Tap-to-flip flashcard · Complete-the-ayah** |
| Gamification | **Daily streak + sawab + badges** (reuse existing infra) |
| Translation | **Fully trilingual now** (EN authored → Urdu + Arabic via translator agents) |
| After completion | **Done-for-today recap** (result, sawab, streak, "come back tomorrow") |
| Implementation | **Standalone subsystem** (mirrors `DailyMessageProvider` / `DuasManager` / `QuizManager`) |

## Context: what already exists

- A full **per-surah quiz system** — `QuizModels.swift`, `QuizManager.swift`, `QuizView.swift`,
  and `quiz_1.json … quiz_114.json`. Multiple-choice + true/false, sawab, badges
  (`QuizBadgeType`), understanding levels. It is **not** daily, **not** on Today, and has **no**
  flashcard/fill-in formats. This new feature deliberately does **not** modify it.
- **Daily mechanics** to mirror: `DailyMessageProvider` (daily verse), `DuasManager` (du'a of
  the day), `ProgressManager` (reading streak + badges + stats).
- **Today screen:** `TodayView.swift` (legacy/light) + `EmeraldTodayView.swift` (Midnight
  Emerald). Flow: greeting → Daily Reminder → Continue Reading → Du'a of the Day.
- **Theming:** `Em*` components (`EmCard`, `EmGoldCTA`, `EmHeading`, `EmIconChip`, `EmType`),
  `ThemeManager` (`isMidnightEmerald`, gold accent `#D6B25E`).
- **Reading scale:** `ReadingSettingsManager.shared.scale` (steps `[0.9, 1.0, 1.15, 1.3, 1.5]`).
- **Localization:** `CommentaryLanguageManager.shared`; trilingual via parallel fields with
  English fallback (`Verse.displayTranslation`, `TafsirVerse.content`).
- **Persistence:** singleton managers + UserDefaults (JSON-encoded). Quiz results are local-only.

## 1. User experience

A new **Daily Challenge** card on the Today screen, in the daily-bites cluster
(after *Continue Reading*, before *Du'a of the Day* — placement easy to move):

- **Not done yet:** eyebrow "Daily Challenge", a teaser that hints the format ("Quick
  question" / "True or false?" / "Flip to learn" / "Complete the ayah"), a 🔥 streak chip
  when streak > 0, and a gold **Start** CTA.
- **Done for today:** calm completed state — ✓ "Done for today", whether they got it right,
  sawab earned, and "🔥 7 days — come back tomorrow." Not re-playable today.

**Start** opens a `DailyChallengeView` sheet rendering today's one item by format:

- **Multiple choice** — prompt (+ optional ayah in Arabic), tap option → lock + reveal
  correct/wrong + short explanation.
- **True / False** — statement → two buttons → reveal + explanation.
- **Flashcard** — front → tap to flip → back (answer + explanation) → "Got it" / "Review
  again" (both complete it; self-graded).
- **Complete the ayah** — phrase with a blank + word choices → reveal correct + explanation.

After answering: a small **+sawab** flourish, streak ticks up, sheet closes, card flips to
its done state.

## 2. New files

| File | Role |
|---|---|
| `Models/DailyChallengeModels.swift` | `DailyChallenge`, `DailyChallengeFormat`, `LocalizedText`, completion/streak/badge types |
| `Services/DailyChallengeProvider.swift` | Loads `daily_challenges.json`; picks today's item deterministically (mirrors `DailyMessageProvider`) |
| `Services/DailyChallengeManager.swift` | `@MainActor` singleton: completion state, streak, badges; awards sawab via existing system |
| `Views/DailyChallengeView.swift` | Interaction sheet (all four formats) |
| `Views/Cards/DailyChallengeCard.swift` | Today card — light (`warmInviting`) + Emerald variants |
| `Data/daily_challenges.json` | Curated trilingual content pool (drop-in synced folder — no pbxproj edits) |

Existing-file edits: insert the card into `TodayView.legacyContent` **and** `EmeraldTodayView`;
wire manager init alongside the other `.shared` managers.

## 3. Data model

One model covers all four formats via a `format` enum + optional fields:

```swift
enum DailyChallengeFormat: String, Codable {
    case multipleChoice, trueFalse, flashcard, fillInBlank
}

struct LocalizedText: Codable {          // app's existing parallel-field convention
    let en: String; let ur: String?; let ar: String?
    func text(for lang: CommentaryLanguage) -> String  // English fallback
}

struct DailyChallenge: Codable, Identifiable {
    let id: String                       // stable, e.g. "dc_001"
    let format: DailyChallengeFormat
    let topic: String                    // "quran" | "dua" | "ahlulbayt" | "event" | "practice"
    let prompt: LocalizedText            // question / statement / flashcard front / sentence-with-blank
    let options: [LocalizedText]?        // MC + fill-in only
    let correctIndex: Int?               // MC/fill-in → option index; trueFalse → 1=true,0=false; flashcard → nil
    let answer: LocalizedText?           // flashcard back
    let explanation: LocalizedText?      // shown after answering
    let arabicText: String?              // optional verse/du'a shown verbatim (never translated)
    let source: String?                  // optional citation, e.g. "Qur'an 2:255" (fixed-size chrome)
}
```

`correctIndex` conventions documented in-code. `daily_challenges.json` is an array of these.

## 4. Daily rotation

`DailyChallengeProvider` mirrors `DailyMessageProvider`: compute a day index from the calendar
day, pick `challenges[dayIndex % count]` (stable all day); `refreshIfDayChanged()` on app-active
across a date boundary. JSON authored **interleaved by format** so consecutive days feel varied.
Completion keyed by **date** (`yyyy-MM-dd`), not the item — done-state stays stable if the pool
changes.

## 5. Streak, sawab & badges

- **Streak** (`currentStreak`, `longestStreak`, `lastCompletedDayKey`): on completion, last =
  yesterday → +1; = today → no-op; else → reset to 1. Start-of-day math mirroring
  `ProgressManager`.
- **Sawab:** through the existing accumulator on completion. **+15 base, +10 if correct**
  (flashcards flat +15). Lighter than per-surah quiz (+50 base) since it's a daily nibble.
- **Badges:** dedicated `DailyChallengeBadge` set persisted like `QuizBadgeType` —
  `firstChallenge`, `streak7`, `streak30`, `streak100`. Unlock → brief celebratory flourish.

## 6. Persistence

UserDefaults + JSON, matching every other manager: `dailyChallengeStreak`,
`dailyChallengeLastCompletion` (today's result for the recap), awarded-badges set.
**Cloud sync out of scope for v1** (matches `QuizManager`, also local-only). Can later follow
`docs/BOOKMARK_SYNC_ARCHITECTURE.md` for cross-device streaks — flagged deliberately, not
silently skipped.

## 7. Theming, localization & text-scaling (CLAUDE.md compliance)

- `Em*` components + `ThemeManager` tokens; **both** light and Emerald card variants, like
  `DuaOfTheDayCard` / `EmDuaOfTheDayCard`.
- UI strings via `DailyChallengeStrings` keyed by `CommentaryLanguage`; RTL via
  `layoutDirection` + trailing alignment for ur/ar.
- **Reading content scales with `ReadingSettingsManager.scale`** — prompt, options, explanation,
  flashcard answer, verse/du'a — font size *and* line spacing. **Fixed (not scaled):** eyebrow,
  titles, source citations, badges, button labels (exactly the CLAUDE.md scope).

## 8. Error handling (CLAUDE.md: no fallbacks)

Missing/corrupt `daily_challenges.json` fails loudly like `DataManager` treats bundle data — no
placeholder question. The English fallback inside `LocalizedText` is **not** prohibited fallback
logic — it's the established localization convention (same as `Verse.displayTranslation`).

## 9. Content pool

Starter pool of **~80 items**, spread roughly evenly across the four formats and across topics
(Quran facts & meanings, du'as, Ahlul Bayt & the 14 Infallibles, key events, practice/ethics).
English authored first, then `urdu-translator` + `arabic-translator` agents fill Urdu + Arabic
for every `LocalizedText`. Narration/fact items get a cited source; v1 kept to well-established
facts. User reviews the pool before ship.

## 10. Verification (no XCTest, per project setup)

Gate = `xcodebuild` build (scheme `Thaqalayn`) + removable `#if DEBUG` preview matrix (four
formats × both themes × three languages × done/streak states), then a simulator pass including a
simulated day-rollover to confirm the streak.

## Out of scope for v1

- Cloud sync of streak/completion (local-only, like the existing quiz).
- "Practice more" / endless mode and a past-days archive (chose done-for-today recap).
- Surfacing badges in a dedicated achievements screen (award + persist + on-card flourish only).
- Personalized challenges tied to current reading (chose the curated pool).
