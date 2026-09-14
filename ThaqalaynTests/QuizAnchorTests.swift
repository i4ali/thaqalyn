// ThaqalaynTests/QuizAnchorTests.swift
import XCTest
@testable import Thaqalayn

final class QuizAnchorTests: XCTestCase {
    private func passage() throws -> Passage {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "passage_2_4", withExtension: "json"))
        return try JSONDecoder().decode(Passage.self, from: Data(contentsOf: url))
    }

    func testNarrationAndNoteAnchors() throws {
        let p = try passage()
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "verses.31.narrations.n3", quote: "x"), in: p, lang: .english), "v31.n3")
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "verses.31.note", quote: "x"), in: p, lang: .english), "v31.note")
    }

    func testEssayAnchorFindsItsParagraph() throws {
        let p = try passage()
        let paragraphs = UnderstandingView.paragraphs(p.essay.en)
        let target = paragraphs.indices.last ?? 0
        let words = paragraphs[target].split(separator: " ").prefix(8).joined(separator: " ")
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "essay", quote: words), in: p, lang: .english), "essay.\(target)")
    }

    func testEssayAnchorWithUnknownQuoteFallsBackToTop() throws {
        let p = try passage()
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "essay", quote: "not in the essay at all"), in: p, lang: .english), "essay.0")
    }

    func testTranslationAnchorLandsOnTheVerseRow() throws {
        let p = try passage()
        let id = UnderstandingView.scrollId(for: QuizAnchor(location: "verses.34.translation", quote: "x"), in: p, lang: .english)
        XCTAssertTrue(id?.hasPrefix("v34.") ?? false, String(describing: id))
    }
}
