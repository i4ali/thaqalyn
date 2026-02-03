# Warm Theme UI Style Guide - Thaqalayn App

## Overview

This document ensures UI consistency for the "Warm & Inviting" theme across all screens.

**Theme Philosophy:** Sanctuary-like, peaceful design with soft lavender backgrounds, warm charcoal text, and rounded typography for a friendly, contemplative reading experience.

---

## 1. Color Palette

### Backgrounds
| Purpose | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Primary Background | `#F8F5FF` | `(0.973, 0.961, 1.0)` | Main screen backgrounds |
| Secondary Background | `#FBFBFA` | `(0.987, 0.969, 0.980)` | Cards, sections |
| Tertiary Background | `#FFF9F5` | `(1.0, 0.976, 0.961)` | Accent areas |
| Card White | `#FFFFFF` | `(1.0, 1.0, 1.0)` | Card surfaces |

### Text Colors
| Purpose | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Primary Text | `#2D2520` | `(0.176, 0.145, 0.125)` | Headings, body text |
| Secondary Text | `#6B5D54` | `(0.42, 0.365, 0.329)` | Subtitles, metadata |
| Tertiary Text | `#B0A399` | `(0.69, 0.64, 0.6)` | Captions, hints |

### Accent Colors
| Purpose | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Peaceful Purple | `#9B8FBF` | `(0.608, 0.561, 0.749)` | Primary accent, buttons |
| Deep Purple | `#8B7FA8` | `(0.545, 0.498, 0.659)` | Gradient end |
| Sunset Orange | `#E89A6F` | `(0.91, 0.604, 0.435)` | Secondary accent |
| Deeper Orange | `#D88A5F` | `(0.847, 0.541, 0.373)` | Orange gradient end |
| Serene Green | `#7FB89A` | `(0.498, 0.722, 0.604)` | Success states, progress |

### Gradients
```swift
// Purple gradient (primary buttons, highlights)
LinearGradient(colors: [.warmPurple, .warmPurpleDark], startPoint: .topLeading, endPoint: .bottomTrailing)

// Orange gradient (secondary actions, badges)
LinearGradient(colors: [.warmOrange, .warmOrangeDark], startPoint: .topLeading, endPoint: .bottomTrailing)
```

---

## 2. Typography

**Font Family:** System with `.rounded` design (SF Pro Rounded)

| Element | Size | Weight | Code |
|---------|------|--------|------|
| Large Title | 34pt | Bold | `.font(.system(size: 34, weight: .bold, design: .rounded))` |
| Headline | 20pt | SemiBold | `.font(.system(size: 20, weight: .semibold, design: .rounded))` |
| Subheadline | 18pt | Medium | `.font(.system(size: 18, weight: .medium, design: .rounded))` |
| Body | 17pt | Regular | `.font(.system(size: 17, weight: .regular, design: .rounded))` |
| Caption | 14pt | Medium | `.font(.system(size: 14, weight: .medium, design: .rounded))` |
| Small Caption | 12pt | Medium | `.font(.system(size: 12, weight: .medium, design: .rounded))` |
| Arabic | 24-32pt | Medium | `.font(.system(size: 28, weight: .medium))` |

### Using Font Extensions
```swift
Text("Title").font(.warmTitle())
Text("Body").font(.warmBody())
Text("Caption").font(.warmCaption())
```

---

## 3. Spacing

```swift
enum WarmSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let regular: CGFloat = 16
    static let large: CGFloat = 20
    static let generous: CGFloat = 24    // Default padding
    static let extraGenerous: CGFloat = 28
    static let huge: CGFloat = 32
}
```

**Standard Usage:**
- Screen padding: 24pt (generous)
- Card internal padding: 16pt (regular)
- Section spacing: 20-24pt
- Element gaps: 8-12pt

---

## 4. Corner Radii

```swift
enum WarmRadius {
    static let small: CGFloat = 12      // Buttons, small elements
    static let medium: CGFloat = 16     // Search bars, inputs
    static let large: CGFloat = 20      // Cards
    static let pill: CGFloat = 24       // Pill buttons
}
```

**Standard Usage:**
- Cards: 20pt
- Buttons: 24pt (pill)
- Search bars: 16pt
- Small elements: 12pt

---

## 5. Shadows

### Card Shadow (default)
```swift
.shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
```

### Button Shadow (accent-tinted)
```swift
.shadow(color: Color.warmOrange.opacity(0.3), radius: 8, x: 0, y: 4)
```

### Badge Shadow
```swift
.shadow(color: Color.warmOrange.opacity(0.4), radius: 8)
```

### Stat Card Shadow (purple-tinted)
```swift
.shadow(color: Color.warmPurple.opacity(0.15), radius: 12, x: 0, y: 4)
```

---

## 6. Component Patterns

### Standard Card
```swift
VStack {
    // Content
}
.padding(WarmSpacing.regular)
.background(Color.white)
.cornerRadius(WarmRadius.large)
.shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
```

### Primary Button
```swift
Button(action: {}) {
    Text("Action")
        .font(.warmBody())
        .foregroundColor(.white)
        .padding(.horizontal, WarmSpacing.generous)
        .padding(.vertical, WarmSpacing.medium)
}
.background(Color.warmPurpleGradient)
.cornerRadius(WarmRadius.pill)
.shadow(color: Color.warmOrange.opacity(0.3), radius: 8, x: 0, y: 4)
```

### Search Bar
```swift
HStack {
    Text("🔍")
    TextField("Search surahs...", text: $searchText)
}
.padding(WarmSpacing.regular)
.background(Color.white)
.cornerRadius(WarmRadius.medium)
.shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
```

### Section Header
```swift
Text("Section Title")
    .font(.warmHeadline())
    .foregroundColor(themeManager.primaryText)
```

### Circular Badge
```swift
Circle()
    .fill(Color.warmOrangeGradient)
    .frame(width: 56, height: 56)
    .shadow(color: Color.warmOrange.opacity(0.4), radius: 8)
```

---

## 7. Screen Structure Template

```swift
struct NewScreenView: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            // Background
            themeManager.primaryBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: WarmSpacing.large) {
                    // Header
                    headerSection

                    // Content cards
                    contentSection
                }
                .padding(.horizontal, WarmSpacing.generous)
                .padding(.top, WarmSpacing.large)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: WarmSpacing.small) {
            Text("Screen Title")
                .font(.warmTitle())
                .foregroundColor(themeManager.primaryText)

            Text("Subtitle or description")
                .font(.warmSubheadline())
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

---

## 8. Animation Guidelines

- **Theme transitions:** `easeInOut`, 0.5s duration
- **Selection feedback:** Scale 1.02x, 0.2s duration
- **Haptic feedback:** Light impact on selections
- **Color transitions:** Always animate with theme changes

---

## 9. Key Files Reference

| File | Purpose |
|------|---------|
| `Services/ThemeManager.swift` | Theme colors & state |
| `Utilities/WarmThemeModifiers.swift` | Color extensions, spacing, modifiers |
| `Views/ThemeSelectionView.swift` | Theme preview implementation |
| `Views/HomeView.swift` | Reference implementation |

---

## 10. Checklist for New Screens

- [ ] Use `themeManager.primaryBackground` for screen background
- [ ] Apply `.rounded` design to all fonts
- [ ] Use warm color palette (no pure black text)
- [ ] Cards have 20pt radius + subtle shadow
- [ ] Buttons use gradient backgrounds + pill radius
- [ ] Standard 24pt horizontal padding
- [ ] Consistent spacing using `WarmSpacing` enum
- [ ] Purple accent for primary actions
- [ ] Orange accent for secondary/highlight elements
- [ ] Green for success/progress states
