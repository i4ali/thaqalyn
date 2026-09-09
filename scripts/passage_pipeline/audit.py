# scripts/passage_pipeline/audit.py
"""Stage 4 support: the audit file format and the pass rule."""
from __future__ import annotations

import re
from pathlib import Path

from . import prose as prose_mod
from .validate import MARKER_RE

VERDICTS = {"supported", "stretched", "unsupported"}
AUDIT_FILE_RE = re.compile(r"audit\.(\d+)\.json$")


def expected_targets(draft: dict) -> set[str]:
    targets: set[str] = set()
    for n in MARKER_RE.findall((draft.get("essay") or {}).get("en", "")):
        targets.add(f"essay[{n}]")
    persp = draft.get("perspectives") or {}
    for n in MARKER_RE.findall(persp.get("en", "") if isinstance(persp, dict) else ""):
        targets.add(f"perspectives[{n}]")
    for entry in draft.get("verses") or []:
        vn = entry.get("verse")
        note = (entry.get("note") or {}).get("en", "") if entry.get("note") else ""
        for n in MARKER_RE.findall(note):
            targets.add(f"verses.{vn}.note[{n}]")
        for nar in entry.get("narrations") or []:
            targets.add(f"verses.{vn}.narrations.{nar.get('id')}")
    return targets


def check(audit_doc: dict, draft: dict) -> tuple[list[str], bool]:
    errs: list[str] = []
    if audit_doc.get("passage") != draft.get("passage"):
        errs.append("audit passage id does not match the draft")
    expected = expected_targets(draft)
    seen: set[str] = set()
    for v in audit_doc.get("verdicts") or []:
        t = v.get("target")
        if t not in expected:
            errs.append(f"verdict target {t!r} is not a marker or narration in the draft")
            continue
        seen.add(t)
        if v.get("verdict") not in VERDICTS:
            errs.append(f"{t}: verdict must be one of {sorted(VERDICTS)}")
        if v.get("verdict") != "unsupported" and not v.get("excerpt"):
            errs.append(f"{t}: a supported or stretched verdict needs the supporting excerpt")
    for t in sorted(expected - seen):
        errs.append(f"{t}: no verdict")
    if not isinstance(audit_doc.get("coverage"), str) or not audit_doc.get("coverage"):
        errs.append("coverage judgement is required")
    if audit_doc.get("prose") is not None:
        errs.extend(prose_mod.check_flags(audit_doc["prose"], draft))
    if errs:
        return errs, False
    # Pass rule (tightened 2026-09-05 after the 2:4 pilot audit): every verdict
    # must be supported and nothing may be uncited. A stretched claim anywhere,
    # including a wrong speaker in the essay or perspectives, forces a rewrite.
    # Prose flags (added 2026-09-08 after 2:3 shipped a garbled sentence) do not
    # fail the audit: status routes them to the polisher, see status.state().
    verdicts = audit_doc.get("verdicts") or []
    not_supported = [v for v in verdicts if v["verdict"] != "supported"]
    uncited = audit_doc.get("uncited") or []
    passed = not not_supported and not uncited
    return [], passed


def next_attempt(work_dir: Path) -> int:
    nums = [int(m.group(1)) for p in work_dir.glob("audit.*.json") for m in [AUDIT_FILE_RE.search(p.name)] if m]
    return (max(nums) + 1) if nums else 1


def latest(work_dir: Path) -> Path | None:
    n = next_attempt(work_dir) - 1
    return (work_dir / f"audit.{n}.json") if n >= 1 else None
