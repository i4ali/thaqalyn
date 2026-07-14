//
//  BookmarkSpotlightCard.swift
//  Thaqalayn
//
//  Today-screen spotlight for the most recently saved bookmark. Tapping the
//  spotlight jumps straight into the surah at that verse; the footer row opens
//  the full Bookmarks list. Hidden entirely while the user has no bookmarks.
//
//  Verse Arabic + translation scale with the reading text-size control; the
//  reference, surah name, eyebrow and footer are chrome and stay fixed.
//

import SwiftUI

// MARK: - Localization

private enum BookmarkSpotlightStrings {
    static func eyebrow(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "آياتك المحفوظة"; case .urdu: return "محفوظ کردہ آیات"; default: return "Your bookmarks" }
    }
    static func allBookmarks(_ n: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "كل الآيات المحفوظة (\(n))"; case .urdu: return "تمام محفوظ آیات (\(n))"; default: return "All bookmarks (\(n))" }
    }
}

// MARK: - Card

/// Drop into TodayView/EmeraldTodayView. Renders nothing when there are no bookmarks.
struct BookmarkSpotlightCard: View {
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    private var latest: Bookmark? {
        bookmarkManager.bookmarks.max(by: { $0.createdAt < $1.createdAt })
    }

    var body: some View {
        if let bookmark = latest {
            if themeManager.isMidnightEmerald {
                emeraldCard(bookmark)
            } else {
                legacyCard(bookmark)
            }
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

    /// Live translation in the reading language when the verse resolves (so Urdu
    /// readers see Urdu); the snapshot stored on the bookmark otherwise.
    private func translation(for bookmark: Bookmark) -> String {
        liveVerse(for: bookmark)?.displayTranslation(for: lang) ?? bookmark.verseTranslation
    }

    private func arabicText(for bookmark: Bookmark) -> String {
        liveVerse(for: bookmark)?.arabicText ?? bookmark.verseText
    }

    /// Latin curly quotes misbehave around RTL text — Urdu renders unquoted.
    private func translationDisplay(for bookmark: Bookmark) -> String {
        let text = translation(for: bookmark)
        return lang == .urdu ? text : "\u{201C}\(text)\u{201D}"
    }

    // MARK: - Midnight Emerald

    private func emeraldCard(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(BookmarkSpotlightStrings.eyebrow(lang).uppercased())
                .emEyebrow(lang, size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
                .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)

            EmCard {
                VStack(spacing: 0) {
                    spotlightLink(bookmark) {
                        emeraldSpotlight(bookmark)
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

    private func emeraldSpotlight(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.verseReference)
                        .font(EmType.serif(24, .semiBold))
                        .foregroundColor(themeManager.accentBright)
                    Text(bookmark.surahName)
                        .font(EmType.serif(15, .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer()

                Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.onAccentText)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(themeManager.accentGradient)
                    )
            }

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
                .multilineTextAlignment(lang == .urdu ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: lang == .urdu ? .trailing : .leading)
                .environment(\.layoutDirection, lang == .urdu ? .rightToLeft : .leftToRight)
        }
        .padding(17)
        .contentShape(Rectangle())
    }

    // MARK: - Legacy (Warm & Inviting)

    private func legacyCard(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BookmarkSpotlightStrings.eyebrow(lang).uppercased())
                .emEyebrow(lang, size: 13, tracking: 0.4)
                .foregroundColor(themeManager.secondaryText)
                .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

            VStack(spacing: 0) {
                spotlightLink(bookmark) {
                    legacySpotlight(bookmark)
                }

                Rectangle()
                    .fill(themeManager.strokeColor)
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                PressableNavLink {
                    BookmarksView()
                } label: {
                    footerRow(color: themeManager.accentColor)
                }
            }
            .background(legacyBackground)
        }
    }

    private func legacySpotlight(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.surahName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                    Text(bookmark.verseReference)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer()

                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.pink)
            }

            Text(arabicText(for: bookmark))
                .font(.custom("Amiri", size: 19 * readingSettings.scale))
                .lineSpacing(5 * readingSettings.scale)
                .foregroundColor(themeManager.primaryText)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)

            Text(translationDisplay(for: bookmark))
                .font(.system(size: 14 * readingSettings.scale))
                .lineSpacing(2 * readingSettings.scale)
                .foregroundColor(themeManager.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(lang == .urdu ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: lang == .urdu ? .trailing : .leading)
                .environment(\.layoutDirection, lang == .urdu ? .rightToLeft : .leftToRight)
        }
        .padding(16)
        .contentShape(Rectangle())
    }

    private var legacyBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(themeManager.strokeColor, lineWidth: 1))
            .shadow(
                color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.05),
                radius: 7, x: 0, y: 4
            )
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
            Text(BookmarkSpotlightStrings.allBookmarks(bookmarkManager.bookmarks.count, lang))
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
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}

#if DEBUG
#Preview("BookmarkSpotlightCard") {
    NavigationView {
        ScrollView {
            BookmarkSpotlightCard()
                .padding(.horizontal, 20)
        }
        .background(Color(hex: "0A1512"))
    }
}
#endif
