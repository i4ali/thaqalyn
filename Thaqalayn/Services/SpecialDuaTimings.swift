//
//  SpecialDuaTimings.swift
//  Thaqalayn
//
//  Per-word recitation timings for the Duas & Ziyarat library, powering the
//  golden karaoke word highlight while a recitation streams. Produced offline
//  by scripts/align_special_duas.py (MMS forced alignment of each dua's Arabic
//  against its duas.org recording) and bundled as special_dua_timings.json.
//  Times address a word as (segment index in SpecialDua.segments, token index
//  in that segment's whitespace-split Arabic).
//

import Foundation

/// Address of one Arabic word: `segment` indexes `SpecialDua.segments` (notes
/// included), `token` the space-split tokens of that segment's `ar`.
struct DuaWordPosition: Equatable {
    let segment: Int
    let token: Int
}

/// Tokenizes a segment's Arabic exactly like the alignment pipeline (Python's
/// `str.split()`; the texts only ever use plain single spaces). Must split on
/// the space SCALAR, not on grapheme clusters: a standalone Quranic pause mark
/// (e.g. U+06DA in a quoted verse) clusters with the preceding space, and a
/// `Character`-level split would swallow it, shifting every later index off
/// the aligned timings.
enum DuaArabicTokenizer {
    static func tokens(_ ar: String) -> [String] {
        ar.unicodeScalars.split(separator: " ").map { String(String.UnicodeScalarView($0)) }
    }
}

struct DuaWordTiming {
    let position: DuaWordPosition
    let start: TimeInterval
    let end: TimeInterval
}

/// One dua's aligned word timeline, with the lookups the karaoke UI needs.
struct DuaTimings {
    /// Duration of the recording the alignment was made against. If the
    /// streamed file's duration disagrees (duas.org swapped the recording),
    /// the timings are stale and highlighting is disabled.
    let audioDuration: TimeInterval
    /// Words in recitation order (starts are monotonic).
    let words: [DuaWordTiming]

    private let segmentStarts: [Int: TimeInterval]

    /// Once the last word has ended, keep it lit briefly (recitations often
    /// trail off with un-transcribed audio), then clear the highlight.
    private static let tailLinger: TimeInterval = 1.5

    init(audioDuration: TimeInterval, words: [DuaWordTiming]) {
        self.audioDuration = audioDuration
        self.words = words.sorted { $0.start < $1.start }
        var starts: [Int: TimeInterval] = [:]
        for w in self.words where starts[w.position.segment] == nil {
            starts[w.position.segment] = w.start
        }
        self.segmentStarts = starts
    }

    /// The word being recited at `time`. A word stays lit until the next one
    /// starts (recitation pauses shouldn't flicker the highlight off).
    func position(at time: TimeInterval) -> DuaWordPosition? {
        guard let first = words.first, let last = words.last,
              time >= first.start, time <= last.end + Self.tailLinger else { return nil }
        // Binary search: last word whose start is <= time.
        var lo = 0, hi = words.count - 1
        while lo < hi {
            let mid = (lo + hi + 1) / 2
            if words[mid].start <= time { lo = mid } else { hi = mid - 1 }
        }
        return words[lo].position
    }

    /// Where segment `segment`'s first word is recited (for tap-to-seek).
    func segmentStart(_ segment: Int) -> TimeInterval? { segmentStarts[segment] }
}

/// Loads the bundled timings file once and hands out per-dua timelines.
@MainActor
final class SpecialDuaTimingsStore {
    static let shared = SpecialDuaTimingsStore()

    private var cache: [String: DuaTimings]?

    func timings(for duaID: String) -> DuaTimings? {
        if cache == nil { cache = Self.load() }
        return cache?[duaID]
    }

    private static func load() -> [String: DuaTimings] {
        guard let url = Bundle.main.url(forResource: "special_dua_timings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(TimingsFile.self, from: data) else {
            return [:]
        }
        var out: [String: DuaTimings] = [:]
        for (id, raw) in file.duas {
            let words = raw.words.compactMap { entry -> DuaWordTiming? in
                guard entry.count == 4 else { return nil }
                return DuaWordTiming(
                    position: DuaWordPosition(segment: entry[0], token: entry[1]),
                    start: TimeInterval(entry[2]) / 100.0,
                    end: TimeInterval(entry[3]) / 100.0
                )
            }
            guard !words.isEmpty else { continue }
            out[id] = DuaTimings(audioDuration: raw.duration, words: words)
        }
        return out
    }

    // Compact wire format: words are [segment, token, startCentisec, endCentisec].
    private struct TimingsFile: Decodable {
        let version: Int
        let duas: [String: RawDua]
    }
    private struct RawDua: Decodable {
        let duration: TimeInterval
        let words: [[Int]]
    }
}
