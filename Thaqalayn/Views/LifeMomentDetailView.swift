//
//  LifeMomentDetailView.swift
//  Thaqalayn
//
//  Detail for a single life moment: the situation, its Qur'an verse (tappable →
//  reader), and a linked supplication from the Daily Duas (tappable → DuaDetailView).
//

import SwiftUI

struct LifeMomentDetailView: View {
    let moment: LifeMoment
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var duasManager = DuasManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @State private var navigateToVerse = false
    @Environment(\.dismiss) private var dismiss

    private var surahData: SurahWithTafsir? {
        dataManager.availableSurahs.first(where: { $0.surah.number == moment.surahNumber })
    }
    private var verse: VerseWithTafsir? {
        surahData?.verses.first(where: { $0.number == moment.verseNumber })
    }
    private var linkedDua: DailyDua? {
        guard let id = moment.duaId else { return nil }
        return duasManager.duas.first(where: { $0.id == id })
    }

    var body: some View {
        ZStack {
            AdaptiveModernBackground()

            ScrollView {
                VStack(spacing: 18) {
                    hero
                    verseSection
                    if let dua = linkedDua {
                        duaSection(dua)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }

            // Hidden link: tapping the verse reference opens that ayah in the reader.
            if let s = surahData {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: s, targetVerse: moment.verseNumber),
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

    // Hero — category icon chip + the situation + a category pill.
    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(themeManager.accentChip)
                    .frame(width: 104, height: 104)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                Image(systemName: moment.categoryIcon)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
            }
            .shadow(color: themeManager.accentColor.opacity(0.18), radius: 16, x: 0, y: 6)

            Text(moment.situation(for: languageManager.selectedLanguage))
                .font(themeManager.isMidnightEmerald ? EmType.serif(30, .semiBold) : .system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)

            Text(moment.category.uppercased())
                .font(.system(size: 11, weight: .bold)).tracking(1.5)
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(themeManager.accentChip))
                .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .padding(.top, 8)
    }

    private var verseSection: some View {
        cardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Button(action: { if surahData != nil { navigateToVerse = true } }) {
                        HStack(spacing: 5) {
                            Text("Qur'an \(moment.surahNumber):\(moment.verseNumber)")
                                .font(.system(size: 12, weight: .bold)).tracking(1)
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(surahData == nil)

                    Spacer(minLength: 8)

                    VerseRecitationButton(surahNumber: moment.surahNumber, verseNumber: moment.verseNumber, size: 34)
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

    // The linked supplication — the whole card taps through to the full DuaDetailView.
    private func duaSection(_ dua: DailyDua) -> some View {
        NavigationLink(destination: DuaDetailView(dua: dua)) {
            cardContainer(highlight: true) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 7) {
                        Image(systemName: "hands.sparkles.fill").font(.system(size: 12, weight: .bold))
                        Text("A DUʿĀ FOR THIS MOMENT").font(.system(size: 11, weight: .bold)).tracking(1.5)
                    }
                    .foregroundColor(themeManager.accentColor)

                    Text(dua.situation(for: languageManager.selectedLanguage))
                        .font(themeManager.isMidnightEmerald ? EmType.serif(20, .semiBold) : .system(size: 19, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(dua.arabic)
                        .font(themeManager.isMidnightEmerald ? EmType.arabic(21 * readingSettings.scale) : .system(size: 20 * readingSettings.scale, weight: .regular))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8 * readingSettings.scale)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .environment(\.layoutDirection, .rightToLeft)

                    Text(dua.transliteration)
                        .font(themeManager.isMidnightEmerald ? EmType.serifItalic(15 * readingSettings.scale) : .system(size: 14 * readingSettings.scale, weight: .regular, design: .serif).italic())
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(themeManager.strokeColor)
                        .frame(height: 1)
                        .padding(.vertical, 2)

                    HStack(spacing: 6) {
                        Text("Open duʿā").font(.system(size: 13.5, weight: .bold))
                        Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                        Spacer(minLength: 8)
                        Text(dua.source)
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .lineLimit(1).truncationMode(.tail)
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // Themed card container — EmCard glass for emerald, rounded glass/white for legacy.
    // `highlight` gives the duʿā card a gold edge + soft glow so it stands apart.
    @ViewBuilder
    private func cardContainer<Content: View>(highlight: Bool = false, @ViewBuilder _ content: () -> Content) -> some View {
        if themeManager.isMidnightEmerald {
            if highlight {
                content()
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(themeManager.accentColor.opacity(0.07))
                            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(themeManager.accentColor.opacity(0.30), lineWidth: 1))
                    )
                    .shadow(color: themeManager.accentColor.opacity(0.12), radius: 18, x: 0, y: 8)
            } else {
                EmCard { content().padding(16) }
            }
        } else {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(highlight ? themeManager.accentColor.opacity(0.4) : themeManager.strokeColor, lineWidth: 1))
                )
        }
    }
}
