"""Single source of truth: copy, colors, dimensions, fonts, slide defs."""
from pathlib import Path

# Canvas — 4:5 portrait
CANVAS_W = 1080
CANVAS_H = 1350

# Palette — dark & dramatic, gold typography
COLOR_BG_FALLBACK = (8, 9, 14)        # near-black, used if bg fails
COLOR_GOLD = (230, 122, 60)           # brand #E67A3C
COLOR_GOLD_BRIGHT = (247, 197, 110)   # brighter gold for glow/headlines
COLOR_CREAM = (240, 233, 220)         # body text on dark
COLOR_DIM = (170, 162, 150)           # captions / sources

# Fonts (macOS system)
FONT_ARABIC = "/System/Library/Fonts/SFArabic.ttf"
FONT_DISPLAY = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_BODY = "/System/Library/Fonts/Supplemental/Arial.ttf"

# Paths
OUTPUT_DIR = Path("dhul_hijjah_carousel")
BG_DIR = OUTPUT_DIR / "backgrounds"
APP_ICON = Path("appicon.png")
APP_SCREENSHOT = Path("scripts/dhul_hijjah_carousel/assets/app_screen_journey.png")

# Shared background style appended to every bg prompt
BG_STYLE = (
    "Dark, dramatic, reverent, cinematic spiritual atmosphere. Deep near-black "
    "night palette with a single warm gold light source. Abstract, no text, no "
    "letters, no words, no human figures, no faces, no animals. Minimal, "
    "elegant, lots of negative space. Subtle film grain. 4:5 vertical portrait."
)

SLIDES = [
    {
        "index": 1,
        "role": "hook",
        "headline": "You're about to waste\nthe best 10 days\nof the year.",
        "subtext": "The first ten days of Dhul-Hijjah",
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "A vast dark night sky over a tiny distant silhouette of "
                     "the Kaaba on the horizon, faint warm glow rising behind it.",
    },
    {
        "index": 2,
        "role": "pillar",
        "headline": "The most beloved days to Allah",
        "subtext": ("“There are no days in which righteous deeds are more "
                    "beloved to Allah than these ten days.”\n— the "
                    "Holy Prophet (ṣ)"),
        "arabic": "مَا مِنْ أَيَّامٍ الْعَمَلُ الصَّالِحُ فِيهِنَّ أَحَبُّ إِلَى اللَّهِ مِنْ هَٰذِهِ الْأَيَّامِ الْعَشْرِ",
        "arabic_verified": True,
        "bg_prompt": "Shafts of warm golden light breaking dramatically through "
                     "heavy dark clouds in a near-black sky.",
    },
    {
        "index": 3,
        "role": "pillar",
        "headline": "And most of us\nlet them slip by.",
        "subtext": ("Fasting · dhikr · repentance · the Day of "
                    "Arafah — the day of forgiveness. Gone, unnoticed, "
                    "every single year."),
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "A row of dim hanging brass lanterns fading into deep "
                     "darkness, one faint warm glow remaining.",
    },
    {
        "index": 4,
        "role": "pillar",
        "headline": "This year, don't.",
        "subtext": "See all 10 days — Arafah & Eid — guided, in the app.",
        "arabic": None,
        "arabic_verified": None,
        "app_screenshot": True,
        "bg_prompt": "First light of dawn breaking over a still dark desert, a "
                     "warm gold band on the horizon promising sunrise.",
    },
    {
        "index": 5,
        "role": "cta",
        "headline": "Don't do these\n10 days alone.",
        "subtext": "Download Thaqalayn — free on the App Store",
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "Minimal dark backdrop with a soft centered warm gold "
                     "radial glow, deep vignette edges.",
    },
]
