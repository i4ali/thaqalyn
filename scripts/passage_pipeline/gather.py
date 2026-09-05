# scripts/passage_pipeline/gather.py
"""Stage 1: fetch and cache every block the writer may cite for one passage."""
from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone

from . import fetch as fetch_mod
from . import rukus, sources
from .rukus import PassageRef


def _now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def quotes_verse(hadith_arabic: str, query: str) -> bool:
    """True when the hadith's Arabic contains the verse opening the search was built
    from. Typesense drops query words until something matches, so without this a
    verse's hits are mostly unrelated texts sharing a common word."""
    return bool(query) and query in fetch_mod.strip_tashkeel(hadith_arabic)


def build_verses(ref: PassageRef) -> dict:
    info = rukus.surah_info(ref.surah)
    return {
        "surah": {"number": ref.surah, "englishName": info["englishName"],
                  "englishNameTranslation": info["englishNameTranslation"],
                  "revelationType": info["revelationType"], "versesCount": info["versesCount"],
                  "passageCount": len(rukus.passages_for_surah(ref.surah))},
        "passage": {"id": ref.id, "index": ref.index, "range": [ref.start, ref.end]},
        "verses": [
            {"verse": v, "arabic": rec["arabicText"], "translation": rec["translation"],
             "translationUrdu": rec.get("translationUrdu", "")}
            for v in ref.verses() for rec in [rukus.verse_record(ref.surah, v)]
        ],
    }


def gather(ref: PassageRef, *, fetch=None, hadith=None) -> dict:
    fetch = fetch or fetch_mod.fetch_altafsir
    hadith = hadith or fetch_mod.search_hadith
    verses = build_verses(ref)
    name = verses["surah"]["englishName"]
    records: list[dict] = []
    by_hash: dict[tuple[str, str], dict] = {}
    unavailable: dict[str, list[int]] = {}

    for key in sources.GATHER_KEYS:
        meta = sources.WORKS[key]
        for v in ref.verses():
            block = fetch(key, ref.surah, v)
            if block is None:
                unavailable.setdefault(key, []).append(v)
                continue
            text = block.text.strip()
            h = (key, _sha(text))
            if h in by_hash:
                by_hash[h]["verses"].append(v)
                continue
            rec = {"id": None, "key": key, "kind": meta["kind"], "work": meta["work"],
                   "author": meta["author"], "tradition": meta["tradition"], "tier": meta["tier"],
                   "role": meta["role"], "verses": [v], "locus": None, "url": block.url,
                   "sha256": h[1], "fetched_at": _now(), "text": text}
            by_hash[h] = rec
            records.append(rec)

    dropped = 0
    for v in ref.verses():
        arabic = rukus.verse_record(ref.surah, v)["arabicText"]
        query = fetch_mod.hadith_query_from_arabic(arabic)
        try:
            hits = hadith(query, limit=10)
        except RuntimeError:
            unavailable.setdefault("thaqalayn", []).append(v)
            continue
        for hit in hits:
            if not quotes_verse(hit.get("text_ar", ""), query):
                dropped += 1
                continue
            text = f"{hit['text_ar']}\n{hit['text_en']}".strip()
            h = ("thaqalayn", _sha(text))
            if h in by_hash:
                by_hash[h]["verses"].append(v)
                continue
            locus = ", ".join(p for p in [
                f"vol. {hit['volume']}" if hit.get("volume") else "",
                f"hadith {hit['number']}" if hit.get("number") is not None else "",
            ] if p) + f", cited at {name} {v}"
            rec = {"id": None, "key": "thaqalayn", "kind": "hadith", "work": hit["book"],
                   "author": hit["author"], "tradition": "shia", "tier": "A", "role": "narrations",
                   "verses": [v], "locus": locus, "url": hit["url"], "sha256": h[1],
                   "fetched_at": _now(), "text": text, "grades": hit.get("grades", [])}
            by_hash[h] = rec
            records.append(rec)

    for i, rec in enumerate(records, start=1):
        rec["id"] = f"s{i}"
        rec["verses"] = sorted(set(rec["verses"]))
        if rec["locus"] is None:
            rec["locus"] = sources.locus_for(name, rec["verses"])

    ref.work_dir.mkdir(parents=True, exist_ok=True)
    (ref.work_dir / "verses.json").write_text(json.dumps(verses, ensure_ascii=False, indent=2), encoding="utf-8")
    payload = {"passage": ref.id, "gathered_at": _now(), "unavailable": unavailable,
               "corpus_hits_dropped": dropped, "sources": records}
    (ref.work_dir / "sources.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    return payload
