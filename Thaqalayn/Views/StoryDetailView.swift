//
//  StoryDetailView.swift
//  Thaqalayn
//
//  Detailed view showing prophetic story with verses and lessons
//

import SwiftUI

struct StoryDetailView: View {
    let story: PropheticStory
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var storiesManager = PropheticStoriesManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var relatedStories: [PropheticStory] {
        story.relatedStories.compactMap { id in
            storiesManager.story(byId: id)
        }
    }

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Story header
                    VStack(spacing: 16) {
                        // Category badge
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: story.categoryIcon)
                                    .font(.system(size: 14, weight: .semibold))

                                Text(story.category.displayName)
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

                        // Prophet name and story title
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(themeManager.accentColor)

                                Text("PROPHET")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            Text(story.prophet)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.accentColor)

                            Divider()
                                .background(themeManager.strokeColor)
                                .padding(.vertical, 4)

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(themeManager.accentColor)

                                Text("THE STORY")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            Text(story.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
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

                    // Story verses header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text("QURANIC NARRATIVE")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)
                        }

                        Text("This story is told through \(story.verseCount) verse\(story.verseCount == 1 ? "" : "s"):")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Verses with story notes
                    ForEach(Array(story.verses.enumerated()), id: \.element.verseNumber) { index, storyVerse in
                        StoryVerseCard(
                            storyVerse: storyVerse,
                            index: index + 1,
                            totalVerses: story.verseCount,
                            onNavigate: {
                                selectedVerseForNav = (storyVerse.surahNumber, storyVerse.verseNumber)
                                navigateToVerse = true
                            }
                        )
                    }

                    // Lessons summary
                    if let lessons = story.lessonsSummary {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.accentColor)

                                Text("LESSONS TO LEARN")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            Text(lessons)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                                .lineSpacing(6)
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
                    }

                    // Related stories
                    if !relatedStories.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "link.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.accentColor)

                                Text("RELATED STORIES")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            ForEach(relatedStories) { relatedStory in
                                RelatedStoryCard(story: relatedStory)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Stories")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct StoryVerseCard: View {
    let storyVerse: StoryVerse
    let index: Int
    let totalVerses: Int
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(storyVerse.surahNumber)"],
              let verse = verses["\(storyVerse.verseNumber)"] else {
            return nil
        }
        return (verse.arabicText, verse.translation)
    }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == storyVerse.surahNumber }?.englishName ?? "Surah \(storyVerse.surahNumber)"
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

                    Text("\(surahName) (\(storyVerse.surahNumber):\(storyVerse.verseNumber))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()

                if storyVerse.isKeyVerse {
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

            // Story note
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)

                    Text("Story Context")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                }

                Text(storyVerse.storyNote)
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

struct RelatedStoryCard: View {
    let story: PropheticStory
    @StateObject private var themeManager = ThemeManager.shared
    @State private var navigateToStory = false

    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story), isActive: $navigateToStory) {
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
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
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

#Preview {
    NavigationView {
        StoryDetailView(
            story: PropheticStory(
                id: "s1",
                title: "Prophet Ibrahim and the Idols",
                shortTitle: "Breaking the Idols",
                prophet: "Ibrahim (Abraham)",
                category: .courage,
                verses: [
                    StoryVerse(
                        surahNumber: 21,
                        verseNumber: 58,
                        storyNote: "Ibrahim destroys the idols to expose the falsehood of idol worship",
                        isKeyVerse: true
                    )
                ],
                relatedStories: [],
                lessonsSummary: "True courage means standing up for truth even when facing overwhelming opposition."
            )
        )
    }
}
