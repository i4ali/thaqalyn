# Daily Duas — Design

**Date:** 2026-05-06
**Status:** Approved (pending implementation)
**Inspiration:** "20 دعاؤں کا گلدستہ" (20 Duas Bouquet) image — short hadith-based supplications for everyday occasions (eating, sleeping, entering home, etc.)

## Goal

Add a Daily Duas feature to the app, modeled on the existing `LifeMoments` pattern but for short Shia hadith-based supplications rather than Quranic verses. Ship 20 well-sourced duas with Arabic + transliteration + English/Urdu translations, displayed in a dedicated list/detail flow reachable from the Explore tab and the Home discovery carousel.

## Non-goals (v1)

- No audio recitation. Skipped to keep scope tight; can be added later by extending `AudioManager` or shipping bundled MP3s.
- No bookmarking/favorites. The full Supabase sync architecture (per `docs/BOOKMARK_SYNC_ARCHITECTURE.md`) is too heavy for 20 read-only items.
- No category filters / grouping. Flat list is sufficient at 20 items.
- No standalone tab in `MainTabView`. Stays within Explore + Home carousel.

## Scope

20 duas from the source image, each authored entry containing:

- Arabic text (diacritics)
- Latin transliteration (consistent style across all 20)
- English translation
- Urdu translation
- Source citation (e.g., "al-Kafi 6:294")
- Situation labels in EN / AR / UR
- Category (`daily | eating | travel | worship | other`)

If 1–2 duas cannot be sourced from authoritative Shia references (al-Kafi, Mafatih al-Jinan, Wasail al-Shia, Sahifa Sajjadiyya), ship with 18–19. Do not substitute or fabricate citations.

## Architecture

Mirror the LifeMoments feature pattern (rejected the alternative of generalizing into a shared "Reference Texts" abstraction — YAGNI for v1).

### Data model

In `Models/QuranModels.swift`:

```swift
struct DailyDuasData: Codable {
    let duas: [DailyDua]
}

struct DailyDua: Codable, Identifiable {
    let id: String
    let situationEn: String
    let situationAr: String
    let situationUr: String
    let arabic: String
    let transliteration: String
    let translationEn: String
    let translationUr: String
    let source: String
    let category: String  // daily | eating | travel | worship | other

    func situation(for language: CommentaryLanguage) -> String
    func translation(for language: CommentaryLanguage) -> String
    var categoryIcon: String  // SF Symbol per category
}
```

Notes:
- No `translationAr` field — the dua *is* Arabic.
- `translation(for:)` returns `translationEn` when language is Arabic (rationale: Arabic→Arabic translation is redundant; English is the sensible fallback for an Arabic-mode reader).
- Reuses the existing `CommentaryLanguage` enum from `CommentaryLanguageManager`.

### Files

**New:**
- `Thaqalayn/Data/daily_duas.json` — 20-entry static content
- `Thaqalayn/Services/DuasManager.swift` — `@MainActor` singleton; loads JSON lazily on first list open; exposes `@Published var duas: [DailyDua]`, `isLoading`, `errorMessage`
- `Thaqalayn/Views/DuasView.swift` — list screen
- `Thaqalayn/Views/DuaDetailView.swift` — per-dua detail screen
- `Thaqalayn/Views/Components/DuasCarouselCard.swift` — Home carousel card

**Modified:**
- `Thaqalayn/Models/QuranModels.swift` — add `DailyDua`, `DailyDuasData` (~40 LOC)
- `Thaqalayn/Views/ExploreView.swift` — add "Daily Duas" entry directly below Life Moments
- `Thaqalayn/Views/Components/DiscoveryCarousel.swift` — append `DuasCarouselCard` directly after `LifeMomentsCarouselCard`

**Not touched:** `Info.plist`, `pbxproj` (Xcode 16 synced folder groups). No new manager registered in `ThaqalaynApp.swift`. No Supabase / RLS / sync. No `BookmarkManager`. No `AudioManager`.

### List UI (`DuasView`)

- Near-clone of `LifeMomentsView`. Reuses `LoadingSection` and `ErrorSection` (already public in `LifeMomentsView.swift`) — no duplication.
- Title: language-driven via `CommentaryLanguageManager` (`"Daily Duas"` / `"روزمرہ کی دعائیں"` / `"الأدعية اليومية"`).
- Subtitle: language-driven (`"20 short supplications for everyday moments"` and AR/UR equivalents).
- `AdaptiveModernBackground()` — same as LifeMoments, theme parity across all 5 themes.
- `DuaCard` row: gradient circle icon (left), `dua.situation(for: language)` (center), chevron (right). Tap pushes `DuaDetailView`.
- **RTL flip**: when `CommentaryLanguageManager.shared.selectedLanguage` is `.arabic` or `.urdu`, apply `.environment(\.layoutDirection, .rightToLeft)` to row cards. Extends the LifeMoments pattern (which is English-only today).

### Detail UI (`DuaDetailView`)

Single scrollable screen, themed via `ThemeManager.shared` to match `FullScreenCommentaryView` styling (glass cards on modern themes, flat warm cards on warmInviting). Top to bottom:

1. **Header** — situation (large, language-driven) + small category pill
2. **Arabic block** — large Arabic text (28–32pt), centered, RTL, in a glass card. Long-press copies. (Mushaf font if it renders well for short prose duas, otherwise system Arabic.)
3. **Transliteration block** — italic ~16pt, subtle separators
4. **Translation block** — `dua.translation(for: language)`. RTL when Urdu mode. In Arabic mode, falls back to English translation (not hidden).
5. **Source citation** — small muted footer, e.g., `"Source: al-Kafi 6:294"`
6. **Share button** — `ShareLink` with payload:
   ```
   {situation in current language}

   {Arabic}

   {Transliteration}

   {Translation in current language}

   — Source: {source}
   Sent via Thaqalayn
   ```

Detail screen reactive to `@StateObject var languageManager = CommentaryLanguageManager.shared` so language changes elsewhere re-render the view.

### Integration

- **`ExploreView.swift`**: new row directly below "Life Moments". Icon `hands.sparkles.fill`, title and subtitle language-driven. Tap pushes `DuasView()`.
- **`DiscoveryCarousel.swift`**: append `DuasCarouselCard` directly after `LifeMomentsCarouselCard`. Same dimensions, same theming, gradient via `themeManager.accentGradient`, icon `hands.sparkles.fill`. Tap pushes `DuasView()`.

## Content sourcing plan

For each of the 20 duas:

1. Take situation from the source image as the seed.
2. Look up the standard Shia version in this priority order:
   - **al-Kafi** (Kulayni)
   - **Mafatih al-Jinan** (Sheikh Abbas Qummi)
   - **Wasail al-Shia** (Hurr al-Amili)
   - **Sahifa Sajjadiyya** (where applicable)
3. Capture full Arabic with diacritics, transliteration, English translation, Urdu translation, precise citation (book + chapter or vol:page).
4. Cross-check Arabic against a second source when possible.

Translations:
- **English**: prefer existing published translations (Ansariyan, duas.org, al-islam.org), normalized for consistency. Cite when wording is non-trivially borrowed.
- **Urdu**: prefer wording from popular Urdu Mafatih editions.
- **Transliteration**: ALA-LC or IJMES style, consistent across all 20.

Constraints:
- Do not transcribe Arabic directly from the source image.
- Do not fabricate citations. Flag any item without a strong source for review.
- For situations with multiple canonical variants (e.g., dua before sleep), pick the most-cited Shia variant and note the source.

Audit: user reviews `daily_duas.json` together with the UI in a single PR/commit (no separate content review pass).

## Risks & open questions

- **Mushaf font with prose duas**: the existing mushaf font is tuned for Quranic verses. Some duas (especially those with non-Quranic vocabulary or sentence-level prose) may render less elegantly. Implementation will test both mushaf font and system Arabic on a representative sample (e.g., dua #1 "Bismillahi wa 'ala barakatillah" vs. dua #19 "Allahumma laka sumtu...") and pick whichever reads better. If the choice differs per dua, default to system Arabic for prose-heavy duas.
- **Urdu translation length**: Urdu translations may run longer than English; ensure the detail screen handles long lines without overflow or awkward wrapping.
- **Carousel ordering**: appending after Life Moments is the chosen position; revisit if A/B data ever becomes available.

## Out of scope (potential follow-ups)

- Audio recitation (bundled MP3s or hosted on Supabase Storage)
- Bookmarking duas (would follow `BOOKMARK_SYNC_ARCHITECTURE.md`)
- Expanded library (Mafatih duas, Sahifa Sajjadiyya, Ramadan-specific, Ziyarat)
- Search / category filtering (only useful once corpus grows beyond ~30)
- Daily-dua push notification ("Today's dua: ...")
