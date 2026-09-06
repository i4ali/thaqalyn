// ThaqalaynTests/PassageIndexTests.swift
import XCTest
@testable import Thaqalayn

final class PassageIndexTests: XCTestCase {
    private func index() throws -> PassageIndex {
        let url = Bundle.main.url(forResource: "quran_data", withExtension: "json")!
        let data = try JSONDecoder().decode(QuranData.self, from: Data(contentsOf: url))
        return PassageIndex(quran: data)
    }

    func testCounts() throws {
        let idx = try index()
        XCTAssertEqual(idx.passages(forSurah: 2).count, 40)
        XCTAssertEqual(idx.passages(forSurah: 1).count, 1)
        XCTAssertEqual((1...114).reduce(0) { $0 + idx.passages(forSurah: $1).count }, 556)
    }

    func testAdamPassage() throws {
        let idx = try index()
        let p = idx.passage(surah: 2, index: 4)!
        XCTAssertEqual(p.start, 30)
        XCTAssertEqual(p.end, 39)
        XCTAssertEqual(p.id, "2:4")
        XCTAssertEqual(p.verses, Array(30...39))
        XCTAssertNil(idx.passage(surah: 2, index: 41))
    }

    func testPassageForVerse() throws {
        let idx = try index()
        XCTAssertEqual(idx.passage(surah: 2, containing: 141)?.index, 16)
        XCTAssertEqual(idx.passage(surah: 2, containing: 253)?.index, 33)
        XCTAssertEqual(idx.passage(surah: 1, containing: 7)?.index, 1)
        XCTAssertNil(idx.passage(surah: 2, containing: 300))
    }

    func testNextPassage() throws {
        let idx = try index()
        XCTAssertEqual(idx.next(after: idx.passage(surah: 2, index: 4)!)?.id, "2:5")
        XCTAssertNil(idx.next(after: idx.passage(surah: 2, index: 40)!))
    }
}
