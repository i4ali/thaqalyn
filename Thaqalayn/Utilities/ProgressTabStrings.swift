//
//  ProgressTabStrings.swift
//  Thaqalayn
//
//  Language-driven copy for the Progress tab — header, stat cards, streak,
//  badges, and the ring legend. Keyed off the global Settings → Language picker.
//
//  Numbers stay Western digits (per app convention). Badge "titles" are spiritual
//  ranks that already ship with an Arabic form (BadgeType.subtitle) — reused for
//  both Urdu and Arabic; surah-completion badges keep the (English) surah name.
//

import Foundation

enum ProgressTabStrings {
    // Header
    static func yourJourneyEyebrow(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "رحلتك"; case .urdu: return "آپ کا سفر"; default: return "Your Journey" }
    }
    static func progressTitle(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "التقدّم"; case .urdu: return "پیش رفت"; default: return "Progress" }
    }
    static func progressSubtitle(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "سجلّ وقتك مع القرآن"
        case .urdu:   return "قرآن کے ساتھ گزرے آپ کے وقت کا ریکارڈ"
        default:      return "A record of your time with the Qur'an"
        }
    }
    static func yourProgress(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "تقدّمك"; case .urdu: return "آپ کی پیش رفت"; default: return "Your Progress" }
    }
    static func trackJourney(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تابع رحلتك القرآنية"
        case .urdu:   return "اپنے قرآنی سفر کا جائزہ لیں"
        default:      return "Track your Quran journey"
        }
    }

    // Stats
    static func versesRead(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "الآيات المقروءة"; case .urdu: return "پڑھی گئی آیات"; default: return "Verses Read" }
    }
    static func surahsComplete(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "السور المكتملة"; case .urdu: return "مکمل سورتیں"; default: return "Surahs Complete" }
    }
    static func quizzesDone(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "الاختبارات المنجزة"; case .urdu: return "مکمل کوئز"; default: return "Quizzes Done" }
    }
    static func totalSawab(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "مجموع الثواب"; case .urdu: return "کل ثواب"; default: return "Total Sawab" }
    }
    static func ofTotal(_ n: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "من \(n)"; case .urdu: return "\(n) میں سے"; default: return "of \(n)" }
    }
    static func surahsTested(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "سور مُختبَرة"; case .urdu: return "آزمودہ سورتیں"; default: return "surahs tested" }
    }
    static func blessingsEarned(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "بركات مكتسبة"; case .urdu: return "حاصل شدہ برکات"; default: return "blessings earned" }
    }

    // Streak
    static func dayStreak(_ n: Int, _ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "سلسلة \(n) يوم"; case .urdu: return "\(n) دن کا سلسلہ"; default: return "\(n) Day Streak" }
    }
    static func keepItGoing(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "واصل التقدّم!"; case .urdu: return "اسے جاری رکھیں!"; default: return "Keep it going!" }
    }
    static func best(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "الأفضل"; case .urdu: return "بہترین"; default: return "Best" }
    }

    // Badges
    static func badges(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "الأوسمة"; case .urdu: return "تمغے"; default: return "Badges" }
    }
    static func badgesDivider(_ count: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "الأوسمة · \(count) من \(total)"
        case .urdu:   return "تمغے · \(count) / \(total)"
        default:      return "Badges · \(count) of \(total)"
        }
    }
    static func noBadgesYet(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "لا أوسمة بعد"; case .urdu: return "ابھی کوئی تمغہ نہیں"; default: return "No badges yet" }
    }
    static func earnBadgesHint(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "أكمل السور وواصل سلسلتك لتكسب الأوسمة."
        case .urdu:   return "تمغے حاصل کرنے کے لیے سورتیں مکمل کریں اور تسلسل برقرار رکھیں۔"
        default:      return "Complete surahs and build streaks to earn badges."
        }
    }
    /// Badge tile label: surah-completion badges show the (English) surah name;
    /// rank badges use the English transliteration for EN and the shipped Arabic
    /// honorific (BadgeType.subtitle) for Urdu + Arabic.
    static func badgeLabel(_ badge: BadgeAward, _ l: CommentaryLanguage) -> String {
        if badge.badgeType == .surahCompletion { return badge.surahName }
        switch l {
        case .english: return badge.badgeType.title
        default:       return badge.badgeType.subtitle
        }
    }

    // Ring legend / center
    static func quran(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "القرآن"; case .urdu: return "قرآن"; default: return "Quran" }
    }
    static func surahs(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "السور"; case .urdu: return "سورتیں"; default: return "Surahs" }
    }
    static func quizzes(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "اختبارات"; case .urdu: return "کوئز"; default: return "Quizzes" }
    }
    /// Localizes the seasonal ring label ("Ramadan" / "Hajj" / "Muharram").
    static func seasonal(_ raw: String, _ l: CommentaryLanguage) -> String {
        switch (raw, l) {
        case ("Hajj", .arabic):     return "الحج"
        case ("Hajj", .urdu):       return "حج"
        case ("Muharram", .arabic): return "محرم"
        case ("Muharram", .urdu):   return "محرم"
        case ("Ramadan", .arabic):  return "رمضان"
        case ("Ramadan", .urdu):    return "رمضان"
        default:                    return raw
        }
    }

    static func isRTL(_ l: CommentaryLanguage) -> Bool { l.isRTL }
}
