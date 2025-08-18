//
//  AccountDeletionView.swift
//  Thaqalayn
//
//  Account deletion confirmation flow with warnings
//

import SwiftUI

struct AccountDeletionView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var confirmationText = ""
    @State private var isDeleting = false
    @State private var showingFinalConfirmation = false
    @State private var deletionError: String?
    
    private let confirmationString = "DELETE MY ACCOUNT"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Warning icon and header
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.3), radius: 20)
                            
                            Text("Delete Account")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.red)
                            
                            Text("This action cannot be undone")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }
                        
                        // Warning details
                        VStack(spacing: 20) {
                            WarningCard(
                                icon: "person.fill.xmark",
                                title: "Account Permanently Deleted",
                                description: "Your account and all associated data will be permanently removed from our servers."
                            )
                            
                            WarningCard(
                                icon: "heart.slash.fill",
                                title: "All Bookmarks Lost",
                                description: "Your saved verses, notes, and tags will be permanently deleted and cannot be recovered."
                            )
                            
                            WarningCard(
                                icon: "icloud.slash.fill",
                                title: "Cloud Sync Disabled",
                                description: "You will lose access to cross-device synchronization of your reading progress."
                            )
                            
                            WarningCard(
                                icon: "arrow.counterclockwise.circle.fill",
                                title: "No Recovery Possible",
                                description: "Once deleted, this data cannot be restored. You would need to create a new account."
                            )
                        }
                        
                        // Confirmation section
                        VStack(spacing: 16) {
                            Text("To confirm deletion, type:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                            
                            Text(confirmationString)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
                            TextField("Enter confirmation text", text: $confirmationText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeManager.strokeColor, lineWidth: 1)
                                        )
                                )
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                        }
                        
                        // Error message
                        if let error = deletionError {
                            Text(error)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showingFinalConfirmation = true
                            }) {
                                HStack {
                                    if isDeleting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    
                                    Text(isDeleting ? "Deleting Account..." : "Delete My Account")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(confirmationText == confirmationString ? .red : .gray)
                                )
                            }
                            .disabled(confirmationText != confirmationString || isDeleting)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.glassEffect)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                            }
                            .disabled(isDeleting)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.primaryText)
                    .disabled(isDeleting)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .alert("Final Confirmation", isPresented: $showingFinalConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("DELETE ACCOUNT", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
    }
    
    private func deleteAccount() async {
        isDeleting = true
        deletionError = nil
        
        do {
            // Delete account through SupabaseService
            try await supabaseService.deleteAccount()
            
            // Clear local data
            bookmarkManager.clearAllLocalData()
            
            await MainActor.run {
                // Dismiss all views and return to welcome screen
                dismiss()
                
                // Post notification to show welcome/authentication screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .showAuthentication, object: nil)
                }
            }
        } catch {
            await MainActor.run {
                deletionError = error.localizedDescription
                isDeleting = false
            }
        }
    }
}

struct WarningCard: View {
    let icon: String
    let title: String
    let description: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.red)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AccountDeletionView()
}