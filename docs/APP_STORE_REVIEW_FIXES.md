# App Store Review Issues - Fix Plan

## Issues Identified from App Store Review

### Issue 1: Guideline 5.1.1 - Legal - Privacy - Data Collection and Storage
**Problem**: The app requires users to register or log in to access features that are not account based.

**Specific Issue**: The app requires users to register before accessing the Quran. Apps may not require users to enter personal information to function, except when directly relevant to the core functionality of the app or required by law.

**Next Steps**: Revise the app to let users freely access the app's features that are not account based. The app may still require registration for other features that are account based.

### Issue 2: Guideline 5.1.1(v) - Data Collection and Storage  
**Problem**: The app supports account creation but does not include an option to initiate account deletion.

**Requirements**: Apps that support account creation must also offer account deletion to give users more control of the data they've shared while using an app.

**Details**:
- Only offering to temporarily deactivate or disable an account is insufficient
- If users need to visit a website to finish deleting their account, include a link directly to the website page where they can complete the process
- Apps may include confirmation steps to prevent users from accidentally deleting their account

## Solution Plan

### Issue 1: Remove Forced Authentication ✅
**Allow guest access to core Quran reading functionality while keeping authentication optional for account-based features.**

**Changes needed:**
1. **Modify ContentView.swift**: Update `checkFirstLaunch()` to only show welcome screen on first launch, not for authentication
2. **Create GuestModeFlow**: Add "Continue as Guest" option to WelcomeView alongside sign-in options
3. **Update WelcomeView.swift**: 
   - Remove "Authentication Required" messaging
   - Add prominent "Continue as Guest" button
   - Clarify that account is only needed for bookmark sync, not Quran access
4. **Update BookmarkManager**: Handle guest mode gracefully (local-only bookmarks)

### Issue 2: Implement Account Deletion ✅
**Add complete account deletion functionality that permanently removes user data.**

**Changes needed:**
1. **Add SupabaseService method**: Implement `deleteAccount()` function that deletes user from auth and all associated data
2. **Add ProfileMenuView option**: Add "Delete Account" option in user profile menu
3. **Create AccountDeletionView**: Confirmation flow with warnings about permanent data loss
4. **Update BookmarkManager**: Handle account deletion cleanup
5. **Add Supabase database function**: Server-side function to cascade delete all user data

## Implementation Steps

### Phase 1: Guest Access (Priority 1)
1. Update `ContentView.checkFirstLaunch()` to not force authentication
2. Add "Continue as Guest" button to `WelcomeView`
3. Update messaging to clarify authentication is optional
4. Test guest flow thoroughly

### Phase 2: Account Deletion (Priority 1)
1. Create account deletion UI components
2. Implement client-side deletion logic in `SupabaseService`
3. Add database triggers/functions for complete data cleanup
4. Add confirmation flows with appropriate warnings
5. Test deletion flow thoroughly

### Phase 3: Verification
1. Test that core Quran reading works without authentication
2. Test that bookmark sync still requires authentication
3. Test complete account deletion flow
4. Verify Apple guidelines compliance

## Current Authentication Flow Analysis

### Current Problematic Flow:
```
App Launch → WelcomeView (forced) → Authentication Required → Access to Quran
```

### Required New Flow:
```
App Launch → Optional WelcomeView → Choice: [Continue as Guest] or [Sign In] → Access to Quran
```

### Current Files to Modify:
- `ContentView.swift:58-66` - `checkFirstLaunch()` function
- `WelcomeView.swift:174-184` - Remove "Authentication Required" section
- `SupabaseService.swift` - Add account deletion methods
- `ProfileMenuView.swift` - Add account deletion option

## Notes
- Core Quran reading, audio playback, and theme selection should work without authentication
- Bookmarks, cloud sync, and cross-device features require authentication
- Account deletion must be permanent and complete
- Privacy policy already mentions account deletion capability