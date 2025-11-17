//
//  ProgressManager.swift
//  Thaqalayn
//
//  Service for managing reading progress, streaks, and badges
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProgressManager: ObservableObject {
    static let shared = ProgressManager()

    // MARK: - Published Properties

    @Published var verseProgress: [VerseProgress] = []
    @Published var streak: ReadingStreak = ReadingStreak()
    @Published var badges: [BadgeAward] = []
    @Published var stats: ProgressStats = ProgressStats()
    @Published var preferences: ProgressPreferences = ProgressPreferences()
    @Published var pendingBadge: BadgeAward? = nil // For showing badge celebration
    @Published var isSyncing = false
    @Published var syncStatus: String?
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var hasConflict: Bool = false
    @Published var conflictMessage: String?

    // MARK: - UserDefaults Keys

    private let verseProgressKey = "verseProgress"
    private let streakKey = "readingStreak"
    private let badgesKey = "badgeAwards"
    private let statsKey = "progressStats"
    private let preferencesKey = "progressPreferences"

    // MARK: - Sync Properties

    private var supabaseService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    private var progressData: ReadingProgressData?
    private var lastAuthenticatedUserId: String?
    private var needsSync: Bool = false // Tracks if local changes need uploading
    private var pendingDeletes: Set<String> = [] // For future use if deletion is needed

    // MARK: - Initialization

    private init() {
        loadProgress()
        setupSupabaseObservers()
    }

    // MARK: - Data Persistence

    func loadProgress() {
        // Load verse progress
        if let data = UserDefaults.standard.data(forKey: verseProgressKey),
           let decoded = try? JSONDecoder().decode([VerseProgress].self, from: data) {
            self.verseProgress = decoded
        }

        // Load streak
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let decoded = try? JSONDecoder().decode(ReadingStreak.self, from: data) {
            self.streak = decoded
        }

        // Load badges
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let decoded = try? JSONDecoder().decode([BadgeAward].self, from: data) {
            self.badges = decoded
        }

        // Load stats
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(ProgressStats.self, from: data) {
            self.stats = decoded
        }

        // Load preferences
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(ProgressPreferences.self, from: data) {
            self.preferences = decoded
        }

        // Update today's verse count and streak on load
        updateTodayVersesCount()
        updateStreakOnLoad()
    }

    private func saveProgress() {
        // Save verse progress
        if let encoded = try? JSONEncoder().encode(verseProgress) {
            UserDefaults.standard.set(encoded, forKey: verseProgressKey)
        }

        // Save streak
        if let encoded = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(encoded, forKey: streakKey)
        }

        // Save badges
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }

        // Save stats
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }

        // Save preferences
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }

    // MARK: - Supabase Sync

    private func setupSupabaseObservers() {
        // Observe authentication state changes
        supabaseService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)

        supabaseService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }

                if let user = user {
                    let newUserId = user.id.uuidString

                    // Check if this is a different user
                    if let lastUserId = self.lastAuthenticatedUserId, lastUserId != newUserId {
                        print("🔄 ProgressManager: User changed - clearing local data")
                        self.clearAllLocalData()
                    }

                    // Update last authenticated user
                    self.lastAuthenticatedUserId = newUserId

                    // Perform initial sync
                    Task {
                        await self.performInitialSync()
                    }
                } else {
                    // User signed out - clear last user ID
                    self.lastAuthenticatedUserId = nil
                }
            }
            .store(in: &cancellables)
    }

    private func clearAllLocalData() {
        verseProgress = []
        streak = ReadingStreak()
        badges = []
        stats = ProgressStats()
        preferences = ProgressPreferences()
        progressData = nil
        pendingDeletes.removeAll()

        // Clear sync status
        syncStatus = nil
        errorMessage = nil
        hasConflict = false
        conflictMessage = nil

        // Remove from UserDefaults (matching BookmarkManager pattern)
        UserDefaults.standard.removeObject(forKey: verseProgressKey)
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: badgesKey)
        UserDefaults.standard.removeObject(forKey: statsKey)
        UserDefaults.standard.removeObject(forKey: preferencesKey)

        print("🗑️ ProgressManager: Cleared all local progress data")
    }

    func signOutAndClearRemoteData() async {
        do {
            try await supabaseService.signOut()

            // Clear all local data for clean state
            clearAllLocalData()

            print("✅ ProgressManager: Signed out and cleared all local data")
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
            print("❌ ProgressManager: Sign out error: \(error)")
        }
    }

    private func performInitialSync() async {
        // Only perform initial sync once after authentication (matching BookmarkManager pattern)
        // Skip if we already have synced data (progressData exists and no pending changes)
        guard isAuthenticated &&
              !(progressData != nil && !needsSync) else {
            return
        }

        syncStatus = "Initial sync..."
        await performSync()
    }

    // MARK: - Three-Step Sync Pattern (matching BookmarkManager)

    private func performSync() async {
        guard isAuthenticated else {
            return
        }

        isSyncing = true
        syncStatus = "Syncing..."

        do {
            // Step 1: Process pending deletes (placeholder for future use)
            // Note: Single row per user, deletion not currently needed

            // Step 2: Upload pending changes (conditional - only if needsSync = true)
            try await uploadPendingProgress()

            // Step 3: Download remote changes (always executes)
            try await downloadRemoteProgress()

            syncStatus = "Sync completed"
        } catch {
            syncStatus = "Sync failed"
            errorMessage = "Sync failed: \(error.localizedDescription)"
            print("❌ ProgressManager: Sync error: \(error)")
        }

        isSyncing = false

        // Auto-clear sync status after 3 seconds (matching BookmarkManager)
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if syncStatus == "Sync completed" || syncStatus == "Sync failed" {
                syncStatus = nil
            }
        }
    }

    private func uploadPendingProgress() async throws {
        // Guard: Skip upload if no pending changes (THE KEY for fresh install)
        guard needsSync else {
            print("ℹ️ ProgressManager: No pending changes to upload - skipping")
            return
        }

        guard let userId = supabaseService.currentUser?.id.uuidString else {
            print("❌ ProgressManager: Cannot upload - no authenticated user")
            return
        }

        print("📤 ProgressManager: Uploading local progress to cloud")

        let localData = ReadingProgressData(
            verseProgress: verseProgress,
            readingStreak: streak,
            badges: badges,
            stats: stats,
            preferences: preferences,
            updatedAt: Date(),
            syncStatus: .synced
        )

        try await supabaseService.syncReadingProgress(localData, userId: userId)

        // Mark as synced after successful upload
        needsSync = false
        progressData = localData

        print("✅ ProgressManager: Upload successful")
    }

    private func downloadRemoteProgress() async throws {
        guard let userId = supabaseService.currentUser?.id.uuidString else {
            print("❌ ProgressManager: Cannot download - no authenticated user")
            return
        }

        print("📥 ProgressManager: Downloading remote progress")

        if let remoteData = try await supabaseService.fetchReadingProgress(userId: userId) {
            // Handle merge conflicts and take newer version
            if let local = progressData {
                // Check for conflict: local has pending changes AND remote is newer
                if needsSync && remoteData.updatedAt > local.updatedAt {
                    print("⚠️ ProgressManager: Sync conflict detected!")
                    print("   Local has pending changes but remote is newer")
                    print("   Preserving local changes to prevent data loss")

                    // Mark conflict explicitly (matching BookmarkManager pattern)
                    hasConflict = true
                    conflictMessage = "Local changes conflict with remote. Preserving local changes."

                    // Keep local changes, don't apply remote (conflict resolution)
                    // needsSync stays true so local changes will be uploaded next sync
                } else if remoteData.updatedAt > local.updatedAt {
                    // Local is synced and remote is newer - accept remote changes
                    print("🔄 ProgressManager: Remote data is newer - updating local")
                    applyRemoteData(remoteData)
                    progressData = remoteData

                    // Clear conflict status when successfully accepting remote
                    hasConflict = false
                    conflictMessage = nil
                } else {
                    // Local is current or newer
                    print("✅ ProgressManager: Local data is current")
                }
            } else {
                // No local progressData cached, use remote
                print("📥 ProgressManager: No cached data - using remote")
                applyRemoteData(remoteData)
                progressData = remoteData
            }

            print("✅ ProgressManager: Download successful")
        } else {
            print("ℹ️ ProgressManager: No remote data found")
        }
    }

    private func applyRemoteData(_ remoteData: ReadingProgressData) {
        verseProgress = remoteData.verseProgress
        streak = remoteData.readingStreak
        badges = remoteData.badges
        stats = remoteData.stats
        preferences = remoteData.preferences
        saveProgress()
    }

    /// Manually resolve conflicts by accepting remote changes
    func resolveConflictWithRemote() async {
        guard hasConflict else { return }

        hasConflict = false
        conflictMessage = nil
        needsSync = false

        // Re-download to get latest remote data
        await performSync()

        print("✅ ProgressManager: Conflict resolved - accepted remote changes")
    }

    private func scheduleSync() {
        guard supabaseService.isAuthenticated else {
            return
        }

        // Mark as needing sync (local changes exist)
        needsSync = true

        // Debounce sync requests to avoid excessive API calls
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            await performSync()
        }
    }

    // MARK: - Verse Progress Tracking

    @discardableResult
    func markVerseAsRead(surahNumber: Int, verseNumber: Int) -> Bool {
        // Validation
        guard surahNumber > 0 && surahNumber <= 114 else {
            errorMessage = "Invalid surah number"
            return false
        }

        let verseKey = "\(surahNumber):\(verseNumber)"

        // Check if already marked
        var isNewRead = false
        if let existingIndex = verseProgress.firstIndex(where: { $0.verseKey == verseKey }) {
            // Update existing
            var updated = verseProgress[existingIndex]
            updated = VerseProgress(
                id: updated.id,
                surahNumber: surahNumber,
                verseNumber: verseNumber,
                readDate: Date(),
                isRead: true
            )
            verseProgress[existingIndex] = updated
        } else {
            // Add new
            let progress = VerseProgress(
                surahNumber: surahNumber,
                verseNumber: verseNumber
            )
            verseProgress.append(progress)
            isNewRead = true
        }

        // Update stats
        stats.totalVersesRead = verseProgress.filter { $0.isRead }.count
        updateTodayVersesCount()
        stats.lastReadDate = Date()

        // Award sawab for verse reading (10 sawab per verse, based on hadith)
        if isNewRead {
            stats.totalSawab += 10
            print("✨ ProgressManager: +10 sawab earned! Total: \(stats.totalSawab)")
        }

        // Update streak
        updateStreak()

        // Check for surah completion and badges
        checkSurahCompletion(surahNumber: surahNumber)

        // Save changes
        saveProgress()

        // Sync to cloud if authenticated
        scheduleSync()

        print("✅ ProgressManager: Marked verse \(verseKey) as read")
        return true
    }

    @discardableResult
    func unmarkVerseAsRead(surahNumber: Int, verseNumber: Int) -> Bool {
        // Validation
        guard surahNumber > 0 && surahNumber <= 114 else {
            errorMessage = "Invalid surah number"
            return false
        }

        let verseKey = "\(surahNumber):\(verseNumber)"

        if let index = verseProgress.firstIndex(where: { $0.verseKey == verseKey }) {
            verseProgress.remove(at: index)

            // Update stats
            stats.totalVersesRead = verseProgress.filter { $0.isRead }.count
            updateTodayVersesCount()

            // Deduct sawab for unmarking verse
            stats.totalSawab = max(0, stats.totalSawab - 10)

            saveProgress()

            // Sync to cloud if authenticated
            scheduleSync()

            print("✅ ProgressManager: Unmarked verse \(verseKey)")
            return true
        } else {
            errorMessage = "Verse not found in progress"
            return false
        }
    }

    func isVerseRead(surahNumber: Int, verseNumber: Int) -> Bool {
        let verseKey = "\(surahNumber):\(verseNumber)"
        return verseProgress.contains(where: { $0.verseKey == verseKey && $0.isRead })
    }

    func getVerseProgress(surahNumber: Int, verseNumber: Int) -> VerseProgress? {
        let verseKey = "\(surahNumber):\(verseNumber)"
        return verseProgress.first(where: { $0.verseKey == verseKey })
    }

    // MARK: - Surah Completion

    func getSurahCompletion(surahNumber: Int) -> (read: Int, total: Int) {
        let surahVerses = verseProgress.filter { $0.surahNumber == surahNumber && $0.isRead }
        let totalVerses = DataManager.shared.getSurah(number: surahNumber)?.surah.versesCount ?? 0
        return (read: surahVerses.count, total: totalVerses)
    }

    func isSurahCompleted(surahNumber: Int) -> Bool {
        let completion = getSurahCompletion(surahNumber: surahNumber)
        return completion.read == completion.total && completion.total > 0
    }

    private func checkSurahCompletion(surahNumber: Int) {
        guard isSurahCompleted(surahNumber: surahNumber) else { return }

        // Check if badge already awarded
        let alreadyAwarded = badges.contains(where: {
            $0.surahNumber == surahNumber && $0.badgeType == .surahCompletion
        })

        if !alreadyAwarded, let surah = DataManager.shared.getSurah(number: surahNumber)?.surah {
            // Award badge
            let badge = BadgeAward(
                surahNumber: surahNumber,
                surahName: surah.englishName,
                arabicName: surah.arabicName,
                badgeType: .surahCompletion
            )
            badges.append(badge)
            stats.totalSurahsCompleted += 1

            // Award sawab for badge
            let badgeSawab = badge.badgeType.sawabValue
            stats.totalSawab += badgeSawab
            print("✨ ProgressManager: +\(badgeSawab) sawab earned from \(badge.badgeType.title)! Total: \(stats.totalSawab)")

            // Set pending badge for celebration
            if preferences.celebrationsEnabled {
                pendingBadge = badge
            }

            // Check milestone badges
            checkMilestoneBadges()

            saveProgress()

            // Sync to cloud if authenticated
            scheduleSync()

            print("🎉 ProgressManager: Surah \(surahNumber) completed! Badge awarded.")
        }
    }

    private func checkMilestoneBadges() {
        let completedSurahs = stats.totalSurahsCompleted

        // Check for milestone badges
        let milestones: [(count: Int, type: BadgeType)] = [
            (10, .milestone10),
            (25, .milestone25),
            (50, .milestone50),
            (114, .allSurahs)
        ]

        for milestone in milestones {
            if completedSurahs == milestone.count {
                let alreadyAwarded = badges.contains(where: { $0.badgeType == milestone.type })
                if !alreadyAwarded {
                    let badge = BadgeAward(
                        surahNumber: 0,
                        surahName: milestone.type.title,
                        arabicName: milestone.type.subtitle,
                        badgeType: milestone.type
                    )
                    badges.append(badge)

                    // Award sawab for milestone badge
                    let badgeSawab = badge.badgeType.sawabValue
                    stats.totalSawab += badgeSawab
                    print("✨ ProgressManager: +\(badgeSawab) sawab earned from \(milestone.type.title)! Total: \(stats.totalSawab)")

                    if preferences.celebrationsEnabled {
                        pendingBadge = badge
                    }

                    print("🎉 ProgressManager: Milestone badge awarded: \(milestone.type.title)")
                }
            }
        }
    }

    // MARK: - Streak Management

    private func updateStreakOnLoad() {
        guard let lastRead = streak.lastReadDate else { return }

        let calendar = Calendar.current
        let now = Date()

        // Check if streak should be broken
        if let daysSince = calendar.dateComponents([.day], from: lastRead, to: now).day {
            if daysSince > 1 {
                // Streak broken
                streak.currentStreak = 0
                streak.streakStartDate = nil
                print("📉 ProgressManager: Streak broken (last read \(daysSince) days ago)")
            }
        }

        // Update stats
        stats.currentStreak = streak.currentStreak
        stats.longestStreak = streak.longestStreak

        saveProgress()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let now = Date()

        if let lastRead = streak.lastReadDate {
            // Check if this is a new day
            if calendar.isDate(lastRead, inSameDayAs: now) {
                // Same day - no streak change
                return
            }

            // Check if this is the next day
            if let daysSince = calendar.dateComponents([.day], from: lastRead, to: now).day {
                if daysSince == 1 {
                    // Continue streak
                    streak.currentStreak += 1
                    if streak.currentStreak > streak.longestStreak {
                        streak.longestStreak = streak.currentStreak
                    }

                    // Check for streak badges
                    checkStreakBadges()

                    print("🔥 ProgressManager: Streak continued! Current: \(streak.currentStreak)")
                } else if daysSince > 1 {
                    // Streak broken - start new
                    streak.currentStreak = 1
                    streak.streakStartDate = now
                    print("📉 ProgressManager: Streak broken. Starting fresh.")
                }
            }
        } else {
            // First read ever
            streak.currentStreak = 1
            streak.longestStreak = 1
            streak.streakStartDate = now
            print("🎉 ProgressManager: First reading streak started!")
        }

        streak.lastReadDate = now

        // Update stats
        stats.currentStreak = streak.currentStreak
        stats.longestStreak = streak.longestStreak
        stats.lastReadDate = now
    }

    private func checkStreakBadges() {
        let streakMilestones: [(days: Int, type: BadgeType)] = [
            (7, .streak7),
            (30, .streak30),
            (100, .streak100)
        ]

        for milestone in streakMilestones {
            if streak.currentStreak == milestone.days {
                let alreadyAwarded = badges.contains(where: { $0.badgeType == milestone.type })
                if !alreadyAwarded {
                    let badge = BadgeAward(
                        surahNumber: 0,
                        surahName: milestone.type.title,
                        arabicName: milestone.type.subtitle,
                        badgeType: milestone.type
                    )
                    badges.append(badge)

                    // Award sawab for streak badge
                    let badgeSawab = badge.badgeType.sawabValue
                    stats.totalSawab += badgeSawab
                    print("✨ ProgressManager: +\(badgeSawab) sawab earned from \(milestone.type.title)! Total: \(stats.totalSawab)")

                    if preferences.celebrationsEnabled {
                        pendingBadge = badge
                    }

                    print("🔥 ProgressManager: Streak badge awarded: \(milestone.type.title)")
                }
            }
        }
    }

    // MARK: - Today's Verses Count

    private func updateTodayVersesCount() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todayVerses = verseProgress.filter { progress in
            calendar.isDate(progress.readDate, inSameDayAs: today)
        }

        stats.versesReadToday = todayVerses.count
    }

    // MARK: - Progress Stats

    func getProgressStats() -> ProgressStats {
        return stats
    }

    func getWeeklyProgress() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var weeklyData: [Int] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                weeklyData.append(0)
                continue
            }

            let dayStart = calendar.startOfDay(for: date)
            let versesOnDay = verseProgress.filter { progress in
                calendar.isDate(progress.readDate, inSameDayAs: dayStart)
            }.count

            weeklyData.append(versesOnDay)
        }

        return weeklyData
    }

    func getMonthlyProgress() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var monthlyData: [Int] = []

        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                monthlyData.append(0)
                continue
            }

            let dayStart = calendar.startOfDay(for: date)
            let versesOnDay = verseProgress.filter { progress in
                calendar.isDate(progress.readDate, inSameDayAs: dayStart)
            }.count

            monthlyData.append(versesOnDay)
        }

        return monthlyData
    }

    func getRecentActivity(limit: Int = 10) -> [VerseProgress] {
        return verseProgress
            .sorted { $0.readDate > $1.readDate }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Badge Management

    func getBadges() -> [BadgeAward] {
        return badges.sorted { $0.awardedDate > $1.awardedDate }
    }

    func dismissPendingBadge() {
        pendingBadge = nil
    }

    // MARK: - Preferences

    func updatePreferences(_ newPreferences: ProgressPreferences) {
        self.preferences = newPreferences
        saveProgress()
    }

    // MARK: - Reset Progress

    func resetProgress() async {
        // Clear local data
        verseProgress.removeAll()
        streak = ReadingStreak()
        badges.removeAll()
        stats = ProgressStats()
        pendingBadge = nil
        progressData = nil
        needsSync = false

        saveProgress()

        // Delete from cloud if authenticated (matching BookmarkManager deletion pattern)
        if isAuthenticated, let userId = supabaseService.currentUser?.id.uuidString {
            do {
                try await supabaseService.deleteReadingProgress(userId: userId)
                print("✅ ProgressManager: Deleted progress from cloud")
            } catch {
                errorMessage = "Failed to delete cloud progress: \(error.localizedDescription)"
                print("❌ ProgressManager: Cloud deletion failed: \(error)")
            }
        }

        print("🔄 ProgressManager: Progress reset (local + cloud)")
    }
}
