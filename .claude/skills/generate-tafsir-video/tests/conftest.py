# .claude/skills/generate-tafsir-video/tests/conftest.py
import json
from pathlib import Path
import pytest


@pytest.fixture
def tmp_data_dir(tmp_path):
    """Mimics Thaqalayn/Thaqalayn/Data/ layout."""
    d = tmp_path / "Data"
    d.mkdir()
    return d


@pytest.fixture
def minimal_tafsir(tmp_data_dir):
    """Writes a tafsir_2.json with verse 258 layer2 populated."""
    path = tmp_data_dir / "tafsir_2.json"
    data = {
        "258": {
            "layer1": "Layer 1 placeholder text.",
            "layer2": "Allamah Tabatabai in Al-Mizan presents the debate between Ibrahim and the king who arrogantly claimed to control life and death. Tabatabai argues this verse demonstrates the irrationality of denying divine sovereignty.",
        }
    }
    path.write_text(json.dumps(data))
    return path


@pytest.fixture
def minimal_quran(tmp_data_dir):
    """Writes a quran_data.json with surah 2 metadata."""
    path = tmp_data_dir / "quran_data.json"
    data = {
        "surahs": [
            {"number": 1, "englishName": "Al-Fatiha"},
            {"number": 2, "englishName": "Al-Baqarah"},
        ]
    }
    path.write_text(json.dumps(data))
    return path
