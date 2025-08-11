//
//  PurchaseManager.swift
//  Thaqalayn
//
//  StoreKit 2 integration for premium features unlock
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    // MARK: - Product Configuration
    static let premiumUnlockProductID = "com.thaqalayn.premium_reciters"
    
    // MARK: - Published Properties
    @Published var isLoadingProducts = false
    @Published var products: [Product] = []
    @Published var purchaseError: String?
    @Published var isPurchasing = false
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoadingProducts = true
        purchaseError = nil
        
        do {
            let storeProducts = try await Product.products(for: [Self.premiumUnlockProductID])
            products = storeProducts
            print("✅ PurchaseManager: Loaded \(products.count) products")
        } catch {
            print("❌ PurchaseManager: Failed to load products: \(error)")
            purchaseError = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoadingProducts = false
    }
    
    // MARK: - Purchase Flow
    
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        purchaseError = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await transaction.finish()
                
                // Update premium status
                await PremiumManager.shared.unlockPremiumFeatures()
                
                print("✅ PurchaseManager: Purchase successful for product: \(product.id)")
                isPurchasing = false
                return true
                
            case .userCancelled:
                print("ℹ️ PurchaseManager: User cancelled purchase")
                isPurchasing = false
                return false
                
            case .pending:
                print("⏳ PurchaseManager: Purchase pending")
                isPurchasing = false
                return false
                
            @unknown default:
                print("⚠️ PurchaseManager: Unknown purchase result")
                isPurchasing = false
                return false
            }
            
        } catch {
            print("❌ PurchaseManager: Purchase failed: \(error)")
            purchaseError = "Purchase failed: \(error.localizedDescription)"
            isPurchasing = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        print("🔄 PurchaseManager: Restoring purchases...")
        
        do {
            try await AppStore.sync()
            
            // Check for existing transactions
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                
                if transaction.productID == Self.premiumUnlockProductID {
                    await PremiumManager.shared.unlockPremiumFeatures()
                    print("✅ PurchaseManager: Restored premium unlock")
                    break
                }
            }
        } catch {
            print("❌ PurchaseManager: Failed to restore purchases: \(error)")
            purchaseError = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Transaction Listening
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts(transaction: transaction)
                    await transaction.finish()
                } catch {
                    print("❌ PurchaseManager: Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func updatePurchasedProducts(transaction: Transaction) async {
        if transaction.productID == Self.premiumUnlockProductID {
            await PremiumManager.shared.unlockPremiumFeatures()
        }
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Product Information
    
    var premiumUnlockProduct: Product? {
        return products.first { $0.id == Self.premiumUnlockProductID }
    }
    
    func formatPrice(for product: Product) -> String {
        return product.displayPrice
    }
}

// MARK: - Purchase Errors

enum PurchaseError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let message):
            return message
        }
    }
}