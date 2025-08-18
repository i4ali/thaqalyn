//
//  BookmarkManager.swift
//  Thaqalayn
//
//  Manages bookmarks with offline-first architecture and Supabase sync
//

import Foundation
import UIKit
import Combine

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
    @Published var isAuthenticated = false
    
    private let localStorageKey = "ThaqalaynBookmarks"
    private let preferencesKey = "ThaqalaynBookmarkPreferences"
    private let collectionsKey = "ThaqalaynBookmarkCollections"
    private let pendingDeletesKey = "ThaqalaynPendingDeletes"
    
    private var supabaseService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    private var pendingDeletes: Set<UUID> = []
    
    private var currentUserId: String {
        // Use authenticated user ID if available, otherwise device ID for guest mode
        if let user = supabaseService.currentUser {
            return user.id.uuidString
        }
        return UIDevice.current.identifierForVendor?.uuidString ?? "guest"
    }
    
    private init() {
        loadLocalBookmarks()
        loadLocalPreferences()
        loadLocalCollections()
        loadPendingDeletes()
        setupSupabaseObservers()
    }
    
    private func setupSupabaseObservers() {
        // Observe authentication state changes
        supabaseService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        supabaseService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    Task {
                        await self?.performInitialSync()
                    }
                }
            }
            .store(in: &cancellables)
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
    
    private func loadPendingDeletes() {
        guard let data = UserDefaults.standard.data(forKey: pendingDeletesKey),
              let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            print("💾 No pending deletes found")
            return
        }
        
        pendingDeletes = decoded
        print("💾 Loaded \(pendingDeletes.count) pending deletes from local storage")
    }
    
    private func savePendingDeletes() {
        guard let encoded = try? JSONEncoder().encode(pendingDeletes) else {
            print("❌ Failed to encode pending deletes")
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: pendingDeletesKey)
        print("💾 Saved \(pendingDeletes.count) pending deletes to local storage")
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
        
        // Check bookmark limit - 10 bookmarks for all users
        let bookmarkLimit = 10
        
        if bookmarks.count >= bookmarkLimit {
            errorMessage = "You've reached your bookmark limit (\(bookmarkLimit) bookmarks)."
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
        
        // Schedule sync if authenticated
        if isAuthenticated {
            scheduleSync()
        }
        
        print("✅ Added bookmark for \(surahName) \(verseNumber)")
        return true
    }
    
    func removeBookmark(id: UUID) {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let bookmark = bookmarks[index]
        
        // Remove immediately from local array for instant UI feedback
        bookmarks.remove(at: index)
        saveLocalBookmarks()
        
        // Add to pending deletes for cloud sync if it was previously synced
        if bookmark.syncStatus == .synced && isAuthenticated {
            pendingDeletes.insert(id)
            savePendingDeletes()
            scheduleSync()
        }
        
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
        
        if isAuthenticated {
            scheduleSync()
        }
        
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
    
    
    // MARK: - Debug & Reset Methods
    
    func clearAllLocalData() {
        // Clear all local bookmarks
        bookmarks.removeAll()
        
        // Clear all local collections
        collections.removeAll()
        
        // Reset preferences
        preferences = UserBookmarkPreferences(userId: currentUserId)
        
        // Clear pending deletes
        pendingDeletes.removeAll()
        
        // Remove from UserDefaults
        UserDefaults.standard.removeObject(forKey: localStorageKey)
        UserDefaults.standard.removeObject(forKey: preferencesKey)
        UserDefaults.standard.removeObject(forKey: collectionsKey)
        UserDefaults.standard.removeObject(forKey: pendingDeletesKey)
        
        // Clear error state
        errorMessage = nil
        syncStatus = nil
        
        print("🧹 BookmarkManager: Cleared all local data")
    }
    
    // MARK: - Sync Management
    
    private func scheduleSync() {
        // Debounce sync requests to avoid excessive API calls
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            await performSync()
        }
    }
    
    private func performSync() async {
        guard isAuthenticated else {
            print("⚠️ Not authenticated, skipping sync")
            return
        }
        
        isSyncing = true
        syncStatus = "Syncing bookmarks..."
        errorMessage = nil
        
        do {
            // Step 1: Process pending deletes
            await processPendingDeletes()
            
            // Step 2: Upload local changes (pending sync)
            try await uploadPendingBookmarks()
            
            // Step 3: Download remote changes
            try await downloadRemoteBookmarks()
            
            syncStatus = "Sync completed"
            print("✅ Sync completed successfully")
        } catch {
            syncStatus = "Sync failed"
            errorMessage = "Sync failed: \(error.localizedDescription)"
            print("❌ Sync failed: \(error)")
        }
        
        isSyncing = false
        
        // Clear sync status after delay
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if syncStatus == "Sync completed" || syncStatus == "Sync failed" {
                syncStatus = nil
            }
        }
    }
    
    private func processPendingDeletes() async {
        for deleteId in pendingDeletes {
            do {
                try await supabaseService.deleteBookmark(id: deleteId)
                pendingDeletes.remove(deleteId)
            } catch {
                print("❌ Failed to delete bookmark \(deleteId): \(error)")
                // Keep in pending deletes for retry
            }
        }
        savePendingDeletes()
    }
    
    private func uploadPendingBookmarks() async throws {
        let pendingBookmarks = bookmarks.filter { $0.syncStatus == .pendingSync }
        
        if !pendingBookmarks.isEmpty {
            do {
                try await supabaseService.syncBookmarks(pendingBookmarks)
                
                // Mark as synced
                for i in 0..<bookmarks.count {
                    if bookmarks[i].syncStatus == .pendingSync {
                        bookmarks[i] = Bookmark(
                            id: bookmarks[i].id,
                            userId: bookmarks[i].userId,
                            surahNumber: bookmarks[i].surahNumber,
                            verseNumber: bookmarks[i].verseNumber,
                            surahName: bookmarks[i].surahName,
                            verseText: bookmarks[i].verseText,
                            verseTranslation: bookmarks[i].verseTranslation,
                            notes: bookmarks[i].notes,
                            tags: bookmarks[i].tags,
                            createdAt: bookmarks[i].createdAt,
                            updatedAt: bookmarks[i].updatedAt,
                            syncStatus: .synced
                        )
                    }
                }
                saveLocalBookmarks()
            } catch {
                print("❌ Failed to upload bookmarks: \(error)")
                throw error
            }
        }
    }
    
    private func downloadRemoteBookmarks() async throws {
        do {
            let remoteBookmarks = try await supabaseService.fetchBookmarks()
            await mergeRemoteBookmarks(remoteBookmarks)
        } catch {
            print("❌ Failed to download bookmarks: \(error)")
            throw error
        }
    }
    
    private func mergeRemoteBookmarks(_ remoteBookmarks: [Bookmark]) async {
        let localBookmarkIds = Set(bookmarks.map { $0.id })
        
        // Add new remote bookmarks
        let newRemoteBookmarks = remoteBookmarks.filter { !localBookmarkIds.contains($0.id) }
        bookmarks.append(contentsOf: newRemoteBookmarks)
        
        // Handle conflicts (remote updates vs local updates)
        for remoteBookmark in remoteBookmarks {
            if let localIndex = bookmarks.firstIndex(where: { $0.id == remoteBookmark.id }) {
                let localBookmark = bookmarks[localIndex]
                
                // If local is pending sync and remote is newer, create conflict
                if localBookmark.syncStatus == .pendingSync && 
                   remoteBookmark.updatedAt > localBookmark.updatedAt {
                    // For now, keep local changes (user preference)
                    // TODO: Implement proper conflict resolution UI
                    print("⚠️ Sync conflict detected for bookmark \(remoteBookmark.id)")
                    bookmarks[localIndex] = Bookmark(
                        id: localBookmark.id,
                        userId: localBookmark.userId,
                        surahNumber: localBookmark.surahNumber,
                        verseNumber: localBookmark.verseNumber,
                        surahName: localBookmark.surahName,
                        verseText: localBookmark.verseText,
                        verseTranslation: localBookmark.verseTranslation,
                        notes: localBookmark.notes,
                        tags: localBookmark.tags,
                        createdAt: localBookmark.createdAt,
                        updatedAt: localBookmark.updatedAt,
                        syncStatus: .conflict
                    )
                } else if localBookmark.syncStatus == .synced && 
                         remoteBookmark.updatedAt > localBookmark.updatedAt {
                    // Remote is newer and local is synced, update local
                    bookmarks[localIndex] = remoteBookmark
                }
            }
        }
        
        saveLocalBookmarks()
    }
    
    private func performInitialSync() async {
        // Only perform initial sync once after authentication
        guard isAuthenticated && !bookmarks.contains(where: { $0.syncStatus == .synced }) else {
            return
        }
        
        syncStatus = "Initial sync..."
        await performSync()
    }
    
    func forceSyncWithSupabase() async {
        await performSync()
    }
    
    // MARK: - Authentication Integration
    
    func signInAndSync() async {
        do {
            try await supabaseService.signInAnonymously()
            // Sync will be triggered automatically via observer
        } catch {
            errorMessage = "Authentication failed: \(error.localizedDescription)"
        }
    }
    
    func signOutAndClearRemoteData() async {
        do {
            try await supabaseService.signOut()
            
            // Keep local bookmarks but mark them as pending sync
            for i in 0..<bookmarks.count {
                if bookmarks[i].syncStatus == .synced {
                    bookmarks[i] = Bookmark(
                        id: bookmarks[i].id,
                        userId: currentUserId, // Reset to device ID
                        surahNumber: bookmarks[i].surahNumber,
                        verseNumber: bookmarks[i].verseNumber,
                        surahName: bookmarks[i].surahName,
                        verseText: bookmarks[i].verseText,
                        verseTranslation: bookmarks[i].verseTranslation,
                        notes: bookmarks[i].notes,
                        tags: bookmarks[i].tags,
                        createdAt: bookmarks[i].createdAt,
                        updatedAt: bookmarks[i].updatedAt,
                        syncStatus: .pendingSync
                    )
                }
            }
            saveLocalBookmarks()
            
            // Clear pending deletes
            pendingDeletes.removeAll()
            savePendingDeletes()
            
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
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