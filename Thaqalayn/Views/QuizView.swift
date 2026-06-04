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
            if themeManager.isMidnightEmerald {
                EmeraldBackground()
            } else {
                themeManager.primaryBackground.ignoresSafeArea()
            }

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
        .darkScreenAura()
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

    @ViewBuilder
    private func introView(quiz: SurahQuiz) -> some View {
        if themeManager.isMidnightEmerald { emeraldIntroView(quiz: quiz) } else { legacyIntroView(quiz: quiz) }
    }

    private func emeraldIntroView(quiz: SurahQuiz) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark").font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                }
                Spacer()
                Text("TEST YOUR KNOWLEDGE").font(.system(size: 11, weight: .bold)).tracking(3).foregroundColor(themeManager.accentColor)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20).padding(.top, 12)

            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    RadialGradient(gradient: Gradient(colors: [themeManager.accentColor.opacity(0.18), .clear]), center: .center, startRadius: 0, endRadius: 130)
                        .frame(width: 260, height: 260)
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(themeManager.accentChip)
                        .frame(width: 120, height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 36, style: .continuous).stroke(themeManager.accentColor, lineWidth: 1))
                    Image(systemName: "brain.head.profile").font(.system(size: 52)).foregroundColor(themeManager.accentBright)
                }

                VStack(spacing: 8) {
                    Text(surah.englishName).font(EmType.serif(38, .semiBold)).foregroundColor(themeManager.primaryText)
                    Text(surah.arabicName).font(EmType.arabic(26)).foregroundColor(themeManager.accentColor)
                }

                HStack(spacing: 0) {
                    emeraldQuizStat(icon: "questionmark.circle", value: "\(quiz.questions.count)", label: "Questions")
                    Rectangle().fill(themeManager.strokeColor).frame(width: 1, height: 44)
                    emeraldQuizStat(icon: "clock", value: "~3", label: "Minutes")
                }
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(themeManager.glassSurface)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
                )

                if let bestResult = quizManager.bestResult(for: surah.number) {
                    VStack(spacing: 4) {
                        Text("BEST SCORE").font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundColor(themeManager.tertiaryText)
                        Text("\(bestResult.score)/\(bestResult.totalQuestions)").font(EmType.serif(24, .semiBold)).foregroundColor(themeManager.accentBright)
                        Text(bestResult.level.title).font(.system(size: 12, weight: .medium)).foregroundColor(themeManager.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { quizState.currentQuestionIndex = 0 } }) {
                Text("Begin Quiz").font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.onAccentText)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 18, x: 0, y: 8)
            }
            .buttonStyle(EmPressStyle())
            .padding(.horizontal, 24).padding(.bottom, 40)
        }
    }

    private func emeraldQuizStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(themeManager.accentColor)
            Text(value).font(EmType.serif(26, .semiBold)).foregroundColor(themeManager.accentBright)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(themeManager.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func legacyIntroView(quiz: SurahQuiz) -> some View {
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

    @ViewBuilder
    private func questionView(quiz: SurahQuiz) -> some View {
        if themeManager.isMidnightEmerald { emeraldQuestionView(quiz: quiz) } else { legacyQuestionView(quiz: quiz) }
    }

    private func emeraldQuestionView(quiz: SurahQuiz) -> some View {
        let question = quiz.questions[quizState.currentQuestionIndex]
        let isLastQuestion = quizState.currentQuestionIndex == quiz.questions.count - 1

        return VStack(spacing: 0) {
            // Header with progress
            VStack(spacing: 16) {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark").font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                    Spacer()
                    Text("\(quizState.currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.system(size: 12, weight: .bold)).tracking(1.5)
                        .foregroundColor(themeManager.accentColor)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                        Capsule().fill(themeManager.accentGradient)
                            .frame(width: geometry.size.width * progressFraction, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: quizState.currentQuestionIndex)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 24) {
                    layerBadge(for: question.layer)
                        .padding(.top, 24)

                    Text(question.question)
                        .font(EmType.serif(24, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        if question.type == .trueFalse {
                            trueFalseOptions(question: question)
                        } else if let options = question.options {
                            multipleChoiceOptions(question: question, options: options)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    if showFeedback {
                        feedbackView(question: question)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.bottom, 120)
            }

            if showFeedback {
                VStack(spacing: 0) {
                    Rectangle().fill(themeManager.strokeColor).frame(height: 1)
                    Button(action: {
                        moveToNext(quiz: quiz, isLast: isLastQuestion)
                    }) {
                        Text(isLastQuestion ? "See Results" : "Next Question")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.onAccentText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                            .shadow(color: themeManager.accentColor.opacity(0.28), radius: 18, x: 0, y: 8)
                    }
                    .buttonStyle(EmPressStyle())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }

    private func legacyQuestionView(quiz: SurahQuiz) -> some View {
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
            PhosphorIcon(name: icon, size: 14)

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
        case 1: return ("ph-bank-fill", "Foundation", .blue)
        case 2: return ("ph-books-fill", "Classical", .purple)
        case 3: return ("ph-globe-hemisphere-west-fill", "Contemporary", .green)
        case 4: return ("ph-star-fill", "Ahlul Bayt", .orange)
        case 5: return ("ph-scales-fill", "Comparative", .red)
        default: return ("ph-book-open", "General", .gray)
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

        let emerald = themeManager.isMidnightEmerald

        let backgroundColor: Color = {
            if showResult {
                if isCorrect {
                    return themeManager.semanticGreen.opacity(0.2)
                } else if isSelected {
                    return themeManager.semanticRed.opacity(0.2)
                }
            } else if isSelected {
                return emerald ? themeManager.accentChip : Color.purple.opacity(0.2)
            }
            return emerald ? themeManager.glassSurface : themeManager.secondaryBackground
        }()

        let borderColor: Color = {
            if showResult {
                if isCorrect {
                    return themeManager.semanticGreen
                } else if isSelected {
                    return themeManager.semanticRed
                }
            } else if isSelected {
                return emerald ? themeManager.accentColor : .purple
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
                            .foregroundColor(themeManager.semanticGreen)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.semanticRed)
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
        let infoColor: Color = themeManager.isMidnightEmerald ? themeManager.accentColor : .blue
        let accent = isCorrect ? themeManager.semanticGreen : infoColor

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(accent)

                Text(isCorrect ? "Correct!" : "Explanation")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accent)
            }

            Text(question.explanation)
                .font(themeManager.isMidnightEmerald ? EmType.serif(16, .medium) : .system(size: 15, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(accent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(accent.opacity(0.3), lineWidth: 1)
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
