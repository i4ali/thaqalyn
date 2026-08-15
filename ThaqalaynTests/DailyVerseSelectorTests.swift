//
//  DailyVerseSelectorTests.swift
//  ThaqalaynTests
//
//  Golden characterization of the daily-verse selection. The fixture was
//  captured from DailyVerseProvider BEFORE DailyVerseSelector was extracted;
//  the selector must reproduce it exactly, forever. If this test fails after
//  a refactor, the refactor changed behavior - fix the code, never the fixture.
//

import XCTest
@testable import Thaqalayn

@MainActor
final class DailyVerseSelectorTests: XCTestCase {

    private func goldenDates() -> [Date] {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return (0..<400).map { offset in
            cal.date(byAdding: .day, value: offset,
                     to: cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!)!
        }
    }

    func testSelectionMatchesGoldenDates() throws {
        let got = goldenDates().map { DailyVerseProvider.shared.verse(for: $0).id }
        XCTAssertEqual(got.count, 400)

        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "daily_verse_golden", withExtension: "json") else {
            // Capture mode: no fixture in the bundle yet. Write it next to this
            // source file (simulator tests run as the host user), then fail so
            // the capture run is never mistaken for a passing one.
            let fixtureDir = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().appendingPathComponent("Fixtures")
            try FileManager.default.createDirectory(at: fixtureDir, withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            try encoder.encode(got).write(to: fixtureDir.appendingPathComponent("daily_verse_golden.json"))
            XCTFail("Fixture daily_verse_golden.json captured - rebuild and re-run to pin")
            return
        }
        let expected = try JSONDecoder().decode([String].self, from: Data(contentsOf: url))
        XCTAssertEqual(got, expected)
    }
}
