//
//  ArbaeenDayDetailView.swift
//  Thaqalayn
//
//  Detail view for a single station of the Arbaeen Journey ("The Return").
//  Shows theme, dua/ziyarat (with an optional "read full ziyarat" disclosure on the
//  Station 8 finale), verses, tafsir focus, reflection, and the observance button.
//  Arbaeen is a somber azadari (mourning) observance — no celebratory treatment.
//

import SwiftUI

struct ArbaeenDayDetailView: View {
    let day: ArbaeenDay
    @StateObject private var journeyManager = ArbaeenJourneyManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false
    @State private var showFullZiyarat = false

    var isObserved: Bool {
        journeyManager.isDayObserved(day.dayNumber)
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
        .sheet(isPresented: $showFullZiyarat) {
            if let full = day.dua.fullArabic {
                ArbaeenFullZiyaratSheet(
                    arabic: full,
                    english: day.dua.fullEnglish,
                    source: day.dua.source
                )
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
                statusLabel: isObserved ? JourneyStrings.observed : nil,
                statusTint: themeManager.secondaryText,
                emphasized: false,
                badgeSymbol: nil,
                badgeText: nil
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let source = day.dua.source {
                        Text("— \(source)")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if day.dua.fullArabic != nil {
                        Button {
                            showFullZiyarat = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(JourneyStrings.readFullZiyarat)
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(themeManager.accentColor)
                        }
                        .buttonStyle(EmPressStyle())
                        .padding(.top, 2)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                EmSectionLabel(icon: "book.pages", text: JourneyStrings.todaysVerses)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(day.verses) { verse in
                    ArbaeenVerseCard(
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
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EmDetailCard(icon: "heart.text.square", label: JourneyStrings.reflection) {
                Text(day.reflection)
                    .font(EmType.serifItalic(18 * readingSettings.scale))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EmJourneyToggleButton(
                isDone: isObserved,
                doneLabel: JourneyStrings.observed,
                todoLabel: JourneyStrings.markObserved,
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

/// The full Ziyarat of Arbaeen, shown in a sheet from the Station 8 "read full" link.
struct ArbaeenFullZiyaratSheet: View {
    let arabic: String
    let english: String?
    let source: String?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(arabic)
                            .font(EmType.arabic(23 * readingSettings.scale))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(12 * readingSettings.scale)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        DuaListenButton(arabic: arabic)

                        if let english = english {
                            Text(english)
                                .font(EmType.serif(16 * readingSettings.scale, .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .lineSpacing(5 * readingSettings.scale)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if let source = source {
                            Text("— \(source)")
                                .font(.system(size: 12.5, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(JourneyStrings.fullZiyaratTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(JourneyStrings.done) { dismiss() }
                        .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct ArbaeenVerseCard: View {
    let verse: ArbaeenVerse
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
