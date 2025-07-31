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
    
    // Sample verses for development
    static let samples: [Verse] = [
        Verse(
            surahId: 1,
            ayahNumber: 1,
            arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            transliteration: "Bismillahi r-rahmani r-raheem"
        ),
        Verse(
            surahId: 1,
            ayahNumber: 2,
            arabicText: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
            translation: "[All] praise is [due] to Allah, Lord of the worlds -",
            transliteration: "Alhamdu lillahi rabbi l-alameen"
        ),
        Verse(
            surahId: 1,
            ayahNumber: 3,
            arabicText: "الرَّحْمَٰنِ الرَّحِيمِ",
            translation: "The Entirely Merciful, the Especially Merciful,",
            transliteration: "Ar-rahmani r-raheem"
        ),
        Verse(
            surahId: 1,
            ayahNumber: 4,
            arabicText: "مَالِكِ يَوْمِ الدِّينِ",
            translation: "Sovereign of the Day of Recompense.",
            transliteration: "Maliki yawmi d-deen"
        ),
        Verse(
            surahId: 1,
            ayahNumber: 5,
            arabicText: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
            translation: "It is You we worship and You we ask for help.",
            transliteration: "Iyyaka na'budu wa iyyaka nasta'een"
        ),
        Verse(
            surahId: 1,
            ayahNumber: 6,
            arabicText: "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
            translation: "Guide us to the straight path -",
            transliteration: "Ihdina s-sirata l-mustaqeem"
        ),
        Verse(
            surahId: 1,
            ayahNumber: 7,
            arabicText: "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
            translation: "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.",
            transliteration: "Sirata l-ladhina an'amta alayhim ghayri l-maghdubi alayhim wa la d-dalleen"
        )
    ]
}