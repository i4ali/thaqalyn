// ThaqalaynTests/PassageMarkupTests.swift
import XCTest
@testable import Thaqalayn

final class PassageMarkupTests: XCTestCase {
    func testSegments() {
        let segs = PassageMarkup.segments("Tabatabai reads it [1] as a request [12].")
        XCTAssertEqual(segs, [.text("Tabatabai reads it "), .marker(1), .text(" as a request "), .marker(12), .text(".")])
        XCTAssertEqual(PassageMarkup.segments("No markers."), [.text("No markers.")])
        XCTAssertEqual(PassageMarkup.segments(""), [])
    }

    func testMarkerNumbers() {
        XCTAssertEqual(PassageMarkup.markerNumbers("a [3] b [1] c [3]"), [3, 1])
    }

    func testAttributedStringCarriesLinks() {
        let attr = PassageMarkup.attributed("Read [2] this.", baseFont: .systemFont(ofSize: 16), color: .black, accent: .blue)
        var links: [URL] = []
        for run in attr.runs { if let l = run.link { links.append(l) } }
        XCTAssertEqual(links, [URL(string: "thaqalayn-source://2")!])
        XCTAssertEqual(String(attr.characters), "Read 2 this.")
        XCTAssertEqual(PassageMarkup.sourceNumber(from: URL(string: "thaqalayn-source://2")!), 2)
        XCTAssertNil(PassageMarkup.sourceNumber(from: URL(string: "https://example.com")!))
    }
}
