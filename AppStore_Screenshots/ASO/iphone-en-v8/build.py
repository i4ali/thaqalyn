#!/usr/bin/env python3
"""App Store screenshots v8 (6.9" 1320x2868): warm ivory backdrop, serif headline,
straight-on phone, serif caption with a gold highlighter mark.

  python3 build.py            # renders out/*.png with headless Chrome (throwaway profile)
  python3 build.py --canvas   # writes canvas/*.dc.html + canvas.json for the design canvas
  python3 build.py 3_tafsir   # render a single shot
  python3 build.py --ipad     # iPad 13" set (2064x2752) from shots-ipad/ into out-ipad/

Never kills or touches the user's own Chrome: headless runs with its own --user-data-dir.
"""
import base64, json, os, pathlib, subprocess, sys

HERE = pathlib.Path(__file__).parent
ROOT = HERE.parent.parent.parent
FONTS = ROOT / "Thaqalayn" / "Fonts"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1320, 2868

# Per-device geometry. iPad: 13" App Store slot (2064x2752), tablet frame.
GEO = {
    "phone": dict(W=1320, H=2868, shots="shots", out="out", head_top=180, head_pad=92, head_size=122,
                  dev_top=660, dev_w=1060, dev_pad=14, dev_radius=122, img_radius=108,
                  fade_top=2250, cap_bottom=128, cap_pad=118, cap_size=66),
    "ipad":  dict(W=2064, H=2752, shots="shots-ipad", out="out-ipad", head_top=170, head_pad=140, head_size=150,
                  dev_top=640, dev_w=1720, dev_pad=22, dev_radius=96, img_radius=74,
                  fade_top=2160, cap_bottom=120, cap_pad=200, cap_size=78),
}
G = GEO["ipad" if "--ipad" in sys.argv else "phone"]
W, H = G["W"], G["H"]

# id, screenshot stem, headline (html), caption (html; <mark> = gold highlighter)
SHOTS = [
    ("1_today", "01_today",
     "Your deen, every day.<br>One place.",
     "Quran, tafsir, duas and journeys, <mark>waiting each morning.</mark>"),
    ("2_quran", "02_surah",
     "Read, listen and reflect,<br>verse by verse.",
     "Recitation, translation and gems for <mark>all 114 surahs.</mark>"),
    ("3_passage", "03_passage",
     "Read, understand,<br>then test yourself.",
     "Every passage explained with sourced narrations, <mark>then a quiz to make it stick.</mark>"),
    ("4_duas", "04_dua",
     "The great duas,<br>with recitation.",
     "Arabic, transliteration and translation, <mark>following the reciter word by word.</mark>"),
    ("5_journeys", "05_journeys",
     "A guided path for<br>every sacred season.",
     "Ramadan, Muharram and Deep Dives, <mark>read or simply listen.</mark>"),
    ("6_inside", "06_inside",
     "Step inside the story<br>of a surah.",
     "Immersive journeys, surah by surah. <mark>Scroll to sink deeper.</mark>"),
    ("7_quiz", "07_quiz",
     "Five questions<br>after every passage.",
     "Answer, see why, <mark>and jump back to the line it came from.</mark>"),
    ("8_progress", "08_progress",
     "Watch your journey<br>take shape.",
     "Rings, streaks and badges for <mark>every verse you read.</mark>"),
    ("9_gems", "09_gems",
     "Two weighty things,<br>never apart.",
     "Every verse, dua and journey, <mark>in the light of the Quran and the Ahlul Bayt.</mark>"),
    ("10_perspectives", "10_perspectives",
     "How both traditions<br>read the passage.",
     "Shia and Sunni commentary on the same verses, <mark>each view sourced.</mark>"),
]

INK = "#1A1408"
GOLD = "#D6B25E"

# 8-point star lattice, gold, very faint (data-URI SVG tile)
STAR_SVG = (
    "<svg xmlns='http://www.w3.org/2000/svg' width='220' height='220' viewBox='0 0 220 220'>"
    "<g fill='none' stroke='#B8923F' stroke-width='1.2' opacity='0.16'>"
    "<rect x='40' y='40' width='140' height='140'/>"
    "<rect x='40' y='40' width='140' height='140' transform='rotate(45 110 110)'/>"
    "<circle cx='110' cy='110' r='16'/>"
    "</g></svg>"
)
STAR_URI = "data:image/svg+xml;utf8," + STAR_SVG.replace("#", "%23").replace("'", "%27")


def b64(p): return base64.b64encode(pathlib.Path(p).read_bytes()).decode()


def font_css_embedded():
    return (
        f"@font-face{{font-family:'Cormorant Garamond';font-weight:600;"
        f"src:url(data:font/ttf;base64,{b64(FONTS/'CormorantGaramond-SemiBold.ttf')}) format('truetype');}}"
        f"@font-face{{font-family:'Cormorant Garamond';font-weight:500;"
        f"src:url(data:font/ttf;base64,{b64(FONTS/'CormorantGaramond-Medium.ttf')}) format('truetype');}}"
    )


def body(img_src, head, cap):
    """The artboard body: every visual value inline so the canvas can restyle it."""
    return f"""<div style="position: relative; width: {W}px; height: {H}px; overflow: hidden; background: #FAF2E8; font-family: 'Cormorant Garamond', 'Cormorant', Georgia, 'Times New Roman', serif; color: {INK};">
  <div style="position: absolute; inset: 0; background: radial-gradient(70% 45% at 18% 8%, #E6EEEB 0%, rgba(230,238,235,0) 70%), radial-gradient(75% 50% at 88% 96%, #F8E5D2 0%, rgba(248,229,210,0) 70%), linear-gradient(180deg, #FAF2E8 0%, #F4ECDD 100%);"></div>
  <div style="position: absolute; inset: 0; background-image: url(&quot;{STAR_URI}&quot;); background-size: 220px 220px; -webkit-mask-image: radial-gradient(80% 60% at 50% 40%, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.15) 100%); mask-image: radial-gradient(80% 60% at 50% 40%, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.15) 100%);"></div>
  <div style="position: absolute; top: {G['head_top']}px; left: 0; right: 0; padding: 0 {G['head_pad']}px; text-align: center; font-weight: 600; font-size: {G['head_size']}px; line-height: 1.08; letter-spacing: -0.5px;">{head}</div>
  <div style="position: absolute; top: {G['dev_top']}px; left: 50%; transform: translateX(-50%); width: {G['dev_w']}px; padding: {G['dev_pad']}px; border-radius: {G['dev_radius']}px; background: linear-gradient(165deg, #121D18, #060C09); box-shadow: 0 50px 110px rgba(26,20,8,0.30), 0 16px 40px rgba(26,20,8,0.22), 0 0 0 1.5px rgba(184,146,63,0.40);">
    <img src="{img_src}" alt="" style="display: block; width: 100%; border-radius: {G['img_radius']}px;">
  </div>
  <div style="position: absolute; left: 0; right: 0; top: {G['fade_top']}px; height: {H - G['fade_top']}px; background: linear-gradient(180deg, rgba(247,238,224,0) 0%, rgba(247,238,224,0.92) 42%, #F5ECDD 100%);"></div>
  <div style="position: absolute; left: 0; right: 0; bottom: {G['cap_bottom']}px; padding: 0 {G['cap_pad']}px; text-align: center; font-weight: 500; font-size: {G['cap_size']}px; line-height: 1.34; text-wrap: balance;">{cap}</div>
</div>"""


MARK_CSS = (
    "mark{background:linear-gradient(180deg, rgba(214,178,94,0) 18%, rgba(214,178,94,0.42) 18%, rgba(214,178,94,0.42) 92%, rgba(214,178,94,0) 92%);"
    "color:inherit;padding:0 0.06em;border-radius:4px;}"
)


def render_html(sid, stem, head, cap):
    img = "data:image/png;base64," + b64(HERE / G["shots"] / f"{stem}.png")
    return f"""<!doctype html><html><head><meta charset="utf-8"><style>
{font_css_embedded()}
*{{margin:0;padding:0;box-sizing:border-box;}}
html,body{{width:{W}px;height:{H}px;overflow:hidden;background:#FAF2E8;}}
{MARK_CSS}
</style></head><body>{body(img, head, cap)}</body></html>"""


def canvas_html(sid, stem, head, cap):
    return f"""<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;600&display=swap">
  <style>
    body {{ margin: 0; background: #FAF2E8; }}
    a {{ color: #B8923F; }} a:hover {{ color: #8F6F2A; }}
    {MARK_CSS}
  </style>
</helmet>
{body(stem + ".jpg", head, cap)}
</x-dc>
<script data-dc-script data-props='{{"$preview":{{"width":{W},"height":{H}}}}}'>
class Component extends DCLogic {{}}
</script>
</body>
</html>"""


def write_canvas():
    cdir = HERE / "canvas"
    boards = []
    x = 0
    for i, (sid, stem, head, cap) in enumerate(SHOTS):
        name = "Main" if i == 0 else f"Shot{i+1}"
        (cdir / f"{name}.dc.html").write_text(canvas_html(sid, stem, head, cap))
        boards.append({"file": f"{name}.dc.html", "title": sid.replace("_", " ").title(),
                       "x": x, "y": 0, "w": W, "h": H})
        x += W + 120
    (cdir / "canvas.json").write_text(json.dumps({"artboards": boards, "launch": {"view": "canvas"}}, indent=2))
    print("canvas:", ", ".join(b["file"] for b in boards))


def render(only):
    work = HERE / ("work-ipad" if G["out"] == "out-ipad" else "work"); out = HERE / G["out"]
    work.mkdir(exist_ok=True); out.mkdir(exist_ok=True)
    profile = pathlib.Path(os.environ.get("TMPDIR", "/tmp")) / "aso-v8-chrome-profile"
    for sid, stem, head, cap in SHOTS:
        if only and sid not in only: continue
        hp = work / f"{sid}.html"
        hp.write_text(render_html(sid, stem, head, cap))
        png = out / f"{sid}.png"
        try:
            subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                        f"--user-data-dir={profile}", "--no-first-run", "--no-default-browser-check",
                        "--force-device-scale-factor=1", f"--screenshot={png}",
                        f"--window-size={W},{H}", "--virtual-time-budget=4000", f"file://{hp}"],
                       stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL, timeout=25)
        except subprocess.TimeoutExpired:
            pass  # screenshot is written before the process is torn down
        print("rendered", png.name if png.exists() else f"FAILED {sid}")


if __name__ == "__main__":
    args = sys.argv[1:]
    if "--canvas" in args:
        write_canvas()
    else:
        render([a for a in args if not a.startswith("--")])
