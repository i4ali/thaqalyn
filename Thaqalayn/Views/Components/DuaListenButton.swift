//
//  DuaListenButton.swift
//  Thaqalayn
//
//  Reusable "Listen" control for a supplication's Arabic text. Plays a bundled
//  pre-recorded recitation when one exists (keyed off the Arabic via DuaAudioKey);
//  otherwise falls back to system TTS (TafsirReader / AVSpeechSynthesizer). Used by
//  DuaDetailView and every journey day detail view (Muharram, Hajj, Ramadan,
//  Fatimiyya, Arbaeen) and the deep-dive closing dua, so each du'a/ziyarat across the
//  app has a consistent listen option. Play/Pause/Resume state is keyed off this
//  string so the button reflects activity only while *this* du'a is the one playing.
//

import SwiftUI

struct DuaListenButton: View {
    /// The Arabic supplication to play (recording) or speak (TTS fallback).
    let arabic: String

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var tafsirReader = TafsirReader.shared
    @StateObject private var duaPlayer = DuaAudioPlayer.shared

    // Recording lookup (nil -> TTS fallback). Cheap: SHA256 of a short string.
    private var recordingURL: URL? { DuaAudioKey.recordingURL(for: arabic) }
    private var key: String { DuaAudioKey.key(for: arabic) }
    private var hasRecording: Bool { recordingURL != nil }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldButton
            } else {
                standardButton
            }
        }
        .onAppear {
            #if DEBUG
            NSLog("DUAAUDIOBTN hasRec=\(hasRecording) key=\(key) arabic=\(arabic.prefix(30))")
            #endif
        }
        .onDisappear {
            // Stop playback when the screen goes away, but only if it was this du'a.
            if hasRecording {
                if duaPlayer.currentKey == key { duaPlayer.stop() }
            } else if tafsirReader.currentText == arabic {
                tafsirReader.stop()
            }
        }
    }

    private var standardButton: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(themeManager.primaryText)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(themeManager.secondaryBackground.opacity(0.8))
                    .overlay(
                        Capsule().stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var emeraldButton: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                Image(systemName: iconName).font(.system(size: 15, weight: .semibold))
                Text(label).font(.system(size: 14.5, weight: .semibold))
            }
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 20).padding(.vertical, 11)
            .background(Capsule().fill(themeManager.accentChip))
            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle())
        .frame(maxWidth: .infinity)
    }

    // MARK: - State (driven by the recording player OR TTS, per this dua)

    private var isActive: Bool {
        hasRecording ? duaPlayer.currentKey == key : tafsirReader.currentText == arabic
    }
    private var isPlayingThis: Bool {
        isActive && (hasRecording ? duaPlayer.isPlaying : tafsirReader.isPlaying)
    }
    private var isPausedThis: Bool {
        isActive && (hasRecording ? duaPlayer.isPaused : tafsirReader.isPaused)
    }

    private var iconName: String {
        isPlayingThis ? "pause.fill" : "speaker.wave.2.fill"
    }

    private var label: String {
        if isActive {
            if isPlayingThis { return "Pause" }
            if isPausedThis { return "Resume" }
        }
        return "Listen"
    }

    private func handleTap() {
        if hasRecording, let url = recordingURL {
            if isActive && (duaPlayer.isPlaying || duaPlayer.isPaused) {
                duaPlayer.togglePlayPause()
            } else {
                duaPlayer.play(key: key, url: url)
            }
        } else {
            if tafsirReader.currentText == arabic && (tafsirReader.isPlaying || tafsirReader.isPaused) {
                tafsirReader.togglePlayPause()
            } else {
                tafsirReader.speak(text: arabic, language: .arabic)
            }
        }
    }
}
