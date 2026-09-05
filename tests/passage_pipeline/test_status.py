# tests/passage_pipeline/test_status.py
import json
from pathlib import Path

from scripts.passage_pipeline import rukus, status

FIX = Path(__file__).parent / "fixtures"


def test_state_progression(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    assert status.state(ref)["stage"] == "new"
    ref.work_dir.mkdir(parents=True)
    for name in ("verses.json", "sources.json"):
        (ref.work_dir / name).write_text((FIX / name.replace(".json", "_ok.json")).read_text(encoding="utf-8"), encoding="utf-8")
    assert status.state(ref)["stage"] == "gathered"
    (ref.work_dir / "draft.json").write_text((FIX / "draft_ok.json").read_text(encoding="utf-8"), encoding="utf-8")
    s = status.state(ref)
    assert s["stage"] == "drafted" and s["valid"] is False  # placeholder essay is under budget
    (ref.work_dir / "audit.1.json").write_text(json.dumps({"passage": "2:4", "verdicts": [], "uncited": [], "coverage": "x"}), encoding="utf-8")
    s = status.state(ref)
    assert s["attempts"] == 1


def test_next_lists_passages_not_yet_passed(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    refs = status.next_passages(surah=2, count=2)
    assert [r.id for r in refs] == ["2:1", "2:2"]
