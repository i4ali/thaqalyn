import sys
from pathlib import Path
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from generate_tafsir_video import parse_verse, output_path_for  # noqa: E402


def test_parse_verse_valid():
    assert parse_verse("2:258") == (2, 258)


def test_parse_verse_invalid_raises():
    with pytest.raises(ValueError, match="Expected SURAH:VERSE"):
        parse_verse("nope")


def test_output_path_for():
    p = output_path_for(2, 258, base_dir=Path("/tmp/out"))
    assert p == Path("/tmp/out/2_258.mp4")
