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
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    init(verse: VerseWithTafsir, surah: Surah, initialLayer: TafsirLayer) {
        self.verse = verse
        self.surah = surah
        self.initialLayer = initialLayer
        self._selectedLayer = State(initialValue: initialLayer)
    }
    
    var body: some View {
        ZStack {
            // Reading-optimized background
            readingBackground
            
            VStack(spacing: 0) {
                // Minimal header
                readingHeader
                
                // Layer selector (compact)
                compactLayerSelector
                
                // Full-screen reading content
                readingContent
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden(true) // Hide status bar for immersive reading
        .preferredColorScheme(themeManager.colorScheme)
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
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(themeManager.secondaryBackground.opacity(0.8))
                            .overlay(
                                Circle()
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            // Context info
            VStack(spacing: 2) {
                Text("Commentary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text("\(surah.englishName) • Verse \(verse.number)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            // Reading mode indicator
            Image(systemName: "book.pages")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.tertiaryText)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
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
        Button(action: { 
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedLayer = layer 
            }
        }) {
            VStack(spacing: 6) {
                Text(layerIcon(for: layer))
                    .font(.system(size: 18))
                
                Text(layerShortTitle(for: layer))
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(selectedLayer == layer ? .white : themeManager.secondaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if selectedLayer == layer {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(layerGradient(for: layer))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.tertiaryBackground.opacity(0.6))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedLayer == layer ? Color.clear : themeManager.strokeColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var readingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let tafsirText = DataManager.shared.getTafsirText(for: verse, layer: selectedLayer) {
                    // Layer header with enhanced typography
                    readingLayerHeader
                    
                    // Reading-optimized content
                    readingTextContent(tafsirText)
                } else {
                    noCommentaryView
                }
            }
            .padding(.horizontal, 28) // Generous margins for comfortable reading
            .padding(.bottom, 60) // Extra bottom padding
        }
        .animation(.easeInOut(duration: 0.3), value: selectedLayer)
    }
    
    private var readingLayerHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(layerGradient(for: selectedLayer))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(layerIcon(for: selectedLayer))
                            .font(.system(size: 24))
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
            }
            
            // Elegant separator
            Rectangle()
                .fill(layerGradient(for: selectedLayer).opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 32)
    }
    
    private func readingTextContent(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(formattedParagraphs(from: text).enumerated()), id: \.offset) { index, paragraph in
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Reading-optimized paragraph text with background
                    Text(paragraph.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(themeManager.primaryText)
                        .lineSpacing(8) // Optimized line spacing for readability
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.secondaryBackground.opacity(0.8))
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(themeManager.glassEffect)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(themeManager.strokeColor.opacity(0.5), lineWidth: 1)
                                )
                                .shadow(
                                    color: themeManager.primaryText.opacity(0.05), 
                                    radius: 8, 
                                    x: 0, 
                                    y: 2
                                )
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
        case .foundation: return "🏛️"
        case .classical: return "📚"
        case .contemporary: return "🌍"
        case .ahlulBayt: return "⭐"
        }
    }
    
    private func layerShortTitle(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "Foundation"
        case .classical: return "Classical"
        case .contemporary: return "Modern"
        case .ahlulBayt: return "Ahlul Bayt"
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
        }
    }
    
    private func layerShadowColor(for layer: TafsirLayer) -> Color {
        switch layer {
        case .foundation: return .blue.opacity(0.3)
        case .classical: return .green.opacity(0.3)
        case .contemporary: return .orange.opacity(0.3)
        case .ahlulBayt: return .purple.opacity(0.3)
        }
    }
}

#Preview {
    let sampleVerse = Verse(
        arabicText: "وَآتُوا الْيَتَامَىٰ أَمْوَالَهُمْ وَلَا تَتَبَدَّلُوا الْخَبِيثَ بِالطَّيِّبِ",
        translation: "And give to the orphans their properties and do not substitute the defective [of your own] for the good [of theirs]. And do not consume their properties into your own...",
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
        layer4: "Ahlul Bayt commentary..."
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