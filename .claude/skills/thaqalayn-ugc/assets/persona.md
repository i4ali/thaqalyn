# The Thaqalayn UGC presenter

One character, locked on 2026-09-16. He never changes. Every clip uses `assets/character.jpg` as the Seedance image reference and `assets/voice_ref.mp3` as the cadence reference, so his face, setting and delivery stay consistent across the whole account.

## Name and handle

- **Name:** Mehdi (confirmed by the user on 2026-09-16)
- **Handle:** @mehdi.explains (checked free on TikTok on 2026-09-16; @mehdi.reads not yet checked)
- **Bio draft:** "Mehdi Rizvi, 28, Toronto. Reading the Quran properly for the first time. Not a scholar."
- **Account:** a dedicated persona account, not the app's brand account. The format only works if he reads as a person who found the app. Turn on TikTok's AI-generated content label when posting; the persona still works with it.

## Look (what the locked JSON pins)

28, slim, medium tan skin, black hair cropped with a skin fade, short dense black beard connected to the moustache, dark brown eyes, small mole under the outer corner of the left eye. Plain white crew-neck T-shirt, small black lavalier mic clipped at the collar. Standing in a suburban back garden at golden hour, large tree trunk behind him, sunlit foliage, red fence at the far right. Selfie framing, head and shoulders, mid-sentence, warm smile at 6 out of 10.

Full specification: `assets/character.json` (portrait-clone locked JSON, v1). Generated on Gemini 3 Pro Image through treg (`reapi.image-gen.gemini-3-pro-image`, $0.03) from the JSON alone, no reference photo. The GPT Image 2.5 render of the same JSON was the runner-up.

## Voice

`assets/voice_ref.mp3` is a 12.45 s slice (50.00 s to 62.45 s) of the presenter video the user picked at the trend stage; see `assets/voice_ref.source.txt`. It is passed to Seedance as `@audio1` for rhythm and timbre only. The user chose this explicitly on 2026-09-16 after being told the alternative (a licensed ElevenLabs voice) and the concern (an identifiable creator's voice in a competitor's ad). Do not clone this voice in ElevenLabs; its terms require consent. After every run, delete the hosted copy from the `ugc-refs` GitHub repo (the run script does this).

Result on take 1: 243 words per minute, one natural 0.34 s breath, speech ending 0.11 s before the clip end. The user's verdict: "it's perfect".

## Voice for the demo voiceover

Current: a 480p Seedance take with the same character image and voice reference (about $1.19 per episode), so hook and demo share one voice. An ElevenLabs clone of that voice exists in the project's account as "Mehdi (Thaqalayn presenter)", id ho9qcMh74s4YTqrsBtBY, made on 2026-09-17 from 29 s of approved takes; the user listened and chose to stay on Seedance for now. It is wired into episode.py behind `vo_engine: elevenlabs` in the pack and is unused.

## Other voice options (not in use)

Two options, both need the user's OK: an ElevenLabs licensed voice (samples of Liam, Will and Mark are in `~/ugc/thaqalayn/voice/`), or an ElevenLabs instant clone of the character's own audio from an approved Seedance take, which keeps the voice identical between hook and demo and clones nothing real.

## Rules

1. Never regenerate, re-roll or edit the character. If a take drifts from him, rerun the take, not the character.
2. Never host a real person's face or voice anywhere except the voice reference above, and delete it after each run.
3. Every clip names Thaqalayn once, late, as the answer. The hook is his experience, never a fatwa. Spell it "Thaqalayn" and add the pronunciation line to the prompt.
