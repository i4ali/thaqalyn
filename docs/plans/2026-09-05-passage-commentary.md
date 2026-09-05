# Passage Commentary Pipeline Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the content pipeline that produces one sourced, validated, audited commentary per ruku, and run it on the al-Baqarah pilot (passages 2:1 to 2:5, verses 1 to 46).

**Architecture:** A Python package `scripts/passage_pipeline/` with a thin CLI `scripts/passages.py` owns all state under `passages_work/<surah>/<index>/`. A deterministic `gather` fetches and caches source blocks; the `passage-writer` agent writes a draft citing only those blocks; a deterministic validator enforces the schema and every mechanical rule; the `passage-auditor` agent rules on every claim against the same blocks; `assemble` merges passed drafts into `Thaqalayn/Thaqalayn/Data/passages_N.json`. Agents never write into `Data/`.

**Tech Stack:** Python 3.13 in `.venv`, pytest 9, curl via subprocess (lifted from `scripts/citation_audit.py`), Claude Code agents (`.claude/agents/*.md`) on the `opus` model (the orchestrating session runs on Fable; the writer and auditor do not), PostToolUse hook for blocking validation.

**Design:** `docs/plans/2026-09-05-passage-commentary-design.md`. Read it first. The app reader is a separate plan, written after the pilot produces real data.

**Out of scope here:** Urdu and Arabic translation (after the English pilot is frozen), the iOS reader, deleting `tafsir_N.json`.

---

## Conventions for every task

- Run Python as `.venv/bin/python` from the repo root. Tests: `.venv/bin/python -m pytest tests/passage_pipeline -q`.
- Tests import the package as `from scripts.passage_pipeline import rukus` (there is a `scripts/__init__.py` and a `tests/__init__.py` already).
- Network tests are marked `@pytest.mark.network` and skipped unless `-m network` is passed. Everything else runs offline with fakes.
- **Commits:** the house rule is never to commit without asking. At each "Commit" step, present the files and message with AskUserQuestion, and commit only on approval. No co-author trailer.
- English text rules from `CLAUDE.md`: plain spelling, no transliteration diacritics, no em dash.
- Work-dir layout, fixed for the whole plan:

```
passages_work/
  2/
    04/
      verses.json      gather output: surah info, passage ref, verses
      sources.json     gather output: citable blocks s1..sN with full text
      draft.json       writer output
      audit.1.json     auditor output, one file per attempt
      audit.2.json
    titles.json        per-surah title review file
```

---

### Task 1: Package skeleton and ruku index

**Files:**
- Create: `scripts/passage_pipeline/__init__.py` (empty)
- Create: `scripts/passage_pipeline/rukus.py`
- Create: `tests/passage_pipeline/__init__.py` (empty)
- Create: `tests/passage_pipeline/test_rukus.py`
- Modify: `.gitignore` (append `passages_work/`)

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_rukus.py
import pytest
from scripts.passage_pipeline import rukus


def test_al_baqarah_has_40_passages():
    assert len(rukus.passages_for_surah(2)) == 40


def test_adam_passage_is_index_4():
    p = rukus.passage(2, 4)
    assert (p.start, p.end) == (30, 39)
    assert p.id == "2:4"


def test_whole_quran_has_556_passages():
    assert len(rukus.all_passages()) == 556


def test_fatiha_is_one_passage():
    (p,) = rukus.passages_for_surah(1)
    assert (p.start, p.end) == (1, 7)


def test_passage_for_verse_finds_container():
    assert rukus.passage_for_verse(2, 141).index == 16
    assert rukus.passage_for_verse(2, 253).index == 33


def test_parse_passage_ref():
    p = rukus.parse_passage_ref("2:4")
    assert (p.surah, p.index, p.start, p.end) == (2, 4, 30, 39)


def test_parse_passage_ref_rejects_out_of_range():
    with pytest.raises(ValueError):
        rukus.parse_passage_ref("2:41")


def test_work_dir_is_zero_padded():
    assert rukus.passage(2, 4).work_dir.name == "04"
    assert rukus.passage(2, 4).work_dir.parent.name == "2"


def test_surah_info():
    info = rukus.surah_info(2)
    assert info["englishName"] == "Al-Baqara"
    assert info["versesCount"] == 286
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_rukus.py -q`
Expected: FAIL with `ModuleNotFoundError: No module named 'scripts.passage_pipeline'`

**Step 3: Write minimal implementation**

```python
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
        groups.setdefault(rec["ruku"], []).append(int(key))
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
```

Append to `.gitignore`:

```
passages_work/
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_rukus.py -q`
Expected: `9 passed`

**Step 5: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/__init__.py scripts/passage_pipeline/rukus.py tests/passage_pipeline/__init__.py tests/passage_pipeline/test_rukus.py .gitignore
git commit -m "passages: ruku index for the passage pipeline"
```

---

### Task 2: Fetch helpers lifted from citation_audit.py

**Files:**
- Create: `scripts/passage_pipeline/fetch.py`
- Create: `tests/passage_pipeline/test_fetch.py`
- Create: `tests/passage_pipeline/fixtures/altafsir_page.html`
- Reference: `scripts/citation_audit.py:350-425` (curl_get, decode_body, html_to_text), `:470-547` (ALTAFSIR_TAFSIRS, cmd_tafsir), `:551-649` (hadith search)

**Step 1: Write the fixture**

`tests/passage_pipeline/fixtures/altafsir_page.html`:

```html
<html><head><title>x</title></head><body>
<div id=menu><a href="?Page=1">1</a></div>
<div id=SearchResults>
<select><option>الآية 30</option><option>الآية 31</option></select>
<p>{ وَإِذْ قَالَ رَبُّكَ لِلْمَلَٰئِكَةِ إِنِّي جَاعِلٌ فِي ٱلأَرْضِ خَلِيفَةً }</p>
<p>بيان الآيات تنبىء عن غرض إنزال الإِنسان إلى الدنيا وحقيقة جعل الخلافة في الأرض، وهذا الكلام من الملائكة في مقام تعرف ما جهلوه واستيضاح ما أشكل عليهم من أمر هذا الخليفة، وليس من الاعتراض والخصومة في شيء.</p>
<a href="Tafasir.asp?tTafsirNo=56&tSoraNo=2&tAyahNo=30&Page=2">2</a>
</div>
</body></html>
```

**Step 2: Write the failing test**

```python
# tests/passage_pipeline/test_fetch.py
from pathlib import Path

import pytest

from scripts.passage_pipeline import fetch

FIXTURE = Path(__file__).parent / "fixtures" / "altafsir_page.html"


def test_altafsir_url_matches_site_format():
    url = fetch.altafsir_url(56, 1, 2, 30, page=1)
    assert url == (
        "https://www.altafsir.com/Tafasir.asp?tMadhNo=0&tTafsirNo=56&tSoraNo=2"
        "&tAyahNo=30&tDisplay=yes&UserProfile=0&LanguageId=1&Page=1"
    )


def test_extract_results_block_returns_segment_and_more_flag():
    src = FIXTURE.read_text(encoding="utf-8")
    seg, has_more = fetch.extract_results_block(src, page=1)
    assert seg.startswith("<div id=SearchResults")
    assert has_more is True


def test_extract_results_block_missing():
    assert fetch.extract_results_block("<html><body>nothing</body></html>", page=1) == (None, False)


def test_clean_block_text_drops_menu_chrome_and_keeps_commentary():
    src = FIXTURE.read_text(encoding="utf-8")
    seg, _ = fetch.extract_results_block(src, page=1)
    text = fetch.clean_block_text(seg)
    assert "الآية 30" not in text
    assert "وليس من الاعتراض والخصومة في شيء" in text
    assert text.startswith("{")


def test_fetch_altafsir_walks_pages_with_injected_getter():
    page1 = FIXTURE.read_text(encoding="utf-8")
    page2 = page1.replace('&Page=2">2</a>', "").replace("Page=2", "Page=3")
    page2 = page2.replace("وليس من الاعتراض", "تتمة الكلام وليس من الاعتراض")
    calls = []

    def fake_get(url, timeout=45):
        calls.append(url)
        body = page1 if "Page=1" in url else page2
        return 200, "text/html; charset=windows-1256", body.encode("cp1256", errors="replace")

    block = fetch.fetch_altafsir("mizan", 2, 30, get=fake_get)
    assert block is not None
    assert block.pages == 2
    assert len(calls) == 2
    assert "تتمة الكلام" in block.text
    assert block.url.endswith("Page=1")


def test_fetch_altafsir_returns_none_for_empty_block():
    def fake_get(url, timeout=45):
        return 200, "text/html", b"<html><body><div id=SearchResults>{ x }</div></body></html>"

    assert fetch.fetch_altafsir("mizan", 2, 30, get=fake_get) is None


def test_hadith_query_from_arabic_strips_tashkeel_and_takes_four_words():
    ar = "وَإِذْ قُلْنَا لِلْمَلَٰٓئِكَةِ ٱسْجُدُوا۟ لِءَادَمَ فَسَجَدُوٓا۟"
    assert fetch.hadith_query_from_arabic(ar) == "واذ قلنا للملائكة اسجدوا"


def test_search_hadith_parses_typesense_response():
    payload = {"results": [{"found": 1, "hits": [{"document": {
        "bookNameOriginal": "Al-Kafi", "authorName": "al-Kulayni", "volumeNumber": 2,
        "chapterNumber": 5, "number": 1028, "bookId": "al-kafi", "textEn": "Three signs",
        "textArDisplay": "ثلاث علامات", "gradesCanonical": ["Sahih"],
    }}]}]}

    class Proc:
        returncode = 0
        stdout = __import__("json").dumps(payload)
        stderr = ""

    hits = fetch.search_hadith("three signs", run=lambda *a, **k: Proc())
    assert hits == [{
        "book": "Al-Kafi", "author": "al-Kulayni", "volume": 2, "chapter": 5, "number": 1028,
        "url": "https://thaqalayn.com/book/al-kafi", "text_en": "Three signs",
        "text_ar": "ثلاث علامات", "grades": ["Sahih"],
    }]


@pytest.mark.network
def test_live_altafsir_mizan_2_30():
    block = fetch.fetch_altafsir("mizan", 2, 30)
    assert block and "الخلافة" in block.text
```

Add to `tests/passage_pipeline/conftest.py`:

```python
import pytest


def pytest_configure(config):
    config.addinivalue_line("markers", "network: hits real sites; run with -m network")


def pytest_collection_modifyitems(config, items):
    if config.getoption("-m"):
        return
    skip = pytest.mark.skip(reason="network test; pass -m network to run")
    for item in items:
        if "network" in item.keywords:
            item.add_marker(skip)
```

**Step 3: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_fetch.py -q`
Expected: FAIL with `ImportError: cannot import name 'fetch'`

**Step 4: Write minimal implementation**

```python
# scripts/passage_pipeline/fetch.py
"""HTTP helpers: altafsir.com commentary blocks and the thaqalayn.com hadith search.

curl_get, decode_body and html_to_text are lifted verbatim from
scripts/citation_audit.py (lines 350 to 425). The altafsir logic is cmd_tafsir
rewritten to return data instead of printing it.
"""
from __future__ import annotations

import html as html_lib
import json
import os
import re
import subprocess
import tempfile
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)

# ---- copy curl_get, decode_body, html_to_text verbatim from citation_audit.py ----
# curl_get(url, timeout=45) -> (status, content_type, body_bytes); on curl failure raise RuntimeError
# (replace the `die(...)` call with `raise RuntimeError(...)`).
# decode_body(body, content_type, forced=None) -> str, falling back to cp1256.
# html_to_text(src) -> str.
# --------------------------------------------------------------------------------

Getter = Callable[..., tuple[int, str, bytes]]

# altafsir.com tafsir ids (tTafsirNo). LanguageId 1 = Arabic, 2 = English.
ALTAFSIR_TAFSIRS: dict[str, tuple[int, int, str]] = {
    "mizan": (56, 1, "al-Mizan fi Tafsir al-Quran"),
    "majma": (3, 1, "Majma al-Bayan"),
    "tibyan": (39, 1, "al-Tibyan fi Tafsir al-Quran"),
    "qummi": (38, 1, "Tafsir al-Qummi"),
    "burhan": (110, 1, "al-Burhan fi Tafsir al-Quran"),
    "safi": (41, 1, "Tafsir al-Safi"),
    "furat": (45, 1, "Tafsir Furat al-Kufi"),
    "tabari": (1, 1, "Jami al-Bayan"),
    "ibn-kathir": (7, 1, "Tafsir al-Quran al-Azim"),
    "qurtubi": (5, 1, "al-Jami li-Ahkam al-Quran"),
    "razi": (4, 1, "Mafatih al-Ghayb"),
    "durr": (26, 1, "al-Durr al-Manthur"),
}

MAX_PAGES = 12


@dataclass
class FetchedBlock:
    key: str
    surah: int
    verse: int
    url: str
    text: str
    pages: int


def altafsir_url(tafsir_id: int, lang: int, surah: int, verse: int, page: int = 1) -> str:
    return (
        "https://www.altafsir.com/Tafasir.asp?tMadhNo=0"
        f"&tTafsirNo={tafsir_id}&tSoraNo={surah}&tAyahNo={verse}&tDisplay=yes&UserProfile=0"
        f"&LanguageId={lang}&Page={page}"
    )


def extract_results_block(src: str, page: int) -> tuple[str | None, bool]:
    start = src.find("<div id=SearchResults")
    if start < 0:
        start = src.lower().find('id="searchresults"')
    if start < 0:
        return None, False
    seg = src[start:]
    end = seg.find("</body>")
    seg = seg[:end] if end > 0 else seg
    has_more = bool(re.search(rf"Page={page + 1}\b", seg))
    return seg, has_more


def clean_block_text(segment_html: str) -> str:
    text = html_to_text(segment_html)
    lines = text.split("\n")
    for i, ln in enumerate(lines):
        if "{" in ln or len(ln) > 120:
            lines = lines[i:]
            break
    return "\n".join(lines).strip()


def fetch_altafsir(key: str, surah: int, verse: int, *, get: Getter = None) -> FetchedBlock | None:
    get = get or curl_get
    tafsir_id, lang, _ = ALTAFSIR_TAFSIRS[key]
    parts: list[str] = []
    first_url = altafsir_url(tafsir_id, lang, surah, verse, 1)
    page = 1
    while page <= MAX_PAGES:
        url = altafsir_url(tafsir_id, lang, surah, verse, page)
        code, ctype, body = get(url, timeout=45)
        if code != 200:
            break
        src = decode_body(body, ctype, "cp1256" if lang == 1 else None)
        seg, has_more = extract_results_block(src, page)
        if seg is None:
            break
        parts.append(clean_block_text(seg))
        if not has_more:
            break
        page += 1
    text = "\n".join(p for p in parts if p).strip()
    if len(text) < 80:
        return None
    return FetchedBlock(key, surah, verse, first_url, text, len(parts))


# ---- thaqalayn.com hadith corpus -------------------------------------------------

THAQALAYN_SEARCH_URL = "https://api.thaqalayn.com:8108/multi_search"
THAQALAYN_SEARCH_KEY = os.environ.get("THAQALAYN_TYPESENSE_KEY", "AmswDdjQNKm0xVNBLhUpkgjLj4JnNNbh")
TASHKEEL_RE = re.compile(r"[ؐ-ًؚ-ٰٟۖ-ۭـ]")


def strip_tashkeel(text: str) -> str:
    text = unicodedata.normalize("NFKC", text)
    text = TASHKEEL_RE.sub("", text)
    return text.replace("ٱ", "ا").replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")


def hadith_query_from_arabic(arabic: str, words: int = 4) -> str:
    return " ".join(strip_tashkeel(arabic).split()[:words])


def search_hadith(query: str, *, book: str | None = None, limit: int = 10,
                  run=subprocess.run) -> list[dict]:
    body = {"searches": [{
        "collection": "hadiths",
        "q": query,
        "query_by": "textEn,textArSearch,bookName,chapterName",
        "per_page": max(1, min(limit, 25)),
        "num_typos": 0,
        "highlight_full_fields": "none",
        "exclude_fields": "embedding,textArSearch,bookNameArSearch,chapterNameArSearch",
    }]}
    if book:
        body["searches"][0]["filter_by"] = f"bookName:={json.dumps(book)}"
    proc = run(
        ["curl", "-sS", "--max-time", "30", "-X", "POST",
         "-H", f"X-TYPESENSE-API-KEY: {THAQALAYN_SEARCH_KEY}",
         "-H", "Content-Type: application/json",
         "-d", json.dumps(body, ensure_ascii=False), THAQALAYN_SEARCH_URL],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(f"thaqalayn.com search unavailable: {proc.stderr.strip() or 'curl error'}")
    data = json.loads(proc.stdout)
    result = (data.get("results") or [{}])[0]
    if "error" in result:
        raise RuntimeError(f"thaqalayn.com search error: {result['error']}")
    hits = []
    for hit in result.get("hits", []):
        d = hit.get("document", {})
        hits.append({
            "book": d.get("bookNameOriginal") or d.get("bookName") or "?",
            "author": d.get("authorName") or "",
            "volume": d.get("volumeNumber"),
            "chapter": d.get("chapterNumber"),
            "number": d.get("number"),
            "url": f"https://thaqalayn.com/book/{d.get('bookId', '')}",
            "text_en": d.get("textEn") or "",
            "text_ar": d.get("textArDisplay") or d.get("textAr") or "",
            "grades": d.get("gradesCanonical") or d.get("grades") or [],
        })
    return hits
```

Copy the three helper functions in where the comment block says, changing `die(...)` to `raise RuntimeError(...)`.

**Step 5: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_fetch.py -q`
Expected: `8 passed, 1 skipped`

Then once, live: `.venv/bin/python -m pytest tests/passage_pipeline/test_fetch.py -q -m network`
Expected: `1 passed`

**Step 6: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/fetch.py tests/passage_pipeline/test_fetch.py tests/passage_pipeline/fixtures/altafsir_page.html tests/passage_pipeline/conftest.py
git commit -m "passages: altafsir and hadith fetch helpers"
```

---

### Task 3: Source registry and tiers

**Files:**
- Create: `scripts/passage_pipeline/sources.py`
- Create: `tests/passage_pipeline/test_sources.py`

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_sources.py
from scripts.passage_pipeline import sources


def test_every_altafsir_key_has_a_work_entry():
    from scripts.passage_pipeline.fetch import ALTAFSIR_TAFSIRS
    for key in ALTAFSIR_TAFSIRS:
        assert key in sources.WORKS, key


def test_tiers_follow_copyright_status():
    assert sources.WORKS["burhan"]["tier"] == "A"
    assert sources.WORKS["majma"]["tier"] == "A"
    assert sources.WORKS["mizan"]["tier"] == "B"
    assert sources.WORKS["thaqalayn"]["tier"] == "A"


def test_sunni_works_are_perspectives_only():
    for key in ("tabari", "ibn-kathir", "qurtubi", "razi", "durr"):
        assert sources.WORKS[key]["tradition"] == "sunni"
        assert sources.WORKS[key]["role"] == "perspectives"


def test_narration_bearing_keys():
    assert sources.NARRATION_KEYS == {"qummi", "burhan", "safi", "furat", "majma", "thaqalayn"}


def test_gather_order_is_stable():
    assert sources.GATHER_KEYS[:3] == ["mizan", "majma", "tibyan"]
    assert sources.GATHER_KEYS[-1] == "durr"


def test_locus_wording():
    assert sources.locus_for("Al-Baqara", [30, 31, 32, 33]) == "on Al-Baqara 30 to 33"
    assert sources.locus_for("Al-Baqara", [34]) == "on Al-Baqara 34"
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_sources.py -q`
Expected: FAIL with `ImportError`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/sources.py
"""Registry of citable works: who wrote them, which tradition, which tier the
source sheet uses, and which role they play in a passage."""
from __future__ import annotations

# tier A: public domain, full excerpt with chain. B: in copyright, original
# language, one sentence. C: copyrighted translation, locus only.
WORKS: dict[str, dict] = {
    "mizan": {"work": "al-Mizan fi Tafsir al-Quran", "author": "Allamah Muhammad Husayn Tabatabai",
              "tradition": "shia", "tier": "B", "role": "essay", "kind": "tafsir"},
    "majma": {"work": "Majma al-Bayan", "author": "Shaykh al-Tabrisi",
              "tradition": "shia", "tier": "A", "role": "essay", "kind": "tafsir"},
    "tibyan": {"work": "al-Tibyan fi Tafsir al-Quran", "author": "Shaykh al-Tusi",
               "tradition": "shia", "tier": "A", "role": "essay", "kind": "tafsir"},
    "qummi": {"work": "Tafsir al-Qummi", "author": "Ali ibn Ibrahim al-Qummi",
              "tradition": "shia", "tier": "A", "role": "narrations", "kind": "hadith"},
    "burhan": {"work": "al-Burhan fi Tafsir al-Quran", "author": "Sayyid Hashim al-Bahrani",
               "tradition": "shia", "tier": "A", "role": "narrations", "kind": "hadith"},
    "safi": {"work": "Tafsir al-Safi", "author": "Fayd Kashani",
             "tradition": "shia", "tier": "A", "role": "narrations", "kind": "hadith"},
    "furat": {"work": "Tafsir Furat al-Kufi", "author": "Furat ibn Ibrahim al-Kufi",
              "tradition": "shia", "tier": "A", "role": "narrations", "kind": "hadith"},
    "thaqalayn": {"work": "", "author": "", "tradition": "shia", "tier": "A",
                  "role": "narrations", "kind": "hadith"},
    "tabari": {"work": "Jami al-Bayan", "author": "al-Tabari",
               "tradition": "sunni", "tier": "A", "role": "perspectives", "kind": "tafsir"},
    "ibn-kathir": {"work": "Tafsir al-Quran al-Azim", "author": "Ibn Kathir",
                   "tradition": "sunni", "tier": "A", "role": "perspectives", "kind": "tafsir"},
    "qurtubi": {"work": "al-Jami li-Ahkam al-Quran", "author": "al-Qurtubi",
                "tradition": "sunni", "tier": "A", "role": "perspectives", "kind": "tafsir"},
    "razi": {"work": "Mafatih al-Ghayb", "author": "Fakhr al-Din al-Razi",
             "tradition": "sunni", "tier": "A", "role": "perspectives", "kind": "tafsir"},
    "durr": {"work": "al-Durr al-Manthur", "author": "Jalal al-Din al-Suyuti",
             "tradition": "sunni", "tier": "A", "role": "perspectives", "kind": "tafsir"},
}

# Order in which gather fetches altafsir works. Hadith corpus search runs after.
GATHER_KEYS = ["mizan", "majma", "tibyan", "qummi", "burhan", "safi", "furat",
               "tabari", "ibn-kathir", "qurtubi", "razi", "durr"]

NARRATION_KEYS = {"qummi", "burhan", "safi", "furat", "majma", "thaqalayn"}


def locus_for(surah_name: str, verses: list[int]) -> str:
    vs = sorted(verses)
    if len(vs) == 1:
        return f"on {surah_name} {vs[0]}"
    return f"on {surah_name} {vs[0]} to {vs[-1]}"
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_sources.py -q`
Expected: `6 passed`

**Step 5: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/sources.py tests/passage_pipeline/test_sources.py
git commit -m "passages: source registry with tiers and roles"
```

---

### Task 4: Gather command

**Files:**
- Create: `scripts/passage_pipeline/gather.py`
- Create: `scripts/passage_pipeline/cli.py`
- Create: `scripts/passages.py`
- Create: `tests/passage_pipeline/test_gather.py`

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_gather.py
import json

from scripts.passage_pipeline import gather, rukus
from scripts.passage_pipeline.fetch import FetchedBlock

MIZAN = "{ الآيات } بيان: هذا الكلام من الملائكة في مقام تعرف ما جهلوه وليس من الاعتراض في شيء. " * 3
BURHAN_34 = "385/ علي بن إبراهيم عن أبيه عن ابن أبي عمير عن جميل عن أبي عبد الله عليه السلام قال: أخرج ما كان في قلب إبليس من الحسد. " * 2


def fake_fetch(key, surah, verse, **kw):
    if key == "mizan" and 30 <= verse <= 33:
        return FetchedBlock(key, surah, verse, f"https://x/{key}/{verse}", MIZAN, 1)
    if key == "burhan" and verse == 34:
        return FetchedBlock(key, surah, verse, f"https://x/{key}/{verse}", BURHAN_34, 1)
    return None


def fake_hadith(query, **kw):
    if query.startswith("واذ قلنا"):
        return [{"book": "Al-Kafi", "author": "al-Kulayni", "volume": 2, "chapter": 5, "number": 1028,
                 "url": "https://thaqalayn.com/book/al-kafi", "text_en": "Three signs of a hypocrite",
                 "text_ar": "ثلاث علامات للمنافق", "grades": ["Sahih"]}]
    return []


def test_gather_writes_verses_and_deduplicated_sources(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    result = gather.gather(ref, fetch=fake_fetch, hadith=fake_hadith)

    verses = json.loads((ref.work_dir / "verses.json").read_text())
    assert verses["passage"]["id"] == "2:4"
    assert [v["verse"] for v in verses["verses"]] == list(range(30, 40))
    assert verses["verses"][4]["translation"].startswith("And when We said to the angels")
    assert verses["surah"]["englishName"] == "Al-Baqara"

    srcs = json.loads((ref.work_dir / "sources.json").read_text())["sources"]
    assert [s["id"] for s in srcs] == ["s1", "s2", "s3"]
    mizan = srcs[0]
    assert mizan["key"] == "mizan" and mizan["tier"] == "B" and mizan["role"] == "essay"
    assert mizan["verses"] == [30, 31, 32, 33]
    assert mizan["locus"] == "on Al-Baqara 30 to 33"
    assert mizan["text"] == MIZAN.strip()
    burhan = srcs[1]
    assert burhan["kind"] == "hadith" and burhan["locus"] == "on Al-Baqara 34"
    corpus = srcs[2]
    assert corpus["key"] == "thaqalayn" and corpus["work"] == "Al-Kafi"
    assert corpus["locus"] == "vol. 2, hadith 1028, cited at Al-Baqara 34"
    assert "ثلاث علامات" in corpus["text"] and "Three signs" in corpus["text"]
    assert result["unavailable"] == {
        "mizan": [34, 35, 36, 37, 38, 39], "majma": list(range(30, 40)), "tibyan": list(range(30, 40)),
        "qummi": list(range(30, 40)), "burhan": [30, 31, 32, 33, 35, 36, 37, 38, 39],
        "safi": list(range(30, 40)), "furat": list(range(30, 40)), "tabari": list(range(30, 40)),
        "ibn-kathir": list(range(30, 40)), "qurtubi": list(range(30, 40)), "razi": list(range(30, 40)),
        "durr": list(range(30, 40)),
    }


def test_gather_is_idempotent_on_ids(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    gather.gather(ref, fetch=fake_fetch, hadith=fake_hadith)
    first = (ref.work_dir / "sources.json").read_text()
    gather.gather(ref, fetch=fake_fetch, hadith=fake_hadith)
    second = json.loads((ref.work_dir / "sources.json").read_text())
    assert [s["id"] for s in json.loads(first)["sources"]] == [s["id"] for s in second["sources"]]
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_gather.py -q`
Expected: FAIL with `ImportError: cannot import name 'gather'`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/gather.py
"""Stage 1: fetch and cache every block the writer may cite for one passage."""
from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone

from . import fetch as fetch_mod
from . import rukus, sources
from .rukus import PassageRef


def _now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def build_verses(ref: PassageRef) -> dict:
    info = rukus.surah_info(ref.surah)
    return {
        "surah": {"number": ref.surah, "englishName": info["englishName"],
                  "englishNameTranslation": info["englishNameTranslation"],
                  "revelationType": info["revelationType"], "versesCount": info["versesCount"],
                  "passageCount": len(rukus.passages_for_surah(ref.surah))},
        "passage": {"id": ref.id, "index": ref.index, "range": [ref.start, ref.end]},
        "verses": [
            {"verse": v, "arabic": rec["arabicText"], "translation": rec["translation"],
             "translationUrdu": rec.get("translationUrdu", "")}
            for v in ref.verses() for rec in [rukus.verse_record(ref.surah, v)]
        ],
    }


def gather(ref: PassageRef, *, fetch=None, hadith=None) -> dict:
    fetch = fetch or fetch_mod.fetch_altafsir
    hadith = hadith or fetch_mod.search_hadith
    verses = build_verses(ref)
    name = verses["surah"]["englishName"]
    records: list[dict] = []
    by_hash: dict[tuple[str, str], dict] = {}
    unavailable: dict[str, list[int]] = {}

    for key in sources.GATHER_KEYS:
        meta = sources.WORKS[key]
        for v in ref.verses():
            block = fetch(key, ref.surah, v)
            if block is None:
                unavailable.setdefault(key, []).append(v)
                continue
            text = block.text.strip()
            h = (key, _sha(text))
            if h in by_hash:
                by_hash[h]["verses"].append(v)
                continue
            rec = {"id": None, "key": key, "kind": meta["kind"], "work": meta["work"],
                   "author": meta["author"], "tradition": meta["tradition"], "tier": meta["tier"],
                   "role": meta["role"], "verses": [v], "locus": None, "url": block.url,
                   "sha256": h[1], "fetched_at": _now(), "text": text}
            by_hash[h] = rec
            records.append(rec)

    for v in ref.verses():
        arabic = rukus.verse_record(ref.surah, v)["arabicText"]
        query = fetch_mod.hadith_query_from_arabic(arabic)
        try:
            hits = hadith(query, limit=10)
        except RuntimeError:
            unavailable.setdefault("thaqalayn", []).append(v)
            continue
        for hit in hits:
            text = f"{hit['text_ar']}\n{hit['text_en']}".strip()
            h = ("thaqalayn", _sha(text))
            if h in by_hash:
                by_hash[h]["verses"].append(v)
                continue
            locus = ", ".join(p for p in [
                f"vol. {hit['volume']}" if hit.get("volume") else "",
                f"hadith {hit['number']}" if hit.get("number") is not None else "",
            ] if p) + f", cited at {name} {v}"
            rec = {"id": None, "key": "thaqalayn", "kind": "hadith", "work": hit["book"],
                   "author": hit["author"], "tradition": "shia", "tier": "A", "role": "narrations",
                   "verses": [v], "locus": locus, "url": hit["url"], "sha256": h[1],
                   "fetched_at": _now(), "text": text, "grades": hit.get("grades", [])}
            by_hash[h] = rec
            records.append(rec)

    for i, rec in enumerate(records, start=1):
        rec["id"] = f"s{i}"
        rec["verses"] = sorted(set(rec["verses"]))
        if rec["locus"] is None:
            rec["locus"] = sources.locus_for(name, rec["verses"])

    ref.work_dir.mkdir(parents=True, exist_ok=True)
    (ref.work_dir / "verses.json").write_text(json.dumps(verses, ensure_ascii=False, indent=2), encoding="utf-8")
    payload = {"passage": ref.id, "gathered_at": _now(), "unavailable": unavailable, "sources": records}
    (ref.work_dir / "sources.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    return payload
```

```python
# scripts/passage_pipeline/cli.py
from __future__ import annotations

import argparse
import sys

from . import gather as gather_mod
from . import rukus


def cmd_gather(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    result = gather_mod.gather(ref)
    n = len(result["sources"])
    print(f"{ref.id} ({ref.start}-{ref.end}): {n} source blocks -> {ref.work_dir}")
    for key, vs in result["unavailable"].items():
        print(f"  unavailable {key}: {vs}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="passages.py", description="Passage commentary pipeline")
    sub = p.add_subparsers(dest="cmd", required=True)
    g = sub.add_parser("gather", help="fetch and cache the citable sources for a passage")
    g.add_argument("ref", help="surah:index, e.g. 2:4")
    g.set_defaults(fn=cmd_gather)
    return p


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
```

```python
# scripts/passages.py
#!/usr/bin/env python3
"""CLI for the passage commentary pipeline. See docs/plans/2026-09-05-passage-commentary-design.md."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scripts.passage_pipeline.cli import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_gather.py -q`
Expected: `2 passed`

**Step 5: Run gather for real on the Adam passage**

Run: `.venv/bin/python scripts/passages.py gather 2:4`
Expected: a line like `2:4 (30-39): NN source blocks -> .../passages_work/2/04` and `passages_work/2/04/sources.json` exists. Open it and confirm al-Burhan on 34 contains `أخرج ما كان في قلب إبليس من الحسد`. If altafsir returns empty for a work, it is listed under `unavailable`, which is fine.

**Step 6: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/gather.py scripts/passage_pipeline/cli.py scripts/passages.py tests/passage_pipeline/test_gather.py
git commit -m "passages: gather command caches citable source blocks per passage"
```

---

### Task 5: Draft schema and validator

**Files:**
- Create: `scripts/passage_pipeline/validate.py`
- Create: `tests/passage_pipeline/test_validate.py`
- Create: `tests/passage_pipeline/fixtures/draft_ok.json`
- Create: `tests/passage_pipeline/fixtures/sources_ok.json`
- Create: `tests/passage_pipeline/fixtures/verses_ok.json`

**Step 1: Write the fixtures**

`sources_ok.json` (a trimmed gather output):

```json
{"passage": "2:4", "gathered_at": "2026-09-08T10:00:00Z", "unavailable": {}, "sources": [
  {"id": "s1", "key": "mizan", "kind": "tafsir", "work": "al-Mizan fi Tafsir al-Quran", "author": "Allamah Muhammad Husayn Tabatabai", "tradition": "shia", "tier": "B", "role": "essay", "verses": [30, 31, 32, 33], "locus": "on Al-Baqara 30 to 33", "url": "https://www.altafsir.com/x?Page=1", "sha256": "a", "fetched_at": "2026-09-08T10:00:00Z",
   "text": "بيان الآيات تنبىء عن غرض إنزال الإِنسان إلى الدنيا. وهذا الكلام من الملائكة في مقام تعرف ما جهلوه واستيضاح ما أشكل عليهم من أمر هذا الخليفة، وليس من الاعتراض والخصومة في شيء."},
  {"id": "s2", "key": "burhan", "kind": "hadith", "work": "al-Burhan fi Tafsir al-Quran", "author": "Sayyid Hashim al-Bahrani", "tradition": "shia", "tier": "A", "role": "narrations", "verses": [34], "locus": "on Al-Baqara 34", "url": "https://www.altafsir.com/y?Page=1", "sha256": "b", "fetched_at": "2026-09-08T10:00:00Z",
   "text": "385/ [4]- علي بن إبراهيم، قال: حدثني أبي، عن ابن أبي عمير، عن جميل، عن أبي عبد الله (عليه السلام)، قال: فلما أمر الله الملائكة بالسجود لآدم، أخرج ما كان في قلب إبليس من الحسد، فعلمت الملائكة عند ذلك أن إبليس لم يكن منهم."},
  {"id": "s3", "key": "tabari", "kind": "tafsir", "work": "Jami al-Bayan", "author": "al-Tabari", "tradition": "sunni", "tier": "A", "role": "perspectives", "verses": [34], "locus": "on Al-Baqara 34", "url": "https://www.altafsir.com/z?Page=1", "sha256": "c", "fetched_at": "2026-09-08T10:00:00Z",
   "text": "وكان سجود الملائكة لآدم تكرمة له وطاعة لله، لا عبادة لآدم."}
]}
```

`verses_ok.json`:

```json
{"surah": {"number": 2, "englishName": "Al-Baqara", "englishNameTranslation": "The Cow", "revelationType": "Medinan", "versesCount": 286, "passageCount": 40},
 "passage": {"id": "2:4", "index": 4, "range": [30, 39]},
 "verses": [{"verse": 30, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 31, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 32, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 33, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 34, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 35, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 36, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 37, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 38, "arabic": "…", "translation": "…", "translationUrdu": ""}, {"verse": 39, "arabic": "…", "translation": "…", "translationUrdu": ""}]}
```

`draft_ok.json` (essay padded to the budget; the test helper fills it):

```json
{
  "passage": "2:4",
  "title": {"en": "Adam and the angels"},
  "essay": {"en": "ESSAY_PLACEHOLDER"},
  "verses": [
    {"verse": 34, "heading": {"en": "Iblis refuses"},
     "note": {"en": "Iblis was of the jinn (18:50), raised among the angels by his worship. Refused, then arrogant, then faithless."},
     "narrations": [
       {"id": "n1", "speaker": "Imam al-Sadiq", "addressee": null,
        "arabic": "فلما أمر الله الملائكة بالسجود لآدم، أخرج ما كان في قلب إبليس من الحسد، فعلمت الملائكة عند ذلك أن إبليس لم يكن منهم",
        "chain": "Ali ibn Ibrahim, from his father, from Ibn Abi Umayr, from Jamil, from Abu Abdillah",
        "text": {"en": "When Allah commanded the angels to prostrate to Adam, He brought out the envy that was in the heart of Iblis, and at that the angels knew that Iblis had not been one of them."},
        "source": "s2"}
     ]}
  ],
  "perspectives": {"en": "PERSPECTIVES_PLACEHOLDER"},
  "sources": [
    {"id": "s1", "excerpt": {"lang": "ar", "text": "وهذا الكلام من الملائكة في مقام تعرف ما جهلوه واستيضاح ما أشكل عليهم من أمر هذا الخليفة، وليس من الاعتراض والخصومة في شيء"}, "gloss": "This speech of the angels was a seeking to know what they did not know, and a request for clarity about this viceroy. It was not an objection or a dispute in any way."},
    {"id": "s2", "excerpt": {"lang": "ar", "text": "أخرج ما كان في قلب إبليس من الحسد"}, "gloss": "He brought out the envy that was in the heart of Iblis."},
    {"id": "s3", "excerpt": {"lang": "ar", "text": "تكرمة له وطاعة لله، لا عبادة لآدم"}, "gloss": "An honouring of him and obedience to Allah, not worship of Adam."}
  ]
}
```

**Step 2: Write the failing test**

```python
# tests/passage_pipeline/test_validate.py
import copy
import json
from pathlib import Path

import pytest

from scripts.passage_pipeline import validate as v

FIX = Path(__file__).parent / "fixtures"
ESSAY = ("The passage opens with an announcement, not a creation. Tabatabai reads the angels' question "
         "as a request to understand, not an objection [1]. ") * 12  # about 300 words
PERSP = ("Both traditions read the prostration as honouring Adam, not worship [3]. They part on the "
         "names and on the words of verse 37. ") * 4  # about 90 words


@pytest.fixture
def bundle():
    draft = json.loads((FIX / "draft_ok.json").read_text(encoding="utf-8"))
    draft["essay"]["en"] = ESSAY.strip()
    draft["perspectives"]["en"] = PERSP.strip()
    sources = json.loads((FIX / "sources_ok.json").read_text(encoding="utf-8"))
    verses = json.loads((FIX / "verses_ok.json").read_text(encoding="utf-8"))
    return draft, sources, verses


def errors(bundle, mutate=None):
    draft, sources, verses = copy.deepcopy(bundle)
    if mutate:
        mutate(draft, sources, verses)
    return v.validate_draft(draft, sources, verses)


def test_valid_draft_has_no_errors(bundle):
    assert errors(bundle) == []


def test_word_count_ignores_markers():
    assert v.word_count("Tabatabai reads it [1] as a request [12].") == 6


def test_normalize_arabic_strips_tashkeel_and_alef_forms():
    assert v.normalize_arabic("أَخْرَجَ مَا كَانَ") == v.normalize_arabic("اخرج ما كان")


def test_marker_must_resolve(bundle):
    errs = errors(bundle, lambda d, s, vv: d["essay"].__setitem__("en", d["essay"]["en"] + " Also [9]."))
    assert any("[9]" in e and "no source" in e for e in errs)


def test_every_source_must_be_used(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = d["essay"]["en"].replace("[1]", "")
    assert any("s1" in e and "never cited" in e for e in errors(bundle, mutate))


def test_draft_source_must_exist_in_gathered(bundle):
    def mutate(d, s, vv):
        d["sources"].append({"id": "s4", "excerpt": None, "gloss": None})
    assert any("s4" in e and "not in sources.json" in e for e in errors(bundle, mutate))


def test_excerpt_must_be_substring_of_block(bundle):
    def mutate(d, s, vv):
        d["sources"][0]["excerpt"]["text"] = "كلام لا وجود له في المصدر"
    assert any("s1" in e and "excerpt" in e and "not found" in e for e in errors(bundle, mutate))


def test_excerpt_may_join_spans_with_ellipsis(bundle):
    def mutate(d, s, vv):
        d["sources"][1]["excerpt"]["text"] = "فلما أمر الله الملائكة … لم يكن منهم"
    assert errors(bundle, mutate) == []


def test_tier_b_excerpt_limited_to_one_sentence(bundle):
    def mutate(d, s, vv):
        d["sources"][0]["excerpt"]["text"] = s["sources"][0]["text"]  # two sentences
    assert any("s1" in e and "tier B" in e for e in errors(bundle, mutate))


def test_tier_c_forbids_excerpt(bundle):
    def mutate(d, s, vv):
        s["sources"][0]["tier"] = "C"
    assert any("s1" in e and "tier C" in e for e in errors(bundle, mutate))


def test_narration_arabic_must_be_in_source(bundle):
    def mutate(d, s, vv):
        d["verses"][0]["narrations"][0]["arabic"] = "نص مخترع"
    assert any("n1" in e and "arabic" in e and "not found" in e for e in errors(bundle, mutate))


def test_narration_source_must_bear_narrations(bundle):
    def mutate(d, s, vv):
        d["verses"][0]["narrations"][0]["source"] = "s1"
        d["verses"][0]["narrations"][0]["arabic"] = "وليس من الاعتراض والخصومة في شيء"
    assert any("n1" in e and "mizan" in e and "not a narration source" in e for e in errors(bundle, mutate))


def test_sunni_source_outside_perspectives_rejected(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = d["essay"]["en"].replace("[1]", "[1][3]", 1)
    assert any("[3]" in e and "sunni" in e and "essay" in e for e in errors(bundle, mutate))


def test_essay_budget_for_long_passage(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = "Short essay [1]."
    assert any("essay" in e and "250" in e for e in errors(bundle, mutate))


def test_essay_budget_for_short_passage(bundle):
    def mutate(d, s, vv):
        vv["passage"]["range"] = [30, 34]
        vv["verses"] = vv["verses"][:5]
        d["essay"]["en"] = ("word " * 260).strip() + " [1]"
    assert any("essay" in e and "250" in e and "over" in e for e in errors(bundle, mutate))


def test_note_and_title_budgets(bundle):
    def mutate(d, s, vv):
        d["title"]["en"] = "One two three four five six seven"
        d["verses"][0]["note"]["en"] = ("w " * 41).strip()
    errs = errors(bundle, mutate)
    assert any("title" in e and "6 words" in e for e in errs)
    assert any("note" in e and "40 words" in e for e in errs)


def test_max_three_narrations_per_verse(bundle):
    def mutate(d, s, vv):
        n = d["verses"][0]["narrations"][0]
        d["verses"][0]["narrations"] = [dict(n, id=f"n{i}") for i in range(1, 5)]
    assert any("verse 34" in e and "3 narrations" in e for e in errors(bundle, mutate))


def test_verse_entry_needs_note_or_narration(bundle):
    def mutate(d, s, vv):
        d["verses"].append({"verse": 35, "heading": {"en": "x"}, "note": None, "narrations": []})
    assert any("verse 35" in e and "nothing of its own" in e for e in errors(bundle, mutate))


def test_verse_must_be_in_range_and_unique(bundle):
    def mutate(d, s, vv):
        d["verses"].append(dict(d["verses"][0], verse=99))
        d["verses"].append(dict(d["verses"][0]))
    errs = errors(bundle, mutate)
    assert any("verse 99" in e and "outside" in e for e in errs)
    assert any("verse 34" in e and "twice" in e for e in errs)


def test_style_rules(bundle):
    def mutate(d, s, vv):
        d["essay"]["en"] = d["essay"]["en"] + " Ṭabāṭabāʾī — said."
    errs = errors(bundle, mutate)
    assert any("diacritic" in e for e in errs)
    assert any("em dash" in e for e in errs)


def test_perspectives_optional_but_budgeted(bundle):
    def mutate(d, s, vv):
        d["perspectives"] = None
        d["sources"] = d["sources"][:2]
    assert errors(bundle, mutate) == []

    def mutate2(d, s, vv):
        d["perspectives"]["en"] = "Tiny [3]."
    assert any("perspectives" in e and "60" in e for e in errors(bundle, mutate2))


def test_passage_id_must_match(bundle):
    assert any("passage" in e for e in errors(bundle, lambda d, s, vv: d.__setitem__("passage", "2:5")))
```

**Step 3: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_validate.py -q`
Expected: FAIL with `ImportError: cannot import name 'validate'`

**Step 4: Write minimal implementation**

```python
# scripts/passage_pipeline/validate.py
"""Stage 3: every mechanical rule from the design doc, as a list of error strings."""
from __future__ import annotations

import re
import unicodedata

from . import sources as sources_mod

MARKER_RE = re.compile(r"\[(\d+)\]")
DIACRITIC_RE = re.compile(r"[āīūḥṣḍṭẓʿʾĀĪŪḤṢḌṬẒ]")
TASHKEEL_RE = re.compile(r"[ؐ-ًؚ-ٰٟۖ-ۭـ]")
ARABIC_SENTENCE_END_RE = re.compile(r"[.!?؟]")
WORD_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9'’-]*")

TITLE_MAX_WORDS = 6
HEADING_MAX_WORDS = 5
NOTE_MAX_WORDS = 40
NARRATION_MAX_WORDS = 60
NARRATIONS_PER_VERSE = 3
ESSAY_LONG = (250, 400)   # passages of 8 or more verses
ESSAY_SHORT = (120, 250)
PERSPECTIVES = (60, 120)
TIER_B_MAX_CHARS = 220


def strip_markers(text: str) -> str:
    return MARKER_RE.sub("", text)


def word_count(text: str) -> int:
    return len(WORD_RE.findall(strip_markers(text)))


def normalize_arabic(text: str) -> str:
    text = unicodedata.normalize("NFKC", text)
    text = TASHKEEL_RE.sub("", text)
    for a, b in (("ٱ", "ا"), ("أ", "ا"), ("إ", "ا"), ("آ", "ا"), ("ى", "ي"), ("ة", "ه")):
        text = text.replace(a, b)
    text = re.sub(r"[^\w\s]", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def spans_in(needle: str, haystack: str) -> bool:
    """Every span of `needle` (split on an ellipsis) appears in `haystack`, normalized."""
    hay = normalize_arabic(haystack)
    for span in re.split(r"…|\.\.\.", needle):
        span = normalize_arabic(span)
        if span and span not in hay:
            return False
    return True


def _markers(text: str | None) -> list[int]:
    return [int(m) for m in MARKER_RE.findall(text or "")]


def _en(field) -> str | None:
    if field is None:
        return None
    return field.get("en") if isinstance(field, dict) else None


def validate_draft(draft: dict, gathered: dict, verses: dict) -> list[str]:
    errs: list[str] = []
    ref = verses["passage"]
    if draft.get("passage") != ref["id"]:
        errs.append(f"passage id {draft.get('passage')!r} does not match {ref['id']!r}")
    lo, hi = ref["range"]
    n_verses = hi - lo + 1
    by_id = {s["id"]: s for s in gathered["sources"]}

    # sources block of the draft
    draft_sources = draft.get("sources") or []
    draft_ids = [s.get("id") for s in draft_sources]
    for s in draft_sources:
        sid = s.get("id")
        if sid not in by_id:
            errs.append(f"source {sid} is not in sources.json")
            continue
        g = by_id[sid]
        ex = s.get("excerpt")
        if g["tier"] == "C" and ex:
            errs.append(f"source {sid} is tier C: excerpt must be null")
        if ex:
            if not spans_in(ex.get("text", ""), g["text"]):
                errs.append(f"source {sid} excerpt not found in the gathered block")
            if g["tier"] == "B":
                body = ex.get("text", "")
                if len(body) > TIER_B_MAX_CHARS or len(ARABIC_SENTENCE_END_RE.findall(body.rstrip(".!?؟"))) > 0:
                    errs.append(f"source {sid} is tier B: quote one sentence, at most {TIER_B_MAX_CHARS} characters")
            if not s.get("gloss"):
                errs.append(f"source {sid} has an excerpt but no gloss")

    def marker_ids(text: str | None, where: str, allow_sunni: bool) -> None:
        for n in _markers(text):
            sid = f"s{n}"
            if sid not in draft_ids or sid not in by_id:
                errs.append(f"marker [{n}] in {where} has no source (expected {sid} in the draft's sources)")
                continue
            if not allow_sunni and by_id[sid]["tradition"] == "sunni":
                errs.append(f"marker [{n}] in {where} cites a sunni source; sunni works only in perspectives")

    # title and essay
    title = _en(draft.get("title")) or ""
    if not title:
        errs.append("title.en is required")
    elif word_count(title) > TITLE_MAX_WORDS:
        errs.append(f"title is over {TITLE_MAX_WORDS} words")
    essay = _en(draft.get("essay")) or ""
    lo_w, hi_w = ESSAY_LONG if n_verses >= 8 else ESSAY_SHORT
    wc = word_count(essay)
    if wc < lo_w:
        errs.append(f"essay has {wc} words, under the {lo_w} minimum for a {n_verses}-verse passage")
    if wc > hi_w:
        errs.append(f"essay has {wc} words, over the {hi_w} maximum (budget {lo_w} to {hi_w})")
    marker_ids(essay, "essay", allow_sunni=False)
    used: set[int] = set(_markers(essay))

    # verses
    seen: set[int] = set()
    for entry in draft.get("verses") or []:
        vn = entry.get("verse")
        if vn in seen:
            errs.append(f"verse {vn} appears twice")
        seen.add(vn)
        if not (lo <= vn <= hi):
            errs.append(f"verse {vn} is outside the passage range {lo} to {hi}")
        heading = _en(entry.get("heading")) or ""
        if word_count(heading) > HEADING_MAX_WORDS:
            errs.append(f"verse {vn} heading is over {HEADING_MAX_WORDS} words")
        note = _en(entry.get("note"))
        nars = entry.get("narrations") or []
        if not note and not nars:
            errs.append(f"verse {vn} has nothing of its own; drop the entry")
        if note:
            if word_count(note) > NOTE_MAX_WORDS:
                errs.append(f"verse {vn} note is over {NOTE_MAX_WORDS} words")
            marker_ids(note, f"verse {vn} note", allow_sunni=False)
            used.update(_markers(note))
        if len(nars) > NARRATIONS_PER_VERSE:
            errs.append(f"verse {vn} has more than {NARRATIONS_PER_VERSE} narrations")
        for nar in nars:
            nid = nar.get("id", "?")
            sid = nar.get("source")
            if sid not in by_id or sid not in draft_ids:
                errs.append(f"narration {nid} source {sid} is not in the draft's sources")
                continue
            used.add(int(sid[1:]))
            g = by_id[sid]
            if g["key"] not in sources_mod.NARRATION_KEYS:
                errs.append(f"narration {nid} cites {g['key']}, which is not a narration source")
            if g["tradition"] != "shia":
                errs.append(f"narration {nid} cites a sunni source")
            if not nar.get("arabic"):
                errs.append(f"narration {nid} has no arabic")
            elif not spans_in(nar["arabic"], g["text"]):
                errs.append(f"narration {nid} arabic not found in source {sid}")
            if not nar.get("speaker"):
                errs.append(f"narration {nid} has no speaker")
            en = _en(nar.get("text")) or ""
            if not en:
                errs.append(f"narration {nid} has no text.en")
            elif word_count(en) > NARRATION_MAX_WORDS:
                errs.append(f"narration {nid} text is over {NARRATION_MAX_WORDS} words")

    # perspectives
    persp = _en(draft.get("perspectives"))
    if persp:
        pw = word_count(persp)
        if pw < PERSPECTIVES[0] or pw > PERSPECTIVES[1]:
            errs.append(f"perspectives has {pw} words, budget {PERSPECTIVES[0]} to {PERSPECTIVES[1]}")
        marker_ids(persp, "perspectives", allow_sunni=True)
        used.update(_markers(persp))

    # every draft source cited somewhere
    for sid in draft_ids:
        if sid in by_id and int(sid[1:]) not in used:
            errs.append(f"source {sid} is listed but never cited")

    # style, English fields only
    english = [title, essay, persp or ""]
    for entry in draft.get("verses") or []:
        english += [_en(entry.get("heading")) or "", _en(entry.get("note")) or ""]
        english += [_en(n.get("text")) or "" for n in entry.get("narrations") or []]
    english += [s.get("gloss") or "" for s in draft_sources]
    blob = "\n".join(english)
    if DIACRITIC_RE.search(blob):
        errs.append("transliteration diacritics found in English text; use plain spelling")
    if "—" in blob:
        errs.append("em dash found in English text; use a plain dash")
    return errs
```

Note for the tier B check: the excerpt may end with a full stop; the rule is no sentence terminator inside the quote. The test fixture's al-Mizan excerpt has none.

**Step 5: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_validate.py -q`
Expected: `22 passed`

**Step 6: Wire `validate` into the CLI**

Add to `cli.py`:

```python
import json
from . import validate as validate_mod


def load_work(ref):
    d = ref.work_dir
    read = lambda name: json.loads((d / name).read_text(encoding="utf-8"))
    return read("draft.json"), read("sources.json"), read("verses.json")


def cmd_validate(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    try:
        draft, gathered, verses = load_work(ref)
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    errs = validate_mod.validate_draft(draft, gathered, verses)
    if errs:
        print(f"{ref.id}: {len(errs)} problem(s)")
        for e in errs:
            print(f"  - {e}")
        return 1
    print(f"{ref.id}: draft is valid")
    return 0
```

and in `build_parser`:

```python
    vp = sub.add_parser("validate", help="check draft.json against the rules")
    vp.add_argument("ref")
    vp.set_defaults(fn=cmd_validate)
```

Run: `.venv/bin/python scripts/passages.py validate 2:4`
Expected: `missing file: .../draft.json` and exit code 2 (no draft yet).

**Step 7: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/validate.py scripts/passage_pipeline/cli.py tests/passage_pipeline/test_validate.py tests/passage_pipeline/fixtures/
git commit -m "passages: draft validator with every mechanical rule"
```

---

### Task 6: Brief command (the packet agents read)

**Files:**
- Create: `scripts/passage_pipeline/brief.py`
- Modify: `scripts/passage_pipeline/cli.py`
- Create: `tests/passage_pipeline/test_brief.py`

The writer and auditor never open `sources.json` by hand. They run `brief`, which prints one document: the verses, then every source block with its id, work, tier, role and full text. `--audit` adds the draft. Keeping the packet a single command keeps the agent prompts short and the inputs identical for both agents.

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_brief.py
import json
from pathlib import Path

from scripts.passage_pipeline import brief

FIX = Path(__file__).parent / "fixtures"


def load(name):
    return json.loads((FIX / name).read_text(encoding="utf-8"))


def test_writer_brief_lists_verses_and_sources():
    out = brief.render(load("verses_ok.json"), load("sources_ok.json"), draft=None)
    assert "# Passage 2:4 · Al-Baqara 30 to 39" in out
    assert "## Verses" in out and "### 34" in out
    assert "## Sources you may cite" in out
    assert "### s1 · al-Mizan fi Tafsir al-Quran · Allamah Muhammad Husayn Tabatabai · shia · tier B · essay" in out
    assert "### s2 · al-Burhan fi Tafsir al-Quran" in out
    assert "أخرج ما كان في قلب إبليس" in out
    assert "## Draft" not in out


def test_audit_brief_includes_draft():
    draft = load("draft_ok.json")
    out = brief.render(load("verses_ok.json"), load("sources_ok.json"), draft=draft)
    assert "## Draft under audit" in out
    assert '"title"' in out and "Adam and the angels" in out


def test_unavailable_sources_are_named():
    srcs = load("sources_ok.json")
    srcs["unavailable"] = {"qummi": [30, 31]}
    out = brief.render(load("verses_ok.json"), srcs, draft=None)
    assert "qummi: verses 30, 31" in out
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_brief.py -q`
Expected: FAIL with `ImportError`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/brief.py
from __future__ import annotations

import json


def render(verses: dict, gathered: dict, draft: dict | None) -> str:
    s = verses["surah"]
    p = verses["passage"]
    lo, hi = p["range"]
    out = [f"# Passage {p['id']} · {s['englishName']} {lo} to {hi}",
           f"{s['englishNameTranslation']} · {s['revelationType']} · passage {p['index']} of {s['passageCount']}", ""]
    out.append("## Verses")
    for v in verses["verses"]:
        out += [f"### {v['verse']}", v["arabic"], "", v["translation"], ""]
    out.append("## Sources you may cite")
    out.append("Cite by id only. Anything not listed here does not exist for this passage.")
    unavailable = gathered.get("unavailable") or {}
    if unavailable:
        out.append("Not available for this passage: " + "; ".join(
            f"{k}: verses {', '.join(map(str, vs))}" for k, vs in unavailable.items()))
    out.append("")
    for src in gathered["sources"]:
        out.append(f"### {src['id']} · {src['work'] or src['key']} · {src['author']} · {src['tradition']} · "
                   f"tier {src['tier']} · {src['role']}")
        out.append(f"{src['locus']} · {src['url']}")
        if src.get("grades"):
            out.append(f"grading: {', '.join(map(str, src['grades']))}")
        out += ["", src["text"], ""]
    if draft is not None:
        out += ["## Draft under audit", "```json", json.dumps(draft, ensure_ascii=False, indent=2), "```"]
    return "\n".join(out)
```

CLI:

```python
from . import brief as brief_mod


def cmd_brief(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    d = ref.work_dir
    read = lambda name: json.loads((d / name).read_text(encoding="utf-8"))
    draft = read("draft.json") if args.audit else None
    print(brief_mod.render(read("verses.json"), read("sources.json"), draft))
    return 0
```

```python
    b = sub.add_parser("brief", help="print the packet the writer (or with --audit, the auditor) reads")
    b.add_argument("ref")
    b.add_argument("--audit", action="store_true")
    b.set_defaults(fn=cmd_brief)
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_brief.py -q`
Expected: `3 passed`

Run: `.venv/bin/python scripts/passages.py brief 2:4 | head -40`
Expected: the header, verse 30's Arabic and translation.

**Step 5: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/brief.py scripts/passage_pipeline/cli.py tests/passage_pipeline/test_brief.py
git commit -m "passages: brief command renders the agent packet"
```

---

### Task 7: Validation hook and the writer agent

**Files:**
- Create: `.claude/hooks/validate-passage-draft.py`
- Create: `.claude/agents/passage-writer.md`

**Step 1: Write the hook**

```python
#!/usr/bin/env python3
"""PostToolUse hook: when an agent writes passages_work/<s>/<i>/draft.json, run the
validator. Exit 2 with the errors on stderr so the write is reported back as blocked."""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PATTERN = re.compile(r"passages_work/(\d+)/(\d+)/draft\.json$")


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)
    path = (data.get("tool_input") or {}).get("file_path", "")
    m = PATTERN.search(path.replace("\\", "/"))
    if not m:
        sys.exit(0)
    ref = f"{int(m.group(1))}:{int(m.group(2))}"
    proc = subprocess.run([str(ROOT / ".venv" / "bin" / "python"), str(ROOT / "scripts" / "passages.py"),
                           "validate", ref], capture_output=True, text=True)
    if proc.returncode == 0:
        print(f"Passage draft {ref} is valid")
        sys.exit(0)
    print("PASSAGE DRAFT REJECTED. Fix every item and write draft.json again:\n" + proc.stdout, file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
```

Run: `chmod +x .claude/hooks/validate-passage-draft.py`

Test the hook by hand:

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"passages_work/2/04/draft.json"}}' | .venv/bin/python .claude/hooks/validate-passage-draft.py; echo "exit $?"
```

Expected: `missing file: .../draft.json` on stderr, `exit 2` (no draft yet).

**Step 2: Write the writer agent**

```markdown
---
name: passage-writer
description: Write the commentary for one Quran passage (a ruku) from the gathered source blocks only - title, essay with citation markers, verse headings and notes, sourced narrations with verbatim Arabic, and perspectives - as passages_work/<surah>/<index>/draft.json. Never fetches anything and never edits app data. Use when asked to write, draft, or rewrite passage <surah>:<index>.
tools: Read, Write, Bash
model: opus
hooks:
  PreToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
    - matcher: Edit
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
  PostToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/validate-passage-draft.py"
---

You write the commentary for one passage of the Quran for the Thaqalayn app, a Shia app. You write from sources, not from memory. Every claim you make must point at a block in the packet, and you may not cite anything that is not in the packet.

## Input

The request names a passage as `surah:index`, for example `2:4`. Run:

```
.venv/bin/python scripts/passages.py brief 2:4
```

That prints the verses (Arabic and the Ali Quli Qarai translation) and every source block you may cite, each with an id (`s1`, `s2`, ...), the work, the author, the tradition, the tier and the role. Read all of it before writing a word. If the request says this is a rewrite, also read `passages_work/<surah>/<index>/audit.<n>.json` (the highest n) first: every `unsupported` or `stretched` verdict must be resolved, by re-grounding the claim in a block that actually says it or by removing the claim.

## Output

Write exactly one file: `passages_work/<surah>/<index>/draft.json`. A validator runs on every write and rejects the file with a list of problems if any rule is broken. Fix every item and write again. Do not write anywhere else. Do not create summaries.

```json
{
  "passage": "2:4",
  "title": {"en": "Adam and the angels"},
  "essay": {"en": "... prose with markers like [1] and [2] ..."},
  "verses": [
    {
      "verse": 34,
      "heading": {"en": "Iblis refuses"},
      "note": {"en": "One or two sentences, only if this verse needs its own gloss [2]."},
      "narrations": [
        {
          "id": "n1",
          "speaker": "Imam al-Sadiq",
          "addressee": null,
          "arabic": "verbatim Arabic copied from the source block",
          "chain": "Ali ibn Ibrahim, from his father, from Ibn Abi Umayr, from Jamil, from Abu Abdillah",
          "text": {"en": "Faithful English rendering, at most 60 words."},
          "source": "s2"
        }
      ]
    }
  ],
  "perspectives": {"en": "... or null when the traditions do not differ on this passage ..."},
  "sources": [
    {"id": "s1", "excerpt": {"lang": "ar", "text": "verbatim span from the block"}, "gloss": "English rendering of the excerpt"},
    {"id": "s2", "excerpt": {"lang": "ar", "text": "..."}, "gloss": "..."}
  ]
}
```

## Rules the validator enforces

- Markers `[n]` refer to source `s<n>`. Every marker resolves. Every source you list is cited at least once. A source id that is not in the packet does not exist.
- The essay is 250 to 400 words for passages of 8 or more verses, 120 to 250 for shorter ones. Title at most 6 words. Heading at most 5. Note at most 40. Narration text at most 60. Perspectives 60 to 120 words or `null`.
- Narrations cite only narration-bearing sources (al-Burhan, Tafsir al-Qummi, al-Safi, Furat, Majma al-Bayan, the hadith corpus). `arabic` is copied verbatim from the block; you may join two spans with ` … `. Give the chain when the block has one. At most 3 narrations per verse.
- A verse entry exists only when the verse has a note or a narration. Do not pad. Most verses in a passage will have no entry.
- Sunni sources (`tradition: sunni`) may be cited only in `perspectives`.
- Every source with an excerpt has a gloss. Tier B sources: quote one sentence. Tier C: `"excerpt": null`.
- English in plain spelling: Tabatabai, Ali, Fatimah, Husayn. No macrons, no under-dots, no half-rings. No em dash. Quote the verse in Qarai's wording.

## How to write

- **Title**: what the passage is about, as a reader would name it. "Adam and the angels", not "Verses 30 to 39".
- **Essay**: tell the passage once, in order, as one piece. Open with what it announces, follow its turns, close with where it leaves the reader. Lean on al-Mizan, Majma and al-Tibyan for the reading; cite the block whenever you report what a commentator holds, an occasion of revelation, or a disputed reading. Plain narrative of what the verses say needs no marker. Never attribute a position to a scholar the packet does not show holding it.
- **Verse entries**: only where a verse needs its own gloss (a term, a ruling, a cross-reference such as 18:50) or has a narration about it specifically. A narration about the whole passage goes on its first verse.
- **Narrations**: prefer the ones that interpret the verse over the ones that merely quote it. Render the Arabic faithfully; do not embellish. If the packet has no narration for a verse, that verse gets none.
- **Perspectives**: only where the Shia and Sunni blocks actually read the passage differently. Say what each holds and cite both. When they agree, write `null`.
- **Excerpts**: the shortest span that carries the claim.

When the validator accepts the file, stop. Do not summarise.
```

**Step 3: Smoke-test the writer on the Adam passage**

Precondition: `passages_work/2/04/sources.json` exists from Task 4.

Run from the main session: launch the `passage-writer` agent with the prompt `Write passage 2:4`.

Expected: the agent runs `brief`, writes `draft.json`, the hook either accepts it or returns the error list and the agent rewrites. End state: `.venv/bin/python scripts/passages.py validate 2:4` prints `2:4: draft is valid`. Read the draft. If the essay is generic or the narrations look thin, that is a prompt problem: adjust the "How to write" section, not the rules.

**Step 4: Commit**

Ask first. Then:

```bash
git add .claude/hooks/validate-passage-draft.py .claude/agents/passage-writer.md
git commit -m "passages: writer agent with blocking draft validation"
```

---

### Task 8: Audit format, audit-check, and the auditor agent

**Files:**
- Create: `scripts/passage_pipeline/audit.py`
- Modify: `scripts/passage_pipeline/cli.py`
- Create: `tests/passage_pipeline/test_audit.py`
- Create: `.claude/agents/passage-auditor.md`

The auditor writes `passages_work/<s>/<i>/audit.<n>.json` where n is one more than the highest existing. `audit-check` validates its shape, confirms that every marker and narration in the draft has a verdict, and computes pass.

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_audit.py
import copy
import json
from pathlib import Path

from scripts.passage_pipeline import audit

FIX = Path(__file__).parent / "fixtures"


def draft():
    d = json.loads((FIX / "draft_ok.json").read_text(encoding="utf-8"))
    d["essay"]["en"] = "Tabatabai reads it as a request, not an objection [1]."
    d["perspectives"]["en"] = "Both honour, not worship [3]."
    return d


def good_audit():
    return {"passage": "2:4", "verdicts": [
        {"target": "essay[1]", "claim": "Tabatabai: request, not objection", "verdict": "supported",
         "excerpt": "وليس من الاعتراض والخصومة في شيء", "note": ""},
        {"target": "verses.34.narrations.n1", "claim": "Imam al-Sadiq on envy", "verdict": "supported",
         "excerpt": "أخرج ما كان في قلب إبليس من الحسد", "note": ""},
        {"target": "perspectives[3]", "claim": "Tabari: honour not worship", "verdict": "supported",
         "excerpt": "لا عبادة لآدم", "note": ""},
    ], "uncited": [], "coverage": "The essay covers the whole passage.", "summary": "All supported."}


def test_expected_targets_come_from_draft():
    assert audit.expected_targets(draft()) == {"essay[1]", "verses.34.narrations.n1", "perspectives[3]"}


def test_good_audit_passes():
    errs, passed = audit.check(good_audit(), draft())
    assert errs == [] and passed is True


def test_missing_verdict_is_an_error():
    a = good_audit()
    a["verdicts"].pop()
    errs, _ = audit.check(a, draft())
    assert any("perspectives[3]" in e and "no verdict" in e for e in errs)


def test_unknown_target_is_an_error():
    a = good_audit()
    a["verdicts"][0]["target"] = "essay[7]"
    errs, _ = audit.check(a, draft())
    assert any("essay[7]" in e for e in errs)


def test_unsupported_fails():
    a = good_audit()
    a["verdicts"][0]["verdict"] = "unsupported"
    errs, passed = audit.check(a, draft())
    assert errs == [] and passed is False


def test_stretched_narration_fails_but_stretched_essay_passes():
    a = good_audit()
    a["verdicts"][0]["verdict"] = "stretched"
    assert audit.check(a, draft())[1] is True
    a = good_audit()
    a["verdicts"][1]["verdict"] = "stretched"
    assert audit.check(a, draft())[1] is False


def test_uncited_claim_fails():
    a = good_audit()
    a["uncited"] = [{"where": "essay", "claim": "Makarem Shirazi holds X", "note": "named scholar, no marker"}]
    assert audit.check(a, draft())[1] is False


def test_next_attempt_number(tmp_path):
    assert audit.next_attempt(tmp_path) == 1
    (tmp_path / "audit.1.json").write_text("{}")
    (tmp_path / "audit.2.json").write_text("{}")
    assert audit.next_attempt(tmp_path) == 3
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_audit.py -q`
Expected: FAIL with `ImportError`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/audit.py
"""Stage 4 support: the audit file format and the pass rule."""
from __future__ import annotations

import re
from pathlib import Path

from .validate import MARKER_RE

VERDICTS = {"supported", "stretched", "unsupported"}
AUDIT_FILE_RE = re.compile(r"audit\.(\d+)\.json$")


def expected_targets(draft: dict) -> set[str]:
    targets: set[str] = set()
    for n in MARKER_RE.findall((draft.get("essay") or {}).get("en", "")):
        targets.add(f"essay[{n}]")
    persp = draft.get("perspectives") or {}
    for n in MARKER_RE.findall(persp.get("en", "") if isinstance(persp, dict) else ""):
        targets.add(f"perspectives[{n}]")
    for entry in draft.get("verses") or []:
        vn = entry.get("verse")
        note = (entry.get("note") or {}).get("en", "") if entry.get("note") else ""
        for n in MARKER_RE.findall(note):
            targets.add(f"verses.{vn}.note[{n}]")
        for nar in entry.get("narrations") or []:
            targets.add(f"verses.{vn}.narrations.{nar.get('id')}")
    return targets


def check(audit_doc: dict, draft: dict) -> tuple[list[str], bool]:
    errs: list[str] = []
    if audit_doc.get("passage") != draft.get("passage"):
        errs.append("audit passage id does not match the draft")
    expected = expected_targets(draft)
    seen: set[str] = set()
    for v in audit_doc.get("verdicts") or []:
        t = v.get("target")
        if t not in expected:
            errs.append(f"verdict target {t!r} is not a marker or narration in the draft")
            continue
        seen.add(t)
        if v.get("verdict") not in VERDICTS:
            errs.append(f"{t}: verdict must be one of {sorted(VERDICTS)}")
        if v.get("verdict") != "unsupported" and not v.get("excerpt"):
            errs.append(f"{t}: a supported or stretched verdict needs the supporting excerpt")
    for t in sorted(expected - seen):
        errs.append(f"{t}: no verdict")
    if not isinstance(audit_doc.get("coverage"), str) or not audit_doc.get("coverage"):
        errs.append("coverage judgement is required")
    if errs:
        return errs, False
    verdicts = audit_doc.get("verdicts") or []
    unsupported = [v for v in verdicts if v["verdict"] == "unsupported"]
    stretched_narrations = [v for v in verdicts if v["verdict"] == "stretched" and ".narrations." in v["target"]]
    uncited = audit_doc.get("uncited") or []
    passed = not unsupported and not stretched_narrations and not uncited
    return [], passed


def next_attempt(work_dir: Path) -> int:
    nums = [int(m.group(1)) for p in work_dir.glob("audit.*.json") for m in [AUDIT_FILE_RE.search(p.name)] if m]
    return (max(nums) + 1) if nums else 1


def latest(work_dir: Path) -> Path | None:
    n = next_attempt(work_dir) - 1
    return (work_dir / f"audit.{n}.json") if n >= 1 else None
```

CLI:

```python
from . import audit as audit_mod


def cmd_audit_check(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    path = ref.work_dir / f"audit.{args.attempt}.json" if args.attempt else audit_mod.latest(ref.work_dir)
    if path is None or not path.exists():
        print("no audit file")
        return 2
    doc = json.loads(path.read_text(encoding="utf-8"))
    errs, passed = audit_mod.check(doc, draft)
    if errs:
        print(f"{path.name}: malformed")
        for e in errs:
            print(f"  - {e}")
        return 2
    print(f"{path.name}: {'PASS' if passed else 'FAIL'}")
    for v in doc["verdicts"]:
        if v["verdict"] != "supported":
            print(f"  {v['verdict']:11s} {v['target']}: {v.get('note') or v['claim']}")
    for u in doc.get("uncited") or []:
        print(f"  uncited     {u['where']}: {u['claim']}")
    return 0 if passed else 1


def cmd_next_attempt(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    print(audit_mod.next_attempt(ref.work_dir))
    return 0
```

```python
    ac = sub.add_parser("audit-check", help="validate the latest audit file and print PASS or FAIL")
    ac.add_argument("ref")
    ac.add_argument("--attempt", type=int)
    ac.set_defaults(fn=cmd_audit_check)
    na = sub.add_parser("next-attempt", help="print the attempt number the next audit file should use")
    na.add_argument("ref")
    na.set_defaults(fn=cmd_next_attempt)
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_audit.py -q`
Expected: `8 passed`

**Step 5: Write the auditor agent**

```markdown
---
name: passage-auditor
description: Audit one passage draft against its gathered source blocks - rule on every citation marker and every narration as supported, stretched or unsupported with the supporting excerpt, flag claims that carry no marker, judge coverage - and write passages_work/<surah>/<index>/audit.<n>.json. Never fetches anything, never edits the draft, never edits app data. Use when asked to audit passage <surah>:<index>.
tools: Read, Write, Bash
model: opus
hooks:
  PreToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
    - matcher: Edit
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
---

You are the second pair of eyes on a passage commentary for the Thaqalayn app. The writer was allowed to use only the source blocks in the packet. Your job is to check, claim by claim, whether the blocks actually say what the draft says they say. You check text against text. You do not use your own knowledge of tafsir to fill gaps, and you never look anything up.

## Input

The request names a passage as `surah:index`. Run:

```
.venv/bin/python scripts/passages.py brief 2:4 --audit
.venv/bin/python scripts/passages.py next-attempt 2:4
```

The first prints the verses, every source block, and the draft. The second prints the attempt number `n` for your output file.

## What to rule on

One verdict for every target:

- Every marker in the essay: target `essay[n]`.
- Every marker in a verse note: target `verses.<verse>.note[n]`.
- Every marker in perspectives: target `perspectives[n]`.
- Every narration: target `verses.<verse>.narrations.<id>`.

For a marker, the claim is the sentence (or clause) the marker is attached to. Find the place in block `s<n>` that supports it and quote it as `excerpt`. Rule:

- `supported`: the block says this. Paraphrase is fine; the position, the attribution and the substance match.
- `stretched`: the block is about this but the draft goes further than it does, sharpens it, or attributes to the author something the block reports from someone else.
- `unsupported`: the block does not say this, or says the opposite, or the marker points at a block about something else.

For a narration, compare the `arabic` and the English `text` against the block: the speaker named in the draft must be the speaker in the chain, the English must render the Arabic without addition, and the `chain` must match the block. Any mismatch in speaker or substance is `unsupported`; an English rendering that adds colour the Arabic lacks is `stretched`.

Then two more things:

- **Uncited claims.** Read the essay, notes and perspectives for sentences that attribute a position to a named person or work, report an occasion of revelation, or quote a saying, and carry no marker. List each under `uncited`. Plain narration of what the verses say does not need a marker.
- **Coverage.** In two or three sentences, does the essay tell the whole passage in order, or does it skip verses or drift?

## Output

Write exactly one file, `passages_work/<surah>/<index>/audit.<n>.json`:

```json
{
  "passage": "2:4",
  "verdicts": [
    {"target": "essay[1]", "claim": "Tabatabai reads the angels' question as a request to understand, not an objection", "verdict": "supported", "excerpt": "وليس من الاعتراض والخصومة في شيء", "note": ""},
    {"target": "verses.34.narrations.n1", "claim": "Imam al-Sadiq: the command brought out the envy in Iblis", "verdict": "supported", "excerpt": "أخرج ما كان في قلب إبليس من الحسد", "note": "chain matches"}
  ],
  "uncited": [
    {"where": "essay", "claim": "Makarem Shirazi links adl to systemic fairness", "note": "named scholar with no marker and no block"}
  ],
  "coverage": "The essay follows 30 to 39 in order and closes on 38 to 39.",
  "summary": "12 supported, 1 stretched (essay[4] sharpens Majma), 0 unsupported, 1 uncited."
}
```

Then run `.venv/bin/python scripts/passages.py audit-check 2:4`. If it prints `malformed`, fix the file. When it prints PASS or FAIL, stop. Do not edit the draft. Do not write anything else.
```

**Step 6: Smoke-test the loop on 2:4**

From the main session, with a valid draft present: launch `passage-auditor` with `Audit passage 2:4`. Then `.venv/bin/python scripts/passages.py audit-check 2:4`. If FAIL, launch `passage-writer` with `Rewrite passage 2:4; read the latest audit first`, then audit again. Record how many attempts it took.

**Step 7: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/audit.py scripts/passage_pipeline/cli.py tests/passage_pipeline/test_audit.py .claude/agents/passage-auditor.md
git commit -m "passages: audit format, audit-check, and the auditor agent"
```

---

### Task 9: Status and next

**Files:**
- Create: `scripts/passage_pipeline/status.py`
- Modify: `scripts/passage_pipeline/cli.py`
- Create: `tests/passage_pipeline/test_status.py`

State is derived from files, never stored: `gathered` (sources.json), `drafted` (draft.json), `valid` (validator passes), `audited: PASS|FAIL n` (latest audit), `titles` (approved flag in titles.json), `assembled` (present in Data/passages_N.json).

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_status.py
import json
from pathlib import Path

from scripts.passage_pipeline import rukus, status

FIX = Path(__file__).parent / "fixtures"


def test_state_progression(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    assert status.state(ref)["stage"] == "new"
    ref.work_dir.mkdir(parents=True)
    for name in ("verses.json", "sources.json"):
        (ref.work_dir / name).write_text((FIX / name.replace(".json", "_ok.json")).read_text(encoding="utf-8"), encoding="utf-8")
    assert status.state(ref)["stage"] == "gathered"
    (ref.work_dir / "draft.json").write_text((FIX / "draft_ok.json").read_text(encoding="utf-8"), encoding="utf-8")
    s = status.state(ref)
    assert s["stage"] == "drafted" and s["valid"] is False  # placeholder essay is under budget
    (ref.work_dir / "audit.1.json").write_text(json.dumps({"passage": "2:4", "verdicts": [], "uncited": [], "coverage": "x"}), encoding="utf-8")
    s = status.state(ref)
    assert s["attempts"] == 1


def test_next_lists_passages_not_yet_passed(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    refs = status.next_passages(surah=2, count=2)
    assert [r.id for r in refs] == ["2:1", "2:2"]
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_status.py -q`
Expected: FAIL with `ImportError`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/status.py
from __future__ import annotations

import json

from . import audit as audit_mod
from . import rukus
from . import validate as validate_mod
from .rukus import PassageRef


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def state(ref: PassageRef) -> dict:
    d = ref.work_dir
    out = {"id": ref.id, "range": [ref.start, ref.end], "stage": "new", "valid": None,
           "attempts": 0, "audit": None, "titles": False}
    if not (d / "sources.json").exists():
        return out
    out["stage"] = "gathered"
    if not (d / "draft.json").exists():
        return out
    out["stage"] = "drafted"
    draft = _read(d / "draft.json")
    errs = validate_mod.validate_draft(draft, _read(d / "sources.json"), _read(d / "verses.json"))
    out["valid"] = not errs
    latest = audit_mod.latest(d)
    if latest:
        out["attempts"] = audit_mod.next_attempt(d) - 1
        aerrs, passed = audit_mod.check(_read(latest), draft)
        out["audit"] = "malformed" if aerrs else ("PASS" if passed else "FAIL")
        out["stage"] = "passed" if out["audit"] == "PASS" else "audited"
    titles = d.parent / "titles.json"
    if titles.exists():
        out["titles"] = bool(_read(titles).get(str(ref.index), {}).get("approved"))
    return out


def next_passages(surah: int | None, count: int) -> list[PassageRef]:
    refs = rukus.passages_for_surah(surah) if surah else rukus.all_passages()
    return [r for r in refs if state(r)["stage"] != "passed"][:count]
```

CLI:

```python
from . import status as status_mod


def cmd_status(args) -> int:
    refs = rukus.passages_for_surah(args.surah) if args.surah else rukus.all_passages()
    for r in refs:
        s = status_mod.state(r)
        if args.all or s["stage"] != "new":
            valid = "" if s["valid"] is None else (" valid" if s["valid"] else " INVALID")
            audit = f" audit {s['audit']} x{s['attempts']}" if s["audit"] else ""
            titles = " titles ok" if s["titles"] else ""
            print(f"{r.id:7s} {r.start:>3}-{r.end:<3} {s['stage']:9s}{valid}{audit}{titles}")
    return 0


def cmd_next(args) -> int:
    for r in status_mod.next_passages(args.surah, args.count):
        print(r.id)
    return 0
```

```python
    st = sub.add_parser("status", help="stage of every passage that has been touched")
    st.add_argument("--surah", type=int)
    st.add_argument("--all", action="store_true", help="include untouched passages")
    st.set_defaults(fn=cmd_status)
    nx = sub.add_parser("next", help="next passages that have not passed audit")
    nx.add_argument("--surah", type=int)
    nx.add_argument("--count", type=int, default=2)
    nx.set_defaults(fn=cmd_next)
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_status.py -q`
Expected: `2 passed`

Run: `.venv/bin/python scripts/passages.py status --surah 2`
Expected: one line for 2:4 showing its current stage.

**Step 5: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/status.py scripts/passage_pipeline/cli.py tests/passage_pipeline/test_status.py
git commit -m "passages: status and next commands"
```

---

### Task 10: Title review file

**Files:**
- Create: `scripts/passage_pipeline/titles.py`
- Modify: `scripts/passage_pipeline/cli.py`
- Create: `tests/passage_pipeline/test_titles.py`

`titles <surah>` writes `passages_work/<surah>/titles.json` from every draft in the surah, preserving edits and approvals already there. The user edits titles and headings and flips `approved` to true. `titles <surah> --apply` writes the edited values back into the drafts.

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_titles.py
import json
from pathlib import Path

from scripts.passage_pipeline import rukus, titles

FIX = Path(__file__).parent / "fixtures"


def seed(tmp_path, monkeypatch):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path)
    ref = rukus.passage(2, 4)
    ref.work_dir.mkdir(parents=True)
    (ref.work_dir / "draft.json").write_text((FIX / "draft_ok.json").read_text(encoding="utf-8"), encoding="utf-8")
    return ref


def test_collect_writes_review_file(tmp_path, monkeypatch):
    ref = seed(tmp_path, monkeypatch)
    path = titles.collect(2)
    doc = json.loads(path.read_text(encoding="utf-8"))
    assert doc["4"] == {"range": [30, 39], "title": "Adam and the angels",
                        "headings": {"34": "Iblis refuses"}, "approved": False}


def test_collect_preserves_existing_edits(tmp_path, monkeypatch):
    ref = seed(tmp_path, monkeypatch)
    titles.collect(2)
    path = ref.work_dir.parent / "titles.json"
    doc = json.loads(path.read_text(encoding="utf-8"))
    doc["4"]["title"] = "Adam, the angels and Iblis"
    doc["4"]["approved"] = True
    path.write_text(json.dumps(doc), encoding="utf-8")
    titles.collect(2)
    doc2 = json.loads(path.read_text(encoding="utf-8"))
    assert doc2["4"]["title"] == "Adam, the angels and Iblis" and doc2["4"]["approved"] is True


def test_apply_writes_back_into_drafts(tmp_path, monkeypatch):
    ref = seed(tmp_path, monkeypatch)
    path = titles.collect(2)
    doc = json.loads(path.read_text(encoding="utf-8"))
    doc["4"]["title"] = "Adam, the angels and Iblis"
    doc["4"]["headings"]["34"] = "The refusal of Iblis"
    doc["4"]["approved"] = True
    path.write_text(json.dumps(doc), encoding="utf-8")
    changed = titles.apply(2)
    assert changed == ["2:4"]
    draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    assert draft["title"]["en"] == "Adam, the angels and Iblis"
    assert draft["verses"][0]["heading"]["en"] == "The refusal of Iblis"
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_titles.py -q`
Expected: FAIL with `ImportError`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/titles.py
from __future__ import annotations

import json
from pathlib import Path

from . import rukus


def _review_path(surah: int) -> Path:
    return rukus.WORK_DIR / str(surah) / "titles.json"


def collect(surah: int) -> Path:
    path = _review_path(surah)
    existing = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
    doc: dict = {}
    for ref in rukus.passages_for_surah(surah):
        dpath = ref.work_dir / "draft.json"
        if not dpath.exists():
            continue
        draft = json.loads(dpath.read_text(encoding="utf-8"))
        key = str(ref.index)
        headings = {str(e["verse"]): (e.get("heading") or {}).get("en", "") for e in draft.get("verses") or []}
        prev = existing.get(key)
        if prev:
            doc[key] = {"range": [ref.start, ref.end], "title": prev["title"],
                        "headings": {**headings, **prev.get("headings", {})}, "approved": bool(prev.get("approved"))}
        else:
            doc[key] = {"range": [ref.start, ref.end], "title": draft["title"]["en"],
                        "headings": headings, "approved": False}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(doc, ensure_ascii=False, indent=2), encoding="utf-8")
    return path


def apply(surah: int) -> list[str]:
    doc = json.loads(_review_path(surah).read_text(encoding="utf-8"))
    changed: list[str] = []
    for ref in rukus.passages_for_surah(surah):
        row = doc.get(str(ref.index))
        dpath = ref.work_dir / "draft.json"
        if not row or not row.get("approved") or not dpath.exists():
            continue
        draft = json.loads(dpath.read_text(encoding="utf-8"))
        before = json.dumps(draft, sort_keys=True)
        draft["title"]["en"] = row["title"]
        for entry in draft.get("verses") or []:
            h = row["headings"].get(str(entry["verse"]))
            if h:
                entry["heading"] = {**(entry.get("heading") or {}), "en": h}
        after = json.dumps(draft, sort_keys=True)
        if before != after:
            dpath.write_text(json.dumps(draft, ensure_ascii=False, indent=2), encoding="utf-8")
        changed.append(ref.id)
    return changed
```

CLI:

```python
from . import titles as titles_mod


def cmd_titles(args) -> int:
    if args.apply:
        for pid in titles_mod.apply(args.surah):
            print(f"applied {pid}")
        return 0
    print(titles_mod.collect(args.surah))
    return 0
```

```python
    t = sub.add_parser("titles", help="write (or with --apply, apply) the per-surah title review file")
    t.add_argument("surah", type=int)
    t.add_argument("--apply", action="store_true")
    t.set_defaults(fn=cmd_titles)
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_titles.py -q`
Expected: `3 passed`

**Step 5: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/titles.py scripts/passage_pipeline/cli.py tests/passage_pipeline/test_titles.py
git commit -m "passages: title review file"
```

---

### Task 11: Assemble and extract-gems

**Files:**
- Create: `scripts/passage_pipeline/assemble.py`
- Modify: `scripts/passage_pipeline/cli.py`
- Create: `tests/passage_pipeline/test_assemble.py`

`assemble <surah>` merges every passage that has a PASS audit and an approved title into `Thaqalayn/Thaqalayn/Data/passages_<surah>.json`, joining the writer's excerpt and gloss onto the gathered source metadata, and dropping the full source text. `extract-gems <surah>` copies `quickOverview` from `tafsir_<surah>.json` into `gems_<surah>.json` so the old file can be deleted later without losing Gems.

**Step 1: Write the failing test**

```python
# tests/passage_pipeline/test_assemble.py
import json
from pathlib import Path

from scripts.passage_pipeline import assemble, rukus

FIX = Path(__file__).parent / "fixtures"


def seed_passed(tmp_path, monkeypatch, approved=True):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path / "work")
    monkeypatch.setattr(assemble, "DATA_DIR", tmp_path / "data")
    (tmp_path / "data").mkdir()
    ref = rukus.passage(2, 4)
    ref.work_dir.mkdir(parents=True)
    for src, dst in (("draft_ok.json", "draft.json"), ("sources_ok.json", "sources.json"), ("verses_ok.json", "verses.json")):
        (ref.work_dir / dst).write_text((FIX / src).read_text(encoding="utf-8"), encoding="utf-8")
    draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    draft["essay"]["en"] = ("Tabatabai reads the question as a request, not an objection [1]. " * 12).strip()
    draft["perspectives"]["en"] = ("Both honour, not worship [3]. Names and words differ. " * 7).strip()
    (ref.work_dir / "draft.json").write_text(json.dumps(draft, ensure_ascii=False), encoding="utf-8")
    verdicts = [{"target": t, "claim": "c", "verdict": "supported", "excerpt": "x", "note": ""}
                for t in ("essay[1]", "verses.34.narrations.n1", "perspectives[3]")]
    (ref.work_dir / "audit.1.json").write_text(json.dumps({"passage": "2:4", "verdicts": verdicts, "uncited": [],
                                                           "coverage": "ok", "summary": "ok"}), encoding="utf-8")
    (ref.work_dir.parent / "titles.json").write_text(json.dumps({"4": {"range": [30, 39], "title": "Adam and the angels",
                                                                        "headings": {"34": "Iblis refuses"}, "approved": approved}}), encoding="utf-8")
    return ref


def test_assemble_writes_passages_file(tmp_path, monkeypatch):
    ref = seed_passed(tmp_path, monkeypatch)
    written, skipped = assemble.assemble(2)
    assert written == ["2:4"] and skipped == []
    out = json.loads((tmp_path / "data" / "passages_2.json").read_text(encoding="utf-8"))
    p = out["4"]
    assert p["id"] == "2:4" and p["range"] == [30, 39]
    assert p["title"]["en"] == "Adam and the angels"
    s1 = next(s for s in p["sources"] if s["id"] == "s1")
    assert s1["work"] == "al-Mizan fi Tafsir al-Quran" and s1["tier"] == "B"
    assert s1["locus"] == "on Al-Baqara 30 to 33" and s1["url"].startswith("https://")
    assert s1["excerpt"]["text"].startswith("وهذا الكلام") and s1["gloss"]
    assert "text" not in s1 and "sha256" not in s1
    assert p["verses"][0]["narrations"][0]["source"] == "s2"
    assert p["status"]["audit_attempts"] == 1


def test_assemble_skips_unapproved_titles(tmp_path, monkeypatch):
    seed_passed(tmp_path, monkeypatch, approved=False)
    written, skipped = assemble.assemble(2)
    assert written == [] and skipped == [("2:4", "titles not approved")]


def test_extract_gems(tmp_path, monkeypatch):
    monkeypatch.setattr(assemble, "DATA_DIR", tmp_path)
    (tmp_path / "tafsir_2.json").write_text(json.dumps({"30": {"layer1": "x", "quickOverview": {"concepts": []}},
                                                         "31": {"layer1": "y"}}), encoding="utf-8")
    n = assemble.extract_gems(2)
    assert n == 1
    gems = json.loads((tmp_path / "gems_2.json").read_text(encoding="utf-8"))
    assert gems == {"30": {"concepts": []}}
```

**Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_assemble.py -q`
Expected: FAIL with `ImportError`

**Step 3: Write minimal implementation**

```python
# scripts/passage_pipeline/assemble.py
"""Stage 6: merge passed drafts into the app data file."""
from __future__ import annotations

import json
from datetime import datetime, timezone

from . import audit as audit_mod
from . import rukus
from . import status as status_mod

DATA_DIR = rukus.DATA_DIR
SOURCE_PUBLIC_FIELDS = ("id", "kind", "work", "author", "tradition", "tier", "locus", "url", "grades")


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def build_record(ref: rukus.PassageRef) -> dict:
    d = ref.work_dir
    draft, gathered = _read(d / "draft.json"), _read(d / "sources.json")
    by_id = {s["id"]: s for s in gathered["sources"]}
    merged_sources = []
    for s in draft["sources"]:
        g = by_id[s["id"]]
        rec = {k: g[k] for k in SOURCE_PUBLIC_FIELDS if k in g}
        rec["excerpt"] = s.get("excerpt")
        rec["gloss"] = s.get("gloss")
        merged_sources.append(rec)
    latest = audit_mod.latest(d)
    return {
        "id": ref.id, "surah": ref.surah, "index": ref.index, "range": [ref.start, ref.end],
        "title": draft["title"], "essay": draft["essay"], "verses": draft.get("verses") or [],
        "perspectives": draft.get("perspectives"), "sources": merged_sources,
        "status": {"gathered_at": gathered.get("gathered_at"),
                   "audit_attempts": audit_mod.next_attempt(d) - 1,
                   "audited_at": datetime.fromtimestamp(latest.stat().st_mtime, timezone.utc).isoformat() if latest else None,
                   "assembled_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")},
    }


def assemble(surah: int) -> tuple[list[str], list[tuple[str, str]]]:
    out_path = DATA_DIR / f"passages_{surah}.json"
    existing = _read(out_path) if out_path.exists() else {}
    written, skipped = [], []
    for ref in rukus.passages_for_surah(surah):
        s = status_mod.state(ref)
        if s["stage"] == "new":
            continue
        if s["stage"] != "passed":
            skipped.append((ref.id, f"stage {s['stage']}"))
            continue
        if not s["valid"]:
            skipped.append((ref.id, "draft invalid"))
            continue
        if not s["titles"]:
            skipped.append((ref.id, "titles not approved"))
            continue
        existing[str(ref.index)] = build_record(ref)
        written.append(ref.id)
    if written:
        ordered = {k: existing[k] for k in sorted(existing, key=int)}
        out_path.write_text(json.dumps(ordered, ensure_ascii=False, indent=2), encoding="utf-8")
    return written, skipped


def extract_gems(surah: int) -> int:
    src = DATA_DIR / f"tafsir_{surah}.json"
    tafsir = _read(src)
    gems = {k: v["quickOverview"] for k, v in tafsir.items() if isinstance(v, dict) and v.get("quickOverview")}
    (DATA_DIR / f"gems_{surah}.json").write_text(json.dumps(gems, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(gems)
```

CLI:

```python
from . import assemble as assemble_mod


def cmd_assemble(args) -> int:
    written, skipped = assemble_mod.assemble(args.surah)
    for pid in written:
        print(f"assembled {pid}")
    for pid, why in skipped:
        print(f"skipped   {pid}: {why}")
    return 0 if written or not skipped else 1


def cmd_extract_gems(args) -> int:
    print(f"gems_{args.surah}.json: {assemble_mod.extract_gems(args.surah)} verses")
    return 0
```

```python
    a = sub.add_parser("assemble", help="merge passed, title-approved passages into Data/passages_<surah>.json")
    a.add_argument("surah", type=int)
    a.set_defaults(fn=cmd_assemble)
    eg = sub.add_parser("extract-gems", help="copy quickOverview from tafsir_<surah>.json into gems_<surah>.json")
    eg.add_argument("surah", type=int)
    eg.set_defaults(fn=cmd_extract_gems)
```

**Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/passage_pipeline -q`
Expected: all passing, network test skipped.

**Step 5: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/assemble.py scripts/passage_pipeline/cli.py tests/passage_pipeline/test_assemble.py
git commit -m "passages: assemble and extract-gems"
```

---

### Task 12: Metrics and the pilot runbook

**Files:**
- Create: `scripts/passage_pipeline/metrics.py`
- Modify: `scripts/passage_pipeline/cli.py`
- Create: `docs/plans/2026-09-05-passage-pilot-runbook.md`

**Step 1: Write metrics (no test beyond a smoke run; it only reads state)**

```python
# scripts/passage_pipeline/metrics.py
from __future__ import annotations

import json
from datetime import datetime

from . import audit as audit_mod
from . import rukus
from . import status as status_mod


def rows(surah: int) -> list[dict]:
    out = []
    for ref in rukus.passages_for_surah(surah):
        s = status_mod.state(ref)
        if s["stage"] == "new":
            continue
        d = ref.work_dir
        first = d / "audit.1.json"
        first_pass = None
        if first.exists():
            draft = json.loads((d / "draft.json").read_text(encoding="utf-8"))
            errs, passed = audit_mod.check(json.loads(first.read_text(encoding="utf-8")), draft)
            first_pass = passed and not errs
        gathered = json.loads((d / "sources.json").read_text(encoding="utf-8")).get("gathered_at")
        latest = audit_mod.latest(d)
        hours = None
        if gathered and latest:
            t0 = datetime.fromisoformat(gathered.replace("Z", "+00:00"))
            t1 = datetime.fromtimestamp(latest.stat().st_mtime, t0.tzinfo)
            hours = round((t1 - t0).total_seconds() / 3600, 1)
        out.append({"id": ref.id, "stage": s["stage"], "attempts": s["attempts"],
                    "first_pass": first_pass, "hours": hours, "sources": len(json.loads((d / "sources.json").read_text(encoding="utf-8"))["sources"])})
    return out
```

CLI:

```python
from . import metrics as metrics_mod


def cmd_metrics(args) -> int:
    rs = metrics_mod.rows(args.surah)
    print(f"{'passage':8s} {'stage':9s} {'attempts':>8s} {'first':>6s} {'hours':>6s} {'sources':>8s}")
    for r in rs:
        print(f"{r['id']:8s} {r['stage']:9s} {r['attempts']:>8d} {str(r['first_pass']):>6s} {str(r['hours']):>6s} {r['sources']:>8d}")
    done = [r for r in rs if r["stage"] == "passed"]
    if done:
        print(f"\n{len(done)} passed, first-try {sum(1 for r in done if r['first_pass'])}/{len(done)}, "
              f"mean attempts {sum(r['attempts'] for r in done) / len(done):.1f}")
    return 0
```

```python
    m = sub.add_parser("metrics", help="pilot numbers per passage")
    m.add_argument("surah", type=int)
    m.set_defaults(fn=cmd_metrics)
```

**Step 2: Write the runbook**

```markdown
# Passage Pilot Runbook - al-Baqarah 2:1 to 2:5

Gate to batch: all five pass audit with a mean of at most 1.5 attempts, and you are
happy with the drafts as a reader.

## Per passage

1. `passages.py gather 2:N` (main session, once). Check `unavailable` in the output; a
   missing al-Mizan or al-Burhan block is worth a retry.
2. Launch `passage-writer` with `Write passage 2:N`. At most two agents at a time.
3. `passages.py validate 2:N` must print valid (the hook already enforced it).
4. Launch `passage-auditor` with `Audit passage 2:N`.
5. `passages.py audit-check 2:N`. On FAIL, launch `passage-writer` with
   `Rewrite passage 2:N; read the latest audit first`, then audit again. Third FAIL:
   stop and read the audit yourself; the fix is in the prompts, not in the loop.
6. `passages.py status --surah 2` to see where everything stands.

## Per surah

7. `passages.py titles 2`, edit `passages_work/2/titles.json`, set `approved: true`
   per passage, then `passages.py titles 2 --apply`.
8. `passages.py assemble 2` writes `Thaqalayn/Thaqalayn/Data/passages_2.json`.
9. `passages.py metrics 2` for the gate numbers.

## What to read for, as a reader

- Does the essay tell the passage once, in order, in a voice you would put your name to?
- Are the narrations the ones that interpret the verse, or filler that merely quotes it?
- Is anything cited that a reader tapping the source sheet would not find?
- Is Perspectives present only where the traditions genuinely differ?

Adjust the "How to write" section of `passage-writer.md` for taste problems.
Adjust `validate.py` only for rules that should be mechanical.
```

**Step 3: Run the pilot**

Follow the runbook for 2:1 through 2:5. Waves of two agents. Record the `metrics` output at the end in the runbook under a "Results" heading.

**Step 4: Commit**

Ask first. Then:

```bash
git add scripts/passage_pipeline/metrics.py scripts/passage_pipeline/cli.py docs/plans/2026-09-05-passage-pilot-runbook.md
git commit -m "passages: metrics and pilot runbook"
```

Pilot output (`Thaqalayn/Thaqalayn/Data/passages_2.json`) is committed separately, once you have read it and approved it, as its own commit.

---

## After the pilot

- Write the app reader plan against the real `passages_2.json`.
- Adapt the Urdu and Arabic translators to the passage schema (title, essay, headings, notes, narration text, perspectives, gloss), preserving markers.
- Delete `scripts/citation_audit.py` once nothing imports from it.
- Batch order from the design doc: al-Fatihah, Yasin, al-Kahf, al-Mulk, juz 30, al-Rahman, al-Waqi'ah, al-Baqarah, Al Imran, then sequential.
