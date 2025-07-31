//
//  ThaqalynDesignSystem.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct ThaqalynDesignSystem {
    
    // MARK: - Colors
    
    struct Colors {
        static let primaryBlue = Color(hex: "007AFF")
        static let secondaryGray = Color(hex: "8E8E93")
        static let backgroundGray = Color(hex: "F2F2F7")
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let accent = Color.accentColor
        
        // Islamic-inspired accent colors
        static let islamicGreen = Color(hex: "00A86B")
        static let goldAccent = Color(hex: "FFD700")
        static let deepBlue = Color(hex: "003366")
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primaryBlue, Color(hex: "5856D6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let islamic = LinearGradient(
            colors: [Colors.islamicGreen, Colors.deepBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let background = LinearGradient(
            colors: [Colors.backgroundGray, Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let largeTitleFont = Font.system(size: 34, weight: .bold, design: .default)
        static let titleFont = Font.system(size: 28, weight: .semibold, design: .default)
        static let headlineFont = Font.system(size: 22, weight: .semibold, design: .default)
        static let bodyFont = Font.system(size: 17, weight: .regular, design: .default)
        static let calloutFont = Font.system(size: 16, weight: .medium, design: .default)
        static let captionFont = Font.system(size: 12, weight: .regular, design: .default)
        
        // Arabic text fonts
        static let arabicLargeFont = Font.system(size: 24, weight: .medium, design: .serif)
        static let arabicBodyFont = Font.system(size: 20, weight: .regular, design: .serif)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Shadow
    
    struct Shadow {
        static let light = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let heavy = (color: Color.black.opacity(0.25), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
}

// MARK: - Color Extension

extension Color {
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

// MARK: - View Extensions for Design System

extension View {
    func modernCardStyle() -> some View {
        self
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.lg))
            .shadow(
                color: ThaqalynDesignSystem.Shadow.medium.color,
                radius: ThaqalynDesignSystem.Shadow.medium.radius,
                x: ThaqalynDesignSystem.Shadow.medium.x,
                y: ThaqalynDesignSystem.Shadow.medium.y
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(ThaqalynDesignSystem.Typography.calloutFont)
            .foregroundColor(.white)
            .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
            .padding(.vertical, ThaqalynDesignSystem.Spacing.md)
            .background(ThaqalynDesignSystem.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.md))
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(ThaqalynDesignSystem.Typography.calloutFont)
            .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
            .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
            .padding(.vertical, ThaqalynDesignSystem.Spacing.md)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.md)
                    .stroke(ThaqalynDesignSystem.Colors.primaryBlue, lineWidth: 1)
            )
    }
}