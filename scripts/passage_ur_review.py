#!/usr/bin/env python3
"""Render a passages file that carries "ur" values as a side-by-side English / Urdu review page.

Takes the Data file that translate_passages_ur.py updated in place (or any
staged copy of it).

Usage:
    python3 scripts/passage_ur_review.py Thaqalayn/Thaqalayn/Data/passages_1.json --open
    python3 scripts/passage_ur_review.py Thaqalayn/Thaqalayn/Data/passages_2.json --index 3 --out /tmp/review.html

Every translatable field is shown English on the left, Urdu on the right, with
a check line (citation markers, paragraph count) and a marker for fields not
translated yet. Output defaults to <input stem>_review.html next to the input.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import subprocess
import sys
from pathlib import Path

MARKER_RE = re.compile(r"\[\d+\]")

CSS = """
:root {
  --paper: #f6f1e7; --ink: #211d18; --muted: #6e6357; --rule: #d8cfbf; --rule-soft: #e9e2d4;
  --accent: #1f6b4f; --warn: #9a5b1e; --miss: #a1978a; --chip: #ece5d6;
  --serif: "Iowan Old Style", "Palatino Linotype", Palatino, Charter, Georgia, "Times New Roman", serif;
  --urdu: "Noto Nastaliq Urdu", "Jameel Noori Nastaleeq", "Geeza Pro", "Noto Naskh Arabic", serif;
  --sans: ui-sans-serif, -apple-system, "Helvetica Neue", Arial, sans-serif;
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --paper: #1c1a17; --ink: #ebe4d7; --muted: #a79d8f; --rule: #3d372f; --rule-soft: #2c2823;
    --accent: #79c7a1; --warn: #d79a56; --miss: #7d746a; --chip: #2b2721;
  }
}
:root[data-theme="dark"] {
  --paper: #1c1a17; --ink: #ebe4d7; --muted: #a79d8f; --rule: #3d372f; --rule-soft: #2c2823;
  --accent: #79c7a1; --warn: #d79a56; --miss: #7d746a; --chip: #2b2721;
}
body { background: var(--paper); color: var(--ink); font-family: var(--serif); font-size: 15.5px;
  line-height: 1.55; margin: 0; padding-block: 40px 80px; padding-inline: 20px; }
main { max-width: 1180px; margin: 0 auto; }
.eyebrow { font-family: var(--sans); font-size: 11px; letter-spacing: .14em; text-transform: uppercase;
  color: var(--muted); }
h1 { font-weight: 500; font-size: 34px; line-height: 1.15; margin: 6px 0 4px; text-wrap: balance; letter-spacing: -.01em; }
h1 .ur { display: block; font-family: var(--urdu); font-size: 26px; line-height: 2; direction: rtl; text-align: left; color: var(--accent); }
.lede { font-style: italic; color: var(--muted); margin: 0 0 6px; max-width: 70ch; }
.meta { font-family: var(--sans); font-size: 12.5px; color: var(--muted); display: flex; flex-wrap: wrap; gap: 6px 22px; margin-top: 14px; }
.meta b { color: var(--ink); font-weight: 600; }
header { padding-bottom: 22px; border-bottom: 1px solid var(--ink); margin-bottom: 8px; }
h2 { font-family: var(--sans); font-size: 12px; letter-spacing: .14em; text-transform: uppercase; font-weight: 600;
  color: var(--ink); margin: 40px 0 0; padding-top: 14px; border-top: 1px solid var(--rule); }
section.field { padding: 20px 0 22px; border-top: 1px solid var(--rule-soft); }
section.field:first-of-type { border-top: 0; }
.head { display: flex; flex-wrap: wrap; align-items: baseline; gap: 4px 14px; margin-bottom: 12px; }
.head .eyebrow { color: var(--accent); }
.speaker { font-style: italic; color: var(--muted); font-size: 14px; }
.check { font-family: var(--sans); font-size: 11.5px; color: var(--muted); margin-inline-start: auto; }
.check.warn { color: var(--warn); }
.check.miss { color: var(--miss); }
.arabic { font-family: var(--urdu); font-size: 17px; line-height: 2; direction: rtl; text-align: right;
  color: var(--muted); margin: 0 0 14px; padding: 0 0 12px; border-bottom: 1px dotted var(--rule); }
.pair { display: grid; grid-template-columns: 1fr 1fr; gap: 0 36px; }
.en, .ur { margin: 0; }
.en p, .ur p { margin: 0 0 .9em; }
.en p:last-child, .ur p:last-child { margin-bottom: 0; }
.en { max-width: 66ch; }
.ur { font-family: var(--urdu); font-size: 16.5px; line-height: 2.15; direction: rtl; text-align: right;
  padding-inline-start: 36px; border-inline-start: 1px solid var(--rule-soft); }
.ur .m, .en .m { font-family: var(--sans); font-size: 10.5px; color: var(--accent); vertical-align: super; letter-spacing: 0; }
.ur.missing { font-family: var(--serif); font-size: 14px; font-style: italic; color: var(--miss); direction: ltr; text-align: left; }
.short .en, .short .ur { font-size: 18px; }
.short .ur { font-size: 19px; }
@media (max-width: 760px) {
  body { padding-block: 24px 60px; padding-inline: 16px; }
  .pair { grid-template-columns: 1fr; gap: 14px 0; }
  .ur { padding-inline-start: 0; border-inline-start: 0; padding-top: 12px; border-top: 1px solid var(--rule-soft); }
  h1 { font-size: 28px; }
}
"""


def esc(s: str) -> str:
    return html.escape(s or "", quote=False)


def paragraphs(text: str, mark: bool = True) -> str:
    out = []
    for para in (text or "").split("\n\n"):
        p = esc(para).replace("\n", "<br>")
        if mark:
            p = MARKER_RE.sub(lambda m: f'<span class="m">{m.group(0)}</span>', p)
        out.append(f"<p>{p}</p>")
    return "".join(out)


def check_line(kind: str, en: str, ur: str | None) -> str:
    if not ur:
        return '<span class="check miss">not translated yet</span>'
    notes, warn = [], False
    a, b = sorted(MARKER_RE.findall(en)), sorted(MARKER_RE.findall(ur))
    if a or b:
        ok = a == b
        warn |= not ok
        notes.append(f"markers {len(b)}/{len(a)}" + ("" if ok else " differ"))
    if kind in ("essay", "perspectives", "note"):
        pe, pu = en.count("\n\n") + 1, ur.count("\n\n") + 1
        ok = pe == pu
        warn |= not ok
        notes.append(f"paragraphs {pu}/{pe}" + ("" if ok else " differ"))
    if re.search(r"[A-Za-z]{3,}", ur):
        warn = True
        notes.append("Latin text present")
    notes.append(f"{len(ur)} chars")
    return f'<span class="check{" warn" if warn else ""}">{" · ".join(notes)}</span>'


def field(kind: str, label: str, holder: dict, speaker: str = "", arabic: str = "") -> str:
    en, ur = holder.get("en") or "", holder.get("ur")
    short = kind in ("title", "heading")
    head = f'<span class="eyebrow">{esc(label)}</span>'
    if speaker:
        head += f'<span class="speaker">{esc(speaker)}</span>'
    head += check_line(kind, en, ur)
    ar = f'<p class="arabic">{esc(arabic)}</p>' if arabic else ""
    ur_html = (f'<div class="ur">{paragraphs(ur)}</div>' if ur
               else '<div class="ur missing">Urdu not translated yet</div>')
    return (f'<section class="field{" short" if short else ""}"><div class="head">{head}</div>{ar}'
            f'<div class="pair"><div class="en">{paragraphs(en)}</div>{ur_html}</div></section>')


def render(passages: dict, pids: list[str], src: Path, model: str, effort: str) -> str:
    first = passages[pids[0]]
    surah = first.get("surah")
    parts = [f"<title>Surah {surah} Urdu Review</title>", f"<style>{CSS}</style>", "<main>"]
    total = done = 0
    body = []
    for pid in pids:
        p = passages[pid]
        r = p.get("range") or ["", ""]
        body.append(f"<h2>Passage {esc(str(p.get('id', pid)))} · verses {r[0]} to {r[1]}</h2>")
        units = [("title", "Title", p["title"], "", ""), ("essay", "Essay", p["essay"], "", "")]
        if isinstance(p.get("perspectives"), dict):
            units.append(("perspectives", "Perspectives", p["perspectives"], "", ""))
        for v in p.get("verses", []):
            vn = v.get("verse")
            if isinstance(v.get("heading"), dict):
                units.append(("heading", f"Verse {vn} · heading", v["heading"], "", ""))
            if isinstance(v.get("note"), dict):
                units.append(("note", f"Verse {vn} · note", v["note"], "", ""))
            for n in v.get("narrations", []):
                units.append(("narration", f"Verse {vn} · narration {n.get('id')}", n["text"],
                              n.get("speaker") or "", n.get("arabic") or ""))
        for kind, label, holder, speaker, arabic in units:
            if not (holder.get("en") or "").strip():
                continue
            total += 1
            done += 1 if holder.get("ur") else 0
            body.append(field(kind, label, holder, speaker, arabic))
    title_en = first["title"].get("en", "")
    title_ur = first["title"].get("ur", "")
    parts.append("<header>")
    parts.append(f'<div class="eyebrow">Surah {surah} · Urdu translation review</div>')
    parts.append(f"<h1>{esc(title_en)}" + (f'<span class="ur">{esc(title_ur)}</span>' if title_ur else "") + "</h1>")
    parts.append('<p class="lede">English on the left is the shipped commentary; Urdu on the right is the local model\'s '
                 'translation, unedited. Superscript numbers are citation markers and must match on both sides.</p>')
    parts.append(f'<div class="meta"><span>Model <b>{esc(model)}</b></span><span>Reasoning effort <b>{esc(effort)}</b></span>'
                 f'<span>Fields translated <b>{done} of {total}</b></span><span>Source <b>{esc(src.name)}</b></span></div>')
    parts.append("</header>")
    parts.extend(body)
    parts.append("</main>")
    return "\n".join(parts)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ur_file", help="passages_<N>_ur.json produced by translate_passages_ur.py")
    ap.add_argument("--index", help="passage index or range to include, e.g. 3 or 3-5 (default: all)")
    ap.add_argument("--out", help="output HTML path (default: <stem>_review.html next to the input)")
    ap.add_argument("--model", default="qwen3.8:27b-q8_0", help="model name shown in the header")
    ap.add_argument("--effort", default="high", help="reasoning effort shown in the header")
    ap.add_argument("--open", action="store_true", help="open the page in the default browser (new tab)")
    a = ap.parse_args()

    src = Path(a.ur_file)
    if not src.exists():
        sys.exit(f"error: {src} not found")
    passages = json.load(open(src, encoding="utf-8"))
    available = sorted(passages.keys(), key=lambda k: int(k))
    pids = available
    if a.index:
        wanted = set()
        for part in a.index.split(","):
            if "-" in part:
                lo, hi = part.split("-", 1)
                wanted.update(str(i) for i in range(int(lo), int(hi) + 1))
            elif part.strip():
                wanted.add(str(int(part)))
        pids = [k for k in available if k in wanted]
        if not pids:
            sys.exit(f"error: no passages match --index {a.index}")

    out = Path(a.out) if a.out else src.with_name(f"{src.stem}_review.html")
    out.write_text(render(passages, pids, src, a.model, a.effort), encoding="utf-8")
    print(out)
    if a.open:
        subprocess.run(["open", str(out)], check=False)


if __name__ == "__main__":
    main()
