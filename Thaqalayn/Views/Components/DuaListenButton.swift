//
//  DuaListenButton.swift
//  Thaqalayn
//
//  Reusable "Listen" control for a supplication's Arabic text. Speaks the duʿā via
//  the shared TTS reader (AVSpeechSynthesizer) and reflects Listen / Pause / Resume
//  state. Used by DuaDetailView and every journey day detail view (Muharram, Hajj,
//  Ramadan, Fatimiyya) so each duʿā/ziyārat across the app has a consistent listen
//  option. Duʿās have no pre-recorded audio, so playback is system text-to-speech.
//

import SwiftUI

struct DuaListenButton: View {
    /// The Arabic supplication to speak. Play/pause state is keyed off this string so
    /// the button reflects activity only while *this* duʿā is the one being read.
    let arabic: String

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var tafsirReader = TafsirReader.shared

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldButton
            } else {
                standardButton
            }
        }
        .onDisappear {
            // Stop speaking when the screen goes away, but only if it was this duʿā.
            if tafsirReader.currentText == arabic {
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

    private var iconName: String {
        if tafsirReader.currentText == arabic && tafsirReader.isPlaying {
            return "pause.fill"
        }
        return "speaker.wave.2.fill"
    }

    private var label: String {
        if tafsirReader.currentText == arabic {
            if tafsirReader.isPlaying { return "Pause" }
            if tafsirReader.isPaused { return "Resume" }
        }
        return "Listen"
    }

    private func handleTap() {
        if tafsirReader.currentText == arabic && (tafsirReader.isPlaying || tafsirReader.isPaused) {
            tafsirReader.togglePlayPause()
        } else {
            tafsirReader.speak(text: arabic, language: .arabic)
        }
    }
}
