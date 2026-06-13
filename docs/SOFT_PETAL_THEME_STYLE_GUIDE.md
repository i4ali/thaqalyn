# Soft Petal Theme UI Style Guide - Thaqalayn App

## Overview

This document defines the "Soft Petal" theme variant, a gentle evolution of the Warm & Inviting theme.

**Theme Philosophy:** Same sanctuary-like warmth, but with a soft rosy blush replacing the lavender tint. The shift is subtle — backgrounds lean pink instead of purple, and the primary accent moves from peaceful purple to a dusty rose. Everything else (typography, spacing, radii, shadows, component patterns) remains identical.

**Variant Name:** `softPetal`
**Display Name:** "Soft Petal"
**Description:** "Gentle rosy warmth"
**Color Scheme:** Light

---

## 1. Color Palette

### Backgrounds
| Purpose | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Primary Background | `#FFF5F7` | `(1.0, 0.961, 0.965)` | Main screen backgrounds |
| Secondary Background | `#FEF8F9` | `(0.996, 0.973, 0.976)` | Cards, sections |
| Tertiary Background | `#FFFAF7` | `(1.0, 0.980, 0.969)` | Accent areas |
| Card White | `#FFFFFF` | `(1.0, 1.0, 1.0)` | Card surfaces |

### Comparison with Warm & Inviting
| Purpose | Warm & Inviting | Soft Petal | Shift |
|---------|-----------------|------------|-------|
| Primary BG | `#F8F5FF` (lavender) | `#FFF5F7` (blush) | Purple tint → Pink tint |
| Secondary BG | `#FBFBFA` | `#FEF8F9` | Neutral → Rosy cream |
| Tertiary BG | `#FFF9F5` | `#FFFAF7` | Same warmth, slightly rosier |

### Text Colors
| Purpose | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Primary Text | `#2F2325` | `(0.184, 0.137, 0.145)` | Headings, body text |
| Secondary Text | `#6B5A5E` | `(0.42, 0.353, 0.369)` | Subtitles, metadata |
| Tertiary Text | `#B09A9E` | `(0.69, 0.604, 0.620)` | Captions, hints |

### Accent Colors
| Purpose | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Dusty Rose | `#BF8F9B` | `(0.749, 0.561, 0.608)` | Primary accent, buttons |
| Deep Rose | `#A87F8B` | `(0.659, 0.498, 0.545)` | Gradient end |
| Sunset Orange | `#E89A6F` | `(0.91, 0.604, 0.435)` | Secondary accent (unchanged) |
| Deeper Orange | `#D88A5F` | `(0.847, 0.541, 0.373)` | Orange gradient end (unchanged) |
| Serene Green | `#7FB89A` | `(0.498, 0.722, 0.604)` | Success states (unchanged) |

### Comparison with Warm & Inviting Accents
| Purpose | Warm & Inviting | Soft Petal | Shift |
|---------|-----------------|------------|-------|
| Primary Accent | `#9B8FBF` (purple) | `#BF8F9B` (dusty rose) | Purple → Rose |
| Deep Accent | `#8B7FA8` | `#A87F8B` | Deep purple → Deep rose |
| Orange | `#E89A6F` | `#E89A6F` | No change |
| Green | `#7FB89A` | `#7FB89A` | No change |

### Gradients
```swift
// Rose gradient (primary buttons, highlights)
LinearGradient(colors: [
    Color(red: 0.749, green: 0.561, blue: 0.608), // #BF8F9B - dusty rose
    Color(red: 0.659, green: 0.498, blue: 0.545)  // #A87F8B - deep rose
], startPoint: .topLeading, endPoint: .bottomTrailing)

// Orange gradient (secondary actions, badges) — same as Warm & Inviting
LinearGradient(colors: [
    Color(red: 0.91, green: 0.604, blue: 0.435),  // #E89A6F
    Color(red: 0.847, green: 0.541, blue: 0.373)   // #D88A5F
], startPoint: .topLeading, endPoint: .bottomTrailing)
```

---

## 2. Typography

**Identical to Warm & Inviting.** Same font family (SF Pro Rounded), same sizes, same weights.

| Element | Size | Weight | Code |
|---------|------|--------|------|
| Large Title | 34pt | Bold | `.font(.system(size: 34, weight: .bold, design: .rounded))` |
| Headline | 20pt | SemiBold | `.font(.system(size: 20, weight: .semibold, design: .rounded))` |
| Subheadline | 18pt | Medium | `.font(.system(size: 18, weight: .medium, design: .rounded))` |
| Body | 17pt | Regular | `.font(.system(size: 17, weight: .regular, design: .rounded))` |
| Caption | 14pt | Medium | `.font(.system(size: 14, weight: .medium, design: .rounded))` |
| Small Caption | 12pt | Medium | `.font(.system(size: 12, weight: .medium, design: .rounded))` |
| Arabic | 24-32pt | Medium | `.font(.system(size: 28, weight: .medium))` |

---

## 3. Spacing

**Identical to Warm & Inviting.** Uses the same `WarmSpacing` enum.

---

## 4. Corner Radii

**Identical to Warm & Inviting.** Uses the same `WarmRadius` enum.

---

## 5. Shadows

### Card Shadow (default)
```swift
.shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
```

### Button Shadow (rose-tinted instead of orange-tinted)
```swift
.shadow(color: Color(red: 0.749, green: 0.561, blue: 0.608).opacity(0.3), radius: 8, x: 0, y: 4)
```

### Badge Shadow
```swift
.shadow(color: Color.warmOrange.opacity(0.4), radius: 8)
```

### Stat Card Shadow (rose-tinted instead of purple-tinted)
```swift
.shadow(color: Color(red: 0.749, green: 0.561, blue: 0.608).opacity(0.15), radius: 12, x: 0, y: 4)
```

---

## 6. Stroke Color

```swift
Color(red: 0.184, green: 0.137, blue: 0.145).opacity(0.1) // Subtle rosy charcoal
```

---

## 7. Glass Effect

Same as Warm & Inviting: `.ultraThin`

---

## 8. Floating Orb Colors

```swift
[
    Color(red: 0.749, green: 0.561, blue: 0.608).opacity(0.06), // Dusty rose (subtle)
    Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.05),  // Sunset orange (very subtle)
    Color(red: 0.498, green: 0.722, blue: 0.604).opacity(0.04)  // Serene green (barely visible)
]
```

---

## 9. What Changes vs. Warm & Inviting

| Aspect | Changes? | Details |
|--------|----------|---------|
| Backgrounds | Yes | Lavender tint → Rose/blush tint |
| Text colors | Yes | Warm brown → Rosy brown (very subtle) |
| Primary accent | Yes | Purple (#9B8FBF) → Dusty rose (#BF8F9B) |
| Orange accent | No | Same sunset orange |
| Green accent | No | Same serene green |
| Typography | No | Same SF Pro Rounded |
| Spacing | No | Same WarmSpacing |
| Corner radii | No | Same WarmRadius |
| Shadows | Slight | Purple tint → Rose tint on stat cards/buttons |
| Animations | No | Same durations and curves |

---

## 10. Implementation Notes

- Add `case softPetal = "softPetal"` to `ThemeVariant` enum
- Group with `.warmInviting` in `colorScheme` (both are `.light`)
- Group with `.warmInviting` in `isDarkMode` (both are `false`)
- Reuse all `WarmSpacing`, `WarmRadius`, and font extensions — no new utilities needed
- Update `ThemeSelectionView` preview helpers with the new case

---

## 11. Key Files to Modify

| File | Changes |
|------|---------|
| `Services/ThemeManager.swift` | Add `.softPetal` case to all switch statements |
| `Views/ThemeSelectionView.swift` | Add preview helper cases for `.softPetal` |
| `Utilities/WarmThemeModifiers.swift` | No changes needed |
