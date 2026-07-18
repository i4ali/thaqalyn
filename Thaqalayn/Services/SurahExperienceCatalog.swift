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
    /// Cover art (Assets.xcassets), composed 4:5 with a dark top so the title can sit
    /// in the sky. Drives the shelf poster and the list-row tile. Coming-soon entries
    /// carry one too - the art is what makes the roadmap worth buying into.
    var coverAssetName: String? = nil

    static let all: [SurahExperienceDescriptor] = [
        SurahExperienceDescriptor(
            id: "surah-fatiha",
            surahNumber: 1,
            title: LocalizedText(en: "Surah al-Fatiha", ur: "سورۂ فاتحہ", ar: "سورة الفاتحة"),
            titleAr: "الْفَاتِحَة",
            sfSymbol: "book.closed",
            subtitle: LocalizedText(en: "The Opening - the prayer beneath every prayer",
                                    ur: "فاتحہ - ہر نماز میں چھپی ہوئی دعا",
                                    ar: "الفاتحة - الدعاء الكامن في كل صلاة"),
            available: true, dive: .surahFatiha,
            coverAssetName: "FatihaCover"
        ),
        SurahExperienceDescriptor(
            id: "surah-baqara",
            surahNumber: 2,
            title: LocalizedText(en: "Surah al-Baqara", ur: "سورۂ بقرہ", ar: "سورة البقرة"),
            titleAr: "الْبَقَرَة",
            sfSymbol: "hands.sparkles.fill",
            subtitle: LocalizedText(en: "The Cow - the mirror inside the mightiest surah",
                                    ur: "البقرہ - عظیم ترین سورہ کے اندر ایک آئینہ",
                                    ar: "البقرة - مرآةٌ في أعظم السور"),
            available: true, dive: .surahBaqara,
            coverAssetName: "BaqaraCover"
        ),
        SurahExperienceDescriptor(
            id: "surah-ali-imran",
            surahNumber: 3,
            title: LocalizedText(en: "Surah Al Imran", ur: "سورۂ آلِ عمران", ar: "سورة آل عمران"),
            titleAr: "آلِ عِمْرَان",
            sfSymbol: "person.3.sequence.fill",
            subtitle: LocalizedText(en: "The Family of Imran - one chosen house, and the house that answered it",
                                    ur: "آلِ عمران - ایک برگزیدہ گھرانہ، اور وہ گھرانہ جس نے لبیک کہا",
                                    ar: "آل عمران - بيتٌ اصطفاه الله، والبيتُ الذي أجابه"),
            available: true, dive: .surahAliImran,
            coverAssetName: "AliImranCover"
        ),
        SurahExperienceDescriptor(
            id: "surah-nisa",
            surahNumber: 4,
            title: LocalizedText(en: "Surah al-Nisa", ur: "سورۂ نساء", ar: "سورة النساء"),
            titleAr: "النِّسَاء",
            sfSymbol: "figure.2.and.child.holdinghands",
            subtitle: LocalizedText(en: "The Women - one trust, from the orphan's coin to the seat of authority",
                                    ur: "النساء - ایک ہی امانت، یتیم کے مال سے لے کر منصبِ ولایت تک",
                                    ar: "النساء - أمانةٌ واحدة، من مال اليتيم إلى مقام الولاية"),
            // Rewritten from scratch 2026-07-16 (the earlier version was withdrawn for
            // comprehension; old text recoverable from git, commit f35b980).
            available: true, dive: .surahNisa,
            coverAssetName: "NisaCover"
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
            available: true, dive: .surahYusuf,
            coverAssetName: "YusufCover"
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
            available: false, dive: nil,
            coverAssetName: "YasinCover"
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
            available: true, dive: .surahRahman,
            coverAssetName: "RahmanCover"
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
            available: false, dive: nil,
            coverAssetName: "MulkCover"
        ),
    ]

    static func byId(_ id: String) -> SurahExperienceDescriptor? { all.first { $0.id == id } }
    static func bySurahNumber(_ n: Int) -> SurahExperienceDescriptor? { all.first { $0.surahNumber == n } }
}
