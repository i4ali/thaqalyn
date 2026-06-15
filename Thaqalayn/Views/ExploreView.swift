//
//  ExploreView.swift
//  Thaqalayn
//
//  Table of contents style layout for discovery features
//

import SwiftUI

// MARK: - Data Model

enum ExploreSection: CaseIterable {
    case lifeAndGuidance
    case storiesAndFigures

    func title(for language: CommentaryLanguage) -> String {
        switch self {
        case .lifeAndGuidance:
            switch language {
            case .arabic: return "الحياة والهداية"
            case .urdu:   return "زندگی و رہنمائی"
            default:      return "Life & Guidance"
            }
        case .storiesAndFigures:
            switch language {
            case .arabic: return "القصص والشخصيات"
            case .urdu:   return "قصے اور شخصیات"
            default:      return "Stories & Figures"
            }
        }
    }

    var items: [ExploreItem] {
        switch self {
        case .lifeAndGuidance:
            return [
                ExploreItem(
                    id: "lifeMoments",
                    icon: "heart.fill",
                    titleEn: "Life Moments",
                    titleAr: "لحظات الحياة",
                    titleUr: "زندگی کے لمحات",
                    subtitleEn: "Find solace for any situation",
                    subtitleAr: "اعثر على السكينة في كل حال",
                    subtitleUr: "ہر حال میں سکون پائیں",
                    destination: .lifeMoments
                ),
                ExploreItem(
                    id: "dailyDuas",
                    icon: "hands.sparkles.fill",
                    titleEn: "Daily Duas",
                    titleAr: "أدعية يومية",
                    titleUr: "روزمرہ دعائیں",
                    subtitleEn: "20 supplications for everyday moments",
                    subtitleAr: "20 دعاءً للحظات اليومية",
                    subtitleUr: "روزمرہ لمحات کے لیے 20 دعائیں",
                    destination: .dailyDuas
                ),
                ExploreItem(
                    id: "foods",
                    icon: "leaf.fill",
                    titleEn: "Foods of the Quran",
                    titleAr: "أطعمة القرآن",
                    titleUr: "قرآن کی غذائیں",
                    subtitleEn: "Nourishment from Qur'an & Ahlul Bayt",
                    subtitleAr: "غذاءٌ من القرآن وأهل البيت (ع)",
                    subtitleUr: "قرآن اور اہلِ بیت سے غذا",
                    destination: .foods
                ),
                ExploreItem(
                    id: "propheticParallels",
                    icon: "person.2.wave.2.fill",
                    titleEn: "Prophetic Parallels",
                    titleAr: "أمثلة الأنبياء",
                    titleUr: "انبیائی مثالیں",
                    subtitleEn: "You aren't alone in your struggles",
                    subtitleAr: "لستَ وحدك في محنتك",
                    subtitleUr: "اپنی آزمائشوں میں آپ اکیلے نہیں",
                    destination: .propheticParallels
                ),
                ExploreItem(
                    id: "questions",
                    icon: "questionmark.circle",
                    titleEn: "Questions & Answers",
                    titleAr: "أسئلة وأجوبة",
                    titleUr: "سوالات و جوابات",
                    subtitleEn: "Quranic answers to questions",
                    subtitleAr: "أجوبة قرآنية على تساؤلاتك",
                    subtitleUr: "سوالوں کے قرآنی جوابات",
                    destination: .questions
                ),
                ExploreItem(
                    id: "fasting",
                    icon: "moon.fill",
                    titleEn: "Fasting in the Quran",
                    titleAr: "الصيام في القرآن",
                    titleUr: "قرآن میں روزہ",
                    subtitleEn: "Verses about fasting & Ramadan",
                    subtitleAr: "آياتٌ عن الصيام ورمضان",
                    subtitleUr: "روزے اور رمضان سے متعلق آیات",
                    destination: .fasting
                )
            ]
        case .storiesAndFigures:
            return [
                ExploreItem(
                    id: "propheticStories",
                    icon: "book",
                    titleEn: "Prophetic Stories",
                    titleAr: "قصص الأنبياء",
                    titleUr: "انبیاء کے قصے",
                    subtitleEn: "Accounts of the messengers",
                    subtitleAr: "سِيَر الرسل",
                    subtitleUr: "رسولوں کے واقعات",
                    destination: .propheticStories
                ),
                ExploreItem(
                    id: "ahlulbaytQuran",
                    icon: "star.fill",
                    titleEn: "Ahl al-Bayt in Quran",
                    titleAr: "أهل البيت في القرآن",
                    titleUr: "قرآن میں اہلِ بیت",
                    subtitleEn: "Verses honoring the family",
                    subtitleAr: "آياتٌ في فضل آل النبي (ص)",
                    subtitleUr: "آلِ رسول کی شان میں آیات",
                    destination: .ahlulbaytQuran
                )
            ]
        }
    }
}

struct ExploreItem: Identifiable {
    let id: String
    let icon: String
    let titleEn: String
    let titleAr: String
    let titleUr: String
    let subtitleEn: String
    let subtitleAr: String
    let subtitleUr: String
    let destination: ExploreDestination

    func title(for language: CommentaryLanguage) -> String {
        switch language {
        case .arabic: return titleAr
        case .urdu:   return titleUr
        default:      return titleEn
        }
    }

    func subtitle(for language: CommentaryLanguage) -> String {
        switch language {
        case .arabic: return subtitleAr
        case .urdu:   return subtitleUr
        default:      return subtitleEn
        }
    }
}

enum ExploreDestination {
    case lifeMoments
    case dailyDuas
    case propheticParallels
    case questions
    case fasting
    case foods
    case propheticStories
    case ahlulbaytQuran
}

// MARK: - View

struct ExploreView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var showLifeMoments = false
    @State private var showDailyDuas = false
    @State private var showPropheticParallels = false
    @State private var showQuestions = false
    @State private var showFasting = false
    @State private var showPropheticStories = false
    @State private var showAhlulbaytQuran = false
    @State private var showFoods = false

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }

    private var localizedTitle: String {
        switch lang {
        case .arabic: return "استكشف"
        case .urdu:   return "تلاش کریں"
        default:      return "Explore"
        }
    }

    private var localizedSubtitle: String {
        switch lang {
        case .arabic: return "تأمّل حكمة القرآن الكريم"
        case .urdu:   return "قرآنی حکمت پر غور کریں"
        default:      return "Discover Quranic Wisdom"
        }
    }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                EmeraldExploreView(onTap: handleTap)
            } else {
                legacyBody
            }
        }
        .fullScreenCover(isPresented: $showLifeMoments) {
            LifeMomentsView()
        }
        .fullScreenCover(isPresented: $showDailyDuas) {
            DuasView()
        }
        .fullScreenCover(isPresented: $showPropheticParallels) {
            PropheticParallelsView()
        }
        .fullScreenCover(isPresented: $showQuestions) {
            QuestionsView()
        }
        .fullScreenCover(isPresented: $showFasting) {
            FastingVersesView()
        }
        .fullScreenCover(isPresented: $showPropheticStories) {
            PropheticStoriesView()
        }
        .fullScreenCover(isPresented: $showAhlulbaytQuran) {
            AhlulbaytQuranView()
        }
        .fullScreenCover(isPresented: $showFoods) {
            FoodsView()
        }
    }

    private var legacyBody: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizedTitle)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.primaryText)

                    Text(localizedSubtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Sections
                ForEach(ExploreSection.allCases, id: \.self) { section in
                    sectionView(section)
                }

                Spacer(minLength: 100)
            }
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }

    @ViewBuilder
    private func sectionView(_ section: ExploreSection) -> some View {
        VStack(spacing: 0) {
            // Section header
            ExploreSectionHeader(title: section.title(for: lang))

            // Section card with rows
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    ExploreRow(
                        icon: iconForItem(item),
                        title: item.title(for: lang),
                        subtitle: item.subtitle(for: lang)
                    ) {
                        handleTap(item.destination)
                    }

                    // Divider between rows (not after last row)
                    if index < section.items.count - 1 {
                        Divider()
                            .padding(.leading, 76) // Align with text, not icon
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.strokeColor, lineWidth: 1))
                    .shadow(
                        color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                        radius: 12, x: 0, y: 4
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
        }
    }

    private func iconForItem(_ item: ExploreItem) -> String {
        // Use emoji for warmInviting theme, SF Symbols text for others
        switch item.destination {
        case .lifeMoments:
            return "heart.fill"
        case .dailyDuas:
            return "hands.sparkles.fill"
        case .propheticParallels:
            return "person.2.wave.2.fill"
        case .questions:
            return "questionmark.circle"
        case .fasting:
            return "moon.fill"
        case .propheticStories:
            return "book"
        case .ahlulbaytQuran:
            return "star.fill"
        case .foods:
            return "leaf.fill"
        }
    }

    private func handleTap(_ destination: ExploreDestination) {
        switch destination {
        case .lifeMoments:
            showLifeMoments = true
        case .dailyDuas:
            showDailyDuas = true
        case .propheticParallels:
            showPropheticParallels = true
        case .questions:
            showQuestions = true
        case .fasting:
            showFasting = true
        case .propheticStories:
            showPropheticStories = true
        case .ahlulbaytQuran:
            showAhlulbaytQuran = true
        case .foods:
            showFoods = true
        }
    }
}

// MARK: - Midnight Emerald — Explore

private struct EmeraldExploreView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    let onTap: (ExploreDestination) -> Void

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    private var isRTL: Bool { lang.isRTL }

    private var localizedEyebrow: String {
        switch lang {
        case .arabic: return "اكتشف"
        case .urdu:   return "دریافت"
        default:      return "Discover"
        }
    }

    private var localizedTitle: String {
        switch lang {
        case .arabic: return "استكشف"
        case .urdu:   return "تلاش کریں"
        default:      return "Explore"
        }
    }

    private var localizedSubtitle: String {
        switch lang {
        case .arabic: return "تأمّل حكمة القرآن الكريم"
        case .urdu:   return "قرآنی حکمت پر غور کریں"
        default:      return "Discover Quranic Wisdom"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(localizedEyebrow.uppercased())
                        .font(.system(size: 11, weight: .bold)).tracking(3)
                        .foregroundColor(themeManager.accentColor)
                    Text(localizedTitle)
                        .font(EmType.serif(40, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(localizedSubtitle)
                        .font(.system(size: 13.5))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.top, 8)

                ForEach(ExploreSection.allCases, id: \.self) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        EmDivider(label: section.title(for: lang))
                        VStack(spacing: 10) {
                            ForEach(section.items) { item in
                                Button { onTap(item.destination) } label: {
                                    EmCard {
                                        HStack(spacing: 14) {
                                            EmIconChip(sfSymbol: item.icon, size: 44)
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(item.title(for: lang))
                                                    .font(EmType.serif(19, .semiBold))
                                                    .foregroundColor(themeManager.primaryText)
                                                Text(item.subtitle(for: lang))
                                                    .font(.system(size: 12.5))
                                                    .foregroundColor(themeManager.tertiaryText)
                                                    .lineLimit(1)
                                            }
                                            Spacer(minLength: 8)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(themeManager.tertiaryText)
                                        }
                                        .padding(16)
                                    }
                                }
                                .buttonStyle(EmPressStyle())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 120)
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }
}

#Preview {
    ExploreView()
}
