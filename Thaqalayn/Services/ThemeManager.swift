//
//  ThemeManager.swift
//  Thaqalayn
//
//  Theme management. Two themes: warmInviting ("Light") and nightSanctuary
//  ("Midnight Emerald" — emerald-black & gold). Midnight Emerald is the default
//  for fresh installs; users can switch in Settings (selectedTheme is persisted).
//

import SwiftUI

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
        case .nightSanctuary: return "Midnight Emerald — emerald-black & gold"
        }
    }
}

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
            // Fresh install (no stored preference) → default to Midnight Emerald.
            self.selectedTheme = .nightSanctuary
        }
    }

    var isDarkMode: Bool { selectedTheme == .nightSanctuary }

    /// True when the active theme is Midnight Emerald (the Dark slot).
    var isMidnightEmerald: Bool { selectedTheme == .nightSanctuary }

    var colorScheme: ColorScheme { selectedTheme == .nightSanctuary ? .dark : .light }

    /// Alias kept for clarity at call sites that prefer the explicit name.
    var swiftUIColorScheme: ColorScheme { colorScheme }

    // MARK: - Backgrounds

    var primaryBackground: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.973, green: 0.961, blue: 1.0) // #F8F5FF
        case .nightSanctuary:
            return Color(hex: "0A1512")
        }
    }

    var secondaryBackground: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.987, green: 0.969, blue: 0.980) // #FBFBFA
        case .nightSanctuary:
            return Color(hex: "081310")
        }
    }

    var tertiaryBackground: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 1.0, green: 0.976, blue: 0.961) // #FFF9F5
        case .nightSanctuary:
            return Color(hex: "0C1D16")
        }
    }

    // MARK: - Text

    var primaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125) // #2D2520
        case .nightSanctuary:
            return Color(hex: "F1E8D6")
        }
    }

    var secondaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.42, green: 0.365, blue: 0.329) // #6B5D54
        case .nightSanctuary:
            return Color(hex: "F1E8D6").opacity(0.60)
        }
    }

    var tertiaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.69, green: 0.64, blue: 0.6) // #B0A399
        case .nightSanctuary:
            return Color(hex: "F1E8D6").opacity(0.38)
        }
    }

    var quaternaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.78, green: 0.74, blue: 0.71)
        case .nightSanctuary:
            return Color(hex: "F1E8D6").opacity(0.24)
        }
    }

    // MARK: - Accents

    var accentColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF
        case .nightSanctuary:
            return Color(hex: "D6B25E")
        }
    }

    var accentColorDeep: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.545, green: 0.498, blue: 0.659) // #8B7FA8
        case .nightSanctuary:
            return Color(hex: "B8923F")
        }
    }

    var accentColorSoft: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.14)
        case .nightSanctuary:
            return Color(hex: "D6B25E").opacity(0.14)
        }
    }

    var accentGradient: LinearGradient {
        switch selectedTheme {
        case .warmInviting:
            return LinearGradient(
                colors: [
                    Color(red: 0.91, green: 0.604, blue: 0.435), // #E89A6F - sunset orange
                    Color(red: 0.847, green: 0.541, blue: 0.373) // #D88A5F - deeper orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nightSanctuary:
            return LinearGradient(colors: [Color(hex: "ECD49A"), Color(hex: "B8923F")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var purpleGradient: LinearGradient {
        switch selectedTheme {
        case .warmInviting:
            return LinearGradient(
                colors: [
                    Color(red: 0.608, green: 0.561, blue: 0.749), // #9B8FBF - peaceful purple
                    Color(red: 0.545, green: 0.498, blue: 0.659) // #8B7FA8 - deeper purple
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

    // MARK: - Onboarding Variant C (static; onboarding is always warm/light)

    struct ChipColor { let bg: Color; let fg: Color }

    static let chipGold        = ChipColor(bg: Color(hex: "ECD49A").opacity(0.15), fg: Color(hex: "ECD49A")) // decorative default
    // Five-layer semantic tones (FiveLayersScreen rows), retuned to glow on dark:
    static let chipFoundation  = ChipColor(bg: Color(hex: "6FA5E8").opacity(0.15), fg: Color(hex: "6FA5E8")) // blue
    static let chipKnowledge   = ChipColor(bg: Color(hex: "B8A6D9").opacity(0.15), fg: Color(hex: "B8A6D9")) // lilac
    static let chipProgress    = ChipColor(bg: Color(hex: "6FD0A6").opacity(0.15), fg: Color(hex: "6FD0A6")) // green
    static let chipBrand       = ChipColor(bg: Color(hex: "ECD49A").opacity(0.16), fg: Color(hex: "ECD49A")) // gold (Ahlul Bayt)
    static let chipComparative = ChipColor(bg: Color(hex: "D69BB0").opacity(0.15), fg: Color(hex: "D69BB0")) // mauve
    // Decorative leftovers (no longer semantic) -> gold:
    static let chipFeatured    = ChipColor(bg: Color(hex: "ECD49A").opacity(0.15), fg: Color(hex: "ECD49A"))
    static let chipWarmth      = ChipColor(bg: Color(hex: "ECD49A").opacity(0.15), fg: Color(hex: "ECD49A"))

    enum OnboardingTilt { case peach, lavender, mauve, sage }

    static func tiltColors(_ tilt: OnboardingTilt) -> [Color] {
        switch tilt {
        case .peach:    return [Color(hex: "F5E6E6"), Color(hex: "F8E5D2"), Color(hex: "FAF2E8")]
        case .lavender: return [Color(hex: "F1E9F4"), Color(hex: "F5E8E5"), Color(hex: "FAF2E8")]
        case .mauve:    return [Color(hex: "ECE3F2"), Color(hex: "F2E6E8"), Color(hex: "FAF2E8")]
        case .sage:     return [Color(hex: "E6EEEB"), Color(hex: "F0EBE2"), Color(hex: "FAF2E8")]
        }
    }

    // MARK: - Materials

    var glassEffect: Material { .ultraThin }

    var glassSurface: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color.white.opacity(0.6)
        case .nightSanctuary:
            return Color.white.opacity(0.045)
        }
    }

    var glassSurfaceRecessed: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color.white.opacity(0.4)
        case .nightSanctuary:
            return Color.white.opacity(0.03)
        }
    }

    var screenGlowColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.08)
        case .nightSanctuary:
            return Color(hex: "D6B25E").opacity(0.14)
        }
    }

    // MARK: - Strokes & dividers

    var strokeColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.10)
        case .nightSanctuary:
            return Color(hex: "D6B25E").opacity(0.16)
        }
    }

    var strokeColorStrong: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.18)
        case .nightSanctuary:
            return Color(hex: "D6B25E").opacity(0.24)
        }
    }

    var dividerColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.06)
        case .nightSanctuary:
            return Color(hex: "D6B25E").opacity(0.09)
        }
    }

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

    // MARK: - Semantic

    var semanticGreen: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.498, green: 0.722, blue: 0.604) // #7FB89A
        case .nightSanctuary:
            return Color(hex: "3E9B79")
        }
    }

    var semanticRed: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.93, green: 0.28, blue: 0.6)
        case .nightSanctuary:
            return Color(red: 0.957, green: 0.471, blue: 0.459) // #F47875
        }
    }

    var semanticBlue: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.39, green: 0.4, blue: 0.95)
        case .nightSanctuary:
            return Color(red: 0.435, green: 0.647, blue: 0.910) // #6FA5E8
        }
    }

    var semanticYellow: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.95, green: 0.78, blue: 0.30)
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

    // MARK: - Midnight Emerald additions

    var accentBright: Color         { Color(hex: "ECD49A") }                 // goldBright
    var accentChip: Color           { Color(hex: "D6B25E").opacity(0.14) }   // goldChip
    var glassSurfaceElevated: Color { isMidnightEmerald ? Color.white.opacity(0.07) : Color.white } // cardElev
    var semanticGreenChip: Color    { Color(hex: "3E9B79").opacity(0.16) }   // emerChip
    var onAccentText: Color         { Color(hex: "1A1408") }                 // ctaText
    var emeraldBgTop: Color         { Color(hex: "0C1D16") }                 // bg1
    var emeraldBgBottom: Color      { Color(hex: "081310") }                 // bg2

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
}
