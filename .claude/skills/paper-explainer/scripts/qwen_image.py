#!/usr/bin/env python3
"""Local still generation with Qwen-Image (ComfyUI, free) - drop-in for nano_banana.py.

usage: qwen_image.py --prompt "..." --output out.png [--aspect 9:16] [--seed 42]
       qwen_image.py --prompt "..." --ref a.png [--ref b.png --ref c.png] --output out.png   (Qwen-Image-Edit-2511, up to 3 refs)
       [--steps N] [--no-lightning] [--restart-server]

Text-to-image: Qwen-Image-2512 + Lightning 8-step LoRA (cfg 1). With --ref: Qwen-Image-Edit-2511 + Lightning 4-step LoRA.
--no-lightning drops the LoRA (20 steps, cfg 4) for a slower, higher-fidelity pass.
Native sizes (Qwen presets): 9:16 928x1664, 16:9 1664x928, 1:1 1328x1328, 3:4 1104x1472, 4:3 1472x1104.
Server: starts ComfyUI ($COMFYUI_DIR) with $COMFY_FLAGS (default "--fp32-vae": bf16 UNet, fp32 VAE; fp16 UNet gives NaN/black on MPS) if not up;
--restart-server kills whatever listens on 8188 first (use once after a server was started without the fp16 flags).
"""
import argparse, json, os, shutil, subprocess, sys, time, urllib.request, urllib.error, uuid

HERE = os.path.dirname(os.path.abspath(__file__))
COMFY = os.environ.get("COMFYUI_DIR", os.path.expanduser("~/Documents/development/ComfyUI"))
URL = "http://127.0.0.1:8188"
SIZES = {"9:16": (928, 1664), "16:9": (1664, 928), "1:1": (1328, 1328), "3:4": (1104, 1472), "4:3": (1472, 1104)}

def up():
    try:
        urllib.request.urlopen(URL + "/system_stats", timeout=2); return True
    except Exception:
        return False

def kill_server():
    out = subprocess.run(["lsof", "-ti", "tcp:8188"], capture_output=True, text=True).stdout.split()
    for pid in out:
        subprocess.run(["kill", pid])
    for _ in range(30):
        if not up(): return
        time.sleep(1)

def ensure_server(log):
    if up(): return
    py = os.path.join(COMFY, ".venv", "bin", "python")
    flags = os.environ.get("COMFY_FLAGS", "--fp32-vae").split()   # bf16 UNet (fp16 UNet -> NaN/black on MPS), fp32 VAE
    subprocess.Popen([py, "main.py", "--listen", "127.0.0.1", "--port", "8188", "--disable-auto-launch",
                      "--use-pytorch-cross-attention"] + flags,
                     cwd=COMFY, stdout=open(log, "a"), stderr=subprocess.STDOUT, start_new_session=True)
    for _ in range(120):
        if up(): return
        time.sleep(2)
    sys.exit("ComfyUI did not start; see " + log)

def stage(path):
    name = f"qwen_{uuid.uuid4().hex[:8]}{os.path.splitext(path)[1]}"
    shutil.copy(path, os.path.join(COMFY, "input", name))
    return name

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True); ap.add_argument("--output", required=True)
    ap.add_argument("--ref", action="append", default=[], help="reference image(s), max 3 -> Qwen-Image-Edit-2511")
    ap.add_argument("--aspect", default="9:16", choices=list(SIZES))
    ap.add_argument("--size", default=None, help="ignored (nano_banana.py compatibility)")
    ap.add_argument("--seed", type=int, default=42); ap.add_argument("--steps", type=int)
    ap.add_argument("--no-lightning", action="store_true"); ap.add_argument("--restart-server", action="store_true")
    a = ap.parse_args()
    if len(a.ref) > 3: sys.exit("max 3 --ref images")
    w, h = SIZES[a.aspect]
    if a.restart_server: kill_server()
    log = os.path.join(COMFY, "qwen_server.log")
    ensure_server(log)

    wf = json.load(open(os.path.join(HERE, "workflow_qwen_edit.json" if a.ref else "workflow_qwen_t2i.json")))
    wf["6"]["inputs"]["prompt" if a.ref else "text"] = a.prompt
    wf["8"]["inputs"].update(width=w, height=h)
    steps = a.steps or (4 if a.ref else 8)
    if a.no_lightning:
        wf["5"]["inputs"]["model"] = ["1", 0]; del wf["4"]
        steps = a.steps or 20; wf["9"]["inputs"]["cfg"] = 4.0
    wf["9"]["inputs"].update(seed=a.seed, steps=steps)
    if a.ref:
        for i, r in enumerate(a.ref):
            ld, sc = str(20 + i), str(30 + i)
            wf[ld] = {"class_type": "LoadImage", "inputs": {"image": stage(r)}}
            wf[sc] = {"class_type": "ImageScaleToTotalPixels", "inputs": {"image": [ld, 0], "upscale_method": "lanczos", "megapixels": 1.0, "resolution_steps": 8}}
            for n in ("6", "7"): wf[n]["inputs"][f"image{i + 1}"] = [sc, 0]
    prefix = "qwen/" + os.path.splitext(os.path.basename(a.output))[0]
    wf["11"]["inputs"]["filename_prefix"] = prefix

    t0 = time.time()
    req = urllib.request.Request(URL + "/prompt", data=json.dumps({"prompt": wf, "client_id": "qwen_image"}).encode(),
                                 headers={"Content-Type": "application/json"})
    try:
        pid = json.load(urllib.request.urlopen(req))["prompt_id"]
    except urllib.error.HTTPError as e:
        sys.exit("submit failed: " + e.read().decode()[:2000])
    print("queued", pid, flush=True)
    while True:
        hist = json.load(urllib.request.urlopen(URL + f"/history/{pid}"))
        if pid in hist:
            st = hist[pid].get("status", {})
            if st.get("status_str") == "error":
                print(json.dumps(st, indent=1)[:3000]); sys.exit("generation failed; see " + log)
            outs = hist[pid]["outputs"]; break
        time.sleep(3)
    files = [o for v in outs.values() for o in v.get("images", [])]
    src = os.path.join(COMFY, "output", files[0].get("subfolder", ""), files[0]["filename"])
    os.makedirs(os.path.dirname(os.path.abspath(a.output)) or ".", exist_ok=True)
    shutil.copy(src, a.output)
    print(f"done in {(time.time() - t0) / 60:.1f} min -> {a.output} ({w}x{h}; server copy {src})")

if __name__ == "__main__":
    main()
