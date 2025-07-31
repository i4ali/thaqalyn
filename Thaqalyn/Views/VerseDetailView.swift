//
//  VerseDetailView.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct VerseDetailView: View {
    let verse: Verse
    @State private var selectedLayer = 1
    @State private var commentary: [Int: TafsirContent] = [:]
    @State private var isLoading: [Int: Bool] = [:]
    @State private var isBookmarked = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: ThaqalynDesignSystem.Spacing.xl) {
                // Verse display
                verseSection
                
                // Layer selector
                LayerSelector(selectedLayer: $selectedLayer, isCompact: false)
                    .onChange(of: selectedLayer) { _, newLayer in
                        loadCommentaryIfNeeded(for: newLayer)
                    }
                
                // Commentary section
                commentarySection
            }
            .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
            .padding(.top, ThaqalynDesignSystem.Spacing.sm)
        }
        .background(ThaqalynDesignSystem.Colors.backgroundGray)
        .navigationTitle("Verse \(verse.ayahNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? ThaqalynDesignSystem.Colors.goldAccent : ThaqalynDesignSystem.Colors.secondaryGray)
                }
            }
        }
        .onAppear {
            checkBookmarkStatus()
            loadCommentaryIfNeeded(for: selectedLayer)
        }
    }
    
    private var verseSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.lg) {
                HStack {
                    Text("Surah \(verse.surahId), Verse \(verse.ayahNumber)")
                        .font(ThaqalynDesignSystem.Typography.calloutFont)
                        .fontWeight(.semibold)
                        .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                    
                    Spacer()
                    
                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(ThaqalynDesignSystem.Colors.goldAccent)
                            .font(.system(size: 16))
                    }
                }
                
                VStack(alignment: .trailing, spacing: ThaqalynDesignSystem.Spacing.md) {
                    Text(verse.arabicText)
                        .font(ThaqalynDesignSystem.Typography.arabicLargeFont)
                        .multilineTextAlignment(.trailing)
                        .environment(\.layoutDirection, .rightToLeft)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                        .padding(.vertical, ThaqalynDesignSystem.Spacing.sm)
                    
                    Divider()
                    
                    Text(verse.translation)
                        .font(ThaqalynDesignSystem.Typography.bodyFont)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                }
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
        }
    }
    
    private var commentarySection: some View {
        Group {
            if let isLoadingForLayer = isLoading[selectedLayer], isLoadingForLayer {
                ModernCard {
                    CommentarySkeletonView()
                }
            } else if let commentaryContent = commentary[selectedLayer] {
                CommentaryView(content: commentaryContent)
            } else {
                ModernCard {
                    VStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                        
                        VStack(spacing: ThaqalynDesignSystem.Spacing.sm) {
                            Text("Commentary Not Available")
                                .font(ThaqalynDesignSystem.Typography.headlineFont)
                                .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                            
                            Text("Tap to generate \(CommentaryLayerInfo.forLayer(selectedLayer).title) commentary for this verse")
                                .font(ThaqalynDesignSystem.Typography.bodyFont)
                                .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Generate Commentary") {
                            loadCommentary(for: selectedLayer, force: true)
                        }
                        .primaryButtonStyle()
                    }
                    .padding(ThaqalynDesignSystem.Spacing.xl)
                }
            }
        }
    }
    
    private func loadCommentaryIfNeeded(for layer: Int) {
        guard commentary[layer] == nil && isLoading[layer] != true else { return }
        loadCommentary(for: layer)
    }
    
    private func loadCommentary(for layer: Int, force: Bool = false) {
        if !force {
            // First check cache
            if let cachedContent = CacheManager.shared.getCachedTafsir(
                surah: verse.surahId,
                ayah: verse.ayahNumber,
                layer: layer
            ) {
                commentary[layer] = cachedContent
                return
            }
        }
        
        // Set loading state
        isLoading[layer] = true
        
        // Simulate API call for now - will be replaced with actual API integration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let sampleContent = generateSampleCommentary(for: layer)
            commentary[layer] = sampleContent
            isLoading[layer] = false
            
            // Cache the generated content
            CacheManager.shared.cacheTafsir(
                sampleContent,
                arabicText: verse.arabicText,
                translation: verse.translation
            )
        }
    }
    
    private func generateSampleCommentary(for layer: Int) -> TafsirContent {
        let layerInfo = CommentaryLayerInfo.forLayer(layer)
        let sampleCommentaries: [Int: String] = [
            1: "This verse opens with the Basmala, the invocation of Allah's name. In Islamic tradition, beginning any significant action with 'Bismillah' acknowledges Allah as the source of all blessing and success. The words 'Ar-Rahman' and 'Ar-Raheem' both derive from the root r-h-m, related to mercy, but Rahman refers to Allah's universal mercy for all creation, while Raheem indicates His special mercy for believers.",
            2: "According to Allamah Tabatabai in Al-Mizan, the Basmala serves as a spiritual key that opens the heart to divine guidance. Tabrisi in Majma al-Bayan explains that the repetition of mercy attributes emphasizes that Allah's mercy precedes His wrath. Classical Shia scholars note that this verse establishes the principle that all actions should begin with remembrance of Allah.",
            3: "Contemporary Shia scholars like Grand Ayatollah Makarem Shirazi emphasize that the Basmala teaches us to approach all endeavors with humility and divine consciousness. Modern applications include beginning speeches, contracts, and even scientific research with this invocation. The verse promotes interfaith dialogue by highlighting God's universal mercy, which extends to all humanity regardless of faith.",
            4: "According to narrations from Imam Ali (AS), the Basmala contains all the secrets of the Quran. Imam Ja'far as-Sadiq (AS) taught that when one says 'Bismillah' with complete presence of heart, Allah removes their sins. The mystical dimension reveals that Rahman represents the divine mercy inherent in creation itself, while Raheem is the mercy that draws the believer back to Allah. This verse embodies the Wilayah principle - divine guardianship that guides believers to truth."
        ]
        
        return TafsirContent(
            surah: verse.surahId,
            ayah: verse.ayahNumber,
            layer: layer,
            content: sampleCommentaries[layer] ?? "Commentary content for \(layerInfo.title) layer.",
            sources: layer == 2 ? ["tabatabai", "tabrisi"] : ["contemporary"],
            confidenceScore: 0.85
        )
    }
    
    private func toggleBookmark() {
        if isBookmarked {
            CacheManager.shared.removeBookmark(surah: verse.surahId, ayah: verse.ayahNumber)
        } else {
            CacheManager.shared.addBookmark(surah: verse.surahId, ayah: verse.ayahNumber)
        }
        isBookmarked.toggle()
    }
    
    private func checkBookmarkStatus() {
        isBookmarked = CacheManager.shared.isBookmarked(surah: verse.surahId, ayah: verse.ayahNumber)
    }
}

#Preview {
    NavigationView {
        VerseDetailView(verse: Verse.samples[0])
    }
}