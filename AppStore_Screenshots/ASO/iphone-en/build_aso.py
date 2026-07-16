#!/usr/bin/env python3
"""Build emerald English App Store screenshots: art bg + floating device + serif headline."""
import base64, pathlib, subprocess, sys, os

HERE = pathlib.Path(__file__).parent
ROOT = HERE.parent.parent.parent            # repo root
FONTS = ROOT / "Thaqalayn" / "Fonts"
ART = ROOT / "assets" / "premium-art"
SCR = ROOT / "assets" / "premium-art" / "app-preview" / "frames"   # fresh emerald screens
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1320, 2868

def b64(p): return base64.b64encode(pathlib.Path(p).read_bytes()).decode()
serif   = b64(FONTS / "CormorantGaramond-SemiBold.ttf")
serifm  = b64(FONTS / "CormorantGaramond-Medium.ttf")
serifit = b64(FONTS / "CormorantGaramond-MediumItalic.ttf")

# shot: id, screen png, bg art, eyebrow, head html (use <b> for gold accent), sub, rotate(deg)
SHOTS = [
    ("1_tafsir", SCR/"06_tafsir.png", ART/"style-frames/bluehour_A.png",
     "TAFSIR, REIMAGINED", "<b>Five layers.</b><br>One verse.",
     "From plain language to classical scholarship and the Ahlul Bayt - switch perspective with a tap.", -4),
    ("2_gems", SCR/"07_gems.png", ART/"style-frames/master_flag_A.png",
     "PRECIOUS GEMS", "Insights,<br><b>unveiled.</b>",
     "The heart of every verse - the core insight, and why it matters.", -4),
    ("3_journeys", SCR/"08_journeys.png", ART/"journeys/arbaeen_road_A.png",
     "SACRED SEASONS", "A path for<br><b>every season.</b>",
     "Ramadan, Muharram, Arbaeen and more - walk the year, guided.", -4),
    ("4_explore", SCR/"01_explore.png", ART/"style-frames/goldendusk_A.png",
     "LIFE & GUIDANCE", "Guidance for<br><b>every moment.</b>",
     "Life Moments, daily duas, and nourishment straight from the Qur'an.", -4),
    ("5_readreflect", SCR/"05_readreflect.png", ART/"style-frames/bluehour_B.png",
     "THE NOBLE QUR'AN", "All 114,<br><b>beautifully clear.</b>",
     "Every surah and verse - Arabic, translation and tafsir, together.", -4),
    ("6_surah", SCR/"04_surah.png", ART/"style-frames/master_flag_B.png",
     "READ, LISTEN, REFLECT", "Every verse,<br><b>in depth.</b>",
     "Recitation, translation, gems and commentary - verse by verse.", -4),
    ("7_quiz", SCR/"09_quiz.png", ART/"style-frames/goldendusk_B.png",
     "TEST YOUR KNOWLEDGE", "Learn, quiz,<br><b>remember.</b>",
     "Short quizzes on every surah lock in what you've read.", -4),
    ("8_today", SCR/"02_today.png", ART/"journeys/ramadan_city.png",
     "YOUR DAY", "A companion,<br><b>every day.</b>",
     "A daily verse, a reflection, and your journey - waiting each morning.", -4),
]

def fileuri(p): return "file://" + str(pathlib.Path(p).resolve())

def html_for(scr, bg, eyebrow, head, sub, rot):
    subhtml = f'<div class="sub">{sub}</div>' if sub else ""
    return f"""<!doctype html><html><head><meta charset='utf-8'><style>
@font-face{{font-family:'Corm';src:url(data:font/ttf;base64,{serif}) format('truetype');font-weight:600;}}
@font-face{{font-family:'CormM';src:url(data:font/ttf;base64,{serifm}) format('truetype');font-weight:500;}}
@font-face{{font-family:'CormIt';src:url(data:font/ttf;base64,{serifit}) format('truetype');font-style:italic;}}
*{{margin:0;padding:0;box-sizing:border-box;}}
html,body{{width:{W}px;height:{H}px;overflow:hidden;background:#05100B;}}
.canvas{{position:relative;width:{W}px;height:{H}px;overflow:hidden;
  font-family:-apple-system,'Helvetica Neue',sans-serif;}}
.bg{{position:absolute;inset:0;background:url('{fileuri(bg)}') center/cover no-repeat;
  filter:blur(2.5px) brightness(.66) saturate(1.16);transform:scale(1.14);}}
.tint{{position:absolute;inset:0;background:
   radial-gradient(60% 32% at 50% 66%, rgba(233,201,120,.24), rgba(233,201,120,0) 68%),
   linear-gradient(180deg, rgba(5,17,11,.86) 0%, rgba(6,19,13,.32) 22%, rgba(7,24,16,.04) 42%, rgba(6,18,12,.20) 64%, rgba(4,12,8,.82) 100%);}}
.vig{{position:absolute;inset:0;box-shadow:inset 0 0 300px 60px rgba(3,10,7,.72);}}
.text{{position:absolute;top:142px;left:0;right:0;padding:0 108px;text-align:center;}}
.eyebrow{{font-size:33px;font-weight:600;letter-spacing:7px;color:#D8B871;opacity:.95;margin-bottom:30px;}}
.head{{font-family:'Corm';font-weight:600;font-size:118px;line-height:1.06;color:#F3ECDA;letter-spacing:.5px;
  text-shadow:0 4px 40px rgba(0,0,0,.55);}}
.head b{{font-weight:600;color:#E9C978;}}
.sub{{font-family:'CormIt';font-style:italic;font-size:60px;line-height:1.4;color:rgba(235,227,209,.82);
  max-width:1040px;margin:40px auto 0;}}
.phone{{position:absolute;top:1000px;left:50%;transform:translateX(-50%) rotate({rot}deg);
  width:1016px;background:linear-gradient(160deg,#0b1712,#060d09);padding:16px;border-radius:112px;
  box-shadow:0 70px 150px rgba(0,0,0,.72), 0 20px 60px rgba(0,0,0,.55),
             0 0 0 1.5px rgba(233,201,120,.28), inset 0 0 0 2px rgba(233,201,120,.10);}}
.phone::after{{content:'';position:absolute;inset:16px;border-radius:96px;
  box-shadow:inset 0 0 0 1px rgba(233,201,120,.18);pointer-events:none;}}
.phone img{{display:block;width:100%;border-radius:96px;}}
</style></head><body>
<div class='canvas'>
  <div class='bg'></div><div class='tint'></div><div class='vig'></div>
  <div class='text'><div class='eyebrow'>{eyebrow}</div><div class='head'>{head}</div>{subhtml}</div>
  <div class='phone'><img src='{fileuri(scr)}'></div>
</div></body></html>"""

os.makedirs(HERE / "work", exist_ok=True)
os.makedirs(HERE / "out", exist_ok=True)
only = sys.argv[1:] if len(sys.argv) > 1 else None
for sid, scr, bg, eb, hd, sb, rot in SHOTS:
    if only and sid not in only: continue
    hp = HERE / "work" / f"{sid}.html"
    hp.write_text(html_for(scr, bg, eb, hd, sb, rot))
    out = HERE / "out" / f"{sid}.png"
    subprocess.run([CHROME,"--headless=new","--disable-gpu","--hide-scrollbars",
                    "--force-device-scale-factor=1",f"--screenshot={out}",
                    f"--window-size={W},{H}",f"file://{hp}"],
                   stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    print("rendered", out.name)
subprocess.run(["pkill","-f","Google Chrome"], stderr=subprocess.DEVNULL)
