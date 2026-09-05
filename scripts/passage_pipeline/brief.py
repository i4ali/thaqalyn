# scripts/passage_pipeline/brief.py
from __future__ import annotations

import json


def render(verses: dict, gathered: dict, draft: dict | None) -> str:
    s = verses["surah"]
    p = verses["passage"]
    lo, hi = p["range"]
    out = [f"# Passage {p['id']} · {s['englishName']} {lo} to {hi}",
           f"{s['englishNameTranslation']} · {s['revelationType']} · passage {p['index']} of {s['passageCount']}", ""]
    out.append("## Verses")
    for v in verses["verses"]:
        out += [f"### {v['verse']}", v["arabic"], "", v["translation"], ""]
    out.append("## Sources you may cite")
    out.append("Cite by id only. Anything not listed here does not exist for this passage.")
    unavailable = gathered.get("unavailable") or {}
    if unavailable:
        out.append("Not available for this passage: " + "; ".join(
            f"{k}: verses {', '.join(map(str, vs))}" for k, vs in unavailable.items()))
    out.append("")
    for src in gathered["sources"]:
        out.append(f"### {src['id']} · {src['work'] or src['key']} · {src['author']} · {src['tradition']} · "
                   f"tier {src['tier']} · {src['role']}")
        out.append(f"{src['locus']} · {src['url']}")
        if src.get("grades"):
            out.append(f"grading: {', '.join(map(str, src['grades']))}")
        out += ["", src["text"], ""]
    if draft is not None:
        out += ["## Draft under audit", "```json", json.dumps(draft, ensure_ascii=False, indent=2), "```"]
    return "\n".join(out)
