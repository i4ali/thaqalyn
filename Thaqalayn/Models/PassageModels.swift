// Thaqalayn/Models/PassageModels.swift
//
//  Passage commentary models: one commentary per ruku, produced by
//  scripts/passages.py and shipped as Data/passages_<surah>.json keyed by the
//  passage index within the surah. See docs/plans/2026-09-05-passage-commentary-design.md.
//

import Foundation

// `LocalizedText` (en + optional ur/ar) is defined once in DailyChallengeModels.swift
// and reused here - no duplicate type. Passage text fields need language-aware
// resolution for the tafsir reader's EN/UR/AR toggle, so these live here.
extension LocalizedText {
    func text(for language: CommentaryLanguage) -> String {
        switch language {
        case .english: return en
        case .urdu: return ur ?? en
        case .arabic: return ar ?? en
        }
    }

    var availableLanguages: [CommentaryLanguage] {
        var langs: [CommentaryLanguage] = [.english]
        if ur != nil { langs.append(.urdu) }
        if ar != nil { langs.append(.arabic) }
        return langs
    }
}

struct Passage: Codable, Identifiable, Hashable {
    let id: String
    let surah: Int
    let index: Int
    let range: [Int]
    let title: LocalizedText
    let essay: LocalizedText
    let verses: [PassageVerseEntry]
    let perspectives: LocalizedText?
    let sources: [PassageSource]
    let status: PassageStatus?

    var start: Int { range[0] }
    var end: Int { range[1] }
    var verseCount: Int { end - start + 1 }
    var narrationCount: Int { verses.reduce(0) { $0 + $1.narrations.count } }

    func source(id: String) -> PassageSource? { sources.first { $0.id == id } }
    func entry(forVerse verse: Int) -> PassageVerseEntry? { verses.first { $0.verse == verse } }

    /// Whole minutes to read the understanding screen at 200 words a minute, at least 1.
    var readingMinutes: Int {
        var words = essay.en.split(separator: " ").count
        for v in verses {
            words += (v.note?.en ?? "").split(separator: " ").count
            words += v.narrations.reduce(0) { $0 + $1.text.en.split(separator: " ").count }
        }
        words += (perspectives?.en ?? "").split(separator: " ").count
        return max(1, words / 200 + 1)
    }
}

struct PassageVerseEntry: Codable, Identifiable, Hashable {
    let verse: Int
    let heading: LocalizedText?
    let note: LocalizedText?
    let narrations: [Narration]
    var id: Int { verse }

    enum CodingKeys: String, CodingKey { case verse, heading, note, narrations }

    /// A note-only entry may omit `narrations` entirely; treat that as empty
    /// rather than failing the whole surah file.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        verse = try c.decode(Int.self, forKey: .verse)
        heading = try c.decodeIfPresent(LocalizedText.self, forKey: .heading)
        note = try c.decodeIfPresent(LocalizedText.self, forKey: .note)
        narrations = try c.decodeIfPresent([Narration].self, forKey: .narrations) ?? []
    }
}

struct Narration: Codable, Identifiable, Hashable {
    let id: String
    let speaker: String
    let addressee: String?
    let arabic: String
    let chain: String?
    let text: LocalizedText
    let source: String
}

struct SourceExcerpt: Codable, Hashable {
    let lang: String
    let text: String
}

struct PassageSource: Codable, Identifiable, Hashable {
    let id: String
    let kind: String
    let work: String
    let author: String
    let tradition: String
    let tier: String
    let locus: String
    let url: String
    let excerpt: SourceExcerpt?
    let gloss: String?
    let grades: [String]?

    /// Marker number, so "s12" renders as [12].
    var number: Int { Int(id.dropFirst()) ?? 0 }
}

struct PassageStatus: Codable, Hashable {
    let gatheredAt: String?
    let auditAttempts: Int?
    let auditedAt: String?
    let assembledAt: String?

    enum CodingKeys: String, CodingKey {
        case gatheredAt = "gathered_at"
        case auditAttempts = "audit_attempts"
        case auditedAt = "audited_at"
        case assembledAt = "assembled_at"
    }
}
