//
//  PosterCarouselCard.swift
//  Thaqalayn
//
//  Full-bleed cover-art poster card for the Discovery Carousel: the
//  destination's cover fills the card, the title sits in serif over a
//  text-side scrim, and a quiet gold Explore affordance replaces the old
//  gradient-capsule CTA. The art mirrors horizontally for RTL languages so
//  the dark side stays under the text (same rule as EmDailyReminderHero).
//

import SwiftUI

struct PosterCarouselCard: View {
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    let assetName: String
    let title: String
    let subtitle: String
    let action: () -> Void

    private var isRTL: Bool { languageManager.selectedLanguage.isRTL }

    // The covers read as emerald-night art in every app theme, so the poster
    // uses the art's own fixed palette rather than the active theme's.
    private let gold = Color(hex: "ECD49A")
    private let cream = Color(hex: "F0EDE4")
    private let night = Color(hex: "050E0B")

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                art
                scrim
                content
            }
            .frame(height: 145)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(gold.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 4)
        }
        .buttonStyle(EmPressStyle())
    }

    // Every cover is composed 4:5 with a dark, uncluttered top third; a wide
    // card wants the band just below that sky, so the crop is biased upward
    // (26% of the vertical overflow) rather than centered.
    private var art: some View {
        GeometryReader { geo in
            let imgH = geo.size.width * 5 / 4
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: imgH)
                .offset(y: -(imgH - geo.size.height) * 0.26)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .clipped()
                .scaleEffect(x: isRTL ? -1 : 1)
        }
        .accessibilityHidden(true)
    }

    private var scrim: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: night.opacity(0.87), location: 0),
                    .init(color: night.opacity(0.62), location: 0.44),
                    .init(color: night.opacity(0.10), location: 0.78),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading, endPoint: .trailing
            )
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.54),
                    .init(color: night.opacity(0.55), location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
        }
        .scaleEffect(x: isRTL ? -1 : 1)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(discoverLabel)
                .font(.system(size: 10, weight: .bold))
                .tracking(2.4)
                .foregroundColor(gold)

            Text(title)
                .font(EmType.serif(21, .semiBold))
                .foregroundColor(cream)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 6)

            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(cream.opacity(0.72))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 5)
                .frame(maxWidth: 235, alignment: .leading)

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                Text(exploreLabel)
                    .font(.system(size: 12.5, weight: .bold))
                    .tracking(0.3)
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .flipsForRightToLeftLayoutDirection(true)
            }
            .foregroundColor(gold)
        }
        .padding(.horizontal, 20)
        .padding(.top, 19)
        .padding(.bottom, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }

    private var discoverLabel: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "اكتشف"
        case .urdu: return "دریافت کریں"
        default: return "DISCOVER"
        }
    }

    private var exploreLabel: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "استكشف"
        case .urdu: return "دیکھیں"
        default: return "Explore"
        }
    }
}

#Preview {
    PosterCarouselCard(
        assetName: "DailyDuasCover",
        title: "Duas for Every Need",
        subtitle: "Supplications for health, protection, sustenance, forgiveness, and more"
    ) {}
    .padding()
}
