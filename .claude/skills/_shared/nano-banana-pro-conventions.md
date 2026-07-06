# Nano Banana Pro - calling conventions (shared)

Conventions for every skill/script in this repo that generates images with **Nano Banana
Pro**. Deep reference: `nano-banana-pro-prompting-guide.html` at the repo root.

## Model + endpoint

- **Model id:** `google/gemini-3-pro-image` (GA). The old `-preview` slug is retired -
  never use it.
- **Endpoint:** OpenRouter's **Unified Image API** - `POST https://openrouter.ai/api/v1/images`
  (NOT `/chat/completions` with `modalities`; that path ignores resolution/aspect).
- **Auth:** `OPENROUTER_API_KEY` (already in `.env`). No `GEMINI_API_KEY` needed.

Request (top-level fields) and response:

```jsonc
// POST /api/v1/images
{
  "model": "google/gemini-3-pro-image",
  "prompt": "<descriptive brief>",
  "resolution": "4K",            // "1K" | "2K" | "4K"
  "aspect_ratio": "9:16",        // see list below
  "input_references": [          // optional (image edit / character consistency)
    { "type": "image_url", "image_url": { "url": "data:image/png;base64,..." } }
  ]
}
// Response: { "data": [ { "b64_json": "<base64 PNG>" } ], "usage": {...} }
```

## Resolution (measured, this model)

| `resolution` | 9:16 output | cost | use for |
|---|---|---|---|
| `1K` | 768x1376 | ~$0.13 | abstract/low-detail backgrounds (composited/cropped/upscaled anyway); AND any dense text-card layout (see the cap below) |
| `2K` | 768x1376 | ~$0.13 | **no-op - identical to 1K.** Don't bother. |
| `4K` | 3072x5504 | ~$0.24 | scenes, faces, single-subject art (even with a short headline) - anything delivered at >=1080px |

There is no usable middle tier: **1K (~768px) or 4K.** Use 4K whenever crispness matters
- with one exception:

**The text-card cap (measured):** a prompt with a *dense multi-element text layout*
(several distinct strings + layout rules - a verse card, an infographic) returns
~768x1376 **even at 4K**, and still bills the 4K rate. A scene or single-subject prompt -
even one with a short headline - gets true 4K. So: 4K for scenes; for a multi-string text
card, 4K is wasted money (use 1K), and if you need genuinely crisp text, composite it with
PIL rather than having the model render it.

**Gotcha:** don't put meta-labels in the prompt ("Nano Banana Pro brief", "verse-art
card") - the model renders them as a footer/caption, and the words "Nano Banana" summon a
banana logo. Describe the scene, not the deliverable.

## Aspect ratio

Supported: `1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9`. Always set it explicitly
- **especially with `input_references`**, or the output snaps to the *last* reference's
ratio.

## Reference images

- Up to 14 (`input_references`). Put the base/target image **last**.
- In the prompt, name each reference by **role + a transformation verb** ("keep the actor
  identical, change only the pose to ..."), never a bare "image 1 / image 2" (that triggers
  a returns-a-copy bug). Composition is preserved well (verified: recolor an image, layout
  stays identical).

## Prompting (reasoning model - brief it like a creative director)

- Write a **descriptive natural-language brief**, not comma-separated keyword soup.
- **Positive framing for exclusions:** "a clean, unpopulated field" / "every surface plain
  and unlettered" - NOT "no people, no text". Double negatives can backfire.
- **On-image text:** quote the exact string, name the font/weight, keep each block short
  (<~10 words), and render at **4K** (text blurs at 1K). Verify non-English (e.g. Arabic)
  every run.
- Structure: Subject + Composition + Action + Location + Style, then camera/lighting/text.

## Shared caller

`scripts/nano_banana.py` (and its per-skill copies in `doodle-dialogue-video` and
`ugc-app-ad`) wraps all of the above:

```bash
python scripts/nano_banana.py --prompt "..." --output out.png \
  [--ref base.png ...] [--aspect 9:16] [--size 4K]
```
Defaults: `--aspect 9:16`, `--size 1K`. Pass `--size 4K` for hi-res.
