# Stage 5 - the flow audit (flag-only, four agents, two waves)

Run **after** the build is green, for **every** new sūrah. Dispatch **four** subagents
in **two waves**: Auditors A and B together, then Auditors C and D (never more than two at once).
**Dispatch all four auditors on Opus 4.6 (`model: "opus"`).**  All **report only - they do not edit anything.** When all four return, consolidate into
one ranked list and present it; the user decides what to change.

Give each auditor: the sūrah id, the path to `Thaqalayn/Content/Surah<Name>Dive.swift`, and
the approved script at `docs/plans/surah-experience/<id>-script.md`.

---

## Auditor A - Flow, coherence & the learnings

> You are auditing a new "Inside the Sūrah" immersive journey for the Thaqalayn iOS app,
> defined in `<dive file>` (approved script: `<script file>`). Read the whole `sections:`
> array in order and experience it as a user swiping through one screen at a time. REPORT
> ONLY - do not edit.
>
> Walk every beat and check:
> 1. **Coherence** - does each screen make sense on its own? Is anything confusing out of
>    context (like a whole-sūrah map that reads as if it belongs to one movement)?
> 2. **Flow & transitions** - does each beat lead naturally into the next? Do the movement
>    dividers (`.act`) actually connect their `connector` thread to what came before? Any
>    jarring jump?
> 3. **Pacing** - does the descent build, or sag? Too many similar beats in a row? Is any
>    stretch monotonous or too dense? Is the length right for the sūrah?
> 4. **The learnings (hard checks):**
>    - **Spoilers** - is any payoff (a reveal, ḥadīth, divine reply, the sūrah's turn)
>      front-loaded in an early/overview beat instead of unfolding where it is felt?
>    - **Overview placement** - is any `.depths`/map beat sitting inside a movement
>      (`act: 1/2/3`)? It must be `act: 0` at the threshold, or be dropped. Flag it.
>    - **Every beat earns its place** - is any beat present only because the template has
>      it? Any beat redundant with the orientation or a movement divider?
>    - **Template not forced** - does the shape fit THIS sūrah, or is it bent into a
>      three-movement mold that does not suit it?
>    - **Em dashes** - flag every "—" (the app forbids them; must be " - ").
>    - **Listen affordance** - if any beat shows a duʿā/ziyārat's Arabic, is a Listen
>      control expected (repo CLAUDE.md)? Flag if missing.
> Return a ranked list of issues, most severe first: for each, the beat (tag/index), what
> is wrong, why it hurts the experience, and a suggested direction (do NOT apply it).

## Auditor B - Theology, sourcing & Arabic

> You are fact-checking a new "Inside the Sūrah" journey for a Twelver Shia iOS app,
> defined in `<dive file>` (approved script: `<script file>`). REPORT ONLY - do not edit.
>
> Check:
> 1. **Shia sourcing** - every tafsir point / narration should trace to a Shia source
>    (al-Mīzān / Ṭabāṭabāʾī, Tafsīr Nūr al-Thaqalayn, Majmaʿ al-Bayān / Ṭabrisī, al-Kāfī,
>    ʿUyūn Akhbār al-Riḍā, or an Ahl al-Bayt narration). Flag anything unsourced, or that
>    reads as a Sunni-only interpretation presented as the Shia reading. **Named attributions must be correct, not just Shia:** when the prose pins a point on a specific scholar/work ("al-Mīzān notes…", "Ṭabrisī reads…"), confirm that source actually makes THAT specific point, and flag any claim that in fact belongs to a different mufassir - even a fellow Shia one (e.g. the developmental, heard-in-the-womb order-of-faculties reading is Makārim Shīrāzī's in Tafsīr Namūna / al-Amthāl, not al-Mīzān's). The app's own layer2 tafsir (`tafsir_<n>.json`) conflates commentators and over-labels points as al-Mīzān's, so any named attribution echoing it is especially suspect - trace it to the primary source.
> 2. **Honorifics** - the Prophet Muḥammad ﷺ, and ʿalayhi al-salām (or equivalent) for the
>    Imams and prophets. Flag omissions.
> 3. **Narration verification** - for each `.narration`/`.response`/`.climax` source, does
>    the attribution hold up (the named source actually makes THIS specific point, not merely that the source exists and is on-topic)? Flag any you
>    cannot verify, with what you checked.
> 4. **Qur'an Arabic** - run
>    `python3 .claude/skills/inside-the-surah/scripts/pull_arabic.py <all surah:ayah used>`
>    and confirm each `.verse(arabic:)` matches byte-for-byte. Flag any mismatch (usually
>    NFC drift). Sanity-check hand-authored ḥadīth Arabic anchors for correct spelling/diacritics.
> 5. **Translation fidelity** - do the English translations reasonably render the Arabic?
> Return a ranked list of issues, most severe first: location, the problem, the evidence
> (source checked / expected vs actual bytes), and a suggested correction (do NOT apply it).

## Auditor C - Readability

> You are auditing the READABILITY of a new "Inside the Sūrah" journey for the Thaqalayn
> iOS app, defined in `<dive file>` (approved script: `<script file>`). REPORT ONLY - do
> not edit anything.
>
> Read every English string a user sees (open line, orientation, movement dividers, verse
> translations and reflections, narration bodies, climax, reflection prompt, closing) as a
> first-time reader on a phone - possibly tired, possibly reading English as a second
> language. The bar: every sentence understood on the FIRST pass, no rereading, no stopping
> to work out what a sentence means. (The first al-Nisa dive was withdrawn for failing
> exactly this - approved structure, verified sourcing, prose too hard to follow.)
>
> Flag:
> 1. **Sentences that demand rereading** - long or winding sentences, stacked clauses,
>    asides nested inside asides, a verb that arrives late.
> 2. **Described-not-shown arguments** - prose that talks ABOUT its evidence instead of
>    laying the evidence out step by step (quote the words, then say plainly what they mean).
> 3. **Unglossed Arabic terms** - a transliterated term carrying the meaning of a sentence
>    with no instant plain-English gloss.
> 4. **Walls of text** - a reflection stacking several scholarly points or too many ideas
>    for one beat.
> 5. **Rhetorical scaffolding** - literary throat-clearing ("Watch how the verse is built",
>    inverted syntax) where saying the thing directly would be clearer.
>
> Return a ranked list, hardest-to-read first: for each, the beat (tag/index), the exact
> sentence(s), why a first-pass reader stumbles, and a suggested plainer rewrite (do NOT
> apply it). Simple does not mean shallow - every suggestion must keep the full meaning.

## Auditor D - Voice & reverence

> You are auditing the VOICE and REVERENCE of a new "Inside the Sūrah" journey for the
> Thaqalayn iOS app, a Twelver Shia app, defined in `<dive file>` (approved script:
> `<script file>`). REPORT ONLY - do not edit anything.
>
> Read every English string a user sees and ask ONE question of each line: does it carry the
> dignity that sacred content demands? A sentence can be perfectly clear (that is Auditor C's
> job) and still fail here - crude, casual, or over-familiar in a way that ill-fits the Qur'an,
> Allah, the Prophet ﷺ, or the Ahl al-Bayt (a). This is **register and reverence, not
> comprehension**. The phrase "the Ahl al-Bayt placed it in your mouth every night" is the
> canonical miss: instantly understood, but bodily and undignified for scripture.
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
> Note: honorific PRESENCE (ﷺ / a) is Auditor B's job - you check the tone AROUND the sacred,
> not whether the honorific glyph is there. Return a ranked list, most severe first: for each,
> the beat (tag/index), the exact sentence(s), why the register is wrong for sacred content,
> and a suggested rewrite that preserves the full meaning (do NOT apply it).

---

## Consolidating

Merge all four reports into one list, most severe first. Suggested severity bands:
- **Blocker** - a sourcing/theology error, an unverifiable narration presented as fact, an
  Arabic mismatch, a spoiler that breaks the journey, or prose that is irreverent toward the
  sacred (crude anthropomorphism of God, a flippant depiction of the Prophet ﷺ or Imams).
- **Should-fix** - a misplaced overview, a beat that does not earn its place, a flow/pacing
  snag, a missing honorific or Listen control, an undignified or over-familiar register for
  sacred content, or copy a first-time reader cannot follow on the first pass.
- **Polish** - wording, an em dash, a soft transition.

Present the list plainly and let the user pick what to fix. Do not apply fixes as part of
the audit.
