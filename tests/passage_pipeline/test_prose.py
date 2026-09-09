# tests/passage_pipeline/test_prose.py
import json
from pathlib import Path

from scripts.passage_pipeline import prose

FIX = Path(__file__).parent / "fixtures"

BAD = "Tusi notes that a sky without pillars could be the work of nothing created [1]."
GOOD = "Tusi notes that a sky without pillars is beyond the power of anything created [1]."


def draft():
    d = json.loads((FIX / "draft_ok.json").read_text(encoding="utf-8"))
    d["essay"]["en"] = f"The grounds follow. {BAD} Then the challenge."
    d["perspectives"]["en"] = "Both honour, not worship [3]."
    return d


def flag(sentence=BAD, where="essay"):
    return {"where": where, "sentence": sentence, "note": "negation inverted"}


def write_prose(tmp_path, flags, passage="2:4"):
    (tmp_path / "prose.json").write_text(json.dumps({"passage": passage, "flags": flags}), encoding="utf-8")


def test_english_text_covers_every_reader_facing_string():
    text = prose.english_text(draft())
    assert BAD in text
    assert "Iblis was of the jinn" in text            # verse note
    assert "brought out the envy" in text             # narration text
    assert "Both honour, not worship" in text         # perspectives


def test_no_files_means_no_flags(tmp_path):
    assert prose.flags(tmp_path) == []
    assert prose.outstanding(tmp_path, draft()) == []


def test_flag_is_outstanding_while_sentence_is_in_the_draft(tmp_path):
    write_prose(tmp_path, [flag()])
    assert [f["sentence"] for f in prose.outstanding(tmp_path, draft())] == [BAD]


def test_flag_resolves_once_the_sentence_changes(tmp_path):
    write_prose(tmp_path, [flag()])
    d = draft()
    d["essay"]["en"] = d["essay"]["en"].replace(BAD, GOOD)
    assert prose.outstanding(tmp_path, d) == []


def test_audit_prose_merges_with_prose_json_and_deduplicates(tmp_path):
    write_prose(tmp_path, [flag()])
    audit_doc = {"prose": [flag(), flag("Both honour, not worship [3].", "perspectives")]}
    merged = prose.flags(tmp_path, audit_doc)
    assert [(f["where"], f["sentence"]) for f in merged] == [
        ("essay", BAD), ("perspectives", "Both honour, not worship [3].")]
    assert len(prose.outstanding(tmp_path, draft(), audit_doc)) == 2


def test_check_accepts_a_good_file():
    assert prose.check({"passage": "2:4", "flags": [flag()]}, draft()) == []
    assert prose.check({"passage": "2:4", "flags": []}, draft()) == []


def test_check_rejects_passage_mismatch_missing_where_and_unknown_sentence():
    errs = prose.check({"passage": "2:5", "flags": [
        {"sentence": BAD, "note": "no where"},
        {"where": "essay", "sentence": "This sentence is not in the draft.", "note": ""},
        "not an object",
    ]}, draft())
    assert any("does not match" in e for e in errs)
    assert any("needs where" in e for e in errs)
    assert any("not in the draft verbatim" in e for e in errs)
    assert any("must be an object" in e for e in errs)


def test_check_rejects_flags_that_are_not_a_list():
    assert prose.check({"passage": "2:4", "flags": None}, draft()) == ["flags must be a list"]
