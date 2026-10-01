//
//  FindInSurahSheet.swift
//  Thaqalayn
//
//  The surah hub's magnifying glass: type a verse number to jump to it, or a
//  word to list this surah's matching verses (same matching as the Quran-tab
//  search, scoped to one surah). Picking either calls onGoToVerse, which opens
//  the passage that holds the verse.
//

import SwiftUI

struct FindInSurahSheet: View {
    let surah: Surah
    let onGoToVerse: (Int) -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @State private var query = ""
    @State private var hits: [VerseHit] = []
    @State private var searchedQuery: String?

    private var trimmed: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// The query read as a verse number, when it is only digits.
    private var verseNumber: Int? {
        let digits = SearchNormalizer.foldDigits(trimmed)
        guard !digits.isEmpty, digits.allSatisfy(\.isNumber) else { return nil }
        return Int(digits)
    }

    private var isValidVerse: Bool {
        guard let n = verseNumber else { return false }
        return n >= 1 && n <= surah.versesCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(QuranTabStrings.findInSurah)
                        .font(EmType.serif(24, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(QuranTabStrings.findInSurahSubtitle(surah.versesCount))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                Spacer()
                Button(QuranTabStrings.cancel) { dismiss() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
            }

            QuranSearchField(text: $query, isFocused: $focused,
                             placeholder: QuranTabStrings.findPlaceholder,
                             onSubmit: submit)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    results
                }
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .background(themeManager.primaryBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(themeManager.colorScheme)
        .onAppear { focused = true }
        .task(id: query) {
            try? await Task.sleep(nanoseconds: 150_000_000) // debounce
            if Task.isCancelled { return }
            let q = trimmed
            guard verseNumber == nil, q.filter(\.isLetter).count >= QuranSearchEngine.minTextQueryLength,
                  let index = dataManager.searchIndex else {
                hits = []
                searchedQuery = nil
                return
            }
            let number = surah.number
            let found = await Task.detached(priority: .userInitiated) {
                QuranSearchEngine.search(q, in: index, scope: number).verses
            }.value
            if Task.isCancelled { return }
            hits = found
            searchedQuery = q
        }
    }

    @ViewBuilder private var results: some View {
        if let n = verseNumber {
            if isValidVerse {
                Button { onGoToVerse(n) } label: { goToRow(n) }
                    .buttonStyle(EmPressStyle())
            } else {
                note(QuranTabStrings.verseOutOfRange(surah.versesCount))
            }
        } else if searchedQuery != nil, hits.isEmpty {
            note(QuranTabStrings.noMatchesInSurah(trimmed))
        } else {
            ForEach(hits) { hit in
                Button { onGoToVerse(hit.verseNumber) } label: {
                    VerseResultRow(hit: hit, scale: readingSettings.scale)
                }
                .buttonStyle(EmPressStyle())
            }
        }
    }

    private func goToRow(_ n: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(themeManager.accentColor)
            Text(QuranTabStrings.goToVerseNumber(n))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            Spacer()
            Text("\(surah.number):\(n)")
                .font(.system(size: 12))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(themeManager.accentColor.opacity(0.45), lineWidth: 1))
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(themeManager.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 24)
    }

    /// Return jumps to a valid verse number, or to the only matching verse.
    private func submit() {
        if isValidVerse, let n = verseNumber {
            onGoToVerse(n)
        } else if verseNumber == nil, hits.count == 1, let only = hits.first {
            onGoToVerse(only.verseNumber)
        }
    }
}
