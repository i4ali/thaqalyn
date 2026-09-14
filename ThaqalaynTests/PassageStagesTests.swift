// ThaqalaynTests/PassageStagesTests.swift
import XCTest
@testable import Thaqalayn

final class PassageStagesTests: XCTestCase {
    func testVersesOnlyPassageHasOneStage() {
        let unread = PassageStages(isRead: false, isUnderstood: false, hasCommentary: false, hasQuiz: false)
        XCTAssertEqual(unread.available, [.read])
        XCTAssertEqual(unread.total, 1)
        XCTAssertEqual(unread.doneCount, 0)
        XCTAssertEqual(unread.next, .read)
        XCTAssertFalse(unread.isComplete)

        let read = PassageStages(isRead: true, isUnderstood: false, hasCommentary: false, hasQuiz: false)
        XCTAssertTrue(read.isComplete)
        XCTAssertNil(read.next)
    }

    func testStagesFollowTheOrderReadUnderstandTest() {
        var stages = PassageStages(isRead: false, isUnderstood: false, hasCommentary: true, hasQuiz: true)
        XCTAssertEqual(stages.available, [.read, .understand, .test])
        XCTAssertEqual(stages.next, .read)

        stages = PassageStages(isRead: true, isUnderstood: false, hasCommentary: true, hasQuiz: true)
        XCTAssertEqual(stages.doneCount, 1)
        XCTAssertEqual(stages.next, .understand)

        stages = PassageStages(isRead: true, isUnderstood: true, hasCommentary: true, hasQuiz: true)
        XCTAssertEqual(stages.doneCount, 2)
        XCTAssertEqual(stages.next, .test)

        stages = PassageStages(isRead: true, isUnderstood: true, bestScore: 3, hasCommentary: true, hasQuiz: true)
        XCTAssertEqual(stages.doneCount, 3)
        XCTAssertTrue(stages.isComplete)
        XCTAssertNil(stages.next)
    }

    func testStagesCanBeDoneOutOfOrder() {
        // Understood and tested before the verses were marked read: the next
        // step is still Read, and the passage is not complete.
        let stages = PassageStages(isRead: false, isUnderstood: true, bestScore: 5, hasCommentary: true, hasQuiz: true)
        XCTAssertEqual(stages.doneCount, 2)
        XCTAssertEqual(stages.next, .read)
        XCTAssertFalse(stages.isComplete)
    }

    func testAnUnderstoodFlagWithoutCommentaryDoesNotCount() {
        // A stale flag (commentary withdrawn) must not add a stage.
        let stages = PassageStages(isRead: true, isUnderstood: true, hasCommentary: false, hasQuiz: false)
        XCTAssertEqual(stages.total, 1)
        XCTAssertEqual(stages.doneCount, 1)
        XCTAssertTrue(stages.isComplete)
    }
}
