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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    private var localizedFastingEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "الصيام في القرآن"
        case .urdu:   return "قرآن میں روزہ"
        default:      return "Fasting in the Quran"
        }
    }
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                if themeManager.isMidnightEmerald {
                    emeraldSections
                } else {
                VStack(spacing: 24) {
                    // Category header
                    VStack(spacing: 16) {
                        // Icon and title
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.accentGradient)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 10)

                                Image(systemName: category.icon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.title(for: languageManager.selectedLanguage))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(themeManager.primaryText)

                                Text("\(category.verseCount) verse\(category.verseCount == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }

                            Spacer()
                        }

                        // Description
                        Text(category.description(for: languageManager.selectedLanguage))
                            .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(4 * readingSettings.scale)
                    }
                    .padding(24)
                    .environment(\.layoutDirection,
                                 languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                            .shadow(
                                color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06),
                                radius: 16, x: 0, y: 4
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Verses header
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.accentColor)

                        Text("VERSES")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.secondaryText)
                            .tracking(1.2)

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Verses list
                    ForEach(Array(category.verses.enumerated()), id: \.element.id) { index, fastingVerse in
                        FastingVerseCard(
                            fastingVerse: fastingVerse,
                            index: index + 1,
                            totalVerses: category.verseCount,
                            onNavigate: {
                                selectedVerseForNav = (fastingVerse.surahNumber, fastingVerse.verseNumber)
                                navigateToVerse = true
                            }
                        )
                    }

                    Spacer(minLength: 40)
                }
                }
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
        .darkScreenAura(glowOpacity: 0.36)
    }

    @ViewBuilder private var emeraldSections: some View {
        VStack(spacing: 20) {
            // Category header card
            EmCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        EmIconChip(sfSymbol: category.icon, size: 56)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(localizedFastingEyebrow.uppercased())
                                .font(.system(size: 11, weight: .bold)).tracking(3)
                                .foregroundColor(themeManager.accentColor)
                            Text(category.title(for: languageManager.selectedLanguage))
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
                    Text(category.description(for: languageManager.selectedLanguage))
                        .font(EmType.serif(16 * readingSettings.scale, .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .environment(\.layoutDirection,
                             languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

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
                            selectedVerseForNav = (fastingVerse.surahNumber, fastingVerse.verseNumber)
                            navigateToVerse = true
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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(fastingVerse.surahNumber)"],
              let verse = verses["\(fastingVerse.verseNumber)"] else {
            return nil
        }
        // Verse translations exist only in English + Urdu; Arabic/English fall back to English.
        let translation: String
        if languageManager.selectedLanguage == .urdu, let urdu = verse.translationUrdu, !urdu.isEmpty {
            translation = urdu
        } else {
            translation = verse.translation
        }
        return (verse.arabicText, translation)
    }

    /// Verse translation is Urdu-only (Arabic falls back to English), so RTL only for Urdu.
    private var verseTranslationIsRTL: Bool { languageManager.selectedLanguage == .urdu }

    var surahName: String {
        dataManager.quranData?.surahs.first { $0.number == fastingVerse.surahNumber }?.englishName ?? "Surah \(fastingVerse.surahNumber)"
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
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
                        .multilineTextAlignment(verseTranslationIsRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: verseTranslationIsRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, verseTranslationIsRTL ? .rightToLeft : .leftToRight)
                }

                // Relevance note
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(fastingVerse.relevanceNote(for: languageManager.selectedLanguage))
                        .font(.system(size: 13 * readingSettings.scale))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection,
                             languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
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

    private var legacyBody: some View {
        VStack(spacing: 0) {
            // Verse header
            HStack(spacing: 12) {
                // Verse number badge
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 40, height: 40)

                    Text("\(index)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Verse \(index) of \(totalVerses)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)

                    Text("\(surahName) (\(fastingVerse.surahNumber):\(fastingVerse.verseNumber))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()

                VerseRecitationButton(surahNumber: fastingVerse.surahNumber, verseNumber: fastingVerse.verseNumber, size: 32)

                if fastingVerse.isKeyVerse {
                    Text("KEY VERSE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(themeManager.accentColor.opacity(0.15))
                        }
                }
            }
            .padding(20)

            Divider()
                .background(themeManager.strokeColor)

            // Verse text
            if let verse = verseData {
                VStack(alignment: .leading, spacing: 16) {
                    // Arabic text
                    Text(verse.arabic)
                        .font(.custom("AmiriQuran-Regular", size: 24 * readingSettings.scale))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .shadow(color: themeManager.isDarkMode ? themeManager.accentColor.opacity(0.32) : .clear, radius: 16)

                    // Translation
                    Text(verse.translation)
                        .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4 * readingSettings.scale)
                        .multilineTextAlignment(verseTranslationIsRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: verseTranslationIsRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, verseTranslationIsRTL ? .rightToLeft : .leftToRight)
                }
                .padding(20)

                Divider()
                    .background(themeManager.strokeColor)
            }

            // Relevance note
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)

                    Text("Relevance to Fasting")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                }

                Text(fastingVerse.relevanceNote(for: languageManager.selectedLanguage))
                    .font(.system(size: 15 * readingSettings.scale, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
                    .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
            }
            .padding(20)
            .environment(\.layoutDirection,
                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
            .background {
                Rectangle()
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
            }

            Divider()
                .background(themeManager.strokeColor)

            // Action button
            HStack(spacing: 16) {
                Button(action: onNavigate) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 14))

                        Text("Read Full Tafsir")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(themeManager.accentGradient)
                            .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06),
                    radius: 16, x: 0, y: 4
                )
        }
        .padding(.horizontal, 20)
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
                ]
            )
        )
    }
}
