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

    var displayName: String { "Warm & Inviting" }
    var description: String { "Sanctuary-like warm design" }
}

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var selectedTheme: ThemeVariant = .warmInviting

    /// Always false — kept as a vestigial API. Removed dark themes.
    var isDarkMode: Bool { false }

    private init() {
        // Migrate any previously-saved theme to the only remaining option.
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        UserDefaults.standard.removeObject(forKey: "isDarkMode")
    }

    // MARK: - Color scheme

    var colorScheme: ColorScheme { .light }

    // MARK: - Backgrounds

    /// Soft Lavender — top of screen.
    var primaryBackground: Color {
        Color(red: 0.973, green: 0.961, blue: 1.0) // #F8F5FF
    }

    /// Middle blend.
    var secondaryBackground: Color {
        Color(red: 0.987, green: 0.969, blue: 0.980) // #FBFBFA
    }

    /// Warm White — bottom of screen.
    var tertiaryBackground: Color {
        Color(red: 1.0, green: 0.976, blue: 0.961) // #FFF9F5
    }

    // MARK: - Text

    var primaryText: Color {
        Color(red: 0.176, green: 0.145, blue: 0.125) // #2D2520 - warm charcoal
    }

    var secondaryText: Color {
        Color(red: 0.42, green: 0.365, blue: 0.329) // #6B5D54 - soft gray
    }

    var tertiaryText: Color {
        Color(red: 0.69, green: 0.64, blue: 0.6) // #B0A399 - light gray
    }

    // MARK: - Accents

    var accentColor: Color {
        Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF - peaceful purple
    }

    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.91, green: 0.604, blue: 0.435), // #E89A6F - sunset orange
                Color(red: 0.847, green: 0.541, blue: 0.373) // #D88A5F - deeper orange
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var purpleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.608, green: 0.561, blue: 0.749), // #9B8FBF - peaceful purple
                Color(red: 0.545, green: 0.498, blue: 0.659) // #8B7FA8 - deeper purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Materials

    var glassEffect: Material { .ultraThin }

    var strokeColor: Color {
        Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.1)
    }

    var floatingOrbColors: [Color] {
        [
            Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.06),
            Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.05),
            Color(red: 0.498, green: 0.722, blue: 0.604).opacity(0.04)
        ]
    }
}
