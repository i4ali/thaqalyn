# Shukr Deep Dive - Design Spec

**Date:** 2026-07-17
**Status:** Approved (visual mock: `docs/mockups/shukr_mock.png` + `shukr_mock.html`)
**Feature:** The fourth immersive "Deep Dive" (after Yaqin, Sabr, Tawakkul), on **Shukr** (gratitude), shown in the Journeys tab. Premium-gated (veiled preview), like Sabr/Tawakkul.

---

## 1. Summary & identity

Ship **Shukr - The Thanks That Returns**: a single-sitting descent through the **three tongues of thanks** - the classic Ahl al-Bayt tripartite - summiting on the eve of Ashura. Unlike Yaqin (depths of knowing), Sabr (stations of bearing), and Tawakkul (motions of the hand), Shukr moves through the organs of gratitude: what the heart must see, what the tongue must say, what the body must answer.

**Spine (approved): "The Three Tongues."**

- **Movement I - al-Qalb (القَلْب) - "The Recognizing":** to see the gift as gift and the Giver behind it; recognition is itself thanks (al-Kafi; 16:78).
- **Movement II - al-Lisan (اللِّسَان) - "The Saying":** praise spoken aloud - the covenant of increase (14:7), the telling of the blessing (93:11), and the tongue's limit answered by God Himself (Musa, al-Kafi).
- **Movement III - al-Jawarih (الجَوَارِح) - "The Doing":** thanks acted with the body (34:13, the Prophet's swollen feet) -> the turn: God is al-Shakur, He thanks back (76:22) -> Karbala.

**Emotional spine (the callback):** beat 05 opens the descent with 16:78 - "He made for you hearing, and sight, and hearts, that you might give thanks." The climax (beat 14) is Husayn's eve-of-Ashura khutba, which thanks God for prophethood, the Qur'an - and for **hearing, and sight, and hearts** - on the last night they would be his. Verified: the khutba really contains those words, and it is narrated by Imam al-Sajjad, whose Sahifa Dua 37 then closes the dive. The callback is left unannounced in beat 05 and named only in the climax reflection.

**Two identity moves:**
1. Second theme-dive use of the `response` beat ("He answers") - God's reply to Musa on the impossibility of adequate thanks (al-Kafi 2:98 h.27): "Now you have thanked Me - now that you know that even the thanks is from Me."
2. One new interactive beat, **`count`** ("The Count"), replacing the standard `reflectionPrompt`: the reader taps to count blessings - each tap a gold point of light - until the lights start multiplying on their own, outrunning the finger, and the screen resolves into 16:18: "If you count the blessings of God, you cannot number them." Losing the count IS the verse.

Decisions from Q&A: topic Shukr (next in catalog roadmap); Three Tongues spine over "The Increase" / "The Few" alternatives; new `count` beat over reusing `reflectionPrompt` or the `release` mechanic; eve-of-Ashura praise as summit (deliberate second visit to Sabr's "Last Night" scene through a different lens - Sabr watched them choose to stay, Shukr hears what Husayn was saying in that darkness); **English-first** content (string literals; UR/AR later), matching Sabr/Tawakkul.

## 2. Architecture

1. **Modify** `Thaqalayn/Models/DeepDive.swift` - add `case count(...)` to `DeepDiveSection` (+ its `act` mapping = 4).
2. **Modify** `Thaqalayn/Views/DeepDive/DeepDiveView.swift` - add `countPage` renderer + tap/overflow state; add `placeInfo` entry; reset count state in the Amin block's "Begin again".
3. **Create** `Thaqalayn/Content/ShukrDeepDive.swift` - `extension DeepDive { static let shukr }` (content in section 4). Synced folders: no pbxproj edit.
4. **Modify** `Thaqalayn/Services/DeepDiveCatalog.swift` - flip `shukr` to `available: true, dive: .shukr`, subtitle -> "A descent through three tongues - Qur'an to Karbala" (UR: "تین زبانوں میں اترتا ایک سفر - قرآن سے کربلا تک", AR: "نزولٌ عبر ثلاثة ألسنة - من القرآن إلى كربلاء").
5. **Modify** `Thaqalayn/Models/WhatsNewItem.swift` - add `deepDives-shukr` announcement (EN/UR/AR).

Premium gating, veil, audio (VerseRecitationButton / DuaListenButton), reading scale: already handled by the engine. `ShukrCover` asset already exists.

## 3. The `count` beat (engine addition)

```swift
/// The interactive close of a dive built on gratitude. The reader taps to count
/// blessings - each tap births a point of light - until the lights begin multiplying
/// on their own, outrunning the finger, and the screen resolves into the verse:
/// the count cannot be finished. Replaces `reflectionPrompt` for such dives.
case count(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
           arabic: String, translation: LocalizedText, reference: String,
           note: LocalizedText, nextLabel: LocalizedText)
```

Renderer behavior (`countPage`):
- **Idle:** ✦ mark, serif prompt ("Count what He has given you."), italic subline, a single small gold seed-light, label "TAP - EACH TAP, ONE BLESSING".
- **Counting:** each tap spawns a drifting gold point of light and ticks a serif tally (1, 2, 3...), soft haptic per tap. After ~7 taps the lights begin multiplying on their own - the tally accelerates past any finger (20, 80, 147...), a starfield fills the middle of the screen, and the label swaps to "THEY OUTRUN THE COUNT" (light haptic).
- **Resolve:** ~2s after overflow begins (or on next tap), success haptic; the field dims behind a burst-glow crossfade into: Arabic `وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا` (goldBright, glow), translation, reference, note, and the bob (nextLabel) into the dua.
- Honors `reduceMotion` (no cascade/drift; simple state swaps with a static field) and reading scale on prompt/subline/note.
- "Begin again" (Amin block) resets the count state alongside `saidAmin`/`openDepths`.
- `placeInfo`: `("The Count", acts.count)` - all dots filled.

## 4. Full content (source of truth for transcription)

16 beats. Voice matches Yaqin/Sabr/Tawakkul: spare literary prose, " - " never em dash, plain English spelling (house diacritics rule), curly quotes in quoted speech. Qur'an Arabic in the same plain (non-Uthmani) orthography the other dives use; verse beats anchor on a single ayah for recitation.

Metadata: id `shukr` · titleEn `Shukr` · titleAr `شُكْر` · subtitle `Gratitude - a descent through three tongues` · sfSymbol `hands.clap` · estMinutes 5.

Acts: 1 القَلْب al-Qalb "The Recognizing" · 2 اللِّسَان al-Lisan "The Saying" · 3 الجَوَارِح al-Jawarih "The Doing".

### 01 - `open`
- kicker: A DEEP DIVE · titleAr: شُكْر · titleEn: Shukr · subtitle: Gratitude
- line: A descent through the Qur'an and the Ahl al-Bayt - what the heart must see, what the tongue must say, what the body must answer.

### 02 - `orientation`
- eyebrow: Before you descend
- promise: Three tongues of thanks lie below - the heart that recognizes, the tongue that praises, and the limbs that answer.
- leaveWith: You'll leave with a map of gratitude - and a prayer that hands the rest back to Him.

### 03 - `depths` - "The Three Tongues" (act 0)
- tag: The Three Tongues · reference: al-Kafi · Saba 34:13
- items:
  1. القَلْب · al-Qalb · The Recognizing · "To see the gift as gift - and the Giver behind it. Thanks begins before a word is said." · ref nil · embodies: the heart that sees the Giver
  2. اللِّسَان · al-Lisan · The Saying · "To speak the praise aloud - and tell of the blessing." · ref 93:11 · embodies: the tongue that praises
  3. الجَوَارِح · al-Jawarih · The Doing · "To answer the gift with the body - to stand, to serve, to give." · ref 34:13 · embodies: the family who answered with everything

### 04 - `act` I (connector nil, bridge nil)
- line: It begins behind the ribs. Before gratitude has words, it is a kind of seeing - the gift caught in the act of arriving, and the Giver's hand still on it.

### 05 - `verse` - al-Nahl 16:78 (act 1, tag "The First Gifts")
- arabic: وَاللَّهُ أَخْرَجَكُم مِّن بُطُونِ أُمَّهَاتِكُمْ لَا تَعْلَمُونَ شَيْئًا وَجَعَلَ لَكُمُ السَّمْعَ وَالْأَبْصَارَ وَالْأَفْئِدَةَ لَعَلَّكُمْ تَشْكُرُونَ
- translation: "And God brought you out of your mothers' wombs knowing nothing - and He made for you hearing, and sight, and hearts, that you might give thanks."
- reference: al-Nahl · 16 : 78
- reflection: You arrived owning nothing - not even the knowing. Hearing, sight, a heart: the verse lists the first gifts, then names what they were for. Gratitude is not an ornament on the equipment. It is what the equipment was issued for.

### 06 - `narration` - "The Thanks of the Heart" (act 1)
- source: Imam Ja'far al-Sadiq · al-Kafi, the book of thanks
- body: When God grants a servant a blessing, said the Imam, and he recognizes it with his heart - he has already given its thanks.
- reflection: Thanks is born before a word is spoken - in the heart, where the gift is seen and the Giver named. Born, not finished - two tongues remain.

### 07 - `act` II (connector "You have seen the Giver.", bridge nil)
- line: Now - say it. What the heart knows in silence, the tongue brings into the open: the blessing told, the Giver named aloud.

### 08 - `verse` - Ibrahim 14:7 (act 2, tag "The Covenant of Increase")
- arabic: وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ
- translation: "And when your Lord proclaimed: If you give thanks, I will surely increase you."
- reference: Ibrahim · 14 : 7
- reflection: Proclaimed - not whispered. Thanks is the one debt that grows by being paid: thank Him, and He gives you more to thank for. And the increase is not always more of the gift. Sometimes it is more of the seeing.
- (Excerpt of the ayah, per the Sabr 12:86 precedent; recitation plays the full verse.)

### 09 - `verse` - al-Duha 93:11 (act 2, tag "Tell of It")
- arabic: وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ
- translation: "And as for the blessing of your Lord - tell of it."
- reference: al-Duha · 93 : 11
- reflection: Four words, spoken first to the Prophet - an orphan who had just been given everything. Gratitude has a voice - not the boast that forgets the Giver, but the telling that names Him: this came from my Lord.

### 10 - `response` - He Answers (act 2)
- replyingTo: To Musa, who asked: how shall I thank You, when even my thanks is itself Your gift?
- arabic: الْآنَ شَكَرْتَنِي حِينَ عَلِمْتَ أَنَّ ذَلِكَ مِنِّي
- words: "Now you have thanked Me - now that you know that even the thanks is from Me."
- source: His words to Musa · al-Kafi
- reflection: The ladder of thanks has no top rung - every thanks is another gift, owing another thanks. He does not ask you to reach the top. He asks you to know where the ladder stands.

### 11 - `act` III (connector "You have said it.") + bridge Saba 34:13
- line: Now - past the saying. The command to the most gifted house on earth was not to say thanks but to work it. In the end, thanks is something the body does.
- bridge: surah 34 ayah 13 · اعْمَلُوا آلَ دَاوُودَ شُكْرًا وَقَلِيلٌ مِّنْ عِبَادِيَ الشَّكُورُ · "Work, O family of Dawud, in thanks - and few of My servants are deeply grateful." · Saba · 34 : 13

### 12 - `narration` - "The Grateful Servant" (act 3)
- source: The Messenger of God ﷺ · narrated of Imam al-Baqir, al-Kafi
- body: He stood in the night on the tips of his toes, until standing itself was a labor. He was asked: but you are already forgiven - everything past, everything to come - why this? He said: "Shall I not be a grateful servant?"
- reflection: Forgiveness did not retire his worship - it changed what the worship was. No longer a plea; a thank-you. The most truthful tongue on earth was not enough for him. He thanked with his feet.

### 13 - `verse` - al-Insan 76:22 (act 3, tag "The Thanks That Returns")
- arabic: إِنَّ هَٰذَا كَانَ لَكُمْ جَزَاءً وَكَانَ سَعْيُكُم مَّشْكُورًا
- translation: "Indeed this is a reward for you - and your striving has been thanked."
- reference: al-Insan · 76 : 22
- reflection: Spoken in the surah given to the Prophet's own house - the family who fed the hungry for three nights and asked nothing back. Read it slowly: God, who needs nothing, thanks. The thanks you send up does not vanish. It returns.
- (The full al-Insan feeding narrative is deliberately NOT told here - reserved for the future Ikhlas dive. One clause only.)

### 14 - `climax` - "The Praise in the Dark" (act 3)
- source: Imam al-Husayn, the eve of Ashura - al-Irshad of al-Mufid
- arabic: أُثْنِي عَلَى اللَّهِ أَحْسَنَ الثَّنَاءِ، وَأَحْمَدُهُ عَلَى السَّرَّاءِ وَالضَّرَّاءِ
- translation: "I praise God with the best of praise, and I thank Him in ease and in hardship."
- body: The army is across the plain and the morning is known. He gathers his family and companions at nightfall - and opens with praise: for prophethood, for the Qur'an. For hearing, and sight, and hearts.
- reflection: Hearing, sight, hearts - the first gifts, where this descent began. He named them in thanks on the last night they would be his. Anyone can give thanks for the gift. He thanked the Giver while the gifts were being taken.

### 15 - `count` - "The Count" (NEW beat)
- tag: The Count
- prompt: Count what He has given you.
- subline: He counted his blessings on the night they were being taken. Yours are still in your hands - this breath, your sight, a person who loves you. Tap: one blessing at a time.
- arabic: وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا
- translation: "And if you count the blessings of God, you cannot number them."
- reference: al-Nahl · 16 : 18
- note: The count was never going to finish. It was only ever going to point - at the One whose giving outruns it.
- nextLabel: And one prayer
- (fixed renderer strings: "TAP - EACH TAP, ONE BLESSING" / "THEY OUTRUN THE COUNT")

### 16 - `dua` - "A Prayer of the Unfinished Thanks"
- intro: After the heart, the tongue, the limbs - after Karbala - one prayer, in the voice of the fourth Imam: the confession that no thanks arrives at the end.
- arabic: اللَّهُمَّ إِنَّ أَحَدًا لَا يَبْلُغُ مِنْ شُكْرِكَ غَايَةً إِلَّا حَصَلَ عَلَيْهِ مِنْ إِحْسَانِكَ مَا يُلْزِمُهُ شُكْرًا
- translation: "O God, no one ever reaches an end in thanking You - for with every thanks, more of Your goodness settles upon him, and binds him to thank You again."
- source: Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Dua 37
- note: The full count is not asked of you tonight. Only this: one blessing seen, one alhamdulillah said aloud - and the rest left to the One who accepts the little and gives the much.
- close: The thanks is yours to keep.

## 5. Sourcing & verification (done 2026-07-17)

| Item | Source | Status |
|------|--------|--------|
| Ayat 16:78, 14:7, 93:11, 34:13, 76:22, 16:18 | Qur'an | Text checked against app `quran_data.json` (plain orthography per house style; recitation anchored per single ayah; 14:7 and 34:13 shown as excerpts per Sabr 12:86 precedent). |
| Heart-recognition (beat 06) | al-Kafi 2:96, from Imam al-Sadiq | Verified verbatim: «من أنعم الله عليه بنعمة فعرفها بقلبه فقد أدى شكرها». |
| Musa exchange (beat 10) | al-Kafi 2:98 h.27, from Imam al-Sadiq | Verified verbatim: «فيما أوحى الله عز وجل إلى موسى: يا موسى اشكرني حق شكري، فقال: يا رب وكيف أشكرك حق شكرك وليس من شكر أشكرك به إلا وأنت أنعمت به علي؟ قال: يا موسى الآن شكرتني حين علمت أن ذلك مني». |
| The Grateful Servant (beat 12) | al-Kafi, bab al-shukr, from Imam al-Baqir | Verified: the Prophet standing on the tips of his toes, Aisha's question, «ألا أكون عبدا شكورا», and Ta-Ha 20:1-2 revealed (coda kept out of the beat for tightness). **Audit correction 2026-07-17:** the al-Kafi text does NOT mention swelling - «تورمت قدماه» is the Bukhari/Muslim wording (in the Shia corpus it appears in al-Ihtijaj of al-Tabrisi, from Imam al-Kazim); the beat uses al-Kafi's tips-of-the-toes image. |
| Eve-of-Ashura khutba (beat 14) | al-Irshad of al-Mufid / Tabari, narrated by Ali ibn al-Husayn | Verified verbatim: «أثني على الله أحسن الثناء وأحمده على السراء والضراء، اللهم إني أحمدك على أن أكرمتنا بالنبوة وعلمتنا القرآن وفقهتنا في الدين وجعلت لنا أسماعا وأبصارا وأفئدة» - includes the hearing/sight/hearts callback to 16:78, and the narrator is Imam al-Sajjad (whose Dua 37 closes the dive). |
| Sahifa Dua 37 opening (beat 16) | al-Sahifa al-Sajjadiyya #37 (confessing shortcoming in thanks) | Verified verbatim: «اللهم إن أحدا لا يبلغ من شكرك غاية إلا حصل عليه من إحسانك ما يلزمه شكرا». |

**Nothing reused from Yaqin/Sabr/Tawakkul.** No verse overlaps. Explicitly avoided: Ibrahim's fire, the mother of Musa, Zaynab in the court (Yaqin); Ya'qub, Ismail, Ayyub, the lifting of the oath, the last prostration (Sabr); Musa at the sea, the believer of Ghafir, the revelation to Dawud, the morning-of-Ashura trust dua (Tawakkul). Sahifa duas differ (#20 Yaqin, #28 Tawakkul, #37 here; Sabr used al-Sadiq's Amali prayer). The `response` beat deliberately parallels Tawakkul's (Dawud) with a different prophet and theme (Musa, the regress of thanks). The eve-of-Ashura scene revisits Sabr's "Last Night" through a different lens by design: Sabr watched them choose to stay; Shukr hears what Husayn was saying in that darkness. The full al-Insan feeding narrative is reserved for the future Ikhlas dive.

## 6. Catalog + What's New

- Catalog `shukr`: `available: true`, `dive: .shukr`, subtitle per section 2. Title/titleAr/sfSymbol/cover unchanged.
- WhatsNew `deepDives-shukr` (sfSymbol `hands.clap`, destination `.deepDive("shukr")`, trilingual copy, "Begin the descent" CTA).

## 7. Out of scope

- Urdu/Arabic dive content (EN-first; localize later like Sabr/Tawakkul).
- No persistence of the count interaction; no new audio assets.
- Remaining placeholder dives (Ikhlas, Taqwa, Rida) untouched.

## 8. Audit outcome (2026-07-17)

Three flag-only auditors run per the `/theme-deep-dive` skill (full report:
`docs/plans/2026-07-17-shukr-audit-findings.html`). Findings 1-11 (the Blocker + all
Should-fix) were approved and applied to `ShukrDeepDive.swift` and this doc - including
the al-Kafi citation correction on beat 12 (tips-of-the-toes image; see sourcing table).
Section 4 above reflects the post-audit content.

**Post-audit fix (user-found, 2026-07-17):** beat 09's "an orphan who had just been given
everything" carried the beat on an unnamed allusion (the addressee of al-Duha); Auditor C
had noted it but excused it as audience-known - the developer's own simulator pass proved
otherwise. Now "spoken first to the Prophet - an orphan who...". The skill's Auditor C
prompt was hardened: unglossed allusions are findings, never excused by assumed audience
knowledge.

**Findings 12-16 declined - known, accepted:**
- 12: "equipment ... issued" register on beat 05's reflection stays.
- 13: beat 12 source line "narrated of Imam al-Baqir" phrasing and its ﷺ (the family's
  first) stay; honorific convention across dives left as is.
- 14: beat 06 source "al-Kafi, the book of thanks" stays ("chapter" would be stricter).
- 15: 14:7's tie to Movement II remains carried by "Proclaimed - not whispered" alone.
- 16 (recorded-only, series-level): third Sajjad close in four dives + the "not asked of
  you... Only this:" dua-note formula + Dawud in adjacent third movements - a conscious
  break is suggested for the NEXT dive; "three tongues" label containing the literal
  tongue; depths item 3 pairing the Prophet's family with Dawud's verse; the unplayed
  weld that Dua 37's author narrated the eve-of-Ashura khutba.
