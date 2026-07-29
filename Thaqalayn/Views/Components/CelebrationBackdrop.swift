//
//  CelebrationBackdrop.swift
//  Thaqalayn
//
//  The app's one celebration moment, shared by the crossword "Solved!",
//  the Daily Challenge completion and good quiz results: doves rising out
//  of golden light on the emerald night, behind the screen's own content.
//  The plate is fixed emerald-night art, so callers show it only under
//  Midnight Emerald; the scrim keeps the title zone and the bottom CTA
//  solid over the bright core.
//

import SwiftUI

struct CelebrationBackdrop: View {
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("CelebrationDoves")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }

            LinearGradient(
                stops: [
                    .init(color: Color(hex: "040A08").opacity(0.30), location: 0),
                    .init(color: Color(hex: "040A08").opacity(0.05), location: 0.34),
                    .init(color: Color(hex: "040A08").opacity(0.28), location: 0.62),
                    .init(color: Color(hex: "040A08").opacity(0.62), location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// The BadgeAwardView confetti rain (theme-aware `ConfettiPiece`s), packaged
/// for the completion screens. Anchor it to the top of the screen; pieces
/// spawn just above it and fall the full height.
struct CelebrationConfetti: View {
    var count = 30

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                ConfettiPiece(delay: Double(index) * 0.05)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    ZStack {
        CelebrationBackdrop()
        CelebrationConfetti()
    }
}
#endif
