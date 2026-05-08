# Tafsir-Explainer Base Video — Scene Set

This is the prompt set to feed into `shia-event-video-creator` ONCE to produce the
silent base video at `assets/tafsir_base/tafsir_base.mp4`.

**Total length target:** ~40 seconds (8 scenes × ~5s each).
**Format:** 1080×1920 vertical, no audio, no text overlays of any kind.

**Hard rule for every scene:** Add to the negative prompt: `"no text, no Arabic
calligraphy in image, no captions, no watermarks, no UI elements"`. The skill adds
all overlay text in CapCut-style during per-verse rendering.

## Scenes

### Scene 1 — Cosmic zoom (open)
Image: Wide shot of a deep-space nebula, indigo and teal cosmic dust, stars,
galactic core glowing in distance. Cinematic, photoreal, 9:16.
Motion: Slow zoom-in toward the galactic core, stars drifting outward at the edges.

### Scene 2 — Glowing Quran in dark space
Image: An open ornate Quran floating in a black void, a soft cyan-white glow
emanating from its center pages, golden detailing on the cover. Sparks of light
drifting around it. Photoreal, 9:16.
Motion: Subtle hover; pages flutter; cyan glow pulses gently.

### Scene 3 — Galaxy spiral
Image: A vast spiral galaxy seen face-on, deep purples, oranges, and whites. No
foreground objects. Photoreal, 9:16.
Motion: Slow rotation of the spiral arms.

### Scene 4 — Planetary alignment
Image: A row of three large planets at different distances in deep space, ringed
gas giant in the foreground, small red planet behind, distant blue planet in the
background. Stars, faint nebula. Photoreal, 9:16.
Motion: Gentle parallax — planets drift slowly past one another.

### Scene 5 — Exploding fire orb
Image: A fiery orange-red orb suspended in the center of a black void, intense
flames erupting outward in a halo, sparks and embers. Photoreal, 9:16.
Motion: Fire pulses outward and contracts back; embers drift upward.

### Scene 6 — Light tunnel (kinetic)
Image: A bright tunnel of streaking warm-white light particles converging toward
a central point against a dark cosmic backdrop. Photoreal, 9:16.
Motion: Particles streak rapidly toward the center (forward warp feel).

### Scene 7 — Cosmic stillness
Image: A wide stillness — a single distant galaxy, vast empty space, soft purple
ambient glow. Calm, contemplative. Photoreal, 9:16.
Motion: Almost still; very slow drift, soft pulse of light from the galaxy.

### Scene 8 — Crescent moon emerging from shadow (final beat)
Image: A luminous crescent moon emerging from the dark side of a celestial body
in deep space, bright sliver glowing softly with warm white-gold light against
pure black void, faint stars, ethereal reverent atmosphere, dramatic chiaroscuro.
Photoreal, 9:16.
Motion: Crescent slowly grows wider, warm glow on lit edge intensifies softly,
faint stars drift gently in the background, contemplative reverent motion.

## After generation

After Kling renders all 8, stitch them with `ffmpeg concat`:

```bash
ffmpeg -f concat -safe 0 -i scene_list.txt -c:v libx264 -preset slow -crf 18 \
  -pix_fmt yuv420p -an .claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4
```

Verify: `ffprobe -v error -show_streams tafsir_base.mp4` — should show video only,
no audio stream, ~40s, 1080×1920.
