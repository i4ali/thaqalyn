//
//  Config.swift
//  Thaqalayn
//
//  Supabase configuration and environment variables
//

import Foundation

struct Config {
    
    // MARK: - Supabase Configuration
    
    static let supabaseURL = "https://awiuswwmvlmmvkkfghvc.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3aXVzd3dtdmxtbXZra2ZnaHZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MTcyNDIsImV4cCI6MjA2OTk5MzI0Mn0.RUnjQVQJp1q4pOwAdM4RHn2ndBQiZHZ80JlhwlOCeP4"
    
    // MARK: - Project Information
    
    static let projectInfo = ProjectInfo(
        id: "awiuswwmvlmmvkkfghvc",
        name: "Thaqalayn",
        region: "us-east-1",
        organizationId: "zijygqgebsdmibiwdxis"
    )
}

struct ProjectInfo {
    let id: String
    let name: String
    let region: String
    let organizationId: String
}