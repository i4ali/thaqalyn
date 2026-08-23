# Narrated "Listen" - Ship Handoff (20 journeys)

**Date:** 2026-08-21
**Decision:** Ship the 20 fully-rendered journeys now via On-Demand Resources (ODR); finish the remaining 6 later.

## What is done (code-complete, builds green)

- **Phase 4.3 - verse cache-on-play** (`VerseAudioCache`): verses download once and cache to disk, so a journey replays offline after first listen. Unit-tested.
- **Phase 4.2 - ODR delivery**:
  - `JourneyAudioAvailability` - `NSBundleResourceRequest` per journey (tag = journey id): reports bundled / downloaded / needs-download / downloading, `ensureAvailable` / `release`.
  - Resolution seam - premium narration resolves from the downloaded pack's subdirectory (= journey id); bundled free journeys resolve flat. (`JourneyAudioKey.recordingURL(for:packSubdirectory:)`)
  - "Preparing this journey..." download overlay + retry in `JourneyListenView`; `JourneyListenPresenter.open` runs the ODR download before playback for premium journeys.
  - **Ready-gate**: the Listen entry only appears for journeys in `Thaqalayn/Resources/journey_audio_ready.json` (bundled free + every complete ODR pack), so an unfinished journey never offers a half-silent Listen.
- **What's New** entry `journey-listen` (`WhatsNewCatalog.all`) + `.journeyListen(id)` destination, showcasing free Yaqin. Placeholder `releaseDate` - **set it at ship time** (after the steps below).

## Rendered / packaged state

- **20 audio-ready** (in `journey_audio_ready.json`): `yaqin`, `surah-fatiha` (bundled) + 18 ODR packs: sabr, shukr, salah, ikhlas, taqwa, kisa, surah-baqara, surah-ali-imran, surah-nisa, surah-maida, surah-anam, surah-araf, surah-anfal, surah-tawba, surah-yunus, surah-hud, surah-yusuf, surah-rad.
- **ODR packs**: `OnDemandAudio/<journey-id>/*.mp3` - **18 complete packs, 770 clips, ~119 MB**.
- **6 held back** (Listen hidden until finished): tawakkul (1 ToS-blocked line), surah-ibrahim (-3), surah-yasin (-41), surah-rahman (-50), surah-mulk (-37), surah-kawthar (-21).

## STEP 1 - Wire the ODR packs in Xcode ✅ DONE (scripted + build-verified)

Done via `scripts/wire_journey_odr.py` (idempotent, git-revertible): it added the 18 `OnDemandAudio/<id>` packs to `Thaqalayn.xcodeproj` as folder references, each with `ASSET_TAGS = (<journey-id>)` in the app target's Resources build phase.

**Verified against a real build** (`xcodebuild build`, simulator):
- `plutil -lint` on the pbxproj: OK.
- Build products contain `OnDemandResources/` with **18 `.assetpack` bundles**, one per journey tag (e.g. `...Thaqalayn.surah-baqara-<hash>.assetpack`), plus `AssetPackManifestTemplate.plist` / `OnDemandResources.plist` in the app.
- The 770 pack clips are **NOT** in the app binary (only the ~bundled free-tier + dua clips are).
- Each pack preserves the `<journey-id>/` subdirectory (e.g. `surah-baqara.assetpack/surah-baqara/<key>.mp3`) - exactly what `Bundle.main.url(forResource:withExtension:subdirectory: journeyId)` resolves.

You can see the 18 tags in Xcode under the **Thaqalayn** target's Resource Tags tab. The only thing a build can't prove is the runtime download itself - that's the device test.

> To undo: `git checkout Thaqalayn.xcodeproj/project.pbxproj`. When you finish the remaining 6 journeys, re-run `package_journey_odr.py` then `wire_journey_odr.py` (it only adds packs not already wired).

## STEP 2 - Device test (required - do NOT ship without it)

On a real device (ODR + background audio can't be trusted in the simulator):

- [ ] **Free/offline**: airplane mode -> Listen on **Yaqin** and **al-Fatiha** -> full narration + verses play from the bundle.
- [ ] **Premium download**: online -> Listen on e.g. **surah-baqara** -> "Preparing this journey..." shows progress -> plays. Then airplane mode -> Listen again -> plays from cache.
- [ ] **Verse offline**: after one full listen of a journey, airplane mode -> replay -> the woven Quran verses still play (verse cache).
- [ ] **Background + lock screen**: play, lock -> title / beat / cover art show; play/pause/skip/scrub work; audio continues in background.
- [ ] **Gating**: a locked premium journey's Listen -> straight to `PaywallView`. Free ones play.
- [ ] **English-only**: switch content language to Urdu/Arabic -> the Listen headphones disappear.
- [ ] **Ready-gate**: the 6 held-back journeys (tawakkul, surah-ibrahim, -yasin, -rahman, -mulk, -kawthar) show **no** Listen entry.

## STEP 3 - Ship

- Set the real `releaseDate` on the `journey-listen` What's New item.
- **CloudKit**: no schema change here (no synced fields added) - nothing to deploy.
- Version bump + submit via the usual flow.

## Finishing the remaining 6 journeys (later, needs credits)

1. Top up ElevenLabs credits.
2. `cd scripts && source ../.venv/bin/activate` then resume: `set -a && . ../.env && set +a && export ELEVENLABS_API_KEY="$ELEVENLABS_API_KEY_OLD" && export JOURNEY_AUDIO_OUT="$PWD/../journey-audio-render" && python3 build_journey_audio.py` (idempotent - only renders the ~152 missing clips).
3. **tawakkul's ToS-blocked munajat** ("My God, I have cut myself off from all but You...") won't render as-is. Reword it in `build_journey_audio.py`'s `sanitize()` (this changes only what ElevenLabs speaks, not the app's hash key), then re-run.
4. `python3 package_journey_odr.py` - regenerates the packs + `journey_audio_ready.json` (the newly-complete journeys are added automatically).
5. In Xcode, drag the new journey folders in + tag them (STEP 1), rebuild, device-test, ship.

## Commit notes

- The journey-audio work shares the working tree with a **separate, uncommitted "Duas & Ziyarat" feature**. They're coupled at compile time via `DuaStreamPlayer.shared.stop()` mutual-exclusion calls in `JourneyAudioPlayer` / `TafsirReader` / `DuaAudioPlayer`, and both touch `WhatsNewItem.swift` / `WhatsNewCard.swift`. Decide what belongs in this commit.
- **`OnDemandAudio/` (~119 MB)** must be committed (it's the ODR content the project references). That's a large binary add to git history - consider **git-lfs** for `OnDemandAudio/**/*.mp3`. The render staging `journey-audio-render/` (~165 MB) is git-ignored - do not commit it.
- New files this session: `Thaqalayn/Services/VerseAudioCache.swift`, `JourneyAudioAvailability.swift`, `Thaqalayn/Resources/journey_audio_ready.json`, `ThaqalaynTests/VerseAudioCacheTests.swift`, `scripts/package_journey_odr.py`, `scripts/wire_journey_odr.py`, `OnDemandAudio/`. Modified: `Thaqalayn.xcodeproj/project.pbxproj` (18 ODR folder refs + tags), `build_journey_audio.py` (resilience + `JOURNEY_AUDIO_OUT`), `JourneyAudioKey`, `JourneyAudioPlayer`, `JourneyListenPresenter`, `JourneyListenView`, `JourneyHubView`, `WhatsNewItem`, `WhatsNewCard`.
