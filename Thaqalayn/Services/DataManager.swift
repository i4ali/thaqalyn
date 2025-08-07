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
    @Published var availableSurahs: [SurahWithTafsir] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var tafsirCache: [Int: TafsirData] = [:]
    private var quranAlignCache: QuranAlignTimingData? // Global quran-align data
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await loadQuranData()
                await loadAvailableTafsir()
                isLoading = false
            } catch {
                errorMessage = "Failed to load data: \(error.localizedDescription)"
                isLoading = false
            }
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
            self.quranData = try decoder.decode(QuranData.self, from: data)
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
    }
    
    private func loadSurahWithTafsir(surah: Surah) async -> SurahWithTafsir? {
        // Load tafsir data for this surah
        let tafsirData = await loadTafsirData(for: surah.number)
        
        guard let quranData = quranData,
              let surahVerses = quranData.verses[String(surah.number)] else {
            return nil
        }
        
        // Create verses with tafsir
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
    
    func getTafsirText(for verse: VerseWithTafsir, layer: TafsirLayer) -> String? {
        print("🔍 Getting tafsir text for verse \(verse.number), layer \(layer.rawValue)")
        
        guard let tafsir = verse.tafsir else { 
            print("❌ No tafsir data found for verse \(verse.number)")
            return nil 
        }
        
        let rawText: String?
        switch layer {
        case .foundation:
            rawText = tafsir.layer1
        case .classical:
            rawText = tafsir.layer2
        case .contemporary:
            rawText = tafsir.layer3
        case .ahlulBayt:
            rawText = tafsir.layer4
        }
        
        guard let rawText = rawText else {
            print("❌ No text found for verse \(verse.number), layer \(layer.rawValue)")
            return nil
        }
        
        // Clean and format the text for mobile display
        let cleanedText = cleanTafsirText(rawText, layer: layer)
        
        print("✅ Found and cleaned tafsir text (\(cleanedText.count) characters) for verse \(verse.number), layer \(layer.rawValue)")
        return cleanedText
    }
    
    private func cleanTafsirText(_ text: String, layer: TafsirLayer) -> String {
        print("🧹 BEFORE cleaning (first 200 chars): \(String(text.prefix(200)))")
        var cleanedText = text
        
        // Remove redundant introductory sentences that repeat UI info
        let redundantPatterns = [
            "Here is a Layer \\d+ .*? Commentary.*?:",
            "Here is the foundational commentary.*?:",
            "Here is a contemporary commentary.*?:",
            "Here is a Layer \\d+ Classical Shia Commentary.*?:",
            "\\*\\*Layer \\d+ .*? Commentary.*?\\*\\*",
            "### Layer \\d+ Foundation Commentary.*?\\n",
            "📚 \\*\\*Classical Shia Commentary.*?\\*\\*",
            "🌍 \\*\\*Contemporary Insights.*?\\*\\*",
            "## Layer \\d+ Ahlul Bayt Wisdom.*?\\n",
            // Remove verse reference lines that duplicate UI info - more specific patterns
            "\\*\\*Surah [A-Za-z-]+, Verse \\d+:.*?\\*\\*",
            "Surah [A-Za-z-]+, Verse \\d+:.*?:",
            "^Surah [A-Za-z-]+, Verse \\d+.*?\\n",
            // Remove Arabic text repetitions - exact patterns from data
            "\\*\\*.*?بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\\*\\*",
            "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ:?",
            ".*?بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ.*",
            // Remove Arabic-only lines
            "^[\\u0600-\\u06FF\\s]+:?\\s*$",
            "\\n[\\u0600-\\u06FF\\s]+:\\s*\\n"
        ]
        
        for pattern in redundantPatterns {
            cleanedText = cleanedText.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Clean up numbered section headers - exact patterns from data
        cleanedText = cleanedText.replacingOccurrences(
            of: "\\d+\\. \\*\\*([^:]+):\\*\\*",
            with: "$1",
            options: .regularExpression
        )
        
        // Clean up markdown bold patterns
        cleanedText = cleanedText.replacingOccurrences(
            of: "\\*\\*(\\d+)\\. ([^:]+):\\*\\*",
            with: "$2",
            options: .regularExpression
        )
        
        // Clean up plain numbered headers (without markdown)
        cleanedText = cleanedText.replacingOccurrences(
            of: "(\\d+)\\. ([^:]+):",
            with: "$2",
            options: .regularExpression
        )
        
        // Convert markdown bold to plain text with better formatting
        cleanedText = cleanedText.replacingOccurrences(
            of: "\\*\\*([^*]+)\\*\\*",
            with: "$1",
            options: .regularExpression
        )
        
        // Convert markdown italic to plain text
        cleanedText = cleanedText.replacingOccurrences(
            of: "\\*([^*]+)\\*",
            with: "$1",
            options: .regularExpression
        )
        
        // Clean up section headers and make them more readable
        let headerReplacements = [
            "SIMPLE EXPLANATION:": "Simple Explanation:",
            "HISTORICAL CONTEXT:": "Historical Context:",
            "KEY ARABIC TERMS:": "Key Terms:",
            "CONTEMPORARY RELEVANCE:": "Modern Relevance:",
            "RELEVANT HADITH:": "Relevant Teachings:",
            "THEOLOGICAL CONCEPTS:": "Theological Concepts:",
            "Simple Explanation:": "Simple Explanation",
            "Historical Context:": "Historical Context",
            "Key Terms:": "Key Terms",
            "Modern Relevance:": "Modern Relevance",
            "Relevant Teachings:": "Relevant Teachings",
            "Theological Concepts:": "Theological Concepts"
        ]
        
        for (old, new) in headerReplacements {
            cleanedText = cleanedText.replacingOccurrences(of: old, with: new)
        }
        
        // Remove excessive newlines and clean up spacing
        cleanedText = cleanedText.replacingOccurrences(
            of: "\\n\\s*\\n\\s*\\n+",
            with: "\n\n",
            options: .regularExpression
        )
        
        // Remove any leading/trailing colons or periods that might be artifacts
        cleanedText = cleanedText.replacingOccurrences(
            of: "^[:.]\\s*",
            with: "",
            options: .regularExpression
        )
        
        // Remove leading/trailing whitespace and newlines
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🧹 AFTER cleaning (first 200 chars): \(String(cleanedText.prefix(200)))")
        return cleanedText
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