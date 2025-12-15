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

    // Cycle to next language in the list
    func toggleLanguage() {
        let allCases = CommentaryLanguage.allCases
        guard let currentIndex = allCases.firstIndex(of: selectedLanguage) else {
            selectedLanguage = .english
            return
        }
        let nextIndex = (currentIndex + 1) % allCases.count
        selectedLanguage = allCases[nextIndex]
    }

    // Set specific language
    func setLanguage(_ language: CommentaryLanguage) {
        selectedLanguage = language
    }
}