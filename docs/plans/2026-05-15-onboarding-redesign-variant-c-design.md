> **SUPERSEDED (2026-05-15)** by
> `docs/superpowers/specs/2026-05-15-onboarding-aesthetic-reskin-design.md`
> and `docs/superpowers/plans/2026-05-15-onboarding-aesthetic-reskin.md`.
> This document described a full rebuild (11 screens, dropped animations,
> restructured flow); the shipped work is an aesthetics-only reskin that
> preserves the 10-screen flow, all copy/content, and every animation.

# Onboarding Redesign — Variant C ("Native") Design

**Date:** 2026-05-15
**Scope:** Rebuild the 10-screen onboarding flow in SwiftUI to match the hi-fi Variant C handoff in `design_handoff_onboarding_variant_c/`.
**Source of truth for visuals:** `design_handoff_onboarding_variant_c/README.md` + `screenshots/01-welcome.png … 11-final-account.png`.

## Decisions resolved up-front

| Decision | Choice | Rationale |
|---|---|---|
| Screen count | **11 screens**, add `QuizResultScreen.swift`, drop `DailyVerseScreen` from the flow (file left on disk, marked deprecated) | Matches spec; Quiz Result gets its own moment instead of being a 1.2s flash |
| Peach accent | **Use existing `accentGradient` for primary CTAs + add a new `chipBrand` token** for the peach hex values | Avoids repainting the project-wide `accentColor` (currently purple `#9B8FBF`); keeps onboarding visual change contained |
| Dark mode | **Light-mode-first, dark works** — tilts + halos skipped in dark; chip palette + white cards reused as-is over `darkScreenAura()` | Honors spec ("only in light mode") while keeping dark theme shippable |
| Auto-advance | **Drop** the 5-second auto-advance and tap-anywhere-to-advance on HadithScreen | Per spec |
| Implementation style | **Approach A — shared components + per-screen rebuild** | Spec is repetitive in primitives; extracting them keeps screens consistent and short |

## Architecture

### Three additions to `ThemeManager.swift`

A new `// MARK: - Onboarding (Variant C)` block holding **static** (theme-agnostic) tokens.

```swift
struct ChipColor { let bg: Color; let fg: Color }

static let chipBrand      = ChipColor(bg: hex(0xFCE0CC), fg: hex(0xC66829)) // peach
static let chipKnowledge  = ChipColor(bg: hex(0xEAD8F0), fg: hex(0x8C539F)) // plum
static let chipProgress   = ChipColor(bg: hex(0xD6EADF), fg: hex(0x3B8459)) // mint
static let chipFoundation = ChipColor(bg: hex(0xD8E8F4), fg: hex(0x3D78B2)) // sky
static let chipFeatured   = ChipColor(bg: hex(0xF8EAC9), fg: hex(0xB5862A)) // butter
static let chipComparative= ChipColor(bg: hex(0xE6DDE9), fg: hex(0x7B6688)) // mauve
static let chipWarmth     = ChipColor(bg: hex(0xF4D8D8), fg: hex(0xC25656)) // rose

enum TiltStyle { case peach, lavender, mauve, sage }

func tiltGradient(_ style: TiltStyle) -> LinearGradient? // returns nil in dark mode
```

Names use **intent** (chipBrand, chipKnowledge, chipFoundation, …) per the README's preference. A short comment above the block maps intent → screen usage so future readers know why "Foundation" is sky.

### New module: `Views/Onboarding/Components/`

| File | Purpose |
|---|---|
| `HeroChip.swift` | 88×88 chip + amber halo + breathing pulse (`scaleEffect` 1.0↔1.05, 2.5s `repeatForever`). Inputs: `symbol`, `palette: ChipColor`, optional `iconOverride: Color`. |
| `OnboardingBackground.swift` | Tilt gradient + amber radial glow + `primaryBackground` fallback. In dark mode returns only `primaryBackground` so `darkScreenAura()` owns the mood. Inputs: `tilt: TiltStyle`. |
| `OnboardingTitleBlock.swift` | Optional eyebrow + hero title + body sub. Bakes in spec typography (`.system(size: 30, weight: .heavy)`, tracking `-0.6`, line height `1.1`, max-width 300). |
| `FeatureRow.swift` | White 18-radius card with pastel chip on the left + bold title + secondary sub. Inputs: `chip: ChipColor`, `symbol`, `title`, `sub`. Replaces the existing peach-gradient `HighlightRow`. |
| `OnboardingCTA.swift` | Three variants: `.primary` (`accentGradient` bg, inset top highlight, drop shadow `rgba(198,104,41,0.35) radius 14 y10`), `.secondary` (white + hairline border), `.ghost` (centered text). 0.96× press-state baked in. |
| `GemPill.swift` | Wrap-able tag pill — pastel chip background, SF Symbol + 11.5/bold label, 999-radius. Used by screen 04. |
| `QuizAnswerRow.swift` | Default / selected-correct row states; 250ms ease bg + border transition. |

### Coordinator changes — `OnboardingFlowView.swift`

```swift
private let totalPages = 11
@State private var progressNotificationsEnabled = false  // notificationsEnabled removed

TabView(selection: $currentPage) {
    HadithScreen(currentPage: $currentPage).tag(0)
    MissionScreen().tag(1)
    FiveLayersScreen().tag(2)
    QuickGemsScreen().tag(3)
    ProgressTrackingScreen().tag(4)           // mode .progress default
    QuizFeatureScreen(currentPage: $currentPage).tag(5)
    QuizResultScreen().tag(6)                 // NEW
    BismillahScreen().tag(7)                  // NEW thin wrapper: ProgressTrackingScreen(mode: .bismillah)
    ProgressNotificationsScreen(progressNotificationsEnabled: $progressNotificationsEnabled).tag(8)
    SeasonalFeaturesScreen().tag(9)
    FinalScreen(onComplete: { completeOnboarding() }).tag(10)
}
```

`completeOnboarding()` simplifies: drop the `notificationsEnabled` branch. `NotificationManager.shared.requestPermission()` runs only if `progressNotificationsEnabled`. `darkScreenAura()` modifier stays at the root. System page indicator (`.tabViewStyle(.page(indexDisplayMode: .always))`) is retained — handles 11 dots correctly. Final screen suppresses the indicator with a bottom-anchored opaque tilt-peach rectangle.

## Per-screen plan

Every screen follows the same skeleton:

```
ZStack {
    OnboardingBackground(tilt: <peach/lavender/mauve/sage>)
    VStack(spacing: 28) {
        HeroChip(symbol: ..., palette: ...)        // or none on 01 & 11
        OnboardingTitleBlock(eyebrow:, title:, sub:)
        <screen-specific content cards>
        Spacer()
        OnboardingCTA / <none>                     // page indicator handled by TabView
    }
    .padding(.horizontal, 22)
}
.onAppear { isVisible = true }
```

| # | File | Tilt | Hero (chip · symbol) | Body specifics |
|---|---|---|---|---|
| 01 | `HadithScreen.swift` | peach | none — Arabic `ثقلين` logotype 96pt heavy + amber radial behind | Drop `GeometricPatternBackground`, drop shimmer, drop `glowPulse`, drop 5s auto-advance, drop `onTapGesture`. Eyebrow "THE TWO WEIGHTY THINGS" (chipBrand.fg). Hadith card (white 24-radius, 22-padding): peach mini chip + "HADITH OF THAQALAYN" header, two-line Arabic hadith centered, hair divider, English translation, attribution. Primary CTA "Begin the journey →". |
| 02 | `MissionScreen.swift` | lavender | chipBrand · `book.closed.fill` | Title "Wisdom at your fingertips". 4 `FeatureRow`s: chipBrand `book.closed.fill` "Complete Quranic text" · chipKnowledge `sparkles` "5 layers of commentary" · chipFeatured `bell.fill` "Daily verses" · chipWarmth `heart.fill` "Sync bookmarks". Remove the giant Arabic at top (moved to 01). Keep existing fade-in + stagger. |
| 03 | `FiveLayersScreen.swift` | mauve | chipKnowledge · `square.stack.3d.up.fill` | Title "5 Layers of Wisdom" + caption "Tap each layer to explore". 5 `FeatureRow`s with right-side `chevron.right` (14pt tertiary): Foundation/sky, Classical Shia/plum, Contemporary/mint, Ahlul Bayt/peach, Comparative/mauve. |
| 04 | `QuickGemsScreen.swift` | lavender | chipFeatured · `sparkles` (filled) | Title "Gems" + sub "Precious insights unveiled". Verse card (white 22-radius, 20-padding): 36×36 plum→sky gradient round badge w/ white "255", "Al-Baqarah 255" 16/heavy, Arabic fragment (22pt serif, RTL, right-aligned), 4 `GemPill`s. Insight card below: plum chip + "THE THRONE VERSE" eyebrow + 13pt body. |
| 05 | `ProgressTrackingScreen.swift` | lavender | chipFoundation · `chart.bar.fill` | Add `enum Mode { case progress, bismillah }`, default `.progress`. Title "Track Your Progress" + sub. Surah progress card: "Al-Baqarah · The Cow" 14/bold + tertiary "last read 4 minutes ago" + **53%** in `chipProgress.fg` 18/heavy + 8pt mint gradient bar. |
| 06 | `QuizFeatureScreen.swift` | mauve | chipKnowledge · `brain.head.profile` | Title "Test Your Knowledge" + sub. Quiz card: centered sky-chip "FOUNDATION" pill, question "What does 'Kursi' represent in Ayat al-Kursi?", 4 `QuizAnswerRow`s. Tap reveals correctness (250ms), waits 1.2s, advances `currentPage` to 6. `@State quizSelected: Int?` local. Caption "Deepen your understanding through reflection" above page indicator. |
| 07 | `QuizResultScreen.swift` *(NEW)* | mauve | chipKnowledge · `brain.head.profile` | Same hero/title/sub as 06. Result card (white 24-radius, 1.5px plum border, plum shadow): 72×72 plum chip with `book.closed.fill` + halo, "Scholar Level" 24/heavy, Arabic "عالم" 24pt plum, score "9" 80pt heavy with vertical plum-gradient mask (`.foregroundStyle(LinearGradient)`) + "/10" 28pt tertiary, "Excellent understanding!" 14pt secondary, 3-stat strip (12 Quizzes · 87% Avg score · 5 Surahs) in plum. |
| 08 | `BismillahScreen.swift` *(NEW wrapper)* | sage | chipProgress · `checkmark` | One-line file: `ProgressTrackingScreen(mode: .bismillah)`. In `.bismillah` mode, the screen shows: title "Track Your Progress" + sub, Bismillah verse card (32×32 plum→sky gradient verse-number badge w/ white "1", 3-icon control strip [play / heart-outline / mint check], centered Arabic `بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ` 26pt serif, 13.5pt secondary translation), then the same Surah progress card from screen 05. |
| 09 | `ProgressNotificationsScreen.swift` | peach | chipBrand · `flame.fill` | Title "Stay Motivated" + sub. 3 `FeatureRow`s (48×48 chips, 22pt icons): sky `chart.bar.fill` "Track Your Progress" · peach `flame.fill` "Build Streaks" · butter `trophy.fill` "Earn Badges". Primary CTA `bell.fill` "Enable Progress Reminders" → toggles `progressNotificationsEnabled`. Caption 12pt tertiary "You can always enable this later in Settings". |
| 10 | `SeasonalFeaturesScreen.swift` | mauve | chipKnowledge bg + chipBrand.fg icon · `moon.stars.fill` | Title "Special Seasons" + sub. Ramadan card (white 20-radius): 44×44 peach chip w/ `moon.fill` + "Ramadan Journey" 17/heavy + magenta "Seasonal" gradient pill (`#C764D5 → #9A48A8` inline). 4 mini-rows (22×22 butter chips + 13pt secondary): sparkles · book.closed · heart · checkmark. More Coming Soon card: sky chip w/ `calendar` + "More Coming Soon" + blue "Future" gradient pill (`#5BA6F0 → #3D78B2` inline). 4 sky tag pills (Muharram drop, Dhul-Hijjah mountain, Rajab sparkles, Holy nights star). |
| 11 | `FinalScreen.swift` | peach | none — small `ثقلين` 44pt chipBrand.fg with shadow | Hero title "Begin Your Journey" 34/heavy tracking -0.8 + sub. CTA stack (gap 10): primary `book.closed.fill` "Continue as Guest" · secondary `person.fill.badge.plus` "Create Account" · secondary `person.fill` "Sign In". All 3 call `onComplete`. Benefits card below (white 18-radius): mint chip + `heart.fill` + "Account Benefits" + 12.5pt body. Legal at bottom: "By continuing you agree to our **Terms** and **Privacy**." 11pt tertiary, underlined `secondaryText`. Page indicator suppressed via bottom-anchored opaque tilt-peach rectangle. |

### Files removed from the flow

- `DailyVerseScreen.swift` — removed from `OnboardingFlowView` TabView. File left on disk with a `// MARK: - DEPRECATED — not in onboarding flow as of Variant C redesign (2026-05-15)` header. Deletion is a separate cleanup.

## Animation strategy

### Entrance stagger (every screen, identical cadence)

| Element | Animation | Delay |
|---|---|---|
| Hero | `.easeOut(0.6)` opacity + offset `+20pt → 0` | `0.2s` |
| Title | `.easeOut(0.6)` opacity + offset `+20pt → 0` | `0.4s` |
| Sub | `.easeOut(0.6)` opacity + offset `+20pt → 0` | `0.55s` |
| Cards | `.easeOut(0.7)` opacity + offset `+30pt → 0` | `0.7s` |
| CTA | `.easeOut(0.6)` opacity + offset `+30pt → 0` | `0.9s` |

Wrapped behind `@State var isVisible = false` flipped to `true` in `.onAppear`.

### Halo pulse — encapsulated in `HeroChip`

```swift
.scaleEffect(pulse ? 1.05 : 1.0)
.animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulse)
```

Triggered 1.0s after appear so it doesn't compete with entrance.

### CTA press state — built into `OnboardingCTA`

```swift
.scaleEffect(isPressed ? 0.96 : 1.0)
.animation(.easeOut(duration: 0.1), value: isPressed)
```

### Quiz transition (06 → 07)

1. Answer tap sets `quizSelected = index`.
2. `QuizAnswerRow` animates correctness bg/border (250ms ease).
3. After 1.2s: `withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { currentPage = 6 }` advances the TabView; system page-transition handles the slide/fade.

### Hadith shimmer

Dropped. The existing shimmer was on the English title "Hadith of Thaqalayn", which doesn't exist in the new layout. The Arabic logotype gets the amber radial behind it but no shimmer.

## State management summary

| State | Owner | Used by |
|---|---|---|
| `currentPage: Int` | `OnboardingFlowView` | All screens |
| `progressNotificationsEnabled: Bool` | `OnboardingFlowView` | `ProgressNotificationsScreen` (09) |
| `quizSelected: Int?` | `QuizFeatureScreen` local | Answer correctness reveal |
| `isVisible: Bool` | Each screen local | Entrance gate |
| `pulse: Bool` | `HeroChip` local | Halo breathing |

No new app-level state. Quiz state resets if the user pages back to screen 06.

## Light vs. dark behavior

- **Light:** Tilt gradient + amber radial glow + halo breathing all visible. White cards + pastel chips read crisply over the warm gradient.
- **Dark:** `OnboardingBackground` returns only `themeManager.primaryBackground` (skips tilt + radial). `darkScreenAura()` adds peach atmosphere at the root. Pastel chips + white cards float over the dark aura — they read fine; the chip palette is the through-line that keeps the Variant C feel intact in dark.

## Risk areas

1. **Magenta `#C764D5 → #9A48A8` and blue `#5BA6F0 → #3D78B2` gradient pills on screen 10** are one-off values; inline as `LinearGradient` literals, no new tokens.
2. **80pt score numeral with gradient mask** (screen 07) uses iOS 15+ `.foregroundStyle(LinearGradient(...))` — no `.mask()` hack needed.
3. **Right-aligned RTL Arabic on screen 04** is new for this codebase (existing `HadithScreen` centers Arabic). Pattern: `.environment(\.layoutDirection, .rightToLeft)` + `.multilineTextAlignment(.trailing)`.
4. **Page indicator on Final** — suppress via bottom-anchored opaque rectangle in `FinalScreen` rather than tweaking the global `.indexViewStyle`.
5. **Bismillah-as-thin-wrapper** — verify `ProgressTrackingScreen(mode: .bismillah)` doesn't have side-effects from being instantiated twice in the TabView (once at tag 4, once via wrapper at tag 7). Both are independent `@StateObject` containers; should be fine.

## Acceptance criteria

- All 11 screens render in light mode visually matching the screenshots (typography weights, sizes, spacing, chip colors per spec).
- Dark mode renders all 11 screens without broken layouts or unreadable text.
- No new build warnings; `ThemeManager` callers elsewhere in the app are unaffected by the additions.
- Animations don't stutter on a cold-start simulator launch.
- `DailyVerseScreen.swift` left on disk, marked deprecated, no longer reachable from `OnboardingFlowView`.
- `completeOnboarding()` no longer references `notificationsEnabled`; `progressNotificationsEnabled` path is unchanged.

## Files touched

**Modified:**
- `Thaqalayn/Services/ThemeManager.swift` (add chip palette + tilt gradient block)
- `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift` (11 screens, drop DailyVerse, drop notificationsEnabled state)
- `Thaqalayn/Views/Onboarding/HadithScreen.swift` (rebuild — drop pattern bg, auto-advance, tap-advance, shimmer)
- `Thaqalayn/Views/Onboarding/MissionScreen.swift` (rebuild — replace HighlightRow with FeatureRow)
- `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift` (rebuild rows)
- `Thaqalayn/Views/Onboarding/QuickGemsScreen.swift` (rebuild verse + insight cards)
- `Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift` (rebuild + add `Mode` enum for .progress / .bismillah)
- `Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift` (rebuild question state + transition logic)
- `Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift` (rebuild rows + CTA)
- `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift` (rebuild Ramadan + Future cards)
- `Thaqalayn/Views/Onboarding/FinalScreen.swift` (rebuild CTA stack + benefits + legal)
- `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift` (add DEPRECATED comment header — file otherwise untouched)

**New:**
- `Thaqalayn/Views/Onboarding/QuizResultScreen.swift`
- `Thaqalayn/Views/Onboarding/BismillahScreen.swift`
- `Thaqalayn/Views/Onboarding/Components/HeroChip.swift`
- `Thaqalayn/Views/Onboarding/Components/OnboardingBackground.swift`
- `Thaqalayn/Views/Onboarding/Components/OnboardingTitleBlock.swift`
- `Thaqalayn/Views/Onboarding/Components/FeatureRow.swift`
- `Thaqalayn/Views/Onboarding/Components/OnboardingCTA.swift`
- `Thaqalayn/Views/Onboarding/Components/GemPill.swift`
- `Thaqalayn/Views/Onboarding/Components/QuizAnswerRow.swift`

Xcode 16 synced folder groups — no `.pbxproj` edits needed; new files added to `Views/Onboarding/` and `Views/Onboarding/Components/` are picked up automatically.
