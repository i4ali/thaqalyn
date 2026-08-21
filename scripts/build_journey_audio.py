"""Render every English journey-narration string to
Thaqalayn/Resources/JourneyAudio/<key>.mp3 with the approved ElevenLabs narrator
config. Idempotent: skips keys already rendered. Writes journey_audio_manifest.json
alongside. Requires ELEVENLABS_API_KEY in env (use the upgraded/PAID key).

The strings come from extract_journey_strings.gather(), which reads them back from the
app's real narration logic (JourneyNarration.timeline) - so a rendered mp3 is exactly
what the app hashes and plays. This renders the ENGLISH narrator, not dua Arabic.

Run:
  cd <repo>
  set -a && . ./.env && set +a && export ELEVENLABS_API_KEY="$ELEVENLABS_API_KEY_OLD"
  cd scripts && python3 build_journey_audio.py
"""
import json
import os
import re
import sys
import time
import urllib.request
import urllib.error

from journey_audio_key import journey_audio_key
from extract_journey_strings import gather, ROOT

# Narrator = Bear (Resonant, Rich, Cinematic) - a warm, deep, measured American baritone,
# approved by ear 2026-08-21. (Laksh, the dua voice, was tried first but its Hindi-accented
# English didn't fit reverent narration; Bear is a clean native-English emotional voice.)
VOICE = "yU0EHuTjuZhsJiFqbAVB"       # Bear - warm resonant cinematic baritone
MODEL = "eleven_v3"                  # most expressive model, for emotional delivery
FMT = "mp3_44100_64"                 # speech-optimized, ~half the size of the dua 128 kbps.
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "use_speaker_boost": True}
OUT = os.path.join(ROOT, "Thaqalayn", "Resources", "JourneyAudio")


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
    # With journey-id args, render only those journeys' strings (union, deduped by key -
    # includes shared connectors, so a journey renders in isolation). No args -> everything.
    journeys = sys.argv[1:]
    if journeys:
        from extract_journey_strings import strings_for
        items = strings_for(journeys)
        print(f"rendering {len(journeys)} journey(s) [{', '.join(journeys)}]: {len(items)} unique strings")
    else:
        items = gather()
    manifest, rendered, skipped = [], 0, 0
    for it in items:
        # Key hashes the ORIGINAL string (what the app hashes at runtime); the TTS text
        # is sanitize(text). These two intentionally differ - do not conflate them.
        key = journey_audio_key(it["text"])
        path = os.path.join(OUT, f"{key}.mp3")
        if os.path.exists(path):
            skipped += 1
            print(f"  skip {key}  {it['journey']}#{it['order']}")
        else:
            n = synth(sanitize(it["text"]), path)
            rendered += 1
            print(f"  OK   {key}  {n:>7}B  {it['journey']}#{it['order']}")
            time.sleep(0.4)
        manifest.append({"key": key, "journey": it["journey"], "order": it["order"],
                         "chars": len(it["text"]), "text": it["text"]})
    # Manifest lives OUTSIDE the bundled folder (scripts/) so it isn't shipped in the
    # app and can't collide with another manifest.json when resources are flattened.
    # Only a full (unfiltered) run owns the canonical manifest - a filtered run must not
    # clobber it with a partial list.
    if not journeys:
        manifest_path = os.path.join(ROOT, "scripts", "journey_audio_manifest.json")
        with open(manifest_path, "w") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
    uniq = len({m["key"] for m in manifest})
    print(f"\nrendered {rendered}, skipped {skipped}; {len(manifest)} entries, {uniq} unique keys")


if __name__ == "__main__":
    main()
