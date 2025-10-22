//
//  HadithScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 1: Hadith of Thaqalayn
//

import SwiftUI

struct HadithScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var currentPage: Int
    @State private var isVisible = false

    var body: some View {
        ZStack {
            // Subtle Islamic geometric pattern background
            GeometricPatternBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 40) {
                    // Title
                    Text("Hadith of Thaqalayn")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: isVisible)

                    // Arabic Hadith
                    Text("إني تارك فيكم الثقلين:\nكتاب الله وعترتي أهل بيتي،\nما إن تمسكتم بهما\nلن تضلوا بعدي أبداً")
                        .font(.system(size: 26, weight: .medium, design: .serif))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 30)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.6), value: isVisible)

                    // Divider
                    Capsule()
                        .fill(themeManager.accentGradient)
                        .frame(width: 60, height: 3)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(x: isVisible ? 1 : 0, y: 1)
                        .animation(Animation.easeOut(duration: 0.5).delay(0.9), value: isVisible)

                    // English Translation
                    VStack(spacing: 12) {
                        Text("\"I am leaving among you two weighty things:")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(themeManager.primaryText)

                        Text("the Book of Allah and my progeny,")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(themeManager.primaryText)

                        Text("the people of my household.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(themeManager.primaryText)

                        Text("As long as you hold fast to them,")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(themeManager.primaryText)

                        Text("you shall never go astray.\"")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                    }
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 30)
                    .animation(Animation.easeOut(duration: 0.8).delay(1.1), value: isVisible)

                    // Attribution
                    Text("— Prophet Muhammad ﷺ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .opacity(isVisible ? 1 : 0)
                        .animation(Animation.easeOut(duration: 0.6).delay(1.4), value: isVisible)
                }

                Spacer()

                // Tap to continue hint
                VStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)

                    Text("Swipe or tap to continue")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .opacity(isVisible ? 0.7 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(1.7), value: isVisible)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isVisible = true

            // Auto-advance after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentPage = 1
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentPage = 1
            }
        }
    }
}

// MARK: - Geometric Pattern Background

struct GeometricPatternBackground: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            // Subtle gradient
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Very subtle geometric pattern overlay
            Canvas { context, size in
                let spacing: CGFloat = 40
                let lineWidth: CGFloat = 0.5

                for x in stride(from: 0, through: size.width, by: spacing) {
                    for y in stride(from: 0, through: size.height, by: spacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x + spacing, y: y + spacing))

                        context.stroke(
                            path,
                            with: .color(themeManager.strokeColor.opacity(0.1)),
                            lineWidth: lineWidth
                        )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HadithScreen(currentPage: .constant(0))
}
