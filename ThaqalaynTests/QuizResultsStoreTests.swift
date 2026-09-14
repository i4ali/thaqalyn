// ThaqalaynTests/QuizResultsStoreTests.swift
import XCTest
@testable import Thaqalayn

@MainActor
final class QuizResultsStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "QuizResultsStoreTests"
    private let ref = PassageRef(surah: 2, index: 4, start: 30, end: 39)

    override func setUp() {
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    func testEmptyByDefault() {
        XCTAssertNil(QuizResultsStore(defaults: defaults).best(for: ref))
    }

    func testRecordKeepsTheHigherScore() {
        let store = QuizResultsStore(defaults: defaults)
        store.record(PassageQuizResult(surah: 2, index: 4, score: 3, total: 5, completedAt: Date()))
        store.record(PassageQuizResult(surah: 2, index: 4, score: 5, total: 5, completedAt: Date()))
        store.record(PassageQuizResult(surah: 2, index: 4, score: 2, total: 5, completedAt: Date()))
        XCTAssertEqual(store.best(for: ref)?.score, 5)
    }

    func testSummaryForProgressTab() {
        let store = QuizResultsStore(defaults: defaults)
        XCTAssertEqual(store.takenCount, 0)
        XCTAssertEqual(store.fullMarksCount, 0)
        XCTAssertNil(store.averageBestScore)

        store.record(PassageQuizResult(surah: 2, index: 4, score: 5, total: 5, completedAt: Date()))
        store.record(PassageQuizResult(surah: 2, index: 5, score: 3, total: 5, completedAt: Date()))
        store.record(PassageQuizResult(surah: 1, index: 1, score: 4, total: 5, completedAt: Date()))
        // A second, lower attempt on 2:5 must not change the summary.
        store.record(PassageQuizResult(surah: 2, index: 5, score: 1, total: 5, completedAt: Date()))

        XCTAssertEqual(store.takenCount, 3)
        XCTAssertEqual(store.fullMarksCount, 1)
        XCTAssertEqual(store.averageBestScore ?? 0, 4.0, accuracy: 0.001)
    }

    func testPersistsAcrossInstances() {
        QuizResultsStore(defaults: defaults)
            .record(PassageQuizResult(surah: 2, index: 4, score: 4, total: 5, completedAt: Date()))
        let reloaded = QuizResultsStore(defaults: defaults)
        XCTAssertEqual(reloaded.best(for: ref)?.score, 4)
        XCTAssertEqual(reloaded.bestScores(surah: 2), [4: 4])
    }
}
