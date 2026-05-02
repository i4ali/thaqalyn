# Video Model Research — Stage 0 Step 2

This is the **mandatory pre-flight check** before writing any motion prompts. Different Kling versions have meaningfully different prompt conventions, and writing a generic prompt against the wrong model is the #1 reason scenes drift, fade halos, or render unwanted motion.

## Why this matters

We learned the hard way: writing a v2.1-style 80-word motion prompt for what turned out to be a v3.0 render produced halo fade and unintended subject motion. The fix wasn't a different image — it was matching the prompt conventions of the model. Same image + tightened prompt + correct magic phrase = clean output.

**Always run this research step BEFORE Stage 2 image prompts.** Image prompts are also model-specific (Nano Banana Pro vs. Gemini direct vs. ChatGPT Image have different idioms), but Kling motion prompts are where the cost of mismatch is highest.

## What to ask the user (in Stage 0)

> *"Which Kling model do you want to use? Default recommendation is Kling 3.0 (`v3-0-pro` via kie.ai) — has Subject Binding which is essential for veiled-figure work and is the most current model. Other options: 2.6 / 2.6 Motion Control / 2.1 Master."*

Wait for their answer. Don't guess.

## What to research (use WebSearch + WebFetch)

After they pick the model, run **all four** of these queries in parallel:

```
1. WebSearch: "{model} prompt guide image-to-video"
2. WebSearch: "{model} negative prompt camera movement"
3. WebFetch: kie.ai docs page for that model — for the exact API model identifier and supported parameters
4. WebFetch: top third-party prompt guide (fal.ai, Ambience AI, VEED, Atlabs) for documented best practices
```

## What to extract

Capture these as a cheat sheet inline in the conversation so Stages 2 and 4 reference it:

### Required extractions

- **Word count limit** for motion prompts. Most models cap at 15-40 words; longer prompts overload the motion model.
- **Magic phrases** that activate specific behaviors. E.g.:
  - Kling 3.0+: `"Locked-off tripod shot, completely static camera"` for forcing zero camera movement.
  - Kling 2.6 Motion Control: bracketed parameters like `[actor: camera] [action: zoom-in]`.
- **Negative prompt support** — does the API have a separate `negative_prompt` field, or do you have to bake "NO X" clauses into the positive prompt?
  - Kling 3.0 on kie.ai: **no** native negative prompt field as of April 2026. Bake constraints into positive prompt.
  - Kling 2.x on kie.ai: also no separate negative prompt field.
- **Subject Binding behavior** — does the model preserve character features across camera moves automatically, or do you have to explicitly lock them?
  - Kling 3.0: built-in Subject Binding; mentioning the figure once is enough.
  - Kling 2.x: no Subject Binding; must explicitly say "completely motionless, does not move at all."
- **Duration support** — what durations does the model accept?
  - Kling 3.0: 3-15 seconds (string).
  - Kling 2.1 Master / 2.1 / v1.6: 5 or 10 only.
  - Kling 2.0 Master, v2-standard, v2-pro: **5 only** (10s returns HTTP 400).
- **Resolution/mode tier** — what tier yields what resolution?
  - Kling 3.0: `std` = 720p, `pro` = 1080p, `4K` = 2160p.
  - Kling 2.1: `master` is flagship.
- **What NOT to mention** — keywords that trigger unwanted behavior. Universal across Kling:
  - Never say "halo", "veil", "glow", "radiant", "face", "Prophet", "Imam", "Ali", "Fatima", "Muhammad" in motion prompts. Saying any of these directs Kling to *animate* or *modify* that region.
- **kie.ai API model identifier** — the exact string passed in the `model` field of the request. E.g.:
  - Kling 3.0: `kling-3.0/video`
  - Kling 2.1 Master: `kling/v2-1-master-image-to-video`
  - These are different shapes — `kling-3.0/video` vs `kling/v2-1-master-image-to-video` — and the payload schemas differ too. `scripts/kie_kling.py` handles both.

### Save the cheat sheet inline

Format your research findings as a compact table at the end of Stage 0, like:

```
## Kling 3.0 cheat sheet (researched 2026-04-30)

- Model: kling-3.0/video, mode pro (1080p)
- Word limit: 15-40 motion words
- Magic phrase: "Locked-off tripod shot, completely static camera." (forces zero camera move)
- Subject Binding: built-in (lock characters across moves)
- Negative prompt: no native field; bake into positive prompt
- Duration: 3-15s (string), 5 default, 10-15 for climactic
- NEVER mention: halo, veil, glow, face, Prophet, Imam, Ali (triggers face-rendering)
- Best for: veiled-figure work; halos hold dramatically better than v2.1
- Sources: docs.kie.ai/market/kling/kling-3-0, fal.ai/learn/kling-3-0
```

Reference this cheat sheet at the top of every motion prompt file you write in Stage 4.

## Cheat sheets for known versions (current as of April 2026)

These are starting points — **always verify with a fresh WebSearch** since these models update frequently.

### Kling 3.0 (recommended default)

| Property | Value |
|---|---|
| API model | `kling-3.0/video` |
| Tiers | `std` (720p) / `pro` (1080p) / `4K` (2160p) |
| Word limit | 15-40 words |
| Duration | 3-15s (string) |
| Magic phrase | `"Locked-off tripod shot, completely static camera."` |
| Subject Binding | ✅ built-in |
| Negative prompt field | ❌ no native field |
| Best for | Veiled-figure work, character consistency, climactic scenes |
| ELO benchmark | #1 (1243) as of Feb 2026 |

**Working example for veiled figures:**
```
Locked-off tripod shot, completely static camera. Settling dust drifts.
Banners ripple in distant wind. All image content otherwise unchanged.
```

### Kling 2.6 / 2.6 Motion Control

| Property | Value |
|---|---|
| API model | `kling-2.6/video`, `kling-2.6-motion-control/video` |
| Word limit | similar to 3.0 |
| Duration | 5 or 10 |
| Notable | Native audio generation, motion transfer from reference video |
| Best for | Action scenes where you have a reference video to copy motion from |

### Kling 2.1 Master (legacy flagship)

| Property | Value |
|---|---|
| API model | `kling/v2-1-master-image-to-video` |
| Word limit | 15-40 words |
| Duration | 5 or 10 |
| Magic phrase | Same locked-off phrase works but less reliable |
| Subject Binding | ❌ none — must say "completely motionless, does not move at all" |
| Negative prompt field | ❌ no native field |
| Best for | Backup if 3.0 unavailable; cheaper |

### Kling v2-standard / v2-pro (Kling 2.0 Master)

⚠️ **Avoid for veiled-figure work** — earlier model, halos drift more, only supports 5s clips. Returns HTTP 400 on 10s requests.

## When research findings conflict

Prioritize sources in this order:
1. **kie.ai docs** (docs.kie.ai/market/kling/...) — authoritative for the actual API shape we're using.
2. **fal.ai prompt guides** — high quality, model-version-specific.
3. **Official Kling AI blog** (kling.ai/blog) — for new features like Subject Binding.
4. Third-party prompt guides — corroborate but don't fully trust.

If two sources contradict on a magic phrase or word count, **test with a single 5s scene first** before committing to all 6 scenes.

## How to structure the Stage 0 confirmation card

Once research is done, present back to the user like this:

```
## Plan summary

Event: [Khandaq / Ali ع vs Amr ibn Abd Wud]
Tone: [martial → spiritual climax → triumphant]
Scene count: [6 scenes, 35s total]

Video model: [Kling 3.0 Pro via kie.ai]
Key prompt rules I'll apply:
- Motion prompts: 15-40 words max
- Lead with "Locked-off tripod shot, completely static camera"
- Never mention halo / glow / face / sacred-figure-name in motion
- Subject Binding handles character consistency

Image model: [Nano Banana Pro via OpenRouter]
- Hardened halo language (solid disc IN FRONT OF face)
- Explicit "no text in image" clause
- 9:16 aspect ratio

Approve to proceed to scene breakdown?
```

This makes the research visible to the user and gives them a chance to override before you commit.
