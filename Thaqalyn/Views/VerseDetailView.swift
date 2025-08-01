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
        
        // Make real API call
        Task {
            do {
                let generatedContent = try await APIService.shared.generateTafsir(
                    surah: verse.surahId,
                    ayah: verse.ayahNumber,
                    layer: layer
                )
                
                await MainActor.run {
                    commentary[layer] = generatedContent
                    isLoading[layer] = false
                    
                    // Cache the generated content
                    CacheManager.shared.cacheTafsir(
                        generatedContent,
                        arabicText: verse.arabicText,
                        translation: verse.translation
                    )
                }
            } catch {
                await MainActor.run {
                    isLoading[layer] = false
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
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