//
//  WidgetLocationStore.swift
//  Thaqalayn
//
//  The ONLY data that crosses the App Group: one cached location (coordinates
//  + timezone) so the widget can compute prayer times. Nothing else, ever
//  (design decision - no personal state on the widget).
//
//  Target membership: Thaqalayn AND ThaqalaynWidgets.
//

import Foundation

struct WidgetLocation: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let timeZoneId: String

    var timeZone: TimeZone { TimeZone(identifier: timeZoneId) ?? .current }
}

struct WidgetLocationStore {
    static let suiteName = "group.MAHR.Partner.Thaqalayn"
    private static let key = "widgetPrayerLocation"

    private let defaults: UserDefaults

    init(defaults: UserDefaults? = UserDefaults(suiteName: WidgetLocationStore.suiteName)) {
        self.defaults = defaults ?? .standard
    }

    func load() -> WidgetLocation? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(WidgetLocation.self, from: data)
    }

    func save(latitude: Double, longitude: Double, timeZoneId: String) {
        let loc = WidgetLocation(latitude: latitude, longitude: longitude, timeZoneId: timeZoneId)
        defaults.set(try? JSONEncoder().encode(loc), forKey: Self.key)
    }
}
