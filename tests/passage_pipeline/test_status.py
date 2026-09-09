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


def _passing_audit():
    return {"passage": "2:4", "verdicts": [
        {"target": "verses.34.narrations.n1", "claim": "Imam al-Sadiq on envy", "verdict": "supported",
         "excerpt": "أخرج ما كان في قلب إبليس من الحسد", "note": ""}],
        "uncited": [], "coverage": "x", "summary": "1 supported"}


def _prepare(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    ref.work_dir.mkdir(parents=True)
    for name in ("verses.json", "sources.json"):
        (ref.work_dir / name).write_text((FIX / name.replace(".json", "_ok.json")).read_text(encoding="utf-8"), encoding="utf-8")
    (ref.work_dir / "draft.json").write_text((FIX / "draft_ok.json").read_text(encoding="utf-8"), encoding="utf-8")
    return ref


def test_pass_with_outstanding_prose_flag_is_polish_stage(tmp_path, monkeypatch):
    ref = _prepare(tmp_path, monkeypatch)
    a = _passing_audit()
    a["prose"] = [{"where": "verses.34.note", "sentence": "Refused, then arrogant, then faithless.", "note": "fragment"}]
    (ref.work_dir / "audit.1.json").write_text(json.dumps(a, ensure_ascii=False), encoding="utf-8")
    s = status.state(ref)
    assert s["audit"] == "PASS" and s["prose"] == 1 and s["stage"] == "polish"
    assert [r.id for r in status.next_passages(surah=2, count=10)][3] == "2:4"  # still work to do


def test_pass_with_resolved_prose_flag_is_passed(tmp_path, monkeypatch):
    ref = _prepare(tmp_path, monkeypatch)
    (ref.work_dir / "audit.1.json").write_text(json.dumps(_passing_audit(), ensure_ascii=False), encoding="utf-8")
    # A prose.json flag whose sentence is no longer in the draft has resolved itself.
    (ref.work_dir / "prose.json").write_text(json.dumps({"passage": "2:4", "flags": [
        {"where": "essay", "sentence": "An old sentence that was polished away.", "note": ""}]}), encoding="utf-8")
    s = status.state(ref)
    assert s["audit"] == "PASS" and s["prose"] == 0 and s["stage"] == "passed"


def test_prose_json_flag_holds_a_passed_passage(tmp_path, monkeypatch):
    ref = _prepare(tmp_path, monkeypatch)
    (ref.work_dir / "audit.1.json").write_text(json.dumps(_passing_audit(), ensure_ascii=False), encoding="utf-8")
    (ref.work_dir / "prose.json").write_text(json.dumps({"passage": "2:4", "flags": [
        {"where": "verses.34.note", "sentence": "Refused, then arrogant, then faithless.", "note": "fragment"}]}), encoding="utf-8")
    assert status.state(ref)["stage"] == "polish"
