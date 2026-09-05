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
        return [
            # quotes the verse: kept
            {"book": "Al-Kafi", "author": "al-Kulayni", "volume": 2, "chapter": 5, "number": 1028,
             "url": "https://thaqalayn.com/book/al-kafi", "text_en": "Three signs of a hypocrite",
             "text_ar": "قال في قوله تعالى وَإِذْ قُلْنَا لِلْمَلَائِكَةِ اسْجُدُوا: ثلاث علامات للمنافق",
             "grades": ["Sahih"]},
            # matched only on a common word: dropped
            {"book": "Al-Kafi", "author": "al-Kulayni", "volume": 1, "chapter": 1, "number": 7,
             "url": "https://thaqalayn.com/book/al-kafi", "text_en": "Unrelated maxim",
             "text_ar": "قال: جبلت القلوب على حب من أحسن إليها", "grades": []},
        ]
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
    assert result["corpus_hits_dropped"] == 1
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
