# scripts/passage_pipeline/assemble.py
"""Stage 6: merge passed drafts into the app data file."""
from __future__ import annotations

import json
from datetime import datetime, timezone

from . import audit as audit_mod
from . import rukus
from . import status as status_mod

DATA_DIR = rukus.DATA_DIR
SOURCE_PUBLIC_FIELDS = ("id", "kind", "work", "author", "tradition", "tier", "locus", "url", "grades")


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def _iso(dt: datetime) -> str:
    return dt.replace(microsecond=0).isoformat().replace("+00:00", "Z")


def build_record(ref: rukus.PassageRef) -> dict:
    d = ref.work_dir
    draft, gathered = _read(d / "draft.json"), _read(d / "sources.json")
    by_id = {s["id"]: s for s in gathered["sources"]}
    merged_sources = []
    for s in draft["sources"]:
        g = by_id[s["id"]]
        rec = {k: g[k] for k in SOURCE_PUBLIC_FIELDS if k in g}
        rec["excerpt"] = s.get("excerpt")
        rec["gloss"] = s.get("gloss")
        merged_sources.append(rec)
    latest = audit_mod.latest(d)
    return {
        "id": ref.id, "surah": ref.surah, "index": ref.index, "range": [ref.start, ref.end],
        "title": draft["title"], "essay": draft["essay"], "verses": draft.get("verses") or [],
        "perspectives": draft.get("perspectives"), "sources": merged_sources,
        "status": {"gathered_at": gathered.get("gathered_at"),
                   "audit_attempts": audit_mod.next_attempt(d) - 1,
                   "audited_at": _iso(datetime.fromtimestamp(latest.stat().st_mtime, timezone.utc)) if latest else None,
                   "assembled_at": _iso(datetime.now(timezone.utc))},
    }


def assemble(surah: int) -> tuple[list[str], list[tuple[str, str]]]:
    out_path = DATA_DIR / f"passages_{surah}.json"
    existing = _read(out_path) if out_path.exists() else {}
    written, skipped = [], []
    for ref in rukus.passages_for_surah(surah):
        s = status_mod.state(ref)
        if s["stage"] == "new":
            continue
        if s["stage"] != "passed":
            skipped.append((ref.id, f"stage {s['stage']}"))
            continue
        if not s["valid"]:
            skipped.append((ref.id, "draft invalid"))
            continue
        if not s["titles"]:
            skipped.append((ref.id, "titles not approved"))
            continue
        existing[str(ref.index)] = build_record(ref)
        written.append(ref.id)
    if written:
        ordered = {k: existing[k] for k in sorted(existing, key=int)}
        out_path.write_text(json.dumps(ordered, ensure_ascii=False, indent=2), encoding="utf-8")
    return written, skipped


def extract_gems(surah: int) -> int:
    src = DATA_DIR / f"tafsir_{surah}.json"
    tafsir = _read(src)
    gems = {k: v["quickOverview"] for k, v in tafsir.items() if isinstance(v, dict) and v.get("quickOverview")}
    (DATA_DIR / f"gems_{surah}.json").write_text(json.dumps(gems, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(gems)
