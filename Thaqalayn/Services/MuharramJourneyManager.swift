//
//  MuharramJourneyManager.swift
//  Thaqalayn
//
//  Manager for the 10-day "First Ten Days of Muharram" Journey feature
//  Handles progress tracking and persistence
//  Progress is SEPARATE from main ProgressManager (verse counts, streaks, sawab)
//

import Foundation
import Combine

@MainActor
class MuharramJourneyManager: ObservableObject {
    static let shared = MuharramJourneyManager()

    // MARK: - Published Properties

    @Published var days: [MuharramDay] = []
    @Published var progress: MuharramJourneyProgress = MuharramJourneyProgress()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UserDefaults Keys

    private let progressKey = "muharramJourneyProgress"

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

        guard let url = Bundle.main.url(forResource: "muharram_journey", withExtension: "json") else {
            errorMessage = "Could not find muharram_journey.json"
            isLoading = false
            print("MuharramJourneyManager: muharram_journey.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let journeyData = try decoder.decode(MuharramJourneyData.self, from: data)

            self.days = journeyData.days
            self.isLoading = false
            print("MuharramJourneyManager: Loaded \(self.days.count) journey days")
        } catch {
            self.errorMessage = "Failed to load journey: \(error.localizedDescription)"
            self.isLoading = false
            print("MuharramJourneyManager: Failed to load - \(error.localizedDescription)")
        }
    }

    // MARK: - Progress Persistence

    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(MuharramJourneyProgress.self, from: data) {
            self.progress = decoded
            print("MuharramJourneyManager: Loaded progress - \(progress.observedDays.count) days observed")
        }
    }

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
            print("MuharramJourneyManager: Saved progress")
        }
    }

    // MARK: - Year Reset Logic

    /// Check if we need to reset progress for a new Islamic year
    private func checkYearReset() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()

        if progress.year != currentYear {
            // New Islamic year - reset progress
            print("MuharramJourneyManager: New Islamic year \(currentYear) - resetting progress")
            progress = MuharramJourneyProgress(year: currentYear)
            saveProgress()
        }
    }

    // MARK: - Day Observation

    /// Mark a day as observed
    func markDayObserved(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 10 else { return }
        guard !isDayObserved(dayNumber) else { return }

        progress.observedDays.insert(dayNumber)
        progress.lastObservedDate = Date()

        // Ensure year is set
        if progress.year == 0 {
            progress.year = IslamicCalendarManager.shared.currentIslamicYear()
        }

        saveProgress()
        print("MuharramJourneyManager: Day \(dayNumber) marked observed (\(progress.observedDays.count)/10)")
    }

    /// Unmark a day (undo observation)
    func unmarkDayObserved(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 10 else { return }
        guard isDayObserved(dayNumber) else { return }

        progress.observedDays.remove(dayNumber)
        saveProgress()
        print("MuharramJourneyManager: Day \(dayNumber) unmarked (\(progress.observedDays.count)/10)")
    }

    /// Check if a specific day is observed
    func isDayObserved(_ dayNumber: Int) -> Bool {
        return progress.observedDays.contains(dayNumber)
    }

    // MARK: - Lookup Methods

    /// Get a specific day by number
    func day(byNumber dayNumber: Int) -> MuharramDay? {
        return days.first { $0.dayNumber == dayNumber }
    }

    /// Get a specific day by ID
    func day(byId id: String) -> MuharramDay? {
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
        return progress.observedDays.count >= 10
    }

    /// Get remaining days count
    var remainingDaysCount: Int {
        return max(0, 10 - progress.observedDays.count)
    }

    // MARK: - Reset

    /// Reset all progress (for testing or user request)
    func resetProgress() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        progress = MuharramJourneyProgress(year: currentYear)
        saveProgress()
        print("MuharramJourneyManager: Progress reset")
    }
}
