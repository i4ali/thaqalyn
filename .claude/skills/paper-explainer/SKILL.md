---
name: paper-explainer
description: Produce a papercraft-diorama explainer short (TikTok/Reels/Shorts, 9:16) on any Islamic topic - a verse's story, an event, a dua's origin, a "why do Shia..." question, a surah hook. Stills-first pipeline (local Qwen-Image stills, Nano Banana Pro as paid fallback -> local Wan 2.2 motion for hero shots, free depth-parallax for the rest -> ElevenLabs VO with word timestamps -> reference-style captions -> ffmpeg). Motion is mandatory: every hero shot needs a visible event, gated before assembly. Triggers - "paper explainer", "papercraft video", "Paper Planet style video for X", "make an explainer short about X".
argument-hint: "<topic or hook, e.g. Hud - the surah that grayed him>"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Paper explainer

A guideline, not a template. The reference is the @paperplanet_ TikTok format: one sentence =
one shot = one literal paper prop; dry single voice; no music; a page-to-world opener; a quiet
payoff line; small all-caps captions. Ours swaps sarcasm for wonder and never shows sacred
figures. Adapt freely where the topic needs it - keep the mechanics, not the beats.

Everything the skill needs lives here:

```
scripts/qwen_image.py      stills, LOCAL and free (Qwen-Image-2512 / Edit-2511 via ComfyUI; same CLI as nano_banana)
scripts/workflow_qwen_t2i.json + workflow_qwen_edit.json   the ComfyUI graphs qwen_image.py fills in
scripts/nano_banana.py     stills, PAID fallback (OpenRouter, google/gemini-3-pro-image; ~$0.24 each)
scripts/gen_stills_example.sh  the Hud batch - copy, replace prompts (swap NB= to qwen_image.py)
scripts/vo.py              narration + word timestamps (ElevenLabs; ELEVENLABS_API_KEY)
scripts/run_i2v.py + workflow_i2v_lightning.json   local Wan 2.2 hero motion (ComfyUI)
scripts/parallax.py        free 2.5D depth-parallax clip from a still
scripts/assemble.py        fit shots to VO, captions, mux -> final mp4
scripts/place_models.sh    one-time model placement after download (setup)
assets/style_ref_book.jpg  the series book still, pass as --ref on bookend shots
```
Worked examples: `docs/plans/paper-explainer/hud-episode.md` (the benchmark: this is the level
of motion every episode must reach) and `kawthar-episode.md` (the counterexample: it shipped
with two near-static heroes and was rejected by the user for lack of animation).

## Hard rules

- **No sacred figures.** Never depict the Prophet ﷺ, Ahl al-Bayt, or any prophet - not as a
  silhouette, veiled figure, or hand. Show places, objects, faceless paper crowds/companions,
  words as props. A depiction request is a stop-and-ask. Watch for depiction by implication:
  a lone figure walking out of the sanctuary reads as the Prophet even if the prompt meant
  the mocker (Kawthar s04 had to be retaken).
- **Motion is mandatory.** Animation is what the user is paying attention to; a papercraft
  video that only drifts is a slideshow. Every hero shot must contain a visible EVENT (see
  "Motion" below), at least half the shots are hero, and no hero may be silently downgraded
  to parallax, a camera-only clip, or a trimmed-and-stretched near-still. If a hero's event
  cannot be achieved after the retry budget, STOP and ask (Gate 3). Never assemble a final
  with an unresolved hero.
- **Every factual sentence is sourced before it is recorded.** Prefer material already audited
  in the repo (surah experiences, deep dives). Keep attributions honest (e.g. "Ibn Abbas said",
  not the Prophet's own explanation). Plain English spelling, no diacritics, no em dashes.
- **Pure value, no promotion.** No app end card, no CTA line (user decision 2026-08-27).
- **Approval gates:** (1) script + shot list + motion plan before any spend; (2) stills contact
  sheet before motion; (3) motion audit before assembly. Stills cost ~$0.24 each; motion is
  free but slow.

## Shape (defaults - change with reason)

- 60-90 s, 8-10 shots, 150-200 words at ~150 wpm. Hook in the first line: a concrete surprising
  detail or a question. Each sentence: fact -> consequence -> reframe. The last line is the
  twist that re-reads the whole episode; end on a bookend of shot 1, never on a pitch.
- Shot 1 is page-to-world: an open papercraft mushaf/scroll with the topic's heading in Arabic,
  the scene rising from the page; the last shot returns to it in different light.
- One prop per sentence, made physical: a law -> a shredder, a burden -> a scale, seven stories
  -> seven banners. In-scene Arabic text (banners, cards, spines) does half the work.
- **Design props that can DO something.** Before a prop is locked, name what it does on
  screen: water flows, a wave rolls, a lamp lights, a scroll unrolls, a seedling grows, a
  banner lifts in wind, sand pours, a crowd turns, a page turns, shadows swing as the sun
  moves. A prop whose best motion is "camera drift" (a framed shadow box, a card on a mat, a
  stump in a courtyard) is the wrong prop - re-prop it or give the scene a live element
  (a flame, water, hanging cloth, falling petals) that Wan can animate.
- **Hero count: at least half the shots, minimum 5 of 10.** Opener, bookend, and every
  sentence that names an action or a change are hero by default. Parallax is only for shots
  that are truly static props AND have layered depth (foreground / mid / background); flat
  compositions get no visible parallax and must not be used.
- Style block (prepend to every still prompt): *Handmade papercraft diorama photographed with a
  macro lens, tilt-shift shallow depth of field, soft warm studio light. Everything is cut from
  layered cream, sand and kraft card with visible paper fibre and tiny cast shadows at every
  layer edge. Any figures are simple low-poly paper silhouettes with no faces. Accent palette:
  deep emerald and gold leaf. Vertical composition, dark warm bokeh background.*

## Motion (what "animated" means here)

An EVENT is a state change a viewer can describe in one sentence: "the lights come on", "the
wave rolls in", "the scroll unrolls", "the drop falls and ripples", "the seedling grows into a
tree", "the shadows swing round". A camera move alone is not an event. Hud's four heroes are
the bar: city lights up on the push-in; wave rolls forward while the crowd freezes; low orbit
with long shadows swinging; pull-back with the sun glowing up.

- Motion column in the shot list = the event, written as start-state -> end-state. Gate 1
  approves the events, not just the props.
- Motion prompt = the event first, in plain physical terms, then one camera move with a speed
  word, then the explicit end-state, then "everything else stays perfectly still". Never write
  a camera-only prompt ("nothing in the scene moves") - that is a parallax shot wearing a hero
  badge and is forbidden for heroes.
- What Wan 2.2 Lightning does willingly: camera moves, light coming on / warming, water and
  cloth, things lifting, drifting away, falling, unrolling, growing. What it fights: moving an
  object LEFT onto a target, holding standing cards/pages still (it will scatter, fold or turn
  them), precise placement. Prompt the motion it does willingly and, when the clip runs the
  wrong direction, REVERSE it (`ffmpeg -vf reverse`) - a lift-away reversed is a descent onto.
- Retry budget per hero: up to 3 prompt/seed variations at 480p, then up to 2 at 720p. Each
  variation must change the EVENT wording or the seed, not remove motion. If the event still
  does not appear, change the event (or the still) - do not fall back to camera-only.
- 720p finals do not reproduce their 480p tests (same seed). Frame-sheet every 720p final;
  the event must be present at 720p. Trimming a clip to its clean part is allowed only if the
  full event survives in the kept part and the stretch to the line window is <= 2x. A trimmed
  head stretched 4-5x is a still and fails the gate (Kawthar s01/s10).
- Parallax shots: pick `move` per shot and set `zoom`/`parallax` in shots.json (defaults 0.08 /
  0.035; use 0.14 / 0.06 for deep scenes so the drift is actually visible). The animatic shows
  whether a plx shot moves; if it reads as a still, it becomes hero or gets re-propped.

## Pipeline

1. **Script + shot list** -> `docs/plans/paper-explainer/<topic>-episode.md` (VO lines; table:
   shot / type / scene / in-scene text / EVENT). Count heroes (>= half). Gate 1 (AskUserQuestion).
2. **Stills** - copy `gen_stills_example.sh`, one `gen` call per shot, `--aspect 9:16`,
   `--ref assets/style_ref_book.jpg` on bookend shots only (a book ref on a non-book scene
   renders the scene inside the book). Default generator is the LOCAL `qwen_image.py`
   (free; 928x1664 native, ~1 min/still on the M3 Ultra; up to 3 `--ref` images through
   Qwen-Image-Edit-2511). Use `nano_banana.py` (paid, 4K) only where the local model fails
   the shot - typically Arabic text on props; check every Arabic string on the contact sheet
   at full resolution. Run with `nohup` in its own Bash call, Monitor for `DONE`, then a
   contact sheet. Gate 2.
3. **VO** - `vo.py --lines lines.txt --out <ep>/vo/vo.mp3` (one sentence per line; writes
   `vo.lines.json` / `vo.words.json`). Voice: Bear `yU0EHuTjuZhsJiFqbAVB` (paid key,
   `--key-env ELEVENLABS_API_KEY_OLD`) else Brian `nPczCjzI2devNBz1zQrb`. Send the mp3 to the
   user with the contact sheet; re-record a line if a name is mispronounced.
4. **Hero motion** - downscale the still (480x832 to iterate, 720x1280 for finals), then
   `run_i2v.py --image in.png --prompt "<event>" --out clip.mp4 --width W --height H --length 81`.
   Launch with `nohup ... & disown` in its own Bash call (macOS has no `setsid`; a killed
   background wait takes any child it spawned with it) and Monitor the log. Measured on the M3
   Ultra: 480p ~3-7 min, 720p ~34 min; queue all finals at once, the server keeps the 67 GB of
   weights resident. Frame-sheet every test and every final. Wan sometimes adds its own idea
   (lights coming on); keep it when it serves the line.
5. **Gate 3 - motion audit** (AskUserQuestion, with the hero frame sheets). Table: shot /
   intended event / what the 720p final shows / verdict. Every hero must be "event present";
   every plx must visibly move in the animatic. If any hero fails after the retry budget, stop
   here and offer: re-prop the shot (new still), change the event, or the user's call. Do not
   proceed to the final on your own with a failed hero.
6. **Assemble** - write `<ep>/episode.json` (`title`, optional `endcard`) and `<ep>/shots.json`
   (`id, line, type hero|plx|still, src, still, move, zoom, parallax`), then
   `assemble.py --episode <ep> [--animatic] [--reuse]`. Shots are fitted to the VO line windows
   (hero clips retimed with motion interpolation, plx rendered to exact length); captions are
   ASS, all-caps Avenir Next Condensed Heavy, word reveal, low third; title card over shot 1;
   VO only, loudnorm -16 LUFS; audio cut after the last used line. Build the `--animatic` first
   (all parallax) to check pacing; `--reuse` re-muxes without re-rendering (delete the work
   clips of shots that changed type, or it reuses the parallax stand-in).
7. **Review** - frame sheet of the final; send a small preview (`scale=540:960 -crf 27`; the
   full file is usually over the 30 MB upload limit). Record lessons in the episode doc.

## Setup (once per machine)

ComfyUI at `$COMFYUI_DIR` (default `~/Documents/development/ComfyUI`): clone, `python3.13 -m venv
.venv`, `pip install -r requirements.txt huggingface_hub`. Download from
`Comfy-Org/Wan_2.2_ComfyUI_Repackaged` into `models/_wan_dl`: the two `wan2.2_i2v_*_14B_fp16`
diffusion models, `umt5_xxl_fp16`, `wan_2.1_vae`, both `wan2.2_i2v_lightx2v_4steps_lora_v1_*`
loras (fp16 everywhere - MPS has no fp8), then `scripts/place_models.sh`. Stills: run
`ComfyUI/models/_qwen_dl/download.py` (Qwen-Image-2512 + Edit-2511 bf16, full-precision
`qwen_2.5_vl_7b` text encoder, VAE, Lightning LoRAs; ~101 GB). The ComfyUI server must run with
`--fp16-unet --fp16-vae` (both runners start it that way; `qwen_image.py --restart-server`
fixes a server started without them). `~/Desktop/Model Library.app` lists what is
downloaded. Python deps for the scripts live in the repo `.venv` (torch, transformers,
opencv, Depth Anything downloads on first parallax run).

## Where to think, not follow

The prop and its event for each sentence, which shots deserve real motion (more, not fewer),
the Arabic wording on props, shot count and length for the topic, the hook line, and whether
a topic even suits this format (it wants a concrete story with objects that can move; abstract
theology usually does not). When a script's limitation shows up, improve the script rather
than working around it by hand.
