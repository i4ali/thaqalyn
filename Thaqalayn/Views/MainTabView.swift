//
//  MainTabView.swift
//  Thaqalayn
//
//  Main TabView container: Today, Quran, Explore, Progress, Journey
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var deepLinkRouter = DeepLinkRouter.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var tabBarVisibility = TabBarVisibility.shared
    @StateObject private var listen = JourneyListenPresenter.shared
    @StateObject private var duaStream = DuaStreamPlayer.shared
    @State private var selectedTab = 0
    /// The dua whose reader is being shown full-screen from the docked dua mini-player
    /// (reopening it from any tab). The Duas & Ziyarat library pushes its own copy.
    @State private var expandedDua: SpecialDua?

    /// The docked journey mini-player shows when a journey is loaded but its full-screen
    /// player is minimized - and never while the tab bar itself is hidden (immersive
    /// screens), since it docks against that bar.
    private var showMiniPlayer: Bool {
        listen.dive != nil && !listen.expanded && !tabBarVisibility.isHidden
    }

    /// The docked dua mini-player shows while a streamed recitation is loaded (playing
    /// or paused). Starting a stream closes the journey Listen session (and vice versa),
    /// so the two bars never stack.
    private var showDuaMiniPlayer: Bool {
        duaStream.currentDua != nil && listen.dive == nil && !tabBarVisibility.isHidden
    }

    // Localized label for each tab, driven by the global Settings → Language picker.
    private func tabLabel(_ id: Int) -> String {
        switch id {
        case 0:
            switch languageManager.selectedLanguage {
            case .arabic: return "اليوم"
            case .urdu:   return "آج"
            default:      return "Today"
            }
        case 1:
            switch languageManager.selectedLanguage {
            case .arabic: return "القرآن"
            case .urdu:   return "قرآن"
            default:      return "Quran"
            }
        case 2:
            switch languageManager.selectedLanguage {
            case .arabic: return "اكتشف"
            case .urdu:   return "دریافت"
            default:      return "Explore"
            }
        case 3:
            switch languageManager.selectedLanguage {
            case .arabic: return "التقدّم"
            case .urdu:   return "پیش رفت"
            default:      return "Progress"
            }
        default:
            switch languageManager.selectedLanguage {
            case .arabic: return "رحلة"
            case .urdu:   return "سفر"
            default:      return "Journey"
            }
        }
    }

    // Items for the Midnight Emerald floating tab bar — mirrors the five
    // permanent tabs in the TabView below.
    private var emeraldItems: [EmeraldTabItem] {
        [
            EmeraldTabItem(id: 0, label: tabLabel(0), sfSymbol: "sun.max"),
            EmeraldTabItem(id: 1, label: tabLabel(1), sfSymbol: "book.closed"),
            EmeraldTabItem(id: 2, label: tabLabel(2), sfSymbol: "sparkles"),
            EmeraldTabItem(id: 3, label: tabLabel(3), sfSymbol: "chart.bar"),
            EmeraldTabItem(id: 4, label: tabLabel(4), sfSymbol: "map"),
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
        TabView(selection: $selectedTab) {
            TodayTab(selectedTab: $selectedTab)
                .tabItem {
                    Label {
                        Text(tabLabel(0))
                    } icon: {
                        Image(systemName: "sun.max.fill")
                    }
                }
                .tag(0)
                .toolbar(.hidden, for: .tabBar)

            HomeTab()
                .tabItem {
                    Label {
                        Text(tabLabel(1))
                    } icon: {
                        Image(systemName: "book.closed.fill")
                    }
                }
                .tag(1)
                .toolbar(.hidden, for: .tabBar)

            ExploreTab()
                .tabItem {
                    Label {
                        Text(tabLabel(2))
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
                .tag(2)
                .toolbar(.hidden, for: .tabBar)

            ProgressTab()
                .tabItem {
                    Label {
                        Text(tabLabel(3))
                    } icon: {
                        Image(systemName: "circle.circle")
                    }
                }
                .tag(3)
                .toolbar(.hidden, for: .tabBar)

            // Permanent Journey hub — lists all seasonal journeys; only active ones open.
            JourneyHubView()
                .tabItem {
                    Label {
                        Text(tabLabel(4))
                    } icon: {
                        Image(systemName: "map.fill")
                    }
                }
                .tag(4)
                .toolbar(.hidden, for: .tabBar)
        }
        .tint(themeManager.accentColor)
        .background(HideNativeTabBar(hidden: true))
        .disableTabBarMinimize()
        // Rebuild the TabView when the theme changes. iOS 26's Liquid-Glass tab bar
        // can get stuck in its minimized presentation when the switch happens while
        // a sheet (Settings) covers the TabView — and neither .tabBarMinimizeBehavior(.never)
        // nor restoring alpha/isHidden re-expands it. A fresh TabView starts expanded.
        .id(themeManager.selectedTheme)

        if !tabBarVisibility.isHidden {
            EmeraldTabBar(items: emeraldItems, selection: $selectedTab)
        }

        // Docked journey narration mini-player, floating just above the tab bar. Persists
        // across all tabs while a journey is playing and its full player is minimized.
        if showMiniPlayer {
            JourneyMiniPlayer()
                .padding(.bottom, JourneyMiniPlayer.bottomInset)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }

        // Docked dua-recitation mini-player, floating just above the tab bar. Persists
        // across all tabs while a streamed dua/ziyarat recitation is loaded; tapping it
        // reopens the dua's reader full-screen.
        if showDuaMiniPlayer {
            DuaMiniPlayer { expandedDua = duaStream.currentDua }
                .padding(.bottom, JourneyMiniPlayer.bottomInset)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: showMiniPlayer)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: showDuaMiniPlayer)
        // The full-screen journey player - hosted once at the root so minimizing it drops
        // to the docked mini-player instead of tearing narration down. Dismissal (chevron
        // or a swipe) minimizes rather than stops; the mini-player keeps the controls.
        .fullScreenCover(isPresented: Binding(
            get: { listen.expanded && listen.dive != nil },
            set: { if !$0 { listen.minimize() } }
        )) {
            if let dive = listen.dive {
                JourneyListenView(dive: dive, onClose: { listen.minimize() })
            }
        }
        // A locked "Listen" tap routes here through the presenter.
        .fullScreenCover(item: $listen.paywall) { ctx in
            PaywallView(context: ctx)
        }
        // The dua reader, reopened from the docked dua mini-player. Wrapped in its own
        // NavigationView (the same shell DuasZiyaratView gives it) so the toolbar Back
        // button dismisses the cover; the recitation keeps playing either way.
        .fullScreenCover(item: $expandedDua) { dua in
            NavigationView {
                SpecialDuaDetailView(dua: dua)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .preferredColorScheme(themeManager.colorScheme)
            .darkScreenAura()
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToVerse)) { notification in
            guard let userInfo = notification.userInfo,
                  let surah = userInfo["surah"] as? Int,
                  let verse = userInfo["verse"] as? Int else { return }

            // Stash the deep-link first so HomeView consumes it on appear
            deepLinkRouter.pendingDeepLink = PendingDeepLink(
                surahNumber: surah,
                verseNumber: verse
            )
            // Then switch to the Quran tab — HomeView's onAppear/onChange triggers the navigation.
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToJourney)) { notification in
            guard let userInfo = notification.userInfo,
                  let journeyId = userInfo["journey"] as? String else { return }

            // All journeys now live in the Journey hub (tag 4). Stash the id so
            // the hub auto-opens it if that journey is currently active.
            DeepLinkRouter.shared.pendingJourneyId = journeyId
            selectedTab = 4
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToSurahExperience)) { notification in
            guard let userInfo = notification.userInfo,
                  let experienceId = userInfo["id"] as? String else { return }

            // Widget doorway beat -> the Journey hub auto-opens the experience.
            DeepLinkRouter.shared.pendingSurahExperienceId = experienceId
            selectedTab = 4
        }
        .onReceive(NotificationCenter.default.publisher(for: .revealSurahExperience)) { notification in
            guard let userInfo = notification.userInfo,
                  let experienceId = userInfo["id"] as? String else { return }

            // Quran-list Journey tab -> the Journey hub reveals the experience's card
            // (scroll + highlight) so the user chooses Watch or Listen, rather than
            // diving straight in. The hub reads this live, so tapping a different surah
            // while the reveal list is open retargets it.
            DeepLinkRouter.shared.revealSurahExperienceId = experienceId
            selectedTab = 4
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToDeepDive)) { notification in
            guard let userInfo = notification.userInfo,
                  let deepDiveId = userInfo["id"] as? String else { return }

            // Widget doorway beat -> the Journey hub auto-opens the deep dive.
            DeepLinkRouter.shared.pendingDeepDiveId = deepDiveId
            selectedTab = 4
        }
        #if DEBUG
        .onAppear { if ProcessInfo.processInfo.arguments.contains("-ddYaqin") { selectedTab = 4 } }
        #endif
    }
}

private extension View {
    /// Disables iOS 26's tab-bar minimize-on-scroll so the native bar always shows
    /// every tab (in Light it otherwise collapses to a single-tab pill on scroll).
    @ViewBuilder
    func disableTabBarMinimize() -> some View {
        if #available(iOS 26.0, *) {
            self.tabBarMinimizeBehavior(.never)
        } else {
            self
        }
    }
}

/// Hides the native `UITabBar` in BOTH themes — the custom floating `EmeraldTabBar`
/// replaces it everywhere — by driving the live bar's `alpha` to 0. We don't rely on
/// `.toolbar(.hidden, for: .tabBar)` alone: it's unreliable with the tabs' legacy
/// `NavigationView`/`StackNavigationViewStyle`, and on iOS 26 a transparent
/// `UITabBarAppearance` doesn't hide the Liquid-Glass bar. `alpha` is layout-safe.
/// `hidden` is wired through `updateUIViewController` so it stays applied across
/// re-layouts without depending on `dismantleUIViewController` firing.
private struct HideNativeTabBar: UIViewControllerRepresentable {
    var hidden: Bool

    func makeUIViewController(context: Context) -> Proxy { Proxy() }

    func updateUIViewController(_ proxy: Proxy, context: Context) {
        proxy.targetAlpha = hidden ? 0 : 1
        proxy.apply()
    }

    final class Proxy: UIViewController {
        var targetAlpha: CGFloat = 1

        func apply() {
            for tbc in Self.tabBarControllers(in: view.window?.rootViewController) {
                tbc.tabBar.alpha = targetAlpha
                // iOS 26's tab bar minimizes into a single-tab pill on scroll. Disable
                // it so the Light-theme native bar always shows all tabs (and it never
                // interferes with the emerald custom bar). The bar is hidden in emerald.
                if #available(iOS 26.0, *) {
                    tbc.tabBarMinimizeBehavior = .never
                }
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            apply()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            apply()
        }

        /// All tab bar controllers reachable from a root (children + presented).
        static func tabBarControllers(in vc: UIViewController?) -> [UITabBarController] {
            guard let vc else { return [] }
            var result: [UITabBarController] = []
            if let tbc = vc as? UITabBarController { result.append(tbc) }
            vc.children.forEach { result.append(contentsOf: tabBarControllers(in: $0)) }
            if let presented = vc.presentedViewController {
                result.append(contentsOf: tabBarControllers(in: presented))
            }
            return result
        }
    }
}

#Preview {
    MainTabView()
}
