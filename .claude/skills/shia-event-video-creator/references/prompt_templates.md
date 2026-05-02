# Prompt Templates

Copy-paste scaffolds for image and video prompts. Adjust bracketed sections per scene.

---

## Image generation prompt (Nano Banana Pro via OpenRouter)

Nano Banana Pro (`google/gemini-3-pro-image-preview` via OpenRouter) responds well to natural-language descriptive prompts. Stack the locked style preamble + scene content + veiling instruction + negative prompt.

### Full template (use HARDENED halo by default — survives image-to-video animation)

```
Cinematic oil painting in the style of 19th-century Orientalist historical painters,
warm golden hour lighting, 7th-century Arabian Peninsula setting, painterly brushwork,
deep amber and ochre color palette with dramatic sunset sky, particulate atmosphere
with dust motes and heat haze, 9:16 vertical composition.

[SCENE DESCRIPTION — what's happening, who's where, what's the camera doing]

CRITICAL HALO RULES — MUST BE FOLLOWED EXACTLY:
[For EACH sacred figure in the scene, list them on their own line with the veiling
rule. One line per figure, even if it means repeating the rule multiple times.]

- The face of [Prophet Muhammad ﷺ] is COMPLETELY REPLACED by a perfectly solid,
  fully opaque, intensely bright sphere of warm white-gold light, like a small sun
  where the face would be. NO eyes, NO nose, NO mouth, NO beard rendered IN FRONT
  of the halo (beard silhouette only AROUND the halo edge). The halo is positioned
  IN FRONT OF the face, COMPLETELY COVERING IT — not behind the head as a ring.
  Fully opaque white-gold paint, not translucent. Treat as a hard solid disc of light.
- The face of [Imam Ali ع] is ALSO COMPLETELY REPLACED by an identical perfectly
  solid, fully opaque, intensely bright sphere of warm white-gold light. Same
  treatment, no features visible.
- [Repeat for each additional sacred figure — Fatima س, Husayn ع, etc.]

[Other figures — non-sacred companions, crowd, enemies — rendered as painterly
crowd with indistinct features.]

[SYMBOLIC ELEMENTS — banners, specific objects, colors]
[CAMERA — angle, framing, composition]

ABSOLUTELY NO TEXT IN THE IMAGE: NO Arabic words, NO English text, NO subtitles, NO
calligraphy, NO inscriptions, NO writing of any kind. Banners contain NO readable
text — abstract colored cloth shapes only.

Negative: NO visible facial features on sacred figures, NO ring-shaped halo behind
the head, NO see-through halo, NO halo with face features showing through, NO text
of any kind, NO modern clothing, NO modern architecture, NO anachronistic objects,
NO neon colors, NO photorealistic selfie style, NO AI plastic skin, NO distorted
anatomy, NO cartoon style, NO anime, NO 3D render look.
```

**Why the per-figure list matters:** When multiple sacred figures appear in one scene,
a single mention of "the figures are veiled" tends to apply to only one of them.
Nano Banana treats each separate sentence as a distinct instruction that it weights
individually. Always list each sacred figure on its own line.

**Why the hardened halo language matters:** The simpler "obscured by a soft radiant
halo" phrasing was the older default but it tends to render as a translucent ring
that Kling later fades during animation, exposing the face. The hardened language
above ("perfectly solid, fully opaque, intensely bright sphere of warm white-gold
light, like a small sun") was production-tested in April 2026 — it survives Kling
animation reliably and is what should be used by default for any image that will
become a Kling video.

### Side profile addendum

For figures in **side profile or 3/4 view** where the original frontal halo would
appear behind the head when rotated, add explicitly:
```
The halo is positioned IN FRONT OF the visible side of the face, not behind the head
as a ring. The halo blocks the view of the face entirely from this camera angle.
```

This prevents the "behind-head ring + visible face profile" failure mode we hit on
scene 6 of Khandaq.

### "No text" clause (always include for Stage 6 closer scenes)

Nano Banana sometimes bakes Arabic/English text into the sky area, especially when the
prompt mentions "space for text overlay." That text is almost always wrong (mistranslated,
misspelled, or in the wrong place for CapCut overlay). Always negative-prompt it:

```
ABSOLUTELY NO TEXT IN THE IMAGE. The image must contain ZERO written letters, ZERO
words, ZERO Arabic script, ZERO English text, ZERO subtitles, ZERO calligraphy, ZERO
inscriptions, ZERO numbers, ZERO writing of any kind anywhere in the frame. The empty
sky area is pure clean painterly sky with NO text rendered on it. Banners in the
distance contain NO readable text — abstract colored cloth shapes only.
```

### Worked example — Ghadeer scene 4 (the raising of the hand) — using HARDENED halo

```
Cinematic oil painting in the style of 19th-century Orientalist historical painters,
warm golden hour lighting, 7th-century Arabian Peninsula setting, painterly brushwork,
deep amber and ochre color palette with dramatic sunset sky, particulate atmosphere
with dust motes and heat haze, 9:16 vertical composition.

Two figures stand atop a raised platform of stacked camel saddles in a desert valley
at sunset. The Prophet Muhammad ﷺ (in a cream-white robe with a brown over-cloak)
stands to the left, holding the raised right hand of Imam Ali ع (in a green robe with
darker sash) high above both their heads. A vast crowd of pilgrims in earth-toned
robes stretches into the distance, filling the valley floor. Palm trees on either
side. A large green banner rises on a pole to the right. The setting sun is directly
behind and between the two figures.

CRITICAL HALO RULES — MUST BE FOLLOWED EXACTLY:

- The face of the Prophet Muhammad ﷺ is COMPLETELY REPLACED by a perfectly solid,
  fully opaque, intensely bright sphere of warm white-gold light, like a small sun
  where the face would be. NO eyes visible. NO nose visible. NO mouth visible. NO
  beard rendered IN FRONT of the halo (beard silhouette only AROUND the halo edge).
  The halo is fully opaque white-gold paint, not translucent. Treat it as a hard
  solid disc of light positioned IN FRONT OF the face, COMPLETELY COVERING IT.
- The face of Imam Ali ع is ALSO COMPLETELY REPLACED by an identical perfectly
  solid, fully opaque, intensely bright sphere of warm white-gold light. Same
  treatment, no features visible at all.

The crowd behind them has indistinct painterly faces.

Low-angle hero shot looking up toward the two raised figures, with the sun centered
behind them creating a starburst effect. Generous empty sky space at top of frame.

ABSOLUTELY NO TEXT IN THE IMAGE: NO Arabic words, NO English text, NO subtitles, NO
calligraphy, NO inscriptions, NO writing of any kind. Banners contain NO readable
text — abstract colored cloth shapes only.

Negative: NO visible facial features on the Prophet or Imam Ali, NO ring-shaped halo
behind the head, NO see-through halo, NO halo with face features showing through, NO
text of any kind, NO modern clothing, NO modern architecture, NO anachronistic
objects, NO neon colors, NO photorealistic selfie style, NO AI plastic skin, NO
distorted anatomy, NO cartoon style, NO anime, NO 3D render look.
```

---

## Kling video motion prompt (image-to-video)

> ⚠️ **The #1 quality problem in religious video generation is halos drifting during
> the 5-second clip, revealing a face underneath. This template is specifically
> designed to prevent that.**

### Hard rules for motion prompts

1. **NEVER mention "halo", "veil", "glow", "radiant", "face", or the names "Prophet",
   "Imam", "Ali", "Fatima", "Muhammad", etc. in the motion prompt.** Every time you
   mention them, you draw Kling's attention to that region and it tries to animate
   or "complete" what it sees. The halos were set up in the image generation stage;
   do not describe them again here.

2. **Describe sacred figures by physical appearance instead.** Use phrases like:
   - *"the seated figure with the glowing light"*
   - *"the standing figure in green"*
   - *"the figure behind the cloak"*
   - *"the small silhouetted figure in the background"*

3. **Focus motion on the ENVIRONMENT.** Safe motion verbs:
   - Cloaks, thobes, and robes "gently shift in the wind"
   - Lamp flames "flicker softly"
   - Dust motes "drift"
   - A tear "travels down the cheek" (ONLY on figures whose face is visible — never
     on a veiled figure since there's no cheek visible)
   - Smoke "rises" from extinguished wicks
   - Banners "ripple" in the wind
   - Sunset/dawn light "slowly shifts across the scene"
   - Stars "subtly twinkle"

4. **Lock the sacred figure as "completely motionless".** Not "almost still" — say it
   explicitly: *"The figure with the glowing light is completely motionless — does
   not move at all."* Be absolute.

5. **Keep motion prompts SHORT.** 2-4 sentences max. Kling over-animates when given
   long instructions. If you find yourself writing a paragraph, you're telling Kling
   to do too much.

6. **Default `--mode v3-0-pro`** (Kling 3.0 Pro via `scripts/kie_kling.py`). Subject
   Binding is built-in and dramatically better at preserving veiled figures across
   camera moves than any v2.x model. Note: with Subject Binding, the explicit static-
   subject lock from rule 4 is *less critical* — Kling 3.0 preserves the figure as-is
   by default. You still want to lock for climactic scenes where intent matters.
   Fall back to `--mode v2-1-master` only if v3 is unavailable.

### Template

```
[ENVIRONMENT MOTION, 1-2 sentences. Describe what's moving in the scene — robes,
lamps, dust, light shifting, smoke, etc.]

[STATIC SUBJECT INSTRUCTION, 1 sentence. Identify the sacred figure(s) by appearance
— "the figure with the glowing light" — and lock them: "completely motionless, does
not move at all".]

Camera: [very slow push-in / pull-back / locked frame / gentle rise].
Subtle, reverent, minimal motion.
```

### Worked examples

**Intimate sickbed scene — Aam al-Huzn whispered Shahada:**
```
A single slow tear travels down the elderly bearded man's weathered cheek.
The oil lamp flame flickers softly. Golden dust motes drift through the warm air.
The seated figure with the glowing light is completely motionless — does not move
at all.
Camera: extremely slow, barely perceptible push-in.
Subtle, reverent, minimal motion.
```

**Ghadeer scene 4 (raising of the hand) — 10s climactic (use v3-0-pro):**
```
The green banner behind the platform gently ripples in the wind. Robes of the
surrounding crowd sway softly. Golden particulate light drifts across the frame.
The two central figures with the glowing lights are completely motionless — their
joined raised hands do not move at all.
Camera: very slow push-in toward the centered figures.
Subtle, reverent, slow cinematic movement.
```

**Karbala scene 4 (the morning stand) — 5s:**
```
Dust drifts across the plain. Black banners of the distant army ripple in the wind.
Cloaks and robes of the soldiers sway slightly.
The central figure with the glowing light is completely motionless.
Camera: very slow pull-back revealing the full enemy host.
```

**Laylat al-Mabit scene 3 (the vigil) — 5s:**
```
Moonlight shifts subtly through the window. Dust motes drift in the light. The door
shadow looms.
The figure under the green cloak is completely motionless.
Camera: locked frame.
```

### If the halo still drifts

If Kling still animates or fades the halo on the first attempt, work through these in order:

1. **Regenerate with a different seed.** Just re-submit — Kling uses different random
   seeds per attempt.
2. **Simplify the prompt further.** Cut every adjective. Keep only the essential
   environment motion + the "motionless" lock.
3. **Add the magic phrase.** Lead with `"Locked-off tripod shot, completely static
   camera."` This is the documented Kling phrase for forcing zero camera movement —
   the contradiction between camera moves and locked subjects is what causes drift.
4. **Upgrade to Kling 3.0 with `--mode v3-0-pro`** if you were on v2.x. Subject
   Binding is purpose-built for this problem.
5. **Add `--lock-end-frame`** (kie_kling.py flag) — forces Kling to interpolate
   between two identical endpoints, mathematically prevents lighting/halo drift.
6. **Regenerate the source image with hardened halo language** — see "Hardened halo
   variant" section above. The face-rendering bleed-through usually starts in the
   image, not in Kling.
7. **FFmpeg face-overlay patch** (locked-off cameras only). See recipe below.
8. **Fall back to Ken Burns.** Use `scripts/ken_burns.py` on the still image instead
   of Kling for that scene. Zero risk of halo drift because there's no AI animation —
   just a slow FFmpeg zoom on the still PNG.

### FFmpeg face-overlay recipe (option 7 above)

When a specific scene's camera is locked off (no movement) but the source image
still exposes a side-profile face, you can composite a soft white-gold radial
gradient over the face position for the entire clip. The face position is fixed
across all frames, so a single static overlay works.

**Step 1: Generate a circular gradient PNG** (Python + PIL):

```python
from PIL import Image
import math

size = 200  # diameter in pixels; tune to match the existing halo size
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
center = size // 2
pixels = img.load()
for y in range(size):
    for x in range(size):
        dx = x - center
        dy = y - center
        dist = math.sqrt(dx*dx + dy*dy)
        if dist > center:
            continue
        t = dist / center
        # Hard-opaque core to t=0.55, then steep cubic falloff to transparent edge
        if t < 0.55:
            alpha = 255
        else:
            falloff = (t - 0.55) / 0.45
            alpha = int(255 * max(0, 1 - falloff**1.4))
        pixels[x, y] = (255, 240, 200, alpha)  # warm white-gold
img.save('/tmp/halo_overlay.png')
```

**Tuning the size:** Match the existing in-image halo. Too big and it looks artificial;
too small and the face peeks out below the disc. For 1076×1924 frames, halos around
150-250px diameter usually match. Test on a single frame first.

**Step 2: Find the face position** in pixel coordinates (top-left of where you want
the overlay). For locked-off scenes, the face is usually fixed across the clip — pick
any frame, eyeball the face center (x, y), then the overlay top-left is `(x - size/2,
y - size/2)`.

**Step 3: Composite with FFmpeg overlay:**

```bash
# Test on a single frame first to verify position
ffmpeg -y -ss 2.5 -i video_output/<event>/videos/scene_N.mp4 \
  -i /tmp/halo_overlay.png \
  -filter_complex "[0:v][1:v]overlay=<x>:<y>" \
  -frames:v 1 -q:v 2 /tmp/test.jpg

# Once position is right, apply to full clip with high quality
# (always back up the original first!)
cp video_output/<event>/videos/scene_N.mp4 video_output/<event>/backups/scene_N_orig.mp4
ffmpeg -y -i video_output/<event>/backups/scene_N_orig.mp4 \
  -i /tmp/halo_overlay.png \
  -filter_complex "[0:v][1:v]overlay=<x>:<y>" \
  -c:a copy -c:v libx264 -preset slow -crf 18 \
  video_output/<event>/videos/scene_N.mp4
```

**Important:** Move backups OUT of the `videos/` directory (e.g. to `backups/`),
because the stitch script auto-discovers everything in `videos/` and would include
the backup as a duplicate scene.

**Why this works:** The locked-off camera means the figure's screen-space position
doesn't change across the clip, so a single static overlay covers the face for all
frames. With AI-orbiting cameras, this technique fails because the face position
moves — for those, regenerate the image instead.

**Production-tested on:** scene 6 of Khandaq (April 2026), where the source image had
Imam Ali ع in side profile with a behind-head ring halo. A 150px gold-warm gradient
overlay at the face position completely hid the profile features for all 5 seconds.

### Motion vocabulary cheat sheet

**Good (environment only):**
- "gently", "slowly", "softly", "drifts", "ripples", "shifts", "flickers", "rises"
- "push-in", "pull-back", "orbit slowly", "locked frame", "gentle rise"
- "golden particulate light", "dust motes", "heat shimmer", "banner ripples"

**Bad (never use on veiled figures):**
- Anything about the halo, veil, glow, light, face, or the figure's name
- "turns", "looks at", "speaks", "mouths", "breathes visibly"
- "fast", "sudden", "swings", "charges", "handheld shake"

---

## Duration guidelines

- **Standard scene:** 5 seconds. Use for most scenes.
- **Climactic scene:** 10 seconds. Only 1–2 per video.
- **Extended climactic scene:** up to 15 seconds (Kling 3.0 only). Use sparingly.
- **Model compatibility:**
  - `v3-0-std` / `v3-0-pro` / `v3-0-4k` — supports 3-15s (string)
  - `v2-1-master` — supports 5s and 10s
  - `v1-6` — supports 5s and 10s
  - `v2-standard` / `v2-pro` — **5s only** (v2-master rejects 10s with HTTP 400)

For a 6-scene video, typical budget: 5+5+5+10+5+5 = 35 seconds.

---

## Aspect ratio

Always `9:16` for TikTok/Reels/Shorts. Both Nano Banana and Kling support this directly.

---

## Narration script template

For the `generate_narration.py` pipeline, write your narration as `narration.json` in
the event folder. One entry per scene, 1–2 short lines each (narration should be
shorter than the scene to give the visual breathing room).

```json
[
  {"scene": 1, "text": "For years, Abu Talib was the shield of the Prophet."},
  {"scene": 2, "text": "When illness came, the Prophet would not leave his side."},
  {"scene": 3, "text": "Even on his deathbed, Quraysh demanded he abandon his nephew."},
  {"scene": 4, "text": "He refused. And whispered the Shahada to the Prophet."},
  {"scene": 5, "text": "O uncle — you raised me as a child, and supported me as a man."},
  {"scene": 6, "text": "Days later, Khadijah too was gone. The Year of Grief had begun."}
]
```

**Tone rules:**
- One breath, one idea per scene. If it takes two sentences, shorten it.
- Salawat like ﷺ / عليه السلام are often dropped in narration because ElevenLabs
  can't pronounce them reverently — add them to the on-screen text overlay instead.
- Keep each line's delivery under 4 seconds (roughly 10-12 English words).
- Don't read Arabic text through ElevenLabs multilingual — it sounds stilted. Use
  a real recitation track for any Arabic that matters.
