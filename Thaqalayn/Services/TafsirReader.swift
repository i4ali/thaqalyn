//
//  TafsirReader.swift
//  Thaqalayn
//
//  Text-to-speech service for reading tafsir commentary with word highlighting
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class TafsirReader: NSObject, ObservableObject {
    static let shared = TafsirReader()

    // MARK: - Published Properties
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var highlightRange: NSRange?
    @Published var currentText: String = ""

    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?

    // MARK: - Initialization
    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public Methods

    /// Start speaking the provided text
    func speak(text: String) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Reset state
        currentText = text
        highlightRange = nil

        // Create utterance with British male voice (Daniel)
        let utterance = AVSpeechUtterance(string: text)
        let britishMaleVoice = AVSpeechSynthesisVoice.speechVoices()
            .first { $0.language == "en-GB" && $0.gender == .male }
        utterance.voice = britishMaleVoice ?? AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        currentUtterance = utterance
        isPlaying = true
        isPaused = false

        synthesizer.speak(utterance)
    }

    /// Pause the current speech
    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPlaying = false
        isPaused = true
    }

    /// Resume paused speech
    func resume() {
        guard isPaused else { return }
        synthesizer.continueSpeaking()
        isPlaying = true
        isPaused = false
    }

    /// Stop speech completely and reset state
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        isPaused = false
        highlightRange = nil
        currentText = ""
        currentUtterance = nil
    }

    /// Toggle between play/pause states
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else if isPaused {
            resume()
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TafsirReader: AVSpeechSynthesizerDelegate {

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.highlightRange = characterRange
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isPlaying = false
            self.isPaused = false
            self.highlightRange = nil
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isPlaying = false
            self.isPaused = false
            self.highlightRange = nil
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didPause utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isPlaying = false
            self.isPaused = true
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didContinue utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.isPlaying = true
            self.isPaused = false
        }
    }
}
