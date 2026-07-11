# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

### Python Development
```bash
# ⚠️ CRITICAL: ALWAYS USE VIRTUAL ENVIRONMENT ⚠️
source .venv/bin/activate
```
## Critical Development Guidelines

### ⚠️ ALL UI TEXT MUST SCALE WITH THE READING TEXT-SIZE CONTROL ⚠️

**IMPORTANT**: The app has a global reading text-size control (`ReadingSettingsManager.shared`, a `scale: CGFloat` multiplier set in Settings → Reading). Any **reading content** you add or edit — Qur'an Arabic, transliterations, translations, tafsir/commentary, narrations, descriptions, notes, story/answer/comfort body text — MUST scale with it.

**How**:
- Add `@StateObject private var readingSettings = ReadingSettingsManager.shared` (or `@ObservedObject`) to the view.
- Multiply the font size by the scale: `.font(EmType.serif(16 * readingSettings.scale, .medium))` or `.font(.system(size: 16 * readingSettings.scale))`, and scale line spacing too: `.lineSpacing(5 * readingSettings.scale)`.
- Match the pattern already used in `DuaDetailView`, `ParallelDetailView`, `SurahDetailView`, `FoodDetailView`.

**Do NOT scale** (keep fixed): titles/headings, section labels & eyebrows, verse references, source citations, captions, pills/badges, and button labels. The control's scope is "Verses, translation & commentary" — body reading content, not chrome.

**Rationale**: Users rely on this control for accessibility/readability. Hardcoded font sizes ignore it and leave content unreadable at the largest settings.

### ⚠️ EVERY DUʿĀ / ZIYĀRAT MUST HAVE A LISTEN OPTION ⚠️

**IMPORTANT**: Any screen that displays a duʿā or ziyārat's Arabic MUST include a "Listen" control. Duʿās have no pre-recorded audio, so playback is text-to-speech via `TafsirReader.shared` (`AVSpeechSynthesizer`), keyed off the Arabic string — the same mechanism Qur'an verse audio does NOT use (verses have real recitation via `VerseRecitationButton`; duʿās/ziyārāt use TTS).

**How**:
- Drop in the reusable `DuaListenButton(arabic:)` component (`Thaqalayn/Views/Components/DuaListenButton.swift`), placed right after the Arabic text.
- It already handles both theme variants (standard + Midnight Emerald), the Listen → Pause → Resume states, and stopping playback on screen exit. Do NOT hand-roll a per-view TTS button.
- Pattern reference: `DuaDetailView`, `MuharramDayDetailView`, `HajjDayDetailView`, `RamadanDayDetailView`, `FatimiyyaDayDetailView`.

**Rationale**: Listening is a core way users engage with supplications; a duʿā shown without a Listen option is an inconsistency users notice and report.

### ⚠️ CLOUD SYNC ARCHITECTURE PATTERN ⚠️

**CRITICAL**: For any data type that needs to be synced to cloud (Supabase), follow the **[docs/BOOKMARK_SYNC_ARCHITECTURE.md](docs/BOOKMARK_SYNC_ARCHITECTURE.md)** as closely as possible

**Do NOT** deviate from this pattern without explicit approval. This architecture guarantees data integrity and provides excellent UX.

### ⚠️ NEVER RUN MORE THAN TWO SUBAGENTS AT A TIME ⚠️

**IMPORTANT**: Never launch more than two subagents (the Agent/Task tool) concurrently. When work needs many subagents — fan-out content authoring, parallel search, multi-file edits — batch them into **waves of at most two** and wait for each wave to finish before starting the next. Do NOT launch 3+ Agent calls in a single message.

**Rationale**: Running many subagents in parallel burns through tokens fast. Capping concurrency at two keeps token usage under control.

### ⚠️ ANNOUNCE EVERY NEW USER-FACING FEATURE IN "WHAT'S NEW" ⚠️

**IMPORTANT**: When you ship a new user-facing feature, add one entry to `WhatsNewCatalog.all` in `Thaqalayn/Models/WhatsNewItem.swift` so it surfaces on the Today tab's "What's New" spotlight. Provide title/blurb/CTA in all three languages (EN/UR/AR) and a `destination`. The card handles surfacing/retiring automatically; if the feature isn't a Deep Dive, add a `WhatsNewDestination` case and handle it in `WhatsNewCard.open()` (one-time). Do not use an em dash in the copy.

### ⚠️ PREMIUM-GATED FEATURES SHOW A "PREMIUM" LABEL, NOT A LOCK ⚠️

**IMPORTANT**: When gating a feature behind premium, signal it with a "Premium" chip/label in the app's accent style - never a lock icon (`lock.fill`). Match the existing treatment: the `DailyCrosswordCard` accent-chip `PREMIUM` capsule, or the journey day-row "Premium" capsule (`RamadanJourneyView`). Keep the card's normal chevron/affordance; the "Premium" label alone carries the gated signal. Do NOT add `lock.fill` glyphs (and avoid the lock-bearing `PremiumBadgeView`). Gate access with a `PremiumManager.canAccessX()` method and route locked taps to `PaywallView`.

### ⚠️ WRITE ENGLISH CONTENT IN PLAIN SPELLING - NO TRANSLITERATION DIACRITICS ⚠️

**IMPORTANT**: All English-facing text you author - titles, translations, prose, transliterated duʿās/ziyārāt, source citations, card copy - must use plain English spelling WITHOUT academic transliteration diacritics. Do not write macrons (ā ī ū), under-dotted consonants (ḥ ṣ ḍ ṭ ẓ), or the ʿayn/hamza half-ring marks (ʿ ʾ). This is the house style going forward.

**Rules** (encoded in `scripts/strip_diacritics.py`):
- Macrons and under-dots → base letter, preserving case: ā→a, ī→i, ū→u, ḥ→h, ṣ→s, ḍ→d, ṭ→t, ẓ→z.
- ʿayn (`ʿ`) and hamza (`ʾ`) → a straight apostrophe `'` when it sits **between two letters**, otherwise dropped: `Qurʾān`→`Qur'an`, `Shīʿa`→`Shi'a`, `ʿImrān`→`Imran`, `Karbalāʾ`→`Karbala`.
- Examples: "Sūrah Āl ʿImrān" → "Surah Al Imran"; "Allāhumma ṣalli ʿalā Muḥammad" → "Allahumma salli ala Muhammad".

**Scope**: English only. Real Arabic script (`arabic:`/`titleAr:` fields, JSON `ar`) and Urdu stay untouched. To retrofit existing files, run `python3 scripts/strip_diacritics.py --apply <files>` (or `--report` first to preview). Migration is rolling out area by area (Journey/Deep Dive/Inside-the-Sūrah first).

**Rationale**: The academic diacritics read as visual clutter to users; plain spelling is cleaner and is now the standard for all new content.