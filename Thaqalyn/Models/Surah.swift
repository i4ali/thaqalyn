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
    
    // Sample data for development - will be replaced with proper Quran data
    static let all: [Surah] = [
        Surah(
            id: 1,
            name: "الفاتحة",
            transliteration: "Al-Fatihah",
            translation: "The Opening",
            type: .meccan,
            numberOfAyahs: 7,
            revelationOrder: 5
        ),
        Surah(
            id: 2,
            name: "البقرة",
            transliteration: "Al-Baqarah",
            translation: "The Cow",
            type: .medinan,
            numberOfAyahs: 286,
            revelationOrder: 87
        ),
        Surah(
            id: 3,
            name: "آل عمران",
            transliteration: "Ali 'Imran",
            translation: "Family of Imran",
            type: .medinan,
            numberOfAyahs: 200,
            revelationOrder: 89
        ),
        Surah(
            id: 4,
            name: "النساء",
            transliteration: "An-Nisa",
            translation: "The Women",
            type: .medinan,
            numberOfAyahs: 176,
            revelationOrder: 92
        ),
        Surah(
            id: 5,
            name: "المائدة",
            transliteration: "Al-Ma'idah",
            translation: "The Table Spread",
            type: .medinan,
            numberOfAyahs: 120,
            revelationOrder: 112
        )
    ]
}