#!/usr/bin/env python3
"""
Doodle talking-mouth flap.

Given a closed-mouth BASE frame and an open-mouth variant at the SAME framing
(both normalized), this finds the mouth by diffing the two frames and builds a
seamless open-mouth frame (only the mouth region is swapped — everything else is
identical by construction, so there is no whole-character wobble). It then flaps
base<->open in sync with the speech RMS envelope, applies the same centered
push-in zoom, and muxes the audio.

Usage:
  python3 scripts/doodle_talk.py --base norm-base.png --open norm-open.png \
      --audio line.mp3 --out talk.mp4 \
      [--fps 30 --zmax 1.10 --zinc 0.0003 --rms-thresh 0.08 --pad 16]
"""
import argparse
import pathlib
import subprocess
import tempfile

import numpy as np
from PIL import Image


def audio_env(path, fps, n_frames):
    raw = subprocess.run(
        ["ffmpeg", "-nostdin", "-v", "error", "-i", path,
         "-ac", "1", "-ar", "44100", "-f", "s16le", "-"],
        capture_output=True, check=True).stdout
    x = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0
    sr, hop = 44100, 44100 / fps
    win = int(hop)
    env = np.zeros(n_frames)
    for i in range(n_frames):
        s = int(i * hop)
        seg = x[s:s + win]
        env[i] = np.sqrt(np.mean(seg ** 2)) if len(seg) else 0.0
    if env.max() > 0:
        env /= env.max()
    return env


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True)
    ap.add_argument("--open", dest="open_", required=True)
    ap.add_argument("--audio", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--zmax", type=float, default=1.10)
    ap.add_argument("--zinc", type=float, default=0.0003)
    ap.add_argument("--rms-thresh", type=float, default=0.08)
    ap.add_argument("--pad", type=int, default=16, help="padding around detected mouth box")
    ap.add_argument("--mouth", default="", help="override box x0,y0,x1,y1")
    ap.add_argument("--no-audio", dest="no_audio", action="store_true",
                    help="render silent video (audio still used for the flap envelope)")
    ap.add_argument("--ytop-frac", dest="ytop_frac", type=float, default=0.56,
                    help="ignore diffs above this fraction of height (protects eyes/brows/nose)")
    ap.add_argument("--dur", type=float, default=0.0)
    a = ap.parse_args()

    base = Image.open(a.base).convert("RGB")
    W, H = base.size
    opn = Image.open(a.open_).convert("RGB")
    if opn.size != (W, H):
        opn = opn.resize((W, H), Image.LANCZOS)

    b = np.asarray(base).astype(np.float32)
    o = np.asarray(opn).astype(np.float32)
    d = np.abs(b - o).sum(axis=2)
    # The mouth (closed line -> open oval) is the DENSEST change; line "boil"
    # elsewhere is thin/spread. Blur the diff and lock onto the peak blob.
    import cv2
    ytop = int(a.ytop_frac * H)
    d[:ytop, :] = 0.0                       # ignore eyes/brows/nose entirely
    dd = cv2.GaussianBlur(d, (0, 0), 12)
    if a.mouth:
        x0, y0, x1, y1 = map(int, a.mouth.split(","))
    else:
        ys, xs = np.where(dd > 0.40 * dd.max())
        if len(xs) < 20:
            raise SystemExit(f"ERROR: no mouth-change region found below y={ytop}")
        x0, x1 = xs.min() - a.pad, xs.max() + a.pad
        y0, y1 = ys.min() - a.pad, ys.max() + a.pad
    x0, y0 = max(0, x0), max(ytop, y0)
    x1, y1 = min(W, x1), min(H, y1)
    print(f"mouth box x[{x0}:{x1}] y[{y0}:{y1}] ({x1-x0}x{y1-y0})  ytop={ytop}")

    # feathered alpha around the mouth box; hard-clip above the cutoff so the
    # eyes are ALWAYS taken from the base frame (no eye flicker).
    alpha = np.zeros((H, W), np.float32)
    alpha[y0:y1, x0:x1] = 1.0
    alpha = cv2.GaussianBlur(alpha, (0, 0), 8)
    alpha[:ytop, :] = 0.0
    alpha = alpha[..., None]
    open_frame = (b * (1 - alpha) + o * alpha).clip(0, 255).astype(np.uint8)
    open_img = Image.fromarray(open_frame)

    dur = a.dur
    if dur <= 0:
        dur = float(subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "csv=p=0", a.audio], capture_output=True, check=True
        ).stdout.decode().strip())
    N = int(round(dur * a.fps))

    env = audio_env(a.audio, a.fps, N)
    state = env > a.rms_thresh
    for i in range(1, N - 1):                       # debounce single-frame flickers
        if state[i] != state[i - 1] and state[i] != state[i + 1]:
            state[i] = state[i - 1]

    out = pathlib.Path(a.out)
    open_img.save(out.with_name("dbg-open-frame.png"))

    tmp = tempfile.mkdtemp()
    for i in range(N):
        src = open_img if state[i] else base
        z = min(1.0 + a.zinc * i, a.zmax)
        cw, ch = W / z, H / z
        left, top = (W - cw) / 2, (H - ch) / 2
        src.crop((left, top, left + cw, top + ch)).resize((W, H), Image.LANCZOS).save(f"{tmp}/f{i:05d}.png")

    cmd = ["ffmpeg", "-nostdin", "-y", "-v", "error", "-framerate", str(a.fps),
           "-i", f"{tmp}/f%05d.png"]
    if not a.no_audio:
        cmd += ["-i", a.audio, "-c:a", "aac", "-shortest"]
    cmd += ["-c:v", "libx264", "-pix_fmt", "yuv420p", a.out]
    subprocess.run(cmd, check=True)
    print(f"wrote {a.out}  frames={N}  open%={round(100*state.mean())}")


if __name__ == "__main__":
    main()
