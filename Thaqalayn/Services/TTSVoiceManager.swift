//
//  TTSVoiceManager.swift
//  Thaqalayn
//
//  Manages available TTS voices per language and user voice preferences
//

import Foundation
import AVFoundation

@MainActor
class TTSVoiceManager: ObservableObject {
    static let shared = TTSVoiceManager()

    // Published for UI binding - voices grouped by commentary language
    @Published private(set) var voicesByLanguage: [CommentaryLanguage: [AVSpeechSynthesisVoice]] = [:]

    // User's selected voice identifier per language (stored in UserDefaults)
    private var selectedVoiceIds: [String: String] {
        didSet {
            UserDefaults.standard.set(selectedVoiceIds, forKey: "ttsVoiceSelections")
        }
    }

    init() {
        selectedVoiceIds = UserDefaults.standard.dictionary(forKey: "ttsVoiceSelections") as? [String: String] ?? [:]
        loadAvailableVoices()
    }

    /// Languages that have TTS support (excludes French since no French tafsir exists)
    static let supportedTTSLanguages: [CommentaryLanguage] = [.english, .arabic, .urdu]

    /// Load all available voices from the device and group by language
    func loadAvailableVoices() {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()

        voicesByLanguage = [
            .english: allVoices.filter { $0.language.hasPrefix("en") },
            .arabic: allVoices.filter { $0.language.hasPrefix("ar") },
            // Only native Urdu voices (no Hindi fallback)
            .urdu: allVoices.filter { $0.language.hasPrefix("ur") }
        ]
    }

    /// Get all available voices for a specific language
    func voicesForLanguage(_ language: CommentaryLanguage) -> [AVSpeechSynthesisVoice] {
        return voicesByLanguage[language] ?? []
    }

    /// Get the user's selected voice for a language, or a smart default
    func selectedVoice(for language: CommentaryLanguage) -> AVSpeechSynthesisVoice? {
        // Check if user has a saved preference
        if let voiceId = selectedVoiceIds[language.rawValue],
           let voice = voicesByLanguage[language]?.first(where: { $0.identifier == voiceId }) {
            return voice
        }

        // Smart defaults per language
        if let voices = voicesByLanguage[language], !voices.isEmpty {
            if language == .english {
                // Prefer Daniel (British English)
                if let daniel = voices.first(where: { $0.name == "Daniel" }) {
                    return daniel
                }
                // Fallback to any enhanced quality voice
                if let enhanced = voices.first(where: { $0.quality == .enhanced }) {
                    return enhanced
                }
            }
            return voices.first
        }

        return nil
    }

    /// Set the user's preferred voice for a language
    func setSelectedVoice(_ voice: AVSpeechSynthesisVoice, for language: CommentaryLanguage) {
        selectedVoiceIds[language.rawValue] = voice.identifier
    }

    /// Check if any voices are available for a language
    func hasVoicesAvailable(for language: CommentaryLanguage) -> Bool {
        return !(voicesByLanguage[language]?.isEmpty ?? true)
    }

    /// Get a human-readable description of a voice
    func voiceDescription(_ voice: AVSpeechSynthesisVoice) -> String {
        let quality = voice.quality == .enhanced ? "Enhanced" : "Default"
        return "\(voice.name) (\(quality))"
    }
}
