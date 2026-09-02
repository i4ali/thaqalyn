# Paper explainer - Episode 1: "The surah that grayed him" (Hud)

Format: papercraft-diorama editorial explainer (Paper Planet mechanics: one sentence = one
shot = one literal prop; dry single voice; no music; page-to-world opener; captions all-caps
white with outline, phrase reveal). Tone: wonder, not sarcasm. Sacred figures are never shown
(no Prophet, no prophets); only objects, places, and faceless paper crowds/companions.

Target: 9 shots, no end card / no app promotion (pure value), ~80 s, ~185 words at ~150 wpm. 9:16, 1080x1920 final.
Sources: every claim is lifted from the audited `docs/plans/surah-experience/hud-script.md`
(sourcing notes there; Ibn Abbas's causal link stays Ibn Abbas's, never the Prophet's own
explanation; "sisters" never enumerated).

Legend: HERO = local Wan 2.2 image-to-video (real motion). PLX = 2.5D depth parallax from the
still (camera drift only). Every shot starts as a Nano Banana Pro 4K 9:16 still in the locked
style (see Style block).

---

## Voiceover (final wording; ﷺ stripped for TTS, kept in captions if the font has it)

1. When his companions asked the Prophet why gray had hurried into his hair, he did not name a grief, and he did not name an enemy. He named a surah.
2. Surah Hud. One hundred and twenty-three verses, sent down all at once, in the hardest years in Mecca.
3. On the surface it is seven stories: Nuh, Hud, Salih, Ibrahim, Lut, Shu'ayb, Musa. Seven men, each sent to a people who did not want him.
4. Nuh builds an ark on dry ground while his people laugh, and when the water finally comes, it takes his own son.
5. But floods do not gray a man. Ibn Abbas, who knew him, pointed to a single verse instead.
6. Verse one hundred and twelve. Fa-staqim: stand firm, exactly as you were commanded, and everyone who turned with you.
7. Ibn Abbas said no verse ever came down on him harder than this one. That is what showed in his hair.
8. Then, three verses from the end, the surah says why the seven stories were told: so that We may make your heart firm.
9. The surah that grayed him was built, story by story, to hold him up. Both are true. They were never in tension.
(Line 10 / app end card DROPPED 2026-08-27 by user decision: keep the episode pure value, no promotion. The recorded VO line is trimmed off in assembly.)

Word count: ~185.

---

## Shot list

| # | Type | Scene (the prop) | In-scene text | Motion prompt (Wan) / drift (PLX) |
|---|---|---|---|---|
| 1 | HERO | Open papercraft mushaf on a walnut desk; from the page rises a miniature paper Mecca at night: cube-shaped Kaaba with a paper kiswa, low paper houses, paper hills, a paper crescent. Same book as the test still (emerald + gold cover). | Page header: سورة هود | Slow push-in toward the page until the paper city fills the frame, then settles. Book and desk still. |
| 2 | PLX | Paper Mecca at dusk from above; one tall rolled paper scroll descending straight down from a paper sky in a single piece, tied with a gold thread, casting a long shadow over the city. | Scroll edge: ١٢٣ (small) | Slow downward drift, slight push. |
| 3 | PLX | Seven paper banners on poles planted in a line across a paper desert, each banner carrying one name; before each banner a small crowd of faceless paper figures turned away, backs to the pole. | Banners: نوح · هود · صالح · إبراهيم · لوط · شعيب · موسى | Slow lateral dolly along the line. |
| 4 | HERO | A paper ark on cracked dry paper ground; a crowd of faceless paper figures pointing and doubled over laughing at its foot; on the horizon a wall of layered paper wave under paper storm clouds. No figure on the ark. | none | The wave rolls forward and rises, clouds drift, the laughing crowd freezes, then holds. Camera static. |
| 5 | PLX | A paper library nook: an open paper book on a stand, one line of the page raised as a card; a paper hand (sleeve only, faceless, out of frame above) pointing at that line; stacked paper volumes behind, one spine labelled. | Card: ١١:١١٢ · Spine: مجمع البيان | Slow push-in on the card. |
| 6 | HERO | The word فَاسْتَقِمْ as huge upright papercraft letters standing in a paper desert at low sun, long shadows; behind them, in the letters' shade, a long row of small faceless paper figures standing straight. | فَاسْتَقِمْ | Slow low orbit around the letters, light warms, eases to a stop. Figures still. |
| 7 | PLX | A papercraft balance scale on a table; left pan holds a single small paper verse card and is fully down; right pan holds a heap of paper stones (unlabeled) and is up. | Card: ١١٢ | Slow push-in on the low pan. |
| 8 | PLX | A large papercraft heart, layered card, held up from beneath by seven paper pillars; each pillar is a rolled scroll; soft gold light from above. | Small tag: ١١:١٢٠ | Slow rise (tilt up) with gentle parallax. |
| 9 | HERO | Back to the open mushaf on the desk (bookend of shot 1), but the paper city inside is now at dawn, gold light across it; camera pulls back to reveal the whole book and desk. | سورة هود | Slow pull-back that settles. Everything else still. |

Caption style: reference-matched (all-caps white, dark outline, low third, phrase reveal from
MMS word timings). Title card in the first 2 s over shot 1: THE SURAH THAT GRAYED HIM.

---

## Style block (locked, prepended to every still prompt)

Handmade papercraft diorama photographed with a macro lens, tilt-shift shallow depth of field,
soft warm studio light. Everything is cut from layered cream, sand and kraft card with visible
paper fibre and tiny cast shadows at every layer edge. Figures are simple low-poly paper
silhouettes with no faces. Accent palette: deep emerald and gold leaf. Vertical 9:16
composition, dark warm bokeh background.

Reference image for consistency: `still_01_book.png` (passed with `--ref` on shots 1, 9, 10).

---

## Production

1. Stills: 10 x Nano Banana Pro 4K (~$2.40). Contact sheet -> user approval before motion.
2. HERO shots (1, 4, 6, 9): local Wan 2.2, iterate at 480x832/49f (~3 min), finals at
   720x1280/81f (~34 min each, batched). Hero shots may be trimmed to the VO line length.
3. PLX shots: Depth Anything V2 -> 4-layer parallax -> ffmpeg (to be built; free, seconds).
4. VO: ElevenLabs, Bear voice, eleven_v3, one continuous read; split per line by timestamps.
5. Captions: MMS forced alignment -> phrase reveal drawtext, reference style.
6. Assemble: ffmpeg concat at 1080x1920, 24 fps, VO only (no music), end card 3 s.

---

## Build log (2026-08-27)

- Final: `output/paper-explainer/hud/hud_final.mp4` (1080x1920, 24 fps, 79.6 s, VO Brian).
- Hero clips (720x1280, 81f, seed 7, Lightning 4-step): s01 push-in + city lights up (Wan added
  the lights itself; kept), s04 wave rolls forward, s06 low orbit with swinging shadows, s09
  pull-back with a gentle sun glow ("no glare" in the prompt tamed the 480p test's rays).
- Timings: 480p tests 3-6 min compute each; 720p finals ~34 min compute each, ~2.3 h for four
  queued back to back. Running parallax on MPS at the same time slows Wan ~2x.
- Lessons: ElevenLabs Bear needs the paid key (quota exhausted this month) -> Brian fallback;
  caption phrases break on punctuation (<=28 chars, closing word may join); trailing recorded
  lines can be dropped at assembly (audio is cut after the last used line); app end card
  dropped by user decision - episodes end on the bookend shot.
