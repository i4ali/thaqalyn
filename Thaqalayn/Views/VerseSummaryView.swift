//
//  VerseSummaryView.swift
//  Thaqalayn
//
//  Bottom sheet view for displaying verse summaries
//

import SwiftUI

struct VerseSummaryView: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let onViewFullCommentary: () -> Void
    @State private var selectedLanguage: CommentaryLanguage = .english
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Compute device type for adaptive presentation
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // Check if any non-English translated content is available
    private var hasAnyTranslatedContent: Bool {
        guard let tafsir = verse.tafsir else { return false }
        return tafsir.layer2short_urdu != nil ||
               tafsir.layer2short_ar != nil ||
               tafsir.layer2short_fr != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(themeManager.tertiaryText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerView

                    // Verse reference
                    verseReferenceView

                    // Language selector (if any non-English content available)
                    if hasAnyTranslatedContent {
                        languageSelectorView
                    }

                    // Summary content
                    summaryContentView

                    // Full commentary link
                    fullCommentaryButtonView
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(backgroundView)
        .presentationDetents(isIPad ? [.large] : [.fraction(0.7), .large])
        .presentationDragIndicator(.hidden)
        .frame(maxWidth: isIPad ? 600 : nil) // Constrain width on iPad for better readability
    }

    private var headerView: some View {
        HStack {
            Text("✨")
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text("Quick Overview")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text("Essential insights at a glance")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
    }

    private var verseReferenceView: some View {
        HStack(spacing: 12) {
            // Verse number badge
            Circle()
                .fill(themeManager.accentGradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(verse.number)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                )
                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.englishName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text("Verse \(verse.number)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }

    private var languageSelectorView: some View {
        HStack(spacing: 12) {
            ForEach(CommentaryLanguage.allCases, id: \.self) { language in
                Button(action: { selectedLanguage = language }) {
                    Text(language.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedLanguage == language ? .white : themeManager.tertiaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            if selectedLanguage == language {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.accentGradient)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(themeManager.strokeColor, lineWidth: selectedLanguage == language ? 0 : 1)
                        )
                }
            }
        }
    }

    private var summaryContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Layer2 classical commentary (short version for overview)
            if let layer2Text = verse.tafsir?.getLayer2Short(language: selectedLanguage) {
                Text(layer2Text)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(8)
                    .multilineTextAlignment(selectedLanguage.isRTL ? .trailing : .leading)
                    .environment(\.layoutDirection, selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
            } else {
                Text("Overview not available for this verse.")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(themeManager.secondaryText)
                    .italic()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
    }

    private var fullCommentaryButtonView: some View {
        Button(action: {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onViewFullCommentary()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .font(.system(size: 16, weight: .semibold))

                Text("Read In-Depth Commentary")
                    .font(.system(size: 16, weight: .semibold))

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.purpleGradient)
                    .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 12)
            )
        }
        .padding(.top, 8)
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                themeManager.primaryBackground,
                themeManager.secondaryBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    let sampleSurah = Surah(
        number: 1,
        name: "الفاتحة",
        englishName: "Al-Fatiha",
        englishNameTranslation: "The Opening",
        arabicName: "الفاتحة",
        versesCount: 7,
        revelationType: "Meccan"
    )

    let sampleVerse = Verse(
        arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
        juz: 1,
        manzil: 1,
        page: 1,
        ruku: 1,
        hizbQuarter: 1,
        sajda: SajdaInfo(hasSajda: false, id: nil, recommended: nil)
    )

    let sampleTafsir = TafsirVerse(
        layer1: "Foundation commentary...",
        layer2: "This opening verse invokes Allah's infinite mercy and compassion, as explained by classical scholars like Tabatabai. The Bismillah establishes that all actions should begin with remembrance of Allah's attributes of mercy and compassion, reflecting the core theological principle that divine mercy encompasses all creation.",
        layer3: "Contemporary commentary...",
        layer4: "Ahlul Bayt commentary...",
        layer5: "Comparative commentary...",
        layer1_urdu: nil,
        layer2_urdu: nil,
        layer3_urdu: nil,
        layer4_urdu: nil,
        layer5_urdu: nil,
        layer1_ar: nil,
        layer2_ar: nil,
        layer3_ar: nil,
        layer4_ar: nil,
        layer5_ar: nil,
        layer1_fr: nil,
        layer2_fr: nil,
        layer3_fr: nil,
        layer4_fr: nil,
        layer5_fr: nil,
        layer2short: "The Bismillah invokes Allah's infinite mercy and compassion.",
        layer2short_urdu: nil,
        layer2short_ar: nil,
        layer2short_fr: nil
    )

    let sampleVerseWithTafsir = VerseWithTafsir(
        number: 1,
        verse: sampleVerse,
        tafsir: sampleTafsir
    )

    VStack {
        Spacer()
        VerseSummaryView(
            verse: sampleVerseWithTafsir,
            surah: sampleSurah,
            onViewFullCommentary: {}
        )
    }
}
