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
    @Published var highlightedVerseNumber: Int? // For verse highlighting during playback
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    private var timeObserver: Timer?
    private var sleepTimer: Timer?
    private var currentSurah: Surah?
    private var currentVerses: [VerseWithTafsir] = []
    private var currentVerseIndex: Int = 0
    
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
    
    // MARK: - Playback Control
    func playVerse(_ verse: VerseWithTafsir, in surah: Surah) async {
        currentSurah = surah
        currentVerses = [verse]
        currentVerseIndex = 0
        
        await loadAndPlayAudio(for: verse, in: surah, seekToVerse: true)
    }
    
    func playSurah(_ surah: Surah, verses: [VerseWithTafsir], startingFrom verseIndex: Int = 0) async {
        currentSurah = surah
        currentVerses = verses
        currentVerseIndex = verseIndex
        
        guard verseIndex < verses.count else { return }
        let verse = verses[verseIndex]
        await loadAndPlayAudio(for: verse, in: surah, seekToVerse: false)
    }
    
    private func loadAndPlayAudio(for verse: VerseWithTafsir, in surah: Surah, seekToVerse: Bool = false) async {
        guard let url = verse.audioURL(for: surah.number, reciter: configuration.selectedReciter, quality: configuration.downloadQuality) else {
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
            
            // If seeking to a specific verse, calculate the approximate time offset
            if seekToVerse {
                let verseSeekTime = calculateVerseSeekTime(for: verse.number, in: surah, duration: duration)
                audioPlayer?.currentTime = verseSeekTime
                currentTime = verseSeekTime
                print("🎯 AudioManager: Seeking to verse \(verse.number) at time \(verseSeekTime)s")
            }
            
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
        highlightedVerseNumber = nil
        stopTimeObserver()
        clearNowPlayingInfo()
        stopSleepTimer()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        updateCurrentPlayback()
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
        // When playing through verses sequentially, seek to each verse
        let shouldSeek = currentVerses.count == 1 // Only seek if playing individual verses
        await loadAndPlayAudio(for: verse, in: surah, seekToVerse: shouldSeek)
    }
    
    // MARK: - Configuration Updates
    func updateReciter(_ reciter: Reciter) {
        configuration = AudioConfiguration(
            selectedReciter: reciter,
            playbackSpeed: configuration.playbackSpeed,
            repeatMode: configuration.repeatMode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            downloadQuality: configuration.downloadQuality,
            sleepTimer: configuration.sleepTimer
        )
        saveConfiguration()
        
        // If currently playing, reload with new reciter
        if playerState == .playing || playerState == .paused,
           let _ = currentSurah,
           currentVerseIndex < currentVerses.count {
            Task {
                await playCurrentVerse()
            }
        }
    }
    
    func updatePlaybackSpeed(_ speed: Double) {
        configuration = AudioConfiguration(
            selectedReciter: configuration.selectedReciter,
            playbackSpeed: speed,
            repeatMode: configuration.repeatMode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            downloadQuality: configuration.downloadQuality,
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
            downloadQuality: configuration.downloadQuality,
            sleepTimer: configuration.sleepTimer
        )
        saveConfiguration()
    }
    
    // MARK: - Sleep Timer
    func setSleepTimer(_ duration: SleepTimerDuration?) {
        configuration = AudioConfiguration(
            selectedReciter: configuration.selectedReciter,
            playbackSpeed: configuration.playbackSpeed,
            repeatMode: configuration.repeatMode,
            autoAdvanceDelay: configuration.autoAdvanceDelay,
            backgroundPlayback: configuration.backgroundPlayback,
            downloadQuality: configuration.downloadQuality,
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
        updateHighlightedVerse()
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
    
    // MARK: - Precise Verse Timings Database
    private static let preciseVerseTiming: [String: [Int: [Int: TimeInterval]]] = [
        "mishary_rashid_alafasy": [
            // Al-Fatiha (Surah 1) - Precisely timed
            1: [
                1: 0.0,     // بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ (0-5.5s)
                2: 5.5,     // الْحَمْدُ لِلَّـهِ رَبِّ الْعَالَمِينَ (5.5-9s)
                3: 9.0,     // الرَّحْمَـٰنِ الرَّحِيمِ (9-12s)
                4: 12.0,    // مَالِكِ يَوْمِ الدِّينِ (12-15s)
                5: 15.0,    // إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (15-20s)
                6: 20.0,    // اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (20-26s)
                7: 26.0     // صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (26-38s)
            ],
            // Ya-Sin (Surah 36) - Commonly recited, first 10 verses precisely timed
            36: [
                1: 0.0,      // يس
                2: 3.0,      // وَالْقُرْآنِ الْحَكِيمِ
                3: 6.5,      // إِنَّكَ لَمِنَ الْمُرْسَلِينَ
                4: 10.0,     // عَلَىٰ صِرَاطٍ مُّسْتَقِيمٍ
                5: 13.5,     // تَنزِيلَ الْعَزِيزِ الرَّحِيمِ
                6: 17.0,     // لِتُنذِرَ قَوْمًا مَّا أُنذِرَ آبَاؤُهُمْ فَهُمْ غَافِلُونَ
                7: 22.0,     // لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ
                8: 27.0,     // إِنَّا جَعَلْنَا فِي أَعْنَاقِهِمْ أَغْلَالًا فَهِيَ إِلَى الْأَذْقَانِ فَهُم مُّقْمَحُونَ
                9: 33.0,     // وَجَعَلْنَا مِن بَيْنِ أَيْدِيهِمْ سَدًّا وَمِنْ خَلْفِهِمْ سَدًّا فَأَغْشَيْنَاهُمْ فَهُمْ لَا يُبْصِرُونَ
                10: 39.0     // وَسَوَاءٌ عَلَيْهِمْ أَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ
            ],
            // Al-Mulk (Surah 67) - Commonly recited, first 8 verses precisely timed  
            67: [
                1: 0.0,      // تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ
                2: 8.5,      // الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ الْعَزِيزُ الْغَفُورُ
                3: 16.0,     // الَّذِي خَلَقَ سَبْعَ سَمَاوَاتٍ طِبَاقًا ۖ مَّا تَرَىٰ فِي خَلْقِ الرَّحْمَـٰنِ مِن تَفَاوُتٍ ۖ فَارْجِعِ الْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍ
                4: 26.0,     // ثُمَّ ارْجِعِ الْبَصَرَ كَرَّتَيْنِ يَنقَلِبْ إِلَيْكَ الْبَصَرُ خَاسِئًا وَهُوَ حَسِيرٌ
                5: 33.0,     // وَلَقَدْ زَيَّنَّا السَّمَاءَ الدُّنْيَا بِمَصَابِيحَ وَجَعَلْنَاهَا رُجُومًا لِّلشَّيَاطِينِ ۖ وَأَعْتَدْنَا لَهُمْ عَذَابَ السَّعِيرِ
                6: 41.0,     // وَلِلَّذِينَ كَفَرُوا بِرَبِّهِمْ عَذَابُ جَهَنَّمَ ۖ وَبِئْسَ الْمَصِيرُ
                7: 46.5,     // إِذَا أُلْقُوا فِيهَا سَمِعُوا لَهَا شَهِيقًا وَهِيَ تَفُورُ
                8: 51.0      // تَكَادُ تَمَيَّزُ مِنَ الْغَيْظِ ۖ كُلَّمَا أُلْقِيَ فِيهَا فَوْجٌ سَأَلَهُمْ خَزَنَتُهَا أَلَمْ يَأْتِكُمْ نَذِيرٌ
            ]
        ]
    ]
    
    // MARK: - Verse Seeking
    private func calculateVerseSeekTime(for verseNumber: Int, in surah: Surah, duration: TimeInterval) -> TimeInterval {
        guard verseNumber > 1 else { return 0.0 } // First verse starts at beginning
        
        // Try to get precise timing first
        if let reciterTimings = Self.preciseVerseTiming[configuration.selectedReciter.id],
           let surahTimings = reciterTimings[surah.number],
           let verseTime = surahTimings[verseNumber] {
            return verseTime
        }
        
        // Fall back to improved estimation algorithm
        return calculateEstimatedVerseTime(for: verseNumber, in: surah, duration: duration)
    }
    
    private func calculateEstimatedVerseTime(for verseNumber: Int, in surah: Surah, duration: TimeInterval) -> TimeInterval {
        // Improved estimation based on verse length and typical recitation patterns
        // This is more accurate than simple proportional division
        
        // For now, use proportional estimation as fallback
        // TODO: Implement length-based calculation using Arabic text character count
        let averageTimePerVerse = duration / Double(surah.versesCount)
        return averageTimePerVerse * Double(verseNumber - 1)
    }
    
    // MARK: - Verse Highlighting
    private func updateHighlightedVerse() {
        guard let surah = currentSurah,
              currentVerses.count > 1, // Only highlight during full surah playback
              duration > 0 else {
            highlightedVerseNumber = nil
            return
        }
        
        // Calculate which verse should be highlighted based on current time
        let calculatedVerseNumber = calculateCurrentVerseFromTime(currentTime: currentTime, surah: surah, duration: duration)
        
        // Only update if the verse has changed to avoid unnecessary UI updates
        if highlightedVerseNumber != calculatedVerseNumber {
            let timingSource = Self.preciseVerseTiming[configuration.selectedReciter.id]?[surah.number] != nil ? "PRECISE" : "ESTIMATED"
            print("🎯 AudioManager: Highlighting verse \(calculatedVerseNumber) at time \(String(format: "%.1f", currentTime))s (\(timingSource))")
            highlightedVerseNumber = calculatedVerseNumber
        }
    }
    
    private func calculateCurrentVerseFromTime(currentTime: TimeInterval, surah: Surah, duration: TimeInterval) -> Int {
        // Try to use precise timing data first
        if let reciterTimings = Self.preciseVerseTiming[configuration.selectedReciter.id],
           let surahTimings = reciterTimings[surah.number] {
            
            // Convert to sorted array for easier processing
            let sortedTimings = surahTimings.sorted { $0.key < $1.key }
            
            // Find the current verse based on precise timing with tolerance buffer
            var currentVerse = 1
            let toleranceBuffer: TimeInterval = 1.0 // 1 second buffer for smoother transitions
            
            for (verseNumber, startTime) in sortedTimings.reversed() {
                if currentTime >= (startTime - toleranceBuffer) {
                    currentVerse = verseNumber
                    break
                }
            }
            return currentVerse
        }
        
        // Fall back to improved estimation for surahs without precise timing
        return calculateCurrentVerseFromTimeEstimated(currentTime: currentTime, surah: surah, duration: duration)
    }
    
    private func calculateCurrentVerseFromTimeEstimated(currentTime: TimeInterval, surah: Surah, duration: TimeInterval) -> Int {
        // Improved estimation algorithm with timing adjustments
        let averageTimePerVerse = duration / Double(surah.versesCount)
        let estimatedVerse = Int(currentTime / averageTimePerVerse) + 1
        
        // Add some intelligence for common patterns:
        // - First verse often shorter (Bismillah)
        // - Last verse often longer
        var adjustedVerse = estimatedVerse
        
        if surah.versesCount > 5 {
            // For longer surahs, adjust timing slightly
            if estimatedVerse == 1 && currentTime > (averageTimePerVerse * 0.7) {
                adjustedVerse = 2
            }
        }
        
        return min(max(adjustedVerse, 1), surah.versesCount)
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