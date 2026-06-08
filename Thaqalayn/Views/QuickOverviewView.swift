//
//  QuickOverviewView.swift
//  Thaqalayn
//
//  Interactive quick overview with concept bubbles around Arabic verse
//

import SwiftUI

// MARK: - Highlighted Arabic Text Component

struct HighlightedArabicText: View {
    let text: String
    let highlightText: String?
    let highlightColor: Color
    let isHighlighting: Bool

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    private func arabicFont(bold: Bool) -> Font {
        themeManager.isMidnightEmerald ? EmType.arabic(28 * readingSettings.scale, bold: bold) : .system(size: 28 * readingSettings.scale, weight: bold ? .bold : .medium)
    }

    var body: some View {
        if let highlightText = highlightText, !highlightText.isEmpty, isHighlighting {
            // Build attributed text with highlight
            highlightedTextView(fullText: text, highlight: highlightText)
        } else {
            // Regular Arabic text
            Text(text)
                .font(arabicFont(bold: false))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(12 * readingSettings.scale)
                .environment(\.layoutDirection, .rightToLeft)
        }
    }

    @ViewBuilder
    private func highlightedTextView(fullText: String, highlight: String) -> some View {
        // Split the text to find and highlight the matching portion
        let components = splitText(fullText: fullText, highlight: highlight)

        // Use Text concatenation to preserve natural RTL text flow
        components.reduce(Text("")) { result, component in
            if component.isHighlighted {
                return result + Text(component.text)
                    .font(arabicFont(bold: true))
                    .foregroundColor(highlightColor)
            } else {
                return result + Text(component.text)
                    .font(arabicFont(bold: false))
                    .foregroundColor(themeManager.primaryText)
            }
        }
        .multilineTextAlignment(.center)
        .lineSpacing(12 * readingSettings.scale)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private struct TextComponent: Equatable {
        let text: String
        let isHighlighted: Bool
    }

    private func splitText(fullText: String, highlight: String) -> [TextComponent] {
        // Try to find the highlight text in the full text
        guard let range = fullText.range(of: highlight) else {
            // If not found, return the whole text unhighlighted
            return [TextComponent(text: fullText, isHighlighted: false)]
        }

        var components: [TextComponent] = []

        // Text before highlight
        let beforeText = String(fullText[..<range.lowerBound])
        if !beforeText.isEmpty {
            components.append(TextComponent(text: beforeText, isHighlighted: false))
        }

        // Highlighted text
        components.append(TextComponent(text: highlight, isHighlighted: true))

        // Text after highlight
        let afterText = String(fullText[range.upperBound...])
        if !afterText.isEmpty {
            components.append(TextComponent(text: afterText, isHighlighted: false))
        }

        return components
    }
}

// MARK: - Shared helpers for the redesigned Gems sheet

/// Measures a view's natural height so a scroll container can hug its content up to a cap.
private struct VerseHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private extension View {
    /// Softly fades the top & bottom edges of a scroll region so content dissolves
    /// into the background instead of hard-clipping. Works over any background
    /// because it masks to transparent (revealing whatever is behind).
    func scrollEdgeFade(top: CGFloat = 14, bottom: CGFloat = 30) -> some View {
        self.mask(
            GeometryReader { geo in
                let h = max(geo.size.height, 1)
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: min(top / h, 0.5)),
                        .init(color: .black, location: 1 - min(bottom / h, 0.5)),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
        )
    }
}

/// Glass "Back to gems" pill with a themed chevron. Used by the detail pane.
private struct BackToGemsChip: View {
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.accentColor)
                Text("Back to gems")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
            }
            .padding(.leading, 12).padding(.trailing, 15).padding(.vertical, 9)
            .background(
                Capsule().fill(themeManager.glassSurface)
                    .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
            )
        }
        .buttonStyle(EmPressStyle())
    }
}

/// The verse, pinned at the top of the Gems sheet. Shows the reference label,
/// the Arabic (with the selected gem's fragment highlighted), and a gold hairline.
/// Caps its height and scrolls internally only when the verse is taller than the cap,
/// so short verses hug their content and the highlight stays visible.
private struct PinnedVerseView: View {
    let surah: Surah
    let verse: VerseWithTafsir
    let selectedConcept: VerseConcept?

    @StateObject private var themeManager = ThemeManager.shared
    @State private var verseHeight: CGFloat = 0

    private let maxVerseHeight: CGFloat = 230

    private var highlightColor: Color {
        selectedConcept.flatMap { Color(hex: $0.colorHex) } ?? themeManager.accentColor
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("\(surah.englishName.uppercased()) · \(verse.number)")
                .font(.system(size: 11, weight: .bold)).tracking(2)
                .foregroundColor(themeManager.accentColor)

            ScrollView(.vertical, showsIndicators: false) {
                HighlightedArabicText(
                    text: verse.arabicText,
                    highlightText: selectedConcept?.arabicHighlight,
                    highlightColor: highlightColor,
                    isHighlighting: selectedConcept != nil
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .background(GeometryReader { g in
                    Color.clear.preference(key: VerseHeightKey.self, value: g.size.height)
                })
            }
            .frame(height: min(max(verseHeight, 1), maxVerseHeight))
            .onPreferenceChange(VerseHeightKey.self) { verseHeight = $0 }

            // gold hairline divider, fading at both ends
            LinearGradient(
                colors: [.clear, themeManager.accentColor.opacity(0.45), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 1)
        }
        .padding(.horizontal, 22)
        .padding(.top, 2)
    }
}

struct QuickOverviewView: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let quickOverview: QuickOverviewData
    let onViewFullCommentary: () -> Void

    init(verse: VerseWithTafsir,
         surah: Surah,
         quickOverview: QuickOverviewData,
         initialConceptId: String? = nil,
         onViewFullCommentary: @escaping () -> Void) {
        self.verse = verse
        self.surah = surah
        self.quickOverview = quickOverview
        self.onViewFullCommentary = onViewFullCommentary
        _selectedConcept = State(initialValue: initialConceptId.flatMap { id in
            quickOverview.concepts.first { $0.id == id }
        })
    }

    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var selectedConcept: VerseConcept? = nil
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var legacyBody: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(themeManager.tertiaryText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12).padding(.bottom, 16)

            headerView
                .padding(.horizontal, 24).padding(.bottom, 10)

            PinnedVerseView(surah: surah, verse: verse, selectedConcept: selectedConcept)

            Group {
                if let concept = selectedConcept {
                    gemDetailPane(concept)
                        .transition(.opacity)
                } else {
                    legacyBrowseScroll
                        .transition(.opacity)
                }
            }
        }
        .background(backgroundView)
        .darkScreenAura()
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .frame(maxWidth: isIPad ? 600 : nil)
    }

    private var legacyBrowseScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                conceptBubblesGrid
                languageSelectorView
                readFullTafsirCTA
            }
            .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 40)
        }
    }

    // MARK: - Emerald Body

    private var emeraldBody: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(themeManager.tertiaryText.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12).padding(.bottom, 14)

            emeraldHeader
                .padding(.horizontal, 20).padding(.bottom, 14)

            PinnedVerseView(surah: surah, verse: verse, selectedConcept: selectedConcept)

            Group {
                if let concept = selectedConcept {
                    gemDetailPane(concept)
                        .transition(.opacity)
                } else {
                    emeraldBrowseScroll
                        .transition(.opacity)
                }
            }
        }
        .background(EmeraldBackground())
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .frame(maxWidth: isIPad ? 600 : nil)
    }

    private var emeraldBrowseScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 22) {
                conceptBubblesGrid
                languageSelectorView
                readFullTafsirCTA
            }
            .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
        }
    }

    private var emeraldHeader: some View {
        HStack {
            Image(systemName: "sparkles").font(.system(size: 26)).foregroundStyle(themeManager.accentGradient)
            VStack(alignment: .leading, spacing: 2) {
                Text("Gems").font(EmType.serif(26, .semiBold)).foregroundColor(themeManager.primaryText)
                Text("Precious insights, unveiled").font(.system(size: 13, weight: .medium)).foregroundColor(themeManager.secondaryText)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
        }
    }

    // MARK: - Redesigned panes (Option 3)

    private func conceptColor(_ c: VerseConcept) -> Color {
        Color(hex: c.colorHex) ?? themeManager.accentColor
    }

    /// Detail pane that REPLACES the gem grid when a gem is selected.
    /// Back-chip + fade-masked scrolling insight + pinned CTA. Verse stays pinned above.
    private func gemDetailPane(_ concept: VerseConcept) -> some View {
        let lang = languageManager.selectedLanguage
        let rtl = lang.isRTL
        return VStack(spacing: 0) {
            HStack {
                BackToGemsChip {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selectedConcept = nil
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 22).padding(.top, 12).padding(.bottom, 4)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 10) {
                        Image(systemName: concept.icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(conceptColor(concept))
                        Text(concept.getTitle(language: lang).uppercased())
                            .font(.system(size: 14, weight: .bold, design: .rounded)).tracking(1)
                            .foregroundColor(themeManager.primaryText)
                    }
                    detailSection(conceptColor(concept), "The Core Insight:", concept.getCoreInsight(language: lang), rtl: rtl)
                    detailSection(conceptColor(concept), "Why it matters:", concept.getWhyItMatters(language: lang), rtl: rtl)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22).padding(.top, 8).padding(.bottom, 26)
            }
            .scrollEdgeFade()

            readFullTafsirCTA
                .padding(.horizontal, 22).padding(.top, 6).padding(.bottom, 18)
        }
    }

    @ViewBuilder
    private func detailSection(_ color: Color, _ title: String, _ text: String, rtl: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 15 * readingSettings.scale, weight: .regular, design: .serif))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(7 * readingSettings.scale)
                .multilineTextAlignment(rtl ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: rtl ? .trailing : .leading)
                .environment(\.layoutDirection, rtl ? .rightToLeft : .leftToRight)
        }
    }

    /// Single "Read Full Tafsir" CTA shared by browse + detail, both themes.
    /// Emerald → gold gradient + dark text; Legacy → its purple gradient + white.
    private var readFullTafsirCTA: some View {
        Button(action: {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onViewFullCommentary() }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "book.fill").font(.system(size: 15, weight: .semibold))
                Text("Read Full Tafsir").font(.system(size: 15, weight: .bold))
                Image(systemName: "arrow.right").font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(themeManager.isMidnightEmerald ? themeManager.onAccentText : .white)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(themeManager.isMidnightEmerald ? themeManager.accentGradient : themeManager.purpleGradient)
            )
            .shadow(color: themeManager.accentColor.opacity(0.28), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(EmPressStyle())
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(themeManager.accentGradient)

            VStack(alignment: .leading, spacing: 4) {
                Text("Gems")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text("Precious insights unveiled")
                    .font(.system(size: 13, weight: .medium))
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

    // MARK: - Concept Bubbles

    private var conceptBubblesGrid: some View {
        let concepts = quickOverview.concepts

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(concepts) { concept in
                ConceptBubbleView(
                    concept: concept,
                    language: languageManager.selectedLanguage,
                    isSelected: selectedConcept?.id == concept.id
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selectedConcept = concept
                    }
                }
            }
        }
    }

    // MARK: - Language Selector

    private var languageSelectorView: some View {
        HStack(spacing: 12) {
            ForEach(CommentaryLanguage.supportedTafsirLanguages, id: \.self) { language in
                Button(action: { languageManager.setLanguage(language) }) {
                    Text(language.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(languageManager.selectedLanguage == language ? .white : themeManager.tertiaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            if languageManager.selectedLanguage == language {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.accentGradient)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(themeManager.strokeColor, lineWidth: languageManager.selectedLanguage == language ? 0 : 1)
                        )
                }
            }
        }
    }

    // MARK: - Background

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

// MARK: - Concept Bubble View

struct ConceptBubbleView: View {
    let concept: VerseConcept
    let language: CommentaryLanguage
    let isSelected: Bool
    let onTap: () -> Void

    @StateObject private var themeManager = ThemeManager.shared

    private var bubbleColor: Color {
        Color(hex: concept.colorHex) ?? themeManager.accentColor
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: concept.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(bubbleColor)

                Text(concept.getTitle(language: language))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(themeManager.glassEffect)
                    .overlay(
                        Capsule()
                            .stroke(bubbleColor.opacity(0.5), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: bubbleColor.opacity(0.2), radius: isSelected ? 8 : 4)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview

#Preview("Gems — Quick Overview") {
    let sampleSurah = Surah(
        number: 1, name: "الفاتحة", englishName: "Al-Fatiha",
        englishNameTranslation: "The Opening", arabicName: "الفاتحة",
        versesCount: 7, revelationType: "Meccan"
    )
    let sampleVerse = Verse(
        arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
        translationUrdu: "عظیم اور دائمی رحمتوں والے خدا کے نام سے",
        juz: 1, manzil: 1, page: 1, ruku: 1, hizbQuarter: 1,
        sajda: SajdaInfo(hasSajda: false, id: nil, recommended: nil)
    )
    let sampleConcepts = [
        VerseConcept(
            id: "1:1:divine-mercy", title: "Divine Mercy", icon: "heart.fill", colorHex: "#7BC47F",
            coreInsight: "The verse opens with two names of Allah rooted in 'rahma' (mercy) — Rahman encompasses all creation, while Rahim is Allah's special mercy reserved for believers.",
            whyItMatters: "Understanding Allah's mercy transforms fear into hope, encouraging us to approach Him with confidence rather than despair, and to begin every act trusting in His compassion.",
            position: .topLeft, arabicHighlight: "ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
            title_urdu: "رحمت الٰہی", coreInsight_urdu: "یہ آیت اللہ کے دو ناموں سے شروع ہوتی ہے۔", whyItMatters_urdu: "اللہ کی رحمت کو سمجھنا خوف کو امید میں بدل دیتا ہے۔",
            title_ar: "الرحمة الإلهية", coreInsight_ar: "تفتتح الآية باسمين من أسماء الله.", whyItMatters_ar: "فهم رحمة الله يحول الخوف إلى أمل."
        ),
        VerseConcept(
            id: "1:1:sacred-beginning", title: "Sacred Beginning", icon: "sparkles", colorHex: "#9B8FBF",
            coreInsight: "Beginning in Allah's name transforms ordinary actions into worship, sanctifying every deed from eating to major life decisions.",
            whyItMatters: "This simple practice makes spirituality practical — every moment becomes an opportunity for divine connection.",
            position: .topRight, arabicHighlight: "بِسْمِ ٱللَّهِ",
            title_urdu: "مقدس آغاز", coreInsight_urdu: "اللہ کے نام سے شروع کرنا عام کاموں کو عبادت میں بدل دیتا ہے۔", whyItMatters_urdu: "یہ آسان عمل روحانیت کو عملی بناتا ہے۔",
            title_ar: "البداية المقدسة", coreInsight_ar: "البدء باسم الله يحول الأعمال العادية إلى عبادة.", whyItMatters_ar: "هذه الممارسة البسيطة تجعل الروحانية عملية."
        ),
        VerseConcept(
            id: "1:1:divine-name", title: "Allah's Name", icon: "sun.max.fill", colorHex: "#E8B86D",
            coreInsight: "Allah is the comprehensive name encompassing all divine attributes — His majesty, beauty, and perfection.",
            whyItMatters: "By invoking Allah's name, we acknowledge that all power, success, and blessing comes from Him alone.",
            position: .bottomLeft, arabicHighlight: "ٱللَّهِ",
            title_urdu: "اللہ کا نام", coreInsight_urdu: "اللہ جامع نام ہے جو تمام صفات کو شامل ہے۔", whyItMatters_urdu: "اللہ کا نام لے کر ہم اقرار کرتے ہیں کہ ہر طاقت اسی سے ہے۔",
            title_ar: "اسم الله", coreInsight_ar: "الله هو الاسم الجامع لكل الصفات الإلهية.", whyItMatters_ar: "بذكر اسم الله نقر بأن كل قوة منه وحده."
        )
    ]
    let sampleTafsir = TafsirVerse(
        layer1: "", layer2: "", layer3: "", layer4: "", layer5: nil,
        layer1_urdu: nil, layer2_urdu: nil, layer3_urdu: nil, layer4_urdu: nil, layer5_urdu: nil,
        layer1_ar: nil, layer2_ar: nil, layer3_ar: nil, layer4_ar: nil, layer5_ar: nil,
        layer1_fr: nil, layer2_fr: nil, layer3_fr: nil, layer4_fr: nil, layer5_fr: nil,
        layer2short: nil, layer2short_urdu: nil, layer2short_ar: nil, layer2short_fr: nil,
        quickOverview: QuickOverviewData(concepts: sampleConcepts)
    )
    let sampleVWT = VerseWithTafsir(number: 1, verse: sampleVerse, tafsir: sampleTafsir)

    return QuickOverviewView(
        verse: sampleVWT, surah: sampleSurah,
        quickOverview: QuickOverviewData(concepts: sampleConcepts),
        onViewFullCommentary: {}
    )
}


