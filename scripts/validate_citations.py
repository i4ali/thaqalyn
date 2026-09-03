#!/usr/bin/env python3
"""
validate_citations.py - structural check for a citations_{surah}.json produced
by the tafsir-citer agent.

Checks
  - top level: surah (int), verses (object keyed by verse-number strings)
  - every verse / layer key is one of layer1..layer5
  - each citation has: id (1-based, sequential within the layer), anchor,
    source, status, and for verified/partial an url or locator
  - anchor is a VERBATIM substring of that layer's English text in
    Thaqalayn/Thaqalayn/Data/tafsir_{surah}.json (this is what lets the app
    place a superscript without touching the text)
  - status in {verified, partial, not_found, unchecked}
  - altafsir-hosted books never carry page/volume locators (the site shows
    none, so any "vol."/"p." there would be invented)
  - no transliteration diacritics in English fields (house style)

Usage
    python3 scripts/validate_citations.py new_citations/citations_1.json
Exit 0 = passed, 1 = errors printed.
"""
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DATA = os.path.join(ROOT, "Thaqalayn", "Thaqalayn", "Data")
LAYERS = {"layer1", "layer2", "layer3", "layer4", "layer5"}
STATUSES = {"verified", "partial", "not_found", "unchecked"}
ALTAFSIR_BOOKS = {"al-mizan", "majma al-bayan", "tafsir al-qummi", "al-tibyan", "jami al-bayan",
                  "al-kashshaf", "mafatih al-ghayb", "al-jami li-ahkam al-qur'an", "tafsir al-qur'an al-azim",
                  "ibn kathir", "tabari", "razi", "qurtubi", "zamakhshari"}
DIACRITICS = re.compile(r"[āīūḥṣḍṭẓʿʾĀĪŪḤṢḌṬẒ]")


def main(path: str) -> int:
    errors: list[str] = []
    with open(path, encoding="utf-8") as f:
        doc = json.load(f)

    surah = doc.get("surah")
    if not isinstance(surah, int):
        print("ERROR: top-level 'surah' must be an int")
        return 1
    with open(os.path.join(DATA, f"tafsir_{surah}.json"), encoding="utf-8") as f:
        tafsir = json.load(f)

    verses = doc.get("verses")
    if not isinstance(verses, dict) or not verses:
        print("ERROR: 'verses' must be a non-empty object")
        return 1

    n_cites = 0
    counts = {s: 0 for s in STATUSES}
    for v, layers in verses.items():
        entry = tafsir.get(v)
        if entry is None:
            errors.append(f"{surah}:{v} - verse not in tafsir_{surah}.json")
            continue
        if not isinstance(layers, dict):
            errors.append(f"{surah}:{v} - verse value must be an object of layers")
            continue
        for lk, layer in layers.items():
            if lk not in LAYERS:
                errors.append(f"{surah}:{v} - unknown layer key '{lk}'")
                continue
            text = entry.get(lk, "")
            cites = layer.get("citations", [])
            if not isinstance(cites, list):
                errors.append(f"{surah}:{v} {lk} - 'citations' must be a list")
                continue
            for i, c in enumerate(cites, start=1):
                where = f"{surah}:{v} {lk} #{c.get('id', '?')}"
                n_cites += 1
                if c.get("id") != i:
                    errors.append(f"{where} - ids must be sequential from 1 (got {c.get('id')} at position {i})")
                for req in ("anchor", "source", "status"):
                    if not c.get(req):
                        errors.append(f"{where} - missing '{req}'")
                anchor = c.get("anchor", "")
                if anchor and anchor not in text:
                    errors.append(f"{where} - anchor is not a verbatim substring of the layer text: {anchor[:70]!r}")
                if anchor and not (15 <= len(anchor) <= 200):
                    errors.append(f"{where} - anchor length {len(anchor)} outside 15..200")
                st = c.get("status")
                if st not in STATUSES:
                    errors.append(f"{where} - status {st!r} not in {sorted(STATUSES)}")
                else:
                    counts[st] += 1
                if st in ("verified", "partial") and not (c.get("url") or c.get("locator")):
                    errors.append(f"{where} - verified/partial needs a 'url' or 'locator'")
                src = (c.get("source") or "").lower()
                loc = (c.get("locator") or "")
                if any(b in src for b in ALTAFSIR_BOOKS) and "altafsir.com" in (c.get("url") or "") \
                        and re.search(r"\b(vol\.?|p\.|pp\.|page)\b", loc, flags=re.I):
                    errors.append(f"{where} - altafsir source carries a volume/page locator it cannot have: {loc!r}")
                for fld in ("anchor", "claim", "source", "author", "locator", "note"):
                    val = c.get(fld)
                    if isinstance(val, str) and DIACRITICS.search(val) and fld != "anchor":
                        errors.append(f"{where} - transliteration diacritics in '{fld}': {val[:60]!r}")
            if layer.get("issues"):
                errors.append(f"{surah}:{v} {lk} - 'issues' is retired; log each misattribution with "
                              f"scripts/log_misattribution.py add ... and drop the field")

    if errors:
        print("CITATION VALIDATION ERRORS")
        for e in errors:
            print(" -", e)
        print(f"\n{len(errors)} error(s).")
        return 1
    print(f"Citations validation passed: {len(verses)} verse(s), {n_cites} citation(s) "
          f"[verified {counts['verified']}, partial {counts['partial']}, not_found {counts['not_found']}, unchecked {counts['unchecked']}]")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
