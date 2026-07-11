//
//  DeepDiveCatalog.swift
//  Thaqalayn
//
//  Static registry of the immersive "deep dives" shown in the Journeys tab,
//  alongside the seasonal journeys. Mirrors JourneyCatalog's shape but carries no
//  calendar logic — a dive is simply available or coming soon.
//
//  Card copy (title + subtitle) is localized via `LocalizedText` — the same type the
//  `DeepDive` model uses — in English, Urdu and Arabic. The shared "Deep Dive"
//  eyebrow and the FEATURED / PREMIUM / SOON chrome are localized in the card via
//  `JourneyStrings`, not per entry.
//

import SwiftUI

/// One deep dive in the hub. Static registry — see `DeepDiveDescriptor.all`.
struct DeepDiveDescriptor: Identifiable {
    /// Stable id — matches the deep-link id if/when deep dives get deep links.
    let id: String
    let title: LocalizedText   // e.g. "Yaqin · Certainty" / "یقین" / "اليقين"
    let titleAr: String        // e.g. "يَقِين"
    let sfSymbol: String       // card icon
    let subtitle: LocalizedText // one-line descriptor (EN / UR / AR)
    /// True when the dive is built and openable. False = "coming soon" placeholder.
    let available: Bool
    /// The dive content, present only when `available`.
    let dive: DeepDive?

    static let all: [DeepDiveDescriptor] = [
        DeepDiveDescriptor(
            id: "yaqin",
            title: LocalizedText(en: "Yaqin · Certainty", ur: "یقین", ar: "اليقين"),
            titleAr: "يَقِين",
            sfSymbol: "eye",
            subtitle: LocalizedText(en: "A descent through three depths - Qur'an to Karbala",
                                    ur: "تین گہرائیوں میں اترتا ایک سفر - قرآن سے کربلا تک",
                                    ar: "نزولٌ عبر ثلاثة أعماق - من القرآن إلى كربلاء"),
            available: true, dive: .yaqin
        ),
        DeepDiveDescriptor(
            id: "sabr",
            title: LocalizedText(en: "Sabr · Patience", ur: "صبر", ar: "الصبر"),
            titleAr: "صَبْر",
            sfSymbol: "hourglass",
            subtitle: LocalizedText(en: "A descent through three stations - Qur'an to Karbala",
                                    ur: "تین منزلوں میں اترتا ایک سفر - قرآن سے کربلا تک",
                                    ar: "نزولٌ عبر ثلاث محطات - من القرآن إلى كربلاء"),
            available: true, dive: .sabr
        ),
        DeepDiveDescriptor(
            id: "tawakkul",
            title: LocalizedText(en: "Tawakkul · Reliance", ur: "توکل", ar: "التوكّل"),
            titleAr: "تَوَكُّل",
            sfSymbol: "hands.and.sparkles",
            subtitle: LocalizedText(en: "Trusting God with the outcome",
                                    ur: "انجام کو اللہ کے سپرد کر دینا",
                                    ar: "أن تُسلّم النتيجة لله"),
            available: false, dive: nil
        ),
        DeepDiveDescriptor(
            id: "shukr",
            title: LocalizedText(en: "Shukr · Gratitude", ur: "شکر", ar: "الشكر"),
            titleAr: "شُكْر",
            sfSymbol: "hands.clap",
            subtitle: LocalizedText(en: "Turning every blessing into remembrance",
                                    ur: "ہر نعمت کو یاد میں بدل دینا",
                                    ar: "تحويل كل نعمة إلى ذِكر"),
            available: false, dive: nil
        ),
        DeepDiveDescriptor(
            id: "ikhlas",
            title: LocalizedText(en: "Ikhlas · Sincerity", ur: "اخلاص", ar: "الإخلاص"),
            titleAr: "إِخْلَاص",
            sfSymbol: "drop.fill",
            subtitle: LocalizedText(en: "Purifying the intention for God alone",
                                    ur: "نیت کو صرف اللہ کے لیے خالص کرنا",
                                    ar: "إخلاص النية لله وحده"),
            available: false, dive: nil
        ),
        DeepDiveDescriptor(
            id: "taqwa",
            title: LocalizedText(en: "Taqwa · God-consciousness", ur: "تقویٰ", ar: "التقوى"),
            titleAr: "تَقْوَىٰ",
            sfSymbol: "shield",
            subtitle: LocalizedText(en: "The awareness that guards the heart",
                                    ur: "وہ شعور جو دل کی حفاظت کرے",
                                    ar: "الوعي الذي يحرس القلب"),
            available: false, dive: nil
        ),
        DeepDiveDescriptor(
            id: "rida",
            title: LocalizedText(en: "Rida · Contentment", ur: "رضا", ar: "الرضا"),
            titleAr: "رِضَا",
            sfSymbol: "heart.fill",
            subtitle: LocalizedText(en: "Meeting God's decree with a still heart",
                                    ur: "اللہ کے فیصلے کو مطمئن دل سے قبول کرنا",
                                    ar: "لقاء قضاء الله بقلبٍ مطمئن"),
            available: false, dive: nil
        ),
    ]

    static func byId(_ id: String) -> DeepDiveDescriptor? { all.first { $0.id == id } }
}
