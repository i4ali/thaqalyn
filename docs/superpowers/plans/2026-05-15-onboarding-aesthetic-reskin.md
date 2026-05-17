# Onboarding Aesthetic Reskin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reskin all 10 existing onboarding screens to the warm "Variant C" aesthetic (tilt-gradient backgrounds, amber glow, glowing pastel hero chips, white rounded cards, refined typography) while keeping the flow, copy, content, and every animation/behavior exactly as-is.

**Architecture:** A small shared visual kit (palette + tilt tokens on `ThemeManager`, plus `OnboardingBackground`, `HeroChip`, `OnboardingCard`/`OnboardingRow` modifiers, typography helpers) is built first; then each screen is edited surgically against the kit. No timing/state/navigation line is changed — only color/shape/font attribute values, plus relocating each hero's existing glow-pulse into `HeroChip` at the same cadence.

**Tech Stack:** SwiftUI, Xcode 26.5, single target/scheme `Thaqalayn`, iOS Simulator. No test target exists — verification is **build success + a behavior-preservation `git diff` guardrail + a visual check against `design_handoff_onboarding_variant_c/screenshots/`.**

**Spec:** `docs/superpowers/specs/2026-05-15-onboarding-aesthetic-reskin-design.md`

---

## Conventions used by every task

### Build command (the "does it compile" check)

```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug build 2>&1 | tee /tmp/onb-build.log \
  | grep -E "\*\* BUILD (SUCCEEDED|FAILED) \*\*|error: " | tail -5
```
Expected on success: a line containing `** BUILD SUCCEEDED **`. (Use the
`generic/platform=iOS Simulator` destination — a named device like
`iPhone 16 Pro` does not resolve in this machine's Xcode 26.5 simulator set.)

Warnings check (incremental-robust): a raw `grep -c "warning:"` is **unreliable**
here — xcodebuild's incremental cache means a full build shows ~37, a cached
build 0, a partial build something else. Instead assert **no warning references
the changed file or the new symbols**:
```bash
grep -E "warning:" /tmp/onb-build.log | grep -E "<ChangedFile>\.swift|chip(Brand|Knowledge|Progress|Foundation|Featured|Comparative|Warmth)|OnboardingTilt|tiltColors|HeroChip|OnboardingBackground|onboardingCard|onboardingRow|onb(Hero|Final|Eyebrow|Card|Row|Body|Caption|Pill)"
```
Expected: **empty** (the change introduced no warnings). `** BUILD SUCCEEDED **`
remains the primary correctness gate.

### Behavior-preservation guardrail (the real "test" for "animations untouched")

After editing a screen file, run:

```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
git diff -- Thaqalayn/Views/Onboarding/<File>.swift \
  | grep -E '^[-+]' | grep -vE '^(\+\+\+|---)' \
  | grep -E '\.animation\(|\.delay\(|\.spring\(|withAnimation|asyncAfter|Timer\.scheduledTimer|repeatForever|isVisible|@State|@Binding|onTapGesture|onAppear|currentPage|onComplete|notificationsEnabled|progressNotificationsEnabled|selectedAnswer|selectedLayer|showQuestion|showResultCard|showProgressCard|showFeatureCards|isCheckboxChecked|animatedScore|animatedPercentage'
```

**Pass condition:** every line this prints must be a matched `-`/`+` pair that is
**identical except for a color/font/shape attribute value**, OR a removal that this
plan explicitly authorizes for that screen (the old hero glow-`Circle` + its
`iconPulse`/`showMoonGlow`/`starsPulse` state, which is relocated into `HeroChip`
at the same cadence). No timing number, delay, spring parameter, state name, or
navigation call may differ. If anything else differs, revert and redo.

### Visual check

```bash
# Pick any available iPhone sim by id from: xcrun simctl list devices available
DEV=$(xcrun simctl list devices available | grep -m1 -oE '[0-9A-F-]{36}')
xcrun simctl boot "$DEV" 2>/dev/null; open -a Simulator
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/thaqalyn-dd build
APP=$(find /tmp/thaqalyn-dd -name 'Thaqalayn.app' -type d | head -1)
BUNDLE=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$APP/Info.plist")
xcrun simctl uninstall "$DEV" "$BUNDLE" 2>/dev/null   # forces onboarding to show
xcrun simctl install "$DEV" "$APP"
xcrun simctl launch "$DEV" "$BUNDLE"
```
Onboarding shows on a fresh install (the uninstall above guarantees it). Compare
each screen against `design_handoff_onboarding_variant_c/screenshots/NN-*.png`.

### Kit usage reference (defined fully in Tasks 1–5; summarized here)

- `ThemeManager.chipBrand` / `.chipKnowledge` / `.chipProgress` / `.chipFoundation`
  / `.chipFeatured` / `.chipComparative` / `.chipWarmth` → `ChipColor { bg; fg }`.
- `OnboardingBackground(tilt: .peach | .lavender | .mauve | .sage)` → full-bleed
  tilt gradient + amber radial glow. Replaces a screen's root `.background(...)`.
- `HeroChip(palette:isVisible:) { <icon view> }` → 88×88 pastel chip + breathing
  halo. The **caller keeps its existing entrance modifiers** on the `HeroChip`
  (`.opacity/.scaleEffect/.animation(...value: isVisible)`) verbatim.
- `.onboardingCard()` → white fill, radius 22, soft warm shadow, padding 20.
  `.onboardingRow()` → white fill, radius 18, lighter shadow, padding 14.
- `OnboardingType` helpers: `.onbHeroTitle()`, `.onbFinalTitle()`, `.onbEyebrow()`,
  `.onbCardTitle()`, `.onbRowTitle()`, `.onbBody()`, `.onbCaption()`, `.onbPill()`.

---

## Task 0: Baseline capture — ✅ DONE (controller, 2026-05-15)

**Files:** none (read-only baseline).

- [x] **Step 1: Capture warning baseline + confirm clean build**

Executed by the controller:
`xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination
'generic/platform=iOS Simulator' -configuration Debug build` →
**`** BUILD SUCCEEDED **`**, **37** pre-existing warnings (`/tmp/onb-warnbase.txt`
= `WARN_BASELINE=37`). Baseline HEAD = `dac831b`; all onboarding screen files +
`ThemeManager.swift` clean at HEAD (guardrail diffs working tree vs `dac831b`).

- [x] **Step 2: No commit** — per user preference, no commits anywhere in this
plan; all changes stay in the working tree. Guardrail uses `git diff` vs `dac831b`.

---

## Task 1: ThemeManager — Variant C palette + tilt tokens

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift` (add a new MARK block; do not touch existing properties)

- [ ] **Step 1: Add the Variant C block**

Append this block inside `final class ThemeManager` (after the `// MARK: - Accents`
section, before `// MARK: - Materials`). It is **static / theme-agnostic** —
onboarding always renders under the default warm/light theme (verified:
`ContentView.swift:69`, `ThemeManager.swift:51`).

```swift
    // MARK: - Onboarding Variant C (static; onboarding is always warm/light)

    struct ChipColor { let bg: Color; let fg: Color }

    static let chipBrand       = ChipColor(bg: Color(hex: "FCE0CC"), fg: Color(hex: "C66829")) // peach
    static let chipKnowledge   = ChipColor(bg: Color(hex: "EAD8F0"), fg: Color(hex: "8C539F")) // plum
    static let chipProgress    = ChipColor(bg: Color(hex: "D6EADF"), fg: Color(hex: "3B8459")) // mint
    static let chipFoundation  = ChipColor(bg: Color(hex: "D8E8F4"), fg: Color(hex: "3D78B2")) // sky
    static let chipFeatured    = ChipColor(bg: Color(hex: "F8EAC9"), fg: Color(hex: "B5862A")) // butter
    static let chipComparative = ChipColor(bg: Color(hex: "E6DDE9"), fg: Color(hex: "7B6688")) // mauve
    static let chipWarmth      = ChipColor(bg: Color(hex: "F4D8D8"), fg: Color(hex: "C25656")) // rose

    enum OnboardingTilt { case peach, lavender, mauve, sage }

    static func tiltColors(_ tilt: OnboardingTilt) -> [Color] {
        switch tilt {
        case .peach:    return [Color(hex: "F5E6E6"), Color(hex: "F8E5D2"), Color(hex: "FAF2E8")]
        case .lavender: return [Color(hex: "F1E9F4"), Color(hex: "F5E8E5"), Color(hex: "FAF2E8")]
        case .mauve:    return [Color(hex: "ECE3F2"), Color(hex: "F2E6E8"), Color(hex: "FAF2E8")]
        case .sage:     return [Color(hex: "E6EEEB"), Color(hex: "F0EBE2"), Color(hex: "FAF2E8")]
        }
    }
```

`Color(hex:)` already exists and is non-optional (`Utilities/WarmThemeModifiers.swift:188`).
The warm CTA gradient for screens 8/9/10 reuses the **existing** `accentGradient`
(already warm sunset-orange `#E89A6F→#D88A5F` in light) — no new gradient token.

- [ ] **Step 2: Build**

Run the standard build command. Expected: `** BUILD SUCCEEDED **`, warning count
equals `/tmp/onb-warnbase.txt`.

- [ ] **Step 3: Guardrail**

Run: `git diff -- Thaqalayn/Services/ThemeManager.swift`
Expected: only **added** lines (the new block). No existing line modified/removed.

- [ ] **Step 4: Commit**

```bash
git add Thaqalayn/Services/ThemeManager.swift
git commit -m "feat(onboarding): add Variant C chip palette + tilt tokens"
```

---

## Task 2: `OnboardingBackground` component

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/OnboardingBackground.swift`

- [ ] **Step 1: Create the file**

```swift
//
//  OnboardingBackground.swift
//  Thaqalayn
//
//  Variant C reskin: per-screen warm tilt gradient + amber radial glow.
//  Onboarding is always warm/light, so values are fixed (no dark branching).
//

import SwiftUI

struct OnboardingBackground: View {
    let tilt: ThemeManager.OnboardingTilt

    var body: some View {
        ZStack {
            LinearGradient(
                colors: ThemeManager.tiltColors(tilt),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 232/255, green: 148/255, blue: 100/255).opacity(0.18),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
            .frame(width: 500, height: 400)
            .blur(radius: 8)
            .offset(y: -40)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackground(tilt: .peach)
        Text("peach").font(.title.bold())
    }
}
```

- [ ] **Step 2: Build** — standard command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add Thaqalayn/Views/Onboarding/Components/OnboardingBackground.swift
git commit -m "feat(onboarding): add OnboardingBackground (tilt + amber glow)"
```

---

## Task 3: `HeroChip` component

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/HeroChip.swift`

The current screens render the hero as a `ZStack` of a breathing glow `Circle`
(driven by an `iconPulse`/`showMoonGlow` `@State`), a gradient `Circle`
background, and the icon. `HeroChip` **replaces only that inner ZStack's
chrome + the breathing**. The host screen keeps its existing entrance modifiers
(`.opacity/.scaleEffect/.animation(... value: isVisible)`) on the `HeroChip`
verbatim, so entrance timing is unchanged. The breathing halo inside `HeroChip`
runs at the same `easeInOut(2.x s).repeatForever(autoreverses:true)` cadence the
old glow used, so the visible breathing behavior is preserved (relocated, not
removed — this relocation is the one diff the guardrail authorizes).

- [ ] **Step 1: Create the file**

```swift
//
//  HeroChip.swift
//  Thaqalayn
//
//  Variant C reskin: 88x88 pastel "chip" badge with a breathing amber halo.
//  Wraps each screen's existing hero icon (SF Symbol Image OR PhosphorIcon);
//  the host screen keeps its own entrance animation on this view.
//

import SwiftUI

struct HeroChip<Icon: View>: View {
    let palette: ThemeManager.ChipColor
    /// Pass nil to tint the icon with `palette.fg`; pass a color to override
    /// (used by Seasonal: plum chip + peach icon).
    var iconColor: Color? = nil
    /// Matches the breathing cadence the screen's old glow Circle used.
    var pulseDuration: Double = 2.5
    @ViewBuilder var icon: () -> Icon

    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill((iconColor ?? palette.fg).opacity(0.34))
                .frame(width: 120, height: 120)
                .blur(radius: 10)
                .scaleEffect(pulse ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: pulseDuration).repeatForever(autoreverses: true),
                    value: pulse
                )

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.bg)
                .frame(width: 88, height: 88)

            icon()
                .foregroundColor(iconColor ?? palette.fg)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { pulse = true }
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackground(tilt: .lavender)
        HeroChip(palette: ThemeManager.chipKnowledge) {
            Image(systemName: "sparkles").font(.system(size: 38, weight: .semibold))
        }
    }
}
```

- [ ] **Step 2: Build** — standard command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add Thaqalayn/Views/Onboarding/Components/HeroChip.swift
git commit -m "feat(onboarding): add HeroChip (pastel badge + breathing halo)"
```

---

## Task 4: `OnboardingCard` / `OnboardingRow` modifiers

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/OnboardingCard.swift`

- [ ] **Step 1: Create the file**

```swift
//
//  OnboardingCard.swift
//  Thaqalayn
//
//  Variant C reskin: white rounded card + warm shadow chrome.
//

import SwiftUI

struct OnboardingCardModifier: ViewModifier {
    var padding: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: Color(red: 60/255, green: 40/255, blue: 20/255).opacity(0.06),
                        radius: 12, x: 0, y: 8
                    )
            )
    }
}

struct OnboardingRowModifier: ViewModifier {
    var padding: CGFloat = 14
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: Color(red: 60/255, green: 40/255, blue: 20/255).opacity(0.04),
                        radius: 6, x: 0, y: 2
                    )
            )
    }
}

extension View {
    func onboardingCard(padding: CGFloat = 20) -> some View {
        modifier(OnboardingCardModifier(padding: padding))
    }
    func onboardingRow(padding: CGFloat = 14) -> some View {
        modifier(OnboardingRowModifier(padding: padding))
    }
}
```

- [ ] **Step 2: Build** — standard command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add Thaqalayn/Views/Onboarding/Components/OnboardingCard.swift
git commit -m "feat(onboarding): add onboardingCard/onboardingRow modifiers"
```

---

## Task 5: `OnboardingType` typography helpers

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/OnboardingTypography.swift`

- [ ] **Step 1: Create the file**

```swift
//
//  OnboardingTypography.swift
//  Thaqalayn
//
//  Variant C reskin: system-font type scale (no font import).
//  These set font + tracking only; callers keep their own foregroundColor.
//

import SwiftUI

extension View {
    func onbHeroTitle() -> some View {
        font(.system(size: 30, weight: .heavy)).tracking(-0.6)
    }
    func onbFinalTitle() -> some View {
        font(.system(size: 34, weight: .heavy)).tracking(-0.8)
    }
    func onbEyebrow() -> some View {
        font(.system(size: 11.5, weight: .bold)).tracking(3.4).textCase(.uppercase)
    }
    func onbCardTitle() -> some View {
        font(.system(size: 16, weight: .heavy)).tracking(-0.3)
    }
    func onbRowTitle() -> some View {
        font(.system(size: 15, weight: .bold)).tracking(-0.2)
    }
    func onbBody() -> some View {
        font(.system(size: 14.5, weight: .medium))
    }
    func onbCaption() -> some View {
        font(.system(size: 12, weight: .medium))
    }
    func onbPill() -> some View {
        font(.system(size: 11.5, weight: .bold)).tracking(0.3)
    }
}
```

- [ ] **Step 2: Build** — standard command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add Thaqalayn/Views/Onboarding/Components/OnboardingTypography.swift
git commit -m "feat(onboarding): add OnboardingType typography helpers"
```

---

# Phase 2 — Per-screen reskin

> **GLOBAL OVERRIDE (no commits):** Per user preference, **no `git commit` is run
> anywhere in this plan.** Every task's final "Commit" step is replaced by:
> *stage nothing, leave changes in the working tree.* All build/guardrail/visual
> verification still runs. The guardrail diffs the working tree against the
> pre-work HEAD `dac831b` (not `HEAD~N`).

Each screen task is self-contained. The pattern for all 10: (a) replace the root
`.background(themeManager.primaryBackground)` (or `GeometricPatternBackground()`)
with a `ZStack { OnboardingBackground(tilt:) ; <existing content> }`; (b) where a
hero glow-ZStack exists, replace its chrome with `HeroChip { existing icon }`
keeping the screen's entrance modifiers; (c) swap card chrome to
`.onboardingCard()`/`.onboardingRow()`; (d) recolor accent/gradient chips to the
mapped pastel `ChipColor`; (e) apply type helpers to title/subtitle. **Do not
touch** any `@State`, `@Binding`, `.animation`, `.delay`, `.spring`,
`withAnimation`, `asyncAfter`, `Timer`, `onAppear` sequencing, `onTapGesture`,
or navigation.

---

## Task 6: Screen 1 — `HadithScreen.swift` (tilt: peach, no hero chip)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/HadithScreen.swift`

Keep verbatim: `shimmerOffset`, `glowPulse`, all `isVisible` delays (0.3→1.7),
the 5s `asyncAfter` auto-advance, the `onTapGesture` advance, `startTitleAnimations()`.

- [ ] **Step 1: Swap the background**

Replace (lines ~18-21):
```swift
        ZStack {
            // Subtle Islamic geometric pattern background
            GeometricPatternBackground()

            VStack(spacing: 0) {
```
with:
```swift
        ZStack {
            OnboardingBackground(tilt: .peach)

            VStack(spacing: 0) {
```
(Leave the `GeometricPatternBackground` struct definition in the file untouched —
it may be referenced elsewhere; only stop using it here. Verify with
`grep -rn "GeometricPatternBackground" Thaqalayn --include=*.swift`; if no other
caller, still leave it — removal is out of scope.)

- [ ] **Step 2: Recolor the title glow + apply hero title type**

In the title `Text("Hadith of Thaqalayn")` block: change
`.font(.system(size: 20, weight: .semibold))` → keep the shimmer mask intact but
update the visible title to `.onbEyebrow()` is **wrong** here (it's the title, not
an eyebrow). Instead apply `.onbHeroTitle()` and keep `themeManager.primaryText`:
replace `.font(.system(size: 20, weight: .semibold))` (the outer `Text`, line ~28)
with `.onbHeroTitle()` and change its `.foregroundColor(themeManager.secondaryText)`
to `.foregroundColor(themeManager.primaryText)`. In the shimmer `.mask(Text(...))`
(line ~46-48) change the masked `Text`'s `.font(.system(size: 20, weight: .semibold))`
to **`.onbHeroTitle()`** (NOT a bare `.font(...)`) so the shimmer mask matches the
visible title *exactly*, including its `.tracking(-0.6)` — a bare font would make
the mask metrics drift from the rendered glyphs.
Change the glow `Ellipse().fill(themeManager.accentGradient.opacity(0.3))` to
`.fill(Color(hex: "C66829").opacity(0.22))` (warm amber, screen-1 brand fg).

- [ ] **Step 3: Wrap the hadith block in a white card**

Wrap the Arabic + divider + English + attribution group (the four `Text`/`VStack`
blocks after the title, lines ~65-119) in a single container and apply
`.onboardingCard()` + horizontal padding 22. Concretely, replace the outer
`VStack(spacing: 40) {` that holds title+arabic+divider+english+attribution so
that the **hadith content** (everything except the title) is grouped:
```swift
                VStack(spacing: 40) {
                    // Title with glow  (UNCHANGED block from Step 2)
                    Text("Hadith of Thaqalayn") /* ...existing modifiers... */

                    VStack(spacing: 24) {
                        // Arabic Hadith  (existing Text, modifiers UNCHANGED)
                        // Divider        (existing Capsule, fill -> Color(hex:"C66829"))
                        // English VStack (existing, UNCHANGED)
                        // Attribution    (existing, UNCHANGED)
                    }
                    .onboardingCard()
                    .padding(.horizontal, 22)
                }
```
Do not alter the inner `.opacity/.offset/.animation(... value: isVisible)` on each
element. Only the wrapping container + the divider `Capsule().fill(...)` color
(`themeManager.accentGradient` → `Color(hex: "C66829")`) change.

- [ ] **Step 4: Build** — standard command. Expected: `** BUILD SUCCEEDED **`,
warnings unchanged.

- [ ] **Step 5: Guardrail** — run the behavior-preservation grep for
`HadithScreen.swift`. Expected: prints only matched `-`/`+` pairs that differ in a
color/font value; `glowPulse`, `shimmerOffset`, the 5s `asyncAfter`, and
`onTapGesture` lines must be **unchanged** (present identically on `-` and `+`,
or untouched). If any timing/state differs, revert and redo.

- [ ] **Step 6: Visual check** — launch, screen 1. Compare to
`screenshots/01-welcome.png`: peach background, amber glow, white hadith card.
Confirm it still auto-advances after 5s and on tap.

- [ ] **Step 7: Commit**

```bash
git add Thaqalayn/Views/Onboarding/HadithScreen.swift
git commit -m "feat(onboarding): reskin HadithScreen to Variant C (peach)"
```

---

## Task 7: Screen 2 — `MissionScreen.swift` (tilt: lavender, hero: ثقلين logotype)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/MissionScreen.swift`

Keep verbatim: `shimmerOffset`, `startShimmerAnimation()`, the spring entrance on
the logotype (`.spring(response:0.8,dampingFraction:0.6).delay(0.3)`), all
`HighlightRow` `.delay(1.4/1.6/1.8/2.0)` staggers.

- [ ] **Step 1: Swap the background**

Replace (line ~124-125):
```swift
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
```
with:
```swift
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .lavender))
```

- [ ] **Step 2: Restyle the logotype halo (keep the ثقلين wordmark + shimmer)**

In the hero `ZStack` (lines ~21-63): the 3 glow `Circle`s use
`themeManager.accentGradient.opacity(0.3)`. Change each `.fill(...)` to
`.fill(Color(hex: "C66829").opacity(0.18))` (warm amber halo). **Do not** change
the `ForEach(0..<3)`, the `.scaleEffect/.opacity/.animation(... value: isVisible)`,
the `Text("ثقلين")`, or the shimmer overlay/mask. Only the 3 `.fill` colors change.

- [ ] **Step 3: Recolor the 4 feature rows to pastel chips**

In `struct HighlightRow` (lines ~147-175): the icon uses
`.foregroundColor(.white)` on a `RoundedRectangle(cornerRadius: 10).fill(themeManager.accentGradient)`
with `.shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)`. Replace
the `body` chrome so each row uses its mapped `ChipColor`. Add a `chip:` parameter:

Change the struct's stored properties to add `let chip: ThemeManager.ChipColor`
and replace the icon background block:
```swift
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(chip.fg)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 10).fill(chip.bg))

            Text(text)
                .onbRowTitle()
                .foregroundColor(themeManager.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
```
Wrap the whole `HStack` with `.onboardingRow()` (replace nothing else; keep the
`.opacity/.offset(x:)/.animation(... delay value: isVisible)` on the `HStack`).
Then at the 4 call sites (lines ~91-117) add the mapped chip argument:
`HighlightRow(icon:"book.closed.fill", text:..., chip: ThemeManager.chipBrand, isVisible:isVisible, delay:1.4)`,
`sparkles` → `ThemeManager.chipKnowledge` (delay 1.6),
`bell.fill` → `ThemeManager.chipFeatured` (delay 1.8),
`heart.fill` → `ThemeManager.chipWarmth` (delay 2.0).

- [ ] **Step 4: Apply title type**

`Text("This app brings...")` → add `.onbHeroTitle()` (replace its
`.font(.system(size: 26, weight: .semibold))`), keep `primaryText`. The second
`Text` (subtitle) → `.onbBody()` (replace `.font(.system(size: 18, weight: .medium))`),
keep `secondaryText`. Strings unchanged.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build (expect SUCCEEDED). Guardrail grep for `MissionScreen.swift` — `shimmerOffset`,
spring entrance, all 4 `.delay()` staggers unchanged. Visual vs
`screenshots/02-mission.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/MissionScreen.swift
git commit -m "feat(onboarding): reskin MissionScreen to Variant C (lavender)"
```

---

## Task 8: Screen 3 — `FiveLayersScreen.swift` (tilt: mauve, NEW plum hero chip)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift`

Keep verbatim: `selectedLayer` accordion `withAnimation(.spring(response:0.5,
dampingFraction:0.7))`, `LayerCard` `.delay(0.6 + index*0.1)`, the expand/collapse
`isExpanded` behavior + `.transition`, all `isVisible` delays (0.2, 0.4).

- [ ] **Step 1: Swap background**

Replace (lines ~67-68):
```swift
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
```
with:
```swift
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .mauve))
```

- [ ] **Step 2: Add the NEW hero chip above the title**

Inside the header `VStack(spacing: 16)` (line ~26), insert as the first child
(before `Text("5 Layers of Wisdom")`):
```swift
                HeroChip(palette: ThemeManager.chipKnowledge) {
                    PhosphorIcon(name: "ph-stack-fill", size: 38)
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isVisible)
```
(`ph-stack-fill` is the layers glyph, consistent with the existing Phosphor set
used by `LayerCard`. If that asset name is absent — verify with
`ls Thaqalayn/Assets.xcassets | grep -i stack` — fall back to
`Image(systemName: "square.stack.3d.up.fill").font(.system(size: 38, weight: .semibold))`.)

- [ ] **Step 3: Apply title/sub type**

`Text("5 Layers of Wisdom")` → `.onbHeroTitle()` (replace
`.font(.system(size: 32, weight: .bold))`), keep `primaryText`.
`Text("Tap each layer to explore")` → `.onbBody()` (replace
`.font(.system(size: 16, weight: .medium))`), keep `secondaryText`.

- [ ] **Step 4: Restyle LayerCard chrome to pastel**

In `struct LayerCard` add `let chip: ThemeManager.ChipColor`. Replace the icon
circle (lines ~94-100):
```swift
                    PhosphorIcon(name: emoji, size: 28)
                        .foregroundColor(chip.fg)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(chip.bg))
```
Replace the card background (lines ~156-166) so the resting state is a white
`.onboardingRow()` while keeping the expanded accent border:
```swift
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                isExpanded ? chip.fg.opacity(0.5) : Color.clear,
                                lineWidth: isExpanded ? 2 : 0
                            )
                    )
                    .shadow(color: Color(red: 60/255, green: 40/255, blue: 20/255).opacity(0.04), radius: 6, x: 0, y: 2)
            )
            .shadow(color: isExpanded ? chip.fg.opacity(0.18) : Color.clear, radius: isExpanded ? 12 : 0)
```
Keep the badge `Capsule().fill(layer.color)` → `.fill(chip.fg)`. Keep title
`.font(.system(size: 18, weight: .semibold))` → `.onbCardTitle()`. **Do not**
change `onTap`, `isExpanded`, the `.transition`, or the
`.opacity/.offset/.animation(... delay value: isVisible)`.
At the call site (lines ~46-61) add the per-row chip mapping by index:
`[ThemeManager.chipFoundation, .chipKnowledge, .chipProgress, .chipBrand, .chipComparative][index]`.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (`selectedLayer`, accordion spring, `.delay(0.6 + index*0.1)`,
`.transition` all unchanged; the new HeroChip entrance is an authorized addition).
Visual vs `screenshots/03-five-layers.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/FiveLayersScreen.swift
git commit -m "feat(onboarding): reskin FiveLayersScreen to Variant C (mauve) + hero chip"
```

---

## Task 9: Screen 4 — `QuickGemsScreen.swift` (tilt: lavender, hero: butter sparkles)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/QuickGemsScreen.swift`

Keep verbatim: `iconPulse`, `highlightedConcept`, `startConceptAnimation()`
`Timer`, spring entrance `.delay(0.2)`, `.delay(0.4/0.5/0.6/0.8)`,
`HighlightedArabicVerse` color logic + its `.animation(value: highlightedConcept)`.

- [ ] **Step 1: Swap background** — replace
`.background(themeManager.primaryBackground)` (line ~166) with
`.background(OnboardingBackground(tilt: .lavender))`.

- [ ] **Step 2: Replace hero ZStack chrome with HeroChip (butter)**

Replace the hero `ZStack` (lines ~37-70) — the glow `Circle`, gradient
background `Circle`, and `Image(systemName:"sparkles")` — with:
```swift
                HeroChip(palette: ThemeManager.chipFeatured, pulseDuration: 2.0) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 38, weight: .semibold))
                }
```
Keep the `.opacity(isVisible ? 1 : 0).scaleEffect(isVisible ? 1 : 0.5)
.animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2),
value: isVisible)` lines that follow (lines ~71-73) **unchanged**. The screen's
`iconPulse` state + `iconPulse = true` in `.onAppear` become unused; remove the
`@State private var iconPulse = false` and the `iconPulse = true` line — this is
the authorized hero-pulse relocation (cadence preserved by `pulseDuration: 2.0`).

- [ ] **Step 3: Type + verse card chrome**

`Text("Gems")` → `.onbHeroTitle()` (replace `.font(.system(size:34,weight:.bold))`).
`Text("Precious insights unveiled")` → `.onbBody()`.
Verse card background (lines ~142-149): replace the
`RoundedRectangle(cornerRadius:20).fill(themeManager.secondaryBackground.opacity(0.6)).overlay(stroke...)`
with `.onboardingCard()` applied to the inner `VStack(spacing:16)` (remove the
`.padding(16)` since the modifier adds 20; or pass `.onboardingCard(padding:16)`).
The `DemoInsightCard` background (lines ~267-275) → `.onboardingCard(padding:16)`,
keep its `concept.color` accent stroke removed (drop the `.overlay(stroke)`).

- [ ] **Step 4: Recolor the "255" badge + concept bubbles to pastel**

The `Circle().fill(LinearGradient(colors:[.purple,.blue]...))` "255" badge
(lines ~100-106) → `.fill(LinearGradient(colors:[ThemeManager.chipKnowledge.fg,
ThemeManager.chipFoundation.fg], startPoint:.topLeading, endPoint:.bottomTrailing))`.
In `DemoConceptBubble` (lines ~194-217) replace the `Capsule().fill(themeManager.glassEffect)`
chrome with a pastel pill: `.fill(color.opacity(0.16))`, drop the stroke overlay,
keep `isHighlighted` `.scaleEffect(1.05)` + shadow logic unchanged; label
`.font(.system(size:13,weight:.semibold))` → `.onbPill()`. The bubble `color`
values are passed in from `demoConcepts` (purple/green/blue/gold literals) — leave
those literal colors (current content); only the pill chrome changes.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (`Timer`, `highlightedConcept`, spring entrance, all delays
unchanged; `iconPulse` removal authorized). Visual vs
`screenshots/04-quick-gems.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/QuickGemsScreen.swift
git commit -m "feat(onboarding): reskin QuickGemsScreen to Variant C (lavender)"
```

---

## Task 10: Screen 5 — `ProgressTrackingScreen.swift` (tilt: sage, hero: mint check)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift`

Keep verbatim: `startAnimationSequence()` (all `asyncAfter` 2.0/0.8/0.2),
`animatePercentage()` `Timer`, `isCheckboxChecked` `onChange` pulse,
spring entrance `.delay(0.2)`, `.delay(0.4/0.5/0.6/0.3)`, `showProgressCard`.

- [ ] **Step 1: Swap background** — line ~106
`.background(themeManager.primaryBackground)` →
`.background(OnboardingBackground(tilt: .sage))`.

- [ ] **Step 2: HeroChip (mint)** — replace hero `ZStack` (lines ~23-56) with:
```swift
                HeroChip(palette: ThemeManager.chipProgress, pulseDuration: 2.0) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38, weight: .semibold))
                }
```
Keep the following `.opacity/.scaleEffect/.animation(... .delay(0.2) value:isVisible)`
(lines ~57-59) unchanged. Remove now-unused `@State private var iconPulse = false`
and `iconPulse = true` (authorized relocation).

- [ ] **Step 3: Type + card chrome**

`Text("Track Your Progress")` → `.onbHeroTitle()`;
`Text("Master the Quran, verse by verse")` → `.onbBody()`;
bottom `Text("Your progress syncs...")` → `.onbCaption()`.
`DemoVerseCard` background (lines ~209-216) → replace with `.onboardingCard()`
(drop secondaryBackground fill + stroke). `DemoProgressCard` background
(lines ~319-327) → `.onboardingCard(padding:16)`, drop the green stroke overlay.

- [ ] **Step 4: Recolor accents to mint/sky**

`DemoVerseCard` verse-number `Circle().fill(LinearGradient([.purple,.blue]))`
(lines ~160-166) → `LinearGradient([ThemeManager.chipKnowledge.fg,
ThemeManager.chipFoundation.fg], ...)`. `DemoCheckbox` green
(`Color.green` for border/fill/checkmark, lines ~246-258) →
`ThemeManager.chipProgress.fg`. `DemoProgressCard` surah badge gradient
(lines ~281-286) → `LinearGradient([ThemeManager.chipFoundation.fg,
ThemeManager.chipKnowledge.fg], ...)`; the `book.fill` + `\(percentage)%`
`.foregroundColor(.green)` → `.foregroundColor(ThemeManager.chipProgress.fg)`;
`Text("\(percentage)%")` keep `.contentTransition(.numericText())` **unchanged**.
Keep all `.opacity/.offset/.animation(... value: isVisible/showCard)` lines.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (all `asyncAfter`, `Timer`, `onChange`, delays, `contentTransition`
unchanged; `iconPulse` removal authorized). Visual vs
`screenshots/05-progress-tracking.png` & `08-bismillah-tracking.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift
git commit -m "feat(onboarding): reskin ProgressTrackingScreen to Variant C (sage)"
```

---

## Task 11: Screen 6 — `QuizFeatureScreen.swift` (tilt: mauve, hero: plum brain)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift`

Keep verbatim: `startAnimationSequence()` (all `asyncAfter` 0.8/2.5/0.5/1.5/0.3),
`animateScore()` `Timer`, `showQuestion`/`selectedAnswer`/`showCorrectFeedback`/
`showResultCard`, the `if !showResultCard` switch, all springs/delays,
`.contentTransition(.numericText())`.

- [ ] **Step 1: Swap background** — line ~113 → `OnboardingBackground(tilt: .mauve)`.

- [ ] **Step 2: HeroChip (plum)** — replace hero `ZStack` (lines ~25-58) with:
```swift
                HeroChip(palette: ThemeManager.chipKnowledge, pulseDuration: 2.0) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 38, weight: .semibold))
                }
```
Keep the trailing `.opacity/.scaleEffect/.animation(.delay(0.2) value:isVisible)`
(lines ~59-61). Remove unused `iconPulse` state + assignment (authorized).

- [ ] **Step 3: Type + card chrome**

`Text("Test Your Knowledge")` → `.onbHeroTitle()`;
`Text("Quizzes for every surah")` → `.onbBody()`;
bottom `Text("Deepen your understanding...")` → `.onbCaption()`.
`DemoQuestionCard` background (lines ~220-227) → `.onboardingCard()`.
`DemoResultCard` background (lines ~372-380) → `.onboardingCard(padding:24)`;
drop the purple stroke overlay; keep its
`.opacity/.scaleEffect/.animation(... value:isVisible)`.

- [ ] **Step 4: Swap emoji → SF symbol + recolor quiz accents**

In `DemoQuestionCard` the layer badge (lines ~185-197): replace
```swift
                Text("🏛️")
                    .font(.system(size: 14))
                Text("Foundation")
                    .font(.system(size: 12, weight: .semibold))
```
with:
```swift
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Foundation")
                    .onbPill()
```
and change `.foregroundColor(.blue)` → `.foregroundColor(ThemeManager.chipFoundation.fg)`
and the badge `RoundedRectangle(cornerRadius:12).fill(Color.blue.opacity(0.15))`
→ `.fill(ThemeManager.chipFoundation.bg)`.
In `DemoAnswerOption`: `backgroundColor`/`borderColor` use `.purple` for the
non-feedback selected state — change those two `.purple` literals to
`ThemeManager.chipKnowledge.fg`. Leave `.green`/`.red` feedback colors (current
correctness semantics — content). In `DemoResultCard`: the badge gradient
`[.purple.opacity(0.3), .purple.opacity(0.1)]` (lines ~322-327) →
`[ThemeManager.chipKnowledge.bg, ThemeManager.chipKnowledge.bg.opacity(0.5)]`;
`book.closed.fill` gradient + `Text("عالم")`/`Text("\(score)")` `.purple` →
`ThemeManager.chipKnowledge.fg`. Keep `.contentTransition(.numericText())`.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (all `asyncAfter`/`Timer`/state/springs/`contentTransition`
unchanged; `iconPulse` removal authorized; `🏛️`→symbol is a content-glyph swap
explicitly authorized by the spec). Visual vs `screenshots/06-quiz-feature.png`
& `07-quiz-result.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift
git commit -m "feat(onboarding): reskin QuizFeatureScreen to Variant C (mauve)"
```

---

## Task 12: Screen 7 — `SeasonalFeaturesScreen.swift` (tilt: lavender, hero: plum chip + peach moon)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift`

Keep verbatim: `starsPulse` 5-star twinkle `ForEach`, `showMoonGlow`,
`showFeatureCards` `asyncAfter(1.0)`, spring entrance `.delay(0.2)`,
`.delay(0.4/0.5/0.6)`, `SeasonalFeatureExpandedCard` `.delay(delay)` (0 / 0.2).

- [ ] **Step 1: Swap background** — line ~153 → `OnboardingBackground(tilt: .lavender)`.

- [ ] **Step 2: HeroChip (plum chip + peach icon), keep the twinkle stars**

In the hero `ZStack` (lines ~22-79): **keep** the `ForEach(0..<5)` twinkling
`star.fill` block (lines ~24-39) exactly. Replace only the glow `Circle`
(lines ~42-56), the gradient background `Circle` (lines ~59-67), and the
`Image(systemName:"moon.stars.fill")` (lines ~70-78) with a `HeroChip` that keeps
the stars layered around it:
```swift
                ZStack {
                    // KEEP: ForEach(0..<5) twinkling stars block — unchanged
                    HeroChip(palette: ThemeManager.chipKnowledge,
                             iconColor: ThemeManager.chipBrand.fg) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 38, weight: .semibold))
                    }
                }
```
Keep the trailing `.opacity/.scaleEffect/.animation(.delay(0.2) value:isVisible)`
(lines ~80-82). Remove now-unused `showMoonGlow` state + `showMoonGlow = true`
(its breathing is replaced by HeroChip's halo — authorized relocation). Keep
`starsPulse` (still drives the stars).

- [ ] **Step 3: Type + card chrome**

`Text("Special Seasons")` → `.onbHeroTitle()`;
`Text("Unique experiences...")` → `.onbBody()`;
bottom `Text("The Ramadan tab...")` → `.onbCaption()`.
`SeasonalFeatureExpandedCard` background (lines ~253-260) → `.onboardingCard()`.

- [ ] **Step 4: Recolor card accents to pastel**

`SeasonalFeatureExpandedCard` is called with `iconColors:[.yellow,.orange]`
(Ramadan) and `[.blue,.indigo]` (Future), `badgeColor:.purple`/`.blue`. To match
the screenshots, change the **call sites** (lines ~105-136): Ramadan
`iconColors: [ThemeManager.chipBrand.fg, ThemeManager.chipFeatured.fg]`,
`badgeColor: ThemeManager.chipKnowledge.fg`; Future
`iconColors: [ThemeManager.chipFoundation.fg, ThemeManager.chipComparative.fg]`,
`badgeColor: ThemeManager.chipFoundation.fg`. Inside the card, the icon
`Circle().fill(LinearGradient(iconColors.map{ $0.opacity(0.2) }))` stays (now
pastel-derived); title `.font(.system(size:18,weight:.bold))` → `.onbCardTitle()`;
badge `.font(.system(size:10,weight:.bold))` → `.onbPill()`. Strings & the
`features` arrays unchanged.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (`starsPulse`, `showFeatureCards` `asyncAfter`, all delays
unchanged; `showMoonGlow` removal authorized). Visual vs
`screenshots/10-seasonal-features.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift
git commit -m "feat(onboarding): reskin SeasonalFeaturesScreen to Variant C (lavender)"
```

---

## Task 13: Screen 8 — `DailyVerseScreen.swift` (tilt: peach, hero: brand bell)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift`

Keep verbatim: the `if let todayVerse...` data-driven block + its
`.animation(.delay(0.7) value:isVisible)`, spring `.delay(0.2)`,
`.delay(0.4/0.5/0.9/1.1)`, the enable `Button` `withAnimation(.spring)
notificationsEnabled.toggle()`, the `if !notificationsEnabled` text.

- [ ] **Step 1: Swap background** — line ~212 → `OnboardingBackground(tilt: .peach)`.

- [ ] **Step 2: HeroChip (brand) — replace the bell ZStack**

Replace the hero `ZStack` (lines ~26-41) — glow `Circle` + the
`Image(systemName:"bell.fill")` on `accentGradient` `Circle` — with:
```swift
                        HeroChip(palette: ThemeManager.chipBrand) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 36, weight: .semibold))
                        }
```
Keep the trailing `.scaleEffect/.opacity/.animation(.spring...delay(0.2)
value:isVisible)` (lines ~42-44) unchanged.

- [ ] **Step 3: Type + card chrome**

`Text("Your Daily Companion")` → `.onbHeroTitle()`;
`Text("Start each day...")` → `.onbBody()`.
Verse-of-the-day card background (lines ~122-130, the
`RoundedRectangle(cornerRadius:20).fill(glassEffect).overlay(stroke)` +
`.shadow`) → `.onboardingCard()` on its content `VStack(alignment:.leading,
spacing:16)` (keep the `.padding(.horizontal,24)` + the
`.opacity/.offset/.animation(... .delay(0.7) value:isVisible)` after it).
Islamic-calendar card (lines ~157-160) → `.onboardingRow()`. The verse-card
theme-tag `Capsule().fill(themeManager.accentGradient)` → `.fill(ThemeManager.chipBrand.bg)`
with the inner `Text` `.foregroundColor(.white)` → `ThemeManager.chipBrand.fg`.
`star.fill` `.foregroundColor(.yellow)` → `.foregroundColor(ThemeManager.chipFeatured.fg)`.

- [ ] **Step 4: Primary-CTA the enable button (purpleGradient → accentGradient)**

In the enable `Button` background (lines ~182-190): change the non-enabled branch
`themeManager.purpleGradient` → `themeManager.accentGradient`. Keep the enabled
green `LinearGradient`, the `withAnimation(.spring...).toggle()`, the icon/label
ternaries, `.shadow`, all unchanged. (This is the spec's authorized
`purpleGradient → accentGradient` CTA swap; `accentGradient` is the warm
sunset-orange token.)

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (the `if let` data block, `notificationsEnabled.toggle()`,
all delays/springs unchanged; no `iconPulse` here). Visual vs the daily-verse
look in the handoff. Then:
```bash
git add Thaqalayn/Views/Onboarding/DailyVerseScreen.swift
git commit -m "feat(onboarding): reskin DailyVerseScreen to Variant C (peach)"
```

---

## Task 14: Screen 9 — `ProgressNotificationsScreen.swift` (tilt: sage, hero: brand flame)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift`

Keep verbatim: spring `.delay(0.2)`, `.delay(0.4/0.5/0.7/0.8/0.9/1.1)`, the enable
`Button` `withAnimation(.spring) progressNotificationsEnabled.toggle()`, the
`if !progressNotificationsEnabled` text.

- [ ] **Step 1: Swap background** — line ~144 → `OnboardingBackground(tilt: .sage)`.

- [ ] **Step 2: HeroChip (brand) — keep the PhosphorIcon flame**

Replace the hero `ZStack` (lines ~24-44) — glow `Circle` + the
`PhosphorIcon(name:"ph-flame-fill", size:48)` on `glassEffect` `Circle` — with:
```swift
                        HeroChip(palette: ThemeManager.chipBrand) {
                            PhosphorIcon(name: "ph-flame-fill", size: 44)
                        }
```
Keep the trailing `.scaleEffect/.opacity/.animation(.spring...delay(0.2)
value:isVisible)` (lines ~45-47) unchanged.

- [ ] **Step 3: Type + row chrome**

`Text("Stay Motivated")` → `.onbHeroTitle()`;
`Text("Build your reading streak...")` → `.onbBody()`.
In `struct ProgressFeatureCard` (lines ~158-194): replace the card background
(lines ~186-193, `RoundedRectangle(16).fill(glassEffect).overlay(stroke)`) with
`.onboardingRow()`. Recolor the icon: add `let chip: ThemeManager.ChipColor`,
change `Circle().fill(color.opacity(0.2))` → `.fill(chip.bg)` and
`Image(systemName:icon).foregroundColor(color)` → `.foregroundColor(chip.fg)`;
title → `.onbRowTitle()`, description → `.onbBody()`. At the 3 call sites
(lines ~65-93) add `chip:`: `chart.bar.fill` → `ThemeManager.chipFoundation`,
`flame.fill` → `ThemeManager.chipBrand`, `trophy.fill` → `ThemeManager.chipFeatured`.
Keep the `.opacity/.offset/.animation(... delay value:isVisible)` on each card.

- [ ] **Step 4: Primary-CTA the enable button** — same swap as Task 13 Step 4:
non-enabled `themeManager.purpleGradient` → `themeManager.accentGradient` (line
~121). Everything else unchanged.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (`progressNotificationsEnabled.toggle()`, all delays/springs
unchanged). Visual vs `screenshots/09-stay-motivated.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift
git commit -m "feat(onboarding): reskin ProgressNotificationsScreen to Variant C (sage)"
```

---

## Task 15: Screen 10 — `FinalScreen.swift` (tilt: peach, no hero, CTA restyle)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/FinalScreen.swift`

Keep verbatim: `onComplete` on "Continue as Guest", `showingAuthentication = true`
on the other two, the `.fullScreenCover(AuthenticationView)` + its `onComplete`,
`.delay(0.2/0.3/0.5)`.

- [ ] **Step 1: Swap background** — line ~129 → `OnboardingBackground(tilt: .peach)`.

- [ ] **Step 2: Title type**

`Text("Begin Your Journey")` → `.onbFinalTitle()` (replace
`.font(.system(size:32,weight:.bold))`), keep `primaryText`.
`Text("Sync your reading progress...")` → `.onbBody()`.

- [ ] **Step 3: CTA styling — primary gradient + 2 secondary white**

"Continue as Guest" button background (lines ~54-58):
`RoundedRectangle(cornerRadius:16).fill(themeManager.purpleGradient)` →
`.fill(themeManager.accentGradient)`; change `.shadow(color: themeManager.accentColor.opacity(0.4), radius:12)`
→ `.shadow(color: Color(red:198/255,green:104/255,blue:41/255).opacity(0.35), radius:14, y:10)`;
corner radius 16 → 18 here and on the two secondary buttons.
"Create Account" + "Sign In" backgrounds (lines ~74-81 and ~97-104): keep the
white-ish `glassEffect` + stroke but switch to a clean white hairline:
`RoundedRectangle(cornerRadius:18).fill(Color.white).overlay(RoundedRectangle(cornerRadius:18).stroke(Color(red:31/255,green:22/255,blue:18/255).opacity(0.07), lineWidth:1))`.
Keep all three buttons' actions, labels, icons, `.padding(.vertical,16)`,
`.foregroundColor` unchanged.

- [ ] **Step 4: Benefits → white card with mint chip**

Wrap the "Account Benefits" `VStack(spacing:8)` (lines ~108-118) in
`.onboardingCard(padding:16)` and prefix the title with a mint chip:
```swift
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(ThemeManager.chipProgress.fg)
                                    .frame(width: 24, height: 24)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(ThemeManager.chipProgress.bg))
                                Text("Account Benefits").onbCardTitle()
                                    .foregroundColor(themeManager.primaryText)
                            }
                            Text("Sync bookmarks across devices and save your reading progress")
                                .onbCaption()
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .onboardingCard(padding: 16)
```
Keep the surrounding `.padding(.horizontal,24).opacity/.animation(.delay(0.5)
value:isVisible)` unchanged.

- [ ] **Step 5: Build / Guardrail / Visual / Commit**

Build. Guardrail (`onComplete`, `showingAuthentication`, `.fullScreenCover`,
delays unchanged). Visual vs `screenshots/11-final-account.png`. Then:
```bash
git add Thaqalayn/Views/Onboarding/FinalScreen.swift
git commit -m "feat(onboarding): reskin FinalScreen to Variant C (peach)"
```

---

## Task 16: Finalization — supersede old docs + full-flow verification

**Files:**
- Modify: `docs/plans/2026-05-15-onboarding-redesign-variant-c-design.md` (header note)
- Modify: `docs/plans/2026-05-15-onboarding-redesign-variant-c-plan.md` (header note)

- [ ] **Step 1: Add SUPERSEDED headers**

Prepend to the very top of **both** files:
```markdown
> **SUPERSEDED (2026-05-15)** by
> `docs/superpowers/specs/2026-05-15-onboarding-aesthetic-reskin-design.md`
> and `docs/superpowers/plans/2026-05-15-onboarding-aesthetic-reskin.md`.
> This document described a full rebuild; the shipped work is an aesthetic-only
> reskin that preserves the flow, copy, content, and all animations.

```
(Do not delete these files — they are the user's.)

- [ ] **Step 2: Full-flow build + warning check**

Run the standard build. Expected: `** BUILD SUCCEEDED **`. Run
`xcodebuild ... build 2>&1 | grep -c "warning:"` and confirm it equals
`/tmp/onb-warnbase.txt` (no new warnings).

- [ ] **Step 3: Full behavior-preservation guardrail (all 10 screens)**

```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
for f in Hadith Mission FiveLayers QuickGems ProgressTracking QuizFeature \
         Seasonal DailyVerse ProgressNotifications Final; do
  echo "== $f =="
  git diff dac831b -- "Thaqalayn/Views/Onboarding/${f}Screen.swift" \
    | grep -E '^[-+]' | grep -vE '^(\+\+\+|---)' \
    | grep -E '\.delay\(|\.spring\(|asyncAfter|Timer\.scheduledTimer|repeatForever|onTapGesture|onComplete|\.toggle\(\)|currentPage|contentTransition'
done
```
(No commits are made in this plan — diff against the baseline tag `dac831b`,
i.e. the working tree vs the pre-work HEAD.)
**Expected:** for every screen, each printed line appears as a matched `-`/`+`
pair with the timing/number/state **identical** (only nearby color/font context
differs), OR is one of the authorized hero-pulse relocations
(`iconPulse`/`showMoonGlow` removal). Any other difference = a behavior change;
fix that screen before proceeding.

- [ ] **Step 4: Manual visual pass through all 10 screens**

Fresh-install the app in the iPhone 16 Pro simulator, then repeat on iPhone SE
(3rd gen) (risk area: screen 1 long hadith in a card on a small device — confirm
no clipping and the 5s auto-advance still fires). Page through all 10; each must
visually match its `design_handoff_onboarding_variant_c/screenshots/NN-*.png`
counterpart and every animation (shimmer, glow/halo breathing, twinkle, staggered
entrances, quiz/progress demo sequences, checkbox pulse) must still play.

- [ ] **Step 5: Commit**

```bash
git add docs/plans/2026-05-15-onboarding-redesign-variant-c-design.md \
        docs/plans/2026-05-15-onboarding-redesign-variant-c-plan.md
git commit -m "docs: mark old Variant C rebuild docs as superseded"
```

---

## Self-Review (performed against the spec)

**1. Spec coverage:**
- Shared kit (palette, tilt, background, hero chip, card/row, type) → Tasks 1–5 ✓
- All 10 screens reskinned, flow order/tags/bindings unchanged → Tasks 6–15 ✓
- Tilt assignment (1 peach, 2 lavender, 3 mauve, 4 lavender, 5 sage, 6 mauve,
  7 lavender, 8 peach, 9 sage, 10 peach) → matches spec table ✓
- Three judgment calls: FiveLayers new plum hero (Task 8 Step 2) ✓; quiz
  `🏛️`→SF symbol (Task 11 Step 4) ✓; Final hero-less (Task 15, no hero) ✓
- Guardrails: no flow/copy/animation change → enforced by the per-task guardrail
  grep + Task 16 Step 3 ✓; no dark branching (kit is static) ✓; no app-wide
  `accentColor` repaint (only static block added to ThemeManager) ✓; old docs
  superseded not deleted (Task 16) ✓
- Acceptance criteria 1–5 → Task 16 Steps 2–4 ✓

**2. Placeholder scan:** No TBD/TODO. Every code step shows concrete code or exact
old→new edits with line anchors. Fallback for the `ph-stack-fill` asset is
explicit (verify-or-SF-symbol), not a vague "handle it."

**3. Type consistency:** `ThemeManager.ChipColor` / `chip*` tokens /
`OnboardingTilt` / `tiltColors` (Task 1) used consistently in Tasks 2,3,6–15.
`HeroChip(palette:iconColor:pulseDuration:){icon}` signature (Task 3) matches all
call sites (Tasks 8–14). `.onboardingCard()/.onboardingRow()` (Task 4) and
`.onb*()` type helpers (Task 5) used as defined. The spec's `HeroChip(symbol:)`
was refined to a ViewBuilder closure because heroes are a mix of SF Symbols and
`PhosphorIcon` — documented in the plan header and Task 3.

**Spec deviations (intentional, discovered against real code):**
- `HeroChip` takes an icon ViewBuilder, not a `symbol: String` (codebase uses
  both SF Symbols and `PhosphorIcon`).
- CTA gradient = the existing warm `accentGradient` via a `purpleGradient →
  accentGradient` swap (no new token) — current CTAs use `purpleGradient`; spec's
  "reuse `accentGradient`" holds because `accentGradient` is already warm.
- Each hero's existing glow-`Circle` breathing (`iconPulse`/`showMoonGlow`) is
  relocated into `HeroChip` at the same cadence; the guardrail explicitly
  authorizes only this removal.
