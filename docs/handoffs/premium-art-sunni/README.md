# Premium design-asset handoff: Thaqalayn iOS -> AlBayan (Sunni)

> **For the implementing Claude (in the AlBayan repo):** This package is a self-contained program for giving AlBayan the full premium-art system that Thaqalayn has: cover art on journeys, gated content, section headers, the Today hero, the paywall, and an onboarding hero video. You are assumed to have **zero access** to the Thaqalayn repo - everything you need is in this folder. Work the **Master checklist** at the bottom in order. There are **two user-approval gates**; do not pass either without explicit approval.

**Source:** Thaqalayn (Shia sibling app), premium-art initiative shipped v7.4, July 2026.
**Target:** AlBayan (Sunni, SwiftUI iOS app).
**Goal:** the same *system* and *quality bar*, but with AlBayan's **own visual style** and **Sunni-appropriate subjects**. This is NOT a pixel-parity port: every image is generated fresh for AlBayan. What ports verbatim is the method - the composition rules, the surface treatments, the pipeline, and the lessons already paid for.

---

## 1. The three layers - what ports, what is fresh

| Layer | What it is | What you do |
|---|---|---|
| **Method + treatments** | Composition system, mask/scrim recipes, surface specs (docs 01-04), generation pipeline, QC rules | **Port as written.** These are style-independent and were learned the hard way. |
| **Style** | The look of the art itself | **Author fresh.** Derive AlBayan's own style bible from its theme and identity (section 4). Do NOT copy Thaqalayn's look (photoreal blue-hour emerald night). |
| **Subjects** | What the art depicts | **Author fresh, Sunni.** Inventory AlBayan's own catalogs and apply the imagery ruleset (section 5). |

The reference images in `reference/` are **composition references only** - they prove the geometry (dark top third, subject low, one warm focal light). Their style will NOT be your style.

---

## 2. What you are building - the asset classes

Thaqalayn ships 6 asset classes. Build the AlBayan equivalent of each; the exact count comes from *your* catalogs (Stage 1).

| Class | Bundled size (px) | Ratio | Surfaces it feeds | Doc |
|---|---|---|---|---|
| Journey covers | 1170 x 900 (band crop of a 4:5 master) | 13:10 | Hub shelf poster, "All journeys" tile, journey header band, veiled locked-day preview, paywall context | 01 |
| Content-unit covers (deep dives / surah experiences / your equivalents) | 1170 x 1463 | 4:5 | Shelf poster, list mini-tile, reader threshold, reader veil, paywall context | 02 |
| Today seasonal heroes | 1170 x 653 | wide | Today tab daily-verse hero card, one per Hijri season + everyday | 01 |
| Section header covers (Explore-style hub + detail screens) | 1170 x 1452 | ~4:5 | Header band behind each screen's title stack | 03 |
| Paywall hero | 1170 x ~1017 | ~8:7 | Default paywall hero band (context covers override it) | 04 |
| Onboarding hero video | 1080 x 1920 | 9:16 | Silent seamless loop behind onboarding page 1 | 04 |

**The single most important wiring principle:** ONE `coverAssetName` field on the catalog descriptor (journey, dive, experience) feeds every surface - shelf, tile, header, veil, paywall. Never attach art per-surface.

**Cover art on coming-soon entries too.** The art is what makes the roadmap worth buying into. Coming-soon rows show the art dimmed (0.82 on posters, 0.7/0.72 on tiles), never hidden.

---

## 3. Process - six stages, two approval gates

### Stage 0 - prerequisites

- **Higgsfield MCP** is the generation backend for everything (stills and video). If not connected: `claude mcp add --transport http higgsfield https://mcp.higgsfield.ai/mcp` (OAuth login). Check `balance` before starting; a 2K still is ~2 credits, so the whole still program is cheap - video is the only real budget line (see section 6 costs).
- Locate AlBayan's theme tokens (background, accent, text colors) - the style bible anchors to them.
- Confirm how AlBayan bundles images (asset catalog conventions, scale slots).

### Stage 1 - inventory (your app, not Thaqalayn's)

Walk AlBayan's own catalogs and screens and produce an **asset manifest**: one row per image with target surface, subject idea, and pixel size (table in section 2 gives sizes). Cover at minimum:

- Every journey in the journey catalog (including seasonal ones and coming-soon).
- Every gated content unit (deep dives / surah experiences / whatever AlBayan gates), including coming-soon.
- Today hero: one per season window AlBayan recognizes + one everyday (see 01-B).
- Every section/hub screen that has a title header (Explore-style screens).
- One paywall hero + one onboarding video subject.

Show the manifest to the user before generating anything.

### Stage 2 - style exploration -> **GATE 1**

1. Pick ONE representative subject from the manifest (a journey cover works well).
2. Generate 3-4 candidate *styles* of that same subject (e.g. photoreal cinematic, painterly, layered paper-cut, ink + gold - or directions that fit AlBayan's identity). Full 4:5 compositions obeying the composition rules (section 4), not style swatches.
3. Present them on a side-by-side HTML review page opened in the browser (the user judges art visually, never from text descriptions).
4. **User picks. Write the winning direction up as the style bible** (section 4 template) and get it approved.

Lesson paid for on Thaqalayn: they tried a two-tier system (photoreal for "place" moments, paper-cut for product surfaces). The mixed tier failed in practice - cropping a paper-cut poster into a band destroyed it. **Pick ONE style and purpose-compose every image for its exact target frame. Never crop a finished poster into a differently-shaped slot.**

### Stage 3 - master generation -> **GATE 2** (per batch)

- Generate in batches by class (journeys, then content covers, then heroes, ...). Masters at 2K, 4:5 (band and wide crops are derived later; compose knowing where the crop will land).
- Keep **identity consistency** within a batch via image-to-image: pass an approved master's job id as `medias: [{role: "image", value: "<job_id>"}]` so recurring motifs, palette, and grade stay coherent.
- QC every image against the checklist in section 7 before showing it.
- Present each batch as an HTML review grid; **user approves or names retakes**. Record approved job ids.

### Stage 4 - derive crops + import

- Derive each surface's crop from its master with ffmpeg/sips (per-image vertical offset - place the crop where the subject sits, typically the lower half; Thaqalayn's journey band offsets varied 480-580 px on ~1856-wide masters).
- Export bundled files: JPEG quality ~78 at the sizes in section 2, placed in the **3x slot** of the imageset (single-scale; these are full-bleed decorative images).
- Keep full-res masters in the repo outside the app bundle (Thaqalayn uses `assets/premium-art/`), with job ids recorded in a notes file.

### Stage 5 - wire the treatments

Implement docs 01-04 in AlBayan's own theme (map color/type roles per section 8). Order of value:

1. Shared cover header band (03) - one component unlocks every section screen + journey headers.
2. Shelf posters + list tiles (01-A1, 02) - the highest-visibility win.
3. Today seasonal hero (01-B).
4. Paywall hero band + contextual paywall (04-A), then reader threshold + veils (02).
5. Onboarding video (04-B) and poster-zoom transition (01-A2) last - both are polish.

Gate: green build. The user does simulator verification themselves; do not commit on their behalf.

---

## 4. The style bible - method

The style bible is a short, user-approved document. Every future generation pastes its style block **verbatim** into the prompt (paraphrasing drifts the look). It must pin down:

- **Render style**: the medium and finish (photoreal cinematic / painterly / paper-cut / ...). One style for the whole app.
- **Lighting regime**: time of day and where light comes from (Thaqalayn: deep blue hour, one warm gold focal glow low in frame; yours may differ, but ONE warm focal light against a dark field is what makes titles and premium-gating read).
- **Palette**: 2-4 hex anchors taken from AlBayan's theme tokens (dark base + accent at minimum).
- **Recurring motifs**: 2-3 elements that recur across images so the set reads as one collection.
- **Never-appears list**: see section 5, plus anything the user adds.

### Composition rules - style-independent, NON-NEGOTIABLE

These were learned the hard way; three separate UI treatments silently depend on them. Any image that breaks them breaks the UI:

1. **Compose 4:5 with a dark, uncluttered top third; subject in the lower half.** The shelf poster puts its title in that dark "sky" (a bottom scrim was tried and landed on the subject; a top-band crop showed only empty sky - both rejected). The paywall's top-anchored crop and the header bands also rely on it.
2. **One warm focal light source, quiet foreground.** Bright mid-frame subjects punch through overlay text.
3. **No human beings, ever.** Not silhouettes, not crowds, not hands. This is both the house style and what sidesteps figure-depiction concerns entirely.
4. **No text in the art.** No calligraphy, no signage, no book pages with visible writing - AI-garbled Arabic is an instant credibility kill for this audience. (Thaqalayn's one flag exception took multiple retakes; do not attempt.)
5. **No borders or mattes.** Full-bleed to every edge; check for sneaky white matte borders (a known nano-banana failure - one Thaqalayn cover shipped a regen for exactly this).

---

## 5. Sunni imagery ruleset

The content-adaptation ruleset from earlier AlBayan ports (honorifics, sources, no mourning content) has an imagery analog. Apply it to every subject in the manifest:

**Never depict:**
- Any person (rule 3 above - absolute, and doubly so here: no depiction of the Prophet ﷺ, companions, or any sacred figure, in any form, veiled or otherwise).
- Shia-specific iconography: the Karbala/Najaf shrine complexes, "Ya Husayn"/"Ya Ali" flags or any devotional banner, alam/panja standards, mourning processions or black-and-red mourning dressing, turbah tablets, Zuljanah imagery.
- Mourning/azadari registers in general - AlBayan's Muharram framing (if it has one) is the Ashura fast / Hijra / fresh start, so its art should read hopeful dawn, not lament.

**The Sunni-safe subject bank** (pair per-theme; keep subjects concrete and place-like or symbol-like):
- **Places:** the Kaaba and Masjid al-Haram courtyard; Masjid an-Nabawi's green dome; al-Aqsa; Ottoman, Mamluk, and Andalusian mosque architecture (courtyards, arcades, mihrab niches, minarets); lantern-lit old-city streets (Ramadan register); desert dunes, an oasis, a mountain path (journey register).
- **Symbols/still-life:** a lantern, dates and water at iftar, a prayer rug facing a lit mihrab, prayer beads, a closed mushaf on a rehal (closed or too distant to show script - rule 4), a well, an olive tree, a night sky heavy with stars, a single lit window.
- Content-unit covers (Sabr, Shukr, Yusuf, al-Mulk, ...) are mostly sect-neutral symbols already - the theme picks the subject (Yusuf = the well; al-Mulk = dominion of the night sky; Sabr = the olive tree). Derive from each unit's actual content.

**Flag for the user, do not decide alone:** anything Mawlid-related (audience-dependent), any subject involving graves/shrines of any kind, and any depiction that could read as representing the unseen. When in doubt, choose architecture, landscape, or still-life.

The same shipping gate as content ports applies in spirit: if any subject feels doctrinally loaded, ask the user before generating.

---

## 6. Generation pipeline (Higgsfield MCP)

**Models and verified costs** (Thaqalayn, 2026-07-14):

| Job | Model | Cost |
|---|---|---|
| 2K still | `nano_banana_pro` | 2 credits |
| 5s 1080p video | `kling3_0_turbo` | 10 credits |
| 8s 720p video | `seedance_2_0_mini` | 20 credits |
| 8s 1080p video | `seedance_2_0` | 72 credits |

Thaqalayn's entire still program (35+ images incl. retakes) cost ~66 credits. Budget the same order; check `balance` first.

**Prompt skeleton** (fill the brackets; paste the style block verbatim):

```
[SUBJECT], [one scene-specific detail].
Composition: vertical 4:5, subject in the lower half of frame, top third an
uncluttered dark sky, single warm focal light on the subject, quiet foreground.
Style: [VERBATIM style block from the approved style bible].
Palette: [2-3 hex anchors].
No people, no figures, no silhouettes, no text, no calligraphy, no watermark,
no border, no frame.
```

**Working rules:**
- Image-to-image off an approved master job id (`medias: [{role:"image", value:"<job_id>"}]`) for set coherence.
- **Grade in post, not by regenerating.** A too-bright or off-hue but otherwise good image is a free ffmpeg fix (Thaqalayn regraded its onboarding loop with `colorbalance` + `eq` instead of a 72-credit re-render). Only regenerate for composition failures.
- Record every shipped image's job id next to the master file.

**Onboarding video loop recipe** (details in 04-B): generate the hero master still first and get it approved; animate it image-to-video with **start frame = end frame = the same job id** and a locked-off camera prompt (no push/pull/pan - subtle ambient motion only); kill the loop seam with an ffmpeg tail-to-head crossfade (~0.75s xfade of the last segment into the head, then concat); encode `libx265 -crf 27 -tag:v hvc1` -> a 7s loop lands ~300 KB-1.5 MB.

---

## 7. Per-image QC checklist (before showing the user)

- [ ] Top third dark and uncluttered; subject sits in the lower half.
- [ ] One warm focal light; nothing bright mid-frame where overlay text will sit.
- [ ] Zero humans, zero text/calligraphy, zero watermarks.
- [ ] No white matte border or frame at any edge (zoom in on all four).
- [ ] No Shia iconography, nothing from the never-depict list (section 5).
- [ ] Palette sits inside the style bible's anchors; grade matches the batch.
- [ ] Still reads at thumbnail size (the 54pt list tile is the smallest consumer).

---

## 8. Cross-cutting UI rules (apply throughout docs 01-04)

1. **Define AlBayan's palette tokens once.** The docs reference roles, not Thaqalayn's hex values. You need: `heroBase` (near-black base under art), `thresholdBase` (darkest, reader background), `cardBacking` (dark fill ~0.45 alpha for glass cards over art), plus your existing accent/ivory/cream text colors. Derive all from AlBayan's theme.
2. **Theme gating.** If AlBayan has a flagship dark theme + legacy themes (as Thaqalayn does), header bands and the Today hero render ONLY in the flagship theme; shelf posters and list tiles render in all themes; readers/veils/paywall are always-dark surfaces. If AlBayan has one theme, render everywhere.
3. **Mask vs scrim - never mix them up.** Header bands and the paywall hero fade the ART ITSELF to transparent (alpha mask via `.mask(LinearGradient...)`). Posters, Today heroes, reader thresholds, and the onboarding video layer a black gradient scrim ON TOP. Each doc states which applies.
4. **Always fill-crop** (`.scaledToFill()` + `.clipped()`), never letterbox.
5. **Premium is a chip, never a lock.** No `lock.fill` anywhere; a locked tap routes to the paywall carrying that entry's cover as context.
6. **Missing art degrades silently.** No cover -> the old icon/chip layout; no band. Never a placeholder or broken image.
7. **Veil recipe is shared app-wide:** cover scaled 1.22x (blur overscan - `.blur()` vignettes at edges without it) + `.blur(radius: 44, opaque: true)` + black overlay (0.52 journey day / 0.46 reader).
8. **Reduce Motion** disables Ken Burns drift, entrance cascades, and the onboarding video (fall back to a still).
9. House style: plain English spelling (no transliteration diacritics), no em dashes, all reading content scales with AlBayan's text-size control.

---

## Master checklist

- [ ] 0. Prerequisites: Higgsfield MCP connected, `balance` checked, theme tokens located.
- [ ] 1. Asset manifest built from AlBayan's own catalogs; shown to user.
- [ ] 2. Style board (3-4 directions, one subject, HTML side-by-side) -> **GATE 1: user approves; style bible written.**
- [ ] 3. Masters generated batch-by-batch (i2i coherence, QC per section 7) -> **GATE 2: user approves each batch.**
- [ ] 4. Crops derived, imagesets imported (JPEG ~q78, 3x slot), masters + job ids archived in-repo.
- [ ] 5. Shared header band built (03); wired on section screens + journey headers.
- [ ] 6. Shelf posters + list tiles (01-A1, 02); coming-soon dimming; icon fallback kept.
- [ ] 7. Today seasonal hero with Hijri season selection (01-B).
- [ ] 8. Paywall hero band + context covers + motion (04-A); contextual paywall wired at every gated tap.
- [ ] 9. Reader threshold + veils (02); veiled locked-day preview (01-A4).
- [ ] 10. Onboarding video generated, looped, encoded, wired with fallbacks (04-B).
- [ ] 11. Poster-zoom transition (01-A2, polish).
- [ ] 12. Green build; hand to user for simulator verification. Do not commit unless asked.
