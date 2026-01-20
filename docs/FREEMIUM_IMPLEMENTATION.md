# Freemium Model Implementation Guide

## Overview

This document outlines the complete implementation plan for converting Thaqalayn from a paid app ($0.99) to a **freemium model** with in-app purchases.

### Business Model

- **Free Tier**: Surah 1 (Al-Fatiha) with full 5-layer tafsir, all reciters, all themes, bookmarks, cloud sync
- **Premium Tier** ($0.99 IAP): Unlock tafsir commentary for Surahs 2-114

### Key Design Principles

1. ✅ **No Persistent Cache** - Premium status stored in-memory only, cleared on logout
2. ✅ **Source of Truth** - Supabase `is_premium` field is authoritative when online
3. ✅ **User Isolation** - Complete separation between user accounts (no status bleed)
4. ✅ **Offline Support** - StoreKit transaction verification (tied to Apple ID, not user account)
5. ✅ **Secure** - All purchase validation through Apple's servers

---

## Implementation Steps

### 1. StoreKit 2 Integration

#### Create `PurchaseManager.swift`

**Location**: `Thaqalayn/Services/PurchaseManager.swift`

**Responsibilities**:
- Load product from App Store Connect
- Handle purchase flow
- Restore purchases
- Verify transactions
- Sync premium status to Supabase

**Key Methods**:
```swift
@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isLoading = false
    @Published var purchaseError: String?

    private let productID = "com.thaqalayn.premium.tafsir"

    // Load product from App Store Connect
    func loadProducts() async throws -> Product

    // Purchase premium
    func purchase() async throws

    // Restore purchases
    func restorePurchases() async throws

    // Verify current entitlement (offline-capable)
    func verifyPurchase() async -> Bool

    // Update Supabase after purchase
    private func syncPremiumStatusToSupabase() async throws
}
```

**StoreKit 2 Transaction Verification** (Offline-capable):
```swift
func verifyPurchase() async -> Bool {
    for await transaction in Transaction.currentEntitlements {
        if transaction.productID == productID {
            return true
        }
    }
    return false
}
```

---

### 2. PremiumManager Refactor

#### Modify `PremiumManager.swift`

**Critical Changes**:

**Before** (Current):
```swift
@Published var isPremiumUnlocked: Bool = true  // ❌ Hardcoded, always premium
```

**After** (New):
```swift
@Published var isPremium: Bool = false  // ✅ In-memory, defaults to free

// Fetch from Supabase on login
func checkPremiumStatus() async {
    do {
        isPremium = try await SupabaseService.shared.getUserPremiumStatus()
        print("✅ Premium status loaded: \(isPremium)")
    } catch {
        print("❌ Failed to fetch premium status: \(error)")
        isPremium = false  // Default to free on error
    }
}

// Clear on logout
func clearPremiumStatus() {
    isPremium = false
    print("✅ Premium status cleared")
}

// Access control
func canAccessTafsir(surahNumber: Int) async -> Bool {
    // Surah 1 always free
    if surahNumber == 1 {
        return true
    }

    // Check online status
    if await SupabaseService.shared.isAuthenticated {
        return isPremium  // Use Supabase-verified status
    }

    // Offline: Verify via StoreKit
    return await PurchaseManager.shared.verifyPurchase()
}
```

**⚠️ Critical: NO UserDefaults, NO Persistent Cache**

**Why?**
- Prevents premium status bleed between user accounts
- User A (premium) logs out → User B (free) logs in → B must see free status

---

### 3. SupabaseService Integration

#### Modify `SupabaseService.swift`

**Add Premium Status Sync on Auth State Changes**:

```swift
func signIn(email: String, password: String) async throws {
    // ... existing sign-in code ...

    // ✅ Fetch premium status after successful login
    await PremiumManager.shared.checkPremiumStatus()
}

func signUp(email: String, password: String) async throws {
    // ... existing sign-up code ...

    // ✅ Fetch premium status after successful signup
    await PremiumManager.shared.checkPremiumStatus()
}

func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
    // ... existing Apple sign-in code ...

    // ✅ Fetch premium status after successful Apple sign-in
    await PremiumManager.shared.checkPremiumStatus()
}

func signOut() async throws {
    // ✅ Clear premium status BEFORE signing out
    PremiumManager.shared.clearPremiumStatus()

    // ... existing sign-out code ...
}
```

**Existing Methods** (Already implemented ✅):
- `getUserPremiumStatus()` - Line 327
- `updateUserPremiumStatus(isPremium:)` - Line 356

---

### 4. DataManager Access Control

#### Modify `DataManager.swift`

**Update `loadSurahWithTafsir()` method**:

```swift
private func loadSurahWithTafsir(surah: Surah) async -> SurahWithTafsir? {
    // Load tafsir data for this surah
    let tafsirData: TafsirData?

    // Check premium access
    let canAccess = await PremiumManager.shared.canAccessTafsir(surahNumber: surah.number)

    if canAccess {
        tafsirData = await loadTafsirData(for: surah.number)
    } else {
        tafsirData = nil  // Lock tafsir for non-premium users
    }

    guard let quranData = quranData,
          let surahVerses = quranData.verses[String(surah.number)] else {
        return nil
    }

    // Create verses with tafsir (if accessible)
    var verses: [VerseWithTafsir] = []

    for i in 1...surah.versesCount {
        let verseKey = String(i)
        if let verse = surahVerses[verseKey] {
            let tafsir = tafsirData?.verses[verseKey]
            let verseWithTafsir = VerseWithTafsir(
                number: i,
                verse: verse,
                tafsir: tafsir  // nil for locked surahs
            )
            verses.append(verseWithTafsir)
        }
    }

    return SurahWithTafsir(surah: surah, verses: verses)
}
```

---

### 5. UI Components

#### A. Create `PaywallView.swift`

**Location**: `Thaqalayn/Views/PaywallView.swift`

**Purpose**: Full-screen upgrade screen with benefits list

**Key Features**:
- Modern glassmorphism design matching app theme
- List of premium benefits
- Purchase button ($0.99)
- Restore purchases button
- Close button

**Benefits to Display**:
1. ✅ Unlock all 114 surahs with full tafsir
2. ✅ Access all 5 commentary layers
3. ✅ English & Urdu bilingual support
4. ✅ Offline access to all commentary
5. ✅ One-time purchase, lifetime access

#### B. Create `PremiumBadgeView.swift`

**Location**: `Thaqalayn/Views/PremiumBadgeView.swift`

**Purpose**: Lock icon indicator for locked content

**Usage**:
```swift
// On surah cards (surahs 2-114)
if !premiumManager.isPremium && surah.number > 1 {
    PremiumBadgeView()
}

// On commentary buttons
if verse.tafsir == nil && surah.number > 1 {
    PremiumBadgeView()
}
```

#### C. Modify `SurahDetailView.swift`

**Show Paywall for Locked Commentary**:

```swift
struct ModernVerseCard: View {
    // ... existing code ...

    @StateObject private var premiumManager = PremiumManager.shared
    @State private var showingPaywall = false

    var body: some View {
        VStack {
            // ... existing verse display ...

            // Commentary button
            if verse.tafsir != nil || surah.number > 1 {
                Button(action: {
                    if verse.tafsir == nil && surah.number > 1 {
                        // Show paywall for locked content
                        showingPaywall = true
                    } else {
                        onTafsirTap()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: verse.tafsir == nil ? "lock.fill" : "book.fill")
                        Text(verse.tafsir == nil ? "Unlock Commentary" : "Commentary")
                    }
                    // ... styling ...
                }
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}
```

#### D. Modify `ContentView.swift`

**Update `ProfileMenuView` with Premium Status**:

```swift
struct ProfileMenuView: View {
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        VStack {
            // Premium status badge
            VStack(spacing: 4) {
                if premiumManager.isPremium {
                    Text("Premium Member")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                } else {
                    Text("Free Tier")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }

            // Restore purchases button (for non-premium users)
            if !premiumManager.isPremium {
                ProfileMenuItem(
                    icon: "arrow.clockwise",
                    title: "Restore Purchases",
                    subtitle: "Already purchased? Restore here",
                    action: {
                        Task {
                            await purchaseManager.restorePurchases()
                        }
                    }
                )
            }

            // Upgrade button (for non-premium users)
            if !premiumManager.isPremium {
                ProfileMenuItem(
                    icon: "star.fill",
                    title: "Upgrade to Premium",
                    subtitle: "Unlock all tafsir commentary",
                    action: { showingPaywall = true }
                )
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}
```

#### E. Modify `AuthenticationView.swift`

**Update Messaging for Freemium Model**:

```swift
Text("Sign in to access premium features and sync bookmarks across devices.")
    .font(.system(size: 12, weight: .medium))
    .foregroundColor(themeManager.secondaryText)
    .multilineTextAlignment(.center)
```

---

### 6. App Store Configuration

#### Product Setup in App Store Connect

1. **Navigate to**: App Store Connect → Your App → Features → In-App Purchases
2. **Create New In-App Purchase**:
   - **Type**: Non-Consumable
   - **Reference Name**: Premium Tafsir Commentary
   - **Product ID**: `com.thaqalayn.premium.tafsir`
   - **Price**: Tier 1 ($0.99)

3. **Localization (English)**:
   - **Display Name**: Full Tafsir Commentary
   - **Description**: Unlock comprehensive Shia Islamic commentary for all 114 surahs with 5 layers of insight including classical, contemporary, Ahlul Bayt teachings, and comparative analysis. Available in English and Urdu.

4. **Review Information**:
   - **Screenshot**: Show paywall screen
   - **Review Notes**: Explain free tier (Surah 1) vs premium tier (Surahs 2-114)

#### App Pricing Change

1. **Navigate to**: App Store Connect → Your App → Pricing and Availability
2. **Change Price**: From **$0.99 Paid** to **Free**
3. **Submit for Review**

---

### 7. Premium Status Flow

#### Login Flow
```
User enters credentials
  ↓
SupabaseService.signIn()
  ↓
Authentication successful
  ↓
PremiumManager.checkPremiumStatus() → Fetch from Supabase
  ↓
isPremium = true/false (in-memory)
  ↓
UI updates with premium/free state
```

#### Purchase Flow
```
User taps "Unlock Commentary"
  ↓
PaywallView presented
  ↓
User taps "Purchase" ($0.99)
  ↓
PurchaseManager.purchase()
  ↓
StoreKit processes transaction
  ↓
Transaction verified by Apple
  ↓
PurchaseManager.syncPremiumStatusToSupabase()
  ↓
Supabase: UPDATE user_preferences SET is_premium = true
  ↓
PremiumManager.checkPremiumStatus()
  ↓
isPremium = true
  ↓
UI updates, all tafsir unlocked
```

#### Logout Flow
```
User taps "Sign Out"
  ↓
SupabaseService.signOut()
  ↓
PremiumManager.clearPremiumStatus()
  ↓
isPremium = false (in-memory cleared)
  ↓
SupabaseService clears session
  ↓
UI resets to free tier
```

#### User Isolation Example
```
Premium User A logs in
  ↓
Fetch Supabase: is_premium = true
  ↓
isPremium = true (in-memory)
  ↓
User A logs out
  ↓
isPremium = false (cleared)
  ↓
Free User B logs in
  ↓
Fetch Supabase: is_premium = false
  ↓
isPremium = false (fresh fetch)
  ✅ No premium status bleed from User A
```

#### Offline Access Flow
```
No internet connection
  ↓
User tries to access Surah 2 tafsir
  ↓
PremiumManager.canAccessTafsir(surahNumber: 2)
  ↓
Check: SupabaseService.isAuthenticated = false (offline)
  ↓
Fallback: PurchaseManager.verifyPurchase()
  ↓
Check StoreKit transaction history
  ↓
for await transaction in Transaction.currentEntitlements
  ↓
if transaction.productID == "com.thaqalayn.premium.tafsir"
  ↓
return true (access granted via Apple ID verification)
```

---

### 8. Database Schema

#### Existing Schema (No Changes Needed ✅)

**Table**: `user_preferences`

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `user_id` | UUID | - | Foreign key to auth.users |
| `is_premium` | BOOLEAN | `false` | Premium status flag |
| `bookmark_limit` | INTEGER | 2 | Free: 2, Premium: 999 |

**RLS Policies**: Already configured ✅

**Update Logic**:
```sql
-- After successful purchase (handled by PurchaseManager)
UPDATE user_preferences
SET is_premium = true,
    bookmark_limit = 999
WHERE user_id = $1;
```

---

### 9. Testing Checklist

#### Functional Tests

- [ ] **New User Flow**
  - [ ] Install app as new user
  - [ ] Can read Surah 1 tafsir without purchase
  - [ ] See lock icon on Surah 2-114 commentary buttons
  - [ ] Tap locked commentary → PaywallView appears

- [ ] **Purchase Flow**
  - [ ] Tap "Purchase" → StoreKit payment sheet appears
  - [ ] Complete purchase with sandbox account
  - [ ] Purchase succeeds → All tafsir unlocks
  - [ ] Supabase `is_premium` = true confirmed

- [ ] **Restore Purchases**
  - [ ] Delete app, reinstall
  - [ ] Tap "Restore Purchases"
  - [ ] Premium status restored from StoreKit
  - [ ] All tafsir accessible

- [ ] **User Isolation** ⚠️ CRITICAL
  - [ ] Login as Premium User A
  - [ ] Verify all tafsir accessible
  - [ ] Logout
  - [ ] Login as Free User B
  - [ ] Verify Surah 2+ locked (no bleed from User A)

- [ ] **Offline Mode**
  - [ ] Enable Airplane Mode
  - [ ] Premium user can still access all tafsir (StoreKit verification)
  - [ ] Free user still sees locks on Surah 2+

#### Edge Cases

- [ ] Purchase interrupted (app closed mid-transaction)
- [ ] Network error during Supabase sync
- [ ] Multiple rapid logout/login cycles
- [ ] Guest mode → Sign up → Should default to free tier

---

### 10. Migration Strategy for Existing Users

#### Grandfather Existing Paid Users

**Option 1: Manual Migration** (Recommended)
```sql
-- Run once in Supabase SQL Editor
-- Grant premium to all existing users before app update
UPDATE user_preferences
SET is_premium = true,
    bookmark_limit = 999
WHERE created_at < '2025-10-07';  -- Before freemium launch date
```

**Option 2: StoreKit Receipt Validation**
- Check if user downloaded app before freemium launch
- Auto-grant premium based on original app receipt

**Communication**:
- Send update notification: "Thank you for being an early supporter! You've been upgraded to Premium for free."
- In-app banner on first launch after update

---

### 11. Analytics & Monitoring

#### Track Key Metrics

**Conversion Funnel**:
1. Free users viewing locked content (PaywallView impressions)
2. Purchase button taps
3. Completed purchases
4. Restore purchase success rate

**Premium Status Events**:
- `premium_status_fetched`
- `premium_status_cleared`
- `purchase_completed`
- `purchase_restored`
- `paywall_shown`
- `paywall_dismissed`

**Implementation**:
```swift
// Example using os_log
import os.log

extension PremiumManager {
    func logPremiumEvent(_ event: String, metadata: [String: Any] = [:]) {
        os_log(.info, log: .default, "Premium Event: %{public}@", event)
        // Integrate with your analytics service (Firebase, etc.)
    }
}
```

---

### 12. Error Handling

#### Graceful Degradation

**StoreKit Errors**:
- Product not found → Show error, suggest retry
- Purchase canceled → Dismiss paywall silently
- Network error → Show "Check connection" message
- Transaction pending → Show progress indicator

**Supabase Errors**:
- Premium status fetch fails → Default to free tier
- Premium status update fails → Retry with exponential backoff
- Offline → Fall back to StoreKit verification

**Example**:
```swift
func checkPremiumStatus() async {
    do {
        isPremium = try await SupabaseService.shared.getUserPremiumStatus()
    } catch {
        print("⚠️ Failed to fetch premium status, defaulting to free: \(error)")
        isPremium = false  // Safe default
    }
}
```

---

## Summary

### What's Free
✅ All 114 surahs with Arabic text & English translation
✅ Surah 1 (Al-Fatiha) full 5-layer tafsir
✅ All 6 reciters with verse-by-verse audio
✅ All 4 themes (Modern Dark/Light, Traditional, Sepia)
✅ Bookmarks with cloud sync
✅ Authentication (email, Apple Sign In)

### What's Premium ($0.99)
🔒 Tafsir commentary for Surahs 2-114
🔒 All 5 layers (Foundation, Classical, Contemporary, Ahlul Bayt, Comparative)
🔒 English & Urdu bilingual commentary

### Critical Implementation Points
1. ⚠️ **NO persistent cache** - In-memory only, cleared on logout
2. ⚠️ **User isolation** - Fresh fetch from Supabase on every login
3. ⚠️ **Offline support** - StoreKit transaction verification (Apple ID-based)
4. ⚠️ **Security** - All purchase validation through Apple's servers
5. ⚠️ **Grandfather existing users** - Grant premium to early supporters

---

## Estimated Timeline

| Task | Time | Priority |
|------|------|----------|
| PurchaseManager.swift | 1.5 hrs | High |
| PremiumManager refactor | 1 hr | High |
| SupabaseService integration | 30 min | High |
| DataManager access control | 45 min | High |
| PaywallView.swift | 1.5 hrs | High |
| PremiumBadgeView.swift | 30 min | Medium |
| UI updates (SurahDetailView, ContentView) | 1.5 hrs | High |
| Testing & QA | 2 hrs | High |
| **Total** | **~9 hours** | - |

---

## Next Steps

1. ✅ Review this implementation plan
2. Create App Store Connect in-app purchase product
3. Implement code changes in order:
   - PurchaseManager.swift
   - PremiumManager.swift
   - SupabaseService.swift
   - DataManager.swift
   - PaywallView.swift
   - UI updates
4. Test with sandbox accounts
5. Submit for App Review

---

**Questions or Concerns?** Review this document before starting implementation.
