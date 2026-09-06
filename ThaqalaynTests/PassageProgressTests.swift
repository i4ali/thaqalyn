// ThaqalaynTests/PassageProgressTests.swift
import XCTest
@testable import Thaqalayn

final class PassageProgressTests: XCTestCase {
    let adam = PassageRef(surah: 2, index: 4, start: 30, end: 39)

    func testReadWhenEveryVerseRead() {
        let all = Set((30...39).map { "2:\($0)" })
        XCTAssertTrue(PassageProgress.isRead(adam, readVerseKeys: all))
        XCTAssertFalse(PassageProgress.isRead(adam, readVerseKeys: all.subtracting(["2:35"])))
        XCTAssertFalse(PassageProgress.isRead(adam, readVerseKeys: []))
    }

    func testCountsReadPassages() {
        let refs = [PassageRef(surah: 2, index: 1, start: 1, end: 7),
                    PassageRef(surah: 2, index: 2, start: 8, end: 20), adam]
        let keys = Set((1...7).map { "2:\($0)" } + (30...39).map { "2:\($0)" })
        XCTAssertEqual(PassageProgress.readCount(refs, readVerseKeys: keys), 2)
    }
}
