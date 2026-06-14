//
//  VerseRecitationButton.swift
//  Thaqalayn
//
//  A small play/pause chip that recites a single Qur'an verse through the shared
//  AudioManager — the same engine, reciter, and caching as the main reader.
//  Drop it onto any screen that shows a verse; pass the surah + verse numbers.
//

import SwiftUI

struct VerseRecitationButton: View {
    let surahNumber: Int
    let verseNumber: Int
    var size: CGFloat = 36

    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    /// True when this verse is the one currently loaded in the player.
    private var isActive: Bool {
        audioManager.currentPlayback?.surahNumber == surahNumber &&
        audioManager.currentPlayback?.verseNumber == verseNumber
    }
    private var isPlaying: Bool { isActive && audioManager.playerState == .playing }
    private var isLoading: Bool {
        isActive && (audioManager.playerState == .loading || audioManager.playerState == .buffering)
    }

    var body: some View {
        Button(action: handleTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(isActive ? AnyShapeStyle(themeManager.accentGradient)
                                   : AnyShapeStyle(themeManager.accentChip))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(isActive ? Color.clear : themeManager.strokeColor, lineWidth: 1))

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(isActive ? themeManager.onAccentText : themeManager.accentColor)
                } else {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: size * 0.36, weight: .semibold))
                        .foregroundColor(isActive ? themeManager.onAccentText : themeManager.accentColor)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel(isPlaying ? "Pause recitation" : "Play recitation")
    }

    private func handleTap() {
        // Already this verse → just toggle pause/resume.
        if isActive && (audioManager.playerState == .playing || audioManager.playerState == .paused) {
            audioManager.togglePlayPause()
            return
        }
        // Otherwise look up the verse + surah and start it.
        guard let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == surahNumber }),
              let verse = surahData.verses.first(where: { $0.number == verseNumber }) else { return }
        Task { await audioManager.playVerse(verse, in: surahData.surah) }
    }
}
