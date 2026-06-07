//
//  ReadingSettingsManager.swift
//  Thaqalayn
//
//  User reading preferences. Currently: commentary body font scale, adjusted
//  from the in-context "Aa" control in FullScreenCommentaryView and persisted
//  across launches. Same singleton + UserDefaults pattern as ThemeManager.
//

import SwiftUI

@MainActor
final class ReadingSettingsManager: ObservableObject {
    static let shared = ReadingSettingsManager()

    private static let storageKey = "commentaryFontScaleIndex"

    /// Discrete multiplier steps applied to the commentary body font + leading.
    /// Default is index 1 (= 1.0×): one step smaller, three larger.
    static let steps: [CGFloat] = [0.9, 1.0, 1.15, 1.3, 1.5]
    static let defaultIndex = 1

    @Published var stepIndex: Int {
        didSet { UserDefaults.standard.set(stepIndex, forKey: Self.storageKey) }
    }

    private init() {
        if let saved = UserDefaults.standard.object(forKey: Self.storageKey) as? Int {
            stepIndex = min(max(saved, 0), Self.steps.count - 1) // clamp on load
        } else {
            stepIndex = Self.defaultIndex
        }
    }

    var scale: CGFloat { Self.steps[stepIndex] }
    var stepCount: Int { Self.steps.count }
    var canIncrease: Bool { stepIndex < Self.steps.count - 1 }
    var canDecrease: Bool { stepIndex > 0 }

    func increase() { if canIncrease { stepIndex += 1 } }
    func decrease() { if canDecrease { stepIndex -= 1 } }
}
