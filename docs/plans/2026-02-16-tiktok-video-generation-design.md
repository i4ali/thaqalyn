# TikTok Video Generation Design

**Date:** 2026-02-16
**Status:** Approved

## Overview

Generate TikTok-ready videos from Quranic verse art with AI-narrated insights using ElevenLabs TTS and FFmpeg video composition.

## Requirements

- **Content**: Narrate key gems/insights from tafsir (not translation)
- **Voice**: ElevenLabs TTS (high-quality, natural voices)
- **Visual**: Ken Burns effect (subtle pan/zoom animation)
- **Audio**: Soft ambient nasheeds layered under narration
- **Interface**: Claude Code skill (`/generate-tiktok-video`)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    /generate-tiktok-video 2:255                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. LOAD DATA                                                   │
│     • Parse surah:verse                                         │
│     • Load gems from tafsir_{surah}.json                        │
│     • Verify verse art exists                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. GENERATE ASSETS                                             │
│     • Build narration script (intro + gems)                     │
│     • Call ElevenLabs API → narration.mp3                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. COMPOSE VIDEO (FFmpeg)                                      │
│     • Apply Ken Burns effect to image                           │
│     • Mix narration + ambient audio                             │
│     • Render 9:16 MP4 (1080x1920)                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Output: tiktok_videos/{surah}_{verse}.mp4                      │
└─────────────────────────────────────────────────────────────────┘
```

## File Structure

```
.claude/skills/generate-tiktok-video/
├── SKILL.md                    # Skill definition
├── scripts/
│   └── generate_tiktok.py      # Main orchestration script
└── assets/
    └── ambient/
        ├── ambient_1.mp3       # Soft nasheed/ambient track
        ├── ambient_2.mp3       # Alternative track
        └── ambient_3.mp3       # Third option (randomly selected)

tiktok_videos/                  # Output directory
└── {surah}_{verse}.mp4         # Generated videos
```

## Narration Script Structure

```
"This verse gives us these powerful insights..."

[Gem 1 title]: [Gem 1 insight]

[Gem 2 title]: [Gem 2 insight]

[Gem 3 title]: [Gem 3 insight]
```

**Example (Ayat al-Kursi 2:255):**
> "This verse gives us these powerful insights...
>
> The Living Guardian: Allah's watchfulness never sleeps - He sustains all creation without fatigue...
>
> Divine Knowledge: Nothing in the heavens or earth escapes His awareness..."

## Video Composition Details

### Ken Burns Effect
- Slow zoom from 100% → 110% over video duration
- Image stays centered during zoom
- Creates subtle motion to keep viewers engaged

### Audio Mixing
- Narration at 100% volume (foreground)
- Ambient track at 15-20% volume (background)
- Fade in ambient at start (1 sec)
- Fade out both at end (1.5 sec)

### Video Specifications

| Property | Value |
|----------|-------|
| Resolution | 1080x1920 (9:16) |
| Frame Rate | 30 fps |
| Codec | H.264 (libx264) |
| Audio | AAC 128kbps |
| Duration | Auto (matches narration + 2s padding) |

### FFmpeg Pipeline
1. Probe narration.mp3 duration
2. Scale image to 1200x2133 (slight overscan for zoom)
3. Apply zoompan filter (Ken Burns)
4. Mix narration + ambient with volume adjustment
5. Encode to MP4

## Skill Workflow

**Invocation:**
```
/generate-tiktok-video 2:255
```

**Steps:**
1. Parse verse reference (2:255)
2. Check if verse art exists (`verse_art/2_255.png`)
   - If missing: prompt user to run `/generate-verse-art 2:255` first
3. Load gems from `tafsir_2.json`
4. Build narration script with intro + gems
5. Call ElevenLabs API → `tiktok_videos/2_255_narration.mp3`
6. Select random ambient track from `assets/ambient/`
7. Run FFmpeg composition
8. Output: `tiktok_videos/2_255.mp4`
9. Report success with file path

## Dependencies

**Python Packages:**
- `elevenlabs` - TTS API SDK
- `python-dotenv` - Environment variable loading

**System:**
- FFmpeg (`brew install ffmpeg`)

**Environment Variables (.env):**
```
ELEVENLABS_API_KEY=your_key_here
```

## Error Handling

| Condition | Action |
|-----------|--------|
| No gems found | Error with message (tafsir required) |
| No verse art | Prompt to generate first |
| ElevenLabs fails | Clear error with API status |
| FFmpeg not installed | Installation instructions |

## Future Enhancements

- Batch mode: `/generate-tiktok-video 2:255-260` (multiple verses)
- Voice selection parameter
- Custom ambient track option
