---
name: thaqalayn-ugc
description: Produce one finished Thaqalayn UGC video (hook talking-head plus app demo) with the app's one locked AI presenter, Mehdi, from a single approved pack - hook script, demo voiceover, shot list, headers, caption, hashtags and price all agreed up front, the user records the B-roll, then one run generates both takes in parallel and assembles the final. Use when asked for a Thaqalayn UGC clip, a new hook video, the next hook, a TikTok for the app with Mehdi, or to fix or re-assemble an episode. Never for a new character - he is fixed.
argument-hint: [hook number or a new hook idea, e.g. "H4" or "a hook about the Muharram journey"]
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, SendUserFile
---

# Thaqalayn UGC

One presenter, one voice, one prompt template, one pack per episode. Everything is decided and approved before any money moves, the user records the B-roll from a brief, and then one command generates both Seedance takes in parallel and delivers the finished file. Distilled from the H3 run on 2026-09-16, which took three generations and five re-assemblies because these decisions were made one at a time.

**Read first, every time:** `assets/persona.md` (who he is, the rules) and `assets/hooks.md` (the pattern, the scripts, what is used, the B-roll screen guide, posting rules). The flow as a one-page sketch the user approved: https://claude.ai/artifact/76qGm9hFs8rak7B2K5YUYi

## What is fixed

| Thing | File | Rule |
|---|---|---|
| The character | `assets/character.jpg` + `assets/character.json` | Never regenerated, re-rolled or edited. `@image1` on every take. |
| The voice reference | `assets/voice_ref.mp3` (+ `.source.txt`) | `@audio1` on every take. Never cloned in ElevenLabs. The script deletes the hosted copy after each run. |
| The prompt | `assets/prompt_template.txt` | Only the script and the pronunciation lines change. No stage directions, pauses or camera moves. |
| The pack | `assets/pack_template.json` | The single source of truth for an episode. Copied to the episode folder and filled in before gate 1. |
| Resolutions | hook 720p, voiceover 480p | The voiceover take is audio only, so 480p at 45% of the price. |
| Final encode | 30 fps, H.264 High 4.1 | Anything else fails on iPhone Photos. The script checks the level and refuses otherwise. |
| Episode folder | `~/ugc/thaqalayn/episodes/<HOOK>/` | Never inside this repo. |
| ElevenLabs key | this repo's `.env` | Read by `--env-file` only, for Scribe transcripts. No fallback. |

## The two gates

Money is spent only by `episode.py run` and `episode.py fix`. `run` refuses unless `check` passes, and `check` requires the user's recorded approval and the B-roll on disk. Never call `approve` on the user's behalf. Never call `run` because "it's probably fine".

- **Gate 1, the pack.** The user approves the exact hook script, the demo voiceover, the shot list, both headers, the caption, the hashtags and the price, in one message. Edits loop here, free.
- **Gate 2, the finished video.** The user watches `<HOOK>_final.mp4`. Fixes are surgical (one voiceover sentence for about $0.47, or the hook take for about $4) and re-assembly is free.

## Flow

### 0. Prerequisites (check silently, report only what is missing)

`treg` logged in with balance for the pack price; `gh` logged in with the public `ugc-refs` repo; the global skills at `~/.claude/skills/ugc-talking-head-video/` (with `scripts/seedance_treg.py`, `caption_burn.py`, `gh_host.py`), `~/.claude/skills/make-ugc/`, `~/.claude/skills/portrait-clone/`; `ffmpeg`; Python 3 with PIL. `episode.py check` tests all of it.

### 1. Write the pack

```bash
mkdir -p ~/ugc/thaqalayn/episodes/H4/shots
cp .claude/skills/thaqalayn-ugc/assets/pack_template.json ~/ugc/thaqalayn/episodes/H4/pack.json
```

Fill every field. The rules for each:

- **hook_script**: from `assets/hooks.md` if the user named a hook, otherwise draft 2-3 in the pattern (claim or confession, a specific number, the result, Thaqalayn named once near the end), 53-63 words, plain spelling, no diacritics, no em dashes, no double quotes. Comma-join sentences so he does not pause; one question mark at most. Every claim inside what the app ships (`assets/hooks.md` lists it; check `Thaqalayn/Thaqalayn/Data/passages_*.json` for surah coverage).
- **vo_script**: a list, one sentence per screen, 30-45 words total, naming what is on screen. The last sentence lands on the quiz screen.
- **shots**: one per voiceover sentence, in order, with the screen described concretely enough to record from and a `hold_s` of 3-4. Pick the screens from the "B-roll screen guide" in `assets/hooks.md` for the kind of hook; they must show what the hook promises and end on an action (usually the quiz).
- **header_hook / header_demo**: two short lines split on `|`, a claim or tease, one or two emoji on the second line, no app name. Same text on both unless the user asks otherwise.
- **caption / hashtags**: the rules under "Posting copy" in `assets/hooks.md`.
- **phrases_hook / phrases_vo**: hand-cut caption phrases, 1-4 words, on sense, covering the scripts in order. Or delete the lists to auto-chunk (worse).
- **pronunciation**: keep the defaults; add any new surah, imam or Arabic term in the scripts. Only words present in a script are added to its prompt. A missed hint is a $0.47 rerun.

Then:

```bash
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py plan --hook H4
```

It validates the pack, computes durations (words / 4, clamped) and prices, and prints the gate-1 summary plus the recording brief. Show both to the user verbatim.

**Gate 1.** Ask with AskUserQuestion: approve, or say what to change. On changes, edit the pack and re-run `plan`. On approval only:

```bash
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py approve --hook H4
```

### 2. The user records the B-roll

They record from the brief: one clip per shot into `shots/01.mov`, `shots/02.mov`, ... (the easy way), or one continuous recording with `start` and `end` seconds filled in per shot in the pack (the way H3 was done). Screen recording, portrait, Do Not Disturb, dark theme, reading text size one step up, each screen held still for `hold_s`. The recording's audio is ignored. If they send a continuous clip, make a strip (`ffmpeg ... fps=12/<dur>,tile=12x1`), read it, fill the start and end seconds, and re-run `plan` so the pack on disk matches.

```bash
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py check --hook H4
```

Every line must read `[ok]`. If not, fix what it names. Nothing has been spent.

### 3. One run

```bash
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py run --hook H4
```

State the price from the pack before running. The script hosts the two references, submits the hook take and the voiceover take together, waits for both, deletes the hosted voice reference, transcribes both with Scribe, compares each transcript with its script, corrects the spelling of pronunciation-hint words in the captions and flags them with LISTEN in the report, splits the voiceover into sentences by aligning the transcript to the script, cuts the B-roll per shot, places each sentence 0.4 s into its screen (holding the last frame if the screen is shorter than the sentence), burns header and captions on both parts, joins them, encodes at 30 fps level 4.1, writes `report.md`, and marks the hook done in `assets/hooks.md`.

Read `report.md` and `hook/take_strip.jpg`. Then send `<HOOK>_final.mp4` with SendUserFile and give the user the report's LISTEN lines and the pace numbers, and say plainly that voice likeness and lip-sync are theirs to judge.

**Gate 2.** The user replies: approve, or names the problem.

### 4. Fixes (only what the user names)

```bash
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py fix --hook H4 --vo 4        # one voiceover sentence, a 4 s take, about $0.47
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py fix --hook H4 --vo 4-5      # a range, one short take
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py fix --hook H4 --hook-take   # the hook take again, about $4
python3 .claude/skills/thaqalayn-ugc/scripts/episode.py assemble --hook H4          # pack edits only (headers, phrases, shot trims); free
```

State the price before a paid fix. There is no seed; a rerun is a fresh roll and can regress something else, so fix one thing per rerun. `fix` and `assemble` rebuild the final and its strip; send it again.

### 5. Posting (the user does this)

From the persona account, not the app's brand account. Original sound, nothing added. The caption and hashtags from the pack, the App Store link as a pinned comment (a new account cannot put a link in the bio), and TikTok's AI-generated content label switched on. Save to Photos from the Files share sheet, or AirDrop from the Mac.

## Rules

- The character and the voice reference never change. If a take drifts from him, rerun the take.
- Never host a real person's face or voice on `ugc-refs` except `assets/voice_ref.mp3`, and confirm the "deleted" line after every run.
- Quote the price before every paid command and say what was charged after (the report has it).
- Every clip names Thaqalayn once, late. The hook is his experience; no fatwa, no hadith attribution beyond Hadith al-Thaqalayn ("two weighty things"), which is well attested.
- Do not commit episode folders to the repo; they live under `~/ugc/thaqalayn/`.
- Update `assets/hooks.md` when a new hook, header or passage plan is created, so the next episode starts from it.

## Why the flow is shaped this way

- Two takes, not one: the talking-head authors found one take over 20 s of continuous speech drifts, the demo only needs audio (480p is 45% of the price), and a mispronounced word in a single long take means rerunning all of it.
- Pronunciation hints up front: "Sunni" came out as "Sunnah" on the first read and cost a rerun; "Thaqalayn" needs its hint every time. Scribe hearing the scripted word is the check.
- B-roll before generation: the voiceover sentences map one-to-one to screens, so the shot list has to exist before the voiceover is written, and the recording has to exist before the run so the timeline can be built in one pass.
- The header carries over the demo unchanged (user decision on H3, after trying a payoff-style demo header).

## Gotchas learned

- `treg call --data` takes the JSON inline or `--file`; `--data @file` is sent as a literal string. Poll with `treg call reapi.tasks.get --query id=<task>`. Result URLs on `file.deepytb.com` need a browser user agent.
- Do not name a shell variable `GID` in zsh.
- Seedance takes are 24 fps and screen recordings 30 or 60; joining them without `fps=30` made x264 pick level 6.2, which iPhone Photos refuses as "file format is not supported".
- The Claude app delivers an mp4 as a file, not to Photos; that is the channel, not the file.
- The auto-mode classifier refuses to publish a real creator's face frame to the host repo; the character was generated from the locked JSON alone and it was better for it.
- `gpt-image-2.5-flare` failed with "no available channel"; `gpt-image-2.5-flare-official` worked. Only relevant if the character were ever revisited, which it is not.
