//
//  JourneyDurationStore.swift
//  Thaqalayn
//
//  Measures and caches the playback length of a journey's clips so the Listen player can
//  show a whole-journey timeline (total duration, cumulative elapsed, seek-anywhere)
//  instead of the current clip's few seconds. Durations are keyed by a stable per-source
//  key - so a verse / narrator line / dua shared across journeys is measured once - and
//  persisted to disk, so only the first play of new material does any work. Bundled
//  speech/dua files measure instantly; streamed verse recitations load their duration
//  over the network the first time, then are cached. Pauses aren't stored (their length
//  is known inline in the timeline).
//

import Foundation
import AVFoundation

@MainActor
final class JourneyDurationStore {
    static let shared = JourneyDurationStore()

    /// sourceKey -> measured seconds. Recordings are immutable, so an entry never goes
    /// stale: editing a clip changes its content hash (a new key), so old keys simply
    /// stop being looked up.
    private var cache: [String: TimeInterval]
    private let fileURL: URL

    private init() {
        let dir = (try? FileManager.default.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask, appropriateFor: nil, create: true))
            ?? FileManager.default.temporaryDirectory
        fileURL = dir.appendingPathComponent("journey_clip_durations.json")
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([String: TimeInterval].self, from: data) {
            cache = decoded
        } else {
            cache = [:]
        }
    }

    /// Stable cache key for a clip source (nil for pauses - their length is inline).
    static func key(for source: PlayableClip.Source) -> String? {
        switch source {
        case .speech(let text):      return "s:" + JourneyAudioKey.key(for: text)
        case .dua(let arabic):       return "d:" + DuaAudioKey.key(for: arabic)
        case .verse(let s, let ay):  return "v:\(s):\(ay)"
        case .pause:                 return nil
        }
    }

    /// Resolve every clip's duration (measuring + caching the misses), returning the
    /// per-clip seconds aligned to `clips`. Pauses use their inline length; a clip whose
    /// audio can't be measured (missing file / failed load) resolves to 0, matching how
    /// playback skips such a clip. Cheap and idempotent - only unmeasured clips do work.
    func resolveDurations(for clips: [PlayableClip],
                          url: (PlayableClip.Source) -> URL?) async -> [TimeInterval] {
        // Collect the unique, not-yet-cached, resolvable clips to measure.
        var toMeasure: [String: URL] = [:]
        for clip in clips {
            if case .pause = clip.source { continue }
            guard let key = Self.key(for: clip.source), cache[key] == nil else { continue }
            if let u = url(clip.source) { toMeasure[key] = u }
        }

        if !toMeasure.isEmpty {
            let measured = await withTaskGroup(of: (String, TimeInterval).self) { group in
                for (key, u) in toMeasure {
                    group.addTask { (key, await Self.measure(u)) }
                }
                var out: [String: TimeInterval] = [:]
                for await pair in group { out[pair.0] = pair.1 }
                return out
            }
            for (key, seconds) in measured { cache[key] = seconds }
            persist()
        }

        return clips.map { clip in
            if case .pause(let d) = clip.source { return d }
            guard let key = Self.key(for: clip.source) else { return 0 }
            return cache[key] ?? 0
        }
    }

    /// Load one asset's duration (0 on failure). Off the main actor - pure async I/O.
    private nonisolated static func measure(_ url: URL) async -> TimeInterval {
        let asset = AVURLAsset(url: url)
        guard let seconds = try? await asset.load(.duration).seconds,
              seconds.isFinite, seconds > 0 else { return 0 }
        return seconds
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(cache) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
