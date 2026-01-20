#!/usr/bin/env python3
"""
Verify that all quickoverview_{surah}_complete.json files have data for all verses.

Usage:
    python3 verify_qo_complete.py
    python3 verify_qo_complete.py --verbose
    python3 verify_qo_complete.py --surah 2 84 89  # Check specific surahs only
"""

import json
import os
import sys
from glob import glob
from pathlib import Path

# Verse counts for all 114 surahs
SURAH_VERSE_COUNTS = {
    1: 7, 2: 286, 3: 200, 4: 176, 5: 120, 6: 165, 7: 206, 8: 75, 9: 129, 10: 109,
    11: 123, 12: 111, 13: 43, 14: 52, 15: 99, 16: 128, 17: 111, 18: 110, 19: 98, 20: 135,
    21: 112, 22: 78, 23: 118, 24: 64, 25: 77, 26: 227, 27: 93, 28: 88, 29: 69, 30: 60,
    31: 34, 32: 30, 33: 73, 34: 54, 35: 45, 36: 83, 37: 182, 38: 88, 39: 75, 40: 85,
    41: 54, 42: 53, 43: 89, 44: 59, 45: 37, 46: 35, 47: 38, 48: 29, 49: 18, 50: 45,
    51: 60, 52: 49, 53: 62, 54: 55, 55: 78, 56: 96, 57: 29, 58: 22, 59: 24, 60: 13,
    61: 14, 62: 11, 63: 11, 64: 18, 65: 12, 66: 12, 67: 30, 68: 52, 69: 52, 70: 44,
    71: 28, 72: 28, 73: 20, 74: 56, 75: 40, 76: 31, 77: 50, 78: 40, 79: 46, 80: 42,
    81: 29, 82: 19, 83: 36, 84: 25, 85: 22, 86: 17, 87: 19, 88: 26, 89: 30, 90: 20,
    91: 15, 92: 21, 93: 11, 94: 8, 95: 8, 96: 19, 97: 5, 98: 8, 99: 8, 100: 11,
    101: 11, 102: 8, 103: 3, 104: 9, 105: 5, 106: 4, 107: 7, 108: 3, 109: 6, 110: 3,
    111: 5, 112: 4, 113: 5, 114: 6
}

SURAH_NAMES = {
    1: "Al-Fatiha", 2: "Al-Baqarah", 3: "Aal-Imran", 4: "An-Nisa", 5: "Al-Ma'idah",
    6: "Al-An'am", 7: "Al-A'raf", 8: "Al-Anfal", 9: "At-Tawbah", 10: "Yunus",
    11: "Hud", 12: "Yusuf", 13: "Ar-Ra'd", 14: "Ibrahim", 15: "Al-Hijr",
    16: "An-Nahl", 17: "Al-Isra", 18: "Al-Kahf", 19: "Maryam", 20: "Ta-Ha",
    21: "Al-Anbiya", 22: "Al-Hajj", 23: "Al-Mu'minun", 24: "An-Nur", 25: "Al-Furqan",
    26: "Ash-Shu'ara", 27: "An-Naml", 28: "Al-Qasas", 29: "Al-Ankabut", 30: "Ar-Rum",
    31: "Luqman", 32: "As-Sajdah", 33: "Al-Ahzab", 34: "Saba", 35: "Fatir",
    36: "Ya-Sin", 37: "As-Saffat", 38: "Sad", 39: "Az-Zumar", 40: "Ghafir",
    41: "Fussilat", 42: "Ash-Shura", 43: "Az-Zukhruf", 44: "Ad-Dukhan", 45: "Al-Jathiyah",
    46: "Al-Ahqaf", 47: "Muhammad", 48: "Al-Fath", 49: "Al-Hujurat", 50: "Qaf",
    51: "Adh-Dhariyat", 52: "At-Tur", 53: "An-Najm", 54: "Al-Qamar", 55: "Ar-Rahman",
    56: "Al-Waqi'ah", 57: "Al-Hadid", 58: "Al-Mujadila", 59: "Al-Hashr", 60: "Al-Mumtahanah",
    61: "As-Saff", 62: "Al-Jumu'ah", 63: "Al-Munafiqun", 64: "At-Taghabun", 65: "At-Talaq",
    66: "At-Tahrim", 67: "Al-Mulk", 68: "Al-Qalam", 69: "Al-Haqqah", 70: "Al-Ma'arij",
    71: "Nuh", 72: "Al-Jinn", 73: "Al-Muzzammil", 74: "Al-Muddaththir", 75: "Al-Qiyamah",
    76: "Al-Insan", 77: "Al-Mursalat", 78: "An-Naba", 79: "An-Nazi'at", 80: "Abasa",
    81: "At-Takwir", 82: "Al-Infitar", 83: "Al-Mutaffifin", 84: "Al-Inshiqaq", 85: "Al-Buruj",
    86: "At-Tariq", 87: "Al-A'la", 88: "Al-Ghashiyah", 89: "Al-Fajr", 90: "Al-Balad",
    91: "Ash-Shams", 92: "Al-Layl", 93: "Ad-Duha", 94: "Ash-Sharh", 95: "At-Tin",
    96: "Al-Alaq", 97: "Al-Qadr", 98: "Al-Bayyinah", 99: "Az-Zalzalah", 100: "Al-Adiyat",
    101: "Al-Qari'ah", 102: "At-Takathur", 103: "Al-Asr", 104: "Al-Humazah", 105: "Al-Fil",
    106: "Quraysh", 107: "Al-Ma'un", 108: "Al-Kawthar", 109: "Al-Kafirun", 110: "An-Nasr",
    111: "Al-Masad", 112: "Al-Ikhlas", 113: "Al-Falaq", 114: "An-Nas"
}


def verify_complete_file(filepath: str, verbose: bool = False) -> dict:
    """
    Verify a single quickoverview complete file.

    Returns:
        dict with keys: surah, expected, found, missing, extra, valid, error
    """
    filename = Path(filepath).name

    # Extract surah number from filename
    import re
    match = re.search(r'quickoverview_(\d+)_complete\.json', filename)
    if not match:
        return {"error": f"Could not parse surah number from {filename}"}

    surah_num = int(match.group(1))
    expected_count = SURAH_VERSE_COUNTS.get(surah_num)

    if not expected_count:
        return {"error": f"Unknown surah number: {surah_num}"}

    # Load and verify the file
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        return {"surah": surah_num, "error": f"JSON parse error: {e}"}
    except Exception as e:
        return {"surah": surah_num, "error": str(e)}

    # Get verse numbers from file (filter non-numeric keys)
    found_verses = set()
    for key in data.keys():
        if key.isdigit():
            found_verses.add(int(key))

    # Expected verses
    expected_verses = set(range(1, expected_count + 1))

    # Calculate differences
    missing = expected_verses - found_verses
    extra = found_verses - expected_verses

    result = {
        "surah": surah_num,
        "name": SURAH_NAMES.get(surah_num, "Unknown"),
        "expected": expected_count,
        "found": len(found_verses),
        "missing": sorted(missing) if missing else [],
        "extra": sorted(extra) if extra else [],
        "valid": len(missing) == 0 and len(extra) == 0
    }

    # Check for quickOverview data quality if verbose
    if verbose:
        verses_without_concepts = []
        total_concepts = 0
        for verse_num in sorted(found_verses):
            verse_data = data.get(str(verse_num), {})
            qo = verse_data.get('quickOverview', {})
            concepts = qo.get('concepts', [])
            if not concepts:
                verses_without_concepts.append(verse_num)
            total_concepts += len(concepts)

        result["total_concepts"] = total_concepts
        result["avg_concepts_per_verse"] = round(total_concepts / len(found_verses), 2) if found_verses else 0
        result["verses_without_concepts"] = verses_without_concepts

    return result


def group_consecutive(numbers: list) -> list:
    """Group consecutive numbers into ranges."""
    if not numbers:
        return []

    ranges = []
    start = numbers[0]
    end = start

    for num in numbers[1:]:
        if num == end + 1:
            end = num
        else:
            ranges.append((start, end))
            start = num
            end = num
    ranges.append((start, end))

    return ranges


def format_ranges(numbers: list) -> str:
    """Format a list of numbers as ranges string."""
    if not numbers:
        return "none"

    ranges = group_consecutive(numbers)
    parts = []
    for start, end in ranges:
        if start == end:
            parts.append(str(start))
        else:
            parts.append(f"{start}-{end}")
    return ", ".join(parts)


def main():
    verbose = '--verbose' in sys.argv or '-v' in sys.argv

    # Check for specific surahs
    specific_surahs = []
    if '--surah' in sys.argv:
        idx = sys.argv.index('--surah')
        for arg in sys.argv[idx + 1:]:
            if arg.startswith('-'):
                break
            try:
                specific_surahs.append(int(arg))
            except ValueError:
                continue

    # Find all complete files
    qo_dir = Path(__file__).parent / "new_tafsir" / "quickoverview"

    if not qo_dir.exists():
        print(f"Error: Directory not found: {qo_dir}")
        sys.exit(1)

    files = sorted(glob(str(qo_dir / "quickoverview_*_complete.json")))

    if not files:
        print(f"No quickoverview_*_complete.json files found in {qo_dir}")
        sys.exit(1)

    # Filter to specific surahs if requested
    if specific_surahs:
        files = [f for f in files if any(f"quickoverview_{s}_complete.json" in f for s in specific_surahs)]

    print(f"Verifying {len(files)} quickoverview complete file(s)...\n")

    valid_count = 0
    invalid_count = 0
    error_count = 0
    missing_surahs = []

    results = []

    for filepath in files:
        result = verify_complete_file(filepath, verbose)
        results.append(result)

        if 'error' in result and 'surah' not in result:
            print(f"❌ {Path(filepath).name}: {result['error']}")
            error_count += 1
            continue

        surah = result['surah']
        name = result.get('name', '')

        if 'error' in result:
            print(f"❌ Surah {surah} ({name}): {result['error']}")
            error_count += 1
            continue

        if result['valid']:
            if verbose:
                print(f"✅ Surah {surah} ({name}): {result['found']}/{result['expected']} verses")
                print(f"   Total concepts: {result['total_concepts']}, Avg: {result['avg_concepts_per_verse']}/verse")
                if result['verses_without_concepts']:
                    print(f"   ⚠️  Verses without concepts: {format_ranges(result['verses_without_concepts'])}")
            else:
                print(f"✅ Surah {surah} ({name}): {result['found']}/{result['expected']} verses - OK")
            valid_count += 1
        else:
            print(f"❌ Surah {surah} ({name}): {result['found']}/{result['expected']} verses")
            if result['missing']:
                print(f"   Missing: {format_ranges(result['missing'])}")
            if result['extra']:
                print(f"   Extra: {format_ranges(result['extra'])}")
            invalid_count += 1

    # Check which surahs don't have complete files
    existing_surahs = set()
    for r in results:
        if 'surah' in r:
            existing_surahs.add(r['surah'])

    all_surahs = set(range(1, 115))
    missing_complete_files = all_surahs - existing_surahs

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Total files checked: {len(files)}")
    print(f"  ✅ Valid: {valid_count}")
    print(f"  ❌ Invalid: {invalid_count}")
    if error_count:
        print(f"  ⚠️  Errors: {error_count}")

    if missing_complete_files and not specific_surahs:
        print(f"\nSurahs without complete files ({len(missing_complete_files)}):")
        print(f"  {format_ranges(sorted(missing_complete_files))}")

    # Return exit code
    sys.exit(0 if invalid_count == 0 and error_count == 0 else 1)


if __name__ == "__main__":
    main()
