//
//  QuranSearchEngine.swift
//  Thaqalayn
//
//  Pure, UI-free search over surahs, verses (English translation and Arabic),
//  passage titles and Quick Overview "themes". Built once, off the main thread,
//  from DataManager.availableSurahs; passage titles are merged in afterwards.
//
//  Matching rules:
//  - Latin words match at the start of a word ("light" finds "lightning", never
//    "Delight"), every word must match, and exact words rank above word starts.
//  - Surah names match loosely through SearchNormalizer.nameKey plus curated
//    aliases ("fatiha", "baqarah", "yasin", "kausar").
//  - "2:255", "2 255" and "baqara 255" are references; well-known verse names
//    ("Ayat al-Kursi") resolve to their verse. Both become the top hit.
//  - Arabic input is folded (no harakat, one alef) and matched as a substring.
//  - Islamic terms and prophet names reach the translation's words through
//    QuranSearchAliases ("sabr" -> patience, "Musa" -> Moses).
//

import Foundation

// MARK: - Index

struct QuranSearchIndex {
    struct SurahEntry {
        let number: Int
        let englishName: String
        let versesCount: Int
        let key: String
        let fullKey: String
        let aliasKeys: [String]
        let aliasFullKeys: [String]
        let meaningText: String
        let arabicName: String
    }
    struct VerseEntry {
        let surahNumber: Int
        let verseNumber: Int
        let surahEnglishName: String
        let translation: String
        let text: String
        let arabic: String
        let arabicText: String
    }
    struct ThemeRef: Hashable {
        let surahNumber: Int
        let verseNumber: Int
        let surahEnglishName: String
        let conceptId: String
    }
    struct ThemeGroup {
        let title: String
        let colorHex: String
        let text: String
        var refs: [ThemeRef]
    }
    struct PassageEntry {
        let surahNumber: Int
        let surahEnglishName: String
        let index: Int
        let start: Int
        let end: Int
        let title: String
        let text: String
    }
    struct NamedVerseEntry {
        let surah: Int
        let verse: Int
        let name: String
        let keys: [String]
        let tokenSets: [Set<String>]
    }

    let surahs: [SurahEntry]
    let verses: [VerseEntry]
    let themes: [ThemeGroup]
    /// Filled in after launch by `withPassages(_:)`; empty until then.
    private(set) var passages: [PassageEntry] = []
    let namedVerses: [NamedVerseEntry]
    /// Position of each surah's first verse in `verses`.
    private let verseStart: [Int: Int]

    init(surahs source: [SurahWithTafsir]) {
        var surahE: [SurahEntry] = []
        var verseE: [VerseEntry] = []
        var starts: [Int: Int] = [:]
        var themeE: [ThemeGroup] = []
        var themeSlot: [String: Int] = [:]

        for swt in source {
            let s = swt.surah
            let aliases = QuranSearchAliases.surahAliases[s.number] ?? []
            surahE.append(SurahEntry(
                number: s.number,
                englishName: s.englishName,
                versesCount: s.versesCount,
                key: SearchNormalizer.nameKey(s.englishName),
                fullKey: SearchNormalizer.fullNameKey(s.englishName),
                aliasKeys: aliases.map(SearchNormalizer.nameKey),
                aliasFullKeys: aliases.map(SearchNormalizer.fullNameKey),
                meaningText: SearchNormalizer.latinText(s.englishNameTranslation),
                arabicName: SearchNormalizer.arabicSurahName(s.arabicName)
            ))
            starts[s.number] = verseE.count
            for v in swt.verses {
                verseE.append(VerseEntry(
                    surahNumber: s.number,
                    verseNumber: v.number,
                    surahEnglishName: s.englishName,
                    translation: v.translation,
                    text: SearchNormalizer.latinText(v.translation),
                    arabic: v.arabicText,
                    arabicText: " " + SearchNormalizer.arabic(v.arabicText) + " "
                ))
                for c in v.tafsir?.quickOverview?.concepts ?? [] {
                    let text = SearchNormalizer.latinText(c.title)
                    let ref = ThemeRef(surahNumber: s.number, verseNumber: v.number,
                                       surahEnglishName: s.englishName, conceptId: c.id)
                    if let slot = themeSlot[text] {
                        themeE[slot].refs.append(ref)
                    } else {
                        themeSlot[text] = themeE.count
                        themeE.append(ThemeGroup(title: c.title, colorHex: c.colorHex, text: text, refs: [ref]))
                    }
                }
            }
        }

        self.surahs = surahE
        self.verses = verseE
        self.verseStart = starts
        self.themes = themeE
        self.namedVerses = QuranSearchAliases.namedVerses.map { nv in
            NamedVerseEntry(
                surah: nv.surah, verse: nv.verse, name: nv.name,
                keys: nv.aliases.map(SearchNormalizer.nameKey),
                tokenSets: nv.aliases.map { QuranSearchEngine.distinctiveTokens(of: $0) }
            )
        }
    }

    /// A copy carrying the given passage titles.
    func withPassages(_ passages: [PassageEntry]) -> QuranSearchIndex {
        var copy = self
        copy.passages = passages
        return copy
    }

    func surah(_ number: Int) -> SurahEntry? {
        guard number >= 1, number <= surahs.count, surahs[number - 1].number == number else {
            return surahs.first { $0.number == number }
        }
        return surahs[number - 1]
    }

    func verse(_ surah: Int, _ verse: Int) -> VerseEntry? {
        guard let start = verseStart[surah] else { return nil }
        let i = start + verse - 1
        guard verses.indices.contains(i), verses[i].surahNumber == surah, verses[i].verseNumber == verse else {
            return nil
        }
        return verses[i]
    }

    /// Indices of one surah's verses in `verses`.
    func verseRange(ofSurah surah: Int) -> Range<Int> {
        guard let start = verseStart[surah], let entry = self.surah(surah) else { return 0..<0 }
        return start..<min(start + entry.versesCount, verses.count)
    }

    // MARK: Passage titles

    private struct PassageTitleRecord: Decodable {
        struct Title: Decodable { let en: String }
        let surah: Int
        let index: Int
        let range: [Int]
        let title: Title
    }

    /// Reads the title and range of every shipped passage (passages_<n>.json).
    /// Decodes only those fields; call off the main thread.
    static func loadPassageEntries(surahNames: [Int: String], bundle: Bundle = .main) -> [PassageEntry] {
        var entries: [PassageEntry] = []
        for surah in 1...114 {
            guard let url = bundle.url(forResource: "passages_\(surah)", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let records = try? JSONDecoder().decode([String: PassageTitleRecord].self, from: data) else {
                continue
            }
            for r in records.values.sorted(by: { $0.index < $1.index }) where r.range.count == 2 {
                entries.append(PassageEntry(
                    surahNumber: r.surah,
                    surahEnglishName: surahNames[r.surah] ?? "",
                    index: r.index, start: r.range[0], end: r.range[1],
                    title: r.title.en,
                    text: SearchNormalizer.latinText(r.title.en)
                ))
            }
        }
        return entries
    }
}

// MARK: - Results

struct TopHit: Equatable {
    let surahNumber: Int
    let verseNumber: Int
    let surahEnglishName: String
    /// Well-known name ("Ayat al-Kursi"); nil for a typed reference.
    let name: String?
    let preview: String
}

struct SurahHit: Identifiable, Equatable {
    let number: Int
    var id: Int { number }
}

struct VerseHit: Identifiable, Equatable {
    let surahNumber: Int
    let verseNumber: Int
    let surahEnglishName: String
    let snippet: String
    let highlights: [NSRange]
    /// The snippet is the Arabic text (an Arabic query).
    let isArabic: Bool
    /// The English translation shown under an Arabic snippet.
    let translation: String?
    var id: String { "\(surahNumber):\(verseNumber)" }
}

struct PassageHit: Identifiable, Equatable {
    let surahNumber: Int
    let surahEnglishName: String
    let index: Int
    let start: Int
    let end: Int
    let title: String
    var id: String { "\(surahNumber)#\(index)" }
}

struct ThemeHit: Identifiable, Equatable {
    let title: String
    let colorHex: String
    let refs: [QuranSearchIndex.ThemeRef]
    var id: String { title }
}

struct QuranSearchResults: Equatable {
    var topHit: TopHit?
    var surahs: [SurahHit] = []
    var verses: [VerseHit] = []
    var passages: [PassageHit] = []
    var themes: [ThemeHit] = []
    var isEmpty: Bool { topHit == nil && surahs.isEmpty && verses.isEmpty && passages.isEmpty && themes.isEmpty }
}

// MARK: - Engine

enum QuranSearchEngine {
    /// Verses, passages and themes need at least this many letters.
    static let minTextQueryLength = 2

    static let stopWords: Set<String> = ["the", "of", "and", "a", "an", "in", "on", "to", "is", "for", "by", "with", "o"]

    // MARK: Query

    /// One query word with the forms it may match.
    struct Term {
        let token: String
        /// Match at a word start: the word itself and its English expansions.
        let prefixForms: [String]
        /// Match as whole words only: name equivalents and reverse term mappings.
        let wholeForms: [String]
    }

    private struct Vocabulary {
        var expansions: [String: [String]] = [:]
        var equivalents: [String: [String]] = [:]
        var reverse: [String: [String]] = [:]
    }

    private static let vocabulary: Vocabulary = {
        var v = Vocabulary()
        for (term, words) in QuranSearchAliases.termExpansions {
            let key = SearchNormalizer.nameKey(term)
            let folded = words.map { SearchNormalizer.tokens($0).joined(separator: " ") }
            v.expansions[key, default: []].append(contentsOf: folded)
            let termWord = SearchNormalizer.tokens(term).joined(separator: " ")
            for w in folded where !w.contains(" ") {
                v.reverse[w, default: []].append(termWord)
            }
        }
        for group in QuranSearchAliases.equivalentNames {
            for name in group {
                let others = group.filter { $0 != name }
                v.equivalents[name, default: []].append(contentsOf: others)
                v.equivalents[SearchNormalizer.squash(name), default: []].append(contentsOf: others)
            }
        }
        return v
    }()

    static func term(for token: String) -> Term {
        let key = SearchNormalizer.squash(token)
        let v = vocabulary
        let expansions = v.expansions[key] ?? []
        var whole = v.equivalents[token] ?? v.equivalents[key] ?? []
        whole += v.reverse[token] ?? []
        return Term(
            token: token,
            prefixForms: [token] + expansions.filter { $0 != token },
            wholeForms: Array(Set(whole.filter { $0 != token }))
        )
    }

    /// Tokens of a named-verse alias that aren't generic ("verse", "ayat").
    static func distinctiveTokens(of text: String) -> Set<String> {
        Set(SearchNormalizer.tokens(text)
            .filter { !QuranSearchAliases.genericNamedVerseWords.contains($0) }
            .map(SearchNormalizer.squash))
    }

    /// Parsed query shared by every section.
    struct Query {
        let raw: String
        let isArabic: Bool
        let tokens: [String]
        let terms: [Term]
        /// All tokens, stop words included, for exact-phrase matching.
        let phrase: String?
        let arabic: String
    }

    static func parse(_ raw: String) -> Query {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let isArabic = SearchNormalizer.containsArabic(trimmed)
        let tokens = SearchNormalizer.tokens(trimmed)
        let meaningful = tokens.filter { !stopWords.contains($0) }
        let used = meaningful.isEmpty ? tokens : meaningful
        var terms = isArabic ? [] : used.map(term(for:))
        // A multi-word term ("ahl al-bayt", "ruh al-qudus") reads as one term.
        if !isArabic, tokens.count > 1,
           let expansions = vocabulary.expansions[SearchNormalizer.nameKey(trimmed)] {
            let joined = tokens.joined(separator: " ")
            terms = [Term(token: joined, prefixForms: [joined] + expansions, wholeForms: [])]
        }
        return Query(
            raw: trimmed,
            isArabic: isArabic,
            tokens: tokens,
            terms: terms,
            phrase: tokens.count >= 2 ? tokens.joined(separator: " ") : nil,
            arabic: isArabic ? SearchNormalizer.arabic(trimmed) : ""
        )
    }

    // MARK: Search

    /// `scope` limits the search to one surah's verses (Find in this surah).
    static func search(_ raw: String, in index: QuranSearchIndex, scope: Int? = nil) -> QuranSearchResults {
        let query = parse(raw)
        guard !query.raw.isEmpty else { return QuranSearchResults() }
        var results = QuranSearchResults()

        if let scope {
            results.verses = verseHits(query, in: index, scope: scope, named: [])
            return results
        }

        let named = namedVerseMatches(query, in: index)
        if let ref = reference(in: query.raw, index: index) {
            results.topHit = topHit(surah: ref.surah, verse: ref.verse, name: nil, in: index)
        } else if let first = named.first {
            results.topHit = topHit(surah: first.surah, verse: first.verse, name: first.name, in: index)
        }

        results.surahs = surahHits(query, in: index)

        let letters = query.raw.filter { $0.isLetter }.count
        guard letters >= minTextQueryLength else { return results }

        results.verses = verseHits(query, in: index, scope: nil, named: named)
        if !query.isArabic {
            results.passages = passageHits(query, in: index)
            results.themes = themeHits(query, in: index)
        }
        return results
    }

    // MARK: References

    struct Reference: Equatable { let surah: Int; let verse: Int }

    private static let refPattern = try! NSRegularExpression(
        pattern: #"^\s*(\d{1,3})\s*[:.,\s]\s*(\d{1,3})(?:\s*[-–]\s*\d{1,3})?\s*$"#)

    /// "2:255", "2 255", "2.255", "2:255-257" (opens at 255), or a surah name
    /// followed by a verse number ("baqara 255"). Validated against the index.
    static func reference(in raw: String, index: QuranSearchIndex) -> Reference? {
        let text = SearchNormalizer.foldDigits(raw)
        let ns = text as NSString
        if let m = refPattern.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)),
           let s = Int(ns.substring(with: m.range(at: 1))),
           let v = Int(ns.substring(with: m.range(at: 2))) {
            return valid(s, v, in: index)
        }
        let tokens = SearchNormalizer.tokens(text)
        guard tokens.count >= 2, let v = Int(tokens.last!), tokens.dropLast().allSatisfy({ Int($0) == nil }) else {
            return nil
        }
        let nameKey = SearchNormalizer.nameKey(tokens.dropLast().joined(separator: " "))
        guard !nameKey.isEmpty else { return nil }
        let exact = index.surahs.first { $0.key == nameKey || $0.aliasKeys.contains(nameKey) }
        let prefixed = index.surahs.filter { $0.key.hasPrefix(nameKey) || $0.aliasKeys.contains { $0.hasPrefix(nameKey) } }
        guard let surah = exact ?? (prefixed.count == 1 ? prefixed.first : nil) else { return nil }
        return valid(surah.number, v, in: index)
    }

    private static func valid(_ s: Int, _ v: Int, in index: QuranSearchIndex) -> Reference? {
        guard let entry = index.surah(s), v >= 1, v <= entry.versesCount else { return nil }
        return Reference(surah: s, verse: v)
    }

    private static func topHit(surah: Int, verse: Int, name: String?, in index: QuranSearchIndex) -> TopHit? {
        guard let entry = index.verse(surah, verse) else { return nil }
        return TopHit(surahNumber: surah, verseNumber: verse, surahEnglishName: entry.surahEnglishName,
                      name: name, preview: entry.translation)
    }

    /// Named verses the query names: the whole query spells an alias (or its
    /// start, from four letters), or its distinctive words cover all of an
    /// alias's distinctive words ("light" -> "Light Verse", "throne" -> "Throne Verse").
    static func namedVerseMatches(_ query: Query, in index: QuranSearchIndex) -> [QuranSearchIndex.NamedVerseEntry] {
        guard !query.isArabic else { return [] }
        let key = SearchNormalizer.nameKey(query.raw)
        guard key.count >= 3 else { return [] }
        let qTokens = distinctiveTokens(of: query.raw)
        // A known term ("salah") is a word in its own right, not the start of a
        // longer verse name ("Salawat"), so it only matches names exactly.
        let v = vocabulary
        let isKnownTerm = v.expansions[key] != nil || v.equivalents[key] != nil
        var exact: [QuranSearchIndex.NamedVerseEntry] = []
        var loose: [QuranSearchIndex.NamedVerseEntry] = []
        for nv in index.namedVerses {
            // A query of only generic words ("ayat", "verse") names nothing loosely.
            if nv.keys.contains(key) {
                exact.append(nv)
            } else if !qTokens.isEmpty,
                      (key.count >= 5 && !isKnownTerm && nv.keys.contains { $0.hasPrefix(key) })
                        || nv.tokenSets.contains(where: { !$0.isEmpty && $0.isSubset(of: qTokens) }) {
                loose.append(nv)
            }
        }
        return exact + loose
    }

    // MARK: Surahs

    static func surahHits(_ query: Query, in index: QuranSearchIndex) -> [SurahHit] {
        let digits = SearchNormalizer.foldDigits(query.raw)
        if let n = Int(digits) {
            return (1...114).contains(n) ? [SurahHit(number: n)] : []
        }
        let key = SearchNormalizer.nameKey(query.raw)
        let fullKey = SearchNormalizer.fullNameKey(query.raw)
        let arabicQuery = query.isArabic ? SearchNormalizer.arabicSurahName(query.raw) : ""
        let letters = query.raw.filter { $0.isLetter }.count

        var scored: [(Int, Int)] = []
        for s in index.surahs {
            var score = 0
            if query.isArabic {
                if !arabicQuery.isEmpty {
                    if s.arabicName == arabicQuery { score = 100 }
                    else if s.arabicName.contains(arabicQuery) { score = 70 }
                }
            } else {
                if !key.isEmpty {
                    if s.key == key || s.aliasKeys.contains(key) {
                        score = 100
                    } else if s.key.hasPrefix(key) || s.aliasKeys.contains(where: { $0.hasPrefix(key) }) {
                        score = 70 + min(key.count, 20)
                    } else if !fullKey.isEmpty,
                              s.fullKey.hasPrefix(fullKey) || s.aliasFullKeys.contains(where: { $0.hasPrefix(fullKey) }) {
                        score = 60
                    }
                }
                if score == 0, letters >= minTextQueryLength, !query.terms.isEmpty {
                    if let m = matchScore(query.terms, in: s.meaningText) { score = 30 + min(m, 20) }
                }
            }
            if score > 0 { scored.append((s.number, score)) }
        }
        return scored.sorted { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0 < $1.0 }.map { SurahHit(number: $0.0) }
    }

    // MARK: Word matching

    /// Score of one term in a folded text (" word word "), or 0 when absent.
    static func termScore(_ term: Term, in text: String) -> Int {
        var best = 0
        if text.contains(" " + term.token + " ") { return 10 }
        if text.contains(" " + term.token) { best = 6 }
        for form in term.prefixForms.dropFirst() {
            if text.contains(" " + form + " ") { best = max(best, 8) }
            else if text.contains(" " + form) { best = max(best, 5) }
        }
        for form in term.wholeForms where text.contains(" " + form + " ") {
            best = max(best, 8)
        }
        return best
    }

    /// Sum of term scores when every term matches, else nil.
    static func matchScore(_ terms: [Term], in text: String) -> Int? {
        var total = 0
        for term in terms {
            let s = termScore(term, in: text)
            if s == 0 { return nil }
            total += s
        }
        return total
    }

    // MARK: Verses

    static func verseHits(_ query: Query, in index: QuranSearchIndex, scope: Int?,
                          named: [QuranSearchIndex.NamedVerseEntry]) -> [VerseHit] {
        let range = scope.map { index.verseRange(ofSurah: $0) } ?? index.verses.indices
        let namedRefs = Set(named.map { "\($0.surah):\($0.verse)" })
        var scored: [(Int, Int)] = []

        if query.isArabic {
            let q = query.arabic
            guard !q.isEmpty else { return [] }
            for i in range {
                let text = index.verses[i].arabicText
                guard text.contains(q) else { continue }
                let score = text.contains(" " + q + " ") ? 10 : (text.contains(" " + q) ? 8 : 5)
                scored.append((i, score))
            }
        } else {
            guard !query.terms.isEmpty else { return [] }
            let phrase = query.phrase.map { " " + $0 }
            for i in range {
                let entry = index.verses[i]
                guard var score = matchScore(query.terms, in: entry.text) else { continue }
                if let phrase, entry.text.contains(phrase) { score += 50 }
                if namedRefs.contains("\(entry.surahNumber):\(entry.verseNumber)") { score += 100 }
                scored.append((i, score))
            }
        }

        scored.sort { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0 < $1.0 }
        return scored.map { (i, _) in
            let entry = index.verses[i]
            let (snippet, ranges) = query.isArabic
                ? arabicSnippet(entry.arabic, query: query.arabic)
                : latinSnippet(entry.translation, query: query)
            return VerseHit(surahNumber: entry.surahNumber, verseNumber: entry.verseNumber,
                            surahEnglishName: entry.surahEnglishName, snippet: snippet,
                            highlights: ranges, isArabic: query.isArabic,
                            translation: query.isArabic ? entry.translation : nil)
        }
    }

    // MARK: Passages and themes

    private static func titleScore(_ query: Query, text: String) -> Int? {
        guard var score = matchScore(query.terms, in: text) else { return nil }
        let joined = " " + query.tokens.joined(separator: " ")
        if text == joined + " " { score += 100 }
        else if text.hasPrefix(joined) { score += 60 }
        else if let phrase = query.phrase, text.contains(" " + phrase) { score += 30 }
        return score
    }

    static func passageHits(_ query: Query, in index: QuranSearchIndex) -> [PassageHit] {
        guard !query.terms.isEmpty else { return [] }
        var scored: [(Int, Int)] = []
        for (i, p) in index.passages.enumerated() {
            if let score = titleScore(query, text: p.text) { scored.append((i, score)) }
        }
        scored.sort { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0 < $1.0 }
        return scored.map { (i, _) in
            let p = index.passages[i]
            return PassageHit(surahNumber: p.surahNumber, surahEnglishName: p.surahEnglishName,
                              index: p.index, start: p.start, end: p.end, title: p.title)
        }
    }

    static func themeHits(_ query: Query, in index: QuranSearchIndex) -> [ThemeHit] {
        guard !query.terms.isEmpty else { return [] }
        var scored: [(Int, Int)] = []
        for (i, g) in index.themes.enumerated() {
            if let score = titleScore(query, text: g.text) { scored.append((i, score)) }
        }
        scored.sort { a, b in
            if a.1 != b.1 { return a.1 > b.1 }
            let ra = index.themes[a.0].refs.count, rb = index.themes[b.0].refs.count
            if ra != rb { return ra > rb }
            return a.0 < b.0
        }
        return scored.map { (i, _) in
            let g = index.themes[i]
            return ThemeHit(title: g.title, colorHex: g.colorHex, refs: g.refs)
        }
    }

    // MARK: Snippets

    /// Word ranges in `text` to highlight for a Latin query: the exact phrase when
    /// present, else every word matching a term.
    static func latinHighlights(in text: String, query: Query) -> [NSRange] {
        let words = SearchNormalizer.words(in: text)
        if query.tokens.count >= 2 {
            let p = query.tokens
            var i = 0
            var spans: [NSRange] = []
            while i + p.count <= words.count {
                var ok = true
                for j in 0..<p.count {
                    let w = words[i + j].folded
                    if j == p.count - 1 ? !w.hasPrefix(p[j]) : w != p[j] { ok = false; break }
                }
                if ok {
                    let first = words[i].range, last = words[i + p.count - 1].range
                    spans.append(NSRange(location: first.location,
                                         length: last.location + last.length - first.location))
                    i += p.count
                } else {
                    i += 1
                }
            }
            if !spans.isEmpty { return spans }
        }
        return words.filter { w in
            query.terms.contains { t in
                t.prefixForms.contains { !$0.contains(" ") && w.folded.hasPrefix($0) }
                    || t.wholeForms.contains(w.folded)
            }
        }.map(\.range)
    }

    static func latinSnippet(_ text: String, query: Query) -> (String, [NSRange]) {
        window(text, highlights: latinHighlights(in: text, query: query), before: 45, after: 85)
    }

    /// Every occurrence of the folded query in the Arabic text, mapped back onto
    /// the original (with its harakat) through SearchNormalizer.arabicWithMap.
    static func arabicHighlights(in text: String, query: String) -> [NSRange] {
        let (folded, offsets) = SearchNormalizer.arabicWithMap(text)
        let foldedNS = folded as NSString
        let original = text as NSString
        var ranges: [NSRange] = []
        var search = NSRange(location: 0, length: foldedNS.length)
        while search.length > 0 {
            let r = foldedNS.range(of: query, options: [], range: search)
            guard r.location != NSNotFound, r.length > 0 else { break }
            let startIdx = r.location, endIdx = r.location + r.length - 1
            guard endIdx < offsets.count else { break }
            let start = offsets[startIdx]
            var end = offsets[endIdx] + 1
            // Carry the harakat that follow the last matched letter.
            while end < original.length {
                let unit = UInt32(original.character(at: end))
                let isMark = (0x064B...0x065F).contains(unit) || unit == 0x0670 || (0x06D6...0x06ED).contains(unit)
                if !isMark { break }
                end += 1
            }
            ranges.append(NSRange(location: start, length: end - start))
            let next = r.location + r.length
            search = NSRange(location: next, length: foldedNS.length - next)
        }
        return ranges
    }

    static func arabicSnippet(_ text: String, query: String) -> (String, [NSRange]) {
        let clean = text.replacingOccurrences(of: "\u{FEFF}", with: "")
        // Wider than the English window: harakat take up UTF-16 units too.
        return window(clean, highlights: arabicHighlights(in: clean, query: query), before: 90, after: 160)
    }

    /// A window of `text` around the first highlight, widened to word boundaries,
    /// with ellipses where clipped and the highlights shifted into it.
    static func window(_ text: String, highlights: [NSRange], before: Int, after: Int) -> (String, [NSRange]) {
        let ns = text as NSString
        guard let first = highlights.first else {
            if ns.length <= before + after { return (text, []) }
            return (trimmedEnd(ns, to: before + after) + "\u{2026}", [])
        }
        var start = max(0, first.location - before)
        var end = min(ns.length, first.location + first.length + after)
        let space = CharacterSet.whitespaces
        func isSpace(_ i: Int) -> Bool {
            guard let s = Unicode.Scalar(ns.character(at: i)) else { return false }
            return space.contains(s)
        }
        if start > 0 {
            while start < first.location, !isSpace(start - 1) { start += 1 }
        }
        if end < ns.length {
            while end > first.location + first.length, !isSpace(end) { end -= 1 }
        }
        // start now follows a space and end sits on one, so the core carries no
        // edge whitespace and highlight offsets only shift by the prefix.
        let core = ns.substring(with: NSRange(location: start, length: end - start))
        let prefix = start > 0 ? "\u{2026}" : ""
        let suffix = end < ns.length ? "\u{2026}" : ""
        let shift = (prefix as NSString).length - start
        let shifted = highlights.compactMap { r -> NSRange? in
            guard r.location >= start, r.location + r.length <= end else { return nil }
            return NSRange(location: r.location + shift, length: r.length)
        }
        return (prefix + core + suffix, shifted)
    }

    private static func trimmedEnd(_ ns: NSString, to length: Int) -> String {
        var end = min(length, ns.length)
        while end > 0, let s = Unicode.Scalar(ns.character(at: end - 1)), !CharacterSet.whitespaces.contains(s) {
            end -= 1
        }
        return ns.substring(to: end > 0 ? end : min(length, ns.length)).trimmingCharacters(in: .whitespaces)
    }
}
