# Muharram Journey — Design

**Date:** 2026-05-17
**Status:** Approved (brainstorming complete)
**Author:** Design dialogue with project owner

## Summary

A seasonal **Muharram Journey** feature, a sibling of the existing Dhul-Hijjah
(Hajj) Journey and Ramadan Journey. It presents a 10-day reflective journey
through the **themes and values of Karbala**, culminating on Ashura (10 Muharram),
to support the user's azadari (mourning of Imam Husayn (AS)).

It mirrors the Dhul-Hijjah Journey's architecture file-for-file, but with
**somber tonal adaptations**: no completion celebration, no "Champion" badge,
"observed" rather than "completed" wording.

## Decisions (locked)

| Aspect | Decision |
|---|---|
| Scope | Muharram days 1–10 of content. Tab visible from late Dhul-Hijjah (m12, day ≥ 25) through Muharram day 12. Days 11–12 are a quiet grace period (no new content, somber status text) so the tab does not vanish on Ashura night (10th→11th). |
| Day spine | 10 themes/values of Karbala (arc below). Day 10 = Ashura. Reflective, not strict day-by-day chronology. |
| Tone | Somber tracking. Quiet "X of 10 days observed" indicator. "Mark as observed" toggle. **No** celebration overlay, **no** "Champion"/badge, **no** sawab bonus, **no** `ProgressManager` involvement. |
| Access | Day 1 free, Days 2–10 premium — exact parity with Hajj (lock UI + `PaywallView`). |
| Content authoring | Claude drafts the full `muharram_journey.json` from authentic Shia sources with per-entry source citations. Project owner reviews and corrects the content **before any Swift code is wired up** (Phase 0 gate). |
| Notification | **None.** No Ashura reminder. `NotificationManager.swift` and `ContentView.swift` are explicitly NOT touched. |
| Approach | Parallel duplication of the Hajj feature with tone adaptations (not a shared generic engine — rejected as risky over-engineering against a shipped feature, and inconsistent with the codebase's existing Ramadan/Hajj duplication convention). |

## The 10-theme content arc (draft — finalized in Phase 0 review)

1. Intention & awakening to Husayn's (AS) cause
2. Truth over comfort — the refusal of bay'ah to Yazid
3. Migration for principle (Medina → Mecca → Iraq)
4. Loyalty & true companionship (the Ansar of Husayn)
5. Patience (sabr) under trial — the water cut off
6. Dignity over humiliation ("hayhāt minna-dh-dhilla")
7. Sacrifice — the offering of sons and brothers
8. Steadfastness of the women — Sayyida Zaynab (AS)
9. The night of Ashura — worship and resolve (Layla Ashura)
10. **Ashura** — the supreme sacrifice and its eternal message ("every day is Ashura")

Each day carries: `theme`, `themeArabic`, `icon`, one `dua` (a dua or ziyarat
from Mafatih al-Jinan — incl. Ziyarat Ashura / Ziyarat Warith where fitting),
2–3 `verses` (Quranic references with relevance notes), `tafsirFocus`,
`reflection`. Sources cited per entry; reliable maqtal (e.g. al-Lohoof /
Nafasul Mahmoom) used for narrative grounding.

## Architecture

Mirrors the Dhul-Hijjah Journey (commit 3147740). Reference inventory of the
Hajj feature was used as the blueprint.

### New files
- `Thaqalayn/Data/muharram_journey.json` — 10-day content
- `Thaqalayn/Services/MuharramJourneyManager.swift` — `@MainActor` singleton; JSON load, progress persistence, annual reset
- `Thaqalayn/Views/MuharramJourneyView.swift` — header + `LazyVStack` of day cards
- `Thaqalayn/Views/MuharramDayDetailView.swift` — scrollable day detail

### Edited files
- `Thaqalayn/Models/QuranModels.swift` — Muharram models (below)
- `Thaqalayn/Services/IslamicCalendarManager.swift` — Muharram season API (below)
- `Thaqalayn/Services/PremiumManager.swift` — `canAccessMuharramDay(_:)`
- `Thaqalayn/Views/MainTabView.swift` — conditional Muharram tab, `tag(6)`
- `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift` — Muharram onboarding card
- `Thaqalayn/Views/ProgressRingsView.swift` — include Muharram in the shared seasonal-ring slot (quiet % only)

### Explicitly NOT touched
- `Thaqalayn/Services/NotificationManager.swift` (no notification)
- `Thaqalayn/ContentView.swift` (no notification scheduling)
- `Thaqalayn/Services/ProgressManager.swift` (no badge, no sawab)

### Data model (`QuranModels.swift`)

Shape-for-shape mirror of the Hajj models:

- `MuharramJourneyData { days: [MuharramDay] }`
- `MuharramDay { id, dayNumber, theme, themeArabic, icon, dua, verses, tafsirFocus, reflection }` (Codable, Identifiable)
- `MuharramDua { arabic, transliteration, english, source? }`
- `MuharramVerse { id, surahNumber, verseNumber, relevanceNote }` + `verseReference` computed
- `MuharramJourneyProgress { observedDays: Set<Int>, lastObservedDate: Date?, year: Int }` + `completionPercentage`. **No `isCompleted` badge trigger path.**

### Season detection (`IslamicCalendarManager.swift`)

- `isMuharramSeason()` → Dhul-Hijjah (month 12) day ≥ 25 (lead-in countdown) **OR** Muharram (month 1) day ≤ 12 (10 content days + 11–12 quiet grace). No overlap with Hajj (m12 day ≤ 13) or Ramadan (m8–10); mutually exclusive with both.
- `currentMuharramDay()` → 1…10 if month 1 and day ≤ 10, else nil (grace days 11–12 return nil — no "current day" highlight)
- `daysUntilMuharram()` → countdown during late Dhul-Hijjah (month 12): `max(0, 30 - day + 1)`
- `muharramSeasonStatus()` → "N days until Muharram" / "Day X of Muharram" / Day 10 → a mournful Ashura message (e.g. "Ashura — Ya Husayn"), **never "Mubarak"** / days 11–12 → somber grace text

### Manager (`MuharramJourneyManager.swift`)

Mirror of `HajjJourneyManager` minus the badge path:
- Load `muharram_journey.json` from bundle; throw clear error on failure (no fallback, per CLAUDE.md)
- `observedDays` persisted in `UserDefaults` key `muharramJourneyProgress`
- Annual reset keyed on Islamic year
- `markDayObserved(_:)` / `unmarkDayObserved(_:)`, `isDayObserved(_:)`, `completionPercentage`
- **Removed vs Hajj:** no `checkForCompletionBadge()`, no `ProgressManager` call, no `pendingBadge`

### Views

`MuharramJourneyView`: `AdaptiveModernBackground`, header (title, somber status from `muharramSeasonStatus()`, quiet "X of 10 days observed" — **no "Journey Complete!" line**), `LazyVStack` of day cards (number/observed-check/lock circle, theme + Arabic, current-day highlight only on days 1–10), hidden `NavigationLink` to detail. Reuses `ThemeManager`, AmiriQuran font, premium lock UI, `PaywallView` sheet.

`MuharramDayDetailView`: scrollable — day header, dua/ziyarat section, verses section (`MuharramVerseCard` with "Full Tafsir" → `SurahDetailView` deep link), tafsir focus, reflection, "Mark as observed" toggle. **Day 10 / Ashura gets a distinct somber visual treatment.**

### Tab integration (`MainTabView.swift`)

`private var isMuharramSeason` computed property; conditional tab `if isMuharramSeason { MuharramJourneyView().tabItem { Label("Muharram", systemImage: "flame.fill") }.tag(6) }`. Icon `flame.fill` (candle of remembrance) — adjustable.

### Premium (`PremiumManager.swift`)

`canAccessMuharramDay(_ dayNumber: Int) -> Bool` — `dayNumber == 1 ? true : isPremium`. Exact Hajj parity.

### Onboarding (`SeasonalFeaturesScreen.swift`)

`SeasonalFeatureExpandedCard` for Muharram, somber framing (remembrance of Imam Husayn (AS), azadari, ziyarat, 10-day reflective journey, track days observed).

### Shared seasonal progress ring (`ProgressRingsView.swift`)

Add Muharram to the existing mutually-exclusive seasonal-ring slot (Ramadan/Hajj/Muharram). Quiet completion % only, label "Muharram" — not celebratory.

## Verification approach

The iOS project has **no XCTest target**; the existing Ramadan and Hajj
features shipped without unit tests. Verification is therefore:

1. **Phase 0 content-review gate** — owner reviews `muharram_journey.json` and source citations; no Swift code wired until signed off.
2. Xcode build succeeds (target builds clean, no warnings introduced).
3. Manual season-window check via a temporary Hijri date override (verify tab appears/disappears at the right boundaries: m12 d25 on, m1 d12 last visible, d13 off; current-day highlight only d1–10; mutual exclusivity with Ramadan/Hajj).
4. Manual content/tone pass in the running app (somber wording, no celebration, Day-10 Ashura treatment, premium lock on days 2–10, Day 1 free).

No fallback logic anywhere (CLAUDE.md): JSON load failure throws a clear error.

## Out of scope / YAGNI

- No shared generic "SeasonalJourney" engine refactor.
- No notification of any kind.
- No badge / sawab / celebration / `ProgressManager` integration.
- No streak features (the `lastObservedDate` field exists for parity/future, unused in UI).
- No extension to Arba'een / full 40-day arc.

## Sequencing

- **Phase 0:** Draft `muharram_journey.json` + a human-readable content review doc with per-entry source citations. **Owner sign-off gate.**
- **Phase 1+:** Models → season API → manager → views → tab/premium/onboarding/ring wiring → build + manual verification.

(Detailed phased plan produced by the writing-plans step.)

## Notes

- Per owner preference, design docs and code are **not auto-committed**; the owner commits.
