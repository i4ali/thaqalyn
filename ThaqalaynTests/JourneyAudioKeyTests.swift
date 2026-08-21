import XCTest
@testable import Thaqalayn

final class JourneyAudioKeyTests: XCTestCase {
    func test_key_isStableAndNFCNormalized() {
        XCTAssertEqual(JourneyAudioKey.key(for: "Certainty is not the absence of doubt."),
                       "4498c0bd55262f1af403")
        XCTAssertEqual(JourneyAudioKey.key(for: "  trimmed  "), JourneyAudioKey.key(for: "trimmed"))
        XCTAssertEqual(JourneyAudioKey.key(for: "café").count, 20)
    }
}
