//
//  CommentaryView.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct CommentaryView: View {
    let content: TafsirContent
    @State private var isExpanded = false
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.lg) {
                // Header
                header
                
                // Commentary content
                commentaryContent
                
                // Footer with metadata
                footer
            }
            .padding(ThaqalynDesignSystem.Spacing.lg)
        }
    }
    
    private var header: some View {
        HStack(spacing: ThaqalynDesignSystem.Spacing.md) {
            Text(content.layerInfo.icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.xs) {
                Text(content.layerInfo.title)
                    .font(ThaqalynDesignSystem.Typography.headlineFont)
                    .fontWeight(.semibold)
                    .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                
                Text(content.layerInfo.description)
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Confidence indicator
            confidenceIndicator
        }
    }
    
    private var commentaryContent: some View {
        VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.md) {
            Text(content.content)
                .font(ThaqalynDesignSystem.Typography.bodyFont)
                .foregroundColor(ThaqalynDesignSystem.Colors.textPrimary)
                .lineLimit(isExpanded ? nil : 10)
                .animation(.easeInOut, value: isExpanded)
            
            if content.content.count > 300 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(isExpanded ? "Show Less" : "Read More")
                            .font(ThaqalynDesignSystem.Typography.captionFont)
                            .fontWeight(.medium)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var footer: some View {
        VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.sm) {
            Divider()
            
            HStack {
                // Sources
                if !content.sources.isEmpty {
                    HStack(spacing: ThaqalynDesignSystem.Spacing.xs) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 12))
                        
                        Text("Sources: \(content.sources.joined(separator: ", "))")
                            .font(ThaqalynDesignSystem.Typography.captionFont)
                    }
                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
                }
                
                Spacer()
                
                // Generation date
                Text(formatDate(content.generatedAt))
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
            }
            
            // Action buttons
            actionButtons
        }
    }
    
    private var confidenceIndicator: some View {
        HStack(spacing: ThaqalynDesignSystem.Spacing.xs) {
            Circle()
                .fill(confidenceColor)
                .frame(width: 8, height: 8)
            
            Text("\(Int(content.confidenceScore * 100))%")
                .font(ThaqalynDesignSystem.Typography.captionFont)
                .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
        }
    }
    
    private var confidenceColor: Color {
        switch content.confidenceScore {
        case 0.8...:
            return ThaqalynDesignSystem.Colors.islamicGreen
        case 0.6..<0.8:
            return ThaqalynDesignSystem.Colors.goldAccent
        default:
            return Color.orange
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: ThaqalynDesignSystem.Spacing.md) {
            Button(action: shareCommentary) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
            }
            .buttonStyle(.plain)
            
            Button(action: copyCommentary) {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: regenerateCommentary) {
                Label("Regenerate", systemImage: "arrow.clockwise")
                    .font(ThaqalynDesignSystem.Typography.captionFont)
                    .foregroundColor(ThaqalynDesignSystem.Colors.secondaryGray)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func shareCommentary() {
        let shareText = """
        \(content.layerInfo.title) Commentary
        Surah \(content.surah), Verse \(content.ayah)
        
        \(content.content)
        
        Generated by Thaqalyn
        """
        
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    private func copyCommentary() {
        UIPasteboard.general.string = content.content
        // TODO: Show toast notification
    }
    
    private func regenerateCommentary() {
        // TODO: Trigger regeneration
    }
}

// Expandable text view for long commentary
struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    @State private var isExpanded = false
    @State private var isTruncated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.sm) {
            Text(text)
                .font(ThaqalynDesignSystem.Typography.bodyFont)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    Text(text)
                        .font(ThaqalynDesignSystem.Typography.bodyFont)
                        .lineLimit(lineLimit)
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                let height = geometry.size.height
                                let lineHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight
                                isTruncated = height > lineHeight * CGFloat(lineLimit)
                            }
                        })
                        .hidden()
                )
                .animation(.easeInOut, value: isExpanded)
            
            if isTruncated {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: ThaqalynDesignSystem.Spacing.xs) {
                        Text(isExpanded ? "Show Less" : "Read More")
                            .font(ThaqalynDesignSystem.Typography.captionFont)
                            .fontWeight(.medium)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(ThaqalynDesignSystem.Colors.primaryBlue)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    let sampleContent = TafsirContent(
        surah: 1,
        ayah: 1,
        layer: 1,
        content: "This verse opens with the Basmala, the invocation of Allah's name. In Islamic tradition, beginning any significant action with 'Bismillah' acknowledges Allah as the source of all blessing and success. The words 'Ar-Rahman' and 'Ar-Raheem' both derive from the root r-h-m, related to mercy, but Rahman refers to Allah's universal mercy for all creation, while Raheem indicates His special mercy for believers. This fundamental principle establishes the proper relationship between the creator and creation.",
        sources: ["tabatabai", "contemporary"],
        confidenceScore: 0.85
    )
    
    CommentaryView(content: sampleContent)
        .padding()
        .background(ThaqalynDesignSystem.Colors.backgroundGray)
}