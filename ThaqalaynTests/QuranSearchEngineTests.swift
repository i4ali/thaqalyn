// ThaqalaynTests/QuranSearchEngineTests.swift
//
// The Quran-tab search against the real bundled data: one case per problem the
// 2026-09-30 search audit found (misspelled surah names, references, Arabic,
// Islamic terms, word-start matching, ranking, theme grouping).

import XCTest
@testable import Thaqalayn

final class QuranSearchEngineTests: XCTestCase {

    /// Built once for the whole class, the way DataManager builds it.
    private static var cachedIndex: QuranSearchIndex?

    private func index() throws -> QuranSearchIndex {
        if let cached = Self.cachedIndex { return cached }
        let url = try XCTUnwrap(Bundle.main.url(forResource: "quran_data", withExtension: "json"))
        let quran = try JSONDecoder().decode(QuranData.self, from: Data(contentsOf: url))
        var surahs: [SurahWithTafsir] = []
        for surah in quran.surahs {
            var tafsir: [String: TafsirVerse] = [:]
            if let tUrl = Bundle.main.url(forResource: "tafsir_\(surah.number)", withExtension: "json"),
               let decoded = try? JSONDecoder().decode([String: TafsirVerse].self, from: Data(contentsOf: tUrl)) {
                tafsir = decoded
            }
            let verses = (1...surah.versesCount).compactMap { i -> VerseWithTafsir? in
                guard let v = quran.verses[String(surah.number)]?[String(i)] else { return nil }
                return VerseWithTafsir(number: i, verse: v, tafsir: tafsir[String(i)])
            }
            surahs.append(SurahWithTafsir(surah: surah, verses: verses))
        }
        let names = Dictionary(uniqueKeysWithValues: quran.surahs.map { ($0.number, $0.englishName) })
        let built = QuranSearchIndex(surahs: surahs)
            .withPassages(QuranSearchIndex.loadPassageEntries(surahNames: names))
        Self.cachedIndex = built
        return built
    }

    private func search(_ q: String) throws -> QuranSearchResults {
        QuranSearchEngine.search(q, in: try index())
    }

    private func refs(_ hits: [VerseHit]) -> [String] { hits.map(\.id) }

    // MARK: - Normalizer

    func testNameKeys() {
        XCTAssertEqual(SearchNormalizer.nameKey("Al-Faatiha"), "fatiha")
        XCTAssertEqual(SearchNormalizer.nameKey("fatihah"), "fatiha")
        XCTAssertEqual(SearchNormalizer.nameKey("Yaseen"), "yasin")
        XCTAssertEqual(SearchNormalizer.nameKey("ya sin"), "yasin")
        XCTAssertEqual(SearchNormalizer.nameKey("Al-Baqara"), SearchNormalizer.nameKey("baqarah"))
        XCTAssertEqual(SearchNormalizer.nameKey("al baqara"), "baqara")
        XCTAssertEqual(SearchNormalizer.nameKey("Aal-i-Imraan"), "imran")
        XCTAssertEqual(SearchNormalizer.nameKey("Ayatul Kursi"), SearchNormalizer.nameKey("Ayat al-Kursi"))
    }

    func testLatinAndArabicFolding() {
        XCTAssertEqual(SearchNormalizer.latinText("the Ka\u{2018}bah's - All-merciful."), " the kabahs all merciful ")
        XCTAssertEqual(SearchNormalizer.arabic("سُورَةُ البَقَرَةِ"), "سوره البقره")
        XCTAssertEqual(SearchNormalizer.arabicSurahName("سُورَةُ ٱلْفَاتِحَةِ"), "الفاتحه")
        XCTAssertEqual(SearchNormalizer.arabic("\u{FEFF}بِسْمِ ٱللَّهِ"), "بسم الله")
        XCTAssertTrue(SearchNormalizer.containsArabic("سورة"))
        XCTAssertFalse(SearchNormalizer.containsArabic("surah"))
    }

    // MARK: - Finding 1: surah names in any common spelling

    func testSurahSpellings() throws {
        let cases: [(String, Int)] = [
            ("fatiha", 1), ("Fatihah", 1), ("baqarah", 2), ("al baqara", 2), ("Al-Baqara", 2),
            ("al imran", 3), ("yasin", 36), ("ya sin", 36), ("yaseen", 36), ("rahman", 55),
            ("ikhlas", 112), ("waqiah", 56), ("kausar", 108), ("kawthar", 108), ("tawbah", 9),
            ("mulk", 67), ("kahf", 18), ("nur", 24), ("noor", 24), ("hajj", 22), ("muminun", 23),
        ]
        for (q, expected) in cases {
            XCTAssertEqual(try search(q).surahs.first?.number, expected, "query \(q)")
        }
    }

    func testTypingYasinNeverLosesYaseen() throws {
        for q in ["y", "ya", "yas", "yasi", "yasin"] {
            XCTAssertTrue(try search(q).surahs.contains { $0.number == 36 }, "query \(q)")
        }
    }

    // MARK: - Finding 2: references and named verses

    func testReferences() throws {
        for q in ["2:255", "2 255", "2.255", "2:255-257", "baqara 255", "Al-Baqara 255", "\u{0662}:\u{0662}\u{0665}\u{0665}"] {
            let top = try search(q).topHit
            XCTAssertEqual(top?.surahNumber, 2, "query \(q)")
            XCTAssertEqual(top?.verseNumber, 255, "query \(q)")
        }
        XCTAssertNil(try search("2:999").topHit)
        XCTAssertEqual(try search("36").surahs.first?.number, 36)
        XCTAssertTrue(try search("200").surahs.isEmpty)
    }

    func testNamedVerses() throws {
        let cases: [(String, Int, Int)] = [
            ("ayat al kursi", 2, 255), ("ayatul kursi", 2, 255), ("kursi", 2, 255), ("throne verse", 2, 255),
            ("ayat al tathir", 33, 33), ("mubahala", 3, 61), ("light verse", 24, 35), ("wilayah verse", 5, 55),
        ]
        for (q, s, v) in cases {
            let top = try search(q).topHit
            XCTAssertEqual(top?.surahNumber, s, "query \(q)")
            XCTAssertEqual(top?.verseNumber, v, "query \(q)")
            XCTAssertNotNil(top?.name, "query \(q)")
        }
        XCTAssertNil(try search("salah").topHit, "a term is not the start of Ayat al-Salawat")
        XCTAssertEqual(try search("salawat").topHit?.verseNumber, 56)
        XCTAssertNil(try search("ayat").topHit, "a generic word names no verse")
        XCTAssertNil(try search("verse").topHit, "a generic word names no verse")
    }

    // MARK: - Finding 3: Arabic

    func testArabicSurahNames() throws {
        XCTAssertEqual(try search("البقرة").surahs.first?.number, 2)
        XCTAssertEqual(try search("الكهف").surahs.first?.number, 18)
        XCTAssertEqual(try search("سورة يس").surahs.first?.number, 36)
        XCTAssertEqual(try search("مريم").surahs.first?.number, 19)
    }

    func testArabicVerseText() throws {
        let r = try search("الصمد")
        let hit = try XCTUnwrap(r.verses.first { $0.id == "112:2" })
        XCTAssertTrue(hit.isArabic)
        let highlighted = (hit.snippet as NSString).substring(with: try XCTUnwrap(hit.highlights.first))
        XCTAssertEqual(SearchNormalizer.arabic(highlighted), "الصمد")
    }

    // MARK: - Finding 4: Islamic terms, prophet names, passages

    func testTermsReachTranslationWords() throws {
        XCTAssertTrue(refs(try search("sabr").verses).contains("2:153"))
        let musa = try search("musa").verses
        XCTAssertGreaterThan(musa.count, 100)
        XCTAssertTrue(refs(musa).contains("7:143"))
        XCTAssertGreaterThan(try search("salah").verses.count, 50)
        XCTAssertTrue(refs(try search("ahl al-bayt").verses).contains("33:33"))
        // "isa" reaches Jesus as a whole word, ranked above "Isaac" word-start hits.
        let isa = try XCTUnwrap(try search("isa").verses.first)
        XCTAssertTrue(try index().verse(isa.surahNumber, isa.verseNumber)!.text.contains(" jesus "))
    }

    func testPassageTitles() throws {
        let idx = try index()
        XCTAssertGreaterThan(idx.passages.count, 400)
        let hit = try XCTUnwrap(try search("adam's two sons").passages.first)
        XCTAssertEqual(hit.surahNumber, 5)
        XCTAssertEqual(hit.start, 27)
    }

    // MARK: - Findings 6 and 7: word starts and ranking

    func testWordStartMatching() throws {
        let r = try search("light")
        XCTAssertEqual(r.verses.first?.id, "24:35", "the Light Verse ranks first")
        let folded = r.themes.map { SearchNormalizer.latinText($0.title) }
        XCTAssertFalse(folded.contains { $0.contains(" delight") || $0.contains(" flight") || $0.contains("enlight") })
        XCTAssertTrue(folded.allSatisfy { $0.contains(" light") || $0.contains(" nur") })

        let idx = try index()
        let man = try search("man").verses
        XCTAssertTrue(man.allSatisfy { hit in
            idx.verse(hit.surahNumber, hit.verseNumber)!.text.contains(" man")
        }, "'man' never matches inside 'woman' or 'command'")
    }

    func testEnglishWordsDoNotReachOtherWords() throws {
        // "mercy" is not a word start of "merciful"; its only extra reach is the
        // whole word "rahmah"/"rahma" (reverse of the term list).
        let idx = try index()
        let hits = try search("mercy").verses
        XCTAssertFalse(hits.isEmpty)
        XCTAssertTrue(hits.allSatisfy { hit in
            let text = idx.verse(hit.surahNumber, hit.verseNumber)!.text
            return text.contains(" mercy") || text.contains(" rahmah ") || text.contains(" rahma ")
        })
    }

    func testExactPhraseRanksFirst() throws {
        let verses = try search("darkness into light").verses
        let phraseVerses = ["2:257", "5:16", "14:1", "14:5", "33:43", "57:9", "65:11"]
        XCTAssertEqual(Set(refs(Array(verses.prefix(7)))), Set(phraseVerses))
    }

    func testHighlightsAreMatchedWords() throws {
        let hit = try XCTUnwrap(try search("light").verses.first)
        XCTAssertFalse(hit.highlights.isEmpty)
        for r in hit.highlights {
            let word = (hit.snippet as NSString).substring(with: r).lowercased()
            XCTAssertTrue(word.hasPrefix("light"), word)
        }
    }

    // MARK: - Findings 8 to 10: sizes and grouping

    func testNoCapsOnResults() throws {
        // Every verse with a word starting "light" (60 in the bundled translation), uncapped.
        XCTAssertEqual(try search("light").verses.count, 60)
    }

    func testThemesAreGrouped() throws {
        let themes = try search("divine light").themes
        let group = try XCTUnwrap(themes.first)
        XCTAssertEqual(group.title.lowercased(), "divine light")
        XCTAssertGreaterThanOrEqual(group.refs.count, 2)
        XCTAssertEqual(Set(themes.map { $0.title.lowercased() }).count, themes.count, "one row per title")
    }

    func testSingleLetterMatchesOnlySurahNames() throws {
        let r = try search("y")
        XCTAssertEqual(Set(r.surahs.map(\.number)), [10, 12, 36])
        XCTAssertTrue(r.verses.isEmpty)
        XCTAssertTrue(r.themes.isEmpty)
    }

    // MARK: - Finding 17: Find in this Surah

    func testScopedSearch() throws {
        let hits = QuranSearchEngine.search("light", in: try index(), scope: 24).verses
        XCTAssertFalse(hits.isEmpty)
        XCTAssertTrue(hits.allSatisfy { $0.surahNumber == 24 })
        XCTAssertTrue(refs(hits).contains("24:35"))
    }
}
