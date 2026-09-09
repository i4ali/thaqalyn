//
//  UnderstandingView.swift
//  Thaqalayn
//
//  The passage commentary read in full: the essay with its citation markers,
//  then verse by verse notes and narrations, perspectives where present, the
//  bibliography, and the link to the next passage. Tapping a marker, a
//  narration's source line or a bibliography row opens the source sheet.
//

import SwiftUI
import UIKit

struct UnderstandingView: View {
    let surahWithTafsir: SurahWithTafsir
    let ref: PassageRef
    let passage: Passage

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var tafsirReader = TafsirReader.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showTextSizePanel = false
    @State private var openedSource: PassageSource?

    init(surahWithTafsir: SurahWithTafsir, ref: PassageRef, passage: Passage) {
        self.surahWithTafsir = surahWithTafsir
        self.ref = ref
        self.passage = passage
    }

    // MARK: - Derived

    private var surah: Surah { surahWithTafsir.surah }

    private var scale: CGFloat { readingSettings.scale }

    private var availableLanguages: [CommentaryLanguage] { passage.essay.availableLanguages }

    /// The reader's language, or English when this passage has not been translated into it.
    private var lang: CommentaryLanguage {
        availableLanguages.contains(languageManager.selectedLanguage) ? languageManager.selectedLanguage : .english
    }

    private var isRTL: Bool { lang.isRTL }

    /// Every block of commentary text is laid out in the reader's direction, so
    /// `.leading` always means the start of the line: the right edge for Urdu and Arabic.
    private var direction: LayoutDirection { isRTL ? .rightToLeft : .leftToRight }

    private var nextRef: PassageRef? {
        dataManager.passageIndex?.next(after: ref)
    }

    private var eyebrow: String {
        "Understanding · \(surah.englishName) \(ref.rangeLabel)"
    }

    private var essayParagraphs: [String] {
        Self.paragraphs(passage.essay.text(for: lang))
    }

    private var perspectiveParagraphs: [String] {
        passage.perspectives.map { Self.paragraphs($0.text(for: lang)) } ?? []
    }

    /// Bibliography order: by marker number, so [10] follows [9] rather than [1].
    private var orderedSources: [PassageSource] {
        passage.sources.sorted { $0.number < $1.number }
    }

    private static func paragraphs(_ text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Fonts

    /// The Cormorant Garamond face behind `EmType.serif`, as a UIFont for attributed prose.
    private static func serifUIFont(_ size: CGFloat, _ weight: EmType.Weight = .medium) -> UIFont {
        UIFont(name: weight.face, size: size) ?? .systemFont(ofSize: size)
    }

    /// The italic face behind `EmType.serifItalic`.
    private static func serifItalicUIFont(_ size: CGFloat) -> UIFont {
        UIFont(name: EmType.italicFace, size: size) ?? .italicSystemFont(ofSize: size)
    }

    // MARK: - Listen

    /// One block of prose as the voice reads it: the view id of the block on screen,
    /// its text with citation markers stripped, and where it sits in `listenText`.
    private struct ListenPart {
        let id: String
        let spoken: String
        let range: NSRange
    }

    /// Everything on the screen in reading order, one part per prose block, so a
    /// spoken range can be traced back to the block that shows it.
    private var listenParts: [ListenPart] {
        var texts: [(String, String)] = []
        for (i, paragraph) in essayParagraphs.enumerated() { texts.append(("essay.\(i)", paragraph)) }
        for entry in passage.verses {
            if let heading = entry.heading { texts.append(("v\(entry.verse).heading", heading.text(for: lang))) }
            if let note = entry.note { texts.append(("v\(entry.verse).note", note.text(for: lang))) }
            for narration in entry.narrations { texts.append(("v\(entry.verse).\(narration.id)", narration.text.text(for: lang))) }
        }
        for (i, paragraph) in perspectiveParagraphs.enumerated() { texts.append(("persp.\(i)", paragraph)) }

        var parts: [ListenPart] = []
        var offset = 0
        for (id, text) in texts {
            let spoken = Self.stripMarkers(text)
            let length = (spoken as NSString).length
            parts.append(ListenPart(id: id, spoken: spoken, range: NSRange(location: offset, length: length)))
            offset += length + 2   // the "\n\n" between parts
        }
        return parts
    }

    /// The text handed to the voice; citation markers removed so it does not read numbers aloud.
    private var listenText: String {
        listenParts.map(\.spoken).joined(separator: "\n\n")
    }

    /// The block being spoken and the word within it (in marker-stripped coordinates),
    /// while this passage is playing or paused.
    private var spokenWord: (id: String, range: NSRange)? {
        guard isListeningToThis, tafsirReader.isPlaying || tafsirReader.isPaused,
              let range = tafsirReader.highlightRange,
              let part = listenParts.first(where: { NSLocationInRange(range.location, $0.range) })
        else { return nil }
        let local = NSIntersectionRange(range, part.range)
        return (part.id, NSRange(location: local.location - part.range.location, length: local.length))
    }

    private func spokenRange(in id: String) -> NSRange? {
        guard let word = spokenWord, word.id == id else { return nil }
        return word.range
    }

    private static func stripMarkers(_ text: String) -> String {
        PassageMarkup.segments(text).compactMap { segment -> String? in
            if case .text(let s) = segment { return s }
            return nil
        }.joined()
    }

    private var isListeningToThis: Bool { tafsirReader.currentText == listenText }
    private var isPlayingThis: Bool { isListeningToThis && tafsirReader.isPlaying }
    private var isPausedThis: Bool { isListeningToThis && tafsirReader.isPaused }

    private var listenLabel: String {
        if isPlayingThis { return "Pause" }
        if isPausedThis { return "Resume" }
        return "Listen"
    }

    private func toggleListen() {
        if isListeningToThis && (tafsirReader.isPlaying || tafsirReader.isPaused) {
            tafsirReader.togglePlayPause()
        } else {
            tafsirReader.speak(text: listenText, language: lang)
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if themeManager.isMidnightEmerald {
                EmeraldBackground()
            } else {
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground,
                        themeManager.tertiaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                header

                ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        titleBlock
                            .padding(.bottom, 14)

                        languagePills
                            .padding(.bottom, 18)

                        essaySection

                        verseByVerseSection
                            .padding(.top, 30)

                        perspectivesSection
                            .padding(.top, 30)

                        sourcesSection
                            .padding(.top, 30)

                        if let next = nextRef {
                            NextPassageCard(surahWithTafsir: surahWithTafsir, next: next)
                                .padding(.top, 30)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 48)
                }
                // Follow the voice: bring each block into view as the reading reaches it.
                .onChange(of: spokenWord?.id) { _, id in
                    guard let id, tafsirReader.isPlaying else { return }
                    withAnimation(.easeInOut(duration: 0.5)) { proxy.scrollTo(id, anchor: .center) }
                }
                }
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            if let n = PassageMarkup.sourceNumber(from: url) {
                openSource(n)
                return .handled
            }
            return .systemAction
        })
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 60, trailingPadding: 20)
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.22, starCount: 10)
        .sheet(item: $openedSource) { source in
            SourceSheet(source: source, passage: passage, surahName: surah.englishName)
                .presentationDetents([.medium, .large])
        }
        .onChange(of: lang) { _, _ in
            // The spoken text changed with the language; stop rather than finish the old one.
            TafsirReader.shared.stop()
        }
        .onDisappear { TafsirReader.shared.stop() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())

            Spacer()

            TextSizeButton(isPanelOpen: $showTextSizePanel)

            listenChip
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var listenChip: some View {
        Button(action: toggleListen) {
            HStack(spacing: 7) {
                Image(systemName: isPlayingThis ? "pause.fill" : "play.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text(listenLabel)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(Capsule().fill(themeManager.accentChip))
            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel(isPlayingThis ? "Pause reading" : "Listen to the commentary")
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
            Text(passage.title.text(for: lang))
                .font(EmType.serif(30, .semiBold))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .environment(\.layoutDirection, direction)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var languagePills: some View {
        if availableLanguages.count > 1 {
            HStack(spacing: 8) {
                ForEach(availableLanguages, id: \.self) { language in
                    let selected = language == lang
                    Button(action: { languageManager.setLanguage(language) }) {
                        Text(language.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selected ? themeManager.onAccentText : themeManager.accentColor)
                            .padding(.horizontal, 14)
                            .frame(height: 32)
                            .background(
                                Capsule().fill(selected ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(themeManager.accentChip))
                            )
                            .overlay(Capsule().stroke(selected ? Color.clear : themeManager.strokeColor, lineWidth: 1))
                    }
                    .buttonStyle(EmPressStyle())
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
                Spacer()
            }
        }
    }

    // MARK: - Essay and perspectives

    private var essaySection: some View {
        proseBlock(essayParagraphs, idPrefix: "essay")
    }

    @ViewBuilder
    private var perspectivesSection: some View {
        if !perspectiveParagraphs.isEmpty {
            VStack(alignment: .leading, spacing: 18) {
                EmDivider(label: "Perspectives")
                proseBlock(perspectiveParagraphs, idPrefix: "persp")
            }
        }
    }

    /// Paragraphs of reading prose with citation markers, in the reader's direction.
    private func proseBlock(_ paragraphs: [String], idPrefix: String) -> some View {
        VStack(alignment: .leading, spacing: 14 * scale) {
            ForEach(paragraphs.indices, id: \.self) { i in
                markedText(
                    paragraphs[i],
                    id: "\(idPrefix).\(i)",
                    font: Self.serifUIFont(17 * scale),
                    color: themeManager.primaryText,
                    lineSpacing: 6 * scale
                )
            }
        }
        .environment(\.layoutDirection, direction)
    }

    /// One run of prose whose "[n]" markers become tappable superscripts, and whose
    /// spoken word is highlighted while the passage is being read aloud. `id` is the
    /// block's key in `listenParts`, and its scroll anchor.
    private func markedText(_ text: String, id: String, font: UIFont, color: Color, lineSpacing: CGFloat) -> some View {
        Text(PassageMarkup.attributed(
            text, baseFont: font, color: UIColor(color), accent: UIColor(themeManager.accentColor),
            highlight: spokenRange(in: id), highlightColor: UIColor(themeManager.accentColor.opacity(0.28))))
            .tint(themeManager.accentColor)
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .id(id)
    }

    // MARK: - Verse by verse

    @ViewBuilder
    private var verseByVerseSection: some View {
        if !passage.verses.isEmpty {
            VStack(alignment: .leading, spacing: 22) {
                EmDivider(label: "Verse by verse")
                ForEach(passage.verses) { entry in
                    verseEntry(entry)
                }
            }
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }

    private func verseEntry(_ entry: PassageVerseEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                EmNumeralCircle(n: entry.verse, size: 26)
                if let heading = entry.heading {
                    markedText(
                        heading.text(for: lang),
                        id: "v\(entry.verse).heading",
                        font: Self.serifUIFont(17, .semiBold),
                        color: themeManager.primaryText,
                        lineSpacing: 0
                    )
                }
            }

            if let note = entry.note {
                markedText(
                    note.text(for: lang),
                    id: "v\(entry.verse).note",
                    font: Self.serifItalicUIFont(16 * scale),
                    color: themeManager.secondaryText,
                    lineSpacing: 5 * scale
                )
            }

            ForEach(entry.narrations) { narration in
                narrationBlock(narration, id: "v\(entry.verse).\(narration.id)")
            }
        }
    }

    /// A narration: speaker, English text and the source line, behind a thin accent rule.
    /// The verbatim Arabic and the chain live on the source sheet.
    private func narrationBlock(_ narration: Narration, id: String) -> some View {
        let source = passage.source(id: narration.source)

        return HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(themeManager.accentColor)
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 8) {
                speakerLine(narration)

                markedText(
                    narration.text.text(for: lang),
                    id: id,
                    font: Self.serifUIFont(16 * scale),
                    color: themeManager.primaryText,
                    lineSpacing: 5 * scale
                )

                if let source {
                    Button(action: { openedSource = source }) {
                        Text("Sourced · \(source.work) · \(source.locus)")
                            .emEyebrow(size: 10, tracking: 1)
                            .foregroundColor(themeManager.accentColor)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(EmPressStyle.gentle)
                    .accessibilityLabel("Open source, \(source.work)")
                }
            }
        }
        .padding(.top, 4)
    }

    private func speakerLine(_ narration: Narration) -> some View {
        var line = Text(narration.speaker)
            .font(EmType.serif(15, .semiBold))
            .foregroundColor(themeManager.primaryText)
        if let addressee = narration.addressee, !addressee.isEmpty {
            line = line + Text(" to \(addressee)")
                .font(EmType.serif(15, .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        return line
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Sources

    @ViewBuilder
    private var sourcesSection: some View {
        if !orderedSources.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                EmDivider(label: "Sources")
                VStack(spacing: 0) {
                    ForEach(Array(orderedSources.enumerated()), id: \.element.id) { i, source in
                        sourceRow(source)
                        if i < orderedSources.count - 1 {
                            Rectangle()
                                .fill(themeManager.dividerColor)
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
    }

    private func sourceRow(_ source: PassageSource) -> some View {
        Button(action: { openedSource = source }) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("[\(source.number)]")
                    .font(EmType.serif(15, .semiBold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(source.work)
                        .font(EmType.serif(16, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(source.author)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                    Text(source.locus)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle.gentle)
    }

    // MARK: - Actions

    private func openSource(_ number: Int) {
        guard let source = passage.sources.first(where: { $0.number == number }) else { return }
        openedSource = source
    }
}
