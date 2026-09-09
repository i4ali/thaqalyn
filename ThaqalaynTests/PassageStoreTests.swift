// ThaqalaynTests/PassageStoreTests.swift
import XCTest
@testable import Thaqalayn

@MainActor
final class PassageStoreTests: XCTestCase {
    func testLoadsBundledPassage() {
        let store = PassageStore()
        let p = store.passage(surah: 2, index: 4)
        XCTAssertEqual(p?.title.en, "Adam and the angels")
        XCTAssertTrue(store.hasCommentary(surah: 2, index: 4))
        // Commentary ships surah by surah; count only what cannot regress.
        XCTAssertGreaterThanOrEqual(store.passageCount(withCommentary: 2), 5)
        XCTAssertFalse(store.hasCommentary(surah: 2, index: 41), "al-Baqarah has 40 passages")
        XCTAssertNil(store.passage(surah: 114, index: 1), "no passages file for an-Nas yet")
        XCTAssertEqual(store.passageCount(withCommentary: 114), 0)
    }

    func testTitleFallsBackToVerseRange() {
        let store = PassageStore()
        XCTAssertEqual(store.title(for: PassageRef(surah: 2, index: 4, start: 30, end: 39)), "Adam and the angels")
        XCTAssertEqual(store.title(for: PassageRef(surah: 114, index: 1, start: 1, end: 6)), "Verses 1 to 6")
    }

    func testUnderstandingGate() {
        XCTAssertTrue(PremiumManager.shared.canAccessUnderstanding(surahNumber: 1))
        XCTAssertEqual(PremiumManager.shared.canAccessUnderstanding(surahNumber: 2), PremiumManager.shared.isPremium)
    }
}
