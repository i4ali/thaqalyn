//
//  SpecialDuaDetailView.swift
//  Thaqalayn
//
//  Reader for one major supplication / ziyarat: a header with context, a streamed
//  recitation bar (buffering + scrubbing, since these run long), then the full text
//  line by line — Arabic + transliteration + translation, with the occasional
//  structural note ("Then prostrate and say:"). While the recitation plays, the
//  word being recited glows gold and the reader gently follows along (karaoke
//  highlight, driven by DuaKaraokeEngine); tapping a line seeks the recitation
//  there. Reading content scales with the global reading text-size control.
//  Works in both the standard and Midnight Emerald themes. Text & recitation
//  are courtesy of Duas.org.
//

import SwiftUI
import UIKit

struct SpecialDuaDetailView: View {
    let dua: SpecialDua

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var stream = DuaStreamPlayer.shared
    @StateObject private var karaoke = DuaKaraokeEngine()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// After a manual scroll, hold off auto-following for this long so the
    /// reader can browse while the recitation keeps playing.
    @State private var lastUserScroll: Date?
    private static let followCooldown: TimeInterval = 6

    private var em: Bool { themeManager.isMidnightEmerald }
    private var scale: CGFloat { readingSettings.scale }

    /// The karaoke gold: Midnight Emerald's bright gold; a deeper gold that
    /// stays legible on the standard theme's light background.
    private var karaokeGold: Color { em ? Color(hex: "ECD49A") : Color(hex: "9A7514") }

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            if em {
                // Dim the lit shrine a touch so the attribution and intro
                // (both muted secondary text) stay legible over the bright cover.
                EmCoverBand(assetName: "DuasZiyaratCover", dim: 0.28)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        header
                        if dua.audioURL != nil { StreamListenBar(dua: dua) }
                        Divider().overlay(themeManager.strokeColor).padding(.vertical, 2)
                        segmentsView
                        creditFooter
                        shareButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, em ? 16 : 20)
                    .padding(.bottom, 44)
                }
                .onScrollPhaseChange { _, newPhase in
                    if newPhase == .interacting { lastUserScroll = Date() }
                }
                .onChange(of: karaoke.currentSegment) { _, segment in
                    autoFollow(to: segment, proxy: proxy)
                }
            }
        }
        .onAppear { karaoke.configure(duaID: dua.id) }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(em ? .hidden : .automatic, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        // Pushed from DuasZiyaratView's stack: hide the system back button so the
        // custom one above is the only "Back" (otherwise both render side by side).
        .navigationBarBackButtonHidden(true)
        // No onDisappear stop: like verse audio and journey narration, the recitation
        // keeps playing when the reader navigates away - the docked DuaMiniPlayer
        // (MainTabView / DuasZiyaratView) keeps the controls in reach.
        .darkScreenAura()
        .hideTabBarInEmerald()
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dua.titleEn)
                .font(em ? EmType.serif(30, .semiBold) : .system(size: 28, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: SpecialDuaIcon.symbol(for: dua.id))
                    .font(.system(size: 11, weight: .semibold))
                Text(dua.whenEn)
                    .font(.system(size: 12.5, weight: .semibold))
            }
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(Capsule().fill(themeManager.accentColor.opacity(0.14)))

            Text(dua.attributionEn)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)

            Text(dua.introEn)
                .font(em ? EmType.serif(16 * scale, .medium) : .system(size: 16 * scale, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .lineSpacing(5 * scale)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Segments

    private var segmentsView: some View {
        ForEach(Array(dua.segments.enumerated()), id: \.offset) { index, seg in
            if let note = seg.note {
                noteRow(note)
                    .id(index)
            } else {
                segmentRow(seg, index: index)
                    .id(index)
            }
        }
    }

    private func segmentRow(_ seg: SpecialDuaSegment, index: Int) -> some View {
        VStack(spacing: 9) {
            if let ar = seg.ar, !ar.isEmpty {
                Text(arabicLine(ar, segmentIndex: index))
                    .font(em ? EmType.arabic(27 * scale) : .system(size: 26 * scale, weight: .regular))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10 * scale)
                    .frame(maxWidth: .infinity)
                    .environment(\.layoutDirection, .rightToLeft)
                    .textSelection(.enabled)
            }
            if let tr = seg.tr, !tr.isEmpty {
                Text(tr)
                    .font(em ? EmType.serifItalic(15.5 * scale) : .system(size: 15 * scale, weight: .regular, design: .serif))
                    .italic(!em)
                    .foregroundColor(themeManager.tertiaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .textSelection(.enabled)
            }
            if let en = seg.en, !en.isEmpty {
                Text(en)
                    .font(em ? EmType.serif(16.5 * scale, .medium) : .system(size: 16.5 * scale, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4 * scale)
                    .frame(maxWidth: .infinity)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, 6)
        .background {
            // Soft gold wash behind the line being recited (word-level parity
            // between Arabic and transliteration isn't reliable, so the
            // companion lines get line-level emphasis instead).
            if karaoke.currentSegment == index {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(karaokeGold.opacity(em ? 0.08 : 0.09))
                    .padding(.horizontal, -10)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: karaoke.currentSegment == index)
        .contentShape(Rectangle())
        .onTapGesture { seekToSegment(index) }
    }

    // MARK: - Karaoke

    /// The segment's Arabic with the word currently being recited in gold.
    /// Word addressing matches the aligner (DuaArabicTokenizer). Arabic letter
    /// joining never crosses a space, so per-word coloring cannot break the
    /// script's shaping.
    private func arabicLine(_ ar: String, segmentIndex: Int) -> AttributedString {
        guard let current = karaoke.currentWord, current.segment == segmentIndex else {
            return AttributedString(ar)
        }
        let tokens = DuaArabicTokenizer.tokens(ar)
        guard current.token < tokens.count else { return AttributedString(ar) }
        var line = AttributedString()
        for (i, token) in tokens.enumerated() {
            if i > 0 { line += AttributedString(" ") }
            var word = AttributedString(token)
            if i == current.token { word.foregroundColor = karaokeGold }
            line += word
        }
        return line
    }

    /// Tap a line to jump the recitation there. Only while this dua is the
    /// one loaded (playing or paused) — a tap while idle stays a tap, it
    /// doesn't surprise-start audio.
    private func seekToSegment(_ index: Int) {
        guard karaoke.canSeek, let start = karaoke.timings?.segmentStart(index) else { return }
        stream.seek(to: start)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Keep the recited line centered while playing, unless the reader
    /// recently scrolled somewhere themselves.
    private func autoFollow(to segment: Int?, proxy: ScrollViewProxy) {
        guard let segment, stream.currentID == dua.id, stream.isPlaying else { return }
        if let last = lastUserScroll, Date().timeIntervalSince(last) < Self.followCooldown { return }
        if reduceMotion {
            proxy.scrollTo(segment, anchor: .center)
        } else {
            withAnimation(.easeInOut(duration: 0.5)) {
                proxy.scrollTo(segment, anchor: .center)
            }
        }
    }

    private func noteRow(_ note: String) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(themeManager.accentColor.opacity(0.4)).frame(height: 1)
            Text(note)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(themeManager.accentColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            Rectangle().fill(themeManager.accentColor.opacity(0.4)).frame(height: 1)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Credit + Share

    private var creditFooter: some View {
        VStack(spacing: 4) {
            if let reciter = dua.reciterEn, !reciter.isEmpty {
                Text("Recitation by \(reciter)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
            HStack(spacing: 4) {
                Text("Text & recitation courtesy of")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.tertiaryText)
                Link("Duas.org", destination: URL(string: "https://www.duas.org")!)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private var shareButton: some View {
        ShareLink(item: shareText) {
            HStack(spacing: 9) {
                Image(systemName: "square.and.arrow.up").font(.system(size: 15, weight: .semibold))
                Text("Share").font(.system(size: 15.5, weight: .bold))
            }
            .foregroundColor(em ? themeManager.onAccentText : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(themeManager.accentGradient)
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 16, x: 0, y: 8)
            )
        }
        .padding(.top, 6)
    }

    private var shareText: String {
        """
        \(dua.titleEn)
        \(dua.whenEn) · \(dua.attributionEn)

        \(dua.introEn)

        Read & listen in Thaqalayn
        """
    }
}

// MARK: - Streaming Listen bar

/// Play / pause / resume + buffering spinner + scrubbing bar for a streamed recitation.
private struct StreamListenBar: View {
    let dua: SpecialDua

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var stream = DuaStreamPlayer.shared
    @State private var isScrubbing = false
    @State private var scrubValue: Double = 0

    private var isThis: Bool { stream.currentID == dua.id }
    private var isPlayingThis: Bool { isThis && stream.isPlaying }
    private var isPausedThis: Bool { isThis && stream.isPaused }
    private var isLoadingThis: Bool { isThis && stream.isLoading }

    private var label: String {
        if isThis && stream.failed { return "Try again" }
        if isLoadingThis { return "Loading" }
        if isPlayingThis { return "Pause" }
        if isPausedThis { return "Resume" }
        return "Listen"
    }
    private var icon: String { isPlayingThis ? "pause.fill" : "play.fill" }

    var body: some View {
        VStack(spacing: 10) {
            Button(action: handleTap) {
                HStack(spacing: 9) {
                    if isLoadingThis {
                        ProgressView().controlSize(.small)
                            .tint(themeManager.isMidnightEmerald ? themeManager.accentColor : themeManager.primaryText)
                    } else {
                        Image(systemName: icon).font(.system(size: 15, weight: .bold))
                    }
                    Text(label).font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(themeManager.isMidnightEmerald ? themeManager.accentColor : themeManager.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    Capsule()
                        .fill(themeManager.isMidnightEmerald ? themeManager.accentChip : themeManager.secondaryBackground.opacity(0.8))
                        .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                )
            }

            if isThis && stream.duration > 0 {
                VStack(spacing: 2) {
                    Slider(
                        value: Binding(
                            get: { isScrubbing ? scrubValue : stream.currentTime },
                            set: { scrubValue = $0 }
                        ),
                        in: 0...max(stream.duration, 1),
                        onEditingChanged: { editing in
                            if editing {
                                isScrubbing = true
                            } else {
                                stream.seek(to: scrubValue)
                                isScrubbing = false
                            }
                        }
                    )
                    .tint(themeManager.accentColor)

                    HStack {
                        Text(timeString(isScrubbing ? scrubValue : stream.currentTime))
                        Spacer()
                        Text(timeString(stream.duration))
                    }
                    .font(.system(size: 11, weight: .medium).monospacedDigit())
                    .foregroundColor(themeManager.tertiaryText)
                }
            }
        }
    }

    private func handleTap() {
        guard dua.audioURL != nil else { return }
        if isThis && (stream.isPlaying || stream.isPaused) {
            stream.togglePlayPause()
        } else {
            stream.play(dua: dua)
        }
    }

    private func timeString(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let total = Int(t)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
