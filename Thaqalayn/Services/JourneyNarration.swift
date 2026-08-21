//
//  JourneyNarration.swift
//  Thaqalayn
//
//  The "audio director": shared connector strings + the assembler that turns a whole
//  deep dive into one ordered narration timeline (intro + per-movement announcements +
//  each beat's segments + outro). This is THE canonical narration source - both the
//  extractor (which pre-renders the English speech) and the player consume `timeline(for:)`.
//

import Foundation

enum JourneyNarration {
    static let verseLeadIn = "The Qur'an says:"
    static let meaning = "which means:"
    static let beatGap: TimeInterval = 1.0
    static let outro = "That brings the journey to its close."   // tuned by ear at the sample gate

    /// "Movement one. The Knowing." - needs the act NAME, which lives on `dive.acts`,
    /// so this is assembled here (timeline scope), not in the section-local method.
    static func movementAnnouncement(for dive: DeepDive, act n: Int) -> String {
        let word = dive.stageWord                       // "Movement" by default
        let ord = ordinal(n)
        if let name = dive.actInfo(n)?.name.text(for: .english), !name.isEmpty {
            return "\(word) \(ord). \(name)."
        }
        return "\(word) \(ord)."
    }

    /// Journey intro built from titleEn + the dive-level subtitle.
    static func intro(for dive: DeepDive) -> [NarrationSegment] {
        [.speech("\(dive.titleEn). \(dive.subtitle.text(for: .english))"), .pause(beatGap)]
    }

    /// A narration segment tagged with the dive.sections index it belongs to
    /// (intro -> section 0; a movement announcement -> its act section; outro -> last section).
    struct AnnotatedSegment: Equatable { let segment: NarrationSegment; let beatIndex: Int }

    /// Beat-attributed assembly: the whole narration timeline, each segment tagged with the
    /// `dive.sections` index it belongs to (so the player can surface the current beat).
    /// `timeline` is defined as this with the tags dropped, so the two can never diverge -
    /// the extractor + NarrationSegmentsTests pin `timeline`'s exact output.
    static func annotatedTimeline(for dive: DeepDive) -> [AnnotatedSegment] {
        var out: [AnnotatedSegment] = []
        let last = max(0, dive.sections.count - 1)
        for seg in intro(for: dive) { out.append(.init(segment: seg, beatIndex: 0)) }
        for (i, section) in dive.sections.enumerated() {
            if case .act(let a, _, _, _) = section, a >= 1 {
                out.append(.init(segment: .speech(movementAnnouncement(for: dive, act: a)), beatIndex: i))
            }
            for seg in section.narrationSegments(for: .english) {
                out.append(.init(segment: seg, beatIndex: i))
            }
        }
        out.append(.init(segment: .pause(beatGap), beatIndex: last))
        out.append(.init(segment: .speech(outro), beatIndex: last))
        return out
    }

    static func timeline(for dive: DeepDive) -> [NarrationSegment] {
        annotatedTimeline(for: dive).map { $0.segment }
    }

    /// one, two, three, ... (fallback to the numeral). Small map for 1-12.
    private static func ordinal(_ n: Int) -> String {
        let words = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve"]
        return (1...12).contains(n) ? words[n] : "\(n)"
    }
}
