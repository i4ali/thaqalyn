//
//  TTSVoicePickerView.swift
//  Thaqalayn
//
//  Voice selection UI for text-to-speech per language
//

import SwiftUI
import AVFoundation

struct TTSVoicePickerView: View {
    let language: CommentaryLanguage
    @StateObject private var voiceManager = TTSVoiceManager.shared
    @StateObject private var tafsirReader = TafsirReader.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .darkScreenAura()
        .preferredColorScheme(themeManager.colorScheme)
        .onDisappear {
            tafsirReader.stop()
        }
    }

    private var legacyBody: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if voiceManager.voicesForLanguage(language).isEmpty {
                    // No voices available
                    VStack(spacing: 16) {
                        Image(systemName: "speaker.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.tertiaryText)

                        Text("No voices available")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)

                        Text("Your device does not have any \(language.displayName) voices installed.")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.tertiaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(voiceManager.voicesForLanguage(language), id: \.identifier) { voice in
                                VoiceRow(
                                    voice: voice,
                                    isSelected: voiceManager.selectedVoice(for: language)?.identifier == voice.identifier,
                                    onSelect: {
                                        voiceManager.setSelectedVoice(voice, for: language)
                                        playSample(for: language)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("\(language.displayName) Voices")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        tafsirReader.stop()
                        dismiss()
                    }
                    .foregroundColor(themeManager.semanticBlue)
                }
            }
        }
    }

    private var emeraldBody: some View {
        NavigationView {
            ZStack {
                EmeraldBackground()

                if voiceManager.voicesForLanguage(language).isEmpty {
                    // No voices available
                    VStack(spacing: 18) {
                        EmIconChip(sfSymbol: "speaker.slash.fill", size: 72)

                        Text("No Voices Available")
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)

                        Text("Your device does not have any \(language.displayName) voices installed.")
                            .font(EmType.serif(18, .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            EmHeading(eyebrow: "Text to Speech", title: "\(language.displayName) Voices")
                                .padding(.bottom, 4)

                            LazyVStack(spacing: 12) {
                                ForEach(voiceManager.voicesForLanguage(language), id: \.identifier) { voice in
                                    VoiceRow(
                                        voice: voice,
                                        isSelected: voiceManager.selectedVoice(for: language)?.identifier == voice.identifier,
                                        onSelect: {
                                            voiceManager.setSelectedVoice(voice, for: language)
                                            playSample(for: language)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        tafsirReader.stop()
                        dismiss()
                    }
                    .font(EmType.serif(18, .semiBold))
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private func playSample(for language: CommentaryLanguage) {
        let sampleText: String
        switch language {
        case .english:
            sampleText = "This is a sample of the selected voice for reading tafsir commentary."
        case .arabic:
            sampleText = "هذا نموذج للصوت المحدد لقراءة تفسير القرآن الكريم."
        case .urdu:
            sampleText = "یہ منتخب آواز کا نمونہ ہے تفسیر پڑھنے کے لیے۔"
        case .french:
            sampleText = "" // French TTS not supported
        }
        tafsirReader.speak(text: sampleText, language: language)
    }
}

struct VoiceRow: View {
    let voice: AVSpeechSynthesisVoice
    let isSelected: Bool
    let onSelect: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                EmIconChip(
                    sfSymbol: voice.gender == .male ? "person.fill" : voice.gender == .female ? "person.fill" : "waveform",
                    size: 46,
                    active: isSelected
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(voice.name)
                        .font(EmType.serif(19, .semiBold))
                        .foregroundColor(themeManager.primaryText)

                    HStack(spacing: 8) {
                        Text(voice.language)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)

                        if voice.quality == .enhanced {
                            Text("Enhanced")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(themeManager.semanticGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(themeManager.semanticGreenChip)
                                )
                                .overlay(
                                    Capsule().stroke(themeManager.semanticGreen.opacity(0.5), lineWidth: 1)
                                )
                        }

                        if voice.gender == .male {
                            Text("Male")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                        } else if voice.gender == .female {
                            Text("Female")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                        }
                    }
                }

                Spacer(minLength: 8)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? themeManager.accentChip : themeManager.glassSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? themeManager.accentColor : themeManager.strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 24, x: 0, y: 8)
        }
        .buttonStyle(EmPressStyle())
    }

    private var legacyBody: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Voice icon
                ZStack {
                    Circle()
                        .fill(isSelected ? themeManager.accentGradient : LinearGradient(colors: [themeManager.tertiaryBackground, themeManager.tertiaryBackground], startPoint: .top, endPoint: .bottom))
                        .frame(width: 50, height: 50)

                    Image(systemName: voice.gender == .male ? "person.fill" : voice.gender == .female ? "person.fill" : "waveform")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? .white : themeManager.secondaryText)
                }

                // Voice info
                VStack(alignment: .leading, spacing: 4) {
                    Text(voice.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    HStack(spacing: 8) {
                        // Language code
                        Text(voice.language)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)

                        // Quality badge
                        if voice.quality == .enhanced {
                            Text("Enhanced")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.green)
                                )
                        }

                        // Gender indicator
                        if voice.gender == .male {
                            Text("Male")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                        } else if voice.gender == .female {
                            Text("Female")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                        }
                    }
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(themeManager.semanticBlue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.isDarkMode ? themeManager.glassSurface : themeManager.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? themeManager.semanticBlue.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TTSVoicePickerView(language: .english)
}
