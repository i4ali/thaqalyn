// ThaqalaynTests/MiracleStoriesTests.swift
import XCTest
@testable import Thaqalayn

final class MiracleStoriesTests: XCTestCase {
    private func load() throws -> MiracleStoriesData {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "miracle_stories", withExtension: "json"))
        return try JSONDecoder().decode(MiracleStoriesData.self, from: Data(contentsOf: url))
    }

    private static let figures: Set<String> = [
        "Sayyida Fatima", "Imam Ali", "Imam Husayn", "Imam Jafar al-Sadiq", "Imam Musa al-Kazim", "Hazrat Abbas",
    ]

    /// Transliteration diacritics the house style forbids in English (scripts/strip_diacritics.py).
    private static let diacritics = Set("āĀīĪūŪḥḤṣṢḍḌṭṬẓẒʿʾ")

    func testAllSixteenMiraclesShipInBookOrder() throws {
        let data = try load()
        XCTAssertEqual(data.stories.map(\.number), Array(1...16))
        XCTAssertEqual(Set(data.stories.map(\.id)).count, 16, "ids must be unique")
        XCTAssertFalse(data.note.isEmpty)
    }

    func testEveryStoryIsCompleteInEnglishAndUrdu() throws {
        for story in try load().stories {
            XCTAssertTrue(Self.figures.contains(story.figure.en), "\(story.id): figure \(story.figure.en)")
            var fields = [story.figure, story.title, story.subtitle, story.body]
            if let closing = story.closing { fields.append(closing) }
            for field in fields {
                XCTAssertFalse(field.en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, story.id)
                XCTAssertFalse((field.ur ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, story.id)
            }
            XCTAssertEqual(story.body.availableLanguages, [.english, .urdu], story.id)
            XCTAssertEqual(
                MiracleStoryDetailView.paragraphs(story.body.en).count,
                MiracleStoryDetailView.paragraphs(story.body.ur ?? "").count,
                "\(story.id): English and Urdu paragraph counts differ"
            )
        }
    }

    func testOnlyTheImamAliStoryHasAClosing() throws {
        let withClosing = try load().stories.filter { $0.closing != nil }.map(\.number)
        XCTAssertEqual(withClosing, [3])
    }

    func testEnglishFollowsHouseStyle() throws {
        let data = try load()
        var texts = [data.note]
        for story in data.stories {
            texts += [story.figure.en, story.title.en, story.subtitle.en, story.body.en]
            if let closing = story.closing { texts.append(closing.en) }
        }
        for text in texts {
            XCTAssertFalse(text.contains("\u{2014}") || text.contains("\u{2013}"), "em or en dash: \(text.prefix(60))")
            XCTAssertTrue(text.filter { Self.diacritics.contains($0) }.isEmpty, "diacritics: \(text.prefix(60))")
        }
    }

    /// The recorded narration is one clip per paragraph in this exact order and id scheme
    /// (scripts/build_miracle_audio.py), so English and Urdu must split identically.
    func testParagraphsLineUpAcrossLanguages() throws {
        for story in try load().stories {
            let en = story.paragraphs(for: .english).map(\.id)
            let ur = story.paragraphs(for: .urdu).map(\.id)
            XCTAssertEqual(en, ur, story.id)
            XCTAssertEqual(en.first, "body.0", story.id)
            XCTAssertEqual(en.contains("closing.0"), story.closing != nil, story.id)
        }
    }

    func testEveryStoryHasRecordedNarrationInBothLanguages() throws {
        let stories = try load().stories
        XCTAssertEqual(stories.first?.audioTag(for: .english), "miracle-01-en")
        XCTAssertEqual(stories.first?.audioTag(for: .urdu), "miracle-01-ur")
        let expected = Set(stories.flatMap { [$0.audioTag(for: .english), $0.audioTag(for: .urdu)] })
        XCTAssertEqual(MiracleAudioPlayer.readyTags, expected, "every story needs a complete narration pack in both languages")
    }

    func testGroupsFollowTheBook() throws {
        let data = try load()
        var order: [String] = []
        for story in data.stories where !order.contains(story.figure.en) { order.append(story.figure.en) }
        XCTAssertEqual(order.first, "Sayyida Fatima")
        XCTAssertEqual(order.count, Set(data.stories.map(\.figure.en)).count)
    }
}
