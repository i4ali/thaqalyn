//
//  PremiumManager.swift
//  Thaqalayn
//
//  Premium feature state management and persistence
//

import Foundation
import Combine

@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    // MARK: - UserDefaults Keys
    private static let premiumUnlockedKey = "ThaqalaynPremiumUnlocked"
    private static let premiumUnlockDateKey = "ThaqalaynPremiumUnlockDate"
    
    // MARK: - Published Properties
    @Published var isPremiumUnlocked: Bool = false {
        didSet {
            if isPremiumUnlocked != oldValue {
                savePremiumStatus()
                notifyPremiumStatusChanged()
            }
        }
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        loadPremiumStatus()
        setupObservers()
    }
    
    // MARK: - Premium Status Management
    
    private func loadPremiumStatus() {
        isPremiumUnlocked = userDefaults.bool(forKey: Self.premiumUnlockedKey)
        print("📊 PremiumManager: Loaded premium status: \(isPremiumUnlocked)")
    }
    
    private func savePremiumStatus() {
        userDefaults.set(isPremiumUnlocked, forKey: Self.premiumUnlockedKey)
        
        if isPremiumUnlocked {
            userDefaults.set(Date(), forKey: Self.premiumUnlockDateKey)
        }
        
        print("💾 PremiumManager: Saved premium status: \(isPremiumUnlocked)")
    }
    
    func unlockPremiumFeatures() async {
        isPremiumUnlocked = true
        
        // Sync with Supabase if user is authenticated
        await syncPremiumStatusWithSupabase()
        
        print("🔓 PremiumManager: Premium features unlocked!")
    }
    
    func lockPremiumFeatures() async {
        isPremiumUnlocked = false
        
        // Sync with Supabase if user is authenticated
        await syncPremiumStatusWithSupabase()
        
        print("🔒 PremiumManager: Premium features locked")
    }
    
    // MARK: - Feature Access Control
    
    func canAccessPremiumReciter(_ reciter: Reciter) -> Bool {
        return !reciter.isPremium || isPremiumUnlocked
    }
    
    func getPremiumReciters() -> [Reciter] {
        return Reciter.popularReciters.filter { $0.isPremium }
    }
    
    func getFreeReciters() -> [Reciter] {
        return Reciter.popularReciters.filter { !$0.isPremium }
    }
    
    var premiumUnlockDate: Date? {
        return userDefaults.object(forKey: Self.premiumUnlockDateKey) as? Date
    }
    
    // MARK: - Supabase Sync
    
    private func syncPremiumStatusWithSupabase() async {
        // Only sync if user is authenticated and not in guest mode
        guard let currentUser = await getCurrentUser() else {
            print("ℹ️ PremiumManager: No authenticated user, skipping Supabase sync")
            return
        }
        
        do {
            // Update user profile with premium status
            // This would be implemented when we add user profiles to Supabase
            print("🔄 PremiumManager: Would sync premium status with Supabase for user: \(currentUser)")
        } catch {
            print("❌ PremiumManager: Failed to sync premium status with Supabase: \(error)")
        }
    }
    
    private func getCurrentUser() async -> String? {
        // This would integrate with your existing authentication system
        // For now, return nil to skip Supabase sync
        return nil
    }
    
    // MARK: - Observers Setup
    
    private func setupObservers() {
        // Listen for app becoming active to restore purchase status
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.checkPurchaseStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkPurchaseStatus() async {
        // Check with StoreKit to verify current entitlements
        do {
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                
                if transaction.productID == PurchaseManager.premiumUnlockProductID {
                    if !isPremiumUnlocked {
                        await unlockPremiumFeatures()
                    }
                    return
                }
            }
            
            // If no entitlements found and currently premium, lock features
            if isPremiumUnlocked {
                await lockPremiumFeatures()
            }
            
        } catch {
            print("❌ PremiumManager: Failed to check purchase status: \(error)")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PremiumError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Notifications
    
    private func notifyPremiumStatusChanged() {
        NotificationCenter.default.post(
            name: .premiumStatusChanged,
            object: nil,
            userInfo: ["isPremiumUnlocked": isPremiumUnlocked]
        )
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    func resetPremiumStatus() {
        userDefaults.removeObject(forKey: Self.premiumUnlockedKey)
        userDefaults.removeObject(forKey: Self.premiumUnlockDateKey)
        isPremiumUnlocked = false
        print("🔄 PremiumManager: Reset premium status for debugging")
    }
    
    func debugUnlockPremium() {
        Task {
            await unlockPremiumFeatures()
        }
    }
    #endif
}

// MARK: - Premium Errors

enum PremiumError: LocalizedError {
    case failedVerification
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Failed to verify premium status"
        case .syncFailed(let message):
            return "Failed to sync premium status: \(message)"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let premiumStatusChanged = Notification.Name("PremiumStatusChanged")
}

// MARK: - StoreKit Import
import StoreKit