---
name: generate-tiktok-video
description: Generate TikTok videos from verse art with AI narration of gems/insights using ElevenLabs TTS and FFmpeg. Supports English and Urdu.
argument-hint: [surah:verse] [--urdu]
allowed-tools: Read, Bash, Glob
---

# Generate TikTok Video

Generate TikTok-ready videos from Quranic verse art with AI-narrated insights. Supports both English and Urdu languages.

## Instructions

When invoked with a verse reference (e.g., `1:1` or `2:255`):

1. Parse the surah and verse number from `$ARGUMENTS`
2. Check if `--urdu` or `-u` flag is present for Urdu video generation
3. Run the Python script to generate the video:
   ```bash
   # English (default)
   source .venv/bin/activate && python3 .claude/skills/generate-tiktok-video/scripts/generate_tiktok.py $ARGUMENTS

   # Urdu
   source .venv/bin/activate && python3 .claude/skills/generate-tiktok-video/scripts/generate_tiktok.py $ARGUMENTS --urdu
   ```
4. Report the result to the user with the saved file path

## Input Format

- Single verse: `1:1`, `2:255`, `112:1`
- Add `--urdu` or `-u` for Urdu audio and text overlays
- Requires verse art to exist at `verse_art/{surah}_{verse}.png`
- Requires tafsir with gems at `Thaqalayn/Thaqalayn/Data/tafsir_{surah}.json`

## Output

- English videos: `tiktok_videos/{surah}_{verse}.mp4`
- Urdu videos: `tiktok_videos/urdu/{surah}_{verse}.mp4`
- Vertical 9:16 format (1080x1920)
- Ken Burns zoom effect with narration + ambient audio

## Language Support

### English (Default)
- Voice: Adam (clear, calm male voice)
- Text overlays in English
- Narration in English

### Urdu (`--urdu`)
- Voice: Aakash Aryan (Hindi/Urdu male voice)
- Text overlays in Urdu script
- Narration in Urdu
- Uses `title_urdu` and `coreInsight_urdu` from tafsir data

## Requirements

- `.env` file with `ELEVENLABS_API_KEY`
- FFmpeg installed (`brew install ffmpeg`)
- Python virtual environment with `elevenlabs` package
- Verse art image must exist (run `/generate-verse-art` first)
- For Urdu: tafsir must have Urdu translations (`title_urdu`, `coreInsight_urdu`)
