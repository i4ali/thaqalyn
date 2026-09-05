# scripts/passage_pipeline/titles.py
from __future__ import annotations

import json
from pathlib import Path

from . import rukus


def _review_path(surah: int) -> Path:
    return rukus.WORK_DIR / str(surah) / "titles.json"


def collect(surah: int) -> Path:
    path = _review_path(surah)
    existing = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
    doc: dict = {}
    for ref in rukus.passages_for_surah(surah):
        dpath = ref.work_dir / "draft.json"
        if not dpath.exists():
            continue
        draft = json.loads(dpath.read_text(encoding="utf-8"))
        key = str(ref.index)
        headings = {str(e["verse"]): (e.get("heading") or {}).get("en", "") for e in draft.get("verses") or []}
        prev = existing.get(key)
        if prev:
            doc[key] = {"range": [ref.start, ref.end], "title": prev["title"],
                        "headings": {**headings, **prev.get("headings", {})}, "approved": bool(prev.get("approved"))}
        else:
            doc[key] = {"range": [ref.start, ref.end], "title": draft["title"]["en"],
                        "headings": headings, "approved": False}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(doc, ensure_ascii=False, indent=2), encoding="utf-8")
    return path


def apply(surah: int) -> list[str]:
    doc = json.loads(_review_path(surah).read_text(encoding="utf-8"))
    changed: list[str] = []
    for ref in rukus.passages_for_surah(surah):
        row = doc.get(str(ref.index))
        dpath = ref.work_dir / "draft.json"
        if not row or not row.get("approved") or not dpath.exists():
            continue
        draft = json.loads(dpath.read_text(encoding="utf-8"))
        before = json.dumps(draft, sort_keys=True)
        draft["title"]["en"] = row["title"]
        for entry in draft.get("verses") or []:
            h = row["headings"].get(str(entry["verse"]))
            if h:
                entry["heading"] = {**(entry.get("heading") or {}), "en": h}
        after = json.dumps(draft, sort_keys=True)
        if before != after:
            dpath.write_text(json.dumps(draft, ensure_ascii=False, indent=2), encoding="utf-8")
        changed.append(ref.id)
    return changed
