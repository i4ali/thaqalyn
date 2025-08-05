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
    
    init(number: Int, verse: Verse, tafsir: TafsirVerse? = nil) {
        self.id = "\(number)"
        self.number = number
        self.arabicText = verse.arabicText
        self.translation = verse.translation
        self.sajda = verse.sajda
        self.tafsir = tafsir
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