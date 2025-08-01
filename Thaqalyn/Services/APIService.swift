//
//  APIService.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import Foundation

@MainActor
class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://thaqalyn-api.vercel.app/api/v1"
    private let session = URLSession.shared
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0
    
    private init() {}
    
    // MARK: - Public API Methods
    
    func generateTafsir(surah: Int, ayah: Int, layer: Int) async throws -> TafsirContent {
        let request = TafsirRequest(surah: surah, ayah: ayah, layer: layer)
        let response: TafsirResponse = try await performRequest(
            endpoint: "/tafsir/generate",
            method: .POST,
            body: request
        )
        
        return response.toTafsirContent(surah: surah, ayah: ayah, layer: layer)
    }
    
    func getSurahs() async throws -> [Surah] {
        let response: SurahsResponse = try await performRequest(
            endpoint: "/surahs",
            method: .GET,
            body: Optional<String>.none
        )
        return response.data
    }
    
    func getVerses(surahId: Int) async throws -> [Verse] {
        print("🌐 APIService: Fetching verses for surah \(surahId)")
        let response: VersesResponse = try await performRequest(
            endpoint: "/verses/\(surahId)",
            method: .GET,
            body: Optional<String>.none
        )
        print("📥 APIService: Received \(response.verses.count) verses for surah \(surahId)")
        return response.verses
    }
    
    // MARK: - Private HTTP Methods
    
    private func performRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil
    ) async throws -> R {
        var attempt = 0
        var lastError: Error?
        
        while attempt < maxRetries {
            do {
                return try await executeRequest(endpoint: endpoint, method: method, body: body)
            } catch {
                lastError = error
                attempt += 1
                
                if attempt < maxRetries {
                    // Exponential backoff
                    let delay = retryDelay * pow(2.0, Double(attempt - 1))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? APIError.unknown
    }
    
    private func executeRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Thaqalyn-iOS/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        // Perform request
        let (data, response) = try await session.data(for: request)
        
        // Handle HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // Decode response
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: LocalizedError {
    case invalidURL
    case encodingError(Error)
    case decodingError(Error)
    case invalidResponse
    case badRequest
    case unauthorized
    case rateLimited
    case serverError
    case httpError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response"
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "Unauthorized"
        case .rateLimited:
            return "Rate limited. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .unknown:
            return "Unknown error"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .rateLimited, .serverError:
            return true
        case .httpError(let code):
            return code >= 500
        default:
            return false
        }
    }
}

// Enhanced request/response models
struct TafsirRequest: Codable {
    let surah: Int
    let ayah: Int
    let layer: Int
    let language: String
    let sources: [String]?
    
    init(surah: Int, ayah: Int, layer: Int, language: String = "en", sources: [String]? = nil) {
        self.surah = surah
        self.ayah = ayah
        self.layer = layer
        self.language = language
        self.sources = sources
    }
}

struct TafsirResponse: Codable {
    let content: String
    let sources: [String]
    let generatedAt: String
    let confidenceScore: Double
    let metadata: ResponseMetadata?
    
    struct ResponseMetadata: Codable {
        let modelUsed: String?
        let tokenCount: Int?
        let processingTime: Double?
    }
    
    func toTafsirContent(surah: Int, ayah: Int, layer: Int) -> TafsirContent {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: generatedAt) ?? Date()
        
        return TafsirContent(
            surah: surah,
            ayah: ayah,
            layer: layer,
            content: content,
            sources: sources,
            generatedAt: date,
            confidenceScore: confidenceScore
        )
    }
}

// Response wrapper for surahs endpoint
struct SurahsResponse: Codable {
    let success: Bool
    let data: [Surah]
    let count: Int
    let generatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case success, data, count
        case generatedAt = "generated_at"
    }
}

// Response wrapper for verses endpoint
struct VersesResponse: Codable {
    let success: Bool
    let surahId: Int
    let verses: [Verse]
    let count: Int
    let generatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case success, verses, count
        case surahId = "surahId"
        case generatedAt = "generated_at"
    }
}