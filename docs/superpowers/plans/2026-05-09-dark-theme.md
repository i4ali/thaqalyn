# Dark Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a manual-toggle Dark theme to Thaqalayn, alongside the unchanged warmInviting Light theme, applied across every screen of the iOS app.

**Architecture:** Single `ThemeManager` (existing) gains a second `ThemeVariant` case (`.nightSanctuary`). Every existing color/material/gradient accessor becomes a `switch selectedTheme` returning today's value for `.warmInviting` (byte-identical) and the dark-mode value for `.nightSanctuary`. New tokens added for dark-only treatments (peach accent, glass surfaces, semantic colors, screen glow). A new `darkScreenAura()` modifier overlays radial glow + sparse stars only when dark is active. Theme is forced via `.preferredColorScheme(themeManager.swiftUIColorScheme)` at the app root (OS Dark Mode is ignored). Settings gets a 2-segment Light/Dark picker.

**Tech Stack:** SwiftUI, iOS 18+, UIKit (UITabBarAppearance / UINavigationBarAppearance), `UserDefaults` for persistence, no third-party theme libraries. No unit-test target exists; verification is **Xcode build + SwiftUI Previews + manual Simulator pass**.

**Spec:** `docs/superpowers/specs/2026-05-09-dark-theme-design.md`. Read it before starting.

**Conventions:**
- **All commits are user-driven.** Each task ends with a suggested `git commit` command — *the engineer running the plan should NOT auto-execute it.* Show the suggestion to the user; user decides when/whether to commit.
- **Light theme regression rule:** Every accessor's `.warmInviting` branch must return today's exact value. No accidental shifts. Verified in Task 23 (Phase E).
- **No fallback logic** (per `CLAUDE.md`): if a token is missing, throw / `fatalError` in DEBUG; do not silently substitute.
- **File-scoping note for Xcode 16 synced folders:** Xcode auto-discovers files dropped into source folders — no `.pbxproj` edits needed.

**Build command (used in many tasks):**

```bash
xcodebuild -project /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn.xcodeproj \
  -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6' \
  -configuration Debug build 2>&1 | tail -40
```

Expected: `** BUILD SUCCEEDED **`. If errors appear, fix before proceeding.

---

## Task 1: Audit hardcoded colors across the codebase

**Goal:** Produce a checklist file listing every hardcoded color/gradient/material literal across Views/Utilities so later tasks can reference it.

**Files:**
- Create: `dark/verification/audit.md`

- [ ] **Step 1: Run grep for `Color(red:` literals**

```bash
grep -rn 'Color(red:' /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Views \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Utilities \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/ContentView.swift > /tmp/audit-rgb.txt
```

- [ ] **Step 2: Run grep for `Color.white` and `Color.black` literal usage**

```bash
grep -rnE '\bColor\.(white|black|gray|primary|secondary|accentColor)\b' /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Views \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Utilities \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/ContentView.swift > /tmp/audit-named.txt
```

- [ ] **Step 3: Run grep for hex-init colors and Color(.system…) and `.warm*` static colors**

```bash
grep -rnE 'Color\(hex:|Color\(\.system|Color\.warm[A-Z]' /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Views \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Utilities \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/ContentView.swift > /tmp/audit-other.txt
```

- [ ] **Step 4: Run grep for inline gradients and materials**

```bash
grep -rnE 'LinearGradient\(|RadialGradient\(|\.ultraThinMaterial|\.thinMaterial|\.regularMaterial' /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Views \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Utilities \
  /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/ContentView.swift > /tmp/audit-gradients.txt
```

- [ ] **Step 5: Write `dark/verification/audit.md`**

Concatenate the four `/tmp/audit-*.txt` outputs into a single Markdown file with sections (`## Raw RGB`, `## Named colors`, `## Hex / system / warm statics`, `## Gradients & materials`). Each line should be `path/to/file.swift:LINE — context`. This file is read-only documentation for later tasks; not a strict requirement to clear every entry — it's the inventory.

```bash
{
  echo "# Hardcoded color audit — generated $(date '+%Y-%m-%d')"
  echo
  echo "## Raw RGB literals"; echo '```'; cat /tmp/audit-rgb.txt; echo '```'
  echo "## Named Color usages"; echo '```'; cat /tmp/audit-named.txt; echo '```'
  echo "## Hex / system / warm statics"; echo '```'; cat /tmp/audit-other.txt; echo '```'
  echo "## Gradients & materials"; echo '```'; cat /tmp/audit-gradients.txt; echo '```'
} > /Users/muhammadimranali/Documents/development/thaqalyn/dark/verification/audit.md
```

- [ ] **Step 6: Confirm file exists**

```bash
test -s /Users/muhammadimranali/Documents/development/thaqalyn/dark/verification/audit.md && echo "audit ok"
```

Expected: `audit ok`.

- [ ] **Step 7: (User-driven commit, suggested message)**

```bash
git add dark/verification/audit.md
git commit -m "chore(dark): inventory hardcoded color usage"
```

---

## Task 2: Add `.nightSanctuary` ThemeVariant case + display strings

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift`

- [ ] **Step 1: Replace `ThemeVariant` enum**

Open `Thaqalayn/Services/ThemeManager.swift`. Replace the existing enum with:

```swift
enum ThemeVariant: String, CaseIterable {
    case warmInviting = "warmInviting"
    case nightSanctuary = "nightSanctuary"

    var displayName: String {
        switch self {
        case .warmInviting:   return "Light"
        case .nightSanctuary: return "Dark"
        }
    }

    var description: String {
        switch self {
        case .warmInviting:   return "Sanctuary-like warm design"
        case .nightSanctuary: return "Verse-Hero warm-black with peach accent"
        }
    }
}
```

- [ ] **Step 2: Build**

Run the standard build command from the header. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: (User-driven commit, suggested message)**

```bash
git add Thaqalayn/Services/ThemeManager.swift
git commit -m "feat(theme): add nightSanctuary variant case"
```

---

## Task 3: ThemeManager persistence + `swiftUIColorScheme` + reactivated `isDarkMode`

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift`

- [ ] **Step 1: Replace `ThemeManager` class top with persistence + scheme**

Replace the class (`@MainActor class ThemeManager: ObservableObject { … }`) so the top of the class reads:

```swift
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    private static let storageKey = "selectedTheme"

    @Published var selectedTheme: ThemeVariant {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Self.storageKey)
        }
    }

    private init() {
        // Drop legacy keys from pre-removal era (defensive, no behavior change).
        UserDefaults.standard.removeObject(forKey: "isDarkMode")

        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = ThemeVariant(rawValue: raw) {
            self.selectedTheme = saved
        } else {
            self.selectedTheme = .warmInviting
        }
    }

    var isDarkMode: Bool { selectedTheme == .nightSanctuary }

    var colorScheme: ColorScheme { selectedTheme == .nightSanctuary ? .dark : .light }

    /// Alias kept for clarity at call sites that prefer the explicit name.
    var swiftUIColorScheme: ColorScheme { colorScheme }

    // MARK: - Backgrounds — see Task 4
    // (Existing accessors below are intentionally left in place for now;
    // Task 4 makes them theme-conditional.)
```

> **NOTE:** keep all the existing color/material accessors below this point untouched in Task 3. Only the top of the class changes.

- [ ] **Step 2: Build**

Run the build command. Expected `** BUILD SUCCEEDED **`. Existing call sites of `themeManager.colorScheme` / `isDarkMode` already type-check.

- [ ] **Step 3: Smoke-test persistence in Simulator**

Launch the app in Simulator. Open `SettingsView` (or any screen that displays content) — confirm the app still launches and shows light theme (default for new install or migrated user). No behavior change visible yet.

- [ ] **Step 4: (User-driven commit, suggested message)**

```bash
git add Thaqalayn/Services/ThemeManager.swift
git commit -m "feat(theme): persist selectedTheme + reactivate isDarkMode"
```

---

## Task 4: ThemeManager — conditional background, text, accent, and stroke colors

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift`

- [ ] **Step 1: Replace background accessors**

Replace `primaryBackground`, `secondaryBackground`, `tertiaryBackground` with:

```swift
// MARK: - Backgrounds

var primaryBackground: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.973, green: 0.961, blue: 1.0) // #F8F5FF
    case .nightSanctuary:
        return Color(red: 0.106, green: 0.078, blue: 0.063) // #1B1410
    }
}

var secondaryBackground: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.987, green: 0.969, blue: 0.980) // #FBFBFA
    case .nightSanctuary:
        return Color(red: 0.071, green: 0.051, blue: 0.039) // #120D0A
    }
}

var tertiaryBackground: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 1.0, green: 0.976, blue: 0.961) // #FFF9F5
    case .nightSanctuary:
        return Color(red: 0.043, green: 0.027, blue: 0.020) // #0B0705
    }
}
```

- [ ] **Step 2: Replace text accessors + add `quaternaryText`**

Replace `primaryText`, `secondaryText`, `tertiaryText` and add `quaternaryText`:

```swift
// MARK: - Text

var primaryText: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.176, green: 0.145, blue: 0.125) // #2D2520
    case .nightSanctuary:
        return Color.white
    }
}

var secondaryText: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.42, green: 0.365, blue: 0.329) // #6B5D54
    case .nightSanctuary:
        return Color.white.opacity(0.72)
    }
}

var tertiaryText: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.69, green: 0.64, blue: 0.6) // #B0A399
    case .nightSanctuary:
        return Color.white.opacity(0.48)
    }
}

var quaternaryText: Color {
    switch selectedTheme {
    case .warmInviting:
        // Light: a slightly lighter gray than tertiary.
        return Color(red: 0.78, green: 0.74, blue: 0.71)
    case .nightSanctuary:
        return Color.white.opacity(0.32)
    }
}
```

- [ ] **Step 3: Replace `accentColor` + add `accentColorDeep` and `accentColorSoft`**

Replace `accentColor` and add the two new tokens:

```swift
// MARK: - Accents

var accentColor: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF — peaceful purple
    case .nightSanctuary:
        return Color(red: 0.910, green: 0.580, blue: 0.392) // #E89464 — peach
    }
}

var accentColorDeep: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.545, green: 0.498, blue: 0.659) // #8B7FA8 — purple deep
    case .nightSanctuary:
        return Color(red: 0.820, green: 0.478, blue: 0.282) // #D17A48 — peach deep
    }
}

var accentColorSoft: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.14)
    case .nightSanctuary:
        return Color(red: 0.910, green: 0.580, blue: 0.392).opacity(0.14)
    }
}
```

- [ ] **Step 4: Replace `strokeColor` + add `strokeColorStrong` and `dividerColor`**

```swift
// MARK: - Strokes & dividers

var strokeColor: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.10)
    case .nightSanctuary:
        return Color.white.opacity(0.10)
    }
}

var strokeColorStrong: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.18)
    case .nightSanctuary:
        return Color.white.opacity(0.16)
    }
}

var dividerColor: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.06)
    case .nightSanctuary:
        return Color.white.opacity(0.07)
    }
}
```

- [ ] **Step 5: Build**

Build with the standard command. Expected: `** BUILD SUCCEEDED **`. (Light returns the byte-identical values it returns today.)

- [ ] **Step 6: Smoke-test in Simulator**

Launch app, confirm light still renders identically to before.

- [ ] **Step 7: (User-driven commit, suggested message)**

```bash
git add Thaqalayn/Services/ThemeManager.swift
git commit -m "feat(theme): conditional background/text/accent/stroke colors"
```

---

## Task 5: ThemeManager — gradients, materials, orbs, glass surfaces, semantic colors

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift`

- [ ] **Step 1: Replace `accentGradient` and `purpleGradient`**

```swift
// MARK: - Gradients

var accentGradient: LinearGradient {
    switch selectedTheme {
    case .warmInviting:
        return LinearGradient(
            colors: [
                Color(red: 0.91, green: 0.604, blue: 0.435), // #E89A6F sunset orange
                Color(red: 0.847, green: 0.541, blue: 0.373) // #D88A5F deeper orange
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    case .nightSanctuary:
        return LinearGradient(
            colors: [
                Color(red: 0.910, green: 0.580, blue: 0.392), // #E89464 peach
                Color(red: 0.820, green: 0.478, blue: 0.282)  // #D17A48 peach deep
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

var purpleGradient: LinearGradient {
    switch selectedTheme {
    case .warmInviting:
        return LinearGradient(
            colors: [
                Color(red: 0.608, green: 0.561, blue: 0.749), // #9B8FBF
                Color(red: 0.545, green: 0.498, blue: 0.659)  // #8B7FA8
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    case .nightSanctuary:
        return LinearGradient(
            colors: [
                Color(red: 0.722, green: 0.651, blue: 0.851), // #B8A6D9 muted lilac
                Color(red: 0.592, green: 0.533, blue: 0.761)  // #9788C2 deeper lilac
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

- [ ] **Step 2: Material accessor (unchanged), add `glassSurface` + `glassSurfaceRecessed` + `screenGlowColor`**

Replace `glassEffect` and add the new tokens:

```swift
// MARK: - Materials

var glassEffect: Material { .ultraThinMaterial }

var glassSurface: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color.white.opacity(0.6)
    case .nightSanctuary:
        return Color.white.opacity(0.06)
    }
}

var glassSurfaceRecessed: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color.white.opacity(0.4)
    case .nightSanctuary:
        return Color.white.opacity(0.04)
    }
}

var screenGlowColor: Color {
    switch selectedTheme {
    case .warmInviting:
        // Light barely uses this; return a faint warm tint.
        return Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.08)
    case .nightSanctuary:
        return Color(red: 0.227, green: 0.129, blue: 0.094) // #3A2118
    }
}
```

- [ ] **Step 3: Replace `floatingOrbColors`**

```swift
// MARK: - Orbs

var floatingOrbColors: [Color] {
    switch selectedTheme {
    case .warmInviting:
        return [
            Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.06), // purple
            Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.05),  // orange
            Color(red: 0.498, green: 0.722, blue: 0.604).opacity(0.04)  // green
        ]
    case .nightSanctuary:
        return [
            Color(red: 0.910, green: 0.580, blue: 0.392).opacity(0.18), // peach
            Color(red: 0.722, green: 0.651, blue: 0.851).opacity(0.12), // lilac
            Color(red: 0.357, green: 0.773, blue: 0.541).opacity(0.06)  // green
        ]
    }
}
```

- [ ] **Step 4: Add semantic colors**

```swift
// MARK: - Semantic

var semanticGreen: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.498, green: 0.722, blue: 0.604) // #7FB89A
    case .nightSanctuary:
        return Color(red: 0.357, green: 0.773, blue: 0.541) // #5BC58A
    }
}

var semanticRed: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.93, green: 0.28, blue: 0.6) // current pink-red used in ErrorView
    case .nightSanctuary:
        return Color(red: 0.957, green: 0.471, blue: 0.459) // #F47875
    }
}

var semanticBlue: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.39, green: 0.4, blue: 0.95) // current blue used in toolbars
    case .nightSanctuary:
        return Color(red: 0.435, green: 0.647, blue: 0.910) // #6FA5E8
    }
}

var semanticYellow: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.95, green: 0.78, blue: 0.30) // warm gold
    case .nightSanctuary:
        return Color(red: 0.949, green: 0.788, blue: 0.412) // #F2C969
    }
}

var semanticLilac: Color {
    switch selectedTheme {
    case .warmInviting:
        return Color(red: 0.722, green: 0.651, blue: 0.851).opacity(0.7)
    case .nightSanctuary:
        return Color(red: 0.722, green: 0.651, blue: 0.851) // #B8A6D9
    }
}
```

- [ ] **Step 5: Build and visual smoke-test**

Build (`** BUILD SUCCEEDED **`). Launch in Simulator — light theme should still look identical (since semantic colors are *new* tokens; existing screens that hardcode similar colors will be migrated in later tasks).

- [ ] **Step 6: (User-driven commit)**

```bash
git add Thaqalayn/Services/ThemeManager.swift
git commit -m "feat(theme): conditional gradients/materials/orbs/semantic tokens"
```

---

## Task 6: Add `lightPreview` / `darkPreview` factories for SwiftUI Previews

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift`

- [ ] **Step 1: Append preview factories at the end of the class**

```swift
    // MARK: - Preview helpers (DEBUG only)

    #if DEBUG
    /// Returns a freshly-instantiated ThemeManager forced to light, for SwiftUI Previews only.
    /// Do NOT use at runtime — this bypasses the singleton.
    static var lightPreview: ThemeManager {
        let m = ThemeManager()
        m.selectedTheme = .warmInviting
        return m
    }

    /// Returns a freshly-instantiated ThemeManager forced to dark, for SwiftUI Previews only.
    static var darkPreview: ThemeManager {
        let m = ThemeManager()
        m.selectedTheme = .nightSanctuary
        return m
    }
    #endif
```

- [ ] **Step 2: Build**

`** BUILD SUCCEEDED **`.

- [ ] **Step 3: (User-driven commit)**

```bash
git add Thaqalayn/Services/ThemeManager.swift
git commit -m "feat(theme): preview-only light/dark factory accessors"
```

---

## Task 7: Create `DarkScreenAura` modifier (radial glows + sparse stars)

**Files:**
- Create: `Thaqalayn/Utilities/DarkScreenAura.swift`

- [ ] **Step 1: Write the file**

Create `Thaqalayn/Utilities/DarkScreenAura.swift`:

```swift
//
//  DarkScreenAura.swift
//  Thaqalayn
//
//  View modifier that overlays radial glows + sparse stars behind content
//  when the active theme is .nightSanctuary. No-op in light theme.
//

import SwiftUI

struct DarkScreenAuraModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    let glowOpacity: Double
    let starCount: Int

    func body(content: Content) -> some View {
        if themeManager.selectedTheme == .nightSanctuary {
            content.background(auraLayer.ignoresSafeArea())
        } else {
            content
        }
    }

    private var auraLayer: some View {
        ZStack {
            // Top-left peach glow (~360pt radius)
            RadialGradient(
                colors: [themeManager.accentColor.opacity(glowOpacity), .clear],
                center: .init(x: 0.15, y: 0.05),
                startRadius: 0,
                endRadius: 360
            )

            // Bottom-right lilac glow
            RadialGradient(
                colors: [themeManager.semanticLilac.opacity(0.16), .clear],
                center: .init(x: 0.85, y: 0.95),
                startRadius: 0,
                endRadius: 360
            )

            // Deterministic star field
            StarField(count: starCount)
        }
    }
}

private struct StarField: View {
    let count: Int

    /// Deterministic positions seeded by index — no random per render.
    /// Mirrors the mock's pattern: positions = (i*47 % 90, i*79 % 100), size = 2.5 if i%3==0 else 1.5.
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let big = i % 3 == 0
                    let size: CGFloat = big ? 2.5 : 1.5
                    let opacity: Double = 0.10 + Double(i % 5) * 0.05
                    let x = CGFloat((i * 79) % 100) / 100.0 * proxy.size.width
                    let y = CGFloat((i * 47) % 90)  / 100.0 * proxy.size.height

                    Circle()
                        .fill(Color.white)
                        .frame(width: size, height: size)
                        .opacity(opacity)
                        .position(x: x, y: y)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

extension View {
    /// Overlays a dark-only aura layer (radial glows + sparse stars) behind the content.
    /// In light mode this returns the receiver unchanged.
    func darkScreenAura(glowOpacity: Double = 0.32, starCount: Int = 14) -> some View {
        modifier(DarkScreenAuraModifier(glowOpacity: glowOpacity, starCount: starCount))
    }
}

#if DEBUG
#Preview("Aura — dark") {
    Text("Aura preview")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.071, green: 0.051, blue: 0.039))
        .foregroundColor(.white)
        .darkScreenAura()
        .environmentObject(ThemeManager.darkPreview)
}
#endif
```

- [ ] **Step 2: Build**

`** BUILD SUCCEEDED **`.

- [ ] **Step 3: Verify preview**

Open `DarkScreenAura.swift` in Xcode → expand the Preview canvas → confirm peach glow top-left, lilac glow bottom-right, ~14 white dots scattered. *(If the preview environmentObject does not visibly switch the theme of the modifier — because the modifier reads `ThemeManager.shared` — temporarily set `ThemeManager.shared.selectedTheme = .nightSanctuary` in your dev simulator state to verify, then revert.)*

- [ ] **Step 4: (User-driven commit)**

```bash
git add Thaqalayn/Utilities/DarkScreenAura.swift
git commit -m "feat(theme): add darkScreenAura modifier"
```

---

## Task 8: Create `ChromeAppearance` helper for native UITabBar / UINavigationBar

**Files:**
- Create: `Thaqalayn/Utilities/ChromeAppearance.swift`

- [ ] **Step 1: Write the file**

```swift
//
//  ChromeAppearance.swift
//  Thaqalayn
//
//  Configures UIKit-bridged native chrome (UITabBar, UINavigationBar)
//  to match the active SwiftUI theme.
//

import SwiftUI
import UIKit

enum ChromeAppearance {
    @MainActor
    static func apply(for variant: ThemeVariant) {
        let isDark = variant == .nightSanctuary
        let accent = UIColor(ThemeManager.shared.accentColor)

        // --- Tab bar ---
        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()
        tab.stackedLayoutAppearance.selected.iconColor = accent
        tab.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        let inactive = isDark
            ? UIColor.white.withAlphaComponent(0.48)
            : UIColor.label.withAlphaComponent(0.6)
        tab.stackedLayoutAppearance.normal.iconColor = inactive
        tab.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactive]

        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        // --- Navigation bar ---
        let nav = UINavigationBarAppearance()
        nav.configureWithDefaultBackground()
        let titleColor = isDark ? UIColor.white : UIColor.label
        nav.titleTextAttributes = [.foregroundColor: titleColor]
        nav.largeTitleTextAttributes = [.foregroundColor: titleColor]

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = accent
    }
}
```

- [ ] **Step 2: Build**

`** BUILD SUCCEEDED **`.

- [ ] **Step 3: (User-driven commit)**

```bash
git add Thaqalayn/Utilities/ChromeAppearance.swift
git commit -m "feat(theme): add ChromeAppearance helper for UITabBar/UINavigationBar"
```

---

## Task 9: Wire ChromeAppearance + tint into the app root

**Files:**
- Modify: `Thaqalayn/ThaqalaynApp.swift`
- Modify: `Thaqalayn/ContentView.swift`

- [ ] **Step 1: Update `ThaqalaynApp.init` to apply chrome at launch**

In `ThaqalaynApp.swift`, modify `init()` to call `ChromeAppearance.apply` after the existing notification delegate setup:

```swift
init() {
    UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    ChromeAppearance.apply(for: ThemeManager.shared.selectedTheme)
}
```

- [ ] **Step 2: Subscribe to theme change in `ContentView`**

In `Thaqalayn/ContentView.swift`, locate the `body` of `ContentView`. Add an `.onChange(of: themeManager.selectedTheme)` after the existing `.onAppear`:

```swift
.onAppear {
    checkFirstLaunch()
    ratingManager.recordAppLaunch()
}
.onChange(of: themeManager.selectedTheme) { _, newValue in
    ChromeAppearance.apply(for: newValue)
}
```

Also ensure the existing `.preferredColorScheme(themeManager.colorScheme)` line is present (it is) — no edit needed; `colorScheme` now correctly returns `.dark` for night sanctuary.

- [ ] **Step 3: Set explicit tint on `ContentView` root**

Just above the `.onAppear` add:

```swift
.tint(themeManager.accentColor)
```

This guards against any place that uses default `.tint` falling back to the static `AccentColor` asset (R2 in the spec).

- [ ] **Step 4: Build & smoke-test**

Build. Expected `** BUILD SUCCEEDED **`. Launch app in Simulator. Light theme should look identical. Tab bar items: selected uses peaceful purple as before (`accentColor` for warmInviting is unchanged). No visible regression.

- [ ] **Step 5: (User-driven commit)**

```bash
git add Thaqalayn/ThaqalaynApp.swift Thaqalayn/ContentView.swift
git commit -m "feat(theme): wire ChromeAppearance + .tint at app root"
```

---

## Task 10: Add Appearance section to SettingsView

**Files:**
- Modify: `Thaqalayn/Views/SettingsView.swift`

- [ ] **Step 1: Locate the `ScrollView { VStack(spacing: 24) { … } }` in `SettingsView.body`**

The first child today is the "Daily Verse" section. Insert a new "Appearance" section as the *first* child:

```swift
SettingsSection(title: "Appearance") {
    HStack(spacing: 12) {
        Image(systemName: "moon.stars.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(themeManager.accentColor)
            .frame(width: 28)

        VStack(alignment: .leading, spacing: 2) {
            Text("Theme")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            Text("Light or Dark")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }

        Spacer()

        Picker("Theme", selection: Binding(
            get: { themeManager.selectedTheme },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.25)) {
                    themeManager.selectedTheme = newValue
                }
            }
        )) {
            Text("Light").tag(ThemeVariant.warmInviting)
            Text("Dark").tag(ThemeVariant.nightSanctuary)
        }
        .pickerStyle(.segmented)
        .frame(width: 150)
    }
    .padding(16)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(themeManager.glassEffect)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.strokeColor, lineWidth: 1)
            )
    )
}
```

> **NOTE:** if `SettingsSection` is defined in the same file and accepts a different signature, adapt the closure shape to match its existing call sites (look for other `SettingsSection(title: …) { … }` calls in the file as templates).

- [ ] **Step 2: Build**

`** BUILD SUCCEEDED **`.

- [ ] **Step 3: Manual verification**

Run app in Simulator. Open Settings (via Profile menu → Settings). Verify "Appearance" section appears at top with a Light/Dark segmented picker. Tap Dark — observe the entire app cross-fade: warm-black background, peach accent, white text. Tap Light — observe instant return to current visuals. Force-quit app, relaunch — verify the last selection is restored from `UserDefaults`.

> ⚠️ At this point, dark mode will look "mostly correct" globally because the `ThemeManager` accessors flip, but several screens have hardcoded colors that won't flip yet — those are addressed in Tasks 11–22. Don't be alarmed by some screens still appearing too light/wrong in dark; it's the audit that fixes them.

- [ ] **Step 4: (User-driven commit)**

```bash
git add Thaqalayn/Views/SettingsView.swift
git commit -m "feat(settings): add Appearance Light/Dark picker"
```

---

## Task 11: Refactor `WarmThemeModifiers.swift` for theme-awareness

**Files:**
- Modify: `Thaqalayn/Utilities/WarmThemeModifiers.swift`

The current modifiers hardcode `Color.white` cards and orange shadows. We make each one read from `ThemeManager.shared`.

- [ ] **Step 1: Update `warmCardStyle`**

Replace:

```swift
func warmCardStyle(cornerRadius: CGFloat = 20) -> some View {
    self
        .background(Color.white)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
}
```

with:

```swift
func warmCardStyle(cornerRadius: CGFloat = 20) -> some View {
    modifier(WarmCardStyleModifier(cornerRadius: cornerRadius))
}
```

Then add at the bottom of the file:

```swift
private struct WarmCardStyleModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let cardFill: Color = themeManager.selectedTheme == .nightSanctuary
            ? themeManager.glassSurface
            : Color.white
        let shadowColor: Color = themeManager.selectedTheme == .nightSanctuary
            ? Color.black.opacity(0.45)
            : Color.black.opacity(0.04)

        return content
            .background(cardFill)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(themeManager.strokeColor, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: 12, x: 0, y: 4)
    }
}
```

- [ ] **Step 2: Update `warmButtonStyle`**

Replace with:

```swift
func warmButtonStyle(gradient: LinearGradient) -> some View {
    modifier(WarmButtonStyleModifier(gradient: gradient))
}
```

Add:

```swift
private struct WarmButtonStyleModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    let gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .background(gradient)
            .cornerRadius(24)
            .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
```

- [ ] **Step 3: Update `warmCircularBadge`**

Replace:

```swift
func warmCircularBadge(size: CGFloat = 56, gradient: LinearGradient) -> some View {
    modifier(WarmCircularBadgeModifier(size: size, gradient: gradient))
}
```

Add:

```swift
private struct WarmCircularBadgeModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    let size: CGFloat
    let gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(gradient)
                    .shadow(color: themeManager.accentColor.opacity(0.4), radius: 8)
            )
    }
}
```

- [ ] **Step 4: Update `warmStatCardStyle`**

```swift
func warmStatCardStyle() -> some View {
    modifier(WarmStatCardStyleModifier())
}
```

```swift
private struct WarmStatCardStyleModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared

    func body(content: Content) -> some View {
        let cardFill: Color = themeManager.selectedTheme == .nightSanctuary
            ? themeManager.glassSurface
            : Color.white
        let shadowColor = themeManager.selectedTheme == .nightSanctuary
            ? Color.black.opacity(0.45)
            : Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.15)

        return content
            .background(cardFill)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(themeManager.strokeColor, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: 12, x: 0, y: 4)
    }
}
```

- [ ] **Step 5: Build & smoke-test light**

Build. Launch in Simulator with Light theme — visual diff vs. previous build should be **zero** (cards still white, shadows still soft). The dark variants only kick in when the theme is dark.

- [ ] **Step 6: (User-driven commit)**

```bash
git add Thaqalayn/Utilities/WarmThemeModifiers.swift
git commit -m "refactor(theme): make WarmThemeModifiers theme-aware"
```

---

## Task 12: Refactor `ContentView.swift` — `AdaptiveModernBackground`, hardcoded colors

The largest single concentration of hardcoded colors lives in `ContentView.swift` (LoadingView, ErrorView, ProfileMenuView, ProfileMenuItem, AudioSettingsView, ProfileAvatar, BookmarkBadge, AuthenticationStatusButton, SyncStatusToast, ModernSurahCard, StatCard).

**Files:**
- Modify: `Thaqalayn/ContentView.swift`

- [ ] **Step 1: Drive `AdaptiveModernBackground` from ThemeManager**

Replace the body of `AdaptiveModernBackground` with:

```swift
var body: some View {
    ZStack {
        LinearGradient(
            colors: [
                themeManager.primaryBackground,
                themeManager.secondaryBackground,
                themeManager.tertiaryBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        RadialGradient(
            colors: [themeManager.floatingOrbColors[0], .clear],
            center: .topLeading,
            startRadius: 0,
            endRadius: 300
        )

        RadialGradient(
            colors: [themeManager.floatingOrbColors[1], .clear],
            center: .bottomTrailing,
            startRadius: 0,
            endRadius: 300
        )

        RadialGradient(
            colors: [themeManager.floatingOrbColors[2], .clear],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )
    }
    .ignoresSafeArea()
    .darkScreenAura()
}
```

- [ ] **Step 2: Replace hardcoded blue/red/orange in `LoadingView`**

In `LoadingView.body`, replace:
- `Color(red: 0.39, green: 0.4, blue: 0.95)` (used in shadow + ProgressView tint) → `themeManager.semanticBlue`
- Keep the `ثقلين` text shadow but route the color through `themeManager.semanticBlue.opacity(0.5)`.

- [ ] **Step 3: Replace hardcoded red in `ErrorView`**

`Color(red: 0.93, green: 0.28, blue: 0.6)` → `themeManager.semanticRed` (both icon foreground and shadow).

- [ ] **Step 4: Replace hardcoded blue in `ProfileMenuView`, `ProfileMenuItem`, `AudioSettingsView`, `AudioSettingCard`**

Throughout these structs, replace `Color(red: 0.39, green: 0.4, blue: 0.95)` with `themeManager.semanticBlue`.

- [ ] **Step 5: Replace `Color.white` card fills + `Color.black` shadows**

In `ModernSurahCard.body` and `StatCard.body`, replace the `RoundedRectangle.fill(Color(red: 1.0, green: 1.0, blue: 1.0).opacity(1.0))` plus `.shadow(color: Color.black.opacity(0.04), …)` with the theme-aware combo:

```swift
.background {
    RoundedRectangle(cornerRadius: 20)
        .fill(themeManager.selectedTheme == .nightSanctuary
              ? themeManager.glassSurface
              : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(themeManager.strokeColor, lineWidth: 1)
        )
        .shadow(
            color: themeManager.selectedTheme == .nightSanctuary
                ? Color.black.opacity(0.45)
                : Color.black.opacity(0.04),
            radius: 12, x: 0, y: 4
        )
}
```

- [ ] **Step 6: Replace `BookmarkBadge` hardcoded peach/white**

```swift
HStack(spacing: 6) {
    Text("❤️").font(.system(size: 20))
    Text("\(bookmarkManager.bookmarks.count)")
        .font(.system(size: 18, weight: .bold))
        .foregroundColor(themeManager.accentColor)
}
.padding(.horizontal, 16)
.padding(.vertical, 10)
.background {
    RoundedRectangle(cornerRadius: 24)
        .fill(themeManager.selectedTheme == .nightSanctuary
              ? themeManager.glassSurface
              : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(themeManager.strokeColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(themeManager.selectedTheme == .nightSanctuary ? 0.4 : 0.06),
                radius: 8, x: 0, y: 2)
}
```

- [ ] **Step 7: Replace `SurahListView` search-bar background**

Replace the `RoundedRectangle.fill(Color(red: 1.0, green: 1.0, blue: 1.0).opacity(1.0))` with the same theme-aware fill+stroke pattern.

- [ ] **Step 8: Replace `SyncStatusToast` background**

Replace the `.fill(Color.black.opacity(0.3))` overlay with `.fill(themeManager.primaryText.opacity(0.85))` (so text-on-toast contrast holds in light *and* dark).

- [ ] **Step 9: Build & smoke-test both modes**

Build. In Simulator: switch to Dark via Settings → walk Home → Profile Menu → Settings. Verify backgrounds, accent (peach), text colors look right. Switch to Light → confirm zero regression.

- [ ] **Step 10: (User-driven commit)**

```bash
git add Thaqalayn/ContentView.swift
git commit -m "refactor(theme): route ContentView colors through ThemeManager"
```

---

## Task 13: Apply aura + audit colors in Tab screens

**Files:**
- Modify: `Thaqalayn/Views/Tabs/HomeTab.swift`
- Modify: `Thaqalayn/Views/Tabs/TodayTab.swift`
- Modify: `Thaqalayn/Views/Tabs/ExploreTab.swift`
- Modify: `Thaqalayn/Views/Tabs/ProgressTab.swift`
- Modify: `Thaqalayn/Views/HomeView.swift`
- Modify: `Thaqalayn/Views/ExploreView.swift`
- Modify: `Thaqalayn/Views/TodayView.swift`
- Modify: `Thaqalayn/Views/ProgressRingsView.swift`

For each tab:

- [ ] **Step 1: HomeTab**

Open `Tabs/HomeTab.swift`. At the outermost view in `body`, append `.darkScreenAura()`. Then read the file end-to-end and replace any `Color(red: …)`, `Color.white`, `Color.black` literals with the appropriate `themeManager.*` token (cross-reference `dark/verification/audit.md`).

- [ ] **Step 2: TodayTab**

Open `Tabs/TodayTab.swift`. Append `.darkScreenAura(glowOpacity: 0.36, starCount: 14)` at the outermost level. Audit hardcoded colors. The Today tab has multiple cards (daily reminder, continue reading, du'a-of-the-day) — each needs its card fill / stroke / shadow routed through the same theme-aware pattern used in `ModernSurahCard` (Task 12 Step 5).

- [ ] **Step 3: ExploreTab + ExploreView**

Append `.darkScreenAura()` at the outermost level of `ExploreTab`. Audit `ExploreView.swift` (the actual list content). Look out for tile background fills and tile border color values.

- [ ] **Step 4: ProgressTab + ProgressRingsView**

Append `.darkScreenAura(glowOpacity: 0.22, starCount: 14)`. In `ProgressRingsView.swift`, the activity rings use four colors — replace any hardcoded `red/green/blue/yellow` with `themeManager.semanticRed/Green/Blue/Yellow`. The mock applies `drop-shadow(0 0 8px ${color}88)` to each ring; replicate via `.shadow(color: ringColor.opacity(0.5), radius: 8)` only when dark (gate the modifier with `if themeManager.isDarkMode`).

- [ ] **Step 5: HomeView**

`HomeView.swift` is the surah list shell. Audit hardcoded colors; ensure search field / cards / Q&A surfaces all route through the theme.

- [ ] **Step 6: TodayView**

`TodayView.swift` is the legacy Today screen wrapped by `TodayTab`. Audit hardcoded colors there too if `TodayTab` delegates to it; otherwise leave it (only modify if it's a live code path).

- [ ] **Step 7: Build, light + dark walk**

Build. Switch to Dark, walk all 4 tabs — verify warm-black backgrounds + peach glow + sparse stars + glass cards. Switch to Light — verify zero regression.

- [ ] **Step 8: (User-driven commit)**

```bash
git add Thaqalayn/Views/Tabs/ Thaqalayn/Views/HomeView.swift \
        Thaqalayn/Views/ExploreView.swift Thaqalayn/Views/TodayView.swift \
        Thaqalayn/Views/ProgressRingsView.swift
git commit -m "feat(dark): tab screens — aura + theme-routed colors"
```

---

## Task 14: Quran reading flow

**Files:**
- Modify: `Thaqalayn/Views/SurahDetailView.swift`
- Modify: `Thaqalayn/Views/AhlulbaytQuranView.swift`
- Modify: `Thaqalayn/Views/AhlulbaytEntryDetailView.swift`
- Modify: `Thaqalayn/Views/FullScreenCommentaryView.swift`
- Modify: `Thaqalayn/Views/QuickOverviewView.swift`
- Modify: `Thaqalayn/Views/TafsirSourcesView.swift`
- Modify: `Thaqalayn/Views/VerseSummaryView.swift`
- Modify: `Thaqalayn/Views/SurahAudioPlayerView.swift`
- Modify: `Thaqalayn/Views/HighlightedText.swift`

- [ ] **Step 1: SurahDetailView**

Append `.darkScreenAura(glowOpacity: 0.22, starCount: 10)` at outermost view. Audit hardcoded colors.

For the active verse card (the "Now Reading" treatment in the mock with peach gradient overlay), gate the dark-only border + linear gradient via `if themeManager.isDarkMode { … } else { … }` — keep the existing light treatment intact.

For Arabic hero text on dark, add a peach text-shadow:
```swift
.shadow(color: themeManager.isDarkMode ? themeManager.accentColor.opacity(0.32) : .clear, radius: 16)
```

- [ ] **Step 2: SurahAudioPlayerView**

Append `.darkScreenAura()` at outermost. Audit scrubber track color, time labels, play/pause icon — all route through `themeManager.*`.

- [ ] **Step 3: AhlulbaytQuranView + AhlulbaytEntryDetailView**

Append aura. Audit colors.

- [ ] **Step 4: FullScreenCommentaryView**

Append aura. The full-screen Arabic display benefits from `glowOpacity: 0.36` (similar treatment to Today). Audit text colors.

- [ ] **Step 5: QuickOverviewView, TafsirSourcesView, VerseSummaryView**

Append aura with defaults. Audit colors (these are likely simpler — list/card layouts).

- [ ] **Step 6: HighlightedText**

This file controls search-result highlighting. Replace the hardcoded yellow background with `themeManager.semanticYellow.opacity(themeManager.isDarkMode ? 0.30 : 0.50)` so the highlight remains readable on dark glass.

- [ ] **Step 7: Build, walk**

Build. Open a surah, scrub through the audio player, open commentary full-screen, view tafsir sources — in both modes. Visual sanity check.

- [ ] **Step 8: (User-driven commit)**

```bash
git add Thaqalayn/Views/SurahDetailView.swift \
        Thaqalayn/Views/AhlulbaytQuranView.swift \
        Thaqalayn/Views/AhlulbaytEntryDetailView.swift \
        Thaqalayn/Views/FullScreenCommentaryView.swift \
        Thaqalayn/Views/QuickOverviewView.swift \
        Thaqalayn/Views/TafsirSourcesView.swift \
        Thaqalayn/Views/VerseSummaryView.swift \
        Thaqalayn/Views/SurahAudioPlayerView.swift \
        Thaqalayn/Views/HighlightedText.swift
git commit -m "feat(dark): Quran reading flow — aura + theme-routed colors"
```

---

## Task 15: Du'as flow

**Files:**
- Modify: `Thaqalayn/Views/DuasView.swift`
- Modify: `Thaqalayn/Views/DuaDetailView.swift`

- [ ] **Step 1: DuasView**

Append `.darkScreenAura()` at outermost view. Audit hardcoded colors.

- [ ] **Step 2: DuaDetailView**

Append `.darkScreenAura()`. Apply Arabic hero peach shadow as in Task 14 Step 1 if there's a hero Arabic block.

- [ ] **Step 3: Build, walk both modes**

- [ ] **Step 4: (User-driven commit)**

```bash
git add Thaqalayn/Views/DuasView.swift Thaqalayn/Views/DuaDetailView.swift
git commit -m "feat(dark): Du'as flow"
```

---

## Task 16: Discovery flows (Questions, Stories, Life Moments, Prophetic Parallels, Fasting Verses)

**Files:**
- Modify: `Thaqalayn/Views/QuestionsView.swift`
- Modify: `Thaqalayn/Views/QuestionDetailView.swift`
- Modify: `Thaqalayn/Views/PropheticStoriesView.swift`
- Modify: `Thaqalayn/Views/StoryDetailView.swift`
- Modify: `Thaqalayn/Views/LifeMomentsView.swift`
- Modify: `Thaqalayn/Views/PropheticParallelsView.swift`
- Modify: `Thaqalayn/Views/ParallelDetailView.swift`
- Modify: `Thaqalayn/Views/FastingVersesView.swift`
- Modify: `Thaqalayn/Views/FastingCategoryDetailView.swift`

- [ ] **Step 1: For each file, append `.darkScreenAura()` at the outermost view**

Use defaults `(0.32, 14)` unless the screen is hero-style (e.g. detail views with large illustration), in which case use `(0.36, 14)`.

- [ ] **Step 2: Audit each file for hardcoded colors**

Cross-reference `dark/verification/audit.md`. Replace each hit with the appropriate `themeManager.*` token. Pay attention to:
- Card fills → `glassSurface` in dark, `Color.white` in light (use the pattern from Task 12 Step 5)
- Tile color tints (the explore tile colors come from the mock's `D.green/red/blue/yellow/lilac`) → route through the new `semantic*` tokens

- [ ] **Step 3: Build, walk both modes**

- [ ] **Step 4: (User-driven commit)**

```bash
git add Thaqalayn/Views/QuestionsView.swift \
        Thaqalayn/Views/QuestionDetailView.swift \
        Thaqalayn/Views/PropheticStoriesView.swift \
        Thaqalayn/Views/StoryDetailView.swift \
        Thaqalayn/Views/LifeMomentsView.swift \
        Thaqalayn/Views/PropheticParallelsView.swift \
        Thaqalayn/Views/ParallelDetailView.swift \
        Thaqalayn/Views/FastingVersesView.swift \
        Thaqalayn/Views/FastingCategoryDetailView.swift
git commit -m "feat(dark): discovery flows"
```

---

## Task 17: Ramadan flow

**Files:**
- Modify: `Thaqalayn/Views/RamadanJourneyView.swift`
- Modify: `Thaqalayn/Views/RamadanDayDetailView.swift`

- [ ] **Step 1: Append `.darkScreenAura()` at outermost**
- [ ] **Step 2: Audit hardcoded colors**
- [ ] **Step 3: Build, walk both modes**
- [ ] **Step 4: (User-driven commit)**

```bash
git add Thaqalayn/Views/RamadanJourneyView.swift Thaqalayn/Views/RamadanDayDetailView.swift
git commit -m "feat(dark): Ramadan flow"
```

---

## Task 18: Quiz flow

**Files:**
- Modify: `Thaqalayn/Views/QuizView.swift`
- Modify: `Thaqalayn/Views/QuizResultsView.swift`

- [ ] **Step 1: Append `.darkScreenAura()` at outermost**

- [ ] **Step 2: Replace correct/incorrect colors**

In `QuizView`, replace any hardcoded `Color.green` / `Color.red` for answer feedback with `themeManager.semanticGreen` / `themeManager.semanticRed`. Verify that `glassSurface`-tinted answer cards still read clearly against the warm-black background.

- [ ] **Step 3: QuizResultsView**

Audit the score circle / progress visuals. Score badge colors → `semantic*` tokens.

- [ ] **Step 4: Build, walk both modes**

- [ ] **Step 5: (User-driven commit)**

```bash
git add Thaqalayn/Views/QuizView.swift Thaqalayn/Views/QuizResultsView.swift
git commit -m "feat(dark): Quiz flow"
```

---

## Task 19: Auth, Account, Notifications, Bookmarks

**Files:**
- Modify: `Thaqalayn/Views/AuthenticationView.swift`
- Modify: `Thaqalayn/Views/AccountDeletionView.swift`
- Modify: `Thaqalayn/Views/NotificationsView.swift`
- Modify: `Thaqalayn/Views/BookmarksView.swift`

- [ ] **Step 1: AuthenticationView**

Append `.darkScreenAura(starCount: 0)` (forms shouldn't have visual chatter per spec). Audit colors. Buttons / text fields / OAuth buttons all route through theme tokens.

- [ ] **Step 2: AccountDeletionView**

Append `.darkScreenAura(starCount: 0)`. Audit. Destructive button color uses `themeManager.semanticRed`.

- [ ] **Step 3: NotificationsView**

Append `.darkScreenAura()`. Notification rows use `glassSurface` cards.

- [ ] **Step 4: BookmarksView**

Append `.darkScreenAura()`. Bookmark cards (likely similar to surah cards) use the theme-aware fill+stroke pattern.

- [ ] **Step 5: Build, walk both modes**

- [ ] **Step 6: (User-driven commit)**

```bash
git add Thaqalayn/Views/AuthenticationView.swift \
        Thaqalayn/Views/AccountDeletionView.swift \
        Thaqalayn/Views/NotificationsView.swift \
        Thaqalayn/Views/BookmarksView.swift
git commit -m "feat(dark): auth/account/notifications/bookmarks"
```

---

## Task 20: Paywall, PremiumBadge, Settings (full screen aura)

**Files:**
- Modify: `Thaqalayn/Views/PaywallView.swift`
- Modify: `Thaqalayn/Views/PremiumBadgeView.swift`
- Modify: `Thaqalayn/Views/SettingsView.swift`

- [ ] **Step 1: PaywallView**

Append `.darkScreenAura(glowOpacity: 0.40, starCount: 18)` (hero feel per spec). Audit colors. Pricing CTAs use `accentGradient`. "Most Popular" badge uses `semanticYellow`. Strike-through pricing uses `tertiaryText`.

- [ ] **Step 2: PremiumBadgeView**

Audit gold accents. Replace any hardcoded yellow with `themeManager.semanticYellow`.

- [ ] **Step 3: SettingsView (top-level aura)**

Append `.darkScreenAura()` at the outermost ZStack. Audit any remaining hardcoded colors in row icons / dividers / destructive buttons.

- [ ] **Step 4: Build, walk both modes**

Pay extra attention to PaywallView — high-contrast pricing should remain legible.

- [ ] **Step 5: (User-driven commit)**

```bash
git add Thaqalayn/Views/PaywallView.swift \
        Thaqalayn/Views/PremiumBadgeView.swift \
        Thaqalayn/Views/SettingsView.swift
git commit -m "feat(dark): paywall/premium/settings full-screen aura"
```

---

## Task 21: Onboarding flow

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift`
- Modify: `Thaqalayn/Views/Onboarding/MissionScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/HadithScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/QuickGemsScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift`
- Modify: `Thaqalayn/Views/Onboarding/FinalScreen.swift`

- [ ] **Step 1: Apply aura at the OnboardingFlowView wrapper, not each screen**

In `OnboardingFlowView.swift`, append `.darkScreenAura()` to the outermost view of the flow container so all child screens inherit it.

- [ ] **Step 2: Audit each onboarding screen for hardcoded colors**

Each screen typically has: a hero illustration / icon, a title, body copy, and a CTA. Replace hardcoded colors with `themeManager.*` tokens.

- [ ] **Step 3: Verify illustration backgrounds are transparent**

Open each onboarding screen's `Image(...)` references. If any image has a baked-in light background, flag it for redesign in a follow-up — *do not* attempt asset surgery in this plan.

- [ ] **Step 4: Build, run onboarding from start in both modes**

To force onboarding to appear: `defaults delete <BUNDLE_ID> hasShownWelcome` in Simulator, or simply tap through it.

- [ ] **Step 5: (User-driven commit)**

```bash
git add Thaqalayn/Views/Onboarding/
git commit -m "feat(dark): onboarding flow"
```

---

## Task 22: Welcome, BadgeAward, TTSVoicePicker, Components folder

**Files:**
- Modify: `Thaqalayn/Views/WelcomeView.swift`
- Modify: `Thaqalayn/Views/BadgeAwardView.swift`
- Modify: `Thaqalayn/Views/TTSVoicePickerView.swift`
- Modify: `Thaqalayn/Views/Components/AhlulbaytQuranCarouselCard.swift`
- Modify: `Thaqalayn/Views/Components/DiscoveryCarousel.swift`
- Modify: `Thaqalayn/Views/Components/DuasCarouselCard.swift`
- Modify: `Thaqalayn/Views/Components/ExploreRow.swift`
- Modify: `Thaqalayn/Views/Components/ExploreSectionHeader.swift`
- Modify: `Thaqalayn/Views/Components/IslamicGeometricPattern.swift`
- Modify: `Thaqalayn/Views/Components/LifeMomentsCarouselCard.swift`
- Modify: `Thaqalayn/Views/Components/ProgressRingView.swift`
- Modify: `Thaqalayn/Views/Components/ProgressRingsStack.swift`
- Modify: `Thaqalayn/Views/Components/PropheticStoriesCarouselCard.swift`
- Modify: `Thaqalayn/Views/Components/QuestionsCarouselCard.swift`

- [ ] **Step 1: WelcomeView, BadgeAwardView, TTSVoicePickerView**

Append `.darkScreenAura()` to each at outermost view. Audit hardcoded colors. `BadgeAwardView` particle / orb colors come from `themeManager.floatingOrbColors`.

- [ ] **Step 2: Components folder audit**

For each component:
- Replace card fills with theme-aware glass surface pattern
- Route any tile / icon tints through `themeManager.*` tokens
- `IslamicGeometricPattern.swift`: stroke color routes through `themeManager.strokeColor` (or a slightly stronger `strokeColorStrong` if the pattern needs to stay visible on dark)
- `ProgressRingView` / `ProgressRingsStack`: ring colors use `semanticGreen/Red/Blue/Yellow`; in dark, add `.shadow(color: ringColor.opacity(0.5), radius: 8)` per Task 13 Step 4

- [ ] **Step 3: Build, walk badge award + carousel cards in both modes**

Trigger a badge by completing a surah's first verse (or via existing dev shortcut, if any). Verify carousel cards on Home/Today look right.

- [ ] **Step 4: (User-driven commit)**

```bash
git add Thaqalayn/Views/WelcomeView.swift \
        Thaqalayn/Views/BadgeAwardView.swift \
        Thaqalayn/Views/TTSVoicePickerView.swift \
        Thaqalayn/Views/Components/
git commit -m "feat(dark): welcome/badge/TTS picker + components"
```

---

## Task 23: Phase D — manual dark verification pass

**Files:**
- Create (or update): `dark/verification/dark-pass.md`

This task is verification, not coding.

- [ ] **Step 1: Force dark in Settings**

Open the app, Settings → Appearance → Dark.

- [ ] **Step 2: Walk every screen and record findings**

Walk this checklist in Simulator (iPhone 15 Pro). For each, check: warm-black background, peach accent, glass cards readable, Arabic legible, no light flashes:

```
- [ ] HomeTab (surah list)
- [ ] TodayTab
- [ ] ExploreTab
- [ ] ProgressTab
- [ ] SurahDetailView (open Al-Fatiha)
- [ ] QuickOverviewView
- [ ] FullScreenCommentaryView
- [ ] TafsirSourcesView
- [ ] VerseSummaryView
- [ ] SurahAudioPlayerView (start playback)
- [ ] AhlulbaytQuranView
- [ ] AhlulbaytEntryDetailView
- [ ] DuasView
- [ ] DuaDetailView
- [ ] QuestionsView
- [ ] QuestionDetailView
- [ ] PropheticStoriesView
- [ ] StoryDetailView
- [ ] LifeMomentsView
- [ ] PropheticParallelsView
- [ ] ParallelDetailView
- [ ] FastingVersesView
- [ ] FastingCategoryDetailView
- [ ] RamadanJourneyView (only visible in Ramadan season — temporarily force on if needed)
- [ ] RamadanDayDetailView
- [ ] QuizView (start a quiz)
- [ ] QuizResultsView (finish a quiz)
- [ ] BookmarksView
- [ ] NotificationsView
- [ ] AuthenticationView (sign out to see)
- [ ] AccountDeletionView
- [ ] PaywallView
- [ ] SettingsView
- [ ] WelcomeView
- [ ] OnboardingFlowView (reset hasShownWelcome to retrigger)
- [ ] BadgeAwardView (complete a verse to trigger)
- [ ] TTSVoicePickerView (Settings → TTS voice)
- [ ] ProfileMenuView (sheet from avatar)
- [ ] AudioSettingsView
- [ ] System sheets (Picker, Toggle in Settings)
- [ ] System alerts (Sign Out confirmation)
```

- [ ] **Step 3: Record any issues in `dark/verification/dark-pass.md`**

For each screen, write `OK` or a short bug note (e.g. `BookmarksView: empty-state illustration is too dark — needs lighter tint`).

- [ ] **Step 4: Fix any P0 issues inline**

If a screen is broken in a way users would notice, patch it in the appropriate file from Tasks 12–22.

- [ ] **Step 5: (User-driven commit)**

```bash
git add dark/verification/dark-pass.md
git commit -m "docs(dark): Phase D verification log"
```

---

## Task 24: Phase E — light regression check

**Files:**
- Create (or update): `dark/verification/light-pass.md`

- [ ] **Step 1: Switch to Light**

Settings → Appearance → Light. Force-relaunch the app.

- [ ] **Step 2: Walk the same screen list as Task 23**

For each screen, compare visually against the *current production build* (or the prior commit before this branch). Flag any visual shift in light mode.

- [ ] **Step 3: For any flagged shifts, audit the offending file**

Most likely cause: a `switch selectedTheme` branch in `ThemeManager.swift` or `WarmThemeModifiers.swift` is returning the wrong value for `.warmInviting`. Fix by restoring today's exact value.

- [ ] **Step 4: Record findings in `dark/verification/light-pass.md`**

```
- [ ] HomeTab — OK
- [ ] TodayTab — OK
- [ ] …
```

- [ ] **Step 5: (User-driven commit)**

```bash
git add dark/verification/light-pass.md
git commit -m "docs(dark): Phase E light regression log"
```

---

## Task 25: Wrap-up — final pass and changelog

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-dark-theme-design.md` (add "Implementation status: complete" line at top)
- Create (or append): `dark/verification/known-issues.md`

- [ ] **Step 1: Read the spec sections "Edge cases" and "Risks & open questions"**

Confirm each is either implemented, accepted as known cosmetic (LaunchScreen flash), or documented in `dark/verification/known-issues.md` with rationale.

- [ ] **Step 2: Update the spec front-matter to status complete**

Add a line under "Status:" at the top:

```markdown
**Status:** Implemented 2026-05-09 — see `dark/verification/dark-pass.md` and `dark/verification/light-pass.md`.
```

- [ ] **Step 3: Final clean build**

```bash
xcodebuild -project /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn.xcodeproj \
  -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6' \
  -configuration Release clean build 2>&1 | tail -40
```

Expected: `** BUILD SUCCEEDED **` on a clean Release build.

- [ ] **Step 4: (User-driven commit — wrap-up)**

```bash
git add docs/superpowers/specs/2026-05-09-dark-theme-design.md \
        dark/verification/known-issues.md
git commit -m "feat(dark): theme implementation complete"
```

---

## Spec coverage checklist

Self-review map of spec requirements → tasks that implement them:

| Spec section | Implemented in |
|---|---|
| `ThemeManager` evolution — new `.nightSanctuary` case + display strings | Task 2 |
| Persistence (UserDefaults `selectedTheme` key) | Task 3 |
| `swiftUIColorScheme` + reactivated `isDarkMode` | Task 3 |
| Conditional accessors (backgrounds, text, accent, stroke) | Task 4 |
| New tokens (gradients, materials, orbs, semantic colors, glass surfaces) | Task 5 |
| Preview helpers `lightPreview` / `darkPreview` | Task 6 |
| `darkScreenAura()` modifier with stars + radial glows | Task 7 |
| Native chrome (UITabBar / UINavigationBar) | Tasks 8, 9 |
| Forced `.preferredColorScheme` at app root | Task 9 (already present, validated) |
| Explicit `.tint` at root (R2 mitigation) | Task 9 |
| Settings UI — segmented Light/Dark picker | Task 10 |
| `WarmThemeModifiers.swift` theme-awareness | Task 11 |
| `ContentView.swift` audit (LoadingView, ErrorView, ProfileMenu, etc.) | Task 12 |
| Tab screens aura + audit | Task 13 |
| Quran reading flow aura + audit | Task 14 |
| Du'as flow | Task 15 |
| Discovery flows (Q&A, stories, life moments, parallels, fasting) | Task 16 |
| Ramadan flow | Task 17 |
| Quiz flow + correct/incorrect colors | Task 18 |
| Auth/account/notifications/bookmarks | Task 19 |
| Paywall + Premium + Settings full-screen aura | Task 20 |
| Onboarding flow | Task 21 |
| Welcome / BadgeAward / TTS picker / Components | Task 22 |
| Phase D — dark verification | Task 23 |
| Phase E — light regression | Task 24 |
| Wrap-up + known issues | Task 25 |
| LaunchScreen acceptance (out of scope, documented) | Task 25 (known-issues.md) |
| Snapshot tests (out of scope) | Not implemented (per spec) |
| OS Dark Mode following (out of scope) | Not implemented (per spec) |
| Layout changes beyond styling (out of scope) | Not implemented (per spec) |
| Light theme accent change (out of scope) | Not implemented (per spec) |

All requirements mapped.
