#!/usr/bin/env python3
"""Validate Thaqalayn/Data/daily_challenges.json against the Swift DailyChallenge decode
contract + the app's trilingual requirement + dedup. Mirrors DailyChallengeModels.swift.

Usage: python3 scripts/challenges/validate.py
Exit 0 = valid; exit 1 = problems (printed)."""
import json, re, sys, os

DATA = os.path.join(os.path.dirname(__file__), "..", "..", "Thaqalayn", "Data", "daily_challenges.json")
FORMATS = {"multipleChoice", "trueFalse", "flashcard", "fillInBlank"}
TOPICS = {"quran", "dua", "ahlulbayt", "event", "practice"}
errors = []

def lt_ok(v, where):
    """LocalizedText must have non-empty en, ur, ar (app ships all three)."""
    if not isinstance(v, dict):
        errors.append(f"{where}: not an object"); return
    for lang in ("en", "ur", "ar"):
        if not isinstance(v.get(lang), str) or not v[lang].strip():
            errors.append(f"{where}: missing/empty {lang}")

d = json.load(open(os.path.abspath(DATA), encoding="utf-8"))
if not isinstance(d, list):
    print("ROOT is not a list"); sys.exit(1)
if len(d) != 365:
    errors.append(f"count {len(d)} != 365")

seen_prompt = {}
for i, o in enumerate(d):
    exp_id = f"dc_{i+1:03d}"
    cid = o.get("id")
    if cid != exp_id:
        errors.append(f"[{i}] id {cid!r} != expected {exp_id}")
    where = f"{cid}"
    F = o.get("format")
    if F not in FORMATS:
        errors.append(f"{where}: bad format {F!r}")
    if o.get("topic") not in TOPICS:
        errors.append(f"{where}: bad topic {o.get('topic')!r}")
    lt_ok(o.get("prompt"), f"{where}.prompt")
    lt_ok(o.get("explanation"), f"{where}.explanation")
    opts, ci, ans = o.get("options"), o.get("correctIndex"), o.get("answer")
    if F == "multipleChoice":
        if not isinstance(opts, list) or len(opts) != 4: errors.append(f"{where}: MC options != 4")
        else:
            for j, op in enumerate(opts): lt_ok(op, f"{where}.options[{j}]")
        if not isinstance(ci, int) or isinstance(ci, bool) or not 0 <= ci <= 3: errors.append(f"{where}: MC correctIndex {ci!r}")
        if ans is not None: errors.append(f"{where}: MC answer must be null")
    elif F == "fillInBlank":
        if not isinstance(opts, list) or len(opts) != 3: errors.append(f"{where}: fillInBlank options != 3")
        else:
            for j, op in enumerate(opts): lt_ok(op, f"{where}.options[{j}]")
        if not isinstance(ci, int) or isinstance(ci, bool) or not 0 <= ci <= 2: errors.append(f"{where}: fillInBlank correctIndex {ci!r}")
        if ans is not None: errors.append(f"{where}: fillInBlank answer must be null")
    elif F == "trueFalse":
        if opts is not None: errors.append(f"{where}: trueFalse options must be null")
        if ci not in (0, 1): errors.append(f"{where}: trueFalse correctIndex {ci!r} not in 0/1")
        if ans is not None: errors.append(f"{where}: trueFalse answer must be null")
    elif F == "flashcard":
        if opts is not None: errors.append(f"{where}: flashcard options must be null")
        if ci is not None: errors.append(f"{where}: flashcard correctIndex must be null")
        lt_ok(ans, f"{where}.answer")
    at, src = o.get("arabicText"), o.get("source")
    # arabicText/source are optional; existing data uses "" as well as null - both are fine.
    if at is not None and not isinstance(at, str): errors.append(f"{where}: arabicText not a string")
    if src is not None and not isinstance(src, str): errors.append(f"{where}: source not a string")
    # dedup on normalized English prompt
    pe = (o.get("prompt") or {}).get("en", "")
    norm = re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", pe.lower())).strip()
    if norm in seen_prompt: errors.append(f"{where}: duplicate prompt vs {seen_prompt[norm]}: {pe[:50]}")
    else: seen_prompt[norm] = cid

from collections import Counter
print(f"objects: {len(d)}")
print("formats:", dict(Counter(o.get('format') for o in d)))
print("topics :", dict(Counter(o.get('topic') for o in d)))
print(f"\n{'FAILED' if errors else 'VALID'} - {len(errors)} error(s)")
for e in errors[:80]:
    print("  -", e)
sys.exit(1 if errors else 0)
