//
//  BadgeAwardView.swift
//  Thaqalayn
//
//  Celebration view for badge awards and surah completions
//

import SwiftUI

struct BadgeAwardView: View {
    let badge: BadgeAward
    let onDismiss: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var confettiOpacity: Double = 0
    @State private var rotation: Double = -15

    var body: some View {
        emeraldBody
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                    confettiOpacity = 1.0
                }
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    rotation = 15
                }
            }
    }

    // MARK: - Emerald

    private var emeraldBody: some View {
        ZStack {
            // Scrim (this floats over an already-themed screen, so it keeps a
            // plain dimmed backdrop rather than EmeraldBackground).
            // Deeper than the shared modalScrim in dark: the badge is a full-screen moment.
            Color(light: Color(hex: "14261E").opacity(0.35), dark: Color.black.opacity(0.72))
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            // Confetti effect
            confettiView
                .opacity(confettiOpacity)

            EmCard(glow: true, cornerRadius: 28) {
                VStack(spacing: 26) {
                    // Congratulations heading
                    VStack(spacing: 10) {
                        ZStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 26))
                                .foregroundColor(themeManager.accentBright)
                                .offset(x: -64, y: -6)
                                .rotationEffect(.degrees(rotation))
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.accentColor)
                                .offset(x: 62, y: 4)
                                .rotationEffect(.degrees(-rotation))

                            Text("MASHALLAH")
                                .font(.system(size: 12, weight: .bold)).tracking(4)
                                .foregroundColor(themeManager.accentColor)
                        }
                    }

                    // Badge medallion
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [themeManager.accentColor.opacity(0.28), Color.clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 84
                                    )
                                )
                                .frame(width: 168, height: 168)

                            Circle()
                                .fill(themeManager.accentGradient)
                                .frame(width: 116, height: 116)
                                .overlay(Circle().stroke(themeManager.accentBright.opacity(0.6), lineWidth: 1.5))
                                .shadow(color: themeManager.accentColor.opacity(0.45), radius: 24, x: 0, y: 10)

                            Image(systemName: badge.badgeType.icon)
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundColor(themeManager.onAccentText)
                        }
                        .rotationEffect(.degrees(rotation * 0.15))

                        // Badge title + subtitle
                        VStack(spacing: 7) {
                            Text(badge.badgeType.title)
                                .font(EmType.serif(28, .semiBold))
                                .foregroundColor(themeManager.primaryText)
                                .multilineTextAlignment(.center)

                            Text(badge.badgeType.subtitle)
                                .font(EmType.serif(20, .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)

                            if badge.badgeType == .surahCompletion {
                                Text(badge.surahName)
                                    .font(EmType.serif(18, .semiBold))
                                    .foregroundColor(themeManager.accentColor)
                                Text(badge.arabicName)
                                    .font(EmType.arabic(20))
                                    .foregroundColor(themeManager.accentColor)
                            }

                            // Sawab pill
                            HStack(spacing: 5) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.accentBright)
                                Text("+\(badge.badgeType.sawabValue) Sawab")
                                    .font(.system(size: 13, weight: .bold)).tracking(0.3)
                                    .foregroundColor(themeManager.accentBright)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                            .padding(.top, 6)

                            // Description
                            Text(badge.badgeType.description)
                                .font(EmType.serif(16, .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .padding(.top, 6)

                            // Hadith
                            if let hadith = badge.badgeType.hadith {
                                VStack(spacing: 10) {
                                    EmDivider()
                                    Text(hadith)
                                        .font(EmType.serifItalic(16))
                                        .foregroundColor(themeManager.tertiaryText)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 4)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }

                    EmGoldCTA(title: "Continue Reading", sfSymbol: "book.fill") {
                        dismissWithAnimation()
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 30)
            }
            .padding(.horizontal, 28)
            .scaleEffect(scale)
            .opacity(opacity)
        }
    }

    private var confettiView: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { index in
                ConfettiPiece(delay: Double(index) * 0.05)
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
            confettiOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Confetti Piece

struct ConfettiPiece: View {
    let delay: Double
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    private let randomIndex: Int
    private let randomXStart: CGFloat
    private let randomRotation: Double

    init(delay: Double) {
        self.delay = delay
        self.randomIndex = Int.random(in: 0..<7)
        self.randomXStart = CGFloat.random(in: -150...150)
        self.randomRotation = Double.random(in: 0...360)
    }

    /// Pulls from the theme's confetti palette.
    private var randomColor: Color {
        let palette = themeManager.confettiColors
        return palette[randomIndex % palette.count].opacity(1.0)
    }

    var body: some View {
        Circle()
            .fill(randomColor)
            .frame(width: 8, height: 8)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                xOffset = randomXStart
                withAnimation(
                    .easeIn(duration: 2.0)
                    .delay(delay)
                ) {
                    yOffset = UIScreen.main.bounds.height
                    rotation = randomRotation * 3
                    opacity = 0
                }
            }
    }
}

#Preview {
    BadgeAwardView(
        badge: BadgeAward(
            surahNumber: 1,
            surahName: "Al-Fatiha",
            arabicName: "الفاتحة",
            badgeType: .surahCompletion
        ),
        onDismiss: {}
    )
}
