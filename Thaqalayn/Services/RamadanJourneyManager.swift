//
//  RamadanJourneyManager.swift
//  Thaqalayn
//
//  Manager for 30-day Ramadan Journey feature
//  Handles progress tracking, persistence, and badge awarding
//  Progress is SEPARATE from main ProgressManager (verse counts, streaks, sawab)
//

import Foundation
import Combine

@MainActor
class RamadanJourneyManager: ObservableObject {
    static let shared = RamadanJourneyManager()

    // MARK: - Published Properties

    @Published var days: [RamadanDay] = []
    @Published var progress: RamadanJourneyProgress = RamadanJourneyProgress()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UserDefaults Keys

    private let progressKey = "ramadanJourneyProgress"

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

        guard let url = Bundle.main.url(forResource: "ramadan_journey", withExtension: "json") else {
            errorMessage = "Could not find ramadan_journey.json"
            isLoading = false
            print("RamadanJourneyManager: ramadan_journey.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let journeyData = try decoder.decode(RamadanJourneyData.self, from: data)

            self.days = journeyData.days
            self.isLoading = false
            print("RamadanJourneyManager: Loaded \(self.days.count) journey days")
        } catch {
            self.errorMessage = "Failed to load journey: \(error.localizedDescription)"
            self.isLoading = false
            print("RamadanJourneyManager: Failed to load - \(error.localizedDescription)")
        }
    }

    // MARK: - Progress Persistence

    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(RamadanJourneyProgress.self, from: data) {
            self.progress = decoded
            print("RamadanJourneyManager: Loaded progress - \(progress.completedDays.count) days completed")
        }
    }

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
            print("RamadanJourneyManager: Saved progress")
        }
    }

    // MARK: - Year Reset Logic

    /// Check if we need to reset progress for a new Islamic year
    private func checkYearReset() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()

        if progress.year != currentYear {
            // New Islamic year - reset progress
            print("RamadanJourneyManager: New Islamic year \(currentYear) - resetting progress")
            progress = RamadanJourneyProgress(year: currentYear)
            saveProgress()
        }
    }

    // MARK: - Day Completion

    /// Mark a day as completed
    func markDayCompleted(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 30 else { return }
        guard !isDayCompleted(dayNumber) else { return }

        progress.completedDays.insert(dayNumber)
        progress.lastCompletedDate = Date()

        // Ensure year is set
        if progress.year == 0 {
            progress.year = IslamicCalendarManager.shared.currentIslamicYear()
        }

        saveProgress()
        print("RamadanJourneyManager: Day \(dayNumber) marked complete (\(progress.completedDays.count)/30)")

        // Check for completion badge
        checkForCompletionBadge()
    }

    /// Unmark a day (undo completion)
    func unmarkDayCompleted(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 30 else { return }
        guard isDayCompleted(dayNumber) else { return }

        progress.completedDays.remove(dayNumber)
        saveProgress()
        print("RamadanJourneyManager: Day \(dayNumber) unmarked (\(progress.completedDays.count)/30)")
    }

    /// Check if a specific day is completed
    func isDayCompleted(_ dayNumber: Int) -> Bool {
        return progress.completedDays.contains(dayNumber)
    }

    // MARK: - Badge Awarding

    /// Check if all 30 days are completed and award badge
    private func checkForCompletionBadge() {
        guard progress.isCompleted else { return }

        // Award badge through ProgressManager
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        ProgressManager.shared.awardRamadanBadge(year: currentYear)

        print("RamadanJourneyManager: Journey complete! Badge awarded for year \(currentYear)")
    }

    // MARK: - Lookup Methods

    /// Get a specific day by number
    func day(byNumber dayNumber: Int) -> RamadanDay? {
        return days.first { $0.dayNumber == dayNumber }
    }

    /// Get a specific day by ID
    func day(byId id: String) -> RamadanDay? {
        return days.first { $0.id == id }
    }

    // MARK: - Statistics

    /// Number of completed days
    var completedDaysCount: Int {
        return progress.completedDays.count
    }

    /// Completion percentage (0.0 to 1.0)
    var completionPercentage: Double {
        return progress.completionPercentage
    }

    /// Check if the entire journey is completed
    var isJourneyCompleted: Bool {
        return progress.isCompleted
    }

    /// Get remaining days count
    var remainingDaysCount: Int {
        return max(0, 30 - progress.completedDays.count)
    }

    // MARK: - Reset

    /// Reset all progress (for testing or user request)
    func resetProgress() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        progress = RamadanJourneyProgress(year: currentYear)
        saveProgress()
        print("RamadanJourneyManager: Progress reset")
    }
}
