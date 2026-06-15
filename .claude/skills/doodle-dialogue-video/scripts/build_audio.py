#!/usr/bin/env python3
"""
Build the voices+SFX audio track for a doodle-dialogue video AND print the
authoritative beat timing.

Each line mp3 is padded to its slot (line + --gap silence) and the slots are
concatenated; a soft whoosh is mixed in at every cut (start of beats 2..N),
louder before any --emphasis beat. The printed `slot` per beat is what you put
in segments.txt, and the printed start/end are the caption times — so audio,
captions and video stay in sync.

Usage:
  python3 build_audio.py --out inputs/audio.mp3 --gap 0.4 \
      work/audio/line1.mp3 work/audio/line2.mp3 ... [--emphasis 6] [--no-sfx]

(Pass lines in beat order. For two beats that share a still, pass that beat's
combined line mp3 once and treat it as one slot.)
"""
import argparse
import os
import subprocess
import tempfile


def dur(p):
    return float(subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "csv=p=0", p], capture_output=True, check=True
    ).stdout.decode().strip())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("lines", nargs="+")
    ap.add_argument("--out", required=True)
    ap.add_argument("--gap", type=float, default=0.4)
    ap.add_argument("--whoosh-vol", dest="whoosh_vol", type=float, default=0.30)
    ap.add_argument("--emphasis", type=int, action="append", default=[],
                    help="1-based beat index to hit with a louder whoosh (repeatable)")
    ap.add_argument("--no-sfx", dest="no_sfx", action="store_true")
    a = ap.parse_args()

    n = len(a.lines)
    slots = [dur(p) + a.gap for p in a.lines]
    starts, t = [], 0.0
    for s in slots:
        starts.append(t)
        t += s

    tmp = tempfile.mkdtemp()
    inputs, parts = [], []
    for i, p in enumerate(a.lines):
        inputs += ["-i", p]
        parts.append(f"[{i}:a]apad=whole_dur={slots[i]:.4f}[v{i}]")
    parts.append("".join(f"[v{i}]" for i in range(n)) +
                 f"concat=n={n}:v=0:a=1[voices]")
    mapout = "[voices]"

    if not a.no_sfx and n > 1:
        whoosh = os.path.join(tmp, "whoosh.wav")
        subprocess.run(
            ["ffmpeg", "-nostdin", "-y", "-v", "error", "-f", "lavfi",
             "-i", "anoisesrc=color=pink:duration=0.35:amplitude=0.6",
             "-af", "highpass=f=250,lowpass=f=4200,afade=t=in:st=0:d=0.07,afade=t=out:st=0.12:d=0.23",
             "-ar", "44100", "-ac", "2", whoosh], check=True)
        wi = n
        inputs += ["-i", whoosh]
        nw = n - 1
        parts.append(f"[{wi}:a]asplit={nw}" + "".join(f"[w{j}]" for j in range(nw)))
        mix = ["[voices]"]
        for j in range(nw):
            cut_ms = int(round(starts[j + 1] * 1000))
            vol = 0.55 if (j + 2) in a.emphasis else a.whoosh_vol
            parts.append(f"[w{j}]adelay={cut_ms}|{cut_ms},volume={vol}[d{j}]")
            mix.append(f"[d{j}]")
        parts.append("".join(mix) +
                     f"amix=inputs={len(mix)}:duration=first:dropout_transition=0:normalize=0[a]")
        mapout = "[a]"

    subprocess.run(
        ["ffmpeg", "-nostdin", "-y", "-v", "error", *inputs,
         "-filter_complex", ";".join(parts), "-map", mapout,
         "-c:a", "libmp3lame", "-q:a", "2", a.out], check=True)

    print(f"wrote {a.out}  total={t:.3f}s")
    print("beat   start     end      slot   (slot -> segments.txt seconds; start/end -> caption times)")
    for i in range(n):
        print(f"{i+1:>4}  {starts[i]:8.3f} {starts[i]+slots[i]:8.3f} {slots[i]:7.3f}")


if __name__ == "__main__":
    main()
