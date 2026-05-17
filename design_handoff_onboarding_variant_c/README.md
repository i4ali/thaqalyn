# Handoff — Onboarding Redesign (Variant C · "Native")

## Overview

A redesign of the 10-screen onboarding flow for the Thaqalayn iOS app. This variant ("Native") stays faithful to the app's existing warm-and-inviting visual vocabulary — soft lavender→peach gradient backgrounds, pastel rounded-square icon "chips," friendly bold sans titles, generous rounded white cards, and the existing peach accent CTA — but elevates the layout: better typographic hierarchy, glowing hero badges, gradient CTAs, and per-screen subtle background hue shifts to give the flow visual rhythm.

The flow is 11 screens in the redesign (an explicit Quiz Result screen was added after the Quiz Feature screen). If you want to keep parity with the 10-screen current flow, merge `06-quiz-feature` and `07-quiz-result` into a single screen with an animated transition between question and result (see "State Management" below for guidance).

## About the Design Files

The files in this bundle (`design-files/Onboarding.html` + the `.jsx` files) are **design references created in HTML/React** — prototypes showing intended look and behavior, not production code to copy. The task is to **recreate these designs in SwiftUI inside the existing Thaqalayn Xcode project**, using the codebase's established patterns:

- `ThemeManager.shared` for colors (`primaryBackground`, `primaryText`, `secondaryText`, `tertiaryText`, `accentColor`, `accentGradient`, `glassEffect`, `strokeColor`).
- The existing files in `Thaqalayn/Views/Onboarding/` (one per screen, listed below) — modify these in place rather than creating parallel files.
- The existing `OnboardingFlowView` coordinator (paged `TabView` with skip button and `darkScreenAura()` wrapper).
- The existing `darkScreenAura()` modifier and warm-theme helpers in `Utilities/`.

Do **not** introduce a separate design-tokens file or theme system — extend `ThemeManager` only if you need a new semantic color that's reused 3+ times across the redesign.

## Fidelity

**Hi-fi.** Pixel-perfect mockups with final colors, typography, spacing, and interactions. Recreate using the codebase's existing `ThemeManager` colors where they semantically match (see "Color Mapping" below); use the explicit hex values from this doc only when no theme token applies (e.g., the pastel chip backgrounds, which are net-new).

## Screen Map

The 11 redesigned screens map to the existing 10 SwiftUI screen files as follows. Numbering on the left is the **redesign order**; the file name is the **existing SwiftUI screen** to modify:

| #  | Redesign label       | SwiftUI file to modify                                   |
|----|----------------------|----------------------------------------------------------|
| 01 | Welcome (Hadith)     | `Views/Onboarding/HadithScreen.swift`                    |
| 02 | Mission              | `Views/Onboarding/MissionScreen.swift`                   |
| 03 | Five Layers          | `Views/Onboarding/FiveLayersScreen.swift`                |
| 04 | Gems                 | `Views/Onboarding/QuickGemsScreen.swift`                 |
| 05 | Progress Tracking    | `Views/Onboarding/ProgressTrackingScreen.swift`          |
| 06 | Quiz Feature         | `Views/Onboarding/QuizFeatureScreen.swift` (question state) |
| 07 | Quiz Result          | `Views/Onboarding/QuizFeatureScreen.swift` (result state)   |
| 08 | Bismillah / Tracking | merge into `ProgressTrackingScreen` OR keep as a sub-section |
| 09 | Stay Motivated       | `Views/Onboarding/ProgressNotificationsScreen.swift`     |
| 10 | Seasonal Features    | `Views/Onboarding/SeasonalFeaturesScreen.swift`          |
| 11 | Begin Journey        | `Views/Onboarding/FinalScreen.swift`                     |

Open `screenshots/` for the final visual of each. The `design-files/Onboarding.html` prototype shows all three explored variants side-by-side; **only Variant C is being shipped** (the section labelled "Variant C · Native").

---

## Design System — what's new vs. what to reuse

### Reuse from existing app
| Reuse                                  | Token                                |
|---------------------------------------|--------------------------------------|
| Page background gradient              | `themeManager.primaryBackground`     |
| Primary text                          | `themeManager.primaryText`           |
| Secondary text                        | `themeManager.secondaryText`         |
| Tertiary / placeholder text           | `themeManager.tertiaryText`          |
| Accent (peach) for buttons, highlights | `themeManager.accentColor`           |
| Accent gradient for CTAs              | `themeManager.accentGradient`        |
| Skip pill background                  | `themeManager.glassEffect`           |
| Dark-mode aura on the flow            | `.darkScreenAura()` (already applied in `OnboardingFlowView`) |

### New tokens (Variant C "Native")

These are **chip palette** colors — flat pastel backgrounds with a saturated icon color. Each pairs a `chip` (fill) with an `ic` (foreground icon color). Add these as static properties on `ThemeManager`, named semantically (not "plum"/"sky" — use intent like `chipBrand`, `chipKnowledge`, `chipSeasonal`, etc., per your preference).

| Name             | Chip (bg)   | Icon (fg)   | Use for                          |
|------------------|-------------|-------------|----------------------------------|
| Peach (brand)    | `#FCE0CC`   | `#C66829`   | Welcome, daily verse, motivation |
| Plum             | `#EAD8F0`   | `#8C539F`   | Layers, quiz, gems "throne"      |
| Mint             | `#D6EADF`   | `#3B8459`   | Progress tracking, check states  |
| Sky              | `#D8E8F4`   | `#3D78B2`   | Foundation layer, future content |
| Butter           | `#F8EAC9`   | `#B5862A`   | Daily-verse star, "Kursi" tag    |
| Rose             | `#F4D8D8`   | `#C25656`   | (reserved — not used in C)       |
| Mauve            | `#E6DDE9`   | `#7B6688`   | Comparative layer                |

### Background gradients (per-screen "tilt")

Each screen tilts the page gradient slightly to create a flow rhythm. Implement as a `LinearGradient` in the screen's `ZStack` background **above** `themeManager.primaryBackground` so light/dark mode still respects the global theme — but only in **light mode**. In dark mode, keep `themeManager.primaryBackground` only and let `darkScreenAura()` do the atmosphere.

| Tilt name | Top stop (light) | Mid stop  | Bottom stop |
|-----------|------------------|-----------|-------------|
| lavender  | `#F1E9F4`        | `#F5E8E5` | `#FAF2E8`   |
| peach     | `#F5E6E6`        | `#F8E5D2` | `#FAF2E8`   |
| mauve     | `#ECE3F2`        | `#F2E6E8` | `#FAF2E8`   |
| sage      | `#E6EEEB`        | `#F0EBE2` | `#FAF2E8`   |

Per-screen assignment: 01 peach · 02 lavender · 03 mauve · 04 peach · 05 lavender · 06 mauve · 07 mauve · 08 sage · 09 peach · 10 mauve · 11 peach.

A soft amber radial glow (`radial-gradient(rgba(232,148,100,0.18), transparent 60%)`, blurred 8px, centered ~ top of viewport, 500×400) sits above each tilted gradient. Skip this in dark mode.

### Typography

System fonts only — no custom font import. Match these to SwiftUI `.system(size:weight:)`:

| Role                | iOS                                              | Notes |
|---------------------|--------------------------------------------------|-------|
| Hero title          | `.system(size: 30, weight: .heavy)` · tracking `-0.6`, line height `1.1` | "Welcome to Thaqalayn", "5 Layers of Wisdom", etc. |
| Welcome title (11)  | `.system(size: 34, weight: .heavy)` · tracking `-0.8`, line height `1.05` | "Begin Your Journey" |
| Section eyebrow     | `.system(size: 11.5, weight: .bold)` · tracking `3.4`, uppercase | "THE TWO WEIGHTY THINGS" |
| Card title          | `.system(size: 16, weight: .heavy)` · tracking `-0.3` | "Al-Baqarah 255", "Ramadan Journey" |
| Row title           | `.system(size: 15, weight: .bold)` · tracking `-0.2` | feature rows, layer rows |
| Body                | `.system(size: 14.5, weight: .medium)` · line height `1.45` | sub-headlines under hero |
| Caption             | `.system(size: 12, weight: .medium)` | meta, "Surah 22, Verse 27" |
| Caption muted       | `.system(size: 11)` color tertiary | timestamps |
| Pill text           | `.system(size: 11.5, weight: .bold)` · tracking `0.3` | chip labels, gem tags |
| Arabic verse        | `.system(size: 22, design: .serif, weight: .medium)`, line height `1.85`, `.environment(\.layoutDirection, .rightToLeft)`, `.multilineTextAlignment(.trailing)` | use system serif for Arabic — matches existing screens |
| Arabic logotype "ثقلين" | `.system(size: 96, weight: .bold)` · tracking `-2` | screen 01 only |
| Arabic small mark   | `.system(size: 44, weight: .regular)` color `accentColor` with shadow `accentColor.opacity(0.4) radius 30` | screen 11 |
| Big numeral (score) | `.system(size: 80, weight: .heavy)` · tracking `-3`, gradient fill `accentGradient` or plum gradient | screen 07 |

### Spacing & radii

| Token        | Value | Used for |
|--------------|-------|----------|
| Screen padding | 22    | left/right padding for cards |
| Section gap    | 28    | hero → title block |
| Card padding   | 20    | inside white cards |
| Card radius    | 22    | primary white cards |
| Small card     | 18    | secondary/feature rows |
| Chip radius    | 12–14 | icon chips (12 for small, 14 for medium, 18 for hero) |
| Hero chip      | 88×88, radius 28 | per-screen "halo" icon at the top |
| Pill radius    | 999   | tags, page-indicator background |
| CTA radius     | 18    | bottom action buttons |
| Inner stat tile| 14    | 3-up stat strip inside result card |

### Shadows

| Use            | Shadow                                                 |
|----------------|--------------------------------------------------------|
| White cards    | `color: rgba(60,40,20,0.06), radius: 12, x: 0, y: 8`   |
| Feature rows   | `color: rgba(60,40,20,0.04), radius: 6, x: 0, y: 2`    |
| Primary CTA    | `color: rgba(198,104,41,0.35), radius: 14, x: 0, y: 10` + inset top highlight `rgba(255,255,255,0.3) y:1` |
| Hero halo      | radial gradient behind chip — `accentColor.opacity(0.34)`, 65% transparent-stop, blur 10 |

### CTAs

- **Primary** — `accentGradient` background, white text, 17pt padding vertical, 18px corner radius, inset top white highlight, drop shadow as above. Icon-left + label.
- **Secondary** — white fill, 1px hairline `rgba(31,22,18,0.07)` border, ink text. Same size and radius. Used for "Create Account", "Sign In".
- **Ghost** — no background, just centered text, `secondaryText` color. Used for "Continue as Guest" alt action and the skip-link feel.

### Page indicator

Bottom-center pill (`background: rgba(255,255,255,0.6)`, backdrop blur 10, 8×12 padding, 999 radius), 7 dots, active dot 8×8, inactive 6×6 (`rgba(31,22,18,0.2)`). Honestly — keep the existing `.tabViewStyle(.page(indexDisplayMode: .always))` indicator if the system one is close enough; custom is only needed if you want the pill backdrop.

---

## Screen-by-screen specifications

For every screen unless noted otherwise:
- Status bar handled by iOS (do not draw)
- **Skip** pill in top-right (`themeManager.glassEffect`, 8×16 padding, ghost text `secondaryText`) — already wired in `OnboardingFlowView`
- **Hero badge** at the top: an 88×88 chip with the screen's icon at 38pt, halo gradient behind. Sits at top `y ≈ 110` from the safe-area top
- **Title block** centered, ~`y 246`: hero title (30/heavy) + 14.5pt body subline, max-width 300, line-height 1.45
- **Page indicator** centered at bottom (`bottom: 24`)

### 01 — Welcome (Hadith)
**File:** `HadithScreen.swift` · **Tilt:** peach · **Hero:** none (the Arabic logotype IS the hero)

- Drop `GeometricPatternBackground`. Replace with the peach tilt gradient + radial amber glow.
- Centered Arabic mark `ثقلين` at `y 110`, 96pt heavy, tracking -2, with a radial behind it (`rgba(232,148,100,0.34)`, blur 10, inset -30%).
- Eyebrow at `y 246`: "THE TWO WEIGHTY THINGS" — `iconPeach` color, 11.5pt bold, tracking 3.4, uppercase.
- Hero title at `y 290`: "Welcome to Thaqalayn" — 30/heavy.
- Sub at `y 332` ish, max-width 290: "The Quran and the wisdom of the Ahlul Bayt, made for everyday companionship."
- **Hadith card** at `y 432`: white, 24-radius, 22-padding. Contains:
  - Small chip-row header: 32×32 peach chip with sparkle icon + eyebrow "HADITH OF THAQALAYN" (11.5/bold, tracking 2, `iconPeach`).
  - Arabic text (full hadith) centered, 20pt serif, line-height 1.85, two lines: `إنّي تاركٌ فيكم الثقلين / كتاب الله وعترتي أهلَ بيتي`.
  - 1px hair divider (`rgba(31,22,18,0.07)`).
  - English translation centered, 14pt body, secondary text.
  - "— Prophet Muhammad ﷺ" centered, 11/semibold, tracking 1.5, uppercase, tertiary.
- **Primary CTA** at bottom: "Begin the journey →"
- **Drop** the auto-advance-after-5-seconds and tap-anywhere-advances behaviors. Use the standard swipe + CTA.

### 02 — Mission
**File:** `MissionScreen.swift` · **Tilt:** lavender · **Hero icon:** book (peach chip)

- Hero chip with `book.closed.fill` SF Symbol, halo amber.
- Title: "Wisdom at your fingertips"
- Sub: "Everything you need to read, reflect, and grow — in one calm companion."
- **Feature list** of 4 rows in white cards (18-radius, vertical stack with 10px gaps):
  - Peach chip · `book.closed.fill` · **Complete Quranic text** · "with English & Urdu translation"
  - Plum chip · `sparkles` · **5 layers of commentary** · "authentic Shia scholarship"
  - Butter chip · `bell.fill` · **Daily verses** · "aligned with the Islamic calendar"
  - Rose chip · `heart.fill` · **Sync bookmarks** · "across iPhone, iPad and the web"
- 42×42 chips, 12-radius, 20pt icon inside. Row padding 12×14.
- The existing `HighlightRow` component does this but with `accentGradient` chips — change to the new pastel-chip styling, one chip color per row.
- Keep the existing shimmer + stagger fade-in animation (0.6s ease-out, 0.2s stagger). Don't keep the giant Arabic at the top — that's now on screen 01.

### 03 — Five Layers
**File:** `FiveLayersScreen.swift` · **Tilt:** mauve · **Hero icon:** columns/3-bars (plum chip)

- Hero chip with `square.stack.3d.up.fill` or `text.alignleft` (use whichever feels closer; current code uses an info-style icon — replace).
- Title: "5 Layers of Wisdom"
- Sub (caption, not body): "Tap each layer to explore"
- **Layer rows** (5 cards, 8px gaps, white 18-radius):
  1. Sky chip · `square.stack.3d.up.fill` · **Foundation** · "Simple explanations & history"
  2. Plum chip · `book.closed.fill` · **Classical Shia** · "Tabatabai, Tabrisi, al-Tusi"
  3. Mint chip · `globe` · **Contemporary** · "Modern & scientific perspectives"
  4. Peach chip · `star.fill` · **Ahlul Bayt** · "Hadith from the 14 Infallibles"
  5. Mauve chip · `scale.3d` · **Comparative** · "Balanced Shia & Sunni scholarship"
- Right-side chevron (`chevron.right`, 14pt, tertiary) — implies tappable (these don't navigate in onboarding, but the affordance reads).

### 04 — Quick Gems
**File:** `QuickGemsScreen.swift` · **Tilt:** lavender · **Hero icon:** sparkles (butter chip, filled)

- Hero chip with `sparkles` filled in `iconButter`, halo butter `#C49431`.
- Title: "Gems" (single word)
- Sub: "Precious insights unveiled"
- **Verse card** (white, 22-radius, 20-padding):
  - 36×36 round badge with linear gradient `iconPlum → iconSky`, white "255" centered, 12pt heavy.
  - "Al-Baqarah 255" 16/heavy beside the badge.
  - Arabic verse fragment (22pt serif, line-height 1.8, RTL, right-aligned):
    `ٱلْقَيُّومُ ٱلْحَىُّ لَا إِلَٰهَ إِلَّا هُوَ ٱللَّهُ`
  - **Gem tags** wrapping below — 4 pills, each a different chip color. Icon + label, 6×11 padding, 999 radius, 11.5/bold:
    - Plum · crown · "The Throne Verse"
    - Mint · sparkle · "The Ever-Living"
    - Sky · globe · "Cosmic Owners…"
    - Butter · star · "The Kursi"
- **Insight card** below (white, 18-radius, 14-padding): plum chip + eyebrow "THE THRONE VERSE" (plum, 10.5/heavy, tracking 1.8, uppercase) + 13pt body explaining significance.

### 05 — Progress Tracking
**File:** `ProgressTrackingScreen.swift` (light) · **Tilt:** lavender · **Hero icon:** chart (sky chip)

If you keep the redesign's 11-screen flow, this screen has the **feature rows** style (chart / streak / badges). If you stick with 10 screens, merge the feature rows into screen 09 "Stay Motivated" instead. In Variant C as designed, screen 05 is actually a "Track Your Progress" card-grid intro — but the existing `ProgressTrackingScreen.swift` is rich enough already, so use that file for whichever role fits.

- Title: "Track Your Progress"
- Sub: "Master the Quran, verse by verse"
- Bismillah verse card with controls (play / heart / done check) — see screen 08 spec.
- Surah progress card: "Al-Baqarah · The Cow" 14/bold + "last read 4 minutes ago" 11 tertiary, **53%** label in `iconMint` 18/heavy, 8-tall progress bar with gradient `iconMint → #56A879`.

### 06 — Quiz Feature
**File:** `QuizFeatureScreen.swift` (question state) · **Tilt:** mauve · **Hero icon:** brain (plum chip)

- Hero plum chip with `brain.head.profile` (or `lightbulb.fill`).
- Title: "Test Your Knowledge"
- Sub: "Quizzes for every surah"
- **Quiz card** (white, 22-radius, 18-padding):
  - Centered pill at top: sky chip "FOUNDATION" with `square.stack.3d.up.fill` icon (5×11 padding, 12/bold, tracking 0.3).
  - Question text centered: "What does 'Kursi' represent in Ayat al-Kursi?" — 17/heavy, line-height 1.3.
  - 4 answer rows (12-padding, 14-radius, 1.5px border, 8px gap):
    - Default rows: bg `#FBF6EE`, hairline border `rgba(31,22,18,0.07)`, 28×28 round letter badge (white fill, ink letter A/B/C/D).
    - Selected/correct row: bg peach chip `#FCE0CC`, border accent peach `#E89464`, 28×28 round badge in accent fill with white check mark.
  - Answer text 13.5/semibold, ink color.
- Caption at bottom (above page indicator): "Deepen your understanding through reflection" — 13pt tertiary.

### 07 — Quiz Result
**File:** `QuizFeatureScreen.swift` (result state — or split into its own screen) · **Tilt:** mauve · **Hero icon:** brain (plum chip)

If you keep the 10-screen flow, **animate** between the question and result states in `QuizFeatureScreen` (cross-fade / slide). Otherwise, add a `QuizResultScreen.swift`.

- Same hero, title, sub as 06.
- **Result card** (white, 24-radius, 22×20-padding, 1.5px plum border `#EAD8F0`, deeper shadow `rgba(140,83,159,0.18)`):
  - 72×72 plum chip (radius 24) at top with `book.closed.fill` icon, halo `rgba(151,100,168,0.30)` blur 6.
  - "Scholar Level" centered 24/heavy.
  - Arabic "عالم" centered, 24pt, plum color, 4pt below title.
  - **Score numeral**: "9" rendered with a gradient mask (plum `#8C539F → #6F3F88` vertical), 80pt heavy, tracking -3, plus "/10" 28pt tertiary baseline-aligned.
  - 14pt secondary "Excellent understanding!" centered.
  - **3-stat strip** (gap 8, equal columns, 14-radius `#FAF4F7` tiles, hairline border):
    - 12 · Quizzes
    - 87% · Avg score
    - 5 · Surahs
  - Stat value 18/heavy in `iconPlum`, label 10/semibold tertiary uppercase tracking 0.6.

### 08 — Bismillah & tracking detail
**File:** merge into `ProgressTrackingScreen.swift` or use as its detail · **Tilt:** sage · **Hero icon:** check (mint chip)

- Hero chip mint, `checkmark` at 40pt stroke 2.6.
- Title: "Track Your Progress"
- Sub: "Master the Quran, verse by verse"
- **Bismillah card** (white, 22-radius, 18-padding):
  - Header row: 32×32 round verse-number badge (gradient plum→sky, white "1") on the left; on the right a 3-icon control strip (play / heart-outline / mint-square-check), all 14–16pt.
  - Centered Arabic at 26pt serif: `بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ`
  - 13.5pt secondary translation centered: "In the name of Allah, the Most Gracious, the Most Merciful."
- **Surah progress card** below (white, 18-radius): exactly the spec from screen 05.

### 09 — Stay Motivated
**File:** `ProgressNotificationsScreen.swift` · **Tilt:** peach · **Hero icon:** flame (peach chip)

- Hero peach chip with `flame.fill`, halo amber.
- Title: "Stay Motivated"
- Sub: "Build your reading streak and earn badges"
- **3 feature rows** (white 18-radius, gap 10, 14-padding, 48×48 chips with 22pt icons):
  - Sky chip · `chart.bar.fill` · **Track Your Progress** · "See your daily verse count and reading streaks"
  - Peach chip · `flame.fill` · **Build Streaks** · "Read daily to maintain your streak"
  - Butter chip · `trophy.fill` · **Earn Badges** · "Complete surahs and hit milestones"
- **Primary CTA**: "Enable Progress Reminders" with `bell.fill` icon.
- Caption below CTA: "You can always enable this later in Settings" — 12pt tertiary.
- Hook up to existing `@Binding var progressNotificationsEnabled: Bool` — keep the toggle wiring on the CTA tap (don't replace it with a real toggle UI; the CTA acts as accept).

### 10 — Seasonal Features
**File:** `SeasonalFeaturesScreen.swift` · **Tilt:** mauve · **Hero icon:** moon (plum chip with peach icon)

- Hero plum chip with `moon.stars.fill` in `iconPeach`, halo amber.
- Title: "Special Seasons"
- Sub: "Unique experiences for blessed months"
- **Ramadan card** (white, 20-radius, 16-padding):
  - Top row: 44×44 peach chip with `moon.fill` + title "Ramadan Journey" 17/heavy + magenta "Seasonal" pill (gradient `#C764D5 → #9A48A8`, white text, 10.5/bold, tracking 0.4).
  - 4 small feature rows below — 22×22 butter mini-chip + 13pt secondary text:
    - sparkles · "Daily duas from Mafatih al-Jinan"
    - book.closed · "Curated Quranic verses with tafsir"
    - heart · "Reflections and spiritual guidance"
    - checkmark · "Track your 30-day progress"
- **"More Coming Soon" card** (white, 20-radius):
  - Top row: 44×44 sky chip with `calendar` + title "More Coming Soon" 16/heavy + blue "Future" pill (gradient `#5BA6F0 → #3D78B2`).
  - Tag pills below (sky chips with icon + label, wrap, 5×10 padding):
    - water-drop · "Muharram"
    - mountain · "Dhul-Hijjah"
    - sparkles · "Rajab"
    - star · "Holy nights"

### 11 — Begin Your Journey (Final)
**File:** `FinalScreen.swift` · **Tilt:** peach · **No hero chip** — small `ثقلين` mark at top

- Small Arabic "ثقلين" at `y 88`, 44pt, `iconPeach` color, shadow `rgba(232,148,100,0.4) radius 30`.
- Hero title "Begin Your Journey" at `y 172` — 34/heavy, tracking -0.8.
- Sub: "Sync your reading progress and bookmarks across all your devices." max-width 300.
- **CTA stack** at `y 330` (gap 10):
  1. **Primary** — `book.closed.fill` + "Continue as Guest" (peach gradient)
  2. **Secondary** — `person.fill.badge.plus` + "Create Account" (white, hairline border)
  3. **Secondary** — `person.fill` + "Sign In" (white, hairline border)
- **Benefits card** at `y 558` (white, 18-radius, 14×16-padding, centered): 24×24 mint chip with `heart.fill` + "Account Benefits" 12.5/bold tracking 0.3 + body "Sync bookmarks across devices and save your reading progress." 12.5pt tertiary line-height 1.5.
- **Legal** at bottom: "By continuing you agree to our **Terms** and **Privacy**." 11pt tertiary, underlined link words in `secondaryText`. No page indicator on this screen.
- Wire to existing `onComplete` callback when any of the three CTAs is tapped (matching current behavior).

---

## Interactions & Behavior

- **Navigation**: existing `TabView` with `.page(indexDisplayMode: .always)`. Keep swipe-left/right and the skip button.
- **No auto-advance**: drop the 5-second auto-advance on the Hadith screen and the tap-anywhere-to-advance handler. Users control pace via the CTA + swipe.
- **Entrance animations**: keep the existing per-screen fade-in / stagger (`Animation.easeOut(duration: 0.6).delay(...)`) and the Arabic-mark shimmer on screens that have it. Stagger order: hero badge → title → sub → cards → CTA.
- **Halo pulse**: the hero halo on each screen should breathe — `scaleEffect(pulse ? 1.05 : 1.0).animation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true))`. Same pattern as `glowPulse` in current `HadithScreen.swift`.
- **CTA pressed state**: 0.96× scale, 100ms ease-out.
- **Quiz screen (06)**: tapping an answer reveals correctness — animate the row's background/border into the "correct" state (250ms ease), then after 1.2s slide to screen 07. If keeping a single screen, cross-fade between question and result variants in-place.
- **Halo color** matches the hero chip's icon color, opacity 0.34, blurred 10.

## State Management

The `OnboardingFlowView` already owns the relevant state:
- `currentPage: Int` — paged tab index
- `notificationsEnabled: Bool` — daily-verse permission accept (bound into screen 04/`DailyVerseScreen`)
- `progressNotificationsEnabled: Bool` — progress-reminders accept (bound into screen 09/`ProgressNotificationsScreen`)

Add (only if you implement quiz interactivity):
- `quizSelected: Int?` in `QuizFeatureScreen` — index of tapped answer
- `quizResultShown: Bool` — gate for cross-fade to result state, auto-set true 1.2s after selection
- Use `@State` locally inside `QuizFeatureScreen`; no parent binding needed because the quiz is illustrative.

`completeOnboarding()` is unchanged.

## Assets

No new image assets required. **All icons are SF Symbols** — list per screen:

| Screen | Symbol(s) |
|--------|-----------|
| 01     | `sparkles` (mini chip header only) |
| 02     | `book.closed.fill`, `sparkles`, `bell.fill`, `heart.fill` |
| 03     | `square.stack.3d.up.fill`, `book.closed.fill`, `globe`, `star.fill`, `scale.3d`, `chevron.right` |
| 04     | `sparkles` (hero), `crown.fill`, `sparkles`, `globe`, `star.fill` |
| 05/08  | `play.fill`, `heart`, `checkmark`, `chart.bar.fill` |
| 06     | `brain.head.profile`, `square.stack.3d.up.fill`, `checkmark` |
| 07     | `book.closed.fill` (hero badge) |
| 09     | `flame.fill`, `chart.bar.fill`, `trophy.fill`, `bell.fill` |
| 10     | `moon.stars.fill`, `moon.fill`, `sparkles`, `book.closed.fill`, `heart`, `checkmark`, `calendar`, `drop.fill`, `mountain.2.fill`, `star.fill` |
| 11     | `book.closed.fill`, `person.fill.badge.plus`, `person.fill`, `heart.fill` |

Use existing fonts only (system + system serif for Arabic). No font imports needed.

## Files

| Path | Purpose |
|------|---------|
| `design-files/Onboarding.html` | Open in a browser to see all 3 explored variants. Variant C is the one to implement. |
| `design-files/variant-c.jsx` | React source for every Variant C screen — read for exact pixel measurements, padding, gradients, icon paths. |
| `design-files/onboarding.jsx` | Variant A source (Parchment) — reference only, not for shipping. Contains the `PhoneFrame` helper. |
| `design-files/variant-b.jsx` | Variant B source (Lantern, dark) — reference only. |
| `design-files/app.jsx` | Composes all three variants into the design canvas. |
| `design-files/design-canvas.jsx` | Canvas/artboard scaffold used by the prototype HTML. |
| `screenshots/01-welcome.png` … `11-final-account.png` | Final visual of each Variant C screen — your pixel reference. |

Source SwiftUI files (in the existing codebase) to modify:
- `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift` (coordinator — minor tweak only)
- `Thaqalayn/Views/Onboarding/HadithScreen.swift` (drop GeometricPatternBackground + auto-advance)
- `Thaqalayn/Views/Onboarding/MissionScreen.swift` (rebuild feature rows with chip styling)
- `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift` (rebuild row styling)
- `Thaqalayn/Views/Onboarding/QuickGemsScreen.swift` (rebuild verse card + gem tags)
- `Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift` (rebuild progress card)
- `Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift` (rebuild quiz + add result state)
- `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift` (rebuild Ramadan + future cards)
- `Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift` (rebuild feature rows)
- `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift` (light tweaks — verse card style)
- `Thaqalayn/Views/Onboarding/FinalScreen.swift` (rebuild CTA stack + benefits card)
