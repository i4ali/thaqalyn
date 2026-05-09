# Light Regression Pass — manual

**Phase E** of the dark-theme rollout. Set Settings → Appearance → Light. For each screen, compare visually against the *current production build* (or the last commit before this branch's dark-theme work began — `badbfb3` on `main`). Flag any visual shift in light mode.

The goal: zero regressions in light. If anything looks different from before this work, it's a bug — fix without touching dark.

## Known light-mode additions to verify

These are deliberate additions during the dark theme rollout that may show up subtly in light mode:

1. **Card stroke hairlines.** `WarmCardStyleModifier`, `WarmStatCardStyleModifier`, and the inline card refactors (ModernSurahCard, StatCard, BookmarkBadge, search bars, carousel cards, every screen's card list) now have a `themeManager.strokeColor` overlay border in BOTH modes. In light, that's `(0.176, 0.145, 0.125).opacity(0.10)` — a faint warm-charcoal hairline. **Verify cards don't look "outlined" or "boxed-in" compared to the prior shadow-only style.** If too prominent, either lower the opacity or gate the overlay to dark only.

## Screens (compare to pre-branch baseline)

- [ ] HomeTab (surah list)
- [ ] TodayTab
- [ ] ExploreTab
- [ ] ProgressTab
- [ ] SurahDetailView (open Al-Fatiha)
- [ ] QuickOverviewView
- [ ] FullScreenCommentaryView
- [ ] TafsirSourcesView
- [ ] VerseSummaryView
- [ ] SurahAudioPlayerView (start playback)
- [ ] AhlulbaytQuranView
- [ ] AhlulbaytEntryDetailView
- [ ] DuasView
- [ ] DuaDetailView
- [ ] QuestionsView
- [ ] QuestionDetailView
- [ ] PropheticStoriesView
- [ ] StoryDetailView
- [ ] LifeMomentsView
- [ ] PropheticParallelsView
- [ ] ParallelDetailView
- [ ] FastingVersesView
- [ ] FastingCategoryDetailView
- [ ] RamadanJourneyView
- [ ] RamadanDayDetailView
- [ ] QuizView
- [ ] QuizResultsView
- [ ] BookmarksView
- [ ] NotificationsView
- [ ] AuthenticationView
- [ ] AccountDeletionView
- [ ] PaywallView
- [ ] SettingsView
- [ ] WelcomeView
- [ ] OnboardingFlowView
- [ ] BadgeAwardView
- [ ] TTSVoicePickerView
- [ ] ProfileMenuView
- [ ] AudioSettingsView

## Likely diff sources to look for

- Any view where `themeManager.colorScheme` previously returned `.light` always but now returns `.dark` — this should ONLY happen when the user has explicitly chosen Dark in Settings.
- Cards rendered without their original Color.white fill — verify ContentView's StatCard/ModernSurahCard/BookmarkBadge/SurahListView search bar still look white in light.
- AdaptiveModernBackground — compare gradient stops to baseline.
- ProgressRingsView rings — colors moved from hardcoded hex to `semanticRed/Green/Blue/Yellow`. Verify ring hues are visually identical in light.
- Toast (SyncStatusToast) was reverted to `Color.black.opacity(0.3)` overlay; verify toast still looks correct in light.

## Issues found

_(Fill in as you walk. Use format `<screen>: <issue> — <proposed fix>`.)_
