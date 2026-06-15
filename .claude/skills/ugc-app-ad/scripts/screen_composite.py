#!/usr/bin/env python3
"""
Warp the app screenshot into a fixed phone-screen quad and overlay it on a
video segment (single static quad — valid only for a near-static window).

Usage:
  python3 scripts/screen_composite.py --video seg.mp4 --screenshot shot.png \
    --quad "x1,y1 x2,y2 x3,y3 x4,y4" --output out.mp4
"""
import argparse
import json
import os
import subprocess
import tempfile

import cv2
import numpy as np

ap = argparse.ArgumentParser()
ap.add_argument("--video", required=True)
ap.add_argument("--screenshot", required=True)
ap.add_argument("--quad", required=True, help="TL TR BR BL in video px")
ap.add_argument("--output", required=True)
a = ap.parse_args()

probe = json.loads(subprocess.check_output([
    "ffprobe", "-v", "error", "-select_streams", "v:0",
    "-show_entries", "stream=width,height", "-of", "json", a.video]))
vw = probe["streams"][0]["width"]
vh = probe["streams"][0]["height"]

dst = np.array([[float(v) for v in p.split(",")]
                for p in a.quad.split()], dtype=np.float32)
shot = cv2.imread(a.screenshot)
sh, sw = shot.shape[:2]
src = np.array([[0, 0], [sw, 0], [sw, sh], [0, sh]], dtype=np.float32)
M = cv2.getPerspectiveTransform(src, dst)
warped = cv2.warpPerspective(shot, M, (vw, vh))
mask = cv2.warpPerspective(np.full((sh, sw), 255, np.uint8),
                           M, (vw, vh))
mask = cv2.erode(mask, np.ones((3, 3), np.uint8))  # avoid green fringe

tmp = tempfile.mkdtemp()
overlay = os.path.join(tmp, "ov.png")
bgra = cv2.cvtColor(warped, cv2.COLOR_BGR2BGRA)
bgra[:, :, 3] = mask
cv2.imwrite(overlay, bgra)

subprocess.check_call([
    "ffmpeg", "-y", "-loglevel", "error", "-i", a.video, "-i", overlay,
    "-filter_complex", "[0:v][1:v]overlay=0:0:format=auto",
    "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", a.output])
print("Wrote", a.output)
