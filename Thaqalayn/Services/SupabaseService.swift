//
//  SupabaseService.swift
//  Thaqalayn
//
//  Supabase service wrapper for database operations
//

import Foundation
import Supabase
import AuthenticationServices

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    private let client: SupabaseClient

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - User Cache (for offline access)
    private let cachedEmailKey = "com.thaqalayn.cachedUserEmail"

    /// Cached user email for offline display (persisted to UserDefaults)
    var cachedUserEmail: String? {
        UserDefaults.standard.string(forKey: cachedEmailKey)
    }

    private func cacheUserEmail(_ email: String?) {
        if let email = email {
            UserDefaults.standard.set(email, forKey: cachedEmailKey)
            print("💾 Cached user email: \(email)")
        }
    }

    private func clearCachedUserEmail() {
        UserDefaults.standard.removeObject(forKey: cachedEmailKey)
        print("💾 Cleared cached user email")
    }

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )

        // Check initial auth state
        Task {
            await checkAuthState()
        }
    }
    
    // MARK: - Authentication
    
    func checkAuthState() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true

            // Cache user email for offline access
            cacheUserEmail(session.user.email)

            // ✅ Fetch premium status when restoring existing session
            await PremiumManager.shared.checkPremiumStatus()
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
            // Note: Don't clear cached email on auth check failure - user may just be offline
        }
    }
    
    func signInAnonymously() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await client.auth.signInAnonymously()
            self.currentUser = response.user
            self.isAuthenticated = true
            print("✅ Signed in anonymously: \(response.user.id)")
        } catch {
            self.errorMessage = "Failed to sign in: \(error.localizedDescription)"
            print("❌ Auth error: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Configure redirect URL for email confirmation
            let response = try await client.auth.signUp(
                email: email, 
                password: password,
                redirectTo: URL(string: "thaqalayn://auth/callback")
            )
            
            // Note: User might not be confirmed yet if email confirmation is enabled
            self.currentUser = response.user
            self.isAuthenticated = response.user.emailConfirmedAt != nil
            
            if response.user.emailConfirmedAt != nil {
                print("✅ Signed up and confirmed: \(response.user.id.uuidString)")

                // Cache user email for offline access
                cacheUserEmail(response.user.email)

                // ✅ Fetch premium status after successful signup
                await PremiumManager.shared.checkPremiumStatus()
            } else {
                print("📧 Signed up, waiting for email confirmation: \(response.user.id.uuidString)")
            }
        } catch {
            self.errorMessage = "Failed to sign up: \(error.localizedDescription)"
            print("❌ Sign up error: \(error)")
            throw error
        }

        isLoading = false
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await client.auth.signIn(email: email, password: password)
            self.currentUser = response.user
            self.isAuthenticated = true
            print("✅ Signed in successfully: \(response.user.id.uuidString)")

            // Cache user email for offline access
            cacheUserEmail(response.user.email)

            // ✅ Fetch premium status after successful login
            await PremiumManager.shared.checkPremiumStatus()
        } catch {
            self.errorMessage = "Failed to sign in: \(error.localizedDescription)"
            print("❌ Sign in error: \(error)")
            throw error
        }

        isLoading = false
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        errorMessage = nil

        do {
            guard let identityToken = credential.identityToken,
                  let identityTokenString = String(data: identityToken, encoding: .utf8) else {
                throw SupabaseError.appleSignInFailed("Invalid identity token")
            }

            let response = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: identityTokenString
                )
            )

            self.currentUser = response.user
            self.isAuthenticated = true
            print("✅ Signed in with Apple: \(response.user.id.uuidString)")

            // Cache user email for offline access
            cacheUserEmail(response.user.email)

            // ✅ Fetch premium status after successful Apple sign-in
            await PremiumManager.shared.checkPremiumStatus()
        } catch {
            self.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            print("❌ Apple Sign In error: \(error)")
            throw error
        }

        isLoading = false
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await client.auth.resetPasswordForEmail(email)
            print("✅ Password reset email sent to \(email)")
        } catch {
            self.errorMessage = "Failed to send reset email: \(error.localizedDescription)"
            print("❌ Password reset error: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async throws {
        // ✅ Clear premium status and cached email BEFORE signing out
        PremiumManager.shared.clearPremiumStatus()
        clearCachedUserEmail()

        isLoading = true
        errorMessage = nil

        do {
            try await client.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            print("✅ Signed out successfully")
        } catch {
            self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print("❌ Sign out error: \(error)")
            throw error
        }

        isLoading = false
    }
    
    func deleteAccount() async throws {
        guard isAuthenticated, let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        isLoading = true
        errorMessage = nil

        do {
            // Call the complete deletion function - no fallbacks
            let result: String = try await client.rpc("delete_user_account_complete", params: ["user_id_param": userId.uuidString]).execute().value

            print("✅ Complete account deletion result: \(result)")

            // Clear premium status and cached email
            PremiumManager.shared.clearPremiumStatus()
            clearCachedUserEmail()

            // Sign out to clear persisted session
            try await client.auth.signOut()

            // Clear local state
            self.currentUser = nil
            self.isAuthenticated = false

            print("✅ Account deleted and session cleared successfully")
        } catch {
            self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
            print("❌ Account deletion error: \(error)")
            throw error
        }

        isLoading = false
    }
    
    // MARK: - Database Operations
    
    func getClient() -> SupabaseClient {
        return client
    }
    
    // MARK: - Bookmark Operations
    
    func syncBookmarks(_ bookmarks: [Bookmark]) async throws {
        guard isAuthenticated, let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Convert bookmarks to database format
            let dbBookmarks = bookmarks.map { bookmark in
                DatabaseBookmark(
                    id: bookmark.id,
                    userId: userId,
                    surahNumber: bookmark.surahNumber,
                    verseNumber: bookmark.verseNumber,
                    surahName: bookmark.surahName,
                    verseText: bookmark.verseText,
                    verseTranslation: bookmark.verseTranslation,
                    notes: bookmark.notes,
                    tags: bookmark.tags,
                    createdAt: bookmark.createdAt,
                    updatedAt: bookmark.updatedAt
                )
            }
            
            // Upsert bookmarks to database
            try await client
                .from("bookmarks")
                .upsert(dbBookmarks)
                .execute()
            
            print("✅ Synced \(bookmarks.count) bookmarks to Supabase")
        } catch {
            self.errorMessage = "Failed to sync bookmarks: \(error.localizedDescription)"
            print("❌ Bookmark sync error: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    func fetchBookmarks() async throws -> [Bookmark] {
        guard isAuthenticated, let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [DatabaseBookmark] = try await client
                .from("bookmarks")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            // Convert database bookmarks to app format
            let bookmarks = response.map { dbBookmark in
                Bookmark(
                    id: dbBookmark.id,
                    userId: dbBookmark.userId.uuidString,
                    surahNumber: dbBookmark.surahNumber,
                    verseNumber: dbBookmark.verseNumber,
                    surahName: dbBookmark.surahName,
                    verseText: dbBookmark.verseText,
                    verseTranslation: dbBookmark.verseTranslation,
                    notes: dbBookmark.notes,
                    tags: dbBookmark.tags,
                    createdAt: dbBookmark.createdAt,
                    updatedAt: dbBookmark.updatedAt,
                    syncStatus: .synced
                )
            }
            
            print("✅ Fetched \(bookmarks.count) bookmarks from Supabase")
            return bookmarks
        } catch {
            self.errorMessage = "Failed to fetch bookmarks: \(error.localizedDescription)"
            print("❌ Bookmark fetch error: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    func deleteBookmark(id: UUID) async throws {
        guard isAuthenticated else {
            throw SupabaseError.notAuthenticated
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await client
                .from("bookmarks")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            print("✅ Deleted bookmark \(id) from Supabase")
        } catch {
            self.errorMessage = "Failed to delete bookmark: \(error.localizedDescription)"
            print("❌ Bookmark delete error: \(error)")
            throw error
        }
        
        isLoading = false
    }

    // MARK: - Reading Progress Sync

    func syncReadingProgress(_ progressData: ReadingProgressData, userId: String) async throws {
        guard isAuthenticated else {
            throw SupabaseError.notAuthenticated
        }

        isLoading = true
        errorMessage = nil

        do {
            // Convert to database format
            let dbProgress = DatabaseReadingProgress(
                userId: userId,
                verseProgress: progressData.verseProgress,
                readingStreak: progressData.readingStreak,
                badges: progressData.badges,
                stats: progressData.stats,
                preferences: progressData.preferences,
                updatedAt: progressData.updatedAt,
                createdAt: Date()
            )

            // Upsert reading progress to database (single row per user)
            try await client
                .from("reading_progress")
                .upsert(dbProgress)
                .execute()

            print("✅ Synced reading progress to Supabase")
        } catch {
            self.errorMessage = "Failed to sync reading progress: \(error.localizedDescription)"
            print("❌ Reading progress sync error: \(error)")
            throw error
        }

        isLoading = false
    }

    func fetchReadingProgress(userId: String) async throws -> ReadingProgressData? {
        guard isAuthenticated else {
            throw SupabaseError.notAuthenticated
        }

        isLoading = true
        errorMessage = nil

        do {
            let response: [DatabaseReadingProgress] = try await client
                .from("reading_progress")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value

            // Return nil if no progress found (user hasn't synced yet)
            guard let dbProgress = response.first else {
                print("ℹ️ No reading progress found for user in Supabase")
                isLoading = false
                return nil
            }

            // Convert database format to app format
            let progressData = ReadingProgressData(
                verseProgress: dbProgress.verseProgress,
                readingStreak: dbProgress.readingStreak,
                badges: dbProgress.badges,
                stats: dbProgress.stats,
                preferences: dbProgress.preferences,
                updatedAt: dbProgress.updatedAt,
                syncStatus: .synced
            )

            print("✅ Fetched reading progress from Supabase")
            return progressData
        } catch {
            self.errorMessage = "Failed to fetch reading progress: \(error.localizedDescription)"
            print("❌ Reading progress fetch error: \(error)")
            throw error
        }

        isLoading = false
    }

    func deleteReadingProgress(userId: String) async throws {
        guard isAuthenticated else {
            throw SupabaseError.notAuthenticated
        }

        isLoading = true
        errorMessage = nil

        do {
            try await client
                .from("reading_progress")
                .delete()
                .eq("user_id", value: userId)
                .execute()

            print("✅ Deleted reading progress from Supabase")
        } catch {
            self.errorMessage = "Failed to delete reading progress: \(error.localizedDescription)"
            print("❌ Reading progress delete error: \(error)")
            throw error
        }

        isLoading = false
    }

    // MARK: - User Preferences & Premium Status
    
    func getUserPremiumStatus() async throws -> Bool {
        print("🔍 SupabaseService: Getting premium status")
        
        guard let currentUser = currentUser else {
            print("❌ SupabaseService: No current user for premium status check")
            throw SupabaseError.notAuthenticated
        }
        
        print("🔍 SupabaseService: Checking premium status for user: \(currentUser.id)")
        
        do {
            let response: [DatabaseUserPreferences] = try await client
                .from("user_preferences")
                .select()
                .eq("user_id", value: currentUser.id.uuidString)
                .execute()
                .value

            print("🔍 SupabaseService: Premium status response: \(response)")
            let isPremium = response.first?.isPremium ?? false
            print("🔍 SupabaseService: Returning premium status: \(isPremium)")

            return isPremium
        } catch {
            print("❌ SupabaseService: Error fetching premium status: \(error)")
            print("❌ SupabaseService: Error details: \(error)")
            throw SupabaseError.fetchFailed("Failed to fetch premium status: \(error.localizedDescription)")
        }
    }
    
    func updateUserPremiumStatus(isPremium: Bool) async throws {
        guard let currentUser = currentUser else {
            throw SupabaseError.notAuthenticated
        }

        print("🔄 SupabaseService: Starting premium status update for user \(currentUser.id.uuidString)")

        let updateData = DatabaseUserPreferencesUpdate(
            userId: currentUser.id.uuidString,
            isPremium: isPremium,
            bookmarkLimit: isPremium ? 999 : 2
        )

        print("🔄 SupabaseService: Update data prepared: \(updateData)")

        do {
            let response = try await client
                .from("user_preferences")
                .upsert(updateData, onConflict: "user_id")
                .execute()

            print("✅ SupabaseService: Updated premium status to \(isPremium) for user \(currentUser.id.uuidString)")
            print("✅ SupabaseService: Response: \(response)")
        } catch {
            print("❌ SupabaseService: Failed to update premium status: \(error)")
            print("❌ SupabaseService: Error type: \(type(of: error))")
            print("❌ SupabaseService: Full error: \(String(describing: error))")
            throw SupabaseError.syncFailed("Failed to update premium status: \(error.localizedDescription)")
        }
    }
}

// MARK: - Database Models

struct DatabaseUserPreferences: Codable {
    let userId: UUID
    let isPremium: Bool
    let bookmarkLimit: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isPremium = "is_premium"
        case bookmarkLimit = "bookmark_limit"
    }
}

struct DatabaseUserPreferencesUpdate: Codable {
    let userId: String
    let isPremium: Bool
    let bookmarkLimit: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isPremium = "is_premium"
        case bookmarkLimit = "bookmark_limit"
    }
}

struct DatabaseBookmark: Codable {
    let id: UUID
    let userId: UUID
    let surahNumber: Int
    let verseNumber: Int
    let surahName: String
    let verseText: String
    let verseTranslation: String
    let notes: String?
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case surahNumber = "surah_number"
        case verseNumber = "verse_number"
        case surahName = "surah_name"
        case verseText = "verse_text"
        case verseTranslation = "verse_translation"
        case notes
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case notAuthenticated
    case syncFailed(String)
    case fetchFailed(String)
    case appleSignInFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .fetchFailed(let message):
            return "Fetch failed: \(message)"
        case .appleSignInFailed(let message):
            return "Apple Sign In failed: \(message)"
        }
    }
}