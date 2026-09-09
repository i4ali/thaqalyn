# scripts/passage_pipeline/prose.py
"""Prose flags: sentences a reader stumbles on or misreads.

A flag is {"where": ..., "sentence": ..., "note": ...} with the sentence copied
verbatim from the draft. Flags come from two files in a passage's work dir:
`prose.json` (written by the passage-prose-reader agent over existing drafts)
and the `prose` list of the latest audit (written by the passage-auditor for
new drafts). A flag is outstanding while its sentence still occurs verbatim in
the draft's English; once the passage-polisher has rewritten the sentence the
flag resolves itself, with no bookkeeping.
"""
from __future__ import annotations

import json
from pathlib import Path

PROSE_FILE = "prose.json"


def _en(value) -> str:
    return value.get("en", "") if isinstance(value, dict) else ""


def english_text(draft: dict) -> str:
    """Every English string a reader sees: essay, notes, narration text, perspectives."""
    parts = [_en(draft.get("essay"))]
    for entry in draft.get("verses") or []:
        parts.append(_en(entry.get("note")))
        for nar in entry.get("narrations") or []:
            parts.append(_en(nar.get("text")))
    parts.append(_en(draft.get("perspectives")))
    return "\n".join(p for p in parts if p)


def _read(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def flags(work_dir: Path, audit_doc: dict | None = None) -> list[dict]:
    """Flags from prose.json plus the given audit's `prose` list, deduplicated by (where, sentence)."""
    out: list[dict] = []
    seen: set[tuple] = set()

    def add(items) -> None:
        for f in items or []:
            if not isinstance(f, dict):
                continue
            key = (f.get("where"), f.get("sentence"))
            if key in seen:
                continue
            seen.add(key)
            out.append(f)

    path = work_dir / PROSE_FILE
    if path.exists():
        add(_read(path).get("flags"))
    if audit_doc:
        add(audit_doc.get("prose"))
    return out


def outstanding(work_dir: Path, draft: dict, audit_doc: dict | None = None) -> list[dict]:
    """Flags whose sentence is still in the draft."""
    text = english_text(draft)
    return [f for f in flags(work_dir, audit_doc) if f.get("sentence") and f["sentence"] in text]


def check_flags(items, draft: dict, label: str = "prose") -> list[str]:
    """Shape check shared by prose.json and the audit's prose list."""
    errs: list[str] = []
    if not isinstance(items, list):
        return [f"{label} must be a list"]
    text = english_text(draft)
    for i, f in enumerate(items):
        tag = f"{label}[{i}]"
        if not isinstance(f, dict):
            errs.append(f"{tag}: must be an object with where, sentence and note")
            continue
        if not f.get("where"):
            errs.append(f"{tag}: needs where (essay, perspectives, verses.<verse>.note or verses.<verse>.narrations.<id>)")
        sentence = f.get("sentence")
        if not sentence or not isinstance(sentence, str):
            errs.append(f"{tag}: needs the sentence copied verbatim from the draft")
        elif sentence not in text:
            errs.append(f"{tag}: sentence is not in the draft verbatim: {sentence[:60]!r}")
    return errs


def check(doc: dict, draft: dict) -> list[str]:
    """Validate a prose.json document against the draft it describes."""
    errs: list[str] = []
    if doc.get("passage") != draft.get("passage"):
        errs.append("prose passage id does not match the draft")
    errs.extend(check_flags(doc.get("flags"), draft, "flags"))
    return errs
