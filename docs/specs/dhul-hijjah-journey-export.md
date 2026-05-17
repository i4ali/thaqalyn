# Dhul-Hijjah Journey — Port Guide & Spec (for the Sunni variant app)

**Source:** Thaqalayn (Shia) iOS app, commit `3147740`.
**Target:** Sibling Sunni iOS/SwiftUI app with the same overall architecture (singleton `@MainActor` managers, `ThemeManager`, `IslamicCalendarManager`, `ProgressManager`, `NotificationManager`, `PremiumManager`, a `MainTabView`, JSON content files bundled in `Data/`).
**Goal:** Re-implement the "First Ten Days of Dhul-Hijjah" Journey as a seasonal tab.

> **Key principle for the port:** the *engine* (models, manager, seasonality, persistence, UI) is **100% sect-agnostic** and can be copied **verbatim**. Only three things change for the Sunni variant: (1) the JSON content file, (2) honorific/source strings in user-facing copy, (3) the notification body text. See §12 (Sunni Adaptation).

---

## 1. Architecture summary

A self-contained seasonal feature that appears as a **conditional 5th tab** during the Hajj window of the Islamic year. It presents a **10-day journey** (Dhul-Hijjah 1–10), one card per day; each day has a du'a, two Quranic verses with relevance notes, a tafsir-focus paragraph, and a reflection prompt. The user marks days complete; progress is stored locally per Islamic year and resets annually. Completing all 10 days awards a "Hajj Champion" badge through the existing `ProgressManager`. A single Day-of-Arafah local notification is scheduled during the season.

Progress for this feature is **separate** from the main `ProgressManager` (verse counts/streaks/sawab), except for the completion badge which is routed through `ProgressManager` so it joins the existing badge wall and sawab total.

**Mirrors the Ramadan Journey pattern exactly** — Hajj season (months 11–12) and Ramadan season (months 8–10) are mutually exclusive, so the two share one conditional tab slot.

---

## 2. File inventory

### New files

| File | Lines | Copy verbatim? |
|---|---|---|
| `Services/HajjJourneyManager.swift` | ~188 | ✅ Yes |
| `Views/HajjJourneyView.swift` | ~343 | ✅ Yes (uses your `ThemeManager`/background components) |
| `Views/HajjDayDetailView.swift` | ~458 | ✅ Yes (uses your verse-data lookup + deep-link) |
| `Data/hajj_journey.json` | 10 days | ❌ **Rewrite content** (see §12) |

### Modified existing files (additive)

| File | Change |
|---|---|
| `Models/QuranModels.swift` | Add 5 structs (§3) + `hajjCompletion` badge case (§8) |
| `Services/IslamicCalendarManager.swift` | Add 4 methods (§5) |
| `Services/NotificationManager.swift` | Add `scheduleArafahReminder()`; call it from the daily-verse rescheduling path when in Hajj season (§6) |
| `Services/PremiumManager.swift` | Add `canAccessHajjDay(_:)` (§7) |
| `Services/ProgressManager.swift` | Add `awardHajjBadge(year:)` (§8) |
| `Views/MainTabView.swift` | Conditional Hajj tab + (already-present) `navigateToVerse` deep-link receiver (§9) |
| `ContentView.swift` | On launch, if Hajj season → `Task { await NotificationManager.shared.scheduleArafahReminder() }` (§9) |
| `Views/ProgressRingsView.swift` | Show the seasonal ring as "Hajj" using `HajjJourneyManager.shared.completionPercentage` when in Hajj season (§9) |
| `Views/Onboarding/SeasonalFeaturesScreen.swift` | Add a "Dhul-Hijjah Journey" feature card (copy → §12) |

No asset catalog entries are required — the feature uses **SF Symbols only**.

---

## 3. Data models (add to `Models/QuranModels.swift`, verbatim)

```swift
struct HajjJourneyData: Codable {
    let days: [HajjDay]
}

struct HajjDay: Codable, Identifiable {
    let id: String          // "day1" ... "day10"
    let dayNumber: Int       // 1...10
    let theme: String        // English theme
    let themeArabic: String  // Arabic theme (RTL)
    let icon: String         // SF Symbol name
    let dua: HajjDua
    let verses: [HajjVerse]  // exactly 2 per day in current content
    let tafsirFocus: String
    let reflection: String
}

struct HajjDua: Codable {
    let arabic: String
    let transliteration: String
    let english: String
    let source: String?
}

struct HajjVerse: Codable, Identifiable {
    let id: String           // "h1v1", "h1v2", ...
    let surahNumber: Int
    let verseNumber: Int
    let relevanceNote: String

    var verseReference: String { "Quran \(surahNumber):\(verseNumber)" }
}

struct HajjJourneyProgress: Codable {
    var completedDays: Set<Int>
    var lastCompletedDate: Date?
    var year: Int            // Islamic (Hijri) year — used for annual reset

    init(completedDays: Set<Int> = [], lastCompletedDate: Date? = nil, year: Int = 0) {
        self.completedDays = completedDays
        self.lastCompletedDate = lastCompletedDate
        self.year = year
    }

    var completionPercentage: Double { Double(completedDays.count) / 10.0 }
    var isCompleted: Bool { completedDays.count >= 10 }
}
```

---

## 4. Content file: `Data/hajj_journey.json`

Bundled JSON, loaded by name `hajj_journey` from `Bundle.main`. Top level `{ "days": [ ... ] }`, exactly **10** entries (`dayNumber` 1–10). Per-day shape:

```json
{
  "id": "day1",
  "dayNumber": 1,
  "theme": "The Blessed Ten",
  "themeArabic": "العَشْرُ المُبارَكَة",
  "icon": "calendar.badge.exclamationmark",
  "dua": {
    "arabic": "لَا إِلَٰهَ إِلَّا اللَّهُ عَدَدَ اللَّيَالِي وَالدُّهُورِ ...",
    "transliteration": "La ilaha illa-llahu 'adada-l-layali wa-d-duhur ...",
    "english": "There is no god but Allah, as numerous as the nights and the ages ...",
    "source": "Mafatih al-Jinan — Amal of the Ten Days of Dhul-Hijjah"
  },
  "verses": [
    { "id": "h1v1", "surahNumber": 89, "verseNumber": 2,  "relevanceNote": "And by the ten nights — ..." },
    { "id": "h1v2", "surahNumber": 22, "verseNumber": 28, "relevanceNote": "That they may witness benefits ..." }
  ],
  "tafsirFocus": "Reflect on why Allah swears by 'the ten nights' ...",
  "reflection": "These ten days will pass quickly. What is the one act of worship you commit to ...?"
}
```

### Day map (themes, icons, verses) — structure to keep, content to re-source

| Day | Theme (EN) | Theme (AR) | SF Symbol | Verses | Current du'a source (Shia) |
|---|---|---|---|---|---|
| 1 | The Blessed Ten | العَشْرُ المُبارَكَة | `calendar.badge.exclamationmark` | 89:2, 22:28 | Mafatih al-Jinan — Amal of the Ten Days |
| 2 | Remembrance | الذِّكْر | `sparkles` | (dhikr theme) | Mafatih al-Jinan — recommended dhikr |
| 3 | Repentance | التَّوْبَة | `arrow.counterclockwise` | (tawba theme) | Supplication of Imam al-Sajjad (AS) — al-Sahifa al-Sajjadiyya |
| 4 | Pure Monotheism | التَّوْحِيد | `circle.hexagongrid.fill` | 112:1 | Supplication attributed to Imam Ali (AS) |
| 5 | Sacrifice & Charity | الإيثار | `hands.and.sparkles.fill` | 22:37 | Mafatih al-Jinan — adapted |
| 6 | The Submission of Ibrahim | تَسْلِيمُ إِبْرَاهِيم | `flame.fill` | 37:102–107 | Du'a of Prophet Ibrahim (AS), Quran 14:40 |
| 7 | The Call of Hajj | نِدَاءُ الحَجّ | `figure.walk.circle.fill` | 22:27 | The Talbiyah — Mafatih al-Jinan |
| 8 | Day of Tarwiyah | يَوْمُ التَّرْوِيَة | `drop.fill` | 2:197 | Mafatih al-Jinan — Amal of 8 Dhul-Hijjah |
| 9 | **The Day of Arafah** | يَوْمُ عَرَفَة | `mountain.2.fill` | 2:198, 7:55 | **Du'a Arafah of Imam al-Husayn (AS) — Mafatih al-Jinan** |
| 10 | Eid al-Adha | عِيدُ الأَضْحَى | `moon.stars.fill` | 108:2 | Takbirat of Eid al-Adha — Mafatih al-Jinan |

> Themes 1–10 and the verse selections are **doctrinally neutral and can be kept as-is**. Only the du'a *texts* and `source` strings carry sect-specific sourcing (rows 3, 4, 9 most strongly). See §12.

---

## 5. Seasonality (add to `IslamicCalendarManager`, verbatim)

Relies on existing `currentIslamicMonth()`, `currentIslamicDay()`, `currentIslamicYear()`, and an exposed `islamicCalendar` (`Calendar(identifier: .islamicUmmAlQura)` or equivalent).

```swift
/// Hajj window: last 5 days of Dhul-Qa'dah (countdown) + Dhul-Hijjah days 1–13.
/// Mutually exclusive with Ramadan season (months 8/9/10).
func isHajjSeason() -> Bool {
    let month = currentIslamicMonth()
    let day = currentIslamicDay()
    switch month {
    case 11: return day >= 25   // Dhul-Qa'dah lead-in
    case 12: return day <= 13   // 10-day journey + Eid + Tashriq tail
    default: return false
    }
}

func currentHajjDay() -> Int? {
    guard currentIslamicMonth() == 12 else { return nil }
    let day = currentIslamicDay()
    return (1...10).contains(day) ? day : nil
}

func daysUntilHajj() -> Int? {
    guard currentIslamicMonth() == 11 else { return nil }
    return max(0, 30 - currentIslamicDay() + 1)
}

func hajjSeasonStatus() -> String {
    let month = currentIslamicMonth(), day = currentIslamicDay()
    switch month {
    case 11:
        if let d = daysUntilHajj(), d > 0 { return "\(d) day\(d == 1 ? "" : "s") until Dhul-Hijjah" }
        return "Dhul-Hijjah begins soon"
    case 12:
        if day == 9 { return "Day of Arafah" }
        if day == 10 { return "Eid al-Adha Mubarak!" }
        if day <= 10 { return "Day \(day) of Dhul-Hijjah" }
        if day <= 13 { return "Eid al-Adha Mubarak!" }
        return ""
    default: return ""
    }
}
```

---

## 6. Arafah notification (add to `NotificationManager`)

Single local notification on **9 Dhul-Hijjah** at the user's existing preferred notification time. **Does not request permission** (owned by the daily-verse opt-in flow) — only schedules if already `.authorized`. Deep-links to **Quran 2:198** via `content.userInfo = ["surah": 2, "verse": 198]` (the existing verse deep-link path). `categoryIdentifier = "ARAFAH_REMINDER"`. Resolves 9 Dhul-Hijjah of `currentIslamicYear()` to a Gregorian fire date; skips if already passed this year. **Re-arm it inside the daily-verse rescheduling routine** guarded by `if islamicCalendar.isHajjSeason() { await scheduleArafahReminder() }` so it survives daily reschedules.

> **Sunni variant:** change `content.body` — remove "Du'a of Imam al-Husayn (AS)". Suggested: `"Today is the Day of Arafah — the best day of the year for du'a and seeking forgiveness. Tap to continue your Dhul-Hijjah Journey."` Keep title `"Day of Arafah 🤲"`.

---

## 7. Premium gating (add to `PremiumManager`, verbatim)

```swift
/// Day 1 free; days 2–10 require premium (mirrors Ramadan gating).
func canAccessHajjDay(_ dayNumber: Int) -> Bool {
    if dayNumber == 1 { return true }
    return isPremium
}
```

`HajjJourneyView` shows a lock affordance / paywall route for days where this returns `false`.

---

## 8. Completion badge

Add the badge case to the badge-type enum in `Models/QuranModels.swift`:

```swift
case hajjCompletion = "hajj_completion"
```

and its `switch` arms (match the existing pattern):

| Property | Value |
|---|---|
| `title` | `"Hajj Champion"` |
| `subtitle` | `"بطل الحج"` |
| `icon` | `"building.columns.fill"` |
| `color` | `"gold"` |
| `description` | `"Completed the entire 10-day Dhul-Hijjah Journey"` |
| `sawabValue` | `500` |
| `hadith` | `"There are no days in which righteous deeds are more beloved to Allah than these ten days. - Prophet Muhammad (PBUH)"` *(this hadith is in Bukhari — keep verbatim for the Sunni variant)* |

Add to `ProgressManager` (verbatim):

```swift
/// Award Hajj completion badge — once per Islamic year. Called by HajjJourneyManager.
func awardHajjBadge(year: Int) {
    let alreadyAwarded = badges.contains {
        $0.badgeType == .hajjCompletion &&
        Calendar.current.component(.year, from: $0.awardedDate) == year
    }
    guard !alreadyAwarded else { return }

    let badge = BadgeAward(surahNumber: 0, surahName: "Hajj Champion",
                           arabicName: "بطل الحج", badgeType: .hajjCompletion)
    badges.append(badge)
    stats.totalSawab += badge.badgeType.sawabValue
    if preferences.celebrationsEnabled { pendingBadge = badge }
    saveProgress()
    scheduleSync()   // joins the existing cloud-sync pipeline if present
}
```

---

## 9. Manager & integration

### `HajjJourneyManager` (new, copy verbatim)

`@MainActor`, `ObservableObject`, `static let shared`. Responsibilities:

- **Publishes:** `days: [HajjDay]`, `progress: HajjJourneyProgress`, `isLoading`, `errorMessage`.
- **`init()`** → `loadProgress()` → `loadDays()` → `checkYearReset()`.
- **`loadDays()`** decodes `hajj_journey.json` from bundle (no fallback — sets `errorMessage` on failure, per project's no-fallback rule).
- **Persistence:** UserDefaults key **`"hajjJourneyProgress"`**, JSON-encoded `HajjJourneyProgress`. Local only — *no cloud sync for progress itself*; only the badge syncs (via `ProgressManager`).
- **`checkYearReset()`**: if `progress.year != IslamicCalendarManager.shared.currentIslamicYear()`, replace with fresh `HajjJourneyProgress(year: currentYear)` and save — this is the annual reset.
- **`markDayCompleted(_:)` / `unmarkDayCompleted(_:)` / `isDayCompleted(_:)`**: guard 1...10, mutate `completedDays`, set `lastCompletedDate`, save; on mark, call `checkForCompletionBadge()`.
- **`checkForCompletionBadge()`**: if `progress.isCompleted`, call `ProgressManager.shared.awardHajjBadge(year:)`.
- **Lookups/stats:** `day(byNumber:)`, `day(byId:)`, `completedDaysCount`, `completionPercentage`, `isJourneyCompleted`, `remainingDaysCount`, `resetProgress()`.

(Full source is identical to `Thaqalayn/Services/HajjJourneyManager.swift` — copy it.)

### `MainTabView` — conditional tab (tag 5)

```swift
private var isHajjSeason: Bool { IslamicCalendarManager.shared.isHajjSeason() }
...
if isHajjSeason {
    HajjJourneyView()
        .tabItem { Label { Text("Hajj") } icon: { Image(systemName: "building.columns.fill") } }
        .tag(5)
}
```

Also ensure the `.navigateToVerse` `NotificationCenter` receiver exists (used by the Arafah notification tap → stash a `PendingDeepLink(surah:verse:)` then switch to the Quran tab).

### `ContentView` — schedule on launch

```swift
if IslamicCalendarManager.shared.isHajjSeason() {
    Task { await NotificationManager.shared.scheduleArafahReminder() }
}
```

### `ProgressRingsView` — seasonal ring

When `isHajjSeason()`, render the seasonal progress ring using `HajjJourneyManager.shared.completionPercentage` and label it **"Hajj"** (replaces the Ramadan ring slot; add to the legend).

---

## 10. UI / UX spec

**Theming:** uses the app's existing `ThemeManager` (`accentColor`, accent gradient, secondary/tertiary text, glass surface, stroke), an adaptive light/dark background component, and the dark-mode aura modifier. Arabic du'a + verse text render in the bundled Quran font (`"AmiriQuran-Regular"` in the source app — substitute your app's Arabic/Quran font). Arabic blocks are `.trailing`-aligned (RTL); transliteration/English/refs are LTR.

### Screen 1 — `HajjJourneyView` (list)

- **Header:** title "Dhul-Hijjah Journey", subtitle = `IslamicCalendarManager.shared.hajjSeasonStatus()`, progress bar with "X of 10 days" and percent. When `isJourneyCompleted`, show a green checkmark completion banner.
- **Body:** `LazyVStack` of 10 `HajjDayCard`s. Each card: circular day badge (green + checkmark if completed; accent if it is today's `currentHajjDay()`; muted if future/locked), theme + Arabic theme, day icon, status pill ("TODAY" or "Premium" lock), chevron.
- **Tap:** if `PremiumManager.shared.canAccessHajjDay(day)` → push `HajjDayDetailView`; else → paywall route.

### Screen 2 — `HajjDayDetailView` (detail)

Scrollable sections, in order:

1. **Header** — day badge, theme, Arabic theme.
2. **Du'a** — Arabic (Quran font, large, `.trailing`), transliteration (italic), English, `source` (tertiary). Section icon `hands.sparkles.fill`.
3. **Today's Verses** — one card per `HajjVerse`: header `"Quran S:V"` + a "Full Tafsir" button (deep-links into the app's surah/verse detail using the existing verse-data store), Arabic, translation, `relevanceNote` on a subtle tinted background. Section icon `book.pages.fill`.
4. **Tafsir Focus** — `tafsirFocus` paragraph, warm-tinted card, icon `lightbulb.fill`.
5. **Reflection** — `reflection` prompt, italic, bordered card, icon `heart.text.square.fill`.
6. **Mark Day as Complete** — toggle button; accent when incomplete, green gradient + checkmark when complete; calls `markDayCompleted` / `unmarkDayCompleted`.

The verse cards depend on the host app having a Quran data store keyed by surah/verse to fetch Arabic + translation and to deep-link to full tafsir. Wire these to the Sunni app's equivalents.

---

## 11. Persistence & lifecycle summary

| Concern | Mechanism |
|---|---|
| Journey progress | `UserDefaults["hajjJourneyProgress"]` → JSON `HajjJourneyProgress` |
| Annual reset | `checkYearReset()` on manager init, compares stored `year` vs current Hijri year |
| Completion badge | Routed to `ProgressManager.badges` (joins existing sawab/badge wall + cloud sync if present) |
| Tab visibility | Live `isHajjSeason()` check in `MainTabView` |
| Arafah notification | Local, scheduled on launch + re-armed in daily-verse reschedule, only if `.authorized` |
| Premium | `canAccessHajjDay(_:)` — day 1 free, 2–10 premium |

No new cloud schema/RLS is required (progress is device-local; badge uses the existing `ProgressManager` sync pipeline).

---

## 12. Sunni adaptation guidelines

**What stays unchanged (sect-neutral):** all Swift engine code (manager, seasonality, notification mechanics, premium, badge plumbing, both views), the 10-day theme structure, English/Arabic theme names, SF Symbols, verse *selections*, the Bukhari "ten days" hadith on the badge, persistence keys, tab logic.

**What must change — content & strings only:**

| Item | Shia (current) | Sunni replacement guidance |
|---|---|---|
| **Honorific notation** | `(AS)` after Imams / `(S)` | Use `ﷺ` / "(peace be upon him)" for the Prophet; "(may Allah be pleased with him)" / "(RA)" for Companions. Remove Imam-specific `(AS)` usage. |
| **Du'a source compendium** | "Mafatih al-Jinan" | Re-source from Sunni-accepted collections: **Hisn al-Muslim**, **Sahih al-Bukhari/Muslim**, **Riyad as-Salihin**, **al-Adhkar (al-Nawawi)**. Update every `dua.source` string accordingly. |
| **Day 3 — Repentance** | "Supplication of Imam al-Sajjad (AS) — al-Sahifa al-Sajjadiyya" | Replace with **Sayyid al-Istighfar** (Bukhari) — already a canonical Sunni repentance du'a. |
| **Day 4 — Pure Monotheism** | "Supplication attributed to Imam Ali (AS)" | Replace with a Tawhid du'a from Sahih hadith (e.g., the du'a of `La ilaha illa Allah wahdahu la sharika lah...` — Bukhari/Muslim). |
| **Day 9 — Day of Arafah du'a** | "Du'a Arafah of Imam al-Husayn (AS) — Mafatih al-Jinan" | Replace with the **Prophet's ﷺ best du'a of Arafah**: *"Lā ilāha illā Allāhu waḥdahū lā sharīka lah, lahu-l-mulku wa lahu-l-ḥamd, wa huwa ʿalā kulli shayʾin qadīr"* — source: **Jami' at-Tirmidhi / Muwatta Malik**. Update `tafsirFocus` to reference this hadith instead of Imam al-Husayn's Du'a Arafah. |
| **Day 9 notification body** | "...Recite the Du'a of Imam al-Husayn (AS)..." | "Today is the Day of Arafah — the best day of the year for du'a and seeking forgiveness. Tap to continue your Dhul-Hijjah Journey." |
| **Days 1, 2, 5, 8, 10** | Mafatih al-Jinan dhikr/Takbirat | Dhikr/Takbir/Talbiyah texts are largely shared across schools; keep the texts, **only re-attribute `source`** to a Sunni reference (e.g., "Sunnah — Takbirat of Eid al-Adha (Bukhari)"). |
| **Days 6, 7** | Du'a of Ibrahim (Quran 14:40); the Talbiyah | Doctrinally shared — keep text; re-attribute source to Quran / Sunnah / Bukhari-Muslim. |
| Onboarding card copy | mentions "Mafatih", "Du'a of Imam Husayn (AS)" | Rewrite card bullets: "Daily du'a & dhikr for the ten blessed days", "Curated verses for the best ten days of the year", "Day of Arafah reminder", "Track your 10-day journey". |

**Process recommendation:** have a Sunni scholar/reviewer validate the rewritten `hajj_journey.json` (especially Days 3, 4, 9 du'a texts and all `source` attributions and `tafsirFocus` paragraphs) before shipping. The schema and field semantics do not change — this is a content-only swap into the identical structure.

---

## 13. Port checklist

1. Copy `HajjJourneyManager.swift`, `HajjJourneyView.swift`, `HajjDayDetailView.swift` verbatim; fix the Arabic-font name and the verse-data/deep-link wiring to the Sunni app's equivalents.
2. Add the 5 models + `hajjCompletion` badge case/arms to the models file.
3. Add the 4 seasonality methods to `IslamicCalendarManager`.
4. Add `scheduleArafahReminder()` to `NotificationManager`; re-arm it in the daily-verse reschedule path; use the Sunni notification body.
5. Add `canAccessHajjDay(_:)` to `PremiumManager`.
6. Add `awardHajjBadge(year:)` to `ProgressManager`.
7. Add the conditional tab in `MainTabView`; verify the `.navigateToVerse` deep-link receiver exists.
8. Add the launch-time `scheduleArafahReminder()` call in `ContentView`.
9. Add the seasonal "Hajj" ring in `ProgressRingsView`.
10. Add the onboarding card (Sunni copy).
11. Author `Data/hajj_journey.json` (10 days) using the §12 mapping; scholar-review.
12. Bundle `hajj_journey.json` in the target's `Data/` group; build & test by temporarily forcing `isHajjSeason()`/`currentHajjDay()` to validate tab appearance, day cards, completion, badge award, and the Arafah notification.
