---
name: doodle-dialogue-video
description: Use when creating a short vertical video where two simple line-doodle characters trade scripted lines (a curious asker + a knowledgeable host) to explain a topic, answer a question, react, or bust a myth — for TikTok/Reels/Shorts. Triggers - "make a doodle dialogue/explainer video", "two-character talking video", "da'wah Q&A short", "turn this story/event/talking-point into a TikTok".
argument-hint: "[topic / story / event / talking-point the video should cover]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Doodle Dialogue Video

Produce a ~15–30s, 9:16 video in the popular "two characters trading lines" format:
flat black-on-white **line-doodle** characters, **2-voice TTS**, big top captions,
optional **talking-mouth** flap, gentle push-in, **no instrumental music**. The
**script is co-designed with the user every time** — this skill is the reusable
production *engine*, not a fixed storyboard.

Human-in-the-loop: AI art and voices need user approval at each costed step. No
silent fallback — surface trade-offs as decisions.

## When to use
- A short scripted exchange between two relatable doodle characters: Q&A,
  myth-vs-fact, did-you-know, reaction, problem→reframe, testimonial.
- Output: TikTok / Reels / Shorts (1080×1920).

Not for: photoreal actors (use `ugc-app-ad`), cinematic film, or accurate phoneme
lip-sync (the mouth flap is amplitude-gated, not viseme-accurate).

## Guardrails (defaults ON — relax only if the user says so)
- **Accuracy + citations** — every factual/scriptural claim is verified and shown
  with a small source line. Prefer shared/agreed sources for a disarming,
  non-divisive tone.
- **No depiction of Prophets, Imams or holy figures** — characters are ordinary
  modern people only.
- **Non-divisive**, respectful framing (a curious friend, not a polemic).
- **No instrumental music** — voices + light SFX (whoosh on cuts) or a vocal bed.
- **Render-safe captions** — burn plain text only: NO emoji, NO `ﷺ` glyph (libass
  tofu risk) — spell `(pbuh)`; always verify on sampled frames.

## Step 1 — Co-design the script (REQUIRED FIRST)
**REQUIRED SUB-SKILL:** superpowers:brainstorming. Drive it with **AskUserQuestion**,
locking one decision at a time:
- **Topic** — the story / event / talking-point (ask for it first if not given).
- **Angle + beats** — pick the structure, then write the ordered **beats** (one line
  each: who speaks + the exact caption/spoken line). Aim 6–8 beats, ~15–25s. Open on
  a hook in the first ~2s.
- **Characters** — A = asker, B = host (keep B as a recurring host across a series);
  age / dress / vibe; any head-covering.
- **Voices** — 2-voice TTS (default), silent+captions, or user-recorded VO.
- **Audio** — voice + light SFX (default) / vocal bed / voice-only. No music.
- **Talking mouths?** — flap (default) or static.
- **Citations** — the exact source for each factual beat (verify before burn-in).
- **Branding** — app/CTA end card? (default: none).

Show the **storyboard** in the brainstorming **visual companion**. Write a short
design doc to `docs/plans/YYYY-MM-DD-<name>-doodle-design.md`.

## Setup (first run)
```bash
source .venv/bin/activate
pip install -r .claude/skills/doodle-dialogue-video/requirements.txt
# .env (auto-loaded by the scripts) needs: OPENROUTER_API_KEY, ELEVENLABS_API_KEY
```

## Step 2 — Production engine
Work under `ads/<name>/{inputs,stills,clips,work}`. Scripts live in this skill's
`scripts/`. **STOP for user approval after every API-cost asset** — show
stills/audio/video in the visual companion (embed as base64 so it renders).

1. **Character refs** — `nano_banana.py` (`OPENROUTER_API_KEY`): one line-doodle ref
   for **A**, then **B** with `--ref <A>` (same style, distinct identity). Style:
   clean uniform BLACK outline, flat WHITE fill, no colour/shading, big simple eyes,
   plain off-white bg, head-and-torso, 9:16. Approve.
2. **Per-beat stills** — for each beat, `nano_banana.py --ref <char>` changing ONLY
   the expression. Then `normalize_doodle_stills.py <stills...> --outdir work/norm`
   (outputs are `norm-` prefixed; `--span-frac/--head-frac` tune size/clearance).
   Every beat then shares identical framing, top third clear for captions. Approve.
3. **(If talking) mouth variants** — for each speaking still, `nano_banana.py --ref
   <still>` "change ONLY the mouth: open wide". For an already-open beat make a
   CLOSED variant (the rest state). Normalize them too.
4. **Voices** — discover IDs with `tts_eleven.py --list` (if the key lacks
   `voices_read` it 401s — use premade IDs, e.g. Will `bIHbv24MWmeRgasZH58o` young,
   George `JBFqnCBsd6RMkjVDRZzb` warm). Then `tts_eleven.py --voice <id> --text "..."
   --output work/audio/line1-A.mp3` per beat (expand `ﷺ`→"peace be upon him", drop
   emoji, natural casing). Approve the audio.
5. **Audio track** — `build_audio.py --out inputs/audio.mp3 --gap 0.4
   work/audio/line1-A.mp3 ... lineN.mp3 [--emphasis <beat#>]`. It pads each line to
   its slot, concats, mixes a whoosh at every cut, and **prints each beat's
   start/end/slot** — those numbers are authoritative: use `slot` for `segments.txt`
   seconds and start/end for caption times. No music.
6. **Talking mouths** — per beat: `doodle_talk.py --base work/norm/norm-<beat>-closed.png
   --open work/norm/norm-<beat>-open.png --audio work/audio/lineN.mp3 --dur <slot>
   --zmax <z> --zinc <r> --no-audio --out work/talk_segN.mp4` (always the `norm-`
   files). It swaps only a feathered mouth box *below* `--ytop-frac` (eyes/brows never
   move) and flaps it on the speech RMS. For a static beat, list the still in step 8.
7. **Captions** — `cp templates/captions.ass.example work/captions.ass`, then fill one
   `Cap` `Dialogue` per beat using the step-5 start/end times, plus a `Cite` line over
   factual beats. It already has the required 10-field `Format:` line and `Cap`/`Cite`
   styles; set the Cite colour to your brand (ASS is BGR: `#E67A3C` → `&H003C7AE6`).
   Render-safe text only.
8. **Assemble** — build `work/segments.txt` (one `file|seconds` per ordered beat — a
   `talk_segN.mp4` or a still `.png`, `seconds` = step-5 slot), then `bash
   doodle_assemble.sh <base>` → normalizes, concats, muxes `inputs/audio.mp3`, burns
   captions → `final.mp4`. **Verify** with ffprobe + sampled frames (captions render
   with no tofu, mouths move, eyes static, framing consistent).

## Parameters
- **Defaults:** gap `0.4`s; `doodle_talk.py` `--zmax 1.10 --zinc 0.0003
  --rms-thresh 0.08 --ytop-frac 0.56`; bigger `--zmax`/faster `--zinc` for a punchy
  reaction beat.
- **Push-in:** `--zinc` is a *per-frame* increment, so to reach `zmax` over the whole
  clip use `--zinc = (zmax - 1) / (dur × 30)`.
- **`--dur`** = the beat's **slot** (line + gap) from step 5.
- **`segments.txt` seconds are authoritative** — `doodle_assemble.sh` trims each beat
  to them, so keep them equal to the step-5 slots (and the caption end-times).

## Reusable engine (scripts/ + templates/)
| File | Role |
|---|---|
| `nano_banana.py` | Character refs + per-beat expression / mouth stills (`--ref` = consistency) |
| `normalize_doodle_stills.py` | Force identical 1080×1920 framing across all stills (`norm-` outputs) |
| `tts_eleven.py` | ElevenLabs 2-voice TTS (`--list`; key may lack `voices_read` → premade IDs) |
| `build_audio.py` | Lines+gaps+whoosh → `inputs/audio.mp3`; prints authoritative beat timing |
| `doodle_talk.py` | Amplitude-gated talking-mouth flap (mouth-only swap; `--ytop-frac` protects eyes) |
| `doodle_assemble.sh` | `segments.txt` → normalized, concatenated, voiced, captioned 1080×1920 MP4 |
| `templates/captions.ass.example` | Copyable ASS skeleton (10-field Format line, Cap/Cite styles) |

Run any script with `--help` (or read its header) for full flags.

## Common mistakes
| Mistake | Fix |
|---|---|
| Skipping script co-design / reusing an old storyboard | Step 1 is required — brainstorm + AskUserQuestion each time |
| Whole character "boils"/wobbles when the mouth moves | Swap ONLY a feathered mouth box (`doodle_talk.py`), never the full frame |
| Eyes / brows flicker while talking | Keep the swap below `--ytop-frac` (mid-face) — eyes always come from the base |
| Characters change size between cuts | Always run `normalize_doodle_stills.py`; point `doodle_talk.py` at the `norm-` files |
| Audio / captions / video drift out of sync | Derive `segments.txt` seconds AND caption times from `build_audio.py`'s printed slots |
| Caption `,0,0,0,,` prefix | Use the template's 10-field ASS `Format:` line |
| Tofu boxes / missing glyphs in captions | No emoji, no `ﷺ` in the burn; spell `(pbuh)`; verify sampled frames |
| `seg6` → `eg6`, mangled filenames | ffmpeg in a `while read` loop needs `-nostdin` (`doodle_assemble.sh` has it) |
| Shell quirks bite | This env runs **zsh**: arrays are 1-indexed, unquoted `$var` does NOT word-split, empty globs error — use explicit args, arrays, temp dirs |
| Reaching for Kling/AI lip-sync | Not needed and doesn't work on flat doodles — use the flap |

## Validated
End-to-end on the Thaqalayn "Why pray on clay?" da'wah Q&A
(`ads/dawah-clay/`, 1080×1920, ~23 s, talking mouths).
