//
//  JourneyNarrationTranslation.swift
//  Thaqalayn
//
//  The Urdu narration of a journey. The English timeline (JourneyNarration) stays the one
//  canonical script: Urdu is that same timeline with every narrator line swapped for its
//  translation, so both languages share the beats, pauses and recitations exactly and a
//  saved position carries across a language switch.
//
//  Translations ship per journey as Data/JourneyUrdu/journey_ur_<id>.json - an ordered list
//  of {en, ur} pairs, written and reviewed offline (scripts/journey_urdu.py) - and the three
//  connectors every journey shares are fixed here. A line is matched by its exact English, so
//  editing a narrated English line leaves it untranslated until its pair is updated; the
//  tooling and NarrationTranslationTests catch that before an Urdu pack ships.
//

import Foundation

enum JourneyNarrationTranslation {
    /// The Urdu for the narrator lines every journey shares.
    static let urduConnectors: [String: String] = [
        JourneyNarration.verseLeadIn: "قرآنِ مجید فرماتا ہے:",
        JourneyNarration.meaning: "جس کا ترجمہ ہے:",
        JourneyNarration.outro: "یہاں یہ سفر اپنے اختتام کو پہنچتا ہے۔",
    ]

    /// English narrator line -> Urdu for one journey, connectors included, or nil when the
    /// journey has no Urdu translation. Loaded from the bundle once per journey, then cached.
    static func urduLines(for journeyId: String) -> [String: String]? {
        cache.lines(for: journeyId)
    }

    // MARK: - Bundled translation files

    private struct File: Decodable {
        struct Line: Decodable { let en: String; let ur: String }
        let lines: [Line]
    }

    private static let cache = Cache()

    /// Thread-safe per-journey cache (the playlist is built off the main actor in tests).
    private final class Cache: @unchecked Sendable {
        private let lock = NSLock()
        private var loaded: [String: [String: String]?] = [:]

        func lines(for journeyId: String) -> [String: String]? {
            lock.lock(); defer { lock.unlock() }
            if let hit = loaded[journeyId] { return hit }
            let table = Self.load(journeyId)
            loaded[journeyId] = table
            return table
        }

        private static func load(_ journeyId: String) -> [String: String]? {
            guard let url = Bundle.main.url(forResource: "journey_ur_\(journeyId)", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let file = try? JSONDecoder().decode(File.self, from: data) else { return nil }
            var table = urduConnectors
            for line in file.lines { table[line.en] = line.ur }
            return table
        }
    }
}
