---
name: inside-the-surah
description: Author a new "Inside the Sūrah" immersive Deep Dive experience for any sūrah in the Thaqalayn iOS app. Use when asked to create/build/generate an "Inside the Sūrah", a sūrah experience, a sūrah journey, or an immersive Deep Dive for a specific sūrah (e.g. "make an Inside the Sūrah for al-Kahf", "build the Sūrah Yāsīn experience", "new surah journey for al-Mulk"). Runs research → blueprint → script → implement → build → audit with two approval gates, adapting the house template to each sūrah instead of forcing it.
---

# Inside the Sūrah - author a new sūrah experience

You are building one immersive, full-screen "descent" through a sūrah for the Thaqalayn
app: a sequence of beats (open, verses with reflection, movement dividers, narrations, a
climax, a closing) rendered by `DeepDiveView` from a single data file. The four existing
dives - `al-Fātiḥa`, `Yūsuf`, `Yaqīn`, `Sabr` - are your reference, not your cage.

## THE PRIME DIRECTIVE (read twice)

**The house template is a GUIDE, not a mold. Fit the sūrah, never force the sūrah into
the template.**

Every sūrah has its own shape. A narrative (Yūsuf) wants an arc; a hymn with a refrain
(al-Raḥmān) wants the refrain to recur; a legal/community sūrah (al-Baqara) can't be
covered verse-by-verse and needs a thematic spine; a short protection sūrah (al-Mulk)
wants a single held idea. The three-movement structure, the "map" card, the climax - all
of it is optional. **If a beat is there only because the other dives have it, cut it.**
Add beats, drop beats, reorder, or invent new framings as the sūrah demands. When in
doubt, ask: *does this beat earn its place for THIS sūrah?*

### Hard-won learnings (from building al-Fātiḥa; see `docs/plans/2026-07-08-fatiha-what-he-says-back-design.md`)

1. **No spoilers.** A sūrah's payoff - a reveal, a ḥadīth, a divine response, the turn -
   must unfold **in-flow, where it is felt**, not be pre-dumped in an early card. (al-Fātiḥa's
   "God answers you line by line" was wrongly front-loaded in a map; it now lands beat by
   beat as `.response` reveals after each part you recite.)
2. **Overview/map cards belong at the THRESHOLD, never inside a movement.** If (and only
   if) an at-a-glance map earns its place - usually for a *narrative* sūrah - it is a
   `.depths` beat with `act: 0`, placed after `.orientation` and before the first movement
   divider, so it carries **no "Movement I" label**. Default to NOT having one; a prayer or
   a single-theme sūrah does not need a map.
3. **Every beat earns its place.** Redundancy with the orientation or the movement dividers
   is a smell. Cut or merge.
4. **Match the reading experience**: Qur'an Arabic verbatim from `quran_data.json`; reading
   text-size compliance is automatic in `DeepDiveView` (do not hardcode around it); a
   `DuaListenButton` on any duʿā/ziyārat beat; **never an em dash** (use " - ").
5. **Sourcing is Shia and verified**: al-Mīzān (Ṭabāṭabāʾī), Tafsīr Nūr al-Thaqalayn,
   Majmaʿ al-Bayān, and Ahl al-Bayt narrations with real sources; honorifics on the
   Prophet ﷺ and the Imams (ʿalayhi al-salām). Verify every narration before it ships.

## Scope of this run

- **Languages: English first.** Author all copy in English; leave Urdu/Arabic for a later
  translation pass. Use bare string literals for `LocalizedText` fields (they satisfy
  `ExpressibleByStringLiteral`), exactly like `SurahFatihaDive.swift` and `SurahYusufDive.swift`.
  (Qur'an Arabic and short ḥadīth Arabic anchors are still authored now.)
- **Two approval gates**: the BLUEPRINT (Stage 1) and the SCRIPT (Stage 2). Do not write
  Swift until both are approved.

---

## Pipeline

### Stage 0 - Immerse and research (no output to user yet)

1. **Read the reference dives in full** to internalize the RANGE of shapes, then read the
   design doc for the learnings:
   - `Thaqalayn/Content/SurahFatihaDive.swift` (conversation shape, `.response` reveals)
   - `Thaqalayn/Content/SurahYusufDive.swift` (narrative arc, threshold map)
   - `Thaqalayn/Content/YaqinDeepDive.swift`, `Thaqalayn/Content/SabrDeepDive.swift` (ladder)
   - `docs/plans/2026-07-08-fatiha-what-he-says-back-design.md`
   - `references/beat-vocabulary.md` (this skill) - every beat type and when to use it.
2. **Gather the sūrah's material.** The app already ships 5-layer Shia tafsir for most
   sūrahs inside `Thaqalayn/Thaqalayn/Data/quran_data.json` - mine it first (layer 2 =
   Ṭabāṭabāʾī/al-Mīzān, layer 4 = Ahl al-Bayt narrations are the richest for this). Then do
   **targeted web research** only for the specific narrations, occasions of revelation, or
   al-Mīzān points you will actually use. Note every source as you go.
3. **Decide the spine.** What is this sūrah's single organizing idea, and its natural shape?
   For a long sūrah, choose a focused thematic slice and the handful of verses that carry it -
   do NOT attempt full coverage. Write down candidate verses (surah:ayah) you may quote.

### Stage 1 - BLUEPRINT  ← GATE 1

Present a concise blueprint to the user and **stop for approval**. It must contain:
- **The sūrah's shape** in one paragraph: theme, genre (narrative / hymn / legal /
  devotional / mixed), length strategy (full or thematic slice + why).
- **Template fit - explicit**: state where you FOLLOW the house template and where you
  deliberately BREAK it for this sūrah, and why. (E.g. "no map card - this is a prayer, not a
  plot"; "four movements, not three"; "no climax beat - the sūrah's peak is verse 3 itself".)
- **The beat outline**: an ordered list of beats (type + one-line purpose + verse ref),
  the movement/act grouping, and the estimated length. Mark any `.depths` overview as `act: 0`
  threshold. Flag any duʿā/ziyārat beats (they need a Listen button).
- **Sources**: the narrations/tafsir you will lean on, each with its reference.

Iterate with the user until the shape is right. Do not proceed to copy until approved.

### Stage 2 - SCRIPT  ← GATE 2

Write the full English master script as markdown to
`docs/plans/surah-experience/<surah-id>-script.md` (mirror `fatiha-script.md`): every beat
with its final copy, verse Arabic + translation + reflection, narration bodies, sources,
and meta (id, titleEn, titleAr, subtitle, sfSymbol, estMinutes, acts). **Stop for approval.**
Apply the learnings as you write - no spoilers, every beat earning its place, no em dashes.
Revise until approved.

### Stage 3 - IMPLEMENT

Follow `references/technical-integration.md` exactly. In short:
1. Create `Thaqalayn/Content/Surah<Name>Dive.swift` with `static let surah<Name>: DeepDive`.
2. **Pull verse Arabic programmatically** with `scripts/pull_arabic.py` (this skill) and paste
   the output verbatim into the `arabic:` fields - hand-typed Arabic drifts to NFC and fails the
   byte-check. Short ḥadīth-qudsī anchors are authored by hand (not Qur'an, no byte-check).
3. Register in `Thaqalayn/Services/SurahExperienceCatalog.swift` (`available: true, dive: .surah<Name>`)
   - fill the existing stub if one exists (Yāsīn/Raḥmān/Mulk are stubbed), else add an entry.
4. Add a `WhatsNewItem` in `Thaqalayn/Models/WhatsNewItem.swift` (`destination: .surahExperience("surah-<id>")`).
5. Wrap the `#Preview` in `#if DEBUG` (Release/Archive breaks otherwise).

### Stage 4 - BUILD

`xcodebuild -scheme Thaqalayn -destination 'id=<booted-sim-UDID>' build` (get the UDID from
`xcrun simctl list devices booted`; use `id=`, not `name=`). **Ignore SourceKit "Cannot find
type ... in scope" diagnostics on the new file** - they are stale-index false positives; the
green `xcodebuild` is the truth. No XCTest. Do not launch the simulator - the user does the
device pass themselves.

### Stage 5 - AUDIT (flag-only, two agents)  ← REQUIRED for every new sūrah

Once the build is green, run the flow audit per `references/audit.md`: **exactly two**
subagents in a single wave (never more than two at once):
- **Auditor A - Flow & learnings**: walks every beat in order and checks coherence, pacing,
  transitions, and the learnings-checklist (no spoilers, overview at threshold, every beat
  earns its place, template not forced, no em dashes, Listen buttons present).
- **Auditor B - Theology, sourcing & Arabic**: verifies Shia sourcing and honorifics, each
  narration's attribution, and that every `arabic:` verse field matches `quran_data.json`.

Both **report only** - they do not edit. Consolidate their findings into a single ranked
list of issues/risks (most severe first) and present it. The user decides what to fix.

---

## Guardrails
- **Two gates are mandatory.** Never write Swift before the blueprint AND script are approved.
- **Max two subagents at a time** (the audit is exactly two, one wave).
- **Never auto-commit** - the user commits themselves.
- **No em dashes**, anywhere, ever. Reading-scale and Listen-button rules from the repo
  `CLAUDE.md` are non-negotiable.
- A new sūrah experience is a shipped user-facing feature → the What's New entry is required.
- Deep-dive copy is premium-gated by default (only al-Fātiḥa is free) - no action needed in
  code; `PremiumManager.canAccessSurahExperience` already gates by id.
