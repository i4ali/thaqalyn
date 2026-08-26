//
//  PropheticStoriesCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Prophetic Stories in the Discovery Carousel.
//

import SwiftUI

struct PropheticStoriesCarouselCard: View {
    @Binding var showFullView: Bool

    var body: some View {
        PosterCarouselCard(
            assetName: "PropheticStoriesCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private let localizedTitle = "Prophetic Stories"

    private let localizedSubtitle = "Quranic accounts of the messengers"
}

#Preview {
    PropheticStoriesCarouselCard(showFullView: .constant(false))
        .padding()
}
