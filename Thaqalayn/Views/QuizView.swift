//
//  QuizView.swift
//  Thaqalayn
//
//  Main quiz screen with intro, questions, and results flow
//

import SwiftUI

struct QuizView: View {
    let surah: Surah
    let onDismiss: () -> Void

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var quizManager = QuizManager.shared

    @State private var quiz: SurahQuiz?
    @State private var quizState = QuizState()
    @State private var showingResults = false
    @State private var result: QuizResult?
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ZStack {
            // Background
            themeManager.primaryBackground
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let error = error {
                errorView(error)
            } else if let quiz = quiz {
                if showingResults, let result = result {
                    QuizResultsView(
                        surah: surah,
                        result: result,
                        quiz: quiz,
                        answers: quizState.answers,
                        onRetry: {
                            resetQuiz()
                        },
                        onDismiss: onDismiss
                    )
                } else if quizState.currentQuestionIndex == -1 {
                    introView(quiz: quiz)
                } else {
                    questionView(quiz: quiz)
                }
            }
        }
        .onAppear {
            loadQuiz()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(themeManager.primaryText)

            Text("Loading Quiz...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Quiz Unavailable")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text(message)
                .font(.system(size: 16))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: onDismiss) {
                Text("Go Back")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.accentGradient)
                    )
            }
        }
    }

    // MARK: - Intro View

    private func introView(quiz: SurahQuiz) -> some View {
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

                Text("Quiz")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Spacer()

                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // Intro content
            VStack(spacing: 32) {
                // Brain icon
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 56))
                        .foregroundStyle(themeManager.accentGradient)
                }

                // Surah info
                VStack(spacing: 8) {
                    Text("Test Your Knowledge")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text(surah.englishName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)

                    Text(surah.arabicName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                // Quiz details
                VStack(spacing: 16) {
                    quizDetailRow(icon: "questionmark.circle.fill", text: "\(quiz.questions.count) Questions")
                    quizDetailRow(icon: "clock.fill", text: "~3 minutes")
                }
                .padding(.vertical, 20)

                // Best score if available
                if let bestResult = quizManager.bestResult(for: surah.number) {
                    VStack(spacing: 8) {
                        Text("Best Score")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)

                        Text("\(bestResult.score)/\(bestResult.totalQuestions)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(levelColor(bestResult.level))

                        Text(bestResult.level.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.secondaryBackground)
                    )
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Start button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    quizState.currentQuestionIndex = 0
                }
            }) {
                Text("Start Quiz")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.accentGradient)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func quizDetailRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(themeManager.accentGradient)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.primaryText)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Question View

    private func questionView(quiz: SurahQuiz) -> some View {
        let question = quiz.questions[quizState.currentQuestionIndex]
        let isLastQuestion = quizState.currentQuestionIndex == quiz.questions.count - 1

        return VStack(spacing: 0) {
            // Header with progress
            VStack(spacing: 16) {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                            .frame(width: 40, height: 40)
                    }

                    Spacer()

                    Text("\(quizState.currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    Spacer()

                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.secondaryBackground)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.green, Color(red: 0.75, green: 0.60, blue: 0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressFraction, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: quizState.currentQuestionIndex)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            ScrollView {
                VStack(spacing: 24) {
                    // Layer indicator
                    layerBadge(for: question.layer)
                        .padding(.top, 24)

                    // Question text
                    Text(question.question)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Answer options
                    VStack(spacing: 12) {
                        if question.type == .trueFalse {
                            trueFalseOptions(question: question)
                        } else if let options = question.options {
                            multipleChoiceOptions(question: question, options: options)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Feedback
                    if showFeedback {
                        feedbackView(question: question)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.bottom, 120)
            }

            // Next/Finish button
            if showFeedback {
                VStack(spacing: 0) {
                    Divider()

                    Button(action: {
                        moveToNext(quiz: quiz, isLast: isLastQuestion)
                    }) {
                        Text(isLastQuestion ? "See Results" : "Next Question")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, Color(red: 0.75, green: 0.60, blue: 0.35)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(themeManager.primaryBackground)
            }
        }
    }

    private var progressFraction: CGFloat {
        guard let quiz = quiz else { return 0 }
        return CGFloat(quizState.currentQuestionIndex + 1) / CGFloat(quiz.questions.count)
    }

    private func layerBadge(for layer: Int) -> some View {
        let (icon, name, color) = layerInfo(layer)

        return HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 14))

            Text(name)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }

    private func layerInfo(_ layer: Int) -> (String, String, Color) {
        switch layer {
        case 1: return ("🏛️", "Foundation", .blue)
        case 2: return ("📚", "Classical", .purple)
        case 3: return ("🌍", "Contemporary", .green)
        case 4: return ("⭐", "Ahlul Bayt", .orange)
        case 5: return ("⚖️", "Comparative", .red)
        default: return ("📖", "General", .gray)
        }
    }

    // MARK: - Answer Options

    private func trueFalseOptions(question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            answerButton(
                text: "True",
                answer: "true",
                question: question
            )

            answerButton(
                text: "False",
                answer: "false",
                question: question
            )
        }
    }

    private func multipleChoiceOptions(question: QuizQuestion, options: [String]) -> some View {
        let letters = ["A", "B", "C", "D"]

        return VStack(spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                answerButton(
                    text: option,
                    answer: letters[index],
                    question: question,
                    letter: letters[index]
                )
            }
        }
    }

    private func answerButton(text: String, answer: String, question: QuizQuestion, letter: String? = nil) -> some View {
        let isSelected = selectedAnswer == answer
        let isCorrect = answer.lowercased() == question.correctAnswer.lowercased()
        let showResult = showFeedback

        let backgroundColor: Color = {
            if showResult {
                if isCorrect {
                    return .green.opacity(0.2)
                } else if isSelected {
                    return .red.opacity(0.2)
                }
            } else if isSelected {
                return Color.purple.opacity(0.2)
            }
            return themeManager.secondaryBackground
        }()

        let borderColor: Color = {
            if showResult {
                if isCorrect {
                    return .green
                } else if isSelected {
                    return .red
                }
            } else if isSelected {
                return .purple
            }
            return themeManager.strokeColor
        }()

        return Button(action: {
            if !showFeedback {
                selectAnswer(answer, for: question)
            }
        }) {
            HStack(spacing: 12) {
                if let letter = letter {
                    Text(letter)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isSelected || (showResult && isCorrect) ? borderColor : themeManager.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(borderColor.opacity(0.15))
                        )
                }

                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.leading)

                Spacer()

                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderColor, lineWidth: isSelected || (showResult && isCorrect) ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showFeedback)
    }

    private func feedbackView(question: QuizQuestion) -> some View {
        let isCorrect = selectedAnswer?.lowercased() == question.correctAnswer.lowercased()

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isCorrect ? .green : .blue)

                Text(isCorrect ? "Correct!" : "Explanation")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isCorrect ? .green : .blue)
            }

            Text(question.explanation)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCorrect ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isCorrect ? Color.green.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Actions

    private func loadQuiz() {
        Task {
            let loadedQuiz = await quizManager.loadQuiz(for: surah.number)
            await MainActor.run {
                if let loadedQuiz = loadedQuiz {
                    quiz = loadedQuiz
                    quizState.currentQuestionIndex = -1 // Start at intro
                } else {
                    error = "No quiz available for this surah yet. Check back soon!"
                }
                isLoading = false
            }
        }
    }

    private func selectAnswer(_ answer: String, for question: QuizQuestion) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedAnswer = answer
            quizState.answers[question.id] = answer
        }

        // Show feedback after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showFeedback = true
            }
        }
    }

    private func moveToNext(quiz: SurahQuiz, isLast: Bool) {
        if isLast {
            // Calculate and show results
            let score = quizManager.calculateScore(quiz: quiz, answers: quizState.answers)
            let newResult = QuizResult(
                surahNumber: surah.number,
                score: score,
                totalQuestions: quiz.questions.count
            )
            quizManager.saveResult(newResult)
            result = newResult

            withAnimation(.easeInOut(duration: 0.3)) {
                showingResults = true
            }
        } else {
            // Move to next question
            withAnimation(.easeInOut(duration: 0.3)) {
                quizState.currentQuestionIndex += 1
                selectedAnswer = nil
                showFeedback = false
            }
        }
    }

    private func resetQuiz() {
        withAnimation(.easeInOut(duration: 0.3)) {
            quizState = QuizState()
            quizState.currentQuestionIndex = -1
            selectedAnswer = nil
            showFeedback = false
            showingResults = false
            result = nil
        }
    }

    private func levelColor(_ level: UnderstandingLevel) -> Color {
        switch level {
        case .hafiz: return .yellow
        case .scholar: return .purple
        case .student: return .blue
        case .seeker: return .green
        case .beginner: return .gray
        }
    }
}

#Preview {
    QuizView(
        surah: Surah(
            number: 1,
            name: "Al-Fatihah",
            englishName: "The Opening",
            englishNameTranslation: "The Opening",
            arabicName: "الفاتحة",
            versesCount: 7,
            revelationType: "Meccan"
        ),
        onDismiss: {}
    )
}
