//
//  QuestionsCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Questions & Answers feature in Discovery Carousel
//

import SwiftUI

struct QuestionsCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var questionsManager = QuestionsManager.shared

    var previewQuestions: [Question] {
        Array(questionsManager.questions.prefix(3))
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

                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Questions & Answers")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text("Find Quranic answers to life's biggest questions")
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
    QuestionsCarouselCard(showFullView: .constant(false))
}
