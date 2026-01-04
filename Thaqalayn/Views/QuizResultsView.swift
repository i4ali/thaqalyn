//
//  QuizResultsView.swift
//  Thaqalayn
//
//  Quiz results display with celebration and score breakdown
//

import SwiftUI

struct QuizResultsView: View {
    let surah: Surah
    let result: QuizResult
    let quiz: SurahQuiz
    let answers: [String: String]
    let onRetry: () -> Void
    let onDismiss: () -> Void

    @StateObject private var themeManager = ThemeManager.shared
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    @State private var showDetails = false

    private var isPerfect: Bool {
        result.score == result.totalQuestions
    }

    private var isGood: Bool {
        Double(result.score) / Double(result.totalQuestions) >= 0.6
    }

    var body: some View {
        ZStack {
            // Background
            themeManager.primaryBackground
                .ignoresSafeArea()

            // Confetti for good scores
            if showConfetti && isGood {
                confettiView
            }

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                            .frame(width: 40, height: 40)
                    }

                    Spacer()

                    Text("Results")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Spacer()

                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 32) {
                        // Main result card
                        resultCard
                            .scaleEffect(scale)
                            .opacity(opacity)

                        // Score breakdown
                        if showDetails {
                            breakdownCard
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }

                    Button(action: onDismiss) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(themeManager.secondaryBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(themeManager.primaryBackground)
            }
        }
        .onAppear {
            animateIn()
        }
    }

    // MARK: - Result Card

    private var resultCard: some View {
        VStack(spacing: 24) {
            // Level icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [levelColor.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(levelColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(levelColor, lineWidth: 3)
                    )

                Image(systemName: result.level.icon)
                    .font(.system(size: 36))
                    .foregroundColor(levelColor)
            }

            // Score
            VStack(spacing: 8) {
                Text("\(result.score)/\(result.totalQuestions)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text(result.level.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(levelColor)

                Text(result.level.arabicTitle)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            // Message
            Text(result.level.message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Surah info
            VStack(spacing: 4) {
                Text(surah.englishName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text(surah.arabicName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(levelColor.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: levelColor.opacity(0.2), radius: 20)
        )
    }

    // MARK: - Breakdown Card

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question Breakdown")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            VStack(spacing: 12) {
                ForEach(Array(quiz.questions.enumerated()), id: \.offset) { index, question in
                    let userAnswer = answers[question.id] ?? ""
                    let isCorrect = userAnswer.lowercased() == question.correctAnswer.lowercased()

                    HStack(spacing: 12) {
                        // Question number
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isCorrect ? .green : .red)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(isCorrect ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                            )

                        // Question preview
                        Text(question.question)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2)

                        Spacer()

                        // Result icon
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(isCorrect ? .green : .red)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.primaryBackground)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }

    // MARK: - Confetti

    private var confettiView: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { index in
                QuizConfettiPiece(delay: Double(index) * 0.03)
            }
        }
    }

    // MARK: - Helpers

    private var levelColor: Color {
        switch result.level {
        case .hafiz: return .yellow
        case .scholar: return .purple
        case .student: return .blue
        case .seeker: return .green
        case .beginner: return .gray
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
        }

        if isGood {
            showConfetti = true
        }

        // Show details after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showDetails = true
            }
        }
    }
}

// MARK: - Quiz Confetti Piece

struct QuizConfettiPiece: View {
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
    QuizResultsView(
        surah: Surah(
            number: 1,
            name: "Al-Fatihah",
            englishName: "The Opening",
            englishNameTranslation: "The Opening",
            arabicName: "الفاتحة",
            versesCount: 7,
            revelationType: "Meccan"
        ),
        result: QuizResult(
            surahNumber: 1,
            score: 8,
            totalQuestions: 10
        ),
        quiz: SurahQuiz(surahNumber: 1, questions: []),
        answers: [:],
        onRetry: {},
        onDismiss: {}
    )
}
