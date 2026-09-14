// ThaqalaynTests/QuizStoreTests.swift
import XCTest
@testable import Thaqalayn

@MainActor
final class QuizStoreTests: XCTestCase {
    func testLoadsShippedQuiz() {
        let store = QuizStore()
        let ref = PassageRef(surah: 1, index: 1, start: 1, end: 7)
        XCTAssertTrue(store.hasQuiz(for: ref))
        XCTAssertEqual(store.quiz(for: ref)?.questions.count, 5)
    }

    func testMissingSurahHasNoQuiz() {
        let store = QuizStore()
        XCTAssertFalse(store.hasQuiz(for: PassageRef(surah: 114, index: 1, start: 1, end: 3)))
        XCTAssertTrue(store.quizIndices(surah: 114).isEmpty)
    }

    func testIndicesForBaqarah() {
        let store = QuizStore()
        XCTAssertGreaterThanOrEqual(store.quizIndices(surah: 2).count, 40)
    }

    func testShippedQuizCountCoversEverySurahFile() {
        let store = QuizStore()
        // al-Fatihah has 1, al-Baqarah 40; more surahs only raise it.
        XCTAssertGreaterThanOrEqual(store.shippedQuizCount(), 41)
        XCTAssertEqual(store.shippedQuizCount(), store.quizIndices(surah: 1).count + store.quizIndices(surah: 2).count
                       + (3...114).reduce(0) { $0 + store.quizIndices(surah: $1).count })
    }

    func testQuizGateFollowsUnderstanding() {
        let pm = PremiumManager.shared
        XCTAssertEqual(pm.canAccessQuiz(surahNumber: 1), pm.canAccessUnderstanding(surahNumber: 1))
        XCTAssertEqual(pm.canAccessQuiz(surahNumber: 2), pm.canAccessUnderstanding(surahNumber: 2))
    }
}
