//
//  Config.swift
//  Thaqalayn
//
//  Supabase configuration and environment variables
//

import Foundation

struct Config {
    
    // MARK: - Supabase Configuration
    // TODO: Add your Supabase credentials before building
    
    static let supabaseURL = "YOUR_SUPABASE_URL_HERE"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY_HERE"
    
    // MARK: - Project Information
    // TODO: Add your project information before building
    
    static let projectInfo = ProjectInfo(
        id: "YOUR_PROJECT_ID_HERE",
        name: "Thaqalayn",
        region: "us-east-1",
        organizationId: "YOUR_ORGANIZATION_ID_HERE"
    )
}

struct ProjectInfo {
    let id: String
    let name: String
    let region: String
    let organizationId: String
}