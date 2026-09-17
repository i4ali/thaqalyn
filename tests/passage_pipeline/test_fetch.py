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


LONG = "وليس من الاعتراض والخصومة في شيء " * 6


def _altafsir_page(body: str, links: list[int], tafsir: int = 56) -> str:
    pager = "".join(f"<A HREF=Javascript:InnerLink_onchange({tafsir},{n},1)><u>{n}</u></A>" for n in links)
    return f"<html><body><div id=SearchResults>{body}<center>{pager}</center></div></body></html>"


def test_extract_results_block_sees_the_javascript_pager():
    src = _altafsir_page("{ x } " + LONG, links=[2, 3])
    _, more = fetch.extract_results_block(src, page=1)
    assert more is True
    # On the last page the links point back at earlier pages only.
    _, more = fetch.extract_results_block(_altafsir_page("{ x } " + LONG, links=[1, 2]), page=3)
    assert more is False


def test_fetch_altafsir_walks_javascript_pages_and_drops_repeated_verse_header():
    pages = {
        1: _altafsir_page("{ قُلْ مَن يَرْزُقُكُم } * { أَمَّن يَمْلِكُ }<br>" + LONG + "الصفحة الأولى", links=[2, 3]),
        2: _altafsir_page("{ قُلْ مَن يَرْزُقُكُم } * { أَمَّن يَمْلِكُ }<br>" + LONG + "الصفحة الثانية", links=[1, 3]),
        3: _altafsir_page("{ قُلْ مَن يَرْزُقُكُم } * { أَمَّن يَمْلِكُ }<br>" + LONG + "الصفحة الثالثة", links=[1, 2]),
    }

    def fake_get(url, timeout=45):
        n = int(url.rsplit("Page=", 1)[1])
        return 200, "text/html; charset=windows-1256", pages[n].encode("cp1256", errors="replace")

    block = fetch.fetch_altafsir("mizan", 10, 36, get=fake_get)
    assert block is not None and block.pages == 3
    assert block.text.count("{ قُلْ مَن يَرْزُقُكُم }") == 1
    assert "الصفحة الثالثة" in block.text


def test_fetch_altafsir_retries_one_dropped_page_mid_walk():
    calls = []
    good = _altafsir_page("{ x }<br>" + LONG, links=[2])
    last = _altafsir_page("{ x }<br>" + LONG + "النهاية", links=[1])

    def fake_get(url, timeout=45):
        calls.append(url)
        if url.endswith("Page=2") and calls.count(url) == 1:
            return 200, "text/html", b"<html><body>empty</body></html>"
        return 200, "text/html; charset=windows-1256", (good if url.endswith("Page=1") else last).encode("cp1256")

    block = fetch.fetch_altafsir("mizan", 10, 36, get=fake_get)
    assert block is not None and block.pages == 2 and "النهاية" in block.text


GT_PAGE = (
    "<html><body>"
    '<select name="ctl00$ContentPlaceHolder1$ddlTafsir" id="ctl00_ContentPlaceHolder1_ddlTafsir">'
    '<option value="3">مجمع البيان</option><option selected="selected" value="56">الميزان</option></select>'
    '<div id="ctl00_ContentPlaceHolder1_UpdatePanel1" class="AyaContainer">'
    "<div>وَمَا كَانَ هَـٰذَا ٱلْقُرْآنُ أَن يُفْتَرَىٰ ٣٧</div><div>أَمْ يَقُولُونَ ٱفْتَرَاهُ ٣٨</div></div>"
    '<div id="ctl00_ContentPlaceHolder1_UpdatePanel2" class="contentContainer">'
    "<div>أضف للمقارنة</div><div>الميزان في تفسير القرآن</div><div>(بيان)</div>"
    "<div>رجوع إلى أمر القرآن وأنه كتاب منزل من عند الله لا ريب فيه وتلقين الحجة في ذلك " + LONG + "</div>"
    "<div>x</div><div>x</div><div>1</div></div>"
    '<div id="ctl00_ContentPlaceHolder1_UpdatePanel4"></div>'
    "</body></html>"
)


def test_greattafsirs_url_and_block_shape():
    assert fetch.greattafsirs_url(56, 10, 41) == (
        "https://www.greattafsirs.com/Tafsir_Library.aspx?MadhabNo=0&TafsirNo=56&SoraNo=10&AyahNo=41&LanguageID=1"
    )
    text = fetch.extract_greattafsirs_block(GT_PAGE, 56)
    lines = text.split("\n")
    assert lines[0] == "{ وَمَا كَانَ هَـٰذَا ٱلْقُرْآنُ أَن يُفْتَرَىٰ } * { أَمْ يَقُولُونَ ٱفْتَرَاهُ }"
    assert lines[1] == "(بيان)"
    assert "أضف للمقارنة" not in text and not text.endswith("1") and not text.endswith("x")


def test_greattafsirs_rejects_the_silent_majma_substitution():
    src = GT_PAGE.replace('<option selected="selected" value="56">', '<option value="56">').replace(
        '<option value="3">', '<option selected="selected" value="3">')
    assert fetch.extract_greattafsirs_block(src, 56) is None
    assert fetch.extract_greattafsirs_block(src, 3) is not None


def test_fetch_altafsir_falls_back_to_greattafsirs_on_server_error():
    def fake_get(url, timeout=45):
        if "altafsir.com" in url:
            return 500, "text/html", b"<html>500 - Internal server error.</html>"
        return 200, "text/html; charset=utf-8", GT_PAGE.encode("utf-8")

    block = fetch.fetch_altafsir("mizan", 10, 41, get=fake_get)
    assert block is not None
    assert "greattafsirs.com" in block.url and block.pages == 1
    assert block.text.startswith("{ وَمَا كَانَ")
    assert fetch.fetch_altafsir("mizan", 10, 41, get=fake_get, fallback=False) is None


def test_fetch_altafsir_falls_back_to_greattafsirs_when_curl_fails():
    def fake_get(url, timeout=45):
        if "altafsir.com" in url:
            raise RuntimeError(f"curl failed for {url}: curl: (28) Operation timed out")
        return 200, "text/html; charset=utf-8", GT_PAGE.encode("utf-8")

    block = fetch.fetch_altafsir("mizan", 13, 27, get=fake_get)
    assert block is not None and "greattafsirs.com" in block.url

    def both_fail(url, timeout=45):
        raise RuntimeError(f"curl failed for {url}: curl: (28) Operation timed out")

    assert fetch.fetch_altafsir("mizan", 13, 27, get=both_fail) is None
    assert fetch.fetch_greattafsirs("mizan", 13, 27, get=both_fail) is None


def test_fetch_altafsir_incomplete_walk_prefers_the_whole_greattafsirs_block():
    page1 = _altafsir_page("{ x }<br>" + LONG + "الصفحة الأولى", links=[2, 3, 4])

    def fake_get(url, timeout=45):
        if "greattafsirs.com" in url:
            return 200, "text/html; charset=utf-8", GT_PAGE.encode("utf-8")
        if url.endswith("Page=1"):
            return 200, "text/html; charset=windows-1256", page1.encode("cp1256", errors="replace")
        return 500, "text/html", b"<html>500</html>"

    block = fetch.fetch_altafsir("mizan", 10, 36, get=fake_get)
    assert "greattafsirs.com" in block.url
    partial = fetch.fetch_altafsir("mizan", 10, 36, get=fake_get, fallback=False)
    assert partial is not None and partial.partial is True and partial.pages == 1
    assert fetch.pager_last_page(page1) == 4


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
