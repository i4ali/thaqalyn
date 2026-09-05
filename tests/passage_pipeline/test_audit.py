# tests/passage_pipeline/test_audit.py
import copy
import json
from pathlib import Path

from scripts.passage_pipeline import audit

FIX = Path(__file__).parent / "fixtures"


def draft():
    d = json.loads((FIX / "draft_ok.json").read_text(encoding="utf-8"))
    d["essay"]["en"] = "Tabatabai reads it as a request, not an objection [1]."
    d["perspectives"]["en"] = "Both honour, not worship [3]."
    return d


def good_audit():
    return {"passage": "2:4", "verdicts": [
        {"target": "essay[1]", "claim": "Tabatabai: request, not objection", "verdict": "supported",
         "excerpt": "وليس من الاعتراض والخصومة في شيء", "note": ""},
        {"target": "verses.34.narrations.n1", "claim": "Imam al-Sadiq on envy", "verdict": "supported",
         "excerpt": "أخرج ما كان في قلب إبليس من الحسد", "note": ""},
        {"target": "perspectives[3]", "claim": "Tabari: honour not worship", "verdict": "supported",
         "excerpt": "لا عبادة لآدم", "note": ""},
    ], "uncited": [], "coverage": "The essay covers the whole passage.", "summary": "All supported."}


def test_expected_targets_come_from_draft():
    assert audit.expected_targets(draft()) == {"essay[1]", "verses.34.narrations.n1", "perspectives[3]"}


def test_good_audit_passes():
    errs, passed = audit.check(good_audit(), draft())
    assert errs == [] and passed is True


def test_missing_verdict_is_an_error():
    a = good_audit()
    a["verdicts"].pop()
    errs, _ = audit.check(a, draft())
    assert any("perspectives[3]" in e and "no verdict" in e for e in errs)


def test_unknown_target_is_an_error():
    a = good_audit()
    a["verdicts"][0]["target"] = "essay[7]"
    errs, _ = audit.check(a, draft())
    assert any("essay[7]" in e for e in errs)


def test_unsupported_fails():
    a = good_audit()
    a["verdicts"][0]["verdict"] = "unsupported"
    errs, passed = audit.check(a, draft())
    assert errs == [] and passed is False


def test_stretched_anywhere_fails():
    # Tightened after the 2:4 pilot: a wrong speaker in perspectives was ruled
    # "stretched" and would have shipped under a narrations-only rule.
    for i in range(3):
        a = good_audit()
        a["verdicts"][i]["verdict"] = "stretched"
        errs, passed = audit.check(a, draft())
        assert errs == [] and passed is False, a["verdicts"][i]["target"]


def test_uncited_claim_fails():
    a = good_audit()
    a["uncited"] = [{"where": "essay", "claim": "Makarem Shirazi holds X", "note": "named scholar, no marker"}]
    assert audit.check(a, draft())[1] is False


def test_next_attempt_number(tmp_path):
    assert audit.next_attempt(tmp_path) == 1
    (tmp_path / "audit.1.json").write_text("{}")
    (tmp_path / "audit.2.json").write_text("{}")
    assert audit.next_attempt(tmp_path) == 3
