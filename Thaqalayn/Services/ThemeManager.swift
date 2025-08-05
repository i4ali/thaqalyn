//
//  ThemeManager.swift
//  Thaqalayn
//
//  Theme management for light/dark mode switching
//

import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    private init() {
        // Default to dark mode for first launch
        if UserDefaults.standard.object(forKey: "isDarkMode") == nil {
            self.isDarkMode = true
            UserDefaults.standard.set(true, forKey: "isDarkMode")
        } else {
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
    }
    
    // MARK: - Color Schemes
    
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
    
    // Background colors
    var primaryBackground: Color {
        isDarkMode 
            ? Color(red: 0.06, green: 0.09, blue: 0.16) // #0f172a
            : Color(red: 0.98, green: 0.98, blue: 0.99) // #fafafa
    }
    
    var secondaryBackground: Color {
        isDarkMode
            ? Color(red: 0.12, green: 0.16, blue: 0.23) // #1e293b
            : Color(red: 0.95, green: 0.95, blue: 0.97) // #f1f5f9
    }
    
    var tertiaryBackground: Color {
        isDarkMode
            ? Color(red: 0.2, green: 0.25, blue: 0.33)  // #334155
            : Color(red: 0.89, green: 0.91, blue: 0.94) // #e2e8f0
    }
    
    // Text colors
    var primaryText: Color {
        isDarkMode ? .white : Color(red: 0.06, green: 0.09, blue: 0.16)
    }
    
    var secondaryText: Color {
        isDarkMode ? .white.opacity(0.7) : Color(red: 0.2, green: 0.25, blue: 0.33).opacity(0.8)
    }
    
    var tertiaryText: Color {
        isDarkMode ? .white.opacity(0.6) : Color(red: 0.2, green: 0.25, blue: 0.33).opacity(0.6)
    }
    
    // Gradient colors remain the same for both themes
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.39, green: 0.4, blue: 0.95),  // #6366f1
                Color(red: 0.93, green: 0.28, blue: 0.6)   // #ec4899
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var purpleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.39, green: 0.4, blue: 0.95),  // #6366f1
                Color(red: 0.55, green: 0.36, blue: 0.96)  // #8b5cf6
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Material effects
    var glassEffect: Material {
        isDarkMode ? .ultraThinMaterial : .thin
    }
    
    var strokeColor: Color {
        isDarkMode ? .white.opacity(0.1) : .black.opacity(0.1)
    }
    
    // Floating orb colors for background
    var floatingOrbColors: [Color] {
        if isDarkMode {
            return [
                Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3),  // #6366f1
                Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3),  // #ec4899
                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.3)  // #8b5cf6
            ]
        } else {
            return [
                Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.15),  // Lighter opacity for light mode
                Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.15),
                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.15)
            ]
        }
    }
}