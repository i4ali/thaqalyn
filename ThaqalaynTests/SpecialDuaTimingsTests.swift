import XCTest
@testable import Thaqalayn

/// Coverage for the dua karaoke timing model: the position(at:) lookup rules the
/// gold highlight lives on, and the integrity of the bundled alignment data
/// against the bundled dua texts (indices in range, monotonic order). The visual
/// highlight itself is a device-verified step.
final class SpecialDuaTimingsTests: XCTestCase {

    private func makeTimings() -> DuaTimings {
        // Three words: [1.0-1.5], gap, [2.5-3.0], adjacent [3.0-4.0]
        DuaTimings(audioDuration: 10, words: [
            DuaWordTiming(position: DuaWordPosition(segment: 0, token: 0), start: 1.0, end: 1.5),
            DuaWordTiming(position: DuaWordPosition(segment: 0, token: 1), start: 2.5, end: 3.0),
            DuaWordTiming(position: DuaWordPosition(segment: 1, token: 0), start: 3.0, end: 4.0),
        ])
    }

    /// Before the first word there is nothing to light up (intro audio).
    func test_position_nilBeforeFirstWord() {
        XCTAssertNil(makeTimings().position(at: 0.4))
    }

    /// Mid-word lights that word; inside an inter-word pause the previous word
    /// stays lit (no flicker between words).
    func test_position_currentWord_andNoFlickerInGaps() {
        let t = makeTimings()
        XCTAssertEqual(t.position(at: 1.2), DuaWordPosition(segment: 0, token: 0))
        XCTAssertEqual(t.position(at: 2.0), DuaWordPosition(segment: 0, token: 0)) // gap: stay lit
        XCTAssertEqual(t.position(at: 2.6), DuaWordPosition(segment: 0, token: 1))
        XCTAssertEqual(t.position(at: 3.5), DuaWordPosition(segment: 1, token: 0))
    }

    /// The last word lingers briefly past its end (outro audio), then clears.
    func test_position_lingersThenClearsAfterLastWord() {
        let t = makeTimings()
        XCTAssertEqual(t.position(at: 5.0), DuaWordPosition(segment: 1, token: 0))
        XCTAssertNil(t.position(at: 9.0))
    }

    /// Tap-to-seek: a segment's start is its first word's start; a segment with
    /// no timed words has none.
    func test_segmentStart() {
        let t = makeTimings()
        XCTAssertEqual(t.segmentStart(0), 1.0)
        XCTAssertEqual(t.segmentStart(1), 3.0)
        XCTAssertNil(t.segmentStart(7))
    }

    /// The bundled timings must cover every dua that has a recitation, and every
    /// word address must land on a real token of the bundled text, in monotonic
    /// recitation order. Guards against the texts and the alignment drifting apart.
    @MainActor
    func test_bundledTimings_matchBundledTexts() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "special_duas", withExtension: "json"))
        let data = try JSONDecoder().decode(SpecialDuasData.self, from: Data(contentsOf: url))

        for dua in data.duas where dua.audioURL != nil {
            let timings = try XCTUnwrap(SpecialDuaTimingsStore.shared.timings(for: dua.id),
                                        "\(dua.id): no bundled timings")
            XCTAssertGreaterThan(timings.audioDuration, 60, "\(dua.id): implausible duration")

            var lastStart: TimeInterval = -1
            for word in timings.words {
                let pos = word.position
                XCTAssertTrue(dua.segments.indices.contains(pos.segment),
                              "\(dua.id): segment \(pos.segment) out of range")
                let tokens = DuaArabicTokenizer.tokens(dua.segments[pos.segment].ar ?? "")
                XCTAssertTrue(pos.token < tokens.count,
                              "\(dua.id): token \(pos.token) out of range in segment \(pos.segment)")
                XCTAssertGreaterThanOrEqual(word.start, lastStart, "\(dua.id): non-monotonic starts")
                XCTAssertGreaterThanOrEqual(word.end, word.start, "\(dua.id): word ends before it starts")
                lastStart = word.start
            }
            XCTAssertLessThanOrEqual(timings.words.last!.end, timings.audioDuration + 1,
                                     "\(dua.id): last word beyond the recording")
        }
    }
}
