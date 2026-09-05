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
        "bookNameOriginal": "Al-Kāfi", "authorName": "al-Kulaynī", "volumeNumber": 2,
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
