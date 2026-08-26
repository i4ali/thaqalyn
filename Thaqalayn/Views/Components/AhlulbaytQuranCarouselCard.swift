//
//  AhlulbaytQuranCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Ahl al-Bayt in the Quran in the Discovery Carousel.
//

import SwiftUI

struct AhlulbaytQuranCarouselCard: View {
    @Binding var showFullView: Bool

    var body: some View {
        PosterCarouselCard(
            assetName: "AhlulBaytCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private let localizedTitle = "Ahl al-Bayt in the Quran"

    private let localizedSubtitle = "Verses honoring the Prophet's family"
}

#Preview {
    AhlulbaytQuranCarouselCard(showFullView: .constant(false))
        .padding()
}
