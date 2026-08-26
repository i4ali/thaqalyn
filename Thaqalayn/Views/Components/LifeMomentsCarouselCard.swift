//
//  LifeMomentsCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Life Moments feature in Discovery Carousel
//

import SwiftUI

struct LifeMomentsCarouselCard: View {
    @Binding var showFullView: Bool

    var body: some View {
        PosterCarouselCard(
            assetName: "LifeMomentsCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private let localizedTitle = "Life Moments"

    private let localizedSubtitle = "Find solace in divine words for any situation"
}

#Preview {
    LifeMomentsCarouselCard(showFullView: .constant(false))
        .padding()
}
