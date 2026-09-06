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
    let initialConceptId: String?

    init(verse: VerseWithTafsir, surah: Surah, initialConceptId: String? = nil) {
        self.verse = verse
        self.surah = surah
        self.initialConceptId = initialConceptId
    }

    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Compute device type for adaptive presentation
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // Check if quick overview data is available
    private var hasQuickOverview: Bool {
        return verse.tafsir?.quickOverview != nil
    }

    var body: some View {
        // Use interactive QuickOverviewView if data available, otherwise fallback to text
        if let quickOverview = verse.tafsir?.quickOverview {
            QuickOverviewView(
                verse: verse,
                surah: surah,
                quickOverview: quickOverview,
                initialConceptId: initialConceptId
            )
        } else {
            textBasedOverviewView
        }
    }

    // MARK: - Text-Based Fallback View

    private var textBasedOverviewView: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldFallbackContent
            } else {
                legacyFallbackContent
            }
        }
        .background(backgroundView)
        .darkScreenAura()
        .presentationDetents(isIPad ? [.large] : [.fraction(0.7), .large])
        .presentationDragIndicator(.hidden)
        .frame(maxWidth: isIPad ? 600 : nil) // Constrain width on iPad for better readability
    }

    private var emeraldFallbackContent: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(themeManager.tertiaryText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12).padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 12) {
                        EmIconChip(sfSymbol: "sparkles", active: true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Gems").font(EmType.serif(26, .semiBold)).foregroundColor(themeManager.primaryText)
                            Text("Precious insights unveiled").font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                    }

                    // Verse reference
                    HStack(spacing: 12) {
                        EmNumeralCircle(n: verse.number, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(surah.englishName).font(EmType.serif(18, .semiBold)).foregroundColor(themeManager.primaryText)
                            Text("Verse \(verse.number)").font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
                        }
                        Spacer()
                        VerseRecitationButton(surahNumber: surah.number, verseNumber: verse.number, size: 34)
                    }

                    EmDivider(label: "The Core Insight")

                    Text("Overview not available for this verse.")
                        .font(EmType.serifItalic(16))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private var legacyFallbackContent: some View {
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

                    // Summary content
                    summaryContentView
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private var headerView: some View {
        HStack {
            PhosphorIcon(name: "ph-sparkle-fill", size: 32)
                .foregroundColor(themeManager.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text("Gems")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text("Precious insights unveiled")
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
                .shadow(color: themeManager.semanticBlue.opacity(0.4), radius: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.englishName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text("Verse \(verse.number)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            VerseRecitationButton(surahNumber: surah.number, verseNumber: verse.number, size: 34)
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

    private var summaryContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview not available for this verse.")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundColor(themeManager.secondaryText)
                .italic()
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

    @ViewBuilder
    private var backgroundView: some View {
        if themeManager.isMidnightEmerald {
            EmeraldBackground()
        } else {
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
        translationUrdu: "عظیم اور دائمی رحمتوں والے خدا کے نام سے",
        juz: 1,
        manzil: 1,
        page: 1,
        ruku: 1,
        hizbQuarter: 1,
        sajda: SajdaInfo(hasSajda: false, id: nil, recommended: nil)
    )

    let sampleTafsir = TafsirVerse(quickOverview: nil)

    let sampleVerseWithTafsir = VerseWithTafsir(
        number: 1,
        verse: sampleVerse,
        tafsir: sampleTafsir
    )

    VStack {
        Spacer()
        VerseSummaryView(
            verse: sampleVerseWithTafsir,
            surah: sampleSurah
        )
    }
}
