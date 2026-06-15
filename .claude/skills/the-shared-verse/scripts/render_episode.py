#!/usr/bin/env python3
"""The Shared Verse — episode video pipeline.

Turns an episode JSON into a finished, chrome-free vertical video with voiceover:

  1. Load + validate the episode JSON.
  2. ElevenLabs TTS for the 6 voiceover beats (in spoken order).
  3. Measure clip durations -> audio-driven beat start times (with gaps).
  4. Assemble the narration track (each clip placed at its beat time).
  5. Build a render-ready HTML (inject window.EPISODE + base64-embed bundled fonts).
  6. Screenshot every frame with headless Chrome in parallel, via ?frame=<ms>.
  7. ffmpeg: frames + narration -> mp4 (1080x1920, H.264/AAC).

The exported video is the CLEAN 9:16 only — no phone frame, handle, hashtags, or
"For You" chrome. Those live in episode-template.html for in-feed preview only.

No fallbacks. Every step fails fast with a clear error.

Usage:
  python scripts/render_episode.py episodes/almaidah-5-55.json
  python scripts/render_episode.py episodes/<slug>.json --fps 30
  python scripts/render_episode.py episodes/<slug>.json --preview   # open the demo, no render
"""
from __future__ import annotations
import argparse
import base64
import json
import math
import os
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from tts import synthesize, synthesize_timed  # noqa: E402
from capture_cdp import capture_frames_cdp  # noqa: E402
import unicodedata

SKILL_ROOT = HERE.parent
TEMPLATE = SKILL_ROOT / "episode-template.html"
FONT_DIR = SKILL_ROOT / "assets" / "fonts"
PROJECT_ROOT = SKILL_ROOT.parents[2]
OUTPUT_DIR = PROJECT_ROOT / "the_shared_verse"

FONT_FILES = {
    ("normal", 400): "Amiri-Regular.ttf",
    ("normal", 700): "Amiri-Bold.ttf",
    ("italic", 400): "Amiri-Italic.ttf",
    ("italic", 700): "Amiri-BoldItalic.ttf",
}

CHROME_CANDIDATES = [
    os.environ.get("CHROME_BIN", ""),
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    shutil.which("google-chrome") or "",
    shutil.which("chromium") or "",
]

# timing knobs (ms)
GAP_MS = 350          # silence between voiceover beats
TAIL_MS = 900         # hold after the final beat
LEAD_MS = 250         # tiny lead-in before any audio

TRAD_NAME = {"sunni": "Sunni", "shia": "Shia"}
TRAD_TAG = {"sunni": "b", "shia": "i"}   # matches .vo b{gold} / .vo i{teal} in the template



# Modifier letters (ʿayn / hamza) TTS reads poorly; combining marks (macrons,
# dots) too. Strip them for the SPOKEN text only — the screen keeps the elegant
# diacritics. This is per-character, so word boundaries (and thus the 1:1 word
# mapping that drives the highlight) are preserved exactly.
_STRIP_LETTERS = {"\u02bf", "\u02be", "\u02bb", "\u02bc", "\u02b9", "\u0294", "\u02c8"}


def normalize_for_tts(text: str) -> str:
    text = "".join("" if ch in _STRIP_LETTERS else ch for ch in text)
    decomposed = unicodedata.normalize("NFD", text)
    stripped = "".join(ch for ch in decomposed if not unicodedata.combining(ch))
    return unicodedata.normalize("NFC", stripped)


# ----------------------------- preflight -----------------------------

def find_chrome() -> str:
    for c in CHROME_CANDIDATES:
        if c and Path(c).exists():
            return c
    raise EnvironmentError(
        "Google Chrome not found. Install Chrome or set CHROME_BIN to its binary."
    )


def preflight() -> str:
    if not TEMPLATE.exists():
        raise FileNotFoundError(f"Template missing: {TEMPLATE}")
    if shutil.which("ffmpeg") is None or shutil.which("ffprobe") is None:
        raise EnvironmentError("ffmpeg/ffprobe not found. Install with: brew install ffmpeg")
    for fn in FONT_FILES.values():
        if not (FONT_DIR / fn).exists():
            raise FileNotFoundError(f"Bundled font missing: {FONT_DIR / fn}")
    if not os.environ.get("ELEVENLABS_API_KEY"):
        raise EnvironmentError("ELEVENLABS_API_KEY missing in .env.")
    return find_chrome()


# ----------------------------- episode load -----------------------------

def load_episode(path: Path) -> dict:
    ep = json.loads(Path(path).read_text())
    required = ["slug", "verse_ref", "arabic", "translation", "order", "readings", "voiceover"]
    for k in required:
        if k not in ep:
            raise ValueError(f"Episode JSON missing required key: {k!r}")
    order = ep["order"]
    if sorted(order) != ["shia", "sunni"]:
        raise ValueError('order must be ["sunni","shia"] or ["shia","sunni"].')
    for trad in ("sunni", "shia"):
        r = ep["readings"].get(trad)
        if not r:
            raise ValueError(f"readings.{trad} missing.")
        for k in ("label", "body", "source"):
            if not r.get(k):
                raise ValueError(f"readings.{trad}.{k} missing or empty.")
    for k in ("hook", "reference", "payoff", "question"):
        if not ep["voiceover"].get(k):
            raise ValueError(f"voiceover.{k} missing or empty.")

    # Fairness nudge (non-fatal): the two readings should be matched in length.
    a = len(ep["readings"][order[0]]["body"].split())
    b = len(ep["readings"][order[1]]["body"].split())
    if a and b and max(a, b) / min(a, b) > 1.4:
        print(f"  ⚠ readings differ in length ({a} vs {b} words). Symmetry is the "
              f"safety mechanism — consider matching them.")
    return ep


def build_episode_js(ep: dict, beats: dict, end_ms: int, trans_words: list | None = None, reading_words: dict | None = None) -> dict:
    """Assemble the window.EPISODE object the template consumes."""
    order = ep["order"]
    first, second = order[0], order[1]
    vo = ep["voiceover"]
    hook_cap = vo.get("hook_caption") or "How do two of Islam’s great traditions read the same verse?"
    return {
        "content": {
            "verse_ref": ep["verse_ref"],
            "arabic": ep["arabic"],
            "translation": ep["translation"],
            "order": order,
            "readings": {
                t: {"label": ep["readings"][t]["label"],
                    "body": ep["readings"][t]["body"],
                    "source": ep["readings"][t]["source"],
                    "bodyWords": (reading_words or {}).get(t, [])}
                for t in ("sunni", "shia")
            },
            "caption_desc": ep.get("caption_desc", ""),
            "transWords": trans_words or [],
            "cta": ep.get("cta_text") or ep["voiceover"].get("question", ""),
        },
        "beats": beats,
        "end": end_ms,
        "captions": {
            "hook": hook_cap,
            "readingA": f"First — the <{TRAD_TAG[first]}>{TRAD_NAME[first]}</{TRAD_TAG[first]}> reading.",
            "readingB": f"And the <{TRAD_TAG[second]}>{TRAD_NAME[second]}</{TRAD_TAG[second]}> reading.",
        },
        "showCaptions": ep.get("show_captions", True),
        "showSynth": ep.get("show_payoff_text", True),
        "showCta": ep.get("show_closing_text", True),
    }


# ----------------------------- audio -----------------------------

def ffprobe_duration(path: Path) -> float:
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
        capture_output=True, text=True)
    if out.returncode != 0 or not out.stdout.strip():
        raise RuntimeError(f"ffprobe failed on {path}: {out.stderr[:200]}")
    return float(out.stdout.strip())


def synth_segments(ep: dict, tmp: Path):
    """TTS the 6 beats. Returns (segments, translation_words, reading_words).

    The verse and the two readings speak the SAME text shown on screen, via the
    timestamped endpoint, so their words can be highlighted in sync. Readings are
    normalized for TTS (diacritics stripped) but displayed with diacritics intact —
    normalization is per-character, so the word mapping stays 1:1.
    """
    order = ep["order"]
    vo = ep["voiceover"]
    ref = vo.get("reference")
    translation = ep["translation"]
    verse_text = f"{ref.rstrip(' .')}. {translation}" if ref else translation
    ref_n = len(ref.split()) if ref else 0
    pins = ep.get("pins") or {}

    plan = [
        ("hook", vo["hook"], None),
        ("verse", verse_text, None),
        ("readingA", ep["readings"][order[0]]["body"], order[0]),
        ("readingB", ep["readings"][order[1]]["body"], order[1]),
        ("payoff", vo["payoff"], None),
        ("question", vo["question"], None),
    ]
    segs: list[tuple[str, Path, float]] = []
    trans_words: list[dict] = []
    reading_words: dict[str, list[dict]] = {}
    for i, (name, text, trad) in enumerate(plan):
        mp3 = tmp / f"seg{i}_{name}.mp3"
        pin = pins.get(name)
        if pin:
            src = Path(pin) if Path(pin).is_absolute() else SKILL_ROOT / pin
            if not src.exists():
                raise FileNotFoundError(f"Pinned audio for '{name}' not found: {src}")
            if name == "verse" or trad is not None:
                raise ValueError(f"Cannot pin '{name}': highlighted beats need live word timings.")
            print(f"  [pin {i+1}/6] {name}: using {src.name}")
            shutil.copy(src, mp3)
            segs.append((name, mp3, ffprobe_duration(mp3)))
            continue
        print(f"  [tts {i+1}/6] {name}: {text[:54]}{'…' if len(text) > 54 else ''}")
        if name == "verse":
            words = synthesize_timed(text, mp3)
            if len(words) <= ref_n:
                raise RuntimeError("Verse alignment shorter than the reference — cannot split.")
            trans_words = [{"w": w["word"], "s": int(round(w["start"] * 1000)), "e": int(round(w["end"] * 1000))}
                           for w in words[ref_n:]]
        elif trad is not None:
            spoken = normalize_for_tts(text)
            words = synthesize_timed(spoken, mp3)
            display = text.split()
            if len(words) != len(display):
                raise RuntimeError(
                    f"reading {trad}: {len(words)} spoken words != {len(display)} displayed words. "
                    f"Reword the body so display and speech tokenize the same.")
            reading_words[trad] = [{"w": display[j],
                                    "s": int(round(words[j]["start"] * 1000)),
                                    "e": int(round(words[j]["end"] * 1000))}
                                   for j in range(len(display))]
        else:
            synthesize(text, mp3)
        segs.append((name, mp3, ffprobe_duration(mp3)))
    return segs, trans_words, reading_words

def compute_beats(segs: list[tuple[str, Path, float]]) -> tuple[dict, list[int], int]:
    """Audio-driven beat start times (ms). Each visual beat reveals when its
    voiceover clip begins. Returns (beats, audio_start_ms[], end_ms)."""
    d = [int(round(s[2] * 1000)) for s in segs]   # ms durations, in spoken order
    starts = [LEAD_MS]
    for k in range(1, 6):
        starts.append(starts[-1] + d[k - 1] + GAP_MS)
    end_ms = starts[5] + d[5] + TAIL_MS
    beats = {
        "hook": starts[0], "verse": starts[1], "readingA": starts[2],
        "readingB": starts[3], "payoff": starts[4], "question": starts[5],
    }
    return beats, starts, end_ms


def assemble_narration(segs, starts: list[int], end_ms: int, out_wav: Path) -> Path:
    """Place each clip at its start time and mix into one track of length end_ms."""
    inputs, filters, labels = [], [], []
    for i, (_, mp3, _) in enumerate(segs):
        inputs += ["-i", str(mp3)]
        filters.append(
            f"[{i}:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=mono,"
            f"adelay={starts[i]}:all=1[a{i}]")
        labels.append(f"[a{i}]")
    end_s = end_ms / 1000.0
    fc = (";".join(filters) + ";" + "".join(labels) +
          f"amix=inputs={len(segs)}:normalize=0:dropout_transition=0[m];"
          f"[m]apad,atrim=0:{end_s:.3f}[out]")
    cmd = ["ffmpeg", "-y", *inputs, "-filter_complex", fc,
           "-map", "[out]", "-ar", "44100", "-ac", "1", str(out_wav)]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError("narration assembly failed:\n" + "\n".join(res.stderr.splitlines()[-25:]))
    return out_wav


# ----------------------------- html / frames -----------------------------

def font_face_block() -> str:
    lines = []
    for (style, weight), fn in FONT_FILES.items():
        b64 = base64.b64encode((FONT_DIR / fn).read_bytes()).decode("ascii")
        lines.append(
            f'@font-face{{font-family:"AmiriLocal";font-style:{style};font-weight:{weight};'
            f'src:url(data:font/ttf;base64,{b64}) format("truetype")}}')
    return "\n".join(lines)


def build_render_html(episode_js: dict, out_html: Path) -> Path:
    html = TEMPLATE.read_text()

    # 1) self-contained fonts (no network during capture)
    start, end = "/*FONT-FACE-START*/", "/*FONT-FACE-END*/"
    pre, _, rest = html.partition(start)
    _, _, post = rest.partition(end)
    html = pre + start + "\n" + font_face_block() + "\n" + end + post

    # Network <link> font tags make headless Chrome stall on every frame
    # (virtual-time pauses on the pending fetch). Strip them — Amiri is
    # base64-embedded above, so capture needs no network at all.
    for _ln in (
        '<link rel="preconnect" href="https://fonts.googleapis.com">',
        '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>',
        '<link href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">',
    ):
        html = html.replace(_ln, "")

    # 2) inject the episode object
    inject = "<script>window.EPISODE = " + json.dumps(episode_js, ensure_ascii=False) + ";</script>"
    if "<!--EPISODE-INJECT-->" not in html:
        raise RuntimeError("Template missing the <!--EPISODE-INJECT--> marker.")
    html = html.replace("<!--EPISODE-INJECT-->", inject, 1)

    out_html.write_text(html)
    return out_html


def capture_frames(chrome: str, html: Path, end_ms: int, fps: int, frames_dir: Path,
                   workers: int) -> int:
    # Warm-Chrome capture over the DevTools Protocol: a few browsers loaded ONCE,
    # then seek()+screenshot per frame. Avoids a cold browser launch per frame.
    instances = max(2, min(4, workers))
    return capture_frames_cdp(chrome, html, end_ms, fps, frames_dir,
                              frames_dir.parent, instances)

def compose(frames_dir: Path, narration: Path, fps: int, out_mp4: Path) -> Path:
    out_mp4.parent.mkdir(parents=True, exist_ok=True)
    cmd = ["ffmpeg", "-y",
           "-framerate", str(fps), "-i", str(frames_dir / "f_%05d.png"),
           "-i", str(narration),
           "-c:v", "libx264", "-preset", "medium", "-crf", "20",
           "-pix_fmt", "yuv420p", "-r", str(fps),
           "-c:a", "aac", "-b:a", "192k", "-shortest",
           str(out_mp4)]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError("ffmpeg compose failed:\n" + "\n".join(res.stderr.splitlines()[-25:]))
    return out_mp4


# ----------------------------- preview -----------------------------

def preview(ep: dict) -> None:
    """Write a populated demo HTML (with chrome) and open it. No render."""
    episode_js = build_episode_js(
        ep, {"hook": 0, "verse": 3000, "readingA": 9000, "readingB": 16000,
             "payoff": 23000, "question": 27000}, 30000)
    out = OUTPUT_DIR / "temp" / f"{ep['slug']}_preview.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    # keep network fonts for the hand-preview; just inject the episode object
    html = TEMPLATE.read_text().replace(
        "<!--EPISODE-INJECT-->",
        "<script>window.EPISODE = " + json.dumps(episode_js, ensure_ascii=False) + ";</script>", 1)
    out.write_text(html)
    print(f"Preview written: {out}")
    if sys.platform == "darwin":
        subprocess.run(["open", str(out)])


# ----------------------------- main -----------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description="Render a Shared Verse episode video.")
    ap.add_argument("episode", help="Path to the episode JSON")
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--workers", type=int, default=min(14, (os.cpu_count() or 4)))
    ap.add_argument("--preview", action="store_true",
                    help="Open the in-feed demo for this episode; do not render the mp4.")
    ap.add_argument("--keep-temp", action="store_true")
    args = ap.parse_args()

    ep_path = Path(args.episode)
    ep = load_episode(ep_path)

    if args.preview:
        preview(ep)
        return 0

    chrome = preflight()
    slug = ep["slug"]
    tmp = OUTPUT_DIR / "temp" / slug
    frames_dir = tmp / "frames"
    if tmp.exists():
        shutil.rmtree(tmp)
    tmp.mkdir(parents=True, exist_ok=True)

    print(f"[1/5] Voiceover (ElevenLabs, 6 beats) for {slug}…")
    segs, trans_words, reading_words = synth_segments(ep, tmp)
    beats, starts, end_ms = compute_beats(segs)
    print(f"      beats(ms)={beats}  duration={end_ms/1000:.1f}s")

    print("[2/5] Assembling narration track…")
    narration = assemble_narration(segs, starts, end_ms, tmp / "narration.wav")

    print("[3/5] Building self-contained render HTML…")
    episode_js = build_episode_js(ep, beats, end_ms, trans_words, reading_words)
    render_html = build_render_html(episode_js, tmp / "render.html")

    print(f"[4/5] Capturing frames @ {args.fps}fps with {args.workers} workers…")
    capture_frames(chrome, render_html, end_ms, args.fps, frames_dir, args.workers)

    out_mp4 = OUTPUT_DIR / f"{slug}.mp4"
    print(f"[5/5] Composing → {out_mp4}")
    compose(frames_dir, narration, args.fps, out_mp4)

    if not args.keep_temp:
        shutil.rmtree(tmp, ignore_errors=True)

    dur = ffprobe_duration(out_mp4)
    print(f"\n✅ Done: {out_mp4}  ({dur:.1f}s, 1080x1920)")
    print("   Reminder: voiceover carries the English + commentary only; the Arabic is "
          "shown silently (never AI-recited).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
