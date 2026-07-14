#!/usr/bin/env python3
"""Merge authored batches into Thaqalayn/Data/daily_verses.json.

Batches live in scripts/daily_verses/batches/:
  batch_*.json      -> {"verses": [...]}          appended in filename order
  sacred_days.json  -> {"sacredDays": [...]}

Ids are assigned here, not by the authors, so batches never collide.
Run:  python3 scripts/daily_verses/assemble.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BATCHES = Path(__file__).resolve().parent / "batches"
OUT = ROOT / "Thaqalayn" / "Data" / "daily_verses.json"

THEMES = [
    "tawhid", "mercy", "patience", "gratitude",
    "trust", "repentance", "prayer", "remembrance",
    "knowledge", "justice", "charity", "character",
    "family", "hardship-and-ease", "creation", "hereafter",
    "guidance", "striving",
]


def main():
    verses = []
    for path in sorted(BATCHES.glob("batch_*.json")):
        doc = json.loads(path.read_text(encoding="utf-8"))
        got = doc.get("verses", [])
        verses.extend(got)
        print(f"  {path.name}: {len(got)}")

    sacred_path = BATCHES / "sacred_days.json"
    sacred = json.loads(sacred_path.read_text(encoding="utf-8"))["sacredDays"] \
        if sacred_path.exists() else []

    # Ids are positional and assigned centrally.
    for i, v in enumerate(verses):
        v["id"] = i

    doc = {
        "version": 1,
        "themes": THEMES,
        "verses": verses,
        "sacredDays": sacred,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"\nwrote {OUT.relative_to(ROOT)}: {len(verses)} verses, {len(sacred)} sacred days")


if __name__ == "__main__":
    main()
