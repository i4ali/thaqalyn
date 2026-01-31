//
//  QuizFeatureScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Quiz Feature Highlight
//

import SwiftUI

struct QuizFeatureScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var iconPulse = false
    @State private var showQuestion = false
    @State private var selectedAnswer: String? = nil
    @State private var showCorrectFeedback = false
    @State private var showResultCard = false
    @State private var animatedScore = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header with animated icon
            VStack(spacing: 20) {
                // Animated brain icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .scaleEffect(iconPulse ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: iconPulse
                        )

                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    // Brain icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                // Title
                Text("Test Your Knowledge")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                // Subtitle
                Text("Quizzes for every surah")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            // Demo content
            VStack(spacing: 16) {
                if !showResultCard {
                    // Demo question card
                    DemoQuestionCard(
                        selectedAnswer: $selectedAnswer,
                        showCorrectFeedback: showCorrectFeedback,
                        isVisible: showQuestion
                    )
                } else {
                    // Demo result card
                    DemoResultCard(
                        score: animatedScore,
                        isVisible: showResultCard
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Bottom message
            Text("Deepen your understanding through reflection")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(0.8), value: isVisible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
            iconPulse = true
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        // Show question card after initial animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                showQuestion = true
            }
        }

        // Select answer B after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedAnswer = "B"
            }

            // Show correct feedback after selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showCorrectFeedback = true
                }

                // Transition to result card
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showResultCard = true
                    }

                    // Animate score counting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        animateScore()
                    }
                }
            }
        }
    }

    private func animateScore() {
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
            if animatedScore < 9 {
                animatedScore += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Demo Question Card

struct DemoQuestionCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var selectedAnswer: String?
    let showCorrectFeedback: Bool
    let isVisible: Bool

    private let options = [
        ("A", "The physical throne of Allah"),
        ("B", "Allah's knowledge and authority"),
        ("C", "A type of angel"),
        ("D", "The heavens")
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Layer badge
            HStack(spacing: 6) {
                Text("🏛️")
                    .font(.system(size: 14))
                Text("Foundation")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
            )

            // Question
            Text("What does 'Kursi' represent in Ayat al-Kursi?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            // Answer options
            VStack(spacing: 10) {
                ForEach(options, id: \.0) { letter, text in
                    DemoAnswerOption(
                        letter: letter,
                        text: text,
                        isSelected: selectedAnswer == letter,
                        isCorrect: letter == "B",
                        showFeedback: showCorrectFeedback && selectedAnswer != nil
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 40)
        .animation(Animation.easeOut(duration: 0.6), value: isVisible)
    }
}

// MARK: - Demo Answer Option

struct DemoAnswerOption: View {
    @StateObject private var themeManager = ThemeManager.shared
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let showFeedback: Bool

    private var backgroundColor: Color {
        if showFeedback {
            if isCorrect {
                return .green.opacity(0.2)
            } else if isSelected {
                return .red.opacity(0.2)
            }
        } else if isSelected {
            return Color.purple.opacity(0.2)
        }
        return themeManager.secondaryBackground
    }

    private var borderColor: Color {
        if showFeedback {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
        } else if isSelected {
            return .purple
        }
        return themeManager.strokeColor
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(letter)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isSelected || (showFeedback && isCorrect) ? borderColor : themeManager.secondaryText)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(borderColor.opacity(0.15))
                )

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .lineLimit(1)

            Spacer()

            if showFeedback && isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: isSelected || (showFeedback && isCorrect) ? 2 : 1)
                )
        )
        .scaleEffect(isSelected && !showFeedback ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showFeedback)
    }
}

// MARK: - Demo Result Card

struct DemoResultCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    let score: Int
    let isVisible: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Scholar badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, Color(red: 0.6, green: 0.4, blue: 0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Level title
            VStack(spacing: 8) {
                Text("Scholar Level")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text("عالم")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.purple)
            }

            // Score
            HStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                    .contentTransition(.numericText())

                Text("/10")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            // Message
            Text("Excellent understanding!")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.primaryBackground)
                .shadow(color: Color.purple.opacity(0.2), radius: 20, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.purple.opacity(0.3), lineWidth: 2)
        )
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8)
        .animation(Animation.spring(response: 0.5, dampingFraction: 0.7), value: isVisible)
    }
}

#Preview {
    QuizFeatureScreen()
}
