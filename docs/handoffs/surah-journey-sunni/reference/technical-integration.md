# Technical integration - wiring a new sūrah experience

Three files register a dive; one script gets the Arabic right; one build verifies it.
The repo uses **Xcode 16 synced folder groups** - just create files in the right folder,
no `.pbxproj` edits.

## 1. The content file - `Thaqalayn/Content/Surah<Name>Dive.swift`

Mirror `SurahFatihaDive.swift`. Skeleton:

```swift
import SwiftUI

extension DeepDive {
    static let surah<Name>: DeepDive = DeepDive(
        id: "surah-<id>",                 // stable; also the deep-link + catalog + What's New id
        titleEn: "al-<Name>",
        titleAr: "الْ...",
        subtitle: "One-line descriptor",
        sfSymbol: "book.closed",          // an SF Symbol for the card
        estMinutes: 11,
        acts: [
            ActInfo(number: 1, ar: "...", tr: "...", name: "The ..."),
            // ... only the movements you actually use
        ],
        sections: [
            .open(...),
            .orientation(...),
            // threshold .depths(act: 0, ...) ONLY if it earns its place
            // movements: .act + .verse/.narration/.response/.climax
            .reflectionPrompt(...),
            .closing(...),                // or .dua(...) for a devotional close
        ]
    )
}

#if DEBUG
#Preview("Sūrah al-<Name> experience") {
    DeepDiveView(dive: .surah<Name>, onClose: {})
}
#endif
```

- **English-first**: bare String literals for every `LocalizedText` (they satisfy
  `ExpressibleByStringLiteral`). ur/ar come in a later pass.
- **`#if DEBUG` around `#Preview` is mandatory** - a preview using DEBUG-only symbols
  compiles for the simulator but fails Release/Archive (exit 65).

## 2. Verse Arabic - pull it, never hand-type it

Authored Arabic drifts to NFC normalization and fails the byte-for-byte check against
`quran_data.json`. Get the exact bytes from the data file:

```bash
python3 .claude/skills/inside-the-surah/scripts/pull_arabic.py 12:4 12:15 12:33
```

Paste each printed string verbatim into the matching `.verse(arabic: "...")`. The BOM on
1:1 is stripped by the script. (Short ḥadīth-qudsī anchors for `.response`/`.narration`
are NOT Qur'an and are hand-authored - they skip this check.)

## 3. Catalog - `Thaqalayn/Services/SurahExperienceCatalog.swift`

Add to `SurahExperienceDescriptor.all`, or fill an existing "coming soon" stub
(Yāsīn=36, Raḥmān=55, Mulk=67 are stubbed with `available: false, dive: nil`):

```swift
SurahExperienceDescriptor(
    id: "surah-<id>",
    surahNumber: <n>,
    title: LocalizedText(en: "Sūrah al-<Name>", ur: "...", ar: "..."),
    titleAr: "...",
    sfSymbol: "book.closed",
    subtitle: LocalizedText(en: "...", ur: "...", ar: "..."),
    available: true, dive: .surah<Name>
),
```

(The catalog `title`/`subtitle` may be trilingual even though the dive body is English-first -
match whatever the neighboring entries do; if unsure, English in all three is acceptable for now.)

## 4. What's New - `Thaqalayn/Models/WhatsNewItem.swift`

A new sūrah experience is a shipped feature → add a `WhatsNewItem` to `WhatsNewItem.all`:

```swift
WhatsNewItem(
    id: "surahExperience-<id>",
    sfSymbol: "book.closed",
    releaseDate: DateComponents(calendar: .current, year: 2026, month: ?, day: ?).date ?? .distantPast,
    destination: .surahExperience("surah-<id>"),
    titleEN: "Inside the Sūrah", titleUR: "سورہ کے اندر", titleAR: "في قلب السورة",
    blurbEN: "Sūrah al-<Name> - ...", blurbUR: "...", blurbAR: "...",
    ctaEN: "Begin the journey", ctaUR: "سفر شروع کریں", ctaAR: "ابدأ الرحلة"
),
```

The `.surahExperience(id)` destination is already handled by the router and `WhatsNewCard` -
no new case needed. (Provide the three languages for the What's New card even in an
English-first run; reuse the Yūsuf entry's UR/AR chrome wording.)

## 5. Build & verify

```bash
UDID=$(xcrun simctl list devices booted | grep -oE '\([0-9A-F-]{36}\)' | tr -d '()' | head -1)
xcodebuild -scheme Thaqalayn -destination "id=$UDID" build
```

- Use **`id=<UDID>`**, not `name=`.
- **SourceKit "Cannot find type 'DeepDive'/'LocalizedText'/... in scope" on the new file are
  false positives** (stale index). The authoritative signal is `** BUILD SUCCEEDED **`.
- **No XCTest.** The gate is a green `xcodebuild build`. Do not launch the simulator - the
  user runs the on-device pass and screenshots themselves.

## Gating (no code needed)

All sūrah experiences are premium except al-Fātiḥa. `PremiumManager.canAccessSurahExperience`
gates by id; a new premium dive needs nothing extra. Premium is signalled with a "Premium"
chip, never a lock icon (see repo `CLAUDE.md`).
