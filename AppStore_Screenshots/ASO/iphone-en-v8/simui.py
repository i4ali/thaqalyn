#!/usr/bin/env python3
"""Drive a Simulator window from device coordinates (for App Store shots).

  python3 simui.py "<window name substring>" cal                 # print mapping
  python3 simui.py "<win>" tap <dx> <dy>                         # tap at device px
  python3 simui.py "<win>" drag <dx> <y_from> <y_to> [count]      # touch drag (scrolls); repeat count times
  python3 simui.py "<win>" scroll <dx> <dy> <pixels> [steps]     # wheel-scroll down (+) / up (-) at device px
  python3 simui.py "<win>" shot <udid> <out.png>                 # simctl screenshot

Mapping: captures the window, finds the device screen as the bounding box of
green-tinted pixels (the app's emerald theme) and maps device px to screen pts.
"""
import subprocess, sys, time, pathlib
import Quartz
from PIL import Image
import numpy as np

S = pathlib.Path("/private/tmp/claude-501/-Users-muhammadimranali-Documents-development-thaqalyn/be005e9e-a89a-4d21-9f15-dc9ff319e3fa/scratchpad")
DEVICE = {"iPhone": (1320, 2868), "iPad": (2064, 2752)}

def window(sub):
    for w in Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionOnScreenOnly, Quartz.kCGNullWindowID):
        if w.get("kCGWindowOwnerName") == "Simulator" and sub in (w.get("kCGWindowName") or ""):
            b = dict(w["kCGWindowBounds"]); return int(w["kCGWindowNumber"]), b
    raise SystemExit(f"no Simulator window matching {sub!r}")

def mapping(sub):
    wid, b = window(sub)
    subprocess.run(["osascript", "-e", 'tell application "Simulator" to activate'], check=True, capture_output=True)
    time.sleep(0.4)
    cap = S / "simui_cap.png"
    subprocess.run(["screencapture", "-x", "-o", "-l", str(wid), str(cap)], check=True)
    im = Image.open(cap).convert("RGB"); a = np.array(im).astype(int)
    pad = (im.size[0] - b["Width"]) / 2
    r, g, bl = a[..., 0], a[..., 1], a[..., 2]
    # Screen pixels are tinted (never pure grey); the bezel is black and the window chrome is grey.
    mask = (a.max(axis=2) > 4) & ((np.abs(r - g) > 2) | (np.abs(g - bl) > 2))
    mask[: int(pad) + 60] = False             # skip the title bar (its traffic lights)
    ys, xs = np.nonzero(mask)
    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    dev = DEVICE["iPad" if "iPad" in sub else "iPhone"]
    sx = (x1 - x0) / dev[0]                   # the aspect is fixed, so one scale for both axes
    ratio = (x1 - x0) / (y1 - y0)
    if abs(ratio / (dev[0] / dev[1]) - 1) > 0.015:
        print(f"warning: screen box ratio {ratio:.4f} vs device {dev[0]/dev[1]:.4f}; y may be off", file=sys.stderr)
    ox, oy = b["X"] - pad + x0, b["Y"] - pad + y0
    return dict(ox=ox, oy=oy, sx=sx, sy=sx, ratio=ratio, dev=dev)

def to_screen(m, dx, dy): return int(round(m["ox"] + dx * m["sx"])), int(round(m["oy"] + dy * m["sy"]))

def tap(m, dx, dy):
    x, y = to_screen(m, dx, dy)
    subprocess.run(["cliclick", f"m:{x},{y}", "w:120", f"dd:{x},{y}", "w:90", f"du:{x},{y}"], check=True)

def drag(m, dx, y_from, y_to, moves=12):
    """Touch drag at device x from y_from to y_to (scrolls content the touch way)."""
    x0, y0 = to_screen(m, dx, y_from); x1, y1 = to_screen(m, dx, y_to)
    cmds = [f"m:{x0},{y0}", "w:100", f"dd:{x0},{y0}", "w:60"]
    for i in range(1, moves + 1):
        cmds += [f"dm:{x0},{int(y0 + (y1 - y0) * i / moves)}", "w:12"]
    cmds += [f"du:{x1},{y1}"]
    subprocess.run(["cliclick"] + cmds, check=True)

def scroll(m, dx, dy, pixels, steps=None):
    x, y = to_screen(m, dx, dy)
    subprocess.run(["cliclick", f"m:{x},{y}"], check=True); time.sleep(0.2)
    steps = steps or max(1, abs(pixels) // 40)
    per = pixels / steps
    for _ in range(steps):
        ev = Quartz.CGEventCreateScrollWheelEvent(None, Quartz.kCGScrollEventUnitPixel, 1, int(-per))
        Quartz.CGEventPost(Quartz.kCGHIDEventTap, ev); time.sleep(0.016)

if __name__ == "__main__":
    sub, cmd = sys.argv[1], sys.argv[2]
    m = mapping(sub)
    if cmd == "cal": print(m)
    elif cmd == "tap": tap(m, int(sys.argv[3]), int(sys.argv[4]))
    elif cmd == "drag":   # drag <dx> <y_from> <y_to> [count]
        for _ in range(int(sys.argv[6]) if len(sys.argv) > 6 else 1):
            drag(m, int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5])); time.sleep(0.9)
    elif cmd == "scroll": scroll(m, int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]), int(sys.argv[6]) if len(sys.argv) > 6 else None)
    elif cmd == "shot": subprocess.run(["xcrun", "simctl", "io", sys.argv[3], "screenshot", sys.argv[4]], check=True, capture_output=True)
