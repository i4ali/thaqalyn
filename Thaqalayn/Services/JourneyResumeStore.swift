//
//  JourneyResumeStore.swift
//  Thaqalayn
//
//  "Resume where you left off" for a journey's Listen mode. JourneyAudioPlayer saves the
//  listener's position (which beat + how far into it) at the natural checkpoints - each
//  beat change, pause, and stop - and clears it when the journey reaches the end, so the
//  next open either resumes mid-journey or starts fresh once it's finished.
//
//  The store is the tested seam: a thin, pure UserDefaults round-trip keyed by journey id,
//  with `defaults` injectable so it runs against a throwaway suite (JourneyResumeTests).
//

import Foundation

/// Where the listener left off in a journey's narration - persisted so reopening resumes.
struct JourneyResumePosition: Equatable, Codable {
    let beatIndex: Int
    let offset: TimeInterval   // seconds into the beat's current clip (best-effort)
}

/// Per-journey resume positions in UserDefaults, keyed by journey id. `defaults` is
/// injectable so it is unit-testable against a throwaway suite.
enum JourneyResumeStore {
    private static let prefix = "journeyResume."
    static func save(_ pos: JourneyResumePosition, for journeyId: String, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(pos) else { return }
        defaults.set(data, forKey: prefix + journeyId)
    }
    static func load(for journeyId: String, defaults: UserDefaults = .standard) -> JourneyResumePosition? {
        guard let data = defaults.data(forKey: prefix + journeyId),
              let pos = try? JSONDecoder().decode(JourneyResumePosition.self, from: data) else { return nil }
        return pos
    }
    static func clear(for journeyId: String, defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: prefix + journeyId)
    }
}
