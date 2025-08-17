//
//  CommentaryLanguageManager.swift
//  Thaqalayn
//
//  Commentary language preference management for bilingual support
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
    
    // Toggle between English and Urdu
    func toggleLanguage() {
        selectedLanguage = selectedLanguage == .english ? .urdu : .english
    }
    
    // Set specific language
    func setLanguage(_ language: CommentaryLanguage) {
        selectedLanguage = language
    }
}