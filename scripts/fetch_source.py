#!/usr/bin/env python3
"""
fetch_source.py - pull the primary-source commentary on ONE verse so a citation
pass can check the app's tafsir paragraphs against what the books actually say.

Sources (all per-verse, deterministic URLs, Arabic full text) come from
altafsir.com, which hosts the classical Shia and Sunni tafsirs the commentary
names. The page body is windows-1256 HTML; this script decodes it, extracts the
tafsir body, strips tags and returns clean text, cached on disk so re-runs are
free.

Usage
    python3 scripts/fetch_source.py 1 1 mizan            # al-Mizan on 1:1
    python3 scripts/fetch_source.py 1 1 mizan majma      # several books
    python3 scripts/fetch_source.py 1 1 all              # every book we know
    python3 scripts/fetch_source.py 1 1 mizan --max 6000 # cap characters per book
    python3 scripts/fetch_source.py 1 4 majma --grep مالك ملك   # only paragraphs with these words
    python3 scripts/fetch_source.py --list               # book codes + URLs

Long entries are paginated on altafsir (Page=N&Size=1); every page is fetched
and joined, so al-Mizan on 1:1 comes back as its full 10-plus pages. Use --grep
with one or two Arabic keywords to pull just the paragraphs about the point you
are checking.

Output is plain text to stdout: one header line per book ("=== al-Mizan
(Tabatabai) 1:1  <url>") followed by the body. A book with no commentary on the
verse prints "(no text for this verse)" - many tafsirs comment on a run of
verses under the first one, so try the previous verse or two.
"""
import argparse
import hashlib
import html
import os
import re
import sys
import urllib.request

BASE = "https://www.altafsir.com/Tafasir.asp?tMadhNo={madh}&tTafsirNo={tid}&tSoraNo={s}&tAyahNo={v}&tDisplay=yes&LanguageID=1"

# code -> (altafsir id, madhhab id, display name, author)
BOOKS = {
    "mizan":     (56, 4, "al-Mizan fi Tafsir al-Qur'an", "Tabatabai"),
    "majma":     (3,  4, "Majma al-Bayan", "Tabrisi"),
    "qummi":     (38, 4, "Tafsir al-Qummi", "Ali ibn Ibrahim al-Qummi"),
    "tibyan":    (39, 4, "al-Tibyan", "Shaykh Tusi"),
    "tabari":    (1,  1, "Jami al-Bayan", "al-Tabari"),
    "kashshaf":  (2,  1, "al-Kashshaf", "al-Zamakhshari"),
    "razi":      (4,  1, "Mafatih al-Ghayb", "Fakhr al-Din al-Razi"),
    "qurtubi":   (5,  1, "al-Jami li-Ahkam al-Qur'an", "al-Qurtubi"),
    "ibnkathir": (7,  1, "Tafsir al-Qur'an al-Azim", "Ibn Kathir"),
}

CACHE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scratch", "source_cache")


def url_for(code: str, surah: int, verse: int) -> str:
    tid, madh, _, _ = BOOKS[code]
    return BASE.format(madh=madh, tid=tid, s=surah, v=verse)


def _fetch(url: str) -> str:
    os.makedirs(CACHE_DIR, exist_ok=True)
    key = hashlib.sha1(url.encode()).hexdigest()
    path = os.path.join(CACHE_DIR, key + ".html")
    if os.path.exists(path):
        return open(path, "rb").read().decode("cp1256", "ignore")
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (thaqalayn citation pass)"})
    raw = urllib.request.urlopen(req, timeout=40).read()
    with open(path, "wb") as f:
        f.write(raw)
    return raw.decode("cp1256", "ignore")


def extract_body(page: str) -> str:
    """The tafsir text sits in <div align='right' dir='rtl'><font class='TextResultArabic'>...</div>."""
    m = re.search(r"<div align='right' dir='rtl'>\s*<font class='TextResultArabic'>(.*?)</div>", page, flags=re.S)
    if not m:
        return ""
    body = m.group(1)
    body = re.sub(r"<br\s*/?>", "\n", body, flags=re.I)
    body = re.sub(r"</?(p|h\d|div)[^>]*>", "\n", body, flags=re.I)
    body = re.sub(r"<[^>]+>", "", body)
    body = html.unescape(body)
    body = re.sub(r"[ \t ]+", " ", body)
    body = re.sub(r"\n\s*\n+", "\n\n", body)
    return body.strip()


def _page_numbers(page: str, tid: int) -> set[int]:
    """altafsir paginates long entries; the pager links look like InnerLink_onchange(56,3,1)."""
    return {int(n) for n in re.findall(r"InnerLink_onchange\(%d,(\d+),1\)" % tid, page)}


def get_pages(code: str, surah: int, verse: int) -> tuple[str, list[str]]:
    """Return (url of page 1, [body text of every page]). Follows the pager until no new page appears."""
    tid = BOOKS[code][0]
    url = url_for(code, surah, verse)
    first = _fetch(url)
    bodies = [extract_body(first)]
    seen = {1}
    todo = sorted(_page_numbers(first, tid) - seen)
    while todo:
        n = todo.pop(0)
        if n in seen:
            continue
        seen.add(n)
        page = _fetch(f"{url}&Page={n}&Size=1")
        body = extract_body(page)
        if body:
            bodies.append(body)
        for m in sorted(_page_numbers(page, tid) - seen):
            if m not in todo:
                todo.append(m)
        todo.sort()
    return url, bodies


def get(code: str, surah: int, verse: int, max_chars: int = 0, grep: list[str] | None = None) -> tuple[str, str]:
    url, bodies = get_pages(code, surah, verse)
    text = "\n\n".join(b for b in bodies if b)
    npages = len(bodies)
    if grep:
        # the pages are giant run-on paragraphs, so split into sentences and return each
        # matching sentence with one sentence of context on either side
        sents = [s for s in re.split(r"(?<=[\.\؟!:])\s+|\n+", text) if s.strip()]
        hits = [i for i, s in enumerate(sents) if any(g in s for g in grep)]
        if hits:
            chunks, last_end = [], -1
            for i in hits:
                a, b = max(0, i - 1), min(len(sents), i + 2)
                if a <= last_end:          # merge overlapping windows
                    chunks[-1] = (chunks[-1][0], b)
                else:
                    chunks.append((a, b))
                last_end = b - 1
            text = "\n\n[...] ".join(" ".join(sents[a:b]) for a, b in chunks)
            text = f"({len(hits)} matching sentence(s) for {' / '.join(grep)})\n" + text
        else:
            text = f"(nothing on these {npages} page(s) contains: {' / '.join(grep)})"
    if max_chars and len(text) > max_chars:
        text = text[:max_chars].rstrip() + f"\n[... truncated at {max_chars} chars of {npages} page(s); use --grep to narrow, or raise --max]"
    text = f"[{npages} page(s) on altafsir]\n" + text
    return url, text


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("surah", nargs="?", type=int)
    ap.add_argument("verse", nargs="?", type=int)
    ap.add_argument("books", nargs="*", help="book codes, or 'all'")
    ap.add_argument("--max", type=int, default=0, help="cap characters per book (0 = no cap)")
    ap.add_argument("--grep", nargs="+", metavar="ARABIC", help="only print paragraphs containing any of these strings")
    ap.add_argument("--list", action="store_true", help="list book codes")
    a = ap.parse_args()

    if a.list:
        for code, (tid, madh, name, author) in BOOKS.items():
            print(f"{code:10s} {name} ({author})  id={tid}")
        return 0
    if a.surah is None or a.verse is None or not a.books:
        ap.print_help()
        return 2

    codes = list(BOOKS) if a.books == ["all"] else a.books
    bad = [c for c in codes if c not in BOOKS]
    if bad:
        print(f"unknown book code(s): {', '.join(bad)}  (use --list)", file=sys.stderr)
        return 2

    for code in codes:
        _, _, name, author = BOOKS[code]
        try:
            url, text = get(code, a.surah, a.verse, a.max, a.grep)
        except Exception as e:  # network or parse failure - say so, keep going
            print(f"=== {name} ({author}) {a.surah}:{a.verse}\n(fetch failed: {e})\n")
            continue
        print(f"=== {name} ({author}) {a.surah}:{a.verse}  {url}")
        print(text if text else "(no text for this verse)")
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
