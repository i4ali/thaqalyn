# scripts/passage_pipeline/quiz.py
"""Passage quizzes: five questions per shipped passage, answerable from the
passage alone. Brief, validator, review check, status and assemble.
See docs/plans/2026-09-11-passage-quiz-design.md."""
from __future__ import annotations

import json
import re
import unicodedata
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

from . import rukus
from .rukus import PassageRef
from .validate import CURLY_QUOTE_RE, DIACRITIC_RE, MARKER_RE, strip_markers, word_count

DATA_DIR = rukus.DATA_DIR
QUIZ_FILE = "quiz.json"
REVIEW_FILE_RE = re.compile(r"quiz_review\.(\d+)\.json$")
REVIEW_SCHEMA = 1
VERDICTS = {"ok", "fail"}

TYPES = ("multipleChoice", "trueFalse", "fillGap", "whoSaid")
# whichVerse was dropped on 2026-09-12: it asked the reader to remember what a
# numbered verse says. One of each of these is required when available.
OTHER_TYPES = ("fillGap", "whoSaid")
QUESTION_COUNT = 5
MULTIPLE_CHOICE_COUNT = 2
TRUE_FALSE_COUNT = 1
GAP = "____"
TRUE_FALSE_OPTIONS = ["True", "False"]
PROMPT_WORDS = (5, 40)
EXPLANATION_WORDS = (10, 50)
QUOTE_WORDS = (5, 60)
OPTION_MAX_WORDS = 12
MIN_ANCHOR_PARTS = 3
WHO_SAID_MIN_NARRATIONS = 2
NARRATION_WHERE_RE = re.compile(r"^verses\.(\d+)\.narrations\.(n\d+)$")
VERSE_WHERE_RE = re.compile(r"^verses\.(\d+)\.")
_QUOTES = str.maketrans({"‘": "'", "’": "'", "“": '"', "”": '"'})


def _read(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _iso(ts: float) -> str:
    return datetime.fromtimestamp(ts, timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _en(field) -> str | None:
    return field.get("en") if isinstance(field, dict) and isinstance(field.get("en"), str) else None


def normalize(text: str) -> str:
    """Whitespace, quote marks, markers and case folded away, so a quote copied
    with straight quotes still matches a passage set in curly ones."""
    text = unicodedata.normalize("NFKC", text).translate(_QUOTES)
    text = strip_markers(text)
    text = re.sub(r"\s+([.,;:!?])", r"\1", text)
    return re.sub(r"\s+", " ", text).strip().casefold()


# ---- shipped data -----------------------------------------------------------

def shipped_passage(ref: PassageRef) -> dict | None:
    path = DATA_DIR / f"passages_{ref.surah}.json"
    return _read(path).get(str(ref.index)) if path.exists() else None


def shipped_quiz(ref: PassageRef) -> dict | None:
    path = DATA_DIR / f"quiz_{ref.surah}.json"
    return _read(path).get(str(ref.index)) if path.exists() else None


def passage_parts(passage: dict, ref: PassageRef) -> dict[str, str]:
    """Every anchorable part of the passage: English only, markers stripped."""
    parts: dict[str, str] = {}
    for v in ref.verses():
        parts[f"verses.{v}.translation"] = rukus.verse_record(ref.surah, v)["translation"]
    parts["essay"] = strip_markers(_en(passage.get("essay")) or "")
    for entry in passage.get("verses") or []:
        v = entry["verse"]
        note = _en(entry.get("note"))
        if note:
            parts[f"verses.{v}.note"] = strip_markers(note)
        for nar in entry.get("narrations") or []:
            parts[f"verses.{v}.narrations.{nar['id']}"] = _en(nar.get("text")) or ""
    persp = _en(passage.get("perspectives"))
    if persp:
        parts["perspectives"] = strip_markers(persp)
    return parts


def narration_speakers(passage: dict) -> dict[str, str]:
    return {f"verses.{e['verse']}.narrations.{n['id']}": n["speaker"]
            for e in passage.get("verses") or [] for n in e.get("narrations") or []}


def headings(passage: dict) -> dict[int, str]:
    out: dict[int, str] = {}
    for e in passage.get("verses") or []:
        h = _en(e.get("heading"))
        if h:
            out[e["verse"]] = h
    return out


def allowed_types(passage: dict, ref: PassageRef) -> list[str]:
    out = ["multipleChoice", "trueFalse", "fillGap"]
    if len(narration_speakers(passage)) >= WHO_SAID_MIN_NARRATIONS:
        out.append("whoSaid")
    return out


# ---- validation --------------------------------------------------------------

def validate_quiz(quiz: dict, passage: dict, ref: PassageRef) -> list[str]:
    errs: list[str] = []
    if quiz.get("passage") != ref.id:
        errs.append(f"passage id {quiz.get('passage')!r} does not match {ref.id!r}")
    qs = quiz.get("questions")
    if not isinstance(qs, list) or len(qs) != QUESTION_COUNT or not all(isinstance(q, dict) for q in qs):
        errs.append(f"exactly {QUESTION_COUNT} questions required")
        return errs
    if [q.get("id") for q in qs] != [f"q{i}" for i in range(1, QUESTION_COUNT + 1)]:
        errs.append("ids must be q1 to q5 in order")
    types = [q.get("type") for q in qs]
    bad = [t for t in types if t not in TYPES]
    if bad:
        errs.append(f"unknown question type(s): {', '.join(map(str, bad))}")
        return errs
    counts = Counter(types)
    allowed = allowed_types(passage, ref)
    # One fillGap and one whoSaid when the passage allows them; a slot whose
    # type is unavailable (too few narrations) goes to a third multipleChoice.
    required_others = [t for t in OTHER_TYPES if t in allowed]
    mc_required = MULTIPLE_CHOICE_COUNT + len(OTHER_TYPES) - len(required_others)
    if counts["multipleChoice"] != mc_required:
        errs.append(f"exactly {mc_required} multipleChoice questions required, got {counts['multipleChoice']}")
    if counts["trueFalse"] != TRUE_FALSE_COUNT:
        errs.append(f"exactly {TRUE_FALSE_COUNT} trueFalse question required, got {counts['trueFalse']}")
    for t in required_others:
        if counts[t] != 1:
            errs.append(f"exactly one {t} question required, got {counts[t]}")
    for t in sorted(set(types)):
        if t not in allowed:
            errs.append(f"{t} is not available for this passage")
    for a, b in zip(types, types[1:]):
        if a == b:
            errs.append(f"two adjacent {a} questions; vary the order")
            break
    parts = passage_parts(passage, ref)
    speakers = narration_speakers(passage)
    wheres: list[str] = []
    answers4: list[int] = []
    for q in qs:
        errs += _validate_question(q, parts, speakers, ref, wheres, answers4)
    if len(set(wheres)) < MIN_ANCHOR_PARTS:
        errs.append(f"anchors cover {len(set(wheres))} part(s) of the passage; at least {MIN_ANCHOR_PARTS} required")
    if speakers and not any(NARRATION_WHERE_RE.match(w) for w in wheres):
        errs.append("at least one question must be anchored in a narration")
    if len(answers4) >= 2 and len(set(answers4)) == 1:
        errs.append("the right answer sits in the same slot on every four-option question")
    errs += _style_errors(qs)
    return errs


def _validate_question(q: dict, parts: dict[str, str], speakers: dict[str, str], ref: PassageRef,
                       wheres: list[str], answers4: list[int]) -> list[str]:
    errs: list[str] = []
    qid, t = q.get("id"), q["type"]
    prompt = _en(q.get("prompt"))
    if prompt is None:
        errs.append(f"{qid}: prompt.en missing")
        prompt = ""
    else:
        wc = word_count(prompt)
        if not PROMPT_WORDS[0] <= wc <= PROMPT_WORDS[1]:
            errs.append(f"{qid}: prompt is {wc} words; {PROMPT_WORDS[0]} to {PROMPT_WORDS[1]} required")
    opts = q.get("options")
    texts = [_en(o) for o in opts] if isinstance(opts, list) else None
    if texts is None or any(x is None for x in texts):
        errs.append(f'{qid}: options must be a list of {{"en": ...}}')
        return errs
    expected = 2 if t == "trueFalse" else 4
    if len(texts) != expected:
        errs.append(f"{qid}: {expected} options required, got {len(texts)}")
    if t == "trueFalse" and texts != TRUE_FALSE_OPTIONS:
        errs.append(f"{qid}: trueFalse options must be exactly True and False")
    if len({x.strip().casefold() for x in texts}) != len(texts):
        errs.append(f"{qid}: options must be distinct")
    for x in texts:
        if word_count(x) > OPTION_MAX_WORDS:
            errs.append(f"{qid}: option {x!r} is over {OPTION_MAX_WORDS} words")
    ans = q.get("answer")
    if isinstance(ans, bool) or not isinstance(ans, int) or not 0 <= ans < len(texts):
        errs.append(f"{qid}: answer must be an index into options")
        ans = None
    elif expected == 4:
        answers4.append(ans)
    expl = _en(q.get("explanation"))
    if expl is None:
        errs.append(f"{qid}: explanation.en missing")
    else:
        wc = word_count(expl)
        if not EXPLANATION_WORDS[0] <= wc <= EXPLANATION_WORDS[1]:
            errs.append(f"{qid}: explanation is {wc} words; {EXPLANATION_WORDS[0]} to {EXPLANATION_WORDS[1]} required")
    verse = q.get("verse")
    if isinstance(verse, bool) or not isinstance(verse, int) or not ref.start <= verse <= ref.end:
        errs.append(f"{qid}: verse must be between {ref.start} and {ref.end}")
        verse = None
    anchor = q.get("anchor") if isinstance(q.get("anchor"), dict) else {}
    where, quote = anchor.get("where"), anchor.get("quote")
    part = parts.get(where) if isinstance(where, str) else None
    if part is None:
        errs.append(f"{qid}: anchor.where {where!r} is not a part of this passage")
    else:
        wheres.append(where)
        if not isinstance(quote, str):
            errs.append(f"{qid}: anchor.quote missing")
        else:
            wc = word_count(quote)
            if not QUOTE_WORDS[0] <= wc <= QUOTE_WORDS[1]:
                errs.append(f"{qid}: anchor quote is {wc} words; {QUOTE_WORDS[0]} to {QUOTE_WORDS[1]} required")
            elif normalize(quote) not in normalize(part):
                errs.append(f"{qid}: anchor quote not found in {where}")
        m = VERSE_WHERE_RE.match(where)
        if m and verse is not None and int(m.group(1)) != verse:
            errs.append(f"{qid}: verse {verse} does not match the anchor's verse {m.group(1)}")
    if t == "fillGap":
        if prompt.count(GAP) != 1:
            errs.append(f"{qid}: fillGap prompt must contain exactly one {GAP}")
        elif part is not None and ans is not None and normalize(prompt.replace(GAP, texts[ans])) not in normalize(part):
            errs.append(f"{qid}: fillGap prompt with the right option filled in is not a span of {where}")
    elif t == "whoSaid":
        if not isinstance(where, str) or not NARRATION_WHERE_RE.match(where):
            errs.append(f"{qid}: whoSaid must be anchored in a narration")
        elif ans is not None and texts[ans] != speakers.get(where):
            errs.append(f"{qid}: right option {texts[ans]!r} is not the speaker of {where} ({speakers.get(where)!r})")
    return errs


def _strings(q: dict) -> list[str]:
    out = [_en(q.get("prompt")) or "", _en(q.get("explanation")) or ""]
    out += [_en(o) or "" for o in (q.get("options") if isinstance(q.get("options"), list) else [])]
    a = q.get("anchor") if isinstance(q.get("anchor"), dict) else {}
    out.append(a.get("quote") if isinstance(a.get("quote"), str) else "")
    return out


def _style_errors(qs: list[dict]) -> list[str]:
    blob = "\n".join(s for q in qs for s in _strings(q))
    errs = []
    if DIACRITIC_RE.search(blob):
        errs.append("transliteration diacritics found; use plain spelling")
    if "—" in blob:
        errs.append("em dash found; use a plain dash")
    if CURLY_QUOTE_RE.search(blob):
        errs.append("curly quotation marks found; use straight quotes")
    if MARKER_RE.search(blob):
        errs.append("citation marker like [1] found; quiz text carries no markers")
    return errs


# ---- brief -------------------------------------------------------------------

def render_brief(passage: dict, ref: PassageRef) -> str:
    s = rukus.surah_info(ref.surah)
    total = len(rukus.passages_for_surah(ref.surah))
    parts = passage_parts(passage, ref)
    heads = headings(passage)

    def head(v: int) -> str:
        return f" · {heads[v]}" if v in heads else ""

    out = [f"# Passage {ref.id} · {s['englishName']} {ref.start} to {ref.end} · {_en(passage.get('title'))}",
           f"passage {ref.index} of {total} · question types available: {', '.join(allowed_types(passage, ref))}", ""]
    out.append("## Verses (Qarai translation)")
    for v in ref.verses():
        out += [f"### Verse {v}{head(v)}", parts[f"verses.{v}.translation"], ""]
    out += ["## Essay", parts["essay"], ""]
    entries = [e for e in passage.get("verses") or [] if _en(e.get("note")) or e.get("narrations")]
    if entries:
        out.append("## Verse notes and narrations")
        for e in entries:
            v = e["verse"]
            out.append(f"### Verse {v}{head(v)}")
            if f"verses.{v}.note" in parts:
                out.append(f"note: {parts[f'verses.{v}.note']}")
            for n in e.get("narrations") or []:
                key = f"verses.{v}.narrations.{n['id']}"
                to = f" to {n['addressee']}" if n.get("addressee") else ""
                out.append(f"narration {n['id']} · {n['speaker']}{to}: {parts[key]}")
            out.append("")
    if "perspectives" in parts:
        out += ["## Perspectives", parts["perspectives"], ""]
    out += ["## Anchors you may use", ", ".join(parts)]
    return "\n".join(out)


# ---- reviews -----------------------------------------------------------------

def next_attempt(work_dir: Path) -> int:
    nums = [int(m.group(1)) for p in work_dir.glob("quiz_review.*.json") for m in [REVIEW_FILE_RE.search(p.name)] if m]
    return (max(nums) + 1) if nums else 1


def latest_review(work_dir: Path) -> Path | None:
    n = next_attempt(work_dir) - 1
    return (work_dir / f"quiz_review.{n}.json") if n >= 1 else None


def check_review(doc: dict, quiz: dict) -> tuple[list[str], bool]:
    """(problems with the review file, every question ok)."""
    errs: list[str] = []
    if doc.get("passage") != quiz.get("passage"):
        errs.append(f"passage {doc.get('passage')!r} does not match the quiz {quiz.get('passage')!r}")
    if doc.get("schema") != REVIEW_SCHEMA:
        errs.append(f'"schema": {REVIEW_SCHEMA} required')
    verdicts = doc.get("verdicts")
    if not isinstance(verdicts, list) or not all(isinstance(v, dict) for v in verdicts):
        errs.append("verdicts must be a list")
        return errs, False
    expected = [q.get("id") for q in quiz.get("questions") or []]
    got = [v.get("id") for v in verdicts]
    if sorted(got, key=str) != sorted(expected, key=str):
        errs.append(f"verdict ids {got} do not match the quiz's {expected}")
    fails = 0
    for v in verdicts:
        if v.get("verdict") not in VERDICTS:
            errs.append(f"{v.get('id')}: verdict must be ok or fail")
        elif v["verdict"] == "fail":
            fails += 1
            if not (isinstance(v.get("reason"), str) and v["reason"].strip()):
                errs.append(f"{v.get('id')}: a fail needs a reason")
    passed = fails == 0
    if doc.get("overall") != ("PASS" if passed else "FAIL"):
        errs.append(f"overall must be {'PASS' if passed else 'FAIL'} for these verdicts")
    return errs, passed


# ---- status ------------------------------------------------------------------

def state(ref: PassageRef) -> dict:
    """Stage of a passage's quiz, derived from files: no-passage, none, drafted,
    reviewed (latest review FAIL), passed, assembled."""
    out = {"id": ref.id, "range": [ref.start, ref.end], "stage": "no-passage",
           "valid": None, "attempts": 0, "review": None}
    passage = shipped_passage(ref)
    if passage is None:
        return out
    out["stage"] = "none"
    qpath = ref.work_dir / QUIZ_FILE
    if not qpath.exists():
        return out
    out["stage"] = "drafted"
    quiz = _read(qpath)
    out["valid"] = not validate_quiz(quiz, passage, ref)
    latest = latest_review(ref.work_dir)
    if latest:
        out["attempts"] = next_attempt(ref.work_dir) - 1
        if latest.stat().st_mtime < qpath.stat().st_mtime:
            out["review"] = "stale"
        else:
            errs, passed = check_review(_read(latest), quiz)
            out["review"] = "malformed" if errs else ("PASS" if passed else "FAIL")
            if out["review"] == "FAIL":
                out["stage"] = "reviewed"
            elif out["review"] == "PASS" and out["valid"]:
                out["stage"] = "passed"
    if out["stage"] == "passed":
        shipped = shipped_quiz(ref)
        if shipped and shipped.get("questions") == quiz.get("questions"):
            out["stage"] = "assembled"
    return out


def next_quizzes(surah: int | None, count: int) -> list[PassageRef]:
    refs = rukus.passages_for_surah(surah) if surah else rukus.all_passages()
    out: list[PassageRef] = []
    for r in refs:
        if state(r)["stage"] in ("none", "drafted", "reviewed"):
            out.append(r)
            if len(out) == count:
                break
    return out


# ---- assemble ----------------------------------------------------------------

def build_record(ref: PassageRef, quiz: dict) -> dict:
    d = ref.work_dir
    latest = latest_review(d)
    return {"id": ref.id, "surah": ref.surah, "index": ref.index, "range": [ref.start, ref.end],
            "questions": quiz["questions"],
            "status": {"written_at": _iso((d / QUIZ_FILE).stat().st_mtime),
                       "review_attempts": next_attempt(d) - 1,
                       "reviewed_at": _iso(latest.stat().st_mtime) if latest else None,
                       "assembled_at": _iso(datetime.now(timezone.utc).timestamp())}}


def assemble(surah: int) -> tuple[list[str], list[tuple[str, str]]]:
    """Merge passed quizzes into Data/quiz_<surah>.json. Safe to run again."""
    out_path = DATA_DIR / f"quiz_{surah}.json"
    existing = _read(out_path) if out_path.exists() else {}
    written: list[str] = []
    skipped: list[tuple[str, str]] = []
    for ref in rukus.passages_for_surah(surah):
        s = state(ref)
        if s["stage"] in ("no-passage", "none", "assembled"):
            continue
        if s["stage"] != "passed":
            why = f"stage {s['stage']}" + ("" if s["valid"] in (None, True) else ", quiz invalid")
            skipped.append((ref.id, why))
            continue
        existing[str(ref.index)] = build_record(ref, _read(ref.work_dir / QUIZ_FILE))
        written.append(ref.id)
    if written:
        ordered = {k: existing[k] for k in sorted(existing, key=int)}
        out_path.write_text(json.dumps(ordered, ensure_ascii=False, indent=2), encoding="utf-8")
    return written, skipped
