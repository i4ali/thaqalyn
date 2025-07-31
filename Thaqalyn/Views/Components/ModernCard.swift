//
//  ModernCard.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct ModernCard<Content: View>: View {
    let content: Content
    var backgroundColor: Color = .white
    var cornerRadius: CGFloat = ThaqalynDesignSystem.CornerRadius.lg
    var shadowIntensity: ShadowIntensity = .medium
    
    enum ShadowIntensity {
        case light, medium, heavy
        
        var config: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            switch self {
            case .light:
                return ThaqalynDesignSystem.Shadow.light
            case .medium:
                return ThaqalynDesignSystem.Shadow.medium
            case .heavy:
                return ThaqalynDesignSystem.Shadow.heavy
            }
        }
    }
    
    init(
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = ThaqalynDesignSystem.CornerRadius.lg,
        shadowIntensity: ShadowIntensity = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowIntensity = shadowIntensity
        self.content = content()
    }
    
    var body: some View {
        content
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: shadowIntensity.config.color,
                radius: shadowIntensity.config.radius,
                x: shadowIntensity.config.x,
                y: shadowIntensity.config.y
            )
    }
}

#Preview {
    VStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
        ModernCard {
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.sm) {
                Text("Al-Fatihah")
                    .font(ThaqalynDesignSystem.Typography.headlineFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                
                Text("The Opening")
                    .font(ThaqalynDesignSystem.Typography.bodyFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                
                Text("7 verses")
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        ModernCard(shadowIntensity: .light) {
            VStack {
                Text("Light Shadow Card")
                    .font(ThaqalynDesignSystem.Typography.calloutFont)
                    .padding(ThaqalynDesignSystem.Spacing.md)
            }
        }
        
        ModernCard(shadowIntensity: .heavy) {
            VStack {
                Text("Heavy Shadow Card")
                    .font(ThaqalynDesignSystem.Typography.calloutFont)
                    .padding(ThaqalynDesignSystem.Spacing.md)
            }
        }
    }
    .padding(ThaqalynDesignSystem.Spacing.lg)
    .background(ThaqalynDesignSystem.Colors.backgroundGray)
}