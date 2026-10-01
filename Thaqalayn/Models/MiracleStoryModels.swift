//
//  MiracleStoryModels.swift
//  Thaqalayn
//
//  "Miracle Stories": the sixteen miracles of the Urdu book 14 Mojzay
//  (A. H. Rizvi), retold in our own words in English and Urdu by
//  scripts/mojzay.py and shipped as Data/miracle_stories.json.
//

import Foundation

struct MiracleStoriesData: Decodable {
    /// English framing note shown at the top of the list.
    let note: String
    let stories: [MiracleStory]
}

struct MiracleStory: Decodable, Identifiable, Hashable {
    let id: String
    /// The book's own numbering, 1 to 16.
    let number: Int
    /// Whose miracle it is; the list groups stories by `figure.en`.
    let figure: LocalizedText
    let title: LocalizedText
    let subtitle: LocalizedText
    /// Paragraphs separated by a blank line.
    let body: LocalizedText
    /// How the vow is kept - only the Imam Ali story carries one.
    let closing: LocalizedText?
}

extension MiracleStory {
    /// Every paragraph in reading order - the body, then the closing - with a stable id
    /// ("body.0", "closing.0"). The reader's scroll anchors, its read-aloud spans and the
    /// recorded narration all use this split: scripts/build_miracle_audio.py renders one
    /// clip per paragraph in exactly this order, keyed by the paragraph's text.
    func paragraphs(for language: CommentaryLanguage) -> [(id: String, text: String)] {
        var out: [(id: String, text: String)] = []
        for (section, text) in [("body", body), ("closing", closing)] {
            guard let text else { continue }
            let paragraphs = text.text(for: language)
                .components(separatedBy: "\n\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            out += paragraphs.enumerated().map { ("\(section).\($0.offset)", $0.element) }
        }
        return out
    }

    /// The On-Demand Resources tag (and pack folder) holding this story's narration in a
    /// language, e.g. "miracle-01-ur".
    func audioTag(for language: CommentaryLanguage) -> String {
        String(format: "miracle-%02d-%@", number, language == .urdu ? "ur" : "en")
    }
}

/// The stories of one figure, in the book's order.
struct MiracleStoryGroup: Identifiable {
    let figure: String
    let stories: [MiracleStory]
    var id: String { figure }
}
