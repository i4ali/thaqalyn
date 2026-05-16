//
//  HajjJourneyManager.swift
//  Thaqalayn
//
//  Manager for the 10-day "First Ten Days of Dhul-Hijjah" Journey feature
//  Handles progress tracking, persistence, and badge awarding
//  Progress is SEPARATE from main ProgressManager (verse counts, streaks, sawab)
//

import Foundation
import Combine

@MainActor
class HajjJourneyManager: ObservableObject {
    static let shared = HajjJourneyManager()

    // MARK: - Published Properties

    @Published var days: [HajjDay] = []
    @Published var progress: HajjJourneyProgress = HajjJourneyProgress()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UserDefaults Keys

    private let progressKey = "hajjJourneyProgress"

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

        guard let url = Bundle.main.url(forResource: "hajj_journey", withExtension: "json") else {
            errorMessage = "Could not find hajj_journey.json"
            isLoading = false
            print("HajjJourneyManager: hajj_journey.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let journeyData = try decoder.decode(HajjJourneyData.self, from: data)

            self.days = journeyData.days
            self.isLoading = false
            print("HajjJourneyManager: Loaded \(self.days.count) journey days")
        } catch {
            self.errorMessage = "Failed to load journey: \(error.localizedDescription)"
            self.isLoading = false
            print("HajjJourneyManager: Failed to load - \(error.localizedDescription)")
        }
    }

    // MARK: - Progress Persistence

    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(HajjJourneyProgress.self, from: data) {
            self.progress = decoded
            print("HajjJourneyManager: Loaded progress - \(progress.completedDays.count) days completed")
        }
    }

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
            print("HajjJourneyManager: Saved progress")
        }
    }

    // MARK: - Year Reset Logic

    /// Check if we need to reset progress for a new Islamic year
    private func checkYearReset() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()

        if progress.year != currentYear {
            // New Islamic year - reset progress
            print("HajjJourneyManager: New Islamic year \(currentYear) - resetting progress")
            progress = HajjJourneyProgress(year: currentYear)
            saveProgress()
        }
    }

    // MARK: - Day Completion

    /// Mark a day as completed
    func markDayCompleted(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 10 else { return }
        guard !isDayCompleted(dayNumber) else { return }

        progress.completedDays.insert(dayNumber)
        progress.lastCompletedDate = Date()

        // Ensure year is set
        if progress.year == 0 {
            progress.year = IslamicCalendarManager.shared.currentIslamicYear()
        }

        saveProgress()
        print("HajjJourneyManager: Day \(dayNumber) marked complete (\(progress.completedDays.count)/10)")

        // Check for completion badge
        checkForCompletionBadge()
    }

    /// Unmark a day (undo completion)
    func unmarkDayCompleted(_ dayNumber: Int) {
        guard dayNumber >= 1 && dayNumber <= 10 else { return }
        guard isDayCompleted(dayNumber) else { return }

        progress.completedDays.remove(dayNumber)
        saveProgress()
        print("HajjJourneyManager: Day \(dayNumber) unmarked (\(progress.completedDays.count)/10)")
    }

    /// Check if a specific day is completed
    func isDayCompleted(_ dayNumber: Int) -> Bool {
        return progress.completedDays.contains(dayNumber)
    }

    // MARK: - Badge Awarding

    /// Check if all 10 days are completed and award badge
    private func checkForCompletionBadge() {
        guard progress.isCompleted else { return }

        // Award badge through ProgressManager
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        ProgressManager.shared.awardHajjBadge(year: currentYear)

        print("HajjJourneyManager: Journey complete! Badge awarded for year \(currentYear)")
    }

    // MARK: - Lookup Methods

    /// Get a specific day by number
    func day(byNumber dayNumber: Int) -> HajjDay? {
        return days.first { $0.dayNumber == dayNumber }
    }

    /// Get a specific day by ID
    func day(byId id: String) -> HajjDay? {
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
        return max(0, 10 - progress.completedDays.count)
    }

    // MARK: - Reset

    /// Reset all progress (for testing or user request)
    func resetProgress() {
        let currentYear = IslamicCalendarManager.shared.currentIslamicYear()
        progress = HajjJourneyProgress(year: currentYear)
        saveProgress()
        print("HajjJourneyManager: Progress reset")
    }
}
