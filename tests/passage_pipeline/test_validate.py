# tests/passage_pipeline/test_validate.py
import copy
import json
from pathlib import Path

import pytest

from scripts.passage_pipeline import validate as v

FIX = Path(__file__).parent / "fixtures"
ESSAY = ("The passage opens with an announcement, not a creation. Tabatabai reads the angels' question "
         "as a request to understand, not an objection [1]. ") * 12  # about 300 words
PERSP = ("Both traditions read the prostration as honouring Adam, not worship [3]. They part on the "
         "names and on the words of verse 37. ") * 4  # about 90 words


@pytest.fixture
def bundle():
    draft = json.loads((FIX / "draft_ok.json").read_text(encoding="utf-8"))
    draft["essay"]["en"] = ESSAY.strip()
    draft["perspectives"]["en"] = PERSP.strip()
    sources = json.loads((FIX / "sources_ok.json").read_text(encoding="utf-8"))
    verses = json.loads((FIX / "verses_ok.json").read_text(encoding="utf-8"))
    return draft, sources, verses


def errors(bundle, mutate=None):
    draft, sources, verses = copy.deepcopy(bundle)
    if mutate:
        mutate(draft, sources, verses)
    return v.validate_draft(draft, sources, verses)


def test_valid_draft_has_no_errors(bundle):
    assert errors(bundle) == []


def test_word_count_ignores_markers():
    assert v.word_count("Tabatabai reads it [1] as a request [12].") == 6


def test_normalize_arabic_strips_tashkeel_and_alef_forms():
    assert v.normalize_arabic("أَخْرَجَ مَا كَانَ") == v.normalize_arabic("اخرج ما كان")


def test_marker_must_resolve(bundle):
    errs = errors(bundle, lambda d, s, vv: d["essay"].__setitem__("en", d["essay"]["en"] + " Also [9]."))
    assert any("[9]" in e and "no source" in e for e in errs)


def test_every_source_must_be_used(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = d["essay"]["en"].replace("[1]", "")
    assert any("s1" in e and "never cited" in e for e in errors(bundle, mutate))


def test_draft_source_must_exist_in_gathered(bundle):
    def mutate(d, s, vv):
        d["sources"].append({"id": "s4", "excerpt": None, "gloss": None})
    assert any("s4" in e and "not in sources.json" in e for e in errors(bundle, mutate))


def test_excerpt_must_be_substring_of_block(bundle):
    def mutate(d, s, vv):
        d["sources"][0]["excerpt"]["text"] = "كلام لا وجود له في المصدر"
    assert any("s1" in e and "excerpt" in e and "not found" in e for e in errors(bundle, mutate))


def test_excerpt_may_join_spans_with_ellipsis(bundle):
    def mutate(d, s, vv):
        d["sources"][1]["excerpt"]["text"] = "فلما أمر الله الملائكة … لم يكن منهم"
    assert errors(bundle, mutate) == []


def test_tier_b_excerpt_limited_to_one_sentence(bundle):
    def mutate(d, s, vv):
        d["sources"][0]["excerpt"]["text"] = s["sources"][0]["text"]  # two sentences
    assert any("s1" in e and "tier B" in e for e in errors(bundle, mutate))


def test_tier_c_forbids_excerpt(bundle):
    def mutate(d, s, vv):
        s["sources"][0]["tier"] = "C"
    assert any("s1" in e and "tier C" in e for e in errors(bundle, mutate))


def test_narration_arabic_must_be_in_source(bundle):
    def mutate(d, s, vv):
        d["verses"][0]["narrations"][0]["arabic"] = "نص مخترع"
    assert any("n1" in e and "arabic" in e and "not found" in e for e in errors(bundle, mutate))


def test_narration_source_must_bear_narrations(bundle):
    def mutate(d, s, vv):
        d["verses"][0]["narrations"][0]["source"] = "s1"
        d["verses"][0]["narrations"][0]["arabic"] = "وليس من الاعتراض والخصومة في شيء"
    assert any("n1" in e and "mizan" in e and "not a narration source" in e for e in errors(bundle, mutate))


def test_sunni_source_outside_perspectives_rejected(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = d["essay"]["en"].replace("[1]", "[1][3]", 1)
    assert any("[3]" in e and "sunni" in e and "essay" in e for e in errors(bundle, mutate))


def test_essay_budget_for_long_passage(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = "Short essay [1]."
    assert any("essay" in e and "250" in e for e in errors(bundle, mutate))


def test_essay_budget_for_short_passage(bundle):
    def mutate(d, s, vv):
        vv["passage"]["range"] = [30, 34]
        vv["verses"] = vv["verses"][:5]
        d["essay"]["en"] = ("word " * 260).strip() + " [1]"
    assert any("essay" in e and "250" in e and "over" in e for e in errors(bundle, mutate))


def test_note_and_title_budgets(bundle):
    def mutate(d, s, vv):
        d["title"]["en"] = "One two three four five six seven"
        d["verses"][0]["note"]["en"] = ("w " * 41).strip()
    errs = errors(bundle, mutate)
    assert any("title" in e and "6 words" in e for e in errs)
    assert any("note" in e and "40 words" in e for e in errs)


def test_max_three_narrations_per_verse(bundle):
    def mutate(d, s, vv):
        n = d["verses"][0]["narrations"][0]
        d["verses"][0]["narrations"] = [dict(n, id=f"n{i}") for i in range(1, 5)]
    assert any("verse 34" in e and "3 narrations" in e for e in errors(bundle, mutate))


def test_verse_entry_needs_note_or_narration(bundle):
    def mutate(d, s, vv):
        d["verses"].append({"verse": 35, "heading": {"en": "x"}, "note": None, "narrations": []})
    assert any("verse 35" in e and "nothing of its own" in e for e in errors(bundle, mutate))


def test_verse_must_be_in_range_and_unique(bundle):
    def mutate(d, s, vv):
        d["verses"].append(dict(d["verses"][0], verse=99))
        d["verses"].append(dict(d["verses"][0]))
    errs = errors(bundle, mutate)
    assert any("verse 99" in e and "outside" in e for e in errs)
    assert any("verse 34" in e and "twice" in e for e in errs)


def test_style_rules(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = d["essay"]["en"] + " Ṭabāṭabāʾī — said."
    errs = errors(bundle, mutate)
    assert any("diacritic" in e for e in errs)
    assert any("em dash" in e for e in errs)


def test_perspectives_optional_but_budgeted(bundle):
    def mutate(d, s, vv):
        d["perspectives"] = None
        d["sources"] = d["sources"][:2]
    assert errors(bundle, mutate) == []

    def mutate2(d, s, vv):
        d["perspectives"]["en"] = "Tiny [3]."
    assert any("perspectives" in e and "60" in e for e in errors(bundle, mutate2))


def test_passage_id_must_match(bundle):
    assert any("passage" in e for e in errors(bundle, lambda d, s, vv: d.__setitem__("passage", "2:5")))
