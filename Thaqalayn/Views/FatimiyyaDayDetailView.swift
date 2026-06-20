//
//  FatimiyyaDayDetailView.swift
//  Thaqalayn
//
//  Detail view for a single day of the Ayyam-e-Fatimiyya Journey
//  Shows theme, dua/ziyarat, verses, reflection, and observance button.
//  Fatimiyya is a somber azadari (mourning) observance — no celebratory treatment.
//

import SwiftUI

struct FatimiyyaDayDetailView: View {
    let day: FatimiyyaDay
    @StateObject private var journeyManager = FatimiyyaJourneyManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var isObserved: Bool {
        journeyManager.isDayObserved(day.dayNumber)
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
                    FatimiyyaDayHeader(day: day, isObserved: isObserved)

                    // Dua / Ziyarat section
                    FatimiyyaDuaSection(dua: day.dua)

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
                            FatimiyyaVerseCard(
                                verse: verse,
                                onNavigate: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                        selectedVerseForNav = (verse.surahNumber, verse.verseNumber)
                                        navigateToVerse = true
                                    }
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

                    // Mark as observed button
                    FatimiyyaObserveButton(
                        isObserved: isObserved,
                        onToggle: {
                            if isObserved {
                                journeyManager.unmarkDayObserved(day.dayNumber)
                            } else {
                                journeyManager.markDayObserved(day.dayNumber)
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
                statusLabel: isObserved ? JourneyStrings.observed(lang) : nil,
                statusTint: themeManager.secondaryText,
                emphasized: false,
                badgeSymbol: nil,
                badgeText: nil
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
                    FatimiyyaVerseCard(
                        verse: verse,
                        onNavigate: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                selectedVerseForNav = (verse.surahNumber, verse.verseNumber)
                                navigateToVerse = true
                            }
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
                isDone: isObserved,
                doneLabel: JourneyStrings.observed(lang),
                todoLabel: JourneyStrings.markObserved(lang),
                doneTint: themeManager.secondaryText,
                onToggle: {
                    if isObserved {
                        journeyManager.unmarkDayObserved(day.dayNumber)
                    } else {
                        journeyManager.markDayObserved(day.dayNumber)
                    }
                }
            )

            Spacer(minLength: 40)
        }
        .padding(.top, 4)
    }
}

struct FatimiyyaDayHeader: View {
    let day: FatimiyyaDay
    let isObserved: Bool
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

                if isObserved {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(JourneyStrings.observed(lang))
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.secondaryText)
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

struct FatimiyyaDuaSection: View {
    let dua: FatimiyyaDua
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

struct FatimiyyaVerseCard: View {
    let verse: FatimiyyaVerse
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

struct FatimiyyaObserveButton: View {
    let isObserved: Bool
    let onToggle: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    // Subdued observed state — a quiet, somber confirmation rather than a
    // celebratory green "Completed!" treatment. Fatimiyya is azadari, not achievement.
    private var observedGradient: LinearGradient {
        LinearGradient(
            colors: [
                themeManager.secondaryText.opacity(0.55),
                themeManager.secondaryText.opacity(0.40)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isObserved ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))

                Text(isObserved ? JourneyStrings.observed(languageManager.selectedLanguage) : JourneyStrings.markObserved(languageManager.selectedLanguage))
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isObserved ? observedGradient : themeManager.accentGradient)
                    .shadow(
                        color: (isObserved ? themeManager.secondaryText : themeManager.accentColor).opacity(0.25),
                        radius: 12
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationView {
        FatimiyyaDayDetailView(
            day: FatimiyyaDay(
                id: "day1",
                dayNumber: 1,
                theme: "The Light of az-Zahrā",
                themeArabic: "نُورُ الزَّهْرَاء",
                icon: "star.fill",
                dua: FatimiyyaDua(
                    arabic: "اللَّهُمَّ صَلِّ عَلَى فَاطِمَةَ وَأَبِيهَا وَبَعْلِهَا وَبَنِيهَا",
                    transliteration: "Allahumma salli 'ala Fatimah wa abeeha wa ba'liha wa baneeha",
                    english: "O Allah, send blessings upon Fatimah, her father, her husband and her sons.",
                    source: nil,
                    englishUr: "اے اللہ! فاطمہؑ، ان کے والد، ان کے شوہر اور ان کے بیٹوں پر درود بھیج۔",
                    sourceUr: nil
                ),
                verses: [],
                tafsirFocus: "Reflecting on the station of Lady Fatimah al-Zahrā (AS) in the Quran.",
                reflection: "How can we honour the memory of az-Zahrā (AS) in our daily lives?",
                themeUr: "سیدہ زہراؑ کا نور",
                tafsirFocusUr: "قرآن میں سیدہ فاطمہ زہراؑ کے مقام پر غور و فکر۔",
                reflectionUr: "ہم اپنی روزمرہ زندگی میں سیدہ زہراؑ کی یاد کو کیسے زندہ رکھ سکتے ہیں؟"
            )
        )
    }
}
