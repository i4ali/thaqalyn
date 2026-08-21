//
//  JourneyResumeTests.swift
//  ThaqalaynTests
//
//  Pins the persistence seam behind "resume where you left off": JourneyResumeStore
//  round-trips a per-journey JourneyResumePosition (beatIndex + offset) through
//  UserDefaults, overwrites in place, clears on demand, and keeps journeys isolated
//  from one another. No playback here - the AVPlayer wiring is device-verified.
//

import XCTest
@testable import Thaqalayn

final class JourneyResumeTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "test.journeyResume"
    override func setUp() { defaults = UserDefaults(suiteName: suite); defaults.removePersistentDomain(forName: suite) }
    override func tearDown() { defaults.removePersistentDomain(forName: suite); defaults = nil }

    func test_saveLoadOverwriteClear_andPerJourneyIsolation() {
        XCTAssertNil(JourneyResumeStore.load(for: "yaqin", defaults: defaults))
        JourneyResumeStore.save(.init(beatIndex: 7, offset: 3.5), for: "yaqin", defaults: defaults)
        XCTAssertEqual(JourneyResumeStore.load(for: "yaqin", defaults: defaults), .init(beatIndex: 7, offset: 3.5))
        JourneyResumeStore.save(.init(beatIndex: 9, offset: 0), for: "yaqin", defaults: defaults)   // overwrite
        XCTAssertEqual(JourneyResumeStore.load(for: "yaqin", defaults: defaults)?.beatIndex, 9)
        // isolation: another journey is independent
        JourneyResumeStore.save(.init(beatIndex: 2, offset: 1), for: "surah-fatiha", defaults: defaults)
        JourneyResumeStore.clear(for: "yaqin", defaults: defaults)
        XCTAssertNil(JourneyResumeStore.load(for: "yaqin", defaults: defaults))
        XCTAssertEqual(JourneyResumeStore.load(for: "surah-fatiha", defaults: defaults)?.beatIndex, 2)
    }
}
