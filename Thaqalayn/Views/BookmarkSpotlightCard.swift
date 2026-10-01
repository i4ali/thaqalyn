//
//  BookmarkSpotlightCard.swift
//  Thaqalayn
//
//  Today-screen spotlight for the most recently saved bookmark, a verse or a
//  whole passage. Tapping the spotlight jumps straight into the passage holding
//  that verse (or the saved passage itself); the footer row opens the full
//  Bookmarks list. Hidden entirely while the user has no bookmarks.
//
//  Verse Arabic + translation scale with the reading text-size control; the
//  reference, surah name, passage title, eyebrow and footer are chrome and
//  stay fixed.
//

import SwiftUI

// MARK: - Localization

private enum BookmarkSpotlightStrings {
    static let eyebrow = "Your bookmarks"
    static func allBookmarks(_ n: Int) -> String { "All bookmarks (\(n))" }
}

// MARK: - Card

/// Drop into EmeraldTodayView. Renders nothing when there are no bookmarks.
struct BookmarkSpotlightCard: View {
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared


    private var latest: Bookmark? {
        bookmarkManager.bookmarks.max(by: { $0.createdAt < $1.createdAt })
    }

    var body: some View {
        if let bookmark = latest {
            card(bookmark)
        }
    }

    // MARK: - Verse resolution

    /// Mirrors BookmarksListView.createSurahWithTafsir: prefer the tafsir-backed
    /// surah, fall back to bare quran data so navigation still works.
    private func surahWithTafsir(for bookmark: Bookmark) -> SurahWithTafsir? {
        if let surahWithTafsir = dataManager.availableSurahs.first(where: { $0.surah.number == bookmark.surahNumber }) {
            return surahWithTafsir
        }

        guard let quranData = dataManager.quranData,
              let surah = quranData.surahs.first(where: { $0.number == bookmark.surahNumber }),
              let surahVerses = quranData.verses[String(bookmark.surahNumber)] else {
            return nil
        }

        var verses: [VerseWithTafsir] = []
        for i in 1...surah.versesCount {
            if let verse = surahVerses[String(i)] {
                verses.append(VerseWithTafsir(number: i, verse: verse, tafsir: nil))
            }
        }
        return SurahWithTafsir(surah: surah, verses: verses)
    }

    private func liveVerse(for bookmark: Bookmark) -> VerseWithTafsir? {
        surahWithTafsir(for: bookmark)?.verses.first(where: { $0.number == bookmark.verseNumber })
    }

    /// Live translation when the verse resolves; the snapshot stored on the
    /// bookmark otherwise.
    private func translation(for bookmark: Bookmark) -> String {
        liveVerse(for: bookmark)?.translation ?? bookmark.verseTranslation
    }

    private func arabicText(for bookmark: Bookmark) -> String {
        liveVerse(for: bookmark)?.arabicText ?? bookmark.verseText
    }

    private func translationDisplay(for bookmark: Bookmark) -> String {
        "\u{201C}\(translation(for: bookmark))\u{201D}"
    }

    // MARK: - Card body

    private func card(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(BookmarkSpotlightStrings.eyebrow.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            EmCard {
                VStack(spacing: 0) {
                    spotlightLink(bookmark) {
                        spotlight(bookmark)
                    }

                    EmDivider()
                        .padding(.horizontal, 17)

                    PressableNavLink {
                        BookmarksView()
                    } label: {
                        footerRow(color: themeManager.accentColor)
                    }
                }
            }
        }
    }

    private func spotlight(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.referenceLabel)
                        .font(EmType.serif(24, .semiBold))
                        .foregroundColor(themeManager.accentBright)
                    Text(bookmark.surahName)
                        .font(EmType.serif(15, .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer()

                BookmarkKindBadge(isPassage: bookmark.isPassage)
            }

            if bookmark.isPassage {
                Text(bookmark.passageTitle)
                    .font(EmType.serif(18, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let meta = bookmark.passageMetaLabel {
                    Text(meta)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
            } else {
                Text(arabicText(for: bookmark))
                    .font(EmType.arabic(21 * readingSettings.scale))
                    .lineSpacing(6 * readingSettings.scale)
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, .rightToLeft)

                Text(translationDisplay(for: bookmark))
                    .font(EmType.serif(16 * readingSettings.scale, .medium))
                    .lineSpacing(3 * readingSettings.scale)
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(17)
        .contentShape(Rectangle())
    }

    // MARK: - Shared pieces

    /// Spotlight body wrapped in navigation to the verse when it resolves;
    /// rendered bare (non-tappable) when the surah data is unavailable.
    @ViewBuilder
    private func spotlightLink<Content: View>(_ bookmark: Bookmark, @ViewBuilder content: () -> Content) -> some View {
        if let surah = surahWithTafsir(for: bookmark) {
            PressableNavLink {
                SurahDetailView(surahWithTafsir: surah, targetVerse: bookmark.verseNumber)
            } label: {
                content()
            }
        } else {
            content()
        }
    }

    private func footerRow(color: Color) -> some View {
        HStack {
            Text(BookmarkSpotlightStrings.allBookmarks(bookmarkManager.bookmarks.count))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview("BookmarkSpotlightCard") {
    NavigationView {
        ScrollView {
            BookmarkSpotlightCard()
                .padding(.horizontal, 20)
        }
        .background(ThemeManager.shared.primaryBackground)
    }
}
#endif
