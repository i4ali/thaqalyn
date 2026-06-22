//
//  DailyCrosswordStrings.swift
//  Thaqalayn
//
//  Localized UI strings for the Daily Crossword feature.
//  Mirrors DailyChallengeStrings.swift — keyed by CommentaryLanguage.
//

import Foundation

enum DailyCrosswordStrings {

    // MARK: - Feature name

    static func dailyCrossword(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "الكلمات المتقاطعة"
        case .urdu:   return "روزانہ کراس ورڈ"
        default:      return "Daily Crossword"
        }
    }

    // MARK: - Premium chrome

    static func premiumLabel(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "بريميوم"
        case .urdu:   return "پریمیئم"
        default:      return "Premium"
        }
    }

    static func lockedTagline(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "افتح لغز اليوم"
        case .urdu:   return "روزانہ معمہ کھولیں"
        default:      return "Unlock the daily puzzle"
        }
    }

    // MARK: - Entry card teaser

    static func teaser(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "٦ كلمات للحل"
        case .urdu:   return "حل کرنے کے لیے ٦ الفاظ"
        default:      return "6 words to solve"
        }
    }

    // MARK: - Completion / state

    static func doneForToday(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "اكتمل اليوم"
        case .urdu:   return "آج مکمل"
        default:      return "Done for today"
        }
    }

    static func solved(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تم الحل!"
        case .urdu:   return "حل ہو گیا!"
        default:      return "Solved!"
        }
    }

    static func comeBackTomorrow(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "عُد غدًا لِلُغزٍ جديد."
        case .urdu:   return "نیا معمہ کل دوبارہ آئیں۔"
        default:      return "Come back tomorrow for a new puzzle."
        }
    }

    // MARK: - Clue direction labels

    static func across(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "أفقي"
        case .urdu:   return "افقی"
        default:      return "Across"
        }
    }

    static func down(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "عمودي"
        case .urdu:   return "عمودی"
        default:      return "Down"
        }
    }

    // MARK: - Actions

    static func hint(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تلميح"
        case .urdu:   return "اشارہ"
        default:      return "Hint"
        }
    }

    static func clear(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "مسح"
        case .urdu:   return "مٹائیں"
        default:      return "Clear"
        }
    }

    static func nextClue(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "التلميح التالي"
        case .urdu:   return "اگلا اشارہ"
        default:      return "Next clue"
        }
    }

    static func prevClue(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "التلميح السابق"
        case .urdu:   return "پچھلا اشارہ"
        default:      return "Previous clue"
        }
    }

}
