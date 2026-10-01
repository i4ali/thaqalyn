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
    @StateObject private var readingSettings = ReadingSettingsManager.shared
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

            EmCoverBand(assetName: "PropheticStoriesCover")
                .frame(height: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
        .toolbarBackground(.hidden, for: .navigationBar)
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

    @ViewBuilder private var emeraldSections: some View {
        VStack(spacing: 20) {
            // Story header card
            EmCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 7) {
                        Image(systemName: story.categoryIcon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(story.category.displayName)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(themeManager.accentColor)
                    .padding(.horizontal, 13).padding(.vertical, 7)
                    .background(Capsule().fill(themeManager.accentChip))
                    .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(story.prophetEn.uppercased())
                            .emEyebrow(size: 11, tracking: 2)
                            .foregroundColor(themeManager.accentColor)
                        Text(story.titleEn)
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(22)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Quranic narrative intro
            VStack(alignment: .leading, spacing: 8) {
                EmSectionLabel(icon: "book.pages", text: "Quranic Narrative")
                Text("This story is told through \(story.verseCount) verse\(story.verseCount == 1 ? "" : "s"):")
                    .font(EmType.serif(17, .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)

            // Verses with story notes
            ForEach(story.verses, id: \.verseNumber) { storyVerse in
                StoryVerseCard(
                    storyVerse: storyVerse,
                    onNavigate: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            selectedVerseForNav = (storyVerse.surahNumber, storyVerse.verseNumber)
                            navigateToVerse = true
                        }
                    }
                )
            }

            // Lessons summary
            if let lessons = story.lessonsSummaryEn {
                EmDetailCard(icon: "lightbulb", label: "Lessons to Learn") {
                    Text(lessons)
                        .font(EmType.serif(17 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(5 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Related stories
            if !relatedStories.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    EmSectionLabel(icon: "link", text: "Related Stories")
                    ForEach(relatedStories) { relatedStory in
                        RelatedStoryCard(story: relatedStory)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .padding(.top, 4)
    }
}

struct StoryVerseCard: View {
    let storyVerse: StoryVerse
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

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
        EmCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(surahName) · \(storyVerse.surahNumber):\(storyVerse.verseNumber)")
                        .font(.system(size: 12, weight: .bold)).tracking(0.3)
                        .foregroundColor(themeManager.accentColor)
                    if storyVerse.isKeyVerse {
                        Text("KEY VERSE")
                            .font(.system(size: 9, weight: .bold)).tracking(1)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                    Spacer()
                    VerseRecitationButton(surahNumber: storyVerse.surahNumber, verseNumber: storyVerse.verseNumber, size: 32)
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
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(storyVerse.storyNoteEn)
                        .font(.system(size: 13 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
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

struct RelatedStoryCard: View {
    let story: PropheticStory
    @StateObject private var themeManager = ThemeManager.shared
    @State private var navigateToStory = false

    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story), isActive: $navigateToStory) {
            EmCard(cornerRadius: 16) {
                HStack(spacing: 12) {
                    EmIconChip(sfSymbol: story.categoryIcon, size: 38)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(story.prophetEn)
                            .font(.system(size: 11, weight: .bold)).tracking(0.5)
                            .foregroundColor(themeManager.accentColor)
                        Text(story.titleEn)
                            .font(EmType.serif(17, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
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
}

#Preview {
    NavigationView {
        StoryDetailView(
            story: PropheticStory(
                id: "s1",
                titleEn: "Prophet Ibrahim and the Idols",
                titleAr: "النبي إبراهيم والأصنام",
                titleUr: "حضرت ابراہیم اور بت",
                shortTitleEn: "Breaking the Idols",
                shortTitleAr: "تحطيم الأصنام",
                shortTitleUr: "بتوں کو توڑنا",
                prophetEn: "Ibrahim (Abraham)",
                prophetAr: "النبي إبراهيم (ع)",
                prophetUr: "حضرت ابراہیم علیہ السلام",
                category: .courage,
                verses: [
                    StoryVerse(
                        surahNumber: 21,
                        verseNumber: 58,
                        storyNoteEn: "Ibrahim destroys the idols to expose the falsehood of idol worship",
                        storyNoteAr: "يحطّم إبراهيم الأصنام كاشفاً زيف عبادتها",
                        storyNoteUr: "حضرت ابراہیم بتوں کو توڑ کر بت پرستی کا باطل ہونا ظاہر کرتے ہیں",
                        isKeyVerse: true
                    )
                ],
                relatedStories: [],
                lessonsSummaryEn: "True courage means standing up for truth even when facing overwhelming opposition.",
                lessonsSummaryAr: "الشجاعة الحقيقية تعني الوقوف في وجه الباطل حتى حين يكون الخصوم أشداء.",
                lessonsSummaryUr: "حقیقی شجاعت یہ ہے کہ شدید مخالفت کے باوجود حق پر ڈٹے رہا جائے۔"
            )
        )
    }
}
