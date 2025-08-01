//
//  Verse.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import Foundation

struct Verse: Identifiable, Codable, Hashable {
    let id: String
    let surahId: Int
    let ayahNumber: Int
    let arabicText: String
    let translation: String
    let transliteration: String?
    
    init(surahId: Int, ayahNumber: Int, arabicText: String, translation: String, transliteration: String? = nil) {
        self.id = "\(surahId):\(ayahNumber)"
        self.surahId = surahId
        self.ayahNumber = ayahNumber
        self.arabicText = arabicText
        self.translation = translation
        self.transliteration = transliteration
    }
    
}