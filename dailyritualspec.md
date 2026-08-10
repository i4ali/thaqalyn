# Spec: The Commitment Calendar

A user picks something to recite (a ziyarat, a dua, a verse, or a bundle of them), commits to it for a span of days, and marks each day done on a calendar. The anchor use case: reciting **Ziyarat Ashura every day for the forty days from Ashura to Arbaeen**.

**Visual source of truth:** `commitment-calendar-mockup.html` at the repo root (open in a browser). It shows the five surfaces in the Midnight Emerald design language with real app tokens: the Today-tab shelf (empty state and active state), the create screen, the tracker, and the day-forty completion state. Follow it for layout, spacing intent, and copy tone. Where this spec and the mock disagree on behavior, this spec wins.

**Working branch:** implement on a fresh branch off `master` (do not reuse `claude/daily-ritual-mock-y84o3q`; it holds only the mock).

---

## 1. Vocabulary and naming

- **Commitment** - the user-facing name. One promise: items + span + rule + start date.
- **A forty / the arba'in** - a 40-day commitment, the flagship preset.
- User-facing English copy uses plain spelling per house style: "Ziyarat Ashura", "Arbaeen", "dua" (no diacritics, see `CLAUDE.md` and `scripts/strip_diacritics.py`).

## 2. Scope

### In scope (v1)
1. `Commitment` data model + `CommitmentsManager` (local persistence, day rollover, rules engine).
2. **Today-tab shelf** "Your commitments" in both theme variants of `TodayView` - horizontal shelf, never a vertical stack. Includes the empty state with the seasonal invitation card.
3. **Create screen** (sheet): content picker, duration presets, consecutive/flexible rule, start date, daily reminder.
4. **Tracker screen**: Hijri-first month calendar, tap-today-to-mark, 40-bead strip, computed end date, back-fill day sheet, completion state.
5. **Commitments list screen** ("All N ›" destination): active commitments + archived completed ones.
6. **Ziyarat Ashura ships as new content** with full Arabic, transliteration, EN/UR translation, and a reading screen with a Listen option.
7. Entry points: shelf invitation card, dashed New card, and a "Commit" chip on `DuaDetailView`.
8. Premium gate: one active commitment free, unlimited with premium.
9. Daily reminder notifications.
10. What's New entry.

### Out of scope (v1) - do not build
- The "Daily practice" shelf regrouping of Daily Challenge / Crossword / Dua of the Day (sketched in the mock as a proposal; separate change).
- Supabase sync of commitments (v1 is local-only like DailyChallenge/Crossword; keep the manager's persistence isolated so sync can be added later).
- `.surah` items in the picker (the model supports the case; the picker does not offer it yet).
- Share card, badges ("The Forty"), Android.

---

## 3. Data model

New file `Thaqalayn/Models/CommitmentModels.swift`:

```swift
enum CommitmentItemType: String, Codable { case ziyarat, dua, verse, surah }

struct CommitmentItem: Codable, Hashable, Identifiable {
    let type: CommitmentItemType
    /// ziyarat: content id ("ziyarat-ashura"); dua: DailyDua.id; verse: "surah:verse" e.g. "2:255".
    let refId: String
    var id: String { "\(type.rawValue)-\(refId)" }
}

enum CommitmentSpan: Codable, Equatable {
    case days(Int)          // presets 40 and 10
    case untilDate(Date)    // inclusive end date
    case ongoing            // no end; progress is a streak
}

enum CommitmentRule: String, Codable { case consecutive, flexible }

enum CommitmentStatus: Codable, Equatable {
    case active
    case completed(onDayKey: String)
    case abandoned
}

struct Commitment: Codable, Identifiable {
    let id: UUID
    var items: [CommitmentItem]         // 1..n, order preserved
    var span: CommitmentSpan
    var rule: CommitmentRule
    var startDayKey: String             // "yyyy-MM-dd", Gregorian, local calendar
    var reminderHour: Int?              // nil = no reminder
    var reminderMinute: Int?
    var completedDayKeys: Set<String>
    var status: CommitmentStatus
    var restartCount: Int               // times the consecutive rule reset the count
    var createdAt: Date
}
```

Day keys are **Gregorian** `yyyy-MM-dd` strings via the exact helper already in the codebase: `DailyCrosswordManager.dayKey(for:)` (`Thaqalayn/Services/DailyCrosswordManager.swift:39`). Extract it into a shared `DayKey` utility or duplicate the four-line helper; do not invent a new format. **Hijri is display-only** (section 6); all storage and arithmetic is Gregorian.

## 4. CommitmentsManager

New file `Thaqalayn/Services/CommitmentsManager.swift`. Mirror the house singleton shape (`@MainActor final class`, `static let shared`, `@Published private(set)` state) of `DailyCrosswordManager`.

State:

```swift
@Published private(set) var commitments: [Commitment]          // all, including archived
var active: [Commitment]      // status == .active
var archived: [Commitment]    // completed/abandoned, newest first
@Published private(set) var pendingBackfill: [UUID: String]    // commitment id -> missed yesterdayKey
```

Persistence: single JSON blob in `UserDefaults` under `"commitments_v1"` (encode `[Commitment]`), saved on every mutation. Local-only in v1.

### Derived values (pure, unit-test friendly)

Implement as pure static functions or an extension so the math is testable without the singleton:

- `totalDays(_ c) -> Int?` - `.days(n)` → n; `.untilDate(d)` → inclusive day count from start; `.ongoing` → nil.
- `dayIndex(_ c, todayKey) -> Int` - `completedDayKeys.count + (isMarked(today) ? 0 : 1)`, clamped to totalDays. Drives "Day 34 of 40" (mock shows 33 recited → "Day 34 of 40").
- `endDate(_ c) -> Date?` - for `.days(n)`: start + (n-1) days **plus, under `.flexible`, one day per missed day so far**; `.untilDate`: fixed; `.ongoing`: nil.
- `endDateLabel(_ c) -> String` - Hijri-formatted via `IslamicCalendarManager`; if the end lands on 20 Safar name it "Arbaeen", on 10 Muharram "Ashura", else "17 Rabi al-Awwal"-style. Only name it when it genuinely matches.
- `streak(_ c) -> Int` - for `.ongoing`: consecutive run of day keys ending at today (or yesterday if today unmarked). Reuses the mental model of `DailyCrosswordStreak.next`.

### Marking

- `markToday(_ id)` / `unmarkToday(_ id)` - insert/remove today's key. Marking the final day (count reaches totalDays) sets `status = .completed(onDayKey: today)`, cancels the reminder, and triggers the completion presentation (section 7).
- `mark(_ id, dayKey:)` / `unmark(_ id, dayKey:)` - back-fill, valid only for keys in `[startDayKey, todayKey]` and within the span.

### Day rollover and the rules engine

`refreshForToday()` - called from `init`, on `scenePhase == .active` (add alongside the existing calls in `TodayView.swift:127-134`), and after any mark/unmark:

For each active commitment, compute `missed` = calendar days in `[startDayKey, yesterdayKey]` not in `completedDayKeys` (bounded by the span):

- **0 missed** → normal.
- **`.flexible`** → no prompt, no reset; the end date simply extends (see `endDate`).
- **`.consecutive`, exactly 1 missed and it is yesterday** → set `pendingBackfill[id] = yesterdayKey`. UI shows the ask (shelf-card eyebrow + tracker banner): "Did you recite yesterday?" with Mark yesterday / I missed it. Marking clears it; declining calls `restart`.
- **`.consecutive`, 2+ missed** → `restart(id)` immediately: `startDayKey = todayKey`, `completedDayKeys = []`, `restartCount += 1`, status stays `.active`. The tracker shows a one-line notice ("The count begins again from today"). Never silently: the notice must appear on next open.

Rollover, restart, and end-date arithmetic must be pure functions with unit tests if a Swift test target exists in the project; if none exists, still keep them pure and free of `Date()` internals (inject `todayKey`) so tests can be added.

## 5. Today-tab shelf

**The commitments surface on Today is a horizontal shelf, one row tall, in both `EmeraldTodayView` and `legacyContent`** (`Thaqalayn/Views/TodayView.swift`). Insert after the What's New card and before the Daily Reminder hero. Today already stacks seven full-width cards; commitments must never add vertical stack height regardless of count.

Clone the geometry and header idiom of `JourneyShelf` / `ShelfCard` (`Thaqalayn/Views/JourneyShelf.swift`): eyebrow section label + trailing "All N ›" (pushes the Commitments list), horizontally scrolling `HStack` of fixed-width cards (ShelfCard uses 190pt; match it), uniform height via the `ShelfCardHeightKey` max-reduce pattern, `ThemeManager` tokens throughout so both themes work, RTL via the same `layoutDirection` environment flip. Build a separate `CommitmentShelf` + `CommitmentShelfCard` in `Thaqalayn/Views/Components/CommitmentShelf.swift` rather than forcing `ShelfItem` to carry a check circle.

**Active commitment card** (see mock section 03):
- Top row: `EmIconChip` (40pt) left, **check circle** right (28pt ring; tap = `markToday`/`unmarkToday`, `role: button`, accessibility label "Mark recited today").
- Eyebrow: finite span → "DAY 34 OF 40" (gold) flipping to "DONE TODAY" (the green done treatment the crossword card uses); ongoing → "NIGHTLY · 🔥 12" flipping to "DONE · 🔥 13"; pending back-fill → the yesterday ask.
- Serif title (`EmType.serif`), 2-line max. Bundles title as "Ziyarat Ashura +2".
- Finite span: thin progress bar at the bottom.
- Card body tap (not the circle) → tracker. Gold hairline stroke on cards not yet done today (live emphasis), normal stroke once done.

**Trailing dashed "New" card** always last: dashed stroke, plus icon. Tap → create sheet, or `PaywallView` when gated (section 9); when gated it wears the accent-style `PREMIUM` capsule (match `DailyCrosswordCard`), never a lock icon.

**Empty state** (no commitments ever, or none active - see mock section 00): keep the section header, set a one-line caption above the shelf ("A commitment is a promise to recite something daily, kept on a calendar."), and fill the shelf with:
1. **Seasonal invitation card** (gold, first) when today is within 1 Muharram-20 Safar (use `IslamicCalendarManager` month/day; `isMuharramSeason()`/`isArbaeenSeason()` as reference) and no active commitment contains `ziyarat-ashura`: eyebrow "THE SEASON · 40 DAYS", title "Ziyarat Ashura", caption "Ashura to Arbaeen", "Begin ›". Tap → create sheet pre-filled (Ziyarat Ashura, 40 days, consecutive). Out of season, skip it.
2. **Dashed New card.**
3. **Suggestion card**: "Ayat al-Kursi · Nightly, ongoing" → create sheet pre-filled (verse 2:255, ongoing).
Hide "All N ›" while there is nothing to list.

## 6. Tracker screen (`CommitmentDetailView`)

New file `Thaqalayn/Views/CommitmentDetailView.swift`. Mock section 01 is the layout reference. Top to bottom:

1. Back button + "Edit" (edit sheet: reminder time, rename-order items, abandon with confirmation → archives as `.abandoned`).
2. Eyebrow "40-DAY COMMITMENT" (or "ONGOING COMMITMENT"), serif title.
3. Action chips per item: **Listen** (`DuaListenButton(arabic:)` - mandatory for the ziyarat/dua Arabic per house rule) and **Read** → reading screen (section 8). Multiple items → one chip row per item or a compact item list; keep every ziyarat/dua's Listen reachable.
4. **Summary card**: "Day N of M" (serif, gold), "x recited · today not yet marked" subline, right column "Ends / Arbaeen / 20 Safar" from `endDateLabel`. Ongoing: streak instead. Below, the **bead strip**: `totalDays` beads (wrap rows past 40), filled = completed count, ring on the current bead. Ongoing commitments skip beads.
5. **Hijri month calendar**:
   - Month header "Safar 1448" + Gregorian span caption "JUL 17 - AUG 14 · 2026", chevrons to page months within `[startDay, endDay]`.
   - Grid built from the `islamicUmmAlQura` calendar that `IslamicCalendarManager` already wraps: compute the Gregorian date of Hijri day 1, weekday offset, month length (29/30) via `calendar.range(of: .day, in: .month, ...)`. Each cell maps Hijri day → Gregorian day key.
   - Cell states (mock legend): **done** (gold-gradient filled), **today** (bright gold ring, tappable → `markToday`, scale-press feedback), **remaining window** (thin gold outline), **missed** (dashed outline), out-of-window (muted).
   - Tapping any past in-window day opens a small **day sheet**: date in both calendars + "Mark recited" / "Unmark". This is the back-fill affordance.
6. Back-fill banner when `pendingBackfill` has this commitment; restart notice after a reset.
7. **Completion state** (mock section 04): when `.completed`, the header area becomes the gold hero - eyebrow "Forty days complete", the Arabic salam line `السَّلَامُ عَلَيْكَ يَا أَبَا عَبْدِ اللَّهِ` for Ziyarat Ashura (generic "May it be accepted" title otherwise), dates line "Ziyarat Ashura · 10 Muharram - 20 Safar 1448 · completed on Arbaeen" - above the full bead strip and the finished calendar. Present it automatically the moment the last day is marked (cover the tracker with this state) and thereafter whenever the archived commitment is opened.

Reading-content font sizes on this screen and the day sheet are chrome (labels, numbers) - fixed sizes are fine. The reading screen is where the text-size rule applies.

## 7. Create screen (`CommitmentCreateView`)

New file `Thaqalayn/Views/CommitmentCreateView.swift`, presented as a sheet. Mock section 02. Four decisions, one screen:

1. **What you'll recite** - selected items as rows (icon chip, serif title, per-item remove) + dashed "Add another · a dua, a verse, or a surah" row → picker sheet offering: Ziyarat Ashura, Ayat al-Kursi (verse 2:255, resolved via `DataManager.getVerse`), and the 20 `DailyDua`s from `DuasManager` (searchable list, reuse `DuasView` row styling). At least one item required.
2. **For how long** - chips: **40 days** (first, default), 10 days, Until a date (Hijri-aware date picker; store Gregorian), Ongoing. Caption under the row: for 40 days, "The tradition of forty · ends on <endDateLabel>"; live-update from the chosen start date.
3. **The rule** - two option cards, Consecutive (default; "Miss a day and the count begins again. The way of the forty.") and Flexible ("Missed days extend the end. Gentler on travel and illness."). Hidden for Ongoing (rule is irrelevant; store `.flexible`).
4. **Begins** (Today default; allow tomorrow/future date) + **Daily reminder** (toggle + time, default 9:00 PM).

CTA: gold button "Begin · ends on Arbaeen" (append the end-date name only when the span is finite; otherwise just "Begin"). Creates the commitment, schedules the reminder, dismisses to Today where the new shelf card is visible. Entry points that pre-fill: seasonal invitation, Ayat al-Kursi suggestion, and the detail-view Commit chip (section 10).

## 8. Ziyarat Ashura content + reading screen

- New bundled asset `Thaqalayn/Data/ziyarat_ashura.json`. Shape:

```json
{
  "id": "ziyarat-ashura",
  "titleEn": "Ziyarat Ashura",
  "titleAr": "زيارة عاشوراء",
  "source": "Mafatih al-Jinan, from Kamil al-Ziyarat",
  "sections": [
    { "arabic": "...", "transliteration": "...", "translationEn": "...", "translationUr": "..." }
  ]
}
```

  Author the full standard text divided into readable sections (the salams, the la'n, the salawat, the closing sajdah dua), including notes for the 100x repetitions. **English transliteration and translation in plain spelling - run `python3 scripts/strip_diacritics.py --report` over the file before committing.** Urdu translation required (match the app's existing Urdu quality). This is the largest content task; author it carefully, verify against a printed Mafatih, and keep it in its own commit for review.
- Loader: `ZiyaratContentManager` (or fold into a small `CommitmentContentResolver` that maps any `CommitmentItem` → display title, arabic text, and destination view).
- New reading screen `Thaqalayn/Views/ZiyaratAshuraView.swift` modeled on `DuaDetailView`: section-by-section Arabic / transliteration / translation. **House rules apply in full here:** all reading text scales with `ReadingSettingsManager.shared.scale` (fonts and line spacing, pattern per `DuaDetailView`), and `DuaListenButton(arabic:)` sits directly under the Arabic (one per section, keyed to that section's Arabic). Both themes.

## 9. Premium gating

`PremiumManager` (`Thaqalayn/Services/PremiumManager.swift`) gains:

```swift
/// First active commitment is free; more require premium.
func canStartCommitment(activeCount: Int) -> Bool {
    activeCount == 0 || isPremium
}
```

Gate at the entry points: dashed New card, suggestion cards, and the detail-view Commit chip route to `PaywallView` when `!canStartCommitment(activeCount: manager.active.count)`. Signal with the accent-style "PREMIUM" capsule (the `DailyCrosswordCard` treatment) - **never `lock.fill`, never `PremiumBadgeView`**. Completing or abandoning a commitment frees the slot. Ziyarat Ashura reading content itself is not gated.

## 10. Entry point on DuaDetailView

Add a "Commit" chip to `DuaDetailView` beside the existing Listen control, same capsule family (`accentChip` capsule, calendar SF symbol, "Commit"). Tap → create sheet pre-filled with that dua as the single item. Apply the premium gate. (Journey day detail views keep their current layout; the ziyarat reading screen gets the same chip only if trivially cheap - optional.)

## 11. Reminders

Extend `NotificationManager` (follow the style of `scheduleStreakReminder`):

- `scheduleCommitmentReminder(_ c: Commitment)` - repeating `UNCalendarNotificationTrigger` at the chosen time, identifier `"commitment-reminder-<uuid>"`. Copy (EN example): title "Your commitment", body "Ziyarat Ashura · Day 34 of 40. A few minutes before the day ends." Localize EN/UR/AR via the strings file.
- `cancelCommitmentReminder(id: UUID)` - on completion, abandon, or reminder toggle-off.
- Re-request permission through the existing `requestPermission()` flow; if denied, the create screen shows the reminder row disabled with the standard settings hint.

## 12. Strings, localization, RTL

New `CommitmentStrings.swift` following the `TodayStrings`/`JourneyStrings` pattern: every user-facing string in EN/UR/AR (section labels, empty-state caption, invitation copy, create-screen labels and option copy, rule descriptions, back-fill ask, restart notice, completion copy, notification copy). English copy: plain spelling, no em dashes. The shelf, create screen, tracker, and list all flip for RTL via the `layoutDirection` environment pattern used by `JourneyShelf` and the Today greeting.

## 13. What's New

Per `CLAUDE.md`: add one entry to `WhatsNewCatalog.all` (`Thaqalayn/Models/WhatsNewItem.swift`) with EN/UR/AR title/blurb/CTA, `sfSymbol: "calendar.badge.checkmark"` (or similar), release date = ship date. Add a `WhatsNewDestination.commitments` case and handle it in `WhatsNewCard.open()` - it should open the create sheet (or the Commitments list if one already exists). No em dash in the copy.

## 14. Commitments list screen

`Thaqalayn/Views/CommitmentsListView.swift`, pushed by "All N ›". Reuse the `SectionFullList` chrome (`JourneyShelf.swift:219`): serif title "Commitments", back button. Content: active commitments as full-width cards (icon, title, "Day N of M" or streak, mini bead strip, check circle), then an "Archive" divider with completed/abandoned ones (title, date range, final state; tap → tracker in its archived state). Top row: "+ New commitment" (gated per section 9).

## 15. File map

New files (Xcode 16 synchronized folders pick these up automatically; no pbxproj editing):

| File | Contents |
|---|---|
| `Thaqalayn/Models/CommitmentModels.swift` | Section 3 types |
| `Thaqalayn/Services/CommitmentsManager.swift` | Section 4 |
| `Thaqalayn/Services/ZiyaratContentManager.swift` | Section 8 loader/resolver |
| `Thaqalayn/Views/Components/CommitmentShelf.swift` | Shelf + cards + empty state |
| `Thaqalayn/Views/CommitmentCreateView.swift` | Section 7 |
| `Thaqalayn/Views/CommitmentDetailView.swift` | Section 6 (incl. Hijri grid, beads, day sheet, completion) |
| `Thaqalayn/Views/CommitmentsListView.swift` | Section 14 |
| `Thaqalayn/Views/ZiyaratAshuraView.swift` | Section 8 reading screen |
| `Thaqalayn/Utilities/CommitmentStrings.swift` | Section 12 |
| `Thaqalayn/Data/ziyarat_ashura.json` | Section 8 content |

Edited files: `TodayView.swift` (shelf in both variants + `refreshForToday()` in the scenePhase block), `PremiumManager.swift`, `NotificationManager.swift`, `DuaDetailView.swift`, `WhatsNewItem.swift`, `WhatsNewCard.swift`.

## 16. Suggested build order

1. Models + manager + rules engine (pure functions; tests if a test target exists).
2. Shelf on Today (both themes) with hardcoded-free real data; create screen; list screen.
3. Tracker: summary + beads + Hijri grid + marking + back-fill + rollover UI.
4. Ziyarat Ashura JSON + reading screen + Listen (own commit).
5. Entry points (invitation seasonality, DuaDetailView chip), premium gate, reminders.
6. Completion state, What's New entry, polish pass (RTL, both themes, accessibility labels).

## 17. Acceptance checklist

- [ ] Today shows commitments as one horizontal shelf row in **both** Midnight Emerald and legacy themes; vertical height does not change with 0, 1, or 6 commitments.
- [ ] Empty state: caption + invitation (in season) + New + suggestion cards; invitation absent out of season and once a ziyarat-ashura commitment is active.
- [ ] Check circle on a shelf card marks/unmarks today without navigation; eyebrow and progress update immediately; state survives relaunch.
- [ ] Creating the pre-filled forty on 10 Muharram yields "Ends · Arbaeen · 20 Safar"; the end label is computed, not hardcoded (verify with a different start date).
- [ ] Day rollover: after midnight (or a simulated date change) an unmarked yesterday on a consecutive commitment produces the back-fill ask; declining resets to Day 1 with the visible notice; a 2-day gap resets immediately; a flexible commitment instead extends its end date.
- [ ] Marking day 40 presents the completion state; the commitment archives to the list with calendar intact; reminder is cancelled.
- [ ] Ongoing commitment shows a streak, no beads, no end date.
- [ ] Second commitment while free shows the PREMIUM capsule (no lock anywhere) and routes to `PaywallView`; premium unlocks it.
- [ ] Ziyarat Ashura reading screen: every section has Listen via `DuaListenButton`; all reading text scales with the Settings text-size control; English text passes `strip_diacritics.py --report` clean.
- [ ] Reminder fires at the chosen time and stops after completion/abandon.
- [ ] What's New card appears with EN/UR/AR copy and opens the commitments destination.
- [ ] RTL (Urdu/Arabic app language): shelf, create screen, and tracker mirror correctly.
- [ ] Existing Today features (What's New, reminder hero, Continue Reading, Bookmark Spotlight, Challenge, Crossword, Dua of the Day) are untouched and in their current order.
