# Dark Verification Pass — manual

**Phase D** of the dark-theme rollout. Set Settings → Appearance → Dark, then walk every screen on iPhone 16 Pro (iOS 18.6) Simulator. For each row, write `OK` or a short bug note (e.g. `BookmarksView: empty-state illustration is too dark — needs lighter tint`).

For each screen, check: warm-black background, peach accent, glass cards readable, Arabic legible, no light flashes, no white-on-white text, no broken contrast.

## Screens

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
- [ ] RamadanJourneyView (only visible in Ramadan season — temporarily force on if needed)
- [ ] RamadanDayDetailView
- [ ] QuizView (start a quiz)
- [ ] QuizResultsView (finish a quiz)
- [ ] BookmarksView
- [ ] NotificationsView
- [ ] AuthenticationView (sign out to see)
- [ ] AccountDeletionView
- [ ] PaywallView
- [ ] SettingsView
- [ ] WelcomeView
- [ ] OnboardingFlowView (reset hasShownWelcome to retrigger)
- [ ] BadgeAwardView (complete a verse to trigger)
- [ ] TTSVoicePickerView (Settings → TTS voice)
- [ ] ProfileMenuView (sheet from avatar)
- [ ] AudioSettingsView
- [ ] System sheets (Picker, Toggle in Settings)
- [ ] System alerts (Sign Out confirmation)

## Pre-flagged checks from implementation

- **TodayTab StreakBadge / HijriDatePill** — verify peach number color reads on warm-black.
- **ContinueReadingHero in TodayTab** — peach `resumeBackground` button with white text in dark.
- **ContentView LoadingView** — initial launch with deferred theme: confirm "ثقلين" hero shadow uses peach in dark.
- **SurahDetailView ModernVerseCard** — active "Now Reading" verse should have peach gradient overlay only when dark, with peach text-shadow on the Arabic.
- **HighlightedText search highlight** — yellow at 30% opacity in dark vs 50% in light; verify it's visible but not garish.
- **BadgeAwardView ConfettiPiece** — uses `floatingOrbColors` palette in dark (raw orb opacity is low, e.g. 0.06 for green); confirm confetti dots render bright (not nearly invisible).
- **PaywallView background orbs** + new aura — watch for double-glow stacking visually.
- **Quiz answer cards** — green/red feedback uses `semanticGreen`/`semanticRed`; verify still legible on dark glass.
- **NotificationCard** — refactored from Material to `glassSurface` Color in dark; confirm cards stand out from background.
- **ModernSurahCard surah-number badge** — gradient still hardcoded sunset orange (peach in T1's note); reads on dark glass card.

## Issues found

_(Fill in as you walk. Use the format `<screen>: <issue>` and any fix proposed.)_
