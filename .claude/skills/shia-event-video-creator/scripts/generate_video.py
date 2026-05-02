#!/usr/bin/env python3
"""
Generate a video from an image + motion prompt using Kling AI.

Recommended: `--mode v2-1-master` (Kling 2.1 Master, flagship image-to-video model
with the best prompt adherence for veiled sacred figures).

Usage:
    python generate_video.py \\
        --image /path/to/scene_01.png \\
        --prompt "subtle motion prompt" \\
        --duration 5 \\
        --mode v2-1-master \\
        --output /path/to/scene_01.mp4

Supported modes (highest to lowest quality for religious content):
    v2-1-master    Kling 2.1 Master — flagship, best prompt adherence. RECOMMENDED.
    v2-1           Kling 2.1 — good quality, cheaper than master.
    v2-pro         Kling 2.0 Master (pro) — older; does NOT support 10s duration.
    v2-standard    Kling 2.0 Master (std) — older; does NOT support 10s duration.
    v1-6           Kling 1.6 — legacy.
    pro / standard Kling 1.0 — legacy.

Known limitations:
    - kling-v2-master (v2-standard/v2-pro) only supports duration=5. Use v2-1-master
      or v1-6 if you need 10s clips.

Auth paths (auto-detected from env):

1. Official Kling API (api.klingai.com) — RECOMMENDED
   - Set KLING_ACCESS_KEY and KLING_SECRET_KEY
   - The script generates a JWT per request using HS256

2. Third-party Kling gateway (PiAPI, fal.ai, Kie.ai, AIML, etc.)
   - Set KLING_API_KEY and KLING_API_ENDPOINT
   - KLING_AUTH_HEADER = "Bearer" (default) or "X-API-Key"

Env vars are auto-loaded from .env via python-dotenv if present.

Kling is async. The script:
  1. Uploads the image (base64 inline)
  2. Submits the generation request
  3. Polls until complete (up to 10 minutes)
  4. Downloads the resulting MP4 to --output

Exits 0 on success, non-zero on any failure.
"""

import argparse
import base64
import json
import os
import sys
import time
from pathlib import Path

import requests

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


POLL_INTERVAL_SEC = 10
MAX_POLL_MINUTES = 10


def encode_image_base64(image_path: Path) -> str:
    """Read an image and return its base64 string (no data URI prefix)."""
    return base64.b64encode(image_path.read_bytes()).decode("ascii")


# ----------------------------------------------------------------------------
# Official Kling API (JWT auth)
# ----------------------------------------------------------------------------

def make_kling_jwt() -> str:
    """
    Build an HS256 JWT for the official Kling API.
    Claims: iss=access_key, exp=now+30min, nbf=now-5s
    """
    import jwt  # PyJWT

    ak = os.environ.get("KLING_ACCESS_KEY")
    sk = os.environ.get("KLING_SECRET_KEY")
    if not ak or not sk:
        raise RuntimeError("KLING_ACCESS_KEY and KLING_SECRET_KEY must be set for official Kling auth.")

    now = int(time.time())
    payload = {
        "iss": ak,
        "exp": now + 1800,
        "nbf": now - 5,
    }
    token = jwt.encode(payload, sk, algorithm="HS256", headers={"alg": "HS256", "typ": "JWT"})
    # PyJWT returns str in modern versions
    return token if isinstance(token, str) else token.decode("utf-8")


def generate_official_kling(
    image_path: Path,
    prompt: str,
    duration: int,
    mode: str,
    output: Path,
) -> None:
    base = "https://api.klingai.com"
    submit_url = f"{base}/v1/videos/image2video"

    image_b64 = encode_image_base64(image_path)

    # Map our "mode" to Kling's model_name
    model_name = {
        "standard": "kling-v1",
        "pro": "kling-v1",
        "v1-6": "kling-v1-6",
        "v2-standard": "kling-v2-master",
        "v2-pro": "kling-v2-master",
        "v2-1": "kling-v2-1",
        "v2-1-master": "kling-v2-1-master",
    }.get(mode, "kling-v1")

    # Mode parameter (std vs pro) — only some models accept this
    kling_mode = "std" if "standard" in mode else "pro"

    payload = {
        "model_name": model_name,
        "mode": kling_mode,
        "image": image_b64,
        "prompt": prompt,
        "duration": str(duration),
        "cfg_scale": 0.5,
    }

    headers = {
        "Authorization": f"Bearer {make_kling_jwt()}",
        "Content-Type": "application/json",
    }

    print(f"Submitting to official Kling ({model_name}, {duration}s, mode={mode})...", file=sys.stderr)
    r = requests.post(submit_url, json=payload, headers=headers, timeout=120)
    if r.status_code != 200:
        raise RuntimeError(f"Kling submit error {r.status_code}: {r.text[:500]}")

    data = r.json()
    task_id = data.get("data", {}).get("task_id") or data.get("task_id")
    if not task_id:
        raise RuntimeError(f"No task_id in Kling submit response: {data}")

    print(f"Kling task_id={task_id}. Polling...", file=sys.stderr)

    # Poll
    poll_url = f"{base}/v1/videos/image2video/{task_id}"
    deadline = time.time() + MAX_POLL_MINUTES * 60
    video_url = None
    while time.time() < deadline:
        # Refresh JWT if we're past half its life
        poll_headers = {"Authorization": f"Bearer {make_kling_jwt()}"}
        pr = requests.get(poll_url, headers=poll_headers, timeout=60)
        if pr.status_code != 200:
            print(f"  Poll {pr.status_code}: {pr.text[:200]}", file=sys.stderr)
            time.sleep(POLL_INTERVAL_SEC)
            continue
        pdata = pr.json().get("data", {})
        status = pdata.get("task_status")
        print(f"  status={status}", file=sys.stderr)
        if status == "succeed":
            videos = pdata.get("task_result", {}).get("videos", [])
            if videos:
                video_url = videos[0].get("url")
            break
        if status == "failed":
            reason = pdata.get("task_status_msg") or "unknown"
            raise RuntimeError(f"Kling generation failed: {reason}")
        time.sleep(POLL_INTERVAL_SEC)

    if not video_url:
        raise RuntimeError(f"Kling did not return a video within {MAX_POLL_MINUTES} minutes.")

    download_video(video_url, output)


# ----------------------------------------------------------------------------
# Third-party gateway (simpler, single API key)
# ----------------------------------------------------------------------------

def generate_gateway_kling(
    image_path: Path,
    prompt: str,
    duration: int,
    mode: str,
    output: Path,
) -> None:
    """
    Generic third-party Kling gateway. The exact endpoint shape varies by provider,
    so this uses a reasonable PiAPI-style default that most gateways adapt from.

    User must set:
        KLING_API_KEY
        KLING_API_ENDPOINT   e.g. https://api.piapi.ai/api/v1
        KLING_AUTH_HEADER    "Bearer" (default) or "X-API-Key"
    """
    api_key = os.environ.get("KLING_API_KEY")
    endpoint = os.environ.get("KLING_API_ENDPOINT", "https://api.piapi.ai/api/v1")
    auth_header = os.environ.get("KLING_AUTH_HEADER", "Bearer")

    if not api_key:
        raise RuntimeError("KLING_API_KEY must be set for gateway auth (or use official Kling with KLING_ACCESS_KEY/KLING_SECRET_KEY).")

    headers = {"Content-Type": "application/json"}
    if auth_header == "Bearer":
        headers["Authorization"] = f"Bearer {api_key}"
    else:
        headers[auth_header] = api_key

    image_b64 = encode_image_base64(image_path)

    # PiAPI-style submit
    submit_url = f"{endpoint.rstrip('/')}/task"
    submit_payload = {
        "model": "kling",
        "task_type": "video_generation",
        "input": {
            "prompt": prompt,
            "image_base64": image_b64,
            "duration": duration,
            "mode": mode,
            "aspect_ratio": "9:16",
        },
    }

    print(f"Submitting to Kling gateway ({endpoint}, mode={mode}, {duration}s)...", file=sys.stderr)
    r = requests.post(submit_url, json=submit_payload, headers=headers, timeout=120)
    if r.status_code not in (200, 201):
        raise RuntimeError(f"Gateway submit error {r.status_code}: {r.text[:500]}")

    data = r.json()
    task_id = (
        data.get("task_id")
        or data.get("data", {}).get("task_id")
        or data.get("id")
        or data.get("request_id")
    )
    if not task_id:
        raise RuntimeError(f"No task_id in gateway response: {data}")

    print(f"Gateway task_id={task_id}. Polling...", file=sys.stderr)

    poll_url = f"{endpoint.rstrip('/')}/task/{task_id}"
    deadline = time.time() + MAX_POLL_MINUTES * 60
    video_url = None
    while time.time() < deadline:
        pr = requests.get(poll_url, headers=headers, timeout=60)
        if pr.status_code != 200:
            print(f"  Poll {pr.status_code}: {pr.text[:200]}", file=sys.stderr)
            time.sleep(POLL_INTERVAL_SEC)
            continue
        pdata = pr.json()
        # Different gateways nest results differently
        status = (
            pdata.get("status")
            or pdata.get("data", {}).get("status")
            or pdata.get("task_status")
        )
        print(f"  status={status}", file=sys.stderr)

        if status in ("completed", "succeed", "success", "finished"):
            # Try several shapes
            video_url = (
                pdata.get("output", {}).get("video_url")
                or pdata.get("output", {}).get("url")
                or pdata.get("data", {}).get("video_url")
                or pdata.get("data", {}).get("output", {}).get("video_url")
                or pdata.get("result", {}).get("video_url")
                or pdata.get("video_url")
            )
            if not video_url:
                # Walk the structure
                video_url = _find_video_url(pdata)
            break
        if status in ("failed", "error"):
            reason = pdata.get("error") or pdata.get("message") or "unknown"
            raise RuntimeError(f"Gateway generation failed: {reason}")
        time.sleep(POLL_INTERVAL_SEC)

    if not video_url:
        raise RuntimeError(f"Gateway did not return a video within {MAX_POLL_MINUTES} minutes.")

    download_video(video_url, output)


def _find_video_url(obj) -> str | None:
    """Walk a nested dict/list to find the first value that looks like a video URL."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            if isinstance(v, str) and v.startswith("http") and (
                "video" in k.lower() or v.endswith(".mp4") or "mp4" in v
            ):
                return v
            found = _find_video_url(v)
            if found:
                return found
    elif isinstance(obj, list):
        for item in obj:
            found = _find_video_url(item)
            if found:
                return found
    return None


# ----------------------------------------------------------------------------

def download_video(url: str, output: Path) -> None:
    print(f"Downloading video → {output}", file=sys.stderr)
    r = requests.get(url, stream=True, timeout=300)
    r.raise_for_status()
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("wb") as f:
        for chunk in r.iter_content(chunk_size=1024 * 64):
            if chunk:
                f.write(chunk)


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate a Kling image-to-video clip.")
    ap.add_argument("--image", required=True, help="Input image path (used as first frame).")
    ap.add_argument("--prompt", required=True, help="Motion/content prompt.")
    ap.add_argument("--output", required=True, help="Output MP4 path.")
    ap.add_argument("--duration", type=int, default=5, choices=[5, 10], help="Clip duration in seconds.")
    ap.add_argument(
        "--mode",
        default="v2-1-master",
        choices=["standard", "pro", "v1-6", "v2-standard", "v2-pro", "v2-1", "v2-1-master"],
        help="Kling model tier. v2-1-master is flagship (best prompt adherence, higher cost). Default: v2-1-master.",
    )
    ap.add_argument(
        "--auth",
        choices=["auto", "official", "gateway"],
        default="auto",
        help="Which auth style to use. 'auto' picks based on env vars.",
    )
    args = ap.parse_args()

    image_path = Path(args.image)
    output_path = Path(args.output)

    if not image_path.exists():
        print(f"ERROR: image not found: {image_path}", file=sys.stderr)
        return 1

    # Known model/duration incompatibilities
    if args.duration == 10 and args.mode in ("v2-standard", "v2-pro"):
        print(
            f"ERROR: Kling v2-master ({args.mode}) does not support duration=10. "
            "Use --mode v2-1-master or --mode v1-6 for 10s clips, or drop to --duration 5.",
            file=sys.stderr,
        )
        return 1

    # Decide auth path
    auth_style = args.auth
    if auth_style == "auto":
        if os.environ.get("KLING_ACCESS_KEY") and os.environ.get("KLING_SECRET_KEY"):
            auth_style = "official"
        elif os.environ.get("KLING_API_KEY"):
            auth_style = "gateway"
        else:
            print(
                "ERROR: no Kling credentials. Set either "
                "(KLING_ACCESS_KEY + KLING_SECRET_KEY) for official, "
                "or KLING_API_KEY (+ optional KLING_API_ENDPOINT) for a gateway.",
                file=sys.stderr,
            )
            return 1

    try:
        if auth_style == "official":
            generate_official_kling(image_path, args.prompt, args.duration, args.mode, output_path)
        else:
            generate_gateway_kling(image_path, args.prompt, args.duration, args.mode, output_path)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1

    print(str(output_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
