import pytest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from verse_loader import load_tafsir_layer, get_surah_english_name  # noqa: E402


def test_load_layer2_returns_text(minimal_tafsir):
    text = load_tafsir_layer(2, 258, layer="layer2", data_dir=minimal_tafsir.parent)
    assert "Tabatabai" in text


def test_load_layer_missing_file_raises(tmp_data_dir):
    with pytest.raises(FileNotFoundError, match="Tafsir file not found for surah 99"):
        load_tafsir_layer(99, 1, layer="layer2", data_dir=tmp_data_dir)


def test_load_layer_missing_verse_raises(minimal_tafsir):
    with pytest.raises(ValueError, match="Verse 999 not found in surah 2"):
        load_tafsir_layer(2, 999, layer="layer2", data_dir=minimal_tafsir.parent)


def test_load_layer_missing_layer_raises(minimal_tafsir):
    with pytest.raises(ValueError, match="layer5 missing or empty for 2:258"):
        load_tafsir_layer(2, 258, layer="layer5", data_dir=minimal_tafsir.parent)


def test_surah_english_name_uppercased(minimal_quran):
    assert get_surah_english_name(2, data_dir=minimal_quran.parent) == "AL-BAQARAH"


def test_surah_name_missing_raises(minimal_quran):
    with pytest.raises(ValueError, match="Surah 999 not found"):
        get_surah_english_name(999, data_dir=minimal_quran.parent)
