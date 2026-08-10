# al-Kisa - Under the Cloak: design doc

**Date**: 2026-08-09 · **Status**: approved and implemented; four-auditor audit run and ALL
findings applied 2026-08-09 (none declined). §5 below is the post-audit copy - the single
source of truth. The mock (`docs/mockups/kisa_mock.html/.png`) shows the pre-audit draft
and is kept as a design-stage snapshot only.

## 1. Summary / identity

The eighth deep dive and the series' **first event dive**: not a virtue descended through,
but a story entered - Hadith al-Kisa, the Tradition of the Cloak. Spine: **three widening
circles around one cloak** - the house (al-Bayt), the five (al-Khamsa), the gathering
(al-Mahfil). The cloak widens from a sickbed cover over one tired man, to the shelter of
five, to the axis of creation, to a canopy over every gathering that retells the story -
including the reader's own reading.

Identity moves (each a series first):
1. **Fatima al-Zahra narrates.** Her first words anywhere in the series (she was present
   but silent in Salah's close and Ikhlas's summit - both design docs flagged the debt).
   Every story beat is sourced "Fatima al-Zahra · Hadith al-Kisa - Awalim al-Ulum".
   Her narration beats (05, 07, 08) hold one frame: first-person past, behind a light
   "she says" tag.
2. **The reader is inside the text.** The hadith blesses every gathering that retells it;
   beat 15's reflection turns the camera on the reader. The loop is spent ONLY there -
   the open and the threshold map deliberately withhold it (audit finding, applied).
3. **Everything descends toward a reader who stays still** - mercy, Jibra'il, the verse,
   the promise. Engine verbs follow (see §2). The movement connectors are third-person
   states ("The house is full." / "The verse has been delivered.") rather than the house
   second-person "You have..." - a declared deviation: in an event dive the reader
   witnesses; they have not yet done anything.
4. **Summit mid-dive** (climax in Circle II - "The Naming"): the story's cosmic peak is
   heaven naming the five; Circle III is the turn toward the reader. Deliberate deviation
   from the climax-in-act-3 house pattern; the hadith's own shape wins.
5. **First `response` beat whose `replyingTo` names a prayer, not a person** ("To the
   prayer raised beneath the cloak") - God's reply is announced across the heavens, to
   the angels, while the prayer it answers rose from the house.
6. **No Karbala anywhere** (second non-Karbala summit after Ikhlas; first dive with zero
   Karbala presence - declared, not accidental: the cloak's own story never leaves the house).
7. New interactive close **`salawat` - "The Five Names"**: a count that COMPLETES at
   exactly five - the meaning-inverse of Shukr's `count` (blessings cannot be counted;
   the beloved can). Spec in §4.

## 2. Engine chrome (DeepDive fields)

| Field | Value |
|---|---|
| id | `kisa` |
| titleEn / titleAr | `al-Kisa` / `الكِسَاء` |
| subtitle | `The Cloak - a gathering through three circles` |
| sfSymbol | `moon.stars.fill` |
| estMinutes | 5 |
| stageNoun / stageWord | `Circle` / `Circle` |
| descendCta | `Enter` |
| beginCta | `Enter the gathering` |
| mapLine | `One cloak. Three circles around it.` |
| endLine | `The gathering disperses.` |
| scrollHint / icon | `Scroll to draw nearer` / `arrow.down` |
| acts | 1 `البَيْت` al-Bayt "The House" · 2 `الخَمْسَة` al-Khamsa "The Five" · 3 `المَحْفِل` al-Mahfil "The Gathering" |

`endLine` is textual: the angels ask forgiveness for the gathering "until they part."
Close clause (in `.dua`): **"The promise is yours to keep."**

## 3. Architecture - 17 beats

| # | Beat | Act | Content |
|---|---|---|---|
| 01 | `open` | 0 | Cover |
| 02 | `orientation` | 0 | "Before you enter" |
| 03 | `depths` | 0 | The Three Circles map |
| 04 | `act` I | 1 | Circle I card |
| 05 | `narration` | 1 | The Weakness |
| 06 | `verse` | 1 | Yusuf 12:94 (excerpt) - The Fragrance |
| 07 | `narration` | 1 | The Arrivals |
| 08 | `act` II | 2 | Circle II card ("The house is full.") |
| 09 | `narration` | 2 | The Two Ends |
| 10 | `response` | 2 | He answers - the creation inventory, announced to the angels |
| 11 | `climax` | 2 | THE SUMMIT - The Naming |
| 12 | `verse` | 2 | al-Ahzab 33:33 (tathir clause excerpt) - What the Sixth Carried |
| 13 | `act` III | 3 | Circle III card ("The verse has been delivered."), no bridge |
| 14 | `verse` | 3 | al-Shura 42:23 (excerpt) - The Only Reward |
| 15 | `narration` | 3 | The Promise - the turn to the reader |
| 16 | `salawat` | 4 | NEW BEAT - The Five Names |
| 17 | `dua` | 4 | The Prayer of the Cloak + Amin |

Beat census for the guardrail grep: open 1 · orientation 1 · depths 1 · act 3 · verse 3 ·
narration 4 · response 1 · climax 1 · salawat 1 · dua 1.

## 4. New beat spec: `salawat` - "The Five Names"

**Meaning**: when the five are named, no gathering stays silent - it answers with
salawat. Five deliberate taps, one per name, in the order the cloak gathered them; on the
fifth the arc joins into one glow and resolves into the salawat formula. A count that
completes and rests - the declared meaning-inverse of Shukr's `count`.

**Model case** (`Thaqalayn/Models/DeepDive.swift`) - standard 8-field interactive shape:

```swift
case salawat(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
             arabic: String, translation: LocalizedText, reference: String,
             note: LocalizedText, nextLabel: LocalizedText)
```

`.salawat` is in the grouped `return 4` act mapping.

**Renderer** (`Thaqalayn/Views/DeepDive/DeepDiveView.swift`), following the
`extinguish`/`count` recipe:

- Fixed renderer data (EN-only literals; localization debt tracked with the dive's UR/AR
  pass): the five names in cloak order:
  `[("مُحَمَّد ﷺ", "Muhammad ﷺ"), ("الحَسَن", "Hasan"), ("الحُسَيْن", "Husayn"), ("عَلِيّ", "Ali"), ("فَاطِمَة", "Fatima")]`
- **Layout**: five lights on a low arc (cloak-edge curve); lit name label (Amiri Arabic +
  small EN caption) under each lit light.
- **Idle**: ✦ mark, serif prompt (fixed size), scaled italic subline, five dim lights,
  gold uppercased label `TAP EACH LIGHT - GREET THEM BY NAME`.
- **Active**: a tap anywhere on the arc field lights the NEXT unlit light in order (the
  order is enforced by the beat, not the finger - and the subline says so), `.soft`
  haptic per tap, prompt dims after the first; at four lit the label swaps to goldBright
  `ONE NAME REMAINS` (`.light` haptic at the turn).
- **Resolved** (fifth tap): `.success` haptic; the arc joins beneath the five lights on
  the radial goldBright background; glowing Arabic + translation + reference + hairline +
  note + `bob(nextLabel)`.
- **Accessibility**: `reduceMotion` honored (instant state swaps); reading scale on
  subline/note/translation only.
- **Reset**: `salawatLit = 0; salawatDone = false` in the Begin-again closure. No timers.
- **placeInfo**: `case .salawat(let tag, ...): return (tag(lang), dive.acts.count)`.

## 5. Full per-beat content (POST-AUDIT - transcription source of truth)

Implementers transcribe VERBATIM - never rewrite. Plain (non-Uthmani) orthography for
Qur'an Arabic; " - " never an em dash; curly quotes only inside quoted speech
(response `words`, climax/salawat/dua `translation`).

### 01 · open
- kicker: `A DEEP DIVE`
- titleAr: `الكِسَاء` · titleEn: `al-Kisa` · subtitle: `The Cloak`
- line: `One day in Madina, one cloak, five beneath it. The story is told by the Prophet's ﷺ own daughter, Fatima al-Zahra - and it ends in a promise to every gathering that retells it.`

### 02 · orientation
- eyebrow: `Before you enter`
- promise: `Three circles lie ahead - the house that gathered a family one by one, the five people God says creation itself was made for, and the gathering that has never ended.`
- leaveWith: `You'll leave inside the reach of a promise sworn beneath the cloak - and with the Prophet's ﷺ own prayer over his family, to keep.`

### 03 · depths (act 0)
- tag: `The Three Circles` · reference: `Hadith al-Kisa · Awalim al-Ulum`
- I: ar `البَيْت` tr `al-Bayt` label `The House` · desc `The Prophet ﷺ, feeling a weakness in his body, asks his daughter to cover him. Then, one by one, the family arrives - each met by a fragrance they know, each entering by permission.` · reference nil · embodies `the door love knocks on`
- II: ar `الخَمْسَة` tr `al-Khamsa` label `The Five` · desc `The two ends of the cloak lifted toward the sky - and heaven tells the angels why anything was made.` · reference nil · embodies `the family creation was made for`
- III: ar `المَحْفِل` tr `al-Mahfil` label `The Gathering` · desc `A promise sworn twice over: wherever this story is retold, mercy descends on the ones who tell it.` · reference `Awalim al-Ulum` · embodies `the circle that has never closed`

### 04 · act I (connector nil, bridge nil)
- line: `It begins with the smallest mercy a house knows. The Messenger of God ﷺ comes to his daughter's door - and what happened inside was kept for us in her voice. Everyone beneath that cloak could have told this story. The one who tells it is Fatima.`

### 05 · narration (act 1) - The Weakness
- tag: `The Weakness`
- source: `Fatima al-Zahra · Hadith al-Kisa - Awalim al-Ulum`
- body: `My father came to me, she says, and greeted me: peace be upon you, Fatima. Then he said: I feel in my body a weakness. Bring me the Yemeni cloak, and cover me with it. So I covered him - and as I did, I looked, and his face was shining beneath it like the full moon on its fullest night.`
- reflection: `The story opens with the Prophet ﷺ asking to be covered - the one the whole world leans on, asking his daughter for shelter. First the cloak is only that: warmth laid over a tired father. Heaven is about to make something immense of it - and it begins as the plainest kindness any house knows.`

### 06 · verse (act 1) - Yusuf 12:94, excerpt
- tag: `The Fragrance`
- surah 12, ayah 94
- arabic: `قَالَ أَبُوهُمْ إِنِّي لَأَجِدُ رِيحَ يُوسُفَ`
- translation: `[When the caravan set out,] their father said: truly, I find the fragrance of Yusuf.`
- reference: `Yusuf · 12 : 94`
- reflection: `Yusuf's brothers were carrying his shirt home when their father, far away, caught the scent of his lost son - love recognizes before sight does. Hold that. In this house, each one who now comes to the door will know, by a fragrance, who is beneath the cloak - before anyone says a word.`

### 07 · narration (act 1) - The Arrivals
- tag: `The Arrivals`
- source: `Fatima al-Zahra · Hadith al-Kisa - Awalim al-Ulum`
- body: `Within the hour, she says, Hasan was at the door. He greeted me - and then: mother, I smell a sweet fragrance here, like the fragrance of my grandfather, the Messenger of God. Yes, I told him - your grandfather is beneath the cloak. And he did not run to him. He stopped at the cloak's edge and asked permission to enter. My son, my father answered, master of my Fountain - I give you permission. Husayn came, and knew the same fragrance: my son, who will plead for my nation. Then Ali, my husband: my brother and my successor. Then I rose myself - and asked permission, in my own house, to sit beneath a cloak with my own family: my daughter, part of me. Each of us heard the same words: I give you permission.`
- reflection: `No one sent for them; each arrived on an ordinary errand, and a fragrance told them who was there. And at the edge of the cloak every one of them - the grandsons, the Commander of the Faithful, the daughter of the house - stopped and asked. Around this cloak, love and reverence are one motion: no one enters unasked.`

### 08 · act II
- connector: `The house is full.`
- line: `Five beneath one Yemeni cloak - a grandfather, his daughter, her husband, their two sons. Then, she says, my father took hold of the two ends of the cloak, and pointed with his right hand toward the sky.`
- bridge: nil

### 09 · narration (act 2) - The Two Ends
- tag: `The Two Ends`
- source: `The Messenger of God ﷺ, beneath the cloak · Hadith al-Kisa`
- body: `O God, he prays, these are the people of my house - my own and my nearest kin. Their flesh is my flesh and their blood is my blood; what pains them pains me, and what grieves them grieves me. They are of me, and I am of them. Then comes the plea the whole prayer has been rising toward: he asks God to remove every impurity from them, and to purify them completely.`
- reflection: `He binds five lives into one flesh, then lifts the whole of it upward - the two ends of the cloak raised like an offering. And hold on to the last words of that prayer. His will not be the last voice to say them.`

### 10 · response (act 2) - the creation inventory
- replyingTo: `To the prayer raised beneath the cloak`
- arabic: `مَا خَلَقْتُ سَمَاءً مَبْنِيَّةً وَلَا أَرْضًا مَدْحِيَّةً إِلَّا فِي مَحَبَّةِ هٰؤُلَاءِ الْخَمْسَةِ`
- words: `“O My angels, O dwellers of My heavens: I did not create a built sky, nor an outstretched earth, nor an illumined moon, nor a shining sun, nor a turning heaven, nor a flowing sea, nor a sailing ship - except for the love of these Five beneath the cloak.”`
- source: `His word to the angels · Hadith al-Kisa - Awalim al-Ulum`
- reflection: `The answer is not sent down to the house - it is announced across the heavens. He names creation piece by piece - sky, earth, moon, sun, sea - and gives every piece the same reason: love of these five. The sky you have lived your whole life under was raised for the five beneath that cloak.`

### 11 · climax (act 2) - THE SUMMIT - The Naming
- tag: `The Naming`
- source: `Hadith al-Kisa - Awalim al-Ulum`
- arabic: `هُمْ فَاطِمَةُ وَأَبُوهَا وَبَعْلُهَا وَبَنُوهَا`
- translation: `“They are Fatima, her father, her husband, and her sons.”`
- body: `The prayer beneath the cloak has scarcely ended when a question rises among the angels. It is Jibra'il who asks - the trusted angel who carries God's word down to His prophets: my Lord, who is beneath the cloak?`
- reflection: `Before the naming, God gives them a title: the household of prophethood, the wellspring of the message. Then the names - and every one leans on hers: her father, her husband, her sons. The one who kept this story for us is the one the answer is built around. Then Jibra'il asks what no angel has ever asked: permission to descend, to be the sixth of them. It is granted - and even he stops at the cloak's edge, as the children did, and asks again. He enters carrying a verse.`

### 12 · verse (act 2) - al-Ahzab 33:33, tathir clause (excerpt)
- tag: `What the Sixth Carried`
- surah 33, ayah 33 (recitation anchors the full ayah; displayed Arabic is the tathir clause - Sabr 12:86 / Shukr 14:7 excerpt precedent; the reflection discloses the address turn)
- arabic: `إِنَّمَا يُرِيدُ اللَّهُ لِيُذْهِبَ عَنكُمُ الرِّجْسَ أَهْلَ الْبَيْتِ وَيُطَهِّرَكُمْ تَطْهِيرًا`
- translation: `God only desires to remove all impurity from you, O People of the House, and to purify you, a thorough purifying.`
- reference: `al-Ahzab · 33 : 33`
- reflection: `The words he prayed beneath the cloak come back as revelation - now spoken as God's own desire. And the Arabic turns as it lands: the verses around this clause address the Prophet's ﷺ wives in the feminine; here it shifts to the masculine plural - the form the tradition hears as the five beneath the cloak. For months afterward, on his way to the dawn prayer, he would stop at Fatima's door and call: to prayer, O People of the House! - and recite this clause at the one door it named.`

### 13 · act III
- connector: `The verse has been delivered.`
- line: `Beneath the cloak one question remains, and it is Ali who asks it: O Messenger of God, what merit does this sitting of ours beneath one cloak have in the sight of God?`
- bridge: nil

### 14 · verse (act 3) - al-Shura 42:23, excerpt
- tag: `The Only Reward`
- surah 42, ayah 23
- arabic: `قُل لَّا أَسْأَلُكُمْ عَلَيْهِ أَجْرًا إِلَّا الْمَوَدَّةَ فِي الْقُرْبَىٰ`
- translation: `Say: I ask of you no reward for it - only love of the nearest kin.`
- reference: `al-Shura · 42 : 23`
- reflection: `Before the Prophet ﷺ answers, hold one verse beside Ali's question. For the whole weight of prophethood, one payment is named - not tribute, not rank: love of the nearest kin. The five beneath the cloak are that kin. And this love, as he is about to swear, is not a debt collected from you - it is a door opened to you.`

### 15 · narration (act 3) - The Promise
- tag: `The Promise`
- source: `The Messenger of God ﷺ · Hadith al-Kisa - Awalim al-Ulum`
- body: `By Him who sent me with the truth, he swears: wherever this story of ours is told, in any gathering of people who love us, mercy comes down on them - and the angels gather around them, asking forgiveness for them, until they rise to leave. Then he swears a second time: no one sits there carrying a worry without God lifting it; no one grieving without God easing the grief; no one who came with a need without God granting it. And Ali answers after each oath, the second time larger: then we have won, and our Shia - those who hold to us - have won, in this world and the next, by God, the Lord of the Ka'ba.`
- reflection: `The story has just been told - here. And the oath was sworn with no date and no limit: over every gathering that would ever retell it, in rooms not yet built, in centuries not yet come. The gathering in the oath is this one. Whatever worry you carried in with you, whatever need - the promise was made wide enough to reach it, long before you were born.`

### 16 · salawat - The Five Names (NEW BEAT)
- tag: `The Five Names`
- prompt: `Answer the way every gathering answers.`
- subline: `When the five are named, no gathering stays silent. Five lights wait - one for each soul beneath the cloak. Tap, and they light one by one, in the order the cloak gathered them.`
- arabic: `اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّدٍ`
- translation: `“O God, bless Muhammad and the family of Muhammad.”`
- reference: `The salawat of every gathering`
- note: `God said He made creation itself for love of these five. Greeting them by name is the smallest act of that love there is - and by the promise sworn beneath the cloak, no gathering that says them is left alone.`
- nextLabel: `And the prayer to keep`

### 17 · dua - The Prayer of the Cloak
- tag: `The Prayer of the Cloak`
- intro: `Before the verse, before the angel - the Prophet ﷺ prayed over his family as a father, holding the two ends of the cloak toward the sky. Here is that prayer, whole - yours to keep.`
- arabic (FULL): `اللَّهُمَّ إِنَّ هٰؤُلَاءِ أَهْلُ بَيْتِي وَخَاصَّتِي وَحَامَّتِي، لَحْمُهُمْ لَحْمِي وَدَمُهُمْ دَمِي، يُؤْلِمُنِي مَا يُؤْلِمُهُمْ وَيَحْزُنُنِي مَا يَحْزُنُهُمْ، أَنَا حَرْبٌ لِمَنْ حَارَبَهُمْ وَسِلْمٌ لِمَنْ سَالَمَهُمْ، وَعَدُوٌّ لِمَنْ عَادَاهُمْ وَمُحِبٌّ لِمَنْ أَحَبَّهُمْ، إِنَّهُمْ مِنِّي وَأَنَا مِنْهُمْ، فَاجْعَلْ صَلَوَاتِكَ وَبَرَكَاتِكَ وَرَحْمَتَكَ وَغُفْرَانَكَ وَرِضْوَانَكَ عَلَيَّ وَعَلَيْهِمْ، وَأَذْهِبْ عَنْهُمُ الرِّجْسَ وَطَهِّرْهُمْ تَطْهِيرًا`
- translation: `“O God, these are the people of my house, my own and my nearest kin. Their flesh is my flesh and their blood is my blood; what pains them pains me, and what grieves them grieves me. I am at war with whoever wars on them, at peace with whoever is at peace with them; an enemy to whoever is their enemy, and a lover of whoever loves them. They are of me and I am of them - so set Your blessings, Your graces, Your mercy, Your forgiveness and Your good pleasure upon me and upon them, and remove from them all impurity, and purify them, a thorough purifying.”`
- source: `The Messenger of God ﷺ · Hadith al-Kisa - Awalim al-Ulum of al-Bahrani`
- note: `Families keep this story for Thursday night - the eve of Friday - reciting it in homes where a need is carried or a grief is heavy, for the sake of the promise sworn beneath the cloak. You have heard it whole now. Wherever you retell it, that room joins the gatherings he swore over.`
- close: `The promise is yours to keep.`

Deliberate within-dive echo, declared: the prayer is HEARD inside the story (beat 09,
English prose, trimmed to the binding clauses and the tathir plea) and GIVEN WHOLE at the
close (beat 17, full Arabic + Listen). Heard in the story, kept at the door.

## 6. Sourcing

| Item | Source | Verification |
|---|---|---|
| The long narrative (beats 05-11, 15, 17) | Hadith al-Kisa, Jabir ibn Abdullah al-Ansari from Fatima al-Zahra - Awalim al-Ulum of al-Bahrani, vol. 11 (Fatima volume, ~p. 930-934); also al-Muntakhab of al-Turayhi | Arabic verified verbatim against the standard recited text (duas.org, al-Qazwini's translation on al-islam.org), 2026-08-09; re-verified word-by-word by Auditor B (dua 47/47 words, zero divergence) |
| Arrival order + admission titles | Same text: Hasan (master of my Fountain - sahib hawdi), Husayn (who will plead for my nation - shafi' ummati), Ali (brother, successor), Fatima (my daughter, part of me); Jibra'il sixth. The fragrance is RECOGNITION on arrival, not a summons - fixed per audit | verified |
| 12:94, 33:33, 42:23 | `quran_data.json`, transcribed to plain orthography; 33:33 and 42:23 displayed as excerpts, full-verse recitation anchored; 33:33's reflection discloses the feminine-to-masculine address turn (the recitation plays the full ayah) | pulled + semantically audited 2026-08-09 |
| Dawn-door months (beat 12 reflection) | Anas ibn Malik - Jami' al-Tirmidhi 3206 ("six months... al-salat, ya Ahl al-Bayt" + 33:33); Shia parallels under 33:33 in Majma' al-Bayan, Tafsir Furat al-Kufi. Duration variants (40 days-9 months) exist; the copy says only "for months" | verified |
| Event bedrock (design-doc grounding, not cited in-app) | Sahih Muslim 2424 (Aisha); Tirmidhi 3871 + 3787 and Musnad Ahmad (Umm Salama); al-Hakim. The EVENT is mutawatir across both traditions; the long devotional text is recited under raja' - Mar'ashi Najafi defended its chain, al-Qummi excluded it from Mafatih (publisher appended it ~1960s). NOTE (audit): the mainstream location of the kisa/tathir event in the short versions is the house of Umm Salama (al-Hilli reports consensus); the long Awalim version is set in Fatima's house, and the dive follows its cited source without claiming exclusivity | posture recorded |
| Ali's two exclamations | First: "fuzna wa faza shi'atuna wa-rabb al-Ka'ba"; second, larger: "fuzna wa su'idna... fi al-dunya wa'l-akhira" - beat 15 renders the escalation ("the second time larger... in this world and the next") | verified |
| Salawat formula (beat 16 resolve) | Universal devotional formula | - |

## 7. Catalog + What's New + cover art

**Catalog** (`DeepDiveCatalog.swift`) - NEW entry between `taqwa` and `rida`:
- id `kisa` · titleAr `الكِسَاء` · sfSymbol `moon.stars.fill` · available true · dive `.kisa`
- title: en `al-Kisa · The Cloak` · ur `حدیث کساء` · ar `الكساء`
- subtitle: en `A gathering beneath one cloak - told in the voice of Fatima`
  · ur `ایک چادر تلے ایک اجتماع - فاطمہ زہرا کی زبانی`
  · ar `اجتماعٌ تحت كساءٍ واحد - بلسان فاطمة الزهراء`
- coverAssetName: `KisaCover` - SHIPPED: master `assets/premium-art/covers/kisa_master.png`
  (nano_banana_flash 1k, job id in covers/jobs.md), imageset at 1170x1463 q78 @3x.
  KNOWN, ACCEPTED for now: the weave shows more than five points of light (model overshot
  the exact count); a 2k retake is possible when credits/OpenRouter key are renewed.

**What's New** (`WhatsNewItem.swift`): `deepDives-kisa`, releaseDate placeholder
**2026-08-19** - MUST remain later than taqwa's placeholder (2026-08-18) or the kisa card
never surfaces first (newest-first sort; audit finding). Set both to real dates at ship
time. Copy: title "New Deep Dive: Under the Cloak" (EN/UR/AR), blurb naming Fatima's
voice + the arrivals + the naming + the promise + the salawat close, CTA "Enter the
gathering" / "محفل میں داخل ہوں" / "ادخل المجلس". AR blurb uses بلسان (matches catalog);
UR uses نئی صلوات (feminine).

## 8. Deliberately NOT used / declared echoes

- **The Mubahala (3:61)** - summit of the Al Imran surah journey; effectively spent.
- **The al-Insan three nights / 76:8-9** - Ikhlas's summit.
- **Umm Salama's versions** (Muslim 2424 context, Tirmidhi 3871/3787: "you are upon
  goodness", the drawn-away cloak edge) - different house, different telling; one
  narrative voice kept. Available to a future dive on hope/adab with great care.
- **The pre-creation light narrations** ("lights beneath the Throne") - mixed gradings;
  devotional cosmology, not anchor material.
- **Hadith al-thaqalayn explicit** - lives in the Fatiha surah journey.
- **24:36 (houses God permitted to be raised)** - considered for Circle I, left available.
- **Karbala, entirely** - first dive with no Karbala moment.
- **The full "as-salat" door SCENE as its own beat** - folded into beat 12's reflection;
  a future Fatima-centered dive could still stage it.
- **DECLARED ECHO - Ya'qub/Yusuf**: beat 06 uses 12:94 (the fragrance recognized across
  distance); Sabr's act 1 uses 12:86 (grief carried to God). Same figures, different
  verse, genuinely different lens - recognition by love vs complaint to God. Deliberate.
  (The Yusuf surah journey does not use 12:94.)
- **DECLARED ECHO - the Al Imran surah journey**: its "Our Selves" narration compresses
  the cloak gathering into one sentence AND quotes the tathir clause in English
  translation; its Act II is the Mubahala. The Kisa dive is the different-product,
  different-depth telling: 33:33 as a real Arabic verse beat (banked for exactly this by
  the Ikhlas doc), the full narrative, no Mubahala. Deliberate.
- **Connector deviation, declared**: third-person state connectors (not the house
  "You have...") - see §1.3.

## 9. Audit record (2026-08-09)

Four auditors (flow/ledger, theology/sourcing/Arabic, readability, voice/reverence), all
Opus, flag-only. Consolidated: 5 Blockers, 14 Should-fix, 8 Polish. **User approved
applying ALL findings; none declined.** Highlights of what changed post-mock: the
self-referential loop removed from beats 01/03 (spent only at beat 15), "master of my
pond" → "master of my Fountain", the climax restructured so the gold line answers
Jibra'il's question directly, `replyingTo` now names the prayer, the fragrance corrected
to recognition-on-arrival, beat 15 rewritten in plain English with "our Shia" glossed and
the boundary kept (the reader's need reached by the promise, not seated beneath the
cloak), the cloak never downgraded to blanket/cloth, the Prophet ﷺ never anonymized,
"وَبَرَكَاتِكَ" restored to the dua translation ("Your graces"), the 33:33 address-turn
disclosed, and Fatima's narration held to one first-person frame.

## 10. Out of scope / debts

- UR/AR localization of the dive content (house precedent; English-first).
- `salawat` renderer fixed strings are EN-only literals (tracked with the UR/AR pass).
- Cover art 2k retake with exactly five lights (see §7).
- No engine changes beyond the one new beat. No PremiumManager change.
