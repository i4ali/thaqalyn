# scripts/passage_pipeline/rukus.py
"""Passage (ruku) index derived from quran_data.json.

`ruku` in quran_data.json is a global running number starting at 1 in
al-Fatihah. Passages are numbered 1-based within their surah.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_ROOT / "Thaqalayn" / "Thaqalayn" / "Data"
QURAN_DATA = DATA_DIR / "quran_data.json"
WORK_DIR = PROJECT_ROOT / "passages_work"


@dataclass(frozen=True)
class PassageRef:
    surah: int
    index: int
    start: int
    end: int

    @property
    def id(self) -> str:
        return f"{self.surah}:{self.index}"

    @property
    def verse_count(self) -> int:
        return self.end - self.start + 1

    @property
    def work_dir(self) -> Path:
        return WORK_DIR / str(self.surah) / f"{self.index:02d}"

    def verses(self) -> range:
        return range(self.start, self.end + 1)


@lru_cache(maxsize=1)
def load_quran() -> dict:
    return json.loads(QURAN_DATA.read_text(encoding="utf-8"))


def surah_info(surah: int) -> dict:
    for s in load_quran()["surahs"]:
        if s["number"] == surah:
            return s
    raise KeyError(f"surah {surah} not found")


def verse_record(surah: int, verse: int) -> dict:
    return load_quran()["verses"][str(surah)][str(verse)]


@lru_cache(maxsize=None)
def passages_for_surah(surah: int) -> tuple[PassageRef, ...]:
    verses = load_quran()["verses"][str(surah)]
    groups: dict[int, list[int]] = {}
    for key, rec in verses.items():
        groups.setdefault(int(rec["ruku"]), []).append(int(key))
    return tuple(
        PassageRef(surah, i, min(vs), max(vs))
        for i, (_, vs) in enumerate(sorted(groups.items()), start=1)
    )


def passage(surah: int, index: int) -> PassageRef:
    refs = passages_for_surah(surah)
    if not 1 <= index <= len(refs):
        raise ValueError(f"surah {surah} has {len(refs)} passages, got index {index}")
    return refs[index - 1]


def passage_for_verse(surah: int, verse: int) -> PassageRef:
    for ref in passages_for_surah(surah):
        if ref.start <= verse <= ref.end:
            return ref
    raise ValueError(f"no passage holds {surah}:{verse}")


def all_passages() -> list[PassageRef]:
    return [p for s in range(1, 115) for p in passages_for_surah(s)]


def parse_passage_ref(ref: str) -> PassageRef:
    m = re.fullmatch(r"\s*(\d{1,3})\s*:\s*(\d{1,3})\s*", ref)
    if not m:
        raise ValueError(f"bad passage ref {ref!r}, expected surah:index like 2:4")
    surah, index = int(m.group(1)), int(m.group(2))
    if not 1 <= surah <= 114:
        raise ValueError(f"surah must be 1 to 114, got {surah}")
    return passage(surah, index)
