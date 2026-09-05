# tests/passage_pipeline/test_sources.py
from scripts.passage_pipeline import sources


def test_every_altafsir_key_has_a_work_entry():
    from scripts.passage_pipeline.fetch import ALTAFSIR_TAFSIRS
    for key in ALTAFSIR_TAFSIRS:
        assert key in sources.WORKS, key


def test_tiers_follow_copyright_status():
    assert sources.WORKS["burhan"]["tier"] == "A"
    assert sources.WORKS["majma"]["tier"] == "A"
    assert sources.WORKS["mizan"]["tier"] == "B"
    assert sources.WORKS["thaqalayn"]["tier"] == "A"


def test_sunni_works_are_perspectives_only():
    for key in ("tabari", "ibn-kathir", "qurtubi", "razi", "durr"):
        assert sources.WORKS[key]["tradition"] == "sunni"
        assert sources.WORKS[key]["role"] == "perspectives"


def test_narration_bearing_keys():
    assert sources.NARRATION_KEYS == {"qummi", "burhan", "safi", "furat", "majma", "thaqalayn"}


def test_gather_order_is_stable():
    assert sources.GATHER_KEYS[:3] == ["mizan", "majma", "tibyan"]
    assert sources.GATHER_KEYS[-1] == "durr"


def test_locus_wording():
    assert sources.locus_for("Al-Baqara", [30, 31, 32, 33]) == "on Al-Baqara 30 to 33"
    assert sources.locus_for("Al-Baqara", [34]) == "on Al-Baqara 34"
