#!/usr/bin/env python3
"""
Fetch the English Quran translation from the Al-Quran Cloud API and merge it
inline into quran_data.json as the `translation` field on every verse.

This is the English counterpart to scripts/fetch_quran_urdu.py. The app shipped
Sahih International (en.sahih, a Sunni translation) until 2026-09-01; it now
ships Ali Quli Qarai's phrase-by-phrase translation (en.qarai), the standard
modern Shia English rendering. Re-run this script to refresh or to switch
editions - the `translation` field is the single source of truth for every
English verse in the app (reader, Today verse, search, notifications, widgets,
journeys), so a merge here changes them all.

Default edition: en.qarai (Ali Quli Qarai, ICAS Press 2004).

Usage:
    python3 scripts/fetch_quran_english.py                       # merge into both quran_data.json copies
    python3 scripts/fetch_quran_english.py --edition en.shakir
    python3 scripts/fetch_quran_english.py --quran path/to/quran_data.json

Normalisation applied to the fetched text (documented so the diff is explainable):
  - whitespace is stripped at both ends;
  - the em dash is replaced by a spaced plain dash (house style: no em dashes);
  - two known glyph corruptions in the API's copy of Qarai are repaired
    (9:70 "Tham£d" -> "Thamud", 58:3 "³ih¡r" -> "zihar" - mangled diacritics).
Everything else (curly quotes, bracketed insertions, verse-initial lowercase from
the phrase-by-phrase design) is kept as published.

The merge is deterministic and idempotent: `translation` is overwritten in place,
all other content / key order is preserved. The script fails loudly (no
fallback) if the API verse set does not exactly match quran_data.json.
"""

import argparse
import json
import re
import sys
import urllib.request
from collections import OrderedDict
from pathlib import Path

API_BASE = "http://api.alquran.cloud/v1"
EXPECTED_SURAHS = 114
EXPECTED_VERSES = 6236
ROOT = Path(__file__).resolve().parent.parent
DEFAULT_TARGETS = [
    ROOT / "Thaqalayn" / "Thaqalayn" / "Data" / "quran_data.json",  # bundled by the app
    ROOT / "quran_data.json",                                       # repo-root mirror
]

# Per-edition text repairs: (surah, ayah) -> [(wrong, right), ...]
REPAIRS = {
    "en.qarai": {
        ("9", "70"): [("Tham£d", "Thamud")],
        ("58", "3"): [("³ih¡r", "zihar")],
    },
}


def fail(message: str):
    print(f"❌ {message}", file=sys.stderr)
    sys.exit(1)


def normalise(text: str) -> str:
    text = text.strip()
    text = re.sub(r"\s*—\s*", " - ", text)   # em dash -> spaced plain dash
    text = re.sub(r"[ \t]{2,}", " ", text)
    return text


def fetch_edition(edition: str) -> "OrderedDict[str, OrderedDict[str, str]]":
    """Fetch a full-Quran edition and return {surah: {ayah: text}} (string keys)."""
    url = f"{API_BASE}/quran/{edition}"
    print(f"→ Fetching English edition '{edition}' from {url} ...")
    req = urllib.request.Request(url, headers={"User-Agent": "thaqalayn-quran-english/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        payload = json.load(resp)

    if payload.get("code") != 200 or "data" not in payload:
        fail(f"Unexpected API response for '{edition}': code={payload.get('code')}")

    edition_meta = payload["data"].get("edition", {})
    print(f"  edition: {edition_meta.get('englishName')} "
          f"({edition_meta.get('name')}) - language={edition_meta.get('language')}")
    if edition_meta.get("language") != "en":
        fail(f"Edition '{edition}' is not an English edition (language={edition_meta.get('language')})")

    repairs = REPAIRS.get(edition, {})
    applied = 0
    result: "OrderedDict[str, OrderedDict[str, str]]" = OrderedDict()
    total = 0
    for surah in payload["data"]["surahs"]:
        s_key = str(surah["number"])
        ayah_map: "OrderedDict[str, str]" = OrderedDict()
        for ayah in surah["ayahs"]:
            a_key = str(ayah["numberInSurah"])
            text = normalise(ayah["text"])
            for wrong, right in repairs.get((s_key, a_key), []):
                if wrong not in text:
                    fail(f"Expected repair target {wrong!r} not found in {s_key}:{a_key}; API text changed?")
                text = text.replace(wrong, right)
                applied += 1
            if not text:
                fail(f"Empty translation for {s_key}:{a_key}")
            ayah_map[a_key] = text
            total += 1
        result[s_key] = ayah_map

    print(f"  fetched {len(result)} surahs, {total} ayahs; repairs applied: {applied}")
    if len(result) != EXPECTED_SURAHS or total != EXPECTED_VERSES:
        fail(f"Verse count mismatch: got {len(result)} surahs / {total} ayahs, "
             f"expected {EXPECTED_SURAHS} / {EXPECTED_VERSES}")
    leftovers = [(s, a, ch) for s in result for a in result[s] for ch in "£³¡" if ch in result[s][a]]
    if leftovers:
        fail(f"Corrupt glyphs remain after repairs: {leftovers[:5]}")
    return result


def merge_into(quran_path: Path, english: "OrderedDict[str, OrderedDict[str, str]]") -> int:
    """Overwrite `translation` in place in quran_path. Returns count merged."""
    if not quran_path.exists():
        fail(f"Quran data file not found: {quran_path}")

    with open(quran_path, encoding="utf-8") as f:
        quran = json.load(f, object_pairs_hook=OrderedDict)

    verses = quran.get("verses")
    if not isinstance(verses, dict):
        fail(f"{quran_path.name}: missing 'verses' object")

    # Strict key-set equality: every verse must get exactly one translation.
    for s_key, surah_verses in verses.items():
        if s_key not in english:
            fail(f"Surah {s_key} missing from fetched edition")
        for v_key in surah_verses:
            if v_key not in english[s_key]:
                fail(f"Verse {s_key}:{v_key} missing from fetched edition")
    for s_key, ayah_map in english.items():
        if s_key not in verses:
            fail(f"Surah {s_key} present in edition but absent from {quran_path.name}")
        for v_key in ayah_map:
            if v_key not in verses[s_key]:
                fail(f"Verse {s_key}:{v_key} present in edition but absent from {quran_path.name}")

    merged = 0
    changed = 0
    for s_key, surah_verses in verses.items():
        for v_key, verse_obj in surah_verses.items():
            if "translation" not in verse_obj:
                fail(f"Verse {s_key}:{v_key} has no 'translation' field")
            new = english[s_key][v_key]
            if verse_obj["translation"] != new:
                changed += 1
            verse_obj["translation"] = new  # in place: key order untouched
            merged += 1

    text = json.dumps(quran, ensure_ascii=False, indent=2)
    if not text.endswith("\n"):
        text += "\n"
    json.loads(text)  # round-trip sanity check before writing

    with open(quran_path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"✅ Merged {merged} English translations into {quran_path} ({changed} changed)")
    return merged


def main():
    parser = argparse.ArgumentParser(description="Fetch + merge the English Quran translation inline")
    parser.add_argument("--edition", default="en.qarai", help="Al-Quran Cloud English edition identifier")
    parser.add_argument("--quran", action="append", default=None,
                        help="Target quran_data.json path (repeatable). "
                             "Default: the bundled copy and the repo-root mirror")
    args = parser.parse_args()

    targets = [Path(p) for p in args.quran] if args.quran else DEFAULT_TARGETS
    english = fetch_edition(args.edition)
    for target in targets:
        merge_into(target, english)

    for ref in ("1:1", "5:6", "5:55", "9:70", "58:3"):
        s, a = ref.split(":")
        print(f"  {ref} → {english[s][a][:110]}")
    print("Done.")


if __name__ == "__main__":
    main()
