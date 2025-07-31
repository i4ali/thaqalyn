//
//  TafsirContent.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import Foundation

struct TafsirContent: Identifiable, Codable, Hashable {
    let id: String
    let surah: Int
    let ayah: Int
    let layer: Int
    let content: String
    let sources: [String]
    let generatedAt: Date
    let confidenceScore: Double
    
    init(surah: Int, ayah: Int, layer: Int, content: String, sources: [String] = [], generatedAt: Date = Date(), confidenceScore: Double = 1.0) {
        self.id = "\(surah):\(ayah):\(layer)"
        self.surah = surah
        self.ayah = ayah
        self.layer = layer
        self.content = content
        self.sources = sources
        self.generatedAt = generatedAt
        self.confidenceScore = confidenceScore
    }
    
    var layerInfo: CommentaryLayerInfo {
        CommentaryLayerInfo.forLayer(layer)
    }
}

struct CommentaryLayerInfo {
    let id: Int
    let title: String
    let icon: String
    let description: String
    let fullDescription: String
    
    static func forLayer(_ layer: Int) -> CommentaryLayerInfo {
        switch layer {
        case 1:
            return CommentaryLayerInfo(
                id: 1,
                title: "Foundation",
                icon: "🏛️",
                description: "Simple explanation & context",
                fullDescription: "Simple modern language explanation, historical context (Asbab al-Nuzul), basic Arabic word meanings, and contemporary relevance."
            )
        case 2:
            return CommentaryLayerInfo(
                id: 2,
                title: "Classical",
                icon: "📚",
                description: "Traditional Shia scholars",
                fullDescription: "Tabatabai (al-Mizan) perspective, Tabrisi (Majma al-Bayan) insights, traditional Shia scholarly consensus, and historical Shia interpretations."
            )
        case 3:
            return CommentaryLayerInfo(
                id: 3,
                title: "Contemporary",
                icon: "🌍",
                description: "Modern insights & applications",
                fullDescription: "Modern Shia scholars (Makarem Shirazi, etc.), scientific correlations and modern applications, social justice themes, and interfaith dialogue perspectives."
            )
        case 4:
            return CommentaryLayerInfo(
                id: 4,
                title: "Ahlul Bayt",
                icon: "⭐",
                description: "Hadith & spiritual wisdom",
                fullDescription: "Relevant hadith from 14 Infallibles, unique Shia theological concepts (Wilayah, Imamah), spiritual and mystical dimensions, and practical applications in Shia practice."
            )
        default:
            return CommentaryLayerInfo(
                id: 1,
                title: "Foundation",
                icon: "🏛️",
                description: "Simple explanation & context",
                fullDescription: "Simple modern language explanation and basic context."
            )
        }
    }
    
    static let all: [CommentaryLayerInfo] = [
        CommentaryLayerInfo.forLayer(1),
        CommentaryLayerInfo.forLayer(2),
        CommentaryLayerInfo.forLayer(3),
        CommentaryLayerInfo.forLayer(4)
    ]
}

// API Request/Response models for tafsir generation
struct TafsirRequest: Codable {
    let surah: Int
    let ayah: Int
    let layer: Int
}

struct TafsirResponse: Codable {
    let content: String
    let sources: [String]
    let generatedAt: String
    let confidenceScore: Double
    
    func toTafsirContent(surah: Int, ayah: Int, layer: Int) -> TafsirContent {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: generatedAt) ?? Date()
        
        return TafsirContent(
            surah: surah,
            ayah: ayah,
            layer: layer,
            content: content,
            sources: sources,
            generatedAt: date,
            confidenceScore: confidenceScore
        )
    }
}