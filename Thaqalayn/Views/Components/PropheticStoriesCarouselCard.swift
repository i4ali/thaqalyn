//
//  PropheticStoriesCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Prophetic Stories feature in Discovery Carousel
//

import SwiftUI

struct PropheticStoriesCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var storiesManager = PropheticStoriesManager.shared

    var previewStories: [PropheticStory] {
        Array(storiesManager.stories.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 44, height: 44)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6)

                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Prophetic Stories")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text("Quranic accounts of the messengers")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            // CTA button
            Button(action: { showFullView = true }) {
                HStack {
                    Text("Tap to explore")
                        .font(.system(size: 14, weight: .semibold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(themeManager.accentGradient)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(height: 145)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeManager.floatingOrbColors[0].opacity(0.5),
                                        themeManager.floatingOrbColors[1].opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
    }
}

#Preview {
    PropheticStoriesCarouselCard(showFullView: .constant(false))
}
