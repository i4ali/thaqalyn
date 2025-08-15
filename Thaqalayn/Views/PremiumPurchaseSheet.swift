//
//  PremiumPurchaseSheet.swift
//  Thaqalayn
//
//  Premium reciters purchase interface with glassmorphism design
//

import SwiftUI

struct PremiumPurchaseSheet: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    headerSection
                    
                    // Features section
                    featuresSection
                    
                    // Premium reciters preview
                    recitersPreviewSection
                    
                    // Purchase section
                    purchaseSection
                    
                    // Restore purchases
                    restoreSection
                }
                .padding(20)
            }
            .background(themeManager.primaryBackground)
            .navigationTitle("Premium Reciters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(themeManager.primaryBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.primaryText)
                }
            }
        }
        .alert("Purchase Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .task {
            if purchaseManager.products.isEmpty {
                await purchaseManager.loadProducts()
            }
        }
        .onChange(of: purchaseManager.purchaseError) { error in
            if let error = error {
                errorMessage = error
                showingError = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 20)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Unlock Premium Reciters")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Enhance your Quran listening experience with beautiful recitations from renowned scholars")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.top, 8)
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("What You'll Get")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                PremiumFeatureRow(
                    icon: "person.3.fill",
                    title: "5 Premium Reciters",
                    description: "Al-Sudais, Al-Ghamidi, Al-Ajamy, Al-Muaiqly, Al-Dosari"
                )
                
                PremiumFeatureRow(
                    icon: "waveform.and.person.filled",
                    title: "High-Quality Audio",
                    description: "Crystal clear recitation with optimal bitrate"
                )
                
                PremiumFeatureRow(
                    icon: "arrow.down.circle.fill",
                    title: "Offline Access",
                    description: "Download and listen without internet connection"
                )
                
                PremiumFeatureRow(
                    icon: "infinity",
                    title: "Lifetime Access",
                    description: "One-time purchase, enjoy forever"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
    
    private var recitersPreviewSection: some View {
        VStack(spacing: 16) {
            Text("Premium Reciters")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                ForEach(premiumManager.getPremiumReciters().prefix(5), id: \.id) { reciter in
                    HStack(spacing: 12) {
                        // Crown icon
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(reciter.nameEnglish)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.primaryText)
                            
                            Text(reciter.description)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(themeManager.secondaryText)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.secondaryBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.strokeColor.opacity(0.3), lineWidth: 0.5)
                            )
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
    
    private var purchaseSection: some View {
        VStack(spacing: 16) {
            if let product = purchaseManager.premiumUnlockProduct {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Premium Unlock")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                            
                            Text("One-time purchase")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }
                        
                        Spacer()
                        
                        Text(purchaseManager.formatPrice(for: product))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    Button(action: {
                        Task {
                            isPurchasing = true
                            let success = await purchaseManager.purchase(product)
                            isPurchasing = false
                            
                            if success {
                                dismiss()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            if isPurchasing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Text(isPurchasing ? "Purchasing..." : "Unlock Premium Reciters")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.accentGradient)
                                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 8)
                        )
                    }
                    .disabled(isPurchasing || purchaseManager.isPurchasing)
                    .scaleEffect(isPurchasing ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPurchasing)
                }
            } else if purchaseManager.isLoadingProducts {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(themeManager.accentColor)
                    
                    Text("Loading product information...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                .frame(height: 100)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    
                    Text("Unable to load product information")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                    
                    Button("Retry") {
                        Task {
                            await purchaseManager.loadProducts()
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.accentColor)
                }
                .frame(height: 100)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
    
    private var restoreSection: some View {
        VStack(spacing: 12) {
            Button("Restore Purchases") {
                Task {
                    await purchaseManager.restorePurchases()
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(themeManager.accentColor)
            
            Text("Already purchased? Restore your premium access")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.tertiaryText)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Feature Row Component

struct PremiumFeatureRow: View {
    @StateObject private var themeManager = ThemeManager.shared
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Navigation Bar Background

extension View {
    func navigationBarBackground(_ color: Color) -> some View {
        self.toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    PremiumPurchaseSheet()
}