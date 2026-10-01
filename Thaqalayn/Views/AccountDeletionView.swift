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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var confirmationText = ""
    @State private var isDeleting = false
    @State private var showingFinalConfirmation = false
    @State private var deletionError: String?
    
    private let confirmationString = "DELETE MY ACCOUNT"


    var body: some View {
        emeraldBody
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

    // MARK: - Emerald body

    private var emeraldBody: some View {
        NavigationView {
            ZStack {
                EmeraldBackground()

                ScrollView {
                    VStack(spacing: 28) {
                        // Warning header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.destructive.opacity(0.14))
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Circle()
                                            .stroke(themeManager.destructive.opacity(0.32), lineWidth: 1)
                                    )
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundColor(themeManager.destructive)
                            }
                            .shadow(color: themeManager.destructive.opacity(0.3), radius: 24)

                            VStack(spacing: 7) {
                                Text("PERMANENT ACTION")
                                    .font(.system(size: 11, weight: .bold)).tracking(3)
                                    .foregroundColor(themeManager.destructive)
                                Text("Delete Account")
                                    .font(EmType.serif(40, .semiBold))
                                    .foregroundColor(themeManager.primaryText)
                                Text("This action cannot be undone")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        // Warning details
                        VStack(spacing: 14) {
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

                        EmDivider(label: "CONFIRM")

                        // Confirmation section
                        EmCard {
                            VStack(spacing: 16) {
                                Text("To confirm deletion, type:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(confirmationString)
                                    .font(EmType.serif(20, .semiBold)).tracking(0.5)
                                    .foregroundColor(themeManager.destructive)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(themeManager.destructive.opacity(0.10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(themeManager.destructive.opacity(0.32), lineWidth: 1)
                                            )
                                    )

                                TextField("Enter confirmation text", text: $confirmationText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.primaryText)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(themeManager.glassSurfaceElevated)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                                    .autocapitalization(.allCharacters)
                                    .disableAutocorrection(true)
                            }
                            .padding(20)
                        }

                        // Error message
                        if let error = deletionError {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(themeManager.destructive)
                                Text(error)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.destructive)
                                Spacer(minLength: 0)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(themeManager.destructive.opacity(0.10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(themeManager.destructive.opacity(0.32), lineWidth: 1)
                                    )
                            )
                        }

                        // Action buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showingFinalConfirmation = true
                            }) {
                                HStack(spacing: 9) {
                                    if isDeleting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    Text(isDeleting ? "Deleting Account..." : "Delete My Account")
                                        .font(.system(size: 15.5, weight: .bold)).tracking(0.3)
                                }
                                // White on the red gradient. The disabled fill is
                                // glass, where white only reads on the dark ground.
                                .foregroundColor(
                                    confirmationText == confirmationString || colorScheme == .dark
                                        ? Color.white
                                        : themeManager.tertiaryText
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(
                                            confirmationText == confirmationString
                                                ? AnyShapeStyle(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.82, green: 0.36, blue: 0.33),
                                                            Color(red: 0.70, green: 0.27, blue: 0.25)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                : AnyShapeStyle(themeManager.glassSurfaceElevated)
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .stroke(
                                            confirmationText == confirmationString
                                                ? Color.clear
                                                : themeManager.strokeColor,
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: confirmationText == confirmationString
                                        ? themeManager.destructive.opacity(0.3)
                                        : .clear,
                                    radius: 24, x: 0, y: 10
                                )
                            }
                            .buttonStyle(EmPressStyle())
                            .disabled(confirmationText != confirmationString || isDeleting)

                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 15.5, weight: .bold)).tracking(0.3)
                                    .foregroundColor(themeManager.accentColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                                            .fill(themeManager.accentChip)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(EmPressStyle())
                            .disabled(isDeleting)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(EmType.serif(18, .semiBold))
                    .foregroundColor(themeManager.accentColor)
                    .disabled(isDeleting)
                }
            }
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
        EmCard(cornerRadius: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(themeManager.destructive.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(themeManager.destructive.opacity(0.32), lineWidth: 1)
                        )
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.destructive)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(EmType.serif(19, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
        }
    }
}

#Preview {
    AccountDeletionView()
}