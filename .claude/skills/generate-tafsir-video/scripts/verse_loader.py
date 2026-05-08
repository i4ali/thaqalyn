"""Load tafsir layers and surah metadata from project Data JSON."""
from __future__ import annotations
import json
from pathlib import Path


def _default_data_dir() -> Path:
    # When invoked from project root: Thaqalayn/Thaqalayn/Data/
    return Path(__file__).resolve().parents[4] / "Thaqalayn" / "Thaqalayn" / "Data"


def load_tafsir_layer(surah: int, verse: int, layer: str = "layer2", data_dir: Path | None = None) -> str:
    data_dir = Path(data_dir) if data_dir else _default_data_dir()
    path = data_dir / f"tafsir_{surah}.json"
    if not path.exists():
        raise FileNotFoundError(f"Tafsir file not found for surah {surah}: {path}")
    data = json.loads(path.read_text())
    verse_obj = data.get(str(verse))
    if not verse_obj:
        raise ValueError(f"Verse {verse} not found in surah {surah}")
    text = verse_obj.get(layer)
    if not text or not isinstance(text, str) or not text.strip():
        raise ValueError(f"{layer} missing or empty for {surah}:{verse}")
    return text


def get_surah_english_name(surah: int, data_dir: Path | None = None) -> str:
    data_dir = Path(data_dir) if data_dir else _default_data_dir()
    path = data_dir / "quran_data.json"
    if not path.exists():
        raise FileNotFoundError(f"quran_data.json not found at {path}")
    data = json.loads(path.read_text())
    for s in data.get("surahs", []):
        if s.get("number") == surah:
            name = s.get("englishName")
            if not name:
                raise ValueError(f"Surah {surah} has no englishName")
            return name.upper()
    raise ValueError(f"Surah {surah} not found in quran_data.json")
