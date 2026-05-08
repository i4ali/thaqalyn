"""ElevenLabs TTS with word-level alignment.

Uses the with-timestamps endpoint so we get character-level timing in one call,
then collapse to word-level. No retries, no fallbacks.
"""
from __future__ import annotations
import base64
import json
import os
from pathlib import Path
from typing import Any
import requests


# "George" — British, middle-aged, mature, narrative storyteller.
# Picked over Adam for tafsir narration: warmer and more contemplative,
# matches the storytelling cadence of Quranic exegesis.
DEFAULT_VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"
ELEVEN_URL = "https://api.elevenlabs.io/v1/text-to-speech/{voice_id}/with-timestamps"


def synthesize(text: str, audio_out: Path, timings_out: Path,
               voice_id: str = DEFAULT_VOICE_ID) -> None:
    api_key = os.environ.get("ELEVENLABS_API_KEY")
    if not api_key:
        raise EnvironmentError("ELEVENLABS_API_KEY missing in .env.")

    payload = {
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75},
    }
    headers = {"xi-api-key": api_key, "Content-Type": "application/json"}
    resp = requests.post(ELEVEN_URL.format(voice_id=voice_id),
                         headers=headers, json=payload, timeout=60)
    if resp.status_code != 200:
        raise RuntimeError(f"ElevenLabs TTS failed: {resp.status_code} {resp.text[:300]}")

    data = resp.json()
    audio = base64.b64decode(data["audio_base64"])
    timings = parse_alignment(data)

    audio_out = Path(audio_out)
    audio_out.parent.mkdir(parents=True, exist_ok=True)
    audio_out.write_bytes(audio)

    timings_out = Path(timings_out)
    timings_out.parent.mkdir(parents=True, exist_ok=True)
    timings_out.write_text(json.dumps(timings, indent=2))


def parse_alignment(raw: dict[str, Any]) -> list[dict]:
    """Collapse character-level alignment into word-level."""
    align = raw.get("alignment") or raw.get("normalized_alignment")
    if not align:
        raise RuntimeError("ElevenLabs response missing alignment data.")
    chars = align["characters"]
    starts = align["character_start_times_seconds"]
    ends = align["character_end_times_seconds"]

    words: list[dict] = []
    cur_chars: list[str] = []
    cur_start = None
    cur_end = None

    for ch, s, e in zip(chars, starts, ends):
        if ch.isspace():
            if cur_chars:
                words.append({"word": "".join(cur_chars), "start": cur_start, "end": cur_end})
                cur_chars = []
                cur_start = None
        else:
            if cur_start is None:
                cur_start = s
            cur_end = e
            cur_chars.append(ch)
    if cur_chars:
        words.append({"word": "".join(cur_chars), "start": cur_start, "end": cur_end})
    return words
