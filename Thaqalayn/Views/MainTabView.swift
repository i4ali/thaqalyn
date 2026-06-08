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
    @ObservedObject private var tabBarVisibility = TabBarVisibility.shared
    @State private var selectedTab = 0

    // Items for the Midnight Emerald floating tab bar — mirrors the five
    // permanent tabs in the TabView below.
    private var emeraldItems: [EmeraldTabItem] {
        [
            EmeraldTabItem(id: 0, label: "Today",    sfSymbol: "sun.max"),
            EmeraldTabItem(id: 1, label: "Quran",    sfSymbol: "book.closed"),
            EmeraldTabItem(id: 2, label: "Explore",  sfSymbol: "sparkles"),
            EmeraldTabItem(id: 3, label: "Progress", sfSymbol: "chart.bar"),
            EmeraldTabItem(id: 4, label: "Journey",  sfSymbol: "map"),
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
        TabView(selection: $selectedTab) {
            TodayTab(selectedTab: $selectedTab)
                .tabItem {
                    Label {
                        Text("Today")
                    } icon: {
                        Image(systemName: "sun.max.fill")
                    }
                }
                .tag(0)
                .toolbar(.hidden, for: .tabBar)

            HomeTab()
                .tabItem {
                    Label {
                        Text("Quran")
                    } icon: {
                        Image(systemName: "book.closed.fill")
                    }
                }
                .tag(1)
                .toolbar(.hidden, for: .tabBar)

            ExploreTab()
                .tabItem {
                    Label {
                        Text("Explore")
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
                .tag(2)
                .toolbar(.hidden, for: .tabBar)

            ProgressTab()
                .tabItem {
                    Label {
                        Text("Progress")
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
                        Text("Journey")
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
