# Daily Verse: diversity redesign

**Date:** 2026-07-14
**Status:** Approved, ready for implementation planning
**Mockup:** `mockups/daily-verse-diversity.html` (+ `.png`)

---

## Problem

The daily verse notification repeats constantly.

The pool (`Thaqalayn/Thaqalayn/Data/islamic_month_verses.json`) holds **4 verses per Islamic month** (5 for Ramadan and Dhul-Hijjah), 50 entries total, 48 of them unique. The picker is a modulo over that month's list:

```swift
// NotificationManager.swift:126
let verseIndex = (dayOfMonth - 1) % monthData.verses.count
```

With 4 verses in a 29 to 30 day Hijri month, that is a **four-day loop**, running about seven times a month, and identical again the following year. Selection is a pure function of (Hijri month, Hijri day). There is no randomness, no shuffle, and no record of what has already been shown.

It is worse than four. Muharram's four are 3:169, 2:154, 3:195 and 22:58. The first two are near-paraphrases of each other ("they are not dead, they are alive with their Lord") and 22:58 repeats the same promise of provision for the slain. Functionally the user is told **two ideas**, over and over, for a month.

### Second problem found during the survey

The app has **two unrelated daily-verse systems that never agree**:

| Surface | Pool | Selection | Repeat period |
| --- | --- | --- | --- |
| Push notification | `islamic_month_verses.json` (50 refs) | Hijri month, then `(day - 1) % 4` | 4 days |
| Today tab card | `daily_messages.json` (30 verses) | Gregorian `dayOfYear % 30` | 30 days |

On any given day these show the user **two different "verses of the day"**, and both loop. The Today card's pool also inlines its own `arabic` + `english` and carries no Urdu at all.

### Two structural bugs in the same path

- **The 7-day cliff.** Notifications are scheduled as a rolling 7-day window (`daily_verse_0` through `daily_verse_6`), refreshed only when the app is foregrounded. No background task, no repeating trigger. **If a user does not open the app for 7 days, their daily verse stops permanently.** That is precisely the user this feature exists to reach.
- **The push is English-only.** The title is a hardcoded string. The body always uses `verse.translation` even for Urdu users, though `translationUrdu` exists in the data and is never read. Only the optional 150-character tafsir snippet localizes. The Settings control is a 2-way EN/UR toggle, so Arabic is unreachable.

---

## Goals

1. No verse repeats for a full year.
2. No two consecutive days on the same theme.
3. One verse a day, shared by the push and the Today card.
4. Keep the seasonal resonance on the days that genuinely matter.
5. A lapsed user keeps receiving verses.
6. The push honours the user's language (EN / UR / AR).

## Non-goals

- Per-user randomness. Every user sees the same verse on a given day. For a *daily verse* this is a feature, not a limitation. (If we ever want it, seed by install ID instead of cycle: one line.)
- De-duplicating the verse pool against `daily_challenges.json` or `daily_crosswords.json`. A collision across two different features is far less jarring than a repeat within one.
- Verse recitation audio in the notification.

---

## Design

### 1. Data: one reference-based pool

Retire `islamic_month_verses.json` (50) and `daily_messages.json` (30). Replace both with a single `Thaqalayn/Data/daily_verses.json`:

```json
{
  "version": 1,
  "themes": ["mercy", "patience", "gratitude", "tawhid", "..."],
  "verses": [
    {
      "id": 0,
      "surah": 94,
      "verse": 6,
      "themeKey": "hardship-and-ease",
      "themeEn": "Hardship and ease",
      "themeUr": "مشکل اور آسانی",
      "themeAr": "العسر واليسر"
    }
  ],
  "sacredDays": [
    {
      "month": 1,
      "day": 10,
      "surah": 3,
      "verse": 169,
      "occasionEn": "Ashura",
      "occasionUr": "عاشورا",
      "occasionAr": "عاشوراء",
      "themeEn": "The martyrs are alive",
      "themeUr": "...",
      "themeAr": "..."
    }
  ]
}
```

**365 entries.** Each is a *reference*, not content. `themeKey` comes from a fixed vocabulary of roughly 18 keys and drives the spacing rule; the `themeEn/Ur/Ar` strings drive the UI (the theme is already rendered at `SettingsView.swift:298`, `:709` and `DailyVerseScreen.swift:95`; `relevance` is rendered nowhere and is dropped).

Arabic, English translation, **Urdu translation** and tafsir all hydrate at read time from `quran_data.json` via `DataManager.getVerse(surah:verse:)`, which the app already ships with all 6,236 verses. **Growing the pool costs curation, not content**, and the Today card inherits an Urdu translation it never had.

### 2. Selection: `DailyVerseProvider`

A new service, `Thaqalayn/Services/DailyVerseProvider.swift`, replaces the selection logic in both `NotificationManager` and `DailyMessageProvider`. One entry point:

```swift
func verse(for date: Date) -> DailyVerseSelection
```

**Step 1: sacred-day override.** Convert `date` to Hijri via `IslamicCalendarManager`. If `sacredDays` contains a matching `(month, day)`, return it, carrying its occasion title. This wins.

**Step 2: otherwise, a seeded permutation of the pool.**

```
dayIndex = whole days since a fixed epoch
cycle    = dayIndex / N          // which pass through the pool
position = dayIndex % N
order    = permutation(cycle)    // memoized, keyed by cycle
entry    = pool[order[position]]
```

`permutation(cycle)` is built by **greedy selection from the largest remaining theme bucket**, seeded by the cycle number (splitmix64). Each theme's members are pre-shuffled by the same RNG and ties between equally-full buckets are broken by it, so *which* verse a theme contributes is unpredictable even though the theme rotation is even. The order for cycle N is seeded with the closing theme of cycle N-1, so the guarantee holds across the year seam too.

This yields exact guarantees rather than probabilistic ones:

- No verse twice within a 365-day cycle.
- A different order every cycle, so year 2 is not year 1.
- Never two consecutive days on the same theme, **including across the seam between one year and the next**.

**Two approaches were tried and rejected, both caught by `scripts/daily_verses/simulate.py`** (a line-for-line Python mirror of the Swift, which proves the guarantees against the real pool without needing a simulator):

1. **Shuffle, then repair collisions by scanning forward for a swap candidate.** This is structurally broken: near the end of the array the forward scan runs out of candidates and gives up, so *every cycle ended with broken theme spacing in its final days*. The bug was invisible by inspection and obvious in simulation.
2. **Permuting each cycle independently.** The seam between one cycle's last day and the next cycle's first day was never checked, so two consecutive days shared a theme in **24% of cycles**. Roughly once a year, silently.

Greedy-by-largest-bucket is the standard construction for "rearrange so no two neighbours match" and provably succeeds while no theme holds more than half the pool. `validate.py` caps any theme at a third; the real spread is about 20 of 365. Even rotation is also a quiet upgrade over a plain shuffle, which can drop three mercy verses into one week without ever placing two adjacent.

**Why a permutation and not a shuffle bag.** The scheduler must bake content into notifications up to 30 days out, so it has to answer "what is the verse 27 days from now?" A pure function of the date makes that free. A stateful bag would need to pre-draw and persist those 30 draws, and a reinstall or a fresh device would wipe the bag and restart the repeats. The permutation survives both, and it lets the push and the Today card agree with **no shared mutable state**.

**Edge case:** on an override day the pool position still advances, so that day's pool verse is computed and discarded. Roughly 20 verses a year get skipped this way. Because the permutation reshuffles each cycle, a different set is skipped next year, so no verse is systematically starved.

### 3. Scheduling: kill the 7-day cliff

- Window goes from **7 to 30 days**.
- Identifiers become `daily_verse_<yyyy-MM-dd>` instead of `daily_verse_<offset>`, so a refresh can add only what is missing rather than cancelling and re-adding everything on every foreground.
- Keep the existing "skip today if its time has already passed" behaviour.

**Why 30 and not 60.** iOS hard-caps an app at **64 pending notification requests**. The same budget also serves `streak_reminder`, `gentle_nudge`, `milestone_*`, `near_completion_*`, `arafah_reminder` and `journey_start_*`. Thirty leaves comfortable headroom while still meaning a user who vanishes for a month keeps getting their verse. This must be commented in the code, because the failure mode when the cap is exceeded is iOS silently dropping requests.

### 4. Notification content

- **Title:** localized. Ordinary day, "Verse of the Day" / "آیت روز" / "آية اليوم". Sacred day, the occasion name.
- **Subtitle:** the theme (`content.subtitle`). This frees the body.
- **Body:** the Arabic, then the translation in the user's language, using `translationUrdu` for Urdu users. Optional tafsir snippet only when `includeTafsir` is on.
- **Drop** the hardcoded `"📚 Tap to explore the 5-layer tafsir"` line. iOS truncates the body to roughly four lines on the lock screen, and that CTA spends one of them saying what the tap gesture already says.
- **Settings:** replace the 2-way EN/UR toggle (`SettingsView.swift:933`) with a real EN / UR / AR picker.
- `userInfo` deep link (`thaqalayn://verse?surah=&verse=`) is unchanged.

### 5. Today card

`TodayView`'s daily-message card reads from `DailyVerseProvider` instead of `DailyMessageProvider`. It now shows the same verse as the push, with the theme as a subtitle, and gains Urdu. `daily_messages.json` and `DailyMessageProvider.swift` are deleted.

### 6. Sacred days

Roughly 20 overrides a year, leaving about 345 days to the pool. Proposed refs below. **The exact Hijri dates and the verse choices both need review before authoring**, since some dates vary by narration.

| Hijri date | Occasion | Proposed ref |
| --- | --- | --- |
| 10 Muharram | Ashura | 3:169 |
| 20 Safar | Arbaeen | 22:27 |
| 28 Safar | Passing of the Prophet | 3:144 |
| 17 Rabi' al-Awwal | Mawlid an-Nabi | 21:107 |
| 3 Jumada al-Thani | Martyrdom of Sayyida Fatima | 33:33 |
| 13 Rajab | Birth of Imam Ali | 2:207 |
| 27 Rajab | Mab'ath | 96:1 |
| 3 Sha'ban | Birth of Imam Husayn | 37:107 |
| 15 Sha'ban | Birth of Imam al-Mahdi | 28:5 |
| 1 Ramadan | Start of the fast | 2:183 |
| 15 Ramadan | Birth of Imam Hasan | 76:8 |
| 19 Ramadan | Striking of Imam Ali | 33:23 |
| 21 Ramadan | Martyrdom of Imam Ali | 33:23 |
| 23 Ramadan | Laylat al-Qadr | 97:1 |
| 1 Shawwal | Eid al-Fitr | 87:14 |
| 9 Dhul-Hijjah | Arafah | 2:198 |
| 10 Dhul-Hijjah | Eid al-Adha | 37:107 |
| 18 Dhul-Hijjah | Ghadeer | 5:67 |
| 24 Dhul-Hijjah | Mubahala | 3:61 |
| 25 Dhul-Hijjah | Surah al-Insan | 76:8 |

Where a ref appears twice (37:107, 33:23, 76:8) it should be disambiguated before authoring so no two occasions serve the identical verse.

The whole Muharram 1-10 arc as a themed sequence was considered and deferred; the Muharram journey already covers that ground.

### 7. Content pipeline

Mirror `scripts/challenges/`, which already produced the 365-entry `daily_challenges.json`:

- `scripts/daily_verses/assemble.py` merges agent-authored batches into `daily_verses.json`.
- `scripts/daily_verses/check_batch.py` pre-flights one authored batch: refs exist, both translations present, no collision with the sacred days or another batch, themeKey in vocabulary. Authors run this themselves before returning.
- `scripts/daily_verses/simulate.py` mirrors the Swift selection algorithm in Python and proves the guarantees against the real pool over many cycles. **This is the only way the guarantees get verified without a simulator**, and it has already caught two real bugs. If the Swift algorithm changes, change this too.
- `scripts/daily_verses/validate.py` asserts:
  - exactly 365 pool entries;
  - every `(surah, verse)` resolves in `quran_data.json`, with a **non-empty `translation` and `translationUrdu`**;
  - no duplicate refs within the pool;
  - every `themeKey` is in the declared vocabulary;
  - no theme exceeds roughly a third of the pool, so the spacing repair pass can always succeed;
  - every `sacredDays` ref resolves and every `(month, day)` is unique.

Authoring runs in **waves of at most two agents** (per `CLAUDE.md`), about ten batches of roughly 37 verses, each batch given a theme quota so the pool stays balanced.

**Curation bar for a verse.** It has to read standalone, without surrounding context. It is not a mid-sentence fragment. It is not a ritual or legal technicality. It is not a verse of punishment or threat lifted out of its setting. It is something a person would want to wake up to.

All English copy follows the house plain-spelling rule: no transliteration diacritics.

### 8. Migration

Nothing to migrate. Selection is stateless, a pure function of the date, so users simply begin receiving the new pool on update. Nothing is persisted that encodes the old selection.

**Deletions:**
- `Thaqalayn/Thaqalayn/Data/islamic_month_verses.json`
- `Thaqalayn/Data/daily_messages.json`
- `Thaqalayn/Services/DailyMessageProvider.swift`
- `IslamicMonthVerseData` and `IslamicMonth` models (`QuranModels.swift:664-707`)
- `sendTestNotification()` (`NotificationManager.swift:336-354`), which has zero call sites

**Also worth collapsing while in the file:** `SettingsView` carries a near-duplicate daily-verse section at roughly lines 220-280 and 640-728.

### 9. What's New

Per `CLAUDE.md`, add one `WhatsNewCatalog.all` entry in EN/UR/AR. Something to the effect of "A new verse every day, all year", pointing at the Today card or the notification settings. No em dash in the copy.

---

## Files touched

| File | Change |
| --- | --- |
| `Thaqalayn/Data/daily_verses.json` | **new**, 365 refs + sacred days |
| `Thaqalayn/Services/DailyVerseProvider.swift` | **new**, selection |
| `Thaqalayn/Services/NotificationManager.swift` | selection removed, 30-day window, localized content |
| `Thaqalayn/Views/TodayView.swift` | card reads from the new provider |
| `Thaqalayn/Views/SettingsView.swift` | new provider, EN/UR/AR picker, collapse the duplicate section |
| `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift` | new provider |
| `Thaqalayn/Models/QuranModels.swift` | new models, old ones deleted |
| `Thaqalayn/Models/WhatsNewItem.swift` | announcement entry |
| `scripts/daily_verses/{assemble,validate}.py` | **new**, content pipeline |
| `Thaqalayn/Services/DailyMessageProvider.swift` | **deleted** |
| `Thaqalayn/Thaqalayn/Data/islamic_month_verses.json` | **deleted** |
| `Thaqalayn/Data/daily_messages.json` | **deleted** |

---

## Risks and open questions

1. **Which folder is in the Xcode target.** `islamic_month_verses.json` lives at `Thaqalayn/Thaqalayn/Data/` while the other daily pools live at `Thaqalayn/Data/`. Confirm which is the synced folder in the bundle before placing `daily_verses.json`.
2. **The 64-notification cap** is a hard iOS limit shared with every other notification type in the app. If the event-driven ones grow, the 30-day window has to shrink. Worth a comment and, ideally, a runtime assertion in debug.
3. **Sacred-day refs need scholarly review** before the content run, along with the three duplicated refs noted above.
4. **Theme vocabulary** must be settled before authoring begins, since it is the axis the spacing guarantee depends on.
5. **Hijri date conversion** uses `islamicUmmAlQura`. Sacred-day overrides will land on whatever date that calendar reports, which can differ by a day from local moon-sighting practice. This is pre-existing behaviour, but it becomes more visible once occasions are named in notification titles.
