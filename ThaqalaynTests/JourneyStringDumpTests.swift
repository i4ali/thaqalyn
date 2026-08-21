//
//  JourneyStringDumpTests.swift
//  ThaqalaynTests
//
//  DEBUG-only string dump: emits, in timeline order, every English `.speech`
//  string the narrator must speak for each journey (deep dive + surah experience).
//  Consumed by scripts/extract_journey_strings.py, which pre-renders these to audio.
//
//  This is the correctness anchor: the extractor never re-implements narration logic.
//  It reads back *exactly* what `JourneyNarration.timeline(for:)` yields at runtime,
//  so a pre-rendered mp3 is guaranteed to match the string the app hashes and plays.
//
//  NO-OP unless JRNY_DUMP is set in the environment. A normal test run asserts
//  nothing and returns immediately. The extractor forwards the flag via xcodebuild's
//  test-runner mechanism (TEST_RUNNER_JRNY_DUMP=1 -> XCTest exposes JRNY_DUMP=1).
//
//  OUTPUT CHANNEL: XCTest runs on the simulator in a separate process whose stdout is
//  NOT echoed to xcodebuild's console, so `print()` can't be scraped by the extractor.
//  The dump is therefore written to a host-visible FILE (the simulator shares the host
//  filesystem); the extractor passes the path via TEST_RUNNER_JRNY_OUT and reads it back.
//  It is also printed, harmlessly, so the dump is visible when run from Xcode.
//

import XCTest
@testable import Thaqalayn

final class JourneyStringDumpTests: XCTestCase {

    /// Every built dive, in a stable order, from both catalogs. `compactMap` drops the
    /// coming-soon (nil) entries; a de-dupe by `id` keeps a dive listed in both catalogs
    /// from being dumped twice. Covers all `DeepDive` statics under Content/ (the two
    /// catalogs together reference every one). `.yaqin` and `.surahFatiha` are included.
    private func allDives() -> [DeepDive] {
        let candidates = DeepDiveDescriptor.all.compactMap { $0.dive }
                       + SurahExperienceDescriptor.all.compactMap { $0.dive }
        var seen = Set<String>()
        return candidates.filter { seen.insert($0.id).inserted }
    }

    /// Writes one tab-delimited line per English narrator string, in timeline order:
    ///   JRNYDUMP<TAB><journeyId><TAB><orderIndex><TAB><speechText>
    /// prefixed by a `JRNYDUMP<TAB>__meta__<TAB>count<TAB><n>` sentinel (a cross-check
    /// for the extractor - it is metadata, not a journey, and is skipped when parsing).
    ///
    /// Gated on JRNY_DUMP so it is a NO-OP during normal test runs. Recitation and pause
    /// segments are skipped: only `.speech` is pre-rendered narrator audio.
    func test_dumpJourneySpeechStrings() throws {
        let env = ProcessInfo.processInfo.environment
        guard env["JRNY_DUMP"] != nil else { return }

        let dives = allDives()
        var lines: [String] = ["JRNYDUMP\t__meta__\tcount\t\(dives.count)"]
        for dive in dives {
            var order = 0
            for segment in JourneyNarration.timeline(for: dive) {
                guard case .speech(let text) = segment else { continue }
                // Dive prose carries no embedded tabs/newlines, so a single tab-delimited
                // line per string is unambiguous for the extractor.
                lines.append("JRNYDUMP\t\(dive.id)\t\(order)\t\(text)")
                order += 1
            }
        }
        let payload = lines.joined(separator: "\n") + "\n"

        // Host-visible file is the reliable channel (see file header). The extractor
        // supplies the path via TEST_RUNNER_JRNY_OUT; a fixed /tmp path is the fallback
        // for manual runs. Failing to write is a hard test failure - a silent miss here
        // would ship un-rendered narration.
        let outPath = env["JRNY_OUT"] ?? "/tmp/journey_string_dump.tsv"
        try payload.write(toFile: outPath, atomically: true, encoding: .utf8)

        // Also echo to the test console (visible when run from Xcode; ignored by the extractor).
        print(payload, terminator: "")
    }
}
