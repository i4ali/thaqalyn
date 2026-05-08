# Generate Tafsir Video — Design

**Date**: 2026-05-06
**Status**: Approved (design phase). Implementation plan to follow.
**Reference video**: `v12044gd0000cs6qt0fog65ut0gcss00.MP4` (44.6s, 9:16, narrated tafsir for Surah 2 Ayat 258)

## Goal

Create a Claude Code skill `generate-tafsir-video` that produces TikTok-style tafsir-explainer videos for any verse of the Quran. The visual base is rendered once via Kling and then reused; per-verse output only swaps narration audio + top header text + bottom synced captions. This avoids paying for Kling on every video.

## Non-goals

- Multi-language output (English only — Urdu/Arabic deferred)
- Multi-scene Kling regeneration per verse
- Per-surah / per-juz visual themes (single universal base for v1)
- Background music (narration-only)

## Architecture

Two phases inside one skill:

### Phase A — One-time silent base video setup

Driven manually by invoking `shia-event-video-creator` with a curated "tafsir-explainer" scene set:

- ~6–8 generic scenes that match the reference video's visual vocabulary: cosmos zoom, glowing Quran in dark space, exploding fire orb, planetary scenes, ethereal cosmos
- **Hard constraint**: NO baked-in text in any scene (negative-prompt all text rendering)
- Kling animates each scene; ffmpeg stitches into one continuous ~50s silent base
- Output saved to `.claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4`
- 1080×1920, no audio
- File is reused indefinitely

### Phase B — Per-verse generation (the new skill)

Invocation: `/generate-tafsir-video 2:258`
Output: `tafsir_videos/2_258.mp4`

Conversational + automated split:
1. Skill instructs the agent (Claude) to load tafsir layer2, draft a ~100-word narration with a "Allama Tabatabai explains that ayah {N}..." opener, iterate with the user, save the approved script to `tafsir_videos/temp/{surah}_{verse}_script.txt`.
2. Skill invokes `generate_tafsir_video.py --script-file <path>` which handles TTS, alignment, header rendering, and ffmpeg compositing.

## Components

```
.claude/skills/generate-tafsir-video/
├── SKILL.md                          # Skill definition + agent-facing instructions
├── scripts/
│   ├── generate_tafsir_video.py      # CLI orchestrator
│   ├── synthesize_speech.py          # ElevenLabs TTS + word-level alignment
│   ├── render_header.py              # PIL: pre-renders glowing cyan header PNG
│   └── compose_video.py              # ffmpeg compositor
├── assets/
│   ├── tafsir_base/
│   │   └── tafsir_base.mp4           # Silent base video (Phase A output)
│   └── fonts/
│       ├── header.ttf                # Bold display font for top header
│       └── caption.ttf               # Bold sans for word-by-word captions
└── references/
    └── tafsir_explainer_scenes.md    # Phase A prompt set for shia-event-video-creator
```

### Component responsibilities

| Component | Input | Output |
|---|---|---|
| `synthesize_speech.py` | narration text | `narration.mp3` + `word_timings.json` |
| `render_header.py` | surah English name + ayat number | `header.png` (1080×220, transparent) |
| `compose_video.py` | base.mp4 + narration.mp3 + word_timings + header.png | final `{surah}_{verse}.mp4` |
| `generate_tafsir_video.py` | CLI args (`surah:verse`, `--script-file`) | calls the above in sequence |

### Key technical choices

- **Pre-rendered header PNG (PIL) over ffmpeg drawtext** — ffmpeg drawtext cannot achieve the cyan glow + outer stroke + multi-pass effect cleanly. PIL with `ImageFilter.GaussianBlur` for the halo + multi-pass stroke gives CapCut-fidelity. Single PNG render per video.
- **Word-by-word captions via ffmpeg drawtext + `enable='between(t,start,end)'` per word** — reuses the pattern from `generate-tiktok-video`. Word timings are the single source of truth for caption sync.
- **Reuse via copy, not premature shared utility** — TTS+alignment helpers may overlap with `generate-tiktok-video` initially. Start by copying. Refactor to a shared module only if a third caller appears.
- **Script generation by the agent in conversation, not by Python** — preserves quality and review checkpoint without forcing a CLI-trapped LLM call. The Python pipeline is fully script-driven.

## Data flow

```
1. /generate-tafsir-video 2:258
   └─ Skill loads SKILL.md instructions for the agent.

2. Agent loads metadata
   ├─ Read Thaqalayn/Thaqalayn/Data/quran_data.json → "Al-Baqarah" → "AL-BAQARAH"
   └─ Read Thaqalayn/Thaqalayn/Data/tafsir_2.json → verses["258"]["layer2"]

3. Agent drafts ~100-word narration
   ├─ Opens with "Allama Tabatabai explains that ayah 258..."
   ├─ Declarative prose, no bullets, no Arabic, ~40s read aloud
   └─ Iterates with user; saves approved version to tafsir_videos/temp/2_258_script.txt

4. Agent invokes:
   python3 .claude/skills/generate-tafsir-video/scripts/generate_tafsir_video.py \
     --verse 2:258 --script-file tafsir_videos/temp/2_258_script.txt

5. Python pipeline:
   a. Pre-flight checks (see Error handling below)
   b. synthesize_speech.py
      ├─ ElevenLabs TTS (voice "Adam") → narration.mp3
      └─ ElevenLabs alignment endpoint → word_timings.json
   c. render_header.py
      ├─ PIL canvas 1080×220 transparent
      ├─ "SURAH AL-BAQARAH" / "AYAT 258" two lines, bold
      ├─ Cyan glow (#00E5FF) via GaussianBlur halo
      ├─ White inner stroke + bold fill
      └─ header.png
   d. compose_video.py (ffmpeg single-shot)
      ├─ Trim base to narration_duration (or freeze last frame if shorter)
      ├─ overlay header.png at y=80 (sticky for full duration)
      ├─ drawtext chain at y=1500 — one drawtext per word with enable=between(t,start,end)
      │   • Active word: bright yellow, larger
      │   • All other words rendered in muted yellow
      ├─ Audio: narration.mp3 (no background music)
      └─ Encode: -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p, -c:a aac -b:a 192k

6. Output: tafsir_videos/2_258.mp4
```

## Error handling

Per the project CLAUDE.md no-fallback rule, every failure throws a clear, actionable error. No silent degradation.

### Pre-flight (fail-fast before any I/O)

| Check | Failure message |
|---|---|
| `assets/tafsir_base/tafsir_base.mp4` exists | `"Base video missing. Run shia-event-video-creator with the tafsir-explainer prompt set first. Expected: assets/tafsir_base/tafsir_base.mp4"` |
| `Thaqalayn/Thaqalayn/Data/tafsir_{surah}.json` exists | `"Tafsir file not found for surah {N}."` |
| `verses["{verse}"]["layer2"]` non-empty | `"layer2 missing or empty for {surah}:{verse}."` |
| `quran_data.json` has surah {N} with `englishName` | `"Surah {N} not found in quran_data.json."` |
| `--script-file` exists & non-empty | `"Script file not found or empty: {path}."` |
| `ELEVENLABS_API_KEY` env var set | `"ELEVENLABS_API_KEY missing in .env."` |
| `ffmpeg` on PATH | `"ffmpeg not found. Install with: brew install ffmpeg"` |
| Font files exist | `"Font missing: {path}."` |

### Runtime failures (propagate; do not handle)

- ElevenLabs TTS non-200 → raise with status + body
- Alignment endpoint failure → raise (do NOT estimate timings from word count)
- ffmpeg non-zero exit → raise with last 40 lines of stderr (do NOT retry with simpler filter graph)
- PIL header render failure → raise (do NOT fall back to ffmpeg drawtext)

### Explicitly NOT doing

- ❌ No "try alternate voice if first voice fails"
- ❌ No "estimate evenly-spaced word timings if alignment fails"
- ❌ No "loop base if shorter than narration" (decision is made statically: trim or freeze last frame)
- ❌ No partial outputs — clean up `temp/` on any failure

### Idempotency

Same `surah:verse` + same script file → identical output (deterministic). Temp files namespaced by surah:verse so parallel runs don't collide.

## Testing

| Test | Verifies |
|---|---|
| Manual smoke (2:258) | Visual parity with reference video |
| `test_preflight_missing_base.py` | Pre-flight error when `tafsir_base.mp4` absent |
| `test_preflight_missing_tafsir.py` | Pre-flight error when tafsir json absent |
| `test_preflight_missing_layer2.py` | Pre-flight error when layer2 missing |
| `test_surah_name_resolution.py` | `"Al-Baqarah"` → `"AL-BAQARAH"` |
| `test_word_timings_parse.py` | Alignment response → `[{word,start,end}]` shape |
| `test_render_header_pixel.py` | Header PNG dimensions + non-empty alpha + SSIM > 0.95 vs fixture |
| `test_compose_video_metadata.py` | Output 1080×1920, duration matches narration ±0.5s (ffprobe) |

Skipped: ElevenLabs API tests (paid, flaky), ffmpeg correctness (trust the binary), script content (LLM/conversation artifact).

CI: not configured. Local creative tool, tests run on demand.

## Open items

None blocking. To revisit post-v1:
- Urdu / Arabic narration variants (existing skills already do Urdu — extending is straightforward)
- Multiple themed base videos (stories, cosmology, ethics) selected via verse category
- Reuse of TTS/alignment helpers as a shared module across `generate-tiktok-video` and this skill once the patterns stabilize
