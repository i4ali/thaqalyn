#!/usr/bin/env python3
"""Urdu narration for the journeys (Deep Dives and Surah journeys) - the text side.

The app narrates Urdu by swapping every English narrator line of a journey's timeline for
its Urdu (JourneyNarrationTranslation.swift), from one bundled file per journey:

  Thaqalayn/Data/JourneyUrdu/journey_ur_<id>.json   {"id", "lines": [{"en", "ur"}]}

This script builds the translators' worklists from the app's real timeline, checks a
translation, and installs it. Rendering the audio is build_journey_audio.py --lang ur.

  worklist [id ...]   write journey_urdu_work/<id>/source.json for every narrated journey
                      (or the ones named): each distinct English line in timeline order,
                      with its beat, its role, and for a verse's meaning the app's Urdu
                      Quran translation of that verse to start from. Runs the simulator dump.
  check <id>          validate journey_urdu_work/<id>/ur.json against source.json; writes
                      nothing. Translators and reviewers run this until it prints PASS.
  apply <id> [...]    check, then write the app file for each journey.
  status              per journey: lines, translated, applied (no simulator run).

The shared connectors ("The Qur'an says:", "which means:", the outro) are translated once
in JourneyNarrationTranslation.swift, so they are left out of the worklists.

Run:  .venv/bin/python scripts/journey_urdu.py <command> ...
"""
import json
import os
import re
import sys
from collections import OrderedDict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORK = os.path.join(ROOT, "journey_urdu_work")
APP_DIR = os.path.join(ROOT, "Thaqalayn", "Data", "JourneyUrdu")
QURAN = os.path.join(ROOT, "Thaqalayn", "Thaqalayn", "Data", "quran_data.json")
READY = os.path.join(ROOT, "Thaqalayn", "Resources", "journey_audio_ready.json")

LATIN = re.compile(r"[A-Za-z]")
DIGIT = re.compile(r"[0-9٠-٩۰-۹]")
ARABIC_SCRIPT = re.compile(r"[؀-ۿ]")
DASHES = ("—", "–")   # em dash, en dash
# Lengths outside these ratios (Urdu chars / English chars) have clearly lost or gained
# content. Measured against the English with its bare verse references removed, since the
# Urdu leaves those out.
RATIO_ERROR = (0.45, 2.1)
RATIO_WARN = (0.6, 1.7)
SHORT_LINE = 40                 # English lines shorter than this (titles, part names) skip the length check
VERSE_REF = re.compile(r"\s*\(\d+:\d+(?:-\d+)?(?:;\s*\d+:\d+(?:-\d+)?)*\)")


def app_path(jid):
    return os.path.join(APP_DIR, f"journey_ur_{jid}.json")


def work_dir(jid):
    return os.path.join(WORK, jid)


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def write_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


# ── worklist ────────────────────────────────────────────────────────────────


def quran_urdu():
    data = load_json(QURAN)["verses"]
    return lambda s, a: data.get(str(s), {}).get(str(a), {}).get("translationUrdu")


def cmd_worklist(ids):
    from extract_journey_strings import context_lines
    rows = context_lines()
    if not rows:
        raise SystemExit("the dump produced no JRNYLINE rows")
    ready = set(load_json(READY))
    urdu_of = quran_urdu()
    by_journey = OrderedDict()
    for r in rows:
        by_journey.setdefault(r["journey"], []).append(r)
    wanted = ids or [j for j in by_journey if j in ready]
    unknown = [j for j in wanted if j not in by_journey]
    if unknown:
        raise SystemExit(f"no narration for: {', '.join(unknown)}")
    for jid in wanted:
        seen, lines = set(), []
        for r in by_journey[jid]:
            if r["role"] == "connector" or r["text"] in seen:
                continue
            seen.add(r["text"])
            line = OrderedDict(n=len(lines) + 1, beat=r["beat"], beat_title=r["beat_title"],
                               role=r["role"], en=r["text"])
            m = re.fullmatch(r"verse (\d+):(\d+)", r["role"])
            if m:
                line["quran_ur"] = urdu_of(int(m.group(1)), int(m.group(2)))
            lines.append(line)
        path = os.path.join(work_dir(jid), "source.json")
        old = load_json(path) if os.path.exists(path) else None
        write_json(path, {"journey": jid, "lines": lines})
        changed = "" if old is None else (" (unchanged)" if old["lines"] == lines else " (CHANGED - re-check ur.json)")
        print(f"{jid:20} {len(lines):4} lines{changed}")


# ── check / apply ───────────────────────────────────────────────────────────


def validate(jid):
    """(pairs, errors, warnings) for journey_urdu_work/<id>/ur.json against source.json."""
    src_path = os.path.join(work_dir(jid), "source.json")
    ur_path = os.path.join(work_dir(jid), "ur.json")
    if not os.path.exists(src_path):
        return None, [f"no worklist at {src_path} - run worklist first"], []
    if not os.path.exists(ur_path):
        return None, [f"no translation at {ur_path}"], []
    source = load_json(src_path)["lines"]
    try:
        ur = load_json(ur_path)
    except json.JSONDecodeError as e:
        return None, [f"ur.json is not valid JSON: {e}"], []
    errors, warnings = [], []
    entries = ur.get("lines") if isinstance(ur, dict) else None
    if not isinstance(entries, list):
        return None, ['ur.json must be {"lines": [{"n": 1, "ur": "..."}, ...]}'], []
    by_n = {}
    for e in entries:
        n = e.get("n") if isinstance(e, dict) else None
        if not isinstance(n, int):
            errors.append(f"entry without an integer n: {str(e)[:80]}")
            continue
        if n in by_n:
            errors.append(f"line {n}: given twice")
        by_n[n] = e.get("ur")
    expected = {l["n"] for l in source}
    for n in sorted(set(by_n) - expected):
        errors.append(f"line {n}: no such line in source.json")
    pairs = []
    for line in source:
        n, en, text = line["n"], line["en"], by_n.get(line["n"])
        if not isinstance(text, str) or not text.strip():
            errors.append(f"line {n}: missing")
            continue
        text = text.strip()
        problems = []
        if LATIN.search(text):
            problems.append(f"Latin letters {sorted(set(LATIN.findall(text)))[:6]}")
        if DIGIT.search(text):
            problems.append("digits (write numbers as words; drop verse references)")
        if "ﷺ" in text:
            problems.append("the ﷺ glyph (write صلی اللہ علیہ وآلہ وسلم)")
        if any(d in text for d in DASHES):
            problems.append("an em/en dash (use a comma or a plain -)")
        if "\t" in text or "\n" in text:
            problems.append("a tab or line break")
        if not ARABIC_SCRIPT.search(text):
            problems.append("no Urdu script")
        base = len(VERSE_REF.sub("", en)) or 1
        ratio = len(text) / base
        if base < SHORT_LINE:
            pass                       # a title or a name: one Urdu word may be its whole meaning
        elif not RATIO_ERROR[0] <= ratio <= RATIO_ERROR[1]:
            problems.append(f"length {ratio:.2f}x the English - content lost or added?")
        elif not RATIO_WARN[0] <= ratio <= RATIO_WARN[1]:
            warnings.append(f"line {n}: length {ratio:.2f}x the English - check nothing is lost or added")
        if problems:
            errors.append(f"line {n}: " + "; ".join(problems))
        pairs.append({"en": en, "ur": text})
    return pairs, errors, warnings


def report(jid, errors, warnings):
    for w in warnings:
        print(f"  warn  {w}")
    for e in errors:
        print(f"  FAIL  {e}")


def cmd_check(ids):
    ok = True
    for jid in ids:
        pairs, errors, warnings = validate(jid)
        print(f"{jid}: {'PASS' if not errors else 'FAIL'}"
              + (f" ({len(pairs)} lines)" if pairs is not None and not errors else ""))
        report(jid, errors, warnings)
        ok = ok and not errors
    sys.exit(0 if ok else 1)


def cmd_apply(ids):
    ok = True
    for jid in ids:
        pairs, errors, warnings = validate(jid)
        report(jid, errors, warnings)
        if errors:
            print(f"{jid}: NOT applied ({len(errors)} problems)")
            ok = False
            continue
        write_json(app_path(jid), {"id": jid, "lines": pairs})
        print(f"{jid}: applied {len(pairs)} lines -> {os.path.relpath(app_path(jid), ROOT)}")
    sys.exit(0 if ok else 1)


def cmd_status():
    if not os.path.isdir(WORK):
        raise SystemExit("no journey_urdu_work/ yet - run worklist first")
    print(f"{'journey':20} {'lines':>5}  {'ur.json':8} {'review':7} {'applied':8}")
    for jid in sorted(os.listdir(WORK)):
        src = os.path.join(work_dir(jid), "source.json")
        if not os.path.exists(src):
            continue
        source = load_json(src)["lines"]
        has_ur = os.path.exists(os.path.join(work_dir(jid), "ur.json"))
        has_review = os.path.exists(os.path.join(work_dir(jid), "review.json"))
        applied = "-"
        if os.path.exists(app_path(jid)):
            app = {p["en"] for p in load_json(app_path(jid))["lines"]}
            missing = sum(1 for l in source if l["en"] not in app)
            applied = "yes" if not missing else f"stale {missing}"
        print(f"{jid:20} {len(source):5}  {'yes' if has_ur else '-':8} {'yes' if has_review else '-':7} {applied:8}")


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "worklist":
        cmd_worklist(args)
    elif cmd == "check" and args:
        cmd_check(args)
    elif cmd == "apply" and args:
        cmd_apply(args)
    elif cmd == "status":
        cmd_status()
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
