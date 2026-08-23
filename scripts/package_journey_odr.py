"""Partition the rendered journey narration into per-journey On-Demand Resource packs.

The two free journeys (Yaqin, al-Fatiha) ship bundled in Thaqalayn/Resources/JourneyAudio/
(left untouched). Every other journey becomes a SELF-CONTAINED pack under OnDemandAudio/<id>/
holding every narration mp3 that journey speaks (its own lines + the shared connectors), so it
downloads and plays as one independent ODR tag with no cross-pack dependency. The folder name
is the journey id, which is both the ODR tag AND the bundle subdirectory the app resolves from
(JourneyAudioKey.recordingURL packSubdirectory).

Source of truth for "what a journey speaks" is the same dump the renderer uses (the app's real
JourneyNarration.timeline), so packs never drift from playback.

Run (after the render populates journey-audio-render/):
  cd <repo> && source .venv/bin/activate
  cd scripts && python3 package_journey_odr.py
"""
import json
import os
import shutil
from collections import OrderedDict

from journey_audio_key import journey_audio_key
from extract_journey_strings import _extract, ROOT

RENDER_DIR = os.path.join(ROOT, "journey-audio-render")   # all rendered mp3s (staging)
ODR_DIR = os.path.join(ROOT, "OnDemandAudio")             # output: per-journey packs
BUNDLED = {"yaqin", "surah-fatiha"}                        # free tier - stays bundled, not packed


def per_journey_keys():
    """{journey_id: [keys...]} - every string a journey speaks, per-journey deduped by key
    (shared connectors kept, so each pack is self-contained). Ordered, first-occurrence stable."""
    items, _ = _extract()
    out = OrderedDict()
    seen = {}
    for it in items:
        j = it["journey"]
        if j == "__meta__":
            continue
        key = journey_audio_key(it["text"])
        seen.setdefault(j, set())
        if key in seen[j]:
            continue
        seen[j].add(key)
        out.setdefault(j, []).append(key)
    return out


def main():
    if not os.path.isdir(RENDER_DIR):
        raise SystemExit(f"no render dir at {RENDER_DIR} - run build_journey_audio.py first")
    keys_by_journey = per_journey_keys()

    if os.path.isdir(ODR_DIR):
        shutil.rmtree(ODR_DIR)   # rebuild clean so removed strings don't linger
    os.makedirs(ODR_DIR, exist_ok=True)

    # Only COMPLETE packs (every clip rendered) are shippable. A journey with any missing clip
    # (unrendered or ToS-blocked) is left out of the ODR dir and the ready list, so Listen stays
    # hidden on it until it's finished - no half-silent journeys ship.
    total_bytes, total_files = 0, 0
    complete, incomplete = [], {}   # complete: [(journey, files, bytes)]; incomplete: {journey: missing}
    for journey, keys in keys_by_journey.items():
        if journey in BUNDLED:
            continue
        present = [k for k in keys if os.path.exists(os.path.join(RENDER_DIR, f"{k}.mp3"))]
        n_missing = len(keys) - len(present)
        dest = os.path.join(ODR_DIR, journey)
        if n_missing > 0:
            incomplete[journey] = n_missing
            continue                                    # do not ship an incomplete pack
        os.makedirs(dest, exist_ok=True)
        jbytes = 0
        for k in present:
            shutil.copy2(os.path.join(RENDER_DIR, f"{k}.mp3"), os.path.join(dest, f"{k}.mp3"))
            jbytes += os.path.getsize(os.path.join(dest, f"{k}.mp3"))
        total_bytes += jbytes; total_files += len(present)
        complete.append((journey, len(present), jbytes))

    print(f"{'journey':22} {'clips':>6} {'size':>10}")
    print("-" * 42)
    for journey, jfiles, jbytes in complete:
        print(f"{journey:22} {jfiles:>6} {jbytes/1e6:>8.2f}MB")
    print("-" * 42)
    print(f"{'TOTAL (' + str(len(complete)) + ' complete packs)':30} {total_files:>4} {total_bytes/1e6:>8.2f}MB")
    if incomplete:
        print(f"\n⚠️  {len(incomplete)} incomplete journey(s) held back (Listen stays hidden):")
        for j, n in sorted(incomplete.items(), key=lambda x: -x[1]):
            print(f"    {j:22} missing {n}")

    # Pack index for the ODR wiring step (complete packs only).
    with open(os.path.join(ROOT, "scripts", "journey_odr_packs.json"), "w") as f:
        json.dump({j: n for j, n, _ in complete}, f, indent=2)
    # Bundled audio-ready manifest the app gates the Listen entry on: the free bundled journeys
    # plus every complete ODR pack. Regenerated here, so finishing more journeys auto-updates it.
    ready = sorted(BUNDLED) + sorted(j for j, _, _ in complete)
    ready_path = os.path.join(ROOT, "Thaqalayn", "Resources", "journey_audio_ready.json")
    with open(ready_path, "w") as f:
        json.dump(ready, f, indent=2)
    print(f"\naudio-ready ({len(ready)}): {', '.join(ready)}")
    print(f"wrote {ready_path}")


if __name__ == "__main__":
    main()
