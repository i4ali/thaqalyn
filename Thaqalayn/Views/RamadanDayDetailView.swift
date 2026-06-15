//
//  RamadanDayDetailView.swift
//  Thaqalayn
//
//  Detail view for a single day of the Ramadan Journey
//  Shows theme, dua, verses, reflection, and completion button
//

import SwiftUI

struct RamadanDayDetailView: View {
    let day: RamadanDay
    @StateObject private var journeyManager = RamadanJourneyManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var isCompleted: Bool {
        journeyManager.isDayCompleted(day.dayNumber)
    }

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                if themeManager.isMidnightEmerald {
                    emeraldSections
                } else {
                VStack(spacing: 24) {
                    // Day header
                    RamadanDayHeader(day: day, isCompleted: isCompleted)

                    // Dua section
                    RamadanDuaSection(dua: day.dua)

                    // Verses section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text(JourneyStrings.todaysVerses(lang).uppercased())
                                .emEyebrow(lang, size: 14, tracking: 1.2)
                                .foregroundColor(themeManager.secondaryText)

                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        ForEach(day.verses) { verse in
                            RamadanVerseCard(
                                verse: verse,
                                onNavigate: {
                                    selectedVerseForNav = (verse.surahNumber, verse.verseNumber)
                                    navigateToVerse = true
                                }
                            )
                        }
                    }

                    // Tafsir focus
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text(JourneyStrings.tafsirFocus(lang).uppercased())
                                .emEyebrow(lang, size: 14, tracking: 1.2)
                                .foregroundColor(themeManager.secondaryText)
                        }

                        Text(day.localizedTafsir(lang))
                            .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4 * readingSettings.scale)
                            .multilineTextAlignment(isRTL ? .trailing : .leading)
                            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
                    }
                    .padding(.horizontal, 20)

                    // Reflection section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text(JourneyStrings.reflection(lang).uppercased())
                                .emEyebrow(lang, size: 14, tracking: 1.2)
                                .foregroundColor(themeManager.secondaryText)
                        }

                        Text(day.localizedReflection(lang))
                            .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4 * readingSettings.scale)
                            .italic()
                            .multilineTextAlignment(isRTL ? .trailing : .leading)
                            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                            .shadow(
                                color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                                radius: 12, x: 0, y: 4
                            )
                    }
                    .padding(.horizontal, 20)

                    // Mark complete button
                    RamadanCompleteButton(
                        isCompleted: isCompleted,
                        onToggle: {
                            if isCompleted {
                                journeyManager.unmarkDayCompleted(day.dayNumber)
                            } else {
                                journeyManager.markDayCompleted(day.dayNumber)
                            }
                        }
                    )

                    Spacer(minLength: 40)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(JourneyStrings.backToJourney(lang))
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.36)
        .hideTabBarInEmerald()
    }

    @ViewBuilder private var emeraldSections: some View {
        VStack(spacing: 20) {
            EmJourneyDetailHeader(
                dayNumber: day.dayNumber,
                icon: day.icon,
                theme: day.localizedTheme(lang),
                themeArabic: day.themeArabic,
                statusLabel: isCompleted ? JourneyStrings.completed(lang) : nil,
                statusTint: themeManager.semanticGreen
            )

            EmDetailCard(icon: "hands.sparkles", label: JourneyStrings.duaZiyarat(lang)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(day.dua.arabic)
                        .font(EmType.arabic(24 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(day.dua.transliteration)
                        .font(EmType.serifItalic(16 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                    Text(day.dua.localizedEnglish(lang))
                        .font(EmType.serif(17 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                    if let source = day.dua.localizedSource(lang) {
                        Text("— \(source)")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                EmSectionLabel(icon: "book.pages", text: JourneyStrings.todaysVerses(lang))
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                ForEach(day.verses) { verse in
                    RamadanVerseCard(
                        verse: verse,
                        onNavigate: {
                            selectedVerseForNav = (verse.surahNumber, verse.verseNumber)
                            navigateToVerse = true
                        }
                    )
                }
            }

            EmDetailCard(icon: "lightbulb", label: JourneyStrings.tafsirFocus(lang)) {
                Text(day.localizedTafsir(lang))
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .multilineTextAlignment(isRTL ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
            }

            EmDetailCard(icon: "heart.text.square", label: JourneyStrings.reflection(lang)) {
                Text(day.localizedReflection(lang))
                    .font(EmType.serifItalic(18 * readingSettings.scale))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .multilineTextAlignment(isRTL ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
            }

            EmJourneyToggleButton(
                isDone: isCompleted,
                doneLabel: JourneyStrings.completed(lang),
                todoLabel: JourneyStrings.markComplete(lang),
                doneTint: themeManager.semanticGreen,
                onToggle: {
                    if isCompleted {
                        journeyManager.unmarkDayCompleted(day.dayNumber)
                    } else {
                        journeyManager.markDayCompleted(day.dayNumber)
                    }
                }
            )

            Spacer(minLength: 40)
        }
        .padding(.top, 4)
    }
}

struct RamadanDayHeader: View {
    let day: RamadanDay
    let isCompleted: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        VStack(spacing: 16) {
            // Day badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: day.icon)
                        .font(.system(size: 14, weight: .semibold))

                    Text(JourneyStrings.dayN(day.dayNumber, lang))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(themeManager.accentColor.opacity(0.15))
                }

                if isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(JourneyStrings.completed(lang))
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                }

                Spacer()
            }

            // Theme
            VStack(alignment: .leading, spacing: 8) {
                Text(day.localizedTheme(lang))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
                    .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)

                Text(day.themeArabic)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(themeManager.accentColor)
                    .shadow(color: themeManager.isDarkMode ? themeManager.accentColor.opacity(0.32) : .clear, radius: 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
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
    }
}

struct RamadanDuaSection: View {
    let dua: RamadanDua
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.accentColor)

                Text(JourneyStrings.duaZiyarat(lang).uppercased())
                    .emEyebrow(lang, size: 14, tracking: 1.2)
                    .foregroundColor(themeManager.secondaryText)

                Spacer()
            }

            // Arabic
            Text(dua.arabic)
                .font(.custom("AmiriQuran-Regular", size: 24 * readingSettings.scale))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(8 * readingSettings.scale)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Transliteration
            Text(dua.transliteration)
                .font(.system(size: 14 * readingSettings.scale, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .italic()

            // English / Urdu translation
            Text(dua.localizedEnglish(lang))
                .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(4 * readingSettings.scale)
                .multilineTextAlignment(isRTL ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)

            // Source
            if let source = dua.localizedSource(lang) {
                Text("— \(source)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
        }
        .padding(.horizontal, 20)
    }
}

struct RamadanVerseCard: View {
    let verse: RamadanVerse
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(verse.surahNumber)"],
              let v = verses["\(verse.verseNumber)"] else {
            return nil
        }
        let t = (lang == .urdu ? (v.translationUrdu ?? v.translation) : v.translation)
        return (v.arabicText, t)
    }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == verse.surahNumber }?.englishName ?? "Surah \(verse.surahNumber)"
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(surahName) · \(verse.surahNumber):\(verse.verseNumber)")
                        .font(.system(size: 12, weight: .bold)).tracking(0.3)
                        .foregroundColor(themeManager.accentColor)
                    Spacer()
                    VerseRecitationButton(surahNumber: verse.surahNumber, verseNumber: verse.verseNumber, size: 32)
                    Button(action: onNavigate) {
                        HStack(spacing: 4) {
                            Text(JourneyStrings.fullTafsir(lang)).font(.system(size: 12, weight: .semibold))
                            Image(systemName: "arrow.right").font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                    .buttonStyle(EmPressStyle())
                }
                if let data = verseData {
                    Text(data.arabic)
                        .font(EmType.arabic(25 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(data.translation)
                        .font(EmType.serif(16 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(3 * readingSettings.scale)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(verse.localizedNote(lang))
                        .font(.system(size: 13 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2 * readingSettings.scale)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
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
            HStack {
                Text("\(surahName) (\(verse.surahNumber):\(verse.verseNumber))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.accentColor)

                Spacer()

                VerseRecitationButton(surahNumber: verse.surahNumber, verseNumber: verse.verseNumber, size: 32)

                Button(action: onNavigate) {
                    HStack(spacing: 4) {
                        Text(JourneyStrings.fullTafsir(lang))
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(16)

            Divider()
                .background(themeManager.strokeColor)

            // Verse text
            if let data = verseData {
                VStack(alignment: .leading, spacing: 12) {
                    // Arabic
                    Text(data.arabic)
                        .font(.custom("AmiriQuran-Regular", size: 22 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(6 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Translation
                    Text(data.translation)
                        .font(.system(size: 15 * readingSettings.scale, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                }
                .padding(16)

                Divider()
                    .background(themeManager.strokeColor)
            }

            // Relevance note
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.accentColor)

                Text(verse.localizedNote(lang))
                    .font(.system(size: 14 * readingSettings.scale, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(2 * readingSettings.scale)
            }
            .padding(16)
            .background {
                Rectangle()
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
            }
        }
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
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

struct RamadanCompleteButton: View {
    let isCompleted: Bool
    let onToggle: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    private var greenGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green, Color.green.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))

                Text(isCompleted ? JourneyStrings.completed(languageManager.selectedLanguage) : JourneyStrings.markComplete(languageManager.selectedLanguage))
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? greenGradient : themeManager.accentGradient)
                    .shadow(
                        color: (isCompleted ? Color.green : themeManager.accentColor).opacity(0.3),
                        radius: 12
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationView {
        RamadanDayDetailView(
            day: RamadanDay(
                id: "day1",
                dayNumber: 1,
                theme: "Gratitude",
                themeArabic: "الشُّكر",
                icon: "heart.fill",
                dua: RamadanDua(
                    arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ",
                    transliteration: "Allahumma a'inni 'ala dhikrika wa shukrik",
                    english: "O Allah, help me to remember You and be grateful.",
                    source: "Sahih Abu Dawud",
                    englishUr: "اے اللہ، اپنے ذکر اور شکر پر میری مدد فرما۔",
                    sourceUr: "سنن ابی داؤد"
                ),
                verses: [],
                tafsirFocus: "Explore gratitude in the Quran.",
                reflection: "What are you grateful for today?",
                themeUr: "شکرگزاری",
                tafsirFocusUr: "قرآن میں شکرگزاری پر غور کریں۔",
                reflectionUr: "آج آپ کس بات پر شکرگزار ہیں؟"
            )
        )
    }
}
