#!/usr/bin/env python3
"""Assemble the final 293 trilingual challenges from daily_challenges_wip.json, interleave
by format (and spread topics) so the daily rotation stays varied, assign ids dc_073..dc_365,
and append to Thaqalayn/Data/daily_challenges.json (existing 72 preserved byte-for-byte).

Usage: python3 scripts/challenges/assemble.py        # writes the file
       python3 scripts/challenges/assemble.py --dry   # report only, no write"""
import json, os, sys

HERE = os.path.dirname(__file__)
WIP = os.path.join(HERE, "daily_challenges_wip.json")
DATA = os.path.abspath(os.path.join(HERE, "..", "..", "Thaqalayn", "Data", "daily_challenges.json"))
FORMAT_ORDER = ["multipleChoice", "trueFalse", "flashcard", "fillInBlank"]
TOPIC_ORDER = ["quran", "ahlulbayt", "practice", "event", "dua"]

wip = json.load(open(WIP, encoding="utf-8"))
missing = [e["n"] for e in wip if not e.get("ur") or not e.get("ar")]
if missing:
    print(f"ABORT: {len(missing)} entries still missing ur/ar (n {missing[0]}..{missing[-1]})")
    sys.exit(1)

def LT(en, ur, ar): return {"en": en, "ur": ur, "ar": ar}

def build(e):
    ur, ar = e["ur"], e["ar"]
    opts = None
    if e.get("options_en"):
        opts = [LT(a, b, c) for a, b, c in zip(e["options_en"], ur["options"], ar["options"])]
    answer = LT(e["answer_en"], ur["answer"], ar["answer"]) if e.get("answer_en") else None
    return {
        "id": e["_id"],
        "format": e["format"],
        "topic": e["topic"],
        "prompt": LT(e["prompt_en"], ur["prompt"], ar["prompt"]),
        "options": opts,
        "correctIndex": e.get("correctIndex"),
        "answer": answer,
        "explanation": LT(e["explanation_en"], ur["explanation"], ar["explanation"]),
        "arabicText": e.get("arabicText"),
        "source": e.get("source"),
    }

def round_robin(items, key, order):
    buckets = {k: [] for k in order}
    for it in items:
        buckets[key(it)].append(it)
    out = []
    while any(buckets[k] for k in order):
        for k in order:
            if buckets[k]:
                out.append(buckets[k].pop(0))
    return out

# 1) within each format, spread topics (offset the topic start per format so consecutive
#    days vary in BOTH format and topic); 2) round-robin across formats
fmt_buckets = {}
for fi, f in enumerate(FORMAT_ORDER):
    rot = TOPIC_ORDER[fi:] + TOPIC_ORDER[:fi]
    fmt_buckets[f] = round_robin([e for e in wip if e["format"] == f], lambda e: e["topic"], rot)
ordered = []
while any(fmt_buckets[f] for f in FORMAT_ORDER):
    for f in FORMAT_ORDER:
        if fmt_buckets[f]:
            ordered.append(fmt_buckets[f].pop(0))
assert len(ordered) == 293, len(ordered)
for i, e in enumerate(ordered):
    e["_id"] = f"dc_{73 + i:03d}"

existing = json.load(open(DATA, encoding="utf-8"))
assert len(existing) == 72, f"existing is {len(existing)}, expected 72"
new_objs = [build(e) for e in ordered]
final = existing + new_objs
assert len(final) == 365

# sanity: format rotation of the first new ids
print("first 8 new:", [(o["id"], o["format"][:4], o["topic"][:4]) for o in new_objs[:8]])
from collections import Counter
print("new formats:", dict(Counter(o["format"] for o in new_objs)))
print("new topics :", dict(Counter(o["topic"] for o in new_objs)))
print("ids:", new_objs[0]["id"], "..", new_objs[-1]["id"])

if "--dry" in sys.argv:
    print("\n[dry run] not writing")
    sys.exit(0)

out = json.dumps(final, ensure_ascii=False, indent=2)  # no trailing newline (matches existing)
# guard: existing 72 must serialize byte-identically to the original file's first 72
orig = open(DATA, encoding="utf-8").read()
assert json.dumps(existing, ensure_ascii=False, indent=2) == orig, "existing-72 round-trip changed!"
open(DATA, "w", encoding="utf-8").write(out)
print(f"\nWROTE {DATA}: {len(final)} objects (72 preserved + 293 appended)")
