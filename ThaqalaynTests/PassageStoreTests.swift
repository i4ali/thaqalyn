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
        XCTAssertFalse(store.hasCommentary(surah: 2, index: 6))
        XCTAssertNil(store.passage(surah: 3, index: 1))
        XCTAssertEqual(store.passageCount(withCommentary: 2), 5)
        XCTAssertEqual(store.passageCount(withCommentary: 3), 0)
    }

    func testUnderstandingGate() {
        XCTAssertTrue(PremiumManager.shared.canAccessUnderstanding(surahNumber: 1))
        XCTAssertEqual(PremiumManager.shared.canAccessUnderstanding(surahNumber: 2), PremiumManager.shared.isPremium)
    }
}
