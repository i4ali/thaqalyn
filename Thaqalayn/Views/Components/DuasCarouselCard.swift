//
//  DuasCarouselCard.swift
//  Thaqalayn
//
//  Compact preview card for Daily Duas in the Discovery Carousel.
//

import SwiftUI

struct DuasCarouselCard: View {
    @Binding var showFullView: Bool

    var body: some View {
        PosterCarouselCard(
            assetName: "DailyDuasCover",
            title: localizedTitle,
            subtitle: localizedSubtitle
        ) {
            showFullView = true
        }
    }

    private let localizedTitle = "Duas for Every Need"

    private let localizedSubtitle = "Supplications for health, protection, sustenance, forgiveness, and more"
}

#Preview {
    DuasCarouselCard(showFullView: .constant(false))
        .padding()
}
