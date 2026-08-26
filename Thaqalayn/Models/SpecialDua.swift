//
//  SpecialDua.swift
//  Thaqalayn
//
//  The "Duas & Ziyarat" library: the major, most-recited Shia supplications
//  (Kumayl, Ziyarat Ashura, Tawassul, Nudba, al-Ahd ...), shown parallel to the
//  short everyday Daily Duas. Each dua is a segmented text (Arabic + transliteration
//  + translation per line, plus the occasional structural note like "repeat 100x"),
//  and streams a real recitation from a remote URL. Text and recitations are courtesy
//  of Duas.org, which permits free reuse with credit.
//

import Foundation

struct SpecialDuasData: Codable {
    let duas: [SpecialDua]
}

/// One major supplication or ziyarat.
struct SpecialDua: Codable, Identifiable {
    let id: String
    let titleEn: String
    let titleAr: String
    let titleUr: String
    /// When it is traditionally recited (e.g. "Thursday nights"). English chrome.
    let whenEn: String
    /// Who it is attributed to / narrated from.
    let attributionEn: String
    /// A short "what it's for" line.
    let purposeEn: String
    /// A one-to-two sentence context blurb (reading body — scales with text size).
    let introEn: String
    /// Remote recitation stream (nil = no recording; the Listen control falls back to TTS).
    let audioUrl: String?
    /// Named reciter, when known (shown in the credit line).
    let reciterEn: String?
    /// Attribution line for the source of the text/recitation.
    let sourceCreditEn: String
    let segments: [SpecialDuaSegment]

    /// Parsed stream URL, or nil when there is no recording.
    var audioURL: URL? {
        guard let audioUrl, !audioUrl.isEmpty else { return nil }
        return URL(string: audioUrl)
    }

    /// Content lines only (excludes structural "repeat 100x" notes).
    var bodySegments: [SpecialDuaSegment] { segments.filter { $0.ar != nil } }
}

/// One line of a supplication: either a content line (Arabic + transliteration +
/// translation) or a structural instruction (`note`, e.g. "Then prostrate and say:").
struct SpecialDuaSegment: Codable {
    let ar: String?
    let tr: String?
    let en: String?
    let note: String?

    var isNote: Bool { note != nil }
}
