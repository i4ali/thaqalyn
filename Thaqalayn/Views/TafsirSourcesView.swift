//
//  TafsirSourcesView.swift
//  Thaqalayn
//
//  Displays the sources and scholars referenced in the tafsir commentary
//

import SwiftUI

struct TafsirSourcesView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Introduction
                        Text("The commentary in this app draws from classical and contemporary Shia scholarship. Below are the primary sources referenced for each layer.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        // Layer 1 - Foundation
                        SourceSection(
                            icon: "building.columns.fill",
                            title: "Foundation",
                            iconColor: .blue,
                            sources: [
                                SourceItem(title: "General Islamic Scholarship", subtitle: "Historical context and foundational understanding"),
                                SourceItem(title: "Classical Tafsir Methodology", subtitle: "Traditional exegetical approaches")
                            ]
                        )

                        // Layer 2 - Classical Shia
                        SourceSection(
                            icon: "books.vertical.fill",
                            title: "Classical Shia",
                            iconColor: .purple,
                            sources: [
                                SourceItem(title: "Tafsir al-Mizan", subtitle: "Allama Muhammad Husayn Tabatabai"),
                                SourceItem(title: "Majma' al-Bayan", subtitle: "Sheikh Abu Ali al-Fadl al-Tabrisi"),
                                SourceItem(title: "Sharh al-Lum'a", subtitle: "Classical jurisprudential commentary")
                            ]
                        )

                        // Layer 3 - Contemporary
                        SourceSection(
                            icon: "globe",
                            title: "Contemporary",
                            iconColor: .green,
                            sources: [
                                SourceItem(title: "Ayatollah Naser Makarem Shirazi", subtitle: "Contemporary Shia scholar"),
                                SourceItem(title: "Sheikh Mansour Leghaei", subtitle: "Islamic educator and author"),
                                SourceItem(title: "Dr. Reza Shah-Kazemi", subtitle: "Islamic philosopher and author")
                            ]
                        )

                        // Layer 4 - Ahlul Bayt
                        SourceSection(
                            icon: "star.fill",
                            title: "Ahlul Bayt",
                            iconColor: .yellow,
                            sources: [
                                SourceItem(title: "Al-Kafi", subtitle: "Sheikh al-Kulayni"),
                                SourceItem(title: "Bihar al-Anwar", subtitle: "Allama Muhammad Baqir al-Majlisi"),
                                SourceItem(title: "Tafsir al-Qummi", subtitle: "Ali ibn Ibrahim al-Qummi"),
                                SourceItem(title: "Tafsir al-Ayyashi", subtitle: "Muhammad ibn Mas'ud al-Ayyashi"),
                                SourceItem(title: "Al-Sahifa al-Sajjadiyya", subtitle: "Imam Ali Zayn al-Abidin")
                            ]
                        )

                        // Layer 5 - Comparative
                        SourceSection(
                            icon: "scale.3d",
                            title: "Comparative",
                            iconColor: .orange,
                            sources: [
                                SourceItem(title: "Classical Sunni Tafsir Traditions", subtitle: "For comparative scholarly analysis"),
                                SourceItem(title: "Shia-Sunni Scholarly Dialogue", subtitle: "Balanced academic perspectives")
                            ]
                        )
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Tafsir Sources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SourceItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

struct SourceSection: View {
    let icon: String
    let title: String
    let iconColor: Color
    let sources: [SourceItem]

    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            .padding(.horizontal, 20)

            // Sources List
            VStack(spacing: 0) {
                ForEach(sources) { source in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)

                        Text(source.subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)

                    if source.id != sources.last?.id {
                        Divider()
                            .background(themeManager.strokeColor)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    TafsirSourcesView()
}
