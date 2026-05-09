//
//  DuasCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Daily Duas in the Discovery Carousel.
//

import SwiftUI

struct DuasCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 44, height: 44)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6)

                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(localizedTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text(localizedSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

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
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "الأدعية اليومية"
        case .urdu: return "روزمرہ کی دعائیں"
        default: return "Daily Duas"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "20 دعاءً قصيرًا للأكل، النوم، السفر والمزيد"
        case .urdu: return "کھانا، سونا، سفر اور بہت کچھ کے لیے 20 مختصر دعائیں"
        default: return "20 short duas for daily life — eating, sleeping, travel, and more"
        }
    }
}

#Preview {
    DuasCarouselCard(showFullView: .constant(false))
}
