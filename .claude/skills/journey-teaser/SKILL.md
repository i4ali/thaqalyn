---
name: journey-teaser
description: Generate a ~37s TikTok journey teaser video for any surah from its cover art - story beats, verse, journey tease, download CTA - rendered entirely with ffmpeg (zero Higgsfield credits). Use when asked for a surah/journey teaser, promo, or TikTok video from the cover artwork.
argument-hint: [surah name] [optional creative notes]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, SendUserFile
---

# Journey Teaser

Produce a TikTok-ready teaser (1080x1920 @ 30fps, ~37.4s) for one surah's "Inside the Surah" journey, built from its cover master in `assets/premium-art/covers/`. The entire video is rendered with ffmpeg - **never call any Higgsfield tool or spend credits in this skill**. The reference episode is Surah Yunus (`assets/premium-art/tiktok/yunus_ep1_draft.mp4`, config values preserved in `build_yunus_ep1.py`).

## Fixed format (do not restructure)

| Seg | Dur | Content |
|---|---|---|
| S1 | 3.5s | Hook on black: descending light wisp + 2 title cards |
| S2 | 6.0s | Beat 1 - art comes alive (push-in + pulsing glow), 2 lines |
| S3 | 7.5s | Beat 2 - deeper drift, 3 lines (3rd is the gold punch) |
| S4 | 7.0s | The verse - darker grade, Arabic + English translation |
| S5 | 4.5s | The turn - pull back/rise, resolution line + gold question |
| S6 | 7.0s | Journey tease - blurred veil (the app's reader-veil look), 3 movement titles + subs + gold closer |
| S7 | 5.5s | End card on veil - rounded poster, "Continue the journey in the app.", DOWNLOAD THE APP pill, brand line |

S7 is hardcoded in the builder and never changes. 0.6s crossfades; free ambient audio bed (deep rumble + low drone) is generated automatically.

## Workflow

### 1. Resolve inputs
- Parse the surah name from `$ARGUMENTS`; any extra text is creative direction.
- Find the cover master: `Glob assets/premium-art/covers/cover_*.png` (naming: `cover_maida.png`, `cover_anam.png`... - no "al-" prefix, no apostrophes). If the surah has no cover yet, stop and tell the user (covers program status lives in `assets/premium-art/covers/jobs.md`).

### 2. Research the story
- If the journey exists in-app, mine it: `Thaqalayn/Content/Surah<Name>Dive.swift` and `docs/plans/surah-experience/` give the framing, act/movement names, and the climactic verse. The tease movements should mirror the real acts when they exist.
- If no journey exists yet, author from the surah's core narrative (the cover's subject line in `jobs.md` states its theme). Movements = a 3-act arc of the surah, named like chapters.

### 3. Write the copy
Voice rules (non-negotiable):
- **Narrator voice only** - reverent second/third person. Never first-person character POV ("I was there" was explicitly rejected by the user).
- No price, premium, unlock, or subscription language anywhere.
- No em dashes (use " - "), plain English spelling, no transliteration diacritics.
- Never depict or voice the Prophet or Imams; prophets are referred to respectfully in third person. Quran quotes must be verbatim (real Arabic; translation faithful).

Copy slots:
- `hook`: 2 lines. Line 1 = the most arresting true fact of the surah (<= 32 chars). Line 2 (gold) = an open loop the verse segment will pay off (e.g. "What saved him was one sentence.").
- `beat1`: 2 lines - the story begins (line 1 <= 26 chars @ 50px, line 2 <= 42 chars @ 40px).
- `beat2`: 3 lines - deepest point; line 3 is the gold punch (<= 30 chars).
- `verse`: `arabic` (verbatim, with harakat - GeezaPro shapes correctly) + 2 English lines (<= 42 chars each). If the moment is not a quotable verse, set `arabic` to "" and put 2 English lines.
- `turn`: 2 lines - resolution + gold question that sends viewers to the tease ("Do you know why?").
- `tease`: `eyebrow` ("THE JOURNEY  -  SURAH X"), 3 `movements` as [title, sub] pairs (titles "I.  Name" <= 18 chars, subs <= 38 chars, subs must intrigue without spoiling), `closer` (gold, e.g. "Walk it verse by verse.").

### 4. Choose composition points
Thumbnail the cover (`sips -Z 512`) and Read it, then set:
- `crop_x`: x-offset of the 1296px-wide 9:16 slice of the 1856x2304 master (280 = centered; shift if the subject is off-center).
- `glow`: the warm light's position in the final 1080x1920 frame (usually x=540, y 1100-1200 for covers with a low light source).
- `s2_focus` (0-1 vertical focus, ~0.58), `s3_focus` [start, end] drifting toward the subject, `s4_focus` (tight on the light), `s5_focus` [start, end] rising toward the sky.

### 5. Build
Write the config JSON to the scratchpad, then:
```bash
python3 .claude/skills/journey-teaser/scripts/build_teaser.py \
  --config <scratchpad>/teaser_config.json \
  --workdir <scratchpad>/teaser_work \
  --out assets/premium-art/tiktok
```
Output: `assets/premium-art/tiktok/<slug>_teaser.mp4`. Heed any `WARN` lines about caption width (shorten the line or it will crowd the margins). Requires ffmpeg 8+ with harfbuzz (homebrew build has it).

### 6. QC (mandatory before delivering)
Extract frames and **Read every one**:
```bash
for t in 1.8 5.5 12 19 24 27.5 30 34.5; do
  ffmpeg -y -loglevel error -ss $t -i <out>.mp4 -frames:v 1 -vf scale=405:720 qc_$t.png
done
```
Checklist:
- Every caption readable against its background (border + shadow are automatic; if a line sits on a bright area, move its `y` or re-time it).
- Arabic is shaped and ordered correctly (joined letters; first word at the RIGHT).
- All text inside safe areas: y 300-1450, x 90-990 (TikTok top tabs, right rail, caption zone stay clear).
- End card: poster, CTA line, pill, brand line all legible over the dimmed veil.
- No first-person POV, no price/premium wording, no em dashes anywhere on screen.
Fix config, rebuild, re-QC until clean.

### 7. Deliver
- Copy the config JSON next to the video as `assets/premium-art/tiktok/<slug>_teaser_config.json` (reproducibility).
- `SendUserFile` the mp4 with a one-line caption.
- Report: the copy arc, any QC fixes made, and the upgrade path (Kling motion on S2-S5 + a narrator voice via Higgsfield later, ~30-35 credits) - but do not act on it.

## Reference config (Yunus)

```json
{
  "slug": "yunus",
  "src": "assets/premium-art/covers/cover_yunus.png",
  "crop_x": 280,
  "glow": {"x": 540, "y": 1150},
  "s2_focus": 0.58,
  "s3_focus": [0.45, 0.72],
  "s4_focus": 0.66,
  "s5_focus": [0.40, 0.18],
  "hook": ["A prophet was swallowed alive.", "What saved him was one sentence."],
  "beat1": ["The sea closed over him.", "And beneath it, a greater darkness waited."],
  "beat2": ["Three darknesses deep -", "the night, the sea, the whale.", "He did not beg. He confessed."],
  "verse": {
    "arabic": "لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
    "english": ["There is no god but You. Glory be to You.", "I was among the wrongdoers."]
  },
  "turn": ["He walked out of the sea alive.", "Do you know why?"],
  "tease": {
    "eyebrow": "THE JOURNEY  -  SURAH YUNUS",
    "movements": [
      ["I.  The Flight", "A prophet runs from his calling."],
      ["II.  The Depths", "One sentence in three darknesses."],
      ["III.  The Return", "The only city that believed in time."]
    ],
    "closer": "Walk it verse by verse."
  }
}
```
