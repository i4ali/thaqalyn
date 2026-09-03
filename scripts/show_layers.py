#!/usr/bin/env python3
"""
show_layers.py - print the five ENGLISH tafsir layers for one verse (or a range)
without loading a whole multi-megabyte tafsir_N.json into an agent's context.

Usage
    python3 scripts/show_layers.py 1 1          # surah 1, verse 1
    python3 scripts/show_layers.py 1 1 7        # verses 1-7
    python3 scripts/show_layers.py 1 1 --json   # machine-readable
"""
import argparse
import json
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DATA = os.path.join(ROOT, "Thaqalayn", "Thaqalayn", "Data")
LAYERS = ["layer1", "layer2", "layer3", "layer4", "layer5"]
TITLES = {
    "layer1": "Foundation",
    "layer2": "Classical Shia (Tabatabai / Tabrisi)",
    "layer3": "Contemporary",
    "layer4": "Ahlul Bayt narrations",
    "layer5": "Comparative (Shia / Sunni)",
}


def load(surah: int) -> dict:
    with open(os.path.join(DATA, f"tafsir_{surah}.json"), encoding="utf-8") as f:
        return json.load(f)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("surah", type=int)
    ap.add_argument("start", type=int)
    ap.add_argument("end", type=int, nargs="?")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    end = a.end or a.start
    data = load(a.surah)
    out = {}
    for v in range(a.start, end + 1):
        entry = data.get(str(v))
        if not entry:
            print(f"(no tafsir for {a.surah}:{v})", file=sys.stderr)
            continue
        out[str(v)] = {k: entry.get(k, "") for k in LAYERS}
    if a.json:
        json.dump(out, sys.stdout, ensure_ascii=False, indent=1)
        return 0
    for v, layers in out.items():
        print(f"######## {a.surah}:{v}")
        for k in LAYERS:
            print(f"--- {k}  {TITLES[k]}")
            print(layers[k])
            print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
