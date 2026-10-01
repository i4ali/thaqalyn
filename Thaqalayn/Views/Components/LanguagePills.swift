//
//  LanguagePills.swift
//  Thaqalayn
//
//  The reading-language capsules (English / اردو / العربية) shown under a title on
//  the bilingual reading screens (passage commentary, Miracle Stories). Selecting
//  one sets the app-wide CommentaryLanguageManager preference. Hidden when the
//  content has only one language.
//

import SwiftUI

struct LanguagePills: View {
    /// The languages this content is available in.
    let languages: [CommentaryLanguage]
    /// The language currently shown (the preference, or English when unavailable).
    let selected: CommentaryLanguage

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        if languages.count > 1 {
            HStack(spacing: 8) {
                ForEach(languages, id: \.self) { language in
                    let isSelected = language == selected
                    Button(action: { languageManager.setLanguage(language) }) {
                        Text(language.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected ? themeManager.onAccentText : themeManager.accentColor)
                            .padding(.horizontal, 14)
                            .frame(height: 32)
                            .background(
                                Capsule().fill(isSelected ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(themeManager.accentChip))
                            )
                            .overlay(Capsule().stroke(isSelected ? Color.clear : themeManager.strokeColor, lineWidth: 1))
                    }
                    .buttonStyle(EmPressStyle())
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
                Spacer()
            }
        }
    }
}
