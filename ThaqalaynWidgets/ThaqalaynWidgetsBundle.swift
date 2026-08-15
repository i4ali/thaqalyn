//
//  ThaqalaynWidgetsBundle.swift
//  ThaqalaynWidgets
//

import WidgetKit
import SwiftUI

@main
struct ThaqalaynWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DailyReflectionWidget()
        HijriDateAccessory()
        NextPrayerAccessory()
    }
}
