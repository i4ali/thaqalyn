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
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
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
}

// MARK: - Database Models

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