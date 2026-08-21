"""Extract every English narrator string a journey speaks, in timeline order, from
the app's real narration logic - never a Python re-implementation of it.

Source of truth: the DEBUG dump test ThaqalaynTests/JourneyStringDumpTests, which
prints back exactly what `JourneyNarration.timeline(for:)` yields at runtime. We run
it under xcodebuild (forwarding JRNY_DUMP via TEST_RUNNER_), grep its tab-delimited
`JRNYDUMP` lines, and emit an ordered, content-hash-deduped list:

    [{key, journey, order, text}]   key = journey_audio_key(text)

Dedup is GLOBAL by key (the same sentence in two journeys shares one mp3), but order
and first-occurrence stay stable. The full list is written to journey_audio_manifest.json;
`gather()` returns it for build_journey_audio.py.

Run (invokes xcodebuild; does NOT call ElevenLabs):
  cd <repo> && source .venv/bin/activate
  cd scripts && python3 extract_journey_strings.py
"""
import json
import os
import re
import subprocess
from collections import OrderedDict

from journey_audio_key import journey_audio_key

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PROJECT = os.path.join(ROOT, "Thaqalayn.xcodeproj")
SCHEME = "Thaqalayn"
ONLY = "ThaqalaynTests/JourneyStringDumpTests"
# Confirmed-available iPhone 16 Pro; resolve_destination() falls back if it's gone.
PREFERRED_UDID = "00CE7494-2523-4F1B-AF96-30D7969096C1"
# Host-visible path the dump test writes to. XCTest stdout on the simulator is not
# echoed to xcodebuild's console, so the test writes a FILE instead (the simulator
# shares the host filesystem); /tmp is confirmed reachable from both sides. The path
# is handed to the test via TEST_RUNNER_JRNY_OUT (prefix stripped -> JRNY_OUT).
DUMP_FILE = "/tmp/journey_string_dump.tsv"

# Matches the dump line ANYWHERE in a console line (xcodebuild may prefix it):
#   JRNYDUMP<TAB><journey><TAB><order><TAB><text>
_LINE_RE = re.compile(r"JRNYDUMP\t([^\t]*)\t([^\t]*)\t(.*)$")


def resolve_destination() -> str:
    """Prefer the confirmed simulator UDID; otherwise the first available iPhone."""
    out = subprocess.run(["xcrun", "simctl", "list", "devices", "available"],
                         stdout=subprocess.PIPE, text=True).stdout
    if PREFERRED_UDID in out:
        return f"platform=iOS Simulator,id={PREFERRED_UDID}"
    m = re.search(r"iPhone[^(\n]*\(([0-9A-Fa-f-]{36})\)", out)
    if m:
        return f"platform=iOS Simulator,id={m.group(1)}"
    raise SystemExit("No available iPhone simulator found (xcrun simctl list devices available).")


def run_dump(destination: str):
    """Run the gated dump test and return (dump_text, console_output, returncode).
    `dump_text` is the tab-delimited file the test writes to DUMP_FILE. The TEST_RUNNER_
    prefix is how xcodebuild forwards env vars into the test process (JRNY_DUMP gates the
    test; JRNY_OUT tells it where to write)."""
    try:
        os.remove(DUMP_FILE)   # never read a stale dump if the test somehow no-ops
    except FileNotFoundError:
        pass
    cmd = ["xcodebuild", "test",
           "-project", PROJECT, "-scheme", SCHEME,
           "-destination", destination,
           f"-only-testing:{ONLY}"]
    env = dict(os.environ, TEST_RUNNER_JRNY_DUMP="1", TEST_RUNNER_JRNY_OUT=DUMP_FILE)
    proc = subprocess.run(cmd, env=env, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True)
    dump_text = ""
    if os.path.exists(DUMP_FILE):
        with open(DUMP_FILE, encoding="utf-8") as f:
            dump_text = f.read()
    return dump_text, proc.stdout, proc.returncode


def parse(output: str):
    """Pull `JRNYDUMP` lines into ordered [{journey, order, text}] (+ the __meta__
    count sentinel, returned separately). De-dupes on (journey, order) so an echoed
    console line can't corrupt indices. `__meta__` is metadata, never a journey."""
    items, meta_count, seen = [], None, set()
    for raw in output.splitlines():
        m = _LINE_RE.search(raw.rstrip("\r\n"))
        if not m:
            continue
        journey, order_field, text = m.group(1), m.group(2), m.group(3)
        if journey == "__meta__":
            if order_field == "count":
                try:
                    meta_count = int(text.strip())
                except ValueError:
                    pass
            continue
        try:
            order = int(order_field)
        except ValueError:
            continue
        if (journey, order) in seen:
            continue
        seen.add((journey, order))
        items.append({"journey": journey, "order": order, "text": text})
    return items, meta_count


def dedupe(items):
    """Global content-hash dedup, first-occurrence stable -> [{key, journey, order, text}]."""
    seen, out = set(), []
    for it in items:
        key = journey_audio_key(it["text"])
        if key in seen:
            continue
        seen.add(key)
        out.append({"key": key, "journey": it["journey"],
                    "order": it["order"], "text": it["text"]})
    return out


def strings_for(journeys):
    """Deduped-by-key narration strings for the given journey ids (union), first-occurrence
    stable -> [{key, journey, order, text}]. Unlike gather() (global dedup across ALL
    journeys), this keeps EVERY string a selected journey speaks - including shared
    connectors like "The Qur'an says:" - so a journey can be rendered on its own (bundled
    free journeys, or a single on-demand pack) without missing its shared lines."""
    want = set(journeys)
    items, _ = _extract()
    seen, out = set(), []
    for it in items:
        if it["journey"] not in want:
            continue
        key = journey_audio_key(it["text"])
        if key in seen:
            continue
        seen.add(key)
        out.append({"key": key, "journey": it["journey"],
                    "order": it["order"], "text": it["text"]})
    return out


def _extract():
    """Run the test and parse its dump file, or fail loudly with the console log."""
    dump_text, console, rc = run_dump(resolve_destination())
    items, meta_count = parse(dump_text)
    if not items:
        log = os.path.join(ROOT, "scripts", "extract_journey_strings.log")
        with open(log, "w") as f:
            f.write(console)
        raise SystemExit(
            f"No JRNYDUMP lines parsed (xcodebuild rc={rc}); dump file "
            f"{'empty' if dump_text else 'missing'} at {DUMP_FILE}. Console -> {log}")
    return items, meta_count


def gather():
    """Ordered, globally key-deduped narration strings for build_journey_audio.py.
    Re-derives from the app's real narration logic every call (never a stale cache)."""
    items, _ = _extract()
    return dedupe(items)


def main():
    items, meta_count = _extract()
    deduped = dedupe(items)

    per = OrderedDict()
    for it in items:
        per[it["journey"]] = per.get(it["journey"], 0) + 1

    print("Per-journey .speech counts (timeline order):")
    for j, n in per.items():
        print(f"  {n:>4}  {j}")
    print(f"\n{len(items)} total strings across {len(per)} journeys; "
          f"{len(deduped)} unique keys (global content-hash dedup)")
    if meta_count is not None and meta_count != len(per):
        print(f"  WARNING: dump meta count {meta_count} != parsed journeys {len(per)} "
              f"(dump may be partial - some journeys missing)")

    manifest_path = os.path.join(ROOT, "scripts", "journey_audio_manifest.json")
    with open(manifest_path, "w") as f:
        json.dump(deduped, f, ensure_ascii=False, indent=2)
    print(f"wrote {manifest_path}")


if __name__ == "__main__":
    main()
