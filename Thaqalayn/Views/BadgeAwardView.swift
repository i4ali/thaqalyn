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
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .darkScreenAura()
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

    private var legacyBody: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            // Confetti effect
            confettiView
                .opacity(confettiOpacity)

            // Main celebration card
            VStack(spacing: 32) {
                // Congratulations text
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 64))
                        .rotationEffect(.degrees(rotation))

                    Text("MashAllah!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green, themeManager.accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // Badge display
                VStack(spacing: 20) {
                    ZStack {
                        // Glowing background
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [badgeColor.opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)

                        // Badge circle
                        Circle()
                            .fill(badgeColor.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(badgeColor, lineWidth: 4)
                            )

                        // Badge icon
                        Image(systemName: badge.badgeType.icon)
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundColor(badgeColor)
                    }
                    .shadow(color: badgeColor.opacity(0.5), radius: 20)

                    // Badge title and subtitle
                    VStack(spacing: 8) {
                        Text(badge.badgeType.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)

                        Text(badge.badgeType.subtitle)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)

                        if badge.badgeType == .surahCompletion {
                            Text(badge.surahName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.secondaryText)

                            Text(badge.arabicName)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }

                        // Sawab display
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            Text("+\(badge.badgeType.sawabValue) Sawab")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.green, themeManager.accentColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.top, 4)

                        // Description
                        Text(badge.badgeType.description)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                        // Hadith if available
                        if let hadith = badge.badgeType.hadith {
                            VStack(spacing: 4) {
                                Divider()
                                    .padding(.vertical, 8)

                                Text(hadith)
                                    .font(.system(size: 13, weight: .medium, design: .serif))
                                    .foregroundColor(themeManager.secondaryText.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .italic()
                                    .padding(.horizontal, 16)
                            }
                            .padding(.top, 8)
                        }
                    }
                }

                // Dismiss button
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Continue Reading")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, themeManager.accentColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.primaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [badgeColor.opacity(0.5), badgeColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: badgeColor.opacity(0.3), radius: 30)
            )
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
    }

    // MARK: - Emerald

    private var emeraldBody: some View {
        ZStack {
            // Dark scrim (this floats over an already-emerald screen, so it keeps a
            // plain dimmed backdrop rather than EmeraldBackground).
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            // Confetti effect (theme-aware via ConfettiPiece)
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
                                        .font(EmType.serifItalic(15))
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

    private var badgeColor: Color {
        switch badge.badgeType.color {
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "gold": return .yellow
        case "red": return .red
        default: return .gray
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

    /// Bright SwiftUI primitives for the light theme — these auto-adapt and remain festive.
    private let lightColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    private let randomIndex: Int
    private let randomXStart: CGFloat
    private let randomRotation: Double

    init(delay: Double) {
        self.delay = delay
        self.randomIndex = Int.random(in: 0..<7)
        self.randomXStart = CGFloat.random(in: -150...150)
        self.randomRotation = Double.random(in: 0...360)
    }

    /// In dark mode pull from the theme's floating orb palette (peach / lilac / green) at full opacity
    /// for legible confetti against the warm-black backdrop. Otherwise use the SwiftUI primitives.
    private var randomColor: Color {
        if themeManager.isDarkMode {
            let palette = themeManager.floatingOrbColors
            return palette[randomIndex % palette.count].opacity(1.0)
        } else {
            return lightColors[randomIndex % lightColors.count]
        }
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
