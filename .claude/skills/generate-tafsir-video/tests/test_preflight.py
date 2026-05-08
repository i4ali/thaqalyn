import os
import sys
from pathlib import Path
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from preflight import (  # noqa: E402
    check_base_video,
    check_elevenlabs_key,
    check_ffmpeg,
    check_font,
    check_script_file,
)


def test_check_base_video_missing_raises(tmp_path):
    missing = tmp_path / "nope.mp4"
    with pytest.raises(FileNotFoundError, match="Base video missing"):
        check_base_video(missing)


def test_check_base_video_exists_ok(tmp_path):
    p = tmp_path / "base.mp4"
    p.write_bytes(b"fake")
    check_base_video(p)  # should not raise


def test_check_elevenlabs_key_missing_raises(monkeypatch):
    monkeypatch.delenv("ELEVENLABS_API_KEY", raising=False)
    with pytest.raises(EnvironmentError, match="ELEVENLABS_API_KEY missing"):
        check_elevenlabs_key()


def test_check_elevenlabs_key_present_ok(monkeypatch):
    monkeypatch.setenv("ELEVENLABS_API_KEY", "abc")
    check_elevenlabs_key()


def test_check_ffmpeg_present_ok():
    check_ffmpeg()  # ffmpeg should be on PATH on this machine


def test_check_font_missing_raises(tmp_path):
    with pytest.raises(FileNotFoundError, match="Font missing"):
        check_font(tmp_path / "missing.ttf")


def test_script_file_empty_raises(tmp_path):
    p = tmp_path / "s.txt"
    p.write_text("")
    with pytest.raises(ValueError, match="Script file .* empty"):
        check_script_file(p)
