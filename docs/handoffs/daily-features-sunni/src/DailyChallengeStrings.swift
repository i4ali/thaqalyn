//
//  DailyChallengeStrings.swift
//  Thaqalayn
//
//  Localized UI strings for the Daily Challenge feature.
//  Mirror of TodayStrings in TodayView.swift — keyed by CommentaryLanguage.
//

import Foundation

enum DailyChallengeStrings {

    // MARK: - Eyebrow

    static func dailyChallenge(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تحدي اليوم"
        case .urdu:   return "آج کا چیلنج"
        default:      return "Daily Challenge"
        }
    }

    // MARK: - Buttons / actions

    static func start(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "ابدأ"
        case .urdu:   return "شروع کریں"
        default:      return "Start"
        }
    }

    static func doneForToday(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تم لليوم"
        case .urdu:   return "آج کے لیے مکمل"
        default:      return "Done for today"
        }
    }

    static func comeBackTomorrow(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "عد غدًا"
        case .urdu:   return "کل واپس آئیں"
        default:      return "Come back tomorrow"
        }
    }

    // MARK: - Answer feedback

    static func correct(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "صحيح"
        case .urdu:   return "درست"
        default:      return "Correct"
        }
    }

    static func notQuite(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "ليس تمامًا"
        case .urdu:   return "قریب تھے"
        default:      return "Not quite"
        }
    }

    // MARK: - Flashcard

    static func flipCard(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "اقلب البطاقة"
        case .urdu:   return "کارڈ پلٹیں"
        default:      return "Tap to flip"
        }
    }

    static func gotIt(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "فهمت"
        case .urdu:   return "سمجھ گیا"
        default:      return "Got it"
        }
    }

    static func reviewAgain(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "راجع مجددًا"
        case .urdu:   return "دوبارہ دیکھیں"
        default:      return "Review again"
        }
    }

    // MARK: - True / False labels

    static func trueLabel(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "صحيح"
        case .urdu:   return "سچ"
        default:      return "True"
        }
    }

    static func falseLabel(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "خطأ"
        case .urdu:   return "جھوٹ"
        default:      return "False"
        }
    }

    // MARK: - Streak

    /// "N day(s)" with proper singular/plural in each language.
    static func dayUnit(_ count: Int, _ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic:
            // Arabic dual / plural
            switch count {
            case 1:  return "يوم واحد"
            case 2:  return "يومان"
            default: return "\(count) أيام"
            }
        case .urdu:
            // Urdu: singular/plural (Urdu doesn't distinguish in this phrase)
            return count == 1 ? "۱ دن" : "\(count) دن"
        default:
            return count == 1 ? "1 day" : "\(count) days"
        }
    }

    /// Full streak label, e.g. "5-day streak"
    static func streakLabel(_ count: Int, _ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "سلسلة \(dayUnit(count, l))"
        case .urdu:   return "\(dayUnit(count, l)) کا سلسلہ"
        default:      return "\(dayUnit(count, l)) streak"
        }
    }

    // MARK: - Format teasers (shown on the entry card before the sheet opens)

    static func teaser(for format: DailyChallengeFormat, _ l: CommentaryLanguage) -> String {
        switch format {
        case .multipleChoice:
            switch l {
            case .arabic: return "اختر الإجابة الصحيحة"
            case .urdu:   return "صحیح جواب چنیں"
            default:      return "Pick the right answer"
            }
        case .trueFalse:
            switch l {
            case .arabic: return "هل هذا صحيح أم خطأ؟"
            case .urdu:   return "سچ ہے یا جھوٹ؟"
            default:      return "True or false?"
            }
        case .flashcard:
            switch l {
            case .arabic: return "بطاقة تعليمية — اقلب واختبر نفسك"
            case .urdu:   return "فلیش کارڈ — پلٹیں اور جانچیں"
            default:      return "Flashcard — flip to test yourself"
            }
        case .fillInBlank:
            switch l {
            case .arabic: return "أكمل الجملة"
            case .urdu:   return "خالی جگہ بھریں"
            default:      return "Fill in the blank"
            }
        }
    }

    // MARK: - Premium lock strings (locked-card chrome — fixed size, not scaled)

    /// Short label shown in the gold pill on the locked card ("Premium").
    static func premiumLabel(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "مميّز"
        case .urdu:   return "پریمیم"
        default:      return "Premium"
        }
    }

    /// Generic teaser line shown on the locked card when no live challenge is available.
    static func lockedTagline(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تحدٍ جديد كل يوم"
        case .urdu:   return "روز ایک نیا چیلنج"
        default:      return "A new challenge every day"
        }
    }

    // MARK: - Completion screen

    static func completionTitle(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "أحسنت"
        case .urdu:   return "شاباش"
        default:      return "Well done"
        }
    }

    static func doneButton(_ l: CommentaryLanguage) -> String {
        switch l {
        case .arabic: return "تم"
        case .urdu:   return "مکمل"
        default:      return "Done"
        }
    }
}
