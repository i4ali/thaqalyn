//
//  QuizResultsView.swift
//  Thaqalayn
//
//  The end of a passage quiz: the score, five seals, the missed questions
//  with their right answer and a link into the passage, then Try again and
//  Back to passage. Hosted by QuizView, which owns the answers.
//

import SwiftUI

struct QuizResultsView: View {
    let eyebrow: String
    let quiz: PassageQuiz
    let answers: [Int?]
    let onReadAnchor: (QuizAnchor) -> Void
    let onTryAgain: () -> Void
    let onBack: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    private var total: Int { quiz.questions.count }
    private var score: Int { zip(quiz.questions, answers).filter { $0.1 == $0.0.answer }.count }
    private var missed: [QuizQuestion] { zip(quiz.questions, answers).filter { $0.1 != $0.0.answer }.map(\.0) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                }
                .buttonStyle(EmPressStyle())
                .accessibilityLabel("Back to passage")
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(eyebrow.uppercased())
                        .emEyebrow(size: 11, tracking: 2)
                        .foregroundColor(themeManager.accentColor)
                    Text(QuizStrings.score(score, of: total))
                        .font(EmType.serif(64, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .padding(.top, 10)
                    Text(QuizStrings.verdict(score, of: total))
                        .font(EmType.serifItalic(19))
                        .foregroundColor(themeManager.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)

                    seals.padding(.top, 26)

                    if !missed.isEmpty {
                        Text(QuizStrings.missed.uppercased())
                            .emEyebrow(size: 11, tracking: 2)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.top, 30)
                        VStack(spacing: 12) {
                            ForEach(missed) { q in missedCard(q) }
                        }
                        .padding(.top, 12)
                    }

                    buttons.padding(.top, 28)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    }

    private var seals: some View {
        HStack {
            ForEach(quiz.questions.indices, id: \.self) { i in
                VStack(spacing: 6) {
                    if answers[i] == quiz.questions[i].answer {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeManager.semanticGreen)
                    } else {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.semanticRed)
                            .frame(width: 34, height: 34)
                            .overlay(Circle().stroke(themeManager.semanticRed, lineWidth: 1.5))
                    }
                    Text("Q\(i + 1)")
                        .font(.system(size: 11, weight: .bold)).tracking(1)
                        .foregroundColor(themeManager.tertiaryText)
                }
                if i < quiz.questions.count - 1 { Spacer() }
            }
        }
        .padding(.horizontal, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(score) of \(total) correct")
    }

    private func missedCard(_ q: QuizQuestion) -> some View {
        EmCard(elevated: true, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(q.id) · \(q.type.label)".uppercased())
                        .emEyebrow(size: 11, tracking: 1.5)
                        .foregroundColor(themeManager.tertiaryText)
                    Spacer()
                    Text(QuizStrings.verse(q.verse))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                Text(q.prompt.en)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.semanticGreen)
                    Text(q.options[q.answer].en)
                        .font(EmType.serif(17 * readingSettings.scale, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button(action: { onReadAnchor(q.anchor) }) {
                    HStack(spacing: 6) {
                        Text(QuizStrings.readInPassage)
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(themeManager.accentColor)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(EmPressStyle.gentle)
                .accessibilityLabel("Read this in the passage, \(QuizStrings.anchorLabel(q.anchor.location))")
            }
            .padding(18)
        }
    }

    private var buttons: some View {
        HStack(spacing: 12) {
            Button(action: onTryAgain) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16, weight: .semibold))
                    Text(QuizStrings.tryAgain)
                        .font(.system(size: 16, weight: .bold)).tracking(0.3)
                }
                .foregroundColor(themeManager.accentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.glassSurfaceElevated))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Try the quiz again")

            Button(action: onBack) {
                Text(QuizStrings.backToPassage)
                    .font(.system(size: 16, weight: .bold)).tracking(0.3)
                    .foregroundColor(themeManager.onAccentText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Back to passage")
        }
    }
}
