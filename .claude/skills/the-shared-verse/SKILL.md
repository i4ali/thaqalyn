---
name: the-shared-verse
description: Create episodes for "The Shared Verse" — a short-form video channel (TikTok, Reels, Shorts) that presents a single Quran verse through both Sunni and Shia interpretive traditions, side by side, framed as shared reverence rather than debate. Use this whenever the user wants to produce content for this channel — drafting an episode script, choosing a verse, writing the two readings with their tafsir sources, previewing or rendering the animated episode video, or planning the channel's hook, flow, captions, bio, or visual identity. Trigger on mentions of The Shared Verse, Sunni and Shia tafsir videos, comparing how two traditions read the same verse, Quran TikTok or Reels episodes, or requests like "make a new episode", "write the script for this verse", or "render the video". Produces a complete six-beat script (hook, verse and English translation, reading A, reading B, payoff, open question), an episode JSON, and a finished chrome-free vertical mp4 with voiceover, following fixed fairness and sourcing rules.
---

# The Shared Verse — episode creator

> **What ships with this skill.** The rules and channel voice are in this document. Alongside it: `episode-template.html` (the animated video — preview *and* render source, one file with a mode toggle), `scripts/` (the render pipeline), `assets/fonts/` (bundled Amiri), and `episodes/` (one JSON per episode). The worked example is **Sūrat al-Māʾidah 5:55**.

## What this channel is

The Shared Verse takes **one Quranic verse** and shows how the **Sunni** and **Shia** traditions each understand it — presented side by side as *shared reverence with genuine nuance*, never as a debate or a "who's right." The entire appeal is the moment a viewer realizes how much depth a single verse holds across two centuries-deep traditions. Everything here exists to make that moment land while staying fair, reverent, and credible to people in both traditions.

The channel is **its own thing, not an advertisement**. Episodes never pitch an app or product — for a comparison channel, the comparison *is* the product, and any sales nudge makes the readings feel like a teaser whose real payoff lives elsewhere. That framing is also what earns trust with both audiences.

## What you produce

When the user wants an episode, deliver:

1. A complete **episode script** following the six-beat flow below — use the *Episode script template* section as the fill-in structure.
2. An **episode JSON** under `episodes/<slug>.json` (verse + translation, the two readings with sources, and the voiceover lines). This is the single source of truth the renderer consumes.
3. A **finished video** — a clean 1080×1920 mp4 with voiceover — via the pipeline (*Rendering the video* below). Optionally show the **in-feed preview** first.

Always run the **fairness + accuracy checklist** before calling an episode done.

## How to build an episode

1. **Pick the verse.** Either the user gives one, or propose two or three candidates. Choose verses with a *genuine, well-documented* interpretive difference — never manufacture a disagreement, and don't exaggerate a small one. Every few episodes, deliberately pick a **unity verse** that both traditions read essentially the same way (see the rotation rule); this keeps the channel from feeling like it exists only to spotlight division.
2. **Get the Arabic right.** Pull the verse in accurate Uthmani script *with* diacritics from a reliable digital mushaf — never retype Arabic from memory, since errors get caught immediately. Record the sūrah name and āyah number.
3. **Draft both readings, fairly and in parallel — researched live, never from memory.** **Before writing either reading, web-search how each tradition's named tafsir actually treats _this specific verse_** (al-islam.org, alim.org, quranx.com, almizan.org, etc.) — do not rely on recollection. Writing from memory is how you manufacture a difference, exaggerate a small one, mislabel a classical-vs-modern split as Sunni-vs-Shia, or attach a narration to the wrong verse. Confirm the interpretation is genuinely tied to this āyah before citing it. For each tradition, write one to three sentences that an adherent would recognize as accurate and fair. Match the two in length and sentence structure. Attach a real tafsir source to each — see the *Sourcing* section for the citation convention and a starter list of works. Verify the references against the primary texts before anything is published.
4. **Write the script** across the six beats, filling the template. Keep the hook, the payoff line, and the closing question in the channel's standard voice (below).
5. **Author the episode JSON** (schema in *Rendering the video*). Each reading's `body` is shown, read aloud, and highlighted word-by-word, so keep the two bodies matched in length (~20–24 words) and write them to read well aloud; diacritics are fine (kept on screen, auto-stripped for TTS).
6. **Preview, then render.** `--preview` opens the in-feed mockup to eyeball the episode; then render the mp4.
7. **Run the checklist.**

## The six-beat flow (~30 seconds)

This skeleton stays identical every episode; only the verse and the two readings change. The structure itself is the retention engine — the hook opens a curiosity gap and the payoff closes it.

**1 · Hook (0–3s)** — *audio:* voiceover. *screen:* the Arabic, glowing.
Standard hook: **"How do two of Islam's great traditions read the same verse? Let's look."**
Always open on the verse's *depth*, never on people disagreeing. A hook like "two Muslims disagree about this" centers division and invites a comment-section fight; "look how much one verse holds" stops the scroll just as well and stays reverent. More openers are in the *Hooks* section.

**2 · Verse + translation (3–9s)** — *audio:* voiceover **names the sūrah and āyah**, then reads the **English translation**. *screen:* Arabic at full size; the translation sits dim and **each word brightens as it is narrated** (neutral parchment — gold/teal stay reserved for the readings), with the sūrah:āyah reference. No commentary yet — let it be reverent.

**3 · Reading A (9–16s)** — *audio:* voiceover. *screen:* the Arabic shrinks to a quiet header; the Reading A panel reveals with its source line, **each word brightening as it's narrated** (current word glows in the tradition's accent — gold/teal). About seven seconds to hear and read.

**4 · Reading B (16–23s)** — *audio:* voiceover. *screen:* the Reading B panel reveals, with identical length, structure, and visual weight to A.

**5 · Payoff (23–27s)** — *audio:* voiceover. *screen:* both panels on screen together, the verse glowing brighter above them. Name what's shared and what differs. Standard line: **"Same words. Different weight."** (spoken always; show it on screen or hide it with `show_payoff_text: false` to let the readings carry the close). This resolves the hook and is the beat people screenshot.

**6 · Open question (27–30s)** — *audio:* voiceover. *screen:* the prompt (optional — `show_closing_text: false` hides it; the voiceover still plays). Standard: **"Which of these two readings resonates with you?"** — spoken as a calm declarative (drop the "?" in `voiceover.question`; keep it on screen via `cta_text`), since TTS reads short standalone questions flat. Drives comments without taking a side.

The runtime **adapts to the voiceover** — each visual beat reveals exactly when its narration clip begins, so total length follows the audio. Keep Readings A and B to ~5–7 seconds of speech each (roughly 18–26 words) to land near 30s; longer readings simply make a longer video.

## Audio rule (important)

The voiceover (for example, ElevenLabs) reads the **English translation and the commentary only**. **Do not generate Arabic Quran recitation.** A synthetic voice "reciting" the sacred text is something many Muslims and scholars consider inappropriate, and for a channel whose whole value is credibility across two traditions it invites exactly the backlash that can define a new account. It also makes every video noticeably longer. The Arabic is **shown on screen, silently** — its visual presence honors the text without voicing it. If the user wants audible recitation, point them to a licensed human qārī recording, not text-to-speech.

The pipeline enforces this structurally: it only ever synthesizes the spoken text fields (hook, the spoken sūrah:āyah reference, translation, the two commentaries, payoff, question). Naming the reference aloud ("Surah al-Maaidah, verse fifty-five") is not the same as reciting it — the `arabic` field is never sent to TTS.

## Non-negotiable rules

These exist because the topic is sensitive: a clumsy frame doesn't just underperform, it can pull hostile attention and define the channel badly. Each rule has a reason.

- **Research the interpretations every time — never write them from memory.** Before drafting, web-search how each side's named tafsir actually reads *this* verse, and confirm any narration is attached to this āyah (not borrowed from another verse). Recalling a difference from memory is how you manufacture one, exaggerate a small one, or mislabel a classical-vs-modern difference as a Sunni-vs-Shia one. If the honest finding is that both traditions read it the same, make it a unity episode.
- **Symmetry is the safety mechanism.** Readings A and B get equal time, parallel sentence structure, mirrored color, and an identical label format. Any asymmetry — one reading longer, warmer, or more detailed — reads as a thumb on the scale. (The renderer prints a warning if the two readings differ in length by more than ~40%.)
- **Color-code consistently: gold = Sunni, teal = Shia. Never red and blue,** which reads as opposition; gold and teal are both warm and reverent, and they converge rather than clash. Full palette in the *Brand & visual identity* section.
- **Rotate which tradition goes first** across episodes so neither becomes the permanent default voice — track the previous episode's order via the `order` field. Also rotate in a **unity episode** every few videos.
- **Describe, don't adjudicate.** Use "this tradition reads it as…" and never "this is what it really means" or "the correct view." The channel never declares a winner, including in the closing question.
- **Don't claim a narration is exclusive to one side when it isn't.** Frequently both traditions mention the same event but draw different conclusions — for example, the occasion-of-revelation for Q5:55 appears in Sunni tafsir as well; the *interpretation* differs, not the existence of the event. Frame differences as interpretation, not as one side "having" a story the other lacks.
- **Cite a real source under each reading,** in the same convention every episode. Sourcing is what makes the channel authoritative rather than reductive, and it gives commenters something concrete to engage instead of dismissing the video as opinion.
- **Voiceover carries the nuance; on-screen text reinforces it.** Don't force the viewer to read everything — the text is support, not a transcript.

## Fairness + accuracy checklist

Run this before finishing any episode:

- Each reading was checked against a **web search for _this_ verse** (not written from memory), and the cited tafsir actually treats the verse this way.
- Both readings are accurate enough that an adherent of each tradition would nod in recognition.
- Readings A and B are matched in length, structure, and visual weight.
- Gold = Sunni, teal = Shia; no red or blue anywhere.
- Each reading carries a real, correctly-named tafsir source, and the references have been verified.
- No verdict language anywhere; the closing question is neutral.
- The Arabic is correct Uthmani script with diacritics, taken from a reliable source.
- The order (who appears first) is rotated relative to the previous episode, and the unity-episode cadence is on track.
- No app or product pitch; no AI-generated Quran recitation.

---

## Rendering the video (pipeline)

The exported video is the **clean 9:16 only** — the cosmic verse, both reading panels, payoff and question, animated, with voiceover. The TikTok-style wrapper in the preview (phone frame, `@thesharedverse` handle, caption, hashtags, "For You" bar, music line) is **demonstration only**; it shows how the clip sits in the feed and is **never part of the export**.

### The one HTML, three modes

`episode-template.html` is both the preview and the render source. A single `seek(t)` timeline function drives everything, so the preview is pixel-faithful to the export. Modes are toggled by URL params:

| Open as | What you get |
|---|---|
| `episode-template.html` | **Demo** — phone frame + all TikTok chrome. Tap to play. For visualizing in-feed. |
| `episode-template.html?render=1` | **Clean** full-bleed 9:16, autoplays. The actual video, chrome-free. |
| `episode-template.html?frame=<ms>` | One exact static frame at `<ms>` — handy for spot-checks. |
| `episode-template.html?capture=1` | Idle render surface the pipeline drives over DevTools: it calls `seek(t)` per frame and screenshots. No autoplay. |

Don't hand-edit the HTML per episode. It reads its content from `window.EPISODE`; the pipeline injects that (plus base64-embedded fonts) into a copy and renders.

**Layout is tuned for the TikTok frame.** Content sits below the top tabs/status bar, the translation is sized to read on a phone, and the cue captions clear the bottom caption/nav strip. The export is the full 1080×1920 (TikTok overlays its own UI on top) — keep any layout edits inside that safe band.

### Episode JSON schema

```jsonc
{
  "slug": "almaidah-5-55",                  // output filename
  "verse_ref": "Sūrat al-Māʾidah · 5:55",
  "arabic": "…Uthmani + diacritics…",       // SHOWN ONLY — never voiced
  "translation": "“…English…”",             // shown on screen AND read aloud (after the reference); each word brightens as it is narrated
  "order": ["sunni", "shia"],               // reveal/stack order — ROTATE each episode
  "readings": {                               // body is SHOWN, read aloud, AND highlighted word-by-word
    "sunni": { "label": "Sunni emphasis",
               "body": "~20–24 words, matched to the other; highlights GOLD as narrated. Diacritics (ʿAlī) stay on screen, auto-stripped for TTS.",
               "source": "Tafsīr Ibn Kathīr · al-Qurṭubī" },
    "shia":  { "label": "Shia emphasis",
               "body": "… matched in length … (highlights TEAL)",
               "source": "al-Mīzān · Majmaʿ al-Bayān" }
  },
  "voiceover": {
    "hook": "How do two of Islam's great traditions read the same verse? Let's look.",
    "reference": "Surah al-Maaidah, verse fifty-five.",  // SPOKEN before the translation; TTS-friendly transliteration
    "payoff": "Same words. Different weight.",
    "question": "Which of these two readings resonates with you"   // the SPOKEN closing — drop the ? for a calm, declarative read
  },
  "cta_text": "Which of these two readings resonates with you?",    // OPTIONAL on-screen closing text (defaults to voiceover.question); put the ? back here for the visible prompt
  "pins": {                                 // OPTIONAL — reuse an approved audio take verbatim instead of re-synthesizing
    "question": "episodes/pins/<slug>__question.mp3"   // hook / payoff / question only (never a highlighted beat)
  },
  "caption_desc": "demo-only feed caption 🌙 <span class=\"tags\">#quran #tafsir #shia #sunni</span>",
  "show_captions": true,                    // burn the short on-screen cue phrases ("First — the Sunni reading", …)
  "show_payoff_text": true,                 // show "Same words. Different weight." on screen (voiceover plays regardless)
  "show_closing_text": true                 // show the closing prompt pill on screen (voiceover plays regardless)
}
```

- **`order` is how you rotate.** `["sunni","shia"]` = Sunni first/on top; `["shia","sunni"]` flips reveal order, stacking, *and* the gold/teal caption cues — all from this one field.
- **One reading text.** Each reading's `body` is shown, narrated, AND highlighted word-by-word — the current word glows in the tradition's accent (gold/teal) — so display = speech. Keep the two bodies matched in length (~20–24 words). Diacritics (`ʿAlī`, `rukūʿ`) stay on screen and are auto-stripped just for TTS, so they pronounce cleanly.
- **Closing line, two parts.** `voiceover.question` is what's **spoken**; the **on-screen** prompt defaults to it but `cta_text` can override it. Best practice: speak it as a calm declarative (no `?` in `voiceover.question`) but show the `?` via `cta_text`. Hide the on-screen prompt entirely with `show_closing_text: false` — the voiceover still plays.
- **Pinned audio (optional).** `pins: { <beat>: <path> }` reuses an approved take verbatim instead of re-synthesizing — for when ElevenLabs variance hands you a take worth locking. Works for `hook`, `payoff`, `question` (beats with no word-highlight); paths are relative to the skill root.

### Run it

```bash
source .venv/bin/activate                                   # needs ELEVENLABS_API_KEY in .env
pip install -r .claude/skills/the-shared-verse/requirements.txt   # first time only
cd .claude/skills/the-shared-verse

# preview the in-feed mockup (opens in browser, no render, no API cost)
python scripts/render_episode.py episodes/almaidah-5-55.json --preview

# render the finished mp4  ->  <project-root>/the_shared_verse/<slug>.mp4
python scripts/render_episode.py episodes/almaidah-5-55.json
python scripts/render_episode.py episodes/almaidah-5-55.json --fps 30 --workers 14
```

### How it works (pipeline stages)

1. **TTS** the six beats with ElevenLabs ("George", `eleven_multilingual_v2`) — the spoken sūrah:āyah, translation, and commentary only (never the Arabic). The verse beat **and both readings** use the **timestamped** endpoint so their words highlight in sync; each speaks the same text shown on screen (the readings are auto-normalized for clean pronunciation while staying elegant on screen), so the words line up exactly.
2. **Measure** each clip; compute **audio-driven** beat start times (each visual beat reveals when its narration starts; ~0.35s gaps between).
3. **Assemble** the narration track (each clip placed at its beat time).
4. **Build** a self-contained render HTML — inject `window.EPISODE`, base64-embed the bundled Amiri (so capture needs no network).
5. **Capture** every frame by driving a few **warm** headless-Chrome instances over the DevTools Protocol (`scripts/capture_cdp.py`): each loads `?capture=1` once, then `seek(t)` + screenshots per frame. The animation is a pure function of `t` (inline styles, no CSS transitions), so frames are deterministic; reusing a warm browser is far faster than a cold `--screenshot` per frame.
6. **Compose** with ffmpeg → 1080×1920 H.264/AAC mp4.

No fallbacks anywhere: any failed step raises a clear error. Output lands in `the_shared_verse/<slug>.mp4`.

### Posting

The mp4 is bare on purpose. Post it natively to TikTok/Reels/Shorts and let the platform add its own UI; write the caption/hashtags in the post (start from `caption_desc`). Do **not** burn the handle or hashtags into the video.

---

## Brand & visual identity

The goal across everything: signal **shared reverence with nuance**, and stay away from anything that tilts toward one tradition or reads as a fight.

### Name
**The Shared Verse.** Leans into common ground (one Quran, held by both) while "verse" keeps the focus on the text rather than on the communities arguing about it. Keep it app-neutral. Handle: **@thesharedverse** (confirm availability on each platform).

### Bio
Primary (fits the 80-character TikTok limit):
> One Quran, two traditions — every verse through Shia & Sunni eyes 📖

It leads with unity, names both traditions plainly, and "through … eyes" signals *perspective*, not verdict.

### Color palette

| Token | Hex | Use |
|---|---|---|
| Void navy | `#07101f` | Background base (cosmic night) |
| Deep teal | `#0a2e2c` | Background gradient / shadow |
| Gold | `#e3c281` | **Sunni** accent + sacred light/glow |
| Teal | `#45c4b8` | **Shia** accent |
| Parchment | `#f4ecd8` | Warm white for text |

**The color-coding rule is load-bearing: gold = Sunni, teal = Shia, every episode.** Never red and blue — that reads as opposition and "teams." Keep the two accents at equal saturation and prominence so neither dominates.

### Typography
- **Sacred / Arabic text and pull-quotes:** a true naskh face — **Amiri** (designed for Quranic text), bundled in `assets/fonts/`. The verse, translation, and synthesis line use it.
- **UI, labels, captions:** a clean sans. The separation — naskh for the revelation, sans for the "packaging" — quietly reinforces reverence.

### Logo / avatar motif
The thesis in one image: **two elements converging on one source of light.** Light is the safe unifying motif (the Āyah of Light) and avoids sect-specific iconography. A single open book or lamp emitting golden light at the center, two symmetrical arabesque arches mirroring each other and curving inward toward it, over a deep emerald/teal cosmic field; flat vector with a gentle glow.

Image-generation prompt that works:
> A minimalist circular emblem for an Islamic education channel. At the center, a single open book emitting soft radiant golden light. Two symmetrical arabesque arches mirror each other on the left and right, curving inward as if converging on the book. Fine gold Islamic geometric linework radiates outward against a deep emerald and teal background. Calm, reverent, perfectly balanced composition. Absolutely no human, figural, or animal imagery. Flat vector style with a subtle gradient and gentle glow, centered, high detail, designed to stay legible as a small profile icon. 1:1 aspect ratio.

Practical notes: keep the "no figural imagery" instruction in regardless of generator (many sneak in hands or faces); the avatar must read at a tiny circular crop, so don't bake text into the image — overlay the name separately; for a banner, ask for a 16:9 composition with negative space for text.

### Imagery rules
- **No human, figural, or animal imagery** — keeps the channel broadly acceptable and avoids depiction sensitivities.
- **No sect-specific iconography** that would tilt the brand toward one tradition.
- **Light, geometry, and calligraphy are the safe vocabulary.** Cosmic/night backgrounds with gold light read as reverent and neutral.
- Keep the two accent colors balanced in any composition — equal weight signals equal respect.

---

## Hooks

**Principle:** open on the verse's *depth* or a striking textual detail — never on people, sects, or disagreement. The curiosity gap is what stops the scroll; pointing it at the richness of the text gets the same retention as a combative hook without the hostility.

**Standard hook (works for almost any episode):**
> How do two of Islam's great traditions read the same verse? Let's look.

**Bank of alternatives in the same spirit:**
- The same words — two centuries-deep ways of understanding them.
- One verse. Two traditions. Here's what each one sees in it.
- Two of Islam's great traditions. One verse they both hold close.

**Strongest variant when the verse allows it — the textual-detail hook:**
> There's one phrase in this verse that's been reflected on for over a thousand years…

This is the most scroll-stopping, but it's verse-specific (only works when there really is a single pivotal phrase), so it won't fit every episode the way the standard hook does.

**Closing question** (beat 6): keep it neutral and discussion-driving — "Which of these two readings resonates with you?" Never "which is correct."

---

## Sourcing

Citing a real source under each reading is what makes the channel authoritative rather than reductive. Pick **one convention and keep it identical every episode** — it becomes part of the channel's signature. Recommended: **one source per side**, naming the work (and ideally the scholar); optionally pair a classical work with a modern one per side. Display format used in the mockup:

- Sunni → *Tafsīr Ibn Kathīr · al-Qurṭubī*
- Shia → *al-Mīzān (Ṭabāṭabāʾī) · Majmaʿ al-Bayān*

**Starter list of major tafsir works** (recognizable, mainstream anchors — always confirm the work actually treats the verse the way you're attributing before publishing):

*Sunni:* al-Ṭabarī (*Jāmiʿ al-Bayān*) · al-Qurṭubī (*al-Jāmiʿ li-Aḥkām al-Qurʾān*) · Ibn Kathīr (*Tafsīr al-Qurʾān al-ʿAẓīm*) · al-Rāzī (*Mafātīḥ al-Ghayb*) · al-Zamakhsharī (*al-Kashshāf*)

*Shia:* al-Ṭabrisī (*Majmaʿ al-Bayān*) · al-Ṭūsī (*al-Tibyān*) · al-Ṭabāṭabāʾī (*al-Mīzān*, modern) · al-Qummī (*Tafsīr al-Qummī*) · al-ʿAyyāshī (*Tafsīr al-ʿAyyāshī*)

**Accuracy reminders:**
- **Verify before publishing.** Attributions of a specific interpretation to a specific work are easy to get subtly wrong.
- **Reporting a narration is not the same as endorsing a conclusion.** Several Sunni mufassirūn *report* narrations that Shia tafsir builds doctrine on (the Q5:55 ring narration is the classic case) without drawing the same conclusion. "This event only appears in Shia sources" is usually false — the difference is the *interpretation*.

---

## Episode script template

Copy this and fill the bracketed slots. Keep the hook, payoff line, and closing question in the standard voice unless you have a reason to vary. Runtime target ~30s. Mirror these fields into the episode JSON.

```
Episode #: [n]
Verse: [Sūrah name] [chapter:āyah]
Type: [comparison | unity]
Order this episode: [Sunni first | Shia first]   ← rotate vs. last episode (set "order" in the JSON)
Previous episode order: [for your tracking]

BEAT 1 · Hook (0–3s)
  VO: "How do two of Islam's great traditions read the same verse? Let's look."
  Screen: the Arabic, glowing. (Do not name the verse yet.)

BEAT 2 · Verse + translation (3–9s)
  VO: "[Sūrah name], verse [n]." — then reads the English translation: "[English translation]"
  Screen: [Arabic, Uthmani + diacritics] · "[English translation]" · [Sūrah:āyah]

BEAT 3 · Reading A (9–16s)
  Tradition: [Sunni | Shia]   ·   accent: [gold | teal]
  VO: "[1–3 sentences, fair and recognizable to an adherent]"
  Panel — Label: [SUNNI EMPHASIS | SHIA EMPHASIS] · Body: "[same, condensed]" · Source: [Tafsīr …]
  (Arabic shrinks to a header here.)

BEAT 4 · Reading B (16–23s)
  Tradition: [the other]   ·   accent: [the other color]
  VO: "[1–3 sentences, matched in length + structure to A]"
  Panel — Label: [the other] · Body: "[same, condensed]" · Source: [Tafsīr …]

BEAT 5 · Payoff (23–27s)
  VO: "Same words. Different weight."  (or a verse-specific line)
  Screen: both panels together, verse glowing above.

BEAT 6 · Open question (27–30s)
  VO: "Which of these two readings resonates with you"   (spoken; no "?")
  Screen: "Which of these two readings resonates with you?"  (cta_text; optional — hide with show_closing_text:false)

Caption: [short line] 🌙 #quran #tafsir #shia #sunni   (no app/product pitch; written in the post, not burned in)
```

---

## The mockup / render template

The animated phone mockup that used to live inline here is now the standalone, fully-wired **`episode-template.html`** described in *Rendering the video*. It is the single source for both the in-feed preview and the exported frames, so there is no second copy to keep in sync. Open it directly to see the format, add `?render=1` for the clean export view, or run the pipeline to produce the mp4.
