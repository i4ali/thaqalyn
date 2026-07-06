# Kling Hybrid Playbook (adopted June 2026)

Outcome of evaluating Kling's own tooling vs our pipeline. **Bottom line: keep kie.ai
(`scripts/kie_kling.py`, `--mode v3-0-pro`) + this skill as the automated backbone.**
Borrow Kling's prompt craft; reserve Motion Brush as a manual lane; camera_control was
tested and rejected (see §3).

## 1. Prompt craft to apply (from Kling's conventions)
Fold these into motion/image prompts. They complement, never override, the blank-face rules.
- **4-part spine:** Subject + Action + Context (≤3-5 elements) + Style (camera, light, mood). Don't pile on elements — Kling spends a fixed motion budget.
- **Direct it like a film, not a picture.** Name the shot ("locked-off tripod", "slow dolly-in"), the lens feel, the light. Kling cooperates more when treated as a virtual camera crew.
- **Name the move + give it a reason + an endpoint:** e.g. "slow push-in that settles as it reaches him." Endpoints ("…then holds") stop runaway motion.
- **One idea per clip.** Multiple actions → drift.

## 2. Our verified motion rules (hard-won on Al-Fajr 27)
- Kling 3.0 spends its motion budget on the **character** first → a prompt "push-in" on a prominent standing veiled figure makes the **figure walk toward camera**. Fix: locked-off for any prominent standing sacred figure; reserve push-ins for small/distant figures.
- "Crane up and reveal the full ring on every side" → over-rotates into a warped overhead. Fix: bounded "slight upward tilt, horizon kept in view," 5s.
- Camera **orbit** + a painted directional light shaft → the **light falls behind** the subject. Fix: regenerate the image with light coming **straight down from directly overhead** (orbit-stable); keep it subtle.
- Always QC start/⅓/⅔/end frames (ffmpeg `hstack`). Static figure = same size across frames; a walking figure enlarges.

## 3. Feature evaluation — use vs skip
| Kling feature | Verdict | Why |
|---|---|---|
| Deterministic **camera_control** (pan/tilt/zoom) | ❌ Reject | Verified: official API returns `code 1201 "Camera control is not supported by the current model"` on `kling-v2-1-master`. Runs only on `kling-v1`/`v1-6` — older models that hold the blank veiled face poorly. Not worth the face regression. kie.ai & fal-standard don't expose it at all. |
| **Motion Brush** (mask which regions move/freeze) | ✅ Manual lane | The cleanest fix for "figure frozen, only dust moves" + face-completion. **Web-app only**, not API. Use manually for the 1–2 hardest shots per film (see §4). |
| **Elements / Subject-binding** (1–4 ref imgs) | ◐ Test | May help hold the blank face across motion on 3.0. Verify per-model before relying on it. |
| Community **Kling prompt skill** (github, not official) | ❌ Don't adopt as-is | Generic, not doctrine-aware; would re-introduce face/lip-sync motion. Harvest its craft (§1), keep our guardrails. |
| Native audio / lip-sync | ➖ N/A | We use real Qari recitation, not generated audio. |

## 4. Motion Brush manual lane (the sharper "Ken Burns")
When a shot must have moving camera/elements but the figure keeps walking or the face keeps completing under kie.ai:
1. Open the approved still in the **Kling web app → Image-to-Video → Motion Brush**.
2. Paint motion vectors ONLY on environment (dust, banners, smoke). Leave the figure + face **unpainted** → frozen.
3. Generate on the current model (3.0). Download → `videos/scene_N.mp4` → re-stitch.
Works on current-gen models (unlike camera_control); surgical fix for our #1 failure.

## 5. Net
No migration. kie.ai stays the automated default; this skill stays the brain (now with §1 + §2 baked in); Motion Brush is the manual escalation; camera_control is closed. Re-evaluate if Kling ever exposes camera_control on v2.1/v3 or ships an API Motion Brush.
