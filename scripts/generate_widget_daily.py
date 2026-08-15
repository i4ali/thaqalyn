#!/usr/bin/env python3
"""Hydrate the daily-verse pool into widget_daily.json for the widget target.

Reads (all existing, never modified):
  Thaqalayn/Data/daily_verses.json           - the 365 + 19 pool
  Thaqalayn/Thaqalayn/Data/quran_data.json   - Arabic + translation
  Thaqalayn/Thaqalayn/Data/tafsir_<n>.json   - quickOverview gems
  Thaqalayn/Data/widget_reflections.json     - authored reflections + essence lines
  Thaqalayn/Services/SurahExperienceCatalog.swift - doorway names (regex extract)
  Thaqalayn/Services/DeepDiveCatalog.swift        - doorway names (regex extract)

Writes:
  Thaqalayn/Data/widget_daily.json - keyed "surah:verse", one object per pool verse.

Fails loudly (non-zero exit) if any pool verse lacks text or gems. Missing
reflections only WARN by default (the Xcode build phase runs this on every
build, mid-authoring included); pass --require-full to fail on any gap.
"""
import argparse, json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "Thaqalayn" / "Data"
TAFSIR_DIR = ROOT / "Thaqalayn" / "Thaqalayn" / "Data"

# themeKey -> deep dive id, for doorway evenings on theme-matched days.
# Only map where the pairing is obvious; unmapped themes simply have no dive doorway.
# Pool themeKeys are English (patience, trust, ...), dive ids are Arabic (sabr, ...).
THEME_TO_DIVE = {
    "patience": "sabr", "gratitude": "shukr",
    "trust": "tawakkul", "prayer": "salah",
}

def load(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)


def journey_lines(reflections, ident):
    """Authored essence lines for a journey/dive id, [] until authored."""
    lines = reflections.get("journeys", {}).get(ident, {}).get("lines") or []
    return [{"text": l["en"], "source": l.get("source")} for l in lines]

def extract_catalog(path, needs_surah):
    """Regex-extract (id, surahNumber?, title-en, subtitle-en) from a Swift catalog
    file. Swift string literals in these files use straight quotes; the copy inside
    may use curly quotes, which the regex tolerates because it only anchors on the
    straight delimiters."""
    src = Path(path).read_text(encoding="utf-8")
    out = {}
    # Each descriptor: id: "x" ... [surahNumber: N ...] title: LocalizedText(en: "..."
    # ... subtitle: LocalizedText(en: "..."
    pattern = re.compile(
        r'id:\s*"([^"]+)"(?:(?!id:\s*").)*?'
        + (r'surahNumber:\s*(\d+)(?:(?!id:\s*").)*?' if needs_surah else r'()')
        + r'title:\s*LocalizedText\(\s*en:\s*"((?:[^"\\]|\\.)*)"(?:(?!id:\s*").)*?'
        + r'subtitle:\s*LocalizedText\(\s*en:\s*"((?:[^"\\]|\\.)*)"',
        re.DOTALL,
    )
    for m in pattern.finditer(src):
        ident, surah, title, subtitle = m.group(1), m.group(2), m.group(3), m.group(4)
        out[ident] = {"surah": int(surah) if surah else None,
                      "title": title.replace('\\"', '"'),
                      "subtitle": subtitle.replace('\\"', '"')}
    return out

def main():
    ap = argparse.ArgumentParser(description="Hydrate widget_daily.json")
    ap.add_argument("--require-full", action="store_true",
                    help="fail if any verse lacks reflections or any journey "
                         "lacks essence lines (build gate flips this on once "
                         "authoring is complete)")
    args = ap.parse_args()

    pool = load(DATA / "daily_verses.json")
    reflections = load(DATA / "widget_reflections.json")
    quran_data = load(TAFSIR_DIR / "quran_data.json")
    quran = quran_data["verses"]
    surah_names = {s["number"]: s["englishName"] for s in quran_data["surahs"]}
    entries = pool["verses"] + pool["sacredDays"]

    experiences = extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "SurahExperienceCatalog.swift", True)
    dives = extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift", False)

    # Drop coming-soon dives (available: false) - the widget must never promote
    # a journey the app can't open yet.
    dive_src = (ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift").read_text(encoding="utf-8")
    availability = dict(re.findall(
        r'id:\s*"([^"]+)"(?:(?!id:\s*").)*?available:\s*(true|false)', dive_src, re.DOTALL))
    dives = {k: v for k, v in dives.items() if availability.get(k, "true") == "true"}

    surah_to_exp = {v["surah"]: (k, v["title"])
                    for k, v in experiences.items() if v["surah"]}

    assert len(surah_to_exp) >= 18, f"expected >=18 experiences, got {len(surah_to_exp)}"
    assert len(dives) >= 8, f"expected >=8 deep dives, got {len(dives)}"

    tafsir_cache, out, errors = {}, {}, []
    for e in entries:
        s, v = e["surah"], e["verse"]
        key = f"{s}:{v}"
        if key in out:
            continue
        if s not in tafsir_cache:
            tafsir_cache[s] = load(TAFSIR_DIR / f"tafsir_{s}.json")
        verse_text = quran.get(str(s), {}).get(str(v))
        tv = tafsir_cache[s].get(str(v))
        qo = (tv or {}).get("quickOverview", {})
        concepts = qo.get("concepts") or []
        if not verse_text:
            errors.append(f"{key}: no verse text"); continue
        if not concepts:
            errors.append(f"{key}: no gems"); continue

        doorway = None
        if s in surah_to_exp:
            exp_id, title = surah_to_exp[s]
            doorway = {"kind": "experience", "id": exp_id, "name": title,
                       "lines": journey_lines(reflections, exp_id)}
        elif e.get("themeKey") in THEME_TO_DIVE:
            dive_id = THEME_TO_DIVE[e["themeKey"]]
            if dive_id in dives:
                doorway = {"kind": "deepDive", "id": dive_id,
                           "name": dives[dive_id]["title"],
                           "lines": journey_lines(reflections, dive_id)}

        gems = [{
            "title": c["title"],
            "insight": c["coreInsight"],
            "icon": c.get("icon", "sparkles"),
            "colorHex": c.get("colorHex", "#CFA96A"),
        } for c in concepts]
        entry = {
            "surah": s, "verse": v,
            "englishName": surah_names[s],
            "arabic": verse_text["arabicText"].lstrip("﻿"),
            "translation": verse_text["translation"],
            "gems": gems,
            "doorway": doorway,
        }
        # Authored reflections: morning/night lines + one line per gem.
        # A verse without an entry simply omits the keys (views fall back).
        refl = reflections.get("verses", {}).get(key)
        if refl:
            morning = (refl.get("morning") or {}).get("en")
            night = (refl.get("night") or {}).get("en")
            if morning:
                entry["morning"] = morning
            if night:
                entry["night"] = night
            for gem, line in zip(gems, refl.get("gems") or []):
                gem["line"] = line["en"]
        out[key] = entry

    if errors:
        print("HYDRATION FAILED:\n" + "\n".join(errors)); sys.exit(1)

    # The rotation catalog: every experience and dive, interleaved 2:1
    # (18 experiences : 9 dives) so consecutive days vary in kind. The widget
    # picks catalog[dayIndex % len] on days whose verse has no linked doorway.
    exp_ordered = sorted(
        ({"kind": "experience", "id": k, "name": v["title"],
          "lines": journey_lines(reflections, k), "surah": v["surah"]}
         for k, v in experiences.items() if v["surah"]),
        key=lambda x: x["surah"])
    for entry_ in exp_ordered:
        entry_.pop("surah")
    dive_ordered = [{"kind": "deepDive", "id": k, "name": dives[k]["title"],
                     "lines": journey_lines(reflections, k)} for k in sorted(dives)]
    catalog = []
    di = iter(dive_ordered)
    for i, exp in enumerate(exp_ordered, 1):
        catalog.append(exp)
        if i % 2 == 0:
            nxt = next(di, None)
            if nxt:
                catalog.append(nxt)
    catalog.extend(di)

    # Reflection coverage. Lenient by default: the widget build phase runs
    # this script on every build and must keep passing mid-authoring.
    missing_verses = [k for k in sorted(
        out, key=lambda k: (out[k]["surah"], out[k]["verse"]))
        if k not in reflections.get("verses", {})]
    missing_journeys = [c["id"] for c in catalog if len(c["lines"]) < 2]
    if args.require_full and (missing_verses or missing_journeys):
        print("COVERAGE INCOMPLETE:")
        for k in missing_verses:
            print(f"  verse without reflections: {k}")
        for ident in missing_journeys:
            print(f"  journey without lines: {ident}")
        sys.exit(1)

    result = {"version": 2, "verses": out, "catalog": catalog}
    with open(DATA / "widget_daily.json", "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=1)
    doorways = sum(1 for x in out.values() if x["doorway"])
    print(f"OK: {len(out)} verses hydrated, {doorways} with doorways, catalog {len(catalog)}")
    print(f"partial: {len(missing_verses)} verses without reflections, "
          f"{len(missing_journeys)} journeys without lines")

if __name__ == "__main__":
    main()
