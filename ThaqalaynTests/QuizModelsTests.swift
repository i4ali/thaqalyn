// ThaqalaynTests/QuizModelsTests.swift
import XCTest
@testable import Thaqalayn

final class QuizModelsTests: XCTestCase {
    private func loadSurah(_ n: Int) throws -> [String: PassageQuiz] {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "quiz_\(n)", withExtension: "json"))
        return try JSONDecoder().decode([String: PassageQuiz].self, from: Data(contentsOf: url))
    }

    func testFatihaQuizDecodes() throws {
        let quizzes = try loadSurah(1)
        let q = try XCTUnwrap(quizzes["1"])
        XCTAssertEqual(q.id, "1:1")
        XCTAssertEqual(q.surah, 1)
        XCTAssertEqual(q.index, 1)
        XCTAssertEqual(q.start, 1)
        XCTAssertEqual(q.end, 7)
        XCTAssertEqual(q.questions.count, 5)
        XCTAssertEqual(q.questions.map(\.id), ["q1", "q2", "q3", "q4", "q5"])
    }

    func testEveryShippedQuestionIsWellFormed() throws {
        for surah in [1, 2] {
            for (_, quiz) in try loadSurah(surah) {
                XCTAssertEqual(quiz.questions.count, 5, quiz.id)
                for q in quiz.questions {
                    XCTAssertTrue(q.options.indices.contains(q.answer), "\(quiz.id) \(q.id)")
                    XCTAssertFalse(q.anchor.location.isEmpty, "\(quiz.id) \(q.id)")
                    XCTAssertFalse(q.anchor.quote.isEmpty, "\(quiz.id) \(q.id)")
                    if q.type == .trueFalse { XCTAssertEqual(q.options.map(\.en), ["True", "False"], "\(quiz.id) \(q.id)") }
                    if q.type == .fillGap { XCTAssertTrue(q.prompt.en.contains("____"), "\(quiz.id) \(q.id)") }
                }
            }
        }
    }
}
