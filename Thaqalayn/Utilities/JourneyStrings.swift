//
//  JourneyStrings.swift
//  Thaqalayn
//
//  Language-driven copy for the Journey tab — hub, the four seasonal journeys
//  (Ramadan, Dhul-Hijjah/Hajj, Muharram, Fatimiyya), their day lists and day-detail
//  screens. Keyed off the global Settings → Language picker.
//
//  Per product decision this tab is localized to Urdu only; Arabic falls back to
//  English here. Day NARRATIVE content (theme/tafsir/reflection/du'a/notes) is
//  localized via the model `localized…(_:)` accessors, not here.
//

import Foundation

enum JourneyStrings {
    private static func ur(_ l: CommentaryLanguage) -> Bool { l == .urdu }

    // MARK: - Hub
    static func sacredSeasons(_ l: CommentaryLanguage) -> String { ur(l) ? "مقدس ایام" : "Sacred Seasons" }
    static func journeys(_ l: CommentaryLanguage) -> String { ur(l) ? "روحانی سفر" : "Journeys" }
    static func journeysSub(_ l: CommentaryLanguage) -> String {
        ur(l) ? "ہر مقدس موسم کو گہرائی سے جئیں، اور اسے اپنے آپ کو بدلنے دیں۔" : "Live each sacred season deeply, and let it transform you."
    }
    static func nextUp(_ l: CommentaryLanguage) -> String { ur(l) ? "اگلا" : "NEXT UP" }
    static func comingSoonInDays(_ days: Int, _ l: CommentaryLanguage) -> String {
        ur(l) ? "جلد آ رہا ہے · \(days) دن میں" : "Coming soon · in \(days) day\(days == 1 ? "" : "s")"
    }
    static func endedReturns(_ returnsLabel: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "ختم ہوا · \(returnsLabel)" : "Ended · \(returnsLabel)"
    }
    static func gotIt(_ l: CommentaryLanguage) -> String { ur(l) ? "سمجھ گیا" : "Got it" }

    // Locked-journey alert
    static func hasEnded(_ title: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(title) ختم ہو چکا ہے" : "\(title) has ended"
    }
    static func notOpenYet(_ title: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(title) ابھی نہیں کھلا" : "\(title) isn't open yet"
    }
    static func upNextInDays(_ title: String, _ days: Int, _ l: CommentaryLanguage) -> String {
        ur(l) ? "اگلا: \(title) · \(days) دن میں" : "Up next: \(title) · in \(days) day\(days == 1 ? "" : "s")"
    }
    static func upNextToday(_ title: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "اگلا: \(title) · آج" : "Up next: \(title) · today"
    }
    static func isOpenNow(_ title: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(title) اب کھلا ہے" : "\(title) is open now"
    }
    static func begins(_ date: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(date) کو شروع" : "Begins \(date)"
    }
    static func returns(_ date: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(date) کو واپسی" : "Returns \(date)"
    }
    static func firstFatimiyya(_ date: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "پہلی فاطمیہ · \(date)" : "First Fatimiyya · \(date)"
    }
    static func secondFatimiyya(_ date: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "دوسری فاطمیہ · \(date)" : "Second Fatimiyya · \(date)"
    }

    // MARK: - Journey identity (by descriptor id) — used in hub + journey headers
    static func title(_ id: String, _ l: CommentaryLanguage) -> String {
        guard ur(l) else { return englishTitle(id) }
        switch id {
        case "ramadan":  return "رمضان"
        case "hajj":     return "ذی الحجہ"
        case "muharram": return "محرم"
        case "fatimiyya":return "ایامِ فاطمیہ"
        default:         return englishTitle(id)
        }
    }
    private static func englishTitle(_ id: String) -> String {
        switch id {
        case "ramadan":  return "Ramadan"
        case "hajj":     return "Dhul-Hijjah"
        case "muharram": return "Muharram"
        case "fatimiyya":return "Fatimiyya"
        default:         return id.capitalized
        }
    }
    static func eyebrow(_ id: String, _ english: String, _ l: CommentaryLanguage) -> String {
        guard ur(l) else { return english }
        switch id {
        case "ramadan":  return "30 روزہ سفر"
        case "hajj":     return "10 روزہ سفر"
        case "muharram": return "10 روزہ سفر"
        case "fatimiyya":return "عزائے زہراؑ"
        default:         return english
        }
    }
    /// Legacy in-screen header title, e.g. "Muharram Journey".
    static func screenTitle(_ id: String, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(title(id, l)) کا سفر" : "\(englishTitle(id)) Journey"
    }

    // MARK: - Day list / progress
    static func daysObserved(_ done: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(total) میں سے \(done) دن منائے گئے" : "\(done) of \(total) days observed"
    }
    static func daysCompleted(_ done: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        ur(l) ? "\(total) میں سے \(done) دن مکمل" : "\(done) of \(total) days completed"
    }
    static func dayN(_ n: Int, _ l: CommentaryLanguage) -> String { ur(l) ? "دن \(n)" : "Day \(n)" }
    static func today(_ l: CommentaryLanguage) -> String { ur(l) ? "آج" : "TODAY" }
    static func loadingJourney(_ l: CommentaryLanguage) -> String { ur(l) ? "سفر لوڈ ہو رہا ہے…" : "Loading journey..." }
    static func errorLoadingJourney(_ l: CommentaryLanguage) -> String { ur(l) ? "سفر لوڈ کرنے میں خرابی" : "Error Loading Journey" }

    // MARK: - Day detail section labels & buttons
    static func todaysVerses(_ l: CommentaryLanguage) -> String { ur(l) ? "آج کی آیات" : "Today's Verses" }
    static func tafsirFocus(_ l: CommentaryLanguage) -> String { ur(l) ? "تفسیری نکتہ" : "Tafsir Focus" }
    static func reflection(_ l: CommentaryLanguage) -> String { ur(l) ? "غور و فکر" : "Reflection" }
    static func duaZiyarat(_ l: CommentaryLanguage) -> String { ur(l) ? "دعا / زیارت" : "Dua / Ziyarat" }
    static func fullTafsir(_ l: CommentaryLanguage) -> String { ur(l) ? "مکمل تفسیر" : "Full Tafsir" }
    static func backToJourney(_ l: CommentaryLanguage) -> String { ur(l) ? "واپس" : "Journey" }
    static func ashura(_ l: CommentaryLanguage) -> String { ur(l) ? "عاشورا" : "Ashura" }

    // Toggle button — mourning journeys ("observed") vs others ("completed")
    static func observed(_ l: CommentaryLanguage) -> String { ur(l) ? "منایا گیا" : "Observed" }
    static func markObserved(_ l: CommentaryLanguage) -> String { ur(l) ? "اس دن کو منائیں" : "Mark as observed" }
    static func completed(_ l: CommentaryLanguage) -> String { ur(l) ? "مکمل" : "Completed" }
    static func markComplete(_ l: CommentaryLanguage) -> String { ur(l) ? "مکمل کریں" : "Mark as complete" }

    static func isRTL(_ l: CommentaryLanguage) -> Bool { l.isRTL }
}
