#!/usr/bin/env python3
"""Seed one passage as fully complete (read, understood, full quiz marks) into a
simulator's app UserDefaults, for the passage-hub App Store shot.

  python3 seed_passage.py <UDID> [surah] [index]      # default: al-Fatiha 1:1

Writes through the simulator's own cfprefsd (simctl spawn defaults) against the
app container plist, so the running app must be terminated first. Keeps any
existing verse progress and adds the passage's verses to it.
"""
import base64, json, subprocess, sys, uuid
from datetime import datetime, timedelta, timezone

UDID = sys.argv[1]
SURAH = int(sys.argv[2]) if len(sys.argv) > 2 else 1
INDEX = int(sys.argv[3]) if len(sys.argv) > 3 else 1
BUNDLE = "MAHR.Partner.Thaqalayn"
ROOT = "/Users/muhammadimranali/Documents/development/thaqalyn"

REF = datetime(2001, 1, 1, tzinfo=timezone.utc)
def ts(dt): return (dt - REF).total_seconds()
now = datetime.now(timezone.utc)

# Passage verse range from the shipped passage file (index is 1-based).
passages = json.load(open(f"{ROOT}/Thaqalayn/Thaqalayn/Data/passages_{SURAH}.json"))
start, end = passages[str(INDEX)]["range"]

container = subprocess.run(["xcrun", "simctl", "get_app_container", UDID, BUNDLE, "data"],
                           capture_output=True, text=True, check=True).stdout.strip()
DOMAIN = f"{container}/Library/Preferences/{BUNDLE}"   # defaults(1) appends .plist

def read(key):
    r = subprocess.run(["xcrun", "simctl", "spawn", UDID, "defaults", "export", DOMAIN, "-"],
                       capture_output=True, check=True)
    import plistlib
    return plistlib.loads(r.stdout).get(key)

def write_data(key, obj):
    raw = json.dumps(obj, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    subprocess.run(["xcrun", "simctl", "spawn", UDID, "defaults", "write", DOMAIN, key, "-data", raw.hex()], check=True)

# 1. Read the verses: add every verse of the passage to verseProgress.
existing = read("verseProgress")
verse_progress = json.loads(existing) if existing else []
have = {(v["surahNumber"], v["verseNumber"]) for v in verse_progress if v.get("isRead")}
for v in range(start, end + 1):
    if (SURAH, v) in have: continue
    verse_progress.append({"id": str(uuid.uuid4()).upper(), "surahNumber": SURAH, "verseNumber": v,
                           "readDate": ts(now - timedelta(minutes=30) + timedelta(seconds=10 * v)), "isRead": True})
write_data("verseProgress", verse_progress)

# 2. Understand: passageUnderstood is a plain string array of "surah:index".
understood = set(read("passageUnderstood") or [])
understood.add(f"{SURAH}:{INDEX}")
subprocess.run(["xcrun", "simctl", "spawn", UDID, "defaults", "write", DOMAIN, "passageUnderstood",
                "-array", *sorted(understood)], check=True)

# 3. Test yourself: passageQuizBest is JSON data keyed "surah:index".
quiz_raw = read("passageQuizBest")
best = json.loads(quiz_raw) if quiz_raw else {}
total = len(json.load(open(f"{ROOT}/Thaqalayn/Thaqalayn/Data/quiz_{SURAH}.json"))[str(INDEX)]["questions"])
best[f"{SURAH}:{INDEX}"] = {"surah": SURAH, "index": INDEX, "score": total, "total": total,
                            "completedAt": ts(now - timedelta(minutes=5))}
write_data("passageQuizBest", best)

print(f"seeded {SURAH}:{INDEX} verses {start}-{end}: read={len(verse_progress)} understood={sorted(understood)} quiz={best[f'{SURAH}:{INDEX}']}")
