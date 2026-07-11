#!/usr/bin/env python3
"""
strip_diacritics.py - Remove academic Arabic transliteration diacritics from
English-facing text, converting to plain English spelling.

Two modes:
  --report   Scan files, print every unique diacritic-bearing token and its
             mechanical (no-exception) result. Writes nothing. Use this to
             build / adjust the exception list below.
  --apply    Apply the curated exceptions (whole-word) then the mechanical
             rules, writing files back in place (UTF-8, no normalization).

Rules:
  * Macron vowels and under-dotted consonants -> their base Latin letter
    (a i u h s d t z), preserving case.
  * ayn (U+02BF) and hamza (U+02BE) -> a straight apostrophe ' when the mark
    sits BETWEEN two letters, otherwise removed (dropped at a word boundary,
    because "'Imran" reads wrong).
  * A short curated EXCEPTIONS map fixes tokens whose mechanical result reads
    non-standard (e.g. the leading-ayn drop turning "Eid" into "Id").

Safety:
  Only the specific Latin transliteration codepoints in TARGET_CHARS are ever
  rewritten. Real Arabic / Urdu script lives in U+0600-06FF (plus the sallam
  ligature etc.) and uses entirely different codepoints, so it is never
  touched - this is why running over whole files is English-only by
  construction. No Unicode NFC/NFD normalization is performed and files are
  written back verbatim, so authored Arabic verse text stays byte-identical.

Usage:
  python3 scripts/strip_diacritics.py --report [files...]
  python3 scripts/strip_diacritics.py --apply  [files...]
If no files are given, the built-in PHASE 1 (Journey area) list is used.
"""

import argparse
import re
import sys
from collections import Counter
from pathlib import Path

# --- Mechanical character map: diacritic -> base letter --------------------
CHAR_MAP = {
    "ā": "a", "Ā": "A",   # a-macron   ā Ā
    "ī": "i", "Ī": "I",   # i-macron   ī Ī
    "ū": "u", "Ū": "U",   # u-macron   ū Ū
    "ḥ": "h", "Ḥ": "H",   # h-underdot ḥ Ḥ
    "ṣ": "s", "Ṣ": "S",   # s-underdot ṣ Ṣ
    "ḍ": "d", "Ḍ": "D",   # d-underdot ḍ Ḍ
    "ṭ": "t", "Ṭ": "T",   # t-underdot ṭ Ṭ
    "ẓ": "z", "Ẓ": "Z",   # z-underdot ẓ Ẓ
}
AYN = "ʿ"    # ʿ  modifier letter left half ring
HAMZA = "ʾ"  # ʾ  modifier letter right half ring
APOS = "'"        # straight apostrophe for ayn/hamza kept between two letters

TARGET_CHARS = set(CHAR_MAP) | {AYN, HAMZA}

# --- Curated exceptions (whole-word, case-sensitive) -----------------------
# Applied BEFORE the mechanical pass. Keys are the ORIGINAL diacritic tokens;
# values the conventional English spelling. Populated after the report-mode
# review gate - keep it minimal.
EXCEPTIONS = {
    "Ṣād": "Saad",            # Surah Sad (38): avoid the English word "sad" in the "Ṣād · 38 : 44" reference
    "Ṭabāṭabāʾī": "Tabatabai",  # established English spelling of the mufassir (house style)
}

# --- Phase 1 scope: the whole Journey / immersive area ---------------------
# Paths are relative to the repo root (this script lives in scripts/).
PHASE1_FILES = [
    # Seasonal journeys (JSON content)
    "Thaqalayn/Data/ramadan_journey.json",
    "Thaqalayn/Data/hajj_journey.json",
    "Thaqalayn/Data/muharram_journey.json",
    "Thaqalayn/Data/fatimiyya_journey.json",
    "Thaqalayn/Data/arbaeen_journey.json",
    # Deep Dives + Inside the Surah (inline Swift content)
    "Thaqalayn/Content/YaqinDeepDive.swift",
    "Thaqalayn/Content/SabrDeepDive.swift",
    "Thaqalayn/Content/SurahFatihaDive.swift",
    "Thaqalayn/Content/SurahBaqaraDive.swift",
    "Thaqalayn/Content/SurahAliImranDive.swift",
    "Thaqalayn/Content/SurahYusufDive.swift",
    # Catalogs (incl. coming-soon card copy)
    "Thaqalayn/Services/DeepDiveCatalog.swift",
    "Thaqalayn/Services/SurahExperienceCatalog.swift",
    # Onboarding teasers
    "Thaqalayn/Views/Onboarding/DeepDiveScreen.swift",
    "Thaqalayn/Views/Onboarding/SurahExperienceScreen.swift",
    # Renderer (two "Amin" UI strings + preview/comment text)
    "Thaqalayn/Views/DeepDive/DeepDiveView.swift",
    # Today-tab spotlight entries for these features
    "Thaqalayn/Models/WhatsNewItem.swift",
    # Journey-tab chrome strings
    "Thaqalayn/Utilities/JourneyStrings.swift",
]


def is_letter(ch):
    """Counts as a 'letter' for the ayn/hamza between-letters rule.
    Excludes the ayn/hamza modifiers themselves so a rare pairing drops."""
    return bool(ch) and ch.isalpha() and ch not in (AYN, HAMZA)


def mechanical(text):
    """Apply the deterministic character rules (no exceptions).
    Neighbour lookups read the ORIGINAL text, so the ayn/hamza context test is
    independent of substitution order."""
    out = []
    n = len(text)
    for i, ch in enumerate(text):
        mapped = CHAR_MAP.get(ch)
        if mapped is not None:
            out.append(mapped)
        elif ch == AYN or ch == HAMZA:
            prev = text[i - 1] if i > 0 else None
            nxt = text[i + 1] if i + 1 < n else None
            if is_letter(prev) and is_letter(nxt):
                out.append(APOS)
            # else: drop the mark at the word boundary
        else:
            out.append(ch)
    return "".join(out)


def apply_exceptions(text):
    """Whole-word replace of curated exception tokens (longest key first).
    Python's \\w (unicode) includes the diacritic letters and the ayn/hamza
    modifiers, so these boundaries isolate whole tokens correctly."""
    for key in sorted(EXCEPTIONS, key=len, reverse=True):
        text = re.sub(r"(?<!\w)" + re.escape(key) + r"(?!\w)",
                      EXCEPTIONS[key], text)
    return text


def transform(text):
    return mechanical(apply_exceptions(text))


# A token = a run of characters that is not whitespace, a quote, a bracket, or
# terminal punctuation. Hyphens and straight apostrophes stay inside a token so
# "al-Ṣādiq" and "Qur'an" report as single units.
TOKEN_RE = re.compile(
    r"[^\s\"“”‘’(),.;:!?/\\\[\]{}<>|*=&]+"
)


def iter_target_tokens(text):
    for m in TOKEN_RE.finditer(text):
        tok = m.group()
        if any(c in TARGET_CHARS for c in tok):
            yield tok


def count_targets(text):
    return sum(text.count(c) for c in TARGET_CHARS)


def cmd_report(files):
    counter = Counter()
    for f in files:
        counter.update(iter_target_tokens(Path(f).read_text(encoding="utf-8")))
    print(f"# Diacritic token report over {len(files)} files\n")
    print(f"{'count':>5}  {'original':<26}  {'-> mechanical':<26}")
    print("-" * 62)
    # sort: most frequent first, then alphabetical
    for tok, cnt in sorted(counter.items(), key=lambda kv: (-kv[1], kv[0])):
        print(f"{cnt:>5}  {tok:<26}  {mechanical(tok):<26}")
    print(f"\nUnique diacritic tokens: {len(counter)}  |  "
          f"total occurrences: {sum(counter.values())}")


def cmd_apply(files):
    total_before = 0
    any_remaining = False
    for f in files:
        p = Path(f)
        before = p.read_text(encoding="utf-8")
        after = transform(before)
        before_ct = count_targets(before)
        after_ct = count_targets(after)
        total_before += before_ct
        if after_ct:
            any_remaining = True
        if after != before:
            p.write_text(after, encoding="utf-8")
            state = "CHANGED"
        else:
            state = "unchanged"
        rel = f.split("/Thaqalayn/", 1)[-1] if "/Thaqalayn/" in f else f
        print(f"{state:<10} {rel:<46} diacritics {before_ct:>4} -> {after_ct}")
    print(f"\nTotal diacritics processed: {total_before}")
    if any_remaining:
        print("WARNING: some target diacritics remain - investigate.",
              file=sys.stderr)
        sys.exit(2)


def main():
    ap = argparse.ArgumentParser(
        description="Strip Arabic transliteration diacritics from English text.")
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--report", action="store_true",
                      help="scan and print tokens; write nothing")
    mode.add_argument("--apply", action="store_true",
                      help="rewrite files in place")
    ap.add_argument("files", nargs="*",
                    help="files to process (default: phase-1 journey-area list)")
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    raw = args.files or PHASE1_FILES
    files = [f if Path(f).is_absolute() else str(root / f) for f in raw]

    missing = [f for f in files if not Path(f).exists()]
    if missing:
        print("ERROR: missing files:\n  " + "\n  ".join(missing), file=sys.stderr)
        sys.exit(1)

    if args.report:
        cmd_report(files)
    else:
        cmd_apply(files)


if __name__ == "__main__":
    main()
