//
//  QuranModels.swift
//  Thaqalayn
//
//  Data models for Quran and Tafsir content
//

import Foundation

// MARK: - Quran Data Models

struct QuranData: Codable {
    let surahs: [Surah]
    let verses: [String: [String: Verse]]
}

struct Surah: Codable, Identifiable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let arabicName: String
    let versesCount: Int
    let revelationType: String
    
    var id: Int { number }
    
    // Audio-related computed properties
    func audioURL(for reciter: Reciter) -> URL? {
        // Use best available quality for each reciter (full surah audio)
        let surahString = String(format: "%03d", number)
        let urlString = "\(reciter.serverURL)/\(surahString).mp3"
        return URL(string: urlString)
    }
}

struct Verse: Codable {
    let arabicText: String
    let translation: String
    let juz: Int
    let manzil: Int
    let page: Int
    let ruku: Int
    let hizbQuarter: Int
    let sajda: SajdaInfo
}

struct SajdaInfo: Codable {
    let hasSajda: Bool
    let id: Int?
    let recommended: Bool?
    
    init(hasSajda: Bool, id: Int? = nil, recommended: Bool? = nil) {
        self.hasSajda = hasSajda
        self.id = id
        self.recommended = recommended
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let boolValue = try? container.decode(Bool.self) {
            // Handle simple boolean case
            self.hasSajda = boolValue
            self.id = nil
            self.recommended = nil
        } else if let sajdaDict = try? container.decode([String: AnyCodable].self) {
            // Handle object case
            self.hasSajda = true
            self.id = sajdaDict["id"]?.value as? Int
            self.recommended = sajdaDict["recommended"]?.value as? Bool
        } else {
            throw DecodingError.typeMismatch(
                SajdaInfo.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Bool or Object for sajda")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if id != nil || recommended != nil {
            var dict = [String: AnyCodable]()
            if let id = id {
                dict["id"] = AnyCodable(id)
            }
            if let recommended = recommended {
                dict["recommended"] = AnyCodable(recommended)
            }
            try container.encode(dict)
        } else {
            try container.encode(hasSajda)
        }
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        }
    }
}

// MARK: - Tafsir Data Models

struct TafsirData: Codable {
    let verses: [String: TafsirVerse]
}

struct TafsirVerse: Codable {
    // Existing English content
    let layer1: String
    let layer2: String
    let layer3: String
    let layer4: String
    let layer5: String?

    // New Urdu content (optional for backward compatibility)
    let layer1_urdu: String?
    let layer2_urdu: String?
    let layer3_urdu: String?
    let layer4_urdu: String?
    let layer5_urdu: String?

    // Verse summaries for quick reading (optional)
    let summary: String?
    let summary_urdu: String?
    
    // Helper method to get content by language and layer
    func content(for layer: TafsirLayer, language: CommentaryLanguage) -> String {
        switch (layer, language) {
        case (.foundation, .english): return layer1
        case (.foundation, .urdu): return layer1_urdu ?? layer1
        case (.classical, .english): return layer2
        case (.classical, .urdu): return layer2_urdu ?? layer2
        case (.contemporary, .english): return layer3
        case (.contemporary, .urdu): return layer3_urdu ?? layer3
        case (.ahlulBayt, .english): return layer4
        case (.ahlulBayt, .urdu): return layer4_urdu ?? layer4
        case (.comparative, .english): return layer5 ?? ""
        case (.comparative, .urdu): return layer5_urdu ?? layer5 ?? ""
        }
    }
    
    func hasUrduContent(for layer: TafsirLayer) -> Bool {
        switch layer {
        case .foundation: return layer1_urdu != nil
        case .classical: return layer2_urdu != nil
        case .contemporary: return layer3_urdu != nil
        case .ahlulBayt: return layer4_urdu != nil
        case .comparative: return layer5_urdu != nil
        }
    }

    func getSummary(language: CommentaryLanguage) -> String? {
        switch language {
        case .english: return summary
        case .urdu: return summary_urdu ?? summary
        }
    }

    var hasSummary: Bool {
        return summary != nil
    }
}

// MARK: - Display Models

struct SurahWithTafsir: Identifiable {
    let id: Int
    let surah: Surah
    let verses: [VerseWithTafsir]
    
    init(surah: Surah, verses: [VerseWithTafsir]) {
        self.id = surah.number
        self.surah = surah
        self.verses = verses
    }
}

struct VerseWithTafsir: Identifiable {
    let id: String
    let number: Int
    let arabicText: String
    let translation: String
    let sajda: SajdaInfo
    let tafsir: TafsirVerse?
    
    var bookmarkKey: String {
        return id
    }
    
    // Audio-related computed properties
    func audioURL(for surahNumber: Int, reciter: Reciter) -> URL? {
        let surahString = String(format: "%03d", surahNumber)
        let verseString = String(format: "%03d", number)
        
        // Use EveryAyah.com for individual verse audio with best available quality for each reciter
        switch reciter.id {
        case "mishary_rashid_alafasy":
            // Use highest available quality (128kbps)
            let urlString = "https://www.everyayah.com/data/Alafasy_128kbps/\(surahString)\(verseString).mp3"
            return URL(string: urlString)
            
        case "abdul_rahman_al_sudais":
            // Use highest available quality (192kbps)
            let urlString = "https://www.everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/\(surahString)\(verseString).mp3"
            return URL(string: urlString)
            
        case "saad_al_ghamidi":
            // Only 40kbps available for Ghamadi
            let urlString = "https://www.everyayah.com/data/Ghamadi_40kbps/\(surahString)\(verseString).mp3"
            return URL(string: urlString)
            
        case "ahmad_ibn_ali_al_ajamy":
            // Use highest available quality (128kbps)
            let urlString = "https://www.everyayah.com/data/ahmed_ibn_ali_al_ajamy_128kbps/\(surahString)\(verseString).mp3"
            return URL(string: urlString)
            
        case "maher_al_muaiqly":
            // Use highest available quality (128kbps)
            let urlString = "https://www.everyayah.com/data/MaherAlMuaiqly128kbps/\(surahString)\(verseString).mp3"
            return URL(string: urlString)
            
        case "yasser_al_dosari":
            // Only 128kbps available for Yasser Ad-Dussary
            let urlString = "https://www.everyayah.com/data/Yasser_Ad-Dussary_128kbps/\(surahString)\(verseString).mp3"
            return URL(string: urlString)
            
        default:
            // Fall back to full surah audio for other reciters
            let surahOnlyString = String(format: "%03d", surahNumber)
            let urlString = "\(reciter.serverURL)/\(surahOnlyString).mp3"
            return URL(string: urlString)
        }
    }
    
    init(number: Int, verse: Verse, tafsir: TafsirVerse? = nil) {
        self.id = "\(number)"
        self.number = number
        self.arabicText = verse.arabicText
        self.translation = verse.translation
        self.sajda = verse.sajda
        self.tafsir = tafsir
    }
}

// MARK: - Bookmark Models

struct Bookmark: Codable, Identifiable {
    let id: UUID
    let userId: String
    let surahNumber: Int
    let verseNumber: Int
    let surahName: String
    let verseText: String
    let verseTranslation: String
    let notes: String?
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    let syncStatus: BookmarkSyncStatus
    
    var verseReference: String {
        return "\(surahNumber):\(verseNumber)"
    }
    
    init(
        id: UUID = UUID(),
        userId: String,
        surahNumber: Int,
        verseNumber: Int,
        surahName: String,
        verseText: String,
        verseTranslation: String,
        notes: String? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: BookmarkSyncStatus = .synced
    ) {
        self.id = id
        self.userId = userId
        self.surahNumber = surahNumber
        self.verseNumber = verseNumber
        self.surahName = surahName
        self.verseText = verseText
        self.verseTranslation = verseTranslation
        self.notes = notes
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}

enum BookmarkSyncStatus: String, Codable {
    case synced = "synced"
    case pendingSync = "pending_sync"
    case pendingDelete = "pending_delete"
    case conflict = "conflict"
}

struct BookmarkCollection: Codable, Identifiable {
    let id: UUID
    let userId: String
    let name: String
    let description: String?
    let bookmarkIds: [UUID]
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        userId: String,
        name: String,
        description: String? = nil,
        bookmarkIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.bookmarkIds = bookmarkIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct UserBookmarkPreferences: Codable {
    let userId: String
    let isPremium: Bool
    let bookmarkLimit: Int
    let defaultTags: [String]
    let sortOrder: BookmarkSortOrder
    let groupBy: BookmarkGroupBy
    
    init(
        userId: String,
        isPremium: Bool = false,
        bookmarkLimit: Int = 10,
        defaultTags: [String] = [],
        sortOrder: BookmarkSortOrder = .dateDescending,
        groupBy: BookmarkGroupBy = .none
    ) {
        self.userId = userId
        self.isPremium = isPremium
        self.bookmarkLimit = 10 // Standard limit for all users
        self.defaultTags = defaultTags
        self.sortOrder = sortOrder
        self.groupBy = groupBy
    }
}

enum BookmarkSortOrder: String, Codable, CaseIterable {
    case dateAscending = "date_asc"
    case dateDescending = "date_desc"
    case surahOrder = "surah_order"
    case alphabetical = "alphabetical"
    
    var title: String {
        switch self {
        case .dateAscending: return "Oldest First"
        case .dateDescending: return "Newest First"
        case .surahOrder: return "Quran Order"
        case .alphabetical: return "Alphabetical"
        }
    }
}

enum BookmarkGroupBy: String, Codable, CaseIterable {
    case none = "none"
    case surah = "surah"
    case tags = "tags"
    case date = "date"
    
    var title: String {
        switch self {
        case .none: return "No Grouping"
        case .surah: return "By Surah"
        case .tags: return "By Tags"
        case .date: return "By Date"
        }
    }
}

// MARK: - Tafsir Layer Types

enum TafsirLayer: String, CaseIterable {
    case foundation = "layer1"
    case classical = "layer2"
    case contemporary = "layer3"
    case ahlulBayt = "layer4"
    case comparative = "layer5"
    
    var title: String {
        switch self {
        case .foundation:
            return "🏛️ Foundation"
        case .classical:
            return "📚 Classical Shia"
        case .contemporary:
            return "🌍 Contemporary"
        case .ahlulBayt:
            return "⭐ Ahlul Bayt"
        case .comparative:
            return "⚖️ Comparative"
        }
    }
    
    var description: String {
        switch self {
        case .foundation:
            return "Simple explanations, historical context, contemporary relevance"
        case .classical:
            return "Tabatabai, Tabrisi, traditional scholarly consensus"
        case .contemporary:
            return "Modern scholars, scientific insights, social justice themes"
        case .ahlulBayt:
            return "Hadith from Imams, theological concepts, spiritual guidance"
        case .comparative:
            return "Shia vs Sunni scholarly perspectives"
        }
    }

    /// Check if this layer is free for a given surah
    /// - Surah 1: Layers 1 & 2 are free
    /// - All other surahs: No free layers
    func isFree(forSurah surahNumber: Int) -> Bool {
        if surahNumber == 1 {
            return self == .foundation || self == .classical
        }
        return false
    }
}

// MARK: - Commentary Language Support

enum CommentaryLanguage: String, CaseIterable, Codable {
    case english = "en"
    case urdu = "ur"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .urdu: return "اردو"
        }
    }

    var isRTL: Bool {
        return self == .urdu
    }
}

// MARK: - Daily Verse Notification Models

struct IslamicMonthVerseData: Codable {
    let months: [IslamicMonth]
}

struct IslamicMonth: Codable {
    let month: Int
    let name: String
    let arabicName: String
    let theme: String
    let significance: String
    let verses: [DailyVerseEntry]
}

struct DailyVerseEntry: Codable, Identifiable {
    let surah: Int
    let verse: Int
    let relevance: String
    let theme: String

    var id: String {
        return "\(surah):\(verse)"
    }
}

struct NotificationPreferences: Codable {
    var enabled: Bool
    var time: Date
    var language: CommentaryLanguage
    var includeTafsir: Bool

    init(
        enabled: Bool = false,
        time: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        language: CommentaryLanguage = .english,
        includeTafsir: Bool = true
    ) {
        self.enabled = enabled
        self.time = time
        self.language = language
        self.includeTafsir = includeTafsir
    }

    enum CodingKeys: String, CodingKey {
        case enabled, time, language, includeTafsir
    }
}

// MARK: - Progress Tracking Models

struct VerseProgress: Codable, Identifiable {
    let id: UUID
    let surahNumber: Int
    let verseNumber: Int
    let readDate: Date
    let isRead: Bool

    var verseKey: String {
        return "\(surahNumber):\(verseNumber)"
    }

    init(
        id: UUID = UUID(),
        surahNumber: Int,
        verseNumber: Int,
        readDate: Date = Date(),
        isRead: Bool = true
    ) {
        self.id = id
        self.surahNumber = surahNumber
        self.verseNumber = verseNumber
        self.readDate = readDate
        self.isRead = isRead
    }
}

struct ReadingStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastReadDate: Date?
    var streakStartDate: Date?

    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastReadDate: Date? = nil,
        streakStartDate: Date? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastReadDate = lastReadDate
        self.streakStartDate = streakStartDate
    }
}

struct BadgeAward: Codable, Identifiable {
    let id: UUID
    let surahNumber: Int
    let surahName: String
    let arabicName: String
    let awardedDate: Date
    let badgeType: BadgeType

    init(
        id: UUID = UUID(),
        surahNumber: Int,
        surahName: String,
        arabicName: String,
        awardedDate: Date = Date(),
        badgeType: BadgeType = .surahCompletion
    ) {
        self.id = id
        self.surahNumber = surahNumber
        self.surahName = surahName
        self.arabicName = arabicName
        self.awardedDate = awardedDate
        self.badgeType = badgeType
    }
}

enum BadgeType: String, Codable {
    case surahCompletion = "surah_completion"
    case milestone10 = "milestone_10"
    case milestone25 = "milestone_25"
    case milestone50 = "milestone_50"
    case allSurahs = "all_surahs"
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case streak100 = "streak_100"

    var title: String {
        switch self {
        case .surahCompletion: return "Khatm Surah"
        case .milestone10: return "Mubtadi"
        case .milestone25: return "Salik"
        case .milestone50: return "Murid"
        case .allSurahs: return "Waliy Allah"
        case .streak7: return "Mu'min Mutaqin"
        case .streak30: return "Sahib al-Wird"
        case .streak100: return "Mukhlis"
        }
    }

    var subtitle: String {
        switch self {
        case .surahCompletion: return "ختم السورة"
        case .milestone10: return "المبتدئ"
        case .milestone25: return "السالك"
        case .milestone50: return "المريد"
        case .allSurahs: return "ولي الله"
        case .streak7: return "مؤمن متقين"
        case .streak30: return "صاحب الورد"
        case .streak100: return "المخلص"
        }
    }

    var icon: String {
        switch self {
        case .surahCompletion: return "checkmark.seal.fill"
        case .milestone10: return "book.closed.fill"
        case .milestone25: return "star.fill"
        case .milestone50: return "sparkles"
        case .allSurahs: return "star.circle.fill"
        case .streak7: return "flame.fill"
        case .streak30: return "sparkles"
        case .streak100: return "crown.fill"
        }
    }

    var color: String {
        switch self {
        case .surahCompletion: return "green"
        case .milestone10: return "blue"
        case .milestone25: return "purple"
        case .milestone50: return "orange"
        case .allSurahs: return "gold"
        case .streak7: return "orange"
        case .streak30: return "green"
        case .streak100: return "purple"
        }
    }

    var description: String {
        switch self {
        case .surahCompletion:
            return "Completed a surah of the Noble Quran"
        case .milestone10:
            return "The Beginner - Completed 10 surahs on your journey"
        case .milestone25:
            return "The Traveler - Completed 25 surahs on the spiritual path"
        case .milestone50:
            return "The Dedicated Student - Reached the halfway mark with 50 surahs"
        case .allSurahs:
            return "Friend of Allah - Completed all 114 surahs of the Quran"
        case .streak7:
            return "Consistent Believer - Maintained 7 days of steadfast reading"
        case .streak30:
            return "Keeper of Daily Portion - 30 days of unwavering commitment"
        case .streak100:
            return "The Devoted One - 100 days of dedicated spiritual practice"
        }
    }

    var sawabValue: Int {
        switch self {
        case .surahCompletion: return 100
        case .milestone10: return 1000
        case .milestone25: return 2500
        case .milestone50: return 5000
        case .allSurahs: return 11400
        case .streak7: return 700
        case .streak30: return 3000
        case .streak100: return 10000
        }
    }

    var hadith: String? {
        switch self {
        case .surahCompletion:
            return "Whoever recites a letter from the Book of Allah will be credited with a good deed, and a good deed is multiplied into ten. - Prophet Muhammad (PBUH)"
        case .allSurahs:
            return "The best among you are those who learn the Quran and teach it. - Prophet Muhammad (PBUH)"
        case .streak7, .streak30, .streak100:
            return "Make a habit of doing good deeds, for the most beloved deed to Allah is the most regular one, even if it is small. - Imam Ali (AS)"
        default:
            return nil
        }
    }
}

struct ProgressStats: Codable {
    var totalVersesRead: Int
    var totalSurahsCompleted: Int
    var currentStreak: Int
    var longestStreak: Int
    var versesReadToday: Int
    var lastReadDate: Date?
    var startDate: Date
    var totalSawab: Int  // Total sawab (spiritual rewards) earned

    init(
        totalVersesRead: Int = 0,
        totalSurahsCompleted: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        versesReadToday: Int = 0,
        lastReadDate: Date? = nil,
        startDate: Date = Date(),
        totalSawab: Int = 0
    ) {
        self.totalVersesRead = totalVersesRead
        self.totalSurahsCompleted = totalSurahsCompleted
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.versesReadToday = versesReadToday
        self.lastReadDate = lastReadDate
        self.startDate = startDate
        self.totalSawab = totalSawab
    }
}

struct ProgressPreferences: Codable {
    var notificationsEnabled: Bool
    var celebrationsEnabled: Bool
    var showStreakInHeader: Bool

    init(
        notificationsEnabled: Bool = true,
        celebrationsEnabled: Bool = true,
        showStreakInHeader: Bool = true
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.celebrationsEnabled = celebrationsEnabled
        self.showStreakInHeader = showStreakInHeader
    }
}