"""Render every journey-narration string to <out>/<key>.mp3 with the approved ElevenLabs
narrator for its language. Idempotent: skips keys already rendered. Writes
journey_audio_manifest[_ur].json alongside. Requires ELEVENLABS_API_KEY in env.

The strings come from extract_journey_strings.gather(lang), which reads them back from the
app's real narration logic (JourneyNarration.timeline, and for Urdu the same timeline with
its lines translated) - so a rendered mp3 is exactly what the app hashes and plays. This
renders the narrator, not dua Arabic.

  --lang en (default)  Bear, into Thaqalayn/Resources/JourneyAudio/ (or $JOURNEY_AUDIO_OUT)
  --lang ur            Laksh, into journey-audio-render-ur/ (or $JOURNEY_AUDIO_OUT). Lines the
                       Urdu timeline still carries in English (no translation yet) are never
                       sent to the Urdu voice - they are listed and left unrendered.

Run:
  cd <repo> && set -a && . ./.env && set +a
  cd scripts && ../.venv/bin/python build_journey_audio.py [--lang ur] [journey-id ...]
"""
import argparse
import json
import os
import re
import sys
import threading
import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

from journey_audio_key import journey_audio_key
from extract_journey_strings import gather, ROOT

# Narrator = Bear (Resonant, Rich, Cinematic) - a warm, deep, measured American baritone,
# approved by ear 2026-08-21. (Laksh, the dua voice, was tried first but its Hindi-accented
# English didn't fit reverent narration; Bear is a clean native-English emotional voice.)
# Urdu narrator = Laksh, the dua voice - approved by ear for Urdu on the Miracle Stories
# (2026-09-30, chosen over Bear, whose Urdu carried an English accent).
VOICES = {
    "en": "yU0EHuTjuZhsJiFqbAVB",   # Bear - warm resonant cinematic baritone
    "ur": "nwuvEDGFwpyogO4zlBHp",   # Laksh - the dua voice
}
MODEL = "eleven_v3"                  # most expressive model, for emotional delivery
FMT = "mp3_44100_64"                 # speech-optimized, ~half the size of the dua 128 kbps.
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "use_speaker_boost": True}
WORKERS = int(os.environ.get("JOURNEY_AUDIO_WORKERS", "2"))   # the plan allows few concurrent requests
# Default output: English = the bundled free-tier folder, Urdu = its own staging folder (every
# Urdu pack is delivered on demand). Override with JOURNEY_AUDIO_OUT to render elsewhere
# (premium English journeys are delivered on-demand, not bundled - see Phase 4.2 - so their
# mp3s must not land in the app's Resources folder).
DEFAULT_OUT = {
    "en": os.path.join(ROOT, "Thaqalayn", "Resources", "JourneyAudio"),
    "ur": os.path.join(ROOT, "journey-audio-render-ur"),
}
LATIN = re.compile(r"[A-Za-z]")


def sanitize(text: str) -> str:
    # >>> SINGLE TUNING POINT: what ElevenLabs actually speaks (the file-name key is
    # >>> still hashed from the ORIGINAL, unsanitized string - see main()).
    # ﷺ (U+FDFA) — reverence policy CONFIRMED BY EAR AT TASK 1.4.
    # Default: strip the honorific glyph and collapse the doubled space it leaves,
    # yielding grammatical English ("the Prophet ﷺ." -> "the Prophet."). To voice the
    # salawat instead, replace with " peace be upon him and his family" and re-run.
    import re
    t = text.replace("ﷺ", "")
    t = re.sub(r"\s{2,}", " ", t).replace(" .", ".").replace(" ,", ",").strip()
    return t


class BlockedText(Exception):
    """ElevenLabs refused this text (400/403 content/ToS filter). Not retryable, and it must
    NOT kill the whole batch - the caller skips it, logs it, and moves on. A skipped string
    simply has no mp3, so the narrator skips that one clip at playback (handled gracefully)."""


class QuotaExhausted(Exception):
    """The key ran out of credits (401/402 quota). Nothing left to do - stop cleanly, keeping
    every clip already rendered, so a resume after topping up continues idempotently."""


def synth(text, voice, out_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice}?output_format={FMT}"
    body = json.dumps({"text": text, "model_id": MODEL, "voice_settings": SETTINGS}).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "xi-api-key": os.environ["ELEVENLABS_API_KEY"],
        "Content-Type": "application/json", "Accept": "audio/mpeg"})
    for attempt in range(6):
        try:
            with urllib.request.urlopen(req, timeout=180) as r:
                data = r.read()
            if not data:
                raise RuntimeError("empty audio")
            tmp = out_path + ".part"
            with open(tmp, "wb") as f:
                f.write(data)
            os.replace(tmp, out_path)            # never leave a half-written clip behind
            return len(data)
        except urllib.error.HTTPError as e:      # HTTPError is a URLError subclass - catch it first
            msg = e.read().decode("utf-8", "replace")[:200]
            if e.code in (429, 500, 502, 503) and attempt < 5:
                time.sleep(2 * (attempt + 1))
                continue
            if e.code in (400, 403):            # content/ToS block - skip this string, keep going
                raise BlockedText(msg)
            if e.code in (401, 402) and "quota" in msg.lower():   # out of credits - stop cleanly
                raise QuotaExhausted(msg)
            raise RuntimeError(f"HTTP {e.code}: {msg}")
        except (urllib.error.URLError, TimeoutError) as e:
            # Connection-level failure (timeout, DNS, reset) - transient. Retry with backoff;
            # give up on this one clip after the last attempt (the caller skips + can resume).
            if attempt < 5:
                time.sleep(3 * (attempt + 1))
                continue
            reason = getattr(e, "reason", e)
            raise RuntimeError(f"network error after retries: {reason}")


def main():
    ap = argparse.ArgumentParser(description="Render journey narration with ElevenLabs.")
    ap.add_argument("--lang", choices=sorted(VOICES), default="en")
    ap.add_argument("journeys", nargs="*", help="journey ids (default: every journey)")
    args = ap.parse_args()
    lang, journeys = args.lang, args.journeys
    out = os.environ.get("JOURNEY_AUDIO_OUT") or DEFAULT_OUT[lang]
    os.makedirs(out, exist_ok=True)

    # With journey-id args, render only those journeys' strings (union, deduped by key -
    # includes shared connectors, so a journey renders in isolation). No args -> everything.
    if journeys:
        from extract_journey_strings import strings_for
        items = strings_for(journeys, lang)
        print(f"[{lang}] rendering {len(journeys)} journey(s) [{', '.join(journeys)}]: {len(items)} unique strings")
    else:
        items = gather(lang)

    # Key hashes the ORIGINAL string (what the app hashes at runtime); the TTS text is
    # sanitize(text). These two intentionally differ - do not conflate them.
    manifest, jobs, untranslated, skipped = [], [], [], 0
    for it in items:
        key = journey_audio_key(it["text"])
        manifest.append({"key": key, "journey": it["journey"], "order": it["order"], "text": it["text"]})
        if lang == "ur" and LATIN.search(it["text"]):
            untranslated.append(it)          # still English - never voice it in Urdu
            continue
        path = os.path.join(out, f"{key}.mp3")
        if os.path.exists(path):
            skipped += 1
        else:
            jobs.append((key, it, path))
    print(f"[{lang}] {len(items)} strings: {skipped} already rendered, {len(untranslated)} untranslated, "
          f"{len(jobs)} to render ({sum(len(sanitize(j[1]['text'])) for j in jobs)} characters) -> {out}")

    lock, stop = threading.Lock(), threading.Event()
    blocked, failed, rendered = [], [], 0
    consecutive_fail = 0

    def work(job):
        key, it, path = job
        if stop.is_set():
            return None
        try:
            return ("ok", job, synth(sanitize(it["text"]), VOICES[lang], path))
        except BlockedText as b:
            return ("blocked", job, str(b))
        except QuotaExhausted as q:
            # Out of credits: stop here, keep everything rendered so far. A later resume
            # (after topping up) continues from exactly this point - nothing re-rendered.
            stop.set()
            return ("quota", job, str(q))
        except Exception as e:  # noqa: BLE001 - one clip's failure must not stop the rest
            return ("failed", job, str(e))

    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        for fut in as_completed([pool.submit(work, j) for j in jobs]):
            result = fut.result()
            if not result:
                continue
            status, (key, it, _), info = result
            where = f"{it['journey']}#{it['order']}"
            with lock:
                if status == "ok":
                    rendered += 1
                    consecutive_fail = 0
                    print(f"  OK   {key}  {info:>7}B  {where}  ({rendered}/{len(jobs)})", flush=True)
                elif status == "blocked":
                    # ToS filter refused it: skip, log, keep going. A skipped string has no mp3,
                    # so its pack stays incomplete (and unshipped) until the line is reworded.
                    blocked.append({"key": key, "journey": it["journey"], "order": it["order"],
                                    "text": it["text"], "reason": info[:160]})
                    print(f"  BLOCKED {key}  {where}  {it['text'][:70]!r}", flush=True)
                elif status == "quota":
                    print(f"\n⛔ QUOTA EXHAUSTED at {where} - stopping cleanly.\n   {info[:200]}", flush=True)
                else:
                    # Transient failure that survived synth's retries - re-rendered on the next
                    # resume (idempotent). A run of these means the network is down: stop.
                    failed.append({"key": key, "journey": it["journey"], "order": it["order"],
                                   "text": it["text"], "reason": info[:160]})
                    consecutive_fail += 1
                    print(f"  FAIL {key}  {where}  {info[:110]}", flush=True)
                    if consecutive_fail >= 8 and not stop.is_set():
                        print("\n⛔ 8 consecutive failures - network likely down. Stopping; resume later.")
                        stop.set()

    # Manifest lives OUTSIDE the bundled folder (scripts/) so it isn't shipped in the app and
    # can't collide with another manifest.json when resources are flattened. Only a full
    # (unfiltered) run owns the canonical manifest - a filtered run must not clobber it.
    suffix = "" if lang == "en" else f"_{lang}"
    if not journeys and not stop.is_set():
        with open(os.path.join(ROOT, "scripts", f"journey_audio_manifest{suffix}.json"), "w") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
    if blocked:
        blocked_path = os.path.join(ROOT, "scripts", f"journey_audio_blocked{suffix}.json")
        with open(blocked_path, "w") as f:
            json.dump(blocked, f, ensure_ascii=False, indent=2)
        print(f"\n⚠️  {len(blocked)} string(s) BLOCKED by the ToS filter -> {blocked_path}")
    if untranslated:
        per = {}
        for it in untranslated:
            per[it["journey"]] = per.get(it["journey"], 0) + 1
        print(f"\n⚠️  {len(untranslated)} line(s) have no Urdu yet (left unrendered): "
              + ", ".join(f"{j} {n}" for j, n in per.items()))
    print(f"\n[{lang}] rendered {rendered}, skipped {skipped}, blocked {len(blocked)}, "
          f"failed {len(failed)}, untranslated {len(untranslated)}; {len(manifest)} unique keys")
    if failed:
        print(f"  ({len(failed)} transient failures - re-run to render these; nothing else re-renders)")


if __name__ == "__main__":
    main()
