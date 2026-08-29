#!/usr/bin/env python3
"""Seed realistic reading-progress + quiz data into the simulator app's UserDefaults.

Encodes exactly what Swift's JSONEncoder (default strategies) produces:
Dates as seconds since 2001-01-01, UUIDs as uppercase strings, enums as rawValue.
"""
import json, random, subprocess, sys, time, uuid
from datetime import datetime, timedelta, timezone

UDID = "F6AC3A2C-5114-4542-ADC0-6374AE92DA52"
BUNDLE = "MAHR.Partner.Thaqalayn"
ROOT = "/Users/muhammadimranali/Documents/development/thaqalyn"

random.seed(7)
REF = datetime(2001, 1, 1, tzinfo=timezone.utc)
def ts(dt): return (dt - REF).total_seconds()
now = datetime.now(timezone.utc)
today9 = now.replace(hour=9, minute=41 - 9 if now.hour > 9 else 0, second=0, microsecond=0)
def day(n, hour=7, minute=None):  # n days ago
    m = random.randint(0, 59) if minute is None else minute
    return (now - timedelta(days=n)).replace(hour=hour, minute=m, second=random.randint(0, 59), microsecond=0)

surahs = {s["number"]: s for s in json.load(open(f"{ROOT}/quran_data.json"))["surahs"]}

# Reading history: completed surahs (oldest first) + partial ones
completed = [1, 112, 113, 114, 109, 108, 103, 97, 94, 93, 91, 87, 78, 76, 73, 67, 56, 55, 36]
partial = {2: 230, 3: 120, 4: 95, 7: 80, 18: 60, 12: 52}   # surah -> verses read so far
verse_progress, badges = [], []
stats_sawab = 0

# spread completions across the last ~70 days
completion_days = sorted(random.sample(range(2, 70), len(completed)), reverse=True)
for n, d in zip(completed, completion_days):
    s = surahs[n]
    for v in range(1, s["versesCount"] + 1):
        verse_progress.append({"id": str(uuid.uuid4()).upper(), "surahNumber": n, "verseNumber": v,
                               "readDate": ts(day(d, hour=random.choice([6, 7, 21, 22]))), "isRead": True})
        stats_sawab += 10
    badges.append({"id": str(uuid.uuid4()).upper(), "surahNumber": n, "surahName": s["englishName"],
                   "arabicName": s["arabicName"], "awardedDate": ts(day(d, hour=22)), "badgeType": "surah_completion"})
    stats_sawab += 100
    if len([b for b in badges if b["badgeType"] == "surah_completion"]) == 10:
        badges.append({"id": str(uuid.uuid4()).upper(), "surahNumber": 0, "surahName": "Mubtadi",
                       "arabicName": "المبتدئ", "awardedDate": ts(day(d, hour=22, minute=5)), "badgeType": "milestone_10"})
        stats_sawab += 1000

# partial surahs: spread over the last 12 days (the streak), the newest verses today
for n, upto in partial.items():
    for v in range(1, upto + 1):
        d = 0 if (n == 12 and v > 40) else random.randint(1, 11)
        verse_progress.append({"id": str(uuid.uuid4()).upper(), "surahNumber": n, "verseNumber": v,
                               "readDate": ts(day(d, hour=6 if d else 8)), "isRead": True})
        stats_sawab += 10

# streak badge (7 days) awarded inside the current streak
badges.append({"id": str(uuid.uuid4()).upper(), "surahNumber": 0, "surahName": "Mu'min Mutaqin",
               "arabicName": "مؤمن متقين", "awardedDate": ts(day(5, hour=7)), "badgeType": "streak_7"})
stats_sawab += 700

# Quiz results (surahs already completed), mostly strong scores
quiz_scores = {1: (10, 10), 112: (5, 5), 114: (5, 5), 36: (18, 20), 67: (9, 10), 55: (17, 20),
               76: (8, 10), 78: (10, 10), 97: (5, 5), 91: (7, 8), 56: (16, 20), 108: (5, 5),
               113: (5, 5), 109: (7, 8), 103: (4, 5), 93: (8, 8)}
def level(score, total):
    p = score / total
    return "hafiz" if p == 1 else "scholar" if p >= .8 else "student" if p >= .6 else "seeker" if p >= .4 else "beginner"
quiz_results = []
for n, (sc, tot) in quiz_scores.items():
    sawab = 50 + sc * 10 + (100 if sc == tot else 0)
    stats_sawab += sawab
    d = random.randint(1, 60)
    quiz_results.append({"id": str(uuid.uuid4()).upper(), "surahNumber": n, "score": sc, "totalQuestions": tot,
                         "level": level(sc, tot), "sawabEarned": sawab, "completedAt": ts(day(d, hour=21))})
# One earlier attempt on Yusuf so the quiz intro shows a "best score"
quiz_results.append({"id": str(uuid.uuid4()).upper(), "surahNumber": 12, "score": 15, "totalQuestions": 20,
                     "level": "student", "sawabEarned": 200, "completedAt": ts(day(9, hour=21))})
stats_sawab += 200

current_streak, longest_streak = 12, 27
streak = {"currentStreak": current_streak, "longestStreak": longest_streak,
          "lastReadDate": ts(day(0, hour=8)), "streakStartDate": ts(day(current_streak - 1, hour=6))}
stats = {"totalVersesRead": len(verse_progress), "totalSurahsCompleted": len(completed),
         "currentStreak": current_streak, "longestStreak": longest_streak,
         "versesReadToday": 12, "lastReadDate": ts(day(0, hour=8)), "startDate": ts(day(84, hour=9)),
         "totalSawab": stats_sawab}
prefs = {"notificationsEnabled": True, "celebrationsEnabled": True, "showStreakInHeader": True}

import base64
container = subprocess.run(["xcrun", "simctl", "get_app_container", UDID, BUNDLE, "data"],
                           capture_output=True, text=True, check=True).stdout.strip()
PLIST = f"{container}/Library/Preferences/{BUNDLE}.plist"

def write(key, obj):
    raw = json.dumps(obj, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    # sim-root domain (what `simctl spawn defaults` sees) ...
    subprocess.run(["xcrun", "simctl", "spawn", UDID, "defaults", "write", BUNDLE, key, "-data", raw.hex()], check=True)
    # ... and the app container plist, which is what the app actually reads once the key exists there
    subprocess.run(["plutil", "-replace", key, "-data", base64.b64encode(raw).decode(), PLIST], check=True)

write("verseProgress", verse_progress)
write("readingStreak", streak)
write("badgeAwards", badges)
write("progressStats", stats)
write("progressPreferences", prefs)
write("quizResults", quiz_results)
subprocess.run(["xcrun", "simctl", "spawn", UDID, "defaults", "write", BUNDLE, "awardedQuizBadges",
                "-array", "first_quiz", "perfect_score", "quiz_master_10"], check=True)

print(f"verses={len(verse_progress)} surahs={len(completed)} badges={len(badges)} "
      f"quizzes={len(set(r['surahNumber'] for r in quiz_results))} sawab={stats_sawab}")
