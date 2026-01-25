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

    var body: some View {
        if let highlightText = highlightText, !highlightText.isEmpty, isHighlighting {
            // Build attributed text with highlight
            highlightedTextView(fullText: text, highlight: highlightText)
        } else {
            // Regular Arabic text
            Text(text)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(12)
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
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(highlightColor)
            } else {
                return result + Text(component.text)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
            }
        }
        .multilineTextAlignment(.center)
        .lineSpacing(12)
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

struct QuickOverviewView: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let quickOverview: QuickOverviewData
    let onViewFullCommentary: () -> Void

    @State private var selectedLanguage: CommentaryLanguage = .english
    @State private var selectedConcept: VerseConcept? = nil
    @State private var showConceptDetail: Bool = false
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(themeManager.tertiaryText.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView

                        // Arabic verse with concept bubbles
                        arabicVerseSection

                        // Language selector
                        languageSelectorView

                        // Full tafsir button (hide when detail is shown)
                        if !showConceptDetail {
                            fullTafsirButton
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, showConceptDetail ? 280 : 40)
                }
            }
            .background(backgroundView)

            // Concept detail card overlay
            if showConceptDetail, let concept = selectedConcept {
                ConceptDetailCardOverlay(
                    concept: concept,
                    language: selectedLanguage,
                    onClose: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showConceptDetail = false
                            selectedConcept = nil
                        }
                    },
                    onViewFullTafsir: {
                        showConceptDetail = false
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onViewFullCommentary()
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .frame(maxWidth: isIPad ? 600 : nil)
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

    // MARK: - Arabic Verse Section

    private var arabicVerseSection: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            themeManager.tertiaryBackground.opacity(0.6),
                            themeManager.secondaryBackground.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )

            // Decorative orbs
            GeometryReader { geometry in
                Circle()
                    .fill(themeManager.floatingOrbColors[0])
                    .frame(width: 120, height: 120)
                    .blur(radius: 40)
                    .offset(x: -30, y: -20)

                Circle()
                    .fill(themeManager.floatingOrbColors[1])
                    .frame(width: 100, height: 100)
                    .blur(radius: 35)
                    .offset(x: geometry.size.width - 80, y: geometry.size.height - 80)
            }

            VStack(spacing: 20) {
                // Verse reference badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("\(verse.number)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text("\(surah.englishName) \(verse.number)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)
                }

                // Arabic text with highlighting
                HighlightedArabicText(
                    text: verse.arabicText,
                    highlightText: selectedConcept?.arabicHighlight,
                    highlightColor: selectedConcept.map { Color(hex: $0.colorHex) ?? themeManager.accentColor } ?? themeManager.accentColor,
                    isHighlighting: showConceptDetail
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 24)

                // Concept bubbles
                conceptBubblesGrid
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
        }
        .frame(minHeight: 320)
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
                    language: selectedLanguage,
                    isSelected: selectedConcept?.id == concept.id
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedConcept = concept
                        showConceptDetail = true
                    }
                }
            }
        }
    }

    // MARK: - Language Selector

    private var languageSelectorView: some View {
        HStack(spacing: 12) {
            ForEach(CommentaryLanguage.supportedTafsirLanguages, id: \.self) { language in
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

    // MARK: - Full Tafsir Button

    private var fullTafsirButton: some View {
        Button(action: {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onViewFullCommentary()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .font(.system(size: 16, weight: .semibold))

                Text("Read Full Tafsir")
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
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 12)
            )
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

// MARK: - Concept Detail Card Overlay

struct ConceptDetailCardOverlay: View {
    let concept: VerseConcept
    let language: CommentaryLanguage
    let onClose: () -> Void
    let onViewFullTafsir: () -> Void

    @StateObject private var themeManager = ThemeManager.shared

    private var conceptColor: Color {
        Color(hex: concept.colorHex) ?? themeManager.accentColor
    }

    private var isRTL: Bool {
        language.isRTL
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar for dragging
            RoundedRectangle(cornerRadius: 3)
                .fill(themeManager.tertiaryText.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 20) {
                // Header with icon and title
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: concept.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(conceptColor)

                        Text(concept.getTitle(language: language).uppercased())
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.primaryText)
                    }

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.tertiaryText)
                            .padding(8)
                            .background(Circle().fill(themeManager.tertiaryBackground.opacity(0.8)))
                    }
                }

                // Core Insight
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Core Insight:")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(conceptColor)

                    Text(concept.getCoreInsight(language: language))
                        .font(.system(size: themeManager.selectedTheme == .warmInviting ? 15 : 16, weight: .regular, design: .serif))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(7)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                }

                // Why it matters
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it matters:")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(conceptColor)

                    Text(concept.getWhyItMatters(language: language))
                        .font(.system(size: themeManager.selectedTheme == .warmInviting ? 15 : 16, weight: .regular, design: .serif))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(7)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                }

                // Read Full Tafsir button
                Button(action: onViewFullTafsir) {
                    Text("Read Full Tafsir")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(conceptColor)
                        )
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.primaryBackground)
                .shadow(color: Color.black.opacity(0.15), radius: 20, y: -5)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Concept Detail Card (Legacy - for sheet presentation)

struct ConceptDetailCard: View {
    let concept: VerseConcept
    let language: CommentaryLanguage
    let onViewFullTafsir: () -> Void

    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    private var conceptColor: Color {
        Color(hex: concept.colorHex) ?? themeManager.accentColor
    }

    private var isRTL: Bool {
        language.isRTL
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(themeManager.tertiaryText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and title
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: concept.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(conceptColor)

                        Text(concept.getTitle(language: language).uppercased())
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.primaryText)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.tertiaryText)
                            .padding(8)
                            .background(Circle().fill(themeManager.tertiaryBackground))
                    }
                }

                // Core Insight
                VStack(alignment: .leading, spacing: 6) {
                    Text("The Core Insight:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(conceptColor)

                    Text(concept.getCoreInsight(language: language))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(4)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                }

                // Why it matters
                VStack(alignment: .leading, spacing: 6) {
                    Text("Why it matters:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(conceptColor)

                    Text(concept.getWhyItMatters(language: language))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(4)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                }

                // Read Full Tafsir button
                Button(action: onViewFullTafsir) {
                    Text("Read Full Tafsir")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(conceptColor)
                        )
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

