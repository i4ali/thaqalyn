//
//  SurahListView.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct SurahListView: View {
    @State private var searchText = ""
    @State private var surahs = Surah.all
    
    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return surahs
        } else {
            return surahs.filter { surah in
                surah.name.localizedCaseInsensitiveContains(searchText) ||
                surah.transliteration.localizedCaseInsensitiveContains(searchText) ||
                surah.translation.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThaqalynDesignSystem.Colors.backgroundGray
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: ThaqalynDesignSystem.Spacing.md) {
                        ForEach(filteredSurahs) { surah in
                            NavigationLink(destination: VerseListView(surah: surah)) {
                                SurahCard(surah: surah)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
                    .padding(.top, ThaqalynDesignSystem.Spacing.sm)
                }
            }
            .navigationTitle("Thaqalyn")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search surahs...")
        }
    }
}

struct SurahCard: View {
    let surah: Surah
    
    var body: some View {
        ModernCard {
            HStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
                // Surah number in circle
                ZStack {
                    Circle()
                        .fill(ThaqalynDesignSystem.Gradients.primary)
                        .frame(width: 50, height: 50)
                    
                    Text("\(surah.id)")
                        .font(ThaqalynDesignSystem.Typography.calloutFont)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.xs) {
                    HStack {
                        Text(surah.transliteration)
                            .font(ThaqalynDesignSystem.Typography.headlineFont)
                            .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                        
                        Spacer()
                        
                        Text(surah.name)
                            .font(ThaqalynDesignSystem.Typography.arabicBodyFont)
                            .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                    }
                    
                    Text(surah.translation)
                        .font(ThaqalynDesignSystem.Typography.bodyFont)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                    
                    HStack {
                        Label("\(surah.numberOfAyahs) verses", systemImage: "doc.text")
                            .font(ThaqalynDesignSystem.Typography.captionFont)
                            .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                        
                        Spacer()
                        
                        Text(surah.type.rawValue)
                            .font(ThaqalynDesignSystem.Typography.captionFont)
                            .fontWeight(.medium)
                            .foregroundColor(
                                surah.type == .meccan ? 
                                ThaqalynDesignSystem.Colors.islamicGreen : 
                                ThaqalynDesignSystem.Colors.primaryBlue
                            )
                            .padding(.horizontal, ThaqalynDesignSystem.Spacing.sm)
                            .padding(.vertical, ThaqalynDesignSystem.Spacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.sm)
                                    .fill(
                                        surah.type == .meccan ? 
                                        ThaqalynDesignSystem.Colors.islamicGreen.opacity(0.1) : 
                                        ThaqalynDesignSystem.Colors.primaryBlue.opacity(0.1)
                                    )
                            )
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
        }
    }
}

// Placeholder for verse list view
struct VerseListView: View {
    let surah: Surah
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
                ForEach(Verse.samples.filter { $0.surahId == surah.id }, id: \.id) { verse in
                    NavigationLink(destination: VerseDetailView(verse: verse)) {
                        VerseCard(verse: verse)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
            .padding(.top, ThaqalynDesignSystem.Spacing.sm)
        }
        .background(ThaqalynDesignSystem.Colors.backgroundGray)
        .navigationTitle(surah.transliteration)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct VerseCard: View {
    let verse: Verse
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.md) {
                HStack {
                    Text("Verse \(verse.ayahNumber)")
                        .font(ThaqalynDesignSystem.Typography.calloutFont)
                        .fontWeight(.semibold)
                        .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                    
                    Spacer()
                }
                
                VStack(alignment: .trailing, spacing: ThaqalynDesignSystem.Spacing.sm) {
                    Text(verse.arabicText)
                        .font(ThaqalynDesignSystem.Typography.arabicLargeFont)
                        .multilineTextAlignment(.trailing)
                        .environment(\.layoutDirection, .rightToLeft)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                    
                    Text(verse.translation)
                        .font(ThaqalynDesignSystem.Typography.bodyFont)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                }
                
                HStack {
                    Text("Tap for commentary")
                        .font(ThaqalynDesignSystem.Typography.captionFont)
                        .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
        }
    }
}

#Preview {
    SurahListView()
}