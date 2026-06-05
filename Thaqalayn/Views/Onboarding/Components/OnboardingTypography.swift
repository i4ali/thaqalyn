//
//  OnboardingTypography.swift
//  Thaqalayn
//
//  Variant C reskin: system-font type scale (no font import).
//  These set font + tracking only; callers keep their own foregroundColor.
//

import SwiftUI

extension View {
    func onbHeroTitle() -> some View {
        font(EmType.serif(27))
    }
    func onbFinalTitle() -> some View {
        font(EmType.serif(36))
    }
    func onbEyebrow() -> some View {
        font(.system(size: 11.5, weight: .bold)).tracking(3.4).textCase(.uppercase)
    }
    func onbCardTitle() -> some View {
        font(.system(size: 16, weight: .heavy)).tracking(-0.3)
    }
    func onbRowTitle() -> some View {
        font(.system(size: 15, weight: .bold)).tracking(-0.2)
    }
    func onbBody() -> some View {
        font(.system(size: 14.5, weight: .medium))
    }
    func onbCaption() -> some View {
        font(.system(size: 12, weight: .medium))
    }
    func onbPill() -> some View {
        font(.system(size: 11.5, weight: .bold)).tracking(0.3)
    }
}
