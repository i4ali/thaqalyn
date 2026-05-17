# Handoff: Today Tab (althaqalayn / Thaqalayn)

## Overview
A new **Today** tab for the Thaqalayn iOS app. The screen is the user's daily home — a single glance gives them:
1. A rotating uplifting reminder (a short Quranic verse / reflection that changes each day or each visit).
2. A quick way to **continue reading** from where they left off.
3. Two small daily helpers: a Du'a of the day and a journaling reflection prompt.

The chosen design direction is **"Card Stack"** — a warm, light layout that matches the existing Thaqalayn visual system (soft lavender→cream gradient background, white rounded cards, peach/orange accent, bold rounded SF Pro typography).

## About the Design Files
The files in this bundle are **design references created in HTML/React** — prototypes that show the intended look and behavior. They are *not* production code to copy directly.

Your task: **recreate this design in SwiftUI** inside the existing `Thaqalayn/` Xcode project. Reuse the app's existing primitives where possible:
- `ThemeManager.shared` (`primaryText`, `secondaryText`, `tertiaryText`, `accentColor`, `glassEffect`, `strokeColor`).
- `AdaptiveModernBackground` for the screen background gradient.
- `ProgressManager.shared` for streak + reading progress.
- `BookmarkManager.shared` for "last read verse".
- `DataManager.shared.availableSurahs` to resolve the surah for the continue-reading card.

## Fidelity
**High-fidelity.** All colors, paddings, radii, font sizes, and weights below are intended to be matched exactly. If a value isn't listed, derive it from the HTML mock at `today/today.jsx`.

## Where this lives in the app
Add a new tab to `MainTabView.swift` between Home and Explore, titled **"Today"**, system image `sun.max.fill`. Tab order:

| Tag | Title    | Icon                  |
|-----|----------|-----------------------|
| 0   | Home     | `house.fill`          |
| 1   | **Today** | `sun.max.fill`       |
| 2   | Explore  | `sparkles`            |
| 3   | Progress | `circle.circle`       |
| 4*  | Ramadan  | `moon.stars.fill`     |

\* conditional, unchanged.

Create files:
- `Thaqalayn/Views/Tabs/TodayTab.swift` — `NavigationView` wrapper that hosts `AdaptiveModernBackground` + `TodayView`.
- `Thaqalayn/Views/TodayView.swift` — the screen below.
- `Thaqalayn/Services/DailyMessageProvider.swift` — supplies the rotating reminder.

---

## Screen: Today

Vertical stack from top to bottom. All horizontal padding is **18pt** unless noted; section gap is **14pt**.

### 1. Header row (padding 22pt horizontal)
- **Hijri date pill** (left): white pill, 1px border `rgba(0,0,0,0.05)`, padding `6×12pt`, radius `999`, font 12pt / weight 600, color `#5A4A40`, letter-spacing 0.2, uppercase. Content: `"15 RABI' AL-AWWAL · MON"` (use `IslamicCalendarManager` for live values; format day-of-week 3 letters, uppercase).
- **Streak badge** (right): white pill, same shape; flame emoji 🔥 + bold integer in `#D17A48`. Tap → ProgressTab.

### 2. Greeting block (margin-top 18pt)
- Line 1: `"Assalāmu ʿalaykum, {firstName} 🌙"` — 14pt / weight 500 / `secondaryText`. If user is signed-out or has no name, use just `"Assalāmu ʿalaykum 🌙"`.
- Line 2: `"Today"` — **32pt / weight 800**, `letterSpacing -0.6`, `lineHeight 1.1`, `primaryText`.

### 3. Daily reminder banner (margin-top 20pt, radius 22pt)
A peach gradient card.

- Background: `linear-gradient(135deg, #F4B188 0%, #E89464 60%, #D17A48 100%)`.
- Shadow: `0 12px 28px rgba(209,122,72,0.28)`.
- Padding: `18pt` all sides.
- Decorative crescent (top-right): two overlapping 110–120pt circles in `rgba(255,255,255,0.12)` and an inset white shadow ring; pure ornament, ignore on small screens if awkward.
- Eyebrow row: ✦ sparkle icon (14pt) + `"A REMINDER FOR TODAY"` 11pt / weight 700 / letter-spacing 1.3 / white at 92% opacity.
- Headline: the daily verse/quote — **19pt / weight 700 / lineHeight 1.3 / -0.2 tracking / max-width ~270pt**, white. Use curly quotes: `"…"`.
- Source line: `12.5pt / opacity 0.85`. Format: `"{Surah Name} · {chapter}:{verse}"`.
- Tap → opens the source verse in `SurahDetailView` (deep-link).

**Daily message rotation** — see "DailyMessageProvider" below.

### 4. "Continue reading" hero (margin-top 14pt)
Section header row above the card:
- Left: `"CONTINUE READING"` 13pt / weight 700 / `letterSpacing 0.4` / uppercase / `secondaryText`.
- Right: relative time string e.g. `"4 min ago"`, 12pt / `tertiaryText`.

Card:
- White, radius `22pt`, padding `16pt`, shadow `0 6px 18px rgba(60,40,30,0.06)` + inner 1px border `rgba(0,0,0,0.03)`.

Inside the card, three sub-rows with `12pt` vertical gaps:

**a) Surah identity row**
- Square avatar 48×48pt, radius 14pt, fill `#FCE6D5`, surah number centered in `#D17A48` weight 800 18pt.
- Stack: name 16pt / weight 700; sub `"Verse 153 of 286 · The Cow"` 12pt / `tertiaryText`.
- Right: Arabic surah name in Amiri 22pt / `primaryText`.

**b) Verse preview tile**
- Background `#FBF6F0`, radius `14pt`, padding `14pt 14pt 12pt`.
- Arabic line: Amiri 19pt / lineHeight 1.7 / `text-align right` / `direction rtl`.
- Translation: 12.5pt / `secondaryText` / lineHeight 1.5, prefixed/wrapped with curly quotes.

**c) Progress + Resume row** (flex, gap 10pt)
- Progress bar: full-width, height 6pt, track `#F1ECE6`, fill `#E89464`, radius `999`, `{n}% complete` 11pt weight 600 `tertiaryText` below.
- "Resume" pill button (right): height 36pt, padding `10×16pt`, radius `999`, background `#221C18`, white text 13pt weight 700, with a small play triangle icon (12pt) before label. Tap → opens `SurahDetailView` at the saved verse, scroll-to anchor.

### 5. Mini cards row (margin-top 12pt, 2-column grid, gap 10pt)

Each card: white, radius `18pt`, padding `14pt`, shadow `0 4px 14px rgba(60,40,30,0.05)`.

- **Du'a of the day**: 28×28pt rounded square `#FFF1E2` icon tile, quote glyph in `#D17A48`. Title `"Du'a of the day"` 12pt weight 700 `secondaryText`. Headline `"For ease in difficulty"` 13pt weight 600. Sub `"30 sec"` 11pt `tertiaryText`. Tap → `DuaDetailView`.
- **Reflection**: same shape; tile `#E8F4ED`, leaf icon `#2E8B53`. Title `"Reflection"`. Headline a question (e.g. `"What does sabr mean to you?"`). Sub `"Tap to journal"`. Tap → opens a journaling sheet (new view; out of scope to design here — just navigate to a placeholder `ReflectionJournalView` you can stub).

---

## DailyMessageProvider

A small service that returns `{ arabic?: String, english: String, sourceLabel: String, surah: Int, verse: Int }`.

Behavior:
- Curated list of ~30–60 short verses + a few hadith/reflections, stored as a JSON resource (`daily_messages.json`) bundled with the app.
- Selection: deterministic per **calendar day in the user's local timezone** — `index = dayOfYear(today) % messages.count`. This guarantees:
  - Everyone sees the same message on the same day (good for community feel).
  - A pull-to-refresh **does NOT** reroll the message.
- Provide a `peekNext()` for testing.
- Cache the resolved `Message` for the day in `UserDefaults` keyed by `yyyy-MM-dd` so rendering is synchronous.

If you want a "pagination dots" affordance later (variation C had it), expose `messages(forDay:)` returning a small set of 3–5 alternates.

## Continue-reading source of truth

`BookmarkManager` (or `ProgressManager`, whichever already tracks last-read state) should expose:
```swift
struct LastRead {
  let surahNumber: Int
  let verseNumber: Int
  let progress: Double      // 0…1 within that surah
  let updatedAt: Date
}
var lastRead: LastRead? { get }
```

If `lastRead == nil` (new user), replace the Continue card with an **empty-state** card:
- Same shape, but content: `"Start your journey"` headline, `"Open Surah Al-Fātiḥa"` body, single full-width pill button `"Begin"` that pushes Surah 1.

---

## Interactions & Behavior

- **Pull to refresh**: re-reads bookmarks, recomputes progress; does NOT change the daily message.
- **Tap reminder banner** → push `SurahDetailView` for the source verse.
- **Tap surah identity row or Resume** → push `SurahDetailView` for last-read surah, with `targetVerse: lastRead.verseNumber` (existing deep-link param).
- **Tap streak badge** → switch to Progress tab (use selectedTab binding).
- **Long-press reminder banner** → present a share sheet with the verse text + source.
- **Appearance animation**: the three main blocks (banner, continue card, mini-cards) fade-in with a 60–80ms stagger, `easeOut(0.35s)`, on first appear only.
- **Dark mode**: keep the gradient banner saturated; for everything else swap white surfaces to `themeManager.glassEffect`, ink to `primaryText`, etc. The Card Stack reads well in both.

## State Management

```swift
@StateObject private var themeManager = ThemeManager.shared
@StateObject private var bookmarkManager = BookmarkManager.shared
@StateObject private var progressManager = ProgressManager.shared
@StateObject private var dailyMessage = DailyMessageProvider.shared

@State private var selectedSurahForDeepLink: SurahWithTafsir?
@State private var targetVerseNumber: Int?
@State private var showingReminderSource = false
```

Re-resolve `lastRead` and `dailyMessage.today` in `.onAppear` and on `.scenePhase == .active`.

---

## Design Tokens (Card Stack)

### Color
| Token              | Hex        | Notes                        |
|--------------------|------------|------------------------------|
| bg.gradient.start  | `#F2EBF6`  | top of screen                |
| bg.gradient.end    | `#FFF7EE`  | bottom of screen             |
| ink                | `#221C18`  | primary text                 |
| ink.2              | `#5A4A40`  | secondary text               |
| ink.3              | `#9A8C82`  | tertiary text                |
| surface            | `#FFFFFF`  | cards                        |
| surface.warm       | `#FBF6F0`  | inset verse tile             |
| accent             | `#E89464`  | primary accent (peach)       |
| accent.deep        | `#D17A48`  | hover/pressed/dark-on-light  |
| accent.soft        | `#FCE6D5`  | tinted backgrounds           |
| icon.green.bg      | `#E8F4ED`  | reflection tile              |
| icon.green.fg      | `#2E8B53`  |                              |
| icon.peach.bg      | `#FFF1E2`  | du'a tile                    |

### Type
- Display 32 / 800 / -0.6 (Today)
- Title 19 / 700 / -0.2 / 1.3 lh (banner headline)
- Card title 16 / 700 (surah name)
- Body 14 / 500
- Body small 12.5 / 400 (translation)
- Caption 12 / 600 (subtitles)
- Eyebrow 11 / 700 / 1.3 letter-spacing / uppercase
- Numeric mono not required.
- Arabic: Amiri (already in app? otherwise system Arabic) 19–22pt depending on slot, lineHeight 1.7.

### Radii
- Banner / hero card: **22pt**
- Mini card: **18pt**
- Verse inset tile: **14pt**
- Avatar tile: **14pt**
- Pill / streak / Resume: **999**

### Shadow
- Banner: `0 12px 28px rgba(209,122,72,0.28)`
- Hero card: `0 6px 18px rgba(60,40,30,0.06)`
- Mini card: `0 4px 14px rgba(60,40,30,0.05)`
- Pills: `0 1px 3px rgba(0,0,0,0.05)`

### Spacing scale used in this screen
4 / 6 / 8 / 10 / 12 / 14 / 16 / 18 / 20 / 22pt.

---

## Assets
No new image assets are required. All glyphs in the mock are line icons drawn inline as SVG; in SwiftUI, replace with SF Symbols:

| Mock icon | SF Symbol            |
|-----------|----------------------|
| sparkle   | `sparkles`           |
| play      | `play.fill`          |
| quote     | `quote.bubble.fill`  |
| leaf      | `leaf.fill`          |
| arrow     | `arrow.right`        |
| flame     | `flame.fill` (or 🔥)  |

The 🔥 emoji in the streak badge is intentional — keep the emoji rather than `flame.fill` to match `HomeView`'s existing style.

## Files in this bundle
- `today/Today.html` — entry point, opens the design canvas.
- `today/today.jsx` — all three concept screens (`VariationA` is the chosen Card Stack).
- `design-canvas.jsx`, `ios-frame.jsx` — local starter components (referenced by Today.html).

Open `today/Today.html` in a browser to see the live mock. The Card Stack is the leftmost artboard; click ⤢ to open it fullscreen.
