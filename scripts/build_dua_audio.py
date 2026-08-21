"""Render every dua string to Thaqalayn/Resources/DuaAudio/<key>.mp3 with the
approved ElevenLabs v3 config. Idempotent: skips keys already rendered. Writes
manifest.json alongside. Requires ELEVENLABS_API_KEY in env (use the PAID key).

Run:
  cd <repo>
  set -a && . ./.env && set +a && export ELEVENLABS_API_KEY="$ELEVENLABS_API_KEY_OLD"
  cd scripts && python3 build_dua_audio.py
"""
import json
import os
import time
import urllib.request
import urllib.error

from dua_audio_key import dua_audio_key
from extract_dua_strings import gather, ROOT

VOICE = "nwuvEDGFwpyogO4zlBHp"
MODEL = "eleven_v3"
FMT = "mp3_44100_128"
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "use_speaker_boost": True}
OUT = os.path.join(ROOT, "Thaqalayn", "Resources", "DuaAudio")


def synth(text, out_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}?output_format={FMT}"
    body = json.dumps({"text": text, "model_id": MODEL, "voice_settings": SETTINGS}).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "xi-api-key": os.environ["ELEVENLABS_API_KEY"],
        "Content-Type": "application/json", "Accept": "audio/mpeg"})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=180) as r:
                data = r.read()
            if not data:
                raise RuntimeError("empty audio")
            open(out_path, "wb").write(data)
            return len(data)
        except urllib.error.HTTPError as e:
            msg = e.read().decode("utf-8", "replace")[:200]
            if e.code in (429, 500, 502, 503) and attempt < 3:
                time.sleep(2 * (attempt + 1))
                continue
            raise RuntimeError(f"HTTP {e.code}: {msg}")


def main():
    os.makedirs(OUT, exist_ok=True)
    items = gather()
    manifest, rendered, skipped = [], 0, 0
    for it in items:
        key = dua_audio_key(it["arabic"])
        path = os.path.join(OUT, f"{key}.mp3")
        if os.path.exists(path):
            skipped += 1
            print(f"  skip {key}  {it['source']}")
        else:
            n = synth(it["arabic"], path)
            rendered += 1
            print(f"  OK   {key}  {n:>7}B  {it['source']}")
            time.sleep(0.4)
        manifest.append({"key": key, "source": it["source"],
                         "chars": len(it["arabic"]), "arabic": it["arabic"]})
    # Manifest lives OUTSIDE the bundled folder (scripts/) so it isn't shipped in the
    # app and can't collide with another manifest.json when resources are flattened.
    manifest_path = os.path.join(ROOT, "scripts", "dua_audio_manifest.json")
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    uniq = len({m["key"] for m in manifest})
    print(f"\nrendered {rendered}, skipped {skipped}; {len(manifest)} entries, {uniq} unique keys")


if __name__ == "__main__":
    main()
