# The Arbaeen Journey - "The Return"

Date: 2026-07-01

## What it is

A new seasonal Journey for **Safar**, and the direct sequel to the Muharram Journey
(which ends at Ashura / day 10). It walks the **forty days between Ashura and Arbaeen**
(11 Muharram → 20 Safar) as **8 stations**, following the caravan of survivors -
Sayyida Zaynab (AS), Imam al-Sajjad (AS), the children - from the ruins of Karbala
through Kufa and Damascus and back, closing on **Jabir ibn ʿAbdullah al-Ansari** at the
grave on the 40th day and the **Ziyarat of Arbaeen**.

It is a **mourning ("Observed")** journey, cloning the Muharram/Fatimiyya variant: no
badges, "Observed" wording, subdued treatment. It carries a thread of *vindication* -
the message of Karbala surviving through Zaynab's and Sajjad's voices - but the register
stays elegiac.

Design was validated against a full emerald-theme mockup: `mockups/arbaeen-journey/`
(`arbaeen.html` / `arbaeen.png`).

## Decisions

These are the four calls surfaced during design. Marked **(confirm)** where I want the
user's explicit sign-off in spec review; the rest follow the approved mockup.

1. **"Station", not "Day".** The 8 units span 40 real days, so "Day 8" would mislead.
   Label them *Station N*. (Other journeys say "Day N"; this one legitimately differs.)
2. **Finale devotional - full text, not excerpt. (confirm)** The mockup showed the
   Ziyarat of Arbaeen as an excerpt + "Read full". Recommendation: **embed the full
   Ziyarat of Arbaeen** on Station 8 (with the Listen control), because it is *the* text
   of the day and users will want to recite the whole of it. Other stations use shorter
   devotional excerpts; Station 8 is intentionally the long, culminating one.
3. **Station 6 (the Damascus prison) - sober, source-led. (confirm)** The popular
   Sayyida Ruqayya (Sakina) prison-death episode is from the *later* maqtal tradition
   (e.g. *Kamil al-Bahaʾi*, 7th c. AH), not the earliest sources. Recommendation: keep
   the station, anchored on the **well-documented captivity and collective grief** of the
   Ahlul Bayt in Sham; treat Ruqayya only if we can cite it honestly (framed as "narrated
   in the mourning tradition"), otherwise leave it implicit rather than assert weak
   history as fact. Final call after the research pass.
4. **Tone.** Mourning first, with a restrained note of vindication (sovereignty belongs
   to God; the truth outlived the throne). Confirmed by the mockup.

## The 8 stations (content map + research brief)

Each station gets the standard journey "day" shape (see Schema). Below: the historical
beat, the **primary sources** to draw from, a **devotional anchor** candidate (the
dua/ziyarat), **verse** candidates (with the real Qurʾanic connection), and the theme.
Devotional Arabic and final verse picks are *verified against sources during authoring* -
these are the researched starting points, not yet the final text.

**Sourcing note:** the devotional anchors lean deliberately on **al-Sahifa al-Sajjadiyya**
(the supplications of Imam al-Sajjad, the living thread of this journey - impeccably
sourced) and the canonical ziyarat, rather than inventing prayers to fit scenes.

### 1. The Morning After - Karbala, 11 Muharram
- **Event:** dawn after Ashura; martyrs unburied, tents burned, the survivors taken
  captive; Zaynab's farewell over Husayn's body; the caravan driven past the fallen.
- **Sources:** al-Luhuf (Ibn Tawus); Bihar al-Anwar v45 (Majlisi); Maqtal al-Husayn (Muqarram).
- **Devotional anchor:** an excerpt of **Ziyarat al-Nahiya al-Muqaddasa** (the lament for
  the martyrs) *or* a Sahifa passage of submission (tafwid). 
- **Verses:** **2:155-157** (the trial of loss; *inna lillahi wa inna ilayhi rajiʿun*).
- **Theme:** the mission passes from the martyr to the survivors; bearing the unbearable.

### 2. The Road to Kufa - bearing witness
- **Event:** the captives driven toward Kufa, heads carried ahead on spears; the ailing
  Sajjad in chains.
- **Sources:** al-Luhuf; Bihar v45.
- **Devotional anchor:** Sahifa al-Sajjadiyya **Duʿa 22** (on hardship / when distressed).
- **Verses:** **14:42** ("do not think God unaware of what the wrongdoers do").
- **Theme:** witnessing when silence would be easier.

### 3. Kufa: The Voice That Would Not Break - Zaynab's sermon
- **Event:** entry into Kufa; **Zaynab's sermon** silences the city; before Ibn Ziyad,
  *"I saw nothing but beauty" (mā raʾaytu illā jamīlā)*; Sajjad's rejoinder.
- **Sources:** al-Ihtijaj (Tabarsi) for the sermon texts; al-Luhuf; Bihar v45.
- **Devotional anchor:** Zaynab's words are *khutba*, not duʿa - anchor with a short
  Sahifa munajat on steadfast truth, and quote the sermon in the tafsir/reflection.
- **Verses:** **16:92** ("*like her who unravelled her yarn*") - the exact image Zaynab
  drew from the Qurʾan to indict Kufa's broken loyalty.
- **Theme:** speech as resistance; victory inside captivity.

### 4. The Long Road to Sham - endurance
- **Event:** the weeks-long march Kufa → Damascus with captives and heads; desert
  hardship, hunger, exposure.
- **Sources:** al-Luhuf; Bihar v45; Muqarram.
- **Devotional anchor:** Sahifa al-Sajjadiyya **Duʿa 7** (in worry and distress) - the
  Imam who actually walked this road.
- **Verses:** **2:214** ("did you suppose you would enter the Garden without the trial…").
- **Theme:** endurance as worship.

### 5. The Court of Yazid - Damascus
- **Event:** the captives in Yazid's court; his cane at Husayn's lips (Abu Barza's
  rebuke); **Zaynab's sermon before the throne**; **Sajjad's sermon** from the pulpit
  introducing the Ahlul Bayt to Sham.
- **Sources:** al-Ihtijaj (both sermons); al-Luhuf; Bihar v45.
- **Devotional anchor:** a Sahifa passage on ʿizza/tawhid; quote Sajjad's introduction in
  the body.
- **Verses:** **3:26** (*"Malik al-Mulk"* - You give and strip sovereignty; the throne is
  transient) and/or **42:23** (*mawadda fi'l-qurba* - the love owed the kin, which Sajjad
  invoked in Sham).
- **Theme:** truth to power; sovereignty belongs to God; the Imamate preserved.

### 6. The Prison of Sham - the depth of the sorrow
- **Event:** the captivity in a ruin/prison in Damascus; the majalis of mourning; Sham's
  people slowly turning. (Ruqayya - see Decision 3.)
- **Sources:** al-Luhuf; Bihar v45. (Ruqayya episode: later tradition, handled per Decision 3.)
- **Devotional anchor:** a duʿa of grief entrusted to God (Sahifa; or Yaʿqub's words below).
- **Verses:** **12:86** (*"I complain of my grief and sorrow only to God"*).
- **Theme:** sorrow turned toward God, not despair.

### 7. The Turn Homeward - return as covenant
- **Event:** Yazid, facing public revulsion, releases them; they choose the road back
  **via Karbala**; the messenger to Medina.
- **Sources:** al-Luhuf; Bihar v45.
- **Devotional anchor:** Sahifa passage of deliverance/shukr amid grief.
- **Verses:** **21:88** ("We answered him and saved him from grief") *or* **65:2-3**
  ("whoever is mindful of God, He makes a way out").
- **Theme:** deliverance; the covenant that pulls them back to the grave.

### 8. Arbaeen: Jabir at the Grave - Karbala, 20 Safar
- **Event:** **Jabir ibn ʿAbdullah al-Ansari** with **ʿAtiyya al-ʿAwfi** reaches Karbala
  on the 40th day - the **first ziyarat**: ghusl in the Euphrates, the salam, falling
  upon the grave; (in some accounts) the returning caravan meets him there.
- **Sources:** Bishara al-Mustafa (al-Tabari al-Imami) & Bihar for Jabir/ʿAtiyya; the
  **Ziyarat of Arbaeen** from Imam al-Sadiq via Safwan: Misbah al-Mutahajjid (Tusi),
  Tahdhib al-Ahkam, Iqbal al-Aʿmal (Ibn Tawus), Mafatih al-Jinan (Qummi).
- **Devotional anchor:** the **full Ziyarat of Arbaeen** (per Decision 2), with Listen.
- **Verses:** **3:169** ("never think those slain for God dead - they live") + **2:156**
  (*the return*).
- **Theme:** loyalty (*wafa*); the first pilgrim; the tradition that has never stopped.

## Research & sourcing standard

- **Primary Shia sources only for events:** al-Irshad (Mufid), al-Luhuf/al-Malhuf (Ibn
  Tawus), Bihar al-Anwar v44-45 (Majlisi), Maqtal al-Husayn (Muqarram), Nafas al-Mahmum
  & Muntaha al-Amal (Qummi). Sermons from al-Ihtijaj (Tabarsi).
- **Devotional texts** from their canonical collections (al-Sahifa al-Sajjadiyya;
  Mafatih al-Jinan; Misbah al-Mutahajjid). Arabic quoted **verbatim** from a reliable
  edition, never machine-generated; transliteration and translation done carefully.
- **Verses** must have a genuine tafsir/tradition connection (several above are actual
  Qurʾanic allusions the protagonists made). Relevance notes grounded in that link.
- **Disputed material** (e.g. Ruqayya) is either cited honestly with its status noted, or
  left out - never asserted as firm history. Same conservative bar as the app's other content.
- **Honorifics & register** consistent with the app (Imam al-Husayn (AS), Sayyida Zaynab
  (AS), etc.); mourning tone; no triumphalism.

## Schema (per station)

Clone the Fatimiyya shape (`QuranModels.swift:2069-2129`). `ArbaeenDay`:
`id, dayNumber (1-8), theme, themeArabic, icon (SF Symbol), dua: ArbaeenDua,
verses: [ArbaeenVerse], tafsirFocus, reflection` + Urdu twins
`themeUr, tafsirFocusUr, reflectionUr` + `localizedTheme/Tafsir/Reflection(_:)`.
- `ArbaeenDua`: `arabic, transliteration, english, source?, englishUr, sourceUr?`.
- `ArbaeenVerse`: `id, surahNumber, verseNumber, relevanceNote, relevanceNoteUr`
  (+ `verseReference`). Verse Arabic/translation is pulled live from `DataManager.quranData`.
- `ArbaeenJourneyProgress`: `observedDays: Set<Int>`, `lastObservedDate`, `year`.

**Every station is fully trilingual** (Arabic devotional verbatim; en + ur for all prose).
Content lives in `Thaqalayn/Data/arbaeen_journey.json` (`{ "days": [ …8… ] }`).

## Technical implementation (clone the Fatimiyya pattern)

New files (auto-added via `PBXFileSystemSynchronizedRootGroup` - no pbxproj edits):
- `Thaqalayn/Data/arbaeen_journey.json` - the 8 stations.
- `Thaqalayn/Services/ArbaeenJourneyManager.swift` - clone `FatimiyyaJourneyManager`
  (load JSON, `@MainActor`, `observedDays`, year-reset, **no badge awarding**).
- `Thaqalayn/Views/ArbaeenJourneyView.swift` - clone `FatimiyyaJourneyView` (list;
  legacy + `emeraldSections` paths; header + progress + rows; premium gating on rows).
- `Thaqalayn/Views/ArbaeenDayDetailView.swift` - clone `FatimiyyaDayDetailView` (both
  render paths; **`DuaListenButton(arabic:)`** after every devotional; all reading text
  `* readingSettings.scale`).

Modified files:
- `QuranModels.swift` - add the 5 Arbaeen structs (clone `:2069-2129`).
- `IslamicCalendarManager.swift` - add `isArbaeenSeason()`, `currentArbaeenStation()`,
  `arbaeenSeasonStatus()` (Safar logic; see below).
- `PremiumManager.swift` - `canAccessArbaeenStation(_:)` (Station 1 free, rest premium;
  clone the Muharram pattern `:186-191`).
- `JourneyCatalog.swift` - append a `JourneyDescriptor` (id `"arbaeen"`, eyebrow
  `"40-Day Journey"`, title `"Arbaeen"`, `contentStartMonth: 2`, sfSymbol `figure.walk`,
  destination `ArbaeenJourneyView()`, **`statusOverride`** for the cross-month window).
- `JourneyAnnouncements.swift` - append a `JourneyAnnouncement` row.
- `JourneyStrings.swift` - add Arbaeen title/eyebrow/englishTitle cases.

**No badges** (`BadgeType` untouched). No CloudKit schema change (progress is local
UserDefaults, same as the other journeys).

## Calendar & announcement logic

The season is the 40-day mourning window, not a single content month - so like Fatimiyya
it needs a `statusOverride`, and the "current station" is a **date→station bucketing**
across the 40 days (not a 1:1 day map).
- **Season window (active):** `(month == 1 && day >= 11) || (month == 2 && day <= 25)`
  - opens as the Muharram journey winds down (11 Muharram), through a grace tail after
  Arbaeen (25 Safar). Exact grace tuned in the plan.
- **`currentArbaeenStation()`:** bucket the 40-day span into 8 (e.g. S1 ≈ 11-13 Muharram
  … S8 = 20 Safar+). Exact buckets in the plan; before/after season it clamps to 1 / 8.
- **Announcement:** `JourneyAnnouncement(id: "arbaeen", …)` firing near the window open
  (lead-in ≈ 1 Safar to avoid stacking on Muharram's notification), `isWithinAnnounceWindow`
  excluding the post-Arbaeen tail. Exact lead-in date decided in the plan.

## Content production pipeline (quality-first, ≤2 agents at a time)

Per the project rule, **never more than two subagents concurrently**; fan-out batched in
waves of two.

1. **Research (wave of 2):** (a) the historical arc + event sourcing across the 8
   stations; (b) the devotional texts - verified Arabic + source for the Ziyarat of
   Arbaeen and the per-station Sahifa/ziyarat anchors, plus the Ruqayya sourcing question.
2. **Checkpoint:** I synthesize a per-station English draft (theme, devotional Arabic +
   translit + en, verses + relevance, tafsir focus, reflection) **with sources**, and
   **show the user the full English content + sources for approval before any translation**
   (mirrors the daily-challenge flow).
3. **Translate (wave of 2):** `urdu-translator` for all Urdu; `arabic-quality-checker`
   to vet the devotional Arabic (diacritics, fidelity). Verbatim Arabic never translated.
4. **Assemble & validate:** build `arbaeen_journey.json`; a `scripts/arbaeen/validate.py`
   (mirrors the Swift decode contract + trilingual completeness: 8 stations, ids unique,
   non-empty en/ur, Arabic present, valid surah/verse refs).
5. **Build the Swift** (models → manager → views → wiring), then verify.

## Gates

- **Build:** `xcodebuild` (scheme `Thaqalayn`) succeeds; the app launches and the Arbaeen
  journey opens from the hub, a station renders (emerald + legacy), Listen works, reading
  scale affects the text. (Trust `xcodebuild` over SourceKit index warnings on new files.)
- **Data:** `scripts/arbaeen/validate.py` passes.
- **Content:** the English-content checkpoint (step 2) is approved by the user, and a
  final accuracy/sourcing/tone review pass before assembly.
- No XCTest (project convention). Design doc saved here; **not committed** (user commits).

## Open questions for the user

1. **Finale devotional:** embed the **full** Ziyarat of Arbaeen on Station 8 (my rec), or
   keep the excerpt + "Read full" from the mockup?
2. **Station 6 / Ruqayya:** sober-and-source-led (my rec), or lean into the popular
   Ruqayya narrative, or drop Station 6 to make a 7-station journey?
3. Anything in the **8-station spine, sources, or verse picks** you want changed before I
   start the research and content?
