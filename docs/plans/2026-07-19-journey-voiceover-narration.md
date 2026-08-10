# Journey Voiceover Narration - Guided Mode

**Date:** 2026-07-19
**Status:** Plan (approved direction: Guided Mode · preset ElevenLabs voice · al-Fatiha pilot)
**Owner:** journeys / immersive experiences

## Goal

Replace the robotic on-device TTS with warm, pre-recorded narration for the immersive
journeys (both "Inside the Sūrah" surah experiences and the theme Deep Dives, all rendered by
`DeepDiveView`). Ship a hands-free **Guided Mode**: the reader taps "Play guided journey," each
beat's reflection is read aloud in a warm voice, and when a clip ends the journey gently
auto-advances to the next beat - an eyes-optional guided meditation you can start and set the
phone down for.

Audio is generated with **Higgsfield → `text2speech_v2` (ElevenLabs engine)**. Because journey
text is static (authored in `Thaqalayn/Content/*Dive.swift`), this is a **build-time content
pipeline**, not live TTS: we pre-generate one polished clip per beat, and the app just plays
audio. Deterministic, cached, no API key in the app, no latency, no robot voice.

## Division of labor (what gets narrated)

| Content | Voice | Source |
|---|---|---|
| Qur'an Arabic verses | **Real reciter** (untouched) | `VerseRecitationButton` → `AudioManager.playVerse` (streams Alafasy from everyayah.com) |
| English reflection / teaching prose | **Warm narrator (ElevenLabs)** | NEW - this plan |
| Chrome (tags, sources, references, ayah numbers) | none | - |
| Hadith-qudsi Arabic in `.response` beats | narrator reads the English `words` | not Qur'an; no synthetic Arabic recitation |

A synthetic voice never recites Qur'an. On a `.verse` beat, Guided Mode **chains** the two
systems: real Arabic recitation plays, then the narrator reads the English reflection. Two audio
paths, one seamless beat.

## Per-beat narration mapping (which prose is spoken)

Driven by the `DeepDiveSection` case (`Thaqalayn/Models/DeepDive.swift:65`):

| Case | Spoken (in order) | Notes |
|---|---|---|
| `.open` | `line` | threshold |
| `.orientation` | `promise`, `leaveWith` | |
| `.act` | `connector?`, `line` | movement divider |
| `.verse` | [real recitation] → `reflection` | translation optionally read before reflection |
| `.response` | `words`, `reflection` | narrator reads His words (English) |
| `.narration` | `body`, `reflection` | |
| `.climax` | [real recitation of anchor verse] → `body`, `reflection` | |
| `.refrain` | [real recitation] → `intro`, `replyTranslation`, `reflection` | al-Rahman only |
| `.depths` | (skip / optional) | interactive map |
| `.reflectionPrompt` / `.release` / `.count` | `subline` then **pause for interaction** | Guided Mode waits for the tap |
| `.dua` | `intro`, `note`, `close` | Arabic du'a keeps its `DuaListenButton` TTS for now |
| `.closing` | `essence`, `line` | |

The spoken text per beat is an **authored audio-script**, not a raw field dump: citations,
parentheticals, and transliteration diacritics are stripped, and Arabic terms are re-spelled
phonetically for the TTS engine (see Pronunciation). This is a small per-journey authoring step.

## Data / architecture

### 1. Narration manifest (bundled JSON, one per dive)

`DeepDiveSection` carries **no audio field today**, and adding one would touch every case
signature and every content file. Instead, keep narration data **separate from display data** -
the same "bundled JSON" pattern the app already uses everywhere (`quran_data.json`,
`tafsir_<n>.json`, `*_journey.json`).

`Thaqalayn/Data/narration/fatiha-narration.json`:

```json
{
  "diveId": "surah-fatiha",
  "voice": { "engine": "elevenlabs", "voiceId": "<preset-uuid>", "name": "Gideon" },
  "clips": [
    {
      "index": 0,
      "kind": "open",
      "srcHash": "a1b2c3",
      "audioScript": "Seven short verses. You have said them more times than any other words in your life...",
      "clip": "fatiha_000_open.m4a",
      "durationSec": 21.4
    }
  ]
}
```

- **Keying:** clips align to `dive.sections` **by index**, guarded by `srcHash` - a hash of the
  beat's source prose fields. At load the app recomputes the hash from the rendered beat; a
  mismatch (content was edited or reordered) makes that beat **fall back silently** to no
  narration rather than play a stale/wrong clip. Self-correcting: editing a beat's prose
  invalidates only its clip, and the generator re-renders only changed beats.
- Manifest is the generator's **output** and the app's **lookup** - single source of truth.

### 2. Playback: a focused `JourneyNarrator` service

Do **not** overload `AudioManager` (715 lines, Qur'an-specific: reciters, verse timing, repeat
modes). Add `Thaqalayn/Services/JourneyNarrator.swift` - an `@MainActor ObservableObject`
(`.shared`) wrapping an `AVAudioPlayer` for narration clips, that:

- Loads a dive's manifest; exposes `play(beatIndex:)`, `pause()`, `resume()`, `stop()`,
  and published `isPlaying`, `activeBeatIndex`, `mode` (`off` / `guided`).
- **Reuses `AudioManager`'s `AVAudioSession` config** (`.playback`, background + Bluetooth/AirPlay)
  and `MPNowPlayingInfoCenter` so narration plays with the screen off - core to "set the phone
  down." Coordinates with `AudioManager` so the two never talk over each other.
- **Verse chaining:** on a verse beat, calls `AudioManager.playVerse(...)`, then on its
  completion plays the narration clip.
- **Auto-advance:** on clip end, waits ~1.2 s, emits an `onAdvance(nextIndex)` the view uses to
  scroll. On an interactive beat (`reflectionPrompt`/`release`/`count`), narrate the prompt then
  **halt** until the user completes the interaction.

### 3. `DeepDiveView` integration

`Thaqalayn/Views/DeepDive/DeepDiveView.swift`:

- **Guided-Mode entry:** a "Play guided journey" control on the `.open` threshold (premium-gated
  identically to the dive via the existing `lockedPaywallContext`), plus a persistent mini
  play/pause + exit control while active.
- **Per-beat Listen (Idea A, the MVP subset):** a small Listen affordance on each narration beat,
  placed where `VerseRecitationButton` (line ~598) and `DuaListenButton` (line ~838) already sit.
- **Auto-advance driver:** wrap the paging scroll in a `ScrollViewReader` (or bind
  `.scrollPosition`) with per-beat ids so `JourneyNarrator.onAdvance` can
  `scrollTo(nextIndex)` using the existing paging animation. If the user scrolls manually,
  `JourneyNarrator` follows them (play the beat they landed on) rather than fighting the scroll.
- **Transition chime:** a soft bundled cue on auto-advance (one small `.m4a`).

## Content pipeline (generator)

New `scripts/narration/` (mirrors existing `scripts/` patterns):

1. `author_scripts.py` / hand-authored: produce `audioScript` per beat (strip citations &
   diacritics - can reuse `scripts/strip_diacritics.py` - and phoneticize Arabic terms).
2. `generate.py`: for each clip, call Higgsfield `generate_audio`
   (`model: text2speech_v2`, `variant: elevenlabs`, chosen `voice_id`), download the mp3,
   transcode to mono `.m4a` ~64 kbps (voice), write `clip` + `durationSec` + `srcHash` back into
   the manifest. Only regenerate beats whose `srcHash` changed.
3. Output: `fatiha-narration.json` + clip files.

**Cost:** ~0.75 credits per beat-length passage on ElevenLabs. al-Fatiha (~17 narratable beats)
≈ **~13 credits**; all 12 built journeys ≈ **~135 credits**. Balance is 535 - non-issue.

## Hosting

- **Pilot (al-Fatiha):** **bundle** the clips in the app (`Bundle.main.url(forResource:)`) - it's
  the free flagship, so bundling guarantees it works offline as the showcase. ~17 clips × mono
  64 kbps ≈ **~3-4 MB**.
- **Later journeys:** **remote-stream-with-cache**, reusing `AudioManager`'s existing
  `URLSession` stream-plus-cache pattern pointed at a bucket/CDN. Keeps the binary small and lets
  narration be fixed without an App Store release. (Same transport the app already uses for all
  Qur'an audio.)

## Open considerations

- **Arabic-term pronunciation.** ElevenLabs stumbles on "al-Mizan," "Ahl al-Bayt," "rak'ah,"
  "al-Sab al-Mathani," etc. Fix in the audio-script authoring pass by phonetic re-spelling
  (e.g. `al-Mizan` → `al-Meezaan`, `tawfiq` → `tawfeeq`). Per-journey QC listen before shipping.
- **Voice identity.** Pilot uses one preset (TBD: Gideon / Caspian / Orion). Standardize on one
  so every journey shares a sonic identity. `create_voice` cloning of a signature voice remains a
  future option (timbre consistency; Arabic pronunciation is still a general TTS limit).
- **Language.** Journey prose is English-only today (UR/AR pending). Pilot = English; ElevenLabs
  is multilingual, so voiceovers can follow once translations land. Arabic *verses* always stay
  real recitation.
- **"What's New."** Guided Mode is a user-facing feature → add a `WhatsNewCatalog.all` entry
  (EN/UR/AR) per the project rule.
- **No new automated tests** (house convention); gate on `xcodebuild` build + a manual listen
  pass in the simulator.

## Phasing

- **Phase 0 - voice lock:** user picks the preset (#1 Gideon / #2 Caspian / #4 Orion).
- **Phase 1 - pipeline + manifest:** author al-Fatiha audio scripts, build `scripts/narration/`,
  generate clips + `fatiha-narration.json`, bundle them.
- **Phase 2 - playback:** `JourneyNarrator` service (load, play, pause, verse-chaining,
  background/lock-screen).
- **Phase 3 - Guided Mode UI:** entry control, per-beat Listen, auto-advance scroll driver,
  interactive-beat pause, transition chime.
- **Phase 4 - polish + ship:** pronunciation QC, "What's New" entry, `xcodebuild`, simulator
  listen pass. Then roll out to remaining journeys (remote-hosted).
