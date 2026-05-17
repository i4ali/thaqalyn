# Onboarding Aesthetic Reskin — "Variant C look, current behavior" Design

**Date:** 2026-05-15
**Author:** brainstormed with the user
**Status:** Active

## One-line summary

Apply the **visual aesthetic** of the Variant C ("Native") onboarding handoff to the
existing 10-screen SwiftUI onboarding flow — warm tilt-gradient backgrounds, amber
glow, glowing pastel hero chips, white rounded cards, refined typography — **without
changing the flow, the copy, the content, or a single animation/behavior line.**

## Why this spec exists (and supersedes the old one)

There is an older pair of documents:

- `docs/plans/2026-05-15-onboarding-redesign-variant-c-design.md`
- `docs/plans/2026-05-15-onboarding-redesign-variant-c-plan.md`

Those describe a **full rebuild**: 10 → 11 screens, `DailyVerseScreen` deprecated,
new `QuizResultScreen`/`BismillahScreen`, dropped shimmer/glow-pulse/auto-advance,
and a restructured flow. The user explicitly scoped this work **narrower**: *"only
the aesthetics from this design. there are animations we have currently that I like
to keep as is. just try and capture the colors/aesthetics so our onboarding looks
more lively."*

This spec is the source of truth. The two older docs will get a `> **SUPERSEDED by
docs/superpowers/specs/2026-05-15-onboarding-aesthetic-reskin-design.md**` header note
(they are the user's files and are not deleted).

## Decisions resolved up-front

| Decision | Choice | Rationale |
|---|---|---|
| Reskin depth | **Full visual reskin** of all 10 screens (tilt gradients, amber glow, pastel chips, white cards, halo hero chips, type scale) | User-selected; a token-only recolor would not read like the screenshots |
| Copy & content | **Keep current copy/content**, restyle only — no new copy, no illustrative example cards, no new CTA buttons | User-selected; keeps it "aesthetics only" |
| Flow structure | **Unchanged** — 10 screens, same order, same `.tag()`s, same bindings; `DailyVerseScreen` stays in the flow | Old doc's restructure rejected |
| Animations & behavior | **Preserved verbatim** — every entrance/shimmer/glowPulse/pulse/twinkle/`asyncAfter`/auto-advance/tap line is kept | User: "animations we have currently I like to keep as is" |
| Screen 1 auto-advance + tap | **Kept both as-is** | User-selected |
| Dark mode | **No dark-mode branching.** Onboarding only renders on first launch under the default `.warmInviting` (light) theme — verified in `ContentView.swift:69` + `ThemeManager.swift:51`. Fixed warm/light values throughout. | Verified; removes the old doc's "skip tilt in dark" complexity |
| App-wide accent | **No repaint.** `accentColor` stays purple (`#9B8FBF`) everywhere; only the existing `accentGradient` is reused for FinalScreen CTAs | Keeps the change contained to onboarding |
| Implementation style | **Approach A** — small shared visual kit + surgical per-screen restyle | User-selected; consistent, low-risk, animations provably untouched |
| Screen 3 (FiveLayers) hero | **Add** a new plum hero chip (`square.stack.3d.up.fill`) | Screen has no hero today; a badge keeps it visually consistent with the other 9. Visual element, not new copy |
| Screen 6 quiz emoji | **Swap** `🏛️` → SF Symbol `square.stack.3d.up.fill` inside a sky pastel pill; keep the word "Foundation" | Matches the pastel-pill look + the project's "replace emoji-as-icons" direction (commit dac831b) |
| Screen 10 (Final) hero | **No hero chip** (matches handoff screen 11) | Confirmed |

## Architecture — Approach A: shared visual kit

The current screens already share Variant C's skeleton (hero icon → title →
subtitle → cards, with staggered entrance animations). The reskin swaps cosmetic
attributes only. Five small, reusable additions encode "the look"; each screen is
then edited mechanically against them.

### 1. `ThemeManager.swift` — new `// MARK: - Onboarding Variant C` block

Static, theme-agnostic (onboarding is always light):

```swift
struct ChipColor { let bg: Color; let fg: Color }

static let chipBrand       = ChipColor(bg: Color(hex: "FCE0CC"), fg: Color(hex: "C66829")) // peach
static let chipKnowledge   = ChipColor(bg: Color(hex: "EAD8F0"), fg: Color(hex: "8C539F")) // plum
static let chipProgress    = ChipColor(bg: Color(hex: "D6EADF"), fg: Color(hex: "3B8459")) // mint
static let chipFoundation  = ChipColor(bg: Color(hex: "D8E8F4"), fg: Color(hex: "3D78B2")) // sky
static let chipFeatured    = ChipColor(bg: Color(hex: "F8EAC9"), fg: Color(hex: "B5862A")) // butter
static let chipComparative = ChipColor(bg: Color(hex: "E6DDE9"), fg: Color(hex: "7B6688")) // mauve
static let chipWarmth      = ChipColor(bg: Color(hex: "F4D8D8"), fg: Color(hex: "C25656")) // rose

enum OnboardingTilt { case peach, lavender, mauve, sage }
```

The codebase already provides a **non-optional** `Color(hex: String)`
(`Thaqalayn/Utilities/WarmThemeModifiers.swift:188` — invalid input falls back
internally, so no `??` needed; see `ProgressRingView.swift:63`). **Reuse it; do not
add a second hex utility.** Tilt gradient stops below use the same `Color(hex:)` API.

Tilt gradient stops (3-stop vertical `LinearGradient`, top → mid → bottom):

| Tilt | Top | Mid | Bottom |
|---|---|---|---|
| peach | `#F5E6E6` | `#F8E5D2` | `#FAF2E8` |
| lavender | `#F1E9F4` | `#F5E8E5` | `#FAF2E8` |
| mauve | `#ECE3F2` | `#F2E6E8` | `#FAF2E8` |
| sage | `#E6EEEB` | `#F0EBE2` | `#FAF2E8` |

### 2. `Views/Onboarding/Components/OnboardingBackground.swift`

`OnboardingBackground(tilt:)` — a `ZStack`: the 3-stop tilt `LinearGradient`
(ignores safe area) + a soft amber radial glow on top: `RadialGradient` of
`Color(red: 232/255, green: 148/255, blue: 100/255).opacity(0.18)` → `.clear` at
~60%, frame ≈ 500×400, `.blur(radius: 8)`, anchored near the top of the viewport.
Replaces each screen's current background (incl. `GeometricPatternBackground` on
screen 1 and `themeManager.primaryBackground` elsewhere).

### 3. `Views/Onboarding/Components/HeroChip.swift`

`HeroChip(symbol: String, palette: ChipColor, iconColorOverride: Color? = nil, isVisible: Bool)`:

- 88×88 `RoundedRectangle(cornerRadius: 28)` filled `palette.bg`, icon `symbol`
  ~38pt in `iconColorOverride ?? palette.fg`.
- Breathing halo **behind**: radial `palette.fg.opacity(0.34)` → clear, `.blur(10)`,
  `.scaleEffect(pulse ? 1.05 : 1.0)` with
  `.easeInOut(duration: 2.5).repeatForever(autoreverses: true)`, `pulse` flipped
  ~1.0s after appear (local `@State`, mirrors the existing `glowPulse`/`pulse`
  pattern already in the screens).
- **Reuses the host screen's entrance animation**: the component applies the
  screen's existing `isVisible`-driven opacity/scale/offset by accepting `isVisible`
  — it does not introduce a new entrance timing. It is a styled wrapper around the
  hero icon the screen already animates.

### 4. `Views/Onboarding/Components/OnboardingCard.swift`

- `.onboardingCard()` modifier — white fill, `RoundedRectangle(cornerRadius: 22)`,
  shadow `Color(red: 60/255, green: 40/255, blue: 20/255).opacity(0.06)` radius 12
  x 0 y 8. Padding 20.
- `.onboardingRow()` modifier — white fill, radius 18, shadow `…opacity(0.04)`
  radius 6 x 0 y 2. Padding 14. Used for feature-row lists.

### 5. `Views/Onboarding/Components/OnboardingTypography.swift`

System-font scale as `Font`/`Text` helpers (no font import):

| Role | Font | Tracking | Notes |
|---|---|---|---|
| Hero title | `.system(size: 30, weight: .heavy)` | `-0.6` | line height ~1.1 |
| Final title | `.system(size: 34, weight: .heavy)` | `-0.8` | screen 10 only |
| Eyebrow | `.system(size: 11.5, weight: .bold)` | `3.4` | uppercase |
| Card title | `.system(size: 16, weight: .heavy)` | `-0.3` | |
| Row title | `.system(size: 15, weight: .bold)` | `-0.2` | |
| Body | `.system(size: 14.5, weight: .medium)` | — | line height ~1.45 |
| Caption | `.system(size: 12, weight: .medium)` | — | |
| Pill | `.system(size: 11.5, weight: .bold)` | `0.3` | chip/tag labels |

**Arabic text keeps its current per-screen sizing and the system-serif design it
already uses** (Arabic strings are existing content; do not resize them).

### CTA styling (FinalScreen only — it is the only screen with buttons)

- **Primary:** `themeManager.accentGradient` fill, white label, ~17pt vertical
  padding, radius 18, inset top white highlight (`white.opacity(0.3)`, y 1), drop
  shadow `Color(red:198/255,green:104/255,blue:41/255).opacity(0.35)` radius 14 y 10.
- **Secondary:** white fill, 1px hairline border `Color(red:31/255,green:22/255,
  blue:18/255).opacity(0.07)`, ink text, same size/radius.
- `.scaleEffect(isPressed ? 0.96 : 1.0)` 100ms — only if the buttons already have a
  press state; otherwise leave press behavior exactly as today.

## Per-screen reskin mapping

Flow order, `.tag()`s, and bindings are **unchanged**. "Animations kept" = those
exact lines remain byte-for-byte except for color/shape/type attribute values.

| # | Screen file | Tilt | Hero | Content → restyled | Animations preserved verbatim |
|---|---|---|---|---|---|
| 1 | `HadithScreen.swift` | peach | none — keep "Hadith of Thaqalayn" title-with-glow | `GeometricPatternBackground` → `OnboardingBackground`; hadith + divider + translation + attribution → one `.onboardingCard()`; divider recolored | shimmer (`shimmerOffset`), `glowPulse`, all `isVisible` delays (0.3→1.7), **5s auto-advance**, `onTapGesture` advance |
| 2 | `MissionScreen.swift` | lavender | keep `ثقلين` logotype; 3 glow circles → amber halo treatment | 4 `HighlightRow` → pastel-chip rows: brand `book.closed.fill`, knowledge `sparkles`, featured `bell.fill`, warmth `heart.fill` (one chip color each, replaces accent-gradient chip) | shimmer, spring entrance, stagger (0.8→2.0) |
| 3 | `FiveLayersScreen.swift` | mauve | **NEW** `HeroChip` plum `square.stack.3d.up.fill` | 5 `LayerCard` → pastel `.onboardingRow()`: foundation/knowledge/progress/brand/comparative; keep `chevron.right` | stagger (0.2 → 0.6 + index·0.1) |
| 4 | `QuickGemsScreen.swift` | lavender | recolor hero → `HeroChip` featured(butter) `sparkles` | verse card + `DemoInsightCard` → `.onboardingCard()`; concept bubbles → pastel pills (Pill type) | hero pulse (2.0s repeatForever), spring entrance (0.2), stagger |
| 5 | `ProgressTrackingScreen.swift` | sage | recolor hero → `HeroChip` progress(mint) `checkmark.circle.fill` | `DemoVerseCard` + progress card → `.onboardingCard()`; progress bar gradient → mint | hero pulse, spring entrance, stagger, `asyncAfter` reveal sequence, checkbox pulse |
| 6 | `QuizFeatureScreen.swift` | mauve | recolor hero → `HeroChip` knowledge(plum) `brain.head.profile` | `DemoQuestionCard`/result card → `.onboardingCard()`; "Foundation" tag → sky pastel pill, `🏛️` → `square.stack.3d.up.fill` | hero pulse, spring entrance, stagger, full quiz `asyncAfter` demo sequence |
| 7 | `SeasonalFeaturesScreen.swift` | lavender | recolor hero → `HeroChip` knowledge(plum) bg + `chipBrand.fg` icon, `moon.stars.fill`; keep twinkling star | `SeasonalFeatureExpandedCard`s → `.onboardingCard()`; inner gradients recolored to pastel | hero pulse (2.5s), star twinkle, spring entrance, stagger |
| 8 | `DailyVerseScreen.swift` | peach | recolor hero → `HeroChip` brand `bell.fill` | "Verse of the Day" + "Islamic Calendar" cards → `.onboardingCard()`; enable-notifications button → primary CTA style | spring entrance (0.2), stagger; `@Binding notificationsEnabled` wiring unchanged |
| 9 | `ProgressNotificationsScreen.swift` | sage | recolor hero → `HeroChip` brand (keep current icon) | 3 `ProgressFeatureCard` → pastel `.onboardingRow()`; enable button → primary CTA style | spring entrance, stagger; `@Binding progressNotificationsEnabled` wiring unchanged |
| 10 | `FinalScreen.swift` | peach | none (matches handoff screen 11) | title → Final-title type; 3 buttons → CTA styling (Continue as Guest = primary gradient; Create Account + Sign In = secondary white/hairline); benefits → `.onboardingCard()` with mint chip + `heart.fill` | stagger (0.2→0.5); all 3 buttons still call `onComplete()` |

### Per-screen edit recipe (mechanical, applied identically)

For each screen file:

1. Wrap/replace the root background with `OnboardingBackground(tilt: <assigned>)`.
2. If it has a hero icon: wrap it in `HeroChip(...)`, passing the screen's existing
   `isVisible`. (Screen 1 & 10: no hero. Screen 2: keep `ثقلين`, restyle its glow.)
3. Replace title/subtitle fonts with the typography helpers; keep the exact strings.
4. Wrap each content block in `.onboardingCard()` / `.onboardingRow()`.
5. Recolor every accent-gradient chip / icon background to the assigned `ChipColor`.
6. **Do not touch** any `@State`, `@Binding`, `.animation(...)`, `.delay(...)`,
   `.spring(...)`, `withAnimation`, `DispatchQueue.main.asyncAfter`, `onAppear`
   sequencing, `onTapGesture`, or navigation/`onComplete` line except to change a
   color/shape/font attribute *value*.

## Guardrails (what we are NOT doing)

- No screens added, removed, merged, or reordered. `DailyVerseScreen` stays.
- No new copy, eyebrows, illustrative example cards, or new CTA buttons.
- No timing/delay/state-machine/navigation edits — animation & behavior diff is zero.
- No dark-mode code paths; fixed warm/light values.
- No change to app-wide `accentColor`; `accentGradient` reused for Final CTAs only.
- `OnboardingFlowView.swift` unchanged (TabView, skip pill, system page indicator).
- Old `docs/plans/2026-05-15-onboarding-redesign-variant-c-*` get a SUPERSEDED note;
  not deleted.

## Files touched

**New** (`Views/Onboarding/Components/` — Xcode 16 synced folders, no `.pbxproj` edits):

- `OnboardingBackground.swift`
- `HeroChip.swift`
- `OnboardingCard.swift` (card + row modifiers)
- `OnboardingTypography.swift`

**Modified:**

- `Thaqalayn/Services/ThemeManager.swift` (add Variant C palette + tilt block only)
- `Thaqalayn/Views/Onboarding/HadithScreen.swift`
- `Thaqalayn/Views/Onboarding/MissionScreen.swift`
- `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift`
- `Thaqalayn/Views/Onboarding/QuickGemsScreen.swift`
- `Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift`
- `Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift`
- `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift`
- `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift`
- `Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift`
- `Thaqalayn/Views/Onboarding/FinalScreen.swift`
- `docs/plans/2026-05-15-onboarding-redesign-variant-c-design.md` (SUPERSEDED header)
- `docs/plans/2026-05-15-onboarding-redesign-variant-c-plan.md` (SUPERSEDED header)

**Unchanged:** `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift`

## Acceptance criteria

1. All 10 screens render in the warm Variant C aesthetic (assigned tilt + amber
   glow, halo hero chips where mapped, white `.onboardingCard()`s, pastel chips,
   the type scale) and read as visually consistent with `design_handoff_onboarding_
   variant_c/screenshots/`.
2. Every existing animation/behavior fires identically: screen-1 shimmer +
   glowPulse + 5s auto-advance + tap-advance; screen-2 shimmer; hero pulses;
   screen-7 twinkle; all staggered entrance delays; screen-5/6 `asyncAfter`
   sequences; notification-enable bindings; Final `onComplete`. A `git diff`
   shows **no** changes to timing, delays, `@State`/`@Binding`, or navigation.
3. Flow is still 10 screens in the same order; `DailyVerseScreen` still reachable
   at its current tag.
4. No change to `accentColor`; no dark-mode code paths; project builds with no
   new warnings.
5. The two old `docs/plans/2026-05-15-onboarding-redesign-variant-c-*` files carry
   a SUPERSEDED header pointing here.

## Risk areas

1. **Screen 2 `ثقلين` halo** — converting the 3-circle glow to the amber halo
   while keeping the shimmer mask intact; verify the shimmer overlay still reads.
2. **`HeroChip` reusing `isVisible`** — confirm the wrapper applies the host
   screen's entrance modifiers and adds only the breathing halo, so entrance
   timing is unchanged on all 7 hero screens.
3. **Screen 5/6 `asyncAfter` demo sequences** — purely visual restyle inside the
   cards they reveal; do not alter the reveal timing or state flags.
4. **`Color(hex:)` already exists and is non-optional** (`WarmThemeModifiers.swift:
   188`) — use it directly (`Color(hex: "FCE0CC")`); do not add a second hex utility.
5. **Screen 1 layout** — it currently centers a tall hadith with no card. Wrapping
   it in `.onboardingCard()` must not clip the long Arabic + 5-line English; verify
   on a small device (SE) that auto-advance still fires before any scroll need.
