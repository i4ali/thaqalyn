# Narrated "Listen" Mode for Journeys - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Add a blurred, full-screen audio-only way to experience any Deep Dive / Surah Journey - narrating the whole journey (English prose + woven Arabic verse & duʿā recitation) - premium-gated (free: Yaqin, Surah Fatiha), English-only.

**Architecture:** A narration "seam" (`DeepDiveSection.narrationSegments(for:)`) turns each beat into an ordered list of speech/recitation/pause segments; a pre-render pipeline (ElevenLabs, English voice, content-hash keyed like the duʿās) produces mp3s; a new `JourneyAudioPlayer` plays them as one continuous timeline with lock-screen controls; a blurred SwiftUI player is entered via a "Listen" affordance. Audio ships bundled for the 2 free journeys and via Apple-hosted on-demand asset packs for the rest ($0 hosting).

**Tech Stack:** SwiftUI, AVFoundation (`AVQueuePlayer`/`AVAudioPlayer`, `AVAudioSession`), MediaPlayer (`MPNowPlayingInfoCenter`/`MPRemoteCommandCenter`), Background Assets (ODR fallback), CryptoKit (SHA256), Python 3 + ElevenLabs (render pipeline), XCTest (`ThaqalaynTests`).

**Reference design:** `docs/plans/2026-08-20-narrated-journey-audio-design.md`

**Conventions for this plan**
- Build check: `xcodebuild build -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'generic/platform=iOS Simulator' -configuration Debug` (expect `** BUILD SUCCEEDED **`). Never trust a named-device destination that may not resolve.
- Test run: `xcodebuild test -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=<a device from `xcrun simctl list devices available`>' -only-testing:ThaqalaynTests/<Class>`
- Commit after each task. Do not push. Per repo rule, confirm staged files before committing.
- Python: `source .venv/bin/activate` first.

---

## Phase 1 - Narration seam + render pipeline (the foundation)

### Task 1.1: `JourneyAudioKey` (content-hash, byte-identical to Python)

**Files:**
- Create: `Thaqalayn/Services/JourneyAudioKey.swift`
- Create: `scripts/journey_audio_key.py`
- Test: `ThaqalaynTests/JourneyAudioKeyTests.swift`

**Step 1 - Write the failing test.** Known-answer test (compute the three expected hashes once with the Python helper, paste them in):
```swift
import XCTest
@testable import Thaqalayn
final class JourneyAudioKeyTests: XCTestCase {
    func test_key_isStableAndNFCNormalized() {
        XCTAssertEqual(JourneyAudioKey.key(for: "Certainty is not the absence of doubt."),
                       "<paste from python>")
        XCTAssertEqual(JourneyAudioKey.key(for: "  trimmed  "), JourneyAudioKey.key(for: "trimmed"))
        XCTAssertEqual(JourneyAudioKey.key(for: "café").count, 20)
    }
}
```

**Step 2 - Run, expect FAIL** (`JourneyAudioKey` undefined).

**Step 3 - Implement** (mirror `DuaAudioKey` exactly - see `Thaqalayn/Services/DuaAudioKey.swift`):
```swift
import Foundation
import CryptoKit
enum JourneyAudioKey {
    static func key(for text: String) -> String {
        let norm = text.precomposedStringWithCanonicalMapping
            .trimmingCharacters(in: CharacterSet(charactersIn: " \t\n\r"))
        let digest = SHA256.hash(data: Data(norm.utf8))
        return String(digest.map { String(format: "%02x", $0) }.joined().prefix(20))
    }
    static func recordingURL(for text: String) -> URL? {
        let k = key(for: text)
        return Bundle.main.url(forResource: k, withExtension: "mp3")
            ?? Bundle.main.url(forResource: k, withExtension: "mp3", subdirectory: "JourneyAudio")
        // Downloaded (on-demand) packs are resolved by JourneyAudioAvailability (Task 4.2), not here.
    }
}
```
And `scripts/journey_audio_key.py` = copy of `scripts/dua_audio_key.py` (function renamed). Generate the expected hashes with it and paste into the test.

**Step 4 - Run test, expect PASS.**

**Step 5 - Commit** (`JourneyAudioKey + parity test`).

---

### Task 1.2: The narration seam + audio director (Approach B)

Verbatim prose, wrapped by a thin templated director so it flows for a listener (see design doc §3.8 / §4.1). The director = movement announcements (`.act`), recitation framing ("The Qur'an says:" / "which means:"), pacing pauses, and a journey intro/outro. Connectors are a shared constant set (rendered once); **no per-journey prose is authored**.

**Files:**
- Modify: `Thaqalayn/Models/DeepDive.swift` (add `NarrationSegment`/`Recitation` + `narrationSegments(for:)`)
- Create: `Thaqalayn/Services/JourneyNarration.swift` (`enum JourneyNarration` with the connector constants + `static func timeline(for: DeepDive) -> [NarrationSegment]` that adds intro/outro)
- Test: `ThaqalaynTests/NarrationSegmentsTests.swift`

**Step 1 - Write the failing tests** against real beats from `YaqinDeepDive` / `SurahFatihaDive`:
```swift
func test_narrationBeat_emitsBodyThenReflection() {
    let seg = DeepDive.yaqin.sections.first { if case .narration = $0 { return true }; return false }!
        .narrationSegments(for: .english)
    // first speech is the body, later a reflection; no chrome (source/tag) present
    XCTAssertTrue(seg.contains { if case .speech(let s) = $0 { return s.contains("<a known phrase from that body>") }; return false })
}
func test_verseBeat_weavesRecitationBetweenTranslationAndReflection() {
    let seg = DeepDive.surahFatiha.sections.first { if case .verse = $0 { return true }; return false }!
        .narrationSegments(for: .english)
    XCTAssertTrue(seg.contains { if case .recitation(.verse) = $0 { return true }; return false })
}
func test_interactiveBeat_endsWithPause() {
    // pick a dive that has .sujud/.count/.door/.salawat and assert a trailing .pause
}
func test_duaClose_playsDuaRecitationAndReadsIntroAndClose() { /* .dua beat -> .recitation(.dua) present */ }
// Director (Approach B):
func test_verseBeat_framesRecitation() {
    let seg = DeepDive.surahFatiha.sections.first { if case .verse = $0 { return true }; return false }!
        .narrationSegments(for: .english)
    // lead-in speech immediately before the recitation, "which means" before the translation
    let i = seg.firstIndex { if case .recitation = $0 { return true }; return false }!
    XCTAssertEqual(seg[i-1], .speech(JourneyNarration.verseLeadIn))
}
func test_actBeat_announcesMovement() { /* .act -> first segment is the movement announcement */ }
func test_timeline_startsWithIntroAndEndsWithOutro() {
    let t = JourneyNarration.timeline(for: .yaqin)
    XCTAssertTrue({ if case .speech(let s)? = t.first { return s.contains("Yaqin") }; return false }())
}
```

**Step 2 - Run, expect FAIL.**

**Step 3 - Implement.** Add to `Thaqalayn/Models/DeepDive.swift`:
```swift
enum Recitation: Equatable { case verse(surah: Int, ayah: Int); case dua(arabic: String) }
enum NarrationSegment { case speech(String); case recitation(Recitation); case pause(TimeInterval) }

extension DeepDiveSection {
    /// Ordered audio segments a narrator plays for this beat. English prose is
    /// spoken; Arabic verses/duas are recited (real audio); interactive beats
    /// end with a reflective pause. Chrome (titles/citations/labels) is skipped.
    func narrationSegments(for lang: CommentaryLanguage) -> [NarrationSegment] {
        func s(_ t: LocalizedText?) -> NarrationSegment? {
            guard let t, !t(lang).isEmpty else { return nil }; return .speech(t(lang))
        }
        switch self {
        case .narration(_, let body, let reflection, _):
            return [s(body), s(reflection)].compactMap { $0 }
        case .verse(_, _, _, _, let translation, let reflection, let surah, let ayah):
            // Director framing around the recitation (Approach B):
            return [.speech(C.verseLeadIn),                       // "The Qur'an says:"
                    .recitation(.verse(surah: surah, ayah: ayah)),
                    .pause(0.8), .speech(C.meaning),              // "which means:"
                    s(translation), s(reflection), .pause(C.beatGap)].compactMap { $0 }
        case .act(_, let connector, let line, _):
            return [.speech(C.movementAnnouncement(for: self)), s(connector), s(line), .pause(C.beatGap)].compactMap { $0 }
        // ... one arm per case, mirroring the design doc's beat->field table; every arm
        //     ends with .pause(C.beatGap); recitation beats use the verseLeadIn/meaning framing.
        // C = JourneyNarration connector constants (Task's JourneyNarration.swift).
        case .sujud(_, let prompt, let subline, let translation, _, let arabic, _),
             .count(...), .door(...), .extinguish(...), .salawat(...), .release(...):
            return [s(prompt), s(subline), s(translation),
                    arabic.map { NarrationSegment.recitation(.dua(arabic: $0)) },
                    .pause(3.0)].compactMap { $0 }
        case .reflectionPrompt(_, let prompt, let subline, _, _):
            return [s(prompt), s(subline), .pause(4.0)].compactMap { $0 }
        case .dua(_, let intro, let arabic, let translation, let note, let close, _):
            return [s(intro), .recitation(.dua(arabic: arabic)), s(translation), s(note),
                    close.isEmpty ? nil : .speech(close)].compactMap { $0 }
        // ... open/orientation/depths/act/response/climax/refrain/closing ...
        }
    }
}
```
(Fill every case using the exact associated-value labels in `DeepDiveSection` and the narrate/skip columns from the design doc. This is the one place to get right; the switch is exhaustive so the compiler enforces coverage.)

**Step 4 - Run tests, expect PASS.**

**Step 5 - Commit** (`narration seam: DeepDiveSection.narrationSegments`).

---

### Task 1.3: English string extractor + manifest

**Files:**
- Create: `scripts/extract_journey_strings.py`
- Create: `scripts/build_journey_audio.py` (copy of `scripts/build_dua_audio.py`; change VOICE, OUT=`Thaqalayn/Resources/JourneyAudio`, encoding to mono ~48-64 kbps, manifest path)

**Step 1** - Write `extract_journey_strings.py` that, per journey id, emits an **ordered** deduped list `[{key, journey, order, text}]` of the English narratable strings. Cleanest source of truth: don't re-parse Swift - add a tiny debug dump.

Preferred approach (avoids regex-parsing Swift): add a `#if DEBUG` command-line dump in the app that prints `journeyId \t order \t text` for the **`.speech` segments of `JourneyNarration.timeline(for: dive)`** (so it captures both the verbatim prose *and* the shared director connectors/intro/outro - everything the narrator must speak, rendered once by content-hash), run it once in the simulator, pipe to the extractor. Alternative: regex-extract like `extract_dua_strings.py` (brittle for prose). **Decide during implementation; prefer the dump.**

**Step 2** - Verify the extractor output count/order for Yaqin looks right (spot check against the on-screen text).

**Step 3 - Commit** (`journey narration extractor + build script`).

---

### Task 1.4: FLOW + VOICE APPROVAL GATE (hard stop) → then sample render + SIZE CHECKPOINT

> This is a **one-time hard approval gate** - it validates Approach B (the director flow) + the voice on the **Yaqin** sample only. Do **not** proceed to Task 1.5 / Phase 2 until the user signs off on that sample by ear. **After sign-off, every other journey is rendered and built with no per-journey approval step** - the sample is the single checkpoint for the flow/voice. (The size go/no-go in step 5 is likewise a single overall decision, not per journey.)

**Steps:**
1. Assemble the **Yaqin opening** (~the first 3-4 beats, e.g. `open` → `act` → first `narration` → a `verse`) via `JourneyNarration.timeline(for: .yaqin)`, truncated - so the sample exercises the **full director**: intro, a movement announcement, verbatim prose, and a framed recitation with pauses.
2. Render that sample in **2-3 candidate English voices** with `build_journey_audio.py`, stitched into one clip per voice (narration mp3s + the real verse recitation + pauses) so the user hears the actual woven flow, not isolated lines.
3. **Send the sample clip(s) to the user.** They approve **both**: (a) the **voice**, and (b) the **flow** (director wording/pacing). **Blocking - hard stop.**
4. If the flow needs work, tune the connector constants (`JourneyNarration` wording) and `.pause` lengths, re-render the sample, resend. Repeat until approved.
5. Once approved: render the **full Yaqin** journey. Measure total mp3 bytes; extrapolate ×29 and ×114. **Report the app-size delta - explicit go/no-go before rendering everything.** (Blocking.)
6. Commit the Yaqin mp3s into `Thaqalayn/Resources/JourneyAudio/` (free journey → bundled).

---

## Phase 2 - Playback engine

### Task 2.1: `JourneyAudioPlayer` - continuous timeline

**Files:**
- Create: `Thaqalayn/Services/JourneyAudioPlayer.swift`
- Test: `ThaqalaynTests/JourneyPlaylistTests.swift` (pure playlist-building logic only)

**Step 1 - Failing test** for the pure function that resolves a journey to an ordered `[PlayableClip]` (skips missing files gracefully, maps beat index):
```swift
func test_buildPlaylist_ordersSegmentsAndTracksBeatIndex() { /* given a dive, assert clip order + beatIndex mapping */ }
```
**Step 2 - FAIL.**
**Step 3 - Implement** `@MainActor final class JourneyAudioPlayer: ObservableObject` (`.shared`): builds `[PlayableClip]` from `dive.sections` (each speech→`JourneyAudioKey.recordingURL`; verse→reciter cache URL from Task 4.3; dua→`DuaAudioKey.recordingURL`; pause→silent gap); plays sequentially with `AVQueuePlayer` (insert a generated silent `AVPlayerItem` for `.pause`), or an `AVAudioPlayer` chain. Configure `AVAudioSession(.playback, mode: .spokenAudio)`. On `play()`, stop `TafsirReader.shared`, `DuaAudioPlayer.shared`, `AudioManager.shared` (mirror their mutual-exclusion calls). Publish `isPlaying`, `currentTime`, `duration`, `currentBeatIndex`, `rate`. Keep the playlist-building in a pure `static func buildPlaylist(for:) ->[PlayableClip]` so it's the tested seam.
**Step 4 - Run test PASS + build.**
**Step 5 - Commit.**

### Task 2.2: Lock-screen (now-playing + remote commands)

**Files:** Modify `Thaqalayn/Services/JourneyAudioPlayer.swift`
- Add `MPNowPlayingInfoCenter` updates (title = journey title, artist/album = "Thaqalayn · <beat name>", `MPMediaItemPropertyArtwork` = journey cover asset, elapsed/duration/rate).
- Register `MPRemoteCommandCenter` handlers: play, pause, togglePlayPause, nextTrack/previousTrack (→ skip beat), changePlaybackPosition (→ seek). Call `UIApplication.shared.beginReceivingRemoteControlEvents()`.
- **Verify (device):** play, lock the phone, confirm metadata + working play/pause/skip on the Lock Screen; confirm audio continues in background. (No unit test - manual.)
- Commit.

### Task 2.3: Resume position
- Persist `{journeyId: beatIndex/offset}` in `UserDefaults`; resume on reopen. Small unit test on the persistence helper. Commit.

---

## Phase 3 - Blurred audio UI, entry, gating

### Task 3.1: `JourneyListenView` (the blurred player)
**Files:** Create `Thaqalayn/Views/DeepDive/JourneyListenView.swift`. Reuse the shell/styling of `FullScreenAudioPlayerView` in `Thaqalayn/Views/SurahAudioPlayerView.swift` (both emerald + legacy themes). Blurred journey cover behind a glass panel: journey title, cover, **current beat name** (from `player.currentBeatIndex`), play/pause, scrubber+time, prev/next beat, speed (1×/1.25×/1.5×), sleep timer (reuse `AudioManager`'s pattern). Build + visual check in simulator. Commit.

### Task 3.2: "Listen" entry (English-only)
**Files:** Modify `Thaqalayn/Views/DeepDive/DeepDiveCard.swift`, `SurahExperienceCard.swift` (and/or the journey intro). Add a headphones affordance that presents `JourneyListenView` via `.fullScreenCover`. **Only render it when content language is English** (gate on the app's language setting - confirm exact API, e.g. `CommentaryLanguage`/language manager - during this task). Show the existing "Premium" chip when locked. Build + check. Commit.

### Task 3.3: Gating (direct paywall)
**Files:** the tap handler from 3.2. `let free = PremiumManager.shared.canAccessDeepDive(id) || canAccessSurahExperience(id)`. If not free → present `PaywallView(context:)` directly (no veil). Else → `JourneyListenView`. Manual check: locked journey Listen → paywall; free (Yaqin/Fatiha) → plays. Commit.

---

## Phase 4 - On-demand delivery ($0 hosting)

### Task 4.1: Bundle the 2 free journeys
Confirm Yaqin + Surah Fatiha narration mp3s are in `Thaqalayn/Resources/JourneyAudio/` and resolve via `JourneyAudioKey.recordingURL`. Manual: airplane mode, play Yaqin end to end. Commit.

### Task 4.2: Apple-hosted on-demand for premium journeys
**Files:** Create `Thaqalayn/Services/JourneyAudioAvailability.swift`.
- Package each premium journey's mp3s as an **on-demand asset pack** (Background Assets preferred; ODR via `NSBundleResourceRequest` as the simpler fallback - decide here). Tag = journey id.
- `JourneyAudioAvailability` reports `.bundled / .downloaded / .needsDownload / .downloading(progress)` and exposes `ensureAvailable(journeyId:) async`.
- Listen entry: if `needsDownload`, first tap shows "Preparing this journey…" + progress, then plays; cache persists for offline.
- Extend `JourneyAudioKey.recordingURL`/the player to also look in the downloaded pack's location.
- Verify on device: fresh install, premium journey → downloads then plays; second time offline. Commit.

### Task 4.3: Verse recitation cache-on-play
Reuse `AudioManager` reciter URLs; on first play of a verse segment, download+cache the mp3 to disk keyed by surah:ayah; the player uses the cached file thereafter. Verify offline replay. Commit.

---

## Phase 5 - Full render + polish + ship

- **5.1** Render all remaining journeys with the chosen voice; build the on-demand packs. Commit audio + packs.
- **5.2** Polish: lock-screen artwork per journey, sleep timer, speed persistence, resume, graceful handling when a clip is missing (skip, don't stall).
- **5.3** Add a "What's New" entry in `WhatsNewCatalog.all` (`Thaqalayn/Models/WhatsNewItem.swift`) - EN/UR/AR copy + destination (per repo rule). Note: the feature is English-only, so gate/word the card accordingly.
- **5.4** Full device pass: background, Lock Screen, on-demand download, offline replay, premium gating, English-only hiding. Then version bump + submit (separate flow).

---

## Testing philosophy for this plan
- **Unit-tested (ThaqalaynTests):** `JourneyAudioKey` parity, `narrationSegments(for:)` per beat family, `JourneyAudioPlayer.buildPlaylist`, resume-position persistence. These are the correctness-critical pure functions.
- **Build-verified:** every task ends green on the simulator build command above.
- **Device-verified (no unit test possible):** actual playback, background audio, Lock Screen controls, on-demand download, offline replay. Do these on a real device before shipping (the duʿā feature shipped without a device pass - do not repeat that here, given this adds background audio + on-demand downloads).

## Key risks (carried from design)
- Swift/Python key parity (byte-identical) - covered by Task 1.1's known-answer test.
- Dead air when stitching speech→recitation→pause - preload the next clip; test by ear on Yaqin.
- App-size blow-up - Task 1.4 is an explicit go/no-go gate before the full render.
