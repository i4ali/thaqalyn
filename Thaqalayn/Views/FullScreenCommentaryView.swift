//
//  FullScreenCommentaryView.swift
//  Thaqalayn
//
//  Dedicated full-screen reading interface for tafsir commentary
//  Optimized for maximum readability and distraction-free reading
//

import SwiftUI

struct FullScreenCommentaryView: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let initialLayer: TafsirLayer
    @State private var selectedLayer: TafsirLayer
    @State private var showingPaywall = false
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var tafsirReader = TafsirReader.shared
    @StateObject private var voiceManager = TTSVoiceManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @State private var showTextSizePanel = false
    @Environment(\.dismiss) private var dismiss
    
    init(verse: VerseWithTafsir, surah: Surah, initialLayer: TafsirLayer) {
        self.verse = verse
        self.surah = surah
        self.initialLayer = initialLayer
        self._selectedLayer = State(initialValue: initialLayer)
    }
    
    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldContent } else { legacyContent }
        }
        .navigationBarHidden(true)
        .statusBarHidden(true) // Hide status bar for immersive reading
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.36, starCount: 14)
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onDisappear {
            tafsirReader.stop()
        }
        .onChange(of: selectedLayer) { _, _ in
            tafsirReader.stop()
        }
        .onChange(of: languageManager.selectedLanguage) { _, _ in
            tafsirReader.stop()
        }
    }

    private var legacyContent: some View {
        ZStack {
            readingBackground
            VStack(spacing: 0) {
                readingHeader
                compactLayerSelector
                readingContent
            }
        }
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 72, trailingPadding: 24)
    }
    
    // MARK: - Midnight Emerald

    private var emeraldContent: some View {
        ZStack {
            EmeraldBackground()
            VStack(spacing: 0) {
                emeraldHeader
                emeraldLayerSelector
                emeraldReadingContent
            }
        }
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 68, trailingPadding: 20)
    }

    private var emeraldHeader: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark").font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            Spacer()
            HStack(spacing: 10) {
                VerseRecitationButton(surahNumber: surah.number, verseNumber: verse.number, size: 34)
                TextSizeButton(isPanelOpen: $showTextSizePanel)
            }
        }
        .overlay {
            VStack(spacing: 3) {
                Text("Commentary").font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.primaryText)
                Text("\(surah.englishName) · Verse \(verse.number)").font(.system(size: 12, weight: .medium)).foregroundColor(themeManager.tertiaryText)
            }
            .allowsHitTesting(false)
        }
        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 16)
    }

    private var emeraldLayerSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TafsirLayer.allCases, id: \.self) { layer in
                        emeraldLayerButton(for: layer).id(layer)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            .onChange(of: selectedLayer) { _, newLayer in withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(newLayer, anchor: .center) } }
            .onAppear { proxy.scrollTo(selectedLayer, anchor: .center) }
        }
    }

    private func emeraldLayerButton(for layer: TafsirLayer) -> some View {
        let isLocked = !premiumManager.canAccessLayer(layer, surahNumber: surah.number)
        let isActive = selectedLayer == layer && !isLocked
        let chip = layerChipColor(for: layer)
        return Button(action: {
            if isLocked { showingPaywall = true }
            else { withAnimation(.easeInOut(duration: 0.3)) { selectedLayer = layer } }
        }) {
            VStack(spacing: 7) {
                ZStack {
                    Circle().fill(isActive ? AnyShapeStyle(Color.black.opacity(0.20)) : AnyShapeStyle(chip.bg))
                    PhosphorIcon(name: layerIcon(for: layer), size: 17)
                        .foregroundColor(isActive ? Color.white.opacity(0.95) : chip.fg)
                }
                .frame(width: 36, height: 36)
                .opacity(isLocked ? 0.45 : 1)

                Text(layerShortTitle(for: layer))
                    .font(.system(size: 11.5, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isActive ? themeManager.onAccentText : (isLocked ? themeManager.tertiaryText : themeManager.primaryText))
            .frame(width: 84)
            .padding(.vertical, 11)
            .background {
                if isActive {
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(themeManager.accentGradient)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 12)
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(themeManager.glassSurface)
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
                }
            }
            .overlay(alignment: .topTrailing) {
                if isLocked {
                    Image(systemName: "lock.fill").font(.system(size: 9)).foregroundColor(themeManager.tertiaryText).padding(6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Per-layer icon tones (matches the app-wide five-layer chip palette).
    private func layerChipColor(for layer: TafsirLayer) -> ThemeManager.ChipColor {
        switch layer {
        case .foundation: return ThemeManager.chipFoundation
        case .classical: return ThemeManager.chipKnowledge
        case .contemporary: return ThemeManager.chipProgress
        case .ahlulBayt: return ThemeManager.chipBrand
        case .comparative: return ThemeManager.chipComparative
        }
    }

    private var emeraldReadingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let tafsir = verse.tafsir {
                    emeraldReadingLayerHeader
                    emeraldReadingTextContent(tafsir.content(for: selectedLayer, language: languageManager.selectedLanguage))
                } else {
                    noCommentaryView
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 60)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedLayer)
        .animation(.easeInOut(duration: 0.3), value: languageManager.selectedLanguage)
        .animation(.easeInOut(duration: 0.2), value: readingSettings.stepIndex)
    }

    private var emeraldReadingLayerHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(layerChipColor(for: selectedLayer).bg)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
                    PhosphorIcon(name: layerIcon(for: selectedLayer), size: 22).foregroundColor(layerChipColor(for: selectedLayer).fg)
                }
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedLayer.title).font(EmType.serif(24, .semiBold)).foregroundColor(themeManager.primaryText)
                    Text(selectedLayer.description).font(.system(size: 14, weight: .medium)).foregroundColor(themeManager.secondaryText).lineSpacing(2)
                }
                Spacer()
                if voiceManager.hasVoicesAvailable(for: languageManager.selectedLanguage) { ttsButton }
            }
            EmDivider()
        }
        .padding(.bottom, 28)
    }

    private func emeraldReadingTextContent(_ text: String) -> some View {
        let paragraphs = formattedParagraphs(from: text)
        let isRTL = languageManager.selectedLanguage.isRTL
        let scale = readingSettings.scale
        return VStack(alignment: isRTL ? .trailing : .leading, spacing: 16) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                let hlRange = highlightRangeForParagraph(
                    paragraphText: trimmed,
                    paragraphIndex: index,
                    allParagraphs: paragraphs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
                    fullHighlightRange: (tafsirReader.isPlaying || tafsirReader.isPaused) ? tafsirReader.highlightRange : nil
                )
                HighlightedText(
                    text: trimmed,
                    highlightRange: hlRange,
                    font: isRTL ? EmType.arabic(20 * scale) : EmType.serif(19 * scale, .medium),
                    textColor: themeManager.primaryText,
                    highlightColor: themeManager.accentColor.opacity(0.28),
                    lineSpacing: 7 * scale
                )
                .multilineTextAlignment(isRTL ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                .fixedSize(horizontal: false, vertical: true)
                .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                .padding(18)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(themeManager.glassSurface)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
                }
            }
        }
    }

    private var readingBackground: some View {
        ZStack {
            // Base gradient background matching main app
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground,
                    themeManager.tertiaryBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating gradient orbs (with reduced opacity for reading comfort)
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[0].opacity(0.4),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[1].opacity(0.4),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[2].opacity(0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
        }
        .ignoresSafeArea()
    }
    
    private var readingHeader: some View {
        HStack {
            // Close button
            Button(action: { dismiss() }) {
                // Warm theme: × symbol in white circle
                Text("×")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(themeManager.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white.opacity(0.9))
                    )
            }

            Spacer()

            // Context info
            VStack(spacing: 2) {
                Text("Commentary")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text("\(surah.englishName) • Verse \(verse.number)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            // Language toggle button
            HStack(spacing: 10) {
                VerseRecitationButton(surahNumber: surah.number, verseNumber: verse.number, size: 34)
                TextSizeButton(isPanelOpen: $showTextSizePanel)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background {
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.primaryBackground.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // TTS button in layer header
    private var ttsButton: some View {
        Button(action: {
            if tafsirReader.isPlaying || tafsirReader.isPaused {
                tafsirReader.togglePlayPause()
            } else if let tafsir = verse.tafsir {
                let tafsirText = tafsir.content(for: selectedLayer, language: languageManager.selectedLanguage)
                tafsirReader.speak(text: tafsirText, language: languageManager.selectedLanguage)
            }
        }) {
            Text(tafsirReader.isPlaying ? "⏸" : "🔊")
                .font(.system(size: 20))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(themeManager.accentColor.opacity(0.1))
                )
        }
    }

    private var compactLayerSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TafsirLayer.allCases, id: \.self) { layer in
                        layerButton(for: layer)
                            .id(layer)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
            .onChange(of: selectedLayer) { _, newLayer in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newLayer, anchor: .center)
                }
            }
            .onAppear {
                // Ensure initial layer is visible on first appearance
                proxy.scrollTo(selectedLayer, anchor: .center)
            }
        }
    }
    
    private func layerButton(for layer: TafsirLayer) -> some View {
        let isLocked = !premiumManager.canAccessLayer(layer, surahNumber: surah.number)
        let isActive = selectedLayer == layer && !isLocked

        return Button(action: {
            if isLocked {
                // Show paywall for locked layers
                showingPaywall = true
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedLayer = layer
                }
            }
        }) {
            // Warm theme: Larger tabs with specific styling
            VStack(spacing: 6) {
                PhosphorIcon(name: layerIcon(for: layer), size: 28)

                Text(layerShortTitle(for: layer))
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text(layerShortDescription(for: layer))
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .foregroundColor(isActive ? .white : themeManager.primaryText)
            .frame(width: 130, height: 95)
            .padding(12)
            .background {
                if isActive {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.purpleGradient)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 12)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                        .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04), radius: 12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Show language availability in layer selector (all supported languages)
    private func layerAvailabilityIndicator(for layer: TafsirLayer, tafsir: TafsirVerse) -> some View {
        HStack(spacing: 2) {
            ForEach(CommentaryLanguage.supportedTafsirLanguages, id: \.self) { language in
                Circle()
                    .fill(tafsir.hasContent(for: layer, language: language) ? Color.green : Color.gray.opacity(0.4))
                    .frame(width: 4, height: 4)
            }
        }
    }
    
    private var readingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let tafsir = verse.tafsir {
                    let tafsirText = tafsir.content(for: selectedLayer, language: languageManager.selectedLanguage)

                    // Layer header with enhanced typography (always left-aligned)
                    readingLayerHeader

                    // Reading-optimized content with selective RTL
                    readingTextContent(tafsirText)
                } else {
                    noCommentaryView
                }
            }
            .padding(.horizontal, 28) // Generous margins for comfortable reading
            .padding(.bottom, 60) // Extra bottom padding
        }
        .animation(.easeInOut(duration: 0.3), value: selectedLayer)
        .animation(.easeInOut(duration: 0.3), value: languageManager.selectedLanguage)
        .animation(.easeInOut(duration: 0.2), value: readingSettings.stepIndex)
    }

    private var readingLayerHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(layerGradient(for: selectedLayer))
                    .frame(width: 48, height: 48)
                    .overlay(
                        PhosphorIcon(name: layerIcon(for: selectedLayer), size: 24)
                            .foregroundColor(.white)
                    )
                    .shadow(color: layerShadowColor(for: selectedLayer), radius: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedLayer.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text(selectedLayer.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineSpacing(2)
                }

                Spacer()

                // TTS play/pause button (show if voices available for language)
                if voiceManager.hasVoicesAvailable(for: languageManager.selectedLanguage) {
                    ttsButton
                }
            }
            
            // Divider matching mockup
            Rectangle()
                .fill(themeManager.accentColor.opacity(0.2))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 32)
    }

    private func readingTextContent(_ text: String) -> some View {
        let paragraphs = formattedParagraphs(from: text)
        let scale = readingSettings.scale

        return VStack(alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading, spacing: 18) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                let trimmedParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                let paragraphHighlightRange = highlightRangeForParagraph(
                    paragraphText: trimmedParagraph,
                    paragraphIndex: index,
                    allParagraphs: paragraphs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
                    fullHighlightRange: (tafsirReader.isPlaying || tafsirReader.isPaused) ? tafsirReader.highlightRange : nil
                )

                VStack(alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading, spacing: 8) {

                    // Reading-optimized paragraph text with background and selective RTL support
                    HighlightedText(
                        text: trimmedParagraph,
                        highlightRange: paragraphHighlightRange,
                        font: .system(size: 17 * scale, weight: .regular, design: .serif),
                        textColor: themeManager.primaryText,
                        highlightColor: themeManager.semanticYellow.opacity(themeManager.isDarkMode ? 0.30 : 0.50),
                        lineSpacing: 6 * scale
                    )
                        .multilineTextAlignment(languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: languageManager.selectedLanguage.isRTL ? .trailing : .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .environment(\.layoutDirection, languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight) // Apply RTL only to text
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background {
                            // Warm theme: Purple gradient background matching summary view
                            RoundedRectangle(cornerRadius: 24)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                        }
                }
            }
        }
    }
    
    private var noCommentaryView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                Image(systemName: "book.closed")
                    .font(.system(size: 80))
                    .foregroundColor(themeManager.tertiaryText.opacity(0.6))
                
                VStack(spacing: 12) {
                    Text("No commentary available")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)
                    
                    Text("for \(selectedLayer.title)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
            }
            
            Text("Try selecting a different commentary layer above.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(themeManager.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Helper Functions

    /// Calculate the highlight range for a specific paragraph within the full text
    private func highlightRangeForParagraph(
        paragraphText: String,
        paragraphIndex: Int,
        allParagraphs: [String],
        fullHighlightRange: NSRange?
    ) -> NSRange? {
        guard let highlightRange = fullHighlightRange else { return nil }

        // Calculate the starting character position of this paragraph in the full text
        var paragraphStartInFullText = 0
        for i in 0..<paragraphIndex {
            paragraphStartInFullText += allParagraphs[i].count
            // Account for the period and space added between paragraphs
            if i < paragraphIndex {
                paragraphStartInFullText += 2 // ". " separator
            }
        }

        let paragraphEndInFullText = paragraphStartInFullText + paragraphText.count
        let highlightEnd = highlightRange.location + highlightRange.length

        // Check if highlight range overlaps with this paragraph
        if highlightRange.location >= paragraphEndInFullText || highlightEnd <= paragraphStartInFullText {
            return nil // Highlight is not in this paragraph
        }

        // Calculate adjusted range within this paragraph
        let adjustedStart = max(0, highlightRange.location - paragraphStartInFullText)
        let adjustedEnd = min(paragraphText.count, highlightEnd - paragraphStartInFullText)
        let adjustedLength = adjustedEnd - adjustedStart

        if adjustedLength > 0 {
            return NSRange(location: adjustedStart, length: adjustedLength)
        }
        return nil
    }

    private func formattedParagraphs(from text: String) -> [String] {
        let sentences = text.components(separatedBy: ". ")
        var paragraphs: [String] = []
        var currentParagraph = ""
        
        for (index, sentence) in sentences.enumerated() {
            let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !trimmedSentence.isEmpty {
                if currentParagraph.isEmpty {
                    currentParagraph = trimmedSentence
                } else {
                    currentParagraph += ". " + trimmedSentence
                }
                
                // Create paragraph breaks after 2-3 sentences or at natural break points
                let sentenceCount = currentParagraph.components(separatedBy: ". ").count
                let isLastSentence = index == sentences.count - 1
                let hasNaturalBreak = trimmedSentence.contains("However") || 
                                      trimmedSentence.contains("Furthermore") ||
                                      trimmedSentence.contains("Additionally") ||
                                      trimmedSentence.contains("In contrast") ||
                                      trimmedSentence.contains("Therefore") ||
                                      trimmedSentence.contains("Moreover") ||
                                      trimmedSentence.contains("Nevertheless")
                
                if sentenceCount >= 3 || hasNaturalBreak || isLastSentence {
                    if !currentParagraph.isEmpty {
                        paragraphs.append(currentParagraph + (isLastSentence ? "" : "."))
                        currentParagraph = ""
                    }
                }
            }
        }
        
        return paragraphs.isEmpty ? [text] : paragraphs
    }
    
    private func layerIcon(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "ph-bank-fill"
        case .classical: return "ph-books-fill"
        case .contemporary: return "ph-globe-hemisphere-west-fill"
        case .ahlulBayt: return "ph-star-fill"
        case .comparative: return "ph-scales-fill"
        }
    }
    
    private func layerShortTitle(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "Foundation"
        case .classical: return "Classical"
        case .contemporary: return "Modern"
        case .ahlulBayt: return "Ahlul Bayt"
        case .comparative: return "Comparative"
        }
    }

    private func layerShortDescription(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "Simple & Clear"
        case .classical: return "Traditional Scholars"
        case .contemporary: return "Contemporary Insights"
        case .ahlulBayt: return "From the 14 Infallibles"
        case .comparative: return "Balanced Analysis"
        }
    }

    private func layerGradient(for layer: TafsirLayer) -> LinearGradient {
        switch layer {
        case .foundation:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .classical:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .contemporary:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ahlulBayt:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .comparative:
            return LinearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private func layerShadowColor(for layer: TafsirLayer) -> Color {
        switch layer {
        case .foundation: return .blue.opacity(0.3)
        case .classical: return .green.opacity(0.3)
        case .contemporary: return .orange.opacity(0.3)
        case .ahlulBayt: return .purple.opacity(0.3)
        case .comparative: return .indigo.opacity(0.3)
        }
    }
}

#Preview {
    let sampleVerse = Verse(
        arabicText: "وَآتُوا الْيَتَامَىٰ أَمْوَالَهُمْ وَلَا تَتَبَدَّلُوا الْخَبِيثَ بِالطَّيِّبِ",
        translation: "And give to the orphans their properties and do not substitute the defective [of your own] for the good [of theirs]. And do not consume their properties into your own...",
        translationUrdu: nil,
        juz: 1,
        manzil: 1,
        page: 2,
        ruku: 1,
        hizbQuarter: 1,
        sajda: SajdaInfo(hasSajda: false, id: nil, recommended: nil)
    )
    
    let sampleTafsir = TafsirVerse(
        layer1: "In Surah An-Nisaa verse 2, Allah commands believers to act with utmost integrity when entrusted with the property of orphans. The verse begins with \"Wa atu al-yatama amwalahum\" – \"Give the orphans their properties\" – establishing a direct obligation to return wealth to those deprived of parental protection. The term al-yatama (orphans) carries immense weight in Islam, reflecting their vulnerable status and the divine emphasis on their rights. Historically, this verse addressed the pre-Islamic Arabian practice where guardians would exploit orphaned children's inheritance.",
        layer2: "Classical commentary...",
        layer3: "Contemporary commentary...",
        layer4: "Ahlul Bayt commentary...",
        layer5: "**Shia Perspective**: Classical Shia scholars like Al-Tabatabai emphasize the verse's connection to divine justice (adl), viewing orphan protection as a fundamental test of societal righteousness. The Imams stressed that violating orphan rights is among the gravest sins. **Sunni Perspective**: Sunni commentators like Ibn Kathir focus on the legal framework, emphasizing the guardian's fiduciary duty and the severe punishment for those who consume orphan wealth unjustly. Both traditions agree on the verse's core message while differing in jurisprudential applications regarding guardianship laws and inheritance distribution.",
        layer1_urdu: "سورہ النساء آیت 2 میں، اللہ مومنوں کو یتیموں کی املاک کے ساتھ انتہائی دیانتداری سے کام کرنے کا حکم دیتا ہے۔",
        layer2_urdu: "کلاسیکی تفسیر...",
        layer3_urdu: "عصری تفسیر...",
        layer4_urdu: "اہل بیت کی تفسیر...",
        layer5_urdu: "**شیعہ نقطہ نظر**: کلاسیکی شیعہ علماء جیسے الطباطبائی اس آیت کو الہی عدل سے جوڑتے ہیں۔ **سنی نقطہ نظر**: سنی مفسرین جیسے ابن کثیر قانونی فریم ورک پر توجہ دیتے ہیں۔",
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
        layer2short: nil,
        layer2short_urdu: nil,
        layer2short_ar: nil,
        layer2short_fr: nil,
        quickOverview: nil
    )

    let sampleSurah = Surah(
        number: 4,
        name: "سُورَة النِّسَاء",
        englishName: "An-Nisaa",
        englishNameTranslation: "The Women",
        arabicName: "سُورَة النِّسَاء",
        versesCount: 176,
        revelationType: "Medinan"
    )
    
    let sampleVerseWithTafsir = VerseWithTafsir(
        number: 2,
        verse: sampleVerse,
        tafsir: sampleTafsir
    )
    
    FullScreenCommentaryView(
        verse: sampleVerseWithTafsir, 
        surah: sampleSurah, 
        initialLayer: .foundation
    )
}