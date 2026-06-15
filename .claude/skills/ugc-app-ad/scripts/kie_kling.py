#!/usr/bin/env python3
"""
Generate a Kling image-to-video clip via Kie.ai's API.

Kie.ai's API shape differs from PiAPI (which the skill's generate_video.py targets),
so this adapter exists. It:
  1. Uploads the source PNG to tmpfiles.org to get a public URL (Kie.ai requires URL,
     not base64 or local file).
  2. Submits a createTask request to https://api.kie.ai/api/v1/jobs/createTask.
  3. Polls /api/v1/jobs/recordInfo until state == 'success' or 'fail'.
  4. Downloads the resulting MP4 to --output.

Env: KLING_API_KEY (Kie.ai key)
"""

import argparse
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

POLL_INTERVAL_SEC = 5
MAX_POLL_MINUTES = 15

MODEL_MAP = {
    "v2-1-master": "kling/v2-1-master-image-to-video",
    "v2-1": "kling/v2-1-standard-image-to-video",
    "v2-1-standard": "kling/v2-1-standard-image-to-video",
    "v2-1-pro": "kling/v2-1-pro-image-to-video",
    # Kling 3.0 uses a single model string; the resolution tier is passed as input.mode (std/pro/4K).
    "v3-0": "kling-3.0/video",
    "v3-0-std": "kling-3.0/video",
    "v3-0-pro": "kling-3.0/video",
    "v3-0-4k": "kling-3.0/video",
}

# Maps the --mode flag suffix to Kling 3.0's input.mode parameter.
V3_RESOLUTION_MODE = {
    "v3-0": "pro",        # default to 1080p
    "v3-0-std": "std",
    "v3-0-pro": "pro",
    "v3-0-4k": "4K",
}


def upload_to_tmpfiles(image_path: Path) -> str:
    with open(image_path, "rb") as f:
        r = requests.post(
            "https://tmpfiles.org/api/v1/upload",
            files={"file": f},
            timeout=60,
        )
    r.raise_for_status()
    data = r.json()
    share_url = data["data"]["url"]
    direct = share_url.replace("tmpfiles.org/", "tmpfiles.org/dl/")
    return direct


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True)
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--output", required=True)
    ap.add_argument("--duration", type=int, default=5,
                    help="Clip duration in seconds. v2 supports 5/10; v3-0 supports 3-15.")
    ap.add_argument("--mode", default="v2-1-master",
                    help="One of v2-1-master, v2-1, v2-1-pro, v3-0, v3-0-std, v3-0-pro, v3-0-4k.")
    ap.add_argument("--image-url", default=None,
                    help="Optional: pre-uploaded public image URL (skips tmpfiles upload).")
    args = ap.parse_args()

    api_key = os.environ.get("KLING_API_KEY")
    if not api_key:
        print("ERROR: KLING_API_KEY not set", file=sys.stderr)
        return 1

    model = MODEL_MAP.get(args.mode, args.mode if args.mode.startswith("kling/") else f"kling/{args.mode}")
    image_path = Path(args.image)
    output_path = Path(args.output)

    if args.image_url:
        image_url = args.image_url
        print(f"Using pre-uploaded image_url={image_url}", file=sys.stderr)
    else:
        print(f"Uploading {image_path.name} to tmpfiles.org...", file=sys.stderr)
        image_url = upload_to_tmpfiles(image_path)
        print(f"  image_url={image_url}", file=sys.stderr)

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    is_v3 = model.startswith("kling-3")
    if is_v3:
        # Kling 3.0 has a different payload shape: image_urls array, mode, sound,
        # multi_shots, multi_prompt are all required by the OpenAPI spec.
        v3_mode = V3_RESOLUTION_MODE.get(args.mode, "pro")
        submit_payload = {
            "model": model,
            "input": {
                "prompt": args.prompt,
                "image_urls": [image_url],
                "duration": str(args.duration),
                "aspect_ratio": "9:16",
                "sound": False,
                "mode": v3_mode,
                "multi_shots": False,
                "multi_prompt": [],
            },
        }
        print(f"Submitting to Kie.ai (Kling 3.0, mode={v3_mode}, {args.duration}s)...", file=sys.stderr)
    else:
        submit_payload = {
            "model": model,
            "input": {
                "prompt": args.prompt,
                "image_url": image_url,
                "duration": str(args.duration),
                "aspect_ratio": "9:16",
            },
        }
        print(f"Submitting to Kie.ai ({model}, {args.duration}s)...", file=sys.stderr)
    r = requests.post(
        "https://api.kie.ai/api/v1/jobs/createTask",
        json=submit_payload,
        headers=headers,
        timeout=60,
    )
    if r.status_code not in (200, 201):
        print(f"ERROR: createTask {r.status_code}: {r.text[:600]}", file=sys.stderr)
        return 1

    data = r.json()
    if data.get("code") not in (200, 0):
        print(f"ERROR: API code {data.get('code')}: {data.get('msg')}", file=sys.stderr)
        return 1

    task_id = data.get("data", {}).get("taskId") or data.get("taskId")
    if not task_id:
        print(f"ERROR: no taskId in response: {data}", file=sys.stderr)
        return 1

    print(f"taskId={task_id}. Polling...", file=sys.stderr)
    deadline = time.time() + MAX_POLL_MINUTES * 60
    while time.time() < deadline:
        time.sleep(POLL_INTERVAL_SEC)
        pr = requests.get(
            f"https://api.kie.ai/api/v1/jobs/recordInfo?taskId={task_id}",
            headers=headers,
            timeout=30,
        )
        if pr.status_code != 200:
            print(f"  poll {pr.status_code}: {pr.text[:200]}", file=sys.stderr)
            continue
        pdata = pr.json()
        info = pdata.get("data", {})
        state = info.get("state")
        print(f"  state={state}", file=sys.stderr)

        if state == "success":
            result_json = info.get("resultJson", "{}")
            result = json.loads(result_json) if isinstance(result_json, str) else result_json
            urls = result.get("resultUrls") or result.get("result_urls") or []
            if not urls:
                print(f"ERROR: no resultUrls in {result}", file=sys.stderr)
                return 1
            video_url = urls[0]
            print(f"Downloading {video_url}...", file=sys.stderr)
            vr = requests.get(video_url, timeout=180, stream=True)
            vr.raise_for_status()
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, "wb") as f:
                for chunk in vr.iter_content(8192):
                    f.write(chunk)
            print(str(output_path))
            return 0

        if state in ("fail", "failed"):
            print(f"ERROR: task failed. failCode={info.get('failCode')} failMsg={info.get('failMsg')}", file=sys.stderr)
            return 1

    print(f"ERROR: timeout after {MAX_POLL_MINUTES}min", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
