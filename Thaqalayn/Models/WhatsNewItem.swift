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
            id: "deepDives-salah",
            sfSymbol: "stairs",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 12).date ?? .distantPast,
            destination: .deepDive("salah"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Salah - The Believer's Ascent. The first dive that climbs: three names of the prayer, from the night fifty were made five, through the answered Fatiha, to the prayer under arrows at Karbala - closing with Fatima's gift.",
            blurbUR: "نماز - مومن کی معراج۔ پہلا غوطہ جو اوپر چڑھتا ہے: نماز کے تین نام، اُس رات سے جب پچاس نمازیں پانچ ہوئیں، جواب پانے والی فاتحہ سے ہوتے ہوئے، کربلا میں تیروں کے سائے میں نماز تک - اختتام حضرت فاطمہؑ کے تحفے پر۔",
            blurbAR: "الصلاة - معراج المؤمن. أول غوصٍ يصعد: ثلاثة أسماء للصلاة، من ليلة صارت الخمسون خمساً، مروراً بالفاتحة التي تُجاب آيةً آية، إلى الصلاة تحت السهام في كربلاء - وختاماً بهدية فاطمة عليها السلام.",
            ctaEN: "Begin the ascent",
            ctaUR: "صعود کا آغاز کریں",
            ctaAR: "ابدأ الصعود"
        ),
        WhatsNewItem(
            id: "surahExperience-kawthar",
            sfSymbol: "drop.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 8).date ?? .distantPast,
            destination: .surahExperience("surah-kawthar"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Kawthar - the shortest surah in the Qur'an, sent down to answer a single insult. They called the Prophet cut off; God answered with abundance itself: a river at the end of the world, and a gift wearing a face the mockers never thought to count.",
            blurbUR: "سورۂ کوثر - قرآن کی سب سے چھوٹی سورت، جو ایک طعنے کے جواب میں نازل ہوئی۔ انہوں نے نبی کو ابتر کہا؛ اللہ نے خود کثرت سے جواب دیا: دنیا کے آخری کنارے پر ایک نہر، اور ایک ایسا عطیہ جس کا چہرہ طعنہ دینے والوں کے شمار میں کبھی نہ آیا۔",
            blurbAR: "سورة الكوثر - أقصر سورة في القرآن، نزلت رداً على شتيمة واحدة. قالوا عن النبي إنه الأبتر؛ فأجاب الله بالكثرة نفسها: نهرٌ عند منتهى الدنيا، وعطيةٌ لها وجهٌ لم يخطر للساخرين أن يعدّوه.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-yasin",
            sfSymbol: "heart",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 7).date ?? .distantPast,
            destination: .surahExperience("surah-yasin"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah Ya-Sin - the heart of the Qur'an, and the surah read over the dying. Its whole labor is to wake a sleeping heart: the one who ran, the signs all around you, and the morning every soul is raised - met now, while waking is still a choice.",
            blurbUR: "سورۂ یٰسین - قرآن کا دل، اور وہ سورہ جو محتضر کے سرہانے پڑھی جاتی ہے۔ اس کی ساری محنت سوئے ہوئے دل کو جگانا ہے: وہ شخص جو دوڑا، آپ کے چاروں طرف پھیلی نشانیاں، اور وہ صبح جب ہر جان اٹھائی جائے گی - ابھی، جب جاگنا اب بھی ایک اختیار ہے۔",
            blurbAR: "سورة يس - قلبُ القرآن، والسورةُ التي تُقرأ عند المحتضر. همُّها كلُّه أن توقظ القلب النائم: الرجلُ الذي سعى، والآياتُ من حولك، والصباحُ الذي تُبعث فيه كلُّ نفس - تلقاها الآن، والاستيقاظ لا يزال اختياراً.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-mulk",
            sfSymbol: "crown",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 6).date ?? .distantPast,
            destination: .surahExperience("surah-mulk"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Mulk - the Kingdom, and the surah that guards the grave. It proves Whose hand holds everything by teaching the eye to look: up at a flawless sky, out at the bird held aloft by nothing, down at the water beneath your feet.",
            blurbUR: "سورۂ ملک - بادشاہی، اور وہ سورہ جو قبر میں محافظ بنتی ہے۔ یہ ثابت کرتی ہے کہ ہر چیز کس کے ہاتھ میں ہے، آنکھ کو دیکھنا سکھا کر: اوپر بے عیب آسمان کی طرف، سامنے اُس پرندے کی طرف جسے رحمٰن کے سوا کوئی نہیں تھامتا، اور نیچے اُس پانی کی طرف جو تمہارے قدموں کے نیچے ہے۔",
            blurbAR: "سورة الملك - المُلك، والسورةُ التي تحمي في القبر. تُثبت بيدِ مَن كلُّ شيءٍ بأن تُعلّم العين أن تنظر: فوقُ إلى سماءٍ لا فطور فيها، وأمامُ إلى الطير الذي لا يُمسكه إلا الرحمن، وتحتُ إلى الماء الذي تحت قدميك.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "surahExperience-rahman",
            sfSymbol: "water.waves",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 5).date ?? .distantPast,
            destination: .surahExperience("surah-rahman"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Rahman - the bride of the Qur'an asks one question thirty-one times. Walk its four registers of favors, and answer the question yourself, in the very words the Ahl al-Bayt taught.",
            blurbUR: "سورۂ رحمٰن - عروس القرآن ایک ہی سوال اکتیس بار پوچھتی ہے۔ نعمتوں کی چار منزلوں سے گزریں اور خود اس سوال کا جواب دیں، انہی لفظوں میں جو اہلِ بیت نے سکھائے۔",
            blurbAR: "سورة الرحمن - عروس القرآن تسأل سؤالاً واحداً إحدى وثلاثين مرة. اعبر منازل الآلاء الأربع وأجب عن السؤال بنفسك، بالكلمات التي علّمها أهل البيت.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
        WhatsNewItem(
            id: "deepDives-shukr",
            sfSymbol: "hands.clap",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 4).date ?? .distantPast,
            destination: .deepDive("shukr"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Shukr - Gratitude. A descent through the three tongues of thanks, from the first gifts to the praise in the dark of Ashura eve - ending with a count you will lose on purpose.",
            blurbUR: "شکر - شکرگزاری۔ شکر کی تین زبانوں میں اترتا ہوا ایک عمیق سفر، پہلی نعمتوں سے شبِ عاشورا کی حمد تک - جس کا اختتام ایک ایسی گنتی پر ہوتا ہے جو آپ جان بوجھ کر ہار جاتے ہیں۔",
            blurbAR: "الشكر - نزولٌ عبر ألسنة الشكر الثلاثة، من أولى العطايا إلى الثناء في ظلمة ليلة عاشوراء - يُختَم بعدٍّ تخسره عن قصد.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        ),
        WhatsNewItem(
            id: "deepDives-tawakkul",
            sfSymbol: "hands.and.sparkles",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 3).date ?? .distantPast,
            destination: .deepDive("tawakkul"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Tawakkul - Reliance. A descent through three motions of the trusting hand, from the parted sea to the morning of Ashura - ending with a release you perform with your own hand.",
            blurbUR: "توکل - بھروسے والے ہاتھ کی تین حرکتوں میں اترتا ہوا ایک عمیق سفر، شقِ دریا سے صبحِ عاشورا تک - جس کا اختتام ایک ایسی رہائی پر ہوتا ہے جو آپ خود اپنے ہاتھ سے ادا کرتے ہیں۔",
            blurbAR: "التوكّل - نزولٌ عبر ثلاث حركاتٍ لليد المتوكّلة، من انفلاق البحر إلى صباح عاشوراء - يُختَم بإفلاتٍ تؤدّيه بيدك أنت.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        ),
        WhatsNewItem(
            id: "surahExperience-nisa",
            sfSymbol: "figure.2.and.child.holdinghands",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 2).date ?? .distantPast,
            destination: .surahExperience("surah-nisa"),
            titleEN: "Inside the Surah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Surah al-Nisa - why the mightiest book of rights is named The Women. From the orphan's coin to the seat of authority, one trust runs through it all - and one verse names the company promised to those who guard it.",
            blurbUR: "سورۂ نساء - حقوق کی سب سے بڑی کتاب کا نام 'النساء' کیوں؟ یتیم کے مال سے منصبِ اختیار تک ایک ہی امانت سب میں جاری ہے - اور ایک آیت اُس رفاقت کا نام لیتی ہے جس کا وعدہ امانت کے محافظوں سے ہے۔",
            blurbAR: "سورة النساء - لماذا سُمّي أعظمُ كتابِ حقوقٍ باسم النساء؟ من مال اليتيم إلى مقام الولاية أمانةٌ واحدة تجري في السورة كلها - وآيةٌ واحدة تسمّي الرفقةَ الموعودة لمن حفظها.",
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
