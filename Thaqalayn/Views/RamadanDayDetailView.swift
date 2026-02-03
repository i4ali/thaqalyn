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

                            Text("TODAY'S VERSES")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)

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

                            Text("TAFSIR FOCUS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)
                        }

                        Text(day.tafsirFocus)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background {
                        if themeManager.selectedTheme == .warmInviting {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.98, green: 0.98, blue: 0.95))
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.accentColor.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Reflection section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text("REFLECTION")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)
                        }

                        Text(day.reflection)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4)
                            .italic()
                    }
                    .padding(20)
                    .background {
                        if themeManager.selectedTheme == .warmInviting {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        }
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
                        Text("Journey")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct RamadanDayHeader: View {
    let day: RamadanDay
    let isCompleted: Bool
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            // Day badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: day.icon)
                        .font(.system(size: 14, weight: .semibold))

                    Text("Day \(day.dayNumber)")
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
                        Text("Completed")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                }

                Spacer()
            }

            // Theme
            VStack(alignment: .leading, spacing: 8) {
                Text(day.theme)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)

                Text(day.themeArabic)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(themeManager.accentColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct RamadanDuaSection: View {
    let dua: RamadanDua
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.accentColor)

                Text("TODAY'S DUA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.secondaryText)
                    .tracking(1.2)

                Spacer()
            }

            // Arabic
            Text(dua.arabic)
                .font(.custom("AmiriQuran-Regular", size: 24))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(8)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Transliteration
            Text(dua.transliteration)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .italic()

            // English translation
            Text(dua.english)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(4)

            // Source
            if let source = dua.source {
                Text("— \(source)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(20)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

struct RamadanVerseCard: View {
    let verse: RamadanVerse
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared

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
        VStack(spacing: 0) {
            // Verse header
            HStack {
                Text("\(surahName) (\(verse.surahNumber):\(verse.verseNumber))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.accentColor)

                Spacer()

                Button(action: onNavigate) {
                    HStack(spacing: 4) {
                        Text("Full Tafsir")
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
                        .font(.custom("AmiriQuran-Regular", size: 22))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(6)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Translation
                    Text(data.translation)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4)
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

                Text(verse.relevanceNote)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(2)
            }
            .padding(16)
            .background {
                if themeManager.selectedTheme == .warmInviting {
                    Rectangle()
                        .fill(Color(red: 0.98, green: 0.98, blue: 0.95))
                } else {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.05))
                }
            }
        }
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

struct RamadanCompleteButton: View {
    let isCompleted: Bool
    let onToggle: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

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

                Text(isCompleted ? "Day Completed" : "Mark Day as Complete")
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
                    source: "Sahih Abu Dawud"
                ),
                verses: [],
                tafsirFocus: "Explore gratitude in the Quran.",
                reflection: "What are you grateful for today?"
            )
        )
    }
}
