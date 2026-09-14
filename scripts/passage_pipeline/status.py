# scripts/passage_pipeline/status.py
from __future__ import annotations

import json

from . import audit as audit_mod
from . import prose as prose_mod
from . import rukus
from . import validate as validate_mod
from .rukus import PassageRef


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def state(ref: PassageRef) -> dict:
    d = ref.work_dir
    out = {"id": ref.id, "range": [ref.start, ref.end], "stage": "new", "valid": None,
           "attempts": 0, "audit": None, "prose": 0, "titles": False}
    if not (d / "sources.json").exists():
        return out
    out["stage"] = "gathered"
    if not (d / "draft.json").exists():
        return out
    out["stage"] = "drafted"
    draft = _read(d / "draft.json")
    errs = validate_mod.validate_draft(draft, _read(d / "sources.json"), _read(d / "verses.json"))
    out["valid"] = not errs
    latest = audit_mod.latest(d)
    audit_doc = None
    if latest:
        out["attempts"] = audit_mod.next_attempt(d) - 1
        audit_doc = _read(latest)
        aerrs, passed = audit_mod.check(audit_doc, draft, polished=prose_mod.polished(d))
        out["audit"] = "malformed" if aerrs else ("PASS" if passed else "FAIL")
        out["stage"] = "passed" if out["audit"] == "PASS" else "audited"
    # Prose flags never fail an audit, but a passage is not passed (and so not
    # assembled) while a flagged sentence is still in the draft.
    out["prose"] = len(prose_mod.outstanding(d, draft, audit_doc if out["audit"] != "malformed" else None))
    if out["stage"] == "passed" and out["prose"]:
        out["stage"] = "polish"
    titles = d.parent / "titles.json"
    if titles.exists():
        out["titles"] = bool(_read(titles).get(str(ref.index), {}).get("approved"))
    return out


def next_passages(surah: int | None, count: int) -> list[PassageRef]:
    refs = rukus.passages_for_surah(surah) if surah else rukus.all_passages()
    return [r for r in refs if state(r)["stage"] != "passed"][:count]
