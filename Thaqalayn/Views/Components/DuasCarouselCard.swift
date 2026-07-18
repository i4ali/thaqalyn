//
//  DuasCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Daily Duas in the Discovery Carousel.
//

import SwiftUI

struct DuasCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        PosterCarouselCard(
            assetName: "DailyDuasCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أدعية لكل حاجة"
        case .urdu: return "ہر حاجت کی دعا"
        default: return "Duas for Every Need"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أدعية للصحة والحفظ والرزق والمغفرة والمزيد"
        case .urdu: return "صحت، حفاظت، رزق، مغفرت اور مزید کے لیے دعائیں"
        default: return "Supplications for health, protection, sustenance, forgiveness, and more"
        }
    }
}

#Preview {
    DuasCarouselCard(showFullView: .constant(false))
        .padding()
}
