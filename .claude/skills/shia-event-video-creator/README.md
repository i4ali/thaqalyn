# shia-event-video-creator

A Claude skill for producing Shia Islamic short-form videos (TikTok/Reels/Shorts) depicting events from the lives of Prophet Muhammad ﷺ and the Ahlul Bayt (عليهم السلام).

## What it does

Staged interactive pipeline:

1. **Event** — you say "Ghadeer" (or any Shia event)
2. **Scenes** — Claude proposes a scene breakdown, you approve
3. **Images** — Claude calls Nano Banana or ChatGPT Image per scene, you review
4. **Videos** — Claude calls Kling (image-to-video) per approved image
5. **Package** — Claude delivers a TikTok caption, hashtags, and background-audio suggestions

All sacred figures (Prophet, 12 Imams, Fatima س, other Prophets) have their faces obscured by radiant light — never depicted — matching the Al-Thaqalayn visual tradition.

## Install

Drop the whole folder into your Claude skills directory. The layout is:

```
shia-event-video-creator/
├── SKILL.md
├── README.md
├── references/
│   ├── events.md
│   ├── style_guide.md
│   ├── religious_accuracy.md
│   └── prompt_templates.md
└── scripts/
    ├── generate_image.py
    ├── generate_video.py
    └── requirements.txt
```

## One-time setup

Install Python deps:

```bash
pip install -r scripts/requirements.txt --break-system-packages
```

Export API keys (add to your shell profile so they're persistent):

```bash
# For images
export GEMINI_API_KEY="..."      # Nano Banana (Google AI Studio)
export OPENAI_API_KEY="..."      # optional fallback

# For Kling — pick ONE auth style:

# (A) Official Kling API
export KLING_ACCESS_KEY="..."
export KLING_SECRET_KEY="..."

# (B) Third-party gateway (PiAPI, fal.ai, Kie.ai, AIML, etc.)
export KLING_API_KEY="..."
export KLING_API_ENDPOINT="https://api.piapi.ai/api/v1"   # adjust per provider
export KLING_AUTH_HEADER="Bearer"                          # or "X-API-Key"
```

Where to get keys:
- **Gemini (Nano Banana):** https://aistudio.google.com/apikey
- **OpenAI:** https://platform.openai.com/api-keys
- **Official Kling:** https://app.klingai.com/global/dev
- **PiAPI:** https://app.piapi.ai
- **fal.ai:** https://fal.ai/dashboard/keys

## Usage

Once installed, just ask Claude:

- "Make a Ghadeer TikTok"
- "Al-Thaqalayn video for Ashura"
- "Scenes for Mubahala, 5 scenes"
- "Do a Laylat al-Mabit one"

Claude will walk you through it, ask for approval at each stage, and deliver a fully packaged set of files under `/home/claude/video_output/<event>/`.

## Final assembly

This skill stops at individual video clips + the TikTok package. Stitching them into one 30-45 second video is done in your editor of choice:

- **CapCut** — easiest for mobile, supports 9:16 natively
- **Final Cut / Premiere / DaVinci** — if editing on desktop
- **ffmpeg** — for scripted assembly (you can ask Claude to generate the ffmpeg command once you have all the clips)

The audio track (latmiyya / nasheed / Quran recitation) is added in the editor — the skill gives you suggestions but doesn't download audio (that's a separate rights/licensing question).

## Tips

- **Don't skip the image review step.** A bad image becomes a bad 5-second video, and Kling generations are slow and cost money. Fix the still before committing to motion.
- **For climactic scenes, use 10s Kling duration.** For establishing/linking scenes, 5s is plenty.
- **If Nano Banana refuses a religious prompt,** simplify the sacred-figure description and frame the image as "a traditional religious painting." Or fall back to ChatGPT Image.
- **Consistency across scenes:** when generating scene 2+, pass the approved scene 1 image back as a reference (Nano Banana supports this) and ask for "the same rendering style and character."
- **Kling sometimes animates haloed faces** — if a generation makes the light shift in an unwanted way, regenerate with explicit "no head turns, figure is perfectly still" and a new seed.

## Costs (rough, as of 2026)

- **Nano Banana (Gemini 2.5 Flash Image):** ~$0.04/image
- **Nano Banana Pro (Gemini 3 Pro Image):** ~$0.10/image
- **gpt-image-1:** ~$0.04–$0.17/image depending on quality tier
- **Kling Standard 5s:** ~$0.60–$0.75
- **Kling Pro 5s:** ~$1.25
- **Kling Master 5s:** ~$4

A 6-scene Ghadeer video with 1 climactic 10s scene, using Nano Banana + Kling Standard, runs roughly $4–6 in API costs. Check current pricing on your provider's site.
