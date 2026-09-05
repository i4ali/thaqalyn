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
