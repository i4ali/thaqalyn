#!/usr/bin/env python3
"""
log_misattribution.py - append one misattribution found in the tafsir commentary
to the shared log new_citations/misattributions.jsonl, or render that log.

The commentary text is NOT changed by the citation pass. When the citer agent
finds that a paragraph credits a point or a saying to the wrong book, scholar,
Imam or the Prophet, it logs it here and moves on. The log is fixed later.

Append (one JSON line, safe for two agents writing at once):
    python3 scripts/log_misattribution.py add \
        --surah 1 --verse 3 --layer layer4 \
        --anchor "Imam Ali is narrated to have said that God's mercy precedes His wrath" \
        --claimed "Imam Ali" \
        --found "Prophetic hadith qudsi, Sahih al-Bukhari 7453, Sahih Muslim 2751" \
        --note "Not located as a saying of Imam Ali in this session." \
        [--url https://...]

Render:
    python3 scripts/log_misattribution.py report            # markdown to stdout
    python3 scripts/log_misattribution.py report --surah 2  # one surah
"""
import argparse
import json
import os
import sys
from datetime import date

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
LOG = os.path.join(ROOT, "new_citations", "misattributions.jsonl")


def add(a) -> int:
    entry = {
        "surah": a.surah,
        "verse": a.verse,
        "layer": a.layer,
        "anchor": a.anchor,
        "claimed": a.claimed,
        "found": a.found,
        "note": a.note or "",
        "url": a.url or "",
        "logged": date.today().isoformat(),
        "status": "open",
    }
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    line = json.dumps(entry, ensure_ascii=False) + "\n"
    # O_APPEND: each small write lands whole, so concurrent agents do not interleave
    fd = os.open(LOG, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o644)
    try:
        os.write(fd, line.encode("utf-8"))
    finally:
        os.close(fd)
    print(f"logged misattribution {a.surah}:{a.verse} {a.layer}")
    return 0


def load() -> list[dict]:
    if not os.path.exists(LOG):
        return []
    out = []
    with open(LOG, encoding="utf-8") as f:
        for ln in f:
            ln = ln.strip()
            if ln:
                out.append(json.loads(ln))
    return out


def report(a) -> int:
    rows = load()
    if a.surah:
        rows = [r for r in rows if r["surah"] == a.surah]
    rows.sort(key=lambda r: (r["surah"], r["verse"], r["layer"]))
    print(f"# Misattributions in the tafsir commentary ({len(rows)} open items)\n")
    cur = None
    for r in rows:
        key = (r["surah"], r["verse"])
        if key != cur:
            print(f"\n## {r['surah']}:{r['verse']}")
            cur = key
        print(f"- **{r['layer']}** - text says: {r['claimed']}. Actually: {r['found']}.")
        if r.get("anchor"):
            print(f"  - anchor: \"{r['anchor']}\"")
        if r.get("note"):
            print(f"  - {r['note']}")
        if r.get("url"):
            print(f"  - {r['url']}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("add")
    p.add_argument("--surah", type=int, required=True)
    p.add_argument("--verse", type=int, required=True)
    p.add_argument("--layer", required=True, choices=["layer1", "layer2", "layer3", "layer4", "layer5"])
    p.add_argument("--anchor", required=True, help="verbatim clause from the layer text that carries the wrong attribution")
    p.add_argument("--claimed", required=True, help="who or what the paragraph credits")
    p.add_argument("--found", required=True, help="where the point or saying actually is, as far as you found")
    p.add_argument("--note", default="")
    p.add_argument("--url", default="")
    r = sub.add_parser("report")
    r.add_argument("--surah", type=int)
    a = ap.parse_args()
    return add(a) if a.cmd == "add" else report(a)


if __name__ == "__main__":
    sys.exit(main())
