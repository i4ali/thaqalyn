---
name: generate-verse-art
description: Generate abstract/artistic AI images for Quranic verses using OpenRouter's Nano Banana Pro model. Use when asked to create artwork or images for verses.
argument-hint: [surah:verse]
allowed-tools: Read, Bash, Glob
---

# Generate Verse Art

Generate abstract, artistic AI images for Quranic verses using OpenRouter's Nano Banana Pro image generation model.

## Instructions

When invoked with a verse reference (e.g., `1:1` or `2:255`):

1. Parse the surah and verse number from `$ARGUMENTS`
2. Run the Python script to generate the image:
   ```bash
   source thaqalyn-env/bin/activate && python3 .claude/skills/generate-verse-art/scripts/generate_art.py $ARGUMENTS
   ```
3. Report the result to the user with the saved file path

## Input Format

- Single verse: `1:1`, `2:255`, `112:1`
- The script handles fetching verse text and tafsir context automatically

## Output

- Images saved to `verse_art/{surah}_{verse}.png`
- Vertical 9:16 story format (tall and narrow)
- Abstract/artistic style with no text or human figures

## Requirements

- `.env` file with `OPENROUTER_API_KEY`
- Python virtual environment: `.venv`
