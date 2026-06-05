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
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color(hex: "ECD49A").opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
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
                    .fill(Color.white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(hex: "ECD49A").opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.30), radius: 8, x: 0, y: 3)
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
