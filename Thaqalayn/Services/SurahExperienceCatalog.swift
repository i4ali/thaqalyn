//
//  SurahExperienceCatalog.swift
//  Thaqalayn
//
//  Static registry of the immersive "Inside the Surah" experiences shown in the
//  Journeys tab below the Deep Dives, and surfaced as a split-row strip on the
//  matching surah's card in the Quran-tab list. Mirrors DeepDiveCatalog's shape; a surah experience
//  is simply available or coming soon. All entries are premium-gated except
//  al-Fatiha, the free flagship teaser (PremiumManager.canAccessSurahExperience).
//

import SwiftUI

/// One surah experience in the hub. Static registry - see `SurahExperienceDescriptor.all`.
struct SurahExperienceDescriptor: Identifiable {
    /// Stable id - also the deep-link id (DeepLinkRouter.pendingSurahExperienceId).
    let id: String
    /// The surah this experience belongs to - drives the list-row strip lookup.
    let surahNumber: Int
    let title: LocalizedText   // e.g. "Surah Yusuf" / "سورۂ یوسف" / "سورة يوسف"
    let titleAr: String        // e.g. "يُوسُف"
    let sfSymbol: String       // card icon
    let subtitle: LocalizedText // one-line descriptor (EN / UR / AR)
    /// True when the experience is built and openable. False = "coming soon".
    let available: Bool
    /// The experience content, present only when `available`.
    let dive: DeepDive?

    static let all: [SurahExperienceDescriptor] = [
        SurahExperienceDescriptor(
            id: "surah-fatiha",
            surahNumber: 1,
            title: "Surah al-Fatiha",
            titleAr: "الْفَاتِحَة",
            sfSymbol: "book.closed",
            subtitle: "The Opening - the prayer beneath every prayer",
            available: true, dive: .surahFatiha
        ),
        SurahExperienceDescriptor(
            id: "surah-baqara",
            surahNumber: 2,
            title: "Surah al-Baqara",
            titleAr: "الْبَقَرَة",
            sfSymbol: "hands.sparkles.fill",
            subtitle: "The Cow - the mirror inside the mightiest surah",
            available: true, dive: .surahBaqara
        ),
        SurahExperienceDescriptor(
            id: "surah-ali-imran",
            surahNumber: 3,
            title: "Surah Al Imran",
            titleAr: "آلِ عِمْرَان",
            sfSymbol: "person.3.sequence.fill",
            subtitle: "The Family of Imran - one chosen house, and the house that answered it",
            available: true, dive: .surahAliImran
        ),
        SurahExperienceDescriptor(
            id: "surah-nisa",
            surahNumber: 4,
            title: "Surah al-Nisa",
            titleAr: "النِّسَاء",
            sfSymbol: "building.columns",
            subtitle: "The Women - one trust, from the orphan's coin to the seat of authority",
            available: true, dive: .surahNisa
        ),
        SurahExperienceDescriptor(
            id: "surah-yusuf",
            surahNumber: 12,
            title: LocalizedText(en: "Surah Yusuf", ur: "سورۂ یوسف", ar: "سورة يوسف"),
            titleAr: "يُوسُف",
            sfSymbol: "moon.stars",
            subtitle: LocalizedText(en: "The most beautiful of stories - loss, patience, reunion",
                                    ur: "بہترین قصہ - جدائی، صبر، وصال",
                                    ar: "أحسن القصص - فقدٌ وصبرٌ ولقاء"),
            available: true, dive: .surahYusuf
        ),
        SurahExperienceDescriptor(
            id: "surah-yasin",
            surahNumber: 36,
            title: LocalizedText(en: "Surah Yasin", ur: "سورۂ یٰسین", ar: "سورة يس"),
            titleAr: "يس",
            sfSymbol: "heart",
            subtitle: LocalizedText(en: "The heart of the Qur'an - and what it keeps asking you",
                                    ur: "قرآن کا دل - اور اس کا آپ سے سوال",
                                    ar: "قلب القرآن - وما يسألك عنه"),
            available: false, dive: nil
        ),
        SurahExperienceDescriptor(
            id: "surah-rahman",
            surahNumber: 55,
            title: LocalizedText(en: "Surah al-Rahman", ur: "سورۂ رحمٰن", ar: "سورة الرحمن"),
            titleAr: "الرَّحْمَٰن",
            sfSymbol: "water.waves",
            subtitle: LocalizedText(en: "One question, asked thirty-one times",
                                    ur: "ایک سوال، اکتیس بار",
                                    ar: "سؤالٌ واحد، إحدى وثلاثون مرة"),
            available: false, dive: nil
        ),
        SurahExperienceDescriptor(
            id: "surah-mulk",
            surahNumber: 67,
            title: LocalizedText(en: "Surah al-Mulk", ur: "سورۂ ملک", ar: "سورة الملك"),
            titleAr: "الْمُلْك",
            sfSymbol: "crown",
            subtitle: LocalizedText(en: "The protector - whose hand holds the kingdom",
                                    ur: "محافظ سورہ - بادشاہی کس کے ہاتھ میں ہے",
                                    ar: "السورة الحامية - بيد مَن الملك"),
            available: false, dive: nil
        ),
    ]

    static func byId(_ id: String) -> SurahExperienceDescriptor? { all.first { $0.id == id } }
    static func bySurahNumber(_ n: Int) -> SurahExperienceDescriptor? { all.first { $0.surahNumber == n } }
}
