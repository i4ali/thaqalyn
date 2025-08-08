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
        selectedTheme == .modernDark
    }
    
    private init() {
        // Check for existing theme preference, default to modernDark
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ThemeVariant(rawValue: savedTheme) {
            self.selectedTheme = theme
        } else if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
            // Migrate from old boolean system
            let wasLight = !UserDefaults.standard.bool(forKey: "isDarkMode")
            self.selectedTheme = wasLight ? .modernLight : .modernDark
            UserDefaults.standard.removeObject(forKey: "isDarkMode")
        } else {
            self.selectedTheme = .modernDark
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
        selectedTheme == .modernDark ? .dark : .light
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
        case .classicLight, .sepia:
            return accentGradient // Use accent gradient for classic themes
        }
    }
    
    // Material effects
    var glassEffect: Material {
        switch selectedTheme {
        case .modernDark:
            return .ultraThinMaterial
        case .modernLight:
            return .thin
        case .classicLight, .sepia:
            return .ultraThin // Subtle glass effect for traditional themes
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
        }
    }
}