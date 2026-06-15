//
//  FoodDetailView.swift
//  Thaqalayn
//
//  Detail for a single food: illustration, the Qur'an verse (tappable → reader),
//  an Ahlul Bayt narration, a Sunnah practice tip, and a gentle nutrition note.
//

import SwiftUI

struct FoodDetailView: View {
    let food: Food
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @State private var navigateToVerse = false
    @Environment(\.dismiss) private var dismiss

    private var surahData: SurahWithTafsir? {
        dataManager.availableSurahs.first(where: { $0.surah.number == food.surahNumber })
    }
    private var verse: VerseWithTafsir? {
        surahData?.verses.first(where: { $0.number == food.verseNumber })
    }

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 18) {
                    hero
                    verseSection
                    infoCard(label: "From the Ahl al-Bayt", icon: "book.fill", text: food.narration(for: languageManager.selectedLanguage), source: food.narrationSource)
                    infoCard(label: "From the Sunnah", icon: "sparkles", text: food.sunnahTip(for: languageManager.selectedLanguage), source: nil)
                    infoCard(label: "Nutrition", icon: "leaf.fill", text: food.nutritionNote(for: languageManager.selectedLanguage), source: nil)
                    shareSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }

            // Hidden link: tapping the verse reference opens that ayah in the reader.
            if let s = surahData {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: s, targetVerse: food.verseNumber),
                    isActive: $navigateToVerse
                ) { EmptyView() }
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
                        Text("Back")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .darkScreenAura()
        .hideTabBarInEmerald()
    }

    // Hero — emoji-in-glass-chip placeholder (Phase 2 swaps to Image(food.illustrationAsset)).
    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(themeManager.accentChip)
                    .frame(width: 104, height: 104)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                Text(food.emoji).font(.system(size: 52))
            }
            .shadow(color: themeManager.accentColor.opacity(0.18), radius: 16, x: 0, y: 6)

            Text(food.name(for: languageManager.selectedLanguage))
                .font(themeManager.isMidnightEmerald ? EmType.serif(30, .semiBold) : .system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection,
                             languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
        }
        .padding(.top, 8)
    }

    private var verseSection: some View {
        cardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Button(action: { if surahData != nil { navigateToVerse = true } }) {
                        HStack(spacing: 5) {
                            Text("Qur'an \(food.surahNumber):\(food.verseNumber)")
                                .font(.system(size: 12, weight: .bold)).tracking(1)
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(surahData == nil)

                    Spacer(minLength: 8)

                    VerseRecitationButton(surahNumber: food.surahNumber, verseNumber: food.verseNumber, size: 34)
                }

                if let v = verse {
                    Text(v.arabicText)
                        .font(themeManager.isMidnightEmerald ? EmType.arabic(26 * readingSettings.scale) : .system(size: 24 * readingSettings.scale, weight: .regular))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(10 * readingSettings.scale)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .environment(\.layoutDirection, .rightToLeft)
                        .textSelection(.enabled)

                    Text(v.displayTranslation(for: languageManager.selectedLanguage))
                        .font(themeManager.isMidnightEmerald ? EmType.serif(16 * readingSettings.scale, .medium) : .system(size: 16 * readingSettings.scale, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(5 * readingSettings.scale)
                        .multilineTextAlignment(languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                } else {
                    Text("Tap to open this verse in the reader.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.tertiaryText)
                }
            }
        }
    }

    private func infoCard(label: String, icon: String, text: String, source: String?) -> some View {
        let isRTL = languageManager.selectedLanguage.isRTL
        return cardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 7) {
                    Image(systemName: icon).font(.system(size: 12, weight: .bold))
                    Text(label.uppercased()).font(.system(size: 11, weight: .bold)).tracking(1.5)
                }
                .foregroundColor(themeManager.accentColor)

                Text(text)
                    .font(themeManager.isMidnightEmerald ? EmType.serif(16 * readingSettings.scale, .medium) : .system(size: 16 * readingSettings.scale, weight: .regular))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let source = source {
                    Text(source)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
            }
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }

    // Share — formatted text block, matching the Daily Duas share pattern.
    private var shareSection: some View {
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

    private var shareText: String {
        let lang = languageManager.selectedLanguage
        var parts: [String] = ["\(food.emoji) \(food.name(for: lang))"]

        if let v = verse {
            parts.append("Qur'an \(food.surahNumber):\(food.verseNumber)\n\(v.arabicText)")
            parts.append(v.displayTranslation(for: lang))
        } else {
            parts.append("Qur'an \(food.surahNumber):\(food.verseNumber)")
        }

        parts.append("From the Ahl al-Bayt\n\(food.narration(for: lang))\n— \(food.narrationSource)")
        parts.append("From the Sunnah\n\(food.sunnahTip(for: lang))")
        parts.append("Nutrition\n\(food.nutritionNote(for: lang))")
        parts.append("Sent via Thaqalayn")

        return parts.joined(separator: "\n\n")
    }

    // Themed card container — EmCard glass for emerald, rounded glass/white for legacy.
    @ViewBuilder
    private func cardContainer<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        if themeManager.isMidnightEmerald {
            EmCard { content().padding(16) }
        } else {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.strokeColor, lineWidth: 1))
                )
        }
    }
}
