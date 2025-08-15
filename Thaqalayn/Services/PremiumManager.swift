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
        
        // Load premium status from Supabase on initialization
        Task {
            await loadPremiumStatusFromSupabase()
        }
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
            // Update user_preferences table with premium status
            let supabaseService = SupabaseService.shared
            try await supabaseService.updateUserPremiumStatus(isPremium: isPremiumUnlocked)
            print("🔄 PremiumManager: Synced premium status (\(isPremiumUnlocked)) with Supabase for user: \(currentUser)")
        } catch {
            print("❌ PremiumManager: Failed to sync premium status with Supabase: \(error)")
        }
    }
    
    private func getCurrentUser() async -> String? {
        // Get current user from SupabaseService
        return SupabaseService.shared.currentUser?.id.uuidString
    }
    
    // MARK: - Load Premium Status from Supabase
    
    func loadPremiumStatusFromSupabase() async {
        print("🔍 PremiumManager: Starting loadPremiumStatusFromSupabase")
        
        guard let currentUser = await getCurrentUser() else {
            print("ℹ️ PremiumManager: No authenticated user, using local premium status: \(isPremiumUnlocked)")
            return
        }
        
        print("🔍 PremiumManager: Current user found: \(currentUser)")
        print("🔍 PremiumManager: Current local premium status: \(isPremiumUnlocked)")
        
        do {
            let supabaseService = SupabaseService.shared
            let isPremiumFromSupabase = try await supabaseService.getUserPremiumStatus()
            
            print("🔍 PremiumManager: Premium status from Supabase: \(isPremiumFromSupabase)")
            
            // Update local status if different from Supabase
            if isPremiumFromSupabase != isPremiumUnlocked {
                isPremiumUnlocked = isPremiumFromSupabase
                print("🔄 PremiumManager: Updated local premium status from Supabase: \(isPremiumUnlocked)")
            } else {
                print("ℹ️ PremiumManager: Local and Supabase premium status already match: \(isPremiumUnlocked)")
            }
            
        } catch {
            print("❌ PremiumManager: Failed to load premium status from Supabase: \(error)")
        }
    }
    
    // MARK: - Observers Setup
    
    private func setupObservers() {
        // Listen for app becoming active to restore purchase status
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.checkPurchaseStatus()
                    await self?.loadPremiumStatusFromSupabase()
                }
            }
            .store(in: &cancellables)
        
        // Listen for authentication state changes
        SupabaseService.shared.$isAuthenticated
            .dropFirst() // Skip the initial value
            .sink { [weak self] isAuthenticated in
                Task { @MainActor in
                    if isAuthenticated {
                        await self?.loadPremiumStatusFromSupabase()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Also listen for user changes specifically
        SupabaseService.shared.$currentUser
            .dropFirst()
            .sink { [weak self] user in
                Task { @MainActor in
                    if user != nil {
                        await self?.loadPremiumStatusFromSupabase()
                    }
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
    
    func forceUnlockForDeveloper() {
        Task {
            isPremiumUnlocked = true
            await syncPremiumStatusWithSupabase()
            print("🔓 PremiumManager: Force unlocked premium for developer")
        }
    }
    
    func clearAllLocalData() {
        userDefaults.removeObject(forKey: Self.premiumUnlockedKey)
        userDefaults.removeObject(forKey: Self.premiumUnlockDateKey)
        isPremiumUnlocked = false
        print("🧹 PremiumManager: Cleared all local premium data")
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