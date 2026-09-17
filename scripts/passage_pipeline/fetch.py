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

from scripts import strip_diacritics

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)


def curl_get(url: str, timeout: int = 45) -> tuple[int, str, bytes]:
    """GET a URL with a browser user agent. Returns (status, content_type, body)."""
    fd, tmp = tempfile.mkstemp(prefix="citation_fetch_", suffix=".bin")
    os.close(fd)
    try:
        proc = subprocess.run(
            [
                "curl", "-sS", "-L", "--compressed", "--max-time", str(timeout),
                "-A", BROWSER_UA,
                "-H", "Accept: text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8",
                "-H", "Accept-Language: en-US,en;q=0.9,ar;q=0.8",
                "-o", tmp, "-w", "%{http_code}\t%{content_type}", url,
            ],
            capture_output=True, text=True,
        )
        if proc.returncode != 0:
            raise RuntimeError(f"curl failed for {url}: {proc.stderr.strip() or 'exit ' + str(proc.returncode)}")
        code, _, ctype = proc.stdout.partition("\t")
        body = Path(tmp).read_bytes()
    finally:
        try:
            os.unlink(tmp)
        except OSError:
            pass
    return int(code or 0), ctype.strip(), body


def decode_body(body: bytes, content_type: str, forced: str | None = None) -> str:
    candidates: list[str] = []
    if forced:
        candidates.append(forced)
    m = re.search(r"charset=([\w-]+)", content_type or "", re.I)
    if m:
        candidates.append(m.group(1))
    head = body[:6000].decode("ascii", errors="ignore")
    m = re.search(r"charset=[\"']?([\w-]+)", head, re.I)
    if m:
        candidates.append(m.group(1))
    candidates.append("utf-8")
    for enc in candidates:
        try:
            return body.decode(enc)
        except (UnicodeDecodeError, LookupError):
            continue
    # Legacy Arabic sites (altafsir.com) serve Windows-1256 without declaring it.
    return body.decode("cp1256", errors="replace")


def html_to_text(src: str) -> str:
    s = re.sub(r"(?is)<(script|style|noscript|svg|head|nav|footer)\b.*?</\1>", " ", src)
    s = re.sub(r"(?is)<!--.*?-->", " ", s)
    s = re.sub(r"(?i)<br\s*/?>", "\n", s)
    s = re.sub(r"(?i)</(p|div|li|tr|h[1-6]|blockquote|section|article|td|th|dd|dt|pre|option)>", "\n", s)
    s = re.sub(r"<[^>]+>", " ", s)
    s = html_lib.unescape(s)
    lines = [re.sub(r"[ \t\xa0]+", " ", ln).strip() for ln in s.splitlines()]
    return "\n".join(ln for ln in lines if ln)


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
    partial: bool = False   # the pager promised more pages than the site served


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
    # altafsir has used two pagers: plain links carrying Page=N, and (since at
    # least 2026-09) JavaScript links InnerLink_onchange(<tafsir>,<page>,<lang>).
    # Only the pages not currently shown are linked, so page+1 present means more.
    has_more = bool(re.search(rf"Page={page + 1}\b", seg)) or bool(
        re.search(rf"InnerLink_onchange\(\d+,{page + 1},\d+\)", seg))
    return seg, has_more


def pager_last_page(seg: str) -> int:
    """The highest page number the block's pager links to (1 when there is none)."""
    nums = [int(n) for n in re.findall(r"Page=(\d+)\b", seg)]
    nums += [int(n) for n in re.findall(r"InnerLink_onchange\(\d+,(\d+),\d+\)", seg)]
    return max(nums, default=1)


def clean_block_text(segment_html: str) -> str:
    text = html_to_text(segment_html)
    lines = text.split("\n")
    for i, ln in enumerate(lines):
        if "{" in ln or len(ln) > 120:
            lines = lines[i:]
            break
    return "\n".join(lines).strip()


def strip_verse_header(text: str) -> str:
    """Pages 2 and later of an altafsir block repeat the verse group at the top
    ("{ ... } * { ... }"); drop those leading lines so the joined block carries
    the verses once."""
    lines = text.split("\n")
    i = 0
    while i < len(lines) and lines[i].lstrip().startswith("{"):
        i += 1
    return "\n".join(lines[i:]).strip()


def fetch_altafsir(key: str, surah: int, verse: int, *, get: Getter | None = None,
                   fallback: bool = True) -> FetchedBlock | None:
    """The block for one work and one verse, walking every page altafsir shows.
    When altafsir has no block (a server error, or an empty page) and fallback
    is on, the same work is asked of greattafsirs.com, which serves the same
    numbered tafsirs from the same publisher."""
    get = get or curl_get
    tafsir_id, lang, _ = ALTAFSIR_TAFSIRS[key]
    parts: list[str] = []
    first_url = altafsir_url(tafsir_id, lang, surah, verse, 1)
    page = 1
    retried = False
    promised = 1
    while page <= MAX_PAGES:
        url = altafsir_url(tafsir_id, lang, surah, verse, page)
        try:
            code, ctype, body = get(url, timeout=45)
        except RuntimeError:
            # curl gave up (altafsir hanging past its deadline); the same as
            # a server error, so the fallback below still gets its turn.
            code, ctype, body = 0, "", b""
        seg, has_more = (None, False)
        if code == 200:
            src = decode_body(body, ctype, "cp1256" if lang == 1 else None)
            seg, has_more = extract_results_block(src, page)
        if seg is None:
            # altafsir drops a page now and then in the middle of a walk; ask
            # once more before giving up on the rest of the block.
            if page > 1 and not retried:
                retried = True
                continue
            break
        retried = False
        promised = max(promised, pager_last_page(seg))
        text = clean_block_text(seg)
        parts.append(strip_verse_header(text) if page > 1 else text)
        if not has_more:
            break
        page += 1
    text = "\n".join(p for p in parts if p).strip()
    partial = len(parts) < promised
    block = FetchedBlock(key, surah, verse, first_url, text, len(parts), partial) if len(text) >= 80 else None
    if fallback and lang == 1 and (block is None or partial):
        # altafsir answers 500 for whole blocks and for the tail pages of others
        # (Yunus 31 to 36: three of nine pages). greattafsirs serves the same
        # block whole; take it when it carries more than altafsir gave.
        other = fetch_greattafsirs(key, surah, verse, get=get)
        if other is not None and (block is None or len(other.text) > len(block.text)):
            return other
    return block


# ---- greattafsirs.com (same tafsir numbering as altafsir, one page per block) ---

GREATTAFSIRS_SELECT_RE = re.compile(
    r'id="ctl00_ContentPlaceHolder1_ddlTafsir"[^>]*>(.*?)</select>', re.S)
GREATTAFSIRS_SELECTED_RE = re.compile(r'<option\s+selected="selected"\s+value="(\d+)"')
GREATTAFSIRS_VERSES_RE = re.compile(
    r'class="AyaContainer"[^>]*>(.*?)<div id="ctl00_ContentPlaceHolder1_UpdatePanel2"', re.S)
GREATTAFSIRS_TEXT_RE = re.compile(
    r'id="ctl00_ContentPlaceHolder1_UpdatePanel2"[^>]*>(.*?)'
    r'<div id="ctl00_ContentPlaceHolder1_(?:UpdatePanel4|dvLabel)"', re.S)
ARABIC_INDIC_TAIL_RE = re.compile(r"\s*[\u0660-\u0669]+\s*$")
GREATTAFSIRS_CHROME_TAIL_RE = re.compile(r"^[\sxX0-9]*$")


def greattafsirs_url(tafsir_id: int, surah: int, verse: int) -> str:
    return (
        "https://www.greattafsirs.com/Tafsir_Library.aspx?MadhabNo=0"
        f"&TafsirNo={tafsir_id}&SoraNo={surah}&AyahNo={verse}&LanguageID=1"
    )


def extract_greattafsirs_block(src: str, tafsir_id: int) -> str | None:
    """The commentary shown on a greattafsirs page, in altafsir's shape: the
    verse group as "{ ... } * { ... }" on the first line, then the text. None
    when the page shows another work: the site silently falls back to Majma
    al-Bayan when the requested tafsir has no entry for the verse."""
    sel = GREATTAFSIRS_SELECT_RE.search(src)
    chosen = GREATTAFSIRS_SELECTED_RE.search(sel.group(1)) if sel else None
    if chosen is None or int(chosen.group(1)) != tafsir_id:
        return None
    m = GREATTAFSIRS_TEXT_RE.search(src)
    if m is None:
        return None
    lines = [ln for ln in html_to_text(m.group(1)).split("\n") if ln.strip()]
    # Leading chrome: the "add to comparison" control and the work's title.
    while lines and len(lines[0]) < 40 and not lines[0].startswith("("):
        lines.pop(0)
    # Trailing chrome: the tab strip renders as single letters and digits.
    while lines and GREATTAFSIRS_CHROME_TAIL_RE.match(lines[-1]):
        lines.pop()
    if not lines:
        return None
    vm = GREATTAFSIRS_VERSES_RE.search(src)
    verses = [ARABIC_INDIC_TAIL_RE.sub("", ln).strip()
              for ln in html_to_text(vm.group(1)).split("\n") if vm and ln.strip()]
    header = " * ".join("{ " + v + " }" for v in verses if v)
    return "\n".join(([header] if header else []) + lines).strip()


def fetch_greattafsirs(key: str, surah: int, verse: int, *, get: Getter | None = None) -> FetchedBlock | None:
    get = get or curl_get
    tafsir_id, lang, _ = ALTAFSIR_TAFSIRS[key]
    if lang != 1:
        return None
    url = greattafsirs_url(tafsir_id, surah, verse)
    try:
        code, ctype, body = get(url, timeout=60)
    except RuntimeError:
        return None
    if code != 200:
        return None
    text = extract_greattafsirs_block(decode_body(body, ctype), tafsir_id)
    if not text or len(text) < 80:
        return None
    return FetchedBlock(key, surah, verse, url, text, 1)


# ---- thaqalayn.com hadith corpus -------------------------------------------------

THAQALAYN_SEARCH_URL = "https://api.thaqalayn.com:8108/multi_search"
THAQALAYN_SEARCH_KEY = os.environ.get("THAQALAYN_TYPESENSE_KEY", "AmswDdjQNKm0xVNBLhUpkgjLj4JnNNbh")
# Quranic annotation signs (0610-061A), harakat and small marks (064B-065F),
# superscript alef (0670), small high marks (06D6-06ED) and tatweel (0640).
TASHKEEL_RE = re.compile(r"[ؐ-ًؚ-ٰٟۖ-ۭـ]")


def strip_tashkeel(text: str) -> str:
    text = unicodedata.normalize("NFKC", text)
    # The Uthmani text marks a long "a" with a superscript (dagger) alef where
    # standard orthography writes a full alef (ملٰئكة -> ملائكة). Map it before
    # stripping so the query matches hadith texts written in standard spelling.
    text = text.replace("ٰ", "ا")
    text = TASHKEEL_RE.sub("", text)
    return text.replace("ٱ", "ا").replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")


def hadith_query_from_arabic(arabic: str, words: int = 4) -> str:
    return " ".join(strip_tashkeel(arabic).split()[:words])


def plain_english(text: str) -> str:
    """House style for English-facing names: no macrons, under-dots or half rings."""
    return strip_diacritics.transform(text)


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
            # thaqalayn.com ships book and author names with transliteration
            # diacritics (Al-Kāfi); house style is plain spelling.
            "book": plain_english(d.get("bookNameOriginal") or d.get("bookName") or "?"),
            "author": plain_english(d.get("authorName") or ""),
            "volume": d.get("volumeNumber"),
            "chapter": d.get("chapterNumber"),
            "number": d.get("number"),
            "url": f"https://thaqalayn.com/book/{d.get('bookId', '')}",
            "text_en": d.get("textEn") or "",
            "text_ar": d.get("textArDisplay") or d.get("textAr") or "",
            "grades": d.get("gradesCanonical") or d.get("grades") or [],
        })
    return hits
