#!/usr/bin/env python3
"""Emit verbatim Qur'an Arabic from the app's quran_data.json for given verse refs.

Hand-typed Arabic in Surah<Name>Dive.swift drifts to NFC normalization and fails the
byte-for-byte check against quran_data.json. Paste THIS output into the `.verse(arabic:)`
fields so they match the app data exactly.

Usage (from the repo root):
    python3 .claude/skills/inside-the-surah/scripts/pull_arabic.py 12:4 12:15 12:33
    python3 .claude/skills/inside-the-surah/scripts/pull_arabic.py --swift 1:1 1:2

Output: one line per ref  ->  `12:4\t<arabic>`  (or a ready `arabic: "..."` line with --swift).
"""
import json
import os
import sys

CANDIDATES = [
    "Thaqalayn/Thaqalayn/Data/quran_data.json",  # the copy the app bundles (source of truth)
    "quran_data.json",                            # repo-root mirror
]


def load():
    for p in CANDIDATES:
        if os.path.exists(p):
            with open(p, encoding="utf-8") as f:
                return json.load(f), p
    sys.exit("quran_data.json not found - run from the repo root.")


def main():
    args = [a for a in sys.argv[1:] if a != "--swift"]
    as_swift = "--swift" in sys.argv[1:]
    if not args:
        sys.exit(__doc__)

    data, path = load()
    verses = data["verses"]
    print(f"# source: {path}", file=sys.stderr)

    exit_code = 0
    for ref in args:
        try:
            s, a = ref.split(":")
            txt = verses[s][a]["arabicText"].lstrip("﻿")  # strip BOM (notably 1:1)
        except (ValueError, KeyError):
            print(f"{ref}\t!! NOT FOUND (use surah:ayah, e.g. 2:255)", file=sys.stderr)
            exit_code = 1
            continue
        if as_swift:
            print(f'                arabic: "{txt}",   // {ref}')
        else:
            print(f"{ref}\t{txt}")
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
