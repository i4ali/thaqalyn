//
//  ContentView.swift
//  Thaqalyn
//
//  Created by Imran Ali on 7/31/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SurahListView()
                .tabItem {
                    Label("Surahs", systemImage: "book.closed")
                }
            
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(ThaqalynDesignSystem.Colors.primaryBlue)
    }
}

// Placeholder views for other tabs
struct BookmarksView: View {
    @State private var bookmarks: [LocalBookmark] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                ThaqalynDesignSystem.Colors.backgroundGray
                    .ignoresSafeArea()
                
                if bookmarks.isEmpty {
                    VStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 48))
                            .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                        
                        VStack(spacing: ThaqalynDesignSystem.Spacing.sm) {
                            Text("No Bookmarks Yet")
                                .font(ThaqalynDesignSystem.Typography.headlineFont)
                                .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                            
                            Text("Bookmark verses while reading to access them quickly here")
                                .font(ThaqalynDesignSystem.Typography.bodyFont)
                                .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(ThaqalynDesignSystem.Spacing.xl)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ThaqalynDesignSystem.Spacing.md) {
                            ForEach(bookmarks, id: \.id) { bookmark in
                                BookmarkCard(bookmark: bookmark)
                            }
                        }
                        .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
                        .padding(.top, ThaqalynDesignSystem.Spacing.sm)
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadBookmarks()
        }
    }
    
    private func loadBookmarks() {
        bookmarks = CacheManager.shared.getBookmarks()
    }
}

struct BookmarkCard: View {
    let bookmark: LocalBookmark
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.md) {
                HStack {
                    Text("Surah \(bookmark.surah), Verse \(bookmark.ayah)")
                        .font(ThaqalynDesignSystem.Typography.calloutFont)
                        .fontWeight(.semibold)
                        .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                    
                    Spacer()
                    
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(ThaqalynDesignSystem.Colors.goldAccent)
                        .font(.system(size: 16))
                }
                
                if let note = bookmark.note, !note.isEmpty {
                    Text(note)
                        .font(ThaqalynDesignSystem.Typography.bodyFont)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                }
                
                Text("Added \(formatDate(bookmark.createdAt ?? Date()))")
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                ThaqalynDesignSystem.Colors.backgroundGray
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
                        // App info
                        ModernCard {
                            VStack(spacing: ThaqalynDesignSystem.Spacing.md) {
                                Text("Thaqalyn")
                                    .font(ThaqalynDesignSystem.Typography.largeTitleFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                                
                                Text("ثقلين - The Two Weighty Things")
                                    .font(ThaqalynDesignSystem.Typography.arabicBodyFont)
                                    .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                                
                                Text("AI-Powered Shia Quranic Commentary")
                                    .font(ThaqalynDesignSystem.Typography.bodyFont)
                                    .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                
                                Text("Version 1.0.0 (MVP)")
                                    .font(ThaqalynDesignSystem.Typography.captionFont)
                                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                            }
                            .padding(ThaqalynDesignSystem.Spacing.xl)
                        }
                        
                        // Cache stats
                        CacheStatsView()
                    }
                    .padding(.horizontal, ThaqalynDesignSystem.Spacing.lg)
                    .padding(.top, ThaqalynDesignSystem.Spacing.sm)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CacheStatsView: View {
    @State private var cacheStats = CacheStats(cachedTafsirCount: 0, bookmarkCount: 0, approximateSizeBytes: 0)
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.md) {
                Text("Storage")
                    .font(ThaqalynDesignSystem.Typography.headlineFont)
                    .fontWeight(.semibold)
                    .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                
                VStack(spacing: ThaqalynDesignSystem.Spacing.sm) {
                    StatRow(label: "Cached Commentary", value: "\(cacheStats.cachedTafsirCount)")
                    StatRow(label: "Bookmarks", value: "\(cacheStats.bookmarkCount)")
                    StatRow(label: "Storage Used", value: cacheStats.formattedSize)
                }
                
                if cacheStats.cachedTafsirCount > 0 {
                    Button("Clear Cache") {
                        CacheManager.shared.clearOldCache(olderThan: 0)
                        loadCacheStats()
                    }
                    .secondaryButtonStyle()
                    .padding(.top, ThaqalynDesignSystem.Spacing.sm)
                }
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
        }
        .onAppear {
            loadCacheStats()
        }
    }
    
    private func loadCacheStats() {
        cacheStats = CacheManager.shared.getCacheStats()
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(ThaqalynDesignSystem.Typography.bodyFont)
                .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(ThaqalynDesignSystem.Typography.calloutFont)
                .fontWeight(.medium)
                .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
        }
    }
}

#Preview {
    ContentView()
}
