//
//  FatimiyyaJourneyManager.swift
//  Thaqalayn
//
//  Manager for the 5-day "Ayyam-e-Fatimiyya" Journey feature
//  Handles progress tracking and persistence
//  Progress is SEPARATE from main ProgressManager (verse counts, streaks, sawab)
//

import Foundation
import Combine

@MainActor
class FatimiyyaJourneyManager: ObservableObject {
    static let shared = FatimiyyaJourneyManager()

    // MARK: - Published Properties

    @Published var days: [FatimiyyaDay] = []
    @Published var progress: FatimiyyaJourneyProgress = FatimiyyaJourneyProgress()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UserDefaults Keys

    private let progressKey = "fatimiyyaJourneyProgress"

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

        guard let url = Bundle.main.url(forResource: "fatimiyya_journey", withExtension: "json") else {
            errorMessage = "Could not find fatimiyya_journey.json"
            isLoading = false
            print("FatimiyyaJourneyManager: fatimiyya_journey.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let journeyData = try decoder.decode(FatimiyyaJourneyData.self, from: data)

            self.days = journeyData.days
            self.isLoading = false
            print("FatimiyyaJourneyManager: Loaded \(self.days.count) journey days")
        } catch {
            self.errorMessage = "Failed to load journey: \(error.localizedDescription)"
            self.isLoading = false
            print("FatimiyyaJourneyManager: Failed to load - \(error.localizedDescription)")
        }
    }

    // MARK: - Progress Persistence

    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(FatimiyyaJourneyProgress.self, from: data) {
            self.progress = decoded
            print("FatimiyyaJourneyManager: Loaded progress - \(progress.observedDays.count) days observed")
        }
    }

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
            print("FatimiyyaJourneyManager: Saved progress")
        }
    }

    // MARK: - Year Reset Logic

    /// Check if we need to reset progress for a new Islamic year
    private func checkYearReset() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()

        if progress.year != currentYear {
            // New Islamic year - reset progress
            print("FatimiyyaJourneyManager: New Islamic year \(currentYear) - resetting progress")
            progress = FatimiyyaJourneyProgress(year: currentYear)
            saveProgress()
        }
    }

    // MARK: - Day Observation

    /// Mark a day as observed
    func markDayObserved(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 5 else { return }
        guard !isDayObserved(dayNumber) else { return }

        progress.observedDays.insert(dayNumber)
        progress.lastObservedDate = Date()

        // Ensure year is set
        if progress.year == 0 {
            progress.year = IslamicCalendarManager.shared.currentIslamicYear()
        }

        saveProgress()
        print("FatimiyyaJourneyManager: Day \(dayNumber) marked observed (\(progress.observedDays.count)/5)")
    }

    /// Unmark a day (undo observation)
    func unmarkDayObserved(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 5 else { return }
        guard isDayObserved(dayNumber) else { return }

        progress.observedDays.remove(dayNumber)
        saveProgress()
        print("FatimiyyaJourneyManager: Day \(dayNumber) unmarked (\(progress.observedDays.count)/5)")
    }

    /// Check if a specific day is observed
    func isDayObserved(_ dayNumber: Int) -> Bool {
        return progress.observedDays.contains(dayNumber)
    }

    // MARK: - Lookup Methods

    /// Get a specific day by number
    func day(byNumber dayNumber: Int) -> FatimiyyaDay? {
        return days.first { $0.dayNumber == dayNumber }
    }

    /// Get a specific day by ID
    func day(byId id: String) -> FatimiyyaDay? {
        return days.first { $0.id == id }
    }

    // MARK: - Statistics

    /// Number of observed days
    var observedDaysCount: Int {
        return progress.observedDays.count
    }

    /// Completion percentage (0.0 to 1.0)
    var completionPercentage: Double {
        return progress.completionPercentage
    }

    /// Check if the entire journey is observed
    var isJourneyCompleted: Bool {
        return progress.observedDays.count >= 5
    }

    /// Get remaining days count
    var remainingDaysCount: Int {
        return max(0, 5 - progress.observedDays.count)
    }

    // MARK: - Reset

    /// Reset all progress (for testing or user request)
    func resetProgress() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        progress = FatimiyyaJourneyProgress(year: currentYear)
        saveProgress()
        print("FatimiyyaJourneyManager: Progress reset")
    }
}
