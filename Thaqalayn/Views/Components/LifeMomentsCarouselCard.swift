//
//  LifeMomentsCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Life Moments feature in Discovery Carousel
//

import SwiftUI

struct LifeMomentsCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        PosterCarouselCard(
            assetName: "LifeMomentsCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "لحظات الحياة"
        case .urdu: return "زندگی کے لمحات"
        default: return "Life Moments"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "اطمئنان من كلام الله لكل موقف"
        case .urdu: return "ہر صورتحال کے لیے اللہ کے کلام میں سکون"
        default: return "Find solace in divine words for any situation"
        }
    }
}

#Preview {
    LifeMomentsCarouselCard(showFullView: .constant(false))
        .padding()
}
