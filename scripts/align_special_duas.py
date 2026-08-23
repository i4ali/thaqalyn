# -*- coding: utf-8 -*-
"""Per-word timings for the Duas & Ziyarat recitations (karaoke word highlight).

Forced-aligns each dua's Arabic text (special_duas.json) against its duas.org
recitation with torchaudio's MMS_FA aligner. Arabic goes in romanized via
uroman (the MMS aligner's dictionary is a-z'). Star tokens at both ends absorb
any intro/outro audio not in the transcript; STAR_BEFORE adds mid-text stars
where a recitation repeats a passage the text carries once.

Output: Thaqalayn/Data/special_dua_timings.json (bundled with the app):
  {"version": 1,
   "duas": {id: {"duration": secs,
                 "words": [[segIndex, tokenIndex, startCs, endCs], ...]}}}
segIndex indexes the dua's FULL segments array (notes included), tokenIndex
the whitespace-split Arabic tokens of that segment. Times are centiseconds.

QA per dua: greedy-decodes the emission inside every aligned segment window and
compares its consonant skeleton against the expected romanization (difflib
ratio); low-ratio segments are flagged for a manual listen. This catches
misalignment that per-frame scores (unreliable on melodic recitation) miss.

Run:  source .venv/bin/activate
      python scripts/align_special_duas.py [--ids kumayl,ashura]
"""
import argparse, difflib, json, os, re, subprocess, sys, time, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DUAS_JSON = os.path.join(ROOT, "Thaqalayn", "Data", "special_duas.json")
OUT_JSON = os.path.join(ROOT, "Thaqalayn", "Data", "special_dua_timings.json")
AUDIO_DIR = os.path.join(ROOT, "scripts", "special_duas_src", "audio")

# Insert a star token BEFORE these segment indices (full-array indices): the
# star absorbs recitation audio that the text does not carry at that point
# (e.g. a repeated la'n/salam pass). Filled in as QA demands.
STAR_BEFORE = {}

QA_FLAG_RATIO = 0.45   # greedy-decode similarity below this -> flag segment


def roman_word(ur, w):
    r = ur.romanize_string(w).lower()
    return re.sub(r"[^a-z']", "", r)


def skeleton(s):
    """Consonant skeleton for QA comparison: melodic recitation stretches
    vowels, so compare consonants only."""
    return re.sub(r"[aeiouw'ʼ]", "", s)


def load_audio(dua):
    os.makedirs(AUDIO_DIR, exist_ok=True)
    mp3 = os.path.join(AUDIO_DIR, f"{dua['id']}.mp3")
    if not os.path.exists(mp3):
        print(f"  downloading {dua['audioUrl']}")
        urllib.request.urlretrieve(dua["audioUrl"], mp3)
    wav = os.path.join(AUDIO_DIR, f"{dua['id']}_16k.wav")
    if not os.path.exists(wav):
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", mp3,
                        "-ar", "16000", "-ac", "1", wav], check=True)
    import wave as wavmod
    import numpy as np
    with wavmod.open(wav, "rb") as wf:
        sr = wf.getframerate()
        raw = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16)
    return raw.astype(np.float32) / 32768.0, sr


def align_dua(dua, mms, ur):
    import numpy as np
    import torch

    pcm, sr = load_audio(dua)
    dur = len(pcm) / sr
    print(f"  audio {dur:.1f}s")

    # -------- text: flat alignable word list over FULL segment indices
    words, word_ref = [], []           # romanized tokens / (seg, tok, arabic)
    star_before = set(STAR_BEFORE.get(dua["id"], []))
    star_slots = []                    # positions in `words` before which a star goes
    dropped = 0
    for si, seg in enumerate(dua["segments"]):
        ar = seg.get("ar")
        if not ar:
            continue
        if si in star_before:
            star_slots.append(len(words))
        for ti, tok in enumerate(ar.split()):
            r = roman_word(ur, tok)
            if r:
                words.append(r)
                word_ref.append((si, ti, tok))
            else:
                dropped += 1
    print(f"  text: {len(words)} words" + (f" ({dropped} punctuation tokens skipped)" if dropped else ""))

    # -------- emissions in 30 s chunks (the model is convolutional+local
    # enough that plain concatenation is fine for alignment)
    CHUNK = 30 * sr
    t0 = time.time()
    ems = []
    with torch.inference_mode():
        for off in range(0, len(pcm), CHUNK):
            chunk = torch.from_numpy(pcm[off:off + CHUNK]).unsqueeze(0)
            em, _ = mms["model"](chunk)
            ems.append(em[0])
    emission = torch.cat(ems, dim=0)
    n_frames = emission.size(0)
    ratio = len(pcm) / n_frames / sr
    print(f"  emissions: {n_frames} frames in {time.time() - t0:.1f}s")

    # -------- align (stars at both ends + configured mid-text slots)
    tok_seq, star_set = ["*"], {0}
    for wi, w in enumerate(words):
        if wi in star_slots:
            star_set.add(len(tok_seq))
            tok_seq.append("*")
        tok_seq.append(w)
    star_set.add(len(tok_seq))
    tok_seq.append("*")

    t0 = time.time()
    spans = mms["aligner"](emission, mms["tokenizer"](tok_seq))
    print(f"  aligned in {time.time() - t0:.1f}s")
    spans = [sp for i, sp in enumerate(spans) if i not in star_set]
    assert len(spans) == len(words)

    out, scores = [], []
    for (si, ti, ar_tok), span_list in zip(word_ref, spans):
        s = span_list[0].start * ratio
        e = span_list[-1].end * ratio
        sc = sum(sp.score * (sp.end - sp.start) for sp in span_list) / \
             max(1, sum(sp.end - sp.start for sp in span_list))
        out.append({"seg": si, "tok": ti, "start": s, "end": e})
        scores.append(sc)

    # -------- QA: greedy-decode each segment's window vs expected skeleton
    labels = mms["labels"]
    seg_windows = {}
    for w in out:
        s0, e0 = seg_windows.get(w["seg"], (w["start"], w["end"]))
        seg_windows[w["seg"]] = (min(s0, w["start"]), max(e0, w["end"]))

    def greedy(s, e):
        chunk = torch.from_numpy(pcm[int(s * sr):int(e * sr)]).unsqueeze(0)
        if chunk.size(1) < 400:
            return ""
        with torch.inference_mode():
            em, _ = mms["qa_model"](chunk)
        idx = em[0].argmax(-1).tolist()
        res, prev = [], -1
        for i in idx:
            if i != prev and i < len(labels):
                res.append(labels[i])
            prev = i
        return "".join(c if c != "-" else "" for c in res)

    flagged = []
    ratios = []
    for si, (s, e) in sorted(seg_windows.items()):
        exp = skeleton("".join(roman_word(ur, t) for t in dua["segments"][si]["ar"].split()))
        got = skeleton(greedy(s, e))
        r = difflib.SequenceMatcher(None, exp, got).ratio()
        ratios.append(r)
        if r < QA_FLAG_RATIO:
            flagged.append((si, r, s, e))

    gaps = sorted(((b["start"] - a["end"], a, b) for a, b in zip(out, out[1:])),
                  reverse=True, key=lambda g: g[0])

    print(f"  QA: avg frame score {sum(scores) / len(scores):.3f} | "
          f"avg segment decode-ratio {sum(ratios) / len(ratios):.3f} | "
          f"coverage {out[0]['start']:.1f}s -> {out[-1]['end']:.1f}s of {dur:.1f}s")
    for g, a, b in gaps[:4]:
        if g >= 4.0:
            print(f"  QA: {g:5.1f}s gap after seg {a['seg']} ({a['end']:.1f}s) -> seg {b['seg']}")
    if flagged:
        print(f"  QA: {len(flagged)} FLAGGED segments (decode-ratio < {QA_FLAG_RATIO}):")
        for si, r, s, e in flagged[:12]:
            print(f"       seg {si:3d} ratio {r:.2f} @ {s:.1f}-{e:.1f}s : "
                  f"{dua['segments'][si]['ar'][:44]}")
    else:
        print("  QA: no flagged segments")

    words_cs = [[w["seg"], w["tok"], round(w["start"] * 100), round(w["end"] * 100)]
                for w in out]
    return {"duration": round(dur, 2), "words": words_cs}, flagged


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ids", help="comma-separated dua ids (default: all with audio)")
    args = ap.parse_args()

    import torch, torchaudio, uroman
    bundle = torchaudio.pipelines.MMS_FA
    mms = {
        "model": bundle.get_model(with_star=True).eval(),
        "qa_model": bundle.get_model(with_star=False).eval(),
        "tokenizer": bundle.get_tokenizer(),
        "aligner": bundle.get_aligner(),
        "labels": bundle.get_labels(star=None),
    }
    ur = uroman.Uroman()

    data = json.load(open(DUAS_JSON))
    want = set(args.ids.split(",")) if args.ids else None
    existing = {}
    if os.path.exists(OUT_JSON):
        existing = json.load(open(OUT_JSON)).get("duas", {})

    result, any_flags = dict(existing), False
    for dua in data["duas"]:
        if not dua.get("audioUrl"):
            continue
        if want and dua["id"] not in want:
            continue
        print(f"\n=== {dua['id']} ===")
        timings, flagged = align_dua(dua, mms, ur)
        result[dua["id"]] = timings
        any_flags = any_flags or bool(flagged)

    json.dump({"version": 1, "duas": result}, open(OUT_JSON, "w"),
              separators=(",", ":"))
    kb = os.path.getsize(OUT_JSON) / 1024
    print(f"\nwrote {OUT_JSON} ({kb:.0f} KB)")
    if any_flags:
        print("NOTE: flagged segments above need a manual listen before shipping.")
        sys.exit(2)


if __name__ == "__main__":
    main()
