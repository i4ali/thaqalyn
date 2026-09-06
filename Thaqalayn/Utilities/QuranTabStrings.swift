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

    // MARK: - Search results
    static let surahsLabel = "Surahs"
    static let versesLabel = "Verses"
    static let themesLabel = "Themes"
    static func showingFirst(_ showing: Int, _ total: Int) -> String {
        "Showing first \(showing) of \(total)"
    }
    static func noResults(_ query: String) -> String {
        "No results for \u{201C}\(query)\u{201D}"
    }
}
