import json
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from synthesize_speech import synthesize, parse_alignment  # noqa: E402


def test_parse_alignment_returns_word_timings():
    raw = {
        "alignment": {
            "characters": ["H", "i", " ", "y", "o", "u"],
            "character_start_times_seconds": [0.0, 0.1, 0.2, 0.3, 0.4, 0.5],
            "character_end_times_seconds": [0.1, 0.2, 0.3, 0.4, 0.5, 0.6],
        }
    }
    timings = parse_alignment(raw)
    assert timings == [
        {"word": "Hi", "start": 0.0, "end": 0.2},
        {"word": "you", "start": 0.3, "end": 0.6},
    ]


def test_synthesize_writes_mp3_and_timings(tmp_path, monkeypatch):
    monkeypatch.setenv("ELEVENLABS_API_KEY", "fake")
    audio_bytes = b"\xff\xfb\x90\x44" + b"\x00" * 100  # fake mp3-ish
    fake_response = MagicMock(status_code=200)
    fake_response.json.return_value = {
        "audio_base64": __import__("base64").b64encode(audio_bytes).decode(),
        "alignment": {
            "characters": ["H", "i"],
            "character_start_times_seconds": [0.0, 0.1],
            "character_end_times_seconds": [0.1, 0.2],
        },
    }

    with patch("synthesize_speech.requests.post", return_value=fake_response):
        out_audio = tmp_path / "n.mp3"
        out_timings = tmp_path / "t.json"
        synthesize("Hi", out_audio, out_timings)

    assert out_audio.exists() and out_audio.read_bytes() == audio_bytes
    timings = json.loads(out_timings.read_text())
    assert timings == [{"word": "Hi", "start": 0.0, "end": 0.2}]


def test_synthesize_non_200_raises(tmp_path, monkeypatch):
    monkeypatch.setenv("ELEVENLABS_API_KEY", "fake")
    fake_response = MagicMock(status_code=401)
    fake_response.text = "Unauthorized"
    with patch("synthesize_speech.requests.post", return_value=fake_response):
        with pytest.raises(RuntimeError, match="ElevenLabs TTS failed: 401"):
            synthesize("Hi", tmp_path / "n.mp3", tmp_path / "t.json")
