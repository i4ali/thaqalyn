---
name: generate-tafsir-video
description: Generate TikTok-style tafsir-explainer videos for any Quranic verse. The agent drafts a ~40s narration from tafsir layer2 (Tabatabai/Classical Shia), the user approves it in chat, then a Python pipeline does ElevenLabs TTS, renders a glowing cyan header, and composites everything onto a pre-rendered silent base video with synced word-by-word captions. Use when the user says "make a tafsir video for X:Y", "generate verse video for surah X verse Y", or similar. Requires assets/tafsir_base/tafsir_base.mp4 (one-time Phase A setup via shia-event-video-creator) and ELEVENLABS_API_KEY.
argument-hint: [surah:verse]
allowed-tools: Read, Write, Bash
---

# Generate Tafsir Video

Per-verse video generator that reuses a Kling-rendered silent base video and only swaps narration + header + captions.

## Phase A — One-time base video setup (manual)

Before this skill can run, the user must produce `.claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4`. See `references/tafsir_explainer_scenes.md` — feed those scene prompts into `shia-event-video-creator`, then ffmpeg-concat the outputs.

If the base video is missing, the Python pipeline pre-flight will say so explicitly.

## Phase B — Per-verse workflow (this skill)

When invoked with `$ARGUMENTS = "2:258"`:

1. **Parse** the surah and verse from `$ARGUMENTS`.

2. **Load tafsir layer2** for that verse from `Thaqalayn/Thaqalayn/Data/tafsir_{surah}.json` (key: `verses[str(verse)]["layer2"]`). This layer is the Classical Shia / Tabatabai-style commentary.

3. **Draft a ~100-word narration** from layer2:
   - Open with: `"Allama Tabatabai explains that ayah {verse}..."`
   - Declarative prose, no bullets, no list markers
   - No Arabic script in the narration text (this is for English TTS)
   - Aim for ~40 seconds of read-aloud time
   - Preserve the key argument/insight — don't add new content

4. **Show the draft to the user** and iterate until they approve.

5. **Save the approved script** to `tafsir_videos/temp/{surah}_{verse}_script.txt` (create dirs as needed).

6. **Draft 5 high-quality TikTok hashtags** for the video. **Niche-first strategy** — this account is small (~2K followers). Avoid billion-use tags (`#fyp`, `#islam`, `#muslim`, `#quran` alone) — they bury small accounts in oceans of content where the algorithm reads low engagement as low quality. Aim for tags in the **100K–10M post range** where the account can actually rank in the "Popular" tab.

   The 5 slots:
   - **1 thematic exact-match** — the verse's core concept (e.g. `#tawakkul` for trust verses, `#nur` or `#lightofallah` for the Light Verse, `#sabr` for patience-themed, `#rahma` for mercy-themed, `#qadr` for divine decree, `#tawbah` for repentance). Most important tag — pick the term Tabatabai's commentary actually pivots on.
   - **1 secondary thematic** — a related English-language thematic tag (e.g. `#trustinallah`, `#patience`, `#divinemercy`, `#faith`, `#guidance`). Reaches non-Arabic-speakers searching by concept.
   - **1 content-type niche** — `#islamicreminder` (~5M posts, engaged spiritual audience), `#quranverse` (~3M posts), `#tafsir`, or `#quranquotes`. Pick by tone match.
   - **1 community signal** — `#ahlulbayt` (default for this Shia tafsir channel — ~1M posts, devoted audience). Alternates: `#shiamuslim`, `#imamali`, `#karbala` for Muharram-themed verses.
   - **1 verse-specific OR sub-niche** — `#SurahAtTawbah`, `#Ayah51`, or a more specific niche concept tag. Favor a surah tag only for famous surahs (Baqarah, Yasin, Mulk, Rahman, Kahf, Ikhlas).

   **Do NOT include**: `#fyp` (placebo — TikTok confirmed it doesn't affect FYP), `#foryou`, `#viral`, `#islam`, `#muslim`, `#quran` (all billion-volume traps for small accounts).

   Show the proposed 5 to the user, iterate if they want changes, then save space-separated to `tafsir_videos/temp/{surah}_{verse}_hashtags.txt`.

   Do NOT exceed 5 unless the user explicitly asks.

7. **Invoke the Python pipeline** (with the hashtags file):

```bash
source .venv/bin/activate && python3 .claude/skills/generate-tafsir-video/scripts/generate_tafsir_video.py \
  --verse {surah}:{verse} \
  --script-file tafsir_videos/temp/{surah}_{verse}_script.txt \
  --hashtags-file tafsir_videos/temp/{surah}_{verse}_hashtags.txt
```

8. **Report** the output paths to the user:
   - Video: `tafsir_videos/{surah}_{verse}.mp4`
   - Hashtags: `tafsir_videos/{surah}_{verse}_hashtags.txt`

## Output

- `tafsir_videos/{surah}_{verse}.mp4` — 1080×1920, ~40–50s, narrated.
- `tafsir_videos/{surah}_{verse}_hashtags.txt` — 5 curated TikTok hashtags, space-separated.

## Requirements

- `.env` with `ELEVENLABS_API_KEY`
- `ffmpeg` on PATH (`brew install ffmpeg`)
- Project `.venv` with `pillow` and `requests` installed
- `assets/tafsir_base/tafsir_base.mp4` (one-time Phase A output)
- `assets/fonts/header.ttf` and `assets/fonts/caption.ttf`

## Failure modes

The Python pipeline does pre-flight checks and raises clear errors if anything is missing. There are no fallbacks (per project CLAUDE.md). If a check fails, fix the listed issue and re-run.
