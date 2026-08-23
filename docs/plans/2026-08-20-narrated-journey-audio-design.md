# Narrated "Listen" Mode for Journeys - Design

**Date:** 2026-08-20
**Status:** Approved (brainstorm complete), pending implementation plan
**Scope:** A new audio-only way to experience Deep Dives and Surah Journeys - a blurred, full-screen player that narrates the whole journey. Premium-only except Yaqin and Surah Fatiha. English-only.

---

## 1. Summary

Today a journey (a theme Deep Dive like Yaqin/Sabr, or an "Inside the Surah" experience like al-A'raf/al-Rahman) is a **visual, scroll-through, interactive** experience. This feature adds a **second, co-equal way to experience the same journey: audio-only**. The user taps a "Listen" affordance, the screen blurs, and a player narrates the full journey start to finish - English prose read by a narrator, with the Qur'an verses and closing duʿās/ziyārāt woven in as **real Arabic recitation** (verse audio + the duʿā recordings shipped in v8.0).

The existing visual journey is **untouched**. This is purely additive.

## 2. The core architectural win

Deep Dives and Surah Journeys are **one engine**:

- Model: `Thaqalayn/Models/DeepDive.swift` - `DeepDive` struct, `enum DeepDiveSection` (the "beat").
- Renderer: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`.
- Content: `Thaqalayn/Content/*DeepDive.swift` (8 theme dives) and `Thaqalayn/Content/Surah*Dive.swift` (21 surah journeys).
- Catalogs: `DeepDiveDescriptor.all` (`Services/DeepDiveCatalog.swift`), `SurahExperienceDescriptor.all` (`Services/SurahExperienceCatalog.swift`).
- Entry: `Thaqalayn/Views/JourneyHubView.swift` presents `DeepDiveView` via `.fullScreenCover`.

Because both families share `DeepDiveSection`, **the narration layer is built once** and covers all ~29 journeys today, and every future one (the roadmap goal is up to all 114 surahs).

## 3. Locked decisions (from brainstorm)

1. **Entry model:** a separate "Listen" entry that launches the blurred audio-only player. The visual journey is unchanged; the two are co-equal ways to experience a journey.
2. **Narration source:** pre-rendered with ElevenLabs (reusing the duʿā pipeline), using a **dedicated English narrator voice** (the current duʿā voice is tuned for Arabic recitation).
3. **Audio composition:** one continuous timeline that **weaves everything** - English narration + Qur'an verse recitation + captured duʿā recitation, in beat order.
4. **Delivery ($0 ongoing cost):**
   - **Bundle** Yaqin + Surah Fatiha narration in the app binary (instant, offline, the free conversion hook).
   - **Apple-hosted on-demand** (Background Assets, ODR as fallback) for every premium journey - Apple's CDN hosts it free (70 GB ceiling on iOS 18+), downloads on first Listen, iOS caches it (offline after). No Supabase, no egress, no metered bill.
   - **Speech-optimized encoding** (mono, ~48-64 kbps) to keep sizes small. Render one sample journey early and compute the real total as a go/no-go checkpoint.
   - Verses are cached-on-play (reuse existing reciter mp3s), not bundled, so a journey replays offline after first listen without bloating the binary.
5. **Gating:** premium-only via existing `PremiumManager.canAccessDeepDive(_:)` / `canAccessSurahExperience(_:)` (Yaqin + `surah-fatiha` are the free ids). **Tapping Listen on a locked journey goes straight to `PaywallView`** (direct routing) - **no** audio veiled preview. The visual journey keeps its existing veiled preview. The Listen entry shows a **"Premium" chip** (no lock glyph) when locked.
6. **English-only:** the Listen entry only appears when the app's content language is English; hidden/disabled otherwise.
7. **Interactive/close beats** (`reflectionPrompt`, `count`, `sujud`, `door`, `extinguish`, `salawat`, `release`): the narrator reads the prompt + subline, plays any recitation, then holds a **short reflective pause** so the listener can do it in their own space, then continues (no tapping).
8. **Narration flow = verbatim content + a thin "audio director" (Approach B):** the narrator speaks the written prose **verbatim** - nothing is re-authored. A small templated **director** layer wraps it so it flows for a listener: a short **journey intro/outro**, **movement announcements** (from the existing `.act` beats), **recitation framing** ("The Qur'an says:" → recitation → pause → "which means:" → translation), and **pacing pauses** between beats/movements. **Gate (one-time):** an early **sample render of Yaqin's opening** (director + chosen voice) must be **approved by ear** before the full render - a hard stop. It validates the approach **once on Yaqin**; after sign-off, all other journeys render with no per-journey approval.

## 4. Architecture

### 4.1 Narration content model (the seam)

Add one accessor to `DeepDiveSection` (in `Models/DeepDive.swift`):

```swift
enum NarrationSegment {
    case speech(String)         // English narrator (pre-rendered)
    case recitation(Recitation) // real Arabic audio
    case pause(TimeInterval)    // reflective silence (interactive beats)
}
enum Recitation {
    case verse(surah: Int, ayah: Int)  // reciter audio (cache-on-play)
    case dua(arabic: String)           // DuaAudioKey.recordingURL(for:)
}

extension DeepDiveSection {
    func narrationSegments(for lang: CommentaryLanguage) -> [NarrationSegment]
}
```

A `switch` over the beat cases mirrors the beat->field map (from the codebase survey): narrate `body / reflection / translation / line / intro / promise / leaveWith / essence / prompt / subline / note / close …`; splice in `verse` / `dua` recitation where the beat has Arabic; skip chrome (`titleEn`, `titleAr`, `reference`, `source`, `*transliteration`, tags, button labels). Interactive beats append a `.pause`.

A whole journey's timeline = `JourneyNarration.timeline(for: dive)` (a small assembler over `dive.sections.flatMap { $0.narrationSegments(for: .english) }`).

**Audio director (Approach B - the flow layer).** The segments a beat emits are not just its raw fields; they include the templated connectors that make it flow for a listener:
- `.act` beats emit a **movement announcement** ("Movement one. Knowledge." from the existing act data + `line`).
- `verse` / `dua` / any recitation beat **frames** the recitation: a lead-in ("The Qur'an says:") before the `.recitation`, then a `.pause` + "which means:" before the translation.
- Every beat ends with a pacing `.pause`.
- `JourneyNarration.timeline(for:)` prepends a short **intro** (built from the dive's `titleEn` + `subtitle`) and appends an **outro**.

The connectors are a **small shared set of strings** (rendered once by the pipeline) plus the already-authored `.act` lines - **no per-journey prose is written**, and the written prose itself is spoken **verbatim**. The connector wording/pause lengths are tuned against the Yaqin sample (below) before the full render.

### 4.2 Audio generation pipeline (offline, pre-rendered)

- New `scripts/extract_journey_strings.py` - walks `Content/*Dive.swift`, extracts the **English** side of the narratable `LocalizedText` fields per beat, in order, and emits a per-journey ordered list of narration strings (deduped by content-hash, like the duʿā extractor).
- Reuse `scripts/build_dua_audio.py` almost verbatim: same ElevenLabs call + content-hash key (`DuaAudioKey` scheme: `sha256(NFC(text).trim)[:20]`), idempotent, manifest. Changes: a **dedicated English narrator voice id**, speech-optimized output (mono, ~48-64 kbps), output into `Thaqalayn/Resources/JourneyAudio/` (bundled subset) and the on-demand asset packs (rest).
- Swift lookup mirrors `DuaAudioKey`: a `JourneyAudioKey.recordingURL(for:)` that resolves a narration string to its bundled/downloaded mp3.
- **Voice pick is deferred to implementation:** render 2-3 candidate English voices on one sample beat; the user picks by ear before the full render.

### 4.3 Delivery

- **Bundled:** Yaqin + Surah Fatiha narration mp3s ship in `Resources/JourneyAudio/`.
- **On-demand:** each premium journey is an **Apple-hosted asset pack** (Background Assets preferred; ODR is the legacy fallback). On first Listen: download the pack (a brief "Preparing this journey…" state), then iOS caches it for offline replay. A `JourneyAudioAvailability` service reports bundled / downloaded / needs-download / downloading and drives the entry state.
- **Verses:** on first play a beat's verse recitation streams via the existing `AudioManager` reciter URLs and is cached to disk, so subsequent plays are offline.

### 4.4 Playback engine

New `Thaqalayn/Services/JourneyAudioPlayer.swift` - `@MainActor final class JourneyAudioPlayer: ObservableObject` (`.shared`):

- Input: an ordered `[NarrationSegment]` for a journey (+ a map from segment to a local file URL).
- Plays segments back-to-back as **one continuous timeline** (an `AVQueuePlayer` of `AVPlayerItem`s, or sequential `AVAudioPlayer`s), honoring `.pause` gaps.
- Tracks `currentBeatIndex` / overall progress; exposes `isPlaying`, `currentTime`, `duration`, `currentBeatTitle`, playback rate.
- Session: `AVAudioSession` `.playback` / `.spokenAudio`; background playback already entitled (`UIBackgroundModes = [audio]`).
- **Mutual exclusion:** stop `TafsirReader`, `DuaAudioPlayer`, and `AudioManager` on start (they already cross-stop each other; register the new player in the same convention).
- **Lock-screen (new, missing app-wide):** `MPNowPlayingInfoCenter` (journey title, current beat, cover artwork) + `MPRemoteCommandCenter` (play / pause / skip-beat / scrub) + `beginReceivingRemoteControlEvents()`. Model on `AudioManager`'s now-playing scaffolding; add the remote-command block that no player currently has.
- Persists resume position per journey.

### 4.5 The blurred audio-only screen

- **Entry:** a headphones "Listen" affordance on the journey card (`DeepDiveCard` / `SurahExperienceCard`) and/or the journey intro. Visible only when content language is English. Shows a "Premium" chip when locked.
- **Screen:** reuse the `FullScreenAudioPlayerView` shell (`Views/SurahAudioPlayerView.swift`, already themed emerald + legacy). Blurred journey cover behind a glass panel showing: **journey title, cover, current movement/beat name** (subtle context, not a blank blur), and controls: play/pause, scrubber + time, **prev/next beat**, **speed** (1× / 1.25× / 1.5×), **sleep timer** (reuse `AudioManager`'s). Autoplays to the end; resumes where left off.

### 4.6 Gating & language

- Locked tap -> `PaywallView` directly (no veil). Free (Yaqin, surah-fatiha) and purchased -> full playback.
- English-only: gate the entry on the app's content-language setting (the same setting driving EN/UR/AR content; exact API - `CommentaryLanguage` / a language manager - confirmed in implementation).

## 5. Out of scope (YAGNI)

- Live karaoke caption / per-word highlighting (declined; can be added later with per-line timing).
- Any new journey **content** - this narrates the existing text.
- Non-English narration.

## 6. Open items to resolve during implementation

1. **Narrator voice** - pick from 2-3 rendered candidates.
2. **Exact language-setting API** for the English-only gate.
3. **Background Assets vs ODR** - confirm Background Assets fits (modern, Apple-hosted); fall back to ODR if needed.
4. **Real bundled/asset size** - render one sample journey, extrapolate, confirm the app-size delta is acceptable before rendering all.
5. **Where exactly the Listen entry lives** (card, intro, or both) - a small UX placement pass.

## 7. Rough phases

1. **Narration seam + extractor** - `narrationSegments(for:)` + `extract_journey_strings.py`; render one sample journey; size checkpoint + voice pick.
2. **Playback engine** - `JourneyAudioPlayer` with now-playing + remote commands + background; play a bundled journey end to end.
3. **Blurred UI + entry + gating** - the audio screen, the Listen entry, premium/English-only gating, direct paywall.
4. **On-demand delivery** - Background Assets asset packs; bundle the 2 free; download-on-first-Listen + cache; verse cache-on-play.
5. **Full render + polish** - render all journeys, lock-screen/artwork, resume, sleep timer, "What's New" entry.

## 8. Risks / considerations

- **App size** - mitigated by on-demand + speech encoding + the early size checkpoint.
- **Continuous timeline gaps** - stitching narration + recitation + pauses without dead air needs careful sequencing/preloading of the next clip.
- **Content-hash parity** - the Swift `JourneyAudioKey` and Python key must stay byte-identical (same lesson as the duʿā pipeline), or narration silently goes missing.
- **Untested-on-device** - like the duʿā feature, verify real playback (especially lock-screen + background + on-demand download) on a device before shipping.
