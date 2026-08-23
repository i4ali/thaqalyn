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
# Default output = the bundled free-tier folder. Override with JOURNEY_AUDIO_OUT to render
# into a staging/asset-pack area instead (premium journeys are delivered on-demand, not
# bundled - see Phase 4.2 - so their mp3s must not land in the app's Resources folder).
OUT = os.environ.get("JOURNEY_AUDIO_OUT") or os.path.join(ROOT, "Thaqalayn", "Resources", "JourneyAudio")


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


def synth(text, out_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}?output_format={FMT}"
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
            open(out_path, "wb").write(data)
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
    manifest, rendered, skipped, blocked, failed = [], 0, 0, [], []
    stopped_early = False
    consecutive_fail = 0
    for it in items:
        # Key hashes the ORIGINAL string (what the app hashes at runtime); the TTS text
        # is sanitize(text). These two intentionally differ - do not conflate them.
        key = journey_audio_key(it["text"])
        path = os.path.join(OUT, f"{key}.mp3")
        if os.path.exists(path):
            skipped += 1
            print(f"  skip {key}  {it['journey']}#{it['order']}")
        else:
            try:
                n = synth(sanitize(it["text"]), path)
            except BlockedText as b:
                blocked.append({"key": key, "journey": it["journey"], "order": it["order"],
                                "text": it["text"], "reason": str(b)[:160]})
                print(f"  BLOCKED {key}  {it['journey']}#{it['order']}  {it['text'][:70]!r}")
                continue
            except QuotaExhausted as q:
                # Out of credits: stop here, keep everything rendered so far. A later resume
                # (after topping up) continues from exactly this point - nothing re-rendered.
                print(f"\n⛔ QUOTA EXHAUSTED at {it['journey']}#{it['order']} - stopping cleanly.\n   {str(q)[:200]}")
                stopped_early = True
                break
            except Exception as e:
                # Transient failure (network timeout, etc.) that survived synth's retries. Skip
                # this one clip and keep going - it's re-rendered on the next resume (idempotent).
                # A run of these means the network is down, so break out rather than churn.
                failed.append({"key": key, "journey": it["journey"], "order": it["order"],
                               "text": it["text"], "reason": str(e)[:160]})
                consecutive_fail += 1
                print(f"  FAIL {key}  {it['journey']}#{it['order']}  {str(e)[:110]}")
                if consecutive_fail >= 8:
                    print("\n⛔ 8 consecutive failures - network likely down. Stopping; resume later.")
                    stopped_early = True
                    break
                continue
            consecutive_fail = 0
            rendered += 1
            print(f"  OK   {key}  {n:>7}B  {it['journey']}#{it['order']}")
            time.sleep(0.4)
        manifest.append({"key": key, "journey": it["journey"], "order": it["order"],
                         "chars": len(it["text"]), "text": it["text"]})
    # Manifest lives OUTSIDE the bundled folder (scripts/) so it isn't shipped in the
    # app and can't collide with another manifest.json when resources are flattened.
    # Only a full (unfiltered) run owns the canonical manifest - a filtered run must not
    # clobber it with a partial list.
    if not journeys and not stopped_early:
        manifest_path = os.path.join(ROOT, "scripts", "journey_audio_manifest.json")
        with open(manifest_path, "w") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
    if blocked:
        blocked_path = os.path.join(ROOT, "scripts", "journey_audio_blocked.json")
        with open(blocked_path, "w") as f:
            json.dump(blocked, f, ensure_ascii=False, indent=2)
        print(f"\n⚠️  {len(blocked)} string(s) BLOCKED by the ToS filter -> {blocked_path}")
    uniq = len({m["key"] for m in manifest})
    print(f"\nrendered {rendered}, skipped {skipped}, blocked {len(blocked)}, "
          f"failed {len(failed)}; {len(manifest)} entries, {uniq} unique keys")
    if failed:
        print(f"  ({len(failed)} transient failures - re-run to render these; nothing else re-renders)")


if __name__ == "__main__":
    main()
