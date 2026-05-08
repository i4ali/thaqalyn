"""Pre-flight checks. Raise clear, actionable errors. No fallbacks."""
from __future__ import annotations
import os
import shutil
from pathlib import Path


def check_base_video(path: Path) -> None:
    if not Path(path).exists():
        raise FileNotFoundError(
            f"Base video missing. Run shia-event-video-creator with the tafsir-explainer "
            f"prompt set first. Expected: {path}"
        )


def check_elevenlabs_key() -> None:
    if not os.environ.get("ELEVENLABS_API_KEY"):
        raise EnvironmentError("ELEVENLABS_API_KEY missing in .env.")


def check_ffmpeg() -> None:
    if shutil.which("ffmpeg") is None:
        raise EnvironmentError("ffmpeg not found. Install with: brew install ffmpeg")


def check_font(path: Path) -> None:
    if not Path(path).exists():
        raise FileNotFoundError(f"Font missing: {path}")


def check_script_file(path: Path) -> None:
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(f"Script file not found: {path}")
    if not p.read_text().strip():
        raise ValueError(f"Script file is empty: {path}")
