//
//  AudioManager.swift
//  Thaqalayn
//
//  Audio playback service for Quran recitation with background support
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

@MainActor
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - Published Properties
    @Published var currentPlayback: CurrentPlayback?
    @Published var playerState: AudioPlayerState = .stopped
    @Published var configuration: AudioConfiguration
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isBuffering = false
    @Published var errorMessage: String?
    @Published var sleepTimerTimeRemaining: TimeInterval?
    
    // MARK: - Verse Highlighting Properties
    @Published var currentlyHighlightedWord: Int?
    @Published var currentVerseTimingData: VerseTimingData?
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    private var timeObserver: Timer?
    private var sleepTimer: Timer?
    private var currentSurah: Surah?
    private var currentVerses: [VerseWithTafsir] = []
    private var currentVerseIndex: Int = 0
    private var quranAlignData: QuranAlignTimingData?
    
    // MARK: - Audio Caching
    private var audioCache: [String: Data] = [:]
    private let maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
    private var currentCacheSize: Int = 0
    
    
    // MARK: - Initialization
    override init() {
        self.audioSession = AVAudioSession.sharedInstance()
        self.configuration = AudioConfiguration()
        super.init()
        setupAudioSession()
        setupNotifications()
        loadConfiguration()
        validateCurrentReciter()
    }
    
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("❌ AudioManager: Failed to setup audio session: \(error)")
            errorMessage = "Failed to setup audio session"
        }
    }
    
    private func cleanupAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ AudioManager: Failed to cleanup audio session: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
    }
    
    // MARK: - Configuration Management
    private func loadConfiguration() {
        if let data = UserDefaults.standard.data(forKey: "ThaqalaynAudioConfiguration"),
           let config = try? JSONDecoder().decode(AudioConfiguration.self, from: data) {
            configuration = config
        }
    }
    
    func saveConfiguration() {
        if let data = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.set(data, forKey: "ThaqalaynAudioConfiguration")
        }
    }
    
    private func validateCurrentReciter() {
        // All reciters are now free - no validation needed
    }
    
    
    
    // MARK: - Playback Control
    
    func playVerse(_ verse: VerseWithTafsir, in surah: Surah) async {
        currentSurah = surah
        currentVerses = [verse] // Single verse mode
        currentVerseIndex = 0
        
        // Load quran-align timing data for this verse
        await loadQuranAlignData()
        currentVerseTimingData = quranAlignData?.getVerseTimingData(surahNumber: surah.number, ayahNumber: verse.number)
        
        if let timingData = currentVerseTimingData {
            print("✅ Using quran-align timing data for word highlighting")
            await playVerseWithTiming(verse: verse, surah: surah, timingData: timingData)
        } else {
            print("⚠️ No quran-align timing data - playing without word highlighting")
            await playVerseWithoutTiming(verse: verse, surah: surah)
        }
    }
    
    func playVerseSequence(_ verses: [VerseWithTafsir], in surah: Surah, startingFrom verseIndex: Int = 0) async {
        currentSurah = surah
        currentVerses = verses // Keep all verses for sequence playback
        currentVerseIndex = verseIndex
        
        // Load quran-align data once for all verses
        await loadQuranAlignData()
        
        // Start playing the first verse in the sequence
        guard verseIndex < verses.count else { return }
        await playCurrentVerse()
    }
    
    private func playVerseWithTiming(verse: VerseWithTafsir, surah: Surah, timingData: VerseTimingData) async {
        // Generate individual verse audio URL (EveryAyah style)
        guard let url = verse.audioURL(for: surah.number, reciter: configuration.selectedReciter) else {
            print("❌ AudioManager: Unable to generate verse audio URL for surah \(surah.number), verse \(verse.number)")
            errorMessage = "Unable to generate audio URL"
            playerState = .error
            return
        }
        
        print("🎵 AudioManager: Loading verse audio with timing from URL: \(url.absoluteString)")
        playerState = .loading
        isBuffering = true
        
        do {
            let audioData = try await loadAudioData(from: url)
            audioPlayer = try AVAudioPlayer(data: audioData)
            
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 1.0 // Fixed playback speed for accurate word timing
            audioPlayer?.prepareToPlay()
            
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            
            currentPlayback = CurrentPlayback(
                surahNumber: surah.number,
                surahName: surah.englishName,
                verseNumber: verse.number,
                reciter: configuration.selectedReciter,
                currentTime: 0,
                duration: duration,
                isPlaying: false
            )
            
            setupNowPlayingInfo(for: verse, in: surah)
            startTimeObserver()
            
            if audioPlayer?.play() == true {
                playerState = .playing
                isBuffering = false
                updateCurrentPlayback()
            } else {
                playerState = .error
                errorMessage = "Failed to start audio playback"
            }
            
        } catch {
            print("❌ AudioManager: Failed to load verse audio: \(error)")
            playerState = .error
            errorMessage = "Failed to load audio"
            isBuffering = false
        }
    }
    
    private func playVerseWithoutTiming(verse: VerseWithTafsir, surah: Surah) async {
        await loadAndPlayAudio(for: verse, in: surah)
    }
    
    private func loadAndPlayAudio(for verse: VerseWithTafsir, in surah: Surah) async {
        guard let url = verse.audioURL(for: surah.number, reciter: configuration.selectedReciter) else {
            print("❌ AudioManager: Unable to generate audio URL for surah \(surah.number), verse \(verse.number)")
            errorMessage = "Unable to generate audio URL"
            playerState = .error
            return
        }
        
        print("🎵 AudioManager: Loading audio from URL: \(url.absoluteString)")
        playerState = .loading
        isBuffering = true
        
        do {
            let audioData = try await loadAudioData(from: url)
            audioPlayer = try AVAudioPlayer(data: audioData)
            
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 1.0 // Fixed playback speed for accurate verse timing
            audioPlayer?.prepareToPlay()
            
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            
            currentPlayback = CurrentPlayback(
                surahNumber: surah.number,
                surahName: surah.englishName,
                verseNumber: verse.number,
                reciter: configuration.selectedReciter,
                currentTime: 0,
                duration: duration,
                isPlaying: false
            )
            
            setupNowPlayingInfo(for: verse, in: surah)
            startTimeObserver()
            
            
            if audioPlayer?.play() == true {
                playerState = .playing
                isBuffering = false
                updateCurrentPlayback()
            } else {
                playerState = .error
                errorMessage = "Failed to start audio playback"
            }
            
        } catch {
            print("❌ AudioManager: Failed to load audio: \(error)")
            playerState = .error
            errorMessage = "Failed to load audio"
            isBuffering = false
        }
    }
    
    private func loadAudioData(from url: URL) async throws -> Data {
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedData = audioCache[cacheKey] {
            print("🗄️ AudioManager: Using cached audio data for \(url.absoluteString)")
            return cachedData
        }
        
        // Download from network
        print("🌐 AudioManager: Downloading audio from \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 AudioManager: HTTP Response \(httpResponse.statusCode), Content-Length: \(data.count) bytes")
        }
        
        // Cache the data if there's room
        if currentCacheSize + data.count <= maxCacheSize {
            audioCache[cacheKey] = data
            currentCacheSize += data.count
        }
        
        return data
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        playerState = .paused
        updateCurrentPlayback()
        updateNowPlayingPlaybackState()
    }
    
    func resume() {
        guard audioPlayer?.play() == true else {
            playerState = .error
            errorMessage = "Failed to resume playback"
            return
        }
        
        playerState = .playing
        updateCurrentPlayback()
        updateNowPlayingPlaybackState()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        playerState = .stopped
        currentPlayback = nil
        currentTime = 0
        duration = 0
        stopTimeObserver()
        clearNowPlayingInfo()
        stopSleepTimer()
        
        // Reset highlighting state
        currentlyHighlightedWord = nil
        currentVerseTimingData = nil
        quranAlignData = nil
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        updateCurrentPlayback()
    }
    
    func seekToWord(_ wordIndex: Int) {
        guard let timingData = currentVerseTimingData,
              wordIndex < timingData.segments.count else {
            print("⚠️ Cannot seek to word \(wordIndex): no timing data or invalid index")
            return
        }
        
        let wordTiming = timingData.segments[wordIndex]
        let seekTime = wordTiming.startTime
        audioPlayer?.currentTime = seekTime
        currentTime = seekTime
        currentlyHighlightedWord = wordIndex
        updateCurrentPlayback()
        
        print("⏭️ Seeked to word \(wordIndex) at time \(String(format: "%.1f", seekTime))s")
    }
    
    func skipToPrevious() {
        guard currentVerseIndex > 0 else { return }
        currentVerseIndex -= 1
        Task {
            await playCurrentVerse()
        }
    }
    
    func skipToNext() {
        guard currentVerseIndex < currentVerses.count - 1 else {
            // End of surah
            if configuration.repeatMode == .continuous {
                // Find next surah and continue
                // Implementation depends on having access to all surahs
            } else if configuration.repeatMode == .surah {
                currentVerseIndex = 0
                Task {
                    await playCurrentVerse()
                }
            } else {
                stop()
            }
            return
        }
        
        currentVerseIndex += 1
        Task {
            await playCurrentVerse()
        }
    }
    
    private func playCurrentVerse() async {
        guard let surah = currentSurah,
              currentVerseIndex < currentVerses.count else { return }
        
        let verse = currentVerses[currentVerseIndex]
        
        // Load timing data for this specific verse
        currentVerseTimingData = quranAlignData?.getVerseTimingData(surahNumber: surah.number, ayahNumber: verse.number)
        
        if let timingData = currentVerseTimingData {
            print("✅ Using quran-align timing data for word highlighting")
            await playVerseWithTiming(verse: verse, surah: surah, timingData: timingData)
        } else {
            print("⚠️ No quran-align timing data - playing without word highlighting")
            await playVerseWithoutTiming(verse: verse, surah: surah)
        }
    }
    
    private func loadQuranAlignData() async {
        guard quranAlignData == nil else { return } // Already loaded
        
        print("📖 Loading quran-align timing data...")
        quranAlignData = await DataManager.shared.getQuranAlignData()
    }
    
    // MARK: - Configuration Updates
    
    func updatePlaybackSpeed(_ speed: Double) {
        configuration = AudioConfiguration(
            selectedReciter: configuration.selectedReciter,
            playbackSpeed: speed,
            repeatMode: configuration.repeatMode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            sleepTimer: configuration.sleepTimer
        )
        saveConfiguration()
        
        // audioPlayer?.rate = Float(speed) // Disabled for accurate verse timing
    }
    
    func updateRepeatMode(_ mode: RepeatMode) {
        configuration = AudioConfiguration(
            selectedReciter: configuration.selectedReciter,
            playbackSpeed: configuration.playbackSpeed,
            repeatMode: mode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            sleepTimer: configuration.sleepTimer
        )
        saveConfiguration()
    }
    
    func updateReciter(_ reciter: Reciter) {
        // All reciters are now free - no premium validation needed
        configuration = AudioConfiguration(
            selectedReciter: reciter,
            playbackSpeed: configuration.playbackSpeed,
            repeatMode: configuration.repeatMode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            sleepTimer: configuration.sleepTimer
        )
        saveConfiguration()
        
        print("✅ AudioManager: Updated reciter to \(reciter.nameEnglish)")
        
        // Stop current playback to avoid confusion
        stop()
    }
    
    // MARK: - Sleep Timer
    func setSleepTimer(_ duration: SleepTimerDuration?) {
        configuration = AudioConfiguration(
            selectedReciter: configuration.selectedReciter,
            playbackSpeed: configuration.playbackSpeed,
            repeatMode: configuration.repeatMode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            sleepTimer: duration
        )
        saveConfiguration()
        
        stopSleepTimer()
        
        if let duration = duration,
           let timeInterval = duration.timeInterval {
            startSleepTimer(timeInterval)
        }
    }
    
    private func startSleepTimer(_ timeInterval: TimeInterval) {
        sleepTimerTimeRemaining = timeInterval
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self,
                      let remaining = self.sleepTimerTimeRemaining else { return }
                
                if remaining <= 1 {
                    self.stop()
                    self.stopSleepTimer()
                } else {
                    self.sleepTimerTimeRemaining = remaining - 1
                }
            }
        }
    }
    
    private func stopSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerTimeRemaining = nil
    }
    
    // MARK: - Time Observer
    private func startTimeObserver() {
        timeObserver = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTime()
            }
        }
    }
    
    private func stopTimeObserver() {
        timeObserver?.invalidate()
        timeObserver = nil
    }
    
    private func updateTime() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
        updateCurrentPlayback()
        
        // Update word highlighting if playing verse with timing data
        if let timingData = currentVerseTimingData {
            updateWordHighlighting(timingData: timingData)
        }
    }
    
    private func updateWordHighlighting(timingData: VerseTimingData) {
        let currentTimeMs = Int(currentTime * 1000)
        
        // Find which word is currently being recited
        var highlightedWord: Int?
        
        for (index, wordTiming) in timingData.segments.enumerated() {
            if currentTimeMs >= wordTiming.startTimeMs && currentTimeMs <= wordTiming.endTimeMs {
                highlightedWord = index
                break
            }
        }
        
        if highlightedWord != currentlyHighlightedWord {
            currentlyHighlightedWord = highlightedWord
            
            if let wordIndex = highlightedWord {
                let wordTiming = timingData.segments[wordIndex]
                print("🎯 Now highlighting word \(wordIndex) (indices \(wordTiming.wordStartIndex)-\(wordTiming.wordEndIndex)) at time \(String(format: "%.1f", currentTime))s")
            }
        }
    }
    
    
    private func updateCurrentPlayback() {
        guard let surah = currentSurah,
              currentVerseIndex < currentVerses.count else { return }
        
        let verse = currentVerses[currentVerseIndex]
        currentPlayback = CurrentPlayback(
            surahNumber: surah.number,
            surahName: surah.englishName,
            verseNumber: verse.number,
            reciter: configuration.selectedReciter,
            currentTime: currentTime,
            duration: duration,
            isPlaying: playerState == .playing
        )
    }
    
    // MARK: - Now Playing Info
    private func setupNowPlayingInfo(for verse: VerseWithTafsir, in surah: Surah) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = surah.englishName
        nowPlayingInfo[MPMediaItemPropertyArtist] = configuration.selectedReciter.nameEnglish
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = surah.englishNameTranslation
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playerState == .playing ? configuration.playbackSpeed : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingPlaybackState() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playerState == .playing ? configuration.playbackSpeed : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // MARK: - Cache Management
    func clearAudioCache() {
        audioCache.removeAll()
        currentCacheSize = 0
    }
    
    func getCacheSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(currentCacheSize))
    }
    
    
    
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if flag {
                handleAudioFinished()
            } else {
                playerState = .error
                errorMessage = "Audio playback failed"
            }
        }
    }
    
    private func handleAudioFinished() {
        switch configuration.repeatMode {
        case .verse:
            // Replay the same verse
            Task {
                await playCurrentVerse()
            }
        case .off:
            // Check if there are more verses in the surah
            if currentVerseIndex < currentVerses.count - 1 {
                currentVerseIndex += 1
                Task {
                    await playCurrentVerse()
                }
            } else {
                stop()
            }
        case .surah:
            // Go to next verse or restart surah
            if currentVerseIndex < currentVerses.count - 1 {
                currentVerseIndex += 1
                Task {
                    await playCurrentVerse()
                }
            } else {
                currentVerseIndex = 0
                Task {
                    await playCurrentVerse()
                }
            }
        case .continuous:
            // This would require access to next surah
            if currentVerseIndex < currentVerses.count - 1 {
                currentVerseIndex += 1
                Task {
                    await playCurrentVerse()
                }
            } else {
                stop()
            }
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            playerState = .error
            errorMessage = error?.localizedDescription ?? "Audio decode error"
        }
    }
}

// MARK: - Audio Session Notifications
extension AudioManager {
    @objc private func audioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            if playerState == .playing {
                pause()
            }
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resume()
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc private func audioSessionRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            if playerState == .playing {
                pause()
            }
        default:
            break
        }
    }
    
}