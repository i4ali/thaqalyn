#!/usr/bin/env python3
"""Pre-flight one authored batch before it goes into the pool.

Catches the things a verse author gets wrong: a ref that does not exist (verse
number past the end of the surah), a ref that collides with the sacred-day table
or with an already-authored batch, a themeKey outside the vocabulary, or a
missing translation.

It ALSO runs validate.py's near-duplicate and shared-clause checks against the rest
of the pool, because two verses that READ the same are a perceived repeat and that is
the exact complaint this pool exists to fix. Those checks used to live only in
validate.py, which meant authors could not see them until assemble time - one author
had to hand-replicate the logic to catch its own 62-character collision between 57:9
and 33:43. Now they get it here.

Run:  python3 scripts/daily_verses/check_batch.py scripts/daily_verses/batches/batch_01.json
Exit: 0 if the batch is clean, 1 otherwise.
"""
import difflib
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from validate import (  # noqa: E402
    load_quran_index, QURAN, MAX_TRANSLATION_SIMILARITY, MAX_SHARED_CLAUSE_CHARS,
)
from assemble import THEMES, BATCHES  # noqa: E402


def normalise(text):
    text = re.sub(r"\[[^\]]*\]", " ", text or "")   # Sahih Intl bracketed glosses
    text = re.sub(r"[^a-z\s]", " ", text.lower())
    return " ".join(text.split())


def main(batch_path):
    path = Path(batch_path)
    if not path.exists():
        print(f"FAIL: {path} does not exist")
        return 1

    quran = load_quran_index(QURAN)
    verses = json.loads(path.read_text(encoding="utf-8")).get("verses", [])

    # Refs already claimed by the sacred-day table and every OTHER batch.
    taken = {}
    sacred_path = BATCHES / "sacred_days.json"
    if sacred_path.exists():
        for s in json.loads(sacred_path.read_text(encoding="utf-8"))["sacredDays"]:
            taken[(s["surah"], s["verse"])] = f'sacred day ({s["occasionEn"]})'
    for other in sorted(BATCHES.glob("batch_*.json")):
        if other.resolve() == path.resolve():
            continue
        for v in json.loads(other.read_text(encoding="utf-8")).get("verses", []):
            taken[(v["surah"], v["verse"])] = other.name

    errors = []
    seen = set()
    for e in verses:
        try:
            ref = (e["surah"], e["verse"])
        except KeyError:
            errors.append(f"entry missing surah/verse: {e}")
            continue
        label = f'{ref[0]}:{ref[1]}'

        if "id" in e:
            errors.append(f"{label}: do not author an 'id' field, assemble.py assigns it")

        if ref not in quran:
            errors.append(f"{label}: does not exist in quran_data.json")
            continue
        if ref in seen:
            errors.append(f"{label}: duplicated inside this batch")
        seen.add(ref)
        if ref in taken:
            errors.append(f"{label}: already claimed by {taken[ref]}")

        v = quran[ref]
        if not (v.get("translation") or "").strip():
            errors.append(f"{label}: no English translation")
        if not (v.get("translationUrdu") or "").strip():
            errors.append(f"{label}: no Urdu translation")

        if e.get("themeKey") not in THEMES:
            errors.append(f'{label}: themeKey "{e.get("themeKey")}" not in vocabulary')
        for field in ("themeEn", "themeUr", "themeAr"):
            if not (e.get(field) or "").strip():
                errors.append(f"{label}: missing {field}")

    # --- do any of these verses READ like something already in the pool? ---
    # Distinct references are not enough. 62:1 and 64:1 are word-for-word identical in
    # English; 6:17 and 10:107 open with the same 92-character clause and then diverge,
    # scoring a safe-looking ~50% overall. Both are perceived repeats.
    others = []
    for ref, source in taken.items():
        v = quran.get(ref)
        if v is None:
            continue
        text = normalise(v.get("translation"))
        if text:
            others.append((f"{ref[0]}:{ref[1]}", source, text))

    mine = []
    for e in verses:
        ref = (e.get("surah"), e.get("verse"))
        v = quran.get(ref)
        if v is None:
            continue
        text = normalise(v.get("translation"))
        if text:
            mine.append((f"{ref[0]}:{ref[1]}", text))

    # Compare each of mine against the rest of the pool AND against each other.
    for i, (ref_a, text_a) in enumerate(mine):
        against = [(r, s, t) for r, s, t in others]
        against += [(r, "this batch", t) for r, t in mine[i + 1:]]

        for ref_b, source, text_b in against:
            # The length gate is sound for the RATIO only. It must not guard the clause
            # check - a short verse sitting wholly inside a long one is the repeat we
            # care most about, and gating it there made this check dead code once already.
            shorter, longer = sorted((len(text_a), len(text_b)))
            if longer and shorter / longer >= MAX_TRANSLATION_SIMILARITY:
                ratio = difflib.SequenceMatcher(None, text_a, text_b, autojunk=False).ratio()
                if ratio >= MAX_TRANSLATION_SIMILARITY:
                    errors.append(f"{ref_a}: reads almost the same as {ref_b} "
                                  f"({source}) - {ratio:.0%} similar. Pick another verse.")
                    continue

            # autojunk=False matters: on strings over 200 chars the heuristic treats
            # common LETTERS as junk and silently reports a 108-char match as 1 char.
            block = difflib.SequenceMatcher(
                None, text_a, text_b, autojunk=False
            ).find_longest_match(0, len(text_a), 0, len(text_b))
            if block.size >= MAX_SHARED_CLAUSE_CHARS:
                shared = text_a[block.a:block.a + block.size].strip()
                errors.append(f"{ref_a}: shares a {block.size}-character clause with "
                              f'{ref_b} ({source}). Shared: "{shared[:60]}"')

    if errors:
        print(f"FAIL: {path.name}, {len(errors)} problem(s)\n")
        for msg in errors:
            print(f"  - {msg}")
        return 1

    print(f"OK: {path.name}, {len(verses)} verses, all refs resolve and are unclaimed")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
