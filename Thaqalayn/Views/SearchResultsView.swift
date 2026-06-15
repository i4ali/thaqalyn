//
//  SearchResultsView.swift
//  Thaqalayn
//
//  Shared, theme-aware results for the Quran tab search. Renders Surahs / Verses /
//  Themes sections. A bare LazyVStack (host provides the ScrollView + horizontal padding).
//

import SwiftUI

struct SearchResultsView: View {
    let query: String
    let onOpenSurah: (SurahWithTafsir) -> Void
    let onOpenVerse: (_ surahNumber: Int, _ verseNumber: Int) -> Void
    let onOpenTheme: (_ surahNumber: Int, _ verseNumber: Int, _ conceptId: String) -> Void

    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @State private var results = QuranSearchResults()
    @State private var didSearch = false

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            if didSearch && results.isEmpty {
                emptyState
            } else {
                surahSection
                verseSection
                themeSection
            }
        }
        .task(id: query) {
            try? await Task.sleep(nanoseconds: 200_000_000) // debounce
            if Task.isCancelled { return }
            guard let index = dataManager.searchIndex else { return } // not ready: render nothing
            results = QuranSearchEngine.search(query, in: index)
            didSearch = true
        }
    }

    @ViewBuilder private var surahSection: some View {
        if !results.surahs.isEmpty {
            sectionLabel(QuranTabStrings.surahsLabel(lang), count: results.surahs.count)
            ForEach(results.surahs) { hit in
                Button { onOpenSurah(hit.surah) } label: {
                    ModernSurahCard(surah: hit.surah.surah)
                }
                .buttonStyle(EmPressStyle())
            }
        }
    }

    @ViewBuilder private var verseSection: some View {
        if !results.verses.isEmpty {
            sectionLabel(QuranTabStrings.versesLabel(lang), count: results.verseTotal)
            ForEach(results.verses) { hit in
                Button { onOpenVerse(hit.surahNumber, hit.verseNumber) } label: {
                    VerseResultRow(hit: hit)
                }
                .buttonStyle(EmPressStyle())
            }
            if results.verseTotal > results.verses.count {
                moreLabel(showing: results.verses.count, of: results.verseTotal)
            }
        }
    }

    @ViewBuilder private var themeSection: some View {
        if !results.themes.isEmpty {
            sectionLabel(QuranTabStrings.themesLabel(lang), count: results.themeTotal)
            ForEach(results.themes) { hit in
                Button { onOpenTheme(hit.surahNumber, hit.verseNumber, hit.conceptId) } label: {
                    ThemeResultRow(hit: hit)
                }
                .buttonStyle(EmPressStyle())
            }
            if results.themeTotal > results.themes.count {
                moreLabel(showing: results.themes.count, of: results.themeTotal)
            }
        }
    }

    private func sectionLabel(_ title: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold)).tracking(1.5)
                .foregroundColor(themeManager.accentColor)
            Text("\u{00B7} \(count)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(themeManager.tertiaryText)
            Spacer()
        }
        .padding(.top, 14).padding(.bottom, 2)
    }

    private func moreLabel(showing: Int, of total: Int) -> some View {
        Text(QuranTabStrings.showingFirst(showing, total, lang))
            .font(.system(size: 12))
            .foregroundColor(themeManager.tertiaryText)
            .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            PhosphorIcon(name: "ph-magnifying-glass", size: 28)
                .foregroundColor(themeManager.tertiaryText)
            Text(QuranTabStrings.noResults(query, lang))
                .font(.system(size: 15))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Rows

private struct VerseResultRow: View {
    let hit: VerseHit
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(hit.surahEnglishName.uppercased()) \u{00B7} \(hit.surahNumber):\(hit.verseNumber)")
                .font(.system(size: 10, weight: .bold)).tracking(1.2)
                .foregroundColor(themeManager.accentColor)
            HighlightedText(
                text: hit.snippet,
                highlightRange: hit.matchRange,
                font: .system(size: 14),
                textColor: themeManager.primaryText
            )
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }
}

private struct ThemeResultRow: View {
    let hit: ThemeHit
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(Color(hex: hit.colorHex)).frame(width: 9, height: 9)
                .shadow(color: Color(hex: hit.colorHex).opacity(0.6), radius: 4)
            Text(hit.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.primaryText)
            Spacer(minLength: 8)
            Text("\(hit.surahEnglishName) \u{00B7} \(hit.surahNumber):\(hit.verseNumber)")
                .font(.system(size: 11))
                .foregroundColor(themeManager.tertiaryText)
                .lineLimit(1)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }
}

#if DEBUG
#Preview("Results — populated") {
    ScrollView {
        SearchResultsView(query: "light", onOpenSurah: { _ in }, onOpenVerse: { _, _ in }, onOpenTheme: { _, _, _ in })
            .padding(.horizontal, 20)
    }
    .background(Color(hex: "0A1512"))
}
#endif
