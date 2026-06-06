#!/usr/bin/env python3
"""
Fetch an authentic Urdu Quran translation from the Al-Quran Cloud API and merge
it inline into quran_data.json as a `translationUrdu` field on every verse.

This is the Urdu counterpart to scripts/fetch_quran_data.py, which originally
built quran_data.json from the same API (Arabic = quran-uthmani, English =
en.sahih). Because the Urdu edition is served by the same API with the identical
surah / numberInSurah keys, this is a direct fetch-and-merge — no machine
translation of the English is involved.

Default edition: ur.jawadi (Allama Syed Zeeshan Haider Jawadi), the standard
Shia Urdu translation. The other Shia option on this API is ur.najafi.

Usage:
    python3 scripts/fetch_quran_urdu.py                      # merge into quran_data.json
    python3 scripts/fetch_quran_urdu.py --edition ur.najafi
    python3 scripts/fetch_quran_urdu.py --quran path/to/quran_data.json

The merge is deterministic and idempotent: `translationUrdu` is placed
immediately after `translation`, existing values are overwritten, and all other
content / key order is preserved. The script fails loudly (no fallback) if the
API verse set does not exactly match quran_data.json.
"""

import argparse
import json
import sys
import urllib.request
from collections import OrderedDict
from pathlib import Path

API_BASE = "http://api.alquran.cloud/v1"
EXPECTED_SURAHS = 114
EXPECTED_VERSES = 6236


def fail(message: str):
    print(f"❌ {message}", file=sys.stderr)
    sys.exit(1)


def fetch_edition(edition: str) -> "OrderedDict[str, OrderedDict[str, str]]":
    """Fetch a full-Quran edition and return {surah: {ayah: text}} (string keys)."""
    url = f"{API_BASE}/quran/{edition}"
    print(f"→ Fetching Urdu edition '{edition}' from {url} ...")
    req = urllib.request.Request(url, headers={"User-Agent": "thaqalayn-quran-urdu/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        payload = json.load(resp)

    if payload.get("code") != 200 or "data" not in payload:
        fail(f"Unexpected API response for '{edition}': code={payload.get('code')}")

    edition_meta = payload["data"].get("edition", {})
    print(f"  edition: {edition_meta.get('englishName')} "
          f"({edition_meta.get('name')}) — language={edition_meta.get('language')}")
    if edition_meta.get("language") != "ur":
        fail(f"Edition '{edition}' is not an Urdu edition (language={edition_meta.get('language')})")

    surahs = payload["data"]["surahs"]
    result: "OrderedDict[str, OrderedDict[str, str]]" = OrderedDict()
    total = 0
    for surah in surahs:
        s_key = str(surah["number"])
        ayah_map: "OrderedDict[str, str]" = OrderedDict()
        for ayah in surah["ayahs"]:
            ayah_map[str(ayah["numberInSurah"])] = ayah["text"].strip()
            total += 1
        result[s_key] = ayah_map

    print(f"  fetched {len(result)} surahs, {total} ayahs")
    if len(result) != EXPECTED_SURAHS or total != EXPECTED_VERSES:
        fail(f"Verse count mismatch: got {len(result)} surahs / {total} ayahs, "
             f"expected {EXPECTED_SURAHS} / {EXPECTED_VERSES}")
    return result


def merge_into(quran_path: Path, urdu: "OrderedDict[str, OrderedDict[str, str]]") -> int:
    """Inject translationUrdu inline into quran_path. Returns count merged."""
    if not quran_path.exists():
        fail(f"Quran data file not found: {quran_path}")

    with open(quran_path, encoding="utf-8") as f:
        quran = json.load(f, object_pairs_hook=OrderedDict)

    verses = quran.get("verses")
    if not isinstance(verses, dict):
        fail(f"{quran_path.name}: missing 'verses' object")

    # Strict key-set equality: every verse must get exactly one translation.
    for s_key, surah_verses in verses.items():
        if s_key not in urdu:
            fail(f"Surah {s_key} missing from fetched edition")
        for v_key in surah_verses:
            if v_key not in urdu[s_key]:
                fail(f"Verse {s_key}:{v_key} missing from fetched edition")
    for s_key, ayah_map in urdu.items():
        if s_key not in verses:
            fail(f"Surah {s_key} present in edition but absent from {quran_path.name}")
        for v_key in ayah_map:
            if v_key not in verses[s_key]:
                fail(f"Verse {s_key}:{v_key} present in edition but absent from {quran_path.name}")

    merged = 0
    for s_key, surah_verses in verses.items():
        for v_key, verse_obj in surah_verses.items():
            if "translation" not in verse_obj:
                fail(f"Verse {s_key}:{v_key} has no 'translation' field to anchor to")
            rebuilt = OrderedDict()
            for k, v in verse_obj.items():
                if k == "translationUrdu":
                    continue  # drop stale copy; reinserted in canonical position
                rebuilt[k] = v
                if k == "translation":
                    rebuilt["translationUrdu"] = urdu[s_key][v_key]
            surah_verses[v_key] = rebuilt
            merged += 1

    text = json.dumps(quran, ensure_ascii=False, indent=2)
    if not text.endswith("\n"):
        text += "\n"
    json.loads(text)  # round-trip sanity check before writing

    with open(quran_path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"✅ Merged {merged} Urdu translations into {quran_path}")
    return merged


def main():
    parser = argparse.ArgumentParser(description="Fetch + merge Urdu Quran translation inline")
    parser.add_argument("--edition", default="ur.jawadi", help="Al-Quran Cloud Urdu edition identifier")
    parser.add_argument("--quran", action="append", default=None,
                        help="Target quran_data.json path (repeatable). Default: quran_data.json")
    args = parser.parse_args()

    targets = [Path(p) for p in (args.quran or ["quran_data.json"])]
    urdu = fetch_edition(args.edition)
    for target in targets:
        merge_into(target, urdu)

    # Spot check
    sample = urdu["1"]["1"]
    print(f"\nSample 1:1 → {sample}")
    print("Done.")


if __name__ == "__main__":
    main()
