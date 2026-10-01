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
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @StateObject private var dataManager = DataManager.shared
    @State private var navigateToVerse = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            EmCoverBand(assetName: "DailyDuasCover")
                .frame(height: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            content

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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
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
        // Pushed from DuasView's stack: hide the system back button so the custom
        // one above is the only "Back" (otherwise both render side by side).
        .navigationBarBackButtonHidden(true)
        .hideTabBar()
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(dua.category.uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(3)
                            .foregroundColor(themeManager.accentColor)
                        Text(dua.situationEn)
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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

                DuaListenButton(arabic: dua.arabic)

                Text(dua.transliteration)
                    .font(EmType.serifItalic(17 * readingSettings.scale))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .textSelection(.enabled)

                EmCard {
                    Text(dua.translationEn)
                        .font(EmType.serif(17 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
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

    // MARK: - Source

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

    // MARK: - Helpers

    private var shareText: String {
        """
        \(dua.situationEn)

        \(dua.arabic)

        \(dua.transliteration)

        \(dua.translationEn)

        — Source: \(dua.source)
        Sent via Thaqalayn
        """
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
            transliteration: "Allahumma-shfini bishifa'ik, wa dawini bidawa'ik, wa afini min bala'ik",
            translationEn: "O Allah, heal me with Your healing, remedy me with Your remedy, and grant me well-being from Your affliction.",
            translationUr: "اے اللہ! مجھے اپنی شفا سے شفا عطا فرما، اپنی دوا سے میرا علاج فرما، اور اپنی آزمائش سے مجھے عافیت عطا فرما۔",
            source: "Supplication for healing, narrated from the Ahlul Bayt (a)",
            category: "health",
            surahNumber: nil,
            verseNumber: nil
        ))
    }
}
