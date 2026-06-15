//
//  QuranTabStrings.swift
//  Thaqalayn
//
//  Language-driven copy for the Quran (Home) tab — surah-list chrome, search,
//  continue-reading card, search-results sections. Keyed off the global
//  Settings → Language picker (CommentaryLanguageManager).
//
//  Surah NAMES and MEANINGS stay English by product decision: the Surah model has
//  no Urdu/Arabic name data, and the Arabic surah name is already shown beside the
//  English one. Only the surrounding chrome is localized here.
//

import Foundation

enum QuranTabStrings {
    static func greeting(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "السلام عليكم"; case .urdu: return "السلام علیکم"; default: return "Assalāmu ʿalaykum" }
    }
    /// Emerald header eyebrow.
    static func nobleQuranEyebrow(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "القرآن الكريم"; case .urdu: return "قرآنِ کریم"; default: return "The Noble Qur'an" }
    }
    /// Emerald header title.
    static func readAndReflect(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "اقرأ وتدبّر"; case .urdu: return "پڑھیں اور غور کریں"; default: return "Read & Reflect" }
    }
    /// Legacy (Light / Night Sanctuary) header title.
    static func holyQuran(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "القرآن الكريم"; case .urdu: return "قرآنِ مجید"; default: return "The Holy Quran" }
    }
    static func continueReading(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "متابعة القراءة"; case .urdu: return "مطالعہ جاری رکھیں"; default: return "Continue Reading" }
    }
    static func resume(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "استئناف"; case .urdu: return "جاری رکھیں"; default: return "Resume" }
    }
    static func searchPlaceholder(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "ابحث في السور والآيات والمواضيع…"
        case .urdu:   return "سورتیں، آیات، موضوعات تلاش کریں…"
        default:      return "Search surahs, verses, themes…"
        }
    }
    static func surahsCount(_ n: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "\(n) سورة"; case .urdu: return "\(n) سورتیں"; default: return "\(n) Surahs" }
    }
    static func versesCount(_ n: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "\(n) آية"; case .urdu: return "\(n) آیات"; default: return "\(n) verses" }
    }
    /// Maps the data's "Meccan"/"Medinan" revelationType to the active language.
    static func revelation(_ raw: String, _ l: CommentaryLanguage) -> String {
        let isMeccan = raw.caseInsensitiveCompare("Meccan") == .orderedSame
        switch l {
        case .arabic: return isMeccan ? "مكية" : "مدنية"
        case .urdu:   return isMeccan ? "مکی" : "مدنی"
        default:      return raw
        }
    }
    static func verseOf(_ n: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "الآية \(n) من \(total)"; case .urdu: return "آیت \(n) از \(total)"; default: return "Verse \(n) of \(total)" }
    }
    static func percentComplete(_ p: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "\(p)% مكتمل"; case .urdu: return "\(p)% مکمل"; default: return "\(p)% complete" }
    }

    // MARK: - Search results
    static func surahsLabel(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "السور"; case .urdu: return "سورتیں"; default: return "Surahs" }
    }
    static func versesLabel(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "الآيات"; case .urdu: return "آیات"; default: return "Verses" }
    }
    static func themesLabel(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "المواضيع"; case .urdu: return "موضوعات"; default: return "Themes" }
    }
    static func showingFirst(_ showing: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "عرض أول \(showing) من \(total)"
        case .urdu:   return "پہلے \(showing) از \(total) دکھائے جا رہے ہیں"
        default:      return "Showing first \(showing) of \(total)"
        }
    }
    static func noResults(_ query: String, _ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "لا نتائج لـ «\(query)»"
        case .urdu:   return "«\(query)» کے لیے کوئی نتیجہ نہیں"
        default:      return "No results for \u{201C}\(query)\u{201D}"
        }
    }

    static func isRTL(_ l: CommentaryLanguage) -> Bool { l.isRTL }
}
