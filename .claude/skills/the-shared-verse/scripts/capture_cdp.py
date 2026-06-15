"""Frame capture via the Chrome DevTools Protocol.

Per-frame `chrome --screenshot` launches a cold browser every frame; under
parallel load that balloons to ~15s/frame. Instead we launch a few WARM Chrome
instances, load the render page ONCE each (?capture=1), then for each frame call
window.seek(t) and Page.captureScreenshot over the debug socket — ~100ms/frame.

The animation is a pure function of t (seek writes inline styles, no CSS
transitions), so every screenshot is deterministic and reproducible.

No fallbacks — any failure raises a clear error.
"""
from __future__ import annotations
import base64
import json
import math
import socket
import subprocess
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.request import urlopen

import websocket  # websocket-client (sync)


def _free_port() -> int:
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    port = s.getsockname()[1]
    s.close()
    return port


def _page_ws_url(port: int, timeout: float = 20.0) -> str:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            targets = json.load(urlopen(f"http://127.0.0.1:{port}/json", timeout=1))
            for t in targets:
                if t.get("type") == "page" and t.get("webSocketDebuggerUrl"):
                    return t["webSocketDebuggerUrl"]
        except Exception:
            pass
        time.sleep(0.15)
    raise RuntimeError(f"Chrome DevTools endpoint (port {port}) never came up.")


class _CDP:
    def __init__(self, ws_url: str):
        self.ws = websocket.create_connection(ws_url, timeout=60, enable_multithread=True)
        self._id = 0

    def call(self, method: str, params: dict | None = None) -> dict:
        self._id += 1
        mid = self._id
        self.ws.send(json.dumps({"id": mid, "method": method, "params": params or {}}))
        while True:
            msg = json.loads(self.ws.recv())
            if msg.get("id") == mid:
                if "error" in msg:
                    raise RuntimeError(f"{method} -> {msg['error']}")
                return msg.get("result", {})
            # otherwise it's an event — ignore

    def close(self):
        try:
            self.ws.close()
        except Exception:
            pass


def _eval(cdp: _CDP, expr: str) -> dict:
    return cdp.call("Runtime.evaluate", {"expression": expr, "returnByValue": True})


def _run_instance(chrome: str, url: str, frames_dir: Path, profile: Path,
                  indices: list[int], end_ms: int, fps: int, counter: dict) -> None:
    port = _free_port()
    proc = subprocess.Popen(
        [chrome, "--headless=new", "--disable-gpu", "--no-sandbox", "--hide-scrollbars",
         "--mute-audio", "--no-first-run", "--no-default-browser-check",
         "--disable-extensions", "--disable-background-networking",
         "--force-device-scale-factor=1", "--window-size=1080,1920",
         "--remote-allow-origins=*",
         f"--user-data-dir={profile}", f"--remote-debugging-port={port}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    cdp = None
    try:
        cdp = _CDP(_page_ws_url(port))
        cdp.call("Emulation.setDeviceMetricsOverride",
                 {"width": 1080, "height": 1920, "deviceScaleFactor": 1, "mobile": False})
        cdp.call("Page.navigate", {"url": url})

        deadline = time.time() + 25
        while time.time() < deadline:
            try:
                r = _eval(cdp, "(!!window.__SV_READY && typeof seek==='function')")
                if r.get("result", {}).get("value") is True:
                    break
            except Exception:
                pass
            time.sleep(0.1)
        else:
            raise RuntimeError("render page never signalled __SV_READY (fonts/seek not ready).")

        for i in indices:
            t = min(int(round(i * 1000.0 / fps)), end_ms)
            _eval(cdp, f"seek({t})")
            shot = cdp.call("Page.captureScreenshot", {"format": "png", "captureBeyondViewport": False})
            data = base64.b64decode(shot["data"])
            out = frames_dir / f"f_{i:05d}.png"
            out.write_bytes(data)
            if not out.exists() or out.stat().st_size == 0:
                raise RuntimeError(f"frame {i} (t={t}ms) wrote empty file.")
            counter["done"] += 1
            d = counter["done"]
            if d % 120 == 0 or d == counter["total"]:
                print(f"  captured {d}/{counter['total']} frames")
    finally:
        if cdp:
            cdp.close()
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except Exception:
            proc.kill()


def capture_frames_cdp(chrome: str, render_html: Path, end_ms: int, fps: int,
                       frames_dir: Path, tmp_dir: Path, instances: int = 4) -> int:
    """Capture all frames using `instances` warm Chrome processes over CDP."""
    frames_dir.mkdir(parents=True, exist_ok=True)
    n = int(math.ceil(end_ms / 1000.0 * fps)) + 1
    instances = max(1, min(instances, n))
    url = render_html.resolve().as_uri() + "?capture=1"

    # contiguous slices keep each warm browser doing a clean sweep
    slices: list[list[int]] = [[] for _ in range(instances)]
    for i in range(n):
        slices[i * instances // n].append(i)

    counter = {"done": 0, "total": n}
    profiles = []
    for w in range(instances):
        prof = tmp_dir / "cdp_profiles" / f"w{w}"
        prof.mkdir(parents=True, exist_ok=True)
        profiles.append(prof)

    with ThreadPoolExecutor(max_workers=instances) as ex:
        futs = [ex.submit(_run_instance, chrome, url, frames_dir, profiles[w],
                          slices[w], end_ms, fps, counter)
                for w in range(instances) if slices[w]]
        for f in futs:
            f.result()  # re-raise any worker error

    missing = [i for i in range(n) if not (frames_dir / f"f_{i:05d}.png").exists()]
    if missing:
        raise RuntimeError(f"{len(missing)} frames missing (first: {missing[:5]}).")
    return n
