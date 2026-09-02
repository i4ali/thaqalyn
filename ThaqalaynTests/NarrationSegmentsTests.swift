//
//  NarrationSegmentsTests.swift
//  ThaqalaynTests
//
//  Pins how each journey beat becomes an ordered list of narrator segments
//  (English speech / real Arabic recitation / reflective pause) and how the
//  "audio director" (JourneyNarration) assembles a whole dive into one timeline.
//  Chrome - tags, references, sources, placeholders, titles - is never spoken.
//

import XCTest
@testable import Thaqalayn

final class NarrationSegmentsTests: XCTestCase {
    private func firstSection(_ dive: DeepDive, where pred: (DeepDiveSection) -> Bool) -> DeepDiveSection {
        dive.sections.first(where: pred)!
    }
    private func speeches(_ segs: [NarrationSegment]) -> [String] {
        segs.compactMap { if case .speech(let s) = $0 { return s }; return nil }
    }

    func test_narrationBeat_emitsBodyThenReflection_noChrome() {
        let s = firstSection(.yaqin) { if case .narration = $0 { return true }; return false }
            .narrationSegments()
        let sp = speeches(s)
        XCTAssertTrue(sp.first?.contains("the trial grew fierce") == true)   // body is first speech
        XCTAssertTrue(sp.contains { $0.contains("closer he drew") })         // reflection present
        XCTAssertFalse(sp.contains { $0.contains("Ma'ani al-Akhbar") })      // source citation NOT spoken
    }

    func test_verseBeat_weavesVerseRecitation() {
        let s = firstSection(.surahFatiha) { if case .verse = $0 { return true }; return false }
            .narrationSegments()
        XCTAssertTrue(s.contains { if case .recitation(.verse) = $0 { return true }; return false })
    }

    func test_verseBeat_framesRecitation_leadInThenMeaningThenTranslation() {
        let s = firstSection(.surahFatiha) { if case .verse = $0 { return true }; return false }
            .narrationSegments()
        let i = s.firstIndex { if case .recitation = $0 { return true }; return false }!
        XCTAssertEqual(s[i-1], .speech(JourneyNarration.verseLeadIn))         // "The Qur'an says:" right before recitation
        let m = s.firstIndex { $0 == .speech(JourneyNarration.meaning) }!     // "which means:" appears after recitation
        XCTAssertGreaterThan(m, i)
        // the translation speech comes right after `meaning`
        if case .speech(let t) = s[m+1] { XCTAssertTrue(t.contains("In the name of Allah")) } else { XCTFail() }
    }

    func test_duaBeat_recitesDuaReadsIntroAndClose() {
        let s = firstSection(.yaqin) { if case .dua = $0 { return true }; return false }
            .narrationSegments()
        XCTAssertTrue(s.contains { if case .recitation(.dua) = $0 { return true }; return false })
        let sp = speeches(s)
        XCTAssertTrue(sp.contains { $0.contains("one prayer") })              // intro
        XCTAssertTrue(sp.contains { $0.contains("yours to keep") })           // close
        XCTAssertFalse(sp.contains { $0.contains("Sahifa") })                 // source NOT spoken
    }

    func test_reflectionPromptBeat_endsWithReflectivePause() {
        let s = firstSection(.yaqin) { if case .reflectionPrompt = $0 { return true }; return false }
            .narrationSegments()
        guard case .pause(let d) = s.last! else { return XCTFail() }
        XCTAssertGreaterThanOrEqual(d, 3.0)
        XCTAssertFalse(speeches(s).contains { $0.contains("Faith, a decision") }) // placeholder NOT spoken
    }

    func test_responseBeat_readsWordsNotChrome() {
        let s = firstSection(.surahFatiha) { if case .response = $0 { return true }; return false }
            .narrationSegments()
        let sp = speeches(s)
        XCTAssertTrue(sp.contains { $0.contains("praised Me") })              // `words`
        XCTAssertFalse(sp.contains { $0.contains("to your praise") })         // `replyingTo` chrome NOT spoken
    }

    func test_closingBeat_readsEssenceAndLine() {
        let s = firstSection(.surahFatiha) { if case .closing = $0 { return true }; return false }
            .narrationSegments()
        XCTAssertTrue(speeches(s).contains { $0.contains("Seven verses") })
    }

    func test_actBeat_weavesBridgeVerseWhenPresent() {
        // Yaqin Movement III .act carries a bridge verse (15:99)
        let withBridge = DeepDive.yaqin.sections
            .filter { if case .act = $0 { return true }; return false }
            .map { $0.narrationSegments() }
            .first { segs in segs.contains { if case .recitation(.verse) = $0 { return true }; return false } }
        XCTAssertNotNil(withBridge)
    }

    // Director / timeline level:
    func test_timeline_announcesMovementWithActName() {
        let t = JourneyNarration.timeline(for: .yaqin)
        XCTAssertTrue(t.contains { if case .speech(let s) = $0 { return s.contains("Movement one") && s.contains("The Knowing") }; return false })
    }
    func test_timeline_startsWithIntroContainingTitle_andEndsWithOutro() {
        let t = JourneyNarration.timeline(for: .yaqin)
        guard case .speech(let first) = t.first! else { return XCTFail() }
        XCTAssertTrue(first.contains("Yaqin"))
        XCTAssertTrue(t.contains { $0 == .speech(JourneyNarration.outro) })
    }
    func test_timeline_neverSpeaksTagsOrReferences() {
        let sp = JourneyNarration.timeline(for: .surahFatiha).compactMap { seg -> String? in
            if case .speech(let s) = seg { return s }; return nil }
        XCTAssertFalse(sp.contains { $0.contains("al-Fatiha · 1 : 1") })      // reference chrome
        XCTAssertFalse(sp.contains { $0 == "In His Name" })                   // tag chrome
    }
}
