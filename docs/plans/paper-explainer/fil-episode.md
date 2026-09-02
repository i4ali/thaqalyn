# Paper explainer - Episode 3: "The Year of the Elephant" (al-Fil)

Format: papercraft-diorama explainer (Paper Planet mechanics: one sentence = one shot = one
literal prop; dry single voice; no music; page-to-world opener; small all-caps captions). Tone:
wonder. Sacred figures are never shown: no Prophet, no infant, no cradle, no Ahl al-Bayt.
Abraha's soldiers, the Quraysh crowd and Abd al-Muttalib may appear only as faceless low-poly
paper silhouettes, never as a lone hero figure that could be read as the Prophet.

Occasion: mawlid week 1448 (12 Rabi al-Awwal ~25 Aug, 17 Rabi al-Awwal ~30 Aug 2026). The
episode never gives a birth date, only the year, so it serves both dates.

Target: 10 shots, ~88 s, ~220 words at ~150 wpm. 9:16, 1080x1920. No end card, no CTA.
Generators: LOCAL ONLY (user rule 2026-08-28): Qwen-Image-2512 stills via `qwen_image.py`,
Wan 2.2 I2V via `run_i2v.py`, Depth-Anything parallax. No Nano Banana, no Higgsfield.
VO: ElevenLabs Bear (`ELEVENLABS_API_KEY_OLD`) else Brian.

Why this for social: a war elephant that refuses to walk, birds carrying pebbles, an army that
ends as chewed straw - and the twist lands on two words in the first verse. The hook is the
calendar: the year had a name before it had a number.

Sources: Surah 105 (text counted on quran_data.json: 5 verses; كَعَصْفٍ مَّأْكُولٍ is two words);
the audited `Thaqalayn/Thaqalayn/Data/tafsir_105.json` (al-Mizan / Majma al-Bayan layers:
Am al-Fil as the Arabs' dating reference, ababil = successive flocks, sijjil = baked-clay stones,
Abd al-Muttalib's "the House has its own Lord" exchange, the miracle in the Prophet's birth
year); Ibn Ishaq's Sira (Guillaume tr. pp. 21-28) for the narrative beats: al-Qullays cathedral
in Sana'a and the aim of diverting Arab pilgrimage, the elephant Mahmud, the seizure of Abd
al-Muttalib's 200 camels at al-Mughammas, "I am the lord of the camels; the House has a Lord who
will defend it" (أنا رب الإبل وإن للبيت ربا سيمنعه), Quraysh withdrawing to the hilltops, the
elephant kneeling when faced toward Mecca and rising when faced toward Yemen, birds from the sea
carrying a stone in the beak and two in the claws, Abraha fleeing and dying at Sana'a; Majma
al-Bayan and Bihar al-Anwar vol. 15 carry the same narrative on the Shia side. "Fifty days" is
Ibn Ishaq / al-Tabari's interval between the elephant and the birth (Bihar 15 records 55 days);
the VO attributes it to "the sira". 570 CE is the conventional approximation, said as "five
seventy" only to contrast with the named year. Note: tafsir_105.json is machine-drafted, so
every beat above was re-checked against Ibn Ishaq / Majma al-Bayan, not taken from the JSON.

---

## Voiceover (one line per shot; plain spelling, no diacritics)

1. The year the Prophet was born, the Arabs did not call it five-seventy. They called it the Year of the Elephant.
2. In Yemen, a governor named Abraha built a cathedral of marble and gold, and wanted the Arabs to make their pilgrimage there instead of Mecca.
3. When they would not, he marched on the Kaaba with an army and a war elephant to pull it down.
4. Outside Mecca his soldiers seized the herds, two hundred camels among them belonging to the city's chief, Abd al-Muttalib.
5. He went to Abraha for his camels, and Abraha was astonished: you ask for camels, and not for the House I came to destroy?
6. He answered: I am the lord of the camels. The House has a Lord of its own, and He will defend it.
7. At dawn they turned the elephant toward Mecca, and it knelt. They beat it; it would not rise. Turned toward Yemen, it stood and walked.
8. Then birds came in from the sea, flock after flock, each carrying small stones in beak and claws.
9. The Quran gives what was left of the army two words: ka-asfin ma'kul. Like straw that has been eaten.
10. Fifty days later, the sira says, a boy was born in that valley. When this surah came to him, it did not say the Lord of the House. It said: your Lord.

Word count: ~220 (~88 s).

Line-by-line sourcing:
| Line | Source |
|---|---|
| 1 | Am al-Fil as the Arabs' era / reference year (tafsir_105 layer1; Ibn Ishaq; Majma al-Bayan). Birth in that year: Ibn Ishaq, Kulayni (al-Kafi 1:439), Bihar 15 |
| 2 | al-Qullays in Sana'a; Abraha's aim to divert the pilgrimage (Ibn Ishaq; retold in Majma al-Bayan on 105) |
| 3 | March with the army and the elephant Mahmud, vow to demolish the Kaaba (Ibn Ishaq; Majma al-Bayan) |
| 4 | 200 camels of Abd al-Muttalib seized at al-Mughammas (Ibn Ishaq; tafsir_105 layer4 confirms the camel exchange) |
| 5 | Abraha's astonishment, verbatim beat (Ibn Ishaq; Majma al-Bayan) |
| 6 | "I am the lord of the camels; the House has a Lord who will defend it" (Ibn Ishaq; Majma al-Bayan; tafsir_105 layer4) |
| 7 | Elephant kneels toward Mecca, beaten with goads, rises toward Yemen (Ibn Ishaq). Nufayl's whisper omitted for length |
| 8 | Birds from the sea in successive flocks (ababil - Majma al-Bayan, tafsir_105 layer2), stone in beak and two in claws (Ibn Ishaq) |
| 9 | 105:5 كَعَصْفٍ مَّأْكُولٍ, two words; "eaten straw" (al-Mizan, tafsir_105) |
| 10 | 50 days: Ibn Ishaq / al-Tabari (Bihar 15: 55) - attributed to "the sira"; 105:1 rabbuka "your Lord" (al-Mizan: the personal address); the surah is early Meccan, sent to the Prophet |

Respectful-language / depiction rules applied: no birth scene, no infant, no cradle; Abd
al-Muttalib appears only as a faceless silhouette standing among camels (never alone in the
Kaaba's doorway); "your Lord" is the Quran's own phrase.

---

## Shot list (EVENT = what a viewer can describe in one sentence, start -> end)

| # | Type | Scene (the prop) | In-scene text | EVENT (Wan) / drift (PLX) |
|---|---|---|---|---|
| 1 | HERO | Open papercraft mushaf on a walnut desk (series book, `--ref style_ref_book.jpg`); rising from the page, a paper desert with a small paper Kaaba far off and, in the foreground of the page, one large kraft-paper war elephant with a paper howdah, a column of faceless paper soldiers behind it. | Page header: سُورَةُ الْفِيل | Slow push-in toward the page; as the camera closes, the elephant and column lift up off the flat page into standing relief (pop-up book opening) -> ends with the paper desert filling the frame. Book and desk still. |
| 2 | HERO | Paper Sana'a: a tall papercraft cathedral of white marble card with gold-leaf dome and arches, on a hill above small kraft houses; a paper camel caravan on the road below walking AWAY from it, toward the horizon. | Small carved plaque on the facade: الْقُلَّيْس | The cathedral rises layer by layer out of the ground (pop-up growth) while the caravan drifts off toward the horizon -> ends with the cathedral tall and the road empty. Camera: slow tilt up. |
| 3 | HERO | Long column of faceless paper soldiers and one large paper elephant crossing layered sand dunes, spears as paper slivers, banners; a tiny paper Kaaba far off at the top of the frame. | Banner: أَبْرَهَة | Column advances up the dune toward the Kaaba, banners lift and flap, blown sand streams off the dune crests -> ends with the elephant crested on the ridge. Camera: slow lateral dolly. |
| 4 | PLX | A corral of paper spears planted in the sand holding a herd of kraft-paper camels (foreground spears, mid camels, background army tents and the elephant's back). Deep 3-layer scene. | none | Slow push through the spears (zoom 0.14 / parallax 0.06, `move` push). |
| 5 | HERO | Abraha's pavilion: a large paper tent of striped card with an empty gold-leaf throne under its canopy, tent walls and pennants of thin paper; before it, ONE faceless kraft silhouette (Abd al-Muttalib) with a paper camel behind him, and a row of faceless soldiers at the sides. | Pennant: أَبْرَهَة | Wind rises: the tent walls billow and the pennants lift and stream, the canopy fringe sways -> ends with cloth still streaming. Figures still. Camera: slow push-in. |
| 6 | HERO | The paper Kaaba alone in a paper valley at low sun with the words لِلْبَيْتِ رَبٌّ standing as huge upright papercraft letters beside it (Hud s06 pattern); on the hillsides, small faceless paper crowds climbing away from the city. | لِلْبَيْتِ رَبٌّ | The crowds drift away up the hills and out of frame while the long shadows of the letters swing as the sun moves -> ends with the valley empty except the Kaaba and the words. Camera: slow low orbit. |
| 7 | HERO | Dawn road outside Mecca: the large paper elephant standing on the road facing the city, faceless paper soldiers with paper goads on both sides, the Kaaba small in the distance. | none | The elephant lowers to its knees and settles on the ground (start standing -> end kneeling), soldiers still. Camera static. Fallback if Wan only "rises": prompt the rise and REVERSE the clip. |
| 8 | HERO | The same dunes and army from a low angle, sky filled with a flock of small paper birds (swallow shapes) sweeping in from the sea on the horizon, tiny paper pebbles falling. | Verse card at the foot of frame: طَيْرًا أَبَابِيلَ | The flock sweeps across the sky toward the camera in successive waves and pebbles rain down onto the dunes -> ends with the sky full of birds. Camera: slow tilt up. |
| 9 | HERO | The dunes after: the ground littered with shredded, chewed paper straw, a broken paper standard, the elephant gone, the Kaaba untouched in the distance. | Verse card: كَعَصْفٍ مَّأْكُولٍ | Wind blows the straw across the dunes and away, the broken banner strip lifts and flutters -> ends with the sand nearly bare. Camera: slow pull-back. |
| 10 | HERO | Bookend of shot 1: the open mushaf on the desk, but the page now shows the paper valley at dawn with the Kaaba small and gold-lit, birds settled on the hills, no elephant, no army; gold light across the page. | Page: سُورَةُ الْفِيل and beneath it أَلَمْ تَرَ | Light warms across the page (dawn glowing up) as the camera pulls back to reveal the whole book and desk -> ends with the book closed-frame and glowing. Everything else still. |

Hero count: 9 of 10 (minimum 5). Shot 4 is the only parallax and it is a genuine deep scene
(spears / camels / tents). If render time bites, shots 3 and 5 are the ones that could drop to
parallax without losing an event that the VO names; all others name an action.

Caption style: reference-matched (all-caps, Avenir Next Condensed Heavy, word reveal, low
third). Title card over shot 1: THE YEAR OF THE ELEPHANT.

---

## Style block (locked, prepended to every still prompt)

Handmade papercraft diorama photographed with a macro lens, tilt-shift shallow depth of field,
soft warm studio light. Everything is cut from layered cream, sand and kraft card with visible
paper fibre and tiny cast shadows at every layer edge. Any figures are simple low-poly paper
silhouettes with no faces. Accent palette: deep emerald and gold leaf. Vertical composition,
dark warm bokeh background.

Reference image: `assets/style_ref_book.jpg` with `--ref` on shots 1 and 10 only.

---

## Motion plan

- Wan 2.2 Lightning, 81 frames. Tests at 480x832 (3-7 min each), finals at 720x1280 (~34 min
  each; 9 heroes ~5 h queued back to back). Frame-sheet every test and every final.
- Events that play to Wan's strengths: lifting/growing (s01 pop-up, s02 cathedral), cloth and
  wind (s05, s03 banners), drifting away (s02 caravan, s06 crowd, s09 straw), light warming
  (s10), swinging shadows (s06), falling (s08 pebbles). The two risks are s07 (kneel = a
  downward settle; plan A prompt the kneel, plan B prompt "the elephant rises to its feet" and
  reverse) and s08 (a flock "toward camera" - if Wan sends it away, reverse).
- Retry budget per hero: 3 at 480p, then 2 at 720p; each retry changes the event wording or
  seed. Any hero still without its event -> Gate 3 stop.

## Arabic-on-prop risk (local stills)

Qwen-Image-2512's Arabic rendering is unproven here (PoC pending). Every Arabic string above
gets checked at full resolution on the contact sheet. If a string is malformed: retry with the
text isolated on a flat card, then Edit-2511 with a rendered-text reference; last resort is to
generate the prop blank and composite the Arabic with ffmpeg drawtext (Amiri / KFGQPC) on a
flat, front-facing card region. Never a paid generator.

## Production

1. Stills: 10 x Qwen-Image local (`gen_stills.sh`, ~1 min each). Contact sheet -> Gate 2.
2. VO: `vo.py --lines lines.txt` (Bear), send mp3 with the contact sheet; re-record if
   "Abraha" / "Abd al-Muttalib" / "ka-asfin ma'kul" are mispronounced.
3. Hero motion: 9 x Wan (tests, then finals). Gate 3 with frame sheets.
4. Assemble: `assemble.py --episode output/paper-explainer/fil` (animatic first).

---

## Build log (2026-08-28)

- Gate 1 approved as written; user rulings: local models only (no Nano Banana), Arabic as text
  overlay (not generated in-scene), straight to 720p (no 480p tests), silhouette of Abd
  al-Muttalib allowed, hard stop after stills for review.
- Stills: 10 x Qwen-Image-2512 (Lightning 8-step, ~1 min each; the Edit-2511 bookends ~1.5 min).
  Retakes: s05 (v1 figure had a face -> v2 "smooth blank head", also posed from behind), s07 (v1
  was a pink asphalt road with lane markings and an emerald Kaaba -> v2 "sandy track of plain tan
  card, no paved road, matte black card"), s09 (v1 kept two soldiers -> v2 "completely deserted,
  not a single figure"; v2's Kaaba rendered as an open-topped box -> v3 via Qwen-Image-Edit-2511
  "make the cube a solid closed cube... remove the tiny grey figures", which changed only those
  two things). s01: Qwen wrote its own gold Arabic on the page header despite "no text" ->
  cv2.inpaint over a gold-hue mask, then the real heading overlaid.
- Arabic overlay tool: `scripts/overlay_arabic.py` (PIL + raqm, GeezaPro, gold #d4af37 / page gold
  #c9a227, soft shadow, `--rotate` to follow a tilted page; `--canvas WxH` emits a transparent PNG
  for post-motion overlay on clips). Lesson: with raqm available, feed RAW Arabic with
  direction=rtl; pre-shaping with arabic_reshaper + bidi mirrors the glyphs.
  Placement: s01/s10 heading baked into the still before I2V (it must move with the page);
  s06 words and s08/s09 verse cards composited on the finished clips, in the dark bokeh band
  (gold over the bright straw/sea was unreadable).
- Qwen style drift: most mid-episode scenes were rendered on stacked pages / a book base, so the
  whole episode reads as one pop-up book. Accepted at Gate 2.
- VO: Bear unavailable on both keys (old key 142 credits left; main key's tier cannot use that
  voice) -> Brian. 83.9 s, lines 5.7-10.6 s.
- Gate 2 approved. Heroes queued 22:59 in risk order (s07 kneel, s08 birds, s01, s06, s09, s03,
  s05, s02, s10); 121 frames for lines over 8 s (s02, s05, s07, s09, s10), 81 for the rest, seed 7.
  The Qwen-flagged ComfyUI (bf16 UNet / fp32 VAE) was stopped first so run_i2v.py could start
  it with --fp16-unet --fp16-vae; --keep-server on every call so the 67 GB stays resident.
- Hero results (720p, 2026-08-29): s07 kneel PRESENT (121f, 67 min; the elephant kneels then
  rises again, which acts out the full line). s08 birds PRESENT (81f, 37 min; flock sweeps,
  pebbles land on the sand). s01 take 1 FAILED: 4 good frames of slight march + push-in, then
  the dune layers fold up and swallow the elephant (Wan's page-turning habit); reversed it is a
  pop-up reveal but the middle frames are torn-paper chaos -> kept as `s01_take1.mp4` fallback,
  retry queued with a light-rising event + "pages never lift or turn", seed 23.
- s01 retry (seed 23, light-rising event) PRESENT: gold light rises across the page as the
  column marches and the camera pushes in; the right page starts to curl with a glare after
  frame ~70, so the clip is trimmed to 70 frames (4.4 s -> 7.2 s line = 1.65x, within the 2x
  rule, event fully inside the kept part). Full take kept as `s01_r2_full.mp4`.
  s06 crowds PRESENT (figures climb the hills, foreground group walks, slow orbit).
- s09 straw PRESENT (121f; banner streams and reshapes throughout, straw shifts, slow pull-back).
- s03 march PRESENT (81f; elephant strides up the dune toward the Kaaba, column follows, sand
  puffs, lateral drift).
- s05 take 1 WEAK: bunting sways and curtains shift (mean frame diff comparable to s09) but it
  reads as a drift at a glance -> kept as `s05_take1.mp4`, retry queued with "strong gust,
  curtains blow open wide, bunting flaps wildly", seed 31.
- s02 caravan PRESENT (121f; camels and figures walk off along the road, dome flares gold, tilt up).
- s05 retry (seed 31, "strong gust") PRESENT: curtains blow open and fly sideways, bunting swings.
- s10 take 1 FAILED: dawn glow for ~55 frames, then the page flips over the scene and the heading
  vanishes (3.4 s usable vs a 10.6 s line). Kept as `s10_take1.mp4`; retry queued with the s01
  fix ("pages never lift, curl or turn", seed 23), 121f.
- Animatic built 09:24 (86.3 s, all-parallax stand-ins, captions + title card OK). s04 parallax
  (zoom 0.14 / parallax 0.06, push) visibly moves: mean frame diff first->last 47, spears shift
  against the camels. Preview sent to the user for pacing.
- s10 retry 2 (seed 23, pull-back) FAILED the same way (page flips frames ~45-100, heading lost;
  ~2.5 s clean). Kept as `s10_take2.mp4`. Retry 3 queued: camera near-static / gentle push-in,
  sun-brightening + bird-lift event, "rigid pop-up book glued flat", seed 41.
- 10:31 pre-render `fil_pre.mp4` with the 8 passed heroes (s10 stand-in) via `--reuse` after
  deleting the hero stand-ins from work/ - 2 min. Line windows incl. gaps: s01 8.23 s (4.4 s clip
  = 1.88x, OK). User ruling 10:0x: "just show me the final video when it's ready" = Gate 3
  delegated to the self-audit; assemble without a further stop once every hero has its event.
- s10 retry 3 (seed 41, near-static camera + gentle push-in, sun-brightening + bird-lift event,
  "rigid pop-up book glued flat") PRESENT: glow floods the valley, birds lift, page and heading
  hold for all 121 frames. Lesson: on the book bookends Wan flips the page whenever the camera
  PULLS BACK; a push-in / near-static camera with a light event holds the book (s01r2, s10r3).
- FINAL 11:36: `output/paper-explainer/fil/fil_final.mp4` (1080x1920, 24 fps, 86.3 s, 54 MB),
  preview `fil_final_preview.mp4` sent. 9 heroes + 1 parallax, all events present at 720p.
  Total Wan time: 12 renders (9 + 3 retries) ~12.5 h wall clock on the M3 Ultra, unattended.
- Lessons: (1) Qwen-Image ignores "no text" on book pages - plan to inpaint headers; (2) Qwen
  puts most scenes on a book/page base, which reads as a consistent pop-up-book world;
  (3) Qwen-Image-Edit-2511 with the still as --ref makes surgical fixes (close a cube, remove a
  figure) without touching the rest; (4) 121-frame clips cost ~65-70 min at 720p, 81-frame
  ~37 min; (5) assemble --reuse after deleting the hero stand-ins turns the final into a 2-min
  step; (6) the user reads the all-parallax animatic as "still images" - send hero clips, not the
  animatic, when demonstrating motion.
- 17:07 user review of the final: in s01 the soldiers face left but drift right ("walking
  backwards") while the elephant walks correctly. Reversal impossible (elephant + light would
  invert). Re-rendering s01: (a) soldiers "march in exactly the same direction the elephant
  walks, toward the left, never backward", (b) soldiers "stand perfectly still", both seed 23,
  81f. Lesson: name the direction of EVERY moving group in the prompt, relative to a scene
  anchor, or Wan may animate a crowd against its facing.
- 17:45/18:22 both s01 re-renders failed: (a) soldiers turned to face the camera + page curl,
  (b) "stand perfectly still" ignored, soldiers turned again, page flipped at ~3 s. Wan will
  not leave a standing crowd alone on a book page. Fix: remove the failure mode - Edit-2511
  "remove the column of soldiers" on the clean s01 still (`s01_book_elephant_v2.png`), heading
  re-overlaid, render r4 with the r2 prompt minus soldiers (seed 23). NOTE: Qwen-Image on the
  Wan-flagged server (--fp16-unet) returns a BLACK image - restart with qwen_image.py
  --restart-server for edits, then stop it again before Wan.
- s01 r4 (elephant only, seed 23) PRESENT: light rises, elephant walks left, push-in (scale
  1.0 -> 1.125), page holds all 81 frames; the baked heading washed out after frame ~55 under
  the glow, so the heading was re-composited on every frame with a per-frame similarity
  transform (ORB + estimateAffinePartial2D against frame 0) - stays locked to the page.
  FINAL v2 19:1x rebuilt via --reuse; 720p/1080p delivery encodes refreshed.

## Nano Banana pass (2026-08-29 evening)

- User rejected the flat Arabic overlays vs Kawthar's in-scene embossed heading; two overlay
  iterations (thuluth + perspective quad + foil / blind emboss) were stopped by the user.
  Rule revised: stills may use Nano Banana Pro; motion stays local. Resolution: 1K == 2K on
  this model (~768 px wide), 4K needed for crisp Arabic; ~$0.24 vs ~$0.13.
- Regenerated only the Arabic-bearing shots at 4K (s01, s06, s08, s09, s10; $1.20), Arabic in
  the prompts (Hud pattern). All five strings correct at full res. s01 printed a faint
  duplicate heading on the rear page -> cv2.inpaint on a tight gold-hue box. s06 now has the
  words as giant standing gold letters (like Hud s06) instead of a sky overlay.
- Wan batch launched 20:05 on the NB stills with the prompts that passed before (s01 r4,
  s06, s08, s09, s10 r3), 720p, keeping the 5 passed Qwen-based clips (s02, s03, s05, s07 +
  s04 parallax).
- NB heroes: s01 take 1 FAILED (page flips at ~2 s) -> retry seed 41 with the s10-r3 wording
  PRESENT (light rises, elephant walks, page holds; small glare bloom at the page top).
  s06 PRESENT (orbit + figures walking, gold letters intact). s08 PRESENT (flock wheels, pebbles
  fall, card legible). s09 PRESENT (gust throws straw and sand, banner reshapes, card legible).
- s10 NB PRESENT (sun swells to full glow and eases back, page and both headings hold).
- FINAL v3 00:45 2026-08-30: 5 NB heroes + 5 kept Qwen-based shots, rebuilt via --reuse;
  720p/1080p encodes refreshed and 720p sent. Open point: in s08 the in-scene verse card sits
  in the caption band, so the caption overlaps it for part of the line.
