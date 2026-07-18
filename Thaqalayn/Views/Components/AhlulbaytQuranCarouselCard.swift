//
//  AhlulbaytQuranCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Ahl al-Bayt in the Quran in the Discovery Carousel.
//

import SwiftUI

struct AhlulbaytQuranCarouselCard: View {
    @Binding var showFullView: Bool
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        PosterCarouselCard(
            assetName: "AhlulBaytCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أهل البيت في القرآن"
        case .urdu: return "قرآن میں اہل بیت"
        default: return "Ahl al-Bayt in the Quran"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "آيات في فضل عترة النبي"
        case .urdu: return "خاندانِ رسول کی شان میں آیات"
        default: return "Verses honoring the Prophet's family"
        }
    }
}

#Preview {
    AhlulbaytQuranCarouselCard(showFullView: .constant(false))
        .padding()
}
