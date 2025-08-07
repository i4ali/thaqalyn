//
//  AudioModels.swift
//  Thaqalayn
//
//  Audio system data models for Quran recitation
//

import Foundation

// MARK: - Reciter Models

struct Reciter: Codable, Identifiable, Hashable {
    let id: String
    let nameArabic: String
    let nameEnglish: String
    let style: ReciterStyle
    let language: String
    let bitrate: Int
    let format: AudioFormat
    let serverURL: String
    let profileImageURL: String?
    let description: String
    let isPopular: Bool
    let isPremium: Bool
    
    init(
        id: String,
        nameArabic: String,
        nameEnglish: String,
        style: ReciterStyle,
        language: String = "ar",
        bitrate: Int = 128,
        format: AudioFormat = .mp3,
        serverURL: String,
        profileImageURL: String? = nil,
        description: String = "",
        isPopular: Bool = false,
        isPremium: Bool = false
    ) {
        self.id = id
        self.nameArabic = nameArabic
        self.nameEnglish = nameEnglish
        self.style = style
        self.language = language
        self.bitrate = bitrate
        self.format = format
        self.serverURL = serverURL
        self.profileImageURL = profileImageURL
        self.description = description
        self.isPopular = isPopular
        self.isPremium = isPremium
    }
}

enum ReciterStyle: String, Codable, CaseIterable {
    case hafs = "hafs"
    case warsh = "warsh"
    case qaloon = "qaloon"
    case douri = "douri"
    
    var title: String {
        switch self {
        case .hafs: return "Hafs"
        case .warsh: return "Warsh"
        case .qaloon: return "Qaloon"
        case .douri: return "Douri"
        }
    }
}

enum AudioFormat: String, Codable {
    case mp3 = "mp3"
    case m4a = "m4a"
    case wav = "wav"
}

// MARK: - Audio Configuration

struct AudioConfiguration: Codable {
    let selectedReciter: Reciter
    let playbackSpeed: Double
    let repeatMode: RepeatMode
    let autoAdvanceDelay: Double
    let backgroundPlayback: Bool
    let sleepTimer: SleepTimerDuration?
    
    init(
        selectedReciter: Reciter = AudioConfiguration.defaultReciter,
        playbackSpeed: Double = 1.0,
        repeatMode: RepeatMode = .off,
        autoAdvanceDelay: Double = 1.0,
        backgroundPlayback: Bool = true,
        sleepTimer: SleepTimerDuration? = nil
    ) {
        self.selectedReciter = selectedReciter
        self.playbackSpeed = playbackSpeed
        self.repeatMode = repeatMode
        self.autoAdvanceDelay = autoAdvanceDelay
        self.backgroundPlayback = backgroundPlayback
        self.sleepTimer = sleepTimer
    }
    
    static let defaultReciter = Reciter(
        id: "mishary_rashid_alafasy",
        nameArabic: "مشاري بن راشد العفاسي",
        nameEnglish: "Mishary Rashid Alafasy",
        style: .hafs,
        serverURL: "https://server8.mp3quran.net/afs",
        description: "One of the most popular reciters worldwide",
        isPopular: true,
        isPremium: false
    )
}

enum RepeatMode: String, Codable, CaseIterable {
    case off = "off"
    case verse = "verse"
    case surah = "surah"
    case continuous = "continuous"
    
    var title: String {
        switch self {
        case .off: return "No Repeat"
        case .verse: return "Repeat Verse"
        case .surah: return "Repeat Surah"
        case .continuous: return "Continuous"
        }
    }
    
    var icon: String {
        switch self {
        case .off: return "arrow.forward"
        case .verse: return "repeat.1"
        case .surah: return "repeat"
        case .continuous: return "infinity"
        }
    }
}


enum SleepTimerDuration: String, Codable, CaseIterable {
    case minutes5 = "5"
    case minutes10 = "10"
    case minutes15 = "15"
    case minutes30 = "30"
    case minutes60 = "60"
    case endOfSurah = "end_of_surah"
    
    var title: String {
        switch self {
        case .minutes5: return "5 minutes"
        case .minutes10: return "10 minutes"
        case .minutes15: return "15 minutes"
        case .minutes30: return "30 minutes"
        case .minutes60: return "1 hour"
        case .endOfSurah: return "End of Surah"
        }
    }
    
    var timeInterval: TimeInterval? {
        switch self {
        case .minutes5: return 5 * 60
        case .minutes10: return 10 * 60
        case .minutes15: return 15 * 60
        case .minutes30: return 30 * 60
        case .minutes60: return 60 * 60
        case .endOfSurah: return nil
        }
    }
}

// MARK: - Playback State

enum AudioPlayerState: String, Codable {
    case stopped = "stopped"
    case loading = "loading"
    case playing = "playing"
    case paused = "paused"
    case buffering = "buffering"
    case error = "error"
}

struct CurrentPlayback: Codable {
    let surahNumber: Int
    let surahName: String
    let verseNumber: Int
    let reciter: Reciter
    let currentTime: TimeInterval
    let duration: TimeInterval
    let isPlaying: Bool
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
}


// MARK: - Popular Reciters Database

extension Reciter {
    static let popularReciters: [Reciter] = [
        // Free reciter (default)
        Reciter(
            id: "mishary_rashid_alafasy",
            nameArabic: "مشاري بن راشد العفاسي",
            nameEnglish: "Mishary Rashid Alafasy",
            style: .hafs,
            serverURL: "https://server8.mp3quran.net/afs",
            description: "One of the most popular reciters worldwide with a beautiful voice",
            isPopular: true,
            isPremium: false
        ),
        // Premium reciters
        Reciter(
            id: "abdul_rahman_al_sudais",
            nameArabic: "عبد الرحمن السديس",
            nameEnglish: "Abdul Rahman Al-Sudais",
            style: .hafs,
            serverURL: "https://server11.mp3quran.net/sds",
            description: "Imam of the Grand Mosque in Mecca",
            isPopular: true,
            isPremium: true
        ),
        Reciter(
            id: "saad_al_ghamidi",
            nameArabic: "سعد الغامدي",
            nameEnglish: "Saad Al-Ghamidi",
            style: .hafs,
            serverURL: "https://server7.mp3quran.net/s_gmd2",
            description: "Known for his emotional and beautiful recitation",
            isPopular: true,
            isPremium: true
        ),
        Reciter(
            id: "ahmad_ibn_ali_al_ajamy",
            nameArabic: "أحمد بن علي العجمي",
            nameEnglish: "Ahmad Ibn Ali Al-Ajamy",
            style: .hafs,
            serverURL: "https://server10.mp3quran.net/ajm",
            description: "Young reciter with a distinctive melodious voice",
            isPopular: true,
            isPremium: true
        ),
        Reciter(
            id: "maher_al_muaiqly",
            nameArabic: "ماهر المعيقلي",
            nameEnglish: "Maher Al-Muaiqly",
            style: .hafs,
            serverURL: "https://server12.mp3quran.net/maher",
            description: "Imam of the Prophet's Mosque in Medina",
            isPopular: true,
            isPremium: true
        ),
        Reciter(
            id: "yasser_al_dosari",
            nameArabic: "ياسر الدوسري",
            nameEnglish: "Yasser Al-Dosari",
            style: .hafs,
            serverURL: "https://server14.mp3quran.net/yasir",
            description: "Known for his powerful and emotional recitation",
            isPopular: true,
            isPremium: true
        )
    ]
}

// MARK: - Verse-by-Verse Audio Models (quran-align data)

/// Word-level timing data from quran-align project
struct WordTiming: Codable {
    let wordStartIndex: Int
    let wordEndIndex: Int
    let startTimeMs: Int
    let endTimeMs: Int
    
    var startTime: TimeInterval {
        return TimeInterval(startTimeMs) / 1000.0
    }
    
    var endTime: TimeInterval {
        return TimeInterval(endTimeMs) / 1000.0
    }
    
    var duration: TimeInterval {
        return endTime - startTime
    }
    
    init(wordStartIndex: Int, wordEndIndex: Int, startTimeMs: Int, endTimeMs: Int) {
        self.wordStartIndex = wordStartIndex
        self.wordEndIndex = wordEndIndex
        self.startTimeMs = startTimeMs
        self.endTimeMs = endTimeMs
    }
}

/// Individual verse timing data from quran-align project
struct VerseTimingData: Codable {
    let ayahNumber: Int
    let surahNumber: Int
    let segments: [WordTiming]
    let stats: VerseTimingStats?
    
    /// Total verse duration from first to last word
    var duration: TimeInterval {
        guard let firstWord = segments.first,
              let lastWord = segments.last else { return 0 }
        return lastWord.endTime - firstWord.startTime
    }
    
    /// Start time of first word (always 0 for individual verses)
    var startTime: TimeInterval {
        return segments.first?.startTime ?? 0
    }
    
    /// End time of last word
    var endTime: TimeInterval {
        return segments.last?.endTime ?? 0
    }
    
    init(ayahNumber: Int, surahNumber: Int, segments: [WordTiming], stats: VerseTimingStats? = nil) {
        self.ayahNumber = ayahNumber
        self.surahNumber = surahNumber
        self.segments = segments
        self.stats = stats
    }
}

/// Statistics for timing accuracy (from quran-align project)
struct VerseTimingStats: Codable {
    let avgError: Double?
    let stdDevError: Double?
    let wordCount: Int?
    
    init(avgError: Double? = nil, stdDevError: Double? = nil, wordCount: Int? = nil) {
        self.avgError = avgError
        self.stdDevError = stdDevError
        self.wordCount = wordCount
    }
}

/// Collection of all verse timing data (replaces SurahTimingData)
struct QuranAlignTimingData: Codable {
    let verses: [VerseTimingData]
    let reciterID: String
    let sourceProject: String
    let license: String
    
    init(verses: [VerseTimingData], reciterID: String) {
        self.verses = verses
        self.reciterID = reciterID
        self.sourceProject = "quran-align"
        self.license = "CC BY 4.0"
    }
    
    /// Get timing data for specific verse
    func getVerseTimingData(surahNumber: Int, ayahNumber: Int) -> VerseTimingData? {
        return verses.first { $0.surahNumber == surahNumber && $0.ayahNumber == ayahNumber }
    }
    
    /// Get all verses for a specific surah
    func getVersesForSurah(_ surahNumber: Int) -> [VerseTimingData] {
        return verses.filter { $0.surahNumber == surahNumber }
    }
}

