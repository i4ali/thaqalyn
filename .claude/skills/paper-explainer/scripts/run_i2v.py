#!/usr/bin/env python3
"""Headless Wan 2.2 I2V (Lightning 4-step) via a local ComfyUI server.

usage: python run_i2v.py --image input.png --prompt "..." --out clip.mp4
       [--width 480 --height 832 --length 49 --fps 16 --seed 42 --shift 5.0 --steps 4]
Starts ComfyUI ($COMFYUI_DIR, default ~/Documents/development/ComfyUI) on 127.0.0.1:8188 if not up.
"""
import argparse, json, os, shutil, subprocess, sys, time, urllib.request, uuid

HERE = os.path.dirname(os.path.abspath(__file__))
COMFY = os.environ.get("COMFYUI_DIR", os.path.expanduser("~/Documents/development/ComfyUI"))
URL = "http://127.0.0.1:8188"

def up():
    try:
        urllib.request.urlopen(URL + "/system_stats", timeout=2); return True
    except Exception:
        return False

def ensure_server(log):
    if up(): return None
    py = os.path.join(COMFY, ".venv", "bin", "python")
    p = subprocess.Popen([py, "main.py", "--listen", "127.0.0.1", "--port", "8188", "--disable-auto-launch", "--use-pytorch-cross-attention", "--fp16-unet", "--fp16-vae"],
                         cwd=COMFY, stdout=open(log, "a"), stderr=subprocess.STDOUT, start_new_session=True)
    for _ in range(120):
        if up(): return p
        time.sleep(2)
    sys.exit("ComfyUI did not start; see " + log)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True); ap.add_argument("--prompt", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--width", type=int, default=480); ap.add_argument("--height", type=int, default=832)
    ap.add_argument("--length", type=int, default=49); ap.add_argument("--fps", type=float, default=16.0)
    ap.add_argument("--seed", type=int, default=42); ap.add_argument("--shift", type=float, default=5.0)
    ap.add_argument("--steps", type=int, default=4)
    ap.add_argument("--keep-server", action="store_true")
    a = ap.parse_args()

    # stage input image into ComfyUI/input
    name = f"i2v_{uuid.uuid4().hex[:8]}{os.path.splitext(a.image)[1]}"
    shutil.copy(a.image, os.path.join(COMFY, "input", name))

    wf = json.load(open(os.path.join(HERE, "workflow_i2v_lightning.json")))
    wf["9"]["inputs"]["text"] = a.prompt
    wf["11"]["inputs"]["image"] = name
    wf["12"]["inputs"].update(width=a.width, height=a.height, length=a.length)
    wf["7"]["inputs"]["shift"] = a.shift; wf["8"]["inputs"]["shift"] = a.shift
    half = a.steps // 2
    wf["13"]["inputs"].update(noise_seed=a.seed, steps=a.steps, end_at_step=half)
    wf["14"]["inputs"].update(noise_seed=a.seed, steps=a.steps, start_at_step=half, end_at_step=a.steps)
    prefix = "wan_i2v/" + os.path.splitext(os.path.basename(a.out))[0]
    wf["16"]["inputs"].update(filename_prefix=prefix, fps=a.fps)

    log = os.path.join(COMFY, "wan_i2v_server.log")
    proc = ensure_server(log)
    t0 = time.time()
    req = urllib.request.Request(URL + "/prompt", data=json.dumps({"prompt": wf, "client_id": "run_i2v"}).encode(),
                                 headers={"Content-Type": "application/json"})
    try:
        pid = json.load(urllib.request.urlopen(req))["prompt_id"]
    except urllib.error.HTTPError as e:
        sys.exit("submit failed: " + e.read().decode())
    print("queued", pid, flush=True)
    while True:
        h = json.load(urllib.request.urlopen(URL + f"/history/{pid}"))
        if pid in h:
            st = h[pid].get("status", {})
            if st.get("status_str") == "error":
                print(json.dumps(st, indent=1)[:3000]); sys.exit("generation failed; see " + log)
            outs = h[pid]["outputs"]
            break
        time.sleep(5)
    dt = time.time() - t0
    files = [o for v in outs.values() for o in v.get("images", []) + v.get("video", [])]
    src = os.path.join(COMFY, "output", files[0].get("subfolder", ""), files[0]["filename"])
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", src, "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "16", a.out], check=True)
    print(f"done in {dt/60:.1f} min -> {a.out}  (server output: {src})")
    if proc and not a.keep_server:
        proc.terminate()

if __name__ == "__main__":
    main()
