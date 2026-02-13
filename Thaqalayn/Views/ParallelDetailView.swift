//
//  ParallelDetailView.swift
//  Thaqalayn
//
//  Detailed view showing prophetic parallel with comfort message, story, and verses
//  "You aren't alone; the best of humans went through this too."
//

import SwiftUI

struct ParallelDetailView: View {
    let parallel: PropheticParallel
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var parallelsManager = PropheticParallelsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false
    @State private var navigateToStory = false

    var relatedStory: PropheticStory? {
        parallelsManager.relatedStory(for: parallel)
    }

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Header with situation and prophet
                    headerSection

                    // Comfort message box
                    comfortMessageSection

                    // Key verses
                    versesSection

                    // Related story link (if exists)
                    if relatedStory != nil {
                        relatedStorySection
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

            // Hidden NavigationLink for story navigation
            if let story = relatedStory {
                NavigationLink(
                    destination: StoryDetailView(story: story),
                    isActive: $navigateToStory
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
                        Text("Parallels")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Category badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: parallel.category.icon)
                        .font(.system(size: 14, weight: .semibold))

                    Text(parallel.category.displayName)
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

            // Situation text
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: parallel.icon)
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.accentColor)

                    Text("YOUR SITUATION")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                        .tracking(1.2)
                }

                Text(parallel.situation)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)

                Divider()
                    .background(themeManager.strokeColor)
                    .padding(.vertical, 4)

                // Prophet connection
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.accentColor)

                    Text("PROPHET")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                        .tracking(1.2)
                }

                Text(parallel.prophet)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.accentColor)

                Text(parallel.connection)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)
            }
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

    // MARK: - Comfort Message Section

    private var comfortMessageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Text("A MESSAGE FOR YOU")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1.2)
            }

            Text(parallel.comfortMessage)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .lineSpacing(6)
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.purpleGradient)
                .shadow(color: themeManager.accentColor.opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Verses Section

    private var versesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.accentColor)

                Text("KEY VERSES")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.secondaryText)
                    .tracking(1.2)
            }
            .padding(.horizontal, 20)

            ForEach(Array(parallel.verses.enumerated()), id: \.element.verseNumber) { index, verse in
                ParallelVerseCard(
                    verse: verse,
                    index: index + 1,
                    totalVerses: parallel.verses.count,
                    onNavigate: {
                        selectedVerseForNav = (verse.surahNumber, verse.verseNumber)
                        navigateToVerse = true
                    }
                )
            }
        }
    }

    // MARK: - Related Story Section

    private var relatedStorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.accentColor)

                Text("FULL STORY")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.secondaryText)
                    .tracking(1.2)
            }

            if let story = relatedStory {
                Button(action: { navigateToStory = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: story.categoryIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(themeManager.accentColor.opacity(0.15))
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.prophet)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(themeManager.accentColor)

                            Text(story.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)

                            Text("\(story.verseCount) verses • Full Quranic account")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }

                        Spacer()

                        Text("Read Full Story")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(themeManager.accentGradient)
                            }
                    }
                    .padding(16)
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
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Parallel Verse Card

struct ParallelVerseCard: View {
    let verse: ParallelVerse
    let index: Int
    let totalVerses: Int
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(verse.surahNumber)"],
              let verseContent = verses["\(verse.verseNumber)"] else {
            return nil
        }
        return (verseContent.arabicText, verseContent.translation)
    }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == verse.surahNumber }?.englishName ?? "Surah \(verse.surahNumber)"
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

                    Text("\(surahName) (\(verse.surahNumber):\(verse.verseNumber))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()
            }
            .padding(20)

            Divider()
                .background(themeManager.strokeColor)

            // Verse text
            if let verseContent = verseData {
                VStack(alignment: .leading, spacing: 16) {
                    // Arabic text
                    Text(verseContent.arabic)
                        .font(.custom("AmiriQuran-Regular", size: 24))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Translation
                    Text(verseContent.translation)
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
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)

                    Text("Why This Verse Matters")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                }

                Text(verse.relevanceNote)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        ParallelDetailView(
            parallel: PropheticParallel(
                id: "p1",
                situation: "I feel trapped with no way out",
                category: .emotionalStruggles,
                prophet: "Yunus (Jonah)",
                connection: "Yunus was swallowed by a whale in complete darkness",
                comfortMessage: "Even in the darkest depths, Allah heard Yunus's prayer.",
                storySummary: "Prophet Yunus left his people in frustration and was swallowed by a whale.",
                verses: [
                    ParallelVerse(surahNumber: 21, verseNumber: 87, relevanceNote: "Yunus's powerful prayer")
                ],
                relatedStoryId: "s11",
                icon: "water.waves"
            )
        )
    }
}
