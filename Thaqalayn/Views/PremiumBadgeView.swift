//
//  PremiumBadgeView.swift
//  Thaqalayn
//
//  Lock icon indicator for premium content
//

import SwiftUI

struct PremiumBadgeView: View {
    @StateObject private var themeManager = ThemeManager.shared

    var size: BadgeSize = .medium

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: iconSize))
                .foregroundColor(badgeColor)

            if size != .small {
                Text("Premium")
                    .font(.system(size: textSize, weight: .semibold))
                    .foregroundColor(badgeColor)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(badgeColor.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(badgeColor.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Size Configuration

    enum BadgeSize {
        case small, medium, large
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }

    private var textSize: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 3
        case .medium: return 4
        case .large: return 5
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }

    private var badgeColor: Color {
        return .yellow
    }
}

// MARK: - Variant with Custom Text

struct PremiumBadgeWithText: View {
    @StateObject private var themeManager = ThemeManager.shared

    let text: String
    let size: PremiumBadgeView.BadgeSize

    init(text: String = "Unlock", size: PremiumBadgeView.BadgeSize = .medium) {
        self.text = text
        self.size = size
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: iconSize))
                .foregroundColor(.yellow)

            Text(text)
                .font(.system(size: textSize, weight: .semibold))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.yellow.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }

    private var textSize: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 3
        case .medium: return 4
        case .large: return 5
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PremiumBadgeView(size: .small)
        PremiumBadgeView(size: .medium)
        PremiumBadgeView(size: .large)

        PremiumBadgeWithText(text: "Unlock Commentary", size: .large)
    }
    .padding()
    .background(Color.black)
}
