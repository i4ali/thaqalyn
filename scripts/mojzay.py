#!/usr/bin/env python3
"""
mojzay.py - pipeline for the "Miracle Stories" feature: the sixteen miracles of
the Urdu book "14 Mojzay" (A. H. Rizvi), retold in our own words in English, then
rendered into Urdu from our English.

The book is copyrighted, so the scanned pages live only in mojzay_work/
(gitignored) and the app ships nothing but the retellings.

Subcommands:
  fetch                 download the PDF to mojzay_work/source/
  pages [nn ...]        render each miracle's scans at 144 dpi and split every
                        two-page scan at its gutter, one PNG per book page
  check nn [--stage S]  validate mojzay_work/<nn>-<id>/draft.json at a stage:
                        beats (reader done), en (writer done), full (default, Urdu merged)
  ur-apply nn           merge mojzay_work/<nn>-<id>/ur.json (the Urdu translator's
                        output) into the draft; the English is never touched
  next-attempt nn       print the number for the next audit.<n>.json
  audit-check nn        validate the latest audit; on PASS record approved.json
  restamp nn --reason R re-approve an approved miracle after a word-level fix that
                        applies the auditor's own quoted reading of the book; the
                        fix and reason are logged on approved.json (post_audit_edits)
  status                one line per miracle: draft, Urdu, audits, approval
  assemble              write Thaqalayn/Data/miracle_stories.json (every miracle approved)

Draft (mojzay_work/<nn>-<id>/draft.json):
  {"story": "01", "id": "sayyida-1", "pages": [7, 10],
   "beats": [{"page": 7, "event": "..."}],
   "figure": {"en": "...", "ur": "..."}, "title": {...}, "subtitle": {...},
   "body": {"en": ["paragraph", ...], "ur": ["paragraph", ...]},
   "closing": {"en": ["paragraph", ...], "ur": [...]}}      <- miracle 3 only
The reader fills beats and figure.en from the page images; the writer, who never
sees the pages, fills title, subtitle, body and closing "en" from the beats alone,
so the English cannot follow the book's sentences. The Urdu translator writes ur.json
  {"figure": "...", "title": "...", "subtitle": "...", "body": [...], "closing": [...]}
and ur-apply copies it into every "ur", stamping "ur_from" with a hash of the
English it was made from, so an English change afterwards marks the Urdu stale.

Every paragraph has a key the audit refers to: "body.1", "body.2", ... "closing.1".

Usage:
  .venv/bin/python scripts/mojzay.py pages 01
  .venv/bin/python scripts/mojzay.py check 01 --stage en
"""

import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from scripts.strip_diacritics import TARGET_CHARS  # noqa: E402

WORK = ROOT / "mojzay_work"
PDF_URL = "https://www.ziyaraat.net/books/14Mojzay.pdf"
PDF_PATH = WORK / "source" / "14Mojzay.pdf"
PDF_SIZE = 8_628_099
OUTPUT = ROOT / "Thaqalayn" / "Data" / "miracle_stories.json"
DPI = 144

# The book numbers 16 miracles (the original 14 plus two additions) under nine
# headings. One entry per miracle: (number, id, first book page, last book page,
# the book's ordinal label that opens it). A miracle can start or end mid-page;
# its text runs from its own label to the next label or closing ornament.
STORIES = [
    ("01", "sayyida-1", 7, 10, "پہلا معجزہ"),
    ("02", "sayyida-2", 10, 16, "دوسرا معجزہ"),
    ("03", "imam-ali", 17, 21, "تیسرا معجزہ"),
    ("04", "imam-husayn-1", 22, 25, "چوتھا معجزہ"),
    ("05", "imam-husayn-2", 25, 27, "پانچواں معجزہ"),
    ("06", "imam-husayn-3", 27, 30, "چھٹا معجزہ"),
    ("07", "imam-jafar-al-sadiq", 30, 34, "ساتواں معجزہ"),
    ("08", "imam-musa-al-kazim-1", 35, 38, "آٹھواں معجزہ"),
    ("09", "imam-musa-al-kazim-2", 39, 39, "نواں معجزہ"),
    ("10", "imam-musa-al-kazim-3", 40, 42, "دسواں معجزہ"),
    ("11", "das-bibiyan", 42, 51, "گیارھواں معجزہ"),
    ("12", "hazrat-abbas-1", 51, 51, "بارھواں معجزہ"),
    ("13", "hazrat-abbas-2", 52, 52, "تیرھواں معجزہ"),
    ("14", "hazrat-abbas-3", 52, 54, "چودھواں معجزہ"),
    ("15", "chatt-patt-bibi", 55, 58, "پندرھواں معجزہ"),
    ("16", "bab-ul-hawaij", 58, 62, "سولھواں معجزہ"),
]

# Only miracle 3 carries a closing: the book's short "how to make the vow"
# section (tarkeeb-e-nazr) that follows the Imam Ali story on page 21.
CLOSING = {"03"}

# The figures the list screen groups miracles under, in house spelling.
FIGURES = ("Sayyida Fatima", "Imam Ali", "Imam Husayn", "Imam Jafar al-Sadiq", "Imam Musa al-Kazim", "Hazrat Abbas")

NOTE = (
    "These are devotional stories long told in homes across the subcontinent, "
    "often read aloud when a vow is fulfilled. They are retold here in our own words "
    "from the Urdu book 14 Mojzay, compiled by A. H. Rizvi. They are cherished stories "
    "of faith, not narrations with a chain of transmission."
)

LOCALIZED_FIELDS = ("figure", "title", "subtitle")
DASHES = (chr(0x2014), chr(0x2013))  # em dash, en dash
HONORIFIC_ABBREVIATIONS = re.compile(r"\((?:a\.?s\.?|s\.?a\.?|pbuh|saw|saww|ajf|atfs)\)", re.IGNORECASE)
ARABIC_SCRIPT = re.compile(
    "[" + "".join(f"{chr(a)}-{chr(b)}" for a, b in ((0x0600, 0x06FF), (0x0750, 0x077F), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF))) + "]"
)
LATIN = re.compile(r"[A-Za-z]")
# Below this many English words per source page a retelling has almost certainly dropped events.
MIN_WORDS_PER_PAGE = 50

BEAT_VERDICTS = {"supported", "unsupported"}
ENGLISH_VERDICTS = {"faithful", "embellished", "wrong"}
URDU_VERDICTS = {"match", "mismatch"}


# --- helpers -----------------------------------------------------------------

def story(nn: str):
    nn = nn.zfill(2)
    for s in STORIES:
        if s[0] == nn:
            return s
    sys.exit(f"unknown miracle {nn}; expected 01-{len(STORIES):02d}")


def story_dir(s) -> Path:
    return WORK / f"{s[0]}-{s[1]}"


def draft_path(s) -> Path:
    return story_dir(s) / "draft.json"


def audits(s) -> list[Path]:
    found = []
    for p in story_dir(s).glob("audit.*.json"):
        m = re.fullmatch(r"audit\.(\d+)\.json", p.name)
        if m:
            found.append((int(m.group(1)), p))
    return [p for _, p in sorted(found)]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        sys.exit(f"missing {path.relative_to(ROOT)}")
    except json.JSONDecodeError as e:
        sys.exit(f"malformed {path.relative_to(ROOT)}: {e}")


def pdf_page_for(book_page: int) -> tuple[int, str]:
    """PDF page n (n >= 2) holds book page 2n-2 on its right half and 2n-1 on its left."""
    return book_page // 2 + 1, ("right" if book_page % 2 == 0 else "left")


def sections(s) -> tuple[str, ...]:
    return ("body", "closing") if s[0] in CLOSING else ("body",)


def paragraphs(d: dict, s, lang: str) -> dict[str, str]:
    """Every paragraph of the draft in one language, keyed "body.1" ... "closing.1"."""
    out = {}
    for section in sections(s):
        for i, text in enumerate((d.get(section) or {}).get(lang) or [], 1):
            out[f"{section}.{i}"] = text
    return out


def english_hash(d: dict, s) -> str:
    english = {f: (d.get(f) or {}).get("en") for f in LOCALIZED_FIELDS}
    english.update({sec: (d.get(sec) or {}).get("en") for sec in sections(s)})
    return hashlib.sha256(json.dumps(english, ensure_ascii=False, sort_keys=True).encode()).hexdigest()


# --- fetch / pages -------------------------------------------------------------

def cmd_fetch(_args):
    if PDF_PATH.exists() and PDF_PATH.stat().st_size == PDF_SIZE:
        print(f"already have {PDF_PATH.relative_to(ROOT)}")
        return 0
    PDF_PATH.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(PDF_URL, timeout=120) as r:
        data = r.read()
    if len(data) != PDF_SIZE:
        sys.exit(f"unexpected size {len(data)} (expected {PDF_SIZE}); the source file changed, re-check the page map")
    PDF_PATH.write_bytes(data)
    print(f"saved {PDF_PATH.relative_to(ROOT)} ({len(data)} bytes)")
    return 0


def gutter(img) -> int:
    """Column to split a two-page scan at: the middle of the widest blank column band
    in the central 30-70% of the width, or the exact middle when there is none."""
    import numpy as np

    gray = np.asarray(img.convert("L"), dtype=float)
    h, w = gray.shape
    ink = (255 - gray)[int(h * 0.05):int(h * 0.90)]
    dark = (ink > 60).sum(axis=0)
    lo, hi = int(w * 0.30), int(w * 0.70)
    best, start = None, None
    for x in range(lo, hi + 1):
        blank = x < hi and dark[x] <= 1
        if blank and start is None:
            start = x
        elif not blank and start is not None:
            if best is None or (x - 1 - start) > (best[1] - best[0]):
                best = (start, x - 1)
            start = None
    return (best[0] + best[1]) // 2 if best else w // 2


def cmd_pages(args):
    from PIL import Image

    if not PDF_PATH.exists():
        sys.exit("no PDF yet; run: scripts/mojzay.py fetch")
    chosen = [story(n) for n in args.stories] if args.stories else STORIES
    rendered: dict[int, Image.Image] = {}
    with tempfile.TemporaryDirectory() as tmp:
        for s in chosen:
            out = story_dir(s) / "pages"
            out.mkdir(parents=True, exist_ok=True)
            for book_page in range(s[2], s[3] + 1):
                pdf_page, half = pdf_page_for(book_page)
                if pdf_page not in rendered:
                    prefix = Path(tmp) / f"p{pdf_page}"
                    subprocess.run(
                        ["pdftoppm", "-r", str(DPI), "-png", "-singlefile",
                         "-f", str(pdf_page), "-l", str(pdf_page), str(PDF_PATH), str(prefix)],
                        check=True,
                    )
                    rendered[pdf_page] = Image.open(f"{prefix}.png").convert("RGB")
                spread = rendered[pdf_page]
                g = gutter(spread)
                box = (g, 0, spread.width, spread.height) if half == "right" else (0, 0, g, spread.height)
                spread.crop(box).save(out / f"p{book_page:03d}.png")
            print(f"{s[0]} {s[1]}: book pages {s[2]}-{s[3]} -> {out.relative_to(ROOT)}")
    return 0


# --- check -------------------------------------------------------------------

def english_problems(label: str, text: str) -> list[str]:
    problems = []
    bad = sorted({c for c in text if c in TARGET_CHARS})
    if bad:
        problems.append(f"{label}: transliteration diacritics {' '.join(bad)} (use plain spelling)")
    if any(d in text for d in DASHES):
        problems.append(f"{label}: em or en dash (use a plain dash or rephrase)")
    if HONORIFIC_ABBREVIATIONS.search(text):
        problems.append(f"{label}: honorific abbreviation like (as) - use the plain name")
    if ARABIC_SCRIPT.search(text):
        problems.append(f"{label}: Arabic-script text in an English field")
    if "[" in text or "]" in text:
        problems.append(f"{label}: square brackets")
    return problems


def urdu_problems(label: str, text: str) -> list[str]:
    problems = []
    arabic = len(ARABIC_SCRIPT.findall(text))
    latin = len(LATIN.findall(text))
    if arabic == 0 or latin > arabic * 0.05:
        problems.append(f"{label}: not Urdu script ({arabic} Arabic-script letters, {latin} Latin)")
    if any(d in text for d in DASHES):
        problems.append(f"{label}: em or en dash")
    return problems


def paragraph_list_problems(label: str, value, lang: str) -> list[str]:
    if not isinstance(value, list) or not value or not all(isinstance(p, str) and p.strip() for p in value):
        return [f"{label}: needs a list of non-empty paragraphs"]
    problems = []
    for i, p in enumerate(value, 1):
        problems += english_problems(f"{label}[{i}]", p) if lang == "en" else urdu_problems(f"{label}[{i}]", p)
        if "\n" in p:
            problems.append(f"{label}[{i}]: line break inside a paragraph")
    return problems


def draft_problems(s, d: dict, stage: str) -> list[str]:
    problems = []
    nn, sid, first, last, _label = s
    if d.get("story") != nn or d.get("id") != sid:
        problems.append(f"story/id must be {nn!r}/{sid!r}")
    if d.get("pages") != [first, last]:
        problems.append(f"pages must be [{first}, {last}]")

    beats = d.get("beats")
    if not isinstance(beats, list) or not beats:
        problems.append("beats: missing or empty")
    else:
        for i, b in enumerate(beats, 1):
            if not isinstance(b, dict) or not isinstance(b.get("page"), int) or not str(b.get("event", "")).strip():
                problems.append(f"beats[{i}]: needs an int page and an event")
                continue
            if not first <= b["page"] <= last:
                problems.append(f"beats[{i}]: page {b['page']} outside {first}-{last}")
            problems += english_problems(f"beats[{i}]", b["event"])
        pages = [b.get("page") for b in beats if isinstance(b, dict) and isinstance(b.get("page"), int)]
        if pages != sorted(pages):
            problems.append("beats: not in page order")
        missing = sorted(set(range(first, last + 1)) - set(pages))
        if missing:
            problems.append(f"beats: no beat from page(s) {missing}")

    figure = (d.get("figure") or {}).get("en")
    if not figure:
        problems.append("figure.en: empty")
    elif figure not in FIGURES:
        problems.append(f"figure.en: {figure!r} is not one of {FIGURES} (add it to FIGURES if it is genuinely new)")
    if stage == "beats":
        return problems

    languages = ["en"] if stage == "en" else ["en", "ur"]
    for field in LOCALIZED_FIELDS:
        value = d.get(field)
        if not isinstance(value, dict):
            problems.append(f"{field}: missing")
            continue
        for lang in languages:
            text = str(value.get(lang) or "").strip()
            if not text:
                problems.append(f"{field}.{lang}: empty")
            elif lang == "en":
                problems += english_problems(f"{field}.en", text)
            else:
                problems += urdu_problems(f"{field}.ur", text)
    if s[0] not in CLOSING and "closing" in d:
        problems.append("closing: only miracle 3 has a closing")
    for section in sections(s):
        value = d.get(section)
        if not isinstance(value, dict):
            problems.append(f"{section}: missing")
            continue
        problems += paragraph_list_problems(f"{section}.en", value.get("en"), "en")
        if stage != "en":
            problems += paragraph_list_problems(f"{section}.ur", value.get("ur"), "ur")
            en, ur = value.get("en"), value.get("ur")
            if isinstance(en, list) and isinstance(ur, list) and len(en) != len(ur):
                problems.append(f"{section}.ur: {len(ur)} paragraphs, English has {len(en)}")

    if stage != "en" and d.get("ur_from") != english_hash(d, s):
        problems.append("ur: stale - the English changed after the Urdu was made; re-translate and run ur-apply")

    en = (d.get("body") or {}).get("en")
    if isinstance(en, list):
        words = sum(len(p.split()) for p in en if isinstance(p, str))
        page_count = last - first + 1
        if words < MIN_WORDS_PER_PAGE * page_count:
            problems.append(
                f"body.en: {words} words for {page_count} page(s) (under {MIN_WORDS_PER_PAGE} a page); events are likely missing"
            )
    return problems


def cmd_check(args):
    s = story(args.story)
    d = load_json(draft_path(s))
    problems = draft_problems(s, d, args.stage)
    if problems:
        print(f"FAIL {s[0]} {s[1]} ({args.stage})")
        for p in problems:
            print(f"  - {p}")
        return 1
    en = paragraphs(d, s, "en")
    tail = "" if args.stage == "beats" else f", {len(en)} paragraphs, {sum(len(p.split()) for p in en.values())} English words"
    print(f"PASS {s[0]} {s[1]} ({args.stage}): {len(d['beats'])} beats{tail}")
    return 0


def cmd_ur_apply(args):
    s = story(args.story)
    d = load_json(draft_path(s))
    ur = load_json(story_dir(s) / "ur.json")
    problems = []
    for field in LOCALIZED_FIELDS:
        if not isinstance(ur.get(field), str) or not ur[field].strip():
            problems.append(f"{field}: missing")
    for section in sections(s):
        en = (d.get(section) or {}).get("en") or []
        if not isinstance(ur.get(section), list) or len(ur[section]) != len(en):
            problems.append(f"{section}: needs {len(en)} Urdu paragraphs, one for each English paragraph")
    extra = set(ur) - set(LOCALIZED_FIELDS) - set(sections(s))
    if extra:
        problems.append(f"unexpected keys {sorted(extra)}")
    if problems:
        print("FAIL ur.json")
        for p in problems:
            print(f"  - {p}")
        return 1
    for field in LOCALIZED_FIELDS:
        d[field]["ur"] = ur[field].strip()
    for section in sections(s):
        d[section]["ur"] = [p.strip() for p in ur[section]]
    d["ur_from"] = english_hash(d, s)
    draft_path(s).write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"merged Urdu into {draft_path(s).relative_to(ROOT)}")
    return cmd_check(argparse.Namespace(story=args.story, stage="full"))


# --- audit -------------------------------------------------------------------

def cmd_next_attempt(args):
    s = story(args.story)
    existing = audits(s)
    n = int(re.search(r"\d+", existing[-1].name).group()) + 1 if existing else 1
    print(n)
    return 0


def audit_problems(s, d: dict, a: dict) -> tuple[list[str], list[str]]:
    """(malformed, findings). Malformed means the audit itself must be fixed.

    The audit is about fidelity only: beats, omissions, English faithful to the book,
    Urdu matching the English, and prose garbled enough to misstate the story.
    Closeness to the book's wording is not checked (user, 2026-09-29); an older
    audit's "own_words" list is ignored."""
    malformed, findings = [], []
    en, ur = paragraphs(d, s, "en"), paragraphs(d, s, "ur")

    ruled = a.get("beats")
    if not isinstance(ruled, list) or [r.get("index") for r in ruled if isinstance(r, dict)] != list(range(1, len(d["beats"]) + 1)):
        malformed.append(f"beats: need one ruling per beat, index 1-{len(d['beats'])} in order")
    else:
        for r in ruled:
            if r.get("verdict") not in BEAT_VERDICTS:
                malformed.append(f"beats[{r.get('index')}]: verdict must be one of {sorted(BEAT_VERDICTS)}")
            elif r["verdict"] != "supported":
                findings.append(f"beat {r['index']} unsupported: {r.get('note', '')}")

    for key, keys, verdicts, ok in (("english", list(en), ENGLISH_VERDICTS, "faithful"),
                                    ("urdu", list(ur), URDU_VERDICTS, "match")):
        ruled = a.get(key)
        if not isinstance(ruled, list) or [r.get("where") for r in ruled if isinstance(r, dict)] != keys:
            malformed.append(f"{key}: need one ruling per paragraph, in order: {keys}")
            continue
        for r in ruled:
            if r.get("verdict") not in verdicts:
                malformed.append(f"{key}[{r.get('where')}]: verdict must be one of {sorted(verdicts)}")
            elif r["verdict"] != ok:
                findings.append(f"{key} {r['where']} {r['verdict']}: {r.get('note', '')}")

    for key in ("omissions", "prose"):
        items = a.get(key)
        if not isinstance(items, list):
            malformed.append(f"{key}: must be a list (empty when there is nothing)")
            continue
        for item in items:
            if not isinstance(item, dict):
                malformed.append(f"{key}: every entry must be an object")
                continue
            if key != "omissions":
                lang, where, sentence = item.get("lang"), item.get("where"), item.get("sentence") or ""
                text = (en if lang == "en" else ur if lang == "ur" else {}).get(where)
                if text is None:
                    malformed.append(f"{key}: no {lang} paragraph {where!r}")
                    continue
                if not sentence or sentence not in text:
                    malformed.append(f"{key}: sentence not found verbatim in {lang} {where}: {sentence[:60]!r}")
                    continue
            findings.append(f"{key}: {json.dumps(item, ensure_ascii=False)}")
    if not str(a.get("summary", "")).strip():
        malformed.append("summary: empty")
    return malformed, findings


def cmd_audit_check(args):
    s = story(args.story)
    existing = audits(s)
    if not existing:
        sys.exit(f"no audit for {s[0]} yet")
    latest = existing[-1]
    d = load_json(draft_path(s))
    if draft_problems(s, d, "full"):
        print(f"malformed: the draft itself fails check; run check {s[0]} first")
        return 1
    malformed, findings = audit_problems(s, d, load_json(latest))
    approved = story_dir(s) / "approved.json"
    if malformed:
        print(f"malformed {latest.name}")
        for m in malformed:
            print(f"  - {m}")
        return 1
    if findings:
        approved.unlink(missing_ok=True)
        print(f"FAIL {s[0]} {s[1]} ({latest.name}): {len(findings)} finding(s)")
        for f in findings:
            print(f"  - {f}")
        return 1
    approved.write_text(json.dumps({"audit": latest.name, "draft_sha256": sha256(draft_path(s))}, indent=2) + "\n")
    print(f"PASS {s[0]} {s[1]} ({latest.name}); approved")
    return 0


def cmd_restamp(args):
    """Carry an approval across a word-level fix taken verbatim from the auditor's
    notes (its quoted reading of the book), without a full re-audit. Every such
    edit is logged with its reason on approved.json."""
    s = story(args.story)
    approved = story_dir(s) / "approved.json"
    if not approved.exists():
        sys.exit(f"{s[0]} has no approval to carry over; run a full audit")
    problems = draft_problems(s, load_json(draft_path(s)), "full")
    if problems:
        print(f"FAIL {s[0]}: the draft fails check; fix it first")
        for p in problems:
            print(f"  - {p}")
        return 1
    record = json.loads(approved.read_text())
    new = sha256(draft_path(s))
    record.setdefault("post_audit_edits", []).append(
        {"reason": args.reason, "from_sha256": record["draft_sha256"], "to_sha256": new})
    record["draft_sha256"] = new
    approved.write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n")
    print(f"restamped {s[0]} {s[1]} ({len(record['post_audit_edits'])} post-audit edit(s) logged)")
    return 0


def approval_state(s) -> str:
    approved = story_dir(s) / "approved.json"
    if not approved.exists():
        return "not approved"
    record = json.loads(approved.read_text())
    if record.get("draft_sha256") != sha256(draft_path(s)):
        return "stale (draft changed after its audit)"
    edits = len(record.get("post_audit_edits", []))
    return f"approved ({record['audit']}" + (f", +{edits} post-audit edit(s))" if edits else ")")


def cmd_status(_args):
    for s in STORIES:
        dp = draft_path(s)
        if not dp.exists():
            print(f"{s[0]} {s[1]:<22} no draft")
            continue
        d = json.loads(dp.read_text(encoding="utf-8"))
        has_ur = bool((d.get("body") or {}).get("ur"))
        print(f"{s[0]} {s[1]:<22} draft {'en+ur' if has_ur else 'en   '}  audits {len(audits(s))}  {approval_state(s)}")
    return 0


# --- assemble ----------------------------------------------------------------

def localized(value: dict) -> dict:
    return {"en": value["en"].strip(), "ur": value["ur"].strip()}


def joined(value: dict) -> dict:
    return {lang: "\n\n".join(p.strip() for p in value[lang]) for lang in ("en", "ur")}


def cmd_assemble(_args):
    stories, blocked = [], []
    for s in STORIES:
        state = approval_state(s) if draft_path(s).exists() else "no draft"
        if not state.startswith("approved"):
            blocked.append(f"{s[0]} {s[1]}: {state}")
            continue
        d = load_json(draft_path(s))
        entry = {"id": d["id"], "number": int(s[0]), **{f: localized(d[f]) for f in LOCALIZED_FIELDS}, "body": joined(d["body"])}
        if s[0] in CLOSING:
            entry["closing"] = joined(d["closing"])
        stories.append(entry)
    if blocked:
        print("not assembling; every miracle must be approved:")
        for b in blocked:
            print(f"  - {b}")
        return 1
    figure_ur = {}
    for entry in stories:
        en, ur = entry["figure"]["en"], entry["figure"]["ur"]
        if figure_ur.setdefault(en, ur) != ur:
            print(f"not assembling; figure {en!r} has two Urdu spellings: {figure_ur[en]!r} and {ur!r}")
            return 1
    OUTPUT.write_text(json.dumps({"note": NOTE, "stories": stories}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)} ({len(stories)} miracles)")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("fetch").set_defaults(func=cmd_fetch)
    p = sub.add_parser("pages")
    p.add_argument("stories", nargs="*")
    p.set_defaults(func=cmd_pages)
    p = sub.add_parser("check")
    p.add_argument("story")
    p.add_argument("--stage", choices=["beats", "en", "full"], default="full")
    p.set_defaults(func=cmd_check)
    p = sub.add_parser("ur-apply")
    p.add_argument("story")
    p.set_defaults(func=cmd_ur_apply)
    p = sub.add_parser("next-attempt")
    p.add_argument("story")
    p.set_defaults(func=cmd_next_attempt)
    p = sub.add_parser("audit-check")
    p.add_argument("story")
    p.set_defaults(func=cmd_audit_check)
    p = sub.add_parser("restamp")
    p.add_argument("story")
    p.add_argument("--reason", required=True)
    p.set_defaults(func=cmd_restamp)
    sub.add_parser("status").set_defaults(func=cmd_status)
    sub.add_parser("assemble").set_defaults(func=cmd_assemble)
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
