//
//  PremiumManager.swift
//  Thaqalayn
//
//  Manages premium status with freemium model
//  - In-memory only (no persistent cache)
//  - Fetched from Supabase on login
//  - Cleared on logout
//

import Foundation
import Combine

@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()

    // MARK: - Published Properties

    /// Premium status (in-memory only, cleared on logout)
    @Published var isPremium: Bool = false

    // MARK: - Initialization

    init() {
        // Start with free tier by default
        // Premium status will be fetched after login
    }

    // MARK: - Premium Status Management

    /// Fetch premium status from Supabase (called after login)
    func checkPremiumStatus() async {
        do {
            isPremium = try await SupabaseService.shared.getUserPremiumStatus()
            print("✅ Premium status loaded: \(isPremium)")
        } catch {
            print("❌ Failed to fetch premium status: \(error)")
            isPremium = false  // Default to free on error
        }
    }

    /// Clear premium status (called on logout)
    func clearPremiumStatus() {
        isPremium = false
        print("✅ Premium status cleared")
    }

    // MARK: - Access Control

    /// Check if user can access tafsir commentary for a specific surah
    /// - Surah 1 (Al-Fatiha): Always free
    /// - Surahs 2-114: Requires premium (authenticated users only)
    func canAccessTafsir(surahNumber: Int) async -> Bool {
        // Surah 1 always free
        if surahNumber == 1 {
            return true
        }

        // Must be authenticated to access premium content
        guard await SupabaseService.shared.isAuthenticated else {
            return false  // Guest users cannot access premium content
        }

        // Authenticated users: Check premium status from Supabase
        return isPremium
    }

    /// Check if user can access a specific tafsir layer for a given surah
    /// - Surah 1 (Al-Fatiha): Layers 1 & 2 free, Layers 3-5 require premium
    /// - Surahs 2-114: All layers require premium
    func canAccessLayer(_ layer: TafsirLayer, surahNumber: Int) -> Bool {
        // Surah 1: Layers 1 & 2 are free
        if surahNumber == 1 {
            switch layer {
            case .foundation, .classical:
                return true  // Always free for Surah 1
            case .contemporary, .ahlulBayt, .comparative:
                return isPremium  // Require premium for Surah 1
            }
        }

        // Surahs 2-114: All layers require premium
        return isPremium
    }

    // MARK: - Feature Access Control (Legacy - for reciters)

    func canAccessPremiumReciter(_ reciter: Reciter) -> Bool {
        return true // All reciters remain free
    }

    func getPremiumReciters() -> [Reciter] {
        return [] // No premium reciters - all are free
    }

    func getFreeReciters() -> [Reciter] {
        return Reciter.popularReciters // All reciters are free
    }
}
