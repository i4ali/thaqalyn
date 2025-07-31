//
//  LayerSelector.swift
//  Thaqalyn
//
//  Created by Claude on 7/31/25.
//

import SwiftUI

struct LayerSelector: View {
    @Binding var selectedLayer: Int
    let layers: [CommentaryLayer]
    var isCompact: Bool = false
    
    struct CommentaryLayer {
        let id: Int
        let title: String
        let icon: String
        let description: String
        let color: Color
        
        static let all: [CommentaryLayer] = [
            CommentaryLayer(
                id: 1,
                title: "Foundation",
                icon: "🏛️",
                description: "Simple explanation & context",
                color: ThaqalynDesignSystem.Colors.primaryBlue
            ),
            CommentaryLayer(
                id: 2,
                title: "Classical",
                icon: "📚",
                description: "Tabatabai & traditional scholars",
                color: ThaqalynDesignSystem.Colors.islamicGreen
            ),
            CommentaryLayer(
                id: 3,
                title: "Contemporary",
                icon: "🌍",
                description: "Modern insights & applications",
                color: ThaqalynDesignSystem.Colors.goldAccent
            ),
            CommentaryLayer(
                id: 4,
                title: "Ahlul Bayt",
                icon: "⭐",
                description: "Hadith & spiritual wisdom",
                color: ThaqalynDesignSystem.Colors.deepBlue
            )
        ]
    }
    
    init(selectedLayer: Binding<Int>, isCompact: Bool = false) {
        self._selectedLayer = selectedLayer
        self.layers = CommentaryLayer.all
        self.isCompact = isCompact
    }
    
    var body: some View {
        if isCompact {
            compactView
        } else {
            expandedView
        }
    }
    
    private var compactView: some View {
        HStack(spacing: ThaqalynDesignSystem.Spacing.xs) {
            ForEach(layers, id: \.id) { layer in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedLayer = layer.id
                    }
                }) {
                    VStack(spacing: ThaqalynDesignSystem.Spacing.xs) {
                        Text(layer.icon)
                            .font(.system(size: 16))
                        
                        Text(layer.title)
                            .font(ThaqalynDesignSystem.Typography.captionFont)
                            .fontWeight(selectedLayer == layer.id ? .semibold : .regular)
                    }
                    .foregroundColor(selectedLayer == layer.id ? layer.color : ThaqalynDesignSystem.Colors.secondaryGray)
                    .padding(.vertical, ThaqalynDesignSystem.Spacing.xs)
                    .padding(.horizontal, ThaqalynDesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.sm)
                            .fill(selectedLayer == layer.id ? layer.color.opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, ThaqalynDesignSystem.Spacing.sm)
        .padding(.vertical, ThaqalynDesignSystem.Spacing.xs)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.md))
        .shadow(
            color: ThaqalynDesignSystem.Shadow.light.color,
            radius: ThaqalynDesignSystem.Shadow.light.radius,
            x: ThaqalynDesignSystem.Shadow.light.x,
            y: ThaqalynDesignSystem.Shadow.light.y
        )
    }
    
    private var expandedView: some View {
        VStack(spacing: ThaqalynDesignSystem.Spacing.sm) {
            ForEach(layers, id: \.id) { layer in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedLayer = layer.id
                    }
                }) {
                    HStack(spacing: ThaqalynDesignSystem.Spacing.md) {
                        Text(layer.icon)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: ThaqalynDesignSystem.Spacing.xs) {
                            Text(layer.title)
                                .font(ThaqalynDesignSystem.Typography.calloutFont)
                                .fontWeight(.semibold)
                            
                            Text(layer.description)
                                .font(ThaqalynDesignSystem.Typography.captionFont)
                                .foregroundColor(ThaqalynDesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        if selectedLayer == layer.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(layer.color)
                                .font(.system(size: 20))
                        }
                    }
                    .foregroundColor(selectedLayer == layer.id ? layer.color : ThaqalynDesignSystem.Colors.textPrimary)
                    .padding(ThaqalynDesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.md)
                            .fill(selectedLayer == layer.id ? layer.color.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: ThaqalynDesignSystem.CornerRadius.md)
                                    .stroke(
                                        selectedLayer == layer.id ? layer.color : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: ThaqalynDesignSystem.Spacing.xl) {
        LayerSelector(selectedLayer: .constant(1))
        
        LayerSelector(selectedLayer: .constant(2), isCompact: true)
        
        LayerSelector(selectedLayer: .constant(3))
    }
    .padding(ThaqalynDesignSystem.Spacing.lg)
    .background(ThaqalynDesignSystem.Colors.backgroundGray)
}