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
    @StateObject private var readingSettings = ReadingSettingsManager.shared
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

            EmCoverBand(assetName: "PropheticParallelsCover")
                .frame(height: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            emeraldScroll

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
        .toolbarBackground(.hidden, for: .navigationBar)
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

    // MARK: - Emerald

    private var emeraldScroll: some View {
        ScrollView {
            VStack(spacing: 20) {
                emeraldHeaderSection
                if let narration = parallel.narration {
                    AhlulBaytNarrationCard(narration: narration)
                }
                emeraldVersesSection
                if relatedStory != nil {
                    emeraldRelatedStorySection
                }
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
    }

    private var emeraldHeaderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Category eyebrow
            HStack(spacing: 8) {
                Image(systemName: parallel.category.icon)
                    .font(.system(size: 13))
                Text(parallel.category.displayName.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(2)
            }
            .foregroundColor(themeManager.accentColor)

            // Your situation
            VStack(alignment: .leading, spacing: 6) {
                EmSectionLabel(icon: parallel.icon, text: "Your Situation")
                Text(parallel.situationEn)
                    .font(EmType.serif(28, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Rectangle()
                .fill(themeManager.dividerColor)
                .frame(height: 1)
                .padding(.vertical, 2)

            // Prophet connection
            VStack(alignment: .leading, spacing: 6) {
                EmSectionLabel(icon: "person.fill", text: "Prophet")
                Text(parallel.prophetEn)
                    .font(EmType.serif(24, .semiBold))
                    .foregroundColor(themeManager.accentBright)
                    .fixedSize(horizontal: false, vertical: true)
                Text(parallel.connectionEn)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            EmCard { Color.clear }
        )
        .padding(.horizontal, 20)
    }

    private var emeraldVersesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            EmSectionLabel(icon: "book.pages", text: "Key Verses")
                .padding(.horizontal, 20)

            ForEach(parallel.verses, id: \.verseNumber) { verse in
                ParallelVerseCard(
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
    }

    private var emeraldRelatedStorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let story = relatedStory {
                EmDetailCard(icon: "link", label: "Full Story") {
                    Button(action: { DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { navigateToStory = true } }) {
                        HStack(spacing: 12) {
                            EmIconChip(sfSymbol: story.categoryIcon, size: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(story.prophetEn)
                                    .font(.system(size: 11, weight: .bold)).tracking(0.5)
                                    .foregroundColor(themeManager.accentColor)
                                Text(story.titleEn)
                                    .font(EmType.serif(18, .semiBold))
                                    .foregroundColor(themeManager.primaryText)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("\(story.verseCount) verses · Full Quranic account")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(themeManager.tertiaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.tertiaryText)
                        }
                    }
                    .buttonStyle(EmPressStyle())
                }
            }
        }
    }
}

// MARK: - Parallel Verse Card

struct ParallelVerseCard: View {
    let verse: ParallelVerse
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

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
                            Text("Full Tafsir").font(.system(size: 12, weight: .semibold))
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
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(verse.relevanceNoteEn)
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

#Preview {
    NavigationView {
        ParallelDetailView(
            parallel: PropheticParallel(
                id: "p1",
                situationEn: "I feel trapped with no way out",
                situationAr: "أشعر بأنني محاصَر بلا مخرج",
                situationUr: "میں پھنسا ہوا محسوس کرتا ہوں، کوئی راستہ نہیں",
                category: .emotionalStruggles,
                prophetEn: "Yunus (Jonah)",
                prophetAr: "النبي يونس (ع)",
                prophetUr: "حضرت یونس علیہ السلام",
                connectionEn: "Yunus was swallowed by a whale in complete darkness",
                connectionAr: "ابتلع الحوتُ يونسَ في ظلمات تامة",
                connectionUr: "حضرت یونس کو مکمل اندھیرے میں مچھلی نے نگل لیا",
                comfortMessageEn: "Even in the darkest depths, Allah heard Yunus's prayer.",
                comfortMessageAr: "حتى في أحلك الأعماق، سمع اللهُ دعاء يونس.",
                comfortMessageUr: "گہرے ترین اندھیروں میں بھی اللہ نے یونس کی دعا سنی۔",
                storySummaryEn: "Prophet Yunus left his people in frustration and was swallowed by a whale.",
                storySummaryAr: "غادر النبيُّ يونس قومه غاضبًا فالتقمه الحوت.",
                storySummaryUr: "حضرت یونس اپنی قوم کو چھوڑ کر چلے گئے اور مچھلی نے انہیں نگل لیا۔",
                verses: [
                    ParallelVerse(surahNumber: 21, verseNumber: 87,
                                  relevanceNoteEn: "Yunus's powerful prayer",
                                  relevanceNoteAr: "دعاء يونس العظيم",
                                  relevanceNoteUr: "حضرت یونس کی پُرتاثیر دعا")
                ],
                relatedStoryId: "s11",
                icon: "water.waves",
                narration: AhlulBaytNarration(
                    arabic: "فَنَادَىٰ فِي الظُّلُمَاتِ: لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ، فَاسْتَجَابَ اللَّهُ لَهُ.",
                    translationEn: "He called out in the depths of darkness: ‘There is no god but You; glory be to You; truly I was among the wrongdoers.’ So God answered him.",
                    translationUr: "اُنہوں نے تاریکیوں میں پکارا: «تیرے سوا کوئی معبود نہیں، تو پاک ہے، بیشک میں ظالموں میں سے تھا»، پس اللہ نے اُن کی پکار قبول فرمائی۔",
                    sourceEn: "Imam al-Rida (a) — Uyun Akhbar al-Rida, vol. 1, p. 170",
                    sourceAr: "الإمام الرضا (ع) — عيون أخبار الرضا، ج١ ص١٧٠",
                    sourceUr: "امام علی رضا علیہ السلام — عیون اخبار الرضا، ج۱، ص۱۷۰"
                )
            )
        )
    }
}
