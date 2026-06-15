//
//  AhlulbaytEntryDetailView.swift
//  Thaqalayn
//
//  Detailed view showing Ahl al-Bayt entry with verses and perspectives
//

import SwiftUI

struct AhlulbaytEntryDetailView: View {
    let entry: AhlulbaytEntry
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var ahlulbaytManager = AhlulbaytQuranManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    private var localizedScreenEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أهل البيت في القرآن"
        case .urdu:   return "قرآن میں اہلِ بیت"
        default:      return "Ahl al-Bayt in the Quran"
        }
    }
    @State private var selectedVerseForNav: (surah: Int, verse: Int)?
    @State private var navigateToVerse = false

    var relatedEntries: [AhlulbaytEntry] {
        ahlulbaytManager.relatedEntries(for: entry)
    }

    var body: some View {
        ZStack {
            // Adaptive background
            AdaptiveModernBackground()

            ScrollView {
                if themeManager.isMidnightEmerald {
                    emeraldSections
                } else {
                VStack(spacing: 24) {
                    // Entry header
                    VStack(spacing: 16) {
                        // Category badge
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: entry.categoryIcon)
                                    .font(.system(size: 14, weight: .semibold))

                                Text(entry.category.displayName)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(themeManager.accentColor.opacity(0.15))
                            }

                            Spacer()
                        }

                        // Entry title
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(themeManager.accentColor)

                                Text(localizedScreenEyebrow.uppercased())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            Text(entry.title(for: languageManager.selectedLanguage))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.primaryText)
                                .lineSpacing(4)
                        }
                    }
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                            .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Ahl al-Bayt Members
                    if !entry.ahlulbaytMembers(for: languageManager.selectedLanguage).isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.accentColor)

                                Text("AHL AL-BAYT MEMBERS")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            FlowLayout(spacing: 8) {
                                ForEach(entry.ahlulbaytMembers(for: languageManager.selectedLanguage), id: \.self) { member in
                                    Text(member)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.accentColor)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background {
                                            Capsule()
                                                .fill(themeManager.accentColor.opacity(0.12))
                                        }
                                }
                            }
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                    }

                    // Verses header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text("QURANIC REFERENCE")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)
                        }

                        Text("This entry references \(entry.verseCount) verse\(entry.verseCount == 1 ? "" : "s"):")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Verses with context
                    ForEach(Array(entry.verses.enumerated()), id: \.element.verseNumber) { index, ahlulbaytVerse in
                        AhlulbaytVerseCard(
                            ahlulbaytVerse: ahlulbaytVerse,
                            index: index + 1,
                            totalVerses: entry.verseCount,
                            onNavigate: {
                                selectedVerseForNav = (ahlulbaytVerse.surahNumber, ahlulbaytVerse.verseNumber)
                                navigateToVerse = true
                            }
                        )
                    }

                    // Revelation Context
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.accentColor)

                            Text("REVELATION CONTEXT")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.secondaryText)
                                .tracking(1.2)
                        }

                        Text(entry.revelationContext(for: languageManager.selectedLanguage))
                            .font(.system(size: 16 * readingSettings.scale, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineSpacing(6 * readingSettings.scale)
                            .multilineTextAlignment(languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                            .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                            .environment(\.layoutDirection,
                                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)

                    // Related entries
                    if !relatedEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "link.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.accentColor)

                                Text("RELATED ENTRIES")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .tracking(1.2)
                            }

                            ForEach(relatedEntries) { relatedEntry in
                                RelatedEntryCard(entry: relatedEntry)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
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
                        Text("Ahl al-Bayt")
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura()
    }

    // MARK: - Emerald

    @ViewBuilder private var emeraldSections: some View {
        VStack(spacing: 20) {
            // Header card
            EmCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 7) {
                        Image(systemName: entry.categoryIcon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(entry.category.displayName)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(themeManager.accentColor)
                    .padding(.horizontal, 13).padding(.vertical, 7)
                    .background(Capsule().fill(themeManager.accentChip))
                    .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))

                    VStack(alignment: .leading, spacing: 7) {
                        Text(localizedScreenEyebrow.uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(3)
                            .foregroundColor(themeManager.accentColor)
                        Text(entry.title(for: languageManager.selectedLanguage))
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(22)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Ahl al-Bayt members
            if !entry.ahlulbaytMembers(for: languageManager.selectedLanguage).isEmpty {
                EmDetailCard(icon: "person.3", label: "Ahl al-Bayt Members") {
                    FlowLayout(spacing: 8) {
                        ForEach(entry.ahlulbaytMembers(for: languageManager.selectedLanguage), id: \.self) { member in
                            Text(member)
                                .font(.system(size: 13.5, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(themeManager.accentChip))
                                .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Verses header
            VStack(alignment: .leading, spacing: 8) {
                EmSectionLabel(icon: "book.pages", text: "Quranic Reference")
                Text("This entry references \(entry.verseCount) verse\(entry.verseCount == 1 ? "" : "s"):")
                    .font(EmType.serif(17, .medium))
                    .foregroundColor(themeManager.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)

            // Verses with context
            ForEach(Array(entry.verses.enumerated()), id: \.element.verseNumber) { index, ahlulbaytVerse in
                AhlulbaytVerseCard(
                    ahlulbaytVerse: ahlulbaytVerse,
                    index: index + 1,
                    totalVerses: entry.verseCount,
                    onNavigate: {
                        selectedVerseForNav = (ahlulbaytVerse.surahNumber, ahlulbaytVerse.verseNumber)
                        navigateToVerse = true
                    }
                )
            }

            // Revelation context
            EmDetailCard(icon: "clock", label: "Revelation Context") {
                Text(entry.revelationContext(for: languageManager.selectedLanguage))
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .multilineTextAlignment(languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                    .environment(\.layoutDirection,
                                 languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
            }

            // Related entries
            if !relatedEntries.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    EmSectionLabel(icon: "link", text: "Related Entries")
                    ForEach(relatedEntries) { relatedEntry in
                        RelatedEntryCard(entry: relatedEntry)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct AhlulbaytVerseCard: View {
    let ahlulbaytVerse: AhlulbaytVerse
    let index: Int
    let totalVerses: Int
    let onNavigate: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    var verseData: (arabic: String, translation: String)? {
        guard let verses = dataManager.quranData?.verses["\(ahlulbaytVerse.surahNumber)"],
              let verse = verses["\(ahlulbaytVerse.verseNumber)"] else {
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
        dataManager.quranData?.surahs.first { $0.number == ahlulbaytVerse.surahNumber }?.englishName ?? "Surah \(ahlulbaytVerse.surahNumber)"
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    EmNumeralCircle(n: index, size: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Verse \(index) of \(totalVerses)")
                            .font(.system(size: 11)).tracking(0.3)
                            .foregroundColor(themeManager.tertiaryText)
                        Text("\(surahName) · \(ahlulbaytVerse.surahNumber):\(ahlulbaytVerse.verseNumber)")
                            .font(.system(size: 13, weight: .bold)).tracking(0.3)
                            .foregroundColor(themeManager.accentColor)
                    }
                    Spacer()
                    VerseRecitationButton(surahNumber: ahlulbaytVerse.surahNumber, verseNumber: ahlulbaytVerse.verseNumber, size: 32)
                    if ahlulbaytVerse.isPrimary {
                        Text("PRIMARY")
                            .font(.system(size: 8.5, weight: .bold)).tracking(1)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                }
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
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.accentColor)
                    Text(ahlulbaytVerse.context(for: languageManager.selectedLanguage))
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
                Button(action: onNavigate) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill").font(.system(size: 13, weight: .semibold))
                        Text("Read Full Tafsir").font(.system(size: 14, weight: .bold)).tracking(0.3)
                    }
                    .foregroundColor(themeManager.onAccentText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(themeManager.accentGradient))
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 20, x: 0, y: 8)
                }
                .buttonStyle(EmPressStyle())
                .padding(.top, 2)
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

                    Text("\(surahName) (\(ahlulbaytVerse.surahNumber):\(ahlulbaytVerse.verseNumber))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }

                Spacer()

                VerseRecitationButton(surahNumber: ahlulbaytVerse.surahNumber, verseNumber: ahlulbaytVerse.verseNumber, size: 32)

                if ahlulbaytVerse.isPrimary {
                    Text("PRIMARY")
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

            // Verse context
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)

                    Text("Verse Context")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                }

                Text(ahlulbaytVerse.context(for: languageManager.selectedLanguage))
                    .font(.system(size: 15 * readingSettings.scale, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
                    .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .environment(\.layoutDirection,
                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
            .background {
                Rectangle()
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.98, green: 0.98, blue: 0.95))
            }

            Divider()
                .background(themeManager.strokeColor)

            // Action buttons
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
                .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }
}

struct RelatedEntryCard: View {
    let entry: AhlulbaytEntry
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var navigateToEntry = false

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        NavigationLink(destination: AhlulbaytEntryDetailView(entry: entry), isActive: $navigateToEntry) {
            EmCard {
                HStack(spacing: 12) {
                    EmIconChip(sfSymbol: entry.categoryIcon, size: 38)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.category.displayName.uppercased())
                            .font(.system(size: 10, weight: .bold)).tracking(1.5)
                            .foregroundColor(themeManager.accentColor)

                        Text(entry.title(for: languageManager.selectedLanguage))
                            .font(EmType.serif(17, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .padding(14)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle())
    }

    private var legacyBody: some View {
        NavigationLink(destination: AhlulbaytEntryDetailView(entry: entry), isActive: $navigateToEntry) {
            HStack(spacing: 12) {
                Image(systemName: entry.categoryIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 32, height: 32)
                    .background {
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.15))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.category.displayName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(themeManager.accentColor)

                    Text(entry.title(for: languageManager.selectedLanguage))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
        }
        .buttonStyle(EmPressStyle())
    }
}

// FlowLayout for wrapping member tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    NavigationView {
        AhlulbaytEntryDetailView(
            entry: AhlulbaytEntry(
                id: "ab1",
                titleEn: "Verse of Purification (Ayat al-Tathir)",
                titleAr: "آية التطهير",
                titleUr: "آیتِ تطہیر",
                shortTitleEn: "Al-Tathir",
                shortTitleAr: "آية التطهير",
                shortTitleUr: "آیتِ تطہیر",
                category: .purity,
                verses: [
                    AhlulbaytVerse(
                        surahNumber: 33,
                        verseNumber: 33,
                        contextEn: "Allah's declaration of the purity of the Prophet's family",
                        contextAr: "إعلان الله طهارة أهل بيت النبي (ع)",
                        contextUr: "اللہ کی طرف سے اہلِ بیت کی طہارت کا اعلان",
                        isPrimary: true
                    )
                ],
                ahlulbaytMembersEn: ["Prophet Muhammad", "Ali ibn Abi Talib", "Fatimah az-Zahra", "Hasan ibn Ali", "Husayn ibn Ali"],
                ahlulbaytMembersAr: ["النبي محمد (ص)", "علي بن أبي طالب (ع)", "فاطمة الزهراء (ع)", "الحسن بن علي (ع)", "الحسين بن علي (ع)"],
                ahlulbaytMembersUr: ["پیغمبر اکرم (ص)", "علی ابن ابی طالب (ع)", "فاطمہ زہرا (س)", "امام حسن (ع)", "امام حسین (ع)"],
                revelationContextEn: "This verse was revealed specifically about the five members of the Prophet's family.",
                revelationContextAr: "نزلت هذه الآية خصيصًا في الخمسة من أهل بيت النبي (ع).",
                revelationContextUr: "یہ آیت خاص طور پر پیغمبر کے پانچ اہلِ بیت کے بارے میں نازل ہوئی۔",
                relatedEntries: []
            )
        )
    }
}
