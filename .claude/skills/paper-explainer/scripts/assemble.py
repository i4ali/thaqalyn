#!/usr/bin/env python3
"""Assemble a paper-explainer episode: shots fitted to VO line timings + reference-style captions.

usage: assemble.py --episode output/paper-explainer/hud [--animatic] [--out final.mp4]
Expects in the episode dir:
  shots.json   [{"id","line","type":"hero|plx|still","src":path,"move":"push|...","zoom":0.08,"parallax":0.035}]  (line = VO line index; zoom/parallax optional, plx only)
  episode.json {"title": "...\\N...", "endcard": "..."}   (title card text; endcard only used when the last shot is a still)
  vo/vo.mp3, vo/vo.lines.json, vo/vo.words.json   (from vo.py)
--animatic: use parallax from the still for hero shots too (no Wan clips needed).
Hero clips are retimed to the line duration with motion interpolation; plx/still shots are rendered
at the exact duration. Captions: ASS, all-caps white with dark outline, low third, word reveal.
"""
import argparse, json, os, subprocess, sys, tempfile

W, H, FPS = 1080, 1920, 24
LEAD = 0.6      # silence before VO
TAIL = 1.8      # hold after last line
FONT = "Avenir Next Condensed Heavy"
HERE = os.path.dirname(os.path.abspath(__file__))

def run(cmd): subprocess.run(cmd, check=True)

def probe_dur(p):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p]).decode().strip())

def fit_hero(src, dur, out):
    d0 = probe_dur(src)
    f = dur / d0
    # minterpolate stops at the last source frame, so a retimed clip came out ~f/16 s short and the
    # shortfalls accumulated along the concat (Fatiha: -1.7 s by shot 9, picture ahead of VO/captions).
    # tpad clones the last frame past the end and -frames:v cuts to the exact frame count.
    n = round(dur * FPS)
    vf = (f"setpts={f:.5f}*PTS,minterpolate=fps={FPS}:mi_mode=mci:mc_mode=aobmc:vsbmc=1,"
          f"tpad=stop_mode=clone:stop_duration=3,scale={W}:{H}:flags=lanczos,setsar=1")
    run(["ffmpeg", "-v", "error", "-y", "-i", src, "-vf", vf, "-frames:v", str(n), "-r", str(FPS), "-c:v", "libx264", "-crf", "15", "-pix_fmt", "yuv420p", out])

def render_plx(src, dur, move, out, zoom=None, parallax=None):
    cmd = [sys.executable, os.path.join(HERE, "parallax.py"), "--image", src, "--out", out, "--seconds", f"{dur:.3f}", "--fps", str(FPS), "--move", move]
    if zoom is not None: cmd += ["--zoom", str(zoom)]
    if parallax is not None: cmd += ["--parallax", str(parallax)]
    run(cmd)

def render_still(src, dur, out):
    run(["ffmpeg", "-v", "error", "-y", "-loop", "1", "-i", src, "-t", f"{dur:.3f}", "-vf", f"scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},setsar=1", "-r", str(FPS), "-c:v", "libx264", "-crf", "15", "-pix_fmt", "yuv420p", out])

def ass_time(t):
    t = max(t, 0); h = int(t // 3600); m = int(t % 3600 // 60); s = t % 60
    return f"{h}:{m:02d}:{s:05.2f}"

def build_ass(words, lines, title, endcard, path, used=None):
    hdr = f"""[Script Info]
ScriptType: v4.00+
PlayResX: {W}
PlayResY: {H}
WrapStyle: 2

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Cap,{FONT},56,&H00FFFFFF,&H00FFFFFF,&H00141414,&H80000000,0,0,0,0,100,100,1,0,1,4,2,2,90,90,330,1
Style: Title,{FONT},96,&H00FFFFFF,&H00FFFFFF,&H00141414,&H80000000,0,0,0,0,100,100,2,0,1,6,3,8,80,80,260,1
Style: End,{FONT},64,&H00FFFFFF,&H00FFFFFF,&H00141414,&H80000000,0,0,0,0,100,100,3,0,1,5,2,2,80,80,300,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    ev = []
    if title:
        t0, t1, txt = title
        ev.append(f"Dialogue: 1,{ass_time(t0)},{ass_time(t1)},Title,,0,0,0,,{{\\fad(250,400)}}{txt}")
    # chunk words per line into phrases of <= 28 chars (32 if closing on punctuation); reveal word by word
    by_line = {}
    for w in words:
        if used is None or w["line"] in used: by_line.setdefault(w["line"], []).append(w)
    for li, ws in by_line.items():
        if endcard and li == endcard[0]: continue
        chunks, cur = [], []
        for w in ws:
            joined = len(" ".join(x["w"] for x in cur + [w]))
            closes = w["w"][-1] in ",.:;?!" and joined <= 32   # let a closing word join
            if cur and not closes and joined > 28: chunks.append(cur); cur = []
            cur.append(w)
            if len(cur) >= 2 and w["w"][-1] in ",.:;?!": chunks.append(cur); cur = []   # break at punctuation
        if cur: chunks.append(cur)
        if len(chunks) > 1 and len(chunks[-1]) == 1:   # no orphan single-word phrase
            orphan = chunks.pop()                       # pop FIRST: `chunks[-2] += chunks.pop()` evaluated the pop
            chunks[-1].extend(orphan)                   # before the store and wrote the merge one slot too far (Fatiha 2026-09-04)
        for ci, ch in enumerate(chunks):
            nxt = chunks[ci + 1][0]["start"] if ci + 1 < len(chunks) else ch[-1]["end"] + 0.35
            for i, w in enumerate(ch):
                s = w["start"] + LEAD
                e = (ch[i + 1]["start"] if i + 1 < len(ch) else nxt) + LEAD
                txt = " ".join(x["w"] for x in ch[:i + 1]).upper()
                ev.append(f"Dialogue: 0,{ass_time(s)},{ass_time(e)},Cap,,0,0,0,,{txt}")
    if endcard:
        li, t0, t1, txt = endcard
        ev.append(f"Dialogue: 1,{ass_time(t0)},{ass_time(t1)},End,,0,0,0,,{{\\fad(300,300)}}{txt}")
    open(path, "w", encoding="utf-8").write(hdr + "\n".join(ev) + "\n")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--episode", required=True); ap.add_argument("--out")
    ap.add_argument("--animatic", action="store_true"); ap.add_argument("--reuse", action="store_true", help="skip shots whose work clip already exists")
    ap.add_argument("--title", help="title card text (\\N for a line break); default: 'title' in <episode>/episode.json")
    ap.add_argument("--endcard", help="end card text, only used when the last shot is a 'still'; default: 'endcard' in episode.json")
    a = ap.parse_args()
    E = a.episode
    meta_path = os.path.join(E, "episode.json")
    meta = json.load(open(meta_path)) if os.path.exists(meta_path) else {}
    title = a.title or meta.get("title")
    if not title: sys.exit("no title: pass --title or put {\"title\": ...} in " + meta_path)
    endcard = a.endcard or meta.get("endcard", "")
    slug = os.path.basename(os.path.normpath(E))
    shots = json.load(open(os.path.join(E, "shots.json")))
    lines = json.load(open(os.path.join(E, "vo", "vo.lines.json")))
    words = json.load(open(os.path.join(E, "vo", "vo.words.json")))
    out = a.out or os.path.join(E, f"{slug}_animatic.mp4" if a.animatic else f"{slug}_final.mp4")
    work = os.path.join(E, "work"); os.makedirs(work, exist_ok=True)

    # shot windows: from its line start to the next shot's line start (first shot from 0)
    bounds = []
    for i, s in enumerate(shots):
        t0 = 0.0 if i == 0 else lines[s["line"]]["start"] + LEAD
        t1 = (lines[shots[i + 1]["line"]]["start"] + LEAD) if i + 1 < len(shots) else lines[s["line"]]["end"] + LEAD + TAIL
        bounds.append((t0, t1))
    total = bounds[-1][1]

    clips = []
    for s, (t0, t1) in zip(shots, bounds):
        dur = t1 - t0
        c = os.path.join(work, f"{s['id']}.mp4")
        kind = s["type"]
        if kind == "hero" and (a.animatic or not os.path.exists(s["src"])):
            kind = "plx"; src = s.get("still", s["src"])
        else:
            src = s["src"]
        print(f"{s['id']:>20}  {kind:5s}  {t0:6.2f}-{t1:6.2f}  ({dur:.2f}s)", flush=True)
        if a.reuse and os.path.exists(c): clips.append(c); continue
        if kind == "hero": fit_hero(src, dur, c)
        elif kind == "plx": render_plx(src, dur, s.get("move", "push"), c, s.get("zoom"), s.get("parallax"))
        else: render_still(src, dur, c)
        clips.append(c)

    lst = os.path.join(work, "concat.txt")
    open(lst, "w").write("".join(f"file '{os.path.abspath(c)}'\n" for c in clips))
    video = os.path.join(work, "video.mp4")
    run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", video])

    ass = os.path.join(work, "captions.ass")
    end_line = shots[-1]["line"] if shots[-1]["type"] == "still" else None
    build_ass(words, lines, (0.3, 3.2, title), (end_line, bounds[-1][0] + 0.2, total, endcard) if end_line is not None else None, ass, used={s["line"] for s in shots})

    vo = os.path.join(E, "vo", "vo.mp3")
    cut = lines[shots[-1]["line"]]["end"] + 0.2   # drop any recorded lines after the last used shot
    run(["ffmpeg", "-v", "error", "-y", "-i", video, "-i", vo,
         "-filter_complex", f"[1:a]atrim=0:{cut:.3f},afade=t=out:st={cut-0.2:.3f}:d=0.2,adelay={int(LEAD*1000)}|{int(LEAD*1000)},loudnorm=I=-16:TP=-1.5:LRA=11,apad[a]",
         "-vf", f"ass={ass}", "-map", "0:v", "-map", "[a]", "-t", f"{total:.3f}",
         "-c:v", "libx264", "-crf", "17", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart", out])
    print("wrote", out, f"({total:.1f}s)")

if __name__ == "__main__":
    main()
