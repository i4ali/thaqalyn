#!/usr/bin/env python3
"""Validate the bundled daily_crosswords.json. Exits non-zero on any failure."""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "Thaqalayn", "Data", "daily_crosswords.json"))
BANK = os.path.join(HERE, "bank.json")


def main():
    puzzles = json.load(open(OUT, encoding="utf-8"))
    bank = {e["answer"].upper() for e in json.load(open(BANK, encoding="utf-8"))["entries"]}
    assert puzzles, "no puzzles"
    ids = set()
    for p in puzzles:
        pid = p["id"]
        assert pid not in ids, f"duplicate id {pid}"
        ids.add(pid)
        solution = {}            # (r,c) -> letter, must be consistent across entries
        seen_slots = set()
        crossings = 0
        starts = set()
        for e in p["entries"]:
            a = e["answer"].upper()
            assert a in bank, f"{pid}: {a} not in bank"
            assert re.fullmatch(r"[A-Z]{3,6}", a), f"{pid}: bad answer {a}"
            assert e["dir"] in ("A", "D"), f"{pid}: bad dir"
            assert len(e["cells"]) == len(a), f"{pid}: {a} cells/length mismatch"
            for k in ("en", "ur", "ar"):
                assert e["clue"].get(k), f"{pid}: {a} missing clue.{k}"
            slot = (e["dir"], tuple(tuple(c) for c in e["cells"]))
            assert slot not in seen_slots, f"{pid}: duplicate slot {a}"
            seen_slots.add(slot)
            starts.add((e["cells"][0][0], e["cells"][0][1]))
            for i, (r, c) in enumerate(e["cells"]):
                assert 0 <= r < p["rows"] and 0 <= c < p["cols"], f"{pid}: {a} cell out of bounds"
                if (r, c) in solution:
                    assert solution[(r, c)] == a[i], f"{pid}: crossing conflict at {r},{c}"
                    crossings += 1
                else:
                    solution[(r, c)] = a[i]
        assert crossings >= 1, f"{pid}: no crossings"
        # cellNumbers must correspond exactly to entry start cells
        cn = {tuple(int(x) for x in k.split(",")) for k in p["cellNumbers"]}
        assert cn == starts, f"{pid}: cellNumbers {cn} != starts {starts}"
    print(f"ALL {len(puzzles)} PUZZLES VALID  (ids unique, crossings consistent, trilingual clues present)")


if __name__ == "__main__":
    try:
        main()
    except AssertionError as e:
        print("VALIDATION FAILED:", e); sys.exit(1)
