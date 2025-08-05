//
//  BookmarkManager.swift
//  Thaqalayn
//
//  Manages bookmarks with offline-first architecture and Supabase sync
//

import Foundation
import UIKit

@MainActor
class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published var bookmarks: [Bookmark] = []
    @Published var preferences: UserBookmarkPreferences?
    @Published var collections: [BookmarkCollection] = []
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var errorMessage: String?
    @Published var syncStatus: String?
    
    private let localStorageKey = "ThaqalaynBookmarks"
    private let preferencesKey = "ThaqalaynBookmarkPreferences"
    private let collectionsKey = "ThaqalaynBookmarkCollections"
    
    private var currentUserId: String {
        // For now, use device ID as user ID for guest mode
        // TODO: Replace with actual user ID from authentication
        return UIDevice.current.identifierForVendor?.uuidString ?? "guest"
    }
    
    private init() {
        loadLocalBookmarks()
        loadLocalPreferences()
        loadLocalCollections()
    }
    
    // MARK: - Local Storage
    
    private func loadLocalBookmarks() {
        guard let data = UserDefaults.standard.data(forKey: localStorageKey),
              let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) else {
            print("💾 No local bookmarks found")
            return
        }
        
        bookmarks = decoded
        print("💾 Loaded \(bookmarks.count) bookmarks from local storage")
    }
    
    private func saveLocalBookmarks() {
        guard let encoded = try? JSONEncoder().encode(bookmarks) else {
            print("❌ Failed to encode bookmarks")
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: localStorageKey)
        print("💾 Saved \(bookmarks.count) bookmarks to local storage")
    }
    
    private func loadLocalPreferences() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let decoded = try? JSONDecoder().decode(UserBookmarkPreferences.self, from: data) else {
            // Create default preferences
            preferences = UserBookmarkPreferences(userId: currentUserId)
            saveLocalPreferences()
            return
        }
        
        preferences = decoded
        print("💾 Loaded bookmark preferences from local storage")
    }
    
    private func saveLocalPreferences() {
        guard let prefs = preferences,
              let encoded = try? JSONEncoder().encode(prefs) else {
            print("❌ Failed to encode preferences")
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: preferencesKey)
        print("💾 Saved bookmark preferences to local storage")
    }
    
    private func loadLocalCollections() {
        guard let data = UserDefaults.standard.data(forKey: collectionsKey),
              let decoded = try? JSONDecoder().decode([BookmarkCollection].self, from: data) else {
            print("💾 No local bookmark collections found")
            return
        }
        
        collections = decoded
        print("💾 Loaded \(collections.count) bookmark collections from local storage")
    }
    
    private func saveLocalCollections() {
        guard let encoded = try? JSONEncoder().encode(collections) else {
            print("❌ Failed to encode collections")
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: collectionsKey)
        print("💾 Saved \(collections.count) bookmark collections to local storage")
    }
    
    // MARK: - Bookmark Management
    
    func addBookmark(
        surahNumber: Int,
        verseNumber: Int,
        surahName: String,
        verseText: String,
        verseTranslation: String,
        notes: String? = nil,
        tags: [String] = []
    ) -> Bool {
        // Check if bookmark already exists
        if bookmarks.contains(where: { $0.surahNumber == surahNumber && $0.verseNumber == verseNumber }) {
            errorMessage = "This verse is already bookmarked"
            return false
        }
        
        // Check bookmark limit for non-premium users
        if let prefs = preferences, !prefs.isPremium && bookmarks.count >= prefs.bookmarkLimit {
            errorMessage = "You've reached your bookmark limit (\(prefs.bookmarkLimit)). Upgrade to premium for unlimited bookmarks."
            return false
        }
        
        let bookmark = Bookmark(
            userId: currentUserId,
            surahNumber: surahNumber,
            verseNumber: verseNumber,
            surahName: surahName,
            verseText: verseText,
            verseTranslation: verseTranslation,
            notes: notes,
            tags: tags,
            syncStatus: .pendingSync
        )
        
        bookmarks.append(bookmark)
        saveLocalBookmarks()
        
        // TODO: Sync with Supabase
        scheduleSync()
        
        print("✅ Added bookmark for \(surahName) \(verseNumber)")
        return true
    }
    
    func removeBookmark(id: UUID) {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        // For offline-first: remove immediately from local array
        // Later, we can add this to a separate "pending delete" queue for sync
        bookmarks.remove(at: index)
        
        saveLocalBookmarks()
        
        // TODO: Add to sync queue for Supabase deletion
        scheduleSync()
        
        print("🗑️ Removed bookmark from local storage")
    }
    
    func updateBookmark(
        id: UUID,
        notes: String? = nil,
        tags: [String]? = nil
    ) {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let existingBookmark = bookmarks[index]
        bookmarks[index] = Bookmark(
            id: existingBookmark.id,
            userId: existingBookmark.userId,
            surahNumber: existingBookmark.surahNumber,
            verseNumber: existingBookmark.verseNumber,
            surahName: existingBookmark.surahName,
            verseText: existingBookmark.verseText,
            verseTranslation: existingBookmark.verseTranslation,
            notes: notes ?? existingBookmark.notes,
            tags: tags ?? existingBookmark.tags,
            createdAt: existingBookmark.createdAt,
            updatedAt: Date(),
            syncStatus: .pendingSync
        )
        
        saveLocalBookmarks()
        scheduleSync()
        
        print("✏️ Updated bookmark")
    }
    
    func isBookmarked(surahNumber: Int, verseNumber: Int) -> Bool {
        return bookmarks.contains { bookmark in
            bookmark.surahNumber == surahNumber && 
            bookmark.verseNumber == verseNumber
        }
    }
    
    func getBookmark(surahNumber: Int, verseNumber: Int) -> Bookmark? {
        return bookmarks.first { bookmark in
            bookmark.surahNumber == surahNumber && 
            bookmark.verseNumber == verseNumber
        }
    }
    
    // MARK: - Sorting and Filtering
    
    func getSortedBookmarks() -> [Bookmark] {
        guard let prefs = preferences else {
            return bookmarks.sorted { $0.createdAt > $1.createdAt }
        }
        
        switch prefs.sortOrder {
        case .dateAscending:
            return bookmarks.sorted { $0.createdAt < $1.createdAt }
        case .dateDescending:
            return bookmarks.sorted { $0.createdAt > $1.createdAt }
        case .surahOrder:
            return bookmarks.sorted { 
                if $0.surahNumber == $1.surahNumber {
                    return $0.verseNumber < $1.verseNumber
                }
                return $0.surahNumber < $1.surahNumber
            }
        case .alphabetical:
            return bookmarks.sorted { $0.surahName < $1.surahName }
        }
    }
    
    func getBookmarksByTag(_ tag: String) -> [Bookmark] {
        return getSortedBookmarks().filter { $0.tags.contains(tag) }
    }
    
    func getAllTags() -> [String] {
        let allTags = Set(bookmarks.flatMap { $0.tags })
        return Array(allTags).sorted()
    }
    
    // MARK: - Premium Features
    
    func upgradeToPremium() {
        guard let currentPrefs = preferences else { return }
        
        preferences = UserBookmarkPreferences(
            userId: currentPrefs.userId,
            isPremium: true,
            bookmarkLimit: 1000,
            defaultTags: currentPrefs.defaultTags,
            sortOrder: currentPrefs.sortOrder,
            groupBy: currentPrefs.groupBy
        )
        
        saveLocalPreferences()
        print("🌟 Upgraded to premium")
    }
    
    // MARK: - Sync Management
    
    private func scheduleSync() {
        // TODO: Implement actual Supabase sync
        Task {
            await performSync()
        }
    }
    
    private func performSync() async {
        // TODO: Implement Supabase sync logic
        isSyncing = true
        syncStatus = "Syncing bookmarks..."
        
        // Simulate sync delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        syncStatus = "Sync completed"
        isSyncing = false
        
        // Clear sync status after delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        syncStatus = nil
    }
    
    func forceSyncWithSupabase() async {
        await performSync()
    }
}

// MARK: - Errors

enum BookmarkError: LocalizedError {
    case limitReached
    case alreadyBookmarked
    case notFound
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .limitReached:
            return "Bookmark limit reached"
        case .alreadyBookmarked:
            return "Verse already bookmarked"
        case .notFound:
            return "Bookmark not found"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        }
    }
}