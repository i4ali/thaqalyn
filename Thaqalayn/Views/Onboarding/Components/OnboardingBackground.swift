//
//  OnboardingBackground.swift
//  Thaqalayn
//
//  Variant C reskin: per-screen warm tilt gradient + amber radial glow.
//  Onboarding is always warm/light, so values are fixed (no dark branching).
//

import SwiftUI

struct OnboardingBackground: View {
    let tilt: ThemeManager.OnboardingTilt

    var body: some View {
        ZStack {
            Color(hex: "0A1512").ignoresSafeArea()
            GeometryReader { geo in
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "0C1D16"), location: 0.0),
                        .init(color: Color(hex: "0A1512"), location: 0.55),
                        .init(color: Color(hex: "081310"), location: 1.0),
                    ]),
                    center: UnitPoint(x: 0.5, y: -0.10),
                    startRadius: 0,
                    endRadius: max(geo.size.width, geo.size.height) * 1.1
                )
                .ignoresSafeArea()
            }
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "ECD49A").opacity(0.13), .clear]),
                center: .top, startRadius: 0, endRadius: 230
            )
            .frame(height: 320)
            .frame(maxWidth: .infinity, alignment: .top)
            .offset(y: -90)
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackground(tilt: .peach)
        Text("peach").font(.title.bold())
    }
}
