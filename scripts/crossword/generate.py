#!/usr/bin/env python3
"""
Daily Crossword content builder.

Reads the trilingual term bank (bank.json: each entry has answer, clue_en,
clue_ur, clue_ar, theme) and assembles all-thematic 'criss-cross' minis where
every across/down answer is a real term. Emits the bundled app file:

    Thaqalayn/Data/daily_crosswords.json   (array of puzzles, app schema)

App schema per puzzle (sparse: blocked cells are simply absent):
  {
    "id": "dcw_0001", "rows": 7, "cols": 6,
    "entries": [
      {"num": 1, "dir": "A", "answer": "KAABA",
       "clue": {"en": "...", "ur": "...", "ar": "..."},
       "cells": [[0,0],[0,1],[0,2],[0,3],[0,4]]}
    ],
    "cellNumbers": {"0,0": 1, "2,0": 2}
  }

Pure stdlib. Deterministic given the seed.
"""
import json, random, os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "Thaqalayn", "Data", "daily_crosswords.json"))


def load_bank():
    d = json.load(open(os.path.join(HERE, "bank.json"), encoding="utf-8"))
    clue, theme, pool = {}, {}, []
    for e in d["entries"]:
        a = e["answer"].upper()
        for k in ("clue_en", "clue_ur", "clue_ar"):
            if not e.get(k):
                raise ValueError(f"{a}: missing {k} (run translators / merge step first)")
        clue[a] = {"en": e["clue_en"], "ur": e["clue_ur"], "ar": e["clue_ar"]}
        theme[a] = e.get("theme", "")
        if 3 <= len(a) <= 6:
            pool.append(a)
    return clue, theme, pool


def cells_for(word, r, c, orient):
    return ([(r, c + i) for i in range(len(word))] if orient == "H"
            else [(r + i, c) for i in range(len(word))])


def valid(grid, word, r, c, orient):
    """Clean criss-cross placement: >=1 crossing, no parallel touching, ends free."""
    cells = cells_for(word, r, c, orient)
    crossings = 0
    if orient == "H":
        before, after = (r, c - 1), (r, c + len(word))
        side = lambda rr, cc: [(rr - 1, cc), (rr + 1, cc)]
    else:
        before, after = (r - 1, c), (r + len(word), c)
        side = lambda rr, cc: [(rr, cc - 1), (rr, cc + 1)]
    if before in grid or after in grid:
        return None
    for i, (rr, cc) in enumerate(cells):
        if (rr, cc) in grid:
            if grid[(rr, cc)] != word[i]:
                return None
            crossings += 1
        else:
            for nb in side(rr, cc):
                if nb in grid:
                    return None
    return crossings if crossings >= 1 else None


def build(pool, target, max_dim, rng, tries=200):
    for _ in range(tries):
        words = pool[:]; rng.shuffle(words); words.sort(key=lambda w: -len(w))
        first = words[rng.randrange(min(6, len(words)))]
        grid = {(0, i): ch for i, ch in enumerate(first)}
        placed = [(first, 0, 0, "H")]; used = {first}; stalls = 0
        while len(placed) < target and stalls < 60:
            cands = []
            occupied = list(grid.items())
            for w in words:
                if w in used:
                    continue
                for (pr, pc), L in occupied:
                    for i, ch in enumerate(w):
                        if ch != L:
                            continue
                        for orient in ("H", "V"):
                            r0 = pr if orient == "H" else pr - i
                            c0 = pc - i if orient == "H" else pc
                            sc = valid(grid, w, r0, c0, orient)
                            if sc is None:
                                continue
                            cells = cells_for(w, r0, c0, orient)
                            rs = [x for x, _ in cells] + [x for x, _ in grid]
                            cs = [y for _, y in cells] + [y for _, y in grid]
                            if (max(rs) - min(rs)) < max_dim and (max(cs) - min(cs)) < max_dim:
                                cands.append((sc, w, r0, c0, orient, cells))
            if not cands:
                break
            _, w, r0, c0, orient, cells = max(cands, key=lambda t: (t[0], rng.random()))
            for i, (rr, cc) in enumerate(cells):
                grid[(rr, cc)] = w[i]
            placed.append((w, r0, c0, orient)); used.add(w); stalls = 0
        if len(placed) >= target:
            return normalize(grid, placed)
    return None


def normalize(grid, placed):
    rs = [r for r, _ in grid]; cs = [c for _, c in grid]
    dr, dc = -min(rs), -min(cs)
    g2 = {(r + dr, c + dc): ch for (r, c), ch in grid.items()}
    p2 = [(w, r + dr, c + dc, o) for (w, r, c, o) in placed]
    H = max(r for r, _ in g2) + 1; W = max(c for _, c in g2) + 1
    return g2, p2, H, W


def number_and_entries(placed, clue):
    starts = {(r, c) for (_, r, c, _) in placed}
    H = max(r + (len(w) - 1 if o == "V" else 0) for (w, r, c, o) in placed) + 1
    W = max(c + (len(w) - 1 if o == "H" else 0) for (w, r, c, o) in placed) + 1
    nums = {}; n = 0
    for r in range(H):
        for c in range(W):
            if (r, c) in starts:
                n += 1; nums[(r, c)] = n
    entries = []
    for (w, r, c, o) in placed:
        entries.append({"num": nums[(r, c)], "dir": "A" if o == "H" else "D",
                        "answer": w, "clue": clue[w],
                        "cells": [list(x) for x in cells_for(w, r, c, o)]})
    entries.sort(key=lambda e: (e["dir"], e["num"]))
    return nums, entries, H, W


def generate(count, target=6, max_dim=7, seed=11, max_attempts=80000):
    clue, theme, pool = load_bank()
    rng = random.Random(seed); out = []; sigs = set(); attempts = 0
    while len(out) < count and attempts < max_attempts:
        attempts += 1
        res = build(pool, target, max_dim, rng)
        if not res:
            continue
        _, placed, _, _ = res
        sig = ",".join(sorted(f"{w}@{r},{c},{o}" for (w, r, c, o) in placed))
        if sig in sigs:
            continue
        sigs.add(sig)
        nums, entries, H, W = number_and_entries(placed, clue)
        out.append({
            "id": f"dcw_{len(out)+1:04d}", "rows": H, "cols": W, "entries": entries,
            "cellNumbers": {f"{r},{c}": v for (r, c), v in nums.items()},
        })
    return out, attempts


if __name__ == "__main__":
    puzzles, attempts = generate(count=365)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(puzzles, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"wrote {len(puzzles)} puzzles to {OUT} (in {attempts} attempts)")
