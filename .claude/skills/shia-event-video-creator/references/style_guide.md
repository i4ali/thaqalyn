# Visual Style Guide — Locked Aesthetic

The user's existing Al-Thaqalayn content has a specific look (see the Ghadeer reference image). Every image and video the skill produces must match this look. Consistency across scenes matters as much as individual scene quality — viewers need to feel they're watching one piece.

## The look in one sentence

Cinematic oil-painting realism at golden hour, set in 7th-century Arabia, with sacred figures' faces rendered as a smooth blank featureless pale luminous face (the canonical Al-Thaqalayn devotional look).

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
- **Sacred figures (Prophet ﷺ, 12 Imams ع, Fatima س, Prophets):** face rendered as a completely smooth, blank, featureless soft matte pale ivory-white face with a faint gentle aura — natural human-face shape/size/position, framed by head covering or hair, painted in the same oil brushwork as the canvas. Body, hair covering, beard silhouette, and clothing visible — features never. NOT a bright sun-ball / hard disc / floating orb (that "hardened halo" style is retired). See the "veiled-faces instruction" section below for the production-default prompt language.
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

**Use the BLANK-FACE language** (the only veiling technique — the old bright sun-ball /
opaque-disc "hardened halo" is retired). List it once per sacred figure. See
`references/prompt_templates.md` for the full template, the side-profile note, and the
Kling motion recipe that stops the blank face being animated into a real face.

```
The face of [Prophet Muhammad ﷺ / Imam Ali ع / etc.] is rendered as a completely
smooth, blank, featureless face — a soft matte pale ivory-white surface with a gentle
quiet inner luminosity and only a faint soft glowing aura at its edge. It is the
natural shape, size, and position of a real human face (an oval face, NOT a circle,
NOT a ball), framed by the head covering or hair. NO eyes, NO nose, NO mouth, NO
features of any kind. SOFT and SUBTLE, NOT a bright light source, NOT a glowing sun,
NOT a hard-edged disc, NOT a floating orb, NOT oversized — painted in the same matte
oil brushwork as the canvas. A grey beard silhouette below/around the blank face is
fine for elderly figures (it is hair, not a feature).

[Repeat this block for each sacred figure on its own line — Nano Banana applies the
veiling rule per-figure, not collectively.]

Other figures in the scene (companions, crowd) may have visible faces but rendered 
indistinctly as a painterly crowd. Animals have normal natural faces.
```

For figures shown in **side profile or 3/4 view**, also include:
> *"The blank pale face is on the visible side of the head, smooth and featureless from this angle — no profile features (no nose line, no eye, no lips) rendered at all."*

**Animating in Kling:** the blank matte face reads to Kling as a real face and can be
"completed" with features under motion. Pose animated sacred figures forward-facing,
heads level/slightly bowed (never craned up), use locked-off motion prompts, prefer
5s, and fall back to Ken Burns for climactic/upward-gaze scenes. See
`references/prompt_templates.md` and SKILL.md Stage 4b.

## Negative prompt — use in every image generation

```
no visible facial features on sacred figures, no eyes, no nose, no mouth, no bright 
glowing sun face, no hard-edged disc, no pasted-on sphere, no floating orb, no 
oversized glowing ball, no circular shape, no modern clothing, no modern architecture, 
no anachronistic objects (watches, glasses, cars, electronics, modern weapons), 
no neon colors, no photorealistic selfie style, no AI plastic skin, no text artifacts, 
no distorted anatomy, no cartoon style, no anime, no 3D render look
```

## Consistency between scenes

Across the 4–8 scenes of one video, keep these constants:

1. **Same lighting mood** — if scene 1 is golden hour, scene 4 better be too (unless there's a narrative reason — e.g., night scenes for Laylat al-Mabit).
2. **Same color palette** — don't introduce a new dominant color mid-video.
3. **Same figures look the same** — same blank-face size/warmth/aura, same body build, same clothing colors and head covering for the same person across every scene. *If the image model supports reference images, feed scene 1's character as a reference for scenes 2+.*
4. **Same rendering style** — don't let one scene drift into photorealism while another is painterly.

When a scene comes back inconsistent, the fastest fix is usually to tell the model explicitly: "match the rendering style and lighting of the reference image" and feed in the previous approved scene.

## Examples of what to avoid

- **Faces of Prophet or Imams visible.** Hard refusal.
- **Modern Iranian/Pakistani/Arab dress** — the imagery should evoke 7th century, not 21st.
- **Cinematic stills from Mel Gibson's Passion / Hollywood epics.** The tradition we're evoking is different and more reverent.
- **Flag designs from modern political movements.** Use historically-inspired banners (black, green, white — no modern emblems).
- **Anything that looks like a history documentary reenactment** — we want painting, not reenactment photography.
- **Bloody / graphic violence** — Karbala is tragic but never graphic. Suggest through composition.
