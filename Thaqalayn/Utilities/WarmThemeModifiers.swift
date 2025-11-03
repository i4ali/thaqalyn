//
//  WarmThemeModifiers.swift
//  Thaqalayn
//
//  Custom view modifiers and extensions for Warm & Inviting theme
//

import SwiftUI

// MARK: - View Modifiers

extension View {
    /// Applies warm theme card styling with rounded corners and soft shadow
    func warmCardStyle(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 12,
                x: 0,
                y: 4
            )
    }

    /// Applies generous warm theme padding (24-28px)
    func warmPadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, 24)
    }

    /// Applies warm theme button style with gradient
    func warmButtonStyle(gradient: LinearGradient) -> some View {
        self
            .background(gradient)
            .cornerRadius(24)
            .shadow(
                color: Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
    }

    /// Applies circular badge style with gradient
    func warmCircularBadge(size: CGFloat = 56, gradient: LinearGradient) -> some View {
        self
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(gradient)
                    .shadow(
                        color: Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.4),
                        radius: 8
                    )
            )
    }

    /// Applies warm theme stat card styling
    func warmStatCardStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(20)
            .shadow(
                color: Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.15),
                radius: 12,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Font Extensions

extension Font {
    /// Large title for warm theme (34px, bold, rounded)
    static func warmTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }

    /// Headline for warm theme (20px, semibold, rounded)
    static func warmHeadline() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }

    /// Subheadline for warm theme (18px, medium, rounded)
    static func warmSubheadline() -> Font {
        .system(size: 18, weight: .medium, design: .rounded)
    }

    /// Body text for warm theme (17px, regular, rounded)
    static func warmBody() -> Font {
        .system(size: 17, weight: .regular, design: .rounded)
    }

    /// Caption for warm theme (14px, medium, rounded)
    static func warmCaption() -> Font {
        .system(size: 14, weight: .medium, design: .rounded)
    }

    /// Small caption for warm theme (12px, medium, rounded)
    static func warmSmallCaption() -> Font {
        .system(size: 12, weight: .medium, design: .rounded)
    }

    /// Arabic text for warm theme (24-32px, medium)
    static func warmArabic(size: CGFloat = 26) -> Font {
        .system(size: size, weight: .medium)
    }
}

// MARK: - Color Extensions

extension Color {
    // Primary Colors
    static let warmPurple = Color(red: 0.608, green: 0.561, blue: 0.749)      // #9B8FBF
    static let warmPurpleDark = Color(red: 0.545, green: 0.498, blue: 0.659)  // #8B7FA8
    static let warmOrange = Color(red: 0.91, green: 0.604, blue: 0.435)       // #E89A6F
    static let warmOrangeDark = Color(red: 0.847, green: 0.541, blue: 0.373)  // #D88A5F
    static let warmGreen = Color(red: 0.498, green: 0.722, blue: 0.604)       // #7FB89A

    // Text Colors
    static let warmCharcoal = Color(red: 0.176, green: 0.145, blue: 0.125)    // #2D2520
    static let warmGray = Color(red: 0.42, green: 0.365, blue: 0.329)         // #6B5D54
    static let warmLightGray = Color(red: 0.69, green: 0.64, blue: 0.6)       // #B0A399

    // Background Colors
    static let warmLavender = Color(red: 0.97, green: 0.96, blue: 1.0)        // #F8F5FF
    static let warmWhite = Color(red: 1.0, green: 0.98, blue: 0.96)           // #FFF9F5
    static let warmCream = Color(red: 1.0, green: 0.976, blue: 0.941)         // #FFFBF5

    /// Creates a warm purple gradient
    static let warmPurpleGradient = LinearGradient(
        colors: [warmPurple, warmPurpleDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Creates a warm orange gradient
    static let warmOrangeGradient = LinearGradient(
        colors: [warmOrange, warmOrangeDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Convenience initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shape Extensions

extension RoundedRectangle {
    /// Creates a warm theme card shape with 20px radius
    static func warmCard() -> RoundedRectangle {
        RoundedRectangle(cornerRadius: 20)
    }

    /// Creates a warm theme pill shape with 24px radius
    static func warmPill() -> RoundedRectangle {
        RoundedRectangle(cornerRadius: 24)
    }

    /// Creates a warm theme button shape with 12px radius
    static func warmButton() -> RoundedRectangle {
        RoundedRectangle(cornerRadius: 12)
    }
}

// MARK: - Spacing Constants

enum WarmSpacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let regular: CGFloat = 16
    static let large: CGFloat = 20
    static let generous: CGFloat = 24
    static let extraGenerous: CGFloat = 28
    static let huge: CGFloat = 32
}

// MARK: - Corner Radius Constants

enum WarmRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let pill: CGFloat = 24
}
