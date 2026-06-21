//
//  DailyChallengeView.swift
//  Thaqalayn
//
//  Interaction sheet for the Daily Challenge feature.
//  Supports four formats: multipleChoice, trueFalse, flashcard, fillInBlank.
//
//  Scaling rule (project rule):
//    Reading content (prompt, options, explanation, arabicText) → size * readingSettings.scale
//    Chrome (eyebrow, title, source citation, button labels)    → fixed size
//
//  RTL: .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
//       + .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
//  Mirrors: DuaDetailView (scaling + RTL), TodayView/TodayStrings (string pattern).
//

import SwiftUI

// MARK: - Main view

struct DailyChallengeView: View {
    let challenge: DailyChallenge
    var onCompleted: () -> Void

    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var manager = DailyChallengeManager.shared
    @Environment(\.dismiss) private var dismiss

    // State machine
    @State private var selectedIndex: Int? = nil   // chosen option for MC / fill-in / TF (0 or 1)
    @State private var revealed = false             // answer locked + explanation shown
    @State private var flipped = false              // flashcard face
    @State private var flashcardGotIt: Bool? = nil // nil = not yet graded
    @State private var earnedSawab = 0
    @State private var showCompletion = false

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    // MARK: - Body

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            if showCompletion {
                completionLayer
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                mainContent
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: showCompletion)
        .animation(.spring(response: 0.30, dampingFraction: 0.80), value: revealed)
        .animation(.spring(response: 0.30, dampingFraction: 0.80), value: flipped)
    }

    // MARK: - Main scroll content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerRow
                formatBody
                if shouldShowRevealSection { revealSection }
                if revealed || (challenge.format == .flashcard && flashcardGotIt != nil) {
                    doneButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Header row (eyebrow + topic + close)

    private var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: lang.isRTL ? .trailing : .leading, spacing: 5) {
                Text(DailyChallengeStrings.dailyChallenge(lang).uppercased())
                    .emEyebrow(lang, size: 11, tracking: 1.5)
                    .foregroundColor(themeManager.accentColor)
                Text(challenge.topic.capitalized)
                    .font(themeManager.isMidnightEmerald
                          ? EmType.serif(24, .semiBold)
                          : .system(size: 22, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

            Spacer(minLength: 8)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Format body router

    @ViewBuilder
    private var formatBody: some View {
        switch challenge.format {
        case .multipleChoice, .fillInBlank:
            mcOrFillBody
        case .trueFalse:
            trueFalseBody
        case .flashcard:
            flashcardBody
        }
    }

    // MARK: - Multiple Choice + Fill-In body (shared option-row UI)

    private var mcOrFillBody: some View {
        VStack(spacing: 14) {
            // Prompt card (reading content — scaled)
            promptCard

            // Arabic text for fill-in (the sentence with the blank context)
            if challenge.format == .fillInBlank, let arabic = challenge.arabicText {
                arabicCard(arabic)
            }

            // Source citation (chrome — fixed)
            if let source = challenge.source {
                sourceLine(source)
            }

            // Option rows
            if let options = challenge.options {
                VStack(spacing: 10) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        optionRow(text: option.text(for: lang), index: index)
                    }
                }
            }
        }
    }

    // MARK: - Option row

    private func optionRow(text: String, index: Int) -> some View {
        let state = optionState(for: index)
        return Button {
            guard !revealed else { return }
            Haptics.press()
            selectedIndex = index
            revealed = true
        } label: {
            HStack(spacing: 12) {
                // Index bubble
                ZStack {
                    Circle()
                        .fill(bubbleFill(state))
                        .frame(width: 32, height: 32)
                    Text(optionLetter(index))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(bubbleText(state))
                }

                // Option text (reading content — scaled)
                Text(text)
                    .font(themeManager.isMidnightEmerald
                          ? EmType.serif(16 * readingSettings.scale, .medium)
                          : .system(size: 16 * readingSettings.scale))
                    .foregroundColor(optionText(state))
                    .lineSpacing(4 * readingSettings.scale)
                    .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

                // Correct / wrong icon
                if revealed {
                    stateIcon(state)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor(state))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(rowFill(state))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(rowBorder(state), lineWidth: 1.5)
            )
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(revealed)
    }

    private func optionLetter(_ i: Int) -> String {
        let letters = ["A", "B", "C", "D", "E"]
        return i < letters.count ? letters[i] : "\(i + 1)"
    }

    // MARK: - Option coloring helpers (called from @MainActor view context)

    private enum OptionState { case neutral, correct, wrong, correctHighlight }

    private func optionState(for index: Int) -> OptionState {
        guard revealed else { return .neutral }
        let isCorrect = index == challenge.correctIndex
        let isChosen  = index == selectedIndex
        if isCorrect && isChosen { return .correctHighlight }
        if isCorrect              { return .correct }
        if isChosen               { return .wrong }
        return .neutral
    }

    private func rowFill(_ state: OptionState) -> Color {
        switch state {
        case .neutral:           return themeManager.isMidnightEmerald ? Color.white.opacity(0.04) : Color.white.opacity(0.7)
        case .correct:           return Color.green.opacity(0.12)
        case .wrong:             return Color.red.opacity(0.10)
        case .correctHighlight:  return Color.green.opacity(0.16)
        }
    }

    private func rowBorder(_ state: OptionState) -> Color {
        switch state {
        case .neutral:           return themeManager.strokeColor
        case .correct:           return Color.green.opacity(0.55)
        case .wrong:             return Color.red.opacity(0.45)
        case .correctHighlight:  return Color.green.opacity(0.70)
        }
    }

    private func bubbleFill(_ state: OptionState) -> Color {
        switch state {
        case .neutral:          return themeManager.accentChip
        case .correct:          return Color.green.opacity(0.25)
        case .wrong:            return Color.red.opacity(0.20)
        case .correctHighlight: return Color.green.opacity(0.30)
        }
    }

    private func bubbleText(_ state: OptionState) -> Color {
        switch state {
        case .neutral:           return themeManager.accentColor
        case .correct, .correctHighlight: return Color.green
        case .wrong:             return Color.red
        }
    }

    private func optionText(_ state: OptionState) -> Color {
        switch state {
        case .neutral, .correct, .correctHighlight: return themeManager.primaryText
        case .wrong:                                return themeManager.secondaryText
        }
    }

    private func iconColor(_ state: OptionState) -> Color {
        switch state {
        case .correct, .correctHighlight: return .green
        case .wrong:                      return .red
        case .neutral:                    return .clear
        }
    }

    private func stateIcon(_ state: OptionState) -> Image {
        switch state {
        case .correct, .correctHighlight: return Image(systemName: "checkmark.circle.fill")
        case .wrong:                      return Image(systemName: "xmark.circle.fill")
        case .neutral:                    return Image(systemName: "circle")
        }
    }

    // MARK: - True / False body

    private var trueFalseBody: some View {
        VStack(spacing: 14) {
            promptCard

            if let source = challenge.source {
                sourceLine(source)
            }

            HStack(spacing: 12) {
                tfButton(label: DailyChallengeStrings.trueLabel(lang),
                         answer: true,
                         sfSymbol: "checkmark.circle.fill")
                tfButton(label: DailyChallengeStrings.falseLabel(lang),
                         answer: false,
                         sfSymbol: "xmark.circle.fill")
            }
        }
    }

    private func tfButton(label: String, answer: Bool, sfSymbol: String) -> some View {
        let chosen = selectedIndex == (answer ? 1 : 0)
        let correct = challenge.trueFalseAnswer == answer
        let showResult = revealed
        let isCorrectResult = showResult && correct
        let isWrongResult   = showResult && chosen && !correct

        // Pre-compute colors to avoid type-checker overload
        let iconColor: Color = showResult
            ? (isCorrectResult ? .green : (isWrongResult ? .red : themeManager.tertiaryText))
            : (answer ? .green : .red)
        let labelColor: Color = showResult
            ? (isCorrectResult ? .green : (isWrongResult ? .red : themeManager.tertiaryText))
            : themeManager.primaryText
        let bgFill: Color = showResult
            ? (isCorrectResult ? Color.green.opacity(0.12) : (isWrongResult ? Color.red.opacity(0.10) : Color.clear))
            : (themeManager.isMidnightEmerald ? Color.white.opacity(0.04) : Color.white.opacity(0.7))
        let borderColor: Color = showResult
            ? (isCorrectResult ? Color.green.opacity(0.55) : (isWrongResult ? Color.red.opacity(0.45) : themeManager.strokeColor))
            : themeManager.strokeColor

        return Button {
            guard !revealed else { return }
            Haptics.press()
            selectedIndex = answer ? 1 : 0
            revealed = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(labelColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(bgFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(revealed)
    }

    // MARK: - Flashcard body

    private var flashcardBody: some View {
        VStack(spacing: 14) {
            // Card with flip animation
            ZStack {
                // Back face
                flashcardFace(isFront: false)
                    .opacity(flipped ? 1 : 0)
                    .rotation3DEffect(.degrees(flipped ? 0 : 180),
                                      axis: (x: 0, y: 1, z: 0))

                // Front face
                flashcardFace(isFront: true)
                    .opacity(flipped ? 0 : 1)
                    .rotation3DEffect(.degrees(flipped ? -180 : 0),
                                      axis: (x: 0, y: 1, z: 0))
            }
            .pressable(depth: 0.97, dim: 0.95) {
                guard !flipped else { return }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    flipped = true
                }
            }

            // "Got it" / "Review again" buttons — appear after flip
            if flipped && flashcardGotIt == nil {
                HStack(spacing: 12) {
                    flashcardGradeButton(label: DailyChallengeStrings.reviewAgain(lang),
                                         sfSymbol: "arrow.counterclockwise",
                                         gotIt: false)
                    flashcardGradeButton(label: DailyChallengeStrings.gotIt(lang),
                                         sfSymbol: "hand.thumbsup.fill",
                                         gotIt: true)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Source (chrome — fixed)
            if let source = challenge.source {
                sourceLine(source)
            }
        }
    }

    @ViewBuilder
    private func flashcardFace(isFront: Bool) -> some View {
        EmCard(glow: isFront ? false : true) {
            VStack(spacing: 16) {
                if isFront {
                    // Front: prompt + optional arabicText
                    if let arabic = challenge.arabicText {
                        Text(arabic)
                            .font(EmType.arabic(28 * readingSettings.scale))
                            .foregroundColor(themeManager.primaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10 * readingSettings.scale)
                            .frame(maxWidth: .infinity)
                            .environment(\.layoutDirection, .rightToLeft)
                    }
                    Text(challenge.prompt.text(for: lang))
                        .font(themeManager.isMidnightEmerald
                              ? EmType.serif(17 * readingSettings.scale, .medium)
                              : .system(size: 17 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                        .lineSpacing(5 * readingSettings.scale)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

                    // Tap hint (chrome — fixed)
                    Text(DailyChallengeStrings.flipCard(lang).uppercased())
                        .emEyebrow(lang, size: 10, tracking: 1.2)
                        .foregroundColor(themeManager.accentColor)
                        .padding(.top, 4)
                } else {
                    // Back: answer + explanation
                    if let answer = challenge.answer {
                        Text(answer.text(for: lang))
                            .font(themeManager.isMidnightEmerald
                                  ? EmType.serif(18 * readingSettings.scale, .semiBold)
                                  : .system(size: 18 * readingSettings.scale, weight: .semibold))
                            .foregroundColor(themeManager.accentBright)
                            .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                            .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                            .lineSpacing(5 * readingSettings.scale)
                            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    }
                    if let explanation = challenge.explanation {
                        Divider().background(themeManager.strokeColor)
                        Text(explanation.text(for: lang))
                            .font(themeManager.isMidnightEmerald
                                  ? EmType.serif(15 * readingSettings.scale, .medium)
                                  : .system(size: 15 * readingSettings.scale))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                            .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                            .lineSpacing(5 * readingSettings.scale)
                            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    }
                }
            }
            .padding(22)
        }
        .frame(minHeight: 180)
    }

    private func flashcardGradeButton(label: String, sfSymbol: String, gotIt: Bool) -> some View {
        Button {
            Haptics.press()
            flashcardGotIt = gotIt
            earnedSawab = manager.completeFlashcard(challenge: challenge, gotIt: gotIt)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                showCompletion = true
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: sfSymbol).font(.system(size: 14, weight: .semibold))
                Text(label).font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(gotIt ? themeManager.onAccentText : themeManager.accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(gotIt
                          ? AnyShapeStyle(themeManager.accentGradient)
                          : AnyShapeStyle(themeManager.accentChip))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(gotIt ? Color.clear : themeManager.strokeColor, lineWidth: 1)
            )
            .shadow(color: gotIt ? themeManager.accentColor.opacity(0.25) : .clear,
                    radius: 16, x: 0, y: 6)
        }
        .buttonStyle(EmPressStyle())
    }

    // MARK: - Reveal section (explanation after MC/TF/fill-in answer)

    private var shouldShowRevealSection: Bool {
        guard challenge.format != .flashcard else { return false }
        return revealed
    }

    private var revealSection: some View {
        VStack(spacing: 12) {
            // Correct / not-quite header (chrome — fixed size)
            let wasCorrect = (selectedIndex == challenge.correctIndex)
                || (challenge.format == .trueFalse && selectedIndex == (challenge.trueFalseAnswer == true ? 1 : 0))
            HStack(spacing: 8) {
                Image(systemName: wasCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(wasCorrect ? .green : themeManager.accentColor)
                Text(wasCorrect
                     ? DailyChallengeStrings.correct(lang)
                     : DailyChallengeStrings.notQuite(lang))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(wasCorrect ? .green : themeManager.accentColor)
            }
            .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

            // Explanation (reading content — scaled)
            if let explanation = challenge.explanation {
                EmCard {
                    Text(explanation.text(for: lang))
                        .font(themeManager.isMidnightEmerald
                              ? EmType.serif(16 * readingSettings.scale, .medium)
                              : .system(size: 16 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                        .lineSpacing(5 * readingSettings.scale)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                        .padding(18)
                }
            }

            // Arabic text (fill-in shows it above options; other formats show it in reveal if present)
            if challenge.format != .fillInBlank, let arabic = challenge.arabicText {
                arabicCard(arabic)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Done button (leads to completion)

    private var doneButton: some View {
        EmGoldCTA(title: DailyChallengeStrings.doneButton(lang)) {
            triggerCompletion()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func triggerCompletion() {
        guard challenge.format != .flashcard else {
            // Flashcard completes via gotIt/reviewAgain buttons; this path shouldn't be reached
            withAnimation { showCompletion = true }
            return
        }
        let wasCorrect: Bool
        switch challenge.format {
        case .trueFalse:
            wasCorrect = (selectedIndex == (challenge.trueFalseAnswer == true ? 1 : 0))
        default:
            wasCorrect = selectedIndex == challenge.correctIndex
        }
        earnedSawab = manager.complete(challenge: challenge, wasCorrect: wasCorrect)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            showCompletion = true
        }
    }

    // MARK: - Completion layer

    private var completionLayer: some View {
        VStack(spacing: 28) {
            Spacer()

            // Sawab burst (chrome icon + scaled number)
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentChip)
                        .frame(width: 96, height: 96)
                    Image(systemName: "star.fill")
                        .font(.system(size: 36))
                        .foregroundColor(themeManager.accentBright)
                }

                Text(DailyChallengeStrings.sawabEarned(earnedSawab, lang))
                    .font(themeManager.isMidnightEmerald
                          ? EmType.serif(34, .semiBold)
                          : .system(size: 32, weight: .bold))
                    .foregroundColor(themeManager.accentBright)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

                Text(DailyChallengeStrings.completionTitle(lang))
                    .font(themeManager.isMidnightEmerald
                          ? EmType.serif(22, .medium)
                          : .system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
            }

            // Streak flourish
            streakBadge

            Spacer()

            // Dismiss CTA (chrome — fixed)
            EmGoldCTA(title: DailyChallengeStrings.doneForToday(lang),
                      sfSymbol: "checkmark") {
                onCompleted()
                dismiss()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }

    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 16))
                .foregroundColor(themeManager.accentColor)
            Text(DailyChallengeStrings.streakLabel(manager.streak.currentStreak, lang))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(themeManager.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule().fill(themeManager.accentChip)
        )
        .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }

    // MARK: - Shared subviews

    /// Prompt card — reading content, scaled.
    private var promptCard: some View {
        EmCard {
            Text(challenge.prompt.text(for: lang))
                .font(themeManager.isMidnightEmerald
                      ? EmType.serif(18 * readingSettings.scale, .medium)
                      : .system(size: 18 * readingSettings.scale))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                .lineSpacing(5 * readingSettings.scale)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .padding(20)
        }
    }

    /// Arabic verse / du'a display — always RTL, reading content scaled.
    private func arabicCard(_ arabic: String) -> some View {
        EmCard(glow: true) {
            Text(arabic)
                .font(EmType.arabic(28 * readingSettings.scale))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(10 * readingSettings.scale)
                .frame(maxWidth: .infinity)
                .padding(20)
                .environment(\.layoutDirection, .rightToLeft)
                .textSelection(.enabled)
        }
    }

    /// Source citation — chrome, fixed size.
    private func sourceLine(_ source: String) -> some View {
        Text(source)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(themeManager.tertiaryText)
            .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}

// MARK: - DEBUG samples + previews

#if DEBUG
extension DailyChallenge {
    static let sampleMultipleChoice = DailyChallenge(
        id: "dc_debug_mc",
        format: .multipleChoice,
        topic: "Qur'an",
        prompt: LocalizedText(
            en: "In which surah does the Āyat al-Kursī (Verse of the Throne) appear?",
            ur: "آیۃ الکرسی کس سورۃ میں ہے؟",
            ar: "في أي سورة تقع آية الكرسي؟"
        ),
        options: [
            LocalizedText(en: "Surah Yāsīn (36)", ur: "سورۃ یٰس (۳۶)", ar: "سورة يس (٣٦)"),
            LocalizedText(en: "Surah Al-Baqarah (2)", ur: "سورۃ البقرہ (۲)", ar: "سورة البقرة (٢)"),
            LocalizedText(en: "Surah Al-Fātiḥah (1)", ur: "سورۃ الفاتحہ (۱)", ar: "سورة الفاتحة (١)"),
            LocalizedText(en: "Surah Āl ʿImrān (3)", ur: "سورۃ آل عمران (۳)", ar: "سورة آل عمران (٣)")
        ],
        correctIndex: 1,
        answer: nil,
        explanation: LocalizedText(
            en: "Āyat al-Kursī is verse 255 of Surah Al-Baqarah, the longest verse about Allah's sovereignty and knowledge.",
            ur: "آیۃ الکرسی سورۃ البقرہ کی آیت نمبر ۲۵۵ ہے۔ یہ اللہ کی حاکمیت پر عظیم ترین آیت ہے۔",
            ar: "آية الكرسي هي الآية ٢٥٥ من سورة البقرة، وهي أعظم آية في القرآن عن سيادة الله وعلمه."
        ),
        arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
        source: "Qur'an 2:255"
    )

    static let sampleTrueFalse = DailyChallenge(
        id: "dc_debug_tf",
        format: .trueFalse,
        topic: "Ahlul Bayt",
        prompt: LocalizedText(
            en: "Imam Ali (عليه السلام) was the first person to embrace Islam according to Shia tradition.",
            ur: "امام علی (علیہ السلام) شیعہ روایت کے مطابق پہلے مسلمان تھے۔",
            ar: "كان الإمام علي (عليه السلام) أول من أسلم وفق التقليد الشيعي."
        ),
        options: nil,
        correctIndex: 1,     // 1 = true
        answer: nil,
        explanation: LocalizedText(
            en: "According to Shia tradition, Imam Ali accepted Islam as a child before any adult, followed by Lady Khadijah.",
            ur: "شیعہ روایت کے مطابق امام علی نے بچپن میں کسی بھی بالغ سے پہلے اسلام قبول کیا، پھر حضرت خدیجہ نے۔",
            ar: "وفق التقليد الشيعي، أسلم الإمام علي طفلاً قبل أي بالغ، ثم السيدة خديجة."
        ),
        arabicText: nil,
        source: nil
    )

    static let sampleFlashcard = DailyChallenge(
        id: "dc_debug_fc",
        format: .flashcard,
        topic: "Dua",
        prompt: LocalizedText(
            en: "What is the name of the du'a recited on the Day of Arafah?",
            ur: "یوم عرفہ پر کون سی دعا پڑھی جاتی ہے؟",
            ar: "ما اسم الدعاء الذي يُقرأ يوم عرفة؟"
        ),
        options: nil,
        correctIndex: nil,
        answer: LocalizedText(
            en: "Du'a Arafah of Imam Husayn (عليه السلام)",
            ur: "دعائے عرفہ امام حسین (علیہ السلام)",
            ar: "دعاء عرفة للإمام الحسين (عليه السلام)"
        ),
        explanation: LocalizedText(
            en: "Imam Husayn recited this profound supplication on the Day of Arafah in 60 AH, the year before Karbala.",
            ur: "امام حسین نے یہ عمیق دعا ۶۰ ہجری میں یوم عرفہ کو پڑھی، جو کربلا سے ایک سال پہلے تھی۔",
            ar: "قرأ الإمام الحسين هذا الدعاء العميق يوم عرفة عام ٦٠ هـ، قبل عام من كربلاء."
        ),
        arabicText: "إِلَٰهِي أَنَا الْفَقِيرُ فِي غِنَايَ فَكَيْفَ لَا أَكُونُ فَقِيرًا فِي فَقْرِي",
        source: "Mafatih al-Jinan"
    )

    static let sampleFillInBlank = DailyChallenge(
        id: "dc_debug_fib",
        format: .fillInBlank,
        topic: "Practice",
        prompt: LocalizedText(
            en: "Complete the phrase: \"Inna lillahi wa inna ilayhi _______\"",
            ur: "خالی جگہ بھریں: \"إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ _______\"",
            ar: "أكمل العبارة: \"إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ _______\""
        ),
        options: [
            LocalizedText(en: "rāji'ūn (returners)", ur: "رَاجِعُونَ (لوٹنے والے)", ar: "رَاجِعُونَ"),
            LocalizedText(en: "sābirūn (patient ones)", ur: "صَابِرُونَ (صابر لوگ)", ar: "صَابِرُونَ"),
            LocalizedText(en: "ḥāmidūn (praisers)", ur: "حَامِدُونَ (حمد کرنے والے)", ar: "حَامِدُونَ")
        ],
        correctIndex: 0,
        answer: nil,
        explanation: LocalizedText(
            en: "The full verse: 'Indeed, to Allah we belong and to Him we shall return.' (Qur'an 2:156). Recited at times of loss.",
            ur: "پوری آیت: 'بے شک ہم اللہ کے ہیں اور اسی کی طرف لوٹیں گے۔' (قرآن ۲:۱۵۶)۔ مصیبت کے وقت پڑھی جاتی ہے۔",
            ar: "الآية الكاملة: «إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ» (القرآن ٢:١٥٦). تُقرأ عند المصائب."
        ),
        arabicText: "إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ",
        source: "Qur'an 2:156"
    )
}

// MARK: - Previews (one per format × two themes)

#Preview("Multiple Choice — English (Emerald)") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    DailyChallengeView(challenge: .sampleMultipleChoice, onCompleted: {})
}

#Preview("Multiple Choice — Urdu RTL (Light)") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    DailyChallengeView(challenge: .sampleMultipleChoice, onCompleted: {})
}

#Preview("True/False — English (Emerald)") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    DailyChallengeView(challenge: .sampleTrueFalse, onCompleted: {})
}

#Preview("True/False — Urdu RTL (Light)") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    DailyChallengeView(challenge: .sampleTrueFalse, onCompleted: {})
}

#Preview("Flashcard — English (Emerald)") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    DailyChallengeView(challenge: .sampleFlashcard, onCompleted: {})
}

#Preview("Flashcard — Arabic RTL (Emerald)") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.arabic)
    DailyChallengeView(challenge: .sampleFlashcard, onCompleted: {})
}

#Preview("Fill-in-Blank — English (Light)") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    DailyChallengeView(challenge: .sampleFillInBlank, onCompleted: {})
}

#Preview("Fill-in-Blank — Urdu RTL (Emerald)") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    DailyChallengeView(challenge: .sampleFillInBlank, onCompleted: {})
}
#endif
