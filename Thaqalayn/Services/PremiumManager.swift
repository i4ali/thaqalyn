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
    /// - Surahs 2-114: Requires premium
    func canAccessTafsir(surahNumber: Int) async -> Bool {
        // Surah 1 always free
        if surahNumber == 1 {
            return true
        }

        // Check online status
        if await SupabaseService.shared.isAuthenticated {
            // Online: Use Supabase-verified premium status
            return isPremium
        }

        // Offline: Verify via StoreKit (Apple ID-based verification)
        let hasPurchase = await PurchaseManager.shared.verifyPurchase()
        return hasPurchase
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
