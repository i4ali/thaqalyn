# TikTok Video Engagement Improvements Design

**Date:** 2026-02-17
**Status:** Approved
**Approach:** FFmpeg Text Overlays (Approach A)

## Goal

Improve TikTok video engagement through bold statement hooks, countdown pacing, and minimal text overlays to maximize viewer retention.

## Design Overview

### 1. Hook System

**Structure:**
```
[0-3 sec] HOOK: Bold statement + text overlay
[3-5 sec] SETUP: "Here are 3 insights from Surah X, Verse Y"
[5+ sec]  GEMS: Countdown reveal with numbers
```

**Bold Statement Generation:**
- New function `generate_hook(gems)` creates contextual hooks based on gem content
- Hook templates:
  - "This verse will transform how you understand {theme}"
  - "The Prophet's family taught this hidden meaning"
  - "Most people miss these {n} layers in this verse"

**Text Overlay (Hook):**
- Position: Center screen
- Font: White, bold, ~60px
- Duration: 3 seconds with fade in/out
- Shadow for readability over any image

### 2. Countdown Pacing

**Gem Reveal Structure:**
```
[5-7 sec]   "First..." + Gem 1 title overlay + narration
[7-15 sec]  Gem 1 insight narration (title stays visible)
[15-17 sec] "Second..." + Gem 2 title overlay
[17-25 sec] Gem 2 insight narration
[25-27 sec] "Third..." + Gem 3 title overlay
[27-35 sec] Gem 3 insight narration
[35-38 sec] Fade out
```

**Narration Script Format:**
```
"{hook}. Here are {n} insights from this verse. First... {gem1}. Second... {gem2}. Third... {gem3}."
```

**Dynamic Gem Count:**
- If verse has 2 gems: "2 insights"
- If verse has 4+ gems: cap at 3 for optimal TikTok length (<60 seconds)

**Text Overlay (Numbers):**
- Position: Top-left corner
- Style: Large number "1" / "2" / "3" with gem title below
- Timed to appear when narrator says "First/Second/Third"

### 3. Text Overlay Technical Design

**FFmpeg `drawtext` Specs:**
| Element | Position | Size | Style |
|---------|----------|------|-------|
| Hook text | Center | 60px | White, bold, fade in/out |
| Gem number | Top-left (x=50, y=100) | 80px | Bold number |
| Gem title | Below number | 40px | White |

**Font:** `/System/Library/Fonts/Helvetica.ttc` (macOS system font, clean look)

**Timing Calculation:**
- Fixed estimate: ~2 sec for transition words, ~8 sec per gem insight
- Text appears 0.5s before narrator says the gem title

**Filter Chain:**
```
[image] → zoompan (Ken Burns) → drawtext (hook) → drawtext (gem1) → drawtext (gem2) → drawtext (gem3) → [output]
```

**Readability:**
- Black shadow: `shadowx=2:shadowy=2`
- Semi-bold weight
- Edge padding: x=50, y=100 minimum

## Files to Modify

- `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`
  - Add `generate_hook(gems)` function
  - Update `build_narration_script()` with new format
  - Update `compose_video()` with drawtext filters
  - Add timing calculation logic

## Success Criteria

1. Videos start with bold statement hook (0-3 seconds)
2. Gems revealed with countdown ("First...", "Second...", "Third...")
3. Text overlays visible and readable on all verse art backgrounds
4. Total video length remains under 60 seconds
5. Existing functionality preserved (ambient audio mixing, Ken Burns effect)
