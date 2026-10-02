//
//  NarrationTranslationTests.swift
//  ThaqalaynTests
//
//  The Urdu journey narration: the English timeline with each narrator line swapped for its
//  bundled translation (JourneyNarrationTranslation), and the per-language narration packs.
//

import XCTest
@testable import Thaqalayn

final class NarrationTranslationTests: XCTestCase {

    private func allDives() -> [DeepDive] {
        let candidates = DeepDiveDescriptor.all.compactMap { $0.dive }
                       + SurahExperienceDescriptor.all.compactMap { $0.dive }
        var seen = Set<String>()
        return candidates.filter { seen.insert($0.id).inserted }
    }

    private func hasLatin(_ text: String) -> Bool {
        text.range(of: "[A-Za-z]", options: .regularExpression) != nil
    }

    func test_translate_swapsNarratorLinesAndKeepsEverythingElse() {
        let timeline: [JourneyNarration.AnnotatedSegment] = [
            .init(segment: .speech("Seven short verses."), beatIndex: 0),
            .init(segment: .pause(1.0), beatIndex: 0),
            .init(segment: .speech(JourneyNarration.verseLeadIn), beatIndex: 1),
            .init(segment: .recitation(.verse(surah: 1, ayah: 1)), beatIndex: 1),
            .init(segment: .recitation(.dua(arabic: "ٱلْحَمْدُ لِلَّهِ")), beatIndex: 1),
            .init(segment: .speech("Not translated."), beatIndex: 2),
        ]
        var lines = JourneyNarrationTranslation.urduConnectors
        lines["Seven short verses."] = "سات مختصر آیات۔"

        let out = JourneyNarration.translate(timeline, lines: lines)

        XCTAssertEqual(out.map(\.beatIndex), timeline.map(\.beatIndex))
        XCTAssertEqual(out[0].segment, .speech("سات مختصر آیات۔"))
        XCTAssertEqual(out[1].segment, .pause(1.0))
        XCTAssertEqual(out[2].segment, .speech("قرآنِ مجید فرماتا ہے:"))
        XCTAssertEqual(out[3].segment, .recitation(.verse(surah: 1, ayah: 1)))
        XCTAssertEqual(out[4].segment, .recitation(.dua(arabic: "ٱلْحَمْدُ لِلَّهِ")))
        XCTAssertEqual(out[5].segment, .speech("Not translated."), "a missing translation stays English")
    }

    func test_englishNarration_isTheCanonicalTimeline() {
        for dive in allDives() {
            XCTAssertEqual(JourneyNarration.annotatedTimeline(for: dive, language: .english),
                           JourneyNarration.annotatedTimeline(for: dive), dive.id)
        }
    }

    /// A journey with an Urdu translation file narrates every line in Urdu, with the same
    /// beats, pauses and recitations as the English. Editing a narrated English line without
    /// updating its Urdu pair (scripts/journey_urdu.py) fails here.
    func test_everyTranslatedJourney_isFullyTranslated() {
        for dive in allDives() where JourneyNarrationTranslation.urduLines(for: dive.id) != nil {
            let english = JourneyNarration.annotatedTimeline(for: dive)
            let urdu = JourneyNarration.annotatedTimeline(for: dive, language: .urdu)
            XCTAssertEqual(urdu.map(\.beatIndex), english.map(\.beatIndex), dive.id)
            for (u, e) in zip(urdu, english) {
                switch (u.segment, e.segment) {
                case (.speech(let ur), .speech(let en)):
                    XCTAssertFalse(hasLatin(ur), "\(dive.id): no Urdu for “\(en)”")
                default:
                    XCTAssertEqual(u.segment, e.segment, dive.id)
                }
            }
        }
        // Every journey offered in Urdu has its translation bundled.
        for dive in allDives() where JourneyAudioAvailability.isAudioReady(dive.id, language: .urdu) {
            XCTAssertNotNil(JourneyNarrationTranslation.urduLines(for: dive.id), "\(dive.id) is offered in Urdu without its text")
        }
    }

    func test_packTags_andBundling() {
        XCTAssertEqual(JourneyAudioAvailability.packTag("surah-yunus", language: .english), "surah-yunus")
        XCTAssertEqual(JourneyAudioAvailability.packTag("surah-yunus", language: .urdu), "surah-yunus-ur")
        XCTAssertTrue(JourneyAudioAvailability.isBundled("yaqin"))
        XCTAssertFalse(JourneyAudioAvailability.isBundled("yaqin", language: .urdu), "only the free journeys' English is bundled")
        XCTAssertFalse(JourneyAudioAvailability.isBundled("surah-yunus"))
    }

    func test_urduPlaylist_resolvesUrduSpeech() {
        guard let dive = allDives().first(where: { JourneyNarrationTranslation.urduLines(for: $0.id) != nil }) else {
            return   // no journey translated yet
        }
        let english = JourneyAudioPlayer.buildPlaylist(for: dive)
        let urdu = JourneyAudioPlayer.buildPlaylist(for: dive, language: .urdu)
        XCTAssertEqual(urdu.count, english.count)
        XCTAssertEqual(urdu.map(\.beatIndex), english.map(\.beatIndex))
        let urduSpeech = urdu.compactMap { clip -> String? in
            if case .speech(let t) = clip.source { return t } else { return nil }
        }
        XCTAssertFalse(urduSpeech.isEmpty)
        XCTAssertTrue(urduSpeech.allSatisfy { !hasLatin($0) })
    }
}
