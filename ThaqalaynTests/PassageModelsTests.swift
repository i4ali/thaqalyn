// ThaqalaynTests/PassageModelsTests.swift
import XCTest
@testable import Thaqalayn

final class PassageModelsTests: XCTestCase {
    private func load() throws -> Passage {
        let url = Bundle(for: Self.self).url(forResource: "passage_2_4", withExtension: "json")!
        return try JSONDecoder().decode(Passage.self, from: Data(contentsOf: url))
    }

    func testDecodesRealPassage() throws {
        let p = try load()
        XCTAssertEqual(p.id, "2:4")
        XCTAssertEqual(p.surah, 2)
        XCTAssertEqual(p.index, 4)
        XCTAssertEqual(p.range, [30, 39])
        XCTAssertEqual(p.title.en, "Adam and the angels")
        XCTAssertTrue(p.essay.en.contains("[1]"))
        XCTAssertEqual(p.verses.first?.verse, 30)
        XCTAssertEqual(p.verses.first?.narrations.first?.id, "n1")
        XCTAssertEqual(p.verses.first?.narrations.first?.source, "s25")
        XCTAssertNotNil(p.perspectives)
        XCTAssertEqual(p.sources.first?.id, "s1")
        XCTAssertEqual(p.sources.first?.tier, "B")
        XCTAssertEqual(p.sources.first?.excerpt?.lang, "ar")
        XCTAssertEqual(p.status?.auditAttempts, 3)
    }

    func testDerivedCounts() throws {
        let p = try load()
        XCTAssertEqual(p.start, 30)
        XCTAssertEqual(p.end, 39)
        XCTAssertEqual(p.verseCount, 10)
        XCTAssertEqual(p.narrationCount, 12)
        XCTAssertEqual(p.source(id: "s2")?.work, "al-Mizan fi Tafsir al-Quran")
        XCTAssertNil(p.source(id: "s999"))
        // The understanding screen shows essay, verse notes, narrations and perspectives,
        // so reading time covers all of them (essay alone would give 2 for this fixture).
        var words = p.essay.en.split(separator: " ").count
        for v in p.verses {
            words += (v.note?.en ?? "").split(separator: " ").count
            words += v.narrations.reduce(0) { $0 + $1.text.en.split(separator: " ").count }
        }
        words += (p.perspectives?.en ?? "").split(separator: " ").count
        XCTAssertEqual(p.readingMinutes, max(1, words / 200 + 1))
        XCTAssertGreaterThan(p.readingMinutes, max(1, p.essay.en.split(separator: " ").count / 200 + 1))
    }

    func testLocalizedTextFallsBackToEnglish() {
        let t = LocalizedText(en: "Hello", ur: nil, ar: nil)
        XCTAssertEqual(t.text(for: .urdu), "Hello")
        XCTAssertEqual(t.text(for: .arabic), "Hello")
        XCTAssertEqual(t.availableLanguages, [.english])
        let u = LocalizedText(en: "Hello", ur: "ہیلو", ar: nil)
        XCTAssertEqual(u.text(for: .urdu), "ہیلو")
        XCTAssertEqual(u.availableLanguages, [.english, .urdu])
    }
}
