#!/usr/bin/env python3
"""Emit authoring-batch input files for widget reflections.

Reads (all existing, never modified):
  Thaqalayn/Data/daily_verses.json           - the 365 + 19 pool
  Thaqalayn/Thaqalayn/Data/quran_data.json   - Arabic + translation
  Thaqalayn/Thaqalayn/Data/tafsir_<n>.json   - quickOverview gems
  Thaqalayn/Services/SurahExperienceCatalog.swift - journey catalog
  Thaqalayn/Services/DeepDiveCatalog.swift        - dive catalog (available only)
  Thaqalayn/Content/*.swift                  - journey content-file lookup
  Thaqalayn/Data/widget_reflections.json     - coverage check (--missing-only)

Writes:
  scratch/reflection_batches/input_batch_NN.json - batch-size verses, full context
  scratch/reflection_batches/input_journeys.json - id/kind/name/content file

Usage: python3 scripts/make_reflection_batches.py [--batch-size 24] [--missing-only]

--missing-only: emit ONLY pool verses / catalog journeys not yet covered by
Thaqalayn/Data/widget_reflections.json. This is the DELTA WORKFLOW for new
content: when a new journey/dive/verse lands, run this, author the one small
batch, merge, and the strict build gate goes green again.
"""
import argparse, json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_widget_daily as gwd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "Thaqalayn" / "Data"
TAFSIR_DIR = ROOT / "Thaqalayn" / "Thaqalayn" / "Data"
CONTENT_DIR = ROOT / "Thaqalayn" / "Content"
STAGING = ROOT / "scratch" / "reflection_batches"
REFLECTIONS = DATA / "widget_reflections.json"

VERSE_OUTPUT_SHAPE = {"verses": {"<key>": {
    "morning": {"en": "<= 110 chars"},
    "gems": [{"en": "<= 100 chars, one per input gem, same order"}],
    "night": {"en": "<= 110 chars"}}}}
JOURNEY_OUTPUT_SHAPE = {"journeys": {"<id>": {"lines": [
    {"en": "<= 90 chars", "source": "<= 48 chars, or null for takeaway lines"}]}}}


def load_catalog():
    """Ordered [(ident, kind, name)]: experiences by surah, then dives by id.

    Mirrors generate_widget_daily.py - experiences need a surahNumber, dives
    must be available (coming-soon dives are never widget content)."""
    experiences = gwd.extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "SurahExperienceCatalog.swift", True)
    dives = gwd.extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift", False)
    dive_src = (ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift"
                ).read_text(encoding="utf-8")
    availability = dict(re.findall(
        r'id:\s*"([^"]+)"(?:(?!id:\s*").)*?available:\s*(true|false)',
        dive_src, re.DOTALL))
    out = [(k, "experience", v["title"]) for k, v in
           sorted(experiences.items(), key=lambda kv: kv[1]["surah"] or 0)
           if v["surah"]]
    out += [(k, "deepDive", dives[k]["title"]) for k in sorted(dives)
            if availability.get(k, "true") == "true"]
    return out


def content_files_by_id():
    """id -> Content/*.swift path (repo-relative), for every id: "..." literal."""
    found = {}
    id_re = re.compile(r'id:\s*"([^"]+)"')
    for path in sorted(CONTENT_DIR.glob("*.swift")):
        for ident in id_re.findall(path.read_text(encoding="utf-8")):
            found.setdefault(ident, str(path.relative_to(ROOT)))
    return found


def pool_records():
    """Unique pool verses, full authoring context, sorted by (surah, verse)."""
    pool = gwd.load(DATA / "daily_verses.json")
    quran = gwd.load(TAFSIR_DIR / "quran_data.json")["verses"]
    tafsir_cache, records, errors = {}, {}, []
    for e in pool["verses"] + pool["sacredDays"]:
        s, v = e["surah"], e["verse"]
        key = f"{s}:{v}"
        if key in records:
            continue
        if s not in tafsir_cache:
            tafsir_cache[s] = gwd.load(TAFSIR_DIR / f"tafsir_{s}.json")
        verse_text = quran.get(str(s), {}).get(str(v))
        concepts = (tafsir_cache[s].get(str(v)) or {}).get(
            "quickOverview", {}).get("concepts") or []
        if not verse_text:
            errors.append(f"{key}: no verse text"); continue
        if not concepts:
            errors.append(f"{key}: no gems"); continue
        rec = {"key": key,
               "arabic": verse_text["arabicText"].lstrip("﻿"),
               "translation": verse_text["translation"],
               "themeEn": e["themeEn"],
               "gems": [{"title": c["title"], "insight": c["coreInsight"]}
                        for c in concepts]}
        if e.get("themeKey"):
            rec["themeKey"] = e["themeKey"]
        if e.get("occasionEn"):
            rec["occasionEn"] = e["occasionEn"]
        records[key] = rec
    if errors:
        print("POOL LOAD FAILED:\n" + "\n".join(errors)); sys.exit(1)
    return sorted(records.values(),
                  key=lambda r: tuple(int(p) for p in r["key"].split(":")))


def coverage():
    """(verses, journeys) dicts from widget_reflections.json, {} if absent."""
    if not REFLECTIONS.exists():
        return {}, {}
    r = gwd.load(REFLECTIONS)
    return r.get("verses") or {}, r.get("journeys") or {}


def verse_covered(entry, gem_count):
    return (isinstance(entry, dict)
            and (entry.get("morning") or {}).get("en")
            and (entry.get("night") or {}).get("en")
            and len(entry.get("gems") or []) == gem_count)


def journey_covered(entry):
    return isinstance(entry, dict) and len(entry.get("lines") or []) >= 2


def write_json(path, obj):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=1, sort_keys=True)
        f.write("\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--batch-size", type=int, default=24)
    ap.add_argument("--missing-only", action="store_true")
    args = ap.parse_args()

    records = pool_records()
    catalog = load_catalog()
    if args.missing_only:
        done_verses, done_journeys = coverage()
        records = [r for r in records if not verse_covered(
            done_verses.get(r["key"]), len(r["gems"]))]
        catalog = [(i, k, n) for i, k, n in catalog
                   if not journey_covered(done_journeys.get(i))]

    STAGING.mkdir(parents=True, exist_ok=True)
    for stale in list(STAGING.glob("input_batch_*.json")) + [
            STAGING / "input_journeys.json"]:
        stale.unlink(missing_ok=True)

    batches = [records[i:i + args.batch_size]
               for i in range(0, len(records), args.batch_size)]
    for n, batch in enumerate(batches, 1):
        write_json(STAGING / f"input_batch_{n:02d}.json",
                   {"output_file": f"out_batch_{n:02d}.json",
                    "output_shape": VERSE_OUTPUT_SHAPE,
                    "verses": batch})

    files = content_files_by_id()
    journeys, missing_files = [], []
    for ident, kind, name in catalog:
        path = files.get(ident)
        if path is None:
            missing_files.append(ident)
        journeys.append({"id": ident, "kind": kind, "name": name, "file": path})
    if journeys:
        write_json(STAGING / "input_journeys.json",
                   {"output_file": "out_journeys.json",
                    "output_shape": JOURNEY_OUTPUT_SHAPE,
                    "journeys": journeys})

    for ident in missing_files:
        print(f"WARNING: no Thaqalayn/Content/*.swift file found for "
              f"journey '{ident}' (file: null in input_journeys.json)")
    print(f"OK: {len(batches)} verse batches ({len(records)} verses), "
          f"{len(journeys)} journeys -> {STAGING.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
