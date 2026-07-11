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
    /// Open an "Inside the Surah" experience by id (lives in the Journey hub, tab 4).
    case surahExperience(String)
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
            id: "surahExperience-nisa",
            sfSymbol: "building.columns",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 2).date ?? .distantPast,
            destination: .surahExperience("surah-nisa"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Nisa - the surah named for the powerless, and the one command that runs through it: render every trust to the one it belongs to. An immersive descent from the orphan's coin and the woman's right, to the seat of judgment, to the authority God entrusted only to the pure.",
            blurbUR: "سورۂ نساء - وہ سورت جو بے بسوں کے نام سے موسوم ہے، اور اِس میں ایک ہی حکم سب کچھ چلاتا ہے: ہر امانت اُس کے حقدار کو لوٹا دو۔ یتیم کے مال اور عورت کے حق سے لے کر مسندِ انصاف تک، اور اُس اختیار تک جو اللہ نے صرف پاکیزہ لوگوں کے سپرد کیا - ایک عمیق روحانی سفر۔",
            blurbAR: "سورة النساء - السورةُ التي حملت اسم المستضعفين، وأمرٌ واحدٌ يسري فيها كلِّها: أدِّ كلَّ أمانةٍ إلى أهلها. نزولٌ غامرٌ من مال اليتيم وحقِّ المرأة، إلى مقعد القضاء، إلى السلطةِ التي جعلها الله في الطاهرين وحدهم.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-ali-imran",
            sfSymbol: "person.3.sequence.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 1).date ?? .distantPast,
            destination: .surahExperience("surah-ali-imran"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah Al Imran - how God carries His truth through the households He chooses and purifies. From Maryam, chosen and purified in her prayer-niche, to the day God let His Prophet ﷺ stake the truth itself on a single purified household.",
            blurbUR: "سورۂ آلِ عمران - اللہ اپنی سچائی اُن گھرانوں کے ذریعے تھامتا ہے جنہیں وہ چنتا اور پاک کرتا ہے۔ محرابِ مریم سے لے کر اُس دن تک جب اللہ نے اپنے نبی ﷺ کے ذریعے سچائی کو ایک پاکیزہ گھرانے پر داؤ پر لگوایا۔",
            blurbAR: "سورة آل عمران - كيف يحمل الله حقَّه عبر البيوت التي يصطفيها ويطهّرها. من محراب مريم إلى اليوم الذي جعل الله فيه نبيَّه ﷺ يجعل الحقَّ رهاناً على بيتٍ طاهرٍ واحد.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-baqara",
            sfSymbol: "hands.sparkles.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 30).date ?? .distantPast,
            destination: .surahExperience("surah-baqara"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Baqara - why the mightiest surah is named after a cow. An immersive descent through a command, the questions that made it heavy, and the sign that answered it all.",
            blurbUR: "سورۂ بقرہ - سب سے بڑی سورت کا نام ایک گائے پر کیوں؟ ایک حکم، اُسے بھاری بنانے والے سوالات، اور وہ نشانی جس نے سب کا جواب دیا - ایک عمیق سفر۔",
            blurbAR: "سورة البقرة - لماذا سُمّيت أعظم سورة باسم بقرة؟ نزولٌ غامرٌ عبر الأمر، والأسئلة التي أثقلته، والآية التي أجابت عن كل شيء.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-fatiha",
            sfSymbol: "book.closed",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 27).date ?? .distantPast,
            destination: .surahExperience("surah-fatiha"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Fatiha - the prayer beneath every prayer. Walk the opening you know by heart as a conversation with God, and hear what He says back, line by line.",
            blurbUR: "سورۂ فاتحہ - ہر نماز کے پیچھے چھپی دعا۔ جس سورت کو آپ زبانی جانتے ہیں، اُسے اللہ سے ایک مکالمے کے طور پر دیکھیں، اور سنیں کہ وہ ہر سطر کا کیا جواب دیتا ہے۔",
            blurbAR: "سورة الفاتحة - الصلاةُ الكامنة خلف كل صلاة. اسلك الفاتحةَ التي تحفظها عن ظهر قلب حواراً مع الله، واسمع ما يردّ به عليك، سطراً بسطر.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-yusuf",
            sfSymbol: "moon.stars",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 20).date ?? .distantPast,
            destination: .surahExperience("surah-yusuf"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah Yusuf - an immersive journey through the most beautiful of stories, from the dream to the reunion.",
            blurbUR: "سورۂ یوسف - خواب سے وصال تک، بہترین قصے کا ایک عمیق سفر۔",
            blurbAR: "سورة يوسف - رحلة غامرة عبر أحسن القصص، من الرؤيا إلى اللقاء.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "deepDives-sabr",
            sfSymbol: "hourglass",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 13).date ?? .distantPast,
            destination: .deepDive("sabr"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Sabr - Patience. An immersive descent through three stations of the heart, from the patient prophets to Karbala.",
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
            blurbEN: "Yaqin - Certainty. An immersive descent through three depths, from Qur'an to Karbala.",
            blurbUR: "یقین - کامل یقین۔ تین درجاتِ یقین میں اترتا ہوا ایک عمیق روحانی سفر، قرآن سے کربلا تک۔",
            blurbAR: "يَقِين - نزول غامر عبر ثلاثة أعماق من اليقين، من القرآن إلى كربلاء.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        )
    ]

    static func byId(_ id: String) -> WhatsNewItem? { all.first { $0.id == id } }
}
