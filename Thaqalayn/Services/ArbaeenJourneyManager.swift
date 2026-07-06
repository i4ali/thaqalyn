//
//  ArbaeenJourneyManager.swift
//  Thaqalayn
//
//  Manager for the 8-station "Arbaeen" Journey ("The Return") feature.
//  Handles progress tracking and persistence.
//  Progress is SEPARATE from main ProgressManager (verse counts, streaks, sawab).
//  Mourning journey: "observed" days, no badge awarding (mirrors Fatimiyya).
//

import Foundation
import Combine

@MainActor
class ArbaeenJourneyManager: ObservableObject {
    static let shared = ArbaeenJourneyManager()

    // MARK: - Published Properties

    @Published var days: [ArbaeenDay] = []
    @Published var progress: ArbaeenJourneyProgress = ArbaeenJourneyProgress()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UserDefaults Keys

    private let progressKey = "arbaeenJourneyProgress"

    // MARK: - Initialization

    private init() {
        loadProgress()
        loadDays()
        checkYearReset()
    }

    // MARK: - Data Loading

    func loadDays() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "arbaeen_journey", withExtension: "json") else {
            errorMessage = "Could not find arbaeen_journey.json"
            isLoading = false
            print("ArbaeenJourneyManager: arbaeen_journey.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let journeyData = try decoder.decode(ArbaeenJourneyData.self, from: data)

            self.days = journeyData.days
            self.isLoading = false
            print("ArbaeenJourneyManager: Loaded \(self.days.count) journey stations")
        } catch {
            self.errorMessage = "Failed to load journey: \(error.localizedDescription)"
            self.isLoading = false
            print("ArbaeenJourneyManager: Failed to load - \(error.localizedDescription)")
        }
    }

    // MARK: - Progress Persistence

    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(ArbaeenJourneyProgress.self, from: data) {
            self.progress = decoded
            print("ArbaeenJourneyManager: Loaded progress - \(progress.observedDays.count) stations observed")
        }
    }

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
            print("ArbaeenJourneyManager: Saved progress")
        }
    }

    // MARK: - Year Reset Logic

    /// Check if we need to reset progress for a new Islamic year
    private func checkYearReset() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()

        if progress.year != currentYear {
            // New Islamic year - reset progress
            print("ArbaeenJourneyManager: New Islamic year \(currentYear) - resetting progress")
            progress = ArbaeenJourneyProgress(year: currentYear)
            saveProgress()
        }
    }

    // MARK: - Station Observation

    /// Mark a station as observed
    func markDayObserved(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 8 else { return }
        guard !isDayObserved(dayNumber) else { return }

        progress.observedDays.insert(dayNumber)
        progress.lastObservedDate = Date()

        // Ensure year is set
        if progress.year == 0 {
            progress.year = IslamicCalendarManager.shared.currentIslamicYear()
        }

        saveProgress()
        print("ArbaeenJourneyManager: Station \(dayNumber) marked observed (\(progress.observedDays.count)/8)")
    }

    /// Unmark a station (undo observation)
    func unmarkDayObserved(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 8 else { return }
        guard isDayObserved(dayNumber) else { return }

        progress.observedDays.remove(dayNumber)
        saveProgress()
        print("ArbaeenJourneyManager: Station \(dayNumber) unmarked (\(progress.observedDays.count)/8)")
    }

    /// Check if a specific station is observed
    func isDayObserved(_ dayNumber: Int) -> Bool {
        return progress.observedDays.contains(dayNumber)
    }

    // MARK: - Lookup Methods

    /// Get a specific station by number
    func day(byNumber dayNumber: Int) -> ArbaeenDay? {
        return days.first { $0.dayNumber == dayNumber }
    }

    /// Get a specific station by ID
    func day(byId id: String) -> ArbaeenDay? {
        return days.first { $0.id == id }
    }

    // MARK: - Statistics

    /// Number of observed stations
    var observedDaysCount: Int {
        return progress.observedDays.count
    }

    /// Completion percentage (0.0 to 1.0)
    var completionPercentage: Double {
        return progress.completionPercentage
    }

    /// Check if the entire journey is observed
    var isJourneyCompleted: Bool {
        return progress.observedDays.count >= 8
    }

    /// Get remaining stations count
    var remainingDaysCount: Int {
        return max(0, 8 - progress.observedDays.count)
    }

    // MARK: - Reset

    /// Reset all progress (for testing or user request)
    func resetProgress() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        progress = ArbaeenJourneyProgress(year: currentYear)
        saveProgress()
        print("ArbaeenJourneyManager: Progress reset")
    }
}
