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

                    Text("Congratulations!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.39, green: 0.4, blue: 0.95), Color.purple],
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

                    // Badge title
                    VStack(spacing: 8) {
                        Text(badge.badgeType.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)

                        if badge.badgeType == .surahCompletion {
                            Text(badge.surahName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.secondaryText)

                            Text(badge.arabicName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        } else {
                            Text(badgeMessage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
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
                                        colors: [Color(red: 0.39, green: 0.4, blue: 0.95), Color.purple],
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

    private var badgeMessage: String {
        switch badge.badgeType {
        case .surahCompletion:
            return "You completed this surah!"
        case .milestone10:
            return "You've mastered 10 surahs!"
        case .milestone25:
            return "A quarter of the Quran complete!"
        case .milestone50:
            return "You're halfway through the Quran!"
        case .allSurahs:
            return "You completed the entire Quran!"
        case .streak7:
            return "7 days of consistent reading!"
        case .streak30:
            return "30 days of dedication!"
        case .streak100:
            return "100 days of unwavering commitment!"
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
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    private let randomColor: Color
    private let randomXStart: CGFloat
    private let randomRotation: Double

    init(delay: Double) {
        self.delay = delay
        self.randomColor = colors.randomElement() ?? .blue
        self.randomXStart = CGFloat.random(in: -150...150)
        self.randomRotation = Double.random(in: 0...360)
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
