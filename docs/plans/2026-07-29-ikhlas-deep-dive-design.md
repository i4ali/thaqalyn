# Ikhlas Deep Dive - Design Spec

**Date:** 2026-07-29
**Status:** APPROVED 2026-08-05 (Gate 2 verdict: "build it"; catalog subtitle "Qur'an to the house of Fatima" kept; Last Light prompt kept; no copy edits). Implementation in progress. Visual mock rendered: `docs/mockups/ikhlas_mock.html` + `ikhlas_mock.png` (final copy, 17 cells).
**Feature:** The sixth immersive "Deep Dive" (after Yaqin, Sabr, Tawakkul, Shukr, Salah), on **Ikhlas** (sincerity), next roadmap entry in `DeepDiveCatalog` (id `ikhlas`, sfSymbol `drop.fill`, `IkhlasCover` asset exists). Premium-gated like the others.

**GATE 1 (approved by user 2026-07-29):** spine = "The Unmixing" (al-Niyya / al-Tasfiya / al-Mukhlas); summit = the al-Insan nights (first non-Karbala summit); close = new `extinguish` beat "The Last Light".
**GATE 2 (approved 2026-08-05):** design + mock re-presented on resume; user approved "build it" with no copy edits. Both flagged decisions kept - catalog subtitle "Qur'an to the house of Fatima" and the Last Light prompt "Who else were you doing it for?". The vowel-turn readability point (beats 05/11) deferred to the Stage 5 readability auditor. Original parked notes retained in section 8 for history.

---

## 1. Summary & identity

Ship **Ikhlas - The Unmixing**: a single-sitting descent through **three purities**, walking the theme's own root (kh-l-s) through its three Qur'anic forms. The deepest identity move is grammatical: beat 05 plants the active **mukhliSin** (98:5, "the ones who purify"; its reflection warns "one vowel of it will change"), the Purity III card turns the vowel, and 15:40 lands the passive **mukhlaSin** - the ones God has purified, whom even Iblis concedes. Your work becomes His gift.

- **Purity I - al-Niyya (النِّيَّة) - "The Address":** every deed travels to the one it was done for (98:5; "the believer's intention is better than his deed" + "the intention is the deed", al-Kafi).
- **Purity II - al-Tasfiya (التَّصْفِيَة) - "The Straining":** the enemy is being seen - the stone left bare (2:264), the ledger that rewrites secret -> public -> riya as the doer retells (al-Kafi), and the hadith qudsi "I am the best of partners" (al-Kafi).
- **Purity III - al-Mukhlas (المُخْلَص) - "The Purified":** the vowel turns (bridge 39:3, khalis); the whisperer's exception (15:40); the forty days (al-Kafi); **summit: the three nights of Surah al-Insan** (76:8-9) - the household's secret iftars, published by God Himself. Majma' al-Bayan's note is the summit's sharpest point: some say the words were never spoken at all - God knew what was in their hearts and praised them for it.

**Identity moves / series-pattern breaks:**
1. **First non-Karbala summit.** The skill carves out al-Insan for Ikhlas, and Shukr's design doc explicitly reserved the 76:8-9 feeding narrative for this dive (Shukr used only 76:22). Hasan and Husayn sit at that table as children - Karbala present without being visited. Catalog subtitle therefore breaks the "Qur'an to Karbala" formula: "Qur'an to the house of Fatima" (pending approval, section 8).
2. **New interactive beat `extinguish` - "The Last Light":** tap out the borrowed audiences one by one; the last light will not go out - tapping only brightens it - resolving into 28:88 "Everything perishes - except His Face." The gesture IS the theme: sincerity is subtraction, and the one Watcher cannot be removed. Meaning-inverse of Shukr's `count` (adding lights that outrun the finger vs removing lights down to the unremovable One); same 8-field shape and haptic recipe.
3. **Dua Kumayl close** - first Imam Ali voice in the series' closes; second consecutive break from the Sahifa-Sajjad run (per Shukr audit finding 16's series-level request). The "one litany" petition. Close line: "The intention is yours to keep."
4. Response beat recipient varies again: Dawud (Tawakkul) -> Musa (Shukr) -> the reader (Salah) -> now the divided-hearted doer ("To the one who worked for Him - and for other eyes too").
5. **67:2 and 12:24 deliberately avoided** - both already carry beats in the shipped SURAH journeys (SurahMulkDive uses 67:2 with the same al-Kafi ikhlas gloss in its reflection; SurahYusufDive has a full 12:24 beat). Cross-product taste call, not a theme-dive ledger requirement.

Metadata: id `ikhlas` · titleEn `Ikhlas` · titleAr `إِخْلَاص` · subtitle `Sincerity - a descent through three purities` · sfSymbol `drop.fill` · estMinutes 5 · stageNoun `Purity` · stageWord `Purity` (place-bar "Purity II · The Straining"; act card big label "PURITY"). Default descent verbs (this dive descends).

Acts: 1 النِّيَّة al-Niyya "The Address" · 2 التَّصْفِيَة al-Tasfiya "The Straining" · 3 المُخْلَص al-Mukhlas "The Purified".

## 2. Architecture

1. **Modify** `Thaqalayn/Models/DeepDive.swift` - add `case extinguish(...)` to `DeepDiveSection` (+ act mapping = 4, grouped with reflectionPrompt/release/count/sujud/dua/closing).
2. **Modify** `Thaqalayn/Views/DeepDive/DeepDiveView.swift` - add `extinguishPage` renderer + light-field state; `placeInfo` entry `("The Last Light", acts.count)`; reset all extinguish state in the Amin block's "Begin again"; invalidate any timer there and in `.onDisappear`.
3. **Create** `Thaqalayn/Content/IkhlasDeepDive.swift` - `extension DeepDive { static let ikhlas }` (content in section 4). Synced folders: no pbxproj edit.
4. **Modify** `Thaqalayn/Services/DeepDiveCatalog.swift` - flip `ikhlas` to `available: true, dive: .ikhlas`, subtitle -> EN "A descent through three purities - Qur'an to the house of Fatima" (UR/AR drafts in section 6, pending approval).
5. **Modify** `Thaqalayn/Models/WhatsNewItem.swift` - add `deepDives-ikhlas` announcement (EN/UR/AR), sfSymbol `drop.fill`, destination `.deepDive("ikhlas")`, CTA "Begin the descent", `releaseDate` placeholder.

Premium gating, veil, audio (VerseRecitationButton / DuaListenButton), reading scale: engine-level, no per-dive code. `IkhlasCover` asset already exists.

## 3. The `extinguish` beat (engine addition)

```swift
/// The interactive close of a dive built on sincerity. A field of small lights - the
/// audiences the reader has performed for. Tapping a light puts it out; the last light
/// cannot be put out - tapping it only brightens it - and the screen resolves into the
/// verse: everything perishes except His Face. Replaces `reflectionPrompt` for such dives.
case extinguish(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
                arabic: String, translation: LocalizedText, reference: String,
                note: LocalizedText, nextLabel: LocalizedText)
```

Renderer behavior (`extinguishPage`), following the release/count/sujud recipe:
- **Idle:** ✦ mark, serif prompt ("Who else were you doing it for?"), italic subline, a scatter of ~8 small gold lights (fixed positions), label "TAP EACH LIGHT - PUT IT OUT".
- **Extinguishing:** each tapped light dims to a faint outline (soft haptic per tap); the prompt dims as the field empties. When only one light remains: it is subtly larger.
- **The turn:** tapping the last light does not extinguish it - it flares brighter (light haptic), and the label swaps to goldBright "THIS ONE DOES NOT GO OUT".
- **Resolve:** ~1.5s after the flare (or on a second tap of the last light): success haptic; burst-glow crossfade into Arabic `كُلُّ شَيْءٍ هَالِكٌ إِلَّا وَجْهَهُ` (goldBright, glow), translation, reference, hairline, note, and the bob (nextLabel) into the dua.
- Honors `reduceMotion` (no flare/dim animation; simple state swaps) and reading scale on subline/note/translation (NOT the prompt or fixed labels).
- "Begin again" (Amin block) resets all extinguish state alongside `saidAmin`/`openDepths`; timer invalidated there and in `.onDisappear`.
- Fixed renderer strings (EN-only for now): "TAP EACH LIGHT - PUT IT OUT" / "THIS ONE DOES NOT GO OUT".

## 4. Full content (source of truth for transcription)

16 beats. Voice matches the five shipped dives: spare literary prose, " - " never an em dash, plain English spelling (house diacritics rule), curly quotes only inside quoted speech. Qur'an Arabic in plain (non-Uthmani) orthography; verse beats anchor a single ayah for recitation (98:5, 2:264, 39:3 shown as excerpts per the Sabr 12:86 precedent).

### 01 - `open`
- kicker: A DEEP DIVE · titleAr: إِخْلَاص · titleEn: Ikhlas · subtitle: Sincerity
- line: A descent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - tracing whom the deed is for, how it is guarded from other eyes, and whose hand finishes the purifying.

### 02 - `orientation`
- eyebrow: Before you descend
- promise: Three purities lie below - the address every deed carries, the straining that keeps it clean, and the purity only He can finish.
- leaveWith: You'll leave with a map of sincerity - and a prayer that gathers all your scattered deeds into one.

### 03 - `depths` - "The Three Purities" (act 0)
- tag: The Three Purities · reference: al-Kafi · al-Hijr 15:40
- items:
  1. النِّيَّة · al-Niyya · The Address · "Every deed travels to the one it was done for. Before the hands move, the heart has already addressed it." · ref nil · embodies: the heart that chooses its Witness
  2. التَّصْفِيَة · al-Tasfiya · The Straining · "To keep the deed clean of every eye but His - even after it is done." · ref nil · embodies: the hand that hides its gift
  3. المُخْلَص · al-Mukhlas · The Purified · "When the purifying passes out of your hands - and what He seals, no whisper can reach." · ref 15:40 · embodies: the family He purified

### 04 - `act` I (connector nil, bridge nil)
- line: It begins before the deed does. Two people kneel in the same row, give the same coin, say the same words - and the two deeds do not arrive at the same door. What separates them was settled earlier, in silence: whom it was for.

### 05 - `verse` - al-Bayyina 98:5 (act 1, tag "The One Command"; excerpt, recitation plays full verse)
- arabic: وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ
- translation: "And they were not commanded except to worship God, making the religion pure for Him alone."
- reference: al-Bayyina · 98 : 5
- reflection: Not commanded except - as if every command ever sent folds into this one. And the word is mukhlisin - the ones doing the purifying; its singular is mukhlis, the one who purifies. An active word; at this depth, the purifying is yours. Hold that word - before the floor of this descent, one vowel of it will turn.

### 06 - `narration` - "The Soul of the Deed" (act 1)
- source: The Messenger of God ﷺ · al-Kafi, the chapter of intention
- body: The intention of the believer, said the Prophet ﷺ, is better than his deed. And every doer acts upon his intention.
- reflection: Better than the deed - because the deed is only the body, and the intention is its soul. Imam al-Sadiq went further: the intention is the deed. The hands build the visible half; whom it was for is the half that decides.

### 07 - `act` II (connector "You have addressed the deed.", bridge nil)
- line: Now - guard it. The deed takes a moment; keeping it His is the long work. The wish to be seen does not come first - it comes after, quietly, for the deed you have already done.

### 08 - `verse` - al-Baqarah 2:264 (act 2, tag "The Stone Left Bare"; excerpt, recitation plays full verse)
- arabic: فَمَثَلُهُ كَمَثَلِ صَفْوَانٍ عَلَيْهِ تُرَابٌ فَأَصَابَهُ وَابِلٌ فَتَرَكَهُ صَلْدًا
- translation: "[The one who spends his wealth to be seen by people -] his likeness is a smooth stone with soil upon it: a downpour struck it, and left it bare."
- reference: al-Baqarah · 2 : 264
- reflection: The soil was real - the coin was given, the deed was done. But it lay on rock, not in ground. One hard rain, and nothing had ever taken root: a deed done for eyes has no earth under it.

### 09 - `narration` - "The Ledger That Moves" (act 2)
- source: Imam Muhammad al-Baqir · al-Kafi, the chapter on riya
- body: Keeping the deed, said the Imam, is harder than the deed. He was asked: what is keeping the deed? He said: a man gives, spending for God alone, who has no partner, and it is recorded as a secret. Then he mentions it - and the secret is erased, rewritten as a deed done openly. He mentions it again - and that too is erased, rewritten as riya: a deed done to be seen.
- reflection: Nothing changed but the telling - and the telling moved the deed, ledger by ledger, from His eyes toward theirs. Some deeds stay pure the way secrets stay secrets: untold.

### 10 - `response` - He Answers (act 2)
- replyingTo: To the one who worked for Him - and for other eyes too
- arabic: أَنَا خَيْرُ شَرِيكٍ
- words: "I am the best of partners: whoever joins another with Me in a deed he does, I do not accept it - except what was purely Mine."
- source: His word, related by Imam Ja'far al-Sadiq · al-Kafi
- reflection: Every partner on earth quarrels over the shares. He does not - He withdraws. A deed with two addresses is not split with Him; it is left, whole, to the other name on it. Only the undivided arrives.

### 11 - `act` III (connector "You have strained what is yours to strain.") + bridge al-Zumar 39:3 (excerpt)
- line: Now - the turn. The first depth gave you mukhlis: the one who purifies. The Qur'an keeps a second form, one vowel away - mukhlas: the one who has been purified. From active to passive, on a single vowel - and no one makes himself into that second word. At this depth the purifying changes hands.
- bridge: surah 39 ayah 3 · أَلَا لِلَّهِ الدِّينُ الْخَالِصُ · "Truly - to God belongs the religion made pure." · al-Zumar · 39 : 3

### 12 - `verse` - al-Hijr 15:40 (act 3, tag "The Whisperer's Exception")
- arabic: إِلَّا عِبَادَكَ مِنْهُمُ الْمُخْلَصِينَ
- translation: "[Iblis swore: I will make evil fair to them on earth, and I will mislead them, all of them -] except, among them, Your servants - the purified."
- reference: al-Hijr · 15 : 40
- reflection: He does not say: except the careful, or the strong-willed. He names the one place his feet cannot enter - the mukhlasin, the ones God has purified. The whisperer trades in audiences: be seen, be praised, be remembered. A heart emptied of every audience but One has walked out of his market.

### 13 - `narration` - "The Forty Days" (act 3)
- source: Imam Muhammad al-Baqir · al-Kafi, the chapter of ikhlas
- body: When a servant keeps his faith pure for God forty days, said the Imam, God turns his heart from the world - shows him the world's sickness and its cure - and sets wisdom firm in his heart, and lets his tongue speak it.
- reflection: The forty days are yours. Everything after them is His - the sight, the wisdom, the clean spring under the words. You bring the purifying you can manage; He answers with the purifying you cannot. Mukhlis is a labor. Mukhlas is a gift.

### 14 - `climax` - "The Three Nights" (act 3, the al-Insan summit)
- source: The household of the Prophet ﷺ · al-Insan 76:9 · Majma' al-Bayan · al-Amali of al-Saduq
- arabic: إِنَّمَا نُطْعِمُكُمْ لِوَجْهِ اللَّهِ لَا نُرِيدُ مِنكُمْ جَزَاءً وَلَا شُكُورًا
- translation: "We feed you only for the Face of God - we desire from you no repayment, and no thanks."
- body: Hasan and Husayn lie ill, and the household vows three fasts for their healing - Ali, Fatima, and Fidda who serves them. The boys recover; the fasting begins. Ali brings home three measures of barley, and Fatima grinds one each day and bakes it. At sunset a poor man calls at the door. The second sunset, an orphan. The third, a captive. Three nights the whole meal is given away at the door; three nights the family breaks its fast on water. On the fourth day Ali brings the boys to their grandfather - and the Prophet ﷺ weeps. Then the angel Jibril comes down with a surah.
- reflection: They refused even thanks from the ones they fed - and some of the early commentators say the words were never spoken at all: God knew what was in their hearts, and praised them for it. The family kept the secret; He proclaimed it in a surah recited to the end of time. A deed so hidden, only He could tell the story.

### 15 - `extinguish` - "The Last Light" (NEW beat)
- tag: The Last Light
- prompt: Who else were you doing it for?
- subline: The praiser, the critic, the rival - the audience you carry in your head. Small lights, each one an eye. Put them out, one by one.
- arabic: كُلُّ شَيْءٍ هَالِكٌ إِلَّا وَجْهَهُ
- translation: "Everything perishes - except His Face."
- reference: al-Qasas · 28 : 88
- note: Every audience files out in the end. The gaze you could not put out was the first one on your deed - and the only one that keeps it.
- nextLabel: And one prayer
- (fixed renderer strings: "TAP EACH LIGHT - PUT IT OUT" / "THIS ONE DOES NOT GO OUT")

### 16 - `dua` - "A Prayer of One Litany" (Dua Kumayl)
- tag: A Prayer of One Litany
- intro: After the stone, after the three nights - one prayer, in the voice of the first Imam, taught by night to Kumayl ibn Ziyad: that the scattered deeds become one.
- arabic: أَنْ تَجْعَلَ أَوْقَاتِي مِنَ اللَّيْلِ وَالنَّهَارِ بِذِكْرِكَ مَعْمُورَةً، وَبِخِدْمَتِكَ مَوْصُولَةً، وَأَعْمَالِي عِنْدَكَ مَقْبُولَةً، حَتَّىٰ تَكُونَ أَعْمَالِي وَأَوْرَادِي كُلُّهَا وِرْدًا وَاحِدًا، وَحَالِي فِي خِدْمَتِكَ سَرْمَدًا
  (displayed from «أن تجعل» - the petition body; the full sentence opens «وأسألك بحقك وقدسك وأعظم صفاتك وأسمائك». Contiguous-trim precedent: Tawakkul's deliberate 40:44 wa- trim. Note: corrected at audit 2026-08-05 - the canonical/dominant reading is «مِن الليل والنهار» (confirmed against WikiShia and multiple sources, one citing Misbah al-Mutahajjid itself); the app uses «من». The earlier «في» was an error.)
- translation: "That You make my times, by night and by day, filled with Your remembrance, joined to Your service, my works accepted with You - until my works and my litanies become all one litany, and my state in Your service everlasting."
- source: Imam Ali · Dua Kumayl - Misbah al-Mutahajjid of al-Tusi
- note: A whole lifetime, gathered to a single address. Begin smaller tonight: one deed with the door shut and no one told - aimed, start to finish, at the One who was watching before you began.
- close: The intention is yours to keep.

## 5. Sourcing & verification (done 2026-07-29, two research agents + direct checks)

| Item | Source | Status |
|------|--------|--------|
| Ayat 98:5, 2:264, 39:3, 15:39-40, 28:88, 76:8-9 | Qur'an | Text checked against app `quran_data.json` (plain orthography per house style; recitation anchored per single ayah; 98:5, 2:264, 39:3 shown as excerpts per Sabr 12:86 precedent). The app's own text shows the vowel pair: مُخْلِصِينَ in 98:5, ٱلْمُخْلَصِينَ in 15:40 (and 12:24). |
| Intention better than deed (beat 06) | al-Kafi 2:84, bab al-niyya h2 - the Prophet ﷺ via Imam al-Sadiq | Verified verbatim (thaqalayn.net + lib.eshia.ir, Islamiyya ed.): «نية المؤمن خير من عمله ونية الكافر شر من عمله وكل عامل يعمل على نيته». NOTE: continuation is «ونية الكافر...», not «وعمل الكافر». Beat uses first + last clauses. Variant: Amali al-Tusi 2/69 has «أبلغ من عمله». |
| "Intention is the deed" (beat 06 reflection) | al-Kafi 2:16, bab al-ikhlas h4 - Imam al-Sadiq | Verified verbatim: «...لَيْسَ يَعْنِي أَكْثَرَ عَمَلًا وَلَكِنْ أَصْوَبَكُمْ عَمَلًا وَإِنَّمَا الْإِصَابَةُ خَشْيَةُ اللَّهِ وَالنِّيَّةُ الصَّادِقَةُ وَالْحَسَنَةُ ثُمَّ قَالَ الْإِبْقَاءُ عَلَى الْعَمَلِ حَتَّى يَخْلُصَ أَشَدُّ مِنَ الْعَمَلِ وَالْعَمَلُ الْخَالِصُ الَّذِي لَا تُرِيدُ أَنْ يَحْمَدَكَ عَلَيْهِ أَحَدٌ إِلَّا اللَّهُ عَزَّ وَجَلَّ وَالنِّيَّةُ أَفْضَلُ مِنَ الْعَمَلِ أَلَا وَإِنَّ النِّيَّةَ هِيَ الْعَمَلُ ثُمَّ تَلَا: قُلْ كُلٌّ يَعْمَلُ عَلَى شَاكِلَتِهِ - يَعْنِي عَلَى نِيَّتِهِ» (glosses 67:2 and 17:84). 67:2 itself deliberately NOT used as a beat (see section 5 note on Mulk). |
| The ledger that moves (beat 09) | al-Kafi 2:296-297, bab al-riya h16 - Imam al-Baqir (mursal at last link) | Verified verbatim: «الإبقاء على العمل أشد من العمل قال وما الإبقاء على العمل قال يصل الرجل بصلة وينفق نفقة لله وحده لا شريك له فكتب له سرا ثم يذكرها وتمحى فتكتب له علانية ثم يذكرها فتمحى وتكتب له رياء». |
| "I am the best of partners" (beat 10) | al-Kafi 2:295, bab al-riya h9 - hadith qudsi via Imam al-Sadiq | Verified verbatim: «قال الله عز وجل أنا خير شريك من أشرك معي غيري في عمل عمله لم أقبله إلا ما كان لي خالصا» (note «في عمل عمله»). |
| The forty days (beat 13) | al-Kafi 2:16, bab al-ikhlas h6 - Imam al-Baqir | Verified verbatim: «ما أخلص العبد الإيمان بالله عز وجل أربعين يوما - أو قال ما أجمل عبد ذكر الله عز وجل أربعين يوما - إلا زهده الله عز وجل في الدنيا وبصره داءها ودواءها فأثبت الحكمة في قلبه وأنطق بها لسانه» (continues re: ahl al-bid'a - excerpted out). al-Kafi says forty DAYS; the «أربعين صباحا / فجر الله ينابيع الحكمة» wording is Uddat al-Da'i (via Bihar 70:249 entry 25), NOT used. |
| The three nights (beat 14) | Majma' al-Bayan of al-Tabrisi, Surah al-Insan, al-nuzul - vol 10 pp. 611-612 (Nasir Khosrow ed.); al-Amali of al-Saduq p. 212 h. 11 (Bihar 35:237); corroborated al-Kashshaf 4:670 | Majma' text verified verbatim (holyquran.net full text): illness; the Prophet ﷺ and the notables of the Arabs suggest the vow (plural وقالوا); Ali, Fatima AND Fidda vow three fasts on recovery; three sa's of barley borrowed (variant: earned by wool-spinning); Fatima grinds one sa' per day; miskin day 1, yatim day 2, asir day 3; refrain «ولم يذوقوا إلا الماء»; day 4 the Prophet ﷺ weeps and «نزل جبرائيل بسورة هل أتى». On 76:9 Majma' reports: «وقيل إنهم لم يتكلموا بذلك ولكن علم الله سبحانه ما في قلوبهم فأثنى به عليهم» (Sa'id ibn Jubayr, Mujahid) - the reflection's "never spoken at all" line. Loaf count (5) is Kashshaf-only - kept OUT of the beat. Captive per Qatada: from dar al-harb - beat says only "a captive". |
| Dua Kumayl (beat 16) | Misbah al-Mutahajjid of al-Tusi p. 844 (mursal, titled "Dua al-Khidr"); Iqbal al-A'mal of Ibn Tawus p. 220 (the Kumayl narration, mid-Sha'ban; taught to Kumayl ibn Ziyad al-Nakha'i; «فادع به كل ليلة جمعة أو في الشهر مرة...») | Petition verified letter-for-letter on two texts (thaqalayn.net + duas.pro): «وأسألك بحقك وقدسك وأعظم صفاتك وأسمائك أن تجعل أوقاتي في الليل والنهار بذكرك معمورة وبخدمتك موصولة وأعمالي عندك مقبولة حتى تكون أعمالي وأورادي كلها وردا واحدا وحالي في خدمتك سرمدا». NOTE (corrected at audit 2026-08-05): the canonical/dominant reading is «من الليل والنهار» - confirmed against WikiShia and multiple sources, one of them citing Misbah al-Mutahajjid itself; the app now uses «من». The first-pass «في» (attributed above to thaqalayn.net + duas.pro) was an error. Display trims to the petition body from «أن تجعل» (Tawakkul wa-trim precedent). |
| REJECTED: «الإخلاص سر من أسراري» qudsi | Munyat al-Murid p. 133 -> Bihar 70:249 e.24; editor sources it to al-Ghazali's Ihya 4:322 | No isnad in any Shia source; entered Shia literature 10th c. AH. Deliberately not used. |

**No-reuse ledger check (theme dives): CLEAN.** No verse, narration, scene, or dua overlaps with Yaqin/Sabr/Tawakkul/Shukr/Salah. Closing devotion extends the varied run: Sahifa #20 / Amali-Sadiq prayer / Sahifa #28 / Sahifa #37 / Tasbih of Fatima / now Dua Kumayl (Imam Ali - first Amir al-Mu'minin close). Reserved material honored: 76:8-9 was reserved FOR this dive (Shukr doc); Munajat Sha'baniyya (Rida/Dhikr) and Amr ibn Qaraza (wafa) untouched.

**Cross-product avoidances (surah journeys, taste-level):** 67:2 (SurahMulkDive beat + same al-Kafi gloss in its reflection) and 12:24 (SurahYusufDive beat "The Proof of His Lord") deliberately not used.

**Deliberately NOT used (available to future dives):** 6:162 (my living and my dying), 16:66 (the pure-milk khalis image), 92:19-21 (al-Layl - only seeking His Face), 18:110 (associate no one in worship), 107:4-6, 39:11-14, 33:33 (tathir - deserves its own home), the "worship of the free" tripartite (Nahj 237 / al-Kafi 2:84 / Tuhaf - banked; could anchor a future dive on worship/love), Imam Ali's "I found You worthy of worship" (pairs with that tripartite), the forty-mornings «ينابيع الحكمة» wording (Uddat al-Da'i).

## 6. Catalog + What's New (drafts - finalize at implementation)

- Catalog `ikhlas`: `available: true, dive: .ikhlas`. Subtitle EN: "A descent through three purities - Qur'an to the house of Fatima" (PENDING user approval of the non-Karbala formula break). UR draft: "تین پاکیزگیوں میں اترتا ایک سفر - قرآن سے خانۂ فاطمہؑ تک". AR draft: "نزولٌ عبر ثلاث صفاءات - من القرآن إلى بيت فاطمة عليها السلام". Title/titleAr/sfSymbol/cover unchanged.
- WhatsNew `deepDives-ikhlas`: sfSymbol `drop.fill`, destination `.deepDive("ikhlas")`, CTA "Begin the descent" / "نزول کا آغاز کریں" / "ابدأ النزول", `releaseDate` placeholder (adjust at ship). Blurb EN draft: "Ikhlas - The Unmixing: a descent through three purities, from the address every deed carries to the three secret nights of Surah al-Insan - and the one light that does not go out." UR/AR blurbs: to be authored at implementation.

## 7. Out of scope

- Urdu/Arabic dive content (EN-first; localize later like the others).
- No persistence of the extinguish interaction; no new audio assets.
- Remaining placeholder dives (Taqwa, Rida) untouched.

## 8. PARKED STATE (2026-07-29) - resume checklist

**RESOLVED 2026-08-05:** resumed and approved at Gate 2 ("build it", no copy edits; both flagged decisions kept). The notes below are retained as history.

**Where this stopped:** Gate 2 presentation delivered (design + mock); user parked the session WITHOUT approving. Nothing implemented; no Swift written; nothing committed.

**Open review points flagged to the user at the gate:**
1. The catalog subtitle "Qur'an to the house of Fatima" (first break of the "Qur'an to Karbala" formula).
2. The Last Light prompt wording: "Who else were you doing it for?"
3. Whether the vowel-turn language on the Purity III card (beat 11) reads clearly on first pass.

**To resume:** re-present or link `docs/mockups/ikhlas_mock.png`, collect Gate 2 verdict + any copy edits, update this doc's Status to Approved, then proceed per the `/theme-deep-dive` skill: Stage 3 implementation plan (`docs/plans/YYYY-MM-DD-ikhlas-deep-dive.md`) -> waves of max two subagents with build gates (wave 1: DeepDive.swift + DeepDiveView.swift atomic `extinguish` addition; wave 2: IkhlasDeepDive.swift transcribed verbatim from section 4; wave 3: catalog flip + What's New) -> Stage 4 own xcodebuild + guardrail greps -> Stage 5 four-auditor flag-only audit (A/B waves of two, Opus) -> Stage 6 close-out (memory update, releaseDate reminder, user simulator pass + commit).

**Verification is COMPLETE** - all matns in section 5 were fetched and verified this session (thaqalayn.net, lib.eshia.ir Islamiyya ed., holyquran.net Majma', tafsir.app Kashshaf, duas.pro, wikishia). Do not re-run the research agents; trust section 5.

## 9. Audit outcome (2026-08-05, four auditors, flag-only)

Built and audited 2026-08-05. Four auditors (A flow/ledger, B theology/sourcing/Arabic, C readability, D voice/reverence) on Opus, report-only. **No Blockers.** Ledger confirmed fully clean; the mukhliṣīn (98:5) / mukhlaṣīn (15:40) vowel pair confirmed correct. Section 4 above reflects the **applied** copy.

**Applied** (user-approved bundle "8 Should-fix + 6 Polish"):
- **S1** Beat 16 Kumayl: «فِي اللَّيْلِ» → «مِنَ اللَّيْلِ» (canonical; independently confirmed vs WikiShia + several sources, one citing Misbah al-Mutahajjid). Section 5 note corrected.
- **S2** Beats 05+11 vowel turn (the Gate-2 deferred point): 05 now names the singular root ("its singular is mukhlis, the one who purifies") and "Hold that word ... will turn"; 11 shows the flip ("From active to passive, on a single vowel") and drops "climbs into" → "makes himself into that second word". Fixes the mukhlisin/mukhlis callback mismatch + the un-hearable-sound problem.
- **S3** Beat 09 ledger body unstacked into full clauses (secret → erased/rewritten openly → erased/rewritten riya).
- **S4** Beat 13 body: "When a servant ... God ..." (was the archaic "No servant ... but God"); "the world's sickness".
- **S5** Beat 14 body: "the angel Jibril". **S6** "is given away" (was "passes out"). **S9** paragraph break after "the fasting begins." (`\n\n` in the Swift string; not shown inline here).
- **S7** Beat 14 reflection: "He proclaimed it" (was "published"). **P4** "the boys" (was "the weakened boys").
- **S8** Beat 15 note: "Every audience files out in the end." (was "leaves the theater").
- **P1** Beat 01: "how it is guarded from other eyes" (was "kept clean" - de-duplicates the opening "clean" triple). **P5** added the hinge "tracing".
- **P2** Beat 10 source: "Imam Ja'far al-Sadiq" (parallel with al-Baqir). **P3** Beat 06: "went further" (was "pressed it further"). **P7** Beat 12: "the one place his feet cannot enter" (was "one ground his feet cannot cross").

**Known, accepted** (flagged, not applied - taste/house-voice calls):
- Beat 05 "before the floor of this descent" (ornate) - kept. Beat 11 bridge 39:3 introducing a third form (khalis) - kept as scriptural reinforcement. Beat 13 leading with "labor/gift" - kept. Beat 12 optional one-word gloss for Iblis/"the whisperer" - kept (glossed in context). "litany" (16), "the other name on it" (10), "Majma'" apostrophe - kept.
- Auditor A observations, no change: Movement II is the densest stretch (3 riya beats 08-10, judged distinct not repetitive); Fatima anchors two adjacent dives (Salah close + this summit, deliberately foregrounded by the subtitle).

Post-fix build: **BUILD SUCCEEDED**; guardrails clean (em dashes 0, diacritics 0).
