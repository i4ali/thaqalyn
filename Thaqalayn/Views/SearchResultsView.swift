//
//  SearchResultsView.swift
//  Thaqalayn
//
//  Shared, theme-aware results for the Quran tab search: a top hit (a typed
//  reference or a named verse), then Surahs, Verses, Passages and Themes. Each
//  section shows a few rows and expands in place with "Show all". A bare
//  LazyVStack (host provides the ScrollView + horizontal padding).
//

import SwiftUI

/// Where a search result leads: straight into the passage reader, so one Back
/// returns to the results.
struct SearchPassageTarget: Hashable {
    let surah: Int
    let passageIndex: Int
    /// Verse to scroll to (nil for a passage hit).
    let verse: Int?
    /// Gem to open on arrival (theme hits).
    let conceptId: String?
}

struct SearchResultsView: View {
    let query: String
    /// Read state for the surah rows' passage progress, computed once by the host
    /// list per render (see ModernSurahCard).
    let readVerseKeys: Set<String>
    let onOpen: (SearchPassageTarget) -> Void

    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var readingSettings = ReadingSettingsManager.shared
    @State private var results = QuranSearchResults()
    @State private var searchedQuery: String?
    @State private var expanded: Set<ResultSection> = []
    @State private var openThemes: Set<String> = []

    private enum ResultSection { case surahs, verses, passages, themes }

    /// Rows shown per section before "Show all".
    private static let collapsedLimit: [ResultSection: Int] = [.surahs: 3, .verses: 20, .passages: 5, .themes: 12]

    /// Re-run when the query changes or passage titles arrive after launch.
    private var taskKey: String {
        "\(query)|\(dataManager.searchIndex == nil ? -1 : dataManager.searchIndex!.passages.count)"
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            if dataManager.searchIndex == nil {
                preparingRow
            } else if searchedQuery != nil && results.isEmpty {
                emptyState
            } else {
                topHitSection
                surahSection
                verseSection
                passageSection
                themeSection
            }
        }
        .task(id: taskKey) {
            try? await Task.sleep(nanoseconds: 200_000_000) // debounce
            if Task.isCancelled { return }
            guard let index = dataManager.searchIndex else { return }
            let q = query
            let found = await Task.detached(priority: .userInitiated) {
                QuranSearchEngine.search(q, in: index)
            }.value
            if Task.isCancelled { return }
            if searchedQuery != q {
                expanded = []
                openThemes = []
            }
            results = found
            searchedQuery = q
        }
    }

    // MARK: - Navigation

    private func open(surah: Int, verse: Int, conceptId: String? = nil) {
        guard let ref = dataManager.passageIndex?.passage(surah: surah, containing: verse) else { return }
        onOpen(SearchPassageTarget(surah: surah, passageIndex: ref.index, verse: verse, conceptId: conceptId))
    }

    // MARK: - Sections

    @ViewBuilder private var topHitSection: some View {
        if let hit = results.topHit {
            Button { open(surah: hit.surahNumber, verse: hit.verseNumber) } label: {
                TopHitCard(hit: hit)
            }
            .buttonStyle(EmPressStyle())
            .padding(.top, 4)
        }
    }

    @ViewBuilder private var surahSection: some View {
        if !results.surahs.isEmpty {
            sectionLabel(QuranTabStrings.surahsLabel, count: results.surahs.count)
            // Same row as the browse list, so a surah with an "Inside the Surah"
            // experience shows the Read & Tafsir | Journey toggle here too.
            ForEach(visible(results.surahs, .surahs)) { hit in
                if let surah = dataManager.getSurah(number: hit.number) {
                    SurahListRow(surahWithTafsir: surah, readVerseKeys: readVerseKeys)
                }
            }
            showAllButton(.surahs, total: results.surahs.count)
        }
    }

    @ViewBuilder private var verseSection: some View {
        if !results.verses.isEmpty {
            sectionLabel(QuranTabStrings.versesLabel, count: results.verses.count)
            ForEach(visible(results.verses, .verses)) { hit in
                Button { open(surah: hit.surahNumber, verse: hit.verseNumber) } label: {
                    VerseResultRow(hit: hit, scale: readingSettings.scale)
                }
                .buttonStyle(EmPressStyle())
            }
            showAllButton(.verses, total: results.verses.count)
        }
    }

    @ViewBuilder private var passageSection: some View {
        if !results.passages.isEmpty {
            sectionLabel(QuranTabStrings.passagesLabel, count: results.passages.count)
            ForEach(visible(results.passages, .passages)) { hit in
                Button {
                    onOpen(SearchPassageTarget(surah: hit.surahNumber, passageIndex: hit.index,
                                               verse: nil, conceptId: nil))
                } label: {
                    PassageResultRow(hit: hit)
                }
                .buttonStyle(EmPressStyle())
            }
            showAllButton(.passages, total: results.passages.count)
        }
    }

    @ViewBuilder private var themeSection: some View {
        if !results.themes.isEmpty {
            sectionLabel(QuranTabStrings.themesLabel, count: results.themes.count)
            ForEach(visible(results.themes, .themes)) { hit in
                ThemeResultRow(
                    hit: hit,
                    isOpen: openThemes.contains(hit.id),
                    onTap: {
                        if hit.refs.count == 1, let ref = hit.refs.first {
                            open(surah: ref.surahNumber, verse: ref.verseNumber, conceptId: ref.conceptId)
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if openThemes.contains(hit.id) { openThemes.remove(hit.id) } else { openThemes.insert(hit.id) }
                            }
                        }
                    },
                    onOpenRef: { ref in
                        open(surah: ref.surahNumber, verse: ref.verseNumber, conceptId: ref.conceptId)
                    }
                )
            }
            showAllButton(.themes, total: results.themes.count)
        }
    }

    // MARK: - Pieces

    private func visible<T>(_ items: [T], _ section: ResultSection) -> [T] {
        guard !expanded.contains(section), let limit = Self.collapsedLimit[section] else { return items }
        return Array(items.prefix(limit))
    }

    @ViewBuilder private func showAllButton(_ section: ResultSection, total: Int) -> some View {
        if !expanded.contains(section), let limit = Self.collapsedLimit[section], total > limit {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { _ = expanded.insert(section) }
            } label: {
                HStack(spacing: 6) {
                    Text(QuranTabStrings.showAll(total))
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(themeManager.accentColor)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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

    private var preparingRow: some View {
        HStack(spacing: 10) {
            ProgressView().tint(themeManager.accentColor)
            Text(QuranTabStrings.preparingSearch)
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            PhosphorIcon(name: "ph-magnifying-glass", size: 28)
                .foregroundColor(themeManager.tertiaryText)
            Text(QuranTabStrings.noResults(query.trimmingCharacters(in: .whitespaces)))
                .font(.system(size: 15))
                .foregroundColor(themeManager.secondaryText)
            Text(QuranTabStrings.searchHint)
                .font(.system(size: 13))
                .foregroundColor(themeManager.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, 12)
    }
}

// MARK: - Rows

private struct TopHitCard: View {
    let hit: TopHit
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var readingSettings = ReadingSettingsManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Image(systemName: hit.name == nil ? "arrow.right.circle.fill" : "sparkles")
                    .font(.system(size: 11, weight: .bold))
                Text((hit.name ?? QuranTabStrings.goToVerse).uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(1.4)
            }
            .foregroundColor(themeManager.accentColor)
            Text("\(hit.surahEnglishName) \u{00B7} \(hit.surahNumber):\(hit.verseNumber)")
                .font(EmType.serif(20, .semiBold))
                .foregroundColor(themeManager.primaryText)
            Text(hit.preview)
                .font(.system(size: 14 * readingSettings.scale))
                .lineSpacing(3 * readingSettings.scale)
                .foregroundColor(themeManager.secondaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(themeManager.accentColor.opacity(0.45), lineWidth: 1))
    }
}

/// One verse hit: reference eyebrow and highlighted snippet. Also used by Find in this Surah.
struct VerseResultRow: View {
    let hit: VerseHit
    let scale: CGFloat
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(hit.surahEnglishName.uppercased()) \u{00B7} \(hit.surahNumber):\(hit.verseNumber)")
                .font(.system(size: 10, weight: .bold)).tracking(1.2)
                .foregroundColor(themeManager.accentColor)
            if hit.isArabic {
                HighlightedText(
                    text: hit.snippet,
                    highlightRanges: hit.highlights,
                    font: EmType.arabic(20 * scale),
                    textColor: themeManager.primaryText,
                    lineSpacing: 6 * scale
                )
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                if let translation = hit.translation {
                    Text(translation)
                        .font(.system(size: 13 * scale))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            } else {
                HighlightedText(
                    text: hit.snippet,
                    highlightRanges: hit.highlights,
                    font: .system(size: 14 * scale),
                    textColor: themeManager.primaryText,
                    lineSpacing: 4 * scale
                )
                .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }
}

private struct PassageResultRow: View {
    let hit: PassageHit
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 12) {
            Text("\u{0639}")
                .font(EmType.arabic(20))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 22)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(hit.title)
                    .font(EmType.serif(17, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(hit.surahEnglishName) \u{00B7} \(hit.surahNumber):\(hit.start == hit.end ? "\(hit.start)" : "\(hit.start) to \(hit.end)")")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.tertiaryText)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(.horizontal, 13).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }
}

private struct ThemeResultRow: View {
    let hit: ThemeHit
    let isOpen: Bool
    let onTap: () -> Void
    let onOpenRef: (QuranSearchIndex.ThemeRef) -> Void
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    Circle().fill(Color.concept(hex: hit.colorHex)).frame(width: 9, height: 9)
                        .shadow(color: Color.concept(hex: hit.colorHex).opacity(0.6), radius: 4)
                    Text(hit.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    if hit.refs.count == 1, let ref = hit.refs.first {
                        Text("\(ref.surahEnglishName) \u{00B7} \(ref.surahNumber):\(ref.verseNumber)")
                            .font(.system(size: 11))
                            .foregroundColor(themeManager.tertiaryText)
                            .lineLimit(1)
                    } else {
                        Text(QuranTabStrings.themeVerses(hit.refs.count))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(themeManager.tertiaryText)
                        Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                }
                .padding(12)
                .contentShape(Rectangle())
            }
            .buttonStyle(EmPressStyle())

            if isOpen {
                VStack(spacing: 0) {
                    ForEach(hit.refs, id: \.self) { ref in
                        Button { onOpenRef(ref) } label: {
                            HStack {
                                Text("\(ref.surahEnglishName) \u{00B7} \(ref.surahNumber):\(ref.verseNumber)")
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.secondaryText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(themeManager.tertiaryText)
                            }
                            .padding(.horizontal, 12).padding(.leading, 19).padding(.vertical, 9)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(EmPressStyle())
                    }
                }
                .padding(.bottom, 6)
            }
        }
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }
}

// MARK: - Destination

/// The passage reader a search result opens, pushed straight from the Quran
/// tab. Nil when the surah or passage can't be resolved.
struct SearchPassageDestination: View {
    private let surah: SurahWithTafsir
    private let ref: PassageRef
    private let target: SearchPassageTarget

    @MainActor init?(target: SearchPassageTarget) {
        let data = DataManager.shared
        guard let surah = data.getSurah(number: target.surah),
              let ref = data.passageIndex?.passage(surah: target.surah, index: target.passageIndex) else {
            return nil
        }
        self.surah = surah
        self.ref = ref
        self.target = target
    }

    var body: some View {
        PassageView(surahWithTafsir: surah, ref: ref, scrollToVerse: target.verse, openConceptId: target.conceptId)
    }
}
