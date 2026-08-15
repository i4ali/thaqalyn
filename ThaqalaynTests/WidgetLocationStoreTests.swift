//
//  WidgetLocationStoreTests.swift
//  ThaqalaynTests
//

import XCTest
@testable import Thaqalayn

final class WidgetLocationStoreTests: XCTestCase {
    func testRoundTrip() {
        let defaults = UserDefaults(suiteName: "test.widget.location")!
        defaults.removePersistentDomain(forName: "test.widget.location")
        let store = WidgetLocationStore(defaults: defaults)
        XCTAssertNil(store.load())
        store.save(latitude: 34.64, longitude: 50.88, timeZoneId: "Asia/Tehran")
        let loc = store.load()
        XCTAssertEqual(loc?.latitude, 34.64)
        XCTAssertEqual(loc?.longitude, 50.88)
        XCTAssertEqual(loc?.timeZoneId, "Asia/Tehran")
    }

    func testCorruptDataLoadsAsNil() {
        let defaults = UserDefaults(suiteName: "test.widget.location.corrupt")!
        defaults.removePersistentDomain(forName: "test.widget.location.corrupt")
        defaults.set(Data("not json".utf8), forKey: "widgetPrayerLocation")
        XCTAssertNil(WidgetLocationStore(defaults: defaults).load())
    }
}
