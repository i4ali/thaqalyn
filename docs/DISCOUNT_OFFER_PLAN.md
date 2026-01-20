# 40% Discount Promo Offer Implementation Plan

## Feature Summary
When a user sees the paywall and dismisses it without purchasing, show a one-time 40% discount offer. If accepted, charge the discounted price. If declined or dismissed, never show the promo again.

## User Selections
- **Discount Implementation**: Separate product in App Store Connect ($0.59)
- **Persistence**: Sync to Supabase (persists across reinstalls, requires login)
- **Trigger**: On dismiss (when user taps X on paywall)

## Architecture Overview

```
User dismisses PaywallView
         ↓
Check: hasSeenPromoOffer? (from Supabase/local cache)
         ↓
   No → Show DiscountOfferView
         ↓
  User accepts → Purchase discounted product → Mark offer as used
  User declines → Mark offer as used → Dismiss
         ↓
  Yes → Just dismiss paywall
```

## Implementation Steps

### Step 1: App Store Connect Setup (Manual)
Create a new non-consumable product:
- **Product ID**: `com.thaqalayn.premium.tafsir.discount`
- **Price**: $0.59 (40% off $0.99)
- **Display Name**: "Premium Tafsir - Special Offer"

### Step 2: Update PurchaseManager.swift
Add support for the discount product:
```swift
// Add new product ID
private let discountProductID = "com.thaqalayn.premium.tafsir.discount"
private var discountProduct: Product?

// Load both products
func loadProduct() async {
    let products = try await Product.products(for: [productID, discountProductID])
    self.product = products.first { $0.id == productID }
    self.discountProduct = products.first { $0.id == discountProductID }
}

// Add purchase method for discount product
func purchaseDiscounted() async throws { ... }

// Add getters for discount product info
func getDiscountProductPrice() -> String?
var isDiscountProductLoaded: Bool
```

### Step 3: Create DiscountOfferView.swift
New SwiftUI view for the promo modal:
- Urgent, limited-time styling (countdown feel without actual timer)
- "Special One-Time Offer" header
- Show original price crossed out, discounted price highlighted
- "Unlock Now - 40% Off" button
- "No Thanks" button to decline
- Same benefits list as PaywallView

### Step 4: Update PaywallView.swift
Modify the close button action:
```swift
Button(action: {
    // Check if eligible for promo offer
    if !PromoOfferManager.shared.hasSeenPromoOffer {
        showingDiscountOffer = true
    } else {
        dismiss()
    }
})

// Add sheet for discount offer
.sheet(isPresented: $showingDiscountOffer) {
    DiscountOfferView(onDismiss: { dismiss() })
}
```

### Step 5: Create PromoOfferManager.swift
New manager following the offline-first sync pattern (similar to BookmarkManager):

```swift
@MainActor
class PromoOfferManager: ObservableObject {
    static let shared = PromoOfferManager()

    @Published var hasSeenPromoOffer: Bool = false

    // Local cache key
    private let localCacheKey = "com.thaqalayn.promoOfferSeen"

    // Load from local cache on init
    init() { loadFromLocalCache() }

    // Mark offer as seen (local + sync to Supabase)
    func markPromoOfferSeen() async { ... }

    // Sync status from Supabase on login
    func syncFromSupabase() async { ... }

    // Clear on logout
    func clearStatus() { ... }
}
```

### Step 6: Update SupabaseService.swift
Add methods for promo offer status:
```swift
func getPromoOfferStatus() async throws -> Bool
func updatePromoOfferStatus(hasSeen: Bool) async throws
```

### Step 7: Database Schema (Supabase)
Add column to existing `user_preferences` table:
```sql
ALTER TABLE user_preferences ADD COLUMN has_seen_promo_offer BOOLEAN DEFAULT false;
```

## Files to Modify/Create

| File | Action |
|------|--------|
| `PurchaseManager.swift` | Modify - add discount product support |
| `PaywallView.swift` | Modify - add promo offer trigger on dismiss |
| `DiscountOfferView.swift` | **Create** - new promo modal view |
| `PromoOfferManager.swift` | **Create** - new manager for offer state |
| `SupabaseService.swift` | Modify - add promo offer sync methods |
| Supabase Dashboard | SQL migration for new column |

## Edge Cases Handled

1. **User not logged in**: Use local-only cache (UserDefaults), sync when they log in
2. **Offline mode**: Local cache works, syncs next time online
3. **Reinstall with login**: Fetches status from Supabase on auth
4. **Purchase either product**: Both grant premium via same `isPremium` flag
5. **User sees paywall multiple times before dismissing**: Only trigger on actual dismiss (X button)

## Testing Checklist

- [ ] Full price purchase still works
- [ ] Discount offer appears on first dismiss
- [ ] Discount offer never appears after first showing
- [ ] Discount purchase grants premium
- [ ] Status persists across app restarts
- [ ] Status syncs to Supabase for logged-in users
- [ ] Status restores on reinstall + login
- [ ] Restore purchases works for both products
