//
//  DuaDetailView.swift
//  Thaqalayn
//
//  Per-dua detail screen: Arabic + transliteration + translation + source + share.
//

import SwiftUI

struct DuaDetailView: View {
    let dua: DailyDua
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var tafsirReader = TafsirReader.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var dataManager = DataManager.shared
    @State private var navigateToVerse = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            if themeManager.isMidnightEmerald {
                emeraldScroll
            } else {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    arabicSection
                    ttsButton
                    transliterationSection
                    translationSection
                    sourceSection
                    shareSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            }

            // Hidden link: tapping a Qur'anic dua's source opens that verse in the reader.
            if let surahData = linkedSurah, let v = dua.verseNumber {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahData, targetVerse: v),
                    isActive: $navigateToVerse
                ) { EmptyView() }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
        .onDisappear {
            if tafsirReader.currentText == dua.arabic {
                tafsirReader.stop()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
        .darkScreenAura()
        .hideTabBarInEmerald()
    }

    // MARK: - Emerald

    private var emeraldScroll: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(dua.category.uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(3)
                            .foregroundColor(themeManager.accentColor)
                        Text(dua.situation(for: languageManager.selectedLanguage))
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection,
                             languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)

                EmCard(glow: true) {
                    Text(dua.arabic)
                        .font(EmType.arabic(30 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(12 * readingSettings.scale)
                        .frame(maxWidth: .infinity)
                        .padding(22)
                        .environment(\.layoutDirection, .rightToLeft)
                        .textSelection(.enabled)
                }

                emeraldTTSButton

                Text(dua.transliteration)
                    .font(EmType.serifItalic(17 * readingSettings.scale))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .textSelection(.enabled)

                EmCard {
                    Text(dua.translation(for: languageManager.selectedLanguage))
                        .font(EmType.serif(17 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(languageManager.selectedLanguage == .urdu ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage == .urdu ? .trailing : .leading)
                        .padding(20)
                        .environment(\.layoutDirection, languageManager.selectedLanguage == .urdu ? .rightToLeft : .leftToRight)
                        .textSelection(.enabled)
                }

                sourceCitation(prefix: "Source · ", font: .system(size: 12.5, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)

                ShareLink(item: shareText) {
                    HStack(spacing: 9) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 15, weight: .semibold))
                        Text("Share").font(.system(size: 15.5, weight: .bold)).tracking(0.3)
                    }
                    .foregroundColor(themeManager.onAccentText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    private var emeraldTTSButton: some View {
        Button(action: handleTTSTap) {
            HStack(spacing: 8) {
                Image(systemName: ttsIconName).font(.system(size: 15, weight: .semibold))
                Text(ttsLabel).font(.system(size: 14.5, weight: .semibold))
            }
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 20).padding(.vertical, 11)
            .background(Capsule().fill(themeManager.accentChip))
            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle())
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dua.situation(for: languageManager.selectedLanguage))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.leading)

                categoryPill
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    private var categoryPill: some View {
        Text(dua.category.capitalized)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(themeManager.accentColor.opacity(0.15))
            )
    }

    /// The SurahWithTafsir this dua links to, if it is drawn from the Qur'an and loaded.
    private var linkedSurah: SurahWithTafsir? {
        guard let s = dua.surahNumber else { return nil }
        return dataManager.availableSurahs.first(where: { $0.surah.number == s })
    }

    /// Source citation — tappable (accent + chevron, opens the verse) when the dua is Qur'anic.
    @ViewBuilder
    private func sourceCitation(prefix: String, font: Font) -> some View {
        if linkedSurah != nil {
            Button(action: { navigateToVerse = true }) {
                HStack(spacing: 5) {
                    Text("\(prefix)\(dua.source)").font(font)
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(themeManager.accentColor)
            }
            .buttonStyle(.plain)
        } else {
            Text("\(prefix)\(dua.source)")
                .font(font)
                .foregroundColor(themeManager.tertiaryText)
        }
    }

    private var arabicSection: some View {
        Text(dua.arabic)
            .font(.system(size: 28 * readingSettings.scale, weight: .regular))
            .foregroundColor(themeManager.primaryText)
            .shadow(color: themeManager.isDarkMode ? themeManager.accentColor.opacity(0.32) : .clear, radius: 16)
            .multilineTextAlignment(.center)
            .lineSpacing(12 * readingSettings.scale)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(themedCardBackground)
            .environment(\.layoutDirection, .rightToLeft)
            .textSelection(.enabled)
    }

    private var ttsButton: some View {
        Button(action: handleTTSTap) {
            HStack(spacing: 8) {
                Image(systemName: ttsIconName)
                    .font(.system(size: 16, weight: .semibold))
                Text(ttsLabel)
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

    private var ttsIconName: String {
        if tafsirReader.currentText == dua.arabic && tafsirReader.isPlaying {
            return "pause.fill"
        }
        return "speaker.wave.2.fill"
    }

    private var ttsLabel: String {
        if tafsirReader.currentText == dua.arabic {
            if tafsirReader.isPlaying { return "Pause" }
            if tafsirReader.isPaused { return "Resume" }
        }
        return "Listen"
    }

    private func handleTTSTap() {
        if tafsirReader.currentText == dua.arabic && (tafsirReader.isPlaying || tafsirReader.isPaused) {
            tafsirReader.togglePlayPause()
        } else {
            tafsirReader.speak(text: dua.arabic, language: .arabic)
        }
    }

    private var transliterationSection: some View {
        Text(dua.transliteration)
            .font(.system(size: 16 * readingSettings.scale, weight: .regular, design: .serif))
            .italic()
            .foregroundColor(themeManager.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
            .textSelection(.enabled)
    }

    private var translationSection: some View {
        let language = languageManager.selectedLanguage
        let translation = dua.translation(for: language)
        let isRTL = language == .urdu

        return Text(translation)
            .font(.system(size: 17 * readingSettings.scale, weight: .medium))
            .foregroundColor(themeManager.primaryText)
            .multilineTextAlignment(isRTL ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
            .padding(20)
            .background(themedCardBackground)
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
            .textSelection(.enabled)
    }

    private var sourceSection: some View {
        HStack {
            Spacer()
            sourceCitation(prefix: "Source: ", font: .system(size: 13, weight: .medium))
            Spacer()
        }
        .padding(.top, 4)
    }

    private var shareSection: some View {
        ShareLink(item: shareText) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(themeManager.accentGradient)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
            )
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private var shareText: String {
        let lang = languageManager.selectedLanguage
        return """
        \(dua.situation(for: lang))

        \(dua.arabic)

        \(dua.transliteration)

        \(dua.translation(for: lang))

        — Source: \(dua.source)
        Sent via Thaqalayn
        """
    }

    @ViewBuilder
    private var themedCardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(themeManager.strokeColor, lineWidth: 1)
            )
            .shadow(
                color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                radius: 12, x: 0, y: 4
            )
    }
}

#Preview {
    NavigationView {
        DuaDetailView(dua: DailyDua(
            id: "1",
            situationEn: "For health & healing",
            situationAr: "لِلصِّحَّةِ وَالشِّفَاءِ",
            situationUr: "صحت و شفا کے لیے",
            arabic: "اللّٰهُمَّ اشْفِنِي بِشِفَائِكَ وَدَاوِنِي بِدَوَائِكَ وَعَافِنِي مِنْ بَلَائِكَ",
            transliteration: "Allāhumma-shfinī bishifāʾik, wa dāwinī bidawāʾik, wa ʿāfinī min balāʾik",
            translationEn: "O Allah, heal me with Your healing, remedy me with Your remedy, and grant me well-being from Your affliction.",
            translationUr: "اے اللہ! مجھے اپنی شفا سے شفا عطا فرما، اپنی دوا سے میرا علاج فرما، اور اپنی آزمائش سے مجھے عافیت عطا فرما۔",
            source: "Supplication for healing, narrated from the Ahlul Bayt (ʿa)",
            category: "health",
            surahNumber: nil,
            verseNumber: nil
        ))
    }
}
