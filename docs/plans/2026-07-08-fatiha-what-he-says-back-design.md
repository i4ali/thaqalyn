# al-Fātiḥa "What He Says Back" - redesign

**Status:** APPROVED, building. English-only (matches the rest of the Fātiḥa dive).
**Files:** `Thaqalayn/Models/DeepDive.swift`, `Thaqalayn/Views/DeepDive/DeepDiveView.swift`, `Thaqalayn/Content/SurahFatihaDive.swift`.

## Problem

The `.depths` beat "What He Says Back" (after the Bismillah, beat 5) put the ḥadīth
qudsī of the division of the prayer - God's line-by-line replies - into an upfront
tap-to-open **map**. Three defects:

1. **Spoiler.** The Orientation beat promises "knowing what He says back to you, line
   by line" as the journey's payoff; the map immediately gives it away.
2. **Genre flattening.** A narrative reveal (a call-and-response ḥadīth) rendered as a
   glossary/taxonomy card, the format built for Yaqīn's degrees of certainty.
3. **Buried best material.** The ḥadīth lived *only* in that card and was never
   returned to.

## Why the "three" itself is not the problem

The recurring deep-dive element is not "three ascending levels of one quality." Across
dives it flexes:

- Yaqīn "The Three Depths" (ʿIlm→ʿAyn→Ḥaqq) and Sabr "The Three Stations" - an
  ascending **ladder**.
- Yūsuf "The Map of the Sūrah" (Well→Prison→Reunion) - a **map** of narrative stations.

The real invariant: **an early three-fold lens whose parts line up with the three
Movements.** Fātiḥa's His half (1:1-4) / shared hinge (1:5) / your half (1:6-7) maps
one-to-one onto Praise / Turn / Path - the *same species as Yūsuf*. So the three-fold
content fits naturally. Only the delivery (payoff placed in the map) was wrong.

## Design

**Keep a de-spoilered map + reveal the replies in-flow.**

### A. The map card stays, de-spoilered (content-only edit; no code change to `.depths`)

- Tag: "What He Says Back" → **"His Half, and Yours"**.
- Reference kept: *Ḥadīth Qudsī · ʿUyūn Akhbār al-Riḍā* (source of the division).
- Item descriptions name the **shape/ownership** of each part and **drop the divine
  quotes**. `embodies`: "the half that is His" / "the meeting point" / "the half that
  is yours".
- The hardcoded "The map for everything below." subtitle is now honest.

### B. New `.response` beat type - the reveal (call-and-response)

`case response(act: Int, replyingTo: LocalizedText, arabic: String, words:
LocalizedText, source: LocalizedText, reflection: LocalizedText)` + `act` mapping +
one `responsePage(...)` renderer + one line in the `content(...)` switch. Additive -
no other dive uses it (same pattern as `.closing`).

Look (approved mockup): a descending gold thread + hardcoded **"HE ANSWERS"** eyebrow
(goldBright, with a soft halo of light from the top - His voice arrives from above);
the per-beat `replyingTo` microline; the Arabic anchor of His words (Amiri, goldBright,
glow); the divine `words` as the glowing hero line (Cormorant italic, cream); the
`source`; hairline; `reflection` tie-back (mute). Same shape all three times.

### C. Placement - three at the seams

- **① after 1:4** (closes Movement I / Praise): حَمِدَنِي عَبْدِي - "My servant has
  praised Me, extolled Me, and glorified Me." (omits "shall have what he asked" - praise
  is not a request).
- **② after 1:5** (the hinge): بَيْنِي وَبَيْنَ عَبْدِي - "This is between Me and My
  servant - and My servant shall have what he asked."
- **③ after 1:7** (the petition): لِعَبْدِي مَا سَأَلَ - "This is for My servant - and
  My servant shall have what he asked." Tie-back hands into the existing Ḥadīth
  al-Thaqalayn narration ("what He gives, He now names").

Net: 17 → 20 beats (~12 min). The map *names* the three; the reveals *voice* them -
setup then payoff, like Yūsuf's map then story.

## Non-goals / notes

- No Qur'an `.verse` `arabic` fields change, so the quran_data.json byte-check is not
  in play; the `.response` anchors are ḥadīth, not Qur'an.
- Arabic vocalization of the anchors to be eyeballed before shipping.
- Verification gate: `xcodebuild build` (scheme Thaqalayn). No XCTest. User verifies in
  the simulator.
- Not a new feature (a refinement to an existing dive), so no "What's New" entry.

## Addendum (2026-07-08) - map card dropped entirely

The de-spoilered map (§A) was tried in the simulator and cut. Even cleaned of the
spoiler, it is a whole-prayer overview that the template nests *inside* Movement I
(auto-labeled "Movement I · The Praise") and drops between Bismillah and "al-ḥamdu
lillāh" - a meta/structural card interrupting an experiential descent. Yūsuf survives
this because it is a narrative (a map helps hold a plot); al-Fātiḥa is a prayer, not a
plot, so the map is clutter.

Resolution: the `.depths` beat is removed from `SurahFatihaDive` (the enum/renderer are
untouched; other dives keep it). Its one unique contribution - the ḥadīth's "I have
divided this prayer between Me and My servant" frame - is folded into the first
`.response` reflection, so the call-and-response has its footing when it first appears.
Net: 20 → 19 beats. Orientation already previews the three parts; the three reveals now
carry the His/shared/yours division in-flow, where each part is recited.

## Addendum (2026-07-08) - overview cards moved out of Movement I (all dives)

Dropping Fātiḥa's map exposed a template-wide issue: every dive's three-fold overview
card (`.depths`) was nested *inside* Movement I and auto-labeled "Movement I · ..." - but
a whole-sūrah overview is not part of the first movement. The rule adopted: **overview/
map cards belong at the threshold (act 0), not inside a movement.** Mechanism: set the
`.depths` `act` to `0`, which makes `placeInfo` return nil (no place-bar/movement label),
and position it right after `.orientation`, before the Movement-I `.act` divider. The
enum/renderer are unchanged.

Per dive:
- **Fātiḥa** - dropped entirely (a prayer, not a plot; the reveals carry the division).
- **Yūsuf** - relocated to the threshold (act 0). It is a narrative, so the "Map of the
  Sūrah" (Well → Prison → Reunion) earns keeping. Orientation's tail was detuned from a
  six-item arc list ("the dream, the well, the palace, the prison, the throne, and the
  reunion") to "where every fall becomes a rise," so it no longer re-lists the map's own
  stations.
- **Yaqīn** - relocated to the threshold (act 0). Orientation left intact: its leaveWith
  ("a map of certainty") now flows directly into the card, and its promise ("to know it,
  to see it, to live it") reads as a tease the card details with the fire metaphor +
  classical terms. Trilingual dive, so orientation was not rewritten.
- **Sabr** - relocated to the threshold (act 0). Same as Yaqīn (leaveWith "a map of
  patience"); orientation left intact. English-only.

Open follow-up: if the Yaqīn/Sabr promise ("Three depths/stations... endure/accept/peace")
reads as redundant with the now-adjacent card, detune it (Sabr is trivial; Yaqīn needs
ur/ar). Left as tease→detail for now.
