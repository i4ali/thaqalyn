//
//  PremiumManager.swift
//  Thaqalayn
//
//  Simplified premium manager - all features now free
//

import Foundation
import Combine

@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    // MARK: - Published Properties - Always unlocked
    @Published var isPremiumUnlocked: Bool = true
    
    // MARK: - Initialization
    
    init() {
        // All features are now free - no initialization needed
    }
    
    // MARK: - Feature Access Control
    
    func canAccessPremiumReciter(_ reciter: Reciter) -> Bool {
        return true // All reciters are now free
    }
    
    func getPremiumReciters() -> [Reciter] {
        return [] // No premium reciters anymore - all are free
    }
    
    func getFreeReciters() -> [Reciter] {
        return Reciter.popularReciters // All reciters are free
    }
}