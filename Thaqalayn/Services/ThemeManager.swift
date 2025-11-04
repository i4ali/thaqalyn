//
//  ThemeManager.swift
//  Thaqalayn
//
//  Theme management for multiple app themes
//

import SwiftUI

enum ThemeVariant: String, CaseIterable {
    case warmInviting = "warmInviting"
    case royalAmethyst = "royalAmethyst"
    case modernDark = "modernDark"

    var displayName: String {
        switch self {
        case .warmInviting:
            return "Warm & Inviting"
        case .royalAmethyst:
            return "Royal Amethyst"
        case .modernDark:
            return "Modern Dark"
        }
    }

    var description: String {
        switch self {
        case .warmInviting:
            return "Sanctuary-like warm design"
        case .royalAmethyst:
            return "Luxurious purple with gold accents"
        case .modernDark:
            return "Dark glassmorphism design"
        }
    }
}

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var selectedTheme: ThemeVariant {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    // Backward compatibility for isDarkMode
    var isDarkMode: Bool {
        selectedTheme == .modernDark || selectedTheme == .royalAmethyst
    }

    private init() {
        // Check for existing theme preference, default to warmInviting
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ThemeVariant(rawValue: savedTheme) {
            self.selectedTheme = theme
        } else {
            // Default to warmInviting for new users or removed themes
            self.selectedTheme = .warmInviting
            UserDefaults.standard.removeObject(forKey: "isDarkMode")
        }
    }
    
    func setTheme(_ theme: ThemeVariant) {
        withAnimation(.easeInOut(duration: 0.5)) {
            selectedTheme = theme
        }
    }
    
    // MARK: - Color Schemes

    var colorScheme: ColorScheme {
        switch selectedTheme {
        case .modernDark, .royalAmethyst:
            return .dark
        case .warmInviting:
            return .light
        }
    }
    
    // Background colors
    var primaryBackground: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.973, green: 0.961, blue: 1.0) // #F8F5FF - Soft Lavender
        case .royalAmethyst:
            return Color(red: 0.25, green: 0.14, blue: 0.26) // #3f2342 - rich purple-burgundy
        case .modernDark:
            return Color(red: 0.06, green: 0.09, blue: 0.16) // #0f172a
        }
    }

    var secondaryBackground: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.987, green: 0.969, blue: 0.980) // #FBFBFA - middle blend
        case .royalAmethyst:
            return Color(red: 0.40, green: 0.27, blue: 0.36) // #66455c - mauve-rose purple
        case .modernDark:
            return Color(red: 0.12, green: 0.16, blue: 0.23) // #1e293b
        }
    }

    var tertiaryBackground: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 1.0, green: 0.976, blue: 0.961) // #FFF9F5 - Warm White
        case .royalAmethyst:
            return Color(red: 0.51, green: 0.35, blue: 0.44) // #825970 - warm mauve
        case .modernDark:
            return Color(red: 0.2, green: 0.25, blue: 0.33)  // #334155
        }
    }
    
    // Text colors
    var primaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125) // #2D2520 - warm charcoal
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70) // #fae8b3 - bright champagne gold
        case .modernDark:
            return .white
        }
    }

    var secondaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.42, green: 0.365, blue: 0.329) // #6B5D54 - soft gray
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.85) // softer bright gold
        case .modernDark:
            return .white.opacity(0.7)
        }
    }

    var tertiaryText: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.69, green: 0.64, blue: 0.6) // #B0A399 - light gray
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.72) // lighter bright gold
        case .modernDark:
            return .white.opacity(0.6)
        }
    }
    
    // Theme-appropriate gradients
    var accentGradient: LinearGradient {
        switch selectedTheme {
        case .warmInviting:
            return LinearGradient(
                colors: [
                    Color(red: 0.91, green: 0.604, blue: 0.435), // #E89A6F - sunset orange
                    Color(red: 0.847, green: 0.541, blue: 0.373)  // #D88A5F - deeper orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .royalAmethyst:
            return LinearGradient(
                colors: [
                    Color(red: 0.65, green: 0.38, blue: 0.58), // Vibrant mauve-purple
                    Color(red: 0.87, green: 0.52, blue: 0.48)  // Warm rose-gold
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .modernDark:
            return LinearGradient(
                colors: [
                    Color(red: 0.39, green: 0.4, blue: 0.95),  // #6366f1
                    Color(red: 0.93, green: 0.28, blue: 0.6)   // #ec4899
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var accentColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF - peaceful purple
        case .royalAmethyst:
            return Color(red: 0.88, green: 0.70, blue: 0.50) // #e0b37f - warm golden rose
        case .modernDark:
            return Color(red: 0.39, green: 0.4, blue: 0.95)
        }
    }

    var purpleGradient: LinearGradient {
        switch selectedTheme {
        case .warmInviting:
            return LinearGradient(
                colors: [
                    Color(red: 0.608, green: 0.561, blue: 0.749), // #9B8FBF - peaceful purple
                    Color(red: 0.545, green: 0.498, blue: 0.659)  // #8B7FA8 - deeper purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .royalAmethyst, .modernDark:
            return LinearGradient(
                colors: [
                    Color(red: 0.39, green: 0.4, blue: 0.95),  // #6366f1
                    Color(red: 0.55, green: 0.36, blue: 0.96)  // #8b5cf6
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Material effects
    var glassEffect: Material {
        switch selectedTheme {
        case .warmInviting:
            return .ultraThin // Very subtle for warm sanctuary feel
        case .royalAmethyst:
            return .ultraThinMaterial // Dark material for royal amethyst
        case .modernDark:
            return .ultraThinMaterial
        }
    }

    var strokeColor: Color {
        switch selectedTheme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.1) // Very subtle warm charcoal
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.15) // Bright gold stroke
        case .modernDark:
            return .white.opacity(0.1)
        }
    }
    
    // Floating orb colors for background
    var floatingOrbColors: [Color] {
        switch selectedTheme {
        case .warmInviting:
            return [
                Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.06), // Peaceful purple (subtle)
                Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.05),  // Sunset orange (very subtle)
                Color(red: 0.498, green: 0.722, blue: 0.604).opacity(0.04)  // Serene green (barely visible)
            ]
        case .royalAmethyst:
            return [
                Color(red: 0.65, green: 0.38, blue: 0.58).opacity(0.01), // Vibrant mauve-purple (reduced)
                Color(red: 0.87, green: 0.52, blue: 0.48).opacity(0.01), // Warm rose-gold (reduced)
                Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.01)  // Bright champagne gold (reduced)
            ]
        case .modernDark:
            return [
                Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3),  // #6366f1
                Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3),  // #ec4899
                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.3)  // #8b5cf6
            ]
        }
    }
}