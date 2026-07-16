# Ṣabr Deep Dive - Design Spec

**Date:** 2026-07-06
**Status:** Implemented 2026-07-06 (built directly from this spec; `xcodebuild` BUILD SUCCEEDED). Files: `Thaqalayn/Content/SabrDeepDive.swift` (new), `DeepDiveCatalog.swift` (catalog flip), `WhatsNewItem.swift` (announcement).
**Feature:** The second immersive "Deep Dive" (after Yaqīn), on **Ṣabr** (patience), shown in the Journeys tab.

---

## 1. Summary & Goal

Ship **Ṣabr** as the second Deep Dive: an immersive, single-sitting, scroll-snap "descent" through three stations of the patient heart, culminating at Karbalāʾ. It reuses the existing, finished `DeepDiveView` engine verbatim. Structurally it mirrors the Yaqīn dive (same ~14-beat shape, same three-movement stepper), but every piece of content is **fresh** - no material is reused from Yaqīn.

**Spine (chosen: "Stations of the Heart"):** an ascending interior ladder, the closest formal mirror of Yaqīn's three depths.

- **Movement I - al-Ṣabr (الصَّبْر) - "The Enduring":** to bear the decree without breaking, and complain of it to God alone.
- **Movement II - al-Riḍā (الرِّضَا) - "The Accepting":** to stop wishing the decree were otherwise and be pleased with it.
- **Movement III - al-Nafs al-Muṭmaʾinna (النَّفْس المُطْمَئِنَّة) - "The Soul at Peace":** to return to God serene in the very loss, pleased and pleasing -> Karbalāʾ.

**Quiet through-line:** the descent opens with *"to Him we return"* (al-Baqarah 2:156) and its summit is *"return to your Lord"* (al-Fajr 89:27). Patience framed as a homecoming.

---

## 2. Architecture - why this is a content-only change

The Deep Dive engine is complete and fully data-driven. `DeepDiveView` renders every `DeepDiveSection` case generically; audio (`VerseRecitationButton` for āyāt, `DuaListenButton`/TTS for the duʿā), reading-text scaling, the descent background, the movement stepper, and the reflection prompt are all already implemented and were validated on the Yaqīn dive.

Therefore this feature is:

1. **Create** `Thaqalayn/Content/SabrDeepDive.swift` - `extension DeepDive { static let sabr }` (all content below).
2. **Modify** `Thaqalayn/Services/DeepDiveCatalog.swift` - flip the existing `sabr` entry from `available: false, dive: nil` to `available: true, dive: .sabr`, and refresh its subtitle.

No new model cases, no renderer changes, no view changes, no strings, no `.pbxproj` edits (Xcode synced folders pick up the new file).

---

## 3. Global constraints

- **No em dashes** anywhere in copy. Use a spaced hyphen `" - "` (as Yaqīn does).
- **Voice register matches Yaqīn exactly:** spare, literary narrative prose. Names appear without parenthetical honorifics in the immersive body text (e.g. "Ḥusayn", "Yaʿqūb", "Ayyūb"), consistent with the existing Yaqīn content. Diacritics on transliterations. Typographic apostrophe in "Qur'an".
- **Reading-scale, Listen, and recitation are handled by the engine** - content only supplies the strings/refs. The closing duʿā automatically gets `DuaListenButton` (TTS); each `verse`/bridge āyah automatically gets real recitation via `VerseRecitationButton(surah, ayah)`, so every verse beat is anchored on a **single** āyah.
- **Sourcing integrity:** no fabricated attributions. Section 6 lists every Arabic item, its source, and what must be finalized during implementation.
- **Three-movement structure is required** by the engine (`placeInfo`, `romans[a]`, the stepper assume acts 1-3, with `open`/`orientation` = act 0 and `reflectionPrompt`/`dua` = act 4).

---

## 4. Metadata (`DeepDive.sabr`)

| Field | Value |
|-------|-------|
| `id` | `"sabr"` |
| `titleEn` | `"Ṣabr"` |
| `titleAr` | `"صَبْر"` |
| `subtitle` | `"Patience - a descent through three stations"` |
| `sfSymbol` | `"hourglass"` (unchanged from catalog) |
| `estMinutes` | `5` |

**`acts`:**

| # | `ar` | `tr` | `name` |
|---|------|------|--------|
| 1 | الصَّبْر | al-Ṣabr | The Enduring |
| 2 | الرِّضَا | al-Riḍā | The Accepting |
| 3 | النَّفْس المُطْمَئِنَّة | al-Nafs al-Muṭmaʾinna | The Soul at Peace |

---

## 5. Full content (source of truth for transcription)

14 beats, in order.

### 01 - `open`
- **kicker:** `A DEEP DIVE`
- **titleAr:** صَبْر
- **titleEn:** Ṣabr
- **subtitle:** Patience
- **line:** A descent through the Qur'an and the Ahl al-Bayt - through three stations of the patient heart.

### 02 - `orientation`
- **eyebrow:** Before you descend
- **promise:** Three stations of the heart lie below - to endure the decree, to accept it, and to find peace within it.
- **leaveWith:** You'll leave with a map of patience - and a prayer to carry you through your own trial.

### 03 - `act` (Movement I card)
- **act:** 1 · **connector:** nil · **bridge:** nil
- **line:** It begins with the clenched heart. Before patience can become contentment, it is simply this: to hold firm, to restrain the self, to bear what has come - and to carry the grief to God alone.

### 04 - `verse` - al-Baqarah 2:156
- **act:** 1 · **tag:** Those Who Return · **surah/ayah:** 2 : 156
- **arabic:** الَّذِينَ إِذَا أَصَابَتْهُم مُّصِيبَةٌ قَالُوا إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ
- **translation:** "Those who, when calamity strikes them, say: Indeed we belong to God, and indeed to Him we return."
- **reference:** al-Baqarah · 2 : 156
- **reflection:** This is the first breath of patience - not that the blow does not land, but that the heart, even as it breaks, remembers where it is going. To Him we belong; to Him we return.

### 05 - `depths` - "The Three Stations"
- **act:** 1 · **tag:** The Three Stations · **reference:** al-Kāfī · al-Fajr 89:27
- **items:**
  1. **ar:** الصَّبْر · **tr:** al-Ṣabr · **label:** The Enduring · **desc:** To bear the decree without breaking - and to complain of it to God alone. · **reference:** nil · **embodies:** the heart that holds firm
  2. **ar:** الرِّضَا · **tr:** al-Riḍā · **label:** The Accepting · **desc:** To stop wishing the decree were otherwise - and be pleased with it. · **reference:** nil · **embodies:** the soul that yields
  3. **ar:** النَّفْس المُطْمَئِنَّة · **tr:** al-Nafs al-Muṭmaʾinna · **label:** The Soul at Peace · **desc:** To return to God serene in the very loss - pleased, and pleasing to Him. · **reference:** 89:27 · **embodies:** the family who bore it

### 06 - `verse` - Yūsuf 12:86 (Yaʿqūb)
- **act:** 1 · **tag:** The Beautiful Patience · **surah/ayah:** 12 : 86
- **arabic:** قَالَ إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ
- **translation:** "He said: I complain of my anguish and my grief only to God."
- **reference:** Yūsuf · 12 : 86
- **reflection:** Yaʿqūb wept for Yūsuf until the light left his eyes - yet in all those years he laid his grief before no one but God. This is ṣabrun jamīl, beautiful patience: not a heart that does not ache, but a grief carried to the right door.

### 07 - `act` (Movement II card)
- **act:** 2 · **connector:** You have learned to endure the decree. · **bridge:** nil
- **line:** Now - accept it. Riḍā is the station past endurance: not merely to bear God's will, but to be pleased with it - to stop wishing the decree were other than it is.

### 08 - `verse` - al-Ṣāffāt 37:102 (Ismāʿīl)
- **act:** 2 · **tag:** The Willing Son · **surah/ayah:** 37 : 102
- **arabic:** قَالَ يَا أَبَتِ افْعَلْ مَا تُؤْمَرُ ۖ سَتَجِدُنِي إِن شَاءَ اللَّهُ مِنَ الصَّابِرِينَ
- **translation:** "He said: O my father, do as you are commanded. You will find me, if God wills, among the patient."
- **reference:** al-Ṣāffāt · 37 : 102
- **reflection:** The son does not merely submit to the knife - he urges his father toward the command, and names himself patient before the trial has even begun. This is the leap from ṣabr to riḍā: from "I will bear it" to "do as you are commanded."

### 09 - `verse` - Ṣād 38:44 (Ayyūb)
- **act:** 2 · **tag:** The Excellent Servant · **surah/ayah:** 38 : 44
- **arabic:** إِنَّا وَجَدْنَاهُ صَابِرًا ۚ نِّعْمَ الْعَبْدُ ۖ إِنَّهُ أَوَّابٌ
- **translation:** "Indeed We found him patient - an excellent servant. Truly he turned ever back to Us."
- **reference:** Ṣād · 38 : 44
- **reflection:** Stripped of his health, his wealth, his children, Ayyūb never once resented his Lord - he only turned back to Him, and back again. And so God Himself names him: an excellent servant. Riḍā is what turns loss into nearness.

### 10 - `act` (Movement III card + bridge) - al-Fajr 89:27-28
- **act:** 3 · **connector:** You have learned to accept it.
- **line:** Now - the summit. Where patience has become peace, and the soul, stripped of everything, returns to its Lord not broken but serene - pleased, and pleasing to Him.
- **bridge:** surah/ayah **89 : 27** ·
  - **arabic:** يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً
  - **translation:** "O tranquil soul, return to your Lord, pleased and pleasing."
  - **reference:** al-Fajr · 89 : 27-28

### 11 - `narration` - The Last Night
- **act:** 3 · **tag:** The Last Night
- **source:** The night before ʿĀshūrāʾ - al-Irshād of al-Mufīd
- **body:** On the last night, Ḥusayn gathered those with him and lifted his oath from their shoulders: the darkness is a curtain - take it, and go; they want no one but me. Not one of them left. And they passed that night in prayer, standing and bowing, their voices murmuring low - like the humming of bees.
- **reflection:** This is riḍā made visible. Not people trapped into patience, but people who chose it with open eyes, knowing the morning - and turned their last night on earth into worship.

### 12 - `climax` - The Last Prostration (Imam al-Ḥusayn)
- **act:** 3 · **tag:** The Last Prostration
- **source:** Imam al-Ḥusayn, in his final moments at Karbalāʾ - al-Luhūf of Ibn Ṭāwūs
- **arabic:** صَبْرًا عَلَىٰ قَضَائِكَ يَا رَبِّ، لَا إِلَٰهَ سِوَاكَ
- **translation:** "Patience upon Your decree, O my Lord. There is no god but You."
- **body:** Bereaved of every son and brother and companion, his body wounded past counting, he lowered his face to the earth of Karbalāʾ. No word of complaint left him - only surrender: patience with the decree, and there is no god but You.
- **reflection:** This is the summit - al-nafs al-muṭmaʾinna. Not that the loss had stopped wounding, but that the heart, in the very fire, had returned to its Lord: pleased, and pleasing. Patience had become peace.

### 13 - `reflectionPrompt`
- **tag:** Return
- **prompt:** What are you being asked to bear?

### 14 - `dua` - A Prayer in Trial (Imam Jaʿfar al-Ṣādiq)
- **tag:** A Prayer in Trial
- **intro:** After the prophets, after Karbalāʾ - one prayer, in the voice of the sixth Imam, that asks nothing but honesty about our own small patience.
- **arabic:** رَبِّ كَمْ مِنْ نِعْمَةٍ أَنْعَمْتَ بِهَا عَلَيَّ قَلَّ عِنْدَهَا شُكْرِي، وَكَمْ مِنْ بَلِيَّةٍ ابْتَلَيْتَنِي بِهَا قَلَّ لَكَ عِنْدَهَا صَبْرِي، فَيَا مَنْ قَلَّ عِنْدَ نِعْمَتِهِ شُكْرِي فَلَمْ يَحْرِمْنِي، وَيَا مَنْ قَلَّ عِنْدَ بَلِيَّتِهِ صَبْرِي فَلَمْ يَخْذُلْنِي
- **translation:** "My Lord - how many a blessing You gave me, and how little my thanks; how many a trial You tested me with, and how little my patience. O You who did not deprive me though my thanks was little, and did not forsake me though my patience was little."
- **source:** Imam Jaʿfar al-Ṣādiq · al-Amālī of al-Ṣadūq
- **note:** The towering patience of Karbalāʾ is not asked of you. Only this: to bear a little, to return to Him - and to trust that the One who never forsook the patient will not forsake you either.

---

## 6. Sourcing & verification

All content copy above is complete. The following exact-text/citation checks are **implementation-time verification steps** (mirroring the Yaqīn plan's Task 2), not open design questions:

| Item | Source | Status / action at implementation |
|------|--------|-----------------------------------|
| Āyāt 2:156, 12:86, 37:102, 38:44, 89:27-28 | Qur'an | Validate the Arabic strings **against the app's own `quran_data.json`** (in-repo source of truth) so the recitation refs and text agree. |
| Ḥusayn's last words (beat 12) | al-Luhūf (Ibn Ṭāwūs); maqtal tradition | Core line `صَبْرًا عَلَىٰ قَضَائِكَ يَا رَبِّ، لَا إِلَٰهَ سِوَاكَ` is attested. Confirm the fuller wording / exact citation; keep the beat to the attested core. |
| Imam al-Ṣādiq duʿā (beat 14) | al-Amālī of al-Ṣadūq; Biḥār al-Anwār 90:184-185 | First couplet (`رَبِّ كَمْ مِنْ نِعْمَةٍ… قَلَّ لَكَ عِنْدَهَا صَبْرِي`) confirmed verbatim (duas.org). Confirm the continuation (`فَيَا مَنْ… فَلَمْ يَخْذُلْنِي`) and finalize the citation. |
| The Last Night (beat 11) | al-Irshād (al-Mufīd); al-Ṭabarī | Scene (releasing the companions; worship "like the humming of bees") is well attested. Confirm phrasing/source line. |

**No content is reused from Yaqīn.** Explicitly avoided: Ibrāhīm (star/moon/sun, the fire, asking to see), the Mother of Mūsā, Zaynab's "I saw nothing but beauty", and al-Ṣaḥīfa al-Sajjādiyya #20 (Makārim al-Akhlāq). The muṭmaʾinna verse (89:27) is used once, as the Movement III bridge; the climax is Ḥusayn's own supplication, not that verse.

---

## 7. Catalog change (`DeepDiveCatalog.swift`)

Update the existing `sabr` descriptor:

- `subtitle`: `"Standing firm through trial"` -> `"A descent through three stations - Qur'an to Karbala"` (parallels the Yaqīn card).
- `available`: `false` -> `true`
- `dive`: `nil` -> `.sabr`

`id`, `eyebrow`, `titleEn` (`"Ṣabr · Patience"`), `titleAr` (`"صَبْر"`), `sfSymbol` (`"hourglass"`) stay as they are. The `tawakkul` entry stays a `available: false` placeholder.

---

## 8. Out of scope / non-goals

- No engine, renderer, model, or string changes.
- No new audio assets (duʿā is TTS; āyāt use existing recitation).
- Tawakkul (the third dive) is not built here; it remains a "coming soon" card.
- No persistence/sync of the reflection-prompt text (local-only, exactly as Yaqīn).
