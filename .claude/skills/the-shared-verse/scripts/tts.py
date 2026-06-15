"""ElevenLabs TTS for The Shared Verse. No fallbacks — fail fast.

The voiceover reads ONLY the English translation and the commentary (and the
spoken sūrah:āyah reference). It must NEVER recite the Arabic Quran — see SKILL.md
"Audio rule". The Arabic is shown on screen, silently.

Two entry points:
  synthesize(text, mp3)         -> plain audio
  synthesize_timed(text, mp3)   -> audio + word-level timings (for karaoke
                                   highlighting of the translation as it's read)
"""
from __future__ import annotations
import base64
import os
from pathlib import Path
import requests

# "George" — British, mature, contemplative narrator. Matches the reverent,
# storytelling cadence of The Shared Verse; the same voice family the Thaqalayn
# tafsir-video skill uses for Quranic exegesis.
DEFAULT_VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"
URL = "https://api.elevenlabs.io/v1/text-to-speech/{vid}"
URL_TIMED = "https://api.elevenlabs.io/v1/text-to-speech/{vid}/with-timestamps"

_VOICE_SETTINGS = {"stability": 0.5, "similarity_boost": 0.75, "style": 0.0, "use_speaker_boost": True}


def _check(text: str) -> str:
    if not os.environ.get("ELEVENLABS_API_KEY"):
        raise EnvironmentError("ELEVENLABS_API_KEY missing in .env.")
    if not text or not text.strip():
        raise ValueError("Refusing to synthesize empty voiceover text.")
    return text.strip()


def synthesize(text: str, out_mp3: Path, voice_id: str = DEFAULT_VOICE_ID) -> Path:
    """Synthesize one text segment to an mp3 file. Returns the path."""
    text = _check(text)
    payload = {"text": text, "model_id": "eleven_multilingual_v2", "voice_settings": _VOICE_SETTINGS}
    headers = {"xi-api-key": os.environ["ELEVENLABS_API_KEY"],
               "Content-Type": "application/json", "Accept": "audio/mpeg"}
    resp = requests.post(URL.format(vid=voice_id), headers=headers, json=payload, timeout=120)
    if resp.status_code != 200:
        raise RuntimeError(f"ElevenLabs TTS failed: {resp.status_code} {resp.text[:300]}")
    out_mp3 = Path(out_mp3)
    out_mp3.parent.mkdir(parents=True, exist_ok=True)
    out_mp3.write_bytes(resp.content)
    if out_mp3.stat().st_size == 0:
        raise RuntimeError(f"ElevenLabs returned empty audio for: {text[:60]!r}")
    return out_mp3


def synthesize_timed(text: str, out_mp3: Path, voice_id: str = DEFAULT_VOICE_ID) -> list[dict]:
    """Synthesize + return word-level timings: [{"word","start","end"(sec)}, ...].

    Uses the with-timestamps endpoint (character-level alignment) collapsed to
    words — same approach as the tafsir-video skill.
    """
    text = _check(text)
    payload = {"text": text, "model_id": "eleven_multilingual_v2", "voice_settings": _VOICE_SETTINGS}
    headers = {"xi-api-key": os.environ["ELEVENLABS_API_KEY"], "Content-Type": "application/json"}
    resp = requests.post(URL_TIMED.format(vid=voice_id), headers=headers, json=payload, timeout=120)
    if resp.status_code != 200:
        raise RuntimeError(f"ElevenLabs TTS (timed) failed: {resp.status_code} {resp.text[:300]}")
    data = resp.json()
    out_mp3 = Path(out_mp3)
    out_mp3.parent.mkdir(parents=True, exist_ok=True)
    out_mp3.write_bytes(base64.b64decode(data["audio_base64"]))
    if out_mp3.stat().st_size == 0:
        raise RuntimeError(f"ElevenLabs returned empty audio for: {text[:60]!r}")
    return _words_from_alignment(data)


def _words_from_alignment(raw: dict) -> list[dict]:
    align = raw.get("alignment") or raw.get("normalized_alignment")
    if not align:
        raise RuntimeError("ElevenLabs response missing alignment data.")
    chars = align["characters"]
    starts = align["character_start_times_seconds"]
    ends = align["character_end_times_seconds"]
    words: list[dict] = []
    cur: list[str] = []
    cs = ce = None
    for ch, s, e in zip(chars, starts, ends):
        if ch.isspace():
            if cur:
                words.append({"word": "".join(cur), "start": cs, "end": ce})
                cur, cs = [], None
        else:
            if cs is None:
                cs = s
            ce = e
            cur.append(ch)
    if cur:
        words.append({"word": "".join(cur), "start": cs, "end": ce})
    return words
