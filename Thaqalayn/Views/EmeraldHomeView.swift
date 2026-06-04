//
//  EmeraldHomeView.swift
//  Thaqalayn
//
//  Midnight Emerald layout for the Quran (Home/Read) tab. Shown by HomeView
//  when the emerald theme is active; the Light layout is unchanged.
//

import SwiftUI

struct EmeraldHomeView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared

    @Binding var searchText: String
    @Binding var selectedSurahForDeepLink: SurahWithTafsir?
    @Binding var targetVerseNumber: Int?

    @State private var showNotifications = false
    @State private var animateProgress = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var filteredSurahs: [SurahWithTafsir] {
        dataManager.availableSurahs.filter { s in
            searchText.isEmpty ||
            s.surah.englishName.localizedCaseInsensitiveContains(searchText) ||
            s.surah.englishNameTranslation.localizedCaseInsensitiveContains(searchText) ||
            s.surah.arabicName.contains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            greetingRow
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    EmHeading(eyebrow: "The Noble Qur'an", title: "Read & Reflect")

                    if let info = progressManager.lastReadInfo,
                       let s = dataManager.availableSurahs.first(where: { $0.surah.number == info.surahNumber }) {
                        continueReadingCard(info: info, surah: s)
                    }

                    searchField
                    EmDivider(label: "114 Surahs")
                    surahList
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
        .background(deepLinkLink)
        .sheet(isPresented: $showNotifications) { NotificationsView() }
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) { animateProgress = true }
        }
    }

    private var greetingRow: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("Assalāmu ʿalaykum")
                .font(.system(size: 11, weight: .semibold)).tracking(0.5)
                .foregroundColor(themeManager.tertiaryText)
            Spacer()

            NavigationLink(destination: BookmarksView()) {
                PhosphorIcon(name: "ph-heart-fill", size: 15)
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())

            Button { showNotifications = true } label: {
                PhosphorIcon(name: "ph-bell", size: 16)
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
        }
    }

    private func continueReadingCard(info: LastReadInfo, surah s: SurahWithTafsir) -> some View {
        EmCard(glow: true) {
            ZStack(alignment: .topTrailing) {
                Text("\(info.surahNumber)")
                    .font(EmType.serif(120))
                    .foregroundColor(themeManager.accentColor.opacity(0.07))
                    .offset(x: 8, y: -18)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Continue Reading".uppercased())
                        .font(.system(size: 11, weight: .bold)).tracking(2)
                        .foregroundColor(themeManager.accentColor)
                    Text(s.surah.englishName)
                        .font(EmType.serif(27, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text("Verse \(info.verseNumber) of \(s.surah.versesCount) · \(Int(info.progress * 100))% complete")
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.secondaryText)

                    ZStack(alignment: .leading) {
                        Capsule().fill(themeManager.accentChip).frame(height: 4)
                        GeometryReader { geo in
                            Capsule().fill(themeManager.accentGradient)
                                .frame(width: geo.size.width * CGFloat(animateProgress ? info.progress : 0), height: 4)
                        }
                        .frame(height: 4)
                    }
                    .frame(height: 4)

                    Button {
                        targetVerseNumber = info.verseNumber
                        selectedSurahForDeepLink = s
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "play.fill").font(.system(size: 12, weight: .semibold))
                            Text("Resume").font(.system(size: 14, weight: .bold)).tracking(0.3)
                        }
                        .foregroundColor(themeManager.onAccentText)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(Capsule().fill(themeManager.accentGradient))
                        .shadow(color: themeManager.accentColor.opacity(0.28), radius: 16, x: 0, y: 6)
                    }
                    .buttonStyle(EmPressStyle())
                    .padding(.top, 2)
                }
                .padding(20)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            PhosphorIcon(name: "ph-magnifying-glass", size: 16).foregroundColor(themeManager.accentColor)
            TextField("", text: $searchText,
                      prompt: Text("Search surahs, verses, themes…").foregroundColor(themeManager.tertiaryText))
                .foregroundColor(themeManager.primaryText)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(themeManager.glassSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }

    private var surahList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredSurahs) { swt in
                NavigationLink(destination: SurahDetailView(surahWithTafsir: swt, targetVerse: nil)) {
                    ModernSurahCard(surah: swt.surah)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    @ViewBuilder private var deepLinkLink: some View {
        if let surah = selectedSurahForDeepLink {
            NavigationLink(
                destination: SurahDetailView(surahWithTafsir: surah, targetVerse: targetVerseNumber),
                isActive: Binding(
                    get: { selectedSurahForDeepLink != nil },
                    set: { if !$0 { selectedSurahForDeepLink = nil; targetVerseNumber = nil } }
                )
            ) { EmptyView() }
            .hidden()
        }
    }
}
