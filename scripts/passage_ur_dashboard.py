#!/usr/bin/env python3
"""Status dashboard for the Urdu passage translation (translate_passages_ur.py).

Reads every Thaqalayn/Thaqalayn/Data/passages_<N>.json and the passages_work/ur_*.log
files and renders one page: whether the run is going, how many passages and
fields carry Urdu, a line per surah, the passages that are only partly done,
translated fields that fail the marker or paragraph checks, and the log tail.
The data files are the source of truth; logs only feed the speed estimate and
the activity tail.

Usage:
    python3 scripts/passage_ur_dashboard.py --serve          # live page on http://127.0.0.1:8765
    python3 scripts/passage_ur_dashboard.py --out /tmp/ur.html --open

scripts/ur_dashboard.sh starts the live page in the background and opens it.

Only the standard library is used.
"""

from __future__ import annotations

import argparse
import html
import http.server
import json
import re
import subprocess
import time
from pathlib import Path

from passage_ur_review import CSS as REVIEW_CSS

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "Thaqalayn" / "Thaqalayn" / "Data"
WORK = ROOT / "passages_work"
QURAN = ROOT / "quran_data.json"
DEFAULT_PORT = 8765
REFRESH_S = 60

MARKER_RE = re.compile(r"\[\d+\]")
START_RE = re.compile(r"^\[[\d:]+\] \(\d+/\d+\) .* \((\d+) chars\) \.\.\.$")
DONE_RE = re.compile(r"^\[[\d:]+\]\s+ok in (\d+)s, \d+ tokens, [\d.]+ tok/s")

CSS = REVIEW_CSS + """
main { max-width: 980px; }
.status { font-family: var(--sans); font-size: 12px; letter-spacing: .12em; text-transform: uppercase; font-weight: 600; }
.status.on { color: var(--accent); }
.status.off { color: var(--warn); }
.stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 0; margin: 26px 0 6px; }
.stat { padding: 4px 22px 6px 0; border-inline-start: 1px solid var(--rule); padding-inline-start: 18px; }
.stat:first-child { border-inline-start: 0; padding-inline-start: 0; }
.stat .n { font-size: 40px; line-height: 1.1; font-weight: 500; letter-spacing: -.01em; }
.stat .n small { font-size: 18px; color: var(--muted); font-weight: 400; }
.stat .l { font-family: var(--sans); font-size: 11px; letter-spacing: .12em; text-transform: uppercase; color: var(--muted); }
table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 15px; }
th { font-family: var(--sans); font-size: 10.5px; letter-spacing: .12em; text-transform: uppercase; font-weight: 600;
  color: var(--muted); text-align: left; padding: 6px 10px 6px 0; border-bottom: 1px solid var(--rule); }
td { padding: 7px 10px 7px 0; border-bottom: 1px solid var(--rule-soft); vertical-align: baseline; }
td.num, th.num { text-align: right; font-variant-numeric: tabular-nums; }
td .sub { color: var(--muted); font-style: italic; font-size: 13.5px; }
tr.idle td { color: var(--miss); }
.bar { position: relative; height: 3px; background: var(--rule-soft); min-width: 90px; top: -3px; }
.bar i { position: absolute; inset: 0 auto 0 0; background: var(--accent); }
.note { color: var(--muted); font-style: italic; margin: 12px 0 0; }
pre { font-family: ui-monospace, Menlo, monospace; font-size: 12px; line-height: 1.6; color: var(--muted);
  white-space: pre-wrap; margin: 12px 0 0; }
code { font-family: ui-monospace, Menlo, monospace; font-size: 12.5px; background: var(--chip); padding: 1px 5px; }
@media (max-width: 760px) {
  .stats { grid-template-columns: repeat(2, 1fr); gap: 16px 0; }
  .stat:nth-child(3) { border-inline-start: 0; padding-inline-start: 0; }
  .stat .n { font-size: 32px; }
  .hide-sm { display: none; }
}
"""


def esc(s) -> str:
    return html.escape(str(s), quote=False)


# ---------------------------------------------------------------- data


def fields(node, kind: str = "", out: list | None = None) -> list:
    """Every {"en": ...} holder under node, as (kind, holder), in document order."""
    out = [] if out is None else out
    if isinstance(node, dict):
        if isinstance(node.get("en"), str) and node["en"].strip():
            out.append((kind, node))
        for k, v in node.items():
            fields(v, ("narration" if k == "text" else k) if isinstance(v, dict) and "en" in v else kind, out)
    elif isinstance(node, list):
        for v in node:
            fields(v, kind, out)
    return out


def check(kind: str, holder: dict) -> list[str]:
    en, ur = holder["en"], holder.get("ur")
    if not ur:
        return []
    out = []
    if sorted(MARKER_RE.findall(en)) != sorted(MARKER_RE.findall(ur)):
        out.append("citation markers differ")
    if kind in ("essay", "perspectives", "note") and en.count("\n\n") != ur.count("\n\n"):
        out.append(f"paragraphs {ur.count(chr(10) * 2) + 1} vs {en.count(chr(10) * 2) + 1}")
    if re.search(r"[A-Za-z]{3,}", ur):
        out.append("Latin text in Urdu")
    return out


def surah_names() -> dict:
    try:
        return {s["number"]: s.get("englishNameTranslation", "") for s in json.load(open(QURAN))["surahs"]}
    except (OSError, ValueError, KeyError):
        return {}


def collect() -> dict:
    names = surah_names()
    surahs, partial, flagged = [], [], []
    for f in sorted(DATA.glob("passages_*.json"), key=lambda p: int(p.stem.split("_")[1])):
        n = int(f.stem.split("_")[1])
        data = json.load(open(f, encoding="utf-8"))
        row = {"n": n, "name": names.get(n, ""), "passages": len(data), "complete": 0, "partial": 0,
               "fields": 0, "done": 0, "chars_left": 0}
        for key in sorted(data, key=int):
            p = data[key]
            pid = p.get("id", f"{n}:{key}")
            fs = fields(p)
            done = sum(1 for _, h in fs if h.get("ur"))
            row["fields"] += len(fs)
            row["done"] += done
            row["chars_left"] += sum(len(h["en"]) for _, h in fs if not h.get("ur"))
            if done == len(fs):
                row["complete"] += 1
            elif done:
                row["partial"] += 1
                missing = [k or "field" for k, h in fs if not h.get("ur")]
                partial.append({"id": pid, "done": done, "total": len(fs),
                                "essay": bool(p.get("essay", {}).get("ur")), "missing": missing})
            for k, h in fs:
                for issue in check(k, h):
                    flagged.append({"id": pid, "kind": k or "field", "issue": issue})
        surahs.append(row)
    return {"surahs": surahs, "partial": partial, "flagged": flagged}


def seconds_per_char() -> float | None:
    """Average model time per English character over every finished field in the logs."""
    secs = chars = 0
    for log in WORK.glob("ur_*.log"):
        pending = None
        for line in log.read_text(encoding="utf-8", errors="replace").splitlines():
            m = START_RE.match(line)
            if m:
                pending = int(m.group(1))
                continue
            d = DONE_RE.match(line)
            if d and pending:
                secs += int(d.group(1))
                chars += pending
                pending = None
    return secs / chars if chars else None


def latest_log() -> Path | None:
    logs = sorted(WORK.glob("ur_*.log"), key=lambda p: p.stat().st_mtime)
    return logs[-1] if logs else None


def running() -> bool:
    return subprocess.run(["pgrep", "-f", "translate_passages_ur.py"], capture_output=True).returncode == 0


# ---------------------------------------------------------------- render


def fmt_hours(h: float) -> str:
    return f"{h:.0f} h" if h < 48 else f"{h / 24:.1f} days"


def missing_text(p: dict) -> str:
    counts: dict = {}
    for k in p["missing"]:
        counts[k] = counts.get(k, 0) + 1
    parts = [("essay (no EN/UR toggle until it lands)" if k == "essay" else f"{c} {k}{'s' if c > 1 else ''}")
             for k, c in counts.items()]
    return ", ".join(parts)


def render() -> str:
    d = collect()
    S = d["surahs"]
    passages = sum(r["passages"] for r in S)
    complete = sum(r["complete"] for r in S)
    total_f = sum(r["fields"] for r in S)
    done_f = sum(r["done"] for r in S)
    chars_left = sum(r["chars_left"] for r in S)
    spc = seconds_per_char()
    eta = fmt_hours(chars_left * spc / 3600) if spc and chars_left else "-"
    is_on = running()
    log = latest_log()
    tail = log.read_text(encoding="utf-8", errors="replace").splitlines()[-14:] if log else []
    updated = time.strftime("%Y-%m-%d %H:%M:%S")

    status = ('<span class="status on">Running</span>' if is_on
              else '<span class="status off">Stopped</span>')
    pct = 100 * done_f / total_f if total_f else 0

    rows = []
    for r in S:
        p = 100 * r["done"] / r["fields"] if r["fields"] else 0
        idle = "" if r["done"] else ' class="idle"'
        rows.append(
            f'<tr{idle}><td>{r["n"]} <span class="sub">{esc(r["name"])}</span></td>'
            f'<td class="num">{r["complete"]} / {r["passages"]}</td>'
            f'<td class="num hide-sm">{r["partial"] or ""}</td>'
            f'<td class="num">{r["done"]} / {r["fields"]}</td>'
            f'<td><div class="bar"><i style="width:{p:.1f}%"></i></div></td></tr>')

    part_rows = "".join(
        f'<tr><td>{esc(p["id"])}</td><td class="num">{p["done"]} / {p["total"]}</td>'
        f'<td>{esc(missing_text(p))}</td></tr>' for p in d["partial"])
    partial_html = (f'<table><tr><th>Passage</th><th class="num">Fields</th><th>Missing</th></tr>{part_rows}</table>'
                    if part_rows else '<p class="note">No passage is half done.</p>')

    flag_rows = "".join(f'<tr><td>{esc(f["id"])}</td><td>{esc(f["kind"])}</td><td>{esc(f["issue"])}</td></tr>'
                        for f in d["flagged"])
    flag_html = (f'<table><tr><th>Passage</th><th>Field</th><th>Issue</th></tr>{flag_rows}</table>'
                 if flag_rows else '<p class="note">Every translated field keeps its citation markers and paragraphs.</p>')

    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="{REFRESH_S}">
<title>Urdu Translation Status</title>
<style>{CSS}</style></head>
<body><main>
<header>
  <div class="eyebrow">Passage commentary · Urdu</div>
  <h1>Translation status</h1>
  <p class="lede">Local model translating every shipped passage into Urdu, field by field. Numbers come from the Data files themselves.</p>
  <div class="meta">{status}<span>Updated <b>{updated}</b></span><span>Refreshes every {REFRESH_S}s</span>
  <span>Log <b>{esc(log.name) if log else "none"}</b></span></div>
  <div class="stats">
    <div class="stat"><div class="n">{complete}<small> / {passages}</small></div><div class="l">Passages complete</div></div>
    <div class="stat"><div class="n">{done_f:,}<small> / {total_f:,}</small></div><div class="l">Fields translated</div></div>
    <div class="stat"><div class="n">{pct:.1f}<small>%</small></div><div class="l">Of all fields</div></div>
    <div class="stat"><div class="n">{eta}</div><div class="l">Model time left</div></div>
  </div>
</header>

<h2>By surah</h2>
<table><tr><th>Surah</th><th class="num">Passages done</th><th class="num hide-sm">Partial</th>
<th class="num">Fields</th><th style="width:28%"></th></tr>{"".join(rows)}</table>

<h2>Partly translated passages</h2>
{partial_html}

<h2>Checks on translated fields</h2>
{flag_html}

<h2>Latest log</h2>
<pre>{esc(chr(10).join(tail)) or "No log yet."}</pre>
<p class="note">Resume: <code>nohup passages_work/run_ur_loop.sh &gt;&gt; passages_work/ur_resume.log 2&gt;&amp;1 &amp;</code>
&nbsp; Stop: <code>pkill -f run_ur_loop.sh; pkill -f translate_passages_ur</code></p>
</main></body></html>"""


# ---------------------------------------------------------------- main


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ("/", "/index.html"):
            self.send_error(404)
            return
        try:
            body, code = render().encode("utf-8"), 200
        except Exception as e:  # a data file mid-save or a bad log line should not kill the server
            body, code = f"<pre>dashboard error: {esc(e)}</pre>".encode("utf-8"), 500
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--serve", action="store_true", help="serve a live page that re-reads the data on every load")
    ap.add_argument("--port", type=int, default=DEFAULT_PORT)
    ap.add_argument("--out", help="write a static page here instead of serving")
    ap.add_argument("--open", action="store_true", help="open the written page in the default browser")
    a = ap.parse_args()

    if a.serve:
        srv = http.server.ThreadingHTTPServer(("127.0.0.1", a.port), Handler)
        print(f"serving http://127.0.0.1:{a.port}", flush=True)
        srv.serve_forever()
        return
    out = Path(a.out) if a.out else WORK / "ur_dashboard.html"
    out.write_text(render(), encoding="utf-8")
    print(out)
    if a.open:
        subprocess.run(["open", str(out)])


if __name__ == "__main__":
    main()
