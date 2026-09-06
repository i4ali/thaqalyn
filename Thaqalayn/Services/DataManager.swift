//
//  DataManager.swift
//  Thaqalayn
//
//  Manages loading and caching of Quran and Tafsir data
//

import Foundation

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var quranData: QuranData?
    /// Passage (ruku) boundaries for all 114 surahs, built once from quranData. nil until load completes.
    @Published var passageIndex: PassageIndex?
    @Published var availableSurahs: [SurahWithTafsir] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    /// Flat search index, built once after availableSurahs is populated. nil until load completes.
    @Published var searchIndex: QuranSearchIndex?

    private var tafsirCache: [Int: TafsirData] = [:]
    private var quranAlignCache: QuranAlignTimingData? // Global quran-align data
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    /// Minimum time the branded loading splash stays on screen, so it doesn't
    /// just flash by on fast local loads.
    private static let minimumSplashDuration: TimeInterval = 2.5

    func loadData() {
        isLoading = true
        errorMessage = nil
        let startTime = Date()

        Task {
            do {
                try await loadQuranData()
                await loadAvailableTafsir()
                await Self.holdSplash(since: startTime)
                isLoading = false
            } catch {
                errorMessage = "Failed to load data: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    /// Sleeps for whatever remains of `minimumSplashDuration` after loading finishes.
    private static func holdSplash(since start: Date) async {
        let remaining = minimumSplashDuration - Date().timeIntervalSince(start)
        if remaining > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }
    }
    
    private func loadQuranData() async throws {
        print("🔍 Looking for quran_data.json in bundle...")
        
        guard let url = Bundle.main.url(forResource: "quran_data", withExtension: "json") else {
            print("❌ quran_data.json not found in bundle")
            throw DataError.fileNotFound("quran_data.json not found in bundle")
        }
        
        print("✅ Found quran_data.json at: \(url.path)")
        
        guard let data = try? Data(contentsOf: url) else {
            print("❌ Failed to read data from quran_data.json")
            throw DataError.fileNotFound("Failed to read quran_data.json")
        }
        
        print("✅ Successfully read \(data.count) bytes from quran_data.json")
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(QuranData.self, from: data)
            self.quranData = decoded
            self.passageIndex = PassageIndex(quran: decoded)
            print("✅ Successfully decoded QuranData with \(self.quranData?.surahs.count ?? 0) surahs")
        } catch {
            print("❌ JSON decode error: \(error)")
            throw DataError.decodingError(error.localizedDescription)
        }
    }
    
    private func loadAvailableTafsir() async {
        guard let quranData = quranData else { return }
        
        var surahs: [SurahWithTafsir] = []
        
        // Load all 114 surahs (tafsir optional)
        for surah in quranData.surahs {
            if let surahWithTafsir = await loadSurahWithTafsir(surah: surah) {
                surahs.append(surahWithTafsir)
            }
        }
        
        self.availableSurahs = surahs.sorted { $0.surah.number < $1.surah.number }
        print("✅ Loaded \(surahs.count) surahs (with/without tafsir)")
        self.searchIndex = QuranSearchIndex(surahs: self.availableSurahs)
        print("✅ Built search index: \(self.searchIndex?.verseEntries.count ?? 0) verses, \(self.searchIndex?.themeEntries.count ?? 0) themes")
    }
    
    private func loadSurahWithTafsir(surah: Surah) async -> SurahWithTafsir? {
        // Always load tafsir data if available (access control at UI level)
        // This avoids timing issues with premium status loading
        let tafsirData = await loadTafsirData(for: surah.number)

        guard let quranData = quranData,
              let surahVerses = quranData.verses[String(surah.number)] else {
            return nil
        }

        // Create verses with tafsir (if available in bundle)
        var verses: [VerseWithTafsir] = []

        for i in 1...surah.versesCount {
            let verseKey = String(i)
            if let verse = surahVerses[verseKey] {
                let tafsir = tafsirData?.verses[verseKey]
                let verseWithTafsir = VerseWithTafsir(
                    number: i,
                    verse: verse,
                    tafsir: tafsir
                )
                verses.append(verseWithTafsir)
            }
        }

        return SurahWithTafsir(surah: surah, verses: verses)
    }
    
    private func loadTafsirData(for surahNumber: Int) async -> TafsirData? {
        // Check cache first
        if let cached = tafsirCache[surahNumber] {
            return cached
        }
        
        // Load from bundle
        guard let url = Bundle.main.url(forResource: "tafsir_\(surahNumber)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let tafsirData = TafsirData(verses: try decoder.decode([String: TafsirVerse].self, from: data))
            
            // Cache the result
            tafsirCache[surahNumber] = tafsirData
            
            return tafsirData
        } catch {
            print("Error loading tafsir for surah \(surahNumber): \(error)")
            return nil
        }
    }
    
    // MARK: - Public Interface
    
    func getSurah(number: Int) -> SurahWithTafsir? {
        return availableSurahs.first { $0.surah.number == number }
    }
    
    func getVerse(surah: Int, verse: Int) -> VerseWithTafsir? {
        return getSurah(number: surah)?.verses.first { $0.number == verse }
    }
    
    // MARK: - Quran-Align Timing Data
    
    func getQuranAlignData() async -> QuranAlignTimingData? {
        // Check cache first
        if let cached = quranAlignCache {
            return cached
        }
        
        // TODO: Load from bundled quran-align data file
        // For now, return empty data to avoid build errors
        print("📋 TODO: Load quran-align timing data from bundle")
        print("🎯 Implementation needed: Bundle Alafasy_128kbps.json with app")
        
        let emptyData = QuranAlignTimingData(verses: [], reciterID: "mishary_rashid_alafasy")
        quranAlignCache = emptyData
        return emptyData
    }
    
    func getVerseTimingData(surahNumber: Int, ayahNumber: Int) async -> VerseTimingData? {
        guard let quranAlignData = await getQuranAlignData() else { return nil }
        return quranAlignData.getVerseTimingData(surahNumber: surahNumber, ayahNumber: ayahNumber)
    }
}

// MARK: - Errors

enum DataError: LocalizedError {
    case fileNotFound(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let file):
            return "File not found: \(file)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        }
    }
}