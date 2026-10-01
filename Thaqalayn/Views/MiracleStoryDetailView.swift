//
//  MiracleStoryDetailView.swift
//  Thaqalayn
//
//  One miracle story as a reader: the English / Urdu toggle, body text that scales
//  with the reading text-size control, and Listen. Where the story has recorded
//  narration in the chosen language (MiracleAudioPlayer, one clip per paragraph) Listen
//  plays it, highlighting the paragraph being read; otherwise it falls back to the
//  device voice with the spoken word highlighted, or hides Listen when the device has no
//  voice for the language. Either way the page follows the voice.
//  The reading chrome mirrors the passage commentary reader (UnderstandingView).
//

import SwiftUI

struct MiracleStoryDetailView: View {
    let story: MiracleStory

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var tafsirReader = TafsirReader.shared
    @ObservedObject private var voiceManager = TTSVoiceManager.shared
    @ObservedObject private var audio = MiracleAudioPlayer.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showTextSizePanel = false

    // MARK: - Derived

    private var scale: CGFloat { readingSettings.scale }

    private var availableLanguages: [CommentaryLanguage] { story.body.availableLanguages }

    /// The reader's language, or English when this story has not been translated into it.
    private var lang: CommentaryLanguage {
        availableLanguages.contains(languageManager.selectedLanguage) ? languageManager.selectedLanguage : .english
    }

    /// Every block of story text is laid out in the reader's direction, so
    /// `.leading` always means the start of the line: the right edge for Urdu.
    private var direction: LayoutDirection { lang.isRTL ? .rightToLeft : .leftToRight }

    private var bodyParagraphs: [String] { Self.paragraphs(story.body.text(for: lang)) }

    private var closingParagraphs: [String] {
        story.closing.map { Self.paragraphs($0.text(for: lang)) } ?? []
    }

    static func paragraphs(_ text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// The Cormorant Garamond face behind `EmType.serif`, as a UIFont for attributed prose.
    private static func serifUIFont(_ size: CGFloat) -> UIFont {
        UIFont(name: EmType.Weight.medium.face, size: size) ?? .systemFont(ofSize: size)
    }

    // MARK: - Listen

    /// One paragraph as the voice reads it: its view id and where it sits in `listenText`.
    private struct ListenPart {
        let id: String
        let range: NSRange
    }

    private var listenTexts: [(id: String, text: String)] { story.paragraphs(for: lang) }

    /// Every paragraph in reading order, so a spoken range can be traced back to it.
    private var listenParts: [ListenPart] {
        var parts: [ListenPart] = []
        var offset = 0
        for (id, text) in listenTexts {
            let length = (text as NSString).length
            parts.append(ListenPart(id: id, range: NSRange(location: offset, length: length)))
            offset += length + 2   // the "\n\n" between parts
        }
        return parts
    }

    private var listenText: String {
        listenTexts.map(\.text).joined(separator: "\n\n")
    }

    /// The paragraph being spoken and the word within it, while this story is playing or paused.
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

    private var isListeningToThis: Bool { tafsirReader.currentText == listenText }
    private var isPlayingThis: Bool { isListeningToThis && tafsirReader.isPlaying }
    private var isPausedThis: Bool { isListeningToThis && tafsirReader.isPaused }

    /// Recorded narration exists for this story in the reader's language.
    private var usesRecording: Bool { MiracleAudioPlayer.hasRecording(story, language: lang) }

    /// Listen needs a recording or a device voice for the language on screen. Without
    /// either (Urdu with no recording, on most devices) the chip is hidden rather than
    /// reading in the wrong voice or not at all.
    private var canListen: Bool { usesRecording || voiceManager.hasVoicesAvailable(for: lang) }

    /// The recording's state for this story and language (idle while another is loaded).
    private var recordingPhase: MiracleAudioPlayer.Phase {
        audio.isCurrent(story, language: lang) ? audio.phase : .idle
    }

    /// The paragraph the recording is reading, while it is playing or paused.
    private var recordedParagraphId: String? {
        switch recordingPhase {
        case .playing, .paused: return audio.currentParagraphId
        default: return nil
        }
    }

    /// The block the page follows: the recorded paragraph, or the device voice's word.
    private var followId: String? { usesRecording ? recordedParagraphId : spokenWord?.id }

    private var isVoicePlaying: Bool { usesRecording ? recordingPhase == .playing : isPlayingThis }

    private var listenLabel: String {
        if usesRecording {
            switch recordingPhase {
            case .playing: return "Pause"
            case .paused: return "Resume"
            case .preparing(let progress): return progress > 0 ? "Preparing \(Int(progress * 100))%" : "Preparing"
            case .failed: return "Retry"
            case .idle: return "Listen"
            }
        }
        if isPlayingThis { return "Pause" }
        if isPausedThis { return "Resume" }
        return "Listen"
    }

    private var listenIcon: String {
        switch usesRecording ? recordingPhase : .idle {
        case .preparing: return "arrow.down.circle"
        case .failed: return "arrow.clockwise"
        default: return isVoicePlaying ? "pause.fill" : "play.fill"
        }
    }

    private func toggleListen() {
        if usesRecording {
            audio.toggle(story, language: lang)
        } else if isListeningToThis && (tafsirReader.isPlaying || tafsirReader.isPaused) {
            tafsirReader.togglePlayPause()
        } else {
            tafsirReader.speak(text: listenText, language: lang)
        }
    }

    private func stopListening() {
        TafsirReader.shared.stop()
        if audio.storyId == story.id { audio.stop() }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            EmeraldBackground()

            VStack(spacing: 0) {
                header

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            titleBlock
                                .padding(.bottom, 14)

                            LanguagePills(languages: availableLanguages, selected: lang)
                                .padding(.bottom, 18)

                            proseBlock(bodyParagraphs, idPrefix: "body")

                            if !closingParagraphs.isEmpty {
                                VStack(alignment: .leading, spacing: 18) {
                                    EmDivider(label: "How the vow is kept")
                                    proseBlock(closingParagraphs, idPrefix: "closing")
                                }
                                .padding(.top, 30)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 48)
                    }
                    // Follow the voice: bring each paragraph into view as the reading reaches it.
                    .onChange(of: followId) { _, id in
                        guard let id, isVoicePlaying else { return }
                        withAnimation(.easeInOut(duration: 0.5)) { proxy.scrollTo(id, anchor: .center) }
                    }
                }
            }
        }
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 60, trailingPadding: 20)
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .onChange(of: lang) { _, _ in
            // The spoken text changed with the language; stop rather than finish the old one.
            stopListening()
        }
        .onDisappear { stopListening() }
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
            .accessibilityLabel("Back")

            Spacer()

            TextSizeButton(isPanelOpen: $showTextSizePanel)

            if canListen {
                listenChip
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var listenChip: some View {
        Button(action: toggleListen) {
            HStack(spacing: 7) {
                Image(systemName: listenIcon)
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
        .accessibilityLabel(isVoicePlaying ? "Pause reading" : "Listen to the story")
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Miracle \(story.number) · \(story.figure.en)".uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
            Text(story.title.text(for: lang))
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

    // MARK: - Prose

    /// Paragraphs of story text in the reader's direction. The device voice highlights the
    /// spoken word; recorded narration highlights the whole paragraph being read.
    private func proseBlock(_ paragraphs: [String], idPrefix: String) -> some View {
        VStack(alignment: .leading, spacing: 14 * scale) {
            ForEach(paragraphs.indices, id: \.self) { i in
                let id = "\(idPrefix).\(i)"
                Text(PassageMarkup.attributed(
                    paragraphs[i],
                    baseFont: Self.serifUIFont(17 * scale),
                    color: UIColor(themeManager.primaryText),
                    accent: UIColor(themeManager.accentColor),
                    highlight: spokenRange(in: id),
                    highlightColor: UIColor(themeManager.accentColor.opacity(0.28))))
                    .lineSpacing(6 * scale)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        // Drawn outside the text's frame so the highlight never shifts the layout.
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(themeManager.accentColor.opacity(recordedParagraphId == id ? 0.12 : 0))
                            .padding(-8)
                            .animation(.easeInOut(duration: 0.35), value: recordedParagraphId)
                    )
                    .id(id)
            }
        }
        .environment(\.layoutDirection, direction)
    }
}
