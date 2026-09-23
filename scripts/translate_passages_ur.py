#!/usr/bin/env python3
"""Translate a shipped passage file into Urdu with a local Ollama model.

Reads Thaqalayn/Thaqalayn/Data/passages_<N>.json, translates every English
field the app shows (title, essay, perspectives, verse headings, verse notes,
narration texts) and writes the file back in place with a "ur" value beside
each "en" value. That is exactly the shape the app decodes (`LocalizedText`
has `en` plus optional `ur`/`ar`): once the essay carries "ur" the passage
screen offers the EN/UR toggle, and any field still without "ur" falls back
to English. Sources, Arabic, chains, status and the file's formatting are
left untouched, so `git diff` shows only the added "ur" lines.

One model request per field, sequential, saved after every field, so a run can
be stopped at any time and resumed: a field is skipped when the file already
holds a "ur" for the same English text (use --force to redo it). Before every
save the script checks that nothing but "ur" values changed.

Usage:
    python3 scripts/translate_passages_ur.py Thaqalayn/Thaqalayn/Data/passages_1.json
    python3 scripts/translate_passages_ur.py Thaqalayn/Thaqalayn/Data/passages_2.json --index 3
    python3 scripts/translate_passages_ur.py Thaqalayn/Thaqalayn/Data/passages_2.json --index 3-7
    python3 scripts/translate_passages_ur.py Thaqalayn/Thaqalayn/Data/passages_2.json --dry-run
    python3 scripts/translate_passages_ur.py Thaqalayn/Thaqalayn/Data/passages_2.json --limit 3
    python3 scripts/translate_passages_ur.py ... --out passages_work/2/passages_2_ur.json   # stage elsewhere

Review the result with scripts/passage_ur_review.py <file> --open.

Only the standard library is used. Requires a running Ollama server
(brew services start ollama) with the model pulled (ollama pull qwen3.8:27b-q8_0).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

DEFAULT_MODEL = "qwen3.8:27b-q8_0"
DEFAULT_HOST = "http://127.0.0.1:11434"
DEFAULT_EFFORT = "high"
DEFAULT_NUM_CTX = 20480
NUM_PREDICT = 12288
KEEP_ALIVE = "1h"
HTTP_TIMEOUT_S = 3600
MAX_ATTEMPTS = 3

MARKER_RE = re.compile(r"\[\d+\]")
ARABIC_SCRIPT_RE = re.compile(r"[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]")
LATIN_RE = re.compile(r"[A-Za-z]")

SYSTEM_PROMPT = """You are an expert Urdu translator for the Thaqalayn app, which presents Shia Quran commentary. You translate English commentary and hadith renderings into natural, fluent, scholarly Urdu.

Rules:
- Write in proper Urdu script only. No transliteration, no English words, no Latin letters.
- Use natural Urdu sentence structure (subject, object, verb), not English word order. Translate meaning, not word for word.
- Keep the scholarly, calm tone of the original. Do not add, drop or soften anything. Do not add commentary of your own.
- Use standard Urdu Islamic terminology: اللہ for God, نماز، روزہ، توحید، عبادت، امامت، ولایت، تقویٰ and so on.
- Use the conventional Urdu forms of names: علی، فاطمہ، حسن، حسین، امام جعفر صادق، امام محمد باقر، علامہ طباطبائی، شیخ طبرسی، شیخ طوسی، کلینی، صدوق، قمی.
- Use honorifics where Urdu readers expect them: صلی اللہ علیہ وآلہ وسلم after the Prophet, علیہ السلام after an Imam or prophet, رضی اللہ عنہ or سلام اللہ علیہا where appropriate. Keep them short and consistent.
- Keep Quran verse references such as 2:30 or 3:7 exactly as written in the English.
- Keep every citation marker such as [1] or [13] exactly where it sits in the sentence. Never drop, add or renumber a marker.
- Keep paragraph breaks exactly as in the English: one blank line between paragraphs, the same number of paragraphs.
- Quoted Quran or hadith wording inside the text should be rendered in the standard Urdu translation register.
- Output only the Urdu translation. No preface, no notes, no quotation marks around the whole text, no label such as "ترجمہ:"."""

KIND_INSTRUCTIONS = {
    "title": "This is the short title of a Quran passage commentary (a few words). Translate it as a natural Urdu title.",
    "heading": "This is a short heading for one verse inside the commentary (a few words). Translate it as a natural Urdu heading.",
    "note": "This is a brief note on one verse from the commentary. Translate it as flowing Urdu prose.",
    "essay": "This is the main commentary essay on a Quran passage. Translate it as flowing Urdu prose, keeping every paragraph and every citation marker in place.",
    "perspectives": "This is a short section comparing how the Shia and Sunni traditions read the passage. Translate it as flowing Urdu prose, keeping every citation marker in place.",
    "narration": "This is the English rendering of a hadith. Translate it into Urdu in the register of a hadith translation. The English is the authoritative text; the Arabic original is given only to help you choose the right names and terms.",
}


# ---------------------------------------------------------------- units


class Unit:
    """One translatable field: where it lives, what it is, and its English."""

    def __init__(self, pid: str, kind: str, label: str, holder: dict, context: str = ""):
        self.pid = pid
        self.kind = kind
        self.label = label      # human readable, e.g. "2:3 verse 22 narration n1"
        self.holder = holder    # the {"en": ...} dict that receives "ur"
        self.context = context  # extra prompt context (speaker, arabic)

    @property
    def en(self) -> str:
        return self.holder.get("en") or ""


def collect_units(passages: dict, pids: list[str]) -> list[Unit]:
    units: list[Unit] = []
    for pid in pids:
        p = passages[pid]
        tag = p.get("id", pid)
        units.append(Unit(pid, "title", f"{tag} title", p["title"]))
        units.append(Unit(pid, "essay", f"{tag} essay", p["essay"]))
        if isinstance(p.get("perspectives"), dict):
            units.append(Unit(pid, "perspectives", f"{tag} perspectives", p["perspectives"]))
        for v in p.get("verses", []):
            vn = v.get("verse")
            if isinstance(v.get("heading"), dict):
                units.append(Unit(pid, "heading", f"{tag} verse {vn} heading", v["heading"]))
            if isinstance(v.get("note"), dict):
                units.append(Unit(pid, "note", f"{tag} verse {vn} note", v["note"]))
            for n in v.get("narrations", []):
                ctx = f"Narrated from: {n.get('speaker') or 'unknown'}"
                if n.get("addressee"):
                    ctx += f"\nAddressed to: {n['addressee']}"
                if n.get("arabic"):
                    ctx += f"\nArabic original (reference only):\n{n['arabic']}"
                units.append(Unit(pid, "narration", f"{tag} verse {vn} narration {n.get('id')}", n["text"], ctx))
    return [u for u in units if u.en.strip()]


# ---------------------------------------------------------------- reuse of earlier output


def index_previous(prev: dict) -> dict:
    """Map (pid, kind, verse, narration id) -> {"en", "ur"} from an earlier output."""
    idx: dict = {}
    for pid, p in prev.items():
        if not isinstance(p, dict):
            continue
        for kind in ("title", "essay", "perspectives"):
            if isinstance(p.get(kind), dict):
                idx[(pid, kind, None, None)] = p[kind]
        for v in p.get("verses", []):
            vn = v.get("verse")
            for kind in ("heading", "note"):
                if isinstance(v.get(kind), dict):
                    idx[(pid, kind, vn, None)] = v[kind]
            for n in v.get("narrations", []):
                if isinstance(n.get("text"), dict):
                    idx[(pid, "narration", vn, n.get("id"))] = n["text"]
    return idx


def unit_key(u: Unit, passages: dict):
    p = passages[u.pid]
    if u.kind in ("title", "essay", "perspectives"):
        return (u.pid, u.kind, None, None)
    for v in p.get("verses", []):
        if u.kind in ("heading", "note") and v.get(u.kind) is u.holder:
            return (u.pid, u.kind, v.get("verse"), None)
        for n in v.get("narrations", []):
            if n.get("text") is u.holder:
                return (u.pid, "narration", v.get("verse"), n.get("id"))
    return None


def carry_over(units: list[Unit], passages: dict, prev: dict, force: bool) -> int:
    if force or not prev:
        return 0
    idx = index_previous(prev)
    reused = 0
    for u in units:
        old = idx.get(unit_key(u, passages))
        if old and old.get("ur") and (old.get("en") or "") == u.en:
            u.holder["ur"] = old["ur"]
            reused += 1
    return reused


# ---------------------------------------------------------------- ollama


def http_json(url: str, payload: dict | None = None, timeout: int = HTTP_TIMEOUT_S) -> dict:
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode("utf-8"))


def check_server(host: str, model: str) -> None:
    try:
        tags = http_json(f"{host}/api/tags", timeout=10)
    except (urllib.error.URLError, OSError) as e:
        sys.exit(f"error: cannot reach Ollama at {host} ({e}). Start it with: brew services start ollama")
    names = {m.get("name") for m in tags.get("models", [])}
    if model not in names and f"{model}:latest" not in names:
        sys.exit(f"error: model {model} is not pulled. Run: ollama pull {model}\nInstalled: {', '.join(sorted(names)) or 'none'}")


def build_messages(u: Unit, retry_note: str = "") -> list[dict]:
    user = KIND_INSTRUCTIONS[u.kind]
    if u.context:
        user += f"\n\n{u.context}"
    user += f"\n\nEnglish text:\n{u.en}\n\nUrdu translation:"
    if retry_note:
        user += f"\n\n{retry_note}"
    return [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": user}]


def ask_model(host: str, model: str, effort: str, num_ctx: int, messages: list[dict]) -> tuple[str, dict]:
    payload = {
        "model": model,
        "stream": False,
        "think": False if effort == "off" else effort,
        "keep_alive": KEEP_ALIVE,
        "options": {"num_ctx": num_ctx, "num_predict": NUM_PREDICT},
        "messages": messages,
    }
    r = http_json(f"{host}/api/chat", payload)
    if "error" in r:
        raise RuntimeError(r["error"])
    return r.get("message", {}).get("content", ""), r


# ---------------------------------------------------------------- cleaning and checks


def clean(text: str) -> str:
    t = text.strip()
    t = re.sub(r"^(ترجمہ|اردو ترجمہ|Urdu translation|Translation)\s*[:：]\s*", "", t)
    if len(t) >= 2 and t[0] in "\"'“”„«" and t[-1] in "\"'“”»":
        t = t[1:-1].strip()
    t = re.sub(r"[ \t]+\n", "\n", t)
    t = re.sub(r"\n{3,}", "\n\n", t)
    return t


def problems(u: Unit, ur: str) -> list[str]:
    out: list[str] = []
    if not ur:
        return ["empty output"]
    if not ARABIC_SCRIPT_RE.search(ur):
        return ["no Urdu script in output"]
    letters = len(LATIN_RE.findall(ur))
    if letters and letters / max(len(ur), 1) > 0.15:
        out.append("too much Latin text in output")
    want = MARKER_RE.findall(u.en)
    got = MARKER_RE.findall(ur)
    if sorted(want) != sorted(got):
        out.append(f"citation markers differ: English {want} vs Urdu {got}")
    if u.kind in ("essay", "perspectives", "note"):
        pe, pu = u.en.count("\n\n") + 1, ur.count("\n\n") + 1
        if pe != pu:
            out.append(f"paragraph count differs: English {pe} vs Urdu {pu}")
    if u.kind in ("title", "heading") and "\n" in ur:
        out.append("multi-line output for a one-line field")
    return out


def translate_unit(u: Unit, host: str, model: str, effort: str, num_ctx: int) -> tuple[str | None, list[str], dict]:
    """Return (urdu or None, warnings, stats). None means every attempt failed hard."""
    retry_note = ""
    last_soft: list[str] = []
    stats = {"eval_count": 0, "eval_duration": 0, "attempts": 0}
    ur: str | None = None
    for attempt in range(1, MAX_ATTEMPTS + 1):
        stats["attempts"] = attempt
        raw, r = ask_model(host, model, effort, num_ctx, build_messages(u, retry_note))
        stats["eval_count"] += r.get("eval_count", 0)
        stats["eval_duration"] += r.get("eval_duration", 0)
        ur = clean(raw)
        issues = problems(u, ur)
        if not issues:
            return ur, [], stats
        hard = [i for i in issues if i.startswith(("empty", "no Urdu"))]
        last_soft = issues
        retry_note = ("Your previous answer had these problems: " + "; ".join(issues)
                      + ". Answer again in Urdu script only and fix them.")
        if hard:
            ur = None
    return ur, last_soft, stats


# ---------------------------------------------------------------- io


def parse_index(spec: str | None, available: list[str]) -> list[str]:
    if not spec:
        return available
    wanted: list[str] = []
    for part in spec.split(","):
        part = part.strip()
        if "-" in part:
            a, b = part.split("-", 1)
            wanted += [str(i) for i in range(int(a), int(b) + 1)]
        elif part:
            wanted.append(str(int(part)))
    missing = [w for w in wanted if w not in available]
    if missing:
        sys.exit(f"error: passage index not in file: {', '.join(missing)} (file has {available[0]}..{available[-1]})")
    return [w for w in available if w in wanted]


def strip_ur(node):
    """Deep copy with every "ur" key removed, for the only-ur-changed check."""
    if isinstance(node, dict):
        return {k: strip_ur(v) for k, v in node.items() if k != "ur"}
    if isinstance(node, list):
        return [strip_ur(v) for v in node]
    return node


def assert_only_ur_added(original: dict, passages: dict) -> None:
    if strip_ur(passages) != original:
        sys.exit("error: something other than a \"ur\" value changed; refusing to save")
    stack = [passages]
    while stack:
        node = stack.pop()
        if isinstance(node, dict):
            if "ur" in node and not (isinstance(node["ur"], str) and node["ur"].strip()):
                sys.exit("error: an empty or non-string \"ur\" value was produced; refusing to save")
            stack.extend(node.values())
        elif isinstance(node, list):
            stack.extend(node)


def save(out: Path, passages: dict, original: dict) -> None:
    """Write with the same formatting as the shipped Data files (2-space indent, no trailing newline)."""
    assert_only_ur_added(original, passages)
    out.parent.mkdir(parents=True, exist_ok=True)
    tmp = out.with_suffix(out.suffix + ".tmp")
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(passages, f, ensure_ascii=False, indent=2)
    os.replace(tmp, out)


def log(msg: str) -> None:
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", file=sys.stderr, flush=True)


# ---------------------------------------------------------------- main


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("passage_file", help="Data/passages_<N>.json to translate")
    ap.add_argument("--index", help="passage index or range to translate, e.g. 3, 3-7, 3,5,9 (default: all)")
    ap.add_argument("--out", help="output path (default: the input file, updated in place)")
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--host", default=DEFAULT_HOST)
    ap.add_argument("--effort", default=DEFAULT_EFFORT, choices=["off", "low", "medium", "high"],
                    help="reasoning effort passed as Ollama's think value (default: high)")
    ap.add_argument("--num-ctx", type=int, default=DEFAULT_NUM_CTX, help=f"context window (default {DEFAULT_NUM_CTX})")
    ap.add_argument("--force", action="store_true", help="retranslate fields that already have a ur value")
    ap.add_argument("--limit", type=int, help="stop after translating this many fields (for testing)")
    ap.add_argument("--dry-run", action="store_true", help="list what would be translated and exit")
    a = ap.parse_args()

    inp = Path(a.passage_file)
    if not inp.exists():
        sys.exit(f"error: {inp} not found")
    with open(inp, encoding="utf-8") as f:
        passages = json.load(f)
    if not isinstance(passages, dict) or not passages:
        sys.exit("error: expected a JSON object keyed by passage index")

    available = sorted(passages.keys(), key=lambda k: int(k))
    pids = parse_index(a.index, available)
    out = Path(a.out) if a.out else inp
    original = strip_ur(passages)  # what the file must still equal once "ur" values are removed

    prev: dict = {}
    if out.exists():
        with open(out, encoding="utf-8") as f:
            prev = json.load(f)

    units = collect_units(passages, pids)
    reused = carry_over(units, passages, prev, a.force)
    todo = [u for u in units if not u.holder.get("ur")]
    if a.limit is not None:
        todo = todo[: a.limit]

    log(f"{inp.name}: {len(pids)} passage(s), {len(units)} field(s), {reused} already translated, {len(todo)} to do")
    log(f"model {a.model}, effort {a.effort}, output {out}")
    if a.dry_run:
        for u in todo:
            print(f"  {u.label}  ({len(u.en)} chars)")
        return
    if not todo:
        if out != inp or reused:
            save(out, passages, original)
        log("nothing to translate")
        return

    check_server(a.host, a.model)
    if out != inp:
        save(out, passages, original)  # establish a separate output early so a stop mid-run leaves a valid file

    warnings: list[str] = []
    failed: list[str] = []
    done = 0
    tokens = 0
    gen_ns = 0
    t0 = time.time()
    try:
        for i, u in enumerate(todo, 1):
            log(f"({i}/{len(todo)}) {u.label} ({len(u.en)} chars) ...")
            t1 = time.time()
            try:
                ur, soft, st = translate_unit(u, a.host, a.model, a.effort, a.num_ctx)
            except (urllib.error.URLError, OSError, RuntimeError) as e:
                failed.append(f"{u.label}: {e}")
                log(f"    request failed: {e}")
                continue
            dt = time.time() - t1
            tokens += st["eval_count"]
            gen_ns += st["eval_duration"]
            if ur is None:
                failed.append(f"{u.label}: {'; '.join(soft) or 'no usable output'}")
                log(f"    FAILED after {st['attempts']} attempt(s): {'; '.join(soft)}")
                continue
            u.holder["ur"] = ur
            done += 1
            save(out, passages, original)
            tps = st["eval_count"] / (st["eval_duration"] / 1e9) if st["eval_duration"] else 0
            note = f"  warnings: {'; '.join(soft)}" if soft else ""
            if soft:
                warnings.append(f"{u.label}: {'; '.join(soft)}")
            log(f"    ok in {dt:.0f}s, {st['eval_count']} tokens, {tps:.1f} tok/s, attempts {st['attempts']}{note}")
    except KeyboardInterrupt:
        log("interrupted; progress so far is saved")

    elapsed = time.time() - t0
    avg = tokens / (gen_ns / 1e9) if gen_ns else 0
    log(f"done: {done} translated, {len(failed)} failed, {len(warnings)} with warnings, "
        f"{elapsed/60:.1f} min, {tokens} tokens, {avg:.1f} tok/s average")
    log(f"output: {out}")
    for w in warnings:
        log(f"  warning  {w}")
    for f_ in failed:
        log(f"  failed   {f_}")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
