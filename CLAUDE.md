# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

### Python Development
```bash
# ⚠️ CRITICAL: ALWAYS USE VIRTUAL ENVIRONMENT ⚠️
source .venv/bin/activate
```
## Critical Development Guidelines

### ⚠️ NO FALLBACK LOGIC UNLESS EXPLICITLY REQUESTED ⚠️

**IMPORTANT**: Do not add any fallback logic, alternative implementations, or graceful degradation patterns unless explicitly asked. When operations fail, throw appropriate errors and let the caller handle them.

**Examples of what NOT to do**:
- ❌ Adding `try-catch` blocks with alternative implementations
- ❌ Providing "backup" methods when primary fails
- ❌ Silently degrading functionality when errors occur
- ❌ Creating "safe" versions that skip critical steps

**Correct approach**:
- ✅ Throw clear, descriptive errors when operations fail
- ✅ Let calling code decide how to handle failures
- ✅ Maintain data integrity over graceful degradation
- ✅ Fail fast and fail clearly

**Rationale**: Fallback logic can mask critical failures, lead to data inconsistency, and make debugging difficult. Clean error handling ensures problems are caught early and addressed properly.

### ⚠️ ALL UI TEXT MUST SCALE WITH THE READING TEXT-SIZE CONTROL ⚠️

**IMPORTANT**: The app has a global reading text-size control (`ReadingSettingsManager.shared`, a `scale: CGFloat` multiplier set in Settings → Reading). Any **reading content** you add or edit — Qur'an Arabic, transliterations, translations, tafsir/commentary, narrations, descriptions, notes, story/answer/comfort body text — MUST scale with it.

**How**:
- Add `@StateObject private var readingSettings = ReadingSettingsManager.shared` (or `@ObservedObject`) to the view.
- Multiply the font size by the scale: `.font(EmType.serif(16 * readingSettings.scale, .medium))` or `.font(.system(size: 16 * readingSettings.scale))`, and scale line spacing too: `.lineSpacing(5 * readingSettings.scale)`.
- Match the pattern already used in `DuaDetailView`, `ParallelDetailView`, `SurahDetailView`, `FoodDetailView`.

**Do NOT scale** (keep fixed): titles/headings, section labels & eyebrows, verse references, source citations, captions, pills/badges, and button labels. The control's scope is "Verses, translation & commentary" — body reading content, not chrome.

**Rationale**: Users rely on this control for accessibility/readability. Hardcoded font sizes ignore it and leave content unreadable at the largest settings.

### ⚠️ CLOUD SYNC ARCHITECTURE PATTERN ⚠️

**CRITICAL**: For any data type that needs to be synced to cloud (Supabase), follow the **[docs/BOOKMARK_SYNC_ARCHITECTURE.md](docs/BOOKMARK_SYNC_ARCHITECTURE.md)** as closely as possible. This architecture is production-tested and provides:

- **Offline-First Design**: Local operations succeed immediately, cloud sync happens asynchronously
- **Zero Data Loss**: Every operation persists locally before attempting cloud sync
- **Intelligent Conflict Resolution**: Timestamp-based detection with local-first preservation
- **User Account Isolation**: Complete data separation between users
- **Automatic Retry**: Failed operations queue for next sync attempt
- **Three-Step Sync Process**: Delete → Upload → Download (correct order guaranteed)

**Implementation Checklist** (from [docs/BOOKMARK_SYNC_ARCHITECTURE.md](docs/BOOKMARK_SYNC_ARCHITECTURE.md)):
1. ✅ Define data model with sync status enum (`synced`, `pendingSync`, `conflict`)
2. ✅ Create manager class with `@MainActor` isolation
3. ✅ Implement local storage (UserDefaults with JSON encoding)
4. ✅ Implement pending deletes tracking (separate Set)
5. ✅ Setup Supabase observers for auth state changes
6. ✅ Implement CRUD operations (offline-first pattern)
7. ✅ Implement three-step sync process
8. ✅ Implement conflict resolution in merge algorithm
9. ✅ Add debouncing for sync scheduling
10. ✅ Implement cleanup methods (sign-out, user switching)
11. ✅ Add Supabase service methods
12. ✅ Create database schema with RLS policies

**Do NOT** deviate from this pattern without explicit approval. This architecture guarantees data integrity and provides excellent UX.