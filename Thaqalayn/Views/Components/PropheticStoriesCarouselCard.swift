//
//  PropheticStoriesCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Prophetic Stories in the Discovery Carousel.
//

import SwiftUI

struct PropheticStoriesCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        PosterCarouselCard(
            assetName: "PropheticStoriesCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "قصص الأنبياء"
        case .urdu: return "انبیاء کے قصے"
        default: return "Prophetic Stories"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "قصص المرسلين في القرآن الكريم"
        case .urdu: return "قرآن میں رسولوں کے واقعات"
        default: return "Quranic accounts of the messengers"
        }
    }
}

#Preview {
    PropheticStoriesCarouselCard(showFullView: .constant(false))
        .padding()
}
