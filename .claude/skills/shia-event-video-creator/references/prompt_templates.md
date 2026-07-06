# Prompt Templates

Copy-paste scaffolds for image and video prompts. Adjust bracketed sections per scene.

---

## Image generation prompt (Nano Banana Pro via OpenRouter)

Nano Banana Pro (`google/gemini-3-pro-image` via OpenRouter's Unified Image API) is a
reasoning model - it responds best to natural-language descriptive briefs and to
**positive framing** ("plain and unlettered", not "no text"). Stack the locked style
preamble + scene content + blank-face veiling instruction. The blank-face description is
the doctrinal core: keep its wording verbatim (see the CRITICAL FACE RULE below). Only
the generic text/style exclusions are reworded to positive framing.

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

TEXT-FREE FRAME: every surface is plain and unlettered. Banners are abstract panels of
colored cloth, and the open sky is clean painterly space. The frame carries no writing
of any kind.

The sacred figures' faces stay completely featureless: no eyes, no nose, no mouth, no
bright glowing sun face, no blinding light, no hard-edged disc, no pasted-on sphere, no
floating orb, no oversized glowing ball, no ring-shaped halo behind the head, no circular
shape, and the face is never turned up or craned upward.

Style: authentic 7th-century Arabian dress, materials, and architecture throughout,
rendered entirely as a matte oil-on-canvas historical painting with natural anatomy and
visible painterly brushwork. A reverent Orientalist oil painting, not a photograph, a
3D render, a cartoon, or anime.
```

> **What changed vs the old template:** the blank-face description (the CRITICAL FACE
> RULE, above) is unchanged and every face-safety term is preserved - only re-led
> positively ("faces stay completely featureless: no eyes...") and the generic text /
> modern / 3D-render negatives are stated positively, per the model's prompting guide.

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
TEXT-FREE FRAME. Every surface in the image is plain and unlettered: the open sky is
pure, clean painterly space, and banners in the distance are abstract panels of colored
cloth. Keep the frame free of letters, words, Arabic or English script, subtitles,
calligraphy, inscriptions, and numbers of any kind.
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

TEXT-FREE FRAME: every surface is plain and unlettered. The open sky is clean painterly
space and the banners are abstract colored cloth with no readable text.

The faces of the Prophet and Imam Ali stay completely featureless: no eyes, no nose, no
mouth, no bright glowing sun face, no hard-edged disc, no pasted-on sphere, no floating
orb, no ring-shaped halo, no circular shape, and the face is never turned up or craned
upward.

Style: authentic 7th-century dress and setting, rendered entirely as a matte oil-on-canvas
historical painting with natural anatomy. A reverent Orientalist oil painting, not a
photograph, a 3D render, a cartoon, or anime.
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

4. **Real figure movement is the DEFAULT - frozen figures are NOT the goal.** Horses
   toss/stamp/rear-in-place, robes and banners billow, non-sacred people move freely,
   and sacred figures' bodies and heads move too (bowing the head DOWN, leaning, swaying,
   turning AWAY). A still video is no longer the target; proper movement is.

5. **Move the figures, lock the camera.** `"Locked-off tripod shot, completely static
   camera."` is the PREFERRED setup for movement-heavy scenes, not a last resort, for two
   reasons: (a) it stops Kling from pulling back / widening / re-framing - which otherwise
   drifts the composition or drags in content you deliberately cropped out (e.g. a horse's
   legs framed out at the chest); (b) with the camera pinned, all the motion energy goes
   into the figures and environment. Pin the camera, move everything else.

6. **The safe movement envelope** (production-tested on blank-face veiled figures):

   | Tier | What | Use when |
   |---|---|---|
   | **DEFAULT - move figures, lock camera** | Big figure + environment motion: horse tossing/stamping/rearing in place, rider bowing the head down / leaning, robes & banners billowing, dust blowing - under `"Locked-off tripod shot, completely static camera."` | Sacred heads bowed / level / turned away (never craned up or to camera). 5s. The norm for dramatic scenes. |
   | **ALSO FINE - gentle camera** | slow push-in / gentle ~20-30 degree arc + lighter figure motion | Calm scenes where NOTHING is cropped just outside the frame (a widen won't expose anything). Forward-facing or heads level/bowed. |
   | **RISKY (QC every frame)** | big figure motion + a moving camera; 8s+; mild crane | Only forward-facing, never tight on a sacred face. Extract & inspect ~5 frames. |
   | **FORBIDDEN** | a sacred head craning UP or turning to face camera *during motion*; full 360 degree orbit; any camera move + upward gaze; a camera pull-back / widen when content is cropped at the frame edge; fast pans; handheld shake | - |

   The one thing that completes a blank face is the **sacred head craning up / turning to
   camera during motion** - NOT figure movement itself, and not a bowed or turned-away
   head. Move the body and the bowed head freely; just never point the face up or at camera.

7. **Watch the camera, not only the figures.** Kling often ignores or *inverts* a camera
   instruction - a requested "push-in" can come back as a pull-back that widens the frame
   and drags in whatever you cropped out. If anything important sits just outside a frame
   edge, lock the camera off so it cannot widen.

8. **Environment always moves too:** robes/banners billow in the wind, dust blows/drifts,
   light blooms, stars twinkle. The forbidden move stays narrow: a sacred head craning UP
   or the face turning to camera - never that.

9. **Keep prompts SHORT** (2-4 sentences, ~15-40 words), prefer **5s**, `--mode v3-0-pro`
   via `scripts/kie_kling.py`. **Always QC start/mid/end (all 5 frames if the camera moves
   OR the figures move a lot) AND the final stitch.**

10. **Give every motion an end-state.** Close the prompt with where the motion comes to
    rest - "...then steadies", "...and settles", "...and holds still", "...eases to a
    stop". Kling needs a place to finish the shot; a motion with no endpoint can loop and
    stall the render at 99% (per the Kling i2v guide). An end-state also stops a 5s clip
    drifting in its final second.

### Templates

**Default - move the figures, lock the camera (use this for most dramatic scenes):**
```
Locked-off tripod shot, completely static camera. The [animal/object in BIG in-place
motion - tosses its head, mane whipping; stamps; rears in place]. The [figure-by-
appearance] [body motion - sways, bows the head down over the neck, leans], [his] cloak
and the banner billowing. Dust blows, then the motion settles and the shot holds.
(Sacred head bows DOWN or turns away - never up or to camera. Pinned camera = it cannot
widen and reveal cropped-out content.)
```

**Gentle-camera alternative (calm scene, nothing cropped at the frame edge):**
```
[CAMERA: slow push-in that eases to a stop - avoid pull-back if content sits just out of
frame]. [ENVIRONMENT: robes ripple, dust drifts]. The [figure-by-appearance] moves
lightly - [small body motion], head level or bowed, never craned up, then settles.
```

**Fragile only — locked-off (upward gaze / tight on face / QC de-escalation):**
```
Locked-off tripod shot, completely static camera.
[ENVIRONMENT MOTION, 1 sentence]. The [figure-by-appearance] and the
[figure-by-appearance] are completely motionless. All image content otherwise unchanged.
```

### Worked examples

**Movement-heavy, locked camera - 5s (validated default):**
```
Locked-off tripod shot, completely static camera. The white horse stays planted, tossing
its head, mane and forelock whipping in the wind. The rider sways, his green cloak
billowing, and bows his head over the neck. Dust blows across the ground, then the horse
steadies and the dust settles.
```
Big mane/cloak/head motion and the rider bowing his head DOWN; the pinned camera cannot
widen to expose the horse's legs cropped out at the chest. This is the Karbala "horse
will not move" beat.

**Reverent night prayer (kneeling figure) — 5s, slow push-in:**
```
The kneeling figure in the brown robe stays completely motionless and does not move
at all. Stars subtly twinkle across the night sky. The robe shifts faintly in a soft
night breeze. Camera: slow, gentle push-in that eases to a stop and holds.
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
4. **`--lock-end-frame`** — pass it to `kie_kling.py` to reuse the start frame as the end
   frame (v3 sends `image_urls: [start, start]`), so Kling interpolates between two
   identical endpoints. This holds the blank face far better than a free clip; try it
   before Ken Burns for a scene that only mildly drifts.
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

**Good (move the figures + environment, camera usually pinned):** "Locked-off tripod
shot, completely static camera" (now a default for movement-heavy scenes), "tosses its
head", "mane whipping", "stays planted / rears in place / stamps", "sways", "bows the
head down", "leans", "turns away", "cloak billowing", "banner waving", "robes ripple",
"dust blows / drifts", and for calm scenes "slow push-in", "gentle short arc". Close every
prompt with a settle / end-state: "then steadies", "and settles", "holds still", "eases to
a stop".

**Bad (never on a SACRED figure):** the sacred head "looks up / cranes up / lifts the
face / turns to face the camera"; the face/blank-face/glow/aura/figure's name; "full 360
orbit"; any camera move + upward gaze together; a camera "pull-back / zoom out / widen"
when content is cropped at the frame edge; "fast", "sudden", "handheld shake". (A sacred
figure moving the body, bowing the head DOWN, or turning AWAY is fine.)

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

## Aspect ratio & resolution

Always `9:16` for TikTok/Reels/Shorts - now passed as a real API parameter (`--aspect
9:16`), not just prose. Generate scene stills at `--size 4K` for crisp faces and detail:
for this model the "2K" tier is a no-op (identical to 1K, ~768px wide), and 768px is soft
once the clip is delivered at 1080. Kling accepts the high-res still and downscales it.

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
