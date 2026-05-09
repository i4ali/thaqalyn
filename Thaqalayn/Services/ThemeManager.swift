//
//  ThemeManager.swift
//  Thaqalayn
//
//  Theme management. Only one theme remains: warmInviting (light).
//  The enum and selectedTheme property are retained as a vestigial API
//  to minimize churn in the rest of the codebase.
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
        case .nightSanctuary: return "Verse-Hero warm-black with peach accent"
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
            self.selectedTheme = .warmInviting
        }
    }

    var isDarkMode: Bool { selectedTheme == .nightSanctuary }

    var colorScheme: ColorScheme { selectedTheme == .nightSanctuary ? .dark : .light }

    /// Alias kept for clarity at call sites that prefer the explicit name.
    var swiftUIColorScheme: ColorScheme { colorScheme }

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
            return Color(red: 0.78, green: 0.74, blue: 0.71)
        case .nightSanctuary:
            return Color.white.opacity(0.32)
        }
    }

    // MARK: - Accents

    var accentColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF
        case .nightSanctuary:
            return Color(red: 0.910, green: 0.580, blue: 0.392) // #E89464 peach
        }
    }

    var accentColorDeep: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.545, green: 0.498, blue: 0.659) // #8B7FA8
        case .nightSanctuary:
            return Color(red: 0.820, green: 0.478, blue: 0.282) // #D17A48 peach deep
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

    // MARK: - Materials

    var glassEffect: Material { .ultraThin }

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
            return Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.08)
        case .nightSanctuary:
            return Color(red: 0.227, green: 0.129, blue: 0.094) // #3A2118
        }
    }

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
            return Color(red: 0.357, green: 0.773, blue: 0.541) // #5BC58A
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
