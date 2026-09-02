#!/usr/bin/env python3
"""Continuous narration with word timestamps (ElevenLabs with-timestamps).

usage: vo.py --lines lines.txt --out vo.mp3   (one VO line per non-empty line in the file)
Writes vo.mp3, vo.words.json [{w,start,end,line}], vo.lines.json [{line,text,start,end}].
Strips ﷺ for TTS (house policy, see build_journey_audio.py).
"""
import argparse, base64, json, os, re, sys, urllib.request

VOICE = "yU0EHuTjuZhsJiFqbAVB"   # Bear
MODEL = "eleven_v3"
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "use_speaker_boost": True}

def sanitize(t):
    t = t.replace("ﷺ", "")
    return re.sub(r"\s{2,}", " ", t).replace(" .", ".").replace(" ,", ",").strip()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lines", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--model", default=MODEL); ap.add_argument("--voice", default=VOICE); ap.add_argument("--key-env", default="ELEVENLABS_API_KEY")
    a = ap.parse_args()
    key = os.environ[a.key_env]
    lines = [sanitize(l) for l in open(a.lines, encoding="utf-8").read().splitlines() if l.strip()]
    text = "\n\n".join(lines)
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{a.voice}/with-timestamps?output_format=mp3_44100_128",
        data=json.dumps({"text": text, "model_id": a.model, "voice_settings": SETTINGS}).encode("utf-8"),
        headers={"xi-api-key": key, "Content-Type": "application/json"})
    try:
        r = json.load(urllib.request.urlopen(req, timeout=300))
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code}: {e.read().decode()[:500]}")
    open(a.out, "wb").write(base64.b64decode(r["audio_base64"]))
    al = r.get("alignment") or r.get("normalized_alignment")
    chars, st, en = al["characters"], al["character_start_times_seconds"], al["character_end_times_seconds"]
    # group characters into words; track which line each char belongs to via offsets into `text`
    line_of = []
    for i, l in enumerate(lines):
        line_of += [i] * len(l) + [i, i]   # + "\n\n"
    words, cur, cs, ce, cl = [], "", None, None, None
    for idx, (c, s, e) in enumerate(zip(chars, st, en)):
        li = line_of[idx] if idx < len(line_of) else cl
        if c.isspace():
            if cur: words.append({"w": cur, "start": cs, "end": ce, "line": cl}); cur = ""
        else:
            if not cur: cs, cl = s, li
            cur += c; ce = e
    if cur: words.append({"w": cur, "start": cs, "end": ce, "line": cl})
    base = os.path.splitext(a.out)[0]
    json.dump(words, open(base + ".words.json", "w"), indent=1, ensure_ascii=False)
    lj = []
    for i, l in enumerate(lines):
        ws = [w for w in words if w["line"] == i]
        lj.append({"line": i, "text": l, "start": ws[0]["start"], "end": ws[-1]["end"]})
    json.dump(lj, open(base + ".lines.json", "w"), indent=1, ensure_ascii=False)
    for l in lj: print(f'{l["start"]:6.2f}-{l["end"]:6.2f}  {l["text"][:70]}')
    print("total", f'{lj[-1]["end"]:.1f}s', "->", a.out)

if __name__ == "__main__":
    main()
