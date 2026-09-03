#!/usr/bin/env python3
"""
report_citations.py - human-readable summary of a citations_{surah}.json.

Usage
    python3 scripts/report_citations.py new_citations/citations_1.json          # full listing
    python3 scripts/report_citations.py new_citations/citations_1.json --stats  # counts only
"""
import json
import sys
from collections import Counter

MARK = {"verified": "OK ", "partial": "~  ", "not_found": "X  ", "unchecked": "?  "}


def main(path: str, stats_only: bool) -> int:
    doc = json.load(open(path, encoding="utf-8"))
    by_status, by_layer, by_source = Counter(), Counter(), Counter()
    issues = []
    lines = []
    for v, layers in sorted(doc["verses"].items(), key=lambda kv: int(kv[0])):
        for lk in sorted(layers):
            layer = layers[lk]
            cites = layer.get("citations", [])
            if cites:
                lines.append(f"\n{doc['surah']}:{v}  {lk}")
            for c in cites:
                by_status[c["status"]] += 1
                by_layer[(lk, c["status"])] += 1
                by_source[c["source"]] += 1
                loc = f" - {c['locator']}" if c.get("locator") else ""
                note = f"\n        note: {c['note']}" if c.get("note") else ""
                lines.append(f"  {MARK.get(c['status'], '   ')}[{c['id']}] {c['source']}{loc}")
                lines.append(f"        anchor: \"{c['anchor']}\"{note}")
            for iss in layer.get("issues", []) or []:
                issues.append(f"{doc['surah']}:{v} {lk}: {iss}")

    total = sum(by_status.values())
    print(f"Surah {doc['surah']}: {len(doc['verses'])} verses, {total} citations")
    for s in ("verified", "partial", "not_found", "unchecked"):
        print(f"  {s:10s} {by_status[s]:3d}")
    print("\nPer layer (verified / partial / not_found / unchecked):")
    for lk in ("layer1", "layer2", "layer3", "layer4", "layer5"):
        row = [by_layer[(lk, s)] for s in ("verified", "partial", "not_found", "unchecked")]
        if sum(row):
            print(f"  {lk}: {row[0]} / {row[1]} / {row[2]} / {row[3]}")
    print("\nSources cited:")
    for src, n in by_source.most_common():
        print(f"  {n:3d}  {src}")
    print(f"\nIssues logged: {len(issues)}")
    for i in issues:
        print(f"  - {i}")
    if not stats_only:
        print("\n" + "\n".join(lines))
    return 0


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 1:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(args[0], "--stats" in sys.argv))
