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
            LinearGradient(
                colors: ThemeManager.tiltColors(tilt),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 232/255, green: 148/255, blue: 100/255).opacity(0.18),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
            .frame(width: 500, height: 400)
            .blur(radius: 8)
            .offset(y: -40)
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
