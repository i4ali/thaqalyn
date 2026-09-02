#!/usr/bin/env python3
"""2.5D depth-parallax clip from a single still (free, seconds).

usage: parallax.py --image still.png --out clip.mp4 --seconds 5 [--fps 24]
       [--move push|pull|left|right|up|down|drift] [--zoom 0.08] [--parallax 0.035]
       [--width 1080 --height 1920] [--depth-model depth-anything/Depth-Anything-V2-Large-hf]

Depth Anything V2 -> per-pixel displacement (near pixels move more than far ones) driven by a
slow camera path with ease-in/out, plus a gentle zoom. Rendered with cv2.remap; small
disocclusion gaps are filled by rendering from a slightly over-scaled source.
"""
import argparse, os, subprocess, tempfile
import numpy as np, cv2
from PIL import Image

def ease(t):  # smoothstep
    return t * t * (3 - 2 * t)

def depth_map(img, model):
    import torch
    from transformers import pipeline
    dev = "mps" if torch.backends.mps.is_available() else "cpu"
    pipe = pipeline("depth-estimation", model=model, device=dev)
    d = np.array(pipe(img)["predicted_depth"], dtype=np.float32)
    d = cv2.resize(d, img.size, interpolation=cv2.INTER_CUBIC)
    d = (d - d.min()) / (d.max() - d.min() + 1e-6)   # 1 = near, 0 = far (DA-V2 convention)
    return cv2.GaussianBlur(d, (0, 0), 6)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--seconds", type=float, default=5); ap.add_argument("--fps", type=int, default=24)
    ap.add_argument("--move", default="push", choices=["push", "pull", "left", "right", "up", "down", "drift"])
    ap.add_argument("--zoom", type=float, default=0.08, help="total zoom over the clip (fraction)")
    ap.add_argument("--parallax", type=float, default=0.035, help="max lateral shift of nearest pixels (fraction of width)")
    ap.add_argument("--width", type=int, default=1080); ap.add_argument("--height", type=int, default=1920)
    ap.add_argument("--depth-model", default="depth-anything/Depth-Anything-V2-Large-hf")
    ap.add_argument("--save-depth", action="store_true")
    a = ap.parse_args()

    W, H = a.width, a.height
    pil = Image.open(a.image).convert("RGB")
    # fit to target aspect (center crop), render at 1.15x for edge coverage
    ar = W / H
    w0, h0 = pil.size
    if w0 / h0 > ar: nw = int(h0 * ar); pil = pil.crop(((w0 - nw) // 2, 0, (w0 - nw) // 2 + nw, h0))
    else: nh = int(w0 / ar); pil = pil.crop((0, (h0 - nh) // 2, w0, (h0 - nh) // 2 + nh))
    S = 1.15
    RW, RH = int(W * S), int(H * S)
    src = np.array(pil.resize((RW, RH), Image.LANCZOS)).astype(np.float32)
    dep = depth_map(pil.resize((RW, RH), Image.LANCZOS), a.depth_model)
    if a.save_depth:
        cv2.imwrite(os.path.splitext(a.out)[0] + "_depth.png", (dep * 255).astype(np.uint8))

    n = int(a.seconds * a.fps)
    gx, gy = np.meshgrid(np.arange(RW, dtype=np.float32), np.arange(RH, dtype=np.float32))
    cx, cy = RW / 2, RH / 2
    tmp = tempfile.mkdtemp()
    for i in range(n):
        t = ease(i / max(n - 1, 1))
        # camera path -> lateral offset (px) and zoom factor
        px = a.parallax * RW
        if a.move == "push":   ox, oy, z = 0, 0, 1 + a.zoom * t
        elif a.move == "pull": ox, oy, z = 0, 0, 1 + a.zoom * (1 - t)
        elif a.move == "left": ox, oy, z = -px * (t - 0.5) * 2, 0, 1 + a.zoom * 0.5
        elif a.move == "right": ox, oy, z = px * (t - 0.5) * 2, 0, 1 + a.zoom * 0.5
        elif a.move == "up":   ox, oy, z = 0, -px * (t - 0.5) * 2, 1 + a.zoom * 0.5
        elif a.move == "down": ox, oy, z = 0, px * (t - 0.5) * 2, 1 + a.zoom * 0.5
        else:  # drift: slow arc
            ox, oy, z = px * np.sin(t * np.pi) * 0.8, -px * 0.4 * t, 1 + a.zoom * t
        # per-pixel displacement: near pixels shift with the camera, far pixels stay.
        # zoom is also depth-weighted (dolly feel): near layers scale more than far ones.
        zd = 1 + (z - 1) * (0.55 + 0.9 * dep)
        # keep the maps float32: a NumPy float64 scalar (e.g. np.sin in 'drift') would promote them
        # to float64 and cv2.remap only accepts CV_32FC1 maps.
        mapx = (cx + (gx - cx) / zd - ox * dep).astype(np.float32)
        mapy = (cy + (gy - cy) / zd - oy * dep).astype(np.float32)
        frame = cv2.remap(src, mapx, mapy, cv2.INTER_CUBIC, borderMode=cv2.BORDER_REFLECT)
        # crop the 1.15x render to the output size (center)
        x0, y0 = (RW - W) // 2, (RH - H) // 2
        out = np.clip(frame[y0:y0 + H, x0:x0 + W], 0, 255).astype(np.uint8)
        cv2.imwrite(os.path.join(tmp, f"f_{i:05d}.png"), cv2.cvtColor(out, cv2.COLOR_RGB2BGR))
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-framerate", str(a.fps), "-i", os.path.join(tmp, "f_%05d.png"),
                    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "16", a.out], check=True)
    for f in os.listdir(tmp): os.remove(os.path.join(tmp, f))
    os.rmdir(tmp)
    print("wrote", a.out, f"({n} frames @ {a.fps} fps, move={a.move})")

if __name__ == "__main__":
    main()
