# tests/passage_pipeline/test_rukus.py
import pytest
from scripts.passage_pipeline import rukus


def test_al_baqarah_has_40_passages():
    assert len(rukus.passages_for_surah(2)) == 40


def test_adam_passage_is_index_4():
    p = rukus.passage(2, 4)
    assert (p.start, p.end) == (30, 39)
    assert p.id == "2:4"


def test_whole_quran_has_556_passages():
    assert len(rukus.all_passages()) == 556


def test_fatiha_is_one_passage():
    (p,) = rukus.passages_for_surah(1)
    assert (p.start, p.end) == (1, 7)


def test_passage_for_verse_finds_container():
    assert rukus.passage_for_verse(2, 141).index == 16
    assert rukus.passage_for_verse(2, 253).index == 33


def test_parse_passage_ref():
    p = rukus.parse_passage_ref("2:4")
    assert (p.surah, p.index, p.start, p.end) == (2, 4, 30, 39)


def test_parse_passage_ref_rejects_out_of_range():
    with pytest.raises(ValueError):
        rukus.parse_passage_ref("2:41")


def test_work_dir_is_zero_padded():
    assert rukus.passage(2, 4).work_dir.name == "04"
    assert rukus.passage(2, 4).work_dir.parent.name == "2"


def test_surah_info():
    info = rukus.surah_info(2)
    assert info["englishName"] == "Al-Baqara"
    assert info["versesCount"] == 286
