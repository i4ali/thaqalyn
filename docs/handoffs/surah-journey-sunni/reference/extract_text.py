#!/usr/bin/env python3
"""
extract_text.py - dump the human-readable text of a Surah*Dive.swift content
file into a plain, beat-by-beat .txt.

This is a MECHANICAL extractor: it pulls every string literal out of the
`DeepDive(...)` initializer in document order and prints it under its beat
(the `.case(` it belongs to) and field label. It does not paraphrase,
summarize, or reorder anything - what you read in the .txt is verbatim what
is authored in the .swift. Trilingual LocalizedText(en:ur:ar:) fields are
printed with all three languages; English-only fields print one line.

Usage:
    python3 extract_text.py <SurahFooDive.swift> [out.txt]
If out.txt is omitted, prints to stdout.
"""
import re
import sys

TOKEN = re.compile(
    r'(?P<str>"(?:[^"\\]|\\.)*")'          # a Swift string literal (atomic)
    r'|(?P<case>\.[A-Za-z_]\w*\s*\()'      # a dotted case opener e.g. .verse(
    r'|(?P<label>\b[A-Za-z_]\w*\s*:)',     # a field label e.g. reflection:
    re.DOTALL,
)
LANG = {"en", "ur", "ar"}


def unquote(s: str) -> str:
    inner = s[1:-1]
    return inner.replace('\\"', '"').replace("\\n", "\n").replace("\\\\", "\\")


def slice_initializer(text: str) -> tuple[str, str]:
    """Return (meta_and_acts_region, sections_region)."""
    start = text.find("= DeepDive(")
    if start == -1:
        start = text.find("DeepDive(")
    end = text.find("#if DEBUG", start)
    region = text[start:end if end != -1 else len(text)]
    sidx = region.find("sections:")
    head = region[:sidx] if sidx != -1 else region
    body = region[sidx:] if sidx != -1 else ""
    return head, body


def dump_meta(head: str, out: list):
    def first_str(field):
        m = re.search(field + r'\s*:\s*(?:LocalizedText\(\s*en:\s*)?("(?:[^"\\]|\\.)*")', head)
        return unquote(m.group(1)) if m else None

    out.append("=" * 60)
    out.append("META")
    out.append("=" * 60)
    for f in ("id", "titleEn", "titleAr", "subtitle", "sfSymbol", "stageNoun"):
        v = first_str(f)
        if v is not None:
            out.append(f"{f}: {v}")
    mm = re.search(r"estMinutes:\s*(\d+)", head)
    if mm:
        out.append(f"estMinutes: {mm.group(1)}")

    acts = re.findall(
        r'ActInfo\(\s*number:\s*(\d+),\s*ar:\s*"([^"]*)",\s*tr:\s*"([^"]*)",\s*'
        r'name:\s*(?:LocalizedText\(\s*en:\s*)?"([^"]*)"',
        head,
    )
    if acts:
        out.append("")
        out.append("acts (movements / stations):")
        for n, ar, tr, name in acts:
            out.append(f"  {n}. {name}  ({tr} · {ar})")
    out.append("")


def dump_sections(body: str, out: list):
    beats = []            # list of (case_name, [(field, lang, value)])
    cur_case = None
    cur_fields = None
    cur_field = None
    cur_lang = "en"

    for m in TOKEN.finditer(body):
        if m.lastgroup == "case":
            cur_case = m.group("case")[1:].rstrip("( ").strip()
            cur_fields = []
            beats.append((cur_case, cur_fields))
            cur_field = None
            cur_lang = "en"
        elif m.lastgroup == "label":
            name = m.group("label")[:-1].strip()
            if name in LANG:
                cur_lang = name
            else:
                cur_field = name
                cur_lang = "en"
        else:  # string
            if cur_fields is None:
                continue
            cur_fields.append((cur_field or "(text)", cur_lang, unquote(m.group("str"))))

    beat_no = 0
    for case_name, fields in beats:
        beat_no += 1
        out.append("")
        out.append("─" * 60)
        out.append(f"BEAT {beat_no} · .{case_name}")
        out.append("─" * 60)
        # group consecutive entries by field, collecting languages
        i = 0
        while i < len(fields):
            field, lang, val = fields[i]
            langs = {lang: val}
            j = i + 1
            while j < len(fields) and fields[j][0] == field and fields[j][1] in LANG and fields[j][1] not in langs:
                langs[fields[j][1]] = fields[j][2]
                j += 1
            if len(langs) == 1:
                out.append(f"{field}: {langs.get('en', val)}")
            else:
                out.append(f"{field}:")
                for L in ("en", "ur", "ar"):
                    if L in langs:
                        out.append(f"  [{L}] {langs[L]}")
            i = j


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    text = open(sys.argv[1], encoding="utf-8").read()
    head, body = slice_initializer(text)
    out = []
    dump_meta(head, out)
    dump_sections(body, out)
    result = "\n".join(out) + "\n"
    if len(sys.argv) >= 3:
        open(sys.argv[2], "w", encoding="utf-8").write(result)
        print(f"wrote {sys.argv[2]} ({result.count(chr(10))} lines)")
    else:
        sys.stdout.write(result)


if __name__ == "__main__":
    main()
