# scripts/passage_pipeline/metrics.py
from __future__ import annotations

import json
from datetime import datetime

from . import audit as audit_mod
from . import rukus
from . import status as status_mod


def rows(surah: int) -> list[dict]:
    out = []
    for ref in rukus.passages_for_surah(surah):
        s = status_mod.state(ref)
        if s["stage"] == "new":
            continue
        d = ref.work_dir
        first = d / "audit.1.json"
        first_pass = None
        if first.exists():
            draft = json.loads((d / "draft.json").read_text(encoding="utf-8"))
            errs, passed = audit_mod.check(json.loads(first.read_text(encoding="utf-8")), draft)
            first_pass = passed and not errs
        gathered = json.loads((d / "sources.json").read_text(encoding="utf-8")).get("gathered_at")
        latest = audit_mod.latest(d)
        hours = None
        if gathered and latest:
            t0 = datetime.fromisoformat(gathered.replace("Z", "+00:00"))
            t1 = datetime.fromtimestamp(latest.stat().st_mtime, t0.tzinfo)
            hours = round((t1 - t0).total_seconds() / 3600, 1)
        out.append({"id": ref.id, "stage": s["stage"], "attempts": s["attempts"],
                    "first_pass": first_pass, "hours": hours, "sources": len(json.loads((d / "sources.json").read_text(encoding="utf-8"))["sources"])})
    return out
