#!/usr/bin/env python3
"""Journey teaser builder - ~37s TikTok teaser (1080x1920@30) for a surah journey,
rendered entirely with ffmpeg from a cover master. No Higgsfield credits.

Usage:
  python3 build_teaser.py --config teaser_config.json --workdir /tmp/work --out /path/to/outdir

Requires: ffmpeg 8+ built with harfbuzz (Arabic shaping), macOS fonts
(Georgia + GeezaPro). Verified on ffmpeg 8.0 / macOS.

Structure (7 segments, 0.6s crossfades, ~37.4s):
  S1 3.5s  hook          black + descending light wisp + 2 title cards
  S2 6.0s  beat 1        art alive: slow push-in + pulsing glow, 2 lines
  S3 7.5s  beat 2        deeper drift, 3 lines (3rd gold)
  S4 7.0s  the verse     darker grade, Arabic + English (Arabic optional)
  S5 4.5s  the turn      pull back / rise, 2 lines (2nd gold question)
  S6 7.0s  journey tease blurred veil + 3 movement titles + gold closer
  S7 5.5s  end card      veil + rounded poster + CTA pill + brand line

Safe areas: all text y 300-1450, x 90-990 (clears TikTok top tabs, right rail,
caption zone). No price/premium language belongs in any caption.
"""
import argparse, json, os, subprocess, sys

W, H, FPS = 1080, 1920, 30
GEORGIA = "/System/Library/Fonts/Supplemental/Georgia.ttf"
GEORGIA_B = "/System/Library/Fonts/Supplemental/Georgia Bold.ttf"
GEEZA = "/System/Library/Fonts/GeezaPro.ttc"
IVORY, GOLD, SAND, DARK, DIM = "0xf3ecd9", "0xd9b36a", "0xffe9bd", "0x0a1512", "0xb9c6bc"

def run(args, name):
    p = subprocess.run(args, capture_output=True, text=True)
    if p.returncode != 0:
        print(f"FAIL {name}\n{p.stderr[-3000:]}"); sys.exit(1)
    print(f"ok {name}")

def alpha(t_in, t_out, f=0.5):
    return (f"if(lt(t\\,{t_in})\\,0\\,if(lt(t\\,{t_in+f})\\,(t-{t_in})/{f}\\,"
            f"if(lt(t\\,{t_out-f})\\,1\\,if(lt(t\\,{t_out})\\,({t_out}-t)/{f}\\,0))))")

def text(txt, font, size, color, y, t_in, t_out, border=True):
    txt = txt.replace("'", "\\'").replace(":", "\\:").replace(",", "\\,")
    d = (f"drawtext=fontfile='{font}':text='{txt}':fontsize={size}:fontcolor={color}"
         f":x=(w-text_w)/2:y={y}:alpha='{alpha(t_in, t_out)}'")
    if border:
        d += ":borderw=2:bordercolor=black@0.55:shadowx=0:shadowy=3:shadowcolor=black@0.55"
    return d

def glow_src(dur, cx, cy, base_op, amp, period=75, size=800):
    r = size // 2
    src = (f"color=c=black:s={size}x{size}:r={FPS}:d={dur},format=rgba,"
           f"geq=r=255:g=200:b=120:"
           f"a='({base_op}+{amp}*sin(2*PI*N/{period}))*230*pow(max(0\\,1-hypot(X-{r}\\,Y-{r})/{r})\\,2)'")
    return src, cx - r, cy - r

def warn_width(label, s, size):
    est = len(s) * size * 0.50
    if est > 900:
        print(f"WARN {label}: '{s}' est {est:.0f}px wide (>900) - shorten or shrink font")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    cfg = json.load(open(a.config))
    os.makedirs(a.workdir, exist_ok=True); os.makedirs(a.out, exist_ok=True)
    os.chdir(a.workdir)

    slug = cfg["slug"]; src = cfg["src"]
    crop_x = cfg.get("crop_x", 280)
    gx0, gy0 = cfg["glow"]["x"], cfg["glow"]["y"]
    s2f = cfg.get("s2_focus", 0.58)
    s3f = cfg.get("s3_focus", [0.45, 0.72])
    s4f = cfg.get("s4_focus", 0.66)
    s5f = cfg.get("s5_focus", [0.40, 0.18])
    hook, beat1, beat2 = cfg["hook"], cfg["beat1"], cfg["beat2"]
    verse, turn, tease = cfg["verse"], cfg["turn"], cfg["tease"]
    assert len(beat2) == 3 and len(tease["movements"]) == 3, "beat2 needs 3 lines, tease needs 3 movements"
    for lbl, s, sz in [("hook1", hook[0], 58), ("beat1.1", beat1[0], 50),
                       ("beat2.2", beat2[1], 40), ("turn1", turn[0], 48)]:
        warn_width(lbl, s, sz)

    # ---------- static assets ----------
    run(["ffmpeg","-y","-loglevel","error","-i",src,"-vf",
         f"crop=1296:2304:{crop_x}:0,scale=2592:4608:flags=lanczos","base.png"],"base")
    run(["ffmpeg","-y","-loglevel","error","-f","lavfi",
         "-i","color=c=black:s=240x240,format=rgba","-frames:v","1","-vf",
         "geq=r=255:g=214:b=140:a='255*pow(max(0\\,1-hypot(X-120\\,Y-120)/120)\\,1.8)'","wisp.png"],"wisp")
    run(["ffmpeg","-y","-loglevel","error","-i",src,"-vf",
         "scale=380:475:flags=lanczos,format=rgba,"
         "geq=r='r(X\\,Y)':g='g(X\\,Y)':b='b(X\\,Y)':"
         "a='if(gt(hypot(max(0\\,28-X)+max(0\\,X-(W-29))\\,max(0\\,28-Y)+max(0\\,Y-(H-29)))\\,28)\\,0\\,255)'",
         "-frames:v","1","poster.png"],"poster")
    run(["ffmpeg","-y","-loglevel","error","-f","lavfi",
         "-i","color=c=black:s=560x92,format=rgba","-frames:v","1","-vf",
         "geq=r=217:g=179:b=106:"
         "a='if(gt(hypot(max(0\\,46-X)+max(0\\,X-(W-47))\\,max(0\\,46-Y)+max(0\\,Y-(H-47)))\\,46)\\,0\\,255)'",
         "pill.png"],"pill")
    run(["ffmpeg","-y","-loglevel","error","-i","base.png","-vf",
         "scale=1080:1920,boxblur=26:2,eq=brightness=-0.06,"
         f"drawbox=x=0:y=0:w={W}:h={H}:color=black@0.50:t=fill","-frames:v","1","veil.png"],"veil")

    enc = ["-r",str(FPS),"-c:v","libx264","-crf","16","-preset","veryfast","-pix_fmt","yuv420p"]

    # S1 hook
    d1 = 3.5
    fc = (f"color=c=0x050d0b:s={W}x{H}:r={FPS}:d={d1}[bg];"
          f"[bg][1:v]overlay=x=420:y='-240+1350*pow(t/{d1}\\,0.9)'[b1];"
          f"[b1]{text(hook[0], GEORGIA, 58, IVORY, 760, 0.35, 3.3)},"
          f"{text(hook[1], GEORGIA, 44, GOLD, 906, 1.5, 3.45)}[v]")
    run(["ffmpeg","-y","-loglevel","error","-f","lavfi","-i",f"nullsrc=s=8x8:d={d1}",
         "-loop","1","-t",str(d1),"-i","wisp.png","-filter_complex",fc,"-map","[v]",*enc,"s1.mp4"],"s1")

    # S2 beat 1
    d2, n2 = 6.0, int(6.0*FPS)
    g, gx, gy = glow_src(d2, gx0, gy0+30, 0.42, 0.30)
    fc = (f"[0:v]select='eq(n\\,0)',zoompan=d={n2}:z='1+0.10*on/{n2-1}':"
          f"x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*{s2f}':s={W}x{H}:fps={FPS}[art];"
          f"{g}[gl];[art][gl]overlay=x={gx}:y={gy}[a2];"
          f"[a2]{text(beat1[0], GEORGIA, 50, IVORY, 380, 0.4, 5.8)},"
          f"{text(beat1[1], GEORGIA, 40, '0xd8d2c2', 465, 1.8, 5.8)}[v]")
    run(["ffmpeg","-y","-loglevel","error","-loop","1","-t",str(d2),"-i","base.png",
         "-filter_complex",fc,"-map","[v]","-t",str(d2),*enc,"s2.mp4"],"s2")

    # S3 beat 2
    d3, n3 = 7.5, int(7.5*FPS)
    g, gx, gy = glow_src(d3, gx0, gy0, 0.5, 0.32)
    fc = (f"[0:v]select='eq(n\\,0)',zoompan=d={n3}:z='1.28+0.14*on/{n3-1}':"
          f"x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*({s3f[0]}+{round(s3f[1]-s3f[0],3)}*on/{n3-1})':s={W}x{H}:fps={FPS}[art];"
          f"{g}[gl];[art][gl]overlay=x={gx}:y={gy}[a3];"
          f"[a3]{text(beat2[0], GEORGIA, 46, IVORY, 380, 0.5, 7.2)},"
          f"{text(beat2[1], GEORGIA, 40, IVORY, 462, 1.6, 7.2)},"
          f"{text(beat2[2], GEORGIA, 46, GOLD, 552, 3.2, 7.2)}[v]")
    run(["ffmpeg","-y","-loglevel","error","-loop","1","-t",str(d3),"-i","base.png",
         "-filter_complex",fc,"-map","[v]","-t",str(d3),*enc,"s3.mp4"],"s3")

    # S4 the verse (Arabic optional)
    d4, n4 = 7.0, int(7.0*FPS)
    g, gx, gy = glow_src(d4, gx0, gy0-30, 0.62, 0.34)
    if verse.get("arabic"):
        vtxt = (f"{text(verse['arabic'], GEEZA, 54, SAND, 560, 0.4, 6.6)},"
                f"{text(verse['english'][0], GEORGIA, 40, IVORY, 700, 1.6, 6.6)},"
                f"{text(verse['english'][1], GEORGIA, 40, IVORY, 768, 2.4, 6.6)}")
    else:
        vtxt = (f"{text(verse['english'][0], GEORGIA, 46, SAND, 620, 0.6, 6.6)},"
                f"{text(verse['english'][1], GEORGIA, 46, SAND, 700, 1.8, 6.6)}")
    fc = (f"[0:v]select='eq(n\\,0)',zoompan=d={n4}:z='1.42+0.03*on/{n4-1}':"
          f"x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*{s4f}':s={W}x{H}:fps={FPS},"
          f"eq=brightness=-0.10:saturation=0.9[art];"
          f"{g}[gl];[art][gl]overlay=x={gx}:y={gy}[a4];[a4]{vtxt}[v]")
    run(["ffmpeg","-y","-loglevel","error","-loop","1","-t",str(d4),"-i","base.png",
         "-filter_complex",fc,"-map","[v]","-t",str(d4),*enc,"s4.mp4"],"s4")

    # S5 the turn
    d5, n5 = 4.5, int(4.5*FPS)
    fc = (f"[0:v]select='eq(n\\,0)',zoompan=d={n5}:z='1.15-0.10*on/{n5-1}':"
          f"x='(iw-iw/zoom)/2':y='(ih-ih/zoom)*({s5f[0]}-{round(s5f[0]-s5f[1],3)}*on/{n5-1})':s={W}x{H}:fps={FPS}[art];"
          f"[art]hue=b='0.04*sin(2*PI*t/3)'[a5];"
          f"[a5]{text(turn[0], GEORGIA, 48, IVORY, 380, 0.3, 4.35)},"
          f"{text(turn[1], GEORGIA, 42, GOLD, 464, 1.3, 4.35)}[v]")
    run(["ffmpeg","-y","-loglevel","error","-loop","1","-t",str(d5),"-i","base.png",
         "-filter_complex",fc,"-map","[v]","-t",str(d5),*enc,"s5.mp4"],"s5")

    # S6 journey tease
    d6 = 7.0
    m = tease["movements"]
    fc = (f"[0:v]hue=b='0.03*sin(2*PI*t/4)'[bg];"
          f"[bg]{text(tease['eyebrow'], GEORGIA_B, 30, GOLD, 430, 0.3, 6.7)},"
          f"{text(m[0][0], GEORGIA, 50, IVORY, 570, 0.9, 6.7)},"
          f"{text(m[0][1], GEORGIA, 33, DIM, 640, 1.1, 6.7)},"
          f"{text(m[1][0], GEORGIA, 50, IVORY, 780, 2.1, 6.7)},"
          f"{text(m[1][1], GEORGIA, 33, DIM, 850, 2.3, 6.7)},"
          f"{text(m[2][0], GEORGIA, 50, IVORY, 990, 3.3, 6.7)},"
          f"{text(m[2][1], GEORGIA, 33, DIM, 1060, 3.5, 6.7)},"
          f"{text(tease['closer'], GEORGIA, 38, GOLD, 1230, 4.7, 6.7)}[v]")
    run(["ffmpeg","-y","-loglevel","error","-loop","1","-t",str(d6),"-i","veil.png",
         "-filter_complex",fc,"-map","[v]","-t",str(d6),*enc,"s6.mp4"],"s6")

    # S7 end card
    d7 = 5.5
    fc = (f"[0:v]drawbox=x=0:y=0:w={W}:h={H}:color=black@0.25:t=fill[bg];"
          f"[1:v]format=rgba,fade=in:st=0.3:d=0.5:alpha=1[po];[bg][po]overlay=x=350:y=640[c1];"
          f"[2:v]format=rgba,fade=in:st=0.9:d=0.5:alpha=1[pi];[c1][pi]overlay=x=260:y=1240[c2];"
          f"[3:v]format=rgba,fade=in:st=0.4:d=0.4:alpha=1[wi];"
          f"[c2][wi]overlay=x=420:y='400+210*min(1\\,max(0\\,(t-0.4)/1.2))'[c3];"
          f"[c3]{text('Continue the journey in the app.', GEORGIA, 44, IVORY, 1156, 0.7, 99)},"
          f"{text('DOWNLOAD THE APP', GEORGIA_B, 30, DARK, 1268, 1.1, 99, border=False)},"
          f"{text('THAQALAYN  -  INSIDE THE SURAH', GEORGIA, 28, '0xcfe0d5', 1392, 1.4, 99)}[v]")
    run(["ffmpeg","-y","-loglevel","error",
         "-loop","1","-t",str(d7),"-i","veil.png",
         "-loop","1","-t",str(d7),"-i","poster.png",
         "-loop","1","-t",str(d7),"-i","pill.png",
         "-loop","1","-t",str(d7),"-i","wisp.png",
         "-filter_complex",fc,"-map","[v]","-t",str(d7),*enc,"s7.mp4"],"s7")

    # concat + ambient audio
    durs = [d1, d2, d3, d4, d5, d6, d7]
    offs, acc = [], 0.0
    for d in durs[:-1]:
        acc += d - 0.6
        offs.append(round(acc, 2))
    total = round(offs[-1] + durs[-1], 2)
    fc = ""
    prev = "0:v"
    for i, o in enumerate(offs):
        out = f"x{i}" if i < len(offs) - 1 else "vout"
        fc += f"[{prev}][{i+1}:v]xfade=transition=fade:duration=0.6:offset={o}[{out}];"
        prev = out
    fc += (f"anoisesrc=color=brown:r=48000:d={total},lowpass=f=240,volume=0.45,"
           f"tremolo=f=0.1:d=0.55[nz];"
           f"sine=frequency=52:r=48000:d={total},volume=0.10,tremolo=f=0.13:d=0.5[dr];"
           f"[nz][dr]amix=inputs=2:duration=first,afade=t=in:d=1.2,"
           f"afade=t=out:st={total-2.4}:d=2.4[aout]")
    dst = os.path.join(a.out, f"{slug}_teaser.mp4")
    run(["ffmpeg","-y","-loglevel","error",
         "-i","s1.mp4","-i","s2.mp4","-i","s3.mp4","-i","s4.mp4","-i","s5.mp4","-i","s6.mp4","-i","s7.mp4",
         "-filter_complex",fc,"-map","[vout]","-map","[aout]",
         "-c:v","libx264","-crf","19","-preset","slow","-pix_fmt","yuv420p",
         "-c:a","aac","-b:a","128k","-movflags","+faststart","-t",str(total),dst],"final")
    print(f"DONE {dst} total={total}s")

if __name__ == "__main__":
    main()
