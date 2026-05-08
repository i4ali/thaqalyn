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