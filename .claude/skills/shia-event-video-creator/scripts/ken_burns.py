#!/usr/bin/env python3
"""
Ken Burns fallback: generate a slow-zoom MP4 from a still PNG using FFmpeg.

Use this as a rescue path when Kling's image-to-video animates or fades a halo
on a sacred figure. Because there's no AI animation involved — just FFmpeg's
zoompan filter on the still image — the halo cannot drift.

Usage:
    python ken_burns.py --image scene_1.png --output scene_1.mp4
    python ken_burns.py --image scene_1.png --duration 10.0 --zoom-to 1.25 --output scene_1.mp4
    python ken_burns.py --image scene_1.png --zoom-from 1.15 --zoom-to 1.0 --output scene_1.mp4  # zoom-OUT

Tips:
    - Default is a subtle 5s zoom-IN (1.0 → 1.18), which matches typical Kling 5s clip pacing.
    - For 10s clips, use --duration 10 and reduce --zoom-to (e.g. 1.12) to keep the motion gentle.
    - For zoom-OUT (establishing shots), swap zoom-from and zoom-to.
    - Motion always centers on the frame. For off-center Ken Burns (pan), use FFmpeg directly.
"""

import argparse
import subprocess
import sys
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser(description="Ken Burns slow-zoom from still image.")
    ap.add_argument("--image", required=True, help="Input PNG/JPG.")
    ap.add_argument("--output", required=True, help="Output MP4 path.")
    ap.add_argument("--duration", type=float, default=5.0, help="Output duration in seconds (default: 5.0).")
    ap.add_argument("--fps", type=int, default=30, help="Output framerate (default: 30).")
    ap.add_argument("--width", type=int, default=1080, help="Output width (default: 1080).")
    ap.add_argument("--height", type=int, default=1920, help="Output height (default: 1920 — 9:16 TikTok).")
    ap.add_argument("--zoom-from", type=float, default=1.0, help="Starting zoom factor (default: 1.0 = no zoom).")
    ap.add_argument("--zoom-to", type=float, default=1.18, help="Ending zoom factor (default: 1.18 = subtle).")
    ap.add_argument("--crf", type=int, default=18, help="H.264 CRF (lower=better, default: 18).")
    args = ap.parse_args()

    image = Path(args.image)
    output = Path(args.output)
    if not image.exists():
        print(f"ERROR: {image} not found.", file=sys.stderr)
        return 1

    output.parent.mkdir(parents=True, exist_ok=True)

    total_frames = max(1, int(args.duration * args.fps))
    # zoompan's z expression; per-frame increment
    zoom_delta = (args.zoom_to - args.zoom_from) / total_frames

    if args.zoom_to >= args.zoom_from:
        # Zoom in: start at zoom_from, end at zoom_to
        z_expr = f"min(zoom+{zoom_delta:.6f},{args.zoom_to})"
    else:
        # Zoom out: start at zoom_from, end at zoom_to (which is smaller)
        z_expr = f"max(zoom-{abs(zoom_delta):.6f},{args.zoom_to})"

    # Upscale source 2x before zoompan for smoothness, then crop to target
    filter_complex = (
        f"scale={args.width * 2}:-1,"
        f"zoompan=z='{z_expr}':"
        f"x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':"
        f"d={total_frames}:s={args.width}x{args.height}:fps={args.fps}"
    )

    cmd = [
        "ffmpeg", "-y",
        "-loop", "1", "-framerate", str(args.fps),
        "-i", str(image),
        "-vf", filter_complex,
        "-t", f"{args.duration:.6f}",
        "-c:v", "libx264",
        "-crf", str(args.crf),
        "-preset", "medium",
        "-pix_fmt", "yuv420p",
        "-an",
        str(output),
    ]

    print(f"Ken Burns: {image.name} → {output.name} | {args.duration}s | zoom {args.zoom_from}→{args.zoom_to}", file=sys.stderr)
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("FFMPEG STDERR (tail):", file=sys.stderr)
        print("\n".join(r.stderr.splitlines()[-20:]), file=sys.stderr)
        return r.returncode

    print(str(output))
    return 0


if __name__ == "__main__":
    sys.exit(main())
