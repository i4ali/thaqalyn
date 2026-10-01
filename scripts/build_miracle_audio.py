#!/usr/bin/env python3
"""Render the Miracle Stories narration: one mp3 per paragraph, per story, per language,
straight into the On-Demand Resources packs the app downloads on the first Listen.

  OnDemandMiracleAudio/miracle-<nn>-<lang>/<key>.mp3

<key> is JourneyAudioKey's content hash of the paragraph text (NFC, trimmed, SHA256, first
20 hex), so the app finds each clip by hashing the paragraph it is showing - a paragraph
whose text changes simply gets a new clip on the next run. Paragraphs come from
Thaqalayn/Data/miracle_stories.json exactly as the reader splits them (body, then closing,
on blank lines), so clip order = paragraph order and the reader can follow along with no
timing data.

Voices (approved by ear): English = Bear, the Journey Listen narrator; Urdu = Laksh, the
dua voice (2026-09-30, chosen over Bear, whose Urdu carried an English accent).

Idempotent: existing clips are skipped; clips no longer in the stories are pruned. Writes
scripts/miracle_audio_manifest.json and the bundled Thaqalayn/Data/miracle_audio_ready.json
(the packs whose every paragraph has a clip - the app only offers recorded Listen for those).

Run:
  cd <repo> && set -a && . ./.env && set +a
  .venv/bin/python scripts/build_miracle_audio.py [nn ...]      # all stories when none given
Then: .venv/bin/python scripts/wire_miracle_odr.py  (adds new packs to the Xcode project)
"""
import json
import os
import sys
import threading
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from journey_audio_key import journey_audio_key  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STORIES = os.path.join(ROOT, "Thaqalayn", "Data", "miracle_stories.json")
PACKS = os.path.join(ROOT, "OnDemandMiracleAudio")
MANIFEST = os.path.join(ROOT, "scripts", "miracle_audio_manifest.json")
READY = os.path.join(ROOT, "Thaqalayn", "Data", "miracle_audio_ready.json")

VOICES = {
    "en": "yU0EHuTjuZhsJiFqbAVB",   # Bear - the Journey Listen narrator
    "ur": "nwuvEDGFwpyogO4zlBHp",   # Laksh - the dua voice
}
MODEL = "eleven_v3"
FMT = "mp3_44100_64"                # speech-optimized, same as Journey narration
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "use_speaker_boost": True}
WORKERS = int(os.environ.get("MIRACLE_AUDIO_WORKERS", "2"))   # the plan allows few concurrent requests


class BlockedText(Exception):
    """ElevenLabs refused the text (400/403). Skip it; the pack is then not 'ready'."""


class QuotaExhausted(Exception):
    """Out of credits. Stop cleanly; a later run resumes where this one stopped."""


def tag(number: int, lang: str) -> str:
    return f"miracle-{number:02d}-{lang}"


def paragraphs(story: dict, lang: str) -> list[tuple[str, str]]:
    """(id, text) for every paragraph, in reading order - mirrors MiracleStory.paragraphs(for:)."""
    out = []
    for section in ("body", "closing"):
        value = story.get(section)
        if not value:
            continue
        paras = [p.strip() for p in value[lang].split("\n\n") if p.strip()]
        out += [(f"{section}.{i}", p) for i, p in enumerate(paras)]
    return out


def speakable(text: str) -> str:
    """What the voice actually reads (the file key still hashes the text as shown)."""
    return text.replace("ﷺ", "").replace("  ", " ").strip()


def synth(text: str, voice: str, out_path: str) -> int:
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice}?output_format={FMT}"
    body = json.dumps({"text": text, "model_id": MODEL, "voice_settings": SETTINGS}).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "xi-api-key": os.environ["ELEVENLABS_API_KEY"],
        "Content-Type": "application/json", "Accept": "audio/mpeg"})
    for attempt in range(6):
        try:
            with urllib.request.urlopen(req, timeout=240) as r:
                data = r.read()
            if not data:
                raise RuntimeError("empty audio")
            tmp = out_path + ".part"
            with open(tmp, "wb") as f:
                f.write(data)
            os.replace(tmp, out_path)            # never leave a half-written clip behind
            return len(data)
        except urllib.error.HTTPError as e:
            msg = e.read().decode("utf-8", "replace")[:200]
            if e.code in (429, 500, 502, 503) and attempt < 5:
                time.sleep(3 * (attempt + 1))
                continue
            if e.code in (400, 403):
                raise BlockedText(msg)
            if e.code in (401, 402) and "quota" in msg.lower():
                raise QuotaExhausted(msg)
            raise RuntimeError(f"HTTP {e.code}: {msg}")
        except (urllib.error.URLError, TimeoutError) as e:
            if attempt < 5:
                time.sleep(3 * (attempt + 1))
                continue
            raise RuntimeError(f"network error after retries: {getattr(e, 'reason', e)}")


def main() -> int:
    stories = json.load(open(STORIES, encoding="utf-8"))["stories"]
    wanted = {int(a) for a in sys.argv[1:]}
    manifest, jobs = {}, []
    for story in stories:
        for lang in ("en", "ur"):
            t = tag(story["number"], lang)
            clips = []
            for pid, text in paragraphs(story, lang):
                key = journey_audio_key(text)
                clips.append({"id": pid, "key": key, "chars": len(text)})
                path = os.path.join(PACKS, t, f"{key}.mp3")
                if not os.path.exists(path) and (not wanted or story["number"] in wanted):
                    jobs.append((t, pid, lang, text, path))
            manifest[t] = clips

    print(f"{sum(len(c) for c in manifest.values())} clips in {len(manifest)} packs; "
          f"{len(jobs)} to render ({sum(len(j[3]) for j in jobs)} characters)")
    lock, stop = threading.Lock(), threading.Event()
    blocked, failed, done = [], [], 0

    def work(job):
        t, pid, lang, text, path = job
        if stop.is_set():
            return
        os.makedirs(os.path.dirname(path), exist_ok=True)
        try:
            n = synth(speakable(text), VOICES[lang], path)
            return ("ok", job, n)
        except BlockedText as b:
            return ("blocked", job, str(b))
        except QuotaExhausted as q:
            stop.set()
            return ("quota", job, str(q))
        except Exception as e:  # noqa: BLE001 - one clip's failure must not stop the rest
            return ("failed", job, str(e))

    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        for fut in as_completed([pool.submit(work, j) for j in jobs]):
            result = fut.result()
            if not result:
                continue
            status, (t, pid, _, _, _), info = result
            with lock:
                if status == "ok":
                    done += 1
                    print(f"  {done}/{len(jobs)}  {t} {pid}  {info // 1024} KB", flush=True)
                elif status == "blocked":
                    blocked.append(f"{t} {pid}: {info[:120]}")
                    print(f"  BLOCKED {t} {pid}", flush=True)
                elif status == "quota":
                    print(f"  QUOTA EXHAUSTED at {t} {pid} - stopping; rerun to resume", flush=True)
                else:
                    failed.append(f"{t} {pid}: {info[:120]}")
                    print(f"  FAIL {t} {pid}: {info[:120]}", flush=True)

    # Prune clips whose paragraph text no longer exists (only for packs we know about).
    pruned = 0
    for t, clips in manifest.items():
        folder = os.path.join(PACKS, t)
        if not os.path.isdir(folder):
            continue
        keep = {c["key"] + ".mp3" for c in clips}
        for name in os.listdir(folder):
            if name.endswith(".mp3") and name not in keep:
                os.remove(os.path.join(folder, name))
                pruned += 1

    ready = sorted(t for t, clips in manifest.items()
                   if all(os.path.exists(os.path.join(PACKS, t, c["key"] + ".mp3")) for c in clips))
    with open(MANIFEST, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")
    with open(READY, "w", encoding="utf-8") as f:
        json.dump(ready, f, indent=2)
        f.write("\n")

    print(f"\nrendered {done}, blocked {len(blocked)}, failed {len(failed)}, pruned {pruned}; "
          f"{len(ready)}/{len(manifest)} packs ready")
    for line in blocked + failed:
        print("  -", line)
    return 0 if not (blocked or failed or stop.is_set()) else 1


if __name__ == "__main__":
    sys.exit(main())
