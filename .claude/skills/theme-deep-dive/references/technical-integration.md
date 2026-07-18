# Technical integration - wiring a new theme dive

The repo uses **Xcode 16 synced folder groups** - create files in the right folder, no
`.pbxproj` edits. Reference implementation of the full wiring: the Shukr dive
(design `docs/plans/2026-07-17-shukr-deep-dive-design.md`, plan
`docs/plans/2026-07-17-shukr-deep-dive.md`).

## Files

| File | Change |
|---|---|
| `Thaqalayn/Content/<Theme>DeepDive.swift` | CREATE - `extension DeepDive { static let <theme>: DeepDive = ... }`. Mirror `ShukrDeepDive.swift`. Header comment names the spine and points at the design doc. |
| `Thaqalayn/Models/DeepDive.swift` | ONLY if a new interactive beat was earned: the new case + act mapping (see beat-vocabulary.md recipe). |
| `Thaqalayn/Views/DeepDive/DeepDiveView.swift` | ONLY if a new beat: state block + placeInfo case + content-switch case + renderer section + Begin-again reset. |
| `Thaqalayn/Services/DeepDiveCatalog.swift` | Flip the theme's descriptor: `available: true, dive: .<theme>`, new trilingual `subtitle` ("A descent through three <units> - Qur'an to Karbala" pattern, adapted). `title`/`titleAr`/`sfSymbol`/`coverAssetName` already exist for roadmap entries. |
| `Thaqalayn/Models/WhatsNewItem.swift` | Add `deepDives-<theme>` entry: sfSymbol = the catalog's, `destination: .deepDive("<theme>")`, trilingual title ("New Deep Dive" / "نیا گہرا غوطہ" / "غوصٌ عميقٌ جديد"), a blurb naming the spine + summit + the interactive close's hook, CTA "Begin the descent" / "نزول کا آغاز کریں" / "ابدأ النزول". `releaseDate` = expected ship date (newest-first ordering in the file; flag it as adjustable at ship time). |

No pbxproj, no PremiumManager change (gating is engine-level), no audio assets
(recitation + `DuaListenButton` are automatic), no `#Preview` needed in content files
(if one is added, wrap in `#if DEBUG` - Release/Archive breaks otherwise).

## Arabic in content files

- **Plain (non-Uthmani) orthography** for all Qur'an Arabic - deliberately NOT
  byte-matching `quran_data.json` (that byte-check is for surah dives only; do not "fix"
  plain orthography to Uthmani, and do not run the surah-dive pull_arabic check).
- Source of textual truth: read the ayah from `Thaqalayn/Thaqalayn/Data/quran_data.json`
  (`data['verses'][str(surah)][str(ayah)]['arabicText']`) and transcribe to plain
  orthography (ٱ→ا, drop Uthmani small marks, keep standard harakat).
- Excerpting mid-ayah is allowed (Sabr 12:86 precedent); `surah:`/`ayah:` still anchor
  the full-verse recitation.
- Hadith/dua Arabic is authored by hand with standard harakat, from the verified source
  text gathered in Stage 2.

## The visual mock (Stage 2)

Copy `docs/mockups/shukr_mock.html`'s design system (phone frames 388x806, emerald
radial backgrounds bg1-bg5, gold/cream palette, Cormorant + Amiri via local `file://`
fonts). One cell per distinctive beat; a NEW interactive beat gets one cell per state
(idle / active / resolved). Save as `docs/mockups/<theme>_mock.html`, then render with
ONE-SHOT headless Chrome (auto-exits - never touch the user's running Chrome, no pkill):

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new \
  --disable-gpu --allow-file-access-from-files --hide-scrollbars \
  --window-size=1760,<height> \
  --screenshot="docs/mockups/<theme>_mock.png" \
  "file://$PWD/docs/mockups/<theme>_mock.html"
open "docs/mockups/<theme>_mock.png"
```

Height ≈ rows × 850 + 300. Read the PNG yourself before showing it - catch layout breaks.

## Build gate (every wave, plus a final independent run)

From the repo root:

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4
```

If `name=` is ambiguous, fall back to `id=<UDID>` from `xcrun simctl list devices booted`.
Ignore SourceKit "cannot find type in scope" diagnostics - stale-index false positives.
No XCTest. No simctl install/launch/screenshot - the user does the device pass.

## Guardrail greps (Stage 4, run yourself)

```bash
# em dashes in ADDED lines only (pre-existing header comments may contain them):
git diff -U0 -- <edited files> | grep "^+" | grep "—"        # expect empty
grep -c "—" Thaqalayn/Content/<Theme>DeepDive.swift          # expect 0
# transliteration diacritics in English:
python3 scripts/strip_diacritics.py --report Thaqalayn/Content/<Theme>DeepDive.swift
                                                              # expect 0 occurrences
# no lock glyphs:
grep -n "lock.fill" <edited files>                            # expect empty
# beat census matches the design doc (one line per case type):
grep -o "\.\(open\|orientation\|depths\|act\|verse\|narration\|response\|climax\|reflectionPrompt\|release\|count\|dua\)(" \
  Thaqalayn/Content/<Theme>DeepDive.swift | sort | uniq -c
```

Never commit - the user commits (design doc, plan, mock, and code together).
