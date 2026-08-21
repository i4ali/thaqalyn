# Dua Audio Recitations - Design

**Date:** 2026-08-20
**Status:** Approved, pending implementation plan

## Problem

Every dua/ziyarat "Listen" control in the app currently speaks the Arabic via
`AVSpeechSynthesizer` (system TTS), through `TafsirReader.shared`. TTS Arabic is
robotic and users notice. We want high-quality pre-recorded recitations instead,
using an approved ElevenLabs voice, while keeping TTS as a graceful fallback for
any supplication that has no recording yet.

- **Voice:** `nwuvEDGFwpyogO4zlBHp` (ElevenLabs library voice; requires the paid
  account - the key is `ELEVENLABS_API_KEY_OLD` in `.env`, the upgraded plan).
- **Model / format:** `eleven_v3`, `mp3_44100_128`, voice settings
  `{stability: 0.5, similarity_boost: 0.8, use_speaker_boost: true}`. Approved by
  ear on the sample batch.

## Scope - everything that feeds a `DuaListenButton`

`DuaListenButton(arabic:)` is used by exactly 7 views. The Arabic that reaches it:

| Source | Field | Strings | ~Chars |
|---|---|---|---|
| `daily_duas.json` (DuaDetailView) | `dua.arabic` | 20 | 1,876 |
| `muharram_journey.json` | `days[].dua.arabic` | 10 | 1,779 |
| `hajj_journey.json` | `days[].dua.arabic` | 10 | 1,157 |
| `ramadan_journey.json` | `days[].dua.arabic` | 30 | 2,133 |
| `fatimiyya_journey.json` | `days[].dua.arabic` | 5 | 764 |
| `arbaeen_journey.json` | `days[].dua.arabic` | 8 | 1,169 |
| `arbaeen_journey.json` | `fullArabic` (full Ziyarat Arbaeen, one file) | 1 | 2,852 |
| DeepDive content (`Content/*DeepDive.swift`) | `.dua` case `arabic` (8 themes) | 8 | ~2,000 |
| `SurahRahmanDive.swift` | `.refrain` `replyArabic` (dedupes) | ~1-4 | small |

**~96 unique strings, ~14k characters total** (daily 20 already rendered as the
test batch; ~76 new).

**Explicitly excluded:** Qur'an verses (they already have real recitation via
`VerseRecitationButton`, streamed from `everyayah.com` / `mp3quran.net`); the 17
surah experiences that close with `.closing` (no dua); `themeArabic` / `situationAr`
labels (headings, not supplications, never passed to a Listen button).

## Architecture

### Keying (the core idea)

Each recording is named by a **content hash of its Arabic string**:

```
key = hex(sha256( NFC(arabic).trim(" \t\n\r") ))[0..<20]
file = DuaAudio/<key>.mp3
```

The **same** normalization + hash runs on both sides:

- **Swift (runtime):** `arabic.precomposedStringWithCanonicalMapping`
  (NFC) → trim → SHA256 (CryptoKit) → hex → `prefix(20)`.
- **Python (render):** `unicodedata.normalize("NFC", arabic).strip(" \t\n\r")`
  → `hashlib.sha256(...).hexdigest()[:20]`.

NFC on both sides makes the key immune to NFC/NFD byte differences between the
JSON/Swift sources and the runtime string. Because the render list is extracted
from the same source the app compiles, and both use the same key function, the
runtime key and the file name match **by construction**.

### Runtime playback

- **`DuaAudioKey`** - one static func, the shared normalize+hash contract. The
  single source of truth for the algorithm; documented as "must match
  `scripts/build_dua_audio.py`".
- **`DuaAudioPlayer`** - `ObservableObject` singleton wrapping `AVAudioPlayer`.
  `@Published isPlaying / isPaused / currentKey`. Methods `play(key:) / pause() /
  resume() / stop() / togglePlayPause()`. `AVAudioPlayerDelegate` resets state on
  finish. Sets `AVAudioSession` `.playback` so a dua plays through the silent
  switch like a media player. Starting playback stops any `TafsirReader` speech
  (mutual exclusion), and vice versa.
- **`DuaListenButton`** - the only edited view. For its `arabic`:
  - `key = DuaAudioKey.key(for: arabic)`; `hasRecording = Bundle.main.url(
    forResource: key, withExtension: "mp3", subdirectory: "DuaAudio") != nil`.
  - If `hasRecording`: label/icon/tap driven by `DuaAudioPlayer` (keyed on `key`).
  - Else: existing `TafsirReader` TTS path, unchanged.
  - `onDisappear`: stop whichever player was handling this dua.
  - Both theme variants (standard + Midnight Emerald) keep their current look.
  - DEBUG: log when `!hasRecording` so any missing/ mismatched key surfaces in test.

**The 7 views are untouched** - every `DuaListenButton(arabic:)` call site upgrades
automatically.

### Bundling

- `Thaqalayn/Resources/DuaAudio/` as an Xcode **folder reference** (blue), so files
  bundle wholesale without per-file target membership. Runtime reads via the
  `subdirectory: "DuaAudio"` argument.
- First bundled audio in the app (~12-15 MB). Verses continue to stream.

### Reproducible render pipeline

`scripts/build_dua_audio.py` (idempotent, re-runnable):

1. **Gather** every Listen-button string:
   - JSON sources: parse `daily_duas.json` (`arabic`) and each journey file
     (`days[].dua.arabic`, plus `arbaeen` `fullArabic`) - exact by construction.
   - DeepDive Swift: extract the `.dua(... arabic: "…")` literal and each
     `replyArabic: "…"` literal from `Content/*.swift` via a precise regex over
     single-line string literals (verified: no interpolation, no escapes in the
     Arabic).
2. **Key** each with the shared algorithm; dedupe.
3. **Render** only keys whose `<key>.mp3` is missing (so re-runs are cheap and new
   content is a one-liner), with the approved v3 config, into `DuaAudio/`.
4. **Write** `DuaAudio/manifest.json` = `[{key, source, chars, arabic}]` for audit.

Later this can become a `/generate-dua-audio` skill.

## Baked-in decisions

- **Full Ziyarat Arbaeen**: one ~3-min file (matches current whole-text TTS; the
  button has no scrubber). Revisit only if we add a scrubbing UI.
- **TTS fallback is permanent** - new duas speak via TTS until their audio ships.
- **Uniform voice settings** on every file for a consistent voice.

## Testing / verification

- Build succeeds with the new files + folder reference.
- Manual: in the simulator, open a daily dua, a journey day (each journey), the
  full Ziyarat Arbaeen sheet, and a deep-dive closing dua - confirm the recording
  plays (not TTS), and Pause/Resume/leave-screen behave.
- DEBUG "no recording for key …" log stays silent for covered duas (proves the
  Swift key matches the rendered key).
- A dua with no recording still falls back to TTS.

## Cost & footprint

- One-time ~12k ElevenLabs credits for the ~76 new strings (watch quota during the
  run; well within a Starter month).
- ~12-15 MB added to the app bundle.
- ~3 new Swift files, one `DuaListenButton` edit, one Xcode resource wiring, one
  Python script.
