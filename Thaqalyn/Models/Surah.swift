//
//  Surah.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import Foundation

struct Surah: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let type: SurahType
    let numberOfAyahs: Int
    let revelationOrder: Int
    
    enum SurahType: String, Codable, CaseIterable {
        case meccan = "Meccan"
        case medinan = "Medinan"
    }
    
    // Sample data for development - will be replaced with API data
    static let all: [Surah] = [
        Surah(id: 1, name: "الفاتحة", transliteration: "Al-Fatihah", translation: "The Opening", type: .meccan, numberOfAyahs: 7, revelationOrder: 5),
        Surah(id: 2, name: "البقرة", transliteration: "Al-Baqarah", translation: "The Cow", type: .medinan, numberOfAyahs: 286, revelationOrder: 87),
        Surah(id: 3, name: "آل عمران", transliteration: "Ali 'Imran", translation: "Family of Imran", type: .medinan, numberOfAyahs: 200, revelationOrder: 89),
        Surah(id: 4, name: "النساء", transliteration: "An-Nisa", translation: "The Women", type: .medinan, numberOfAyahs: 176, revelationOrder: 92),
        Surah(id: 5, name: "المائدة", transliteration: "Al-Ma'idah", translation: "The Table Spread", type: .medinan, numberOfAyahs: 120, revelationOrder: 112),
        Surah(id: 6, name: "الأنعام", transliteration: "Al-An'am", translation: "The Cattle", type: .meccan, numberOfAyahs: 165, revelationOrder: 55),
        Surah(id: 7, name: "الأعراف", transliteration: "Al-A'raf", translation: "The Heights", type: .meccan, numberOfAyahs: 206, revelationOrder: 39),
        Surah(id: 8, name: "الأنفال", transliteration: "Al-Anfal", translation: "The Spoils of War", type: .medinan, numberOfAyahs: 75, revelationOrder: 88),
        Surah(id: 9, name: "التوبة", transliteration: "At-Tawbah", translation: "The Repentance", type: .medinan, numberOfAyahs: 129, revelationOrder: 113),
        Surah(id: 10, name: "يونس", transliteration: "Yunus", translation: "Jonah", type: .meccan, numberOfAyahs: 109, revelationOrder: 51),
        Surah(id: 11, name: "هود", transliteration: "Hud", translation: "Hud", type: .meccan, numberOfAyahs: 123, revelationOrder: 52),
        Surah(id: 12, name: "يوسف", transliteration: "Yusuf", translation: "Joseph", type: .meccan, numberOfAyahs: 111, revelationOrder: 53),
        Surah(id: 13, name: "الرعد", transliteration: "Ar-Ra'd", translation: "The Thunder", type: .medinan, numberOfAyahs: 43, revelationOrder: 96),
        Surah(id: 14, name: "إبراهيم", transliteration: "Ibrahim", translation: "Abraham", type: .meccan, numberOfAyahs: 52, revelationOrder: 72),
        Surah(id: 15, name: "الحجر", transliteration: "Al-Hijr", translation: "The Rocky Tract", type: .meccan, numberOfAyahs: 99, revelationOrder: 54),
        Surah(id: 16, name: "النحل", transliteration: "An-Nahl", translation: "The Bee", type: .meccan, numberOfAyahs: 128, revelationOrder: 70),
        Surah(id: 17, name: "الإسراء", transliteration: "Al-Isra", translation: "The Night Journey", type: .meccan, numberOfAyahs: 111, revelationOrder: 50),
        Surah(id: 18, name: "الكهف", transliteration: "Al-Kahf", translation: "The Cave", type: .meccan, numberOfAyahs: 110, revelationOrder: 69),
        Surah(id: 19, name: "مريم", transliteration: "Maryam", translation: "Mary", type: .meccan, numberOfAyahs: 98, revelationOrder: 44),
        Surah(id: 20, name: "طه", transliteration: "Ta-Ha", translation: "Ta-Ha", type: .meccan, numberOfAyahs: 135, revelationOrder: 45)
    ]
}