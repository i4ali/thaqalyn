# Kling image-to-video - calling conventions (shared)

Conventions for every skill/script in this repo that animates a still with **Kling** via
**kie.ai** (`scripts/kie_kling.py`). Deep reference: `kling/kling-image-to-video-report.html`.

## Path + what kie.ai actually exposes

- **Caller:** `scripts/kie_kling.py` (+ an identical copy in `ugc-app-ad/scripts/`), via
  kie.ai. Default `--mode v3-0-pro` (Kling 3.0, 1080p). Auth: `KLING_API_KEY`.
- **kie.ai `kling-3.0/video` input schema (verified 2026-07-02):** `prompt`, `image_urls[]`,
  `duration` (string, 3-15), `aspect_ratio`, `mode` (std/pro/4K), `sound`, `multi_shots`,
  `multi_prompt`, `kling_elements` (max 3).
- **NOT exposed by kie.ai's Kling 3.0:** `negative_prompt`, `cfg_scale`, `camera_control`.
  (The official Kling API / fal.ai / Segmind expose these; kie.ai does not. So best-practice
  guides that lean on `negative_prompt` as the #1 stability lever don't apply to our path -
  the prompt text, the end-state, and `--lock-end-frame` are the levers we have.)
- `cfg_scale` and numeric `camera_control` are dead on v3 anyway (the guide: v2.x/v3 ignore
  cfg_scale; on 3.0 the camera is driven by prompt language, not numeric presets).

## Motion prompt = describe MOTION, not the picture

The start frame already locks subject, wardrobe, lighting, and composition. Re-describing
any of it wastes budget and causes drift. Formula (guide):

> **[subject motion] + [one camera move with a speed word] + [optional light/atmosphere
> shift] + [explicit end-state].**

- **Always give an end-state** ("...then holds", "...settles", "...eases to a stop"). A
  motion with no endpoint can loop and stall the render at **99%**.
- **One dominant camera move per clip, always with a speed modifier** ("slow dolly-in", not
  "camera moves"). Never stack orbit + zoom.
- **To lock the camera:** "static camera, tripod shot, no movement" / "Locked-off tripod
  shot, completely static camera". (The guide's paired negative "shaky camera, random zoom"
  can't be sent on kie.ai - the positive phrasing is what we have.)
- Kling defaults to **slow-motion** on dramatic action - override with "fast", "rockets",
  "violently" for real-time speed.
- Keep it tight (~15-40 words; the guide allows up to ~90). Verbs and camera, not adjectives.

## End frame (the drift lever we DO have)

`image_urls` is "first and last frame image URLs". So:
- `--lock-end-frame` → sends `image_urls: [start, start]`; Kling interpolates between two
  identical endpoints, strongly reducing drift (for shia-event: blank-face completion).
- `--end-image <path>` → a distinct last frame (`image_urls: [start, end]`) for an A→B move.
- `--dry-run` prints the payload without uploading or calling the API (no cost).

## Consistency / duration / resolution

- **Subject Binding** is built into Kling 3.0 - mention the subject once; don't over-name.
  `kling_elements` (up to 3 reference images, addressed as `@name`) may help hold identity
  but is untested here - verify before relying on it.
- **Duration:** v3 = 3-15s (default 5); v2-1 = 5 or 10 only.
- **mode:** `std`=720p, `pro`=1080p, `4K`=2160p. **aspect_ratio** for I2V is inferred from
  the source image - crop the still to 9:16 before animating.

## Per-skill intent

- **shia-event** (veiled sacred figures): "move the figures, lock the camera off"; NEVER name
  face/veil/glow or the figure's names in the motion prompt; the #1 failure is the blank face
  being "completed" - guard with forward/level pose, `--lock-end-frame`, then Ken Burns. See
  `shia-event-video-creator/references/prompt_templates.md`.
- **ugc-app-ad** (photoreal actor): minimal motion / still-hold; identity is held at the image
  stage via `nano_banana.py --ref`; `--lock-end-frame` pins a framed/payoff beat.
