//
//  JourneyStrings.swift
//  Thaqalayn
//
//  Language-driven copy for the Journey tab - hub, the seasonal journeys
//  (Ramadan, Dhul-Hijjah/Hajj, Muharram, Fatimiyya, Arbaeen), their day lists and
//  day-detail screens. Keyed off the global Settings -> Language picker.
//
//  Authored in English, Urdu and Arabic; any language without its own string falls
//  back to English. Day NARRATIVE content (theme/tafsir/reflection/du'a/notes) is
//  localized via the model `localized…(_:)` accessors, not here.
//

import Foundation

enum JourneyStrings {
    /// Pick a language variant. English is the fallback for any language (incl. French)
    /// that has no dedicated string here.
    private static func pick(_ l: CommentaryLanguage, en: String, ur: String, ar: String) -> String {
        switch l {
        case .urdu:   return ur
        case .arabic: return ar
        default:      return en
        }
    }

    // MARK: - Hub
    static func sacredSeasons(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Sacred Seasons", ur: "مقدس ایام", ar: "المواسم المقدّسة")
    }
    static func journeys(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Journeys", ur: "روحانی سفر", ar: "الرحلات")
    }
    static func journeysSub(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Live a sacred season, or descend into a theme.",
             ur: "کسی مقدس موسم کو جئیں، یا کسی موضوع کی گہرائی میں اتریں۔",
             ar: "عِشْ موسماً مقدّساً، أو انزل في أعماق موضوع.")
    }
    static func grow(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Grow", ur: "نشوونما", ar: "النمو")
    }
    static func deepDives(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Deep Dives", ur: "گہرے سفر", ar: "غوصٌ عميق")
    }
    static func deepDivesSub(_ l: CommentaryLanguage) -> String {
        pick(l, en: "explore anytime", ur: "جب چاہیں دریافت کریں", ar: "استكشفها في أيّ وقت")
    }
    static func comingSoon(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Coming soon", ur: "جلد آ رہا ہے", ar: "قريباً")
    }
    static func deepDiveOnItsWay(_ title: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(title) is on its way.", ur: "\(title) جلد دستیاب ہوگا۔", ar: "\(title) قادمٌ قريباً.")
    }
    // Deep Dive card chrome - shared across every dive card, so localized here rather
    // than per catalog entry. `premium` is the shared Premium chip label, kept
    // consistent across the app.
    static func deepDiveEyebrow(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Deep Dive", ur: "گہرا مطالعہ", ar: "غوص عميق")
    }
    static func soon(_ l: CommentaryLanguage) -> String {
        pick(l, en: "SOON", ur: "جلد", ar: "قريباً")
    }
    static func premium(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Premium", ur: "پریمیئم", ar: "بريميوم")
    }

    // MARK: - Shelf status eyebrows (compact hub cards)
    // Short status words shown in the eyebrow slot of the horizontal-shelf cards.
    // Longer, full-sentence variants (comingSoonInDays / endedReturns) still drive
    // the full-width "All N" list cards.
    static func live(_ l: CommentaryLanguage) -> String {
        pick(l, en: "LIVE", ur: "جاری", ar: "جارٍ")
    }
    static func ready(_ l: CommentaryLanguage) -> String {
        pick(l, en: "READY", ur: "تیار", ar: "جاهز")
    }
    static func inDaysShort(_ days: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "IN \(days) DAY\(days == 1 ? "" : "S")",
             ur: "\(days) دن میں",
             ar: "بعد \(days) يوماً")
    }
    static func endedShort(_ l: CommentaryLanguage) -> String {
        pick(l, en: "ENDED", ur: "ختم", ar: "انتهت")
    }
    /// "See all" link on a shelf header - count is that section's live total.
    static func allCount(_ n: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "All \(n)", ur: "تمام \(n)", ar: "الكل \(n)")
    }
    // Surah experiences ("Inside the Surah") - hub section, card eyebrow, closing CTA.
    static func insideTheSurah(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Inside the Surah", ur: "سورہ کے اندر", ar: "في قلب السورة")
    }
    static func anImmersiveJourney(_ l: CommentaryLanguage) -> String {
        pick(l, en: "An immersive journey", ur: "ایک عمیق سفر", ar: "رحلة غامرة")
    }
    static func surahJourneyEyebrow(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Surah Journey", ur: "سورہ کا سفر", ar: "رحلة السورة")
    }
    static func readTheFullSurah(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Read the full surah", ur: "مکمل سورہ پڑھیں", ar: "اقرأ السورة كاملة")
    }
    // Surah-card mode toggle: Read & Tafsir | Journey.
    static func readAndTafsir(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Read & Tafsir", ur: "مطالعہ و تفسیر", ar: "القراءة والتفسير")
    }
    static func journey(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Journey", ur: "سفر", ar: "رحلة")
    }
    static func nextUp(_ l: CommentaryLanguage) -> String {
        pick(l, en: "NEXT UP", ur: "اگلا", ar: "التالي")
    }
    static func comingSoonInDays(_ days: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Coming soon · in \(days) day\(days == 1 ? "" : "s")",
             ur: "جلد آ رہا ہے · \(days) دن میں",
             ar: "قريباً · بعد \(days) يوماً")
    }
    static func endedReturns(_ returnsLabel: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Ended · \(returnsLabel)", ur: "ختم ہوا · \(returnsLabel)", ar: "انتهت · \(returnsLabel)")
    }
    static func gotIt(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Got it", ur: "سمجھ گیا", ar: "حسناً")
    }

    // Locked-journey alert
    static func hasEnded(_ title: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(title) has ended", ur: "\(title) ختم ہو چکا ہے", ar: "\(title) قد انتهت")
    }
    static func notOpenYet(_ title: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(title) isn't open yet", ur: "\(title) ابھی نہیں کھلا", ar: "\(title) لم تبدأ بعد")
    }
    static func upNextInDays(_ title: String, _ days: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Up next: \(title) · in \(days) day\(days == 1 ? "" : "s")",
             ur: "اگلا: \(title) · \(days) دن میں",
             ar: "التالي: \(title) · بعد \(days) يوماً")
    }
    static func upNextToday(_ title: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Up next: \(title) · today", ur: "اگلا: \(title) · آج", ar: "التالي: \(title) · اليوم")
    }
    static func isOpenNow(_ title: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(title) is open now", ur: "\(title) اب کھلا ہے", ar: "\(title) مفتوحة الآن")
    }
    static func begins(_ date: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Begins \(date)", ur: "\(date) کو شروع", ar: "تبدأ في \(date)")
    }
    static func returns(_ date: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Returns \(date)", ur: "\(date) کو واپسی", ar: "تعود في \(date)")
    }
    static func firstFatimiyya(_ date: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "First Fatimiyya · \(date)", ur: "پہلی فاطمیہ · \(date)", ar: "الفاطمية الأولى · \(date)")
    }
    static func secondFatimiyya(_ date: String, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Second Fatimiyya · \(date)", ur: "دوسری فاطمیہ · \(date)", ar: "الفاطمية الثانية · \(date)")
    }

    // MARK: - Journey identity (by descriptor id) - used in hub + journey headers
    static func title(_ id: String, _ l: CommentaryLanguage) -> String {
        switch id {
        case "ramadan":  return pick(l, en: "Ramadan", ur: "رمضان", ar: "رمضان")
        case "hajj":     return pick(l, en: "Dhul-Hijjah", ur: "ذی الحجہ", ar: "ذو الحجة")
        case "muharram": return pick(l, en: "Muharram", ur: "محرم", ar: "المحرّم")
        case "fatimiyya":return pick(l, en: "Fatimiyya", ur: "ایامِ فاطمیہ", ar: "الفاطمية")
        case "arbaeen":  return pick(l, en: "Arbaeen", ur: "اربعین", ar: "الأربعين")
        default:         return id.capitalized
        }
    }
    static func eyebrow(_ id: String, _ english: String, _ l: CommentaryLanguage) -> String {
        switch id {
        case "ramadan":  return pick(l, en: english, ur: "30 روزہ سفر", ar: "رحلة 30 يوماً")
        case "hajj":     return pick(l, en: english, ur: "10 روزہ سفر", ar: "رحلة 10 أيام")
        case "muharram": return pick(l, en: english, ur: "10 روزہ سفر", ar: "رحلة 10 أيام")
        case "fatimiyya":return pick(l, en: english, ur: "عزائے زہراؑ", ar: "عزاء الزهراء (ع)")
        case "arbaeen":  return pick(l, en: english, ur: "40 روزہ سفر", ar: "رحلة 40 يوماً")
        default:         return english
        }
    }
    /// Short evocative tagline for a seasonal journey - shown as the description
    /// line on the compact hub shelf card (not the full-width "All" list, which
    /// keeps the status detail line). English + Urdu + Arabic.
    static func seasonTagline(_ id: String, _ l: CommentaryLanguage) -> String {
        switch id {
        case "ramadan":  return pick(l, en: "Thirty nights of nearness", ur: "قربِ الٰہی کی تیس راتیں", ar: "ثلاثون ليلةً من القُرب")
        case "hajj":     return pick(l, en: "The best ten days", ur: "سال کے بہترین دس دن", ar: "أفضلُ عشرةِ أيّام")
        case "muharram": return pick(l, en: "The stand at Karbala", ur: "کربلا کا قیام", ar: "وقفةُ كربلاء")
        case "arbaeen":  return pick(l, en: "The road to Arbaeen", ur: "اربعین کی راہ", ar: "الطريق إلى الأربعين")
        case "fatimiyya":return pick(l, en: "Mourning of az-Zahra (AS)", ur: "عزائے زہراؑ", ar: "عزاء الزهراء (ع)")
        default:         return ""
        }
    }

    /// Legacy in-screen header title, e.g. "Muharram Journey".
    static func screenTitle(_ id: String, _ l: CommentaryLanguage) -> String {
        let name = title(id, l)
        switch l {
        case .urdu:   return "\(name) کا سفر"
        case .arabic: return "رحلة \(name)"
        default:      return "\(name) Journey"
        }
    }

    // MARK: - Day list / progress
    static func daysObserved(_ done: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(done) of \(total) days observed",
             ur: "\(total) میں سے \(done) دن منائے گئے",
             ar: "أُحيِيَ \(done) من \(total) يوماً")
    }
    static func stationsObserved(_ done: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(done) of \(total) stations observed",
             ur: "\(total) میں سے \(done) منزلیں منائی گئیں",
             ar: "أُحيِيَت \(done) من \(total) محطة")
    }
    static func daysCompleted(_ done: Int, _ total: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "\(done) of \(total) days completed",
             ur: "\(total) میں سے \(done) دن مکمل",
             ar: "اكتمل \(done) من \(total) يوماً")
    }
    static func dayN(_ n: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Day \(n)", ur: "دن \(n)", ar: "اليوم \(n)")
    }
    static func stationN(_ n: Int, _ l: CommentaryLanguage) -> String {
        pick(l, en: "Station \(n)", ur: "منزل \(n)", ar: "المحطة \(n)")
    }
    static func today(_ l: CommentaryLanguage) -> String {
        pick(l, en: "TODAY", ur: "آج", ar: "اليوم")
    }
    static func loadingJourney(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Loading journey...", ur: "سفر لوڈ ہو رہا ہے…", ar: "جارٍ تحميل الرحلة…")
    }
    static func errorLoadingJourney(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Error Loading Journey", ur: "سفر لوڈ کرنے میں خرابی", ar: "خطأ في تحميل الرحلة")
    }

    // MARK: - Day detail section labels & buttons
    static func todaysVerses(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Today's Verses", ur: "آج کی آیات", ar: "آيات اليوم")
    }
    static func tafsirFocus(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Tafsir Focus", ur: "تفسیری نکتہ", ar: "محور التفسير")
    }
    static func reflection(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Reflection", ur: "غور و فکر", ar: "تأمّل")
    }
    static func duaZiyarat(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Dua / Ziyarat", ur: "دعا / زیارت", ar: "دعاء / زيارة")
    }
    static func fullTafsir(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Full Tafsir", ur: "مکمل تفسیر", ar: "التفسير الكامل")
    }
    static func readFullZiyarat(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Read the full ziyarat", ur: "مکمل زیارت پڑھیں", ar: "اقرأ الزيارة كاملة")
    }
    static func fullZiyaratTitle(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Ziyarat of Arbaeen", ur: "زیارتِ اربعین", ar: "زيارة الأربعين")
    }
    static func done(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Done", ur: "مکمل", ar: "تمّ")
    }
    static func backToJourney(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Journey", ur: "واپس", ar: "رجوع")
    }
    static func ashura(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Ashura", ur: "عاشورا", ar: "عاشوراء")
    }

    // Toggle button - mourning journeys ("observed") vs others ("completed")
    static func observed(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Observed", ur: "منایا گیا", ar: "أُحيِيَ")
    }
    static func markObserved(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Mark as observed", ur: "اس دن کو منائیں", ar: "أحيِ هذا اليوم")
    }
    static func completed(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Completed", ur: "مکمل", ar: "مكتمل")
    }
    static func markComplete(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Mark as complete", ur: "مکمل کریں", ar: "سجّله مكتملاً")
    }

    static func isRTL(_ l: CommentaryLanguage) -> Bool { l.isRTL }
}
