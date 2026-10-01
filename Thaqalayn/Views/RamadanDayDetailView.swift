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
    @Environment(\.dismiss) private var dismiss

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
                emeraldSections
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
                        Text(JourneyStrings.backToJourney)
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .hideTabBar()
    }

    @ViewBuilder private var emeraldSections: some View {
        VStack(spacing: 20) {
            EmJourneyDetailHeader(
                dayNumber: day.dayNumber,
                icon: day.icon,
                theme: day.theme,
                themeArabic: day.themeArabic,
                statusLabel: isCompleted ? JourneyStrings.completed : nil,
                statusTint: themeManager.semanticGreen
            )

            EmDetailCard(icon: "hands.sparkles", label: JourneyStrings.duaZiyarat) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(day.dua.arabic)
                        .font(EmType.arabic(24 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    DuaListenButton(arabic: day.dua.arabic)
                    Text(day.dua.transliteration)
                        .font(EmType.serifItalic(16 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                    Text(day.dua.english)
                        .font(EmType.serif(17 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let source = day.dua.source {
                        Text("— \(source)")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                EmSectionLabel(icon: "book.pages", text: JourneyStrings.todaysVerses)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(day.verses) { verse in
                    RamadanVerseCard(
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

            EmDetailCard(icon: "lightbulb", label: JourneyStrings.tafsirFocus) {
                Text(day.tafsirFocus)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EmDetailCard(icon: "heart.text.square", label: JourneyStrings.reflection) {
                Text(day.reflection)
                    .font(EmType.serifItalic(18 * readingSettings.scale))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EmJourneyToggleButton(
                isDone: isCompleted,
                doneLabel: JourneyStrings.completed,
                todoLabel: JourneyStrings.markComplete,
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

struct RamadanVerseCard: View {
    let verse: RamadanVerse
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(verse.surahNumber)"],
              let v = verses["\(verse.verseNumber)"] else {
            return nil
        }
        return (v.arabicText, v.translation)
    }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == verse.surahNumber }?.englishName ?? "Surah \(verse.surahNumber)"
    }

    var body: some View {
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
                            Text(JourneyStrings.fullTafsir).font(.system(size: 12, weight: .semibold))
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
                    Text(verse.relevanceNote)
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
