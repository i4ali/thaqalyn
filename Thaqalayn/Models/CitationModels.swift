//
//  CitationModels.swift
//  Thaqalayn
//
//  Source citations for the 5-layer tafsir commentary. Produced offline by the
//  tafsir-citer agent (see .claude/agents/tafsir-citer.md) and bundled as
//  Citations/citations_{surah}.json. The commentary text itself is untouched:
//  each citation carries a verbatim `anchor` from the English layer text, and
//  the reader places a superscript where that anchor ends.
//

import Foundation

enum CitationStatus: String, Codable {
    /// The point is in the named source on this verse.
    case verified
    /// The source discusses the point but the paragraph overstates or misnames it.
    case partial
    /// The source was checked on this verse and the point is not there.
    case notFound = "not_found"
    /// No fetchable source text was available to check.
    case unchecked

    /// Readers see only citations the agent could stand behind. Not-found and
    /// unchecked entries stay in the data for the editor pass.
    var isReaderVisible: Bool {
        switch self {
        case .verified, .partial: return true
        case .notFound, .unchecked: return false
        }
    }
}

struct Citation: Codable, Identifiable, Equatable {
    let id: Int
    /// Verbatim clause from the English layer text; the superscript sits at its end.
    let anchor: String
    let claim: String?
    let source: String
    let author: String?
    let locator: String?
    let url: String?
    let status: CitationStatus
    let note: String?

    var linkURL: URL? {
        guard let url, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    /// "al-Mizan · Tabatabai" or just the book when no author is recorded.
    var displayTitle: String {
        if let author, !author.isEmpty { return "\(source) · \(author)" }
        return source
    }
}

struct LayerCitations: Codable {
    let citations: [Citation]
}

struct SurahCitations: Codable {
    let surah: Int
    /// verse number (as string) -> layer key ("layer1"...) -> citations
    let verses: [String: [String: LayerCitations]]

    func citations(verse: Int, layer: TafsirLayer) -> [Citation] {
        verses[String(verse)]?[layer.rawValue]?.citations ?? []
    }
}
