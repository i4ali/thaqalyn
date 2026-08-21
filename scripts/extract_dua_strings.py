"""Gather every Arabic string that reaches a DuaListenButton, from the same
sources the app compiles/loads.

Sources:
  - daily_duas.json               -> duas[].arabic
  - <journey>_journey.json        -> days[].dua.arabic (+ days[].dua.fullArabic,
                                     e.g. the full Ziyarat Arbaeen)
  - Content/*DeepDive.swift       -> .dua(... arabic: "…")
  - Content/SurahRahmanDive.swift -> replyArabic: "…" (al-Rahman refrain)

Verses, theme labels (themeArabic), and situation headings are deliberately excluded.
Returns list[dict(source, arabic)], deduped by exact string, order-stable.
"""
import json
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "Thaqalayn", "Data")
CONTENT = os.path.join(ROOT, "Thaqalayn", "Content")

_JOURNEYS = ["muharram", "hajj", "ramadan", "fatimiyya", "arbaeen"]


def from_json():
    out = []
    d = json.load(open(os.path.join(DATA, "daily_duas.json")))
    for x in d["duas"]:
        if x.get("arabic"):
            out.append({"source": f"daily_duas#{x['id']}", "arabic": x["arabic"]})
    for j in _JOURNEYS:
        d = json.load(open(os.path.join(DATA, f"{j}_journey.json")))
        for i, day in enumerate(d.get("days", [])):
            dua = day.get("dua") or {}
            if isinstance(dua, dict):
                if dua.get("arabic"):
                    out.append({"source": f"{j}#day{i}", "arabic": dua["arabic"]})
                if dua.get("fullArabic"):
                    out.append({"source": f"{j}#day{i}.full", "arabic": dua["fullArabic"]})
            if day.get("fullArabic"):
                out.append({"source": f"{j}#day{i}.dayfull", "arabic": day["fullArabic"]})
    return out


def from_swift():
    out = []
    for path in sorted(glob.glob(os.path.join(CONTENT, "*.swift"))):
        text = open(path).read()
        name = os.path.basename(path)
        for m in re.finditer(r'replyArabic:\s*"([^"\\]+)"', text):
            out.append({"source": f"{name}:replyArabic", "arabic": m.group(1)})
        for dm in re.finditer(r'\.dua\(', text):
            seg = text[dm.end(): dm.end() + 4000]
            am = re.search(r'arabic:\s*"([^"\\]+)"', seg)
            if am:
                out.append({"source": f"{name}:dua.arabic", "arabic": am.group(1)})
    return out


def gather():
    seen, items = set(), []
    for it in from_json() + from_swift():
        ar = it["arabic"]
        if ar and ar.strip() and ar not in seen:
            seen.add(ar)
            items.append(it)
    return items


if __name__ == "__main__":
    items = gather()
    total = sum(len(i["arabic"]) for i in items)
    print(f"{len(items)} unique strings, {total} chars\n")
    for i in items:
        print(f"  {len(i['arabic']):>4}  {i['source']}")
