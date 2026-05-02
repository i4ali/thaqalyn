# Visual Style Guide — Locked Aesthetic

The user's existing Al-Thaqalayn content has a specific look (see the Ghadeer reference image). Every image and video the skill produces must match this look. Consistency across scenes matters as much as individual scene quality — viewers need to feel they're watching one piece.

## The look in one sentence

Cinematic oil-painting realism at golden hour, set in 7th-century Arabia, with sacred figures haloed in radiant white-gold light that obscures their faces.

## Mandatory style elements

### Lighting
- **Time of day:** late afternoon / golden hour / setting sun. Sometimes early dawn for specific events (Mubahala, dawn raids).
- **Quality:** warm, diffused, painterly. Sun is often low and visible in frame or implied by rim lighting.
- **Sky:** dramatic. Orange / amber / gold cloud banks. Clouds heavy but not stormy (unless the event is Karbala, where dust overtakes the sky).
- **Atmosphere:** particulate — dust, heat shimmer, soft haze. Never crisp or clinical.

### Color palette
- **Primary:** warm earth tones — ochre, burnt sienna, terracotta, sand, olive, dusty gold.
- **Accent:** deep green (Ahlul Bayt, Islam), black (mourning, Muharram, also historical Prophet's banner), white (purity, Prophet's banner at Khaybar), crimson (sparingly, for Karbala dust).
- **Avoid:** neon, saturated cool colors (cyan, pink, purple), modern color grading styles.

### Figures
- **Sacred figures (Prophet ﷺ, 12 Imams ع, Fatima س, Prophets):** face fully covered by a solid, fully opaque sphere of warm white-gold light positioned in front of the face (like a small sun where the face would be), not behind the head as a ring. Body, hair covering, beard silhouette, and clothing visible — features never. See the "veiled-faces instruction" section below for the production-default prompt language.
- **Companions (Sahaba) and bystanders:** may have visible faces, but keep them indistinct and crowd-like rather than individually characterized. No famous-actor look-alikes.
- **Enemies (Yazid's army, Quraysh, etc.):** faces may be shown but often in shadow or under helmets. Do not humanize them with clear expressions — they're narrative foils.
- **Clothing:** 7th-century Arabian — thobes, abayas, cloaks, turbans, head coverings. Natural fibers, earth-dyed. No modern fabrics, no cleanly geometric cuts.

### Settings
- **Desert** — palm groves, oasis, dunes, rocky outcrops, wadis.
- **Architecture** — mudbrick, stone, simple geometry. Mecca / Medina / Kufa / Karbala period-accurate. No minarets with loudspeakers, no tile patterns that post-date the period.
- **Animals** — camels, horses (especially Arabian horses — Zuljanah is white), sheep.

### Composition
- **Aspect ratio:** 9:16 vertical (TikTok / Reels / Shorts). All image prompts must specify this.
- **Framing:** balanced, with space above the figures for Arabic/English text overlays in post-production.
- **Hero moments:** low angle looking up at sacred figures, sun behind them.
- **Establishing shots:** wide landscape with figures small, showing scale.
- **Intimate moments:** medium shots; avoid tight close-ups of veiled figures since the halo becomes the whole frame.

### Rendering style
- Oil painting / matte painting / Orientalist historical painting (in the style of Rudolf Ernst, Ludwig Deutsch, but religiously reverent) — NOT photorealistic, NOT anime, NOT cartoon, NOT AI "plastic" look.
- Visible brushwork acceptable and desirable.
- Slight chiaroscuro (strong light / shadow contrast).

## Style preamble — use at the start of every image prompt

```
Cinematic oil painting in the style of 19th-century Orientalist historical painters, 
warm golden hour lighting, 7th-century Arabian Peninsula setting, painterly brushwork, 
deep amber and ochre color palette with dramatic sunset sky, particulate atmosphere 
with dust motes and heat haze, 9:16 vertical composition.
```

## The veiled-faces instruction — use in every prompt with sacred figures

**Default to the HARDENED halo language.** It is what survives image-to-video animation
in Kling — soft "obscured by a halo" prose tends to render as a translucent ring that
Kling later fades during animation. See `references/prompt_templates.md` for the full
hardened template and the "side profile" addendum.

```
The face of [Prophet Muhammad ﷺ / Imam Ali ع / etc.] is COMPLETELY REPLACED by a 
perfectly solid, fully opaque, intensely bright sphere of warm white-gold light, like 
a small sun where the face would be. NO eyes, NO nose, NO mouth, NO beard rendered IN 
FRONT of the halo (beard silhouette only AROUND the halo edge). The halo is positioned 
IN FRONT OF the face, COMPLETELY COVERING IT — not behind the head as a ring. Fully 
opaque white-gold paint, not translucent. Treat as a hard solid disc of light.

[Repeat this block for each sacred figure on its own line — Nano Banana applies the
veiling rule per-figure, not collectively.]

Other figures in the scene (companions, crowd) may have visible faces but rendered 
indistinctly as a painterly crowd.
```

For figures shown in **side profile or 3/4 view**, also include:
> *"The halo is positioned IN FRONT OF the visible side of the face, not behind the head as a ring. The halo blocks the view of the face entirely from this camera angle."*

## Negative prompt — use in every image generation

```
no visible facial features on sacred figures, no modern clothing, no modern architecture, 
no anachronistic objects (watches, glasses, cars, electronics, modern weapons), 
no neon colors, no photorealistic selfie style, no AI plastic skin, no text artifacts, 
no distorted anatomy, no cartoon style, no anime, no 3D render look
```

## Consistency between scenes

Across the 4–8 scenes of one video, keep these constants:

1. **Same lighting mood** — if scene 1 is golden hour, scene 4 better be too (unless there's a narrative reason — e.g., night scenes for Laylat al-Mabit).
2. **Same color palette** — don't introduce a new dominant color mid-video.
3. **Same figures look the same** — same veil-halo size and warmth, same body build, same clothing colors for the same person. *If the image model supports reference images, feed scene 1's character as a reference for scenes 2+.*
4. **Same rendering style** — don't let one scene drift into photorealism while another is painterly.

When a scene comes back inconsistent, the fastest fix is usually to tell the model explicitly: "match the rendering style and lighting of the reference image" and feed in the previous approved scene.

## Examples of what to avoid

- **Faces of Prophet or Imams visible.** Hard refusal.
- **Modern Iranian/Pakistani/Arab dress** — the imagery should evoke 7th century, not 21st.
- **Cinematic stills from Mel Gibson's Passion / Hollywood epics.** The tradition we're evoking is different and more reverent.
- **Flag designs from modern political movements.** Use historically-inspired banners (black, green, white — no modern emblems).
- **Anything that looks like a history documentary reenactment** — we want painting, not reenactment photography.
- **Bloody / graphic violence** — Karbala is tragic but never graphic. Suggest through composition.
