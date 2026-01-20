//
//  QuickGemsScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Gems Feature Highlight
//

import SwiftUI

struct QuickGemsScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var iconPulse = false
    @State private var highlightedConcept = 0

    // Demo concepts for the sample verse with mock insights
    private let demoConcepts: [(icon: String, title: String, color: Color, coreInsight: String, whyItMatters: String)] = [
        ("heart.fill", "Divine Mercy", .pink,
         "Allah's mercy encompasses all creation, expressed through 'Rahman' and 'Raheem'.",
         "Reminds us that every action begins under Allah's compassionate care."),
        ("sun.max.fill", "Guidance", .orange,
         "The Bismillah sets the foundation for seeking divine guidance in all affairs.",
         "Starting with Allah's name aligns our intentions with divine purpose."),
        ("leaf.fill", "Compassion", .green,
         "'Raheem' indicates special mercy for believers who follow the guided path.",
         "Encourages us to embody compassion in our daily interactions."),
        ("star.fill", "Blessing", .yellow,
         "Beginning with Allah's name invokes barakah (blessing) in all endeavors.",
         "Transforms ordinary actions into acts of worship and remembrance.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header with animated icon
            VStack(spacing: 20) {
                // Animated sparkles icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .scaleEffect(iconPulse ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: iconPulse
                        )

                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    // Sparkles icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                // Title
                Text("Gems")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                // Subtitle
                Text("Precious insights unveiled")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            // Demo verse card
            VStack(spacing: 16) {
                // Demo card container
                VStack(spacing: 16) {
                    // Verse reference
                    HStack(spacing: 8) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("1")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        Text("Al-Fatiha 1")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.secondaryText)
                    }

                    // Arabic verse
                    Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.vertical, 8)

                    // Concept bubbles
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        ForEach(Array(demoConcepts.enumerated()), id: \.offset) { index, concept in
                            DemoConceptBubble(
                                icon: concept.icon,
                                title: concept.title,
                                color: concept.color,
                                isHighlighted: highlightedConcept == index
                            )
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.secondaryBackground.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 40)
                .animation(Animation.easeOut(duration: 0.7).delay(0.6), value: isVisible)

                // Mock detail card showing insight
                DemoInsightCard(
                    concept: demoConcepts[highlightedConcept],
                    isVisible: isVisible
                )
                .animation(.easeInOut(duration: 0.3), value: highlightedConcept)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
            iconPulse = true
            startConceptAnimation()
        }
    }

    private func startConceptAnimation() {
        // Cycle through highlighting different concepts
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                highlightedConcept = (highlightedConcept + 1) % demoConcepts.count
            }
        }
    }
}

// MARK: - Demo Concept Bubble

struct DemoConceptBubble: View {
    @StateObject private var themeManager = ThemeManager.shared

    let icon: String
    let title: String
    let color: Color
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(themeManager.glassEffect)
                .overlay(
                    Capsule()
                        .stroke(isHighlighted ? color : color.opacity(0.3), lineWidth: isHighlighted ? 2 : 1)
                )
        )
        .shadow(color: isHighlighted ? color.opacity(0.4) : Color.clear, radius: 8)
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
    }
}

// MARK: - Demo Insight Card

struct DemoInsightCard: View {
    @StateObject private var themeManager = ThemeManager.shared

    let concept: (icon: String, title: String, color: Color, coreInsight: String, whyItMatters: String)
    let isVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with icon and title
            HStack(spacing: 10) {
                Image(systemName: concept.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(concept.color)

                Text(concept.title.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
            }

            // Core Insight
            VStack(alignment: .leading, spacing: 6) {
                Text("The Core Insight:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(concept.color)

                Text(concept.coreInsight)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)
            }

            // Why it matters
            VStack(alignment: .leading, spacing: 6) {
                Text("Why it matters:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(concept.color)

                Text(concept.whyItMatters)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.primaryBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(concept.color.opacity(0.3), lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .animation(Animation.easeOut(duration: 0.6).delay(0.8), value: isVisible)
    }
}

#Preview {
    QuickGemsScreen()
}
