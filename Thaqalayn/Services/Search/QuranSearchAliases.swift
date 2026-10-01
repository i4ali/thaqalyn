//
//  QuranSearchAliases.swift
//  Thaqalayn
//
//  Curated vocabulary for the Quran search, in plain spelling (house style):
//  other common names for surahs, well-known named verses, and Islamic terms or
//  prophet names mapped onto the words the English translation actually uses
//  ("sabr" -> patience, "Musa" -> Moses). Every English target word here was
//  checked against quran_data.json's translation.
//

import Foundation

enum QuranSearchAliases {

    // MARK: - Surahs

    /// Other names and spellings a reader might type for a surah, beyond what
    /// `SearchNormalizer.nameKey` already folds from the englishName
    /// (doubled vowels, articles, a trailing "h").
    static let surahAliases: [Int: [String]] = [
        1: ["Fatiha", "Hamd", "Umm al-Kitab", "Sab al-Mathani"],
        3: ["Ale Imran", "Al Imran"],
        9: ["Tauba", "Taubah", "Baraah", "Bara'ah"],
        10: ["Younus", "Yunis"],
        12: ["Yousuf", "Yusef"],
        17: ["Bani Israil", "Bani Israel", "Isra"],
        19: ["Mariam"],
        20: ["Ta Ha"],
        31: ["Lukman"],
        35: ["Malaika", "Malaikah"],
        36: ["Ya Sin", "Yasin"],
        40: ["Mumin", "Al-Mumin"],
        41: ["Ha Mim Sajdah", "Hamim Sajdah", "Fussilat"],
        47: ["Qital"],
        51: ["Zariyat", "Dhariyat"],
        56: ["Waqiya", "Waqiah"],
        60: ["Mumtahinah", "Mumtahina"],
        62: ["Jumah", "Juma", "Jummah", "Jumuah"],
        67: ["Tabarak"],
        68: ["Nun"],
        76: ["Dahr", "Insan"],
        92: ["Layl"],
        93: ["Duha", "Zuha"],
        94: ["Inshirah", "Alam Nashrah", "Sharh"],
        96: ["Iqra"],
        99: ["Zilzal", "Zilzaal"],
        106: ["Quraysh"],
        108: ["Kausar", "Kauthar", "Kawsar"],
        111: ["Lahab", "Tabbat"],
        112: ["Tawhid", "Tauheed", "Ikhlas"],
    ]

    // MARK: - Named verses

    struct NamedVerse {
        let surah: Int
        let verse: Int
        /// Display name on the top-hit card.
        let name: String
        /// Everything a reader might type for it (the name included).
        let aliases: [String]
    }

    static let namedVerses: [NamedVerse] = [
        NamedVerse(surah: 1, verse: 1, name: "Bismillah",
                   aliases: ["Bismillah", "Basmala", "Basmalah", "Bismillah ir Rahman ir Rahim"]),
        NamedVerse(surah: 2, verse: 156, name: "Istirja",
                   aliases: ["Istirja", "Inna lillahi wa inna ilayhi rajiun", "Inna lillahi"]),
        NamedVerse(surah: 2, verse: 201, name: "Rabbana Atina",
                   aliases: ["Rabbana Atina", "Rabbana atina fid dunya hasanah"]),
        NamedVerse(surah: 2, verse: 207, name: "Ayat al-Shira",
                   aliases: ["Ayat al-Shira", "Shira", "Laylat al-Mabit", "Mabit"]),
        NamedVerse(surah: 2, verse: 255, name: "Ayat al-Kursi",
                   aliases: ["Ayat al-Kursi", "Ayatul Kursi", "Kursi", "Throne Verse", "Verse of the Throne"]),
        NamedVerse(surah: 2, verse: 285, name: "Amana al-Rasul",
                   aliases: ["Amana al-Rasul", "Amanar Rasul", "Last verses of Baqara"]),
        NamedVerse(surah: 3, verse: 61, name: "Ayat al-Mubahala",
                   aliases: ["Ayat al-Mubahala", "Mubahala", "Mubahalah", "Verse of Mubahala"]),
        NamedVerse(surah: 3, verse: 173, name: "Hasbunallah",
                   aliases: ["Hasbunallah", "Hasbunallahu wa nimal wakil"]),
        NamedVerse(surah: 4, verse: 59, name: "Ayat Uli al-Amr",
                   aliases: ["Ayat Uli al-Amr", "Uli al-Amr", "Ulil Amr", "Those vested with authority"]),
        NamedVerse(surah: 5, verse: 3, name: "Ayat al-Ikmal",
                   aliases: ["Ayat al-Ikmal", "Ikmal", "Verse of Completion", "Perfection of religion"]),
        NamedVerse(surah: 5, verse: 55, name: "Ayat al-Wilayah",
                   aliases: ["Ayat al-Wilayah", "Wilayah Verse", "Verse of Wilayah", "Verse of Guardianship"]),
        NamedVerse(surah: 5, verse: 67, name: "Ayat al-Tabligh",
                   aliases: ["Ayat al-Tabligh", "Tabligh", "Verse of Conveyance"]),
        NamedVerse(surah: 21, verse: 87, name: "Ayat al-Karima",
                   aliases: ["Ayat al-Karima", "Ayatul Karima", "Dua Yunus", "La ilaha illa anta subhanaka"]),
        NamedVerse(surah: 24, verse: 35, name: "Ayat al-Nur",
                   aliases: ["Ayat al-Nur", "Ayatun Nur", "Light Verse", "Verse of Light"]),
        NamedVerse(surah: 33, verse: 33, name: "Ayat al-Tathir",
                   aliases: ["Ayat al-Tathir", "Tathir", "Verse of Purification", "Purification Verse"]),
        NamedVerse(surah: 33, verse: 56, name: "Ayat al-Salawat",
                   aliases: ["Ayat al-Salawat", "Salawat", "Durood", "Verse of Salawat"]),
        NamedVerse(surah: 42, verse: 23, name: "Ayat al-Mawadda",
                   aliases: ["Ayat al-Mawadda", "Mawadda", "Mawaddah", "Verse of Love for Kin"]),
        NamedVerse(surah: 65, verse: 2, name: "Ayat al-Rizq",
                   aliases: ["Ayat al-Rizq", "Wa man yattaqillah"]),
        NamedVerse(surah: 76, verse: 8, name: "Ayat al-Itam",
                   aliases: ["Ayat al-Itam", "Itam", "Verse of Feeding"]),
    ]

    /// Words too generic to single out a named verse on their own
    /// ("verse" would otherwise match every entry above).
    static let genericNamedVerseWords: Set<String> = [
        "ayat", "ayah", "aya", "ayatul", "ayatun", "verse", "verses", "of", "the", "al", "and", "for", "dua",
    ]

    // MARK: - Terms

    /// Names the translation spells one way that readers spell another. Each
    /// group is matched both ways, as whole words only (so "isa" never matches
    /// "Isaac").
    static let equivalentNames: [[String]] = [
        ["musa", "moses"], ["isa", "jesus"], ["ibrahim", "abraham"], ["yusuf", "joseph"],
        ["nuh", "noah"], ["maryam", "mary"], ["harun", "aaron"], ["dawud", "dawood", "david"],
        ["sulayman", "sulaiman", "solomon"], ["yunus", "jonah"], ["ayyub", "job"],
        ["ismail", "ishmael"], ["ishaq", "isaac"], ["yaqub", "jacob"], ["lut", "lot"],
        ["zakariya", "zakariyya", "zechariah"], ["yahya", "john"], ["jibril", "jibrail", "gabriel"],
        ["shaytan", "shaitan", "satan"], ["firawn", "firaun", "pharaoh"], ["qarun", "korah"],
        ["talut", "saul"], ["jalut", "goliath"], ["yajuj", "gog"], ["majuj", "magog"],
        ["kaaba", "kabah"], ["makka", "makkah", "mecca"], ["madina", "madinah", "medina", "yathrib"],
        ["quran", "koran"], ["quraish", "quraysh"],
    ]

    /// Arabic or Urdu terms mapped to the translation's English words. The
    /// English words match at word starts ("pray" also finds "prayers"); the
    /// reverse (an English word reaching the term itself, e.g. "patience" finding
    /// a theme titled "Sabr") is whole-word only.
    static let termExpansions: [String: [String]] = [
        "sabr": ["patience", "patient", "steadfast", "forbearing"],
        "salah": ["prayer", "pray"], "salat": ["prayer", "pray"], "namaz": ["prayer", "pray"],
        "sawm": ["fast"], "siyam": ["fast"], "roza": ["fast"],
        "zakah": ["zakat"],
        "sadaqah": ["charity", "charities"], "sadaqa": ["charity", "charities"],
        "taqwa": ["godwary", "godwariness"],
        "jannah": ["paradise", "garden"], "jannat": ["paradise", "garden"],
        "jahannam": ["hell"],
        "tawbah": ["repent", "repentance"], "tauba": ["repent", "repentance"],
        "rahmah": ["mercy", "merciful"], "rahma": ["mercy", "merciful"],
        "shukr": ["grateful", "gratitude", "thank"],
        "tawakkul": ["trust"],
        "wilayah": ["guardian", "awliya", "wali"], "wilayat": ["guardian", "awliya", "wali"],
        "ahlulbayt": ["household"], "ahlalbayt": ["household"], "ahl al-bayt": ["household"],
        "dua": ["supplicate", "supplication", "invoke"],
        "dhikr": ["remembrance", "remember"], "zikr": ["remembrance", "remember"],
        "ikhlas": ["sincere", "exclusively"],
        "shirk": ["polytheist", "polytheism", "partners"],
        "mushrik": ["polytheist"], "mushrikun": ["polytheist"],
        "kufr": ["faithless", "unfaith"], "kafir": ["faithless"], "kuffar": ["faithless"],
        "munafiq": ["hypocrite", "hypocrisy"], "munafiqun": ["hypocrite", "hypocrisy"], "nifaq": ["hypocrisy", "hypocrite"],
        "iman": ["faith"], "mumin": ["faithful"], "muminun": ["faithful"],
        "akhirah": ["hereafter"], "akhira": ["hereafter"],
        "dunya": ["world"],
        "qiyamah": ["resurrection"], "qiyamat": ["resurrection"],
        "malaika": ["angel"], "malaikah": ["angel"], "malak": ["angel"],
        "rasul": ["apostle"], "nabi": ["prophet"], "anbiya": ["prophet"],
        "kitab": ["book", "scripture"],
        "riba": ["usury"],
        "halal": ["lawful"], "haram": ["unlawful", "forbidden"],
        "khums": ["fifth"],
        "zulm": ["wrong", "injustice"], "dhulm": ["wrong", "injustice"],
        "adl": ["justice", "just"],
        "ilm": ["knowledge"], "hikmah": ["wisdom"], "hikma": ["wisdom"],
        "nur": ["light"], "ruh": ["spirit"], "nafs": ["soul", "self"], "qalb": ["heart"],
        "sirat": ["path"], "hidayah": ["guidance", "guide"], "huda": ["guidance", "guide"],
        "fitnah": ["trial", "test"], "fitna": ["trial", "test"],
        "barakah": ["blessing", "blessed"], "baraka": ["blessing", "blessed"],
        "rizq": ["provision"], "ghayb": ["unseen"], "arsh": ["throne"],
        "imamah": ["imam", "leaders"], "imamat": ["imam", "leaders"],
        "sujud": ["prostrate", "prostration"], "sajdah": ["prostrate", "prostration"],
        "ruku": ["bow", "bowing"], "qibla": ["qiblah"],
        "hajj": ["pilgrimage", "hajj"], "umrah": ["umrah"],
        "jihad": ["jihad", "strive"],
        "yateem": ["orphan"], "yatim": ["orphan"],
        "ummah": ["nation", "community"],
        "shahid": ["witness", "martyr"], "shuhada": ["witness", "martyr"],
        "ruhulqudus": ["holy spirit"], "ruh al-qudus": ["holy spirit"],
    ]
}
