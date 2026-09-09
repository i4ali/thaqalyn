// ThaqalaynTests/BookmarkModelTests.swift
//
// Model-level coverage for passage bookmarks. Deliberately never touches
// BookmarkManager.shared: its storage is the simulator's UserDefaults and
// clearing it would wipe real bookmarks and could trigger a cloud sync.
import XCTest
@testable import Thaqalayn

final class BookmarkModelTests: XCTestCase {
    private func verse(_ surah: Int, _ verse: Int, createdAt: Date = Date(timeIntervalSince1970: 0)) -> Bookmark {
        Bookmark(userId: "u", surahNumber: surah, verseNumber: verse, surahName: "S",
                 verseText: "ar", verseTranslation: "en", createdAt: createdAt)
    }

    private func passage(_ surah: Int, index: Int, start: Int, createdAt: Date = Date(timeIntervalSince1970: 0)) -> Bookmark {
        Bookmark(userId: "u", surahNumber: surah, verseNumber: start, surahName: "S",
                 verseText: "ar", verseTranslation: "Title", createdAt: createdAt, passageIndex: index)
    }

    // The exact shape sitting in users' UserDefaults from before passage bookmarks:
    // twelve keys, dates as the encoder's default seconds since 2001.
    func testDecodesLegacyRecordWithoutPassageIndex() throws {
        let legacy = """
        {"id":"6BA7B810-9DAD-11D1-80B4-00C04FD430C8","userId":"u","surahNumber":2,"verseNumber":30,
         "surahName":"Al-Baqarah","verseText":"ar","verseTranslation":"en","notes":null,"tags":["a"],
         "createdAt":700000000,"updatedAt":700000000,"syncStatus":"synced"}
        """
        let decoded = try JSONDecoder().decode(Bookmark.self, from: Data(legacy.utf8))
        XCTAssertNil(decoded.passageIndex)
        XCTAssertFalse(decoded.isPassage)
        XCTAssertEqual(decoded.verseReference, "2:30")
        XCTAssertEqual(decoded.tags, ["a"])
    }

    func testRoundTripKeepsPassageIndex() throws {
        let original = passage(2, index: 4, start: 30)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Bookmark.self, from: data)
        XCTAssertEqual(decoded.passageIndex, 4)
        XCTAssertEqual(decoded.verseNumber, 30)
        XCTAssertTrue(decoded.isPassage)

        let synced = original.with(syncStatus: .synced)
        XCTAssertEqual(synced.passageIndex, 4)
        XCTAssertEqual(synced.syncStatus, .synced)
        XCTAssertEqual(synced.id, original.id)

        let edited = original.with(syncStatus: .pendingSync, notes: "n", tags: ["t"], updatedAt: Date(timeIntervalSince1970: 5))
        XCTAssertEqual(edited.notes, "n")
        XCTAssertEqual(edited.tags, ["t"])
        XCTAssertEqual(edited.updatedAt, Date(timeIntervalSince1970: 5))
        XCTAssertEqual(edited.passageIndex, 4)
    }

    // The Supabase client builds the upsert's `columns` list from the union of keys in
    // the batch, so a verse row may omit passage_index (it lands as NULL) while a
    // passage row carries it. This pins the encoder behaviour that relies on.
    func testDatabaseBookmarkEncodesPassageIndexOnlyWhenSet() throws {
        let id = UUID(), user = UUID(), now = Date(timeIntervalSince1970: 0)
        let verseRow = DatabaseBookmark(id: id, userId: user, surahNumber: 2, verseNumber: 30, surahName: "S",
                                        verseText: "ar", verseTranslation: "en", notes: nil, tags: [],
                                        createdAt: now, updatedAt: now, passageIndex: nil)
        let verseJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(verseRow)) as! [String: Any]
        XCTAssertNil(verseJSON["passage_index"])
        XCTAssertEqual(verseJSON["verse_number"] as? Int, 30)

        let passageRow = DatabaseBookmark(id: id, userId: user, surahNumber: 2, verseNumber: 30, surahName: "S",
                                          verseText: "ar", verseTranslation: "Title", notes: nil, tags: [],
                                          createdAt: now, updatedAt: now, passageIndex: 4)
        let passageJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(passageRow)) as! [String: Any]
        XCTAssertEqual(passageJSON["passage_index"] as? Int, 4)

        // Rows fetched for a verse bookmark carry an explicit null.
        let fetched = """
        {"id":"\(id.uuidString)","user_id":"\(user.uuidString)","surah_number":2,"verse_number":30,
         "surah_name":"S","verse_text":"ar","verse_translation":"en","notes":null,"tags":[],
         "created_at":0,"updated_at":0,"passage_index":null}
        """
        let decoded = try JSONDecoder().decode(DatabaseBookmark.self, from: Data(fetched.utf8))
        XCTAssertNil(decoded.passageIndex)
    }

    func testVerseAndPassageKeysDoNotCross() {
        let p = passage(2, index: 4, start: 30)
        XCTAssertFalse(p.matchesVerse(surah: 2, verse: 30), "a passage never lights its first verse's heart")
        XCTAssertTrue(p.matchesPassage(surah: 2, index: 4))
        XCTAssertFalse(p.matchesPassage(surah: 2, index: 5))

        let v = verse(2, 30)
        XCTAssertTrue(v.matchesVerse(surah: 2, verse: 30))
        XCTAssertFalse(v.matchesPassage(surah: 2, index: 4))
        XCTAssertFalse(v.matchesVerse(surah: 3, verse: 30))
    }

    func testQuranOrderPutsPassageBeforeItsFirstVerse() {
        let early = Date(timeIntervalSince1970: 1), late = Date(timeIntervalSince1970: 2)
        let items = [verse(2, 30), passage(2, index: 4, start: 30), verse(2, 29), verse(1, 1),
                     passage(2, index: 5, start: 40, createdAt: late), passage(2, index: 5, start: 40, createdAt: early)]
        let sorted = items.sorted(by: Bookmark.precedesInQuranOrder)
        let keys = sorted.map { "\($0.surahNumber):\($0.verseNumber)\($0.isPassage ? "p" : "")" }
        XCTAssertEqual(keys, ["1:1", "2:29", "2:30p", "2:30", "2:40p", "2:40p"])
        XCTAssertEqual(sorted[4].createdAt, early, "same passage twice falls back to save time")
    }
}
