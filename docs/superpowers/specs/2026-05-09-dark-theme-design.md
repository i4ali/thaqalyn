# Dark Theme — Design Spec

**Date:** 2026-05-09
**Author:** Brainstorm session (Claude + user)
**Status:** Implemented 2026-05-09 — see `dark/verification/dark-pass.md` and `dark/verification/light-pass.md` for manual verification logs.
**Reference mocks:** `dark/Dark.html`, `dark/dark.jsx`

---

## Summary

Re-introduce a dark theme to Thaqalayn alongside the existing `warmInviting` light theme. The dark variant is "Verse-Hero": warm-black surfaces (`#120D0A`), peach accent (`#E89464`), glass surfaces with white-alpha borders, subtle radial glows and sparse stars, opacity-based ink levels.

This is a **restyle-only** project — current screen layouts and content stay intact in both modes. The mocks in `dark/dark.jsx` are authoritative for **visual tokens only** (colors, materials, glows, accents); they are **not** authoritative for layout. No new sections, banners, or content are added to existing screens.

The light theme (`warmInviting`) is **untouched**. Every accessor's `.warmInviting` branch must return today's exact value.

## Decisions (from brainstorming)

| # | Decision |
|---|---|
| 1 | **Theme model:** Manual toggle only — Light + Dark. Persisted to `UserDefaults`. OS Dark Mode setting is ignored. |
| 2 | **Scope:** Whole app — every screen must look right in dark. |
| 3 | **Tab bar:** Style the native SwiftUI `TabView`. No custom floating glass pill. |
| 4 | **Mock fidelity:** Restyle only — colors/materials/glow/stars/peach accent. Existing layouts stay. |
| 5 | **Light theme:** Untouched. Zero regressions. |

## Architecture

### `ThemeManager` evolution

Add a second case to `ThemeVariant`:

```swift
enum ThemeVariant: String, CaseIterable {
    case warmInviting = "warmInviting"     // light (unchanged)
    case nightSanctuary = "nightSanctuary" // dark (new) — UI label "Dark"
}
```

`UI labels`: "Light" and "Dark". `displayName` and `description` extended for the new case.

### Persistence

`selectedTheme` is loaded from `UserDefaults.standard` key `selectedTheme` on `init`, written back via `didSet`. The current init line that *removes* the key is replaced with a normal load. If the key is missing or invalid, default to `.warmInviting`. Defensive: keep the `removeObject(forKey: "isDarkMode")` line to drop any legacy key from before dark themes were removed.

### Forcing the SwiftUI `colorScheme`

```swift
var swiftUIColorScheme: ColorScheme {
    selectedTheme == .nightSanctuary ? .dark : .light
}
```

Applied at the app root in `ThaqalaynApp.swift`:
```swift
ContentView()
    .preferredColorScheme(themeManager.swiftUIColorScheme)
```

Sheets, alerts, system pickers inherit this. The OS Dark Mode setting is ignored.

### `isDarkMode` reactivated

Replace the hardcoded `false` with `selectedTheme == .nightSanctuary`. Existing call sites light up automatically.

### Conditional accessors

Every existing color/material/gradient accessor on `ThemeManager` becomes a `switch selectedTheme` returning today's value for `.warmInviting` and the dark value for `.nightSanctuary`. The light path is **byte-identical** to today's. No accidental shifts.

### `@Published` triggers redraw

`selectedTheme` is already `@Published`. Toggling redraws the whole tree; no manual notification plumbing.

## Token palette

### Mapping (mock → `ThemeManager` accessor)

Top→bottom convention preserved from light:

| Mock token | Value | Accessor (dark return) | Notes |
|---|---|---|---|
| `D.bgTop` | `#1B1410` | `primaryBackground` | top of gradient |
| `D.bg` | `#120D0A` | `secondaryBackground` | middle of gradient |
| (deepest) | `#0B0705` | `tertiaryBackground` | bottom of gradient |
| `D.bgGlow` | `#3A2118` | new: `screenGlowColor` | for aura overlay |
| `D.surface` | `rgba(255,255,255,0.06)` | new: `glassSurface` | glass card fill |
| `D.surface2` | `rgba(255,255,255,0.04)` | new: `glassSurfaceRecessed` | recessed wells |
| `D.border` | `rgba(255,255,255,0.10)` | `strokeColor` | default border |
| `D.borderStrong` | `rgba(255,255,255,0.16)` | new: `strokeColorStrong` | emphasized border |
| `D.divider` | `rgba(255,255,255,0.07)` | new: `dividerColor` | row dividers |
| `D.ink` | `#FFFFFF` | `primaryText` | |
| `D.ink2` | `rgba(255,255,255,0.72)` | `secondaryText` | |
| `D.ink3` | `rgba(255,255,255,0.48)` | `tertiaryText` | |
| `D.ink4` | `rgba(255,255,255,0.32)` | new: `quaternaryText` | smallest captions |
| `D.accent` | `#E89464` | `accentColor` | peach |
| `D.accentDeep` | `#D17A48` | new: `accentColorDeep` | for gradients |
| `D.accentSoft` | `rgba(232,148,100,0.14)` | new: `accentColorSoft` | tinted backgrounds |
| `D.green` | `#5BC58A` | new: `semanticGreen` | progress, correct |
| `D.red` | `#F47875` | new: `semanticRed` | progress, incorrect |
| `D.blue` | `#6FA5E8` | new: `semanticBlue` | progress |
| `D.yellow` | `#F2C969` | new: `semanticYellow` | streaks, highlights |
| `D.lilac` | `#B8A6D9` | new: `semanticLilac` | secondary accent |

### Gradients

- **`accentGradient`** in dark: peach `#E89464` → peach-deep `#D17A48` (replaces light's sunset-orange).
- **`purpleGradient`** in dark: muted lilac `#B8A6D9` → ~`#9788C2`. Most call sites are decorative on Today/Quiz; we provide a sane dark equivalent so they don't look broken.

### Materials

- **`glassEffect`** stays `.ultraThinMaterial` for both modes — SwiftUI handles the rendering correctly given the forced `colorScheme`. The mock's glass look is achieved via `glassSurface` + `strokeColor` overlay on top of (or instead of) the material.

### Floating orbs

- **`floatingOrbColors`** dark variant: `(accentColor, 0.18)`, `(semanticLilac, 0.12)`, `(semanticGreen, 0.06)`. Slightly more visible than light's faint orbs since warm-black absorbs more.

### Light values

**Untouched.** Every accessor's `.warmInviting` branch returns today's exact value. Verified by Phase E regression check during implementation.

## Screen background composition

### No re-rooting

Most screens use `ZStack { LinearGradient(colors: [primary, secondary, tertiary]) … }`. We **keep that structure**. The dark accessors return the warm-black equivalents so existing gradients automatically become a dark gradient.

### `darkScreenAura()` modifier

New file `Utilities/DarkScreenAura.swift`:

```swift
extension View {
    func darkScreenAura(
        glowOpacity: Double = 0.32,
        starCount: Int = 14
    ) -> some View {
        modifier(DarkScreenAuraModifier(glowOpacity: glowOpacity, starCount: starCount))
    }
}
```

The modifier overlays — **only when `selectedTheme == .nightSanctuary`** — two layers behind content:

1. **Warm peach glow** at top-left, ~360pt diameter, radial fade `accentColor.opacity(glowOpacity)` → clear (matches mock's first glow blob).
2. **Lilac glow** at bottom-right, ~360pt, `semanticLilac.opacity(0.16)` → clear.
3. **Sparse stars layer** — `starCount` deterministically placed white dots (1.5–2.5pt, opacity 0.10–0.30, positions seeded by a fixed array so they don't reshuffle on redraw). No animation.

In light mode the modifier returns `content` unchanged — true no-op, zero impact on existing screens.

### Application points

Applied at the outermost container of:

**Tabs:** `HomeTab`, `TodayTab`, `ExploreTab`, `ProgressTab`.

**Top-level screens:** `SurahDetailView`, `DuasView`, `BookmarksView`, `QuestionsView`, `PropheticStoriesView`, `LifeMomentsView`, `RamadanJourneyView`, `SettingsView`, `PropheticParallelsView`, `FastingVersesView`, `AhlulbaytQuranView`, `NotificationsView`, `AuthenticationView`, `AccountDeletionView`.

**Detail views:** `DuaDetailView`, `StoryDetailView`, `QuestionDetailView`, `RamadanDayDetailView`, `ParallelDetailView`, `FastingCategoryDetailView`, `AhlulbaytEntryDetailView`, `QuizView`, `QuizResultsView`, `TafsirSourcesView`, `FullScreenCommentaryView`, `PaywallView`, `SurahAudioPlayerView`, `BadgeAwardView`, `WelcomeView`.

**Onboarding:** all `Onboarding/*` screens.

### Per-screen tuning

- **TodayTab:** `glowOpacity: 0.36, starCount: 14` (mock value)
- **SurahDetailView:** `glowOpacity: 0.22, starCount: 10`
- **ProgressTab:** `glowOpacity: 0.22, starCount: 14`
- **PaywallView:** `glowOpacity: 0.40, starCount: 18` (hero feel)
- **AuthenticationView**, **AccountDeletionView:** defaults but `starCount: 0` (forms shouldn't have visual chatter)
- **All others:** defaults `(0.32, 14)`

## Settings UI

### Location

`SettingsView.swift` — add a new "Appearance" section. Single row labeled "Theme" with a `Picker` styled as `.segmented`:

```
[ Light  |  Dark ]
```

Two segments only — no "System" option.

### Binding

```swift
Picker("Theme", selection: $themeManager.selectedTheme) {
    Text("Light").tag(ThemeVariant.warmInviting)
    Text("Dark").tag(ThemeVariant.nightSanctuary)
}
.pickerStyle(.segmented)
```

Toggling animates the change:
```swift
.onChange(of: selectedTheme) { _, newValue in
    withAnimation(.easeInOut(duration: 0.25)) {
        themeManager.selectedTheme = newValue
    }
}
```

### Onboarding

No theme question added to onboarding — would inflate the flow for a binary preference users can find in Settings.

### Discoverability

No first-launch banner, tooltip, or what's-new modal. Users find it in Settings. Default for new installs and existing users is `.warmInviting`.

## View audit & rollout strategy

### Phase A — Inventory

Grep across `Thaqalayn/Thaqalayn/Views/**/*.swift` and `Utilities/*.swift` for hardcoded color/material usage:

| Pattern | Action |
|---|---|
| `Color(red:` (raw RGB literals) | Move into `ThemeManager` if reused, otherwise convert to existing token |
| `Color.white`, `Color.black` literals | Replace with `themeManager.primaryText` / appropriate token unless intentionally mode-invariant (e.g., text on a peach button) |
| `Color.primary`, `Color.secondary` | Already auto-flip; keep |
| `Color(.systemBackground)`, `Color(.label)`, etc. | Already auto-flip; keep |
| `Color.gray`, `Color.accentColor` (default) | Replace with explicit theme token |
| Inline `LinearGradient(colors: […])` | If colors are theme-aware, keep; if hardcoded, route through new gradient tokens |
| `.background(.ultraThinMaterial)` | Keep — Material respects `colorScheme`; verify visually on dark |
| `.tint(`, `.accentColor(` modifiers | Replace literal tints with `themeManager.accentColor` |
| Decorative orbs / blob views | Drive their colors from `themeManager.floatingOrbColors` |

### Phase B — `WarmThemeModifiers.swift` audit

That file is the choke point — many screens compose styling through these modifiers. Each modifier becomes theme-aware: read from `ThemeManager.shared`. Verify no modifier silently returns light-only values.

### Phase C — Native chrome

Add helper `ChromeAppearance.apply(for: ThemeVariant)` called from `ThaqalaynApp.init()` and again on a Combine subscription to `themeManager.$selectedTheme`. It configures:

- `UITabBarAppearance().configureWithDefaultBackground()` with `selectedItemTintColor = UIColor(themeManager.accentColor)`
- `UINavigationBarAppearance().configureWithDefaultBackground()` with same translucent treatment
- Existing `.tint(themeManager.accentColor)` in `MainTabView` stays

### Phase D — Per-screen verification (manual)

For each screen in the application list, open Simulator in light + dark, scroll through every state (loading, empty, populated, error). Per-screen checks:

- Arabic text legibility on warm-black; the mock uses a peach text-shadow on hero Arabic — replicate via `.shadow(color: themeManager.accentColor.opacity(0.32), radius: 16)` only when dark
- Glass card legibility — `glassSurface` tint should not fight content
- Active/disabled button states
- Progress rings & charts — colors come from `semanticGreen/Red/Blue/Yellow` with new dark glow
- Images / SF Symbols — none accidentally render dark-on-dark
- Pickers, toggles, sliders — system controls auto-respect `colorScheme`

### Phase E — Light regression check

Second pass through every screen with theme set to light. Compare side-by-side with current production screenshots. Anything visually shifted in light is a bug — fix without touching dark.

### No fallback logic

Per `CLAUDE.md`: if a color/asset is missing for a mode we throw or assert in DEBUG; we don't silently substitute.

## Edge cases

- **LaunchScreen.** Storyboard/Asset Catalog asset; cannot read `themeManager`. Will briefly show light even when dark is selected. Acceptable cosmetic — flash is sub-second. Documented as known.
- **System controls in sheets.** `Picker`, `Toggle`, `DatePicker`, `Stepper`, keyboard, `UIAlertController` auto-respect `colorScheme` via the forced root `.preferredColorScheme`.
- **`SurahAudioPlayerView`.** Custom playback controls — verify scrubber track, play/pause, time labels in dark.
- **`QuizView` answer cards.** Use `semanticGreen`/`semanticRed`. Verify still readable on glass.
- **`BadgeAwardView`.** Particle/orb colors from `floatingOrbColors`. Verify confetti/glow contrast.
- **`PaywallView`.** Verify pricing CTAs, strike-throughs, "Most Popular" badge clarity on dark.
- **`OnboardingFlowView`.** Brand-image PNGs need transparent backgrounds — audit each onboarding screen's images.
- **Notifications.** `NotificationsView` cards route through `glassSurface`. iOS notification center body is OS-rendered, not us.
- **Share sheets / image exports.** Render with whatever theme is active. No special handling.
- **Verse art / images** from `generate-verse-art` skill — external assets, not theme-dependent.
- **`PremiumBadgeView`.** Gold accents — route any hardcoded yellow through `semanticYellow`.
- **`HighlightedText.swift`.** Search highlighting yellow — verify readable on dark glass via `semanticYellow`.

## Testing

### SwiftUI Previews

Each top-level screen gains a preview tuple rendering both themes:

```swift
#Preview("Light") { ScreenX().environmentObject(ThemeManager.lightPreview) }
#Preview("Dark")  { ScreenX().environmentObject(ThemeManager.darkPreview) }
```

`lightPreview` / `darkPreview` are static factory accessors on `ThemeManager` for previews only — not used at runtime.

### Manual simulator pass

iPhone 15 Pro simulator, both themes, every screen in the application list. Pre-/post-screenshots saved in `dark/verification/` (gitignored or kept lightweight, decision deferred to implementation).

### No automated snapshot tests

The project doesn't currently have a snapshot-test framework. Not added in this work. (Separate spec if desired later.)

## Risks & open questions

- **R1 — `WarmThemeModifiers.swift` may have deeper coupling than expected.** Until that file is read in detail during implementation, scope of audit is uncertain. **Mitigation:** first implementation step reads and themes that file end-to-end.
- **R2 — Asset Catalog `AccentColor`.** Referenced by SwiftUI's default `.tint`. We override at view level via `.tint(themeManager.accentColor)`, but if any code uses default `.tint`, it stays light-purple even in dark. **Mitigation:** explicitly set `.tint` on the `ContentView` root.
- **R3 — Light regressions from misplaced conditional branches.** If a `switch` accidentally returns dark in light or vice versa, light users see broken UI. **Mitigation:** Phase E regression check; reviewer checks every modified file with both themes in Preview.
- **R4 — `.ultraThinMaterial` rendering varies per OS.** Verified for iOS 18+ (current target). Older versions out of scope.
- **R5 — Accessibility.** Higher-contrast modes (Increase Contrast, Reduce Transparency) interact with `.ultraThinMaterial` and our white-alpha overlays. Not explicitly addressed in this spec; assumed to behave acceptably given the system materials respect those settings. Manual verification in Phase D.

## Out of scope

- Custom floating glass pill tab bar (Question 3 chose native TabView).
- Layout changes to match mocks beyond styling (Question 4 chose restyle-only).
- Light theme accent change (Question 5 chose untouched).
- "System" Dark Mode option (Question 1 chose manual only).
- Onboarding theme question.
- Snapshot testing infrastructure.
- LaunchScreen theming.
- Older iOS version support beyond current target.

## Implementation order (preview for plan)

The implementation plan (next step) is expected to sequence work approximately as:

1. **`ThemeManager` extension** — add `.nightSanctuary`, persistence, all conditional accessors with new tokens, `swiftUIColorScheme`, `isDarkMode`.
2. **`ThaqalaynApp.swift`** — apply `.preferredColorScheme(themeManager.swiftUIColorScheme)` at root; call `ChromeAppearance.apply` on launch and on theme change.
3. **`Utilities/DarkScreenAura.swift`** — new modifier with deterministic stars + radial glows.
4. **`Utilities/WarmThemeModifiers.swift`** — make every modifier theme-aware.
5. **`Utilities/ChromeAppearance.swift`** — UITabBar / UINavigationBar appearance helper.
6. **`SettingsView.swift`** — Appearance section with segmented Light/Dark picker.
7. **Screen audit & rollout** — apply `.darkScreenAura()` to each screen in the application list; replace hardcoded colors with `ThemeManager` calls.
8. **Phase D verification** — simulator pass on every screen in dark.
9. **Phase E regression** — simulator pass on every screen in light, compared to current production.
