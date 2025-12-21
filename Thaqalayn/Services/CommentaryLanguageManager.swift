//
//  CommentaryLanguageManager.swift
//  Thaqalayn
//
//  Commentary language preference management for multilingual support
//

import Foundation
import SwiftUI

class CommentaryLanguageManager: ObservableObject {
    @Published var selectedLanguage: CommentaryLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "commentaryLanguage")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "commentaryLanguage") ?? "en"
        self.selectedLanguage = CommentaryLanguage(rawValue: saved) ?? .english
    }

    // Cycle to next language in the list (only supported tafsir languages)
    func toggleLanguage() {
        let supportedLanguages = CommentaryLanguage.supportedTafsirLanguages
        guard let currentIndex = supportedLanguages.firstIndex(of: selectedLanguage) else {
            selectedLanguage = .english
            return
        }
        let nextIndex = (currentIndex + 1) % supportedLanguages.count
        selectedLanguage = supportedLanguages[nextIndex]
    }

    // Set specific language
    func setLanguage(_ language: CommentaryLanguage) {
        selectedLanguage = language
    }
}