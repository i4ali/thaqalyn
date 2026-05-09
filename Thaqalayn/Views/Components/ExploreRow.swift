//
//  ExploreRow.swift
//  Thaqalayn
//
//  Reusable row component for Explore tab
//

import SwiftUI

struct ExploreRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(themeManager.accentGradient)
                            .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6)
                    }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                // Chevron
                Text(">")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()

        VStack(spacing: 0) {
            ExploreRow(
                icon: "heart.fill",
                title: "Life Moments",
                subtitle: "Find solace for any situation"
            ) {
                print("Tapped")
            }

            Divider()

            ExploreRow(
                icon: "questionmark.circle",
                title: "Questions & Answers",
                subtitle: "Quranic answers to questions"
            ) {
                print("Tapped")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}
