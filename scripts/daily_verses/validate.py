#!/usr/bin/env python3
"""Validate daily_verses.json against quran_data.json.

Run:  python3 scripts/daily_verses/validate.py
Exit: 0 if the pool is shippable, 1 otherwise.
"""
import difflib
import itertools
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POOL = ROOT / "Thaqalayn" / "Data" / "daily_verses.json"
QURAN = ROOT / "Thaqalayn" / "Thaqalayn" / "Data" / "quran_data.json"

EXPECTED_COUNT = 365
# The theme-spacing pass in DailyVerseProvider can always succeed while no theme
# holds more than half the pool. We bound it far tighter to keep the year varied.
MAX_THEME_SHARE = 1 / 3

# Two DIFFERENT refs whose translations read the same are a perceived repeat, which is
# the exact complaint this whole pool exists to fix. 62:1 and 64:1 are word-for-word
# identical in English; 3:169 and 2:154 are near-paraphrases (both were in the old pool).
# Distinct references are not enough - the text has to differ too.
MAX_TRANSLATION_SIMILARITY = 0.80

# Whole-string similarity is not enough on its own. 6:17 and 10:107 open with the SAME
# 60-character clause ("if Allah should touch you with adversity, there is no remover of
# it except Him") and then diverge, which scores only ~50% overall - but a reader meets
# the identical sentence twice. Any long shared clause is a perceived repeat.
MAX_SHARED_CLAUSE_CHARS = 60

errors = []


def err(msg):
    errors.append(msg)


def load_quran_index(path):
    """-> {(surah, verse): {"arabicText", "translation", "translationUrdu", ...}}

    quran_data.json is {"surahs": [...meta...], "verses": {"<surah>": {"<verse>": {...}}}}.
    Verified 2026-07-14: 6236 verses, 100% English and 100% Urdu coverage.
    """
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    index = {}
    for surah_key, verses in data["verses"].items():
        for verse_key, v in verses.items():
            index[(int(surah_key), int(verse_key))] = v
    return index


def main():
    if not POOL.exists():
        print(f"FAIL: {POOL} does not exist")
        return 1

    pool_doc = json.loads(POOL.read_text(encoding="utf-8"))
    quran = load_quran_index(QURAN)
    if not quran:
        print(f"FAIL: could not index {QURAN} - check its shape")
        return 1

    vocab = set(pool_doc.get("themes", []))
    verses = pool_doc.get("verses", [])
    sacred = pool_doc.get("sacredDays", [])

    if not vocab:
        err("themes vocabulary is empty")

    # --- pool size ---
    if len(verses) != EXPECTED_COUNT:
        err(f"expected {EXPECTED_COUNT} verses, found {len(verses)}")

    # --- refs resolve, with BOTH translations ---
    seen_refs = set()
    for e in verses:
        ref = (e["surah"], e["verse"])
        label = f'{e["surah"]}:{e["verse"]} (id {e.get("id")})'

        if ref in seen_refs:
            err(f"duplicate ref in pool: {label}")
        seen_refs.add(ref)

        v = quran.get(ref)
        if v is None:
            err(f"ref does not exist in quran_data.json: {label}")
            continue
        if not (v.get("translation") or "").strip():
            err(f"empty English translation: {label}")
        if not (v.get("translationUrdu") or "").strip():
            err(f"empty Urdu translation: {label}")

        # --- theme integrity ---
        if e.get("themeKey") not in vocab:
            err(f'themeKey "{e.get("themeKey")}" not in vocabulary: {label}')
        for field in ("themeEn", "themeUr", "themeAr"):
            if not (e.get(field) or "").strip():
                err(f"missing {field}: {label}")

    # --- near-duplicate translations ---
    # Distinct refs are not enough. If two verses READ the same, the user experiences a
    # repeat, which is the complaint this pool exists to fix. Caught in the wild: 62:1
    # and 64:1 are word-for-word identical in English.
    def normalise(text):
        text = re.sub(r"\[[^\]]*\]", " ", text or "")   # Sahih Intl bracketed glosses
        text = re.sub(r"[^a-z\s]", " ", text.lower())
        return " ".join(text.split())

    normalised = []
    for e in verses:
        v = quran.get((e["surah"], e["verse"]))
        if v is None:
            continue
        text = normalise(v.get("translation"))
        if text:
            normalised.append((f'{e["surah"]}:{e["verse"]}', text))
    by_ref = dict(normalised)

    flagged = set()

    # 1. Whole-string similarity. The length gate is a sound optimisation HERE - two
    #    strings of very different lengths cannot score a high overall ratio. It must NOT
    #    guard the clause check below (an earlier version did, which made that check dead
    #    code on exactly the pairs it existed for).
    for i in range(len(normalised)):
        ref_a, text_a = normalised[i]
        for j in range(i + 1, len(normalised)):
            ref_b, text_b = normalised[j]
            shorter, longer = sorted((len(text_a), len(text_b)))
            if longer and shorter / longer < MAX_TRANSLATION_SIMILARITY:
                continue
            ratio = difflib.SequenceMatcher(None, text_a, text_b, autojunk=False).ratio()
            if ratio >= MAX_TRANSLATION_SIMILARITY:
                flagged.add((ref_a, ref_b))
                err(f"{ref_a} and {ref_b} read almost the same ({ratio:.0%} similar) - "
                    f"pick one")

    # 2. Shared clauses, regardless of length. A short verse sitting wholly inside a long
    #    one is a perceived repeat even though the overall ratio looks safe: 6:17 and
    #    10:107 share a 92-character opening and score only ~50%.
    #
    #    Found by shingling every MAX_SHARED_CLAUSE_CHARS-character window, which is linear
    #    in total text. Comparing all ~66,000 pairs with find_longest_match directly is far
    #    too slow, so the shingles pick out candidate pairs and only those get measured.
    shingles = {}
    for ref, text in normalised:
        for i in range(len(text) - MAX_SHARED_CLAUSE_CHARS + 1):
            shingles.setdefault(text[i:i + MAX_SHARED_CLAUSE_CHARS], set()).add(ref)

    candidates = set()
    for refs in shingles.values():
        if len(refs) > 1:
            candidates.update(itertools.combinations(sorted(refs), 2))

    for ref_a, ref_b in sorted(candidates - flagged):
        text_a, text_b = by_ref[ref_a], by_ref[ref_b]
        block = difflib.SequenceMatcher(None, text_a, text_b, autojunk=False).find_longest_match(
            0, len(text_a), 0, len(text_b))
        shared = text_a[block.a:block.a + block.size].strip()
        err(f"{ref_a} and {ref_b} share a {block.size}-character clause - pick one. "
            f'Shared: "{shared[:70]}"')

    # --- theme balance: the spacing pass needs no theme to dominate ---
    counts = Counter(e.get("themeKey") for e in verses)
    for theme, n in counts.most_common():
        if verses and n / len(verses) > MAX_THEME_SHARE:
            err(f'theme "{theme}" is {n}/{len(verses)} of the pool, over the {MAX_THEME_SHARE:.0%} cap')

    unused = vocab - set(counts)
    if unused:
        err(f"themes declared but never used: {sorted(unused)}")

    # --- sacred days ---
    seen_days, seen_sacred_refs = set(), set()
    for s in sacred:
        key = (s["month"], s["day"])
        label = f'{s["day"]}/{s["month"]} {s.get("occasionEn")}'
        if key in seen_days:
            err(f"duplicate sacred day: {label}")
        seen_days.add(key)

        if not (1 <= s["month"] <= 12) or not (1 <= s["day"] <= 30):
            err(f"sacred day out of Hijri range: {label}")

        ref = (s["surah"], s["verse"])
        if ref not in quran:
            err(f'sacred-day ref does not exist: {s["surah"]}:{s["verse"]} ({label})')
        if ref in seen_sacred_refs:
            err(f'two occasions share the same verse {s["surah"]}:{s["verse"]} ({label})')
        seen_sacred_refs.add(ref)

        # A sacred verse must NOT also sit in the pool, or it could appear twice in a year.
        if ref in seen_refs:
            err(f'sacred-day ref {s["surah"]}:{s["verse"]} is also in the pool ({label})')

        for field in ("occasionEn", "occasionUr", "occasionAr",
                      "themeEn", "themeUr", "themeAr"):
            if not (s.get(field) or "").strip():
                err(f"missing {field}: {label}")

    # --- report ---
    if errors:
        print(f"FAIL: {len(errors)} problem(s)\n")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(f"OK: {len(verses)} verses, {len(counts)} themes, {len(sacred)} sacred days")
    print(f"    theme spread: min {min(counts.values())}, max {max(counts.values())}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
