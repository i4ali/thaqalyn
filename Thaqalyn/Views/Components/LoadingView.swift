//
//  LoadingView.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    var showProgress: Bool = false
    var progress: Double = 0.0
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: ThaqalynDesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(
                        ThaqalynDesignSystem.Colors.primaryBlue.opacity(0.2),
                        lineWidth: 4
                    )
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: showProgress ? progress : 0.7)
                    .stroke(
                        ThaqalynDesignSystem.Gradients.primary,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        showProgress ? .none : .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: ThaqalynDesignSystem.Spacing.sm) {
                Text(message)
                    .font(ThaqalynDesignSystem.Typography.calloutFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                
                if showProgress {
                    Text("\(Int(progress * 100))%")
                        .font(ThaqalynDesignSystem.Typography.captionFont)
                        .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                }
            }
        }
        .padding(ThaqalynDesignSystem.Spacing.xl)
        .onAppear {
            if !showProgress {
                isAnimating = true
            }
        }
    }
}

struct LoadingOverlay: View {
    var message: String = "Loading..."
    var showProgress: Bool = false
    var progress: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ModernCard {
                LoadingView(
                    message: message,
                    showProgress: showProgress,
                    progress: progress
                )
            }
        }
    }
}

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        ThaqalynDesignSystem.Colors.backgroundGray,
                        ThaqalynDesignSystem.Colors.backgroundGray.opacity(0.6),
                        ThaqalynDesignSystem.Colors.backgroundGray
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.sm))
            .scaleEffect(x: isAnimating ? 1 : 0.8)
            .opacity(isAnimating ? 0.6 : 1)
            .animation(
                .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct CommentarySkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.md) {
            HStack {
                SkeletonView()
                    .frame(width: 100, height: 20)
                
                Spacer()
                
                SkeletonView()
                    .frame(width: 60, height: 20)
            }
            
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.sm) {
                SkeletonView()
                    .frame(height: 16)
                
                SkeletonView()
                    .frame(height: 16)
                
                SkeletonView()
                    .frame(width: 200, height: 16)
            }
            
            HStack {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonView()
                        .frame(width: 70, height: 30)
                }
                
                Spacer()
            }
        }
        .padding(ThaqalynDesignSystem.Spacing.lg)
    }
}

#Preview {
    VStack(spacing: ThaqalynDesignSystem.Spacing.xl) {
        LoadingView()
        
        LoadingView(message: "Generating commentary...", showProgress: true, progress: 0.65)
        
        ModernCard {
            CommentarySkeletonView()
        }
    }
    .padding(ThaqalynDesignSystem.Spacing.lg)
    .background(ThaqalynDesignSystem.Colors.backgroundGray)
}