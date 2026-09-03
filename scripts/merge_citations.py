#!/usr/bin/env python3
"""
merge_citations.py - fold per-range files new_citations/citations_{S}_v{a}-{b}.json
into new_citations/citations_{S}.json.

The citer agent runs in verse ranges of about 20 (two agents at a time), and each
range writes its own file so parallel runs never overwrite each other. This
merges them. A verse present in more than one range file takes the newest file.
Range files are left in place; delete them once the surah is complete.

Usage
    python3 scripts/merge_citations.py 2          # merge all ranges of surah 2
    python3 scripts/merge_citations.py 2 --check  # report which verses are still missing
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
OUT = os.path.join(ROOT, "new_citations")
DATA = os.path.join(ROOT, "Thaqalayn", "Thaqalayn", "Data")


def main(surah: int, check: bool) -> int:
    parts = sorted(glob.glob(os.path.join(OUT, f"citations_{surah}_v*-*.json")), key=os.path.getmtime)
    merged_path = os.path.join(OUT, f"citations_{surah}.json")
    merged = {"surah": surah, "verses": {}}
    if os.path.exists(merged_path):
        merged = json.load(open(merged_path, encoding="utf-8"))
    for p in parts:
        doc = json.load(open(p, encoding="utf-8"))
        if doc.get("surah") != surah:
            print(f"skip {os.path.basename(p)}: surah field is {doc.get('surah')}")
            continue
        for v, layers in doc.get("verses", {}).items():
            merged["verses"][v] = layers
    merged["verses"] = dict(sorted(merged["verses"].items(), key=lambda kv: int(kv[0])))

    total = len(json.load(open(os.path.join(DATA, f"tafsir_{surah}.json"), encoding="utf-8")))
    have = {int(v) for v in merged["verses"]}
    missing = [v for v in range(1, total + 1) if v not in have]
    if check:
        print(f"surah {surah}: {len(have)}/{total} verses have a citations entry; missing: "
              + (", ".join(map(str, missing)) if missing else "none"))
        return 0
    with open(merged_path, "w", encoding="utf-8") as f:
        json.dump(merged, f, ensure_ascii=False, indent=1)
    print(f"merged {len(parts)} range file(s) -> {os.path.relpath(merged_path, ROOT)}; "
          f"{len(have)}/{total} verses covered" + (f"; missing {len(missing)}" if missing else ""))
    return 0


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 1:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(int(args[0]), "--check" in sys.argv))
