# Today Tab — Design

**Date:** 2026-05-09
**Status:** Approved (brainstorming complete)
**Source design handoff:** `design_handoff_today_tab/` (Card Stack — Variation A)

## Goal

Add a "Today" tab as the user's daily home: rotating uplifting reminder, quick continue-reading, and a Du'a-of-the-day. Inserted between Home and Explore.

## Decisions log (from brainstorming)

| # | Question | Decision |
|---|---|---|
| 1 | Last-read source-of-truth | Derive from existing `ProgressManager.verseProgress` (sort by readDate, take latest). Zero new sync surface. |
| 2 | Greeting name | Always render `"Assalāmu ʿalaykum 🌙"` (no name). App has no firstName field. |
| 3 | Du'a-of-the-day source | Rotate deterministically from existing `daily_duas.json` via `dayOfYear % count`. |
| 4 | Reflection card | **Dropped for v1.** Du'a card becomes single full-width instead of 2-column grid. |
| 5 | Theme strategy | Theme-aware: warmInviting renders spec colours; dark themes swap white→glassEffect, ink→primaryText. Peach banner stays saturated in all themes. |

## Architecture

### New files
- `Thaqalayn/Views/Tabs/TodayTab.swift` — NavigationView wrapper hosting `AdaptiveModernBackground` + `TodayView` (matches HomeTab/ExploreTab/ProgressTab pattern).
- `Thaqalayn/Views/TodayView.swift` — screen body.
- `Thaqalayn/Services/DailyMessageProvider.swift` — `@MainActor` singleton, loads bundle JSON, returns `today: DailyMessage` deterministically by day-of-year, caches in UserDefaults.
- `Thaqalayn/Data/daily_messages.json` — ~30 short curated verses.

### Edited files
- `Thaqalayn/Models/QuranModels.swift` — add `DailyMessage` struct.
- `Thaqalayn/Services/ProgressManager.swift` — add computed `lastReadInfo: LastReadInfo?` + `LastReadInfo` struct.
- `Thaqalayn/Services/DuasManager.swift` — add `duaOfTheDay() -> DailyDua?` method.
- `Thaqalayn/Views/MainTabView.swift` — insert Today at tag 1; Explore→2, Progress→3, Ramadan→4.

### Tab insertion (no pbxproj changes — synced folder groups)

| Tag | Title  | Icon              |
|-----|--------|-------------------|
| 0   | Home   | `house.fill`      |
| 1   | Today  | `sun.max.fill`    |
| 2   | Explore| `sparkles`        |
| 3   | Progress | `circle.circle` |
| 4*  | Ramadan| `moon.stars.fill` |

\* conditional, unchanged.

### Data model additions

```swift
// QuranModels.swift
struct DailyMessage: Codable, Identifiable {
    let id: Int               // stable index in JSON
    let arabic: String?       // optional
    let english: String       // headline (curly-quoted at render time)
    let surah: Int
    let verse: Int
    var sourceLabel: String { "\(surah):\(verse)" } // surah name resolved via DataManager
}

struct DailyMessagesData: Codable { let messages: [DailyMessage] }

// ProgressManager.swift
struct LastReadInfo {
    let surahNumber: Int
    let verseNumber: Int
    let progress: Double      // 0…1
    let updatedAt: Date
}

extension ProgressManager {
    var lastReadInfo: LastReadInfo? {
        guard let latest = verseProgress
            .filter(\.isRead)
            .max(by: { $0.readDate < $1.readDate }) else { return nil }
        let completion = getSurahCompletion(surahNumber: latest.surahNumber)
        let progress = completion.total > 0 ? Double(completion.read) / Double(completion.total) : 0
        return LastReadInfo(
            surahNumber: latest.surahNumber,
            verseNumber: latest.verseNumber,
            progress: progress,
            updatedAt: latest.readDate
        )
    }
}
```

## TodayView composition

`ScrollView { LazyVStack(spacing: 14) }`. Horizontal padding 18pt unless noted.

### 2a. Header row (padding 22pt horizontal, top 60pt)
- **HijriDatePill** (left): white pill, 1pt border `Color.black.opacity(0.05)`, padding `6×12`, capsule. Text from `IslamicCalendarManager`: `"\(day) \(monthName) · \(weekdayShort)"` uppercased, 12pt/.semibold, kerning 0.2, `secondaryText`.
- **StreakBadge** (right): same shape; `"🔥 \(progressManager.streak.currentStreak)"` accent-coloured int. Tap → `selectedTab = 3`.

### 2b. Greeting (top 18pt)
- Line 1: `"Assalāmu ʿalaykum 🌙"` 14pt/.medium/`secondaryText`.
- Line 2: `"Today"` 32pt/.heavy, kerning -0.6, `primaryText`.

### 2c. DailyReminderBanner (top 20pt, radius 22pt, peach gradient — saturated in all themes)
- `LinearGradient(colors: [#F4B188, #E89464, #D17A48], topLeading→bottomTrailing)`.
- Shadow `Color(red:0.82,green:0.48,blue:0.28).opacity(0.28)`, radius 14, y 12.
- Decorative crescent: two overlapping 110pt `Color.white.opacity(0.12)` circles top-right, clipped to banner shape. Skip on compact width.
- Eyebrow: `sparkles` SF Symbol + `"A REMINDER FOR TODAY"` 11pt/.bold, kerning 1.3, `.white.opacity(0.92)`.
- Headline: `"\u{201C}\(message.english)\u{201D}"` 19pt/.bold, kerning -0.2, `.white`, max 270pt width, no line limit.
- Source: `"\(surahName) · \(surah):\(verse)"` 12.5pt/.white.opacity(0.85).
- **Tap** → push `SurahDetailView(surah, targetVerse:)` for source verse via deep-link state.
- **Long-press** → `ShareLink` activity with `"\(headline) — \(sourceLabel)"`.

### 2d. ContinueReadingHero (top 14pt)
Section header above card:
- Left: `"CONTINUE READING"` 13pt/.bold, kerning 0.4, uppercase, `secondaryText`.
- Right: `RelativeDateTimeFormatter`-formatted `lastReadInfo.updatedAt`, 12pt/`tertiaryText`.

Card (theme-aware bg via helper):
- **Surah identity row**: 48×48pt avatar (radius 14), bg `#FCE6D5` (warm) / `accentColor.opacity(0.2)` (dark), surah number 18pt/.heavy in `#D17A48`. Text stack: name 16pt/.bold; sub `"Verse \(v) of \(total) · \(translationName)"` 12pt/`tertiaryText`. Trailing: Arabic surah name 22pt (Amiri if available, else system).
- **Verse preview tile**: bg `#FBF6F0` (warm) / `glassEffect` (dark), radius 14pt, padding 14pt. Arabic 19pt right-aligned RTL `lineSpacing 5`. Translation 12.5pt curly-quoted `secondaryText`.
- **Progress + Resume** (HStack, gap 10):
  - Progress bar: full-width 6pt height, capsule. Track `#F1ECE6` (warm) / `tertiaryText.opacity(0.2)` (dark). Fill `#E89464` (peach in all themes).
  - Below: `"\(Int(progress*100))% complete"` 11pt/.semibold/`tertiaryText`.
  - Resume pill: 36pt height, padding 10×16, capsule, bg `#221C18` (warm) / `primaryText` (dark). `play.fill` 12pt + `"Resume"` 13pt/.bold in white. Tap → push SurahDetailView with `targetVerse: verseNumber`.

**Empty state** (`lastReadInfo == nil`): same card shape — `"Start your journey"` 16pt/.bold, `"Open Surah Al-Fātiḥa"` 13pt/`secondaryText`, full-width pill `"Begin"` → push Surah 1.

### 2e. Du'a-of-the-day card (top 12pt) — full-width
Single full-width card (no grid since Reflection dropped). Radius 18pt, padding 14pt, theme-aware bg.

- Leading 28×28pt rounded square (radius 8), `#FFF1E2` (warm) / `accentColor.opacity(0.15)` (dark), `quote.bubble.fill` icon in `#D17A48`.
- Stack: title `"Du'a of the day"` 12pt/.bold/`secondaryText`. Headline `dua.situationEn` 14pt/.semibold/`primaryText`. Sub `dua.category.capitalized` 11pt/`tertiaryText`.
- Trailing chevron `arrow.right` 14pt/`tertiaryText`.
- Tap → push `DuaDetailView(dua: ...)`.
- Source: `DuasManager.shared.duaOfTheDay()` → `dayOfYear % duas.count` index.

## Data flow & state

### TodayView state
```swift
@StateObject private var themeManager = ThemeManager.shared
@StateObject private var dataManager = DataManager.shared
@StateObject private var progressManager = ProgressManager.shared
@StateObject private var dailyMessage = DailyMessageProvider.shared
@StateObject private var duasManager = DuasManager.shared
@StateObject private var calendar = IslamicCalendarManager.shared

@Binding var selectedTab: Int
@State private var selectedSurahForDeepLink: SurahWithTafsir?
@State private var targetVerseNumber: Int?
@State private var hasAppeared = false
@Environment(\.scenePhase) private var scenePhase
```

`MainTabView` passes `selectedTab` down: `TodayTab(selectedTab: $selectedTab).tag(1)`.

### DailyMessageProvider
```swift
@MainActor
final class DailyMessageProvider: ObservableObject {
    static let shared = DailyMessageProvider()
    @Published private(set) var today: DailyMessage
    private let cacheKey = "ThaqalaynDailyMessageCache" // {date, index}
    private var messages: [DailyMessage] = []

    private init() {
        loadMessages()                  // bundle JSON, fatalError if missing/empty
        today = resolveToday()
    }

    func refreshIfDayChanged()          // called from .scenePhase == .active
    func peekNext() -> DailyMessage     // test helper
}
```
- Selection: `Calendar.current.ordinality(of: .day, in: .year, for: Date())! % messages.count` in user's local TZ.
- Cache: UserDefaults `{date: "yyyy-MM-dd", index: Int}`. If cached date == today, return `messages[index]`; else recompute and write.
- **Pull-to-refresh does NOT reroll** — same day = same message.

### Last-read flow
- Read-only computed property on `ProgressManager`. SwiftUI auto-invalidates on `verseProgress` change because Today observes the `@StateObject`.
- Surah lookup via `DataManager.shared.getSurah(number:)` (already exists).
- Verse text via `surahWithTafsir.verses[verseNumber - 1]`.

### Lifecycle
- `.onAppear`: trigger one-time stagger animation (banner → continue → du'a, 60ms gaps, `.easeOut(0.35)`); set `hasAppeared = true`.
- `.onChange(of: scenePhase)` → `.active`: `dailyMessage.refreshIfDayChanged()` (handles overnight app-open).
- `.refreshable`: re-evaluates `lastReadInfo` automatically; calls `refreshIfDayChanged()`. **Does not reroll today's message.**

### Deep-link mechanism
Hidden `NavigationLink` bound to `selectedSurahForDeepLink` (matches HomeView.swift:128–144 pattern). Three trigger points:
1. Banner tap → resolve `dailyMessage.today.surah`, set `targetVerseNumber = today.verse`.
2. Continue card / Resume → resolve `lastReadInfo.surahNumber`, set `targetVerseNumber = lastReadInfo.verseNumber`.
3. Empty-state Begin → resolve Surah 1, `targetVerseNumber = 1`.

Du'a card uses its own `NavigationLink(destination: DuaDetailView(dua:))`.

## Error handling & edges

Per CLAUDE.md no-fallback rule:

### fatalError (developer errors)
- `daily_messages.json` missing or unparseable.
- `messages.isEmpty` after parse.

### User-state branches
| State | Behavior |
|---|---|
| `lastReadInfo == nil` | Empty-state Continue card |
| `lastReadInfo.surahNumber` not in `availableSurahs` | Treat as new user; log warning |
| `dailyMessage.today.surah` not in availableSurahs | Banner renders text; tap is no-op; log |
| Streak == 0 | Badge shows `"🔥 0"` (matches existing convention) |
| `duasManager.duas.isEmpty` | Hide Du'a card until loaded |
| Midnight rollover mid-render | Banner stays on yesterday's verse until next `.onAppear` / scene-active |
| Translation contains `"..."` | Wrap with curly quotes; do NOT pre-strip — keep verse faithful |
| Sign-out / user switch | `ProgressManager.clearAllLocalData()` already handles — `lastReadInfo` becomes nil → empty state |

### Theme adaptation helpers
```swift
private var cardBackground: some View {
    Group {
        if themeManager.selectedTheme == .warmInviting {
            RoundedRectangle(cornerRadius: 22).fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 9, y: 6)
        } else {
            RoundedRectangle(cornerRadius: 22).fill(themeManager.glassEffect)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(themeManager.strokeColor, lineWidth: 1))
        }
    }
}
```
Same pattern for verse-tile bg (`#FBF6F0` vs `glassEffect`) and avatar tile (`#FCE6D5` vs `accentColor.opacity(0.2)`). Banner gradient + Resume pill stay literal across themes.

### Accessibility
- Streak: `accessibilityLabel("Reading streak: \(n) days. Tap to view progress.")`
- Banner: `accessibilityLabel("\(headline). \(sourceLabel). Double tap to open verse.")`
- Resume pill: standard button label.
- Hijri pill: `accessibilityLabel("\(day) \(monthFullName)")` (avoid abbreviations).
- Dynamic Type: fixed `.system(size:)` matches handoff; very-large sizes won't auto-scale (consistent with HomeView).

## Verification plan

No XCTest target exists; verification is manual + Previews.

### Build
- `xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` succeeds.
- Warning count does not increase vs. main.

### SwiftUI Previews
- `#Preview("Warm — populated")`
- `#Preview("Royal — populated")`
- `#Preview("Modern Dark — populated")`
- `#Preview("Empty state (new user)")` — most important.

### Manual smoke checklist (iPhone 16 Pro simulator)
1. Tab order is Home / Today / Explore / Progress (+ Ramadan if season). Tags match.
2. Hijri date pill shows correct date and weekday.
3. Streak badge matches ProgressTab. Tap → Progress.
4. Banner: verse renders, source correct. Tap → SurahDetailView at correct verse. Long-press → share sheet.
5. Daily message determinism: relaunch app — same verse. Flip simulator clock +1 day — verse changes.
6. Empty-state Continue path (fresh install / `resetProgress()`): card shows; Begin → Surah 1.
7. Populated Continue path: mark a verse read elsewhere, return → card shows correct surah, %, time. Resume → SurahDetailView at verse.
8. Du'a card content matches `daily_duas.json[dayOfYear % count]`. Tap → DuaDetailView.
9. Theme switch: warm → royal → modern. Today re-renders cleanly. Banner stays peach.
10. Pull-to-refresh: daily message unchanged. Continue card re-evaluates.
11. Cross-midnight scene-phase: banner refreshes on `.active`.
12. Sign-out: Continue card reverts to empty state.
13. Streak == 0 renders cleanly.

### Out of scope for tests
- Unit tests for `DailyMessageProvider.resolveToday()` — would require new test target. Manual date-flip is sufficient.
- Cross-device sync of `verseProgress` — covered by existing ProgressManager sync; Today is read-only over it.
