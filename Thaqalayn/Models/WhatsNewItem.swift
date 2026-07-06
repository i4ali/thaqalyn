//
//  WhatsNewItem.swift
//  Thaqalayn
//
//  One "What's New" feature announcement plus the static registry that feeds the
//  Today-tab spotlight. Mirrors DeepDiveDescriptor.all / JourneyCatalog: adding an
//  announcement is a pure content addition here. No backend.
//

import Foundation

/// Where tapping a What's New card takes the user.
enum WhatsNewDestination: Equatable {
    /// Open an immersive deep dive by id (lives in the Journey hub, tab 4).
    case deepDive(String)
    // Reserved for later: case journey(String), case tab(Int)
}

/// One feature announcement. Copy is per-language (EN / UR / AR), matching the Today tab.
struct WhatsNewItem: Identifiable, Equatable {
    let id: String
    let sfSymbol: String
    let releaseDate: Date
    let destination: WhatsNewDestination

    private let titleEN: String, titleUR: String, titleAR: String
    private let blurbEN: String, blurbUR: String, blurbAR: String
    private let ctaEN: String, ctaUR: String, ctaAR: String

    init(id: String, sfSymbol: String, releaseDate: Date, destination: WhatsNewDestination,
         titleEN: String, titleUR: String, titleAR: String,
         blurbEN: String, blurbUR: String, blurbAR: String,
         ctaEN: String, ctaUR: String, ctaAR: String) {
        self.id = id; self.sfSymbol = sfSymbol; self.releaseDate = releaseDate
        self.destination = destination
        self.titleEN = titleEN; self.titleUR = titleUR; self.titleAR = titleAR
        self.blurbEN = blurbEN; self.blurbUR = blurbUR; self.blurbAR = blurbAR
        self.ctaEN = ctaEN; self.ctaUR = ctaUR; self.ctaAR = ctaAR
    }

    func title(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return titleAR; case .urdu: return titleUR; default: return titleEN }
    }
    func blurb(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return blurbAR; case .urdu: return blurbUR; default: return blurbEN }
    }
    func cta(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return ctaAR; case .urdu: return ctaUR; default: return ctaEN }
    }
}

enum WhatsNewCatalog {
    /// Author in any order; the manager sorts newest-first by releaseDate.
    static let all: [WhatsNewItem] = [
        WhatsNewItem(
            id: "deepDives-sabr",
            sfSymbol: "hourglass",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 13).date ?? .distantPast,
            destination: .deepDive("sabr"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Ṣabr - Patience. An immersive descent through three stations of the heart, from the patient prophets to Karbala.",
            blurbUR: "صبر - دل کے تین مقامات سے گزرتا ہوا ایک عمیق روحانی سفر، صبر کرنے والے انبیاء سے کربلا تک۔",
            blurbAR: "الصَّبْر - نزولٌ غامرٌ عبر ثلاثة مقامات للقلب، من الأنبياء الصابرين إلى كربلاء.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        ),
        WhatsNewItem(
            id: "deepDives-yaqin",
            sfSymbol: "eye",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 6).date ?? .distantPast,
            destination: .deepDive("yaqin"),
            titleEN: "Deep Dives",
            titleUR: "گہرے غوطے",
            titleAR: "الغوص العميق",
            blurbEN: "Yaqīn - Certainty. An immersive descent through three depths, from Qur'an to Karbala.",
            blurbUR: "یقین - کامل یقین۔ تین درجاتِ یقین میں اترتا ہوا ایک عمیق روحانی سفر، قرآن سے کربلا تک۔",
            blurbAR: "يَقِين - نزول غامر عبر ثلاثة أعماق من اليقين، من القرآن إلى كربلاء.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        )
    ]

    static func byId(_ id: String) -> WhatsNewItem? { all.first { $0.id == id } }
}
