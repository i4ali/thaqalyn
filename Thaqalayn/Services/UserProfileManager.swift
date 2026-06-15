//
//  UserProfileManager.swift
//  Thaqalayn
//
//  User profile preferences. Currently: a personal display name shown beside
//  the Today-tab greeting, set during onboarding (PersonalizeScreen) or in
//  Settings. Same singleton + UserDefaults pattern as ReadingSettingsManager.
//

import SwiftUI

@MainActor
final class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()

    private static let storageKey = "userDisplayName"

    /// Raw, as-typed name so a bound TextField types spaces normally; the
    /// trimmed form for display is exposed via `greetingName`.
    @Published var displayName: String {
        didSet { UserDefaults.standard.set(displayName, forKey: Self.storageKey) }
    }

    private init() {
        displayName = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
    }

    /// Trimmed name for the greeting (empty when only whitespace).
    var greetingName: String { displayName.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Whether a non-empty name has been set.
    var hasName: Bool { !greetingName.isEmpty }
}
