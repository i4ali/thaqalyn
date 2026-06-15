#!/usr/bin/env python3
"""Detect the phone's green-screen quad in a frame; print corners + save a debug overlay."""
import argparse
import cv2
import numpy as np

ap = argparse.ArgumentParser()
ap.add_argument("--frame", required=True)
ap.add_argument("--debug", required=True)
a = ap.parse_args()

img = cv2.imread(a.frame)
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
# chroma green range
mask = cv2.inRange(hsv, (40, 80, 80), (85, 255, 255))
mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE,
                        np.ones((9, 9), np.uint8))
cnts, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL,
                           cv2.CHAIN_APPROX_SIMPLE)
c = max(cnts, key=cv2.contourArea)
rect = cv2.minAreaRect(c)
box = cv2.boxPoints(rect)  # 4 pts

# order: TL, TR, BR, BL
s = box.sum(axis=1)
d = np.diff(box, axis=1).ravel()
tl = box[np.argmin(s)]
br = box[np.argmax(s)]
tr = box[np.argmin(d)]
bl = box[np.argmax(d)]
quad = np.array([tl, tr, br, bl])

dbg = img.copy()
for i, p in enumerate(quad):
    cv2.circle(dbg, tuple(p.astype(int)), 10, (0, 0, 255), -1)
    cv2.putText(dbg, ["TL", "TR", "BR", "BL"][i],
                tuple(p.astype(int)), cv2.FONT_HERSHEY_SIMPLEX,
                1.2, (0, 0, 255), 3)
cv2.polylines(dbg, [quad.astype(int)], True, (0, 0, 255), 3)
cv2.imwrite(a.debug, dbg)

print(" ".join(f"{x:.1f},{y:.1f}" for x, y in quad))
print(f"area_px={cv2.contourArea(c):.0f} img={img.shape[1]}x{img.shape[0]}")
