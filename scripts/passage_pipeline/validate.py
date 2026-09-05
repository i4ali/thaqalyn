# scripts/passage_pipeline/validate.py
"""Stage 3: every mechanical rule from the design doc, as a list of error strings."""
from __future__ import annotations

import re
import unicodedata

from . import sources as sources_mod
from .fetch import TASHKEEL_RE

MARKER_RE = re.compile(r"\[(\d+)\]")
DIACRITIC_RE = re.compile(r"[āīūḥṣḍṭẓʿʾĀĪŪḤṢḌṬẒ]")
ARABIC_SENTENCE_END_RE = re.compile(r"[.!?؟]")
WORD_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9'’-]*")

TITLE_MAX_WORDS = 6
HEADING_MAX_WORDS = 5
NOTE_MAX_WORDS = 40
NARRATION_MAX_WORDS = 60
NARRATIONS_PER_VERSE = 3
ESSAY_LONG = (250, 400)   # passages of 8 or more verses
ESSAY_SHORT = (120, 250)
PERSPECTIVES = (60, 120)
TIER_B_MAX_CHARS = 220


def strip_markers(text: str) -> str:
    return MARKER_RE.sub("", text)


def word_count(text: str) -> int:
    return len(WORD_RE.findall(strip_markers(text)))


def normalize_arabic(text: str) -> str:
    text = unicodedata.normalize("NFKC", text)
    text = TASHKEEL_RE.sub("", text)
    for a, b in (("ٱ", "ا"), ("أ", "ا"), ("إ", "ا"), ("آ", "ا"), ("ى", "ي"), ("ة", "ه")):
        text = text.replace(a, b)
    text = re.sub(r"[^\w\s]", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def spans_in(needle: str, haystack: str) -> bool:
    """Every span of `needle` (split on an ellipsis) appears in `haystack`, normalized."""
    hay = normalize_arabic(haystack)
    for span in re.split(r"…|\.\.\.", needle):
        span = normalize_arabic(span)
        if span and span not in hay:
            return False
    return True


def _markers(text: str | None) -> list[int]:
    return [int(m) for m in MARKER_RE.findall(text or "")]


_SOURCE_ID_RE = re.compile(r"^s(\d+)$")


def _source_num(sid) -> int | None:
    """Numeric part of a source id such as 's12', or None when the id is malformed."""
    m = _SOURCE_ID_RE.match(sid) if isinstance(sid, str) else None
    return int(m.group(1)) if m else None


def _en(field) -> str | None:
    if field is None:
        return None
    return field.get("en") if isinstance(field, dict) else None


def validate_draft(draft: dict, gathered: dict, verses: dict) -> list[str]:
    errs: list[str] = []
    ref = verses["passage"]
    if draft.get("passage") != ref["id"]:
        errs.append(f"passage id {draft.get('passage')!r} does not match {ref['id']!r}")
    lo, hi = ref["range"]
    n_verses = hi - lo + 1
    by_id = {s["id"]: s for s in gathered["sources"]}

    # sources block of the draft
    draft_sources = draft.get("sources") or []
    draft_ids = [s.get("id") for s in draft_sources]
    for s in draft_sources:
        sid = s.get("id")
        if _source_num(sid) is None or sid not in by_id:
            errs.append(f"source {sid} is not in sources.json")
            continue
        g = by_id[sid]
        ex = s.get("excerpt")
        if g["tier"] == "C" and ex:
            errs.append(f"source {sid} is tier C: excerpt must be null")
        if ex:
            if not spans_in(ex.get("text", ""), g["text"]):
                errs.append(f"source {sid} excerpt not found in the gathered block")
            if g["tier"] == "B":
                body = ex.get("text", "")
                if len(body) > TIER_B_MAX_CHARS or len(ARABIC_SENTENCE_END_RE.findall(body.rstrip(".!?؟"))) > 0:
                    errs.append(f"source {sid} is tier B: quote one sentence, at most {TIER_B_MAX_CHARS} characters")
            if not s.get("gloss"):
                errs.append(f"source {sid} has an excerpt but no gloss")

    def marker_ids(text: str | None, where: str, allow_sunni: bool) -> None:
        for n in _markers(text):
            sid = f"s{n}"
            if sid not in draft_ids or sid not in by_id:
                errs.append(f"marker [{n}] in {where} has no source (expected {sid} in the draft's sources)")
                continue
            if not allow_sunni and by_id[sid]["tradition"] == "sunni":
                errs.append(f"marker [{n}] in {where} cites a sunni source; sunni works only in perspectives")

    # title and essay
    title = _en(draft.get("title")) or ""
    if not title:
        errs.append("title.en is required")
    elif word_count(title) > TITLE_MAX_WORDS:
        errs.append(f"title is over {TITLE_MAX_WORDS} words")
    essay = _en(draft.get("essay")) or ""
    lo_w, hi_w = ESSAY_LONG if n_verses >= 8 else ESSAY_SHORT
    wc = word_count(essay)
    if wc < lo_w:
        errs.append(f"essay has {wc} words, under the {lo_w} minimum for a {n_verses}-verse passage")
    if wc > hi_w:
        errs.append(f"essay has {wc} words, over the {hi_w} maximum (budget {lo_w} to {hi_w})")
    marker_ids(essay, "essay", allow_sunni=False)
    used: set[int] = set(_markers(essay))

    # verses
    seen: set[int] = set()
    for entry in draft.get("verses") or []:
        vn = entry.get("verse")
        if vn in seen:
            errs.append(f"verse {vn} appears twice")
        seen.add(vn)
        if not (lo <= vn <= hi):
            errs.append(f"verse {vn} is outside the passage range {lo} to {hi}")
        heading = _en(entry.get("heading")) or ""
        if word_count(heading) > HEADING_MAX_WORDS:
            errs.append(f"verse {vn} heading is over {HEADING_MAX_WORDS} words")
        note = _en(entry.get("note"))
        nars = entry.get("narrations") or []
        if not note and not nars:
            errs.append(f"verse {vn} has nothing of its own; drop the entry")
        if note:
            if word_count(note) > NOTE_MAX_WORDS:
                errs.append(f"verse {vn} note is over {NOTE_MAX_WORDS} words")
            marker_ids(note, f"verse {vn} note", allow_sunni=False)
            used.update(_markers(note))
        if len(nars) > NARRATIONS_PER_VERSE:
            errs.append(f"verse {vn} has more than {NARRATIONS_PER_VERSE} narrations")
        for nar in nars:
            nid = nar.get("id", "?")
            sid = nar.get("source")
            num = _source_num(sid)
            if num is None or sid not in by_id or sid not in draft_ids:
                errs.append(f"narration {nid} source {sid} is not in the draft's sources")
                continue
            used.add(num)
            g = by_id[sid]
            if g["key"] not in sources_mod.NARRATION_KEYS:
                errs.append(f"narration {nid} cites {g['key']}, which is not a narration source")
            if g["tradition"] != "shia":
                errs.append(f"narration {nid} cites a sunni source")
            if not nar.get("arabic"):
                errs.append(f"narration {nid} has no arabic")
            elif not spans_in(nar["arabic"], g["text"]):
                errs.append(f"narration {nid} arabic not found in source {sid}")
            if not nar.get("speaker"):
                errs.append(f"narration {nid} has no speaker")
            en = _en(nar.get("text")) or ""
            if not en:
                errs.append(f"narration {nid} has no text.en")
            elif word_count(en) > NARRATION_MAX_WORDS:
                errs.append(f"narration {nid} text is over {NARRATION_MAX_WORDS} words")

    # perspectives
    persp = _en(draft.get("perspectives"))
    if persp:
        pw = word_count(persp)
        if pw < PERSPECTIVES[0] or pw > PERSPECTIVES[1]:
            errs.append(f"perspectives has {pw} words, budget {PERSPECTIVES[0]} to {PERSPECTIVES[1]}")
        marker_ids(persp, "perspectives", allow_sunni=True)
        used.update(_markers(persp))

    # every draft source cited somewhere
    for sid in draft_ids:
        num = _source_num(sid)
        if num is not None and sid in by_id and num not in used:
            errs.append(f"source {sid} is listed but never cited")

    # style, English fields only
    english = [title, essay, persp or ""]
    for entry in draft.get("verses") or []:
        english += [_en(entry.get("heading")) or "", _en(entry.get("note")) or ""]
        english += [_en(n.get("text")) or "" for n in entry.get("narrations") or []]
    english += [s.get("gloss") or "" for s in draft_sources]
    blob = "\n".join(english)
    if DIACRITIC_RE.search(blob):
        errs.append("transliteration diacritics found in English text; use plain spelling")
    if "—" in blob:
        errs.append("em dash found in English text; use a plain dash")
    return errs
