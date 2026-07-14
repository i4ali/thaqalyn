#!/usr/bin/env python3
"""Prove DailyVerseProvider's guarantees against the real pool, without a simulator.

This is a line-for-line mirror of the Swift in Thaqalayn/Services/DailyVerseProvider.swift
(SplitMix64 -> Fisher-Yates -> spaceThemes, with the cycle-seam link). If you change the
algorithm there, change it here, and re-run.

It asserts, over many cycles:
  1. No verse repeats within a cycle.
  2. No two consecutive days share a theme - INCLUDING across the cycle seam.
  3. Each cycle is a different order from the last.
  4. Every pool verse is used exactly once per cycle.

Run:  python3 scripts/daily_verses/simulate.py [cycles]
Exit: 0 if every guarantee holds, 1 otherwise.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POOL = ROOT / "Thaqalayn" / "Data" / "daily_verses.json"

MASK = (1 << 64) - 1
GOLDEN = 0x9E3779B97F4A7C15


class SplitMix64:
    """Mirrors the Swift struct exactly, including &+ / &* wrapping."""

    def __init__(self, seed):
        self.state = seed & MASK

    def next(self):
        self.state = (self.state + GOLDEN) & MASK
        z = self.state
        z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & MASK
        z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & MASK
        return (z ^ (z >> 31)) & MASK


def spaced_order(cycle, themes, previous_theme):
    """Mirrors DailyVerseProvider.spacedOrder(cycle:previousTheme:).

    Greedy by largest remaining theme bucket. Do NOT "simplify" this back into a
    shuffle-then-repair pass: repairing a collision by scanning forward for a swap
    candidate runs out of candidates near the end of the array, so every cycle ends
    with broken spacing in its final days. That is exactly the bug this file caught.
    """
    n = len(themes)
    rng = SplitMix64((cycle + GOLDEN) & MASK)

    buckets = {}
    for index, key in enumerate(themes):
        buckets.setdefault(key, []).append(index)

    # Sorted keys keep the shuffle order identical to Swift's.
    for key in sorted(buckets):
        members = buckets[key]
        i = len(members) - 1
        while i > 0:
            j = rng.next() % (i + 1)
            members[i], members[j] = members[j], members[i]
            i -= 1

    result = []
    last = previous_theme

    while len(result) < n:
        available = {k: v for k, v in buckets.items() if v and k != last}
        if not available:
            for key in sorted(buckets):
                result.extend(buckets[key])
            break
        max_count = max(len(v) for v in available.values())
        tied = sorted(k for k, v in available.items() if len(v) == max_count)
        chosen = tied[rng.next() % len(tied)]
        result.append(buckets[chosen].pop(0))
        last = chosen

    return result


def main(cycles=30):
    if not POOL.exists():
        print(f"FAIL: {POOL} does not exist - author the pool first")
        return 1

    doc = json.loads(POOL.read_text(encoding="utf-8"))
    verses = doc["verses"]
    n = len(verses)
    if n == 0:
        print("FAIL: pool is empty")
        return 1

    themes = [v["themeKey"] for v in verses]
    refs = [f'{v["surah"]}:{v["verse"]}' for v in verses]

    failures = []
    previous_theme = None
    previous_order = None

    for cycle in range(cycles):
        order = spaced_order(cycle, themes, previous_theme)

        # 1. every verse used exactly once
        if sorted(order) != list(range(n)):
            failures.append(f"cycle {cycle}: not a permutation")

        # 2. no repeated ref within the cycle
        cycle_refs = [refs[i] for i in order]
        if len(set(cycle_refs)) != len(cycle_refs):
            dupes = len(cycle_refs) - len(set(cycle_refs))
            failures.append(f"cycle {cycle}: {dupes} repeated verse(s)")

        # 3. no two consecutive days share a theme, inside the cycle
        for i in range(1, n):
            if themes[order[i]] == themes[order[i - 1]]:
                failures.append(
                    f"cycle {cycle}: adjacent theme collision at day {i} "
                    f'("{themes[order[i]]}")'
                )

        # 4. ...and across the seam into this cycle
        if previous_theme is not None and themes[order[0]] == previous_theme:
            failures.append(
                f'cycle {cycle}: SEAM collision - day 0 repeats "{previous_theme}" '
                f"from the end of cycle {cycle - 1}"
            )

        # 5. a different order from last cycle
        if previous_order is not None and order == previous_order:
            failures.append(f"cycle {cycle}: identical order to cycle {cycle - 1}")

        previous_theme = themes[order[-1]]
        previous_order = order

    if failures:
        print(f"FAIL: {len(failures)} problem(s) over {cycles} cycles\n")
        for f in failures[:20]:
            print(f"  - {f}")
        if len(failures) > 20:
            print(f"  ... and {len(failures) - 20} more")
        return 1

    print(f"OK: {cycles} cycles x {n} days = {cycles * n} days simulated")
    print("    no verse repeats within a cycle")
    print("    no two consecutive days share a theme (including across cycle seams)")
    print("    every cycle is a fresh order")
    return 0


if __name__ == "__main__":
    sys.exit(main(int(sys.argv[1]) if len(sys.argv) > 1 else 30))
