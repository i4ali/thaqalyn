# Beat vocabulary - `DeepDiveSection` cases

Defined in `Thaqalayn/Models/DeepDive.swift`; rendered by `Thaqalayn/Views/DeepDive/DeepDiveView.swift`.
A dive is `DeepDive(id, titleEn, titleAr, subtitle, sfSymbol, estMinutes, acts:[ActInfo], sections:[DeepDiveSection])`.
`ActInfo(number, ar, tr, name)` names each movement. English-first: all `LocalizedText`
fields accept bare String literals.

## The `act:` number = where a beat sits (and its label)

`act:` is NOT decorative - it drives the "Movement N · Name" place-bar label and the depth dots:
- **0** - opening / threshold. `open` and `orientation` are always 0. **A `.depths` overview
  you place at the threshold MUST be `act: 0`** so it renders with no movement label.
- **1, 2, 3** - the movements. `verse`, `act`, `narration`, `response`, `climax`, `depths`
  with these values get a "Movement N" label and fill N depth dots.
- **4** - the close. `reflectionPrompt`, `dua`, `closing` are always 4.

There is no rule that a dive must use 1-2-3. One long movement, or four, or a two-movement
sūrah, are all fine - `acts:` just lists whatever movements you define.

## The cases

| Case | Signature (fields) | Renders as | Use for |
|---|---|---|---|
| `.open` | `kicker, titleAr, titleEn, subtitle, line` | Big Arabic title + English title + one framing line; "Descend" cue | Always the first beat. The cover. |
| `.orientation` | `eyebrow, promise, leaveWith` | "Before you begin": a promise + how-it-works hints + what you'll leave with | Always second. Sets expectation. Keep the promise from duplicating any threshold map. |
| `.act` | `act, connector?, line, bridge: BridgeVerse?` | A movement-divider card. `connector` names the thread back to the prior movement | Open each movement. `connector` = nil for movement 1. `bridge` optional. |
| `.verse` | `act, tag, surah, ayah, arabic, translation, reference, reflection` | Arabic (verbatim) + translation + reflection + "Hear it recited" recitation button | The backbone. One per quoted āyah. `reflection` is the reading content. |
| `.narration` | `act, tag, source, body, reflection` | A centered serif ḥadīth/story block + source + reflection | A ḥadīth or narrative aside that is a *story*, not a reply. |
| `.response` | `act, replyingTo, arabic, words, source, reflection` | "HE ANSWERS": a descending thread of light, the replying-to line, a glowing Arabic anchor + the divine words + source + tie-back | Call-and-response reveals (God answering a line, a divine reply). Built for al-Fātiḥa's division ḥadīth - reuse when a sūrah has a reply/answer motif. Unfold **in-flow**, never as an up-front list. |
| `.depths` | `act, tag, reference, items:[Depth]` | A titled "map" with tap-to-open cards. `Depth(ar, tr, label, desc, reference?, embodies)` | An at-a-glance three(ish)-fold overview. **Optional and often wrong.** Only if it earns its place (usually narrative sūrahs). If used, `act: 0` at the threshold. Never put the payoff/spoiler in it. |
| `.climax` | `act, tag, source, arabic, translation, body, reflection` | A build-up `body` → a large glowing Arabic verse → translation → source → reflection | The sūrah's peak reveal, if it has one. Not mandatory. |
| `.reflectionPrompt` | `tag, prompt, placeholder, subline, nextLabel` | A journaling prompt with a text field | Near the end, "The Return". Invites the user to name their takeaway. |
| `.dua` | `tag, intro, arabic, translation, source, note, close` | A devotional duʿā to close on | Devotional close (Yaqīn/Sabr). If it shows a duʿā's Arabic, confirm the Listen-affordance rule in repo `CLAUDE.md` with the user. |
| `.closing` | `tag, titleAr, essence, line` | A final essence line that hands off to reading the full sūrah | The standard close for a *sūrah* experience (al-Fātiḥa, Yūsuf). Prefer this over `.dua` unless the sūrah wants a devotional ending. |

`BridgeVerse(surah, ayah, arabic, translation, reference)` - an optional second verse a
movement divider can carry.

## Shape patterns seen in the existing dives (for range, not obligation)

- **al-Fātiḥa** - a *conversation*: praise → turn → petition, with `.response` reveals of
  God's reply after each part, and a `.climax` where the next sūrah answers the plea. No map.
- **Yūsuf** - a *narrative arc*: threshold `.depths` map (Well → Prison → Reunion) → three
  movements of the story → climax → close.
- **Yaqīn / Sabr** - a *ladder*: threshold `.depths` naming three ascending stations, each
  embodied by one movement.

Your sūrah may match none of these. Invent the shape it needs; use these only to see what
the beats can do.
