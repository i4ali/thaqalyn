# Stage 5 - the flow audit (flag-only, two agents, one wave)

Run **after** the build is green, for **every** new sūrah. Dispatch **exactly two**
subagents **in a single wave** (never more than two at once). Both **report only - they do
not edit anything.** When both return, consolidate into one ranked list and present it; the
user decides what to change.

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
>    reads as a Sunni-only interpretation presented as the Shia reading.
> 2. **Honorifics** - the Prophet Muḥammad ﷺ, and ʿalayhi al-salām (or equivalent) for the
>    Imams and prophets. Flag omissions.
> 3. **Narration verification** - for each `.narration`/`.response`/`.climax` source, does
>    the attribution hold up (the source exists and plausibly contains it)? Flag any you
>    cannot verify, with what you checked.
> 4. **Qur'an Arabic** - run
>    `python3 .claude/skills/inside-the-surah/scripts/pull_arabic.py <all surah:ayah used>`
>    and confirm each `.verse(arabic:)` matches byte-for-byte. Flag any mismatch (usually
>    NFC drift). Sanity-check hand-authored ḥadīth Arabic anchors for correct spelling/diacritics.
> 5. **Translation fidelity** - do the English translations reasonably render the Arabic?
> Return a ranked list of issues, most severe first: location, the problem, the evidence
> (source checked / expected vs actual bytes), and a suggested correction (do NOT apply it).

---

## Consolidating

Merge both reports into one list, most severe first. Suggested severity bands:
- **Blocker** - a sourcing/theology error, an unverifiable narration presented as fact, an
  Arabic mismatch, or a spoiler that breaks the journey.
- **Should-fix** - a misplaced overview, a beat that does not earn its place, a flow/pacing
  snag, a missing honorific or Listen control.
- **Polish** - wording, an em dash, a soft transition.

Present the list plainly and let the user pick what to fix. Do not apply fixes as part of
the audit.
