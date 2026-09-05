# tests/passage_pipeline/test_assemble.py
import json
from pathlib import Path

from scripts.passage_pipeline import assemble, rukus

FIX = Path(__file__).parent / "fixtures"


def seed_passed(tmp_path, monkeypatch, approved=True):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path / "work")
    monkeypatch.setattr(assemble, "DATA_DIR", tmp_path / "data")
    (tmp_path / "data").mkdir()
    ref = rukus.passage(2, 4)
    ref.work_dir.mkdir(parents=True)
    for src, dst in (("draft_ok.json", "draft.json"), ("sources_ok.json", "sources.json"), ("verses_ok.json", "verses.json")):
        (ref.work_dir / dst).write_text((FIX / src).read_text(encoding="utf-8"), encoding="utf-8")
    draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    draft["essay"]["en"] = ("Tabatabai reads the question as a request, not an objection [1]. " * 30).strip()
    draft["perspectives"]["en"] = ("Both honour, not worship [3]. Names and words differ. " * 10).strip()
    (ref.work_dir / "draft.json").write_text(json.dumps(draft, ensure_ascii=False), encoding="utf-8")
    verdicts = [{"target": t, "claim": "c", "verdict": "supported", "excerpt": "x", "note": ""}
                for t in ("essay[1]", "verses.34.narrations.n1", "perspectives[3]")]
    (ref.work_dir / "audit.1.json").write_text(json.dumps({"passage": "2:4", "verdicts": verdicts, "uncited": [],
                                                           "coverage": "ok", "summary": "ok"}), encoding="utf-8")
    (ref.work_dir.parent / "titles.json").write_text(json.dumps({"4": {"range": [30, 39], "title": "Adam and the angels",
                                                                        "headings": {"34": "Iblis refuses"}, "approved": approved}}), encoding="utf-8")
    return ref


def test_assemble_writes_passages_file(tmp_path, monkeypatch):
    ref = seed_passed(tmp_path, monkeypatch)
    written, skipped = assemble.assemble(2)
    assert written == ["2:4"] and skipped == []
    out = json.loads((tmp_path / "data" / "passages_2.json").read_text(encoding="utf-8"))
    p = out["4"]
    assert p["id"] == "2:4" and p["range"] == [30, 39]
    assert p["title"]["en"] == "Adam and the angels"
    s1 = next(s for s in p["sources"] if s["id"] == "s1")
    assert s1["work"] == "al-Mizan fi Tafsir al-Quran" and s1["tier"] == "B"
    assert s1["locus"] == "on Al-Baqara 30 to 33" and s1["url"].startswith("https://")
    assert s1["excerpt"]["text"].startswith("وهذا الكلام") and s1["gloss"]
    assert "text" not in s1 and "sha256" not in s1
    assert p["verses"][0]["narrations"][0]["source"] == "s2"
    assert p["status"]["audit_attempts"] == 1


def test_assemble_skips_unapproved_titles(tmp_path, monkeypatch):
    seed_passed(tmp_path, monkeypatch, approved=False)
    written, skipped = assemble.assemble(2)
    assert written == [] and skipped == [("2:4", "titles not approved")]


def test_extract_gems(tmp_path, monkeypatch):
    monkeypatch.setattr(assemble, "DATA_DIR", tmp_path)
    (tmp_path / "tafsir_2.json").write_text(json.dumps({"30": {"layer1": "x", "quickOverview": {"concepts": []}},
                                                         "31": {"layer1": "y"}}), encoding="utf-8")
    n = assemble.extract_gems(2)
    assert n == 1
    gems = json.loads((tmp_path / "gems_2.json").read_text(encoding="utf-8"))
    assert gems == {"30": {"concepts": []}}
