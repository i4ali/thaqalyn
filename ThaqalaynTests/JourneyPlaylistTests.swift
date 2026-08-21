//
//  JourneyPlaylistTests.swift
//  ThaqalaynTests
//
//  Pins the PURE seam of JourneyAudioPlayer: `buildPlaylist(for:)` turns a whole
//  dive's beat-attributed narration timeline into an ordered list of PlayableClips
//  (English speech / real verse recitation / captured dua / reflective pause), each
//  carrying the dive.sections beatIndex it belongs to. No I/O - fully testable.
//

import XCTest
@testable import Thaqalayn

final class JourneyPlaylistTests: XCTestCase {
    func test_buildPlaylist_ordersSegmentsAndTracksBeatIndex() {
        let clips = JourneyAudioPlayer.buildPlaylist(for: .yaqin)
        // first clip = intro speech, beat 0
        guard case .speech(let s)? = clips.first?.source else { return XCTFail() }
        XCTAssertTrue(s.contains("Yaqin"))
        XCTAssertEqual(clips.first?.beatIndex, 0)
        // there is a verse clip and it maps to a .verse section
        let v = clips.first { if case .verse = $0.source { return true }; return false }
        XCTAssertNotNil(v)
        if let i = v?.beatIndex, case .verse = DeepDive.yaqin.sections[i] {} else { XCTFail("verse clip -> .verse section") }
        // there is a dua clip mapping to the .dua section
        XCTAssertTrue(clips.contains { if case .dua = $0.source { return true }; return false })
        // last clip = outro, mapping to the last section
        guard case .speech(let last)? = clips.last?.source else { return XCTFail() }
        XCTAssertEqual(last, JourneyNarration.outro)
        XCTAssertEqual(clips.last?.beatIndex, DeepDive.yaqin.sections.count - 1)
        // beat indices are non-decreasing (timeline is in section order)
        let idxs = clips.map { $0.beatIndex }
        XCTAssertEqual(idxs, idxs.sorted())
        // pauses are preserved as clips
        XCTAssertTrue(clips.contains { if case .pause = $0.source { return true }; return false })
    }
}
