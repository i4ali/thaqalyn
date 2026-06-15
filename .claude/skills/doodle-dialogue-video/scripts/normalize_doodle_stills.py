#!/usr/bin/env python3
"""
Normalize line-doodle character stills to identical framing.

The Nano-Banana stills come back at inconsistent zoom/scale. This detects each
character's ink (black linework) bounding box, rescales every still so the
shoulder span is constant, and re-canvases onto an identical WxH frame with the
head anchored low — leaving the top clear for captions. Background is sampled
per-image (flat off-white) so the paste is seamless.

Usage:
  python3 scripts/normalize_doodle_stills.py IN1.png IN2.png ... --outdir DIR
"""
import argparse
import pathlib

import numpy as np
from PIL import Image


def bg_color(arr):
    # median of the four corner patches
    h, w, _ = arr.shape
    k = 12
    corners = np.concatenate([
        arr[:k, :k].reshape(-1, 3), arr[:k, -k:].reshape(-1, 3),
        arr[-k:, :k].reshape(-1, 3), arr[-k:, -k:].reshape(-1, 3),
    ])
    return np.median(corners, axis=0)


def ink_bbox(arr, thresh, min_count):
    gray = arr.mean(axis=2)
    mask = gray < thresh                      # near-black linework only
    col_has = mask.sum(axis=0) >= min_count
    row_has = mask.sum(axis=1) >= min_count
    if not col_has.any() or not row_has.any():
        raise ValueError("no ink detected")
    xs = np.where(col_has)[0]
    ys = np.where(row_has)[0]
    return int(xs[0]), int(ys[0]), int(xs[-1]), int(ys[-1])


def normalize(path, out, W, H, span_frac, head_frac, thresh, min_count):
    img = Image.open(path).convert("RGB")
    arr = np.asarray(img)
    bg = tuple(int(c) for c in bg_color(arr))
    x0, y0, x1, y1 = ink_bbox(arr, thresh, min_count)
    span = max(1, x1 - x0)

    scale = (span_frac * W) / span
    new_w, new_h = max(1, round(arr.shape[1] * scale)), max(1, round(arr.shape[0] * scale))
    scaled = img.resize((new_w, new_h), Image.LANCZOS)

    # scaled bbox
    sx0, sy0 = x0 * scale, y0 * scale
    scx = (x0 + x1) / 2 * scale            # character center x, scaled
    canvas = Image.new("RGB", (W, H), bg)
    off_x = round(W / 2 - scx)             # center character horizontally
    off_y = round(head_frac * H - sy0)     # head top at head_frac of height
    canvas.paste(scaled, (off_x, off_y))
    canvas.save(out)
    return bg, (x1 - x0, y1 - y0), scale


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inputs", nargs="+")
    ap.add_argument("--outdir", required=True)
    ap.add_argument("--width", type=int, default=1080)
    ap.add_argument("--height", type=int, default=1920)
    ap.add_argument("--span-frac", type=float, default=0.72)
    ap.add_argument("--head-frac", type=float, default=0.34)
    ap.add_argument("--ink-thresh", type=int, default=128)
    ap.add_argument("--min-count", type=int, default=3)
    args = ap.parse_args()

    outdir = pathlib.Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    for p in args.inputs:
        p = pathlib.Path(p)
        out = outdir / ("norm-" + p.name)
        bg, bbox, scale = normalize(p, out, args.width, args.height,
                                    args.span_frac, args.head_frac,
                                    args.ink_thresh, args.min_count)
        print(f"{p.name:28s} bbox={bbox} scale={scale:.3f} bg={bg} -> {out}")


if __name__ == "__main__":
    main()
