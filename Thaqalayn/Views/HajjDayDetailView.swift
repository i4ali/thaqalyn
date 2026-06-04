//
//  HajjDayDetailView.swift
//  Thaqalayn
//
//  Detail view for a single day of the Dhul-Hijjah Journey
//  Shows theme, dua, verses, reflection, and completion button
//

import SwiftUI

struct HajjDayDetailView: View {
    let day: HajjDay
    @StateObject private var journeyManager = HajjJourneyManager.shared
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
                if themeManager.isMidnightEmerald {
                    emeraldSections
                } else {
                VStack(spacing: 24) {
                    // Day header
                    HajjDayHeader(day: day, isCompleted: isCompleted)

                    // Dua section
                    HajjDuaSection(dua: day.dua)

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
                            HajjVerseCard(
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
                    HajjCompleteButton(
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
                        Text("Journey")
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
                theme: day.theme,
                themeArabic: day.themeArabic,
                statusLabel: isCompleted ? "Completed" : nil,
                statusTint: themeManager.semanticGreen
            )

            EmDetailCard(icon: "hands.sparkles", label: "Today's Dua") {
                VStack(alignment: .leading, spacing: 12) {
                    Text(day.dua.arabic)
                        .font(EmType.arabic(24))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(day.dua.transliteration)
                        .font(EmType.serifItalic(16))
                        .foregroundColor(themeManager.secondaryText)
                    Text(day.dua.english)
                        .font(EmType.serif(17, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4)
                    if let source = day.dua.source {
                        Text("— \(source)")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                EmSectionLabel(icon: "book.pages", text: "Today's Verses")
                    .padding(.horizontal, 20)
                ForEach(day.verses) { verse in
                    HajjVerseCard(
                        verse: verse,
                        onNavigate: {
                            selectedVerseForNav = (verse.surahNumber, verse.verseNumber)
                            navigateToVerse = true
                        }
                    )
                }
            }

            EmDetailCard(icon: "lightbulb", label: "Tafsir Focus") {
                Text(day.tafsirFocus)
                    .font(EmType.serif(17, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EmDetailCard(icon: "heart.text.square", label: "Reflection") {
                Text(day.reflection)
                    .font(EmType.serifItalic(18))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EmJourneyToggleButton(
                isDone: isCompleted,
                doneLabel: "Day Completed",
                todoLabel: "Mark Day as Complete",
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

struct HajjDayHeader: View {
    let day: HajjDay
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

struct HajjDuaSection: View {
    let dua: HajjDua
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

struct HajjVerseCard: View {
    let verse: HajjVerse
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
                    Button(action: onNavigate) {
                        HStack(spacing: 4) {
                            Text("Full Tafsir").font(.system(size: 12, weight: .semibold))
                            Image(systemName: "arrow.right").font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                    .buttonStyle(EmPressStyle())
                }
                if let data = verseData {
                    Text(data.arabic)
                        .font(EmType.arabic(25))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(data.translation)
                        .font(EmType.serif(16, .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(3)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(verse.relevanceNote)
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2)
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

struct HajjCompleteButton: View {
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
        HajjDayDetailView(
            day: HajjDay(
                id: "day1",
                dayNumber: 1,
                theme: "The Blessed Ten",
                themeArabic: "العَشْر المُبارَكة",
                icon: "calendar.badge.exclamationmark",
                dua: HajjDua(
                    arabic: "اللَّهُمَّ هَذِهِ الْأَيَّامُ الَّتِي فَضَّلْتَهَا عَلَى الْأَيَّامِ",
                    transliteration: "Allahumma hadhihi-l-ayyamu-llati faddaltaha 'ala-l-ayyam",
                    english: "O Allah, these are the days You have favored above all other days.",
                    source: "Mafatih al-Jinan"
                ),
                verses: [],
                tafsirFocus: "The virtue of the first ten days of Dhul-Hijjah.",
                reflection: "How will you make the most of these ten blessed days?"
            )
        )
    }
}
