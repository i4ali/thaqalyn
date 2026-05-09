# Dark Theme — Known Issues & Deferred Items

Generated 2026-05-09 at end of dark-theme rollout (Tasks 1–25).

## Acceptable cosmetics

- **LaunchScreen flash.** The launch storyboard cannot read `themeManager`; users with Dark selected will see a brief light-theme flash on cold start (sub-second). Out of scope per spec — fix would require Asset Catalog work and is documented as a known cosmetic.

## Out-of-scope items deferred to future work

- **Snapshot tests.** The project has no test target; we did not introduce one. Spec explicitly lists this as out of scope.
- **OS Dark Mode following.** Per Question 1 in brainstorming, the app intentionally ignores OS Dark Mode and reads only the in-app `selectedTheme` toggle.
- **Layout changes to match the mocks beyond styling.** Spec restyle-only mandate held — no layout modifications were made to existing screens.
- **Light theme accent change.** Light still uses purple `#9B8FBF`; no shift to peach.
- **Custom floating glass-pill tab bar.** Native `TabView` chrome is used (per Question 3). The pill UI in the mocks was not implemented.
- **`AuthenticationStatusButton` in `ContentView.swift`.** Still has hardcoded blue `Color(red: 0.39, 0.4, 0.95).opacity(0.4)` shadow. Likely a legacy / unused struct; flagged in T12 concerns but not modified. If it's reachable from any code path, route through `themeManager.semanticBlue`.
- **`ModernSurahCard.surahNumberGradient`** in `ContentView.swift`. Still hardcoded sunset orange. Could be routed through `themeManager.accentGradient` for full consistency, but the orange/peach pair is close enough to the dark `accentGradient` that the visual diff is minimal.
- **`NotificationType.color` API change.** In T19 we refactored from a stored computed property to `func color(theme: ThemeManager) -> Color`. All current call sites were updated, but new callers must pass a theme.
- **`BookmarkDetailView` and `ModernBookmarksHeader` sort button.** Still use `themeManager.glassEffect` (Material) instead of the new `glassSurface` color. The plan's wording targeted "bookmark cards" specifically; if you want full consistency, swap them.

## Known visual concerns to verify in Phase D/E

- **Card stroke hairlines in light mode.** `WarmCardStyleModifier`, `WarmStatCardStyleModifier`, and per-screen card refactors now add a `themeManager.strokeColor` overlay border in BOTH modes. Light strokeColor is `(0.176, 0.145, 0.125).opacity(0.10)` — a faint warm-charcoal hairline. Watch for screens with many adjacent cards (Today tab stat grids, surah lists) where the cumulative effect could feel "boxed-in" compared to the prior shadow-only style. Mitigation if too prominent: gate the overlay to `.nightSanctuary` only or lower the light opacity.
- **`BadgeAwardView` ConfettiPiece in dark.** `floatingOrbColors` raw alpha is low (peach 0.18, lilac 0.12, green 0.06). The implementation calls `.opacity(1.0)` to reset alpha on each piece, which should yield full-bright confetti, but visually verify the green confetti dots aren't too dim.
- **`ProgressRingsStack` gradients.** Collapsed from a two-color hue ramp (e.g. `FF2D55` → `30D158` style) to `[semantic, semantic.opacity(0.85)]`. Visually subtler — if the previous Apple-Watch-style ramp is preferred, add `semanticRedDeep/GreenDeep/...` tokens to `ThemeManager`.
- **`PaywallView` background orbs + new aura.** Both layers add radial glows; watch for double-stacking in dark mode.
- **`HighlightedText`** — yellow highlight at 30% opacity in dark vs 50% in light. Verify legibility on dark glass cards in search results.

## Active accent and gradient mapping

For reference when debugging:

| Token | Light value | Dark value |
|---|---|---|
| `accentColor` | `#9B8FBF` purple | `#E89464` peach |
| `accentColorDeep` | `#8B7FA8` purple deep | `#D17A48` peach deep |
| `accentGradient` | sunset orange `#E89A6F` → `#D88A5F` | peach `#E89464` → `#D17A48` |
| `purpleGradient` | purple `#9B8FBF` → `#8B7FA8` | lilac `#B8A6D9` → `#9788C2` |
| `glassSurface` | `Color.white.opacity(0.6)` | `Color.white.opacity(0.06)` |
| `strokeColor` | warm charcoal at 10% | white at 10% |
| `strokeColorStrong` | warm charcoal at 18% | white at 16% |
