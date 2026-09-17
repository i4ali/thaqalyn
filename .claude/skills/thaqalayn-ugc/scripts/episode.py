#!/usr/bin/env python3
"""One Thaqalayn UGC episode (hook talking-head + app demo) with the locked presenter, from one approved pack.

  episode.py plan     --hook H4            validate pack.json, compute durations and prices, print the gate-1 summary + recording brief
  episode.py approve  --hook H4            record the user's gate-1 approval in the pack (run only after they said yes)
  episode.py check    --hook H4            everything needed before spending: approval, B-roll on disk, tools, balance
  episode.py run      --hook H4 [--dry-run] [--reuse-hook take.mp4] [--reuse-vo take.mp4]
                                           hook take (720p) + voiceover take (480p) in parallel, verify, assemble, final encode
  episode.py fix      --hook H4 --vo 4-5 | --hook-take [--reuse FILE]
                                           regenerate only those voiceover sentences (one short take) or the hook take, then re-assemble
  episode.py assemble --hook H4            rebuild the demo and the final from the parts on disk (free)

Episode folder: ~/ugc/thaqalayn/episodes/<HOOK>/ with pack.json, shots/, hook/, vo/, demo/, <HOOK>_final.mp4, report.md.
Fixed inputs: assets/character.jpg (@image1), assets/voice_ref.mp3 (@audio1), assets/prompt_template.txt.
Money is spent only inside `run` and `fix`, and `run` refuses unless `check` passes.
"""
import argparse, base64, datetime, difflib, json, os, re, shutil, subprocess, sys, tempfile
sys.path.insert(0, os.path.expanduser("~/.claude/skills/ugc-talking-head-video/scripts"))

HERE = os.path.dirname(os.path.abspath(__file__)); SKILL = os.path.dirname(HERE)
REPO = os.path.abspath(os.path.join(SKILL, "..", "..", ".."))
GLOBAL = os.path.expanduser("~/.claude/skills/ugc-talking-head-video/scripts")
EPISODES = os.path.expanduser("~/ugc/thaqalayn/episodes")
ASSETS = os.path.join(SKILL, "assets")
CHAR, VOICE, TEMPLATE = (os.path.join(ASSETS, n) for n in ("character.jpg", "voice_ref.mp3", "prompt_template.txt"))
ENV = os.path.join(REPO, ".env"); HOOKS_MD = os.path.join(ASSETS, "hooks.md")
RATE = {"480p": 0.1186, "720p": 0.26683, "1080p": 0.462}   # USD/s, reapi.video-gen.seedance-2-5.unrestricted
PLACE_IN, TAIL = 0.4, 0.6                                  # sentence starts 0.4 s into its screen; 0.6 s of screen after it ends
W, H, CROP_Y = 720, 1280, 118                              # 9:16 output; 118 px off the top of a scaled iPhone recording = status bar


def die(m): sys.exit(f"[episode] {m}")
def log(m): print(f"[episode] {m}", file=sys.stderr)
def sh(cmd, check=True):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if check and r.returncode: die(f"{' '.join(str(c) for c in cmd[:3])} failed:\n{(r.stderr or r.stdout)[-800:]}")
    return r.stdout
def ffdur(p): return float(sh(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p]).strip() or 0)
def ffdim(p):
    w, h = sh(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=p=0", p]).strip().split(",")[:2]
    return int(w), int(h)
def norm(s): return re.sub(r"[^a-z0-9']", "", s.lower().replace("’", "'")).strip("'")
def wordlist(s): return [w for w in re.split(r"\s+", s.strip()) if w]
def epdir(hook): return os.path.join(EPISODES, hook.upper())
def load(hook):
    p = os.path.join(epdir(hook), "pack.json")
    if not os.path.isfile(p): die(f"no pack at {p}. Copy assets/pack_template.json there, fill it, then `plan`.")
    return json.load(open(p))
def save(hook, pack): json.dump(pack, open(os.path.join(epdir(hook), "pack.json"), "w"), indent=2, ensure_ascii=False)
def today(): return datetime.date.today().isoformat()


# ---------- prompt ----------
def build_prompt(script, pron):
    t = open(TEMPLATE).read().replace("{script}", script)
    lines = [f'The word {w} is pronounced "{how}".' for w, how in pron.items() if re.search(r"\b" + re.escape(w) + r"\b", script, re.I)]
    return re.sub(r'The name Thaqalayn is pronounced "tha-ka-LAYN"\.\n?', ("\n".join(lines) + "\n") if lines else "", t)


# ---------- plan / approve / check ----------
def duration_for(words, lo=4, hi=20): return max(lo, min(hi, round(words / 4)))

def plan(a):
    pack = load(a.hook); d = epdir(a.hook); os.makedirs(os.path.join(d, "shots"), exist_ok=True)
    for k in ("hook_script", "vo_script", "shots", "header_hook", "header_demo", "caption", "hashtags", "pronunciation"):
        if not pack.get(k): die(f"pack.json is missing `{k}`")
    if '"' in pack["hook_script"] or any('"' in s for s in pack["vo_script"]): die("scripts must not contain double quotes (the prompt wraps them in quotes)")
    if len(pack["vo_script"]) != len(pack["shots"]): die(f"{len(pack['vo_script'])} voiceover sentences but {len(pack['shots'])} shots; one sentence per shot")
    hw = len(wordlist(pack["hook_script"])); vw = sum(len(wordlist(s)) for s in pack["vo_script"])
    if hw > 80: die(f"hook script is {hw} words; over 80 one take drifts. Split it.")
    hd, vd = duration_for(hw, 10, 20), duration_for(vw, 4, 20)
    eleven = vo_engine(pack) == "elevenlabs"
    ph, pv = hd * RATE[pack.get("resolution_hook", "720p")], (0.0 if eleven else vd * RATE[pack.get("resolution_vo", "480p")])
    pack["computed"] = {"hook_words": hw, "hook_duration_s": hd, "vo_words": vw, "vo_duration_s": vd,
                        "price_hook": round(ph, 2), "price_vo": round(pv, 2), "price_total": round(ph + pv, 2)}
    for k in ("phrases_hook", "phrases_vo"):
        if pack.get(k) and pack[k][0].startswith("optional"): pack[k] = None
    save(a.hook, pack)
    print(f"\n=== {a.hook.upper()} - GATE 1: approve this pack ===\n")
    print(f"HOOK ({hw} words, {hd} s at {pack.get('resolution_hook','720p')}, ${ph:.2f}):\n  {pack['hook_script']}\n")
    print(f"DEMO VOICEOVER ({vw} words, " + (f"ElevenLabs voice {pack.get('voice_id')}, free" if eleven else f"{vd} s at {pack.get('resolution_vo','480p')}, ${pv:.2f}") + "), one sentence per screen:")
    for i, (s, sh_) in enumerate(zip(pack["vo_script"], pack["shots"]), 1): print(f"  {i}. {s}\n     screen: {sh_['screen']}")
    used = [w for w in pack["pronunciation"] if re.search(r"\b" + re.escape(w) + r"\b", pack["hook_script"] + " " + " ".join(pack["vo_script"]), re.I)]
    print(f"\nPRONUNCIATION HINTS IN USE: {', '.join(used) or 'none'}")
    print(f"HEADER hook: {pack['header_hook']}   demo: {pack['header_demo']}")
    print(f"CAPTION: {pack['caption']}\nHASHTAGS: {pack['hashtags']}")
    print(f"\nPRICE: ${ph + pv:.2f} total (refunded on failure). Nothing runs until `approve`, then `check` passes.\n")
    print("=== RECORDING BRIEF (what the user records on the phone, before anything is generated) ===")
    print("Screen recording, portrait, Do Not Disturb on, dark theme, reading text size one step up. Hold each screen still for the seconds shown;")
    print("scroll slowly if at all. Either one clip per shot, or one continuous clip with start/end seconds filled in per shot.")
    for i, sh_ in enumerate(pack["shots"], 1): print(f"  shot {i}: {sh_['screen']}  (hold {sh_.get('hold_s', 4)} s) -> {sh_.get('file', 'shots/%02d.mov' % i)}")
    print(f"\nDrop the files into {d}/shots/ then run `check`.")

def approve(a):
    pack = load(a.hook); pack["status"] = {"approved": True, "approved_on": today()}; save(a.hook, pack); log(f"{a.hook.upper()} approved on {today()}")

def shot_clips(hook, pack):
    """[(abs_file, start, end)] per shot, validated."""
    d = epdir(hook); out = []
    for i, s in enumerate(pack["shots"], 1):
        f = os.path.join(d, s.get("file") or f"shots/{i:02d}.mov")
        if not os.path.isfile(f): return None, f"shot {i}: missing {f}"
        dur = ffdur(f); st, en = float(s.get("start", 0)), float(s.get("end", dur))
        if en > dur + 0.05 or en - st < 2.0: return None, f"shot {i}: segment {st}-{en} s is invalid for a {dur:.1f} s file (need at least 2 s)"
        out.append((f, st, min(en, dur)))
    return out, None

def balance():
    m = re.search(r"\$([\d.]+)", sh(["treg", "balance"], check=False)); return float(m.group(1)) if m else 0.0

def check(a, quiet=False):
    pack = load(a.hook); ok = True
    def row(name, good, note=""):
        nonlocal ok; ok = ok and good
        if not quiet: print(f"  [{'ok' if good else 'MISSING'}] {name}{(': ' + note) if note else ''}")
    if not quiet: print(f"\n=== {a.hook.upper()} - pre-flight ===")
    row("pack computed (plan ran)", bool(pack.get("computed", {}).get("price_total")))
    row("gate 1 approved by the user", bool(pack.get("status", {}).get("approved")), pack.get("status", {}).get("approved_on") or "run `approve` after the user says yes")
    clips, err = shot_clips(a.hook, pack); row("B-roll on disk, one clip or segment per voiceover sentence", clips is not None, err or f"{len(clips)} shots")
    for p, what in ((CHAR, "character.jpg"), (VOICE, "voice_ref.mp3"), (TEMPLATE, "prompt_template.txt"), (ENV, "project .env"),
                    (f"{GLOBAL}/seedance_treg.py", "global runner"), (f"{GLOBAL}/caption_burn.py", "global caption script"), (f"{GLOBAL}/gh_host.py", "global hoster")):
        row(what, os.path.isfile(p), p if not os.path.isfile(p) else "")
    for t in ("treg", "gh", "ffmpeg", "ffprobe"): row(f"{t} on PATH", shutil.which(t) is not None)
    row("ELEVENLABS_API_KEY in this repo's .env", os.path.isfile(ENV) and any(l.startswith("ELEVENLABS_API_KEY=") and len(l.strip()) > 20 for l in open(ENV)))
    row("gh logged in", subprocess.run(["gh", "auth", "status"], capture_output=True).returncode == 0)
    if vo_engine(pack) == "elevenlabs":
        try:
            code = subprocess.run(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", f"https://api.elevenlabs.io/v1/voices/{pack.get('voice_id')}", "-H", f"xi-api-key: {eleven_key()}"], capture_output=True, text=True).stdout
        except SystemExit: code = "no key"
        row(f"ElevenLabs voice {pack.get('voice_id')} reachable", code == "200", f"HTTP {code}" if code != "200" else "")
    need = float(pack.get("computed", {}).get("price_total") or 0); bal = balance()
    row(f"treg balance covers ${need:.2f}", bal >= need, f"balance ${bal:.2f}")
    if not quiet: print("  RESULT:", "ready to run" if ok else "NOT ready; fix the MISSING lines, nothing has been spent", "\n")
    return ok


# ---------- voiceover engines ----------
def vo_engine(pack): return pack.get("vo_engine") or ("elevenlabs" if pack.get("voice_id") else "seedance")

def eleven_key():
    import caption_burn as cb
    return cb.project_key(ENV)

def eleven_vo(hook, pack, sentences, offset=0):
    """Read each sentence with the cloned voice via ElevenLabs with-timestamps; write vo/s{k}.wav + vo/s{k}.json.
    Words come from the alignment, so captions never need a transcript. Free on the plan."""
    d = epdir(hook); os.makedirs(f"{d}/vo", exist_ok=True); key = eleven_key(); vid = pack["voice_id"]
    settings = {"stability": 0.4, "similarity_boost": 0.85, "style": 0.35, "use_speaker_boost": True, "speed": float(pack.get("tts_speed") or 1.0)}
    spell = pack.get("tts_spellings") or {}
    for i, s in enumerate(sentences):
        k = offset + i + 1; text = s
        for w, how in spell.items(): text = re.sub(r"\b" + re.escape(w) + r"\b", how, text)
        body = {"text": text, "model_id": pack.get("tts_model") or "eleven_multilingual_v2", "voice_settings": settings}
        r = subprocess.run(["curl", "-s", f"https://api.elevenlabs.io/v1/text-to-speech/{vid}/with-timestamps?output_format=mp3_44100_128",
                            "-H", f"xi-api-key: {key}", "-H", "Content-Type: application/json", "-d", json.dumps(body)], capture_output=True, text=True)
        try: j = json.loads(r.stdout)
        except ValueError: die(f"ElevenLabs returned no JSON for sentence {k}: {r.stdout[:200]}")
        if "audio_base64" not in j: die(f"ElevenLabs failed on sentence {k}: {json.dumps(j)[:300]}")
        open(f"{d}/vo/s{k}.mp3", "wb").write(base64.b64decode(j["audio_base64"]))
        sh(["ffmpeg", "-v", "error", "-y", "-i", f"{d}/vo/s{k}.mp3", "-ac", "1", "-ar", "44100", f"{d}/vo/s{k}.wav"])
        al = j.get("alignment") or {}; chars, st, en = al.get("characters", []), al.get("character_start_times_seconds", []), al.get("character_end_times_seconds", [])
        words, cur = [], None
        for ch, a, b in zip(chars, st, en):
            if ch.isspace():
                if cur: words.append(cur); cur = None
            else:
                if cur is None: cur = {"word": ch, "start": round(a, 3), "end": round(b, 3)}
                else: cur["word"] += ch; cur["end"] = round(b, 3)
        if cur: words.append(cur)
        # captions show the scripted spelling even when tts_spellings changed what was read
        sw = wordlist(s)
        if len(sw) == len(words):
            for w, orig in zip(words, sw): w["word"] = orig
        json.dump({"words": words}, open(f"{d}/vo/s{k}.json", "w"), indent=1)
        log(f"voiceover sentence {k}: {len(words)} words, {words[-1]['end'] if words else 0:.2f} s (ElevenLabs)")
    # one joined file for the Scribe check and the report
    lst = f"{d}/vo/list.txt"; open(lst, "w").write("".join(f"file 's{k}.wav'\n" for k in range(1, len(pack["vo_script"]) + 1) if os.path.isfile(f"{d}/vo/s{k}.wav")))
    sh(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", f"{d}/vo/take.wav"])


# ---------- generation ----------
def host(path):
    url = sh([sys.executable, f"{GLOBAL}/gh_host.py", path]).strip()
    if not url.startswith("http"): die(f"hosting {path} failed")
    return url

def unhost_voice():
    try:
        owner = json.loads(sh(["gh", "api", "user"]))["login"]
        for f in json.loads(sh(["gh", "api", f"repos/{owner}/ugc-refs/contents/"]) or "[]"):
            if f["name"].endswith("_voice_ref.mp3"):
                with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as t: json.dump({"message": f"remove {f['name']}", "sha": f["sha"]}, t); p = t.name
                r = subprocess.run(["gh", "api", "-X", "DELETE", f"repos/{owner}/ugc-refs/contents/{f['name']}", "--input", p], capture_output=True, text=True); os.unlink(p)
                log(f"hosted voice reference {'deleted' if r.returncode == 0 else 'NOT deleted'}")
    except Exception as e: log(f"warning: could not delete the hosted voice reference: {e}")

def seedance(prompt_file, duration, resolution, out, img_url, aud_url):
    """Popen the global runner; returns the process. Cost is parsed from its stderr when it ends."""
    return subprocess.Popen([sys.executable, f"{GLOBAL}/seedance_treg.py", "--image", img_url, "--audio", aud_url, "--prompt-file", prompt_file,
                             "--duration", str(duration), "--resolution", resolution, "--out", out], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

def finish(proc, label):
    out = proc.communicate()[0]; m = re.search(r"cost \$([\d.]+)", out)
    if proc.returncode: die(f"{label} take failed (not charged):\n{out[-900:]}")
    log(f"{label} take done, cost ${m.group(1) if m else '?'}"); return float(m.group(1)) if m else 0.0

def analyze(video):
    r = subprocess.run([sys.executable, f"{GLOBAL}/caption_burn.py", "--video", video, "--analyze", "--env-file", ENV], capture_output=True, text=True)
    if r.returncode: die(f"Scribe analysis failed:\n{r.stdout[-400:]}{r.stderr[-400:]}")
    return json.load(open(video + ".words.json")), r.stdout


# ---------- transcript alignment ----------
def align(script_words, tr_words):
    """Returns (map: transcript idx -> script idx or None, mismatches [(script, heard)])."""
    a = [norm(w) for w in script_words]; b = [norm(w["word"]) for w in tr_words]
    m, mism = {}, []
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if tag == "equal":
            for k in range(i2 - i1): m[j1 + k] = i1 + k
        elif tag == "replace" and (i2 - i1) == (j2 - j1):
            for k in range(i2 - i1): m[j1 + k] = i1 + k; mism.append((script_words[i1 + k], tr_words[j1 + k]["word"]))
        elif tag == "replace":
            for k in range(j2 - j1): m[j1 + k] = i1 if k == 0 else None
            mism.append((" ".join(script_words[i1:i2]), " ".join(w["word"] for w in tr_words[j1:j2])))
        elif tag == "delete": mism.append((" ".join(script_words[i1:i2]), "(dropped)"))
        elif tag == "insert":
            for k in range(j2 - j1): m[j1 + k] = None
            mism.append(("(nothing)", " ".join(w["word"] for w in tr_words[j1:j2])))
    return m, mism

def verify(words_json, script, pron, label):
    """Compare a take's transcript with its script; fix the spelling of pronunciation-hint words in the words JSON so
    captions read right; return report lines and the (possibly corrected) words."""
    data = json.load(open(words_json)); tw = data["words"]; sw = wordlist(script)
    m, mism = align(sw, tw); risky = {norm(w) for w in pron} | {"thaqalayn"}; flagged = []
    for j, i in m.items():
        if i is not None and norm(tw[j]["word"]) != norm(sw[i]) and norm(sw[i]) in risky:
            flagged.append((sw[i], tw[j]["word"])); tw[j]["word"] = sw[i]
    json.dump(data, open(words_json, "w"), indent=1)
    span = tw[-1]["end"] - tw[0]["start"] if tw else 0; wpm = len(tw) / span * 60 if span else 0
    gaps = [(tw[i]["end"], tw[i + 1]["start"] - tw[i]["end"]) for i in range(len(tw) - 1) if tw[i + 1]["start"] - tw[i]["end"] >= 0.25]
    lines = [f"### {label}", f"- words: {len(tw)} heard / {len(sw)} scripted, {wpm:.0f} wpm, {len(gaps)} pause(s) over 0.25 s" + (" at " + ", ".join(f"{t:.1f}s ({g:.2f}s)" for t, g in gaps) if gaps else "")]
    for s, h in flagged: lines.append(f"- LISTEN: scripted \"{s}\", Scribe heard \"{h}\". Likely mispronounced. Captions show \"{s}\". Fix: `fix --vo <sentence>` or `--hook-take`.")
    for s, h in mism:
        if not any(s == fs for fs, _ in flagged): lines.append(f"- differs: scripted \"{s}\", heard \"{h}\"")
    if not flagged and not mism: lines.append("- transcript matches the script word for word")
    return lines, data, m


# ---------- assembly ----------
def phrases_for(pack_phrases, script, words, amap):
    """Turn pack phrases (written against the script) into transcript-word phrases, or None to auto-chunk."""
    if not pack_phrases: return None
    sw = wordlist(script); spans, pos = [], 0
    for ph in pack_phrases:
        n = len(wordlist(ph)); spans.append((pos, pos + n)); pos += n
    if pos != len(sw): die(f"phrases cover {pos} script words but the script has {len(sw)}")
    out = [[] for _ in spans]; cur = 0
    for j, w in enumerate(words):
        i = amap.get(j)
        if i is not None:
            while cur < len(spans) - 1 and i >= spans[cur][1]: cur += 1
        out[cur].append(w["word"])
    return [" ".join(p) for p in out if p]

def caption(video, header, phrases, words_json, out):
    cmd = [sys.executable, f"{GLOBAL}/caption_burn.py", "--video", video, "--header", header, "--words", words_json, "--out", out, "--env-file", ENV]
    if phrases:
        pf = out + ".phrases.txt"; open(pf, "w").write("\n".join(phrases) + "\n"); cmd += ["--phrases", pf]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode: die(f"captioning {os.path.basename(video)} failed:\n{r.stdout[-300:]}{r.stderr[-500:]}")

def split_vo(hook, pack, take, words, amap):
    """Write vo/s{k}.wav and vo/s{k}.json (words relative to the wav) for each sentence of the take."""
    d = epdir(hook); os.makedirs(f"{d}/vo", exist_ok=True)
    bounds, pos = [], 0
    for s in pack["vo_script"]: n = len(wordlist(s)); bounds.append((pos, pos + n)); pos += n
    groups = [[] for _ in bounds]; cur = 0
    for j, w in enumerate(words):
        i = amap.get(j)
        if i is not None:
            while cur < len(bounds) - 1 and i >= bounds[cur][1]: cur += 1
        groups[cur].append(w)
    sh(["ffmpeg", "-v", "error", "-y", "-i", take, "-vn", "-ac", "1", "-ar", "44100", f"{d}/vo/take.wav"])
    for k, g in enumerate(groups, 1):
        if not g: die(f"voiceover sentence {k} has no transcribed words; rerun `fix --vo {k}`")
        s0, s1 = max(0, g[0]["start"] - 0.06), g[-1]["end"] + 0.08
        sh(["ffmpeg", "-v", "error", "-y", "-ss", f"{s0:.3f}", "-to", f"{s1:.3f}", "-i", f"{d}/vo/take.wav", f"{d}/vo/s{k}.wav"])
        json.dump({"words": [{"word": w["word"], "start": round(w["start"] - s0, 3), "end": round(w["end"] - s0, 3)} for w in g]}, open(f"{d}/vo/s{k}.json", "w"), indent=1)

def vf_for(file):
    w, h = ffdim(file); sh_ = int(round(W * h / w / 2) * 2)
    return f"scale={W}:{sh_},crop={W}:{H}:0:{min(CROP_Y, sh_ - H)}" if sh_ >= H else f"scale={W}:{sh_},pad={W}:{H}:0:(oh-ih)/2:color=black"

def assemble(a):
    pack = load(a.hook); d = epdir(a.hook); H_ = a.hook.upper(); os.makedirs(f"{d}/demo", exist_ok=True)
    hook_take = f"{d}/hook/take.mp4"
    if not os.path.isfile(hook_take): die("no hook take on disk; run `run` first")
    clips, err = shot_clips(a.hook, pack)
    if err: die(err)
    n = len(clips); sent = []
    for k in range(1, n + 1):
        if not os.path.isfile(f"{d}/vo/s{k}.wav"): die(f"missing vo/s{k}.wav; run `run` or `fix --vo {k}`")
        sent.append((f"{d}/vo/s{k}.wav", json.load(open(f"{d}/vo/s{k}.json"))["words"], ffdur(f"{d}/vo/s{k}.wav")))
    # timeline: each screen holds at least its clip length, and at least PLACE_IN + sentence + TAIL
    timeline, t = [], 0.0
    for (f, st, en), (wav, ws, sl), shot in zip(clips, sent, pack["shots"]):
        need = max(en - st, float(shot.get("hold_s", 4)), PLACE_IN + sl + TAIL); timeline.append((f, st, en, need, t)); t += need
    total = t
    inputs, vparts, aparts, dwords = [], [], [], []
    for k, ((f, st, en, need, t0), (wav, ws, sl)) in enumerate(zip(timeline, sent)):
        inputs += ["-i", f, "-i", wav]; vi, ai = 2 * k, 2 * k + 1
        vparts.append(f"[{vi}:v]trim={st:.3f}:{en:.3f},setpts=PTS-STARTPTS,{vf_for(f)},fps=30,tpad=stop_mode=clone:stop_duration={max(0, need - (en - st)):.3f}[v{k}]")
        ms = int((t0 + PLACE_IN) * 1000); aparts.append(f"[{ai}:a]adelay={ms}|{ms}[a{k}]")
        dwords += [{"word": w["word"], "start": round(w["start"] + t0 + PLACE_IN, 3), "end": round(w["end"] + t0 + PLACE_IN, 3)} for w in ws]
    fc = ";".join(vparts + aparts) + ";" + "".join(f"[v{k}]" for k in range(n)) + f"concat=n={n}:v=1:a=0[v];" + "".join(f"[a{k}]" for k in range(n)) + f"amix=inputs={n}:normalize=0,apad=whole_dur={total:.3f}[a]"
    sh(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", fc, "-map", "[v]", "-map", "[a]", "-t", f"{total:.3f}", "-c:v", "libx264", "-crf", "18", "-preset", "medium",
        "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "160k", "-ar", "44100", "-ac", "2", f"{d}/demo/demo.mp4"])
    json.dump({"text": " ".join(w["word"] for w in dwords), "words": dwords}, open(f"{d}/demo/demo.mp4.words.json", "w"), indent=1)
    # captions on both parts
    hw = json.load(open(hook_take + ".words.json"))["words"]; hmap, _ = align(wordlist(pack["hook_script"]), hw)
    caption(hook_take, pack["header_hook"], phrases_for(pack.get("phrases_hook"), pack["hook_script"], hw, hmap), hook_take + ".words.json", f"{d}/hook/hook_captioned.mp4")
    vscript = " ".join(pack["vo_script"]); vmap, _ = align(wordlist(vscript), dwords)
    caption(f"{d}/demo/demo.mp4", pack["header_demo"], phrases_for(pack.get("phrases_vo"), vscript, dwords, vmap), f"{d}/demo/demo.mp4.words.json", f"{d}/demo/demo_captioned.mp4")
    final = f"{d}/{H_}_final.mp4"
    sh(["ffmpeg", "-v", "error", "-y", "-i", f"{d}/hook/hook_captioned.mp4", "-i", f"{d}/demo/demo_captioned.mp4", "-filter_complex",
        "[0:v]fps=30,settb=AVTB[v0];[1:v]fps=30,settb=AVTB[v1];[0:a]aresample=44100[a0];[1:a]aresample=44100[a1];[v0][a0][v1][a1]concat=n=2:v=1:a=1[v][a]",
        "-map", "[v]", "-map", "[a]", "-r", "30", "-c:v", "libx264", "-profile:v", "high", "-level", "4.1", "-crf", "18", "-preset", "medium", "-pix_fmt", "yuv420p", "-tag:v", "avc1",
        "-c:a", "aac", "-b:a", "160k", "-ar", "44100", "-ac", "2", "-movflags", "+faststart", "-brand", "mp42", final])
    lvl = sh(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=level", "-of", "csv=p=0", final]).strip()
    if lvl != "41": die(f"final encode level is {lvl}, expected 41")
    fd = ffdur(final); sh(["ffmpeg", "-v", "error", "-y", "-i", final, "-vf", f"fps=12/{fd:.3f},scale=180:-1,tile=12x1", "-frames:v", "1", f"{d}/{H_}_final_strip.jpg"])
    log(f"final -> {final} ({fd:.1f} s, level 4.1, 30 fps)  strip -> {d}/{H_}_final_strip.jpg")
    return final, fd

def report(hook, pack, sections, costs):
    d = epdir(hook); lines = [f"# {hook.upper()} report - {today()}", ""]
    for s in sections: lines += s + [""]
    lines += ["### Cost", *[f"- {k}: ${v:.2f}" for k, v in costs.items()], f"- total: ${sum(costs.values()):.2f}", "",
              "### Not verifiable here", "- voice likeness and lip-sync: judge by ear and eye", "",
              "### Posting", f"- caption: {pack['caption']}", f"- hashtags: {pack['hashtags']}", "- sound: original audio, nothing added", "- pinned comment: the App Store link"]
    open(f"{d}/report.md", "w").write("\n".join(lines) + "\n"); return f"{d}/report.md"

def mark_done(hook, cost):
    if cost <= 0: return
    try:
        t = open(HOOKS_MD).read(); H_ = hook.upper()
        new = re.sub(rf"^\| {H_} \| ([^|]*) \| [^\n]*$", lambda m: f"| {H_} | {m.group(1)} | **done {today()}**, ${cost:.2f}, `~/ugc/thaqalayn/episodes/{H_}/` |", t, count=1, flags=re.M)
        if new != t: open(HOOKS_MD, "w").write(new); log(f"hooks.md status for {H_} updated")
    except Exception as e: log(f"warning: could not update hooks.md: {e}")


# ---------- run / fix ----------
def run(a):
    pack = load(a.hook); d = epdir(a.hook); H_ = a.hook.upper(); c = pack.get("computed") or {}
    if not check(a, quiet=a.dry_run): die("pre-flight failed; nothing spent")
    os.makedirs(f"{d}/hook", exist_ok=True); os.makedirs(f"{d}/vo", exist_ok=True)
    open(f"{d}/hook/prompt.txt", "w").write(build_prompt(pack["hook_script"], pack["pronunciation"]))
    open(f"{d}/vo/prompt.txt", "w").write(build_prompt(" ".join(pack["vo_script"]), pack["pronunciation"]))
    eleven = vo_engine(pack) == "elevenlabs"
    log(f"hook: {c['hook_words']} words, {c['hook_duration_s']} s, ${c['price_hook']:.2f} | voiceover: {c['vo_words']} words, " + ("ElevenLabs, free" if eleven else f"{c['vo_duration_s']} s, ${c['price_vo']:.2f}") + f" | total ${c['price_total']:.2f}")
    if a.dry_run: log("dry run: prompts written, nothing submitted"); return
    costs = {}
    if a.reuse_hook and (a.reuse_vo or eleven):
        shutil.copy(a.reuse_hook, f"{d}/hook/take.mp4")
        if a.reuse_vo: shutil.copy(a.reuse_vo, f"{d}/vo/take.mp4")
    else:
        img, aud = host(CHAR), host(VOICE)
        ph = None if a.reuse_hook else seedance(f"{d}/hook/prompt.txt", c["hook_duration_s"], pack.get("resolution_hook", "720p"), f"{d}/hook/take.mp4", img, aud)
        pv = None if (a.reuse_vo or eleven) else seedance(f"{d}/vo/prompt.txt", c["vo_duration_s"], pack.get("resolution_vo", "480p"), f"{d}/vo/take.mp4", img, aud)
        log("submitted, waiting (usually 2 to 5 minutes)" + ("; voiceover from ElevenLabs meanwhile" if eleven else ""))
        if eleven and not a.reuse_vo: eleven_vo(a.hook, pack, pack["vo_script"])
        if ph: costs["hook take"] = finish(ph, "hook")
        else: shutil.copy(a.reuse_hook, f"{d}/hook/take.mp4")
        if pv: costs["voiceover take"] = finish(pv, "voiceover")
        elif a.reuse_vo: shutil.copy(a.reuse_vo, f"{d}/vo/take.mp4")
        unhost_voice()
    if eleven and a.reuse_hook and not a.reuse_vo: eleven_vo(a.hook, pack, pack["vo_script"])
    sections = []
    _, out = analyze(f"{d}/hook/take.mp4"); lines, _, _ = verify(f"{d}/hook/take.mp4.words.json", pack["hook_script"], pack["pronunciation"], "Hook take"); sections.append(lines)
    hd = ffdur(f"{d}/hook/take.mp4"); hw = json.load(open(f"{d}/hook/take.mp4.words.json"))["words"]
    if hw and hd - hw[-1]["end"] > 1.0: sections[-1].append(f"- speech ends {hd - hw[-1]['end']:.1f} s before the clip ends: it rushed")
    sh(["ffmpeg", "-v", "error", "-y", "-i", f"{d}/hook/take.mp4", "-vf", "select='not(mod(n\\,50))',scale=220:-1,tile=9x1", "-frames:v", "1", f"{d}/hook/take_strip.jpg"])
    if eleven and not a.reuse_vo:
        _, _ = analyze(f"{d}/vo/take.wav"); lines, _, _ = verify(f"{d}/vo/take.wav.words.json", " ".join(pack["vo_script"]), pack["pronunciation"], "Voiceover (ElevenLabs)"); sections.append(lines)
    else:
        _, _ = analyze(f"{d}/vo/take.mp4"); lines, data, vmap = verify(f"{d}/vo/take.mp4.words.json", " ".join(pack["vo_script"]), pack["pronunciation"], "Voiceover take"); sections.append(lines)
        split_vo(a.hook, pack, f"{d}/vo/take.mp4", data["words"], vmap)
    final, fd = assemble(a)
    total = sum(costs.values()); rp = report(a.hook, pack, sections, costs); mark_done(a.hook, total)
    print(f"\n=== {H_} done: {final} ({fd:.1f} s), ${total:.2f} spent. Read {rp} and {d}/hook/take_strip.jpg, then send the final to the user (gate 2). ===")

def fix(a):
    pack = load(a.hook); d = epdir(a.hook); costs = {}
    if a.hook_take:
        os.makedirs(f"{d}/hook", exist_ok=True); c = pack["computed"]
        if a.reuse: shutil.copy(a.reuse, f"{d}/hook/take.mp4")
        else:
            log(f"rerunning the hook take: {c['hook_duration_s']} s at {pack.get('resolution_hook','720p')}, ${c['price_hook']:.2f}")
            img, aud = host(CHAR), host(VOICE); costs["hook take"] = finish(seedance(f"{d}/hook/prompt.txt", c["hook_duration_s"], pack.get("resolution_hook", "720p"), f"{d}/hook/take.mp4", img, aud), "hook"); unhost_voice()
        analyze(f"{d}/hook/take.mp4"); lines, _, _ = verify(f"{d}/hook/take.mp4.words.json", pack["hook_script"], pack["pronunciation"], "Hook take (fix)"); print("\n".join(lines))
    if a.vo:
        lo, hi = (int(x) for x in (a.vo.split("-") + [a.vo])[:2]) if "-" in a.vo else (int(a.vo), int(a.vo))
        sub = pack["vo_script"][lo - 1:hi]; script = " ".join(sub); dur = duration_for(len(wordlist(script)), 4, 20)
        os.makedirs(f"{d}/vo", exist_ok=True)
        if vo_engine(pack) == "elevenlabs" and not a.reuse:
            log(f"re-reading voiceover sentences {lo}-{hi} on ElevenLabs (free); adjust tts_spellings or tts_speed in the pack first if a word or the pace was wrong")
            eleven_vo(a.hook, pack, sub, offset=lo - 1)
            final, fd = assemble(a); print(f"\n=== re-assembled: {final} ({fd:.1f} s), $0.00 ==="); return
        pf = f"{d}/vo/fix_{lo}-{hi}_prompt.txt"; open(pf, "w").write(build_prompt(script, pack["pronunciation"]))
        take = f"{d}/vo/fix_{lo}-{hi}.mp4"
        if a.reuse: shutil.copy(a.reuse, take)
        else:
            log(f"regenerating voiceover sentences {lo}-{hi}: {dur} s at {pack.get('resolution_vo','480p')}, ${dur * RATE[pack.get('resolution_vo','480p')]:.2f}")
            img, aud = host(CHAR), host(VOICE); costs[f"voiceover fix {lo}-{hi}"] = finish(seedance(pf, dur, pack.get("resolution_vo", "480p"), take, img, aud), "voiceover fix"); unhost_voice()
        analyze(take); lines, data, vmap = verify(take + ".words.json", script, pack["pronunciation"], f"Voiceover fix {lo}-{hi}"); print("\n".join(lines))
        subpack = dict(pack); subpack["vo_script"] = sub; tmp_hook = a.hook
        # split into vo/s{k}.wav for the sub-range: write to a temp dir then rename
        td = epdir(tmp_hook); split_vo_into(td, sub, take, data["words"], vmap, offset=lo - 1)
    final, fd = assemble(a)
    if costs:
        rp = f"{d}/report.md"; open(rp, "a").write(f"\n### Fix {today()}\n" + "".join(f"- {k}: ${v:.2f}\n" for k, v in costs.items()))
    print(f"\n=== re-assembled: {final} ({fd:.1f} s), ${sum(costs.values()):.2f} spent on the fix ===")

def split_vo_into(d, sentences, take, words, amap, offset):
    bounds, pos = [], 0
    for s in sentences: n = len(wordlist(s)); bounds.append((pos, pos + n)); pos += n
    groups = [[] for _ in bounds]; cur = 0
    for j, w in enumerate(words):
        i = amap.get(j)
        if i is not None:
            while cur < len(bounds) - 1 and i >= bounds[cur][1]: cur += 1
        groups[cur].append(w)
    wav = take + ".wav"; sh(["ffmpeg", "-v", "error", "-y", "-i", take, "-vn", "-ac", "1", "-ar", "44100", wav])
    for k, g in enumerate(groups):
        if not g: die(f"voiceover sentence {offset + k + 1} has no transcribed words in the fix take")
        s0, s1 = max(0, g[0]["start"] - 0.06), g[-1]["end"] + 0.08; kk = offset + k + 1
        sh(["ffmpeg", "-v", "error", "-y", "-ss", f"{s0:.3f}", "-to", f"{s1:.3f}", "-i", wav, f"{d}/vo/s{kk}.wav"])
        json.dump({"words": [{"word": w["word"], "start": round(w["start"] - s0, 3), "end": round(w["end"] - s0, 3)} for w in g]}, open(f"{d}/vo/s{kk}.json", "w"), indent=1)


def main():
    ap = argparse.ArgumentParser(); sub = ap.add_subparsers(dest="cmd", required=True)
    for name in ("plan", "approve", "check", "assemble"): sub.add_parser(name).add_argument("--hook", required=True)
    r = sub.add_parser("run"); r.add_argument("--hook", required=True); r.add_argument("--dry-run", action="store_true"); r.add_argument("--reuse-hook"); r.add_argument("--reuse-vo")
    f = sub.add_parser("fix"); f.add_argument("--hook", required=True); f.add_argument("--vo", help="sentence number or range, e.g. 4 or 4-5"); f.add_argument("--hook-take", action="store_true"); f.add_argument("--reuse")
    a = ap.parse_args()
    if a.cmd == "fix" and not (a.vo or a.hook_take): ap.error("fix needs --vo N[-M] or --hook-take")
    {"plan": plan, "approve": approve, "check": check, "run": run, "fix": fix, "assemble": assemble}[a.cmd](a)


if __name__ == "__main__": main()
