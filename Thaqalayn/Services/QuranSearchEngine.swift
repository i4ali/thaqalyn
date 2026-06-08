//
//  QuranSearchEngine.swift
//  Thaqalayn
//
//  Pure, UI-free search over surahs, verse translations (English), and
//  Quick Overview concept "themes". Operates on a flat, pre-lowercased index
//  built once from DataManager.availableSurahs.
//

import Foundation

// MARK: - Index

struct QuranSearchIndex {
    struct SurahEntry {
        let surah: SurahWithTafsir
        let nameLower: String
        let translationLower: String
        let arabicName: String
    }
    struct VerseEntry {
        let surahNumber: Int
        let verseNumber: Int
        let surahEnglishName: String
        let translation: String
        let translationLower: String
    }
    struct ThemeEntry {
        let conceptId: String
        let title: String
        let titleLower: String
        let colorHex: String
        let surahNumber: Int
        let verseNumber: Int
        let surahEnglishName: String
    }

    let surahEntries: [SurahEntry]
    let verseEntries: [VerseEntry]
    let themeEntries: [ThemeEntry]

    /// Direct init (used by previews / self-checks).
    init(surahEntries: [SurahEntry], verseEntries: [VerseEntry], themeEntries: [ThemeEntry]) {
        self.surahEntries = surahEntries
        self.verseEntries = verseEntries
        self.themeEntries = themeEntries
    }

    /// Build the flat index from loaded surahs. Verse order is canonical
    /// (surah, then verse) because availableSurahs is already sorted.
    init(surahs: [SurahWithTafsir]) {
        var surahE: [SurahEntry] = []
        var verseE: [VerseEntry] = []
        var themeE: [ThemeEntry] = []
        for swt in surahs {
            let s = swt.surah
            surahE.append(SurahEntry(
                surah: swt,
                nameLower: s.englishName.lowercased(),
                translationLower: s.englishNameTranslation.lowercased(),
                arabicName: s.arabicName
            ))
            for v in swt.verses {
                verseE.append(VerseEntry(
                    surahNumber: s.number,
                    verseNumber: v.number,
                    surahEnglishName: s.englishName,
                    translation: v.translation,
                    translationLower: v.translation.lowercased()
                ))
                if let concepts = v.tafsir?.quickOverview?.concepts {
                    for c in concepts {
                        themeE.append(ThemeEntry(
                            conceptId: c.id,
                            title: c.title,
                            titleLower: c.title.lowercased(),
                            colorHex: c.colorHex,
                            surahNumber: s.number,
                            verseNumber: v.number,
                            surahEnglishName: s.englishName
                        ))
                    }
                }
            }
        }
        self.init(surahEntries: surahE, verseEntries: verseE, themeEntries: themeE)
    }
}

// MARK: - Results

struct SurahHit: Identifiable {
    let surah: SurahWithTafsir
    var id: Int { surah.surah.number }
}

struct VerseHit: Identifiable {
    let surahNumber: Int
    let verseNumber: Int
    let surahEnglishName: String
    let snippet: String
    let matchRange: NSRange?
    var id: String { "\(surahNumber):\(verseNumber)" }
}

struct ThemeHit: Identifiable {
    let conceptId: String
    let title: String
    let colorHex: String
    let surahNumber: Int
    let verseNumber: Int
    let surahEnglishName: String
    var id: String { conceptId }
}

struct QuranSearchResults {
    var surahs: [SurahHit] = []
    var verses: [VerseHit] = []
    var themes: [ThemeHit] = []
    var verseTotal: Int = 0      // pre-cap count, for "showing first N of M"
    var themeTotal: Int = 0
    var isEmpty: Bool { surahs.isEmpty && verses.isEmpty && themes.isEmpty }
}

// MARK: - Engine

enum QuranSearchEngine {
    static let minTextQueryLength = 2
    static let verseLimit = 25
    static let themeLimit = 40

    static func search(_ rawQuery: String, in index: QuranSearchIndex) -> QuranSearchResults {
        let trimmed = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return QuranSearchResults() }
        let q = trimmed.lowercased()

        var results = QuranSearchResults()

        // Surahs — match from 1 char (name / English meaning / Arabic name).
        results.surahs = index.surahEntries
            .filter { $0.nameLower.contains(q) || $0.translationLower.contains(q) || $0.arabicName.contains(trimmed) }
            .map { SurahHit(surah: $0.surah) }

        // Verses + themes only kick in at >= 2 chars to avoid noise.
        guard q.count >= minTextQueryLength else { return results }

        // Verses — canonical order, capped.
        let verseMatches = index.verseEntries.filter { $0.translationLower.contains(q) }
        results.verseTotal = verseMatches.count
        results.verses = verseMatches.prefix(verseLimit).map { entry in
            let (snippet, range) = Self.snippet(from: entry.translation, query: trimmed)
            return VerseHit(
                surahNumber: entry.surahNumber,
                verseNumber: entry.verseNumber,
                surahEnglishName: entry.surahEnglishName,
                snippet: snippet,
                matchRange: range
            )
        }

        // Themes — rank exact title, then prefix, then contains; canonical tiebreak.
        let themeMatches = index.themeEntries.filter { $0.titleLower.contains(q) }
        results.themeTotal = themeMatches.count
        let ranked = themeMatches.sorted { a, b in
            func rank(_ t: QuranSearchIndex.ThemeEntry) -> Int {
                if t.titleLower == q { return 0 }
                if t.titleLower.hasPrefix(q) { return 1 }
                return 2
            }
            let ra = rank(a), rb = rank(b)
            if ra != rb { return ra < rb }
            if a.surahNumber != b.surahNumber { return a.surahNumber < b.surahNumber }
            return a.verseNumber < b.verseNumber
        }
        results.themes = ranked.prefix(themeLimit).map { entry in
            ThemeHit(
                conceptId: entry.conceptId,
                title: entry.title,
                colorHex: entry.colorHex,
                surahNumber: entry.surahNumber,
                verseNumber: entry.verseNumber,
                surahEnglishName: entry.surahEnglishName
            )
        }

        return results
    }

    /// Windowed snippet around the first case-insensitive match, with the match's
    /// NSRange *within the returned snippet* (for HighlightedText). Adds ellipses
    /// when the window is clipped.
    static func snippet(from text: String, query: String, before: Int = 40, after: Int = 60) -> (String, NSRange?) {
        let ns = text as NSString
        let match = ns.range(of: query, options: .caseInsensitive)
        guard match.location != NSNotFound else { return (text, nil) }

        let start = max(0, match.location - before)
        let end = min(ns.length, match.location + match.length + after)
        let core = ns.substring(with: NSRange(location: start, length: end - start))

        let prefix = start > 0 ? "\u{2026}" : ""
        let suffix = end < ns.length ? "\u{2026}" : ""
        var matchInSnippet = NSRange(location: match.location - start + (prefix as NSString).length,
                                     length: match.length)
        let snippet = prefix + core + suffix
        // Clamp defensively.
        if matchInSnippet.location + matchInSnippet.length > (snippet as NSString).length {
            return (snippet, nil)
        }
        return (snippet, matchInSnippet)
    }
}

#if DEBUG
import SwiftUI

extension QuranSearchEngine {
    /// Tiny hand-built index to eyeball engine behavior in the Xcode canvas (Task 1 gate).
    static func _previewResults() -> QuranSearchResults {
        let idx = QuranSearchIndex(
            surahEntries: [],
            verseEntries: [
                .init(surahNumber: 24, verseNumber: 35, surahEnglishName: "An-Noor",
                      translation: "Allah is the Light of the heavens and the earth.",
                      translationLower: "allah is the light of the heavens and the earth.")
            ],
            themeEntries: [
                .init(conceptId: "24:35:divine-light", title: "Divine Light", titleLower: "divine light",
                      colorHex: "#E8B86D", surahNumber: 24, verseNumber: 35, surahEnglishName: "An-Noor")
            ]
        )
        return QuranSearchEngine.search("light", in: idx)
    }
}

#Preview("Engine self-check") {
    let r = QuranSearchEngine._previewResults()
    return VStack(alignment: .leading, spacing: 6) {
        Text("verses: \(r.verses.count)  themes: \(r.themes.count)")
        Text("snippet: \(r.verses.first?.snippet ?? "—")")
        Text("matchRange set: \(r.verses.first?.matchRange != nil ? "yes" : "no")")
    }
    .padding()
}
#endif
