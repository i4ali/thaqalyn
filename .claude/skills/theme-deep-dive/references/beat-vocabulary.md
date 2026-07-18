# Beat vocabulary for theme dives - `DeepDiveSection` cases

Defined in `Thaqalayn/Models/DeepDive.swift`; rendered by
`Thaqalayn/Views/DeepDive/DeepDiveView.swift`. A dive is
`DeepDive(id, titleEn, titleAr, subtitle, sfSymbol, estMinutes, acts:[ActInfo], sections:[DeepDiveSection])`.
`ActInfo(number, ar, tr, name)` names each movement. English-first: all `LocalizedText`
fields accept bare String literals.

## The `act:` number

Drives the "Movement N · Name" place-bar and the depth dots:
- **0** - opening/threshold (`open`, `orientation`, and a threshold `.depths` map).
- **1..n** - the movements (`verse`, `act`, `narration`, `response`, `climax`).
- **4** (via the enum's computed `act`) - the close (`reflectionPrompt`, `release`,
  `count`, `dua`, `closing`) - always renders with all dots filled.

## The cases, as theme dives use them

| Case | Use for | Theme-dive precedent |
|---|---|---|
| `.open` | The cover: Arabic title, English title, one framing line ("A descent through the Qur'an and the Ahl al-Bayt - ..."). Always first. | All four |
| `.orientation` | "Before you descend": the promise (what lies below) + leaveWith (what you take away). Always second. | All four |
| `.depths` | The threshold map naming the movements (`Depth(ar, tr, label, desc, reference?, embodies)`). The `embodies` line traditionally lands on "the family who ..." for the final station. `act: 0`, after orientation. Optional - drop it if the dive has one held idea. | All four (three items each) |
| `.act` | Movement divider. `connector` names the thread back ("You have seen the Giver."), nil for movement I. `bridge: BridgeVerse?` carries an optional keynote verse - the last movement's bridge is a good home for the theme's most famous ayah. | All four |
| `.verse` | The backbone. `surah`/`ayah` anchor real recitation; the displayed `arabic:` may be an EXCERPT of the ayah (Sabr 12:86, Shukr 14:7 precedent) - useful when the full ayah carries a threat/context that breaks the devotional register (see the daily-verse curation memory for what disqualifies). Plain orthography. | All four |
| `.narration` | A hadith/story block with `source` naming Imam + book ("Imam Ja'far al-Sadiq · al-Kafi, the book of thanks"). | All four |
| `.response` | "HE ANSWERS" - a divine reply to a named line (`replyingTo`). For theme dives: a hadith qudsi / revelation-to-a-prophet answering the movement's question. Vary the prophet across dives (Dawud in Tawakkul, Musa in Shukr). Use when the theme has a genuine call-and-response moment; not mandatory. | Tawakkul, Shukr |
| `.climax` | The summit: build-up `body` → large glowing Arabic → translation → source → reflection. The dive's emotional peak (all four peak at Karbala - a finding each time, not a rule). | All four |
| `.reflectionPrompt` | The plain interactive close: a journaling prompt + text field. The DEFAULT close - complete and honorable (Yaqin, Sabr). | Yaqin, Sabr |
| `.release` | Press-and-hold ring; lifting the finger IS the entrustment, resolving into a verse. Belongs to Tawakkul's meaning - reuse only for a theme where letting-go IS the point. | Tawakkul |
| `.count` | Tap-to-count lights; the cascade outruns the finger, resolving into 16:18. Belongs to Shukr's meaning. | Shukr |
| `.dua` | The devotional close: intro, Arabic (gets a `DuaListenButton` automatically), translation, source, note, and `close` - the theme-specific final clause after "The descent ends." ("The thanks is yours to keep."). Theme dives end with `.dua`, not `.closing`. | All four |
| `.closing` | Surah-experience close (hands off to reading the surah). NOT for theme dives. | - |

## The closing dua ledger

Each dive's `.dua` must be new: Sahifa #20 (Yaqin), al-Sadiq's Amali prayer (Sabr),
Sahifa #28 (Tawakkul), Sahifa #37 (Shukr). Check the ledger before choosing.

## Inventing a new interactive beat (the `release`/`count` recipe)

Only when the gesture embodies the theme (SKILL.md Prime Directive #4). The pattern both
existing interactive beats follow - keep to it so the engine stays coherent:

1. **Same 8-field shape**: `case yourBeat(tag: LocalizedText, prompt: LocalizedText,
   subline: LocalizedText, arabic: String, translation: LocalizedText, reference: String,
   note: LocalizedText, nextLabel: LocalizedText)` - and add it to the grouped
   `case .reflectionPrompt, .release, .count, .dua, .closing: return 4` act mapping.
2. **Renderer states**: idle (✦ mark, serif prompt at fixed size, scaled italic subline,
   the interactive element, an uppercased gold instruction label) → active (prompt dims,
   label swaps to the goldBright "turn" instruction) → resolved (glowing Arabic +
   translation + reference + hairline + note + `bob(nextLabel)`), with the radial
   goldBright background on resolve.
3. **Haptics**: `.soft` on first touch, `.light` at the turn, `.success` notification on
   resolve - exactly like both precedents.
4. **Accessibility**: honor `reduceMotion` (state swaps, no cascade/fill animation) and
   reading scale `s` on subline/note/translation (NOT on the prompt or fixed labels).
5. **Reset**: clear ALL the beat's state in `aminBlock`'s "Begin again" closure, and
   invalidate any timer there and in `.onDisappear`.
6. **placeInfo**: `case .yourBeat(let tag, ...): return (tag(lang), dive.acts.count)`.
7. Fixed renderer strings are EN-only string literals for now (localization debt is
   tracked with the dive's UR/AR pass).

The engine change (model case + renderer) is ONE atomic unit - the exhaustive `content`
switch means the project does not compile between the two edits. Never add a `default:`
to that switch; a new beat must fail loudly if unhandled.
