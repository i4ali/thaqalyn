# Daily Reflection Widget - Design

Date: 2026-08-11
Status: Approved. SUPERSEDED IN PART by `2026-08-11-widget-reflection-content-design.md`
(content redesign: titles/teasers on non-prayer beats replaced by authored anchored
reflections; beat structure, prayer beats, and deep links here remain accurate).
Visual proposal: presented and iterated in-session (mockups of all widget states)

## Goal

A home-screen widget that delivers daily value on the home screen, pulls users into the app frequently, and feeds conversion - without being the verse-of-the-day widget every other Qur'an app ships. The widget's identity: **the verse is the surface, the gems are the depth.**

## Locked decisions

1. **Deliver value + tease depth.** The widget shows one complete, readable thought every beat. The tap is earned by curiosity, never by withholding content.
2. **Global daily, for everyone.** One shared daily verse and its gems, computed from bundled data. No personal state on the widget - no streaks, no journey counters, no resume points, ever.
3. **Free widget, premium destinations.** Everything shown on the widget is free to read. Tap-throughs land where the app's existing premium machinery lives. **No premium signal ever appears on the widget UI** - no chip, no lock, no pricing.
4. **Scope: the reflection and the prayer beats. Nothing else.** No widget suite, no habit dashboard, no interactive widgets, no personal strips. One widget, done completely.

## The widget family

One widget kind, four surfaces, all in the Midnight Emerald visual style:

- **Small**: Arabic theme word, English theme, verse reference.
- **Medium (hero)**: gem chip (the concept's own title, e.g. "Beyond Measure"), verse translation, the gem's core insight, concept dots (one per gem on today's verse; the lit dot advances through the day), Thaqalayn wordmark.
- **Large**: medium plus the Arabic verse line. On doorway evenings, the main line is the experience's catalog hook plus a tease row ("Inside the Surah: al-Tawba >").
- **Lock screen accessories**: (a) Hijri date + theme word; (b) next prayer + time.

## The unfolding day

A WidgetKit timeline of ~10 precomputed entries per day. One verse anchors the whole day; its 3-4 gems map onto the day's beats:

| Beat | When | Shows |
|---|---|---|
| Fajr | adhan time | Prayer beat (holds until sunrise) |
| The verse | sunrise | Arabic + translation |
| Zohr | adhan time | Prayer beat (~45 min) |
| First gem | Zohr + 45 min | One concept revealed |
| Asr | adhan time | Prayer beat (~45 min) |
| Next gem | Asr + 45 min | Lit dot advances |
| Maghrib | adhan time | Prayer beat (~45 min) |
| Go deeper | Maghrib + 45 min | Last gem, or the doorway on doorway days |
| Isha | adhan time | Prayer beat (~45 min) |
| Night | Isha + 45 min | Quiet close, until Fajr |

- **Doorway days**: when the daily verse falls in one of the 18 surahs with an Inside-the-Surah experience, or maps to a deep dive theme, the evening beat becomes a doorway using the experience's existing one-line catalog subtitle. Zero new copy.
- **Sacred days**: the daily verse engine already honors 19 Hijri sacred days (Ashura -> 3:169 etc.); the widget inherits them automatically.
- Everything is computed locally a full day ahead: zero network, zero battery cost, entries render at their exact minute.

## Prayer beats

- **Shia (Ja'fari) timings.** Default calculation: Tehran Institute of Geophysics method (Fajr 17.7 degrees, Maghrib 4.5 degrees after sunset, Isha 14 degrees). Calculation method becomes a Settings choice later.
- **Engine**: the `adhan-swift` package (ships the Tehran method) or a small self-contained solar calculator. Local and offline.
- **Content**: each prayer beat shows the prayer name, the time, and one rotating salah line - a hadith-sized thought about prayer from a curated pool of ~100 lines (the only new content this feature requires).
- **Location**: asked once in the app (the `Info.plist` permission string for prayer times already exists and was never wired). Coordinates + timezone are cached to the App Group; the widget computes times for any date from the cache.
- **No location / permission denied**: prayer beats are simply omitted; the reflection beats carry the day. The widget must be fully functional without location.

## Content sources (zero new authoring except salah lines)

| Content | Source | Status |
|---|---|---|
| Daily verse cycle | `DailyVerseProvider` - pure function of the date, reused verbatim | Exists |
| Verse text (Arabic + translation) | `quran_data.json`, hydrated at build time | Exists |
| Gems (chip title + insight line) | `quickOverview.concepts[]` in `tafsir_N.json` - verified **384/384** coverage across the daily pool (365 verses + 19 sacred days) | Exists |
| Doorway copy | `SurahExperienceCatalog` / `DeepDiveCatalog` subtitles | Exists |
| Salah lines | New curated pool, ~100 lines | **To author** |

**`widget_daily.json`**: a build-time script hydrates the 384 pool verses (Arabic, translation, theme, gems, doorway copy) into one bundled file so the widget target does not bundle `quran_data.json` or the 114 tafsir files. The script validates 384/384 gem coverage and fails the build if hydration is incomplete.

## Architecture

- **New target**: `ThaqalaynWidgets` extension (iOS 18.2, WidgetKit + SwiftUI). Bundle id `MAHR.Partner.Thaqalayn.ThaqalaynWidgets`.
- **App Group**: `group.MAHR.Partner.Thaqalayn` on app + extension. Carries **only** the cached location (coordinates + timezone) for prayer times. No other state, ever.
- **Shared code**: `DailyVerseProvider` (and the small models it needs) gain widget target membership; logic unchanged.
- **Timeline provider**: after midnight (device time), generate the day's ~10 entries (plus a margin into the next day). Prayer beats at computed adhan minutes; content beats at their offsets.
- **Deep links**: extend `thaqalayn://` URL parsing beyond the Supabase auth callback. Widget taps route via the existing `DeepLinkRouter`: gem beats open the verse's gems, doorway beats open the experience/dive, prayer beats open the app (Today tab).
- **Premium**: no gating logic in the widget at all. Gating stays in-app where it already lives (`PremiumManager` + `PaywallView`).

## Edge cases

- **First run before the app ever opened**: bundled data covers everything except prayer times; widget shows reflection beats only.
- **Timezone travel**: compute with cached coordinates and the device's current timezone; times refresh on the next timeline reload.
- **Widget gallery preview**: render a representative gem-day snapshot from the bundled data.
- **Ramadan and DST boundaries**: covered by computing per-date from the solar engine; no cached times across days.

## Non-goals (explicitly cut)

- Personal state of any kind (streaks, journey progress, continue-reading, premium status display)
- Widget suite / multiple widget kinds
- Interactive widgets (AppIntent buttons), StandBy/Control Center variants
- Commitment Calendar integration
- Any premium/pricing signal on the widget UI

## Testing

- Unit tests: prayer time calculation against known published values for 2-3 cities and dates; timeline entry generation (deterministic per date + location); gem/doorway selection parity with `DailyVerseProvider`'s verse for the same date.
- Build-time: `widget_daily.json` generation script asserts 384/384 hydration.
- Device pass: all four surfaces, sacred-day rendering, no-location fallback, deep links landing on the right screens.
