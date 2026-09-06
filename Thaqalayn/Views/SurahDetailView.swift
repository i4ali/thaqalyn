//
//  SurahDetailView.swift
//  Thaqalayn
//
//  Entry point every navigation site uses to open a surah. Since the passage
//  reader (2026-09) it is a thin wrapper over SurahPassagesView: a surah is a
//  list of its passages; targetVerse opens the passage that holds the verse.
//

import SwiftUI

struct SurahDetailView: View {
    let surahWithTafsir: SurahWithTafsir
    let targetVerse: Int?
    let targetConceptId: String?

    init(surahWithTafsir: SurahWithTafsir, targetVerse: Int? = nil, targetConceptId: String? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.targetVerse = targetVerse
        self.targetConceptId = targetConceptId
    }

    var body: some View {
        SurahPassagesView(surahWithTafsir: surahWithTafsir, targetVerse: targetVerse, targetConceptId: targetConceptId)
    }
}

struct GoToVerseSheet: View {
    let versesCount: Int
    let onGoToVerse: (Int) -> Void
    @State private var verseNumberText = ""
    @State private var errorMessage: String?
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    private var isValidVerse: Bool {
        guard let number = Int(verseNumberText) else { return false }
        return number >= 1 && number <= versesCount
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    PhosphorIcon(name: "ph-magnifying-glass", size: 40)
                        .foregroundColor(themeManager.accentColor)

                    Text("Go to Verse")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    Text("Enter a verse number (1-\(versesCount))")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.top, 20)

                // Input field
                VStack(spacing: 8) {
                    TextField("Verse number", text: $verseNumberText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AnyShapeStyle(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        }
                        .onChange(of: verseNumberText) { _, newValue in
                            // Clear error when user starts typing
                            errorMessage = nil
                            // Filter non-numeric characters
                            verseNumberText = newValue.filter { $0.isNumber }
                        }

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)

                // Go button
                Button(action: submitVerse) {
                    HStack(spacing: 8) {
                        Text("→")
                            .font(.system(size: 18))
                        Text("Go")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(themeManager.accentGradient)
                    }
                }
                .padding(.horizontal, 20)
                .disabled(verseNumberText.isEmpty)
                .opacity(verseNumberText.isEmpty ? 0.6 : 1.0)

                Spacer()
            }
            .background(
                themeManager.tertiaryBackground
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .presentationDetents([.height(280)])
        .preferredColorScheme(themeManager.colorScheme)
    }

    private func submitVerse() {
        guard let number = Int(verseNumberText) else {
            errorMessage = "Please enter a valid number"
            return
        }

        if number < 1 {
            errorMessage = "Verse number must be at least 1"
            return
        }

        if number > versesCount {
            errorMessage = "This surah only has \(versesCount) verses"
            return
        }

        onGoToVerse(number)
    }
}
