//
//  OnboardingCard.swift
//  Thaqalayn
//
//  Variant C reskin: white rounded card + warm shadow chrome.
//

import SwiftUI

struct OnboardingCardModifier: ViewModifier {
    var padding: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: Color(red: 60/255, green: 40/255, blue: 20/255).opacity(0.06),
                        radius: 12, x: 0, y: 8
                    )
            )
    }
}

struct OnboardingRowModifier: ViewModifier {
    var padding: CGFloat = 14
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: Color(red: 60/255, green: 40/255, blue: 20/255).opacity(0.04),
                        radius: 6, x: 0, y: 2
                    )
            )
    }
}

extension View {
    func onboardingCard(padding: CGFloat = 20) -> some View {
        modifier(OnboardingCardModifier(padding: padding))
    }
    func onboardingRow(padding: CGFloat = 14) -> some View {
        modifier(OnboardingRowModifier(padding: padding))
    }
}
