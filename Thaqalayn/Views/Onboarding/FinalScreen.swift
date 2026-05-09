//
//  FinalScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 10: Account Setup
//

import SwiftUI

struct FinalScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    let onComplete: () -> Void
    @State private var showingAuthentication = false
    @State private var isVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Begin Your Journey")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : -20)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                        Text("Sync your reading progress and bookmarks across devices")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: isVisible)
                    }

                    // Account buttons
                    VStack(spacing: 16) {
                        // Continue as Guest (primary)
                        Button(action: onComplete) {
                            HStack {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Continue as Guest")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.purpleGradient)
                            )
                            .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 12)
                        }

                        // Sign Up
                        Button(action: {
                            showingAuthentication = true
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(themeManager.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeManager.strokeColor, lineWidth: 1.5)
                                    )
                            )
                        }

                        // Sign In
                        Button(action: {
                            showingAuthentication = true
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Sign In")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(themeManager.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeManager.strokeColor, lineWidth: 1.5)
                                    )
                            )
                        }

                        // Account benefits note
                        VStack(spacing: 8) {
                            Text("Account Benefits")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)

                            Text("Sync bookmarks across devices and save your reading progress")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                }

                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
        }
        .fullScreenCover(isPresented: $showingAuthentication) {
            AuthenticationView()
                .onDisappear {
                    if supabaseService.isAuthenticated {
                        onComplete()
                    }
                }
        }
    }
}

#Preview {
    FinalScreen(onComplete: {})
}
