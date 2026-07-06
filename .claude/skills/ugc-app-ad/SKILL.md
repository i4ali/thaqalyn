---
name: ugc-app-ad
description: Use when creating a UGC-style short-form video ad for an app or feature with an AI "actor" (TikTok/Reels/Shorts, vertical). Any concept - notification reaction, problem→solution, testimonial, day-in-the-life, before/after, unboxing-style. Co-designs the scene with the user, then runs a reusable AI-character → animation → optional in-app-screenshot composite → captioned-assembly pipeline. Triggers - "make a UGC ad", "app promo video", "ad with someone using/reacting to the app".
argument-hint: [what the ad should promote]
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# UGC App Ad

Produce a custom ~10–30s, 9:16 UGC ad with a consistent AI actor. The
**story is co-designed with the user every time** — this skill is the
reusable production *engine*, not a fixed storyboard. The
notification→open→smile flow is just one possible concept.

Human-in-the-loop: AI face quality and Kling motion drift require user
visual approval at each costed step. No silent fallback — surface risky
trade-offs as decisions.

## When to use

- Any app/feature promo with a relatable AI "user" on screen
- Concepts: notification-reaction, problem→solution, testimonial/POV,
  day-in-the-life, before/after, "I found this app", feature demo
- Output: TikTok / Reels / Shorts (1080×1920)

Not for: cinematic brand films, or lip-sync talking-head (Kling v3-0
doesn't lip-sync reliably).

## Step 1 — Co-design the scene (REQUIRED FIRST)

**REQUIRED SUB-SKILL:** Use superpowers:brainstorming. Then use
AskUserQuestion to lock:

- **Concept/structure** — which UGC pattern; the ordered **beats**
  (1 line each: what's on screen + what the actor does)
- **Actor** — age/gender/dress/vibe; **Setting**; **Length**
- **Voice** — silent+captions, voiceover, or captions+VO
- **App on screen?** — which beats (if any) show a real screen, and how
  (in-hand composite, full-screen, or none). If yes, get a **retina
  screenshot** (≥1080px wide) — never AI-upscale UI.
- **Audio** — ambient, music (user-provided), or VO; **brand hex**,
  **app name**, and any notification copy if the concept uses one

Write a short design doc to `docs/plans/YYYY-MM-DD-<name>-ugc-ad-design.md`.

## Step 2 — Run the production engine

Work under `ads/<name>/{inputs,stills,clips,work}`; activate `.venv`;
scripts live in this skill's `scripts/`. **STOP for user approval after
every API-cost asset.**

1. **Character reference** — `nano_banana.py --size 4K` (OPENROUTER_API_KEY):
   one strong reference still of the actor in the setting. Use `--size 4K` for a
   crisp photoreal face — the "2K" tier is a no-op for this model and 1K is only
   ~768px (soft at 1080). Approve before reuse.
2. **Per-beat stills** — for each beat, `nano_banana.py --ref <reference>
   --size 4K --aspect 9:16` (ALWAYS pass `--ref` for character consistency, and
   set `--aspect` explicitly so the output doesn't snap to the reference's
   ratio). Describe the change with a verb — "keep the actor identical; change
   only the pose to …". For a beat that shows the app in-hand, generate the actor
   holding a phone with a flat, solid chroma-green screen (an even green panel,
   ready for compositing).
3. **Animate** — `kie_kling.py --mode v3-0-pro --duration 5` per beat. Write
   the motion prompt as **motion + one camera move (with a speed word) + an
   explicit end-state** ("...then holds", "...settles") - Kling loops and
   stalls at 99% without an endpoint - and don't re-describe the actor (the
   still already locks appearance). For beats that must stay framed (anything
   you'll composite onto, or an emotional payoff), prompt for **minimal
   motion**, add `--lock-end-frame` (reuses the still as the end frame to pin
   drift), and/or use a **still-hold** instead (loop the approved still + slow
   zoom) — Kling drifts and reaction clips often dip mid-shot.
4. **In-app screen (only if a beat shows it)** — extract a frame strip;
   the phone is stable only briefly. `detect_green_quad.py` on a stable
   frame → quad; `screen_composite.py` warps the retina screenshot onto
   the stable trim; freeze-extend to length. For a readable beat, cut to
   a full-screen Ken Burns of the screenshot on a soft brand-tint bg.
   Present the in-hand-vs-fullscreen trade-off as a user decision.
5. **Optional notification banner** — `make_notif_banner.py --icon
   --app-name --title [--subtitle] --brand` (only if the concept uses one).
6. **Assemble** — build `$BASE/work/segments.txt` (one `file|seconds`
   per ordered beat), then `assemble.sh <base>`: normalizes, concats,
   adds audio, burns `captions.ass`. Verify with ffprobe + sampled frames.

## Captions (.ass) — critical

The `[Events]` `Format:` line MUST be the full 10-field form, else every
line shows a `,0,0,0,,` prefix:

```
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Style: Cap,Helvetica,66,&H00FFFFFF,&H00000000,&H64000000,1,1,3,2,2,90,90,560
```

`Alignment=2` is bottom-anchored; raise `MarginV` (~560) to lift captions
off the bottom edge. Make caption copy accurate to what's actually on screen.

## Reusable engine (scripts/)

| Script | Role |
|---|---|
| `nano_banana.py` | Character reference + per-beat stills (`--ref` = consistency) |
| `kie_kling.py` | Animate a still → ~5s clip (Kling v3-0) |
| `detect_green_quad.py` | Auto-find the phone screen quad on a frame |
| `screen_composite.py` | Perspective-warp a real screenshot onto footage |
| `make_notif_banner.py` | Branded iOS notification card (optional) |
| `assemble.sh` | Generic: segments.txt → captioned, scored MP4 |

> **Nano Banana Pro prompting** — `nano_banana.py` calls `google/gemini-3-pro-image`
> via OpenRouter's Unified Image API. See
> [`.claude/skills/_shared/nano-banana-pro-conventions.md`](../_shared/nano-banana-pro-conventions.md)
> for the model id, `--size`/`--aspect` behaviour (2K == 1K; use 4K for hi-res),
> positive-framing, and the reference-image ratio gotcha.
>
> **Kling animation** — `kie_kling.py` animates via kie.ai (`--mode v3-0-pro`). See
> [`.claude/skills/_shared/kling-i2v-conventions.md`](../_shared/kling-i2v-conventions.md):
> write motion + one camera move + an explicit end-state (never re-describe the still),
> and use `--lock-end-frame` to pin a framed/payoff beat. kie.ai exposes no
> negative_prompt / cfg_scale / camera_control.

## Common mistakes

| Mistake | Fix |
|---|---|
| Skipping scene co-design, reusing the old storyboard | Step 1 is required — brainstorm a fresh concept each time |
| Caption `,0,0,0,,` prefix | Use the 10-field ASS `Format:` line |
| Character looks different per beat | ALWAYS pass `--ref` to nano_banana |
| Screenshot slides off the phone | Single static quad valid only on the stable window; freeze-extend or full-screen |
| Pixelated full-screen UI | Require retina screenshot; never AI-upscale |
| Payoff beat looks away/drifts | Use a still-hold or `--lock-end-frame`, not the raw clip |
| `concat` "No such file" | segments list uses bare filenames |
| Silently degrading a risky beat | Surface it to the user as a decision |

## Validated

Engine proven end-to-end on the Thaqalayn "Dhul-Hijjah Journey"
notification-reaction ad (`ads/hajj-journey/`, 1080×1920, 15s) — one
concept among many this pipeline supports.
