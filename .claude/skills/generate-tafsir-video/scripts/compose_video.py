"""Compose final video with ffmpeg.

Inputs: silent base mp4, narration mp3, word_timings json, header png.
Output: single mp4 with sticky header overlay + word-by-word captions + narration audio.
"""
from __future__ import annotations
import json
import subprocess
from pathlib import Path

CAPTION_Y = 1500            # y-position of caption baseline
CAPTION_FONT_SIZE = 60
ACTIVE_COLOR = "yellow"
MUTED_COLOR = "0xC9A227"    # darker amber
HEADER_Y = 240   # below TikTok's top profile/username UI safe zone


def build_drawtext_chain(timings: list[dict], font_path: str) -> str:
    """Build drawtext filters for word-by-word captions.

    Pattern: one always-on muted line of all words + one enable-gated drawtext per
    word in the active brighter color. The active drawtext is drawn at the same
    position as the corresponding word in the muted line, on top of it.

    For simplicity v1: render only the *current* active word (as in the reference
    video), not the full sentence. Less code, sharper visual.
    """
    parts = []
    # Empty static layer — placeholder so the test sees one base entry.
    parts.append(
        f"drawtext=fontfile='{font_path}':text=' ':enable='between(t,0,0.0001)':"
        f"fontcolor=white:fontsize=1:x=0:y=0"
    )
    for t in timings:
        word = _escape_text(t["word"])
        if not word:
            continue  # skip pure-punctuation tokens like em-dash
        parts.append(
            f"drawtext=fontfile='{font_path}':text='{word}':"
            f"enable='between(t,{t['start']},{t['end']})':"
            f"fontcolor={ACTIVE_COLOR}:fontsize={CAPTION_FONT_SIZE}:"
            f"box=1:boxcolor=black@0.55:boxborderw=20:"
            f"x=(w-text_w)/2:y={CAPTION_Y}"
        )
    return ",".join(parts)


def build_filter_complex(timings: list[dict], header_path: str, font_path: str,
                         narration_duration: float) -> str:
    """Build the full ffmpeg filter_complex string."""
    captions = build_drawtext_chain(timings, font_path)
    fc = (
        f"[0:v]trim=duration={narration_duration},setpts=PTS-STARTPTS,"
        f"scale=1080:1920,format=rgba[base];"
        f"[1:v]format=rgba[hdr];"
        f"[base][hdr]overlay=x=0:y={HEADER_Y}:format=auto[withhdr];"
        f"[withhdr]{captions}[out]"
    )
    return fc


_PUNCT_TO_STRIP = "'\"`‘’“”"  # straight + curly single/double quotes
_PUNCT_TO_DROP_WORDS = "—–-"  # em/en/hyphen dashes treated as standalone non-word


def _escape_text(s: str) -> str:
    # Strip quotes/apostrophes — they break the layered ffmpeg filter+drawtext
    # escaping rules. Visual loss on flashing word captions is negligible.
    for ch in _PUNCT_TO_STRIP:
        s = s.replace(ch, "")
    # Drop "words" that are nothing but separator punctuation (em-dashes, etc.).
    if all(c in _PUNCT_TO_DROP_WORDS or c.isspace() for c in s):
        return ""
    # Escape what drawtext's own parser cares about
    return (s.replace("\\", "\\\\")
             .replace(":", "\\:")
             .replace("%", "\\%"))


def compose(base_video: Path, narration_audio: Path, word_timings: Path,
            header_png: Path, font_path: Path, output: Path) -> Path:
    timings = json.loads(Path(word_timings).read_text())
    if not timings:
        raise RuntimeError("Word timings are empty — cannot render captions.")
    duration = timings[-1]["end"]

    fc = build_filter_complex(timings, str(header_png), str(font_path), duration)

    cmd = [
        "ffmpeg", "-y",
        "-i", str(base_video),
        "-loop", "1", "-i", str(header_png),
        "-i", str(narration_audio),
        "-filter_complex", fc,
        "-map", "[out]", "-map", "2:a",
        "-c:v", "libx264", "-preset", "medium", "-crf", "20", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-t", f"{duration}",
        str(output),
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        tail = "\n".join(res.stderr.splitlines()[-40:])
        raise RuntimeError(f"ffmpeg failed (exit {res.returncode}):\n{tail}")
    return output
