//
//  PurchaseManager.swift
//  Thaqalayn
//
//  Handles StoreKit 2 purchases and transaction verification
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var purchaseError: String?
    @Published var purchaseSuccess = false

    // MARK: - Product Configuration
    private let productID = "com.thaqalayn.premium.tafsir"
    private var product: Product?

    // MARK: - Transaction Listener
    private var transactionListener: Task<Void, Error>?

    // MARK: - Initialization

    init() {
        // Start listening for transaction updates
        transactionListener = listenForTransactions()

        // Load product on init
        Task {
            await loadProduct()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            self.product = products.first

            if product == nil {
                print("⚠️ Product not found: \(productID)")
            } else {
                print("✅ Product loaded: \(product!.displayName) - \(product!.displayPrice)")
            }
        } catch {
            print("❌ Failed to load product: \(error.localizedDescription)")
            purchaseError = "Failed to load product. Please try again."
        }
    }

    // MARK: - Purchase Flow

    func purchase() async throws {
        guard let product = product else {
            purchaseError = "Product not available. Please try again."
            throw PurchaseError.productNotFound
        }

        isLoading = true
        purchaseError = nil
        purchaseSuccess = false

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Update premium status in Supabase
                await syncPremiumStatusToSupabase()

                // Update UI
                await PremiumManager.shared.checkPremiumStatus()

                // Finish the transaction
                await transaction.finish()

                purchaseSuccess = true
                print("✅ Purchase successful!")

            case .userCancelled:
                print("ℹ️ User cancelled purchase")

            case .pending:
                print("⏳ Purchase pending approval")
                purchaseError = "Purchase pending approval. Please check back later."

            @unknown default:
                print("⚠️ Unknown purchase result")
                purchaseError = "Unknown error occurred. Please try again."
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            purchaseError = "Purchase failed: \(error.localizedDescription)"
            throw error
        }

        isLoading = false
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        isLoading = true
        purchaseError = nil

        do {
            // Sync with App Store
            try await AppStore.sync()

            // Check for premium entitlement
            let hasPremium = await verifyPurchase()

            if hasPremium {
                // Sync to Supabase
                await syncPremiumStatusToSupabase()

                // Update UI
                await PremiumManager.shared.checkPremiumStatus()

                purchaseSuccess = true
                print("✅ Purchases restored successfully!")
            } else {
                purchaseError = "No purchases found to restore."
                print("ℹ️ No premium purchase found")
            }
        } catch {
            print("❌ Restore failed: \(error.localizedDescription)")
            purchaseError = "Restore failed: \(error.localizedDescription)"
            throw error
        }

        isLoading = false
    }

    // MARK: - Transaction Verification

    func verifyPurchase() async -> Bool {
        // Check current entitlements for premium product
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.productID == productID {
                    print("✅ Premium entitlement verified via StoreKit")
                    return true
                }
            } catch {
                print("⚠️ Transaction verification failed: \(error)")
            }
        }

        return false
    }

    // MARK: - Private Helpers

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the transaction is verified
        switch result {
        case .unverified(_, let error):
            // Transaction failed verification
            throw error
        case .verified(let safe):
            // Transaction passed verification
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transaction updates
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Update premium status
                    await self.syncPremiumStatusToSupabase()
                    await PremiumManager.shared.checkPremiumStatus()

                    // Finish the transaction
                    await transaction.finish()

                    print("✅ Transaction update processed: \(transaction.productID)")
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }

    private func syncPremiumStatusToSupabase() async {
        print("🔄 PurchaseManager: Starting premium status sync to Supabase")
        do {
            try await SupabaseService.shared.updateUserPremiumStatus(isPremium: true)
            print("✅ PurchaseManager: Premium status synced to Supabase successfully")
        } catch {
            print("❌ PurchaseManager: Failed to sync premium status to Supabase")
            print("❌ PurchaseManager: Error: \(error)")
            print("❌ PurchaseManager: Error description: \(error.localizedDescription)")
            // Don't throw - we still want the local premium status to work
        }
    }

    // MARK: - Product Information

    func getProductPrice() -> String {
        return product?.displayPrice ?? "$0.99"
    }

    func getProductDescription() -> String {
        return product?.description ?? "Unlock all 114 surahs with comprehensive tafsir commentary"
    }
}

// MARK: - Error Types

enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not available"
        case .purchaseFailed:
            return "Purchase failed"
        case .verificationFailed:
            return "Transaction verification failed"
        }
    }
}
