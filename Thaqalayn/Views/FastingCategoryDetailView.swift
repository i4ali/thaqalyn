//
//  FastingCategoryDetailView.swift
//  Thaqalayn
//
//  Detail view for a fasting category showing verses with full text
//

import SwiftUI

struct FastingCategoryDetailView: View {
    let category: FastingCategory
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Category header
                    VStack(spacing: 16) {
                        // Icon and title
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.accentGradient)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 10)

                                Image(systemName: category.icon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.title)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(themeManager.primaryText)

                                Text("\(category.verseCount) verse\(category.verseCount == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }

                            Spacer()
                        }

                        // Description
                        Text(category.description)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4)
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

                    // Verses header
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.accentColor)

                        Text("VERSES")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.secondaryText)
                            .tracking(1.2)

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Verses list
                    ForEach(Array(category.verses.enumerated()), id: \.element.id) { index, fastingVerse in
                        FastingVerseCard(
                            fastingVerse: fastingVerse,
                            index: index + 1,
                            totalVerses: category.verseCount,
                            onNavigate: {
                                selectedVerseForNav = (fastingVerse.surahNumber, fastingVerse.verseNumber)
                                navigateToVerse = true
                            }
                        )
                    }

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
                        Text("Fasting")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct FastingVerseCard: View {
    let fastingVerse: FastingVerse
    let index: Int
    let totalVerses: Int
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(fastingVerse.surahNumber)"],
              let verse = verses["\(fastingVerse.verseNumber)"] else {
            return nil
        }
        return (verse.arabicText, verse.translation)
    }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == fastingVerse.surahNumber }?.englishName ?? "Surah \(fastingVerse.surahNumber)"
    }

    var body: some View {
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

                    Text("\(surahName) (\(fastingVerse.surahNumber):\(fastingVerse.verseNumber))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()

                if fastingVerse.isKeyVerse {
                    Text("KEY VERSE")
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
                        .font(.custom("AmiriQuran-Regular", size: 24))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Translation
                    Text(verse.translation)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4)
                }
                .padding(20)

                Divider()
                    .background(themeManager.strokeColor)
            }

            // Relevance note
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)

                    Text("Relevance to Fasting")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                }

                Text(fastingVerse.relevanceNote)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)
            }
            .padding(20)
            .background {
                if themeManager.selectedTheme == .warmInviting {
                    Rectangle()
                        .fill(Color(red: 0.98, green: 0.98, blue: 0.95))
                } else {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.05))
                }
            }

            Divider()
                .background(themeManager.strokeColor)

            // Action button
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
    }
}

#Preview {
    NavigationView {
        FastingCategoryDetailView(
            category: FastingCategory(
                id: "obligation",
                title: "Obligation of Fasting",
                icon: "book.fill",
                description: "The foundational verses establishing fasting as an obligation for believers.",
                verses: [
                    FastingVerse(
                        id: "f1",
                        surahNumber: 2,
                        verseNumber: 183,
                        relevanceNote: "The primary verse prescribing fasting for believers.",
                        isKeyVerse: true
                    )
                ]
            )
        )
    }
}
