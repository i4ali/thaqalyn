> **SUPERSEDED (2026-05-15)** by
> `docs/superpowers/specs/2026-05-15-onboarding-aesthetic-reskin-design.md`
> and `docs/superpowers/plans/2026-05-15-onboarding-aesthetic-reskin.md`.
> This document described a full rebuild; the shipped work is an
> aesthetics-only reskin preserving flow, copy/content, and all animations.

# Onboarding Redesign — Variant C Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the 10-screen Thaqalayn onboarding flow as 11 screens matching the hi-fi Variant C handoff, using a small shared component module and new pastel chip palette on `ThemeManager`.

**Architecture:** Three layers. (1) Static ChipColor + TiltStyle tokens added to `ThemeManager`. (2) Seven small reusable SwiftUI structs in a new `Views/Onboarding/Components/` folder (HeroChip, OnboardingBackground, OnboardingTitleBlock, FeatureRow, OnboardingCTA, GemPill, QuizAnswerRow). (3) Each existing onboarding screen file rebuilt in place using those primitives; one new `QuizResultScreen.swift` added; one new `BismillahScreen.swift` thin wrapper added; `DailyVerseScreen.swift` removed from the flow but left on disk with a DEPRECATED comment.

**Tech Stack:** SwiftUI · iOS 16+ · Xcode 16 synced folder groups (no `.pbxproj` edits required) · SF Symbols · system fonts (incl. system serif for Arabic).

**Spec references:**
- Design doc: `docs/plans/2026-05-15-onboarding-redesign-variant-c-design.md`
- Handoff README (pixel-exact spec): `design_handoff_onboarding_variant_c/README.md`
- Screenshots (visual targets): `design_handoff_onboarding_variant_c/screenshots/01-welcome.png` … `11-final-account.png`

**Conventions used in this plan:**
- "Build" means: `xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` (or use Xcode's ⌘B).
- "Preview" means: open the file in Xcode, the canvas auto-resumes; verify the `#Preview` block renders as expected.
- **Commits are checkpoints, not auto-executed.** User commits themselves; the plan flags good commit points but never runs `git commit`.

---

## Phase 1 — ThemeManager foundation

### Task 1: Add `ChipColor` struct + chip palette tokens

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift` (append at end of class, before closing brace at line ~347)

**Step 1: Add the new block**

Append inside the `ThemeManager` class, just before the `#if DEBUG` preview-helpers block:

```swift
    // MARK: - Onboarding (Variant C) — chip palette

    /// Pastel chip (background fill, foreground icon-tint) pair used by the
    /// Variant C onboarding screens. Names use intent, not appearance.
    /// chipBrand → peach. chipKnowledge → plum. chipProgress → mint.
    /// chipFoundation → sky. chipFeatured → butter. chipComparative → mauve.
    /// chipWarmth → rose.
    struct ChipColor: Equatable {
        let bg: Color
        let fg: Color
    }

    private static func hex(_ value: UInt32) -> Color {
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >>  8) & 0xFF) / 255.0
        let b = Double( value        & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }

    static let chipBrand       = ChipColor(bg: hex(0xFCE0CC), fg: hex(0xC66829))
    static let chipKnowledge   = ChipColor(bg: hex(0xEAD8F0), fg: hex(0x8C539F))
    static let chipProgress    = ChipColor(bg: hex(0xD6EADF), fg: hex(0x3B8459))
    static let chipFoundation  = ChipColor(bg: hex(0xD8E8F4), fg: hex(0x3D78B2))
    static let chipFeatured    = ChipColor(bg: hex(0xF8EAC9), fg: hex(0xB5862A))
    static let chipComparative = ChipColor(bg: hex(0xE6DDE9), fg: hex(0x7B6688))
    static let chipWarmth      = ChipColor(bg: hex(0xF4D8D8), fg: hex(0xC25656))
```

**Step 2: Build to confirm**

Run build. Expected: success, no warnings.

**Step 3 (checkpoint):** Good commit point: `feat(onboarding): add ChipColor palette tokens to ThemeManager`

---

### Task 2: Add `TiltStyle` enum + `tiltGradient()` helper

**Files:**
- Modify: `Thaqalayn/Services/ThemeManager.swift` (append immediately after the chip palette block from Task 1)

**Step 1: Append the tilt block**

```swift
    // MARK: - Onboarding (Variant C) — per-screen tilt gradients

    /// Background tilt assigned per onboarding screen to give the flow
    /// rhythm. Returns nil in dark mode — `darkScreenAura()` owns dark mood.
    enum TiltStyle { case peach, lavender, mauve, sage }

    func tiltGradient(_ style: TiltStyle) -> LinearGradient? {
        guard !isDarkMode else { return nil }
        let stops: [Color]
        switch style {
        case .peach:    stops = [Self.hex(0xF5E6E6), Self.hex(0xF8E5D2), Self.hex(0xFAF2E8)]
        case .lavender: stops = [Self.hex(0xF1E9F4), Self.hex(0xF5E8E5), Self.hex(0xFAF2E8)]
        case .mauve:    stops = [Self.hex(0xECE3F2), Self.hex(0xF2E6E8), Self.hex(0xFAF2E8)]
        case .sage:     stops = [Self.hex(0xE6EEEB), Self.hex(0xF0EBE2), Self.hex(0xFAF2E8)]
        }
        return LinearGradient(colors: stops, startPoint: .top, endPoint: .bottom)
    }

    /// Amber radial glow that sits above each tilt in light mode (skipped in dark).
    /// Use as `RadialGradient(...)` with center near top of viewport.
    var amberGlowColor: Color { isDarkMode ? .clear : Color(red: 0.910, green: 0.580, blue: 0.392).opacity(0.18) }
```

Note: the `Self.hex` reference works because `hex` was added as `private static` in Task 1 — change the `private` keyword to `fileprivate` if you hit access issues, or duplicate the helper inside this function as a local closure.

**Step 2: Build**

Expected: success.

**Step 3 (checkpoint):** Good commit point: `feat(onboarding): add TiltStyle + tiltGradient helper to ThemeManager`

---

## Phase 2 — Shared component module

Each task creates one file under `Thaqalayn/Views/Onboarding/Components/`. After each, the build must succeed and the `#Preview` must render in the Xcode canvas. Xcode 16 synced folder groups pick up new files automatically — no `.pbxproj` edits.

### Task 3: Create `HeroChip.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/HeroChip.swift`

**Step 1: Write the file**

```swift
//
//  HeroChip.swift
//  Thaqalayn
//
//  Variant C onboarding — 88×88 pastel chip with amber halo + breathing pulse.
//

import SwiftUI

struct HeroChip: View {
    let symbol: String
    let palette: ThemeManager.ChipColor
    var iconOverride: Color? = nil

    @State private var pulse = false

    var body: some View {
        ZStack {
            // Halo
            RadialGradient(
                colors: [palette.fg.opacity(0.34), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 70
            )
            .frame(width: 160, height: 160)
            .blur(radius: 10)
            .scaleEffect(pulse ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulse)

            // Chip
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(palette.bg)
                .frame(width: 88, height: 88)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundColor(iconOverride ?? palette.fg)
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { pulse = true }
        }
    }
}

#Preview {
    HeroChip(symbol: "book.closed.fill", palette: ThemeManager.chipBrand)
        .padding(40)
        .background(Color(red: 0.95, green: 0.9, blue: 0.85))
}
```

**Step 2: Build + verify Preview**

Build succeeds. Xcode canvas shows a peach chip with a glowing amber halo on a cream background.

**Step 3 (checkpoint):** Good commit point.

---

### Task 4: Create `OnboardingBackground.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/OnboardingBackground.swift`

**Step 1: Write the file**

```swift
//
//  OnboardingBackground.swift
//  Thaqalayn
//
//  Variant C onboarding — per-screen tilt gradient + amber radial glow.
//  Renders nothing extra in dark mode; darkScreenAura() handles dark mood.
//

import SwiftUI

struct OnboardingBackground: View {
    @StateObject private var themeManager = ThemeManager.shared
    let tilt: ThemeManager.TiltStyle

    var body: some View {
        ZStack {
            themeManager.primaryBackground

            if let gradient = themeManager.tiltGradient(tilt) {
                gradient
                    .ignoresSafeArea()

                // Amber radial glow centered near top
                RadialGradient(
                    colors: [themeManager.amberGlowColor, .clear],
                    center: UnitPoint(x: 0.5, y: 0.15),
                    startRadius: 0,
                    endRadius: 250
                )
                .frame(width: 500, height: 400)
                .blur(radius: 8)
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingBackground(tilt: .peach)
}
```

**Step 2: Build + Preview**

Expected: warm peach gradient with subtle amber glow near top.

**Step 3 (checkpoint):** Good commit point.

---

### Task 5: Create `OnboardingTitleBlock.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/OnboardingTitleBlock.swift`

**Step 1: Write the file**

```swift
//
//  OnboardingTitleBlock.swift
//  Thaqalayn
//
//  Variant C onboarding — eyebrow + hero title + body sub. Centered.
//

import SwiftUI

struct OnboardingTitleBlock: View {
    @StateObject private var themeManager = ThemeManager.shared
    var eyebrow: String? = nil
    var eyebrowColor: Color? = nil
    let title: String
    var subtitle: String? = nil
    /// Use 34/heavy/-0.8 tracking on the Final screen ("Begin Your Journey").
    var titleScale: TitleScale = .hero

    enum TitleScale { case hero, jumbo }

    var body: some View {
        VStack(spacing: 12) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.system(size: 11.5, weight: .bold))
                    .tracking(3.4)
                    .foregroundColor(eyebrowColor ?? themeManager.secondaryText)
            }

            Text(title)
                .font(.system(size: titleScale == .hero ? 30 : 34, weight: .heavy))
                .tracking(titleScale == .hero ? -0.6 : -0.8)
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(titleScale == .hero ? 2 : 0)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14.5, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 300)
            }
        }
    }
}

#Preview {
    OnboardingTitleBlock(
        eyebrow: "The two weighty things",
        eyebrowColor: ThemeManager.chipBrand.fg,
        title: "Welcome to Thaqalayn",
        subtitle: "The Quran and the wisdom of the Ahlul Bayt, made for everyday companionship."
    )
    .padding()
}
```

**Step 2: Build + Preview** — verify typography matches spec (`.system(size: 30, weight: .heavy)`).

**Step 3 (checkpoint):** Good commit point.

---

### Task 6: Create `FeatureRow.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/FeatureRow.swift`

**Step 1: Write the file**

```swift
//
//  FeatureRow.swift
//  Thaqalayn
//
//  Variant C onboarding — white card row with pastel chip on the left.
//  Replaces the existing peach-gradient HighlightRow for onboarding use.
//

import SwiftUI

struct FeatureRow: View {
    @StateObject private var themeManager = ThemeManager.shared
    let chip: ThemeManager.ChipColor
    let symbol: String
    let title: String
    let subtitle: String
    var trailingChevron: Bool = false
    /// 42×42 default (Mission/FiveLayers), 48×48 used on Stay Motivated.
    var chipSize: CGFloat = 42
    var iconSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: chipSize >= 48 ? 14 : 12, style: .continuous)
                .fill(chip.bg)
                .frame(width: chipSize, height: chipSize)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundColor(chip.fg)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .tracking(-0.2)
                    .foregroundColor(themeManager.primaryText)
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            if trailingChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color(red: 0.235, green: 0.157, blue: 0.078).opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 10) {
        FeatureRow(chip: ThemeManager.chipBrand, symbol: "book.closed.fill", title: "Complete Quranic text", subtitle: "with English & Urdu translation")
        FeatureRow(chip: ThemeManager.chipKnowledge, symbol: "sparkles", title: "5 layers of commentary", subtitle: "authentic Shia scholarship")
        FeatureRow(chip: ThemeManager.chipFoundation, symbol: "square.stack.3d.up.fill", title: "Foundation", subtitle: "Simple explanations & history", trailingChevron: true)
    }
    .padding()
    .background(Color(red: 0.95, green: 0.9, blue: 0.85))
}
```

**Step 2: Build + Preview** — three rows render with correct chip colors, bold titles, secondary subs, and chevron on row 3.

**Step 3 (checkpoint):** Good commit point.

---

### Task 7: Create `OnboardingCTA.swift` (3 variants)

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/OnboardingCTA.swift`

**Step 1: Write the file**

```swift
//
//  OnboardingCTA.swift
//  Thaqalayn
//
//  Variant C onboarding — primary (peach gradient) / secondary (white) / ghost CTA.
//

import SwiftUI

struct OnboardingCTA: View {
    @StateObject private var themeManager = ThemeManager.shared

    enum Style { case primary, secondary, ghost }

    let style: Style
    var symbol: String? = nil
    let label: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(background)
            .foregroundColor(foreground)
            .overlay(border)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .primary:   themeManager.accentGradient
        case .secondary: Color.white
        case .ghost:     Color.clear
        }
    }

    private var foreground: Color {
        switch style {
        case .primary:   return .white
        case .secondary: return themeManager.primaryText
        case .ghost:     return themeManager.secondaryText
        }
    }

    @ViewBuilder private var border: some View {
        if style == .secondary {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0.122, green: 0.086, blue: 0.071).opacity(0.07), lineWidth: 1)
        } else if style == .primary {
            // Inset top white highlight per spec
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .padding(.bottom, 1)
                .mask(
                    LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .center)
                )
        }
    }

    private var shadowColor: Color {
        style == .primary
            ? Color(red: 0.776, green: 0.408, blue: 0.161).opacity(0.35)
            : .clear
    }
    private var shadowRadius: CGFloat { style == .primary ? 14 : 0 }
    private var shadowY: CGFloat { style == .primary ? 10 : 0 }
}

#Preview {
    VStack(spacing: 12) {
        OnboardingCTA(style: .primary, symbol: "book.closed.fill", label: "Continue as Guest", action: {})
        OnboardingCTA(style: .secondary, symbol: "person.fill.badge.plus", label: "Create Account", action: {})
        OnboardingCTA(style: .secondary, symbol: "person.fill", label: "Sign In", action: {})
        OnboardingCTA(style: .ghost, label: "Skip for now", action: {})
    }
    .padding()
    .background(Color(red: 0.97, green: 0.93, blue: 0.9))
}
```

**Step 2: Build + Preview** — primary has peach gradient + shadow + inset highlight; secondaries are white with hairline border; ghost is text only.

**Step 3 (checkpoint):** Good commit point.

---

### Task 8: Create `GemPill.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/GemPill.swift`

**Step 1: Write the file**

```swift
//
//  GemPill.swift
//  Thaqalayn
//
//  Variant C onboarding — wrap-able tag pill with pastel chip background.
//

import SwiftUI

struct GemPill: View {
    let chip: ThemeManager.ChipColor
    let symbol: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 11.5, weight: .bold))
                .tracking(0.3)
        }
        .foregroundColor(chip.fg)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(Capsule().fill(chip.bg))
    }
}

#Preview {
    HStack {
        GemPill(chip: ThemeManager.chipKnowledge, symbol: "crown.fill", label: "The Throne Verse")
        GemPill(chip: ThemeManager.chipProgress, symbol: "sparkles", label: "The Ever-Living")
        GemPill(chip: ThemeManager.chipFoundation, symbol: "globe", label: "Cosmic Owners…")
        GemPill(chip: ThemeManager.chipFeatured, symbol: "star.fill", label: "The Kursi")
    }
    .padding()
}
```

**Step 2: Build + Preview** — four pastel pills in a row.

**Step 3 (checkpoint):** Good commit point.

---

### Task 9: Create `QuizAnswerRow.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/QuizAnswerRow.swift`

**Step 1: Write the file**

```swift
//
//  QuizAnswerRow.swift
//  Thaqalayn
//
//  Variant C onboarding — quiz answer row with default/correct states.
//

import SwiftUI

struct QuizAnswerRow: View {
    @StateObject private var themeManager = ThemeManager.shared
    let letter: String   // "A", "B", "C", "D"
    let text: String
    let isCorrect: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCorrect ? ThemeManager.chipBrand.fg : Color.white)
                        .frame(width: 28, height: 28)
                    if isCorrect {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(.white)
                    } else {
                        Text(letter)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                    }
                }

                Text(text)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isCorrect ? ThemeManager.chipBrand.bg : Color(red: 0.984, green: 0.965, blue: 0.933))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isCorrect ? ThemeManager.chipBrand.fg : Color(red: 0.122, green: 0.086, blue: 0.071).opacity(0.07), lineWidth: 1.5)
            )
            .animation(.easeOut(duration: 0.25), value: isCorrect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 8) {
        QuizAnswerRow(letter: "A", text: "The physical throne of Allah", isCorrect: false, action: {})
        QuizAnswerRow(letter: "B", text: "Allah's knowledge and authority", isCorrect: true, action: {})
        QuizAnswerRow(letter: "C", text: "A specific location in Paradise", isCorrect: false, action: {})
        QuizAnswerRow(letter: "D", text: "The Day of Judgement", isCorrect: false, action: {})
    }
    .padding()
}
```

**Step 2: Build + Preview** — row B shows peach selected state; others show cream default state.

**Step 3 (checkpoint):** Good commit point. **Phase 2 complete — all 7 components built.**

---

## Phase 3 — Per-screen rebuild

Every screen task follows the same shape. Below I give the full pattern once on Task 10, then for Tasks 11–20 give only the screen-specific content (the wrapper, hero, title-block, and `.onAppear` boilerplate are identical).

### Common skeleton (used for every screen)

```swift
struct ExampleScreen: View {
    @State private var isVisible = false

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .peach)

            VStack(spacing: 28) {
                HeroChip(symbol: "...", palette: ThemeManager.chipBrand)
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                OnboardingTitleBlock(title: "...", subtitle: "...")
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                // <screen-specific cards>
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 30)
                    .animation(.easeOut(duration: 0.7).delay(0.7), value: isVisible)

                Spacer()

                // <optional CTA>
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.9), value: isVisible)
            }
            .padding(.horizontal, 22)
            .padding(.top, 80)
        }
        .onAppear { isVisible = true }
    }
}
```

---

### Task 10: Rebuild `HadithScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/HadithScreen.swift` (full rewrite)

**Step 1: Replace the file**

```swift
//
//  HadithScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 01 — Welcome (Hadith of Thaqalayn). Variant C.
//

import SwiftUI

struct HadithScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var currentPage: Int
    @State private var isVisible = false

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .peach)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Arabic logotype IS the hero
                    Text("ثقلين")
                        .font(.system(size: 96, weight: .bold))
                        .tracking(-2)
                        .foregroundColor(themeManager.primaryText)
                        .background(
                            RadialGradient(
                                colors: [ThemeManager.chipBrand.fg.opacity(0.34), .clear],
                                center: .center, startRadius: 0, endRadius: 130
                            )
                            .frame(width: 280, height: 200)
                            .blur(radius: 10)
                        )
                        .padding(.top, 30)
                        .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                    OnboardingTitleBlock(
                        eyebrow: "The two weighty things",
                        eyebrowColor: ThemeManager.chipBrand.fg,
                        title: "Welcome to Thaqalayn",
                        subtitle: "The Quran and the wisdom of the Ahlul Bayt, made for everyday companionship."
                    )
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                    // Hadith card
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(ThemeManager.chipBrand.bg)
                                .frame(width: 32, height: 32)
                                .overlay(Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(ThemeManager.chipBrand.fg))
                            Text("HADITH OF THAQALAYN")
                                .font(.system(size: 11.5, weight: .bold))
                                .tracking(2)
                                .foregroundColor(ThemeManager.chipBrand.fg)
                            Spacer()
                        }

                        Text("إنّي تاركٌ فيكم الثقلين\nكتاب الله وعترتي أهلَ بيتي")
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(themeManager.primaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)

                        Rectangle()
                            .fill(Color(red: 0.122, green: 0.086, blue: 0.071).opacity(0.07))
                            .frame(height: 1)

                        Text("\"I am leaving among you two weighty things: the Book of Allah and my progeny, the people of my household.\"")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)

                        Text("— PROPHET MUHAMMAD ﷺ")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color(red: 0.235, green: 0.157, blue: 0.078).opacity(0.06), radius: 12, x: 0, y: 8)
                    )
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 30)
                    .animation(.easeOut(duration: 0.7).delay(0.7), value: isVisible)

                    OnboardingCTA(style: .primary, symbol: nil, label: "Begin the journey →") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                            currentPage = 1
                        }
                    }
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.9), value: isVisible)

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 22)
            }
        }
        .onAppear { isVisible = true }
    }
}

#Preview {
    HadithScreen(currentPage: .constant(0))
}
```

**Note:** the old `GeometricPatternBackground` struct in this file is no longer used — leave it in place or delete it. If left, mark unused. Recommended: delete it.

**Step 2: Build + Preview**

Expected: Arabic logotype top, eyebrow + title + sub, hadith card centered, primary CTA at bottom. No tap or auto-advance behavior.

**Step 3 (checkpoint):** Good commit point.

---

### Task 11: Rebuild `MissionScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/MissionScreen.swift` (full rewrite using skeleton)

**Step 1: Apply common skeleton with these specifics:**

- `OnboardingBackground(tilt: .lavender)`
- `HeroChip(symbol: "book.closed.fill", palette: ThemeManager.chipBrand)`
- Title `"Wisdom at your fingertips"` · sub `"Everything you need to read, reflect, and grow — in one calm companion."`
- Cards block: `VStack(spacing: 10)` of 4 `FeatureRow`s:
  ```swift
  FeatureRow(chip: ThemeManager.chipBrand,      symbol: "book.closed.fill", title: "Complete Quranic text",    subtitle: "with English & Urdu translation")
  FeatureRow(chip: ThemeManager.chipKnowledge,  symbol: "sparkles",         title: "5 layers of commentary",   subtitle: "authentic Shia scholarship")
  FeatureRow(chip: ThemeManager.chipFeatured,   symbol: "bell.fill",        title: "Daily verses",             subtitle: "aligned with the Islamic calendar")
  FeatureRow(chip: ThemeManager.chipWarmth,     symbol: "heart.fill",       title: "Sync bookmarks",           subtitle: "across iPhone, iPad and the web")
  ```
- No CTA (user swipes / hits skip / uses page indicator).

**Step 2: Build + Preview.** Expected: 4 pastel rows under a lavender tilt.

**Step 3 (checkpoint):** Good commit point.

---

### Task 12: Rebuild `FiveLayersScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift`

**Specifics:**

- Tilt `.mauve` · Hero `square.stack.3d.up.fill` / chipKnowledge
- Title `"5 Layers of Wisdom"` · subtitle `"Tap each layer to explore"` (use a smaller body — 12.5pt or the default subtitle styling is fine)
- 5 `FeatureRow`s with `trailingChevron: true`:
  ```swift
  FeatureRow(chip: ThemeManager.chipFoundation, symbol: "square.stack.3d.up.fill", title: "Foundation",      subtitle: "Simple explanations & history",          trailingChevron: true)
  FeatureRow(chip: ThemeManager.chipKnowledge,  symbol: "book.closed.fill",        title: "Classical Shia",  subtitle: "Tabatabai, Tabrisi, al-Tusi",            trailingChevron: true)
  FeatureRow(chip: ThemeManager.chipProgress,   symbol: "globe",                   title: "Contemporary",    subtitle: "Modern & scientific perspectives",       trailingChevron: true)
  FeatureRow(chip: ThemeManager.chipBrand,      symbol: "star.fill",               title: "Ahlul Bayt",      subtitle: "Hadith from the 14 Infallibles",         trailingChevron: true)
  FeatureRow(chip: ThemeManager.chipComparative,symbol: "scale.3d",                title: "Comparative",     subtitle: "Balanced Shia & Sunni scholarship",      trailingChevron: true)
  ```
- VStack spacing 8.

**Build + Preview.** **Checkpoint.**

---

### Task 13: Rebuild `QuickGemsScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/QuickGemsScreen.swift`

**Specifics:**

- Tilt `.lavender` · Hero `sparkles` / chipFeatured
- Title `"Gems"` · subtitle `"Precious insights unveiled"`
- **Verse card** (inline, white, 22-radius, 20-padding):
  - Header row: `Circle()` with `LinearGradient([ThemeManager.chipKnowledge.fg, ThemeManager.chipFoundation.fg], topLeading→bottomTrailing)` 36×36, white `"255"` 12/heavy centered, then `"Al-Baqarah 255"` 16/heavy beside it.
  - Arabic fragment: `Text("ٱلْقَيُّومُ ٱلْحَىُّ لَا إِلَٰهَ إِلَّا هُوَ ٱللَّهُ").font(.system(size: 22, design: .serif, weight: .medium)).environment(\.layoutDirection, .rightToLeft).multilineTextAlignment(.trailing).lineSpacing(8)`
  - Pills wrap (use `HStack(spacing: 6)` + a second row if needed — or `WrappingHStack` if you have one; simplest: two HStacks):
    - `GemPill(chip: ThemeManager.chipKnowledge,  symbol: "crown.fill", label: "The Throne Verse")`
    - `GemPill(chip: ThemeManager.chipProgress,   symbol: "sparkles",   label: "The Ever-Living")`
    - `GemPill(chip: ThemeManager.chipFoundation, symbol: "globe",      label: "Cosmic Owners…")`
    - `GemPill(chip: ThemeManager.chipFeatured,   symbol: "star.fill",  label: "The Kursi")`
- **Insight card** below (white, 18-radius, 14-padding):
  - Small plum chip + `"THE THRONE VERSE"` eyebrow (10.5/heavy, tracking 1.8, uppercase, chipKnowledge.fg)
  - 13pt body explaining the verse's significance: `"Ayat al-Kursi is the most majestic verse of the Qur'an — affirming God's sovereignty, knowledge, and care for all creation."`

**Build + Preview.** **Checkpoint.**

---

### Task 14: Rebuild `ProgressTrackingScreen.swift` (with Mode enum)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/ProgressTrackingScreen.swift`

**Specifics:**

```swift
struct ProgressTrackingScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false

    enum Mode { case progress, bismillah }
    var mode: Mode = .progress

    private var tilt: ThemeManager.TiltStyle { mode == .progress ? .lavender : .sage }
    private var heroSymbol: String { mode == .progress ? "chart.bar.fill" : "checkmark" }
    private var heroPalette: ThemeManager.ChipColor { mode == .progress ? ThemeManager.chipFoundation : ThemeManager.chipProgress }

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: tilt)
            VStack(spacing: 28) {
                HeroChip(symbol: heroSymbol, palette: heroPalette)
                    /* stagger */

                OnboardingTitleBlock(
                    title: "Track Your Progress",
                    subtitle: "Master the Quran, verse by verse"
                )
                /* stagger */

                VStack(spacing: 12) {
                    if mode == .bismillah {
                        bismillahCard
                    }
                    surahProgressCard
                }
                /* stagger */

                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 80)
        }
        .onAppear { isVisible = true }
    }

    // MARK: - Cards

    private var bismillahCard: some View {
        VStack(spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [ThemeManager.chipKnowledge.fg, ThemeManager.chipFoundation.fg],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                    Text("1").font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 16) {
                    Image(systemName: "play.fill").foregroundColor(themeManager.tertiaryText)
                    Image(systemName: "heart").foregroundColor(themeManager.tertiaryText)
                    RoundedRectangle(cornerRadius: 6).fill(ThemeManager.chipProgress.bg).frame(width: 22, height: 22)
                        .overlay(Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(ThemeManager.chipProgress.fg))
                }
                .font(.system(size: 14))
            }
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.system(size: 26, design: .serif, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
            Text("In the name of Allah, the Most Gracious, the Most Merciful.")
                .font(.system(size: 13.5, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white)
            .shadow(color: Color(red: 0.235, green: 0.157, blue: 0.078).opacity(0.06), radius: 12, x: 0, y: 8))
    }

    private var surahProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Al-Baqarah · The Cow").font(.system(size: 14, weight: .bold)).foregroundColor(themeManager.primaryText)
                    Text("last read 4 minutes ago").font(.system(size: 11)).foregroundColor(themeManager.tertiaryText)
                }
                Spacer()
                Text("53%").font(.system(size: 18, weight: .heavy)).foregroundColor(ThemeManager.chipProgress.fg)
            }
            ZStack(alignment: .leading) {
                Capsule().fill(ThemeManager.chipProgress.bg).frame(height: 8)
                Capsule().fill(LinearGradient(
                    colors: [ThemeManager.chipProgress.fg, Color(red: 0.337, green: 0.659, blue: 0.471)],
                    startPoint: .leading, endPoint: .trailing))
                    .frame(width: 175, height: 8) // 53% of card width
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white)
            .shadow(color: Color(red: 0.235, green: 0.157, blue: 0.078).opacity(0.04), radius: 6, x: 0, y: 2))
    }
}

#Preview("Progress") { ProgressTrackingScreen(mode: .progress) }
#Preview("Bismillah") { ProgressTrackingScreen(mode: .bismillah) }
```

(Fill in the stagger `.opacity`/`.offset`/`.animation` modifiers per the skeleton above. The progress bar width 175 is approximate; you may compute via GeometryReader for true 53% — fine to leave as-is for the onboarding illustrative case.)

**Build + Preview both modes.** **Checkpoint.**

---

### Task 15: Rebuild `QuizFeatureScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/QuizFeatureScreen.swift`

**Specifics:**

- Tilt `.mauve` · Hero `brain.head.profile` / chipKnowledge
- Add `@Binding var currentPage: Int` (new — change call site in OnboardingFlowView in Task 21)
- Title `"Test Your Knowledge"` · subtitle `"Quizzes for every surah"`
- **Quiz card** (white, 22-radius, 18-padding):
  - Centered pill at top: `HStack(spacing: 5) { Image(systemName: "square.stack.3d.up.fill"); Text("FOUNDATION") }` styled like `GemPill` with `chipFoundation` chip, but centered with `Spacer()` on both sides.
  - Question: `Text("What does 'Kursi' represent in Ayat al-Kursi?").font(.system(size: 17, weight: .heavy)).multilineTextAlignment(.center).lineSpacing(2)`
  - 4 `QuizAnswerRow`s in a `VStack(spacing: 8)`:
    - A: "The physical throne of Allah"
    - B: "Allah's knowledge and authority" (correct)
    - C: "A specific location in Paradise"
    - D: "The Day of Judgement"
- State:
  ```swift
  @State private var quizSelected: Int? = nil
  ```
- On tap of an answer row: `quizSelected = index; DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { currentPage = 6 } }`
- Each row's `isCorrect` = `quizSelected == 1` (only highlight when the correct answer was tapped) — or simpler: `isCorrect` = `quizSelected == index && index == 1`. Tapping wrong shows no visual reveal in this illustrative onboarding case.
- Caption above page indicator: `Text("Deepen your understanding through reflection").font(.system(size: 13)).foregroundColor(themeManager.tertiaryText)`

**Build + Preview.** **Checkpoint.**

---

### Task 16: Create `QuizResultScreen.swift`

**Files:**
- Create: `Thaqalayn/Views/Onboarding/QuizResultScreen.swift`

**Step 1: Write the file**

```swift
//
//  QuizResultScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 07 — Quiz Result. Variant C.
//

import SwiftUI

struct QuizResultScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .mauve)

            VStack(spacing: 28) {
                HeroChip(symbol: "brain.head.profile", palette: ThemeManager.chipKnowledge)
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                OnboardingTitleBlock(title: "Test Your Knowledge", subtitle: "Quizzes for every surah")
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                resultCard
                    .opacity(isVisible ? 1 : 0).offset(y: isVisible ? 0 : 30)
                    .animation(.easeOut(duration: 0.7).delay(0.7), value: isVisible)

                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 80)
        }
        .onAppear { isVisible = true }
    }

    private var resultCard: some View {
        VStack(spacing: 16) {
            // 72×72 plum chip with halo
            ZStack {
                RadialGradient(colors: [ThemeManager.chipKnowledge.fg.opacity(0.30), .clear],
                               center: .center, startRadius: 0, endRadius: 60)
                    .frame(width: 140, height: 140).blur(radius: 6)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(ThemeManager.chipKnowledge.bg)
                    .frame(width: 72, height: 72)
                    .overlay(Image(systemName: "book.closed.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(ThemeManager.chipKnowledge.fg))
            }

            Text("Scholar Level")
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(themeManager.primaryText)

            Text("عالم")
                .font(.system(size: 24))
                .foregroundColor(ThemeManager.chipKnowledge.fg)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("9")
                    .font(.system(size: 80, weight: .heavy))
                    .tracking(-3)
                    .foregroundStyle(LinearGradient(
                        colors: [ThemeManager.chipKnowledge.fg, Color(red: 0.435, green: 0.247, blue: 0.533)],
                        startPoint: .top, endPoint: .bottom))
                Text("/10")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.tertiaryText)
            }

            Text("Excellent understanding!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)

            // 3-stat strip
            HStack(spacing: 8) {
                statTile("12", "Quizzes")
                statTile("87%", "Avg score")
                statTile("5", "Surahs")
            }
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(ThemeManager.chipKnowledge.bg, lineWidth: 1.5))
                .shadow(color: Color(red: 0.549, green: 0.325, blue: 0.624).opacity(0.18), radius: 14, x: 0, y: 8)
        )
    }

    private func statTile(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 18, weight: .heavy)).foregroundColor(ThemeManager.chipKnowledge.fg)
            Text(label.uppercased()).font(.system(size: 10, weight: .semibold)).tracking(0.6).foregroundColor(themeManager.tertiaryText)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(red: 0.980, green: 0.957, blue: 0.969))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 0.122, green: 0.086, blue: 0.071).opacity(0.07), lineWidth: 1)))
    }
}

#Preview { QuizResultScreen() }
```

**Build + Preview.** **Checkpoint.**

---

### Task 17: Create `BismillahScreen.swift` wrapper

**Files:**
- Create: `Thaqalayn/Views/Onboarding/BismillahScreen.swift`

**Step 1: Write the file**

```swift
//
//  BismillahScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 08 — Bismillah & Tracking. Thin wrapper that
//  delegates to ProgressTrackingScreen in .bismillah mode.
//

import SwiftUI

struct BismillahScreen: View {
    var body: some View {
        ProgressTrackingScreen(mode: .bismillah)
    }
}

#Preview { BismillahScreen() }
```

**Build + Preview.** **Checkpoint.**

---

### Task 18: Rebuild `ProgressNotificationsScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/ProgressNotificationsScreen.swift`

**Specifics:**

- Keep the existing `@Binding var progressNotificationsEnabled: Bool`.
- Tilt `.peach` · Hero `flame.fill` / chipBrand
- Title `"Stay Motivated"` · subtitle `"Build your reading streak and earn badges"`
- 3 `FeatureRow`s with `chipSize: 48, iconSize: 22`:
  ```swift
  FeatureRow(chip: ThemeManager.chipFoundation, symbol: "chart.bar.fill", title: "Track Your Progress", subtitle: "See your daily verse count and reading streaks", chipSize: 48, iconSize: 22)
  FeatureRow(chip: ThemeManager.chipBrand,      symbol: "flame.fill",     title: "Build Streaks",       subtitle: "Read daily to maintain your streak",          chipSize: 48, iconSize: 22)
  FeatureRow(chip: ThemeManager.chipFeatured,   symbol: "trophy.fill",    title: "Earn Badges",         subtitle: "Complete surahs and hit milestones",          chipSize: 48, iconSize: 22)
  ```
  (Spacing 10.)
- Primary CTA:
  ```swift
  OnboardingCTA(style: .primary, symbol: "bell.fill", label: "Enable Progress Reminders") {
      progressNotificationsEnabled = true
  }
  ```
- Caption below CTA: `Text("You can always enable this later in Settings").font(.system(size: 12)).foregroundColor(themeManager.tertiaryText)`

**Build + Preview.** **Checkpoint.**

---

### Task 19: Rebuild `SeasonalFeaturesScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/SeasonalFeaturesScreen.swift`

**Specifics:**

- Tilt `.mauve` · Hero `moon.stars.fill` on chipKnowledge bg with `iconOverride: ThemeManager.chipBrand.fg`
- Title `"Special Seasons"` · subtitle `"Unique experiences for blessed months"`
- **Ramadan card** (white, 20-radius, 16-padding):
  - Top row: 44×44 chipBrand chip with `moon.fill` + `Text("Ramadan Journey").font(.system(size: 17, weight: .heavy))` + magenta "Seasonal" pill:
    ```swift
    Text("Seasonal")
        .font(.system(size: 10.5, weight: .bold)).tracking(0.4)
        .foregroundColor(.white)
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(Capsule().fill(LinearGradient(
            colors: [Color(red: 0.78, green: 0.392, blue: 0.835), Color(red: 0.604, green: 0.282, blue: 0.659)],
            startPoint: .top, endPoint: .bottom)))
    ```
  - 4 mini-rows: 22×22 `chipFeatured` mini-chip + 13pt secondary text:
    - `sparkles` · "Daily duas from Mafatih al-Jinan"
    - `book.closed` · "Curated Quranic verses with tafsir"
    - `heart` · "Reflections and spiritual guidance"
    - `checkmark` · "Track your 30-day progress"
- **More Coming Soon card** (white, 20-radius):
  - Top row: 44×44 chipFoundation chip with `calendar` + `Text("More Coming Soon").font(.system(size: 16, weight: .heavy))` + blue "Future" pill (same Capsule pattern, gradient `#5BA6F0 → #3D78B2`).
  - 4 sky tag pills (each `GemPill(chip: ThemeManager.chipFoundation, ...)`):
    - `drop.fill` · "Muharram"
    - `mountain.2.fill` · "Dhul-Hijjah"
    - `sparkles` · "Rajab"
    - `star.fill` · "Holy nights"

**Build + Preview.** **Checkpoint.**

---

### Task 20: Rebuild `FinalScreen.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/FinalScreen.swift`

**Specifics:**

- Keep existing `var onComplete: () -> Void`.
- Tilt `.peach`. No `HeroChip` — top is small Arabic mark:
  ```swift
  Text("ثقلين")
      .font(.system(size: 44))
      .foregroundColor(ThemeManager.chipBrand.fg)
      .shadow(color: themeManager.accentColor.opacity(0.4), radius: 30)
      .padding(.top, 30)
  ```
- `OnboardingTitleBlock` with `titleScale: .jumbo` (34/heavy/-0.8) — title `"Begin Your Journey"`, subtitle `"Sync your reading progress and bookmarks across all your devices."`
- CTA stack (`VStack(spacing: 10)`):
  ```swift
  OnboardingCTA(style: .primary,   symbol: "book.closed.fill",        label: "Continue as Guest") { onComplete() }
  OnboardingCTA(style: .secondary, symbol: "person.fill.badge.plus",  label: "Create Account")    { onComplete() }
  OnboardingCTA(style: .secondary, symbol: "person.fill",             label: "Sign In")           { onComplete() }
  ```
- Benefits card (white, 18-radius, centered):
  ```swift
  HStack(spacing: 10) {
      RoundedRectangle(cornerRadius: 7, style: .continuous)
          .fill(ThemeManager.chipProgress.bg).frame(width: 24, height: 24)
          .overlay(Image(systemName: "heart.fill").font(.system(size: 11)).foregroundColor(ThemeManager.chipProgress.fg))
      VStack(alignment: .leading, spacing: 2) {
          Text("Account Benefits").font(.system(size: 12.5, weight: .bold)).tracking(0.3)
          Text("Sync bookmarks across devices and save your reading progress.")
              .font(.system(size: 12.5)).foregroundColor(themeManager.tertiaryText).lineSpacing(2)
      }
  }
  .padding(.horizontal, 16).padding(.vertical, 14)
  .background(RoundedRectangle(cornerRadius: 18).fill(Color.white)
      .shadow(color: Color(red: 0.235, green: 0.157, blue: 0.078).opacity(0.04), radius: 6, x: 0, y: 2))
  ```
- Legal at bottom: `Text("By continuing you agree to our Terms and Privacy.").font(.system(size: 11)).foregroundColor(themeManager.tertiaryText)` — bold+underline "Terms" and "Privacy" inline via `AttributedString`.
- **Suppress page indicator**: in this screen only, layer a bottom-anchored rectangle:
  ```swift
  VStack {
      Spacer()
      Rectangle()
          .fill(Color(red: 0.980, green: 0.949, blue: 0.910)) // tilt-peach bottom stop
          .frame(height: 40)
          .ignoresSafeArea(edges: .bottom)
  }
  ```

**Build + Preview.** **Checkpoint.**

---

## Phase 4 — Coordinator + cleanup

### Task 21: Update `OnboardingFlowView.swift`

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/OnboardingFlowView.swift`

**Step 1: Replace the body**

```swift
struct OnboardingFlowView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var progressNotificationsEnabled = false

    private let totalPages = 11

    var body: some View {
        ZStack {
            themeManager.primaryBackground.ignoresSafeArea()

            TabView(selection: $currentPage) {
                HadithScreen(currentPage: $currentPage).tag(0)
                MissionScreen().tag(1)
                FiveLayersScreen().tag(2)
                QuickGemsScreen().tag(3)
                ProgressTrackingScreen().tag(4)
                QuizFeatureScreen(currentPage: $currentPage).tag(5)
                QuizResultScreen().tag(6)
                BismillahScreen().tag(7)
                ProgressNotificationsScreen(progressNotificationsEnabled: $progressNotificationsEnabled).tag(8)
                SeasonalFeaturesScreen().tag(9)
                FinalScreen(onComplete: { completeOnboarding() }).tag(10)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            if currentPage < totalPages - 1 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: completeOnboarding) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.secondaryText)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 20).fill(themeManager.glassEffect))
                        }
                        .padding(.trailing, 20).padding(.top, 50)
                    }
                    Spacer()
                }
            }
        }
        .darkScreenAura()
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.colorScheme)
    }

    private func completeOnboarding() {
        if progressNotificationsEnabled {
            Task { await NotificationManager.shared.requestPermission() }
        }
        let progressManager = ProgressManager.shared
        progressManager.preferences.notificationsEnabled = progressNotificationsEnabled
        progressManager.preferences.celebrationsEnabled = progressNotificationsEnabled

        UserDefaults.standard.set(true, forKey: "hasShownWelcome")
        dismiss()
    }
}

#Preview { OnboardingFlowView() }
```

**Step 2: Build.** Expected: success. **Checkpoint.**

---

### Task 22: Mark `DailyVerseScreen.swift` deprecated

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/DailyVerseScreen.swift` (top of file only)

**Step 1: Add a header comment** above the existing `import SwiftUI`:

```swift
//
//  DailyVerseScreen.swift
//  Thaqalayn
//
//  MARK: - DEPRECATED — not in onboarding flow as of Variant C redesign (2026-05-15).
//  Left on disk in case the verse-of-the-day onboarding moment is reintroduced.
//  Safe to delete in a follow-up cleanup.
//
```

**Step 2: Build.** Expected: success (file is still compiled but unreachable). **Checkpoint.**

---

### Task 23: Full flow smoke test in simulator

**Files:** none

**Step 1: Run in simulator**

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Then run the app from Xcode (⌘R) on iPhone 16 Pro simulator. To force the onboarding flow, in the simulator: Settings → reset onboarding key, or call `UserDefaults.standard.removeObject(forKey: "hasShownWelcome")` from a debugger breakpoint, or temporarily set the key to false in `ThaqalaynApp.swift`.

**Step 2: Walk the flow**

- Swipe through all 11 screens. Each renders with no crash, no broken layout, no missing icons.
- Compare each screen visually to `design_handoff_onboarding_variant_c/screenshots/*.png` — typography, chip colors, card layouts match.
- On screen 06 (Quiz), tap answer B — peach correct-state appears, ~1.2s later screen 07 appears.
- On screen 11 (Final), tap each of the three CTAs separately to confirm `onComplete` dismisses the flow.
- Page indicator visible on screens 01–10, hidden on 11.
- Skip button visible on 01–10, hidden on 11.

**Step 3: Switch to dark theme in Settings, re-launch**

- Tilt gradients + amber halos absent. Pastel chips + white cards still render and read clearly over the dark aura. No layout breaks.

**Step 4 (checkpoint):** Final commit point: `feat(onboarding): Variant C redesign — 11 screens with pastel chip palette and tilt backgrounds`

---

## Quality gate (must all be true to call this done)

- [ ] `ThemeManager` exposes 7 chip palette tokens + 4 tilt gradient styles + `amberGlowColor`.
- [ ] 7 component files exist under `Views/Onboarding/Components/` and each has a working `#Preview`.
- [ ] 9 existing onboarding screen files rebuilt; 2 new files created (`QuizResultScreen.swift`, `BismillahScreen.swift`).
- [ ] `DailyVerseScreen.swift` marked DEPRECATED in its top comment, removed from `OnboardingFlowView` TabView.
- [ ] `OnboardingFlowView.totalPages == 11`; `notificationsEnabled` state removed; `completeOnboarding()` simplified.
- [ ] All 11 screens render correctly in light mode on iPhone 16 Pro simulator and visually match the handoff screenshots.
- [ ] All 11 screens render without layout breaks in dark mode.
- [ ] No new build warnings introduced.
- [ ] Quiz tap → result transition works at ~1.2s after answer selected.
- [ ] All three Final-screen CTAs call `onComplete` and dismiss the flow.

---

## Notes for the implementing engineer

- **No `.pbxproj` edits.** Xcode 16 synced folder groups pick up new files automatically. Just drop them in the right folder. (See user memory: `reference_xcode_synced_folders.md`.)
- **No auto-commits.** Each "checkpoint" in this plan is a suggested commit point — the user commits themselves. Do not run `git commit`. (See user memory: `feedback_no_auto_commits.md`.)
- **No fallback logic.** Per project CLAUDE.md: throw clear errors when operations fail; do not add try-catch fallbacks for the "what if a chip color is missing" kind of case.
- **Spec is the source of truth.** When in doubt about a hex value, padding, or font weight, consult `design_handoff_onboarding_variant_c/README.md` (full pixel spec) and `design_handoff_onboarding_variant_c/design-files/variant-c.jsx` (the React reference).
- **Test on iPhone 16 Pro simulator (`device=iPhone 16 Pro`).** The screenshots were rendered at that size; pixel comparisons are easiest there.
