# Stage 5 - the audit (flag-only, four agents, two waves)

Run **after** the final build is green, for **every** new theme dive. Dispatch **four**
subagents in **two waves**: Auditors A and B together, then Auditors C and D (never more than
two at once). **Dispatch all four auditors on Opus 4.6 (`model: "opus"`).** All **report only - they do not edit anything.** When all four return,
consolidate into one ranked list and present it; **stop there**. The user picks which
findings to fix. Apply ONLY the approved fixes, re-run the build gate, and record any
findings the user declined in the design doc as "known, accepted".

Give each auditor: the theme id, the path to `Thaqalayn/Content/<Theme>DeepDive.swift`,
the approved design doc `docs/plans/YYYY-MM-DD-<theme>-deep-dive-design.md`, and the
paths of the other shipped dive content files + design docs (for the ledger checks).

---

## Auditor A - Flow, shape & the ledger

> You are auditing a new theme "Deep Dive" for the Thaqalayn iOS app, defined in
> `<dive file>` (approved design doc: `<design doc>`). Read the whole `sections:` array in
> order and experience it as a user swiping one screen at a time. REPORT ONLY - do not
> edit anything.
>
> Walk every beat and check:
> 1. **Coherence** - does each screen make sense on its own, without the previous one in
>    front of you?
> 2. **Flow & transitions** - do the movement dividers' `connector` lines truly name what
>    the reader just did? Does each beat lead into the next, or is there a jarring jump?
> 3. **Pacing** - does the descent build toward the summit, or sag? Too many similar beats
>    in a row? Right length for a single sitting (~5 min)?
> 4. **Shape not forced** - does the movement structure fit THIS theme, or is a thin
>    movement padded to hit a number? Does the spine metaphor hold from open to close, or
>    does it drift?
> 5. **Interactive close earned** - if the dive has an interactive beat (`release`,
>    `count`, or a new one), does the gesture genuinely embody the theme's meaning, or is
>    it decoration? If it reuses another dive's interactive beat, does the meaning truly
>    transfer?
> 6. **The no-reuse ledger** - compare against the other dive files and design docs
>    provided: flag any verse, narration, scene, figure-moment, or closing dua already
>    used by a shipped dive, UNLESS the design doc explicitly names the echo as
>    deliberate. Flag any use of material a design doc reserved for a future dive.
> 7. **Every beat earns its place** - any beat present only because the pattern has it?
>    Any beat redundant with the orientation or a movement divider? Any spoiler - a
>    payoff/turn pre-announced in an early beat instead of landing where it is felt?
>
> Return a ranked list of issues, most severe first: for each, the beat (tag/index), what
> is wrong, why it hurts the experience, and a suggested direction (do NOT apply it).

## Auditor B - Theology, sourcing & Arabic

> You are fact-checking a new theme "Deep Dive" for a Twelver Shia iOS app, defined in
> `<dive file>` (approved design doc: `<design doc>`, whose sourcing table lists each
> claimed source). REPORT ONLY - do not edit anything.
>
> Check:
> 1. **Shia sourcing** - every narration/dua should trace to a Shia source (al-Kafi,
>    al-Irshad of al-Mufid, al-Sahifa al-Sajjadiyya, Misbah al-Shari'a, Uyun Akhbar
>    al-Rida, al-Amali, or an Ahl al-Bayt narration with a named book). Flag anything
>    unsourced or that reads a Sunni-only interpretation as the Shia reading.
> 2. **Attribution verification** - for each `.narration`/`.response`/`.climax`/`.dua`
>    source line, verify (web search) that the named source exists and plausibly contains
>    the quoted text. Flag any you cannot verify, with what you checked. **Verify at the
>    level of the DETAIL, not the gist**: a beat may narrate an exchange that IS in the
>    cited source while carrying one vivid detail from a different book (the Shukr dive
>    shipped "until his feet swelled" under an al-Kafi citation whose text has only
>    "on the tips of his toes" - the swelling was al-Ihtijaj/Bukhari wording). Check the
>    quoted images word by word against the cited text.
> 3. **Qur'an Arabic - SEMANTIC check, not byte-check.** Theme dives deliberately use
>    plain (non-Uthmani) orthography, so do NOT demand a byte match with
>    `quran_data.json`. Instead, for every `.verse`, `BridgeVerse`, and interactive-beat
>    `arabic:`, read the canonical ayah from `quran_data.json` and confirm the plain-
>    orthography rendering says the same words (no dropped/added/misspelled word, harakat
>    sane). Flag real textual divergences only - not orthography style.
> 4. **Excerpts anchored honestly** - where `arabic:` is a mid-ayah excerpt, confirm
>    `surah:`/`ayah:` point at the right verse and the translation translates the excerpt
>    shown (not the full ayah), and that the cut does not distort meaning.
> 5. **Hadith Arabic** - for Arabic anchors of narrations/duas, confirm the quoted Arabic
>    matches the verified source text from the design doc's sourcing table.
> 6. **Honorifics & register** - the Prophet ﷺ where the style uses it, Imams named with
>    their house style ("Imam Ja'far al-Sadiq"), and English prose free of transliteration
>    diacritics (house rule) - flag violations.
>
> Return a ranked list, most severe first: for each, the beat, the problem, the evidence
> (source checked / expected vs actual), and a suggested correction (do NOT apply it).

## Auditor C - Readability

> You are auditing the READABILITY of a new theme "Deep Dive" for the Thaqalayn iOS app,
> defined in `<dive file>`. REPORT ONLY - do not edit anything.
>
> Read every English string a user sees (open line, orientation, movement dividers, verse
> translations and reflections, narration bodies, the response beat, climax, interactive-
> close prompt/subline/note, dua intro/note/close) as a first-time reader on a phone -
> possibly tired, possibly reading English as a second language. The bar: every sentence
> understood on the FIRST pass, no rereading. (A surah dive was once withdrawn for failing
> exactly this - approved structure, verified sourcing, prose too hard to follow.)
>
> Flag:
> 1. **Sentences that demand rereading** - stacked clauses, asides inside asides, a verb
>    that arrives late.
> 2. **Described-not-shown arguments** - prose that talks ABOUT its point instead of
>    laying it out plainly.
> 3. **Unglossed terms and unnamed references** - a transliterated Arabic term OR an
>    allusion (an unnamed person, place, or revelation-context) carrying a sentence's
>    meaning with no in-text identification. THE BAR IS THE SURFACE OF THE TEXT, never
>    the reader's presumed background: do NOT excuse a finding with "the audience will
>    know" - that exact rationalization let "an orphan who had just been given
>    everything" (the addressee of al-Duha, the Prophet ﷺ) through the Shukr audit as a
>    minor note, and the app's own developer stumbled on it in the simulator. If the text
>    does not name it, it is a ranked finding - a Should-fix, not a footnote. (Movement
>    names introduced on the depths map are fine; so are terms the beat itself glosses.)
> 4. **Walls of text** - a reflection stacking too many ideas for one screen.
> 5. **Rhetorical scaffolding** - literary throat-clearing where saying the thing directly
>    would be clearer. (The house voice IS literary - flag only where the style costs
>    first-pass comprehension, not where it is merely elevated.)
>
> Return a ranked list, hardest-to-read first: for each, the beat, the exact sentence(s),
> why a first-pass reader stumbles, and a suggested plainer rewrite that keeps the full
> meaning (do NOT apply it). Never downgrade a real comprehension gap to a "minor note /
> acceptable" on the strength of assumed audience knowledge - report it ranked and let
> the user decide.

## Auditor D - Voice & reverence

> You are auditing the VOICE and REVERENCE of a new theme "Deep Dive" for the Thaqalayn iOS
> app, a Twelver Shia app, defined in `<dive file>`. REPORT ONLY - do not edit anything.
>
> Read every English string a user sees (open line, orientation, movement dividers, verse
> translations and reflections, narration bodies, the response beat, climax, interactive-
> close prompt/subline/note, dua intro/note/close) and ask ONE question of each line: does
> it carry the dignity that sacred content demands? A sentence can be perfectly clear (that
> is Auditor C's job) and still fail here - crude, casual, or over-familiar in a way that
> ill-fits the Qur'an, Allah, the Prophet ﷺ, or the Ahl al-Bayt (a). This is **register and
> reverence, not comprehension**. (The canonical miss, from a surah dive: "the Ahl al-Bayt
> placed it in your mouth every night" - instantly understood, but bodily and undignified
> for scripture.)
>
> Flag:
> 1. **Undignified or bodily register** - wording a reader understands fine but that reads as
>    crude, flippant, slangy, or physically over-literal about the sacred. Give a rewrite that
>    keeps the meaning with dignity.
> 2. **Over-familiarity with the sacred** - the narrator speaking of Allah, the Prophet ﷺ, or
>    the Imams (a) with a chumminess or breeziness that presumes on the relationship; jokey or
>    throwaway tone around what should be revered.
> 3. **Crude anthropomorphism of God** - describing Allah in bluntly physical or human terms
>    beyond what the tradition's own language warrants. (Auditor B checks doctrinal
>    correctness; you check how it *reads*.)
> 4. **Emotional manipulation / devotional overreach** - prose that tells the reader what they
>    now feel, manufactures a lump in the throat, or claims a spiritual state the beat has not
>    earned. Reverence invites; it does not coerce.
> 5. **Voice inconsistency** - the narrator's register lurching between beats (intimate second
>    person, then dry lecture, then sermon) so it no longer reads as one voice.
>
> Note: honorific PRESENCE (ﷺ / a) and transliteration-diacritic house style are Auditor B's
> job - you check the tone AROUND the sacred, not whether the glyphs are there. Return a
> ranked list, most severe first: for each, the beat (tag/index), the exact sentence(s), why
> the register is wrong for sacred content, and a suggested rewrite that preserves the full
> meaning (do NOT apply it).

---

## Consolidating

Merge all four reports into one list, most severe first:
- **Blocker** - a sourcing/theology error, an unverifiable attribution, a real Arabic
  textual divergence, reserved-material misuse, a spoiler that breaks the descent, or prose
  that is irreverent toward the sacred (crude anthropomorphism of God, a flippant depiction
  of the Prophet ﷺ or Imams).
- **Should-fix** - a ledger collision not named as deliberate, a padded movement, an
  unearned interactive close, a flow/pacing snag, a missing honorific, an unnamed
  reference carrying a beat's meaning, an undignified or over-familiar register for sacred
  content, or copy a first-time reader cannot follow.
- **Polish** - wording, an em dash, a soft transition.

Auditors' own "minor notes / acceptable" items are NOT automatically Polish - re-judge
them during consolidation; an excused comprehension gap belongs in Should-fix.

Present the list plainly and **stop - the user decides what to fix**. Apply only approved
fixes, re-run the build, and note declined findings in the design doc as "known, accepted".
