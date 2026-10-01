//
//  SearchNormalizer.swift
//  Thaqalayn
//
//  Text folding for the Quran search. Latin text is lowercased, diacritic-folded
//  and split into words (apostrophes and ayn/hamza marks join a word, everything
//  else splits). Arabic text loses its harakat and Quranic marks and folds its
//  alef/yeh/teh-marbuta variants. `nameKey` is the looser form used to match
//  transliterated names ("Al-Faatiha", "fatihah" -> "fatiha").
//

import Foundation

enum SearchNormalizer {

    // MARK: - Latin

    /// Marks that sit inside transliterated words (Ka‘bah, Shu'ayb, Qur'an) and are
    /// dropped rather than treated as a word break.
    private static let joiningMarks: Set<Character> = ["'", "\u{2018}", "\u{2019}", "\u{02BF}", "\u{02BE}", "`", "\u{02BC}"]

    /// A word in the original text and its folded form.
    struct Word {
        let range: NSRange
        let folded: String
    }

    /// Lowercased, diacritic-folded single word with joining marks removed.
    static func fold(_ word: String) -> String {
        let stripped = String(word.filter { !joiningMarks.contains($0) })
        return foldDigits(stripped)
            .folding(options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive], locale: nil)
            .lowercased()
    }

    /// Splits `text` into words: runs of letters, digits, combining marks and
    /// joining marks. Ranges are UTF-16 ranges into `text`.
    static func words(in text: String) -> [Word] {
        var result: [Word] = []
        var start: String.Index?
        var index = text.startIndex
        func close(at end: String.Index) {
            guard let s = start else { return }
            let piece = String(text[s..<end])
            let folded = fold(piece)
            if !folded.isEmpty {
                result.append(Word(range: NSRange(s..<end, in: text), folded: folded))
            }
            start = nil
        }
        while index < text.endIndex {
            let ch = text[index]
            if isWordCharacter(ch) {
                if start == nil { start = index }
            } else {
                close(at: index)
            }
            index = text.index(after: index)
        }
        close(at: text.endIndex)
        return result
    }

    private static func isWordCharacter(_ ch: Character) -> Bool {
        if joiningMarks.contains(ch) { return true }
        return ch.isLetter || ch.isNumber || ch.unicodeScalars.allSatisfy {
            CharacterSet.nonBaseCharacters.contains($0)
        }
    }

    /// Folded words joined by single spaces, with a leading and trailing space so
    /// `contains(" " + token)` means "a word starts with token" and
    /// `contains(" " + token + " ")` means "a whole word equals token".
    /// Folds the whole string in one pass (index build runs this over every
    /// verse); the result matches joining `words(in:)`'s folded words.
    static func latinText(_ text: String) -> String {
        var out = String.UnicodeScalarView()
        out.append(" ")
        for s in fold(text).unicodeScalars {
            if CharacterSet.alphanumerics.contains(s) {
                out.append(s)
            } else if out.last != " " {
                out.append(" ")
            }
        }
        if out.last != " " { out.append(" ") }
        return String(out)
    }

    /// Folded query tokens.
    static func tokens(_ text: String) -> [String] {
        words(in: text).map(\.folded)
    }

    // MARK: - Names

    /// Leading articles and connectors dropped from transliterated names.
    private static let articleTokens: Set<String> = [
        "al", "an", "ar", "as", "at", "ad", "adh", "ash", "az", "el", "ul", "aal", "i", "e"
    ]

    /// Loose key for transliterated names: articles dropped, "ee"/"oo" read as
    /// long i/u, doubled letters collapsed, a trailing "h" dropped per word.
    /// "Al-Faatiha" and "fatihah" -> "fatiha"; "Yaseen" and "ya sin" -> "yasin".
    /// When every token is an article the tokens are kept, so typing "an" still
    /// narrows the list instead of emptying it.
    static func nameKey(_ text: String) -> String {
        let tokens = self.tokens(text)
        let kept = tokens.filter { !articleTokens.contains($0) }
        return (kept.isEmpty ? tokens : kept).map(squash).joined()
    }

    /// `nameKey` without dropping articles, used for prefix matching while the
    /// user is still typing the article ("an-n" should reach An-Nisaa).
    static func fullNameKey(_ text: String) -> String {
        tokens(text).map(squash).joined()
    }

    /// Words that fuse the Arabic article onto the word before it
    /// ("Ayatul Kursi", "Ahlul Bayt").
    private static let fusedArticles: [String: String] = [
        "ayatul": "ayat", "ayatal": "ayat", "ayatun": "ayat", "ayatur": "ayat",
        "ahlul": "ahl", "ahlal": "ahl", "ummul": "umm", "ummal": "umm", "abdul": "abd",
    ]

    /// Per-token squash shared by both name keys.
    static func squash(_ token: String) -> String {
        var t = fusedArticles[token] ?? token
        t = t.replacingOccurrences(of: "ee", with: "i")
            .replacingOccurrences(of: "oo", with: "u")
        var out = ""
        for ch in t where ch != out.last { out.append(ch) }
        if out.count > 1, out.hasSuffix("h") { out.removeLast() }
        return out
    }

    // MARK: - Arabic

    static func containsArabic(_ text: String) -> Bool {
        text.unicodeScalars.contains { (0x0600...0x06FF).contains($0.value) }
    }

    private static func isArabicMark(_ v: UInt32) -> Bool {
        (0x064B...0x065F).contains(v) || v == 0x0670 || (0x06D6...0x06ED).contains(v)
            || v == 0x0640 || v == 0xFEFF || v == 0x200F || v == 0x200E
    }

    private static func foldArabicLetter(_ v: UInt32) -> UInt32 {
        switch v {
        case 0x0623, 0x0625, 0x0622, 0x0671: return 0x0627 // أ إ آ ٱ -> ا
        case 0x0649: return 0x064A                         // ى -> ي
        case 0x0629: return 0x0647                         // ة -> ه
        case 0x0624: return 0x0648                         // ؤ -> و
        case 0x0626: return 0x064A                         // ئ -> ي
        default: return v
        }
    }

    /// Arabic with marks stripped and letter variants folded, plus, for each
    /// scalar of the result, the UTF-16 offset of its source scalar in `text`.
    /// Whitespace runs collapse to one space. Folded scalars are all in the BMP,
    /// so an NSRange in the folded string indexes the offsets array directly.
    static func arabicWithMap(_ text: String) -> (folded: String, offsets: [Int]) {
        var scalars = String.UnicodeScalarView()
        var offsets: [Int] = []
        var utf16Offset = 0
        for scalar in text.unicodeScalars {
            defer { utf16Offset += scalar.utf16.count }
            let v = scalar.value
            if isArabicMark(v) { continue }
            if CharacterSet.whitespacesAndNewlines.contains(scalar) {
                if scalars.last == " " || scalars.isEmpty { continue }
                scalars.append(" ")
                offsets.append(utf16Offset)
                continue
            }
            guard let folded = Unicode.Scalar(foldArabicLetter(v)) else { continue }
            scalars.append(folded)
            offsets.append(utf16Offset)
        }
        return (String(scalars), offsets)
    }

    /// Folded Arabic, trimmed.
    static func arabic(_ text: String) -> String {
        arabicWithMap(text).folded.trimmingCharacters(in: .whitespaces)
    }

    /// Folded Arabic surah name without the leading "سورة".
    static func arabicSurahName(_ text: String) -> String {
        var folded = arabic(text)
        let prefix = "سوره "
        if folded.hasPrefix(prefix) { folded.removeFirst(prefix.count) }
        return folded
    }

    // MARK: - Digits

    /// Arabic-Indic and extended Arabic-Indic digits to ASCII.
    static func foldDigits(_ text: String) -> String {
        String(String.UnicodeScalarView(text.unicodeScalars.map { s -> Unicode.Scalar in
            switch s.value {
            case 0x0660...0x0669: return Unicode.Scalar(s.value - 0x0660 + 0x30)!
            case 0x06F0...0x06F9: return Unicode.Scalar(s.value - 0x06F0 + 0x30)!
            default: return s
            }
        }))
    }
}
