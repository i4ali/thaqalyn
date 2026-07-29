# Salah Deep Dive - Implementation Plan

**Date:** 2026-07-28 · **Design (content source of truth):** `docs/plans/2026-07-28-salah-deep-dive-design.md`

Three waves, each ending in a build gate (`xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`). No pbxproj edits (synced folders). Never commit.

## Wave 1 - engine (one atomic unit: model + view)

### `Thaqalayn/Models/DeepDive.swift`

1. Alongside the existing `var stageNoun: String = "Depth"`, add five per-dive journey-verb strings (defaults preserve the four shipped dives exactly):

```swift
    /// CTA under the open beat. "Descend" for the classic dives; "Ascend" for Salah.
    var descendCta: String = "Descend"
    /// CTA under the orientation beat.
    var beginCta: String = "Begin the descent"
    /// Subline under the threshold-map title.
    var mapLine: String = "The map for everything below."
    /// The big label on movement cards and the place-bar noun ("Movement I · ...").
    var stageWord: String = "Movement"
    /// The line in the Amin block before the dive's `close` clause.
    var endLine: String = "The descent ends."
```

2. Add the `sujud` case to `DeepDiveSection` (8-field shape, matching `release`/`count`), and add it to the grouped act-4 mapping (`case .reflectionPrompt, .release, .count, .dua, .closing:` becomes `case .reflectionPrompt, .release, .count, .sujud, .dua, .closing: return 4`). Doc comment per design section 3.

### `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

1. String swaps (line refs approximate):
   - ~394 `("Movement \(roman(a)) · ...` → `("\(dive.stageWord) \(roman(a)) · ...`
   - ~538 `bob("Descend", ...)` → `bob(dive.descendCta, ...)`
   - ~564 `bob("Begin the descent", ...)` → `bob(dive.beginCta, ...)`
   - ~612 `Text("The map for everything below.")` → `Text(dive.mapLine)`
   - ~680 `Text("Movement")` → `Text(dive.stageWord)` (same styling; if the rendered label is uppercased by styling keep as is, else `.uppercased()` to match)
   - ~1236 `Text("The descent ends. \(close)")` → `Text("\(dive.endLine) \(close)")`
2. `sujudPage` renderer mirroring `releasePage` structurally (state block, gesture, haptics, reduceMotion, reading scale) with the sink-to-earth mechanic per design section 3: idle core at ring top + earth-line, ~2.2s sink on hold, turn label at bottom ("STAY - THIS IS THE NEAREST POINT"), resolve after ~2s more of hold or on lift after the turn, gentle reset on early lift. Fixed labels: "PRESS AND HOLD - GO DOWN" / "STAY - THIS IS THE NEAREST POINT".
3. `placeInfo` case: `case .sujud(let tag, ...): return (tag(lang), dive.acts.count)`.
4. Content-switch case for `.sujud` (no `default:` - keep the switch exhaustive).
5. Reset all sujud state in the Amin "Begin again" closure; invalidate any timer there and in `.onDisappear`.

## Wave 2 - content

**Create** `Thaqalayn/Content/SalahDeepDive.swift`: `extension DeepDive { static let salah: DeepDive }`, transcribed **verbatim** from design doc section 4 (16 beats; metadata incl. `stageNoun: "Name"`, `stageWord: "Name"`, `descendCta: "Ascend"`, `beginCta: "Begin the ascent"`, `mapLine: "The map for everything above."`, `endLine: "The ascent ends."`). Header comment names the spine and points at the design doc. Mirror `ShukrDeepDive.swift` style (bare string literals).

## Wave 3 - catalog + What's New

1. `Thaqalayn/Services/DeepDiveCatalog.swift` - insert after the `shukr` descriptor:

```swift
        DeepDiveDescriptor(
            id: "salah",
            title: LocalizedText(en: "Salah · Prayer", ur: "نماز", ar: "الصلاة"),
            titleAr: "صَلَاة",
            sfSymbol: "stairs",
            subtitle: LocalizedText(en: "An ascent through three names - Qur'an to Karbala",
                                    ur: "تین ناموں میں چڑھتا ایک سفر - قرآن سے کربلا تک",
                                    ar: "صعودٌ عبر ثلاثة أسماء - من القرآن إلى كربلاء"),
            available: true, dive: .salah
        ),
```

(`coverAssetName` omitted - nil until SalahCover art exists; follow-up.)

2. `Thaqalayn/Models/WhatsNewItem.swift` - add at the TOP of `WhatsNewCatalog.all`:

```swift
        WhatsNewItem(
            id: "deepDives-salah",
            sfSymbol: "stairs",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 12).date ?? .distantPast,
            destination: .deepDive("salah"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Salah - The Believer's Ascent. The first dive that climbs: three names of the prayer, from the night fifty were made five, through the answered Fatiha, to the prayer under arrows at Karbala - closing with Fatima's gift.",
            blurbUR: "نماز - مومن کی معراج۔ پہلا غوطہ جو اوپر چڑھتا ہے: نماز کے تین نام، اُس رات سے جب پچاس نمازیں پانچ ہوئیں، جواب پانے والی فاتحہ سے ہوتے ہوئے، کربلا میں تیروں کے سائے میں نماز تک - اختتام حضرت فاطمہؑ کے تحفے پر۔",
            blurbAR: "الصلاة - معراج المؤمن. أول غوصٍ يصعد: ثلاثة أسماء للصلاة، من ليلة صارت الخمسون خمساً، مروراً بالفاتحة التي تُجاب آيةً آية، إلى الصلاة تحت السهام في كربلاء - وختاماً بهدية فاطمة عليها السلام.",
            ctaEN: "Begin the ascent",
            ctaUR: "صعود کا آغاز کریں",
            ctaAR: "ابدأ الصعود"
        ),
```

(`releaseDate` is a placeholder - flag to the user at ship time.)

## Guardrails (Stage 4)

Per `references/technical-integration.md`: final independent `xcodebuild`; added-line em-dash grep (expect empty); `strip_diacritics.py --report` on the content file (expect 0); no `lock.fill`; beat census vs design doc (1 open, 1 orientation, 1 depths, 3 act, 3 verse, 3 narration, 1 response, 1 climax, 1 sujud, 1 dua).

## Out of scope

UR/AR dive content; SalahCover art; sujud persistence; audio assets.
