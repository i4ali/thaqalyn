---
name: shia-event-video-creator
description: Create Shia Islamic short-form videos (TikTok, Reels, Shorts) depicting events from the lives of Prophet Muhammad ﷺ and the Ahlul Bayt (عليهم السلام). Use this skill whenever the user wants to produce a religious video for Al-Thaqalayn or similar Shia content, generate scenes for events like Ghadeer, Karbala, Mubahala, Laylat al-Mabit, or Khaybar, create veiled-face religious imagery, or run the full pipeline from event name → scene breakdown → AI images (Nano Banana / ChatGPT Image) → AI video (Kling). Trigger on phrases like "make a TikTok for Ghadeer", "video about Ashura", "generate scenes for Mubahala", "Al-Thaqalayn video", or any request that pairs a Shia Islamic event with short-form video creation.
---

# Shia Event Video Creator

A staged, interactive pipeline for creating religious short-form videos. The workflow is:

**Event + model research → Scene breakdown → Image prompts → Images (Nano Banana Pro via OpenRouter) → Motion prompts → Videos (Kling, default 3.0 via kie.ai) → Narration (ElevenLabs) → Single-pass stitch → TikTok package**

Do not skip ahead. Each stage requires the user's approval before moving to the next, because religious accuracy and visual consistency matter more than speed.

## Onboarding / security note

Before the first run, verify `.env` has these keys (see "API setup" below). **Do not paste
API keys into the chat** — put them directly in `.env`. If a user has already exposed
a key in conversation, recommend rotating it.

## The non-negotiable visual rule

Shia tradition does not depict the faces of the Prophet Muhammad ﷺ, the twelve Imams (عليهم السلام), Lady Fatima (س), or the Prophets. In every single image and video prompt, faces of these figures must be **completely covered by a perfectly solid, fully opaque, intensely bright sphere of warm white-gold light, like a small sun where the face would be** — features fully hidden, only the silhouette, hair covering, beard outline, and body visible. This is how the user's existing Al-Thaqalayn content is styled (see the reference image the user shared). See `references/prompt_templates.md` for the full hardened halo language; it is the production default because it survives image-to-video animation.

Companions and ordinary crowd members (Sahaba, enemies, bystanders) may have visible faces — but be conservative: when in doubt, veil.

This rule is enforced in every prompt the skill emits. Never produce a prompt that allows facial features on a sacred figure, even if the user asks.

## Workflow

### Stage 0 — Capture the event AND lock in the video model

The user says something like "make a video for Ghadeer" or "do a Mubahala one." Before anything else:

1. **Ask which video model they want to use.** This shapes every downstream prompt. Default options to offer:
   - **Kling 3.0 (`v3-0-pro` via kie.ai)** — recommended default. Has built-in **Subject Binding** which dramatically reduces halo drift on veiled sacred figures across camera moves. ELO #1 model as of April 2026. Costs more but is the production-tested path.
   - Kling 2.6 / 2.6 Motion Control — middle ground.
   - Kling 2.1 Master — older flagship, cheaper, less reliable on halos under camera motion.
   Don't decide for them — ask, default to v3-0-pro if they say "you pick."

2. **Web-research the chosen model's prompt guide BEFORE writing any prompts.** This step is non-negotiable — see `references/video_model_research.md` for what to extract. Each Kling version has different conventions (word-count caps, magic phrases like "Locked-off tripod shot," whether negative prompts are supported, what triggers face-rendering, etc.). Save findings inline in the conversation so Stages 2 and 4 can reference them without losing context.

3. If the event is in `references/events.md`, pull the pre-researched narrative beats, date (Hijri + Gregorian), key figures, and typical imagery from there.

4. If it's not, write a short researched summary (3–5 sentences) from Shia sources (Nahj al-Balagha, al-Kafi, Bihar al-Anwar, al-Irshad, Kitab Sulaym ibn Qays, etc.), identify key figures, and propose it to the user for confirmation before proceeding.

5. Confirm the emotional tone (triumphant for Ghadeer/Mubahala, solemn for Ashura, intimate for Laylat al-Mabit, etc.)

6. Propose a scene count based on narrative complexity — usually 4–8 scenes at ~5s each. Simple events (Laylat al-Mabit) need fewer; multi-act events (Karbala) need more.

Present back as a short confirmation card listing: chosen model + key prompt-guide rules + event summary + tone + scene count. Wait for approval.

### Stage 1 — Scene breakdown

Generate the proposed scenes. Each scene needs:

- **Title** — short, e.g., "The Raising of the Hand"
- **Beat** — what happens in this scene (1 sentence)
- **Setting** — location, time of day, weather, landscape
- **Figures** — who is present, which ones have veiled faces
- **Symbolic elements** — banners, color palette, objects (e.g., Dhul-Fiqar, black flag, green flag, Quran, water skin)
- **Camera** — composition suggestion (wide establishing, medium two-shot, low-angle hero, etc.)

Output as a numbered list so the user can reference scenes by number ("redo scene 3"). Wait for approval before generating images. Revise freely.

See `references/style_guide.md` for the locked aesthetic and `references/religious_accuracy.md` for doctrinal guardrails.

### Stage 2 — Image prompts and generation

Once scenes are approved:

1. For each scene, construct a **detailed image generation prompt** using the template in `references/prompt_templates.md`. Every prompt includes:
   - The locked style preamble (golden hour, oil-painting cinematic, 7th century Arabia, 9:16)
   - The veiled-faces instruction for sacred figures (mandatory) — use the **hardened halo language** from `references/prompt_templates.md` ("perfectly solid, fully opaque, intensely bright sphere of warm white-gold light positioned IN FRONT OF the face") not the soft "halo of light" phrasing. The hardened version is what survives image-to-video animation.
   - Scene-specific content
   - **Explicit "no text in image" clause** — Nano Banana sometimes bakes Arabic/English text into the sky area. Always negative-prompt this (the user wants to add overlay text in CapCut, not have it rendered).
   - Negative prompt (no faces on sacred figures, no modern elements, no text artifacts)

2. Call the image API. **Default to `--provider openrouter`** (uses Nano Banana Pro
   = `google/gemini-3-pro-image-preview` via the same OpenRouter key the user already
   has for verse-art generation). Fall back to `nano-banana-pro` (direct Gemini) or
   `chatgpt` only if OpenRouter is unavailable.

   ```bash
   python scripts/generate_image.py \
     --scene-num 1 \
     --prompt "$(cat video_output/<event>/prompts/scene_1.txt)" \
     --output video_output/<event>/images/scene_1.png \
     --provider openrouter \
     --aspect 9:16
   ```

3. Save all images to a single output directory (e.g., `video_output/<event>/images/`). Use consistent naming: `scene_1.png`, `scene_2.png`, etc.

4. Present all images to the user for review before moving to video.

### Stage 3 — Image review loop

The user will either approve everything or flag specific scenes. For each flagged scene:

- Ask what specifically is wrong (face not veiled enough? wrong period clothing? wrong person in frame? composition?)
- Regenerate with an adjusted prompt. Nano Banana/Gemini responds well to iterative edits if you feed the existing image back with a delta instruction ("same scene, but move the banner to the left and make the light softer").
- Loop until the user approves all scenes.

Do not proceed to video until every image is approved. A bad image becomes a bad 5-second video, and Kling generations are slow + expensive.

### Stage 4 — Video prompts and Kling generation

For each approved image:

1. **Pull up the model-specific prompt-guide cheat sheet from Stage 0.** Different Kling versions have different word-count limits, magic phrases, and what-not-to-mention rules. Apply them — don't write generic motion prompts. See `references/video_model_research.md`.

2. Write a **Kling image-to-video prompt** using the template in `references/prompt_templates.md`. Motion should be **subtle and reverent** — this is not an action movie. Good motion for religious content:
   - Slow camera push-in on the sacred figure
   - Gentle wind in robes and flags
   - Soft particulate light (dust motes, shimmering heat)
   - Crowd sway without individual distinct movement
   - Sunset rays shifting slowly
   - Bad motion: anyone turning their head toward camera (risks revealing face), lip-sync attempts, fast pans, anything that "characterizes" a sacred figure

   **Critical rules** (apply regardless of model):
   - **Never** mention "halo", "glow", "veil", "radiant", "face", or sacred-figure names ("Prophet", "Imam", "Ali", "Fatima") in the motion prompt. Mentioning them invites Kling to *animate* or *modify* those regions. Describe sacred figures by physical appearance only ("the figure with the bright sphere of light", "the figure on the trench bridge").
   - For static climactic scenes, lead with the model's documented **"locked-off tripod" magic phrase** (Kling 3.0: `"Locked-off tripod shot, completely static camera."`). Don't combine camera moves with locked subjects — pick one.
   - Keep prompts within the model's documented word limit (Kling 3.0: ~15-40 words). Longer prompts overload the motion model and it adds spurious motion.

3. Call Kling. **Use the project's `scripts/kie_kling.py`** — NOT this skill's generic `scripts/generate_video.py`. Reasons:
   - kie.ai is the production-tested path; the skill's generic script auto-resolver picks the wrong (often out-of-credit) official Kling JWT path when both auth methods are set in `.env`.
   - kie.ai supports Kling 3.0 + 2.6 + Motion Control — the skill's generic doesn't.
   - Kling 3.0's payload shape differs (`image_urls` array, required `mode`/`sound`/`multi_shots` fields) and `kie_kling.py` handles it correctly.

   **Default `--mode v3-0-pro`** (Kling 3.0 Pro, 1080p) for veiled-figure scenes — Subject Binding holds halos through camera moves dramatically better than v2.1 master. Duration 5s default, up to 15s for climactic scenes (Kling 3.0 supports 3-15s). For older v2.1: only 5s and 10s allowed.

   ```bash
   python scripts/kie_kling.py \
     --image video_output/<event>/images/scene_1.png \
     --prompt "$(cat video_output/<event>/prompts/motion_1.txt)" \
     --duration 5 \
     --mode v3-0-pro \
     --output video_output/<event>/videos/scene_1.mp4
   ```

   **For locked-end-frame mode** (mathematically prevents halo/lighting drift by forcing Kling to interpolate between two identical endpoints), pass `--lock-end-frame`. Use this for any scene where halo intensity must stay constant.

4. Kling is async. The script handles submit → poll → download. Expect 1–5 minutes per clip on Kling 3.0. If generating 6+ scenes, submit them **in parallel** by running multiple script invocations in the background, then wait for all to finish.

5. **Save all clips immediately.** Kling's result URLs expire in 24 hours. The script downloads them to disk, but if the user wants to regenerate anything later, we need local copies.

6. Present all videos to the user for review.

### Stage 4b — Halo-drift recovery

The #1 quality problem with AI image-to-video on veiled figures is the halo fading,
drifting, or being repositioned during the clip — revealing features underneath. Order
of attempts when a scene's halo drifts:

1. **Regenerate Kling with a different seed.** Just re-submit — Kling uses a different random seed each attempt.
2. **Simplify the motion prompt further.** Strip every mention of the halo, veil, glow, or the figure's name. Cut camera motion if the prompt also locks the subject (the contradiction is what causes drift). See `references/prompt_templates.md` for hard rules.
3. **Upgrade to Kling 3.0** (`--mode v3-0-pro` via `kie_kling.py`) if you were on v2.x. Subject Binding is purpose-built for this problem.
4. **Add `--lock-end-frame`** so Kling interpolates between two identical endpoints (mathematically prevents lighting drift).
5. **Regenerate the SOURCE IMAGE** with a more solid halo (not translucent) — use the **hardened halo language** in `references/prompt_templates.md`. If the figure is in profile, ensure the halo is described as IN FRONT of the visible face, not behind the head.
6. **FFmpeg face-overlay patch** — if a specific frame range still exposes the face, generate a soft white-gold radial gradient PNG (PIL) and composite it at the face position with `ffmpeg overlay`. Locked-off cameras give consistent face positions, so a single static overlay across the clip works. Non-destructive (always keep `backups/scene_N_orig.mp4`). See `references/prompt_templates.md` for the recipe.
7. **Ken Burns fallback** — skip Kling entirely for that scene, apply an FFmpeg slow-zoom to the still PNG:
   ```bash
   python scripts/ken_burns.py \
     --image video_output/<event>/images/scene_1.png \
     --output video_output/<event>/videos/scene_1.mp4 \
     --duration 5.0 --zoom-to 1.18
   ```
   Zero risk of halo drift because there's no AI animation — just FFmpeg zoompan on the still image. Perfectly acceptable for opening/closing shots and often preferred for reflective content.

### Stage 5 — Narration (ElevenLabs)

Write per-scene narration into `video_output/<event>/narration.json`:

```json
[
  {"scene": 1, "text": "For years, Abu Talib was the shield of the Prophet."},
  {"scene": 2, "text": "When illness came, the Prophet would not leave his side."}
]
```

Generate MP3s:

```bash
python scripts/generate_narration.py --event-dir video_output/<event>/
```

Keep narration lines shorter than the scene video (1–2 short sentences, ~10–12 English
words each). Salawat like ﷺ read awkwardly in TTS — put them in on-screen text overlay
instead. See `references/prompt_templates.md` for narration tone rules.

### Stage 6 — Stitch (single-pass ffmpeg)

Combine scene clips + narrations into one final MP4:

```bash
python scripts/stitch_video.py --event-dir video_output/<event>/ --output final.mp4
```

The script auto-detects however many scenes you have, computes per-scene duration as
`max(video, narration)`, freeze-frame-pads video when narration is longer, silence-pads
audio when video is longer, and builds a single ffmpeg pass to avoid AAC priming drift.

Use `--no-audio` for a silent stitch if you want to add audio in CapCut later.

### Stage 7 — TikTok package

After the final MP4 is stitched, produce the post-production package the user asked for:

1. **TikTok caption** — 1–3 lines, emotionally appropriate to the event, with salawat (ﷺ, عليه السلام) correctly placed. Include the Hijri date. For Ghadeer: joyful. For Ashura: grieving. For Mubahala: triumphant. Match the tone of the Al-Thaqalayn existing caption from the reference ("The Event of Ghadeer Kum On the 18th of Dhul Hijjah...").

2. **Hashtags** — mix of Shia community tags and broader Islamic tags. Always include:
   - Event-specific: `#Ghadeer #EidAlGhadeer` or `#Karbala #Ashura #Muharram` etc.
   - Identity: `#Shia #ShiaIslam #AhlulBayt #Shia313`
   - Discovery: `#Islam #Muslim #IslamicHistory`
   - Brand: `#AlThaqalayn`
   
   Cap at ~12 hashtags. TikTok's algorithm rewards relevance over count.

3. **Background audio suggestions** — 2–3 specific recommendations. Different events call for different audio:
   - **Ghadeer / Eid events** → joyful nasheed (Arabic or Urdu), `Ali Ali Ali Maula` tracks, Nasir al-Qatari style
   - **Ashura / Muharram / Arbaeen** → latmiyya (Basim al-Karbalai, Mahmoud Karimi, Farsi noha), slow majlis-style dirges
   - **Mawlid / birth anniversaries** → mawlid nasheed, salawat chains
   - **Hijrah / night scenes** → soft Arabic instrumental, Qari recitation of relevant ayah
   
   Where relevant, suggest a specific Quranic ayah for recitation overlay (e.g., Ghadeer → Surah al-Maidah 5:67 "Ya ayyuha al-Rasul balligh..."; Mubahala → 3:61).

4. **Assembly notes** — suggested ordering (usually chronological), cut points, where text overlays should appear (event name at scene 1, key hadith at climax, date at end).

Deliver the full package as a markdown file the user can copy.

## Outputs directory convention

Always organize outputs like this (relative to the project root):

```
video_output/<event-slug>/
├── scenes.md              # The approved scene breakdown
├── narration.json         # Per-scene narration script (Stage 5)
├── prompts/
│   ├── scene_1.txt        # Image prompts
│   ├── motion_1.txt       # Kling motion prompts
│   └── ...
├── images/
│   ├── scene_1.png
│   └── ...
├── videos/
│   ├── scene_1.mp4        # Silent Kling (or Ken Burns) clips
│   └── ...
├── audio/
│   ├── scene_1.mp3        # ElevenLabs narrations
│   └── ...
├── final.mp4              # Single-pass stitched output
└── tiktok_package.md      # Caption + hashtags + assembly notes
```

Event slug examples: `ghadeer`, `ashura-day10`, `mubahala`, `laylat-al-mabit`,
`khaybar`, `aam-al-huzn`.

## API setup reminders

All scripts auto-load `.env` from the project root via `python-dotenv`. Confirm these
keys exist before running (all three are already in the user's normal Al-Thaqalayn
`.env` if they've done any verse-art or TikTok work before):

**Required:**
- `OPENROUTER_API_KEY` — for Nano Banana Pro image generation (recommended path)
- `KLING_ACCESS_KEY` + `KLING_SECRET_KEY` — for official Kling API (JWT auth)
  - OR `KLING_API_KEY` + `KLING_API_ENDPOINT` — for a third-party Kling gateway
- `ELEVENLABS_API_KEY` — for narration

**Optional (alternate image providers):**
- `GEMINI_API_KEY` — direct Gemini access (if not using OpenRouter)
- `OPENAI_API_KEY` — for ChatGPT Image fallback

**If you hit a 400/401/404/429:**
- 400 on Kling + 10s duration → `v2-master` doesn't support 10s. Use `v2-1-master` or upgrade to `v3-0-pro`.
- 404 from kie.ai when using the skill's generic `generate_video.py` → that script's gateway path uses a PiAPI-style endpoint that doesn't match kie.ai. Switch to `scripts/kie_kling.py` (project root, NOT skill scripts/).
- 429 "balance not enough" on Kling → user's account is out of credit. If both `KLING_ACCESS_KEY/SECRET_KEY` (official) and `KLING_API_KEY/ENDPOINT` (kie.ai) are set, the skill's auto-resolver may be picking the wrong one — `kie_kling.py` always uses kie.ai.
- Auth errors on image → check which provider is set in `.env`; the script prints which it tried.

**Security:** If the user pastes an API key directly into chat, warn them that
transcripts may be logged and recommend they rotate the key on the provider's site.

## When the user says "make a Ghadeer video"

Don't dump the whole workflow on them. Walk them through it:

1. "Got it — Ghadeer. I'll propose 6 scenes. One moment." → pull from `references/events.md`, present scene outline.
2. Wait for approval or edits.
3. "Generating scene 1 image..." → call the script, show it.
4. Iterate per scene or in batches depending on how they prefer.
5. After images approved: "Kicking off Kling for all 6 scenes in parallel. This takes ~5 min." → run, show videos.
6. Deliver the TikTok package.

Keep messages short on mobile. One action per turn when possible.

## Reference files

- `references/events.md` — Pre-researched narrative structures for common events. Start here for any event you recognize.
- `references/style_guide.md` — The locked visual aesthetic (golden hour, veiled faces, 7th century Arabia, etc.)
- `references/religious_accuracy.md` — Shia doctrinal guardrails; what's authentic, what's controversial, what to avoid.
- `references/prompt_templates.md` — Copy-paste templates for image generation prompts and Kling motion prompts.
- `references/video_model_research.md` — How to research a Kling model's prompt guide upfront in Stage 0. **Required reading before writing any motion prompts.**

## Scripts

### Production-tested path (use these)

- **`scripts/kie_kling.py` (in project root, NOT this skill folder)** — Kling image-to-video via kie.ai gateway. Supports v2.1 master, v2.1 standard/pro, v3-0-std/pro/4k. Handles Kling 3.0's different payload shape (image_urls array, mode std/pro/4K, multi_shots, etc.). Has `--lock-end-frame` for mathematically preventing lighting drift. **This is the default video-generation path.**
- `scripts/generate_image.py` (in this skill) — Nano Banana Pro via OpenRouter (default), direct Gemini, or ChatGPT Image. Saves 9:16 PNG.
- `scripts/generate_narration.py` — ElevenLabs TTS per-scene narration. Reads `<event-dir>/narration.json`, writes `audio/scene_N.mp3`.
- `scripts/stitch_video.py` — Single-pass FFmpeg stitch. Auto-detects any scene count, handles video/audio duration mismatches, no AAC priming drift.
- `scripts/ken_burns.py` — FFmpeg slow-zoom on a still PNG. Use as a halo-drift fallback when Kling repeatedly fails a scene.

### Legacy / fallback

- `scripts/generate_video.py` (in this skill) — Older generic Kling adapter. Has both JWT (official) and PiAPI-style gateway paths, but the gateway path doesn't match kie.ai's API shape (returns 404 on `/task`). Only use if the project doesn't have `scripts/kie_kling.py` for some reason.

### Setup

- `scripts/requirements.txt` — Python deps. Install with:
  ```
  source .venv/bin/activate
  pip install -r .claude/skills/shia-event-video-creator/scripts/requirements.txt
  ```
