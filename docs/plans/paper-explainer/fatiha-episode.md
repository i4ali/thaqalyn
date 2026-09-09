# Paper explainer - Episode 4: "The prayer that answers back" (al-Fatiha)

Format: papercraft-diorama explainer (Paper Planet mechanics: one sentence = one shot = one
literal prop; dry single voice; no music; page-to-world opener; small all-caps captions). Tone:
wonder. Sacred figures are never shown: no Prophet, no Imam al-Rida, no Ahl al-Bayt. The only
figures are a faceless paper congregation seen from behind (shot 5).

Target: 9 shots, ~70 s, ~180 words at ~150 wpm. 9:16, 1080x1920. No end card, no CTA.
Generators (user ruling 2026-09-03): stills = Nano Banana Pro 4K via OpenRouter
(`nano_banana.py`, ~$0.24 each, Arabic in the prompts, Hud pattern); motion = LOCAL Wan 2.2
(`run_i2v.py`), parallax only if a shot is demoted at Gate 3. VO: ElevenLabs Bear
(`ELEVENLABS_API_KEY_OLD`) else Brian.

Why this for social: the most-recited words in a Muslim's life, and a hadith qudsi that says
every line of them gets a reply. The hook is a number ("at least ten times a day") and a
withheld fact ("what He says back"). The twist is the mushaf itself: the surah ends on a plea
and the facing page answers it.

Visual grammar: your words are cream card and rise; His words are gold leaf and descend.
One set: a paper prayer mat before a paper mihrab, a paper lamp above. The road (shots 6-7)
unrolls out of the mat.

Sources: every claim is lifted from the audited `docs/plans/surah-experience/fatiha-script.md`
(APPROVED, built in `Thaqalayn/Content/SurahFatihaDive.swift`; sourcing notes there):
the division hadith qudsi "I have divided the prayer between Me and My servant" and the three
replies (Uyun Akhbar al-Rida, via Tafsir Nur al-Thaqalayn; anchors حَمِدَنِي عَبْدِي,
بَيْنِي وَبَيْنَ عَبْدِي, لِعَبْدِي مَا سَأَلَ as shipped in the dive); Umm al-Kitab / al-Sab
al-Mathani (Q 15:87) and "no prayer is complete without it" (orientation beat); the
third-person to second-person pivot at 1:5 as "the heart of the prayer" (al-Mizan, tafsir
layer2 1:5); 2:2 as the answer to 1:6 (climax beat). Quran Arabic verbatim from
quran_data.json. "At least ten times a day" = Fatiha is obligatory in the first two rak'ahs
of each of the five daily prayers (2 x 5 = 10); the count is a floor, so it holds whether the
third and fourth rak'ahs carry Fatiha or the tasbihat.

---

## Voiceover (one line per shot; plain spelling, no diacritics)

1. There is one surah you say at least ten times a day, every day of your life. Most of us have never heard what He says back.
2. Seven verses. It is called Umm al-Kitab, the Mother of the Book, and no prayer is complete without it.
3. In a hadith qudsi passed down from Imam al-Rida, God says: I have divided this prayer between Me and My servant. Half of it is His. Half of it is yours.
4. You say: all praise is for Allah, Lord of all the worlds. And He says: My servant has praised Me.
5. For four verses you speak about Him. At verse five you turn, and speak to Him: It is You we worship. He says: this is between Me and My servant.
6. Then, out of everything a soul could beg for, the prayer teaches you to ask for one thing. Guide us to the straight path.
7. And He says: this is for My servant. And My servant shall have what he asked.
8. Now look where the surah ends. On a plea. And the very next words of the Quran, on the facing page, answer it: This is the Book, without doubt, a guidance.
9. Al-Fatiha is the question. Everything after it is the answer. You have been asking it, and He has been answering, at least ten times a day, your whole life.

Word count: ~185 (~72 s).

Line-by-line sourcing:
| Line | Source |
|---|---|
| 1 | Ten = 2 rak'ahs x 5 daily prayers (floor, see above); "what He says back" = the division hadith (Uyun Akhbar al-Rida) |
| 2 | 7 verses incl. Bismillah (Shia position, tafsir_1 layer2 / Tabrisi); Umm al-Kitab, al-Sab al-Mathani (Q 15:87), "no prayer is complete without it" (orientation beat, fatiha-script.md) |
| 3 | Hadith qudsi, Uyun Akhbar al-Rida via Nur al-Thaqalayn: "qasamtu al-salata bayni wa bayna abdi nisfayn" (fatiha-script sourcing note 1; dive `.response` 1 reflection). Attributed to Imam al-Rida's transmission, not to the Prophet |
| 4 | 1:2; reply "My servant has praised Me" (dive `.response` 1, anchor حَمِدَنِي عَبْدِي) |
| 5 | Pivot at 1:5, "heart of the prayer" (al-Mizan, layer2 1:5; act II divider); reply "This is between Me and My servant" (dive `.response` 2, anchor بَيْنِي وَبَيْنَ عَبْدِي) |
| 6 | Act III divider ("out of everything a soul could beg for... to be shown the way"); 1:6 |
| 7 | Reply "This is for My servant, and My servant shall have what he asked" (dive `.response` 3, anchor لِعَبْدِي مَا سَأَلَ) |
| 8 | 1:6-7 ends on the petition; 2:2 ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ is the first statement after it (climax beat). "Facing page": in a standard mushaf 1:1-7 and 2:1-5 are the opening spread |
| 9 | Climax beat: "Al-Fatiha is the question. The Quran is the answer"; line 1's count |

---

## Shot list v2 (EVENT = what a viewer can describe in one sentence, start -> end)

v1 (lamps, banners, a scroll) was rejected at Gate 1 as visually flat. v2 scales every prop up
and gives each shot weather or a crowd: paper rising, gold falling, a book blooming, a mat
unrolling from the sky, a road crossing a sea, a page turning.

| # | Type | Scene (the prop) | In-scene text | EVENT (Wan) |
|---|---|---|---|---|
| 1 | HERO | Open papercraft mushaf on the walnut desk (series book, `--ref`). Rising from the page, a whole miniature paper city at night: domes, minarets, flat roofs, a paper crescent. From every rooftop, small cream paper cards are lifting into the air, hundreds of them, a column of paper rising above the book. Nothing comes down. | Page header: سُورَةُ الْفَاتِحَة | The cards keep rising from the rooftops and drift up out of the top of the frame while the camera pushes in on the city -> ends with the sky above the city full of rising paper. Book and desk still; pages never lift or turn. |
| 2 | HERO | A paper courtyard; at its centre one open papercraft mushaf, and out of its spine the pages are opening outward in every direction like the petals of a huge paper flower, dozens of cream pages fanning up and out, gold leaf on their edges; the seven verses on the heart of the bloom. | On the flower's heart: أُمُّ الْكِتَاب | The bloom opens: the pages unfold outward and upward like petals until the flower fills the frame -> ends fully open. Camera: slow tilt up. |
| 3 | HERO | Seen from low on a paper plain at night: a gold paper sky above, a small paper prayer mat far below; between them, a colossal prayer mat is unrolling down out of the sky, its upper half gold leaf and its lower half emerald and cream, a gold thread marking the seam; still half-rolled above the ground. | Woven into the seam: بَيْنِي وَبَيْنَ عَبْدِي | The giant mat unrolls down from the sky until its cream end lands on the plain -> ends fully laid from sky to ground. Camera: slow tilt down following the roll. |
| 4 | HERO | The giant mat from shot 3, now laid; on its cream end the words ٱلْحَمْدُ لِلَّهِ stand as upright cream papercraft letters; cream cards lift from around the letters; from the gold sky above, gold paper leaves are beginning to fall. | Letters: ٱلْحَمْدُ لِلَّهِ ; on a large falling gold leaf: حَمِدَنِي عَبْدِي | Cream cards rise from the mat while a shower of gold leaves falls past them onto the mat -> ends with the mat dusted gold. Letters still. Camera: slow push-in. |
| 5 | HERO | A vast paper courtyard filled with hundreds of faceless low-poly paper figures standing on mats, every one of them facing a different direction; at the far end a tall paper mihrab, dark. | Arch: إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ | Gold light bursts from the mihrab and the whole crowd turns to face it -> ends with every figure facing the lit arch. Camera: slow push-in over their heads. |
| 6 | HERO | From the foot of the giant mat a road of cream card runs out across a paper world: over layered dunes, then across a paper sea of curling blue-and-cream wave layers, toward a distant gold paper mountain; the road is only half laid, its far end a tight roll at the shore. | Milestone at the near end: ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ | The road unrolls forward over the sea while the waves roll and break against it, until it reaches the mountain -> ends with the road complete. Camera: slow tilt up following the roll. |
| 7 | HERO | The same road, complete, at dusk, seen from its far end looking back: the mountain's peak above, dark paper lanterns on posts down both sides of the road across the sea, the sun still below the peak. | On a gold banner across the road's arch: لِعَبْدِي مَا سَأَلَ | The sun rises over the peak and gold light pours down the road toward the camera as the lanterns light one after another -> ends with the whole road lit and the sea gold. Camera near-static. |
| 8 | HERO | A flat open papercraft mushaf from above: the right page carries سُورَةُ الْفَاتِحَة with its seven verses; the page is caught mid-turn, lifted and curling toward the left, and under it the next page is already showing سُورَةُ الْبَقَرَة and beneath it ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ in raised gold leaf, glowing faintly. | As described | The lifted page completes its turn and settles flat on the left, and the gold line of 2:2 flares bright -> ends on the Baqara page open and shining. Camera: slow push-in. (Wan turns pages unprompted; here it is the event.) |
| 9 | HERO | Bookend of shot 1: the mushaf, desk and paper city at dawn, a little wider. Cream cards still rise from the rooftops, and now gold paper cards are falling from the sky onto the city, crossing them. | Page header: سُورَةُ الْفَاتِحَة | Gold cards rain down over the city as the cream cards rise, and the dawn light glows up -> ends with the city in full gold light under crossing paper. Camera: gentle push-in, never a pull-back. |

Hero count: 9 of 9. Shots 1 and 9 are the same set: in 1 only cream rises, in 9 gold comes
down too, which is the last line made visual.

Caption style: reference-matched (all-caps, Avenir Next Condensed Heavy, word reveal, low
third). Title card over shot 1: THE PRAYER THAT ANSWERS BACK.

---

## Style block (locked, prepended to every still prompt)

Handmade papercraft diorama photographed with a macro lens, tilt-shift shallow depth of field,
soft warm studio light. Everything is cut from layered cream, sand and kraft card with visible
paper fibre and tiny cast shadows at every layer edge. Any figures are simple low-poly paper
silhouettes with no faces. Accent palette: deep emerald and gold leaf. Vertical composition,
dark warm bokeh background.

Reference image: `assets/style_ref_book.jpg` with `--ref` on shots 1 and 9 only. Continuity:
shot 3's still passed as `--ref` to shot 4 (same giant mat); shot 6's still passed as `--ref`
to shot 7 (same road and sea).

---

## Motion plan

- Wan 2.2 Lightning, 81 frames (121 for lines over 8 s). Test-vs-final policy decided with the
  user after Gate 2. ~34 min per 81f final, ~65 min per 121f; 9 heroes ~6 h queued unattended.
- Events that play to Wan's strengths: lifting / drifting up (s01, s04, s09 cream cards),
  falling (s04 leaves, s09 gold cards), unrolling (s03 mat, s06 road), unfolding / growing
  (s02 bloom), water (s06 waves), light coming on / sun rising (s05, s07, s09), page turning
  (s08, the one thing Wan does unasked). Risks: s05 crowd turn (Fil showed Wan turns crowds
  readily, usually toward the camera, so the mihrab is placed at the far end on the camera
  axis); s08 must keep the Baqara text legible through the turn (retry with "the writing stays
  exactly the same", Kawthar s04 fix).
- Direction is named for every moving thing (Fil lesson). Bookends keep a push-in camera and
  "pages never lift, curl or turn" (Fil s01 r4 / s10 r3).
- Retry budget per hero: 3 at 480p, then 2 at 720p; each retry changes the event wording or
  seed. Any hero still without its event -> Gate 3 stop.

## Arabic-on-prop plan (Nano Banana 4K)

All Arabic is written in the prompts and rendered in-scene (Hud pattern; Fil NB pass
confirmed 4K renders the strings crisply). Every string is checked at full resolution on the
contact sheet; a malformed string is a retake (~$0.24), never an overlay. The seven-line scroll
(s02 bloom heart) and the two-page spread (s08) are the heaviest text loads; if NB garbles a verse there,
the retake reduces the scroll to the seven verse numbers ١ to ٧ with a single legible line.
Watch for a duplicate heading on the rear page (Fil s01) and inpaint it.

## Production

1. Stills: 9 x Nano Banana Pro 4K 9:16 (~$2.16 + retakes). Contact sheet -> Gate 2.
2. VO: `vo.py --lines lines.txt` (Bear, else Brian); send the mp3 with the contact sheet.
   Pronunciation checks: al-Rida, Umm al-Kitab, iyyaka.
3. Hero motion: 9 x Wan 720p (s03, s05 tested at 480p first). Gate 3 with frame sheets.
4. Assemble: `assemble.py --episode output/paper-explainer/fatiha` (animatic first).

---

## Build log (2026-09-03)

- Gate 1: v1 shot list (lamps, banners, scroll) rejected by the user as visually flat; v2
  (city of rising cards, blooming book, giant mat from the sky, gold-leaf rain, crowd turn, road
  over a sea, sunrise, page turn, gold rain bookend) approved with one change: stills at 2K, not
  4K. Measured: the 2K tier now returns 1536x2752 (the "2K == 1K, ~768 px" note in nano_banana.py
  is stale), ~$0.13 each. User ruling mid-run: stop after the stills, no Wan render without approval.
- VO: Bear (OLD key) quota exceeded (34 credits left, 629 needed) -> Brian, 84.7 s, 9 lines
  (7.1 / 8.5 / 12.5 / 7.9 / 11.1 / 8.1 / 4.9 / 11.5 / 10.6 s). Frame plan: 121f for s02, s03,
  s05, s06, s08, s09; 81f for s01, s04, s07.
- Stills (Nano Banana Pro 2K, `gen_stills.sh`): s01 heading correct, city with a rising column
  of cards; s02 bloom with أم الكتاب correct; s03 mat seam بيني وبين عبدي correct.
- Transport trouble with OpenRouter: broken pipes on requests carrying a multi-MB PNG `--ref`
  (s04 twice) and random SSL EOFs (s05 v2, s06). Script fixes in `nano_banana.py`: references
  are downscaled to 1536 px and sent as JPEG; the POST retries 3x with backoff; timeout 900 s.
  After that every request went through.
- Retakes (each ~$0.13): s05 v1 put a lone figure in the mihrab (imam = depiction by
  implication) -> v2 emptied the mihrab but lost the scattered crowd (everyone already faces
  the wall, nothing left to turn), so the plan is v1 with the figure removed (hand patch failed
  on the floor half; Qwen-Image-Edit-2511 local "remove the standing figure"). s06 v1 rendered
  the straight path as a winding road with the sea beside it -> v2 "ruler-straight causeway,
  no bends" is exact; s07 v1 (on the winding s06) also bends -> v2 on s06 v2. s08 v1 grew three
  green-and-gold figure pairs on the pages and scrambled the verse markers -> v2 plain pages,
  clean, but Nano Banana wraps the gold 2:2 line with its last word on the line above (both
  takes). gen_retakes.sh matches ids by prefix, so `s06` also re-rendered the v1 prompt once
  (wasted $0.13; overwrote s06_road_sea.png with a second winding take).
- Gate 2 approved 17:4x: stills as selected (s05 v1 Qwen-edited, s06 v2, s07 v2, s08 v2 kept
  with the wrapped gold line), VO Brian. User rulings: straight to 720p for all nine, and
  "make sure proper animation is there, I don't want to see still/unanimated shots" - every
  hero is frame-sheeted and any clip without its event is re-prompted before assembly.
- Heroes queued (720x1280, seed 7 except s01 23 / s09 41, 121f for s02 s03 s05 s06 s08 s09,
  81f for s01 s04 s07) in risk order: s05, s08, s03, s06, s02, s01, s04, s07, s09.
  The Qwen-flagged ComfyUI was killed first so run_i2v.py starts it with --fp16-unet --fp16-vae.
- Hero results (720p): s05 PRESENT (64 min; mihrab bursts to gold, crowd shifts and turns
  toward it mid-clip, glow eases back at the end; clip sent to the user 18:5x). s08 PRESENT
  (65 min; page turns over and settles by frame ~40, revealed page blank, then the gold
  heading and the 2:2 line write themselves in over frames 56-80; a second page starts lifting
  at frame ~100 -> trimmed to 100 frames = 6.25 s into the 11.7 s window, 1.9x, event fully
  inside; `s08_final_trim.mp4`).
- s03 seed 7 FAILED (65 min): camera tilts down and the mat sways, but the roll never descends
  (drift-only). Retry tests queued at 480p behind s06: (A) "roll falls and unwinds, static
  camera", seed 11; (B) reverse trick, "mat rolls itself up toward the sky", seed 11.
- s06 seed 7 (65 min): waves roll and break hard, camera dollies up the road, but the roll at
  the far end never unrolls (the intended event). Animated, kept as fallback `s06_final.mp4`;
  480p retry tests queued: (A) "roll tumbles forward and unwinds to the mountain", (B) reverse
  trick "road rolls itself back toward the camera", both seed 11.
- s03 test A (480p, seed 11, "roll falls and unwinds", static camera) PRESENT: the whole mat
  lowers out of the sky and the roll lands beside the small ground mat (descends as a unit rather
  than unwinding; reads as "the mat comes down and lands"). Test B (reverse trick) pending.
- s02 seed 7 (76 min): petals fold inward around a glowing gold heart, then open again (a
  "breath", not a bloom); clearly animated, kept as fallback `s02_final.mp4`. 480p test queued:
  reverse trick, "petals close around the heart" seed 11, to be played reversed as a bloom.
- s06 test A (480p, "roll tumbles forward and unwinds", static camera) PARTIAL: the road does
  unroll forward over the sea with the waves moving, but overshoots and climbs into the sky above
  the mountain like a ramp; the clean part (~3 s) would need a 2.9x stretch. Waiting on test B
  (reverse trick), which ends on the still by construction.
- s03 test B (480p, reverse trick "mat rolls itself up", seed 11) PRESENT and better than A: the
  roll climbs cleanly, taking the emerald half, the seam text and then the gold half with it.
  Reversed = a roll descends from the gold sky unrolling gold -> seam text -> emerald, ending on
  the still. Queued at 720p as `s03_r2.mp4` (121f, seed 11), to be reversed at assembly.
- s01 seed 23 (56 min, 81f) PRESENT: the column of cream cards streams upward throughout, camera
  pushes in, pages hold flat, heading intact.
- s02 test A (480p, reverse trick "petals close around the heart", seed 11) PRESENT: the flower
  folds into a closed bud cleanly, book base holds. Reversed = a bud blooms open into the full
  flower ending on the still. Queued at 720p as `s02_r2.mp4` (121f, seed 11), reversed at assembly.
- s06 test B (480p, reverse trick "road rolls back toward the camera") WEAK: the roll travels
  down the road like a rolling pin but the road behind it stays laid, waves barely move.
  Decision: keep `s06_final.mp4` (waves roll hard, camera travels the straight road) as the
  default, event re-read as "the sea rolls while the road runs to the mountain"; test A's forward
  unroll queued at 720p as `s06_r2.mp4` with anti-overshoot wording ("stops at the shore, stays
  flat on the water"), to be compared at Gate 3.
- s03 r2 (720p, 121f, seed 11, test-B prompt) FAILED to reproduce the test: the roll climbs but
  a blank cream sheet hangs beneath it from early on (the mat's invented "back"), and in the last
  ~10 frames the full mat snaps back, hanging almost to the ground. Reversed + trimmed to 96f it
  would be 2.1x with a visible glitch. Lesson: at 121f Wan ran out of mat to roll and invented
  more. r3 queued (seed 23, 121f): roll up SLOWLY only to the seam, "nothing hangs below the
  roll", so the reversed clip = the emerald half unrolling down from the seam to the still.
- s04 seed 7 (34 min, 81f) PRESENT: gold leaves shower down and pile at the foot of the mat,
  cream cards lift, the reply leaf falls, camera pushes in; the standing letters stay up but are
  hidden behind blurred foreground leaves in the last second -> trimmed to 72f (4.5 s into the
  8.2 s window, 1.8x), `s04_final_trim.mp4`.
- s02 r2 (720p, 121f, seed 11): closes fully to a bud by frame ~64-76 and then reopens (Wan's
  121f "breath" again). Used: frames 0-70 REVERSED = bud blooms open into the still, 4.4 s into
  the 8.7 s window (1.97x), `s02_r2_bloom.mp4`. Lesson: for reverse-trick events at 121f Wan
  completes the motion by mid-clip and undoes it; render 81f or plan to use the first half.
- s06 r2 (720p, 121f, seed 11, anti-overshoot wording): the roll travels forward and reaches the
  mountain by mid-clip, then rolls back toward the camera (first->last diff 7); waves barely
  move. Only the first half carries the event, at a >2x stretch. 720p budget for s06 is spent
  (final + r2). Default stays `s06_final.mp4` (waves roll, camera travels the road); the trimmed
  r2 half is prepared as `s06_r2_unroll.mp4` for the user to compare at Gate 3.
  Correction on closer sampling: the roll travels steadily from mid-sea to the mountain foot
  over frames 0-86 before turning back -> trimmed to 88f = 5.5 s into the 8.6 s window (1.6x),
  event fully inside. `s06_r2_unroll.mp4` is now the s06 default; `s06_final.mp4` (waves +
  dolly, no unroll) kept as the alternative for Gate 3.
- s03 r3 (720p, 121f, seed 23, "roll up slowly only to the seam, nothing below the roll")
  PRESENT: the roll climbs steadily from the bottom to just under the gold seam, no invented
  sheet, seam text and gold half intact. Reversed = the emerald half unrolls down from the seam
  to the still, 7.56 s into the 12.7 s window (1.68x), `s03_r3_rev.mp4`.
- Lesson: `ffmpeg -vf reverse` alone leaves the output with reversed PTS, so seeking to t=0
  returned the wrong frame (frame sheet showed the still first). Reversed clips are encoded with
  `-vf "reverse,setpts=N/FRAME_RATE/TB" -r 16`; first frames verified by index and by seek.
- Pre-fit: the finished hero clips are fitted to their VO windows ahead of time (`prefit.py`,
  same bounds math as assemble.py) so the final `assemble.py --reuse` only fits s07 and s09.
- s07 seed 7 (35 min, 81f) PRESENT: the sun rises over the peak, gold light pours down the road
  toward the camera and the lanterns light along both sides; banner and milestone hold.
- s09 seed 41 (65 min, 121f) PRESENT: gold and cream cards stream over the city while dawn light
  glows up across it, pages and heading hold. HEROES_DONE 07:07; 9/9 events present at 720p
  (4 first-take, 1 trimmed, 4 from retries/reverse trick). Total Wan: 9 finals + 6 tests + 4
  retries, ~13.5 h wall clock unattended.
- Gate 3 approved 07:1x (assemble as audited, s06 unroll take). FINAL:
  `output/paper-explainer/fatiha/fatiha_final.mp4` (1080x1920, 24 fps, 87.1 s, 63 MB, VO Brian,
  title card THE PRAYER THAT ANSWERS BACK, no end card); preview `fatiha_final_preview.mp4`
  (540x960, 6 MB) sent. Built via `assemble.py --reuse` on the pre-fitted work clips (2 min).
  Stills spend: 14 x Nano Banana 2K ~$1.80; motion: local Wan, 19 renders ~13.5 h unattended.
- Lessons: (1) 2K Nano Banana now returns 1536x2752, plenty for 720p Wan input; keep 4K for
  Arabic-heavy props only. (2) Compress `--ref` images before upload and retry the POST; raw
  multi-MB PNG refs get the connection dropped. (3) Wan 2.2 at 121f often completes an event by
  mid-clip and undoes it (s02 breath, s06 roll-back, s03 snap-back); for reverse-trick events
  render 81f or prompt a SLOW motion that ends short of completion (s03 r3 "only to the seam").
  (4) Rolls/unrolls: forward prompts overshoot or ignore the roll; "the mat rolls itself up"
  reversed is the reliable unroll. (5) Reversed clips need `setpts=N/FRAME_RATE/TB` after
  `reverse`. (6) Retake scripts keyed by id prefix re-render every take of that id; key by full
  id. (7) Nano Banana wraps a long Arabic line with its last word on the row above (s08, twice).

## Revision 1 (2026-09-04 morning)

- User review of the final: s05's crowd turn "animates poorly". Ruling: keep the people standing
  still in prayer, no turning; only the light shines. Still switched to `s05_courtyard_turn_v2.png`
  (rows already facing the empty mihrab). Event: mihrab light comes on and floods the courtyard,
  "every figure stays perfectly still, frozen like cut-outs glued to the floor", slow push-in,
  seed 23. 480p check queued, then the 720p final (121f) right behind it with the same prompt;
  the final is interrupted only if the check shows the crowd moving. Output `s05v2_final.mp4`;
  shots.json repointed, stale work clip removed so `--reuse` re-fits it.
- s05 v2 480p check (seed 23) PRESENT: the arch lights and the gold floods the courtyard, the rows
  hold still facing the mihrab, slow push-in; the last frames run hot orange. 720p final left to
  run (started 09:10).
- s05 v2 720p (121f, seed 23) PRESENT: light comes on and floods the still rows, full from
  frame ~56 to ~88, then fades -> trimmed to 96f (6.0 s into the 11.7 s window, 1.95x), ends lit.
  `s05v2_final_trim.mp4`. FINAL v2 rebuilt via `--reuse` (only s05 re-fitted); preview re-sent.
  Old turn take kept as `s05_final.mp4`.
- BUG found on the v2 check (frame at 48.5 s showed s06 under a line-5 caption): `fit_hero`
  retimed clips came out ~0.2 s short each (minterpolate stops at the last source frame; `-t`
  cannot pad), so the concat drifted to -1.74 s by s09 (video 85.4 s vs timeline 87.1 s): the
  picture ran ahead of VO/captions and the tail had no video. Fix in `assemble.py`: tpad clones
  the last frame past the end and `-frames:v round(dur*FPS)` cuts each clip to the exact count.
  All nine work clips refitted (old ones in `work_v1_drift/`). NOTE: the same drift is in the
  Hud, Kawthar and Fil finals (same script); a `--reuse`-free rebuild fixes each in a few minutes.
- FINAL v3 (2026-09-04 ~10:50): `fatiha_final.mp4` rebuilt with the fixed fit (max clip-to-window
  offset 0.04 s, video 87.08 s vs timeline 87.12 s), s05 light-only take in. Preview re-sent.
- BUG (user screenshot at 0:47, "THIS IS BETWEEN" shown twice): the orphan-word merge in
  `build_ass` was `chunks[-2] += chunks.pop()`; Python evaluates the pop before the store, so the
  merged phrase was written one slot too far, overwriting the previous phrase ("He says:" never
  displayed) and leaving the last phrase twice with overlapping events. Fix: pop first, then
  `chunks[-1].extend(orphan)`. Any line whose last word overflowed a phrase was affected, in every
  episode built with this script. FINAL v4 re-muxed via `--reuse`; ASS validated (no event with
  end <= start, no consecutive duplicates, every word present).
