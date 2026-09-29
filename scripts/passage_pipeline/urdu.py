# scripts/passage_pipeline/urdu.py
"""Urdu for shipped passages: brief, validator, and a merge that writes the
"ur" values straight into Data/passages_<surah>.json beside each "en".

The translator agent never writes a file. It pipes one JSON object per passage
to `passages.py ur-apply S:I`, which validates it against the English that is
in the Data file at that moment and, only if every check passes, adds the "ur"
values in place. Nothing but "ur" values may change; the file keeps the
formatting `assemble` gives it. The app's `LocalizedText` decodes `ur` beside
`en`, so a merged passage is readable in Urdu on the next build."""
from __future__ import annotations

import fcntl
import json
import os
import re
from pathlib import Path

from . import rukus
from .rukus import PassageRef

DATA_DIR = rukus.DATA_DIR
LOCK_DIR = rukus.WORK_DIR / ".locks"

# ASCII digits only: Python's \d also matches Urdu digits, which would let a
# marker written as [۱] pass for [1].
MARKER_RE = re.compile(r"\[([0-9]+)\]")
VERSE_REF_RE = re.compile(r"(?<![0-9])([0-9]{1,3}:[0-9]{1,3})(?![0-9])")
URDU_LETTER_RE = re.compile(r"[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]")
LATIN_RE = re.compile(r"[A-Za-z]")
EM_DASH = "—"
PARAGRAPH_KINDS = ("essay", "perspectives", "note")
ONE_LINE_KINDS = ("title", "heading")
# Urdu runs longer than English in words (postpositions stand alone); a value
# far outside this band has dropped or invented content. Checked only on
# fields long enough for the ratio to mean something.
WORD_RATIO = (0.8, 2.5)
RATIO_MIN_EN_WORDS = 15


def _read(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _kind(key: str) -> str:
    if key.startswith("verses."):
        return "narration" if ".narrations." in key else key.rsplit(".", 1)[1]
    return key


def holders(record: dict) -> dict[str, dict]:
    """Every translatable field of a passage record, keyed by its path, mapped
    to the {"en": ...} dict that receives "ur". Order follows the page."""
    out: dict[str, dict] = {}

    def take(key: str, field) -> None:
        if isinstance(field, dict) and isinstance(field.get("en"), str) and field["en"].strip():
            out[key] = field

    take("title", record.get("title"))
    take("essay", record.get("essay"))
    for v in record.get("verses") or []:
        vn = v.get("verse")
        take(f"verses.{vn}.heading", v.get("heading"))
        take(f"verses.{vn}.note", v.get("note"))
        for n in v.get("narrations") or []:
            take(f"verses.{vn}.narrations.{n.get('id')}", n.get("text"))
    take("perspectives", record.get("perspectives"))
    return out


def shipped(ref: PassageRef) -> dict | None:
    path = DATA_DIR / f"passages_{ref.surah}.json"
    return _read(path).get(str(ref.index)) if path.exists() else None


# ---- brief ------------------------------------------------------------------

def render_brief(record: dict, ref: PassageRef) -> str:
    fields = holders(record)
    narrations = {f"verses.{v.get('verse')}.narrations.{n.get('id')}": n
                  for v in record.get("verses") or [] for n in v.get("narrations") or []}
    lines = [f"# Passage {ref.id} (surah {ref.surah}, verses {ref.start} to {ref.end}): Urdu brief", "",
             f"Translate all {len(fields)} fields below. Send them in one JSON object to:",
             f"  .venv/bin/python scripts/passages.py ur-apply {ref.id} <<'JSON'", "  {...}", "  JSON", ""]
    for key, holder in fields.items():
        lines.append(f"## {key}  ({_kind(key)})")
        n = narrations.get(key)
        if n:
            who = n.get("speaker") or "unknown"
            if n.get("addressee"):
                who += f", addressed to {n['addressee']}"
            lines.append(f"Speaker: {who}")
            if n.get("arabic"):
                lines.append(f"Arabic (reference only, do not translate): {n['arabic']}")
        lines.append(holder["en"])
        lines.append("")
    skeleton = {"passage": ref.id, "fields": {k: "" for k in fields}}
    lines.append("## JSON to fill")
    lines.append(json.dumps(skeleton, ensure_ascii=False, indent=2))
    return "\n".join(lines)


# ---- validation ---------------------------------------------------------------

def _words(text: str) -> int:
    return len(MARKER_RE.sub(" ", text).split())


def _paragraphs(text: str) -> int:
    return len([p for p in re.split(r"\n\s*\n", text.strip()) if p.strip()])


def validate(doc, record: dict, ref: PassageRef) -> list[str]:
    if not isinstance(doc, dict):
        return ["the payload must be a JSON object with \"passage\" and \"fields\""]
    errs: list[str] = []
    if doc.get("passage") != ref.id:
        errs.append(f"\"passage\" must be \"{ref.id}\", got {doc.get('passage')!r}")
    got = doc.get("fields")
    if not isinstance(got, dict):
        return errs + ["\"fields\" must be an object mapping each field key to its Urdu"]
    want = holders(record)
    for k in want:
        if k not in got:
            errs.append(f"{k}: missing")
    for k in got:
        if k not in want:
            errs.append(f"{k}: not a field of this passage (keys come from ur-brief)")
    for k, holder in want.items():
        ur = got.get(k)
        if k not in got:
            continue
        if not isinstance(ur, str) or not ur.strip():
            errs.append(f"{k}: empty")
            continue
        en, kind = holder["en"], _kind(k)
        if not URDU_LETTER_RE.search(ur):
            errs.append(f"{k}: no Urdu script")
            continue
        latin = sorted(set(re.findall(r"[A-Za-z]+", ur)))
        if latin:
            errs.append(f"{k}: Latin letters in the Urdu ({', '.join(latin[:6])}); write every word in Urdu script")
        if EM_DASH in ur:
            errs.append(f"{k}: em dash; use a plain dash or a comma")
        want_m, got_m = sorted(MARKER_RE.findall(en), key=int), sorted(MARKER_RE.findall(ur), key=int)
        if want_m != got_m:
            errs.append(f"{k}: citation markers differ: English {['[%s]' % m for m in want_m]} "
                        f"vs Urdu {['[%s]' % m for m in got_m]}")
        want_r, got_r = sorted(VERSE_REF_RE.findall(en)), sorted(VERSE_REF_RE.findall(ur))
        if want_r != got_r:
            errs.append(f"{k}: verse references differ: English {want_r} vs Urdu {got_r} (keep them in Western digits)")
        if kind in PARAGRAPH_KINDS and _paragraphs(en) != _paragraphs(ur):
            errs.append(f"{k}: {_paragraphs(ur)} paragraph(s), the English has {_paragraphs(en)}")
        if kind in ONE_LINE_KINDS and "\n" in ur.strip():
            errs.append(f"{k}: must be one line")
        ew = _words(en)
        if ew >= RATIO_MIN_EN_WORDS:
            ratio = _words(ur) / ew
            if not WORD_RATIO[0] <= ratio <= WORD_RATIO[1]:
                errs.append(f"{k}: {_words(ur)} Urdu words for {ew} English words; "
                            "the translation has dropped or added content")
    return errs


# ---- merge --------------------------------------------------------------------

def _strip_ur(node):
    if isinstance(node, dict):
        return {k: _strip_ur(v) for k, v in node.items() if k != "ur"}
    if isinstance(node, list):
        return [_strip_ur(v) for v in node]
    return node


def apply(ref: PassageRef, doc) -> tuple[list[str], int]:
    """Validate `doc` against the shipped English and merge it into the Data
    file. Returns (errors, fields written); nothing is written on any error."""
    path = DATA_DIR / f"passages_{ref.surah}.json"
    if not path.exists():
        return [f"{path.name} does not exist; passage {ref.id} is not shipped"], 0
    LOCK_DIR.mkdir(parents=True, exist_ok=True)
    with open(LOCK_DIR / f"passages_{ref.surah}.lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        raw = path.read_text(encoding="utf-8")
        data = json.loads(raw)
        record = data.get(str(ref.index))
        if record is None:
            return [f"passage {ref.id} is not in {path.name}"], 0
        errs = validate(doc, record, ref)
        if errs:
            return errs, 0
        before = _strip_ur(data)
        fields = holders(record)
        for k, holder in fields.items():
            holder["ur"] = doc["fields"][k].strip()
        if _strip_ur(data) != before:
            return ["internal: something other than a \"ur\" value changed; nothing written"], 0
        text = json.dumps(data, ensure_ascii=False, indent=2) + ("\n" if raw.endswith("\n") else "")
        tmp = path.with_name(f".{path.name}.tmp")
        tmp.write_text(text, encoding="utf-8")
        os.replace(tmp, path)
    return [], len(fields)


def carry_over(old: dict | None, new: dict) -> int:
    """Keep an old record's "ur" on every field of a rebuilt record whose
    English did not change, so re-assembling a passage does not drop Urdu."""
    if not old:
        return 0
    old_fields = holders(old)
    kept = 0
    for k, holder in holders(new).items():
        prev = old_fields.get(k)
        if prev and prev.get("ur") and prev.get("en") == holder["en"]:
            holder["ur"] = prev["ur"]
            kept += 1
    return kept


# ---- status -------------------------------------------------------------------

def state(ref: PassageRef) -> dict:
    """Urdu stage of a passage: no-passage, none, partial or done."""
    record = shipped(ref)
    if record is None:
        return {"id": ref.id, "stage": "no-passage", "fields": 0, "done": 0}
    fields = holders(record)
    done = sum(1 for h in fields.values() if isinstance(h.get("ur"), str) and h["ur"].strip())
    stage = "done" if fields and done == len(fields) else ("partial" if done else "none")
    return {"id": ref.id, "stage": stage, "fields": len(fields), "done": done}


def next_passages(surah: int | None, count: int) -> list[PassageRef]:
    refs = rukus.passages_for_surah(surah) if surah else rukus.all_passages()
    out = []
    for r in refs:
        if state(r)["stage"] in ("none", "partial"):
            out.append(r)
            if len(out) >= count:
                break
    return out
