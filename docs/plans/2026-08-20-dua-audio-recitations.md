# Dua Audio Recitations Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace robotic `AVSpeechSynthesizer` TTS in the dua/ziyarat "Listen" button with high-quality pre-recorded ElevenLabs recitations, bundled in-app and content-hash keyed, with TTS as an automatic fallback.

**Architecture:** Each recording is named by `sha256(NFC(arabic).trim)[:20].mp3`. The identical normalization runs in Python (render/naming) and Swift (runtime lookup), so file names and runtime keys match by construction. `DuaListenButton` computes the key and plays `DuaAudio/<key>.mp3` if bundled, else falls back to the existing `TafsirReader` TTS. The 7 call-site views are untouched.

**Tech Stack:** Swift/SwiftUI, AVFoundation (`AVAudioPlayer`), CryptoKit (SHA256); Python 3 stdlib (`hashlib`, `unicodedata`, `urllib`) for the render pipeline; ElevenLabs `eleven_v3`.

**Design doc:** `docs/plans/2026-08-20-dua-audio-recitations-design.md`

**Repo rule:** NEVER `git commit` without explicit approval (AskUserQuestion). Every "Commit" step below is a *proposed* commit - present the staged files + message and wait for approval.

---

## Task 1: Python keying function (the shared contract)

**Files:**
- Create: `scripts/dua_audio_key.py`

**Step 1: Implement the key function**

```python
"""Content-hash key for a dua's Arabic string. MUST stay byte-identical to the
Swift DuaAudioKey.key(for:) implementation - both NFC-normalize, trim the same
whitespace set, SHA256, and take the first 20 hex chars."""
import hashlib
import unicodedata

_TRIM = " \t\n\r"

def dua_audio_key(arabic: str) -> str:
    norm = unicodedata.normalize("NFC", arabic).strip(_TRIM)
    return hashlib.sha256(norm.encode("utf-8")).hexdigest()[:20]
```

**Step 2: Sanity check**

Run:
```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
python3 -c "from scripts.dua_audio_key import dua_audio_key as k; print(k('اللّٰهُمَّ اشْفِنِي بِشِفَائِكَ وَدَاوِنِي بِدَوَائِكَ وَعَافِنِي مِنْ بَلَائِكَ'))"
```
Expected: a 20-char hex string (record it - the Swift side must produce the same for the same input in Task 5).

---

## Task 2: String extraction (gather every Listen-button dua)

**Files:**
- Create: `scripts/extract_dua_strings.py`

**Step 1: Implement extraction**

```python
"""Gather every Arabic string that reaches a DuaListenButton, from the same
sources the app compiles/loads. Returns list[dict(source, arabic)]."""
import json, re, glob, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "Thaqalayn", "Data")
CONTENT = os.path.join(ROOT, "Thaqalayn", "Content")

def from_json():
    out = []
    # daily duas: every duas[].arabic
    d = json.load(open(os.path.join(DATA, "daily_duas.json")))
    for x in d["duas"]:
        out.append({"source": f"daily_duas#{x['id']}", "arabic": x["arabic"]})
    # journeys: every days[].dua.arabic
    for j in ["muharram", "hajj", "ramadan", "fatimiyya", "arbaeen"]:
        d = json.load(open(os.path.join(DATA, f"{j}_journey.json")))
        for i, day in enumerate(d["days"]):
            dua = day.get("dua") or {}
            if dua.get("arabic"):
                out.append({"source": f"{j}#day{i}", "arabic": dua["arabic"]})
            if day.get("fullArabic"):   # arbaeen full ziyarat lives on the day
                out.append({"source": f"{j}#day{i}.full", "arabic": day["fullArabic"]})
            if dua.get("fullArabic"):
                out.append({"source": f"{j}#day{i}.dua.full", "arabic": dua["fullArabic"]})
    return out

# DeepDive Swift literals: `.dua(... arabic: "…")` and `replyArabic: "…"`.
# Arabic literals are single-line with no interpolation/escapes (verified).
_ARABIC_LIT = re.compile(r'"([^"\\]*[\u0600-\u06FF][^"\\]*)"')

def from_swift():
    out = []
    for path in sorted(glob.glob(os.path.join(CONTENT, "*.swift"))):
        text = open(path).read()
        name = os.path.basename(path)
        # replyArabic: "…"
        for m in re.finditer(r'replyArabic:\s*"([^"\\]+)"', text):
            out.append({"source": f"{name}:replyArabic", "arabic": m.group(1)})
        # .dua(... arabic: "…" …) - find each `.dua(` then the first `arabic:` literal after it
        for dm in re.finditer(r'\.dua\(', text):
            seg = text[dm.end(): dm.end() + 4000]
            am = re.search(r'arabic:\s*"([^"\\]+)"', seg)
            if am:
                out.append({"source": f"{name}:dua.arabic", "arabic": am.group(1)})
    return out

def gather():
    seen, items = set(), []
    for it in from_json() + from_swift():
        ar = it["arabic"]
        if ar and ar.strip() and ar not in seen:
            seen.add(ar); items.append(it)
    return items

if __name__ == "__main__":
    items = gather()
    total = sum(len(i["arabic"]) for i in items)
    print(f"{len(items)} unique strings, {total} chars")
    for i in items:
        print(f"  {len(i['arabic']):>4}  {i['source']}")
```

**Step 2: Run and verify the count**

Run: `python3 scripts/extract_dua_strings.py`
Expected: ~90-96 unique strings. Confirm it includes: 20 daily, 10 muharram, 10 hajj, 30 ramadan, 5 fatimiyya, 8 arbaeen + 1 arbaeen full ziyarat, 8 DeepDive `.dua`, 1-4 al-Rahman `replyArabic`. If a journey's `dua.arabic` count is off, inspect that JSON's day shape (the extractor tolerates `dua.arabic`, `day.fullArabic`, and `dua.fullArabic`).

---

## Task 3: Render pipeline

**Files:**
- Create: `scripts/build_dua_audio.py`
- Output dir: `Thaqalayn/Resources/DuaAudio/`

**Step 1: Implement**

```python
"""Render every dua string to Thaqalayn/Resources/DuaAudio/<key>.mp3 with the
approved ElevenLabs v3 config. Idempotent: skips keys already rendered. Writes
manifest.json. Requires ELEVENLABS_API_KEY in env (use the PAID key)."""
import json, os, time, urllib.request, urllib.error
from dua_audio_key import dua_audio_key
from extract_dua_strings import gather, ROOT

VOICE = "nwuvEDGFwpyogO4zlBHp"
MODEL = "eleven_v3"
FMT = "mp3_44100_128"
SETTINGS = {"stability": 0.5, "similarity_boost": 0.8, "use_speaker_boost": True}
OUT = os.path.join(ROOT, "Thaqalayn", "Resources", "DuaAudio")

def synth(text, out_path):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE}?output_format={FMT}"
    body = json.dumps({"text": text, "model_id": MODEL, "voice_settings": SETTINGS}).encode()
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "xi-api-key": os.environ["ELEVENLABS_API_KEY"],
        "Content-Type": "application/json", "Accept": "audio/mpeg"})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=180) as r:
                data = r.read()
            if not data: raise RuntimeError("empty audio")
            open(out_path, "wb").write(data)
            return len(data)
        except urllib.error.HTTPError as e:
            msg = e.read().decode("utf-8", "replace")[:200]
            if e.code in (429, 500, 502, 503) and attempt < 3:
                time.sleep(2 * (attempt + 1)); continue
            raise RuntimeError(f"HTTP {e.code}: {msg}")

def main():
    os.makedirs(OUT, exist_ok=True)
    items = gather()
    manifest = []
    for it in items:
        key = dua_audio_key(it["arabic"])
        path = os.path.join(OUT, f"{key}.mp3")
        if os.path.exists(path):
            print(f"  skip {key}  {it['source']}")
        else:
            n = synth(it["arabic"], path)
            print(f"  OK   {key}  {n:>6}B  {it['source']}")
            time.sleep(0.4)
        manifest.append({"key": key, "source": it["source"],
                         "chars": len(it["arabic"]), "arabic": it["arabic"]})
    json.dump(manifest, open(os.path.join(OUT, "manifest.json"), "w"),
              ensure_ascii=False, indent=2)
    print(f"\n{len(manifest)} entries; {len(set(m['key'] for m in manifest))} unique keys")

if __name__ == "__main__":
    main()
```

**Step 2: Dry-run the gather (no credits spent)**

Run: `cd scripts && python3 -c "import build_dua_audio as b; items=b.gather(); print(len(items))"`
Expected: same count as Task 2.

---

## Task 4: Generate the audio

**Step 1: Run the pipeline with the paid key**

Run:
```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
set -a && . ./.env && set +a && export ELEVENLABS_API_KEY="$ELEVENLABS_API_KEY_OLD"
cd scripts && python3 build_dua_audio.py
```
Expected: ~90-96 "OK" lines, then "N entries; N unique keys". Watch for any `HTTP 401 quota_exceeded` (means the paid quota ran out - pause and tell the user).

**Step 2: Verify the output**

Run:
```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Resources/DuaAudio
ls *.mp3 | wc -l                       # == unique key count
for f in *.mp3; do md5 -q "$f"; done | sort | uniq -d   # expect EMPTY (no dup audio)
du -sh .                               # expect ~12-15MB
```
Expected: file count == unique keys; no duplicate md5s; size ~12-15MB.

---

## Task 5: Swift `DuaAudioKey` (runtime key, must match Python)

**Files:**
- Create: `Thaqalayn/Services/DuaAudioKey.swift`

**Step 1: Implement**

```swift
//  DuaAudioKey.swift
//  Thaqalayn
//
//  Content-hash key for a dua's Arabic string -> bundled recording file name.
//  MUST stay byte-identical to scripts/dua_audio_key.py: NFC-normalize, trim the
//  same whitespace, SHA256, first 20 hex chars.

import Foundation
import CryptoKit

enum DuaAudioKey {
    private static let trim = CharacterSet(charactersIn: " \t\n\r")

    static func key(for arabic: String) -> String {
        let norm = arabic.precomposedStringWithCanonicalMapping   // NFC
            .trimmingCharacters(in: trim)
        let digest = SHA256.hash(data: Data(norm.utf8))
        return digest.map { String(format: "%02x", $0) }.joined().prefix(20).lowercased()
    }

    /// URL of the bundled recording for this Arabic, if one exists.
    static func recordingURL(for arabic: String) -> URL? {
        Bundle.main.url(forResource: key(for: arabic), withExtension: "mp3", subdirectory: "DuaAudio")
    }
}
```

Note: `String.prefix(20)` yields a `Substring`; wrap as `String(...)`. Fix:
`return String(digest.map { String(format: "%02x", $0) }.joined().prefix(20))` (hex is already lowercase; `%02x` is lowercase).

**Step 2: Parity check (deferred to Task 11)**
Verified empirically by the DEBUG "no recording" log staying silent for all covered duas.

---

## Task 6: `DuaAudioPlayer`

**Files:**
- Create: `Thaqalayn/Services/DuaAudioPlayer.swift`

**Step 1: Implement**

```swift
//  DuaAudioPlayer.swift
//  Thaqalayn
//
//  Plays a bundled dua recitation (AVAudioPlayer). Mirrors TafsirReader's
//  Listen/Pause/Resume states so DuaListenButton can drive its UI identically.

import Foundation
import AVFoundation

@MainActor
final class DuaAudioPlayer: NSObject, ObservableObject {
    static let shared = DuaAudioPlayer()

    @Published var isPlaying = false
    @Published var isPaused = false
    /// The key currently loaded (nil = nothing). Buttons compare against their own key.
    @Published var currentKey: String?

    private var player: AVAudioPlayer?

    /// Start (or restart) playback of the recording at `url`, identified by `key`.
    func play(key: String, url: URL) {
        // Mutual exclusion with TTS.
        TafsirReader.shared.stop()
        if currentKey == key, let p = player, isPaused {
            p.play(); isPlaying = true; isPaused = false; return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            player = p; currentKey = key; isPlaying = true; isPaused = false
        } catch {
            #if DEBUG
            print("DuaAudioPlayer: failed to play \(key): \(error)")
            #endif
            reset()
        }
    }

    func pause() { player?.pause(); isPlaying = false; isPaused = true }
    func resume() { player?.play(); isPlaying = true; isPaused = false }
    func stop() { player?.stop(); player = nil; reset() }

    func togglePlayPause() {
        if isPlaying { pause() } else if isPaused { resume() }
    }

    private func reset() { isPlaying = false; isPaused = false; currentKey = nil }
}

extension DuaAudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.reset(); self.player = nil }
    }
}
```

---

## Task 7: Mutual exclusion from the TTS side

**Files:**
- Modify: `Thaqalayn/Services/TafsirReader.swift:36` (top of `speak(text:language:)`)

**Step 1: Stop any dua recording when TTS starts**

Add as the first line of `speak(text:language:)`:
```swift
DuaAudioPlayer.shared.stop()
```
So starting TTS anywhere cancels a playing recording, and vice versa (Task 6 already stops TTS when a recording starts).

---

## Task 8: Edit `DuaListenButton`

**Files:**
- Modify: `Thaqalayn/Views/Components/DuaListenButton.swift`

**Step 1: Replace the file body**

```swift
import SwiftUI

struct DuaListenButton: View {
    let arabic: String

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var tafsirReader = TafsirReader.shared
    @StateObject private var duaPlayer = DuaAudioPlayer.shared

    // Recording lookup (nil -> TTS fallback). Computed once per render; SHA256 of a
    // short string is negligible.
    private var recordingURL: URL? { DuaAudioKey.recordingURL(for: arabic) }
    private var key: String { DuaAudioKey.key(for: arabic) }
    private var hasRecording: Bool { recordingURL != nil }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldButton } else { standardButton }
        }
        .onAppear {
            #if DEBUG
            if !hasRecording {
                print("DuaListenButton: no recording for key \(key) - arabic: \(arabic.prefix(40))")
            }
            #endif
        }
        .onDisappear {
            if hasRecording {
                if duaPlayer.currentKey == key { duaPlayer.stop() }
            } else if tafsirReader.currentText == arabic {
                tafsirReader.stop()
            }
        }
    }

    private var standardButton: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                Image(systemName: iconName).font(.system(size: 16, weight: .semibold))
                Text(label).font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(themeManager.primaryText)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(
                Capsule().fill(themeManager.secondaryBackground.opacity(0.8))
                    .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var emeraldButton: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                Image(systemName: iconName).font(.system(size: 15, weight: .semibold))
                Text(label).font(.system(size: 14.5, weight: .semibold))
            }
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 20).padding(.vertical, 11)
            .background(Capsule().fill(themeManager.accentChip))
            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle())
        .frame(maxWidth: .infinity)
    }

    // MARK: - State (recording OR TTS, whichever applies to this dua)

    private var isActive: Bool {
        hasRecording ? duaPlayer.currentKey == key : tafsirReader.currentText == arabic
    }
    private var isPlayingThis: Bool {
        isActive && (hasRecording ? duaPlayer.isPlaying : tafsirReader.isPlaying)
    }
    private var isPausedThis: Bool {
        isActive && (hasRecording ? duaPlayer.isPaused : tafsirReader.isPaused)
    }

    private var iconName: String { isPlayingThis ? "pause.fill" : "speaker.wave.2.fill" }
    private var label: String {
        if isActive { if isPlayingThis { return "Pause" }; if isPausedThis { return "Resume" } }
        return "Listen"
    }

    private func handleTap() {
        if hasRecording, let url = recordingURL {
            if isActive && (duaPlayer.isPlaying || duaPlayer.isPaused) {
                duaPlayer.togglePlayPause()
            } else {
                duaPlayer.play(key: key, url: url)
            }
        } else {
            if tafsirReader.currentText == arabic && (tafsirReader.isPlaying || tafsirReader.isPaused) {
                tafsirReader.togglePlayPause()
            } else {
                tafsirReader.speak(text: arabic, language: .arabic)
            }
        }
    }
}
```

---

## Task 9: Bundle `DuaAudio/` in Xcode

**Files:**
- Modify: `Thaqalayn.xcodeproj/project.pbxproj`

**Step 1: Add the folder as a bundled resource**

Add `Thaqalayn/Resources/DuaAudio` to the app target as a **folder reference** (blue folder), so `Bundle.main.url(..., subdirectory: "DuaAudio")` resolves. Preferred: open Xcode, drag `DuaAudio` into the Project navigator under the app group, choose "Create folder references", app target checked. If editing `project.pbxproj` directly: add a `PBXFileReference` with `lastKnownFileType = folder`, add it to the app group's `children`, and add it to the app target's `PBXResourcesBuildPhase` `files`.

**Step 2: Verify it's a folder reference, not a group**
The navigator shows `DuaAudio` as a blue folder. (A yellow group flattens files and breaks the `subdirectory:` lookup.)

---

## Task 10: Build

**Step 1: Build the app**

Run:
```bash
cd /Users/muhammadimranali/Documents/development/thaqalyn
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -quiet build 2>&1 | tail -30
```
Expected: `BUILD SUCCEEDED`. Fix any compile errors (likely: `String(prefix(20))` wrap in DuaAudioKey; `EmPressStyle`/`accentChip` names already exist in the original button so they compile).

---

## Task 11: Simulator verification (the parity + UX proof)

**Step 1: Run and spot-check**

Launch in the simulator. With the Xcode console visible (DEBUG), open and tap Listen on:
- a Daily Dua (DuaDetailView),
- one day in EACH journey (Muharram, Hajj, Ramadan, Fatimiyya, Arbaeen),
- the **full Ziyarat Arbaeen** sheet (Arbaeen Station 8 -> "read full"),
- a deep-dive **closing dua** (e.g. Ikhlas or Taqwa), and the **al-Rahman refrain** ("You Answer").

Expected for each: real recitation plays (not the robotic voice); Pause -> Resume works; leaving the screen stops it. The console shows **no** `DuaListenButton: no recording for key …` line for any of these (that silence proves the Swift key == the Python key for all covered duas).

**Step 2: Fallback check**
Temporarily pass an un-recorded Arabic string to a `DuaListenButton` (or note a future-content dua): it should speak via TTS and log the DEBUG line. Revert any temporary change.

---

## Task 12: Commit (REQUIRES APPROVAL)

**Step 1: Present the staged set + message via AskUserQuestion**

Proposed message:
```
Dua Listen: pre-recorded ElevenLabs recitations, content-hash keyed with TTS fallback

- DuaAudioKey (sha256(NFC.trim)[:20]), DuaAudioPlayer, DuaListenButton picks
  recording vs TTS per its Arabic; 7 views unchanged
- scripts/build_dua_audio.py render pipeline + ~96 bundled mp3s in Resources/DuaAudio
- design + plan in docs/plans/2026-08-20-dua-audio-recitations*.md
```

**Step 2: Only after approval**

```bash
git add Thaqalayn/Services/DuaAudioKey.swift Thaqalayn/Services/DuaAudioPlayer.swift \
  Thaqalayn/Views/Components/DuaListenButton.swift Thaqalayn/Services/TafsirReader.swift \
  Thaqalayn/Resources/DuaAudio scripts/ docs/plans/2026-08-20-dua-audio-recitations*.md \
  Thaqalayn.xcodeproj/project.pbxproj
git commit -m "…"
```
(Confirm the working tree carries no unrelated changes - e.g. the untracked `sketchnote-explainer/` - before staging.)

---

## Notes / risks

- **Key parity** is the one correctness-critical invariant. NFC on both sides plus
  extracting from the same source the app compiles makes it hold; Task 11's silent
  DEBUG log is the proof. If a known dua logs "no recording", the normalization
  diverged - diff the Python `dua_audio_key` and Swift `DuaAudioKey`.
- **DeepDive literal extraction** assumes single-line Arabic literals with no `\(...)`
  interpolation or escaped quotes (verified during Task 2). If a future dive breaks
  that, extend the regex or move that string to JSON.
- **Bundle size** grows ~12-15MB (first bundled audio). Acceptable; verses still stream.
- **CloudKit:** none - no synced schema changes.
