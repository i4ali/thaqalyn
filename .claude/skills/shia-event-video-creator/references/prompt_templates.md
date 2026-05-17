# Prompt Templates

Copy-paste scaffolds for image and video prompts. Adjust bracketed sections per scene.

---

## Image generation prompt (Nano Banana Pro via OpenRouter)

Nano Banana Pro (`google/gemini-3-pro-image-preview` via OpenRouter) responds well to
natural-language descriptive prompts. Stack the locked style preamble + scene content +
blank-face veiling instruction + negative prompt.

### The veiling technique — BLANK FACE (production default, canonical Al-Thaqalayn look)

Sacred figures' faces are rendered as a **smooth, blank, featureless matte pale face** —
the canonical Al-Thaqalayn devotional style (user reference: `IMG_0550.jpg`). This is the
ONLY veiling technique. The old "hardened halo" (bright opaque white-gold sun-ball / hard
disc / floating orb in front of the face) is **retired** — it reads as a pasted-on
sticker and the user rejected it. Never emit sun-ball / glowing-orb language.

### Full template

```
Cinematic oil painting in the style of 19th-century Orientalist historical painters,
warm golden hour lighting, 7th-century Arabian Peninsula setting, painterly brushwork,
deep amber and ochre color palette with dramatic sunset sky, particulate atmosphere
with dust motes and heat haze, 9:16 vertical composition.

[SCENE DESCRIPTION — what's happening, who's where, what the camera is doing. For any
scene that will be ANIMATED in Kling, pose sacred figures FORWARD-FACING with heads
level or slightly bowed — never craned/looking up (that triggers face-completion).]

CRITICAL FACE RULE — MUST BE FOLLOWED EXACTLY (apply separately to EACH sacred figure,
one line per figure, even if it means repeating the rule):

- The face of [Prophet Muhammad ﷺ] is rendered as a completely smooth, blank,
  featureless face — a soft matte pale ivory-white surface with a gentle quiet inner
  luminosity and only a faint soft glowing aura at its edge. It is the natural shape,
  size, and position of a real human face (an oval face, NOT a circle, NOT a ball),
  sitting correctly on the head and framed closely by the head covering or hair.
  Absolutely NO eyes, NO nose, NO mouth, NO eyebrows, NO features or hint of features
  of any kind — just a serene, smooth, blank luminous pale face. SOFT and SUBTLE, NOT
  a bright light source, NOT a glowing sun, NOT a hard-edged disc, NOT a floating orb,
  NOT oversized — painted with the exact same matte oil brushwork as the rest of the
  canvas. A dignified grey beard silhouette below/around the blank face is acceptable
  for elderly figures (it is hair, not a facial feature).
- The face of [Imam Ali ع] is rendered the same way — an identical completely smooth,
  blank, featureless soft matte pale ivory-white face with a faint gentle aura, natural
  human-face shape/size/position, framed by head covering or hair. No features of any
  kind. SOFT and SUBTLE, NOT a glowing sun, NOT a hard disc, NOT a floating orb.
- [Repeat one line per additional sacred figure — Fatima س, Husayn ع, etc.]

[Other figures — non-sacred companions, crowd, enemies — rendered as a painterly crowd
with indistinct features. Animals have normal natural faces.]

[SYMBOLIC ELEMENTS — banners, specific objects, colors]
[CAMERA — angle, framing, composition. Leave clean sky headroom for text overlay.]

ABSOLUTELY NO TEXT IN THE IMAGE: NO Arabic words, NO English text, NO subtitles, NO
calligraphy, NO inscriptions, NO writing of any kind. Banners contain NO readable
text — abstract colored cloth shapes only.

Negative: NO visible facial features on sacred figures, NO eyes, NO nose, NO mouth,
NO bright glowing sun face, NO blinding light, NO hard-edged disc, NO pasted-on
sphere, NO floating orb, NO oversized glowing ball, NO ring-shaped halo behind the
head, NO circular shape, NO face looking up / head craned upward, NO text of any
kind, NO modern clothing, NO modern architecture, NO anachronistic objects, NO neon
colors, NO photorealistic selfie style, NO AI plastic skin, NO distorted anatomy,
NO cartoon style, NO anime, NO 3D render look.
```

**Why the per-figure list matters:** When multiple sacred figures appear in one scene,
a single collective mention tends to veil only one of them. Nano Banana weights each
separate sentence individually. Always list each sacred figure on its own line.

**Why blank-face (not the old sun-ball):** The bright opaque sphere looked artificial
(a pasted disc) and the user rejected it. The blank matte face matches the existing
Al-Thaqalayn brand. It is doctrinally identical (zero features) and, as a solid matte
form, holds well in stills. Its one weakness is Kling animation — see the motion section.

### Side profile / 3-4 view

The blank face works in profile too — it is simply a smooth featureless pale face on
the visible side of the head. Add:
```
The blank pale face is on the visible side of the head, smooth and featureless from
this angle — no profile features (no nose line, no eye, no lips) rendered at all.
```

### "No text" clause (always include, critical for closer scenes)

Nano Banana sometimes bakes Arabic/English text into the sky, especially if the prompt
mentions "space for text overlay." Always negative-prompt it:

```
ABSOLUTELY NO TEXT IN THE IMAGE. The image must contain ZERO written letters, ZERO
words, ZERO Arabic script, ZERO English text, ZERO subtitles, ZERO calligraphy, ZERO
inscriptions, ZERO numbers, ZERO writing of any kind anywhere in the frame. The empty
sky area is pure clean painterly sky with NO text rendered on it. Banners in the
distance contain NO readable text — abstract colored cloth shapes only.
```

### Worked example — Ghadeer scene 4 (the raising of the hand)

```
Cinematic oil painting in the style of 19th-century Orientalist historical painters,
warm golden hour lighting, 7th-century Arabian Peninsula setting, painterly brushwork,
deep amber and ochre color palette with dramatic sunset sky, particulate atmosphere
with dust motes and heat haze, 9:16 vertical composition.

Two figures stand atop a raised platform of stacked camel saddles in a desert valley
at sunset, facing forward toward the viewer. The Prophet Muhammad ﷺ (cream-white robe,
brown over-cloak, olive-green head covering) stands to the left, holding the raised
right hand of Imam Ali ع (green robe, darker sash) high above both their heads. A vast
crowd of pilgrims in earth-toned robes fills the valley. Palm trees on either side. A
large green banner on a pole to the right. The setting sun behind and between them.

CRITICAL FACE RULE — MUST BE FOLLOWED EXACTLY:

- The face of the Prophet Muhammad ﷺ is rendered as a completely smooth, blank,
  featureless face — a soft matte pale ivory-white surface with a gentle quiet inner
  luminosity and a faint soft aura at its edge, the natural shape/size/position of a
  real human face (oval, NOT a circle or ball), framed by the olive-green head
  covering. NO eyes, NO nose, NO mouth, NO features of any kind. SOFT and SUBTLE,
  NOT a glowing sun, NOT a hard disc, NOT a floating orb, painted in the same matte
  oil brushwork as the canvas. Grey beard silhouette below the blank face is fine.
- The face of Imam Ali ع is rendered the same way — an identical smooth blank
  featureless soft matte pale face, no features, SOFT and SUBTLE, not a sun or disc.

The crowd behind them has indistinct painterly faces.

Low-angle hero shot looking up toward the two raised figures, sun centered behind them.
Generous clean empty sky space at the top of frame for later text overlay.

ABSOLUTELY NO TEXT IN THE IMAGE: NO Arabic words, NO English text, NO subtitles, NO
calligraphy, NO writing of any kind. Banners contain NO readable text.

Negative: NO visible facial features on the Prophet or Imam Ali, NO eyes, NO nose,
NO mouth, NO bright glowing sun face, NO hard-edged disc, NO pasted-on sphere, NO
floating orb, NO ring-shaped halo, NO circular shape, NO text of any kind, NO modern
clothing, NO modern architecture, NO anachronistic objects, NO neon colors, NO
photorealistic selfie style, NO AI plastic skin, NO distorted anatomy, NO cartoon
style, NO anime, NO 3D render look.
```

---

## Kling video motion prompt (image-to-video)

> ⚠️ **The #1 quality problem is Kling "completing" the blank face into a REAL face
> (eyes/nose/mouth) during the clip — a hard doctrinal failure.** The blank matte face
> reads to Kling as a real face, so upward gaze + head turn + camera motion invite it
> to fill in features. This template is designed to prevent that.

### Hard rules for motion prompts

1. **NEVER mention "face", "blank face", "glow", "aura", "veil", or the names
   "Prophet", "Imam", "Ali", "Fatima", "Muhammad", etc.** Every mention draws Kling's
   attention to that region and it tries to "complete" what it sees. The blank faces
   were set up in image generation; do not describe them here at all.

2. **Describe sacred figures by physical appearance / position instead:**
   - *"the kneeling figure in the brown robe"*
   - *"the standing figure in green"*
   - *"the figure on the left"*

3. **Pose matters more than prompt.** The biggest completion trigger is a sacred
   figure who looks UP / cranes the head while the camera moves. If a scene needs an
   upward gaze, regenerate the source image forward-facing FIRST, or go straight to
   Ken Burns. Don't try to fix an upward-gaze scene with prompt wording alone.

4. **Gentle camera movement is the DEFAULT and encouraged — locked-off is NOT the
   norm.** A tasteful slow move makes the video feel cinematic instead of a still.
   Keep figures static while the *camera* moves gently. Use the safe envelope below.

5. **The safe camera-movement envelope** (empirically validated — production-tested on
   blank-face veiled figures):

   | Tier | Moves | Use when |
   |---|---|---|
   | **SAFE (default)** | slow push-in / slow pull-back / **gentle ~20–30° partial arc** / slow lateral parallax — paired with wind in robes + drifting dust | Figures forward-facing or heads level/bowed (never craned up). 5s. This is the default for most scenes. |
   | **RISKY (QC every frame)** | longer/faster arc, 8s, mild crane | Only forward-facing figures, never tight on the face. Extract & inspect ~5 frames. |
   | **FORBIDDEN** | full 360° orbit; ANY camera move combined with an upward gaze or a turning/​moving sacred figure; fast pans; handheld shake | — |

   The subjects stay locked even though the camera moves — that combination is fine
   (a *gentle* move + static subject is the proven sweet spot). The thing that
   completes faces is **upward gaze / head-turn during motion**, not camera motion itself.

6. **Reserve locked-off for FRAGILE scenes only:** an unavoidable upward gaze, framing
   very tight on the face, or a scene that already failed QC (de-escalation). For those,
   lead with `"Locked-off tripod shot, completely static camera."`

7. **Environment always moves too:** robes/banners "gently shift in the wind", dust
   "drifts", light "slowly blooms", stars "twinkle". Never: a sacred figure turning,
   looking, lifting the head, "breathing visibly".

8. **Keep prompts SHORT** (2–4 sentences), prefer **5s**, `--mode v3-0-pro` via
   `scripts/kie_kling.py`. **Always QC start/mid/end (5 frames if the camera moves)
   AND the final stitch.**

### Templates

**Default — gentle movement (use this for most scenes):**
```
[CAMERA: slow push-in / slow pull-back / a gentle slow partial orbit, smooth and
cinematic — pick one]. [ENVIRONMENT: robes ripple in a steady wind, dust drifts, light
blooms]. The [figure-by-appearance] and the [figure-by-appearance] stay completely
still and do not move at all.
```

**Fragile only — locked-off (upward gaze / tight on face / QC de-escalation):**
```
Locked-off tripod shot, completely static camera.
[ENVIRONMENT MOTION, 1 sentence]. The [figure-by-appearance] and the
[figure-by-appearance] are completely motionless. All image content otherwise unchanged.
```

### Worked examples

**Gentle partial arc, static figures — 5s (validated default):**
```
The camera slowly arcs a short distance around the two still figures — a gentle, slow
partial orbit, smooth and cinematic. Their robes ripple softly in a steady wind. Fine
dust drifts low across the ground. The two figures stay completely still and do not
move at all.
```

**Reverent night prayer (kneeling figure) — 5s, slow push-in:**
```
The kneeling figure in the brown robe stays completely motionless and does not move
at all. Stars subtly twinkle across the night sky. The robe shifts faintly in a soft
night breeze. Camera: slow, gentle push-in.
```

**Fragile / upward-gaze climax — 5s locked-off (de-escalation):**
```
Locked-off tripod shot, completely static camera. The shaft of golden light slowly
blooms a little brighter. Faint golden dust drifts softly. The two standing figures
and the animal are completely motionless and do not move at all. All image content
otherwise unchanged.
```

### If the blank face still completes or drifts

Work through these IN ORDER. Escalate to Ken Burns fast for any climactic / upward-gaze
/ reflective scene — it is the expected outcome there, not a last resort:

1. **Regenerate the SOURCE IMAGE forward-facing, heads level/slightly bowed.** Never
   craned up. This is the single highest-leverage fix.
2. **De-escalate the camera move:** drop a partial arc to a slow push-in, or go fully
   locked-off (the "Fragile only" template), 5s, environment-only, no figure/face/glow
   words.
3. **Re-roll Kling with a new seed.** Just re-submit.
4. **`--lock-end-frame`** (if the script supports it) — interpolate between identical
   endpoints.
5. **Ken Burns fallback (the reliable fix).** Skip Kling for that scene; FFmpeg
   slow-zoom on the approved still PNG (perfect blank faces). Zero AI = zero
   completion risk:
   ```bash
   python scripts/ken_burns.py \
     --image video_output/<event>/images/scene_1.png \
     --output video_output/<event>/videos/scene_1.mp4 \
     --duration 5.0 --zoom-to 1.18
   ```

**Always QC start/mid/end frames of every clip AND the final stitch** (extract frames
with ffmpeg, view them). Never ship a clip where any feature appears on a sacred figure.

### Motion vocabulary cheat sheet

**Good (default — gentle camera + environment):** "slow push-in", "slow pull-back",
"gentle partial orbit / short arc", "slow parallax", "gently", "slowly", "softly",
"drifts", "ripples", "blooms", "robes ripple in the wind", "dust drifts",
"locked-off"/"completely static" (fragile scenes only).

**Bad (never on veiled figures):** the face/blank-face/glow/aura/figure's name,
a sacred figure that "turns / looks up / lifts head / speaks / breathes visibly",
"full 360 orbit", any camera move + upward gaze together, "fast", "sudden",
"handheld shake".

---

## Duration guidelines

- **Standard / veiled-figure scene:** 5 seconds (also safest against face-completion).
- **Climactic scene:** 8–10s only if forward-facing + fully locked-off; otherwise keep
  5s or go Ken Burns.
- **Model compatibility:**
  - `v3-0-std` / `v3-0-pro` / `v3-0-4k` — 3-15s (string)
  - `v2-1-master` — 5s and 10s
  - `v2-standard` / `v2-pro` — 5s only

For a 4–6-scene video, typical budget: 5s per scene, 8s for one forward-facing climax.

---

## Aspect ratio

Always `9:16` for TikTok/Reels/Shorts. Both Nano Banana and Kling support this directly.

---

## Narration script template

Write narration as `narration.json` in the event folder. One entry per scene, 1–2
short lines each (narration should be shorter than the scene for breathing room).

```json
[
  {"scene": 1, "text": "For years, Abu Talib was the shield of the Prophet."},
  {"scene": 2, "text": "When illness came, the Prophet would not leave his side."},
  {"scene": 3, "text": "Even on his deathbed, Quraysh demanded he abandon his nephew."},
  {"scene": 4, "text": "He refused. And whispered the Shahada to the Prophet."}
]
```

**Tone rules:**
- One breath, one idea per scene. If it takes two sentences, shorten it.
- Salawat (ﷺ / عليه السلام) are dropped from narration (ElevenLabs can't voice them
  reverently) — put them in the on-screen text overlay instead.
- Keep each line's delivery under ~4 seconds (~10–12 English words).
- Don't read Arabic through ElevenLabs multilingual — use a real recitation track.
