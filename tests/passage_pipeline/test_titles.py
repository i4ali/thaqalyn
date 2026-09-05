# tests/passage_pipeline/test_titles.py
import json
from pathlib import Path

from scripts.passage_pipeline import rukus, titles

FIX = Path(__file__).parent / "fixtures"


def seed(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    ref.work_dir.mkdir(parents=True)
    (ref.work_dir / "draft.json").write_text((FIX / "draft_ok.json").read_text(encoding="utf-8"), encoding="utf-8")
    return ref


def test_collect_writes_review_file(tmp_path, monkeypatch):
    ref = seed(tmp_path, monkeypatch)
    path = titles.collect(2)
    doc = json.loads(path.read_text(encoding="utf-8"))
    assert doc["4"] == {"range": [30, 39], "title": "Adam and the angels",
                        "headings": {"34": "Iblis refuses"}, "approved": False}


def test_collect_preserves_existing_edits(tmp_path, monkeypatch):
    ref = seed(tmp_path, monkeypatch)
    titles.collect(2)
    path = ref.work_dir.parent / "titles.json"
    doc = json.loads(path.read_text(encoding="utf-8"))
    doc["4"]["title"] = "Adam, the angels and Iblis"
    doc["4"]["approved"] = True
    path.write_text(json.dumps(doc), encoding="utf-8")
    titles.collect(2)
    doc2 = json.loads(path.read_text(encoding="utf-8"))
    assert doc2["4"]["title"] == "Adam, the angels and Iblis" and doc2["4"]["approved"] is True


def test_apply_writes_back_into_drafts(tmp_path, monkeypatch):
    ref = seed(tmp_path, monkeypatch)
    path = titles.collect(2)
    doc = json.loads(path.read_text(encoding="utf-8"))
    doc["4"]["title"] = "Adam, the angels and Iblis"
    doc["4"]["headings"]["34"] = "The refusal of Iblis"
    doc["4"]["approved"] = True
    path.write_text(json.dumps(doc), encoding="utf-8")
    changed = titles.apply(2)
    assert changed == ["2:4"]
    draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    assert draft["title"]["en"] == "Adam, the angels and Iblis"
    assert draft["verses"][0]["heading"]["en"] == "The refusal of Iblis"
