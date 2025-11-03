//
//  ThemeManager.swift
//  Thaqalayn
//
//  Theme management for multiple app themes
//

import SwiftUI

enum ThemeVariant: String, CaseIterable {
    case modernDark = "modernDark"
    case modernLight = "modernLight"
    case classicLight = "classicLight"
    case sepia = "sepia"
    case nightMode = "nightMode"
    case mushaf = "mushaf"
    case desertSand = "desertSand"
    case emeraldClassic = "emeraldClassic"
    case highContrast = "highContrast"
    case blueLightFilter = "blueLightFilter"
    case royalAmethyst = "royalAmethyst"
    case warmInviting = "warmInviting"
    
    var displayName: String {
        switch self {
        case .modernDark:
            return "Modern Dark"
        case .modernLight:
            return "Modern Light"
        case .classicLight:
            return "Traditional Manuscript"
        case .sepia:
            return "Sepia"
        case .nightMode:
            return "Night Mode"
        case .mushaf:
            return "Mus'haf"
        case .desertSand:
            return "Desert Sand"
        case .emeraldClassic:
            return "Emerald Classic"
        case .highContrast:
            return "High Contrast"
        case .blueLightFilter:
            return "Blue Light Filter"
        case .royalAmethyst:
            return "Royal Amethyst"
        case .warmInviting:
            return "Warm & Inviting"
        }
    }
    
    var description: String {
        switch self {
        case .modernDark:
            return "Dark glassmorphism design"
        case .modernLight:
            return "Light glassmorphism design"
        case .classicLight:
            return "Classic manuscript style"
        case .sepia:
            return "Warm, easy on the eyes"
        case .nightMode:
            return "Pure black for OLED displays"
        case .mushaf:
            return "Traditional Quranic manuscript"
        case .desertSand:
            return "Warm sand color, reduces blue light"
        case .emeraldClassic:
            return "Restful green, easy on eyes"
        case .highContrast:
            return "Maximum readability"
        case .blueLightFilter:
            return "Evening reading mode"
        case .royalAmethyst:
            return "Luxurious purple with gold accents"
        case .warmInviting:
            return "Sanctuary-like warm design"
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
        selectedTheme == .modernDark || selectedTheme == .nightMode
    }
    
    private init() {
        // Check for existing theme preference, default to warmInviting
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ThemeVariant(rawValue: savedTheme) {
            self.selectedTheme = theme
        } else if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
            // Migrate from old boolean system
            let wasLight = !UserDefaults.standard.bool(forKey: "isDarkMode")
            self.selectedTheme = wasLight ? .modernLight : .modernDark
            UserDefaults.standard.removeObject(forKey: "isDarkMode")
        } else {
            self.selectedTheme = .warmInviting
        }
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTheme = selectedTheme == .modernDark ? .modernLight : .modernDark
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
        case .modernDark, .nightMode, .royalAmethyst:
            return .dark
        default:
            return .light
        }
    }
    
    // Background colors
    var primaryBackground: Color {
        switch selectedTheme {
        case .modernDark:
            return Color(red: 0.06, green: 0.09, blue: 0.16) // #0f172a
        case .modernLight:
            return Color(red: 0.98, green: 0.98, blue: 0.99) // #fafafa
        case .classicLight:
            return Color(red: 0.85, green: 0.92, blue: 0.78) // #d9eac7 - greenish manuscript background
        case .sepia:
            return Color(red: 0.97, green: 0.94, blue: 0.83) // #f7f0d4 - warm sepia
        case .nightMode:
            return Color(red: 0.0, green: 0.0, blue: 0.0) // #000000 - pure black for OLED
        case .mushaf:
            return Color(red: 0.97, green: 0.96, blue: 0.91) // #f8f6e8 - cream manuscript
        case .desertSand:
            return Color(red: 0.96, green: 0.89, blue: 0.74) // #f4e4bc - warm sand
        case .emeraldClassic:
            return Color(red: 0.94, green: 0.97, blue: 0.94) // #f0f8f0 - very light mint
        case .highContrast:
            return Color(red: 1.0, green: 1.0, blue: 1.0) // #ffffff - pure white
        case .blueLightFilter:
            return Color(red: 0.99, green: 0.96, blue: 0.89) // #fdf6e3 - warm white with yellow tint
        case .royalAmethyst:
            return Color(red: 0.25, green: 0.14, blue: 0.26) // #3f2342 - rich purple-burgundy
        case .warmInviting:
            return Color(red: 0.973, green: 0.961, blue: 1.0) // #F8F5FF - Soft Lavender (top of gradient)
        }
    }

    var secondaryBackground: Color {
        switch selectedTheme {
        case .modernDark:
            return Color(red: 0.12, green: 0.16, blue: 0.23) // #1e293b
        case .modernLight:
            return Color(red: 0.95, green: 0.95, blue: 0.97) // #f1f5f9
        case .classicLight:
            return Color(red: 0.80, green: 0.88, blue: 0.72) // #ccdfb8 - slightly darker greenish manuscript
        case .sepia:
            return Color(red: 0.94, green: 0.90, blue: 0.78) // #f0e6c7 - deeper sepia
        case .nightMode:
            return Color(red: 0.05, green: 0.05, blue: 0.05) // #0d0d0d - very dark gray
        case .mushaf:
            return Color(red: 0.94, green: 0.92, blue: 0.86) // #f0eedb - darker cream
        case .desertSand:
            return Color(red: 0.93, green: 0.85, blue: 0.68) // #edd9ad - deeper sand
        case .emeraldClassic:
            return Color(red: 0.89, green: 0.94, blue: 0.89) // #e3f0e3 - light mint
        case .highContrast:
            return Color(red: 0.96, green: 0.96, blue: 0.96) // #f5f5f5 - light gray
        case .blueLightFilter:
            return Color(red: 0.96, green: 0.92, blue: 0.84) // #f5ebd6 - warmer cream
        case .royalAmethyst:
            return Color(red: 0.40, green: 0.27, blue: 0.36) // #66455c - mauve-rose purple
        case .warmInviting:
            return Color(red: 0.987, green: 0.969, blue: 0.980) // #FBFBFA - middle blend of lavender and warm white
        }
    }

    var tertiaryBackground: Color {
        switch selectedTheme {
        case .modernDark:
            return Color(red: 0.2, green: 0.25, blue: 0.33)  // #334155
        case .modernLight:
            return Color(red: 0.89, green: 0.91, blue: 0.94) // #e2e8f0
        case .classicLight:
            return Color(red: 0.75, green: 0.84, blue: 0.66) // #bfd6a8 - greenish manuscript border
        case .sepia:
            return Color(red: 0.88, green: 0.82, blue: 0.68) // #e1d1ad - rich sepia
        case .nightMode:
            return Color(red: 0.1, green: 0.1, blue: 0.1) // #1a1a1a - dark gray
        case .mushaf:
            return Color(red: 0.90, green: 0.87, blue: 0.80) // #e6deccb - medium cream
        case .desertSand:
            return Color(red: 0.89, green: 0.80, blue: 0.62) // #e3cc9e - medium sand
        case .emeraldClassic:
            return Color(red: 0.84, green: 0.91, blue: 0.84) // #d6e8d6 - medium mint
        case .highContrast:
            return Color(red: 0.90, green: 0.90, blue: 0.90) // #e5e5e5 - medium gray
        case .blueLightFilter:
            return Color(red: 0.93, green: 0.88, blue: 0.79) // #ede0c9 - medium warm
        case .royalAmethyst:
            return Color(red: 0.51, green: 0.35, blue: 0.44) // #825970 - warm mauve
        case .warmInviting:
            return Color(red: 1.0, green: 0.976, blue: 0.961) // #FFF9F5 - Warm White (bottom of gradient)
        }
    }
    
    // Text colors
    var primaryText: Color {
        switch selectedTheme {
        case .modernDark:
            return .white
        case .modernLight:
            return Color(red: 0.06, green: 0.09, blue: 0.16)
        case .classicLight:
            return Color(red: 0.15, green: 0.10, blue: 0.05) // #261a0d - rich manuscript brown
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08) // #332614 - sepia brown
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86) // #f5f5dc - soft white with amber tint
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23) // #1b1b3b - deep indigo
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09) // #4a2c17 - dark brown with red tint
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20) // #1b4332 - deep forest green
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0) // #000000 - pure black
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13) // #654321 - dark brown
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70) // #fae8b3 - bright champagne gold
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125) // #2D2520 - warm charcoal
        }
    }
    
    var secondaryText: Color {
        switch selectedTheme {
        case .modernDark:
            return .white.opacity(0.7)
        case .modernLight:
            return Color(red: 0.2, green: 0.25, blue: 0.33).opacity(0.8)
        case .classicLight:
            return Color(red: 0.13, green: 0.09, blue: 0.05).opacity(0.75) // softer dark brown
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08).opacity(0.8) // softer sepia
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.7) // softer amber white
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23).opacity(0.8) // softer indigo
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09).opacity(0.8) // softer brown
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20).opacity(0.8) // softer green
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0).opacity(0.7) // softer black
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13).opacity(0.8) // softer brown
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.85) // softer bright gold
        case .warmInviting:
            return Color(red: 0.42, green: 0.365, blue: 0.329) // #6B5D54 - soft gray
        }
    }
    
    var tertiaryText: Color {
        switch selectedTheme {
        case .modernDark:
            return .white.opacity(0.6)
        case .modernLight:
            return Color(red: 0.2, green: 0.25, blue: 0.33).opacity(0.6)
        case .classicLight:
            return Color(red: 0.13, green: 0.09, blue: 0.05).opacity(0.6) // lighter brown
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08).opacity(0.65) // lighter sepia
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.5) // lighter amber white
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23).opacity(0.65) // lighter indigo
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09).opacity(0.65) // lighter brown
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20).opacity(0.65) // lighter green
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0).opacity(0.5) // lighter black
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13).opacity(0.65) // lighter brown
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.72) // lighter bright gold
        case .warmInviting:
            return Color(red: 0.69, green: 0.64, blue: 0.6) // #B0A399 - light gray for placeholders
        }
    }
    
    // Theme-appropriate gradients
    var accentGradient: LinearGradient {
        switch selectedTheme {
        case .modernDark, .modernLight:
            return LinearGradient(
                colors: [
                    Color(red: 0.39, green: 0.4, blue: 0.95),  // #6366f1
                    Color(red: 0.93, green: 0.28, blue: 0.6)   // #ec4899
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classicLight:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.3),    // Manuscript green
                    Color(red: 0.4, green: 0.6, blue: 0.2)     // Light greenish
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sepia:
            return LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.35, blue: 0.15), // Rich brown
                    Color(red: 0.75, green: 0.55, blue: 0.25)  // Warm golden
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nightMode:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.84, blue: 0.0),   // #ffd700 - gold
                    Color(red: 1.0, green: 0.65, blue: 0.0)    // #ffa500 - orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mushaf:
            return LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.35, blue: 0.52), // Traditional Islamic blue
                    Color(red: 0.25, green: 0.41, blue: 0.58)  // Lighter blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .desertSand:
            return LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.52, blue: 0.25), // Terracotta
                    Color(red: 0.87, green: 0.59, blue: 0.32)  // Clay
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .emeraldClassic:
            return LinearGradient(
                colors: [
                    Color(red: 0.31, green: 0.78, blue: 0.47), // Emerald
                    Color(red: 0.20, green: 0.60, blue: 0.35)  // Forest green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .highContrast:
            return LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.4, blue: 0.8),    // Royal blue
                    Color(red: 0.0, green: 0.3, blue: 0.6)     // Darker blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blueLightFilter:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.55, blue: 0.0),   // Orange
                    Color(red: 0.85, green: 0.45, blue: 0.0)   // Darker orange
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
        case .warmInviting:
            return LinearGradient(
                colors: [
                    Color(red: 0.91, green: 0.604, blue: 0.435), // #E89A6F - sunset orange
                    Color(red: 0.847, green: 0.541, blue: 0.373)  // #D88A5F - deeper orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var accentColor: Color {
        switch selectedTheme {
        case .modernDark, .modernLight:
            return Color(red: 0.39, green: 0.4, blue: 0.95)
        case .classicLight:
            return Color(red: 0.2, green: 0.5, blue: 0.3)
        case .sepia:
            return Color(red: 0.55, green: 0.35, blue: 0.15)
        case .nightMode:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .mushaf:
            return Color(red: 0.18, green: 0.35, blue: 0.52)
        case .desertSand:
            return Color(red: 0.80, green: 0.52, blue: 0.25)
        case .emeraldClassic:
            return Color(red: 0.31, green: 0.78, blue: 0.47)
        case .highContrast:
            return Color(red: 0.0, green: 0.4, blue: 0.8)
        case .blueLightFilter:
            return Color(red: 1.0, green: 0.55, blue: 0.0)
        case .royalAmethyst:
            return Color(red: 0.88, green: 0.70, blue: 0.50) // #e0b37f - warm golden rose
        case .warmInviting:
            return Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF - peaceful purple
        }
    }

    var purpleGradient: LinearGradient {
        switch selectedTheme {
        case .modernDark, .modernLight:
            return LinearGradient(
                colors: [
                    Color(red: 0.39, green: 0.4, blue: 0.95),  // #6366f1
                    Color(red: 0.55, green: 0.36, blue: 0.96)  // #8b5cf6
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warmInviting:
            return LinearGradient(
                colors: [
                    Color(red: 0.608, green: 0.561, blue: 0.749), // #9B8FBF - peaceful purple
                    Color(red: 0.545, green: 0.498, blue: 0.659)  // #8B7FA8 - deeper purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classicLight, .sepia, .nightMode, .mushaf, .desertSand, .emeraldClassic, .highContrast, .blueLightFilter, .royalAmethyst:
            return accentGradient // Use accent gradient for all non-modern themes
        }
    }
    
    // Material effects
    var glassEffect: Material {
        switch selectedTheme {
        case .modernDark:
            return .ultraThinMaterial
        case .modernLight:
            return .thin
        case .classicLight, .sepia, .mushaf, .desertSand, .emeraldClassic, .blueLightFilter:
            return .ultraThin // Subtle glass effect for traditional themes
        case .nightMode, .royalAmethyst:
            return .ultraThinMaterial // Dark material for night mode and royal amethyst
        case .highContrast:
            return .regular // More visible material for high contrast
        case .warmInviting:
            return .ultraThin // Very subtle for warm sanctuary feel
        }
    }
    
    var strokeColor: Color {
        switch selectedTheme {
        case .modernDark:
            return .white.opacity(0.1)
        case .modernLight:
            return .black.opacity(0.1)
        case .classicLight:
            return Color(red: 0.13, green: 0.09, blue: 0.05).opacity(0.15) // Brown stroke
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08).opacity(0.2) // Sepia stroke
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.1) // Amber stroke
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23).opacity(0.15) // Indigo stroke
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09).opacity(0.2) // Brown stroke
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20).opacity(0.2) // Green stroke
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0).opacity(0.3) // Strong black stroke
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13).opacity(0.2) // Brown stroke
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.15) // Bright gold stroke
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.1) // Very subtle warm charcoal stroke
        }
    }
    
    // Floating orb colors for background
    var floatingOrbColors: [Color] {
        switch selectedTheme {
        case .modernDark:
            return [
                Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3),  // #6366f1
                Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3),  // #ec4899
                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.3)  // #8b5cf6
            ]
        case .modernLight:
            return [
                Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.15),  // Lighter opacity for light mode
                Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.15),
                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.15)
            ]
        case .classicLight:
            return [
                Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.08),   // Soft manuscript green
                Color(red: 0.4, green: 0.6, blue: 0.2).opacity(0.06),   // Light greenish
                Color(red: 0.5, green: 0.6, blue: 0.4).opacity(0.05)    // Muted green-brown
            ]
        case .sepia:
            return [
                Color(red: 0.55, green: 0.35, blue: 0.15).opacity(0.1), // Warm brown
                Color(red: 0.75, green: 0.55, blue: 0.25).opacity(0.08), // Golden sepia
                Color(red: 0.65, green: 0.45, blue: 0.20).opacity(0.06)  // Medium sepia
            ]
        case .nightMode:
            return [
                Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.15),  // Gold
                Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.12),  // Orange
                Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.08) // Amber white
            ]
        case .mushaf:
            return [
                Color(red: 0.18, green: 0.35, blue: 0.52).opacity(0.08), // Islamic blue
                Color(red: 0.25, green: 0.41, blue: 0.58).opacity(0.06), // Lighter blue
                Color(red: 0.11, green: 0.11, blue: 0.23).opacity(0.05)  // Indigo
            ]
        case .desertSand:
            return [
                Color(red: 0.80, green: 0.52, blue: 0.25).opacity(0.08), // Terracotta
                Color(red: 0.87, green: 0.59, blue: 0.32).opacity(0.06), // Clay
                Color(red: 0.29, green: 0.17, blue: 0.09).opacity(0.05)  // Dark brown
            ]
        case .emeraldClassic:
            return [
                Color(red: 0.31, green: 0.78, blue: 0.47).opacity(0.08), // Emerald
                Color(red: 0.20, green: 0.60, blue: 0.35).opacity(0.06), // Forest green
                Color(red: 0.11, green: 0.26, blue: 0.20).opacity(0.05)  // Deep green
            ]
        case .highContrast:
            return [
                Color(red: 0.0, green: 0.4, blue: 0.8).opacity(0.1),    // Royal blue
                Color(red: 0.0, green: 0.3, blue: 0.6).opacity(0.08),   // Darker blue
                Color(red: 0.0, green: 0.0, blue: 0.0).opacity(0.05)    // Black
            ]
        case .blueLightFilter:
            return [
                Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.08),  // Orange
                Color(red: 0.85, green: 0.45, blue: 0.0).opacity(0.06), // Darker orange
                Color(red: 0.40, green: 0.26, blue: 0.13).opacity(0.05) // Brown
            ]
        case .royalAmethyst:
            return [
                Color(red: 0.65, green: 0.38, blue: 0.58).opacity(0.01), // Vibrant mauve-purple (reduced)
                Color(red: 0.87, green: 0.52, blue: 0.48).opacity(0.01), // Warm rose-gold (reduced)
                Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.01)  // Bright champagne gold (reduced)
            ]
        case .warmInviting:
            return [
                Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.06), // Peaceful purple (subtle)
                Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.05),  // Sunset orange (very subtle)
                Color(red: 0.498, green: 0.722, blue: 0.604).opacity(0.04)  // Serene green (barely visible)
            ]
        }
    }
}