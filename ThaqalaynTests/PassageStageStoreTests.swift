// ThaqalaynTests/PassageStageStoreTests.swift
import XCTest
@testable import Thaqalayn

@MainActor
final class PassageStageStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "PassageStageStoreTests"
    private let ref = PassageRef(surah: 2, index: 3, start: 21, end: 29)

    override func setUp() {
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    func testEmptyByDefault() {
        let store = PassageStageStore(defaults: defaults)
        XCTAssertFalse(store.isUnderstood(ref))
        XCTAssertEqual(store.understoodCount, 0)
        XCTAssertTrue(store.understoodIndices(surah: 2).isEmpty)
    }

    func testMarkAndUnmark() {
        let store = PassageStageStore(defaults: defaults)
        store.markUnderstood(ref)
        XCTAssertTrue(store.isUnderstood(ref))
        store.markUnderstood(ref) // idempotent
        XCTAssertEqual(store.understoodCount, 1)
        store.unmarkUnderstood(ref)
        XCTAssertFalse(store.isUnderstood(ref))
        XCTAssertEqual(store.understoodCount, 0)
    }

    func testIndicesArePerSurah() {
        let store = PassageStageStore(defaults: defaults)
        store.markUnderstood(PassageRef(surah: 2, index: 1, start: 1, end: 7))
        store.markUnderstood(PassageRef(surah: 2, index: 4, start: 30, end: 39))
        store.markUnderstood(PassageRef(surah: 1, index: 1, start: 1, end: 7))
        XCTAssertEqual(store.understoodIndices(surah: 2), [1, 4])
        XCTAssertEqual(store.understoodIndices(surah: 1), [1])
        XCTAssertEqual(store.understoodIndices(surah: 3), [])
    }

    func testPersistsAcrossInstances() {
        PassageStageStore(defaults: defaults).markUnderstood(ref)
        let reloaded = PassageStageStore(defaults: defaults)
        XCTAssertTrue(reloaded.isUnderstood(ref))
    }
}
