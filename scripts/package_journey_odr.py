"""Partition the rendered journey narration into per-journey On-Demand Resource packs.

The two free journeys (Yaqin, al-Fatiha) ship bundled in Thaqalayn/Resources/JourneyAudio/
(left untouched). Every other journey becomes a SELF-CONTAINED pack under OnDemandAudio/<id>/
holding every narration mp3 that journey speaks (its own lines + the shared connectors), so it
downloads and plays as one independent ODR tag with no cross-pack dependency. The folder name
is the journey id, which is both the ODR tag AND the bundle subdirectory the app resolves from
(JourneyAudioKey.recordingURL packSubdirectory).

Urdu (--lang ur): every journey's Urdu narration is its own pack, OnDemandAudio/<id>-ur/,
tagged "<id>-ur" (the free journeys too - only their English is bundled). A pack is complete
when every Urdu line has a clip and no line is still untranslated English. Each run touches
only its own language's packs and ready entries, so packaging Urdu never disturbs English.

Source of truth for "what a journey speaks" is the same dump the renderer uses (the app's real
JourneyNarration.timeline), so packs never drift from playback.

Run (after the render populates journey-audio-render/ or journey-audio-render-ur/):
  cd <repo> && source .venv/bin/activate
  cd scripts && python3 package_journey_odr.py [--lang ur]
"""
import argparse
import json
import os
import re
import shutil
from collections import OrderedDict

from journey_audio_key import journey_audio_key
from extract_journey_strings import _extract, ROOT

RENDER_DIRS = {                                            # all rendered mp3s (staging)
    "en": os.path.join(ROOT, "journey-audio-render"),
    "ur": os.path.join(ROOT, "journey-audio-render-ur"),
}
ODR_DIR = os.path.join(ROOT, "OnDemandAudio")             # output: per-journey packs
BUNDLED = {"yaqin", "surah-fatiha"}                        # free tier English - stays bundled, not packed
LATIN = re.compile(r"[A-Za-z]")


def pack_tag(journey, lang):
    """ODR tag and pack folder = the journey id (English) or "<id>-<lang>"."""
    return journey if lang == "en" else f"{journey}-{lang}"


def is_lang_tag(tag, lang):
    return tag.endswith("-ur") if lang == "ur" else not tag.endswith("-ur")


def per_journey_keys(lang="en"):
    """{journey_id: [keys...]} - every string a journey speaks, per-journey deduped by key
    (shared connectors kept, so each pack is self-contained). Ordered, first-occurrence stable.
    Urdu lines still in English (untranslated) are returned as None so the pack stays incomplete."""
    items, _ = _extract(lang)
    out = OrderedDict()
    seen = {}
    for it in items:
        j = it["journey"]
        if j == "__meta__":
            continue
        if lang != "en" and LATIN.search(it["text"]):
            out.setdefault(j, []).append(None)          # untranslated - can never be present
            continue
        key = journey_audio_key(it["text"])
        seen.setdefault(j, set())
        if key in seen[j]:
            continue
        seen[j].add(key)
        out.setdefault(j, []).append(key)
    return out


def main():
    ap = argparse.ArgumentParser(description="Package rendered journey narration into ODR packs.")
    ap.add_argument("--lang", choices=sorted(RENDER_DIRS), default="en")
    lang = ap.parse_args().lang
    render_dir = RENDER_DIRS[lang]
    if not os.path.isdir(render_dir):
        raise SystemExit(f"no render dir at {render_dir} - run build_journey_audio.py --lang {lang} first")
    keys_by_journey = per_journey_keys(lang)

    # Rebuild this language's packs clean (so removed strings don't linger); the other
    # language's packs are left exactly as they are.
    os.makedirs(ODR_DIR, exist_ok=True)
    for name in os.listdir(ODR_DIR):
        if os.path.isdir(os.path.join(ODR_DIR, name)) and is_lang_tag(name, lang):
            shutil.rmtree(os.path.join(ODR_DIR, name))

    # Only COMPLETE packs (every clip rendered) are shippable. A journey with any missing clip
    # (unrendered, untranslated or ToS-blocked) is left out of the ODR dir and the ready list,
    # so Listen stays hidden on it until it's finished - no half-silent journeys ship.
    total_bytes, total_files = 0, 0
    complete, incomplete = [], {}   # complete: [(tag, files, bytes)]; incomplete: {tag: missing}
    for journey, keys in keys_by_journey.items():
        if lang == "en" and journey in BUNDLED:
            continue
        tag = pack_tag(journey, lang)
        present = [k for k in keys if k and os.path.exists(os.path.join(render_dir, f"{k}.mp3"))]
        n_missing = len(keys) - len(present)
        if n_missing > 0:
            incomplete[tag] = n_missing
            continue                                    # do not ship an incomplete pack
        dest = os.path.join(ODR_DIR, tag)
        os.makedirs(dest, exist_ok=True)
        jbytes = 0
        for k in present:
            shutil.copy2(os.path.join(render_dir, f"{k}.mp3"), os.path.join(dest, f"{k}.mp3"))
            jbytes += os.path.getsize(os.path.join(dest, f"{k}.mp3"))
        total_bytes += jbytes; total_files += len(present)
        complete.append((tag, len(present), jbytes))

    print(f"{'pack':22} {'clips':>6} {'size':>10}")
    print("-" * 42)
    for tag, jfiles, jbytes in complete:
        print(f"{tag:22} {jfiles:>6} {jbytes/1e6:>8.2f}MB")
    print("-" * 42)
    print(f"{'TOTAL (' + str(len(complete)) + ' complete packs)':30} {total_files:>4} {total_bytes/1e6:>8.2f}MB")
    if incomplete:
        print(f"\n⚠️  {len(incomplete)} incomplete pack(s) held back (Listen stays hidden):")
        for t, n in sorted(incomplete.items(), key=lambda x: -x[1]):
            print(f"    {t:22} missing {n}")

    # Pack index for the ODR wiring step (complete packs of both languages).
    packs_path = os.path.join(ROOT, "scripts", "journey_odr_packs.json")
    packs = json.load(open(packs_path)) if os.path.exists(packs_path) else {}
    packs = {t: n for t, n in packs.items() if not is_lang_tag(t, lang)}
    packs.update({t: n for t, n, _ in complete})
    with open(packs_path, "w") as f:
        json.dump(dict(sorted(packs.items())), f, indent=2)
    # Bundled audio-ready manifest the app gates Listen on: the free bundled journeys, every
    # complete English pack, and every complete Urdu pack ("<id>-ur"). Regenerated here for
    # this language, so finishing more journeys auto-updates it.
    ready_path = os.path.join(ROOT, "Thaqalayn", "Resources", "journey_audio_ready.json")
    ready = json.load(open(ready_path)) if os.path.exists(ready_path) else []
    keep = [t for t in ready if not is_lang_tag(t, lang)]
    mine = (sorted(BUNDLED) if lang == "en" else []) + sorted(t for t, _, _ in complete)
    ready = (mine + keep) if lang == "en" else (keep + mine)
    with open(ready_path, "w") as f:
        json.dump(ready, f, indent=2)
    print(f"\naudio-ready ({len(ready)}): {', '.join(ready)}")
    print(f"wrote {ready_path}")


if __name__ == "__main__":
    main()
