//
//  QuranTabStrings.swift
//  Thaqalayn
//
//  Copy for the Quran (Home) tab - surah-list chrome, search,
//  continue-reading card, search-results sections.
//
//  Surah NAMES and MEANINGS stay English by product decision: the Surah model has
//  no localized name data, and the Arabic surah name is already shown beside the
//  English one.
//

import Foundation

enum QuranTabStrings {
    static let greeting = "Assalamu alaykum"
    /// Emerald header eyebrow.
    static let nobleQuranEyebrow = "The Noble Qur'an"
    /// Emerald header title.
    static let readAndReflect = "Read & Reflect"
    /// Legacy (Light / Night Sanctuary) header title.
    static let holyQuran = "The Holy Quran"
    static let continueReading = "Continue Reading"
    static let resume = "Resume"
    static let searchPlaceholder = "Search surahs, verses, themes…"
    static func surahsCount(_ n: Int) -> String { "\(n) Surahs" }
    static func versesCount(_ n: Int) -> String { "\(n) verses" }
    /// Surah-row passage count: "40 passages" / "1 passage".
    static func passagesCount(_ n: Int) -> String { n == 1 ? "1 passage" : "\(n) passages" }
    /// Surah-row passage progress: "3 of 40 passages" / "1 of 1 passage".
    static func passagesRead(_ read: Int, of total: Int) -> String {
        total == 1 ? "\(read) of 1 passage" : "\(read) of \(total) passages"
    }
    /// The data's "Meccan"/"Medinan" revelationType, shown as-is.
    static func revelation(_ raw: String) -> String { raw }
    static func verseOf(_ n: Int, _ total: Int) -> String { "Verse \(n) of \(total)" }
    static func percentComplete(_ p: Int) -> String { "\(p)% complete" }
    static func passagesRead(_ read: Int, _ total: Int) -> String { "\(read) of \(total) passages read" }

    // MARK: - Search field
    static let cancel = "Cancel"
    static let clearSearch = "Clear search"

    // MARK: - Search results
    static let surahsLabel = "Surahs"
    static let versesLabel = "Verses"
    static let passagesLabel = "Passages"
    static let themesLabel = "Themes"
    /// Top-hit eyebrow for a typed reference ("2:255").
    static let goToVerse = "Go to verse"
    static func showAll(_ total: Int) -> String { "Show all \(total)" }
    /// Theme row covering several verses.
    static func themeVerses(_ n: Int) -> String { "\(n) verses" }
    static let preparingSearch = "Preparing search\u{2026}"
    static func noResults(_ query: String) -> String {
        "No results for \u{201C}\(query)\u{201D}"
    }
    static let searchHint = "Try a surah name, a reference like 2:255, or a word from the translation."

    // MARK: - Find in this surah
    static let findInSurah = "Find in this Surah"
    static func findInSurahSubtitle(_ versesCount: Int) -> String {
        "A verse number (1 to \(versesCount)) or a word"
    }
    static let findPlaceholder = "Verse number or a word"
    static func goToVerseNumber(_ n: Int) -> String { "Go to verse \(n)" }
    static func verseOutOfRange(_ versesCount: Int) -> String {
        "This surah has \(versesCount) verses"
    }
    static func noMatchesInSurah(_ query: String) -> String {
        "No verses in this surah contain \u{201C}\(query)\u{201D}"
    }
}
