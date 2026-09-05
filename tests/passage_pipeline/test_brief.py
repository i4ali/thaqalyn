# tests/passage_pipeline/test_brief.py
import json
from pathlib import Path

from scripts.passage_pipeline import brief

FIX = Path(__file__).parent / "fixtures"


def load(name):
    return json.loads((FIX / name).read_text(encoding="utf-8"))


def test_writer_brief_lists_verses_and_sources():
    out = brief.render(load("verses_ok.json"), load("sources_ok.json"), draft=None)
    assert "# Passage 2:4 · Al-Baqara 30 to 39" in out
    assert "## Verses" in out and "### 34" in out
    assert "## Sources you may cite" in out
    assert "### s1 · al-Mizan fi Tafsir al-Quran · Allamah Muhammad Husayn Tabatabai · shia · tier B · essay" in out
    assert "### s2 · al-Burhan fi Tafsir al-Quran" in out
    assert "أخرج ما كان في قلب إبليس" in out
    assert "## Draft" not in out


def test_audit_brief_includes_draft():
    draft = load("draft_ok.json")
    out = brief.render(load("verses_ok.json"), load("sources_ok.json"), draft=draft)
    assert "## Draft under audit" in out
    assert '"title"' in out and "Adam and the angels" in out


def test_unavailable_sources_are_named():
    srcs = load("sources_ok.json")
    srcs["unavailable"] = {"qummi": [30, 31]}
    out = brief.render(load("verses_ok.json"), srcs, draft=None)
    assert "qummi: verses 30, 31" in out
