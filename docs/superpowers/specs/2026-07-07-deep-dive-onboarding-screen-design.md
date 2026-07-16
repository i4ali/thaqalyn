# Deep Dive Onboarding Screen - Design

Date: 2026-07-07
Status: Implemented; revised post-build (see Revision below)

## Revision (2026-07-07, post-implementation)

After seeing the first build, the concept was pivoted based on user feedback:

- **From single-theme "The Descent" to feature-level "cycling themes."** The original
  screen read as "here is the Yaqin dive" (يقين wordmark + Yaqin's Know/See/Live depths).
  It now explains the *feature* - dive deep into any single theme - and conveys breadth by
  cycling a hero through real catalog themes: Certainty (يَقِين), Patience (صَبْر),
  Gratitude (شُكْر), Reliance (تَوَكُّل), Sincerity (إِخْلَاص), each Arabic + English with a
  glow, swapping every 2.2s (always-on motion).
- **Copy is now feature-level:** eyebrow `Deep Dive`; title `Dive deep into a single
  theme`; body `A virtue, a word from the Qur'an, a question of the heart - explored layer
  by layer in an immersive descent.`; footer `Find Deep Dives in the Journey tab`.
- **No depth-count indicator.** The deepening-dots + "Multi-level" motif under the hero was
  removed (it read as confusing on-device). The hero is just the cycling theme + glow, and
  the screen makes no claim about how many depths a dive has.
- **Motion is more pronounced** (spring scale-in on the hero, larger entrance offsets, plus
  the continuous theme cycle) to fix "barely visible" animation.

`Thaqalayn/Views/Onboarding/DeepDiveScreen.swift` is the source of truth for specifics.
The sections below describe the original "The Descent" concept and are superseded by this
revision where they conflict.

## Summary

Add a new onboarding screen that showcases the **Deep Dive** immersive feature. The
screen is a swipe-through teaser that *performs* the feature rather than merely
describing it: the screen itself becomes a miniature "descent," previewing the free
Yaqin dive. It slots in as screen 3 of the onboarding flow, right after "5 Layers of
Wisdom," bumping the flow from 13 to 14 pages.

Visual reference (approved mockup, direction A): `mockups/deep-dive-onboarding.png`.

## Goal & rationale

- **Primary job: create awe & desire.** Deep Dive's whole value is its cinematic,
  immersive feel, so the onboarding screen should perform that feel, not explain it.
  Copy is evocative and minimal.
- **Why themed on Yaqin:** Yaqin is the free first dive every user can open
  (`PremiumManager.canAccessDeepDive` gates all others behind premium). Teasing Yaqin
  specifically means the screen previews exactly what the user will actually get, which
  both builds desire and sets accurate expectations.

## Placement in the onboarding flow

Insert after "5 Layers of Wisdom" (current tag 2). The narrative flows from "here is how
deep our commentary goes" into "here is the most immersive way to go deep." New order:

| Tag | Screen |
|-----|--------|
| 0 | Hadith |
| 1 | Mission |
| 2 | 5 Layers of Wisdom |
| **3** | **Deep Dive (NEW)** |
| 4 | Quick Gems (was 3) |
| 5 | Progress Tracking (was 4) |
| 6 | Quiz Feature (was 5) |
| 7 | Daily Challenge (was 6) |
| 8 | Daily Crossword (was 7) |
| 9 | Seasonal Features (was 8) |
| 10 | Daily Verse (was 9) |
| 11 | Progress Notifications (was 10) |
| 12 | Personalize (was 11) |
| 13 | Final (was 12) |

## Visual direction

Direction **A ("The Descent")**, warmed with the glowing wordmark from direction B. The
screen is a scale model of the real Deep Dive experience: a background that deepens
top-to-bottom, a vertical descent-line stepping through the three depths, rising gold
motes, and a softly glowing Arabic wordmark behind the descent-line. This is
deliberately distinct from the sibling onboarding screens' shared backdrop, because it
is a taste of Deep Dive's own signature look.

## Screen content & copy (English only)

Copy is final but tunable during implementation. Top-left aligned (matching the other
text-forward onboarding screens).

- **Eyebrow:** `A DEEP DIVE` (rendered uppercase via `.onbEyebrow()`)
- **Title (serif):** `Descend into a single truth`
- **Subtitle:** `An immersive descent through three depths`
- **Descent-line - the three depths of Yaqin** (each rung dimmer as it goes deeper,
  reinforcing the descent). English label + authentic Arabic term:
  - `Know` - عِلْمُ الْيَقِين
  - `See` - عَيْنُ الْيَقِين
  - `Live` - حَقُّ الْيَقِين
  - These mirror the dive's real arc (ilm al-yaqin -> ayn al-yaqin -> haqq al-yaqin,
    "The Knowing -> The Witnessing -> The Living"). See `Content/YaqinDeepDive.swift`.
- **Footer caption (quiet, like the Seasonal screen's closing line):**
  `Find Deep Dives in the Journey tab`
  - Points to where the feature lives, without a pushy call-to-action button.

No em dashes anywhere in the copy (plain dashes only).

## Visual specification

Fixed dark palette regardless of the user's selected app theme (consistent with both the
onboarding flow and the Deep Dive feature, which each keep their own fixed dark look).

- **Background:** deepening vertical gradient painted top-to-bottom by sampling the real
  Deep Dive colour ramp `DeepDivePalette.bg()` at 0.0 / 0.32 / 0.55 / 0.82 (surface
  `#0F1712` down to near-black `#020403`). Note: `DeepDiveBackground(progress:)` renders a
  *flat* colour at a single fixed progress, so it is not reused directly; the screen
  reuses `DeepDivePalette` (colours + ramp) instead, which is the meaningful shared asset.
- **Rising motes:** the mote physics currently lives privately inside `DeepDiveBackground`.
  Extract it into a shared `DeepDiveMotes` view (used by both the real background and this
  screen) so the rising gold motes are single-sourced rather than duplicated.
- **Palette tokens** (from `Views/DeepDive/DeepDiveBackground.swift` `DeepDivePalette`):
  gold `#C9A55C`, goldBright `#E3C37E`, cream `#ECE7DB`, mute `#8F9A8C`, faint `#5C665D`.
- **Text colors:** `themeManager.primaryText` (`#F1E8D6`) for the title; secondary
  (primaryText @ 0.60) for subtitle and caption.
- **Glowing wordmark:** Arabic `يقين` in `EmType.arabic` (Amiri), large, positioned
  behind the descent-line toward the right, at low opacity with a soft radial gold halo
  that breathes (same cadence as `HeroChip`, approx 2.5s). Elevated from a faint
  watermark into a felt presence, but never competing with the title for legibility.
- **Descent-line:** a thin vertical gradient line (goldBright at top fading to faint at
  the bottom) with three circular nodes. Node styling by depth:
  - Know: goldBright fill with a bright glow ring.
  - See: gold fill with a medium glow.
  - Live: muted fill, no glow, dimmed label.
- **Typography:** title `.onbHeroTitle()` (`EmType.serif` 27); eyebrow `.onbEyebrow()`;
  subtitle `.onbBody()`; footer `.onbCaption()`; node English label system ~16 bold with
  wide tracking; node Arabic in `EmType.arabic` ~16-17.
- **Rising motes:** slow upward-drifting soft gold dots (provided by `DeepDiveBackground`
  reuse, or a lightweight local motes layer).
- **Chrome:** the flow's native page dots (index 3 active) and the shared Skip pill
  render over this screen automatically from `OnboardingFlowView`.

## Motion specification

Signature entrance that performs the descent. Driven by a single `@State isVisible`
toggled in `.onAppear`, following the established onboarding pattern (staggered
`.opacity`/`.offset` + `.animation(...delay)`).

1. Background and motes fade in immediately; motes then drift upward continuously.
2. Eyebrow rises + fades in (delay ~0.2s).
3. Title rises + fades in (delay ~0.3s).
4. Subtitle fades in (delay ~0.45s).
5. Descent-line draws downward: `scaleY` 0 -> 1 anchored at the top, duration ~0.8s,
   delay ~0.6s.
6. The three nodes light up in sequence as the line reaches them: Know (delay ~0.9s),
   See (~1.1s), Live (~1.3s), each a soft fade + scale with its glow.
7. Wordmark halo begins its slow breathing loop (~1.0s).
8. Footer caption fades in (delay ~1.5s).

## Technical integration

- **New file:** `Thaqalayn/Views/Onboarding/DeepDiveScreen.swift`, a self-contained
  `View` following the existing screen recipe. A small private descent-node subview keeps
  the file focused.
- **Reuse:** `DeepDivePalette` colors (+ `.bg()` ramp) for the descent gradient, the
  extracted `DeepDiveMotes` view for the rising motes, `EmType.serif` / `EmType.arabic`,
  and the `.onbEyebrow()/.onbBody()/.onbCaption()` type helpers. Xcode 16 synced folder
  groups mean dropping the file into the folder is enough (no `.pbxproj` edits).
- **Wire into `Views/Onboarding/OnboardingFlowView.swift`:**
  - Change `private let totalPages = 13` to `14`.
  - Insert `DeepDiveScreen().tag(3)` immediately after `FiveLayersScreen().tag(2)`.
  - Renumber the subsequent tags 3 -> 4, 4 -> 5, ... 12 -> 13, and update the
    `// Screen N: ...` comments accordingly.
  - The Skip-button visibility math (`currentPage > 0 && currentPage < totalPages - 1`)
    adapts automatically.
- **No new state, models, persistence, or services.** The screen takes no props (it does
  not need `$currentPage`; it is a pure swipe-through page).

## Scope / non-goals

- **Swipe-through teaser only.** It does not launch a live dive during onboarding (awe
  was chosen over drive-to-try). No functional CTA button.
- **Does not scale with the reading text-size control.** This is onboarding chrome, not
  reading content (verses/translation/tafsir/narration), consistent with every other
  onboarding screen. See the CLAUDE.md list of what does vs does not scale.
- **English only**, matching the rest of the onboarding flow. The real Deep Dive feature
  remains fully trilingual; only this teaser is English.
- **No "What's New" entry.** The Deep Dive feature is already announced; this is an
  onboarding screen, not a new user-facing feature of its own.
- **No CloudKit / Supabase / premium-gating changes.** Purely presentational.

## References

Real feature (for visual and copy fidelity):

- `Thaqalayn/Views/DeepDive/DeepDiveView.swift` - the renderer (openPage wordmark, etc.)
- `Thaqalayn/Views/DeepDive/DeepDiveBackground.swift` - `DeepDivePalette`, the deepening
  ramp, and rising motes.
- `Thaqalayn/Content/YaqinDeepDive.swift` - Yaqin's three-depth arc (ActInfo).
- `Thaqalayn/Services/DeepDiveCatalog.swift` - the dive registry.
- `Thaqalayn/Services/PremiumManager.swift` - `canAccessDeepDive` (Yaqin free).

Onboarding system (for style and wiring):

- `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift` - the coordinator to wire into.
- `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift` - nearest sibling / recipe example.
- `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift` - footer-caption pattern.
- `Thaqalayn/Views/Onboarding/Components/OnboardingTypography.swift` - type helpers.

## Verification

Per project convention (no XCTest for iOS work): the gate is a green
`xcodebuild` build of the `Thaqalayn` scheme. The user performs simulator
install/launch/screenshot verification themselves. A removable `#if DEBUG` preview of
`DeepDiveScreen` supports visual checking.
