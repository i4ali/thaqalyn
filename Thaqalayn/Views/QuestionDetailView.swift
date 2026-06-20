//
//  QuestionDetailView.swift
//  Thaqalayn
//
//  Detailed view showing question with verse answers and relevance notes
//

import SwiftUI

struct QuestionDetailView: View {
    let question: Question
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var questionsManager = QuestionsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    private var isRTL: Bool { languageManager.selectedLanguage.isRTL }
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var relatedQuestions: [Question] {
        question.relatedQuestions.compactMap { id in
            questionsManager.question(byId: id)
        }
    }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Questions")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.36)
    }

    private var legacyBody: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Question header
                    VStack(spacing: 16) {
                        // Category badge
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: question.categoryIcon)
                                    .font(.system(size: 14, weight: .semibold))

                                Text(question.category.displayName)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(themeManager.accentColor.opacity(0.15))
                            }

                            Spacer()
                        }

                        // Question text
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(themeManager.accentColor)

                                Text("THE QUESTION")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            Text(question.question(for: languageManager.selectedLanguage))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.primaryText)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                        }
                    }
                    .padding(24)
                    .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                            .shadow(
                                color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06),
                                radius: 16, x: 0, y: 4
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Quranic answer header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text("QURANIC ANSWER")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)
                        }

                        Text("The Quran answers this question in \(question.verseCount) verse\(question.verseCount == 1 ? "" : "s"):")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Verses with answers
                    ForEach(Array(question.verses.enumerated()), id: \.element.verseNumber) { index, questionVerse in
                        VerseAnswerCard(
                            questionVerse: questionVerse,
                            index: index + 1,
                            totalVerses: question.verseCount,
                            onNavigate: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                    selectedVerseForNav = (questionVerse.surahNumber, questionVerse.verseNumber)
                                    navigateToVerse = true
                                }
                            }
                        )
                    }

                    // From the Ahlul Bayt (ʿa)
                    if let narration = question.narration {
                        AhlulBaytNarrationCard(narration: narration)
                    }

                    // Related questions
                    if !relatedQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "link.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.accentColor)

                                Text("RELATED QUESTIONS")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            ForEach(relatedQuestions) { relatedQ in
                                RelatedQuestionCard(question: relatedQ)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }

            // Hidden NavigationLink for verse navigation
            if let verseNav = selectedVerseForNav,
               let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == verseNav.surah }) {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahData, targetVerse: verseNav.verse),
                    isActive: $navigateToVerse
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
    }

    @ViewBuilder private var emeraldBody: some View {
        ZStack {
            // Adaptive background (emerald-aware)
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 20) {
                    // Question header card
                    EmCard {
                        VStack(alignment: .leading, spacing: 16) {
                            // Category badge
                            HStack(spacing: 7) {
                                Image(systemName: question.categoryIcon)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(question.category.displayName)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 13).padding(.vertical, 7)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))

                            // Question text (prominent serif)
                            VStack(alignment: .leading, spacing: 10) {
                                EmSectionLabel(icon: "questionmark.circle", text: "The Question")
                                Text(question.question(for: languageManager.selectedLanguage))
                                    .font(EmType.serif(28, .semiBold))
                                    .foregroundColor(themeManager.primaryText)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(22)
                        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Quranic answer intro
                    VStack(alignment: .leading, spacing: 8) {
                        EmSectionLabel(icon: "book.closed", text: "Quranic Answer")
                        Text("The Quran answers this question in \(question.verseCount) verse\(question.verseCount == 1 ? "" : "s"):")
                            .font(EmType.serif(17, .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Verses with answers
                    ForEach(Array(question.verses.enumerated()), id: \.element.verseNumber) { index, questionVerse in
                        VerseAnswerCard(
                            questionVerse: questionVerse,
                            index: index + 1,
                            totalVerses: question.verseCount,
                            onNavigate: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                    selectedVerseForNav = (questionVerse.surahNumber, questionVerse.verseNumber)
                                    navigateToVerse = true
                                }
                            }
                        )
                    }

                    // From the Ahlul Bayt (ʿa)
                    if let narration = question.narration {
                        AhlulBaytNarrationCard(narration: narration)
                    }

                    // Related questions
                    if !relatedQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            EmSectionLabel(icon: "link", text: "Related Questions")
                            ForEach(relatedQuestions) { relatedQ in
                                RelatedQuestionCard(question: relatedQ)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 4)
            }

            // Hidden NavigationLink for verse navigation
            if let verseNav = selectedVerseForNav,
               let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == verseNav.surah }) {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahData, targetVerse: verseNav.verse),
                    isActive: $navigateToVerse
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
    }
}

struct VerseAnswerCard: View {
    let questionVerse: QuestionVerse
    let index: Int
    let totalVerses: Int
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(questionVerse.surahNumber)"],
              let verse = verses["\(questionVerse.verseNumber)"] else {
            return nil
        }
        // Verse translations exist only in English + Urdu; Arabic/English fall back to English.
        let translation: String
        if languageManager.selectedLanguage == .urdu, let urdu = verse.translationUrdu, !urdu.isEmpty {
            translation = urdu
        } else {
            translation = verse.translation
        }
        return (verse.arabicText, translation)
    }

    private var verseTranslationIsRTL: Bool { languageManager.selectedLanguage == .urdu }
    private var noteIsRTL: Bool { languageManager.selectedLanguage.isRTL }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == questionVerse.surahNumber }?.englishName ?? "Surah \(questionVerse.surahNumber)"
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(surahName) · \(questionVerse.surahNumber):\(questionVerse.verseNumber)")
                        .font(.system(size: 12, weight: .bold)).tracking(0.3)
                        .foregroundColor(themeManager.accentColor)
                    if questionVerse.isPrimary {
                        Text("PRIMARY")
                            .font(.system(size: 9, weight: .bold)).tracking(1)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                    Spacer()
                    VerseRecitationButton(surahNumber: questionVerse.surahNumber, verseNumber: questionVerse.verseNumber, size: 32)
                    Button(action: onNavigate) {
                        HStack(spacing: 4) {
                            Text("Full Tafsir").font(.system(size: 12, weight: .semibold))
                            Image(systemName: "arrow.right").font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                    .buttonStyle(EmPressStyle())
                }
                if let verse = verseData {
                    Text(verse.arabic)
                        .font(EmType.arabic(25 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(verse.translation)
                        .font(EmType.serif(16 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(3 * readingSettings.scale)
                        .multilineTextAlignment(verseTranslationIsRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: verseTranslationIsRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, verseTranslationIsRTL ? .rightToLeft : .leftToRight)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(questionVerse.relevanceNote(for: languageManager.selectedLanguage))
                        .font(.system(size: 13 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: noteIsRTL ? .trailing : .leading)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, noteIsRTL ? .rightToLeft : .leftToRight)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.accentChip.opacity(0.6))
                )
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
    }

    private var legacyBody: some View {
        VStack(spacing: 0) {
            // Verse header
            HStack(spacing: 12) {
                // Verse number badge
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 40, height: 40)

                    Text("\(index)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Verse \(index) of \(totalVerses)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)

                    Text("\(surahName) (\(questionVerse.surahNumber):\(questionVerse.verseNumber))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()

                VerseRecitationButton(surahNumber: questionVerse.surahNumber, verseNumber: questionVerse.verseNumber, size: 32)

                if questionVerse.isPrimary {
                    Text("PRIMARY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(themeManager.accentColor.opacity(0.15))
                        }
                }
            }
            .padding(20)

            Divider()
                .background(themeManager.strokeColor)

            // Verse text
            if let verse = verseData {
                VStack(alignment: .leading, spacing: 16) {
                    // Arabic text
                    Text(verse.arabic)
                        .font(.custom("AmiriQuran-Regular", size: 24 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .shadow(color: themeManager.isDarkMode ? themeManager.accentColor.opacity(0.32) : .clear, radius: 16)

                    // Translation
                    Text(verse.translation)
                        .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                        .multilineTextAlignment(verseTranslationIsRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: verseTranslationIsRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, verseTranslationIsRTL ? .rightToLeft : .leftToRight)
                }
                .padding(20)

                Divider()
                    .background(themeManager.strokeColor)
            }

            // Relevance note
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)

                    Text("Why This Answers")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                }

                Text(questionVerse.relevanceNote(for: languageManager.selectedLanguage))
                    .font(.system(size: 15 * readingSettings.scale, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
                    .frame(maxWidth: .infinity, alignment: noteIsRTL ? .trailing : .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .environment(\.layoutDirection, noteIsRTL ? .rightToLeft : .leftToRight)
            .padding(20)
            .background {
                Rectangle()
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
            }

            Divider()
                .background(themeManager.strokeColor)

            // Action buttons
            HStack(spacing: 16) {
                Button(action: onNavigate) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 14))

                        Text("Read Full Tafsir")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(themeManager.accentGradient)
                            .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06),
                    radius: 16, x: 0, y: 4
                )
        }
        .padding(.horizontal, 20)
    }
}

struct RelatedQuestionCard: View {
    let question: Question
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var navigateToQuestion = false

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        NavigationLink(destination: QuestionDetailView(question: question), isActive: $navigateToQuestion) {
            EmCard(cornerRadius: 16) {
                HStack(spacing: 12) {
                    EmIconChip(sfSymbol: question.categoryIcon, size: 38)
                    Text(question.question(for: languageManager.selectedLanguage))
                        .font(EmType.serif(17, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .padding(14)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle())
    }

    private var legacyBody: some View {
        NavigationLink(destination: QuestionDetailView(question: question), isActive: $navigateToQuestion) {
            HStack(spacing: 12) {
                Image(systemName: question.categoryIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 32, height: 32)
                    .background {
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.15))
                    }

                Text(question.question(for: languageManager.selectedLanguage))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .shadow(
                        color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                        radius: 8, x: 0, y: 2
                    )
            }
        }
        .buttonStyle(EmPressStyle())
    }
}

#Preview {
    NavigationView {
        QuestionDetailView(
            question: Question(
                id: "q1",
                questionEn: "What is the purpose of life?",
                questionAr: "ما هو الغرض من الحياة؟",
                questionUr: "زندگی کا مقصد کیا ہے؟",
                shortQuestionEn: "Life's purpose?",
                shortQuestionAr: "غرض الحياة؟",
                shortQuestionUr: "زندگی کا مقصد؟",
                category: .faith,
                verses: [
                    QuestionVerse(
                        surahNumber: 51,
                        verseNumber: 56,
                        relevanceNoteEn: "This verse directly states the purpose: to worship and know Allah.",
                        relevanceNoteAr: "تنص هذه الآية مباشرةً على الغرض: عبادة الله ومعرفته.",
                        relevanceNoteUr: "یہ آیت براہِ راست مقصد بیان کرتی ہے: اللہ کی عبادت اور معرفت۔",
                        isPrimary: true
                    )
                ],
                relatedQuestions: [],
                narration: nil
            )
        )
    }
}
