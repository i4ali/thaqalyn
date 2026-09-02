#!/usr/bin/env python3
"""8.4 release helpers on top of asc.py.

  asc_release.py create-version            -> creates appStoreVersion 8.4 (or prints existing)
  asc_release.py sets <versionId>          -> lists screenshot sets (per locale) with display types
  asc_release.py upload <setId> <png>...   -> appends screenshots to a set
  asc_release.py whatsnew <versionId>      -> sets What's New on every localization
  asc_release.py attach <versionId> <buildId>
"""
import hashlib, json, os, sys, time, urllib.request
sys.path.insert(0, os.path.dirname(__file__))
from asc import req, get, app_id

VERSION = os.environ.get("ASC_VERSION", "8.5")


def create_version():
    aid = app_id()
    existing = get(f"/v1/apps/{aid}/appStoreVersions", **{"filter[versionString]": VERSION})["data"]
    if existing:
        print("exists", existing[0]["id"], existing[0]["attributes"]["appVersionState"]); return existing[0]["id"]
    r = req("POST", "/v1/appStoreVersions", {"data": {"type": "appStoreVersions",
            "attributes": {"platform": "IOS", "versionString": VERSION},
            "relationships": {"app": {"data": {"type": "apps", "id": aid}}}}})
    print("created", r["data"]["id"]); return r["data"]["id"]


def sets(version_id):
    locs = get(f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations", **{"fields[appStoreVersionLocalizations]": "locale", "limit": 50})["data"]
    out = []
    for loc in locs:
        ss = get(f"/v1/appStoreVersionLocalizations/{loc['id']}/appScreenshotSets",
                 **{"fields[appScreenshotSets]": "screenshotDisplayType", "include": "appScreenshots", "fields[appScreenshots]": "fileName", "limit": 50})
        for s in ss["data"]:
            n = len(s.get("relationships", {}).get("appScreenshots", {}).get("data", []))
            out.append((loc["attributes"]["locale"], s["attributes"]["screenshotDisplayType"], s["id"], n))
            print(loc["attributes"]["locale"], s["attributes"]["screenshotDisplayType"], s["id"], "count", n)
    return out


def upload(set_id, path):
    data = open(path, "rb").read()
    name = os.path.basename(path)
    r = req("POST", "/v1/appScreenshots", {"data": {"type": "appScreenshots",
            "attributes": {"fileName": name, "fileSize": len(data)},
            "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}}}})
    sid = r["data"]["id"]
    for op in r["data"]["attributes"]["uploadOperations"]:
        chunk = data[op["offset"]: op["offset"] + op["length"]]
        rq = urllib.request.Request(op["url"], data=chunk, method=op["method"],
                                    headers={h["name"]: h["value"] for h in op["requestHeaders"]})
        with urllib.request.urlopen(rq) as resp:
            resp.read()
    req("PATCH", f"/v1/appScreenshots/{sid}", {"data": {"type": "appScreenshots", "id": sid,
        "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
    # wait for processing
    for _ in range(40):
        st = get(f"/v1/appScreenshots/{sid}", **{"fields[appScreenshots]": "assetDeliveryState,fileName"})["data"]["attributes"]["assetDeliveryState"]["state"]
        if st == "COMPLETE": break
        if st == "FAILED": raise SystemExit(f"screenshot {name} failed: {st}")
        time.sleep(3)
    print("uploaded", name, "->", sid, st)
    return sid


# 8.5 (build 106): Qarai translation swap + Surah al-Nahl. Keyed by language code; a
# store locale (en-US, es-MX, ar-SA, hi, ur-PK, fr-FR ...) matches on its language prefix.
NOTES = {
    "en": "New: the Quran's English translation is now Ali Quli Qarai's phrase-by-phrase Shia translation, replacing Sahih International, across the reader, daily verse, search, and widget. New Inside the Surah journey: Surah al-Nahl, the Surah of Blessings.",
    "es": "Nuevo: la traducción al inglés del Corán ahora es la traducción chií frase por frase de Ali Quli Qarai, que reemplaza a Sahih International, en el lector, el versículo diario, la búsqueda y el widget. Nuevo recorrido Inside the Surah: Sura an-Nahl, la Sura de las Bendiciones.",
    "fr": "Nouveau : la traduction anglaise du Coran est désormais la traduction chiite phrase par phrase d'Ali Quli Qarai, qui remplace Sahih International, dans le lecteur, le verset du jour, la recherche et le widget. Nouveau parcours Inside the Surah : Sourate an-Nahl, la sourate des Bienfaits.",
    "ar": "جديد: أصبحت الترجمة الإنجليزية للقرآن الآن ترجمة علي قلي قرائي الشيعية عبارةً بعبارة، بدلاً من ترجمة صحيح إنترناشيونال، في القارئ والآية اليومية والبحث والودجت. رحلة جديدة داخل السورة: سورة النحل، سورة النعم.",
    "ur": "نیا: قرآن کا انگریزی ترجمہ اب علی قلی قرائی کا فقرہ بہ فقرہ شیعہ ترجمہ ہے، جو صحیح انٹرنیشنل کی جگہ لے چکا ہے، ریڈر، روزانہ کی آیت، تلاش اور ویجٹ میں۔ سورہ کے اندر کا نیا سفر: سورۃ النحل، نعمتوں کی سورت۔",
    "hi": "नया: क़ुरआन का अंग्रेज़ी अनुवाद अब अली क़ुली क़राई का वाक्यांश-दर-वाक्यांश शिया अनुवाद है, जो सहीह इंटरनेशनल की जगह लेता है, रीडर, दैनिक आयत, खोज और विजेट में। नई Inside the Surah यात्रा: सूरह अन-नहल, नेमतों की सूरह।",
}


def whatsnew(version_id):
    locs = get(f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations", **{"fields[appStoreVersionLocalizations]": "locale,whatsNew", "limit": 50})["data"]
    for loc in locs:
        locale = loc["attributes"]["locale"]
        text = NOTES.get(locale) or NOTES.get(locale.split("-")[0].lower(), NOTES["en"])
        req("PATCH", f"/v1/appStoreVersionLocalizations/{loc['id']}", {"data": {"type": "appStoreVersionLocalizations", "id": loc["id"], "attributes": {"whatsNew": text}}})
        print("whatsNew set", locale)


def attach(version_id, build_id):
    req("PATCH", f"/v1/appStoreVersions/{version_id}/relationships/build", {"data": {"type": "builds", "id": build_id}})
    print("attached build", build_id, "to", version_id)


if __name__ == "__main__":
    cmd, args = sys.argv[1], sys.argv[2:]
    {"create-version": lambda: create_version(),
     "sets": lambda: sets(args[0]),
     "upload": lambda: [upload(args[0], p) for p in args[1:]],
     "whatsnew": lambda: whatsnew(args[0]),
     "attach": lambda: attach(args[0], args[1])}[cmd]()
