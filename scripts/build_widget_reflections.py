#!/usr/bin/env python3
"""Merge staged widget-reflection batches into the authored source of truth.

Reads:
  scratch/reflection_batches/out_batch_*.json    - staged verse reflections
  scratch/reflection_batches/out_journeys*.json  - staged journey essence lines
  Thaqalayn/Data/widget_reflections.json         - existing merged content
  Thaqalayn/Data/daily_verses.json               - valid pool keys
  Thaqalayn/Thaqalayn/Data/tafsir_<n>.json       - gem counts per verse
  Thaqalayn/Services/*Catalog.swift              - valid journey ids

Writes:
  Thaqalayn/Data/widget_reflections.json - merged (staging wins on collision),
  sorted keys; written ONLY when validation passes.

Usage: python3 scripts/build_widget_reflections.py [--require-full]

Fails loudly (non-zero exit) printing EVERY violation: unknown keys/ids,
gem-count mismatch, char caps (morning/night 110, gem 100, essence 90,
source 48), journeys without 2-3 lines, forbidden characters (em dash,
transliteration diacritics, ayn/hamza half-rings). Death language
("dying"/"died"/"passed away") is WARN-only, never a failure.
--require-full additionally fails unless EVERY pool verse and EVERY
available catalog journey is covered, listing each missing one.
"""
import argparse, json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_widget_daily as gwd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "Thaqalayn" / "Data"
TAFSIR_DIR = ROOT / "Thaqalayn" / "Thaqalayn" / "Data"
STAGING = ROOT / "scratch" / "reflection_batches"
REFLECTIONS = DATA / "widget_reflections.json"

CAP_MORNING_NIGHT, CAP_GEM, CAP_ESSENCE, CAP_SOURCE = 110, 100, 90, 48
# Em dash; a i u h s d t z with macron/under-dot (lower + upper); ayn U+02BF,
# hamza U+02BE (escaped so this file never carries the banned glyphs itself).
FORBIDDEN = ("\u2014"                                        # em dash
             "\u0101\u012b\u016b\u1e25\u1e63\u1e0d\u1e6d\u1e93"  # a i u h s d t z
             "\u0100\u012a\u016a\u1e24\u1e62\u1e0c\u1e6c\u1e92"  # uppercase
             "\u02bf\u02be")                                 # ayn, hamza
DEATH_RE = re.compile(r"\b(dying|died|passed away)\b", re.IGNORECASE)


def pool_gem_counts():
    """Unique pool key -> tafsir quickOverview concepts count."""
    pool = gwd.load(DATA / "daily_verses.json")
    tafsir_cache, counts = {}, {}
    for e in pool["verses"] + pool["sacredDays"]:
        s, v = e["surah"], e["verse"]
        key = f"{s}:{v}"
        if key in counts:
            continue
        if s not in tafsir_cache:
            tafsir_cache[s] = gwd.load(TAFSIR_DIR / f"tafsir_{s}.json")
        counts[key] = len((tafsir_cache[s].get(str(v)) or {}).get(
            "quickOverview", {}).get("concepts") or [])
    return counts


def catalog_ids():
    """Available journey/dive ids (experiences with a surah + available dives)."""
    experiences = gwd.extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "SurahExperienceCatalog.swift", True)
    dives = gwd.extract_catalog(
        ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift", False)
    dive_src = (ROOT / "Thaqalayn" / "Services" / "DeepDiveCatalog.swift"
                ).read_text(encoding="utf-8")
    availability = dict(re.findall(
        r'id:\s*"([^"]+)"(?:(?!id:\s*").)*?available:\s*(true|false)',
        dive_src, re.DOTALL))
    return ({k for k, v in experiences.items() if v["surah"]}
            | {k for k in dives if availability.get(k, "true") == "true"})


def scan_strings(node, ctx, violations, warnings):
    """Forbidden-character check on every string; death-language WARN."""
    if isinstance(node, str):
        for ch in node:
            if ch in FORBIDDEN:
                violations.append(
                    f"{ctx}: forbidden char '{ch}' (U+{ord(ch):04X})")
        m = DEATH_RE.search(node)
        if m:
            warnings.append(f'{ctx}: death language "{m.group(0)}" '
                            f"- review respectful-language rule")
    elif isinstance(node, dict):
        for k, v in node.items():
            scan_strings(v, f"{ctx}.{k}", violations, warnings)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            scan_strings(v, f"{ctx}[{i}]", violations, warnings)


def check_text(obj, ctx, cap, violations):
    """{"en": ...} object: en required non-empty string, capped."""
    if not isinstance(obj, dict) or not isinstance(obj.get("en"), str) \
            or not obj.get("en"):
        violations.append(f'{ctx}: expected {{"en": "<text>"}}')
        return
    if len(obj["en"]) > cap:
        violations.append(f"{ctx}: {len(obj['en'])} chars (cap {cap}): "
                          f"{obj['en'][:60]}...")


def validate(verses, journeys, gem_counts, cat_ids):
    violations, warnings = [], []
    for key, entry in verses.items():
        ctx = f"verse {key}"
        if key not in gem_counts:
            violations.append(f"{ctx}: not in the daily-verse pool")
        if not isinstance(entry, dict):
            violations.append(f"{ctx}: entry is not an object"); continue
        for extra in sorted(set(entry) - {"morning", "gems", "night"}):
            violations.append(f"{ctx}: unexpected field '{extra}'")
        check_text(entry.get("morning"), f"{ctx}.morning",
                   CAP_MORNING_NIGHT, violations)
        check_text(entry.get("night"), f"{ctx}.night",
                   CAP_MORNING_NIGHT, violations)
        gems = entry.get("gems")
        if not isinstance(gems, list):
            violations.append(f"{ctx}.gems: expected an array")
        else:
            expected = gem_counts.get(key)
            if expected is not None and len(gems) != expected:
                violations.append(f"{ctx}.gems: {len(gems)} lines but tafsir "
                                  f"has {expected} concepts")
            for i, gem in enumerate(gems):
                check_text(gem, f"{ctx}.gems[{i}]", CAP_GEM, violations)
        scan_strings(entry, ctx, violations, warnings)

    for ident, entry in journeys.items():
        ctx = f"journey {ident}"
        if ident not in cat_ids:
            violations.append(f"{ctx}: not an available catalog journey/dive")
        if not isinstance(entry, dict):
            violations.append(f"{ctx}: entry is not an object"); continue
        for extra in sorted(set(entry) - {"lines"}):
            violations.append(f"{ctx}: unexpected field '{extra}'")
        lines = entry.get("lines")
        if not isinstance(lines, list) or not 2 <= len(lines) <= 3:
            n = len(lines) if isinstance(lines, list) else "none"
            violations.append(f"{ctx}: needs 2-3 lines, has {n}")
            lines = lines if isinstance(lines, list) else []
        for i, line in enumerate(lines):
            check_text(line, f"{ctx}.lines[{i}]", CAP_ESSENCE, violations)
            src = line.get("source") if isinstance(line, dict) else None
            if src is not None:
                if not isinstance(src, str):
                    violations.append(
                        f"{ctx}.lines[{i}].source: expected string or null")
                elif len(src) > CAP_SOURCE:
                    violations.append(f"{ctx}.lines[{i}].source: {len(src)} "
                                      f"chars (cap {CAP_SOURCE}): {src}")
        scan_strings(entry, ctx, violations, warnings)
    return violations, warnings


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--require-full", action="store_true")
    args = ap.parse_args()

    base = (gwd.load(REFLECTIONS) if REFLECTIONS.exists()
            else {"version": 1, "verses": {}, "journeys": {}})
    verses = dict(base.get("verses") or {})
    journeys = dict(base.get("journeys") or {})

    staged_v, staged_j = set(), set()
    staged_files = sorted(STAGING.glob("out_batch_*.json")) \
        + sorted(STAGING.glob("out_journeys*.json"))
    for path in staged_files:
        staged = gwd.load(path)
        for key, entry in (staged.get("verses") or {}).items():
            verses[key] = entry; staged_v.add(key)
        for ident, entry in (staged.get("journeys") or {}).items():
            journeys[ident] = entry; staged_j.add(ident)

    gem_counts = pool_gem_counts()
    cat_ids = catalog_ids()
    violations, warnings = validate(verses, journeys, gem_counts, cat_ids)

    missing = []
    if args.require_full:
        missing = [f"MISSING verse {k}" for k in sorted(
                       set(gem_counts) - set(verses),
                       key=lambda k: tuple(int(p) for p in k.split(":")))] \
                + [f"MISSING journey {i}" for i in sorted(cat_ids - set(journeys))]

    for w in warnings:
        print(f"WARN {w}")
    if violations:
        print(f"VALIDATION FAILED ({len(violations)} violations):")
        for v in violations:
            print(f"  {v}")
    if missing:
        print(f"COVERAGE INCOMPLETE ({len(missing)} missing):")
        for m in missing:
            print(f"  {m}")
    if violations or missing:
        sys.exit(1)

    with open(REFLECTIONS, "w", encoding="utf-8") as f:
        json.dump({"version": 1, "verses": verses, "journeys": journeys},
                  f, ensure_ascii=False, indent=1, sort_keys=True)
        f.write("\n")
    print(f"OK: {len(staged_v)} verses, {len(staged_j)} journeys merged "
          f"(file total: {len(verses)} verses, {len(journeys)} journeys)")


if __name__ == "__main__":
    main()
