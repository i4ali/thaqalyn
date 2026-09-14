//
//  QuizView.swift
//  Thaqalayn
//
//  Five questions on one passage, answered one tap at a time, then results.
//  Pushed from the passage list swipe and from the Test yourself button at the
//  end of PassageView. Tapping an option answers it at once; the explanation
//  and a link into the passage appear beneath, then Next question. The best
//  score is kept locally in QuizResultsStore.
//

import SwiftUI

struct QuizView: View {
    let surahWithTafsir: SurahWithTafsir
    let ref: PassageRef
    let quiz: PassageQuiz

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var passageStore = PassageStore.shared
    @ObservedObject private var results = QuizResultsStore.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    @State private var currentIndex = 0
    @State private var answers: [Int?]
    @State private var showingResults = false
    @State private var showTextSizePanel = false
    @State private var understandingTarget: String? = nil
    @State private var showingUnderstanding = false

    init(surahWithTafsir: SurahWithTafsir, ref: PassageRef, quiz: PassageQuiz) {
        self.surahWithTafsir = surahWithTafsir
        self.ref = ref
        self.quiz = quiz
        _answers = State(initialValue: Array(repeating: nil, count: quiz.questions.count))
    }

    // MARK: - Derived

    private var surah: Surah { surahWithTafsir.surah }
    private var passage: Passage? { passageStore.passage(surah: ref.surah, index: ref.index) }
    private var question: QuizQuestion { quiz.questions[currentIndex] }
    private var picked: Int? { answers[currentIndex] }
    private var isLast: Bool { currentIndex == quiz.questions.count - 1 }
    private var score: Int {
        zip(quiz.questions, answers).filter { $0.1 == $0.0.answer }.count
    }
    private var eyebrow: String { "\(surah.englishName) · \(passageStore.title(for: ref))" }

    /// The reader's language when this passage carries it, else English; the
    /// same rule UnderstandingView applies, so the anchor resolves against the
    /// text that screen will show.
    private var understandingLanguage: CommentaryLanguage {
        guard let passage else { return .english }
        let selected = languageManager.selectedLanguage
        return passage.essay.availableLanguages.contains(selected) ? selected : .english
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            background
            if showingResults {
                QuizResultsView(
                    eyebrow: eyebrow,
                    quiz: quiz,
                    answers: answers,
                    onReadAnchor: openUnderstanding,
                    onTryAgain: reset,
                    onBack: { dismiss() }
                )
            } else {
                questionScreen
            }
        }
        .background(
            NavigationLink(destination: understandingDestination, isActive: $showingUnderstanding) { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
        )
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 60, trailingPadding: 20)
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.22, starCount: 10)
    }

    // MARK: - Background (same ground as PassageView)

    @ViewBuilder private var background: some View {
        if themeManager.isMidnightEmerald {
            EmeraldBackground()
        } else {
            LinearGradient(
                colors: [themeManager.primaryBackground, themeManager.secondaryBackground, themeManager.tertiaryBackground],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()
        }
    }

    // MARK: - Question screen

    private var questionScreen: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleBlock
                    progress.padding(.top, 14).padding(.bottom, 18)
                    questionCard
                    options.padding(.top, 14)
                    if picked != nil {
                        explanation.padding(.top, 18)
                        readLink.padding(.top, 12)
                        nextButton.padding(.top, 20)
                    } else {
                        Text(QuizStrings.hint)
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 18)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Back")
            Spacer()
            TextSizeButton(isPanelOpen: $showTextSizePanel)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
            Text(QuizStrings.title)
                .font(EmType.serif(30, .semiBold))
                .foregroundColor(themeManager.primaryText)
            Text(QuizStrings.question(currentIndex + 1, of: quiz.questions.count))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(quiz.questions.indices, id: \.self) { i in
                Capsule()
                    .fill(i < currentIndex ? themeManager.accentColor
                          : i == currentIndex ? themeManager.accentBright
                          : themeManager.strokeColor)
                    .frame(height: 4)
            }
        }
        .accessibilityHidden(true)
    }

    private var questionCard: some View {
        EmCard(elevated: true, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(question.type.label.uppercased())
                        .emEyebrow(size: 11, tracking: 2)
                        .foregroundColor(themeManager.accentColor)
                    Spacer()
                    Text(QuizStrings.verse(question.verse))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                promptText
            }
            .padding(20)
        }
    }

    /// The fill-the-gap prompt shows its blank as an underlined space; other types show the prompt as is.
    @ViewBuilder private var promptText: some View {
        let font = EmType.serif(20 * readingSettings.scale, .medium)
        if question.type == .fillGap, let range = question.prompt.en.range(of: "____") {
            let before = String(question.prompt.en[..<range.lowerBound])
            let after = String(question.prompt.en[range.upperBound...])
            (Text(before) + Text("        ").underline(true, color: themeManager.accentColor) + Text(after))
                .font(font)
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(5 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(question.prompt.en)
                .font(font)
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(5 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private var options: some View {
        switch question.type {
        case .trueFalse:
            HStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { i in
                    QuizOptionRow(text: question.options[i].en, state: state(for: i), centered: true) { answer(i) }
                }
            }
        case .fillGap:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(question.options.indices, id: \.self) { i in
                    QuizOptionRow(text: question.options[i].en, state: state(for: i), centered: true) { answer(i) }
                }
            }
        default:
            VStack(spacing: 10) {
                ForEach(question.options.indices, id: \.self) { i in
                    QuizOptionRow(text: question.options[i].en, state: state(for: i)) { answer(i) }
                }
            }
        }
    }

    private func state(for option: Int) -> QuizOptionRow.State {
        guard let picked else { return .idle }
        if option == question.answer { return .correct }
        if option == picked { return .wrong }
        return .dimmed
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(QuizStrings.why.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(picked == question.answer ? themeManager.semanticGreen : themeManager.semanticRed)
            Text(question.explanation.en)
                .font(EmType.serif(16 * readingSettings.scale, .medium))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(5 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var readLink: some View {
        Button(action: { openUnderstanding(question.anchor) }) {
            HStack(spacing: 12) {
                Image(systemName: "book")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(QuizStrings.readInPassage)
                        .font(EmType.serif(17, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(QuizStrings.anchorLabel(question.anchor.location))
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(passage == nil)
        .accessibilityLabel("Read this in the passage, \(QuizStrings.anchorLabel(question.anchor.location))")
    }

    private var nextButton: some View {
        Button(action: advance) {
            HStack(spacing: 10) {
                Text(isLast ? QuizStrings.seeResults : QuizStrings.next)
                    .font(.system(size: 16, weight: .bold)).tracking(0.3)
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(themeManager.onAccentText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
            .shadow(color: themeManager.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
        }
        .buttonStyle(EmPressStyle())
    }

    // MARK: - Actions

    private func answer(_ option: Int) {
        guard answers[currentIndex] == nil else { return }
        withAnimation(.easeInOut(duration: 0.2)) { answers[currentIndex] = option }
        UINotificationFeedbackGenerator().notificationOccurred(option == question.answer ? .success : .error)
    }

    private func advance() {
        if isLast {
            results.record(PassageQuizResult(surah: ref.surah, index: ref.index, score: score,
                                             total: quiz.questions.count, completedAt: Date()))
            withAnimation(.easeInOut(duration: 0.3)) { showingResults = true }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) { currentIndex += 1 }
        }
    }

    private func reset() {
        answers = Array(repeating: nil, count: quiz.questions.count)
        currentIndex = 0
        withAnimation(.easeInOut(duration: 0.3)) { showingResults = false }
    }

    private func openUnderstanding(_ anchor: QuizAnchor) {
        guard let passage else { return }
        understandingTarget = UnderstandingView.scrollId(for: anchor, in: passage, lang: understandingLanguage)
        // Let the press squish play before the push starts.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingUnderstanding = true }
    }

    @ViewBuilder private var understandingDestination: some View {
        if let passage {
            UnderstandingView(surahWithTafsir: surahWithTafsir, ref: ref, passage: passage, scrollTarget: understandingTarget)
        } else {
            EmptyView()
        }
    }
}
