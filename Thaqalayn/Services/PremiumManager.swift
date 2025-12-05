//
//  PremiumManager.swift
//  Thaqalayn
//
//  Manages premium status with offline-first architecture
//  - Persisted to UserDefaults for offline access
//  - Fetched from Supabase on login
//  - Cleared on logout
//

import Foundation
import Combine

@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()

    // MARK: - Published Properties

    /// Premium status (persisted to UserDefaults, synced with Supabase)
    @Published var isPremium: Bool = false

    // MARK: - UserDefaults Keys

    private let premiumStatusKey = "com.thaqalayn.premiumStatus"

    // MARK: - Initialization

    init() {
        // Load cached premium status from UserDefaults
        loadCachedPremiumStatus()
    }

    // MARK: - Local Storage

    /// Load premium status from UserDefaults cache
    private func loadCachedPremiumStatus() {
        isPremium = UserDefaults.standard.bool(forKey: premiumStatusKey)
        print("💾 Loaded cached premium status: \(isPremium)")
    }

    /// Save premium status to UserDefaults cache
    private func savePremiumStatus(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: premiumStatusKey)
        print("💾 Saved premium status to cache: \(status)")
    }

    // MARK: - Premium Status Management

    /// Fetch premium status from Supabase (called after login)
    /// Preserves cached status on network errors (offline-first)
    func checkPremiumStatus() async {
        do {
            let fetchedStatus = try await SupabaseService.shared.getUserPremiumStatus()
            isPremium = fetchedStatus
            savePremiumStatus(fetchedStatus)
            print("✅ Premium status fetched and cached: \(fetchedStatus)")
        } catch {
            print("⚠️ Failed to fetch premium status: \(error)")
            print("💾 Preserving cached premium status: \(isPremium)")
            // Don't default to false on error - keep cached value for offline access
        }
    }

    /// Clear premium status (called on logout)
    func clearPremiumStatus() {
        isPremium = false
        UserDefaults.standard.removeObject(forKey: premiumStatusKey)
        print("✅ Premium status cleared from memory and cache")
    }

    // MARK: - Access Control

    /// Check if user can access tafsir commentary for a specific surah
    /// - Surah 1 (Al-Fatiha): Always free
    /// - Surahs 2-114: Requires premium (works offline with cached status)
    func canAccessTafsir(surahNumber: Int) -> Bool {
        // Surah 1 always free
        if surahNumber == 1 {
            return true
        }

        // Check premium status (cached locally, works offline)
        return isPremium
    }

    /// Check if user can access overview/summary for a specific surah
    /// - Surah 1 (Al-Fatiha): Always free
    /// - Surahs 2-114: Requires premium (works offline with cached status)
    func canAccessOverview(surahNumber: Int) -> Bool {
        // Surah 1 always free
        if surahNumber == 1 {
            return true
        }

        // Check premium status (cached locally, works offline)
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
