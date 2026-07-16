# Deep Dive Onboarding Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a swipe-through onboarding screen that teases the immersive Deep Dive feature as a miniature "descent," slotted in as screen 4 (tag 3) right after "5 Layers of Wisdom."

**Architecture:** One new self-contained SwiftUI screen (`DeepDiveScreen`) that reuses the real feature's `DeepDivePalette` for a top-to-bottom descent gradient and a shared, extracted `DeepDiveMotes` view for rising gold motes. It is wired into the existing `OnboardingFlowView` paged `TabView` by inserting a tag and renumbering the ones after it. No new state, models, services, or persistence.

**Tech Stack:** Swift 5 / SwiftUI, Xcode 16 (synced folder groups), iOS. Fonts: Cormorant Garamond (`EmType.serif`) and Amiri (`EmType.arabic`). No third-party dependencies added.

## Global Constraints

Every task's requirements implicitly include these (values copied verbatim from the spec, `docs/superpowers/specs/2026-07-07-deep-dive-onboarding-screen-design.md`):

- **No em dashes** anywhere in copy or in code/comments you author. Plain dashes (`-`) only.
- **English only.** This screen does not use `LocalizedText` or the language manager; every string is an inline English literal, matching the rest of the onboarding flow.
- **Fixed dark palette** regardless of the user's selected app theme (the onboarding flow and Deep Dive both keep their own fixed dark look).
- **Does not scale with the reading text-size control** (`ReadingSettingsManager`). This is onboarding chrome, not reading content. Do not add `readingSettings.scale`.
- **Presentational only.** No CloudKit / Supabase / premium-gating changes, no "What's New" entry, no new persisted `UserDefaults` keys.
- **Verification gate (this project ships iOS without XCTest):** each task ends at a green `xcodebuild` build of the `Thaqalayn` scheme plus a working `#if DEBUG` SwiftUI preview. There is no unit-test target; do not add one. The user performs simulator install/launch/screenshot verification themselves.
- **Do not auto-commit.** Per project preference the user commits at their own checkpoints. Each task ends at a green build; leave the working tree staged-or-unstaged for the user. (If your executor requires a commit boundary, ask the user first.)
- **SourceKit note:** "cannot find type in scope" editor errors on newly created Swift files are stale-index false positives. Trust `xcodebuild`, not the editor squiggles.

**Canonical build command** (booted simulator confirmed present: iPhone 17 Pro Max):

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug build
```

Expected on success: `** BUILD SUCCEEDED **`.

---

### Task 1: Extract a shared `DeepDiveMotes` view

Pull the private rising-mote physics out of `DeepDiveBackground` into a standalone,
reusable `DeepDiveMotes` view so both the real immersive background and the new
onboarding screen share one implementation (DRY). The real Deep Dive must look
identical afterward (default count stays 16).

**Files:**
- Modify: `Thaqalayn/Views/DeepDive/DeepDiveBackground.swift`

**Interfaces:**
- Consumes: `DeepDivePalette.goldBright` (already in this file).
- Produces: `struct DeepDiveMotes: View { init(count: Int = 16) }` - a transparent layer
  of rising gold motes, honoring Reduce Motion. Consumed by Task 2.

- [ ] **Step 1: Add the `DeepDiveMotes` view**

In `Thaqalayn/Views/DeepDive/DeepDiveBackground.swift`, add this new struct immediately
after the closing brace of `enum DeepDivePalette` (i.e. between the palette and the
`// MARK: - Descent background view` section):

```swift
// MARK: - Rising motes (shared)

/// Slow rising gold light-motes over a transparent background. Extracted from
/// `DeepDiveBackground` so both the immersive descent and the onboarding
/// `DeepDiveScreen` share one implementation. Honours Reduce Motion (a static
/// scatter with no per-frame redraw).
struct DeepDiveMotes: View {
    /// How many motes to draw. The immersive background uses 16.
    let count: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Random mote parameters, generated ONCE so they stay stable across redraws.
    @State private var motes: [Mote]

    init(count: Int = 16) {
        self.count = count
        _motes = State(initialValue: DeepDiveMotes.makeMotes(count))
    }

    var body: some View {
        Group {
            if reduceMotion {
                // Reduce Motion: draw the motes once at fixed scattered positions,
                // with no animation and no per-frame redraw.
                moteCanvas(time: nil)
            } else {
                // Continuous slow rise: each mote loops on its own 16-36s period,
                // phase-staggered, forever.
                TimelineView(.animation) { timeline in
                    moteCanvas(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            }
        }
        .allowsHitTesting(false)
    }

    /// Draws all motes. `time == nil` -> static placement (Reduce Motion).
    private func moteCanvas(time: Double?) -> some View {
        Canvas { ctx, size in
            for mote in motes {
                // Vertical fraction: animated rise from just below the bottom
                // (1.08) up to just above the top (-0.08); static scatter otherwise.
                let yFrac: CGFloat = time.map { 1.08 - 1.16 * mote.phase(at: $0) } ?? mote.seed
                let x = mote.x * size.width
                let y = yFrac * size.height
                let d = mote.size
                let rect = CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d)
                ctx.fill(Path(ellipseIn: rect),
                         with: .color(DeepDivePalette.goldBright.opacity(mote.opacity)))
            }
        }
        .blur(radius: 0.3)
        .allowsHitTesting(false)
    }

    /// One rising light-mote. Parameters mirror the JSX `motes` state.
    private struct Mote: Identifiable {
        let id = UUID()
        let x: CGFloat          // horizontal position, 0...1 of width
        let size: CGFloat       // diameter, 1...3 pt
        let duration: Double    // rise period, 16...36 s
        let delay: Double       // CSS-style negative stagger, -30...0 s
        let opacity: Double     // 0.06...0.22
        let seed: CGFloat       // fixed vertical placement (0...1) for Reduce Motion

        /// Loop phase 0...1 at absolute `time`. A negative `delay` shifts the
        /// phase so the motes are already spread out rather than starting in unison.
        func phase(at time: Double) -> CGFloat {
            let cycles = (time - delay) / duration
            return CGFloat(cycles - cycles.rounded(.down))
        }
    }

    /// Generates the motes' random parameters once.
    private static func makeMotes(_ count: Int) -> [Mote] {
        (0 ..< count).map { _ in
            Mote(
                x: CGFloat.random(in: 0 ... 1),
                size: CGFloat.random(in: 1 ... 3),
                duration: Double.random(in: 16 ... 36),
                delay: -Double.random(in: 0 ... 30),
                opacity: Double.random(in: 0.06 ... 0.22),
                seed: CGFloat.random(in: 0 ... 1)
            )
        }
    }
}
```

- [ ] **Step 2: Point `DeepDiveBackground` at the shared view and delete its private copy**

In the same file, in `struct DeepDiveBackground`:

Delete this stored state line (around line 96-97):

```swift
    /// Random mote parameters, generated ONCE so they stay stable across redraws.
    @State private var motes: [Mote] = DeepDiveBackground.makeMotes()
```

In `body`, replace the `moteLayer` reference:

```swift
            // Rising gold light-motes.
            moteLayer
```

with:

```swift
            // Rising gold light-motes (shared implementation).
            DeepDiveMotes()
```

Then delete the now-unused private members of `DeepDiveBackground`: the entire
`// MARK: Motes` section, i.e. `private var moteLayer`, `private func moteCanvas`,
`private struct Mote`, and `private static func makeMotes()`. (They now live in
`DeepDiveMotes`.) Leave `DeepDivePalette`, the base fill, and the vignette untouched.

- [ ] **Step 3: Build to verify it compiles**

Run:

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug build
```

Expected: `** BUILD SUCCEEDED **`. If it fails, read the first error; the usual cause of
a mechanical extraction failure is a leftover reference to a deleted private member.

- [ ] **Step 4: Confirm the real feature is visually unchanged**

The existing `#Preview("Descent 0.0 / 0.5 / 1.0")` in this file already renders
`DeepDiveBackground`. Open it in the Xcode canvas (or leave it for the user's simulator
pass) and confirm motes still rise exactly as before. No code change here - this is a
visual confirmation step. Hand off to the user for the simulator check.

---

### Task 2: Create `DeepDiveScreen`

Build the complete onboarding teaser screen: descent gradient, shared motes, glowing
Arabic wordmark, header copy, the three-depth descent-line, footer caption, and the
staggered "descent-reveal" entrance motion.

**Files:**
- Create: `Thaqalayn/Views/Onboarding/DeepDiveScreen.swift`

**Interfaces:**
- Consumes: `DeepDivePalette` (colours + `.bg()` ramp) and `DeepDiveMotes` from Task 1;
  `EmType.serif` / `EmType.arabic`; the `.onbEyebrow()` / `.onbHeroTitle()` / `.onbBody()`
  / `.onbCaption()` `View` helpers (in `Views/Onboarding/Components/OnboardingTypography.swift`);
  `ThemeManager.shared` (`primaryText`, `secondaryText`).
- Produces: `struct DeepDiveScreen: View` - a no-argument onboarding page. Consumed by
  Task 3.

- [ ] **Step 1: Create the file with the complete screen**

Create `Thaqalayn/Views/Onboarding/DeepDiveScreen.swift` with exactly this content:

```swift
//
//  DeepDiveScreen.swift
//  Thaqalayn
//
//  Onboarding screen (tag 3): a swipe-through teaser for the immersive Deep Dive
//  feature. The screen becomes a miniature of the real "descent" - a deepening
//  backdrop, rising gold motes, a glowing Arabic wordmark, and a vertical
//  descent-line through Yaqin's three depths (Know / See / Live). English-only,
//  matching the rest of the onboarding flow. Reuses DeepDivePalette + DeepDiveMotes
//  for fidelity with the real feature.
//

import SwiftUI

struct DeepDiveScreen: View {
    @StateObject private var themeManager = ThemeManager.shared

    // Entrance animation drivers.
    @State private var isVisible = false      // header / nodes / footer fade-in
    @State private var lineDrawn = false      // descent-line draws downward
    @State private var haloPulse = false      // wordmark glow breathes

    /// Yaqin's three depths, dimming as they go deeper (the dive's real arc:
    /// ilm al-yaqin -> ayn al-yaqin -> haqq al-yaqin).
    private let depths: [(en: String, ar: String)] = [
        ("Know", "عِلْمُ الْيَقِين"),
        ("See",  "عَيْنُ الْيَقِين"),
        ("Live", "حَقُّ الْيَقِين"),
    ]

    var body: some View {
        ZStack {
            descentBackground
            DeepDiveMotes(count: 14)
            wordmark
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isVisible = true
            haloPulse = true
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) { lineDrawn = true }
        }
    }

    // MARK: - Background (the descent ramp, painted top -> bottom from the palette)

    private var descentBackground: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: DeepDivePalette.bg(0.00), location: 0.0),
                .init(color: DeepDivePalette.bg(0.32), location: 0.35),
                .init(color: DeepDivePalette.bg(0.55), location: 0.64),
                .init(color: DeepDivePalette.bg(0.82), location: 1.0),
            ]),
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Glowing wordmark (felt presence behind the content)

    private var wordmark: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [DeepDivePalette.goldBright.opacity(0.16), .clear],
                    center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .scaleEffect(haloPulse ? 1.06 : 1.0)
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true),
                           value: haloPulse)

            Text("يقين")
                .font(EmType.arabic(140))
                .foregroundColor(DeepDivePalette.cream.opacity(0.12))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .offset(x: 46, y: -30)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 1.0).delay(0.5), value: isVisible)
        .allowsHitTesting(false)
    }

    // MARK: - Foreground content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            descentLine
                .padding(.top, 44)
            Spacer(minLength: 0)
            footer
        }
        .padding(.horizontal, 34)
        .padding(.top, 64)
        .padding(.bottom, 70)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("A Deep Dive")
                .onbEyebrow()
                .foregroundColor(DeepDivePalette.gold)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -12)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

            Text("Descend into\na single truth")
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -16)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)

            Text("An immersive descent through three depths")
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .padding(.top, 12)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.45), value: isVisible)
        }
    }

    private var descentLine: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(depths.enumerated()), id: \.offset) { index, depth in
                DescentNode(index: index,
                            en: depth.en,
                            ar: depth.ar,
                            isLast: index == depths.count - 1,
                            isVisible: isVisible,
                            lineDrawn: lineDrawn)
            }
        }
    }

    private var footer: some View {
        Text("Find Deep Dives in the Journey tab")
            .onbCaption()
            .foregroundColor(themeManager.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(1.5), value: isVisible)
    }
}

// MARK: - One rung of the descent-line

private struct DescentNode: View {
    let index: Int
    let en: String
    let ar: String
    let isLast: Bool
    let isVisible: Bool
    let lineDrawn: Bool

    private var dotColor: Color {
        [DeepDivePalette.goldBright, DeepDivePalette.gold, DeepDivePalette.mute][index]
    }
    private var glowRadius: CGFloat { [12, 8, 0][index] }
    private var ringOpacity: Double { [0.16, 0.10, 0.0][index] }
    private var enColor: Color {
        index == 2 ? DeepDivePalette.cream.opacity(0.55) : DeepDivePalette.cream
    }
    private var arColor: Color {
        DeepDivePalette.goldBright.opacity(index == 2 ? 0.40 : 0.72)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            // Rail column: the glowing dot, then a connector down to the next node.
            VStack(spacing: 0) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(dotColor.opacity(ringOpacity), lineWidth: 5))
                    .shadow(color: DeepDivePalette.goldBright.opacity(glowRadius > 0 ? 0.7 : 0),
                            radius: glowRadius)

                if !isLast {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [DeepDivePalette.goldBright.opacity(0.6),
                                     DeepDivePalette.faint.opacity(0.15)],
                            startPoint: .top, endPoint: .bottom))
                        .frame(width: 1.5, height: 46)
                        .scaleEffect(x: 1, y: lineDrawn ? 1 : 0, anchor: .top)
                        .opacity(lineDrawn ? 1 : 0)
                }
            }

            // Labels: punchy English verb + the authentic Arabic term.
            VStack(alignment: .leading, spacing: 3) {
                Text(en)
                    .font(.system(size: 16, weight: .bold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundColor(enColor)
                Text(ar)
                    .font(EmType.arabic(17))
                    .foregroundColor(arColor)
            }
            .padding(.top, -2)

            Spacer(minLength: 0)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -10)
        .animation(.easeOut(duration: 0.5).delay(0.9 + Double(index) * 0.2), value: isVisible)
    }
}

#if DEBUG
#Preview {
    DeepDiveScreen()
}
#endif
```

- [ ] **Step 2: Build to verify it compiles**

Run:

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug build
```

Expected: `** BUILD SUCCEEDED **`. (Ignore any editor "cannot find `DeepDivePalette` /
`DeepDiveMotes` / `EmType` in scope" squiggles - those are stale-index false positives;
the build is the source of truth.)

- [ ] **Step 3: Visual check via preview, then hand to the user**

Open the `#Preview` in the Xcode canvas to confirm the composition renders: eyebrow +
serif title top-left, the three descent nodes (Know brightest -> Live dimmest) with their
Arabic terms, the faint glowing يقين behind them on the right, motes rising, and the
footer centered near the bottom. Positional constants (`.padding(.top, 64)`, the
wordmark `.offset`) are visually tunable; the user does the final simulator pass.

---

### Task 3: Wire `DeepDiveScreen` into the onboarding flow

Insert the new screen at tag 3 (after "5 Layers of Wisdom"), renumber the subsequent
tags, and bump the page count so the pager and Skip-button math stay correct.

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift`

**Interfaces:**
- Consumes: `DeepDiveScreen` from Task 2.
- Produces: nothing new (integration only).

- [ ] **Step 1: Bump the page count**

In `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift`, change (line ~17):

```swift
    private let totalPages = 13
```

to:

```swift
    private let totalPages = 14
```

- [ ] **Step 2: Insert the screen and renumber the tags**

Replace the entire `TabView(selection: $currentPage) { ... }` block (the screen list,
originally lines ~26-82) with this version. The only changes are: a new
`DeepDiveScreen().tag(3)` inserted after `FiveLayersScreen`, every following `.tag(n)`
incremented by one, and the `// Screen N:` comments renumbered (and the last comment's em
dash changed to a plain dash, per the no-em-dash rule):

```swift
            TabView(selection: $currentPage) {
                // Screen 1: Hadith
                HadithScreen(currentPage: $currentPage)
                    .tag(0)

                // Screen 2: Mission
                MissionScreen()
                    .tag(1)

                // Screen 3: Five Layers
                FiveLayersScreen()
                    .tag(2)

                // Screen 4: Deep Dive (immersive teaser)
                DeepDiveScreen()
                    .tag(3)

                // Screen 5: Quick Gems
                QuickGemsScreen()
                    .tag(4)

                // Screen 6: Progress Tracking
                ProgressTrackingScreen()
                    .tag(5)

                // Screen 7: Quiz Feature
                QuizFeatureScreen()
                    .tag(6)

                // Screen 8: Daily Challenge
                DailyChallengeScreen()
                    .tag(7)

                // Screen 9: Daily Crossword
                DailyCrosswordScreen()
                    .tag(8)

                // Screen 10: Seasonal Features (Ramadan Journey)
                SeasonalFeaturesScreen()
                    .tag(9)

                // Screen 11: Daily Verse
                DailyVerseScreen(notificationsEnabled: $notificationsEnabled)
                    .tag(10)

                // Screen 12: Progress Notifications
                ProgressNotificationsScreen(progressNotificationsEnabled: $progressNotificationsEnabled)
                    .tag(11)

                // Screen 13: Personalize (name + preferred language)
                PersonalizeScreen(currentPage: $currentPage)
                    .tag(12)

                // Screen 14: Final Setup (account only - theme picker removed)
                FinalScreen(
                    onComplete: {
                        completeOnboarding()
                    }
                )
                .tag(13)
            }
```

Leave everything else in the file unchanged: the `.tabViewStyle`/`.indexViewStyle`
modifiers, the Skip button (its `currentPage > 0 && currentPage < totalPages - 1` math
now covers pages 1...12 automatically), and `completeOnboarding()`.

- [ ] **Step 3: Build to verify it compiles**

Run:

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -configuration Debug build
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Hand off for full-flow simulator verification**

Ask the user to run the app with a fresh install (onboarding shows on first launch;
to force it again, reset `hasShownWelcome` - e.g. `defaults delete MAHR.Partner.Thaqalayn`
after a simulator install, or delete + reinstall the app) and swipe through onboarding.
Confirm: Deep Dive appears as the 4th screen right after "5 Layers of Wisdom"; the page
dots show 14 pages; Skip appears on it; the descent-reveal animation plays; and the
screens after it (Gems, Progress, ...) still appear in order.

---

## Self-Review

**1. Spec coverage** (checked against `2026-07-07-deep-dive-onboarding-screen-design.md`):

- Placement screen 3 / after 5 Layers / totalPages 14 -> Task 3. ✓
- Direction A "The Descent" + glowing wordmark -> Task 2 (`descentBackground`, `descentLine`, `wordmark`). ✓
- Exact copy (eyebrow, title, subtitle, three depths EN+AR, footer) -> Task 2 (literals). ✓
- Deepening gradient from `DeepDivePalette.bg()` -> Task 2 `descentBackground`. ✓
- Rising motes reused, not duplicated -> Task 1 extraction + Task 2 `DeepDiveMotes(count: 14)`. ✓
- Glowing breathing wordmark -> Task 2 `wordmark` (`haloPulse`). ✓
- Descent-reveal motion (staggered header, line draws down, nodes light in sequence, footer last) -> Task 2 (`isVisible`, `lineDrawn`, per-node delays `0.9 + index*0.2`). ✓
- Node dimming by depth -> Task 2 `DescentNode` (`dotColor`/`glowRadius`/`enColor`/`arColor` indexed). ✓
- English only / no reading-scale / fixed dark / presentational-only / no What's-New -> Global Constraints + no such code added. ✓
- Verification via xcodebuild + `#if DEBUG` preview -> every task's build step + Task 2 preview. ✓

No spec requirement is left without a task.

**2. Placeholder scan:** No "TBD"/"TODO"/"handle edge cases"/"similar to Task N". Every
code step shows complete code; every command shows expected output. ✓

**3. Type consistency:**
- `DeepDiveMotes(count:)` defined in Task 1, called as `DeepDiveMotes()` (default 16) by
  `DeepDiveBackground` in Task 1 and `DeepDiveMotes(count: 14)` in Task 2. ✓
- `DeepDivePalette.bg(_:)`, `.gold`, `.goldBright`, `.cream`, `.mute`, `.faint` - all exist
  in `DeepDiveBackground.swift` (read during planning); used consistently in Task 2. ✓
- `EmType.serif` / `EmType.arabic(_:)` and `.onbEyebrow()/.onbHeroTitle()/.onbBody()/.onbCaption()`
  exist (read during planning). ✓
- `DeepDiveScreen()` takes no arguments - defined Task 2, called Task 3. ✓
- `ThemeManager.shared.primaryText` / `.secondaryText` used as in sibling screens. ✓
