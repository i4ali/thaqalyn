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
    let layer1: String
    let layer2: String
    let layer3: String
    let layer4: String
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
        bookmarkLimit: Int = 2,
        defaultTags: [String] = [],
        sortOrder: BookmarkSortOrder = .dateDescending,
        groupBy: BookmarkGroupBy = .none
    ) {
        self.userId = userId
        self.isPremium = isPremium
        self.bookmarkLimit = isPremium ? 1000 : bookmarkLimit
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
        }
    }
}