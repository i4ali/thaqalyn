//
//  FastingCategoryDetailView.swift
//  Thaqalayn
//
//  Detail view for a fasting category showing verses with full text
//

import SwiftUI

struct FastingCategoryDetailView: View {
    let category: FastingCategory
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    private let fastingEyebrow = "Fasting in the Quran"
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            EmCoverBand(assetName: "FastingCover")
                .frame(height: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            ScrollView {
                emeraldSections
            }

            // Hidden NavigationLink for verse navigation
            if let verseNav = selectedVerseForNav,
               let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == verseNav.surah }) {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahData, targetVerse: verseNav.verse),
                    isActive: $navigateToVerse
                ) {
                    EmptyView()
                }
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
                        Text("Fasting")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    @ViewBuilder private var emeraldSections: some View {
        VStack(spacing: 20) {
            // Category header card
            EmCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        EmIconChip(sfSymbol: category.icon, size: 56)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(fastingEyebrow.uppercased())
                                .font(.system(size: 11, weight: .bold)).tracking(3)
                                .foregroundColor(themeManager.accentColor)
                            Text(category.titleEn)
                                .font(EmType.serif(28, .semiBold))
                                .foregroundColor(themeManager.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(category.verseCount) verse\(category.verseCount == 1 ? "" : "s")")
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Rectangle()
                        .fill(themeManager.dividerColor)
                        .frame(height: 1)
                    Text(category.descriptionEn)
                        .font(EmType.serif(16 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if let narration = category.narration {
                AhlulBaytNarrationCard(narration: narration)
            }

            // Verses section
            VStack(alignment: .leading, spacing: 16) {
                EmSectionLabel(icon: "book.pages", text: "Verses")
                    .padding(.horizontal, 20)
                ForEach(Array(category.verses.enumerated()), id: \.element.id) { index, fastingVerse in
                    FastingVerseCard(
                        fastingVerse: fastingVerse,
                        index: index + 1,
                        totalVerses: category.verseCount,
                        onNavigate: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                selectedVerseForNav = (fastingVerse.surahNumber, fastingVerse.verseNumber)
                                navigateToVerse = true
                            }
                        }
                    )
                }
            }

            Spacer(minLength: 40)
        }
        .padding(.top, 4)
    }
}

struct FastingVerseCard: View {
    let fastingVerse: FastingVerse
    let index: Int
    let totalVerses: Int
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(fastingVerse.surahNumber)"],
              let verse = verses["\(fastingVerse.verseNumber)"] else {
            return nil
        }
        return (verse.arabicText, verse.translation)
    }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == fastingVerse.surahNumber }?.englishName ?? "Surah \(fastingVerse.surahNumber)"
    }

    var body: some View {
        EmCard {
            VStack(alignment: .leading, spacing: 14) {
                // Verse header
                HStack(spacing: 12) {
                    EmNumeralCircle(n: index, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Verse \(index) of \(totalVerses)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(themeManager.secondaryText)
                        Text("\(surahName) · \(fastingVerse.surahNumber):\(fastingVerse.verseNumber)")
                            .font(.system(size: 13, weight: .bold)).tracking(0.3)
                            .foregroundColor(themeManager.accentColor)
                    }
                    Spacer()
                    VerseRecitationButton(surahNumber: fastingVerse.surahNumber, verseNumber: fastingVerse.verseNumber, size: 32)
                    if fastingVerse.isKeyVerse {
                        Text("KEY VERSE")
                            .font(.system(size: 9, weight: .bold)).tracking(1)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                }

                // Verse text
                if let verse = verseData {
                    Text(verse.arabic)
                        .font(EmType.arabic(25 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .environment(\.layoutDirection, .rightToLeft)
                    Text(verse.translation)
                        .font(EmType.serif(16 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(3 * readingSettings.scale)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Relevance note
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(fastingVerse.relevanceNoteEn)
                        .font(.system(size: 13 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.accentChip.opacity(0.6))
                )

                // Action button
                Button(action: onNavigate) {
                    HStack(spacing: 9) {
                        Image(systemName: "book.fill").font(.system(size: 13, weight: .semibold))
                        Text("Read Full Tafsir").font(.system(size: 14, weight: .bold)).tracking(0.3)
                    }
                    .foregroundColor(themeManager.onAccentText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
                }
                .buttonStyle(EmPressStyle())
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
    }
}

/// "From the Ahlul Bayt (a)" card: an attributed narration (Arabic + translation + source).
/// Shared by the Fasting and Prophetic Parallels detail screens; respects the reading
/// text-size control.
struct AhlulBaytNarrationCard: View {
    let narration: AhlulBaytNarration
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    /// Section eyebrow (kept fixed-size - it is chrome, not reading content).
    private let label = "From the Ahlul Bayt (a)"

    var body: some View {
        EmDetailCard(icon: "quote.bubble", label: label) {
            VStack(alignment: .leading, spacing: 14) {
                Text(narration.arabic)
                    .font(EmType.arabic(22 * readingSettings.scale))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(8 * readingSettings.scale)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, .rightToLeft)

                Text(narration.translationEn)
                    .font(EmType.serif(16 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(3 * readingSettings.scale)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(narration.sourceEn)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    NavigationView {
        FastingCategoryDetailView(
            category: FastingCategory(
                id: "obligation",
                titleEn: "Obligation of Fasting",
                titleAr: "فريضة الصيام",
                titleUr: "روزے کی فرضیت",
                icon: "book.fill",
                descriptionEn: "The foundational verses establishing fasting as an obligation for believers.",
                descriptionAr: "الآيات التأسيسية التي تُرسي الصيام فريضةً على المؤمنين.",
                descriptionUr: "بنیادی آیات جو اہلِ ایمان پر روزہ فرض قرار دیتی ہیں۔",
                verses: [
                    FastingVerse(
                        id: "f1",
                        surahNumber: 2,
                        verseNumber: 183,
                        relevanceNoteEn: "The primary verse prescribing fasting for believers.",
                        relevanceNoteAr: "الآية المحورية التي تفرض الصيام على المؤمنين.",
                        relevanceNoteUr: "بنیادی آیت جو اہلِ ایمان پر روزہ فرض کرتی ہے۔",
                        isKeyVerse: true
                    )
                ],
                narration: AhlulBaytNarration(
                    arabic: "بُنِيَ الْإِسْلَامُ عَلَىٰ خَمْسٍ: عَلَى الصَّلَاةِ وَالزَّكَاةِ وَالصَّوْمِ وَالْحَجِّ وَالْوَلَايَةِ.",
                    translationEn: "Islam is built upon five: prayer, zakat, fasting, hajj, and walayah.",
                    translationUr: "اسلام کی بنیاد پانچ چیزوں پر ہے: نماز، زکات، روزہ، حج اور ولایت۔",
                    sourceEn: "Imam al-Baqir (a) — al-Kafi",
                    sourceAr: "الإمام الباقر (عليه السلام) — الكافي",
                    sourceUr: "امام محمد باقر علیہ السلام — الکافی"
                )
            )
        )
    }
}
