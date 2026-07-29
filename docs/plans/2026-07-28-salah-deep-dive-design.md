# Salah Deep Dive - Design Spec

**Date:** 2026-07-28
**Status:** Approved (visual mock: `docs/mockups/salah_mock.png` + `salah_mock.html`)
**Feature:** The fifth immersive "Deep Dive" (after Yaqin, Sabr, Tawakkul, Shukr), on **Salah** (prayer), shown in the Journeys tab. Premium-gated (veiled preview), like the others. Requested arc: take a reader from not knowing the prayer's importance to seeing its value.

---

## 1. Summary & identity

Ship **Salah - The Believer's Ascent**: a single-sitting climb through the tradition's **three names for the prayer**, summiting at the Zuhr prayer of Ashura. Unlike every shipped dive, this one **ascends instead of descends** - the engine's journey verbs invert (Ascend / Begin the ascent / The ascent ends), because the tradition itself calls the prayer a climb.

**Spine (approved): "The Three Names."**

- **Name I - al-Mi'raj (المِعْرَاج) - "The Ascent":** the prayer was born at the summit of the heavens - fifty made five, five worth fifty (al-Faqih, Imam al-Sajjad to his son Zayd); its purpose is remembrance (20:14).
- **Name II - al-Munajat (المُنَاجَاة) - "The Conversation":** before Whom you stand (al-Irshad, Zayn al-Abidin's pallor at wudu); the hadith qudsi of the divided Fatiha - He answers every line (Uyun Akhbar al-Rida); the nearest point is prostration (96:19 + al-Kafi 3:264, Imam al-Rida).
- **Name III - al-Qurban (القُرْبَان) - "The Offering":** guard the prayers (2:238); what Ibrahim paid (14:37); the dying Imam al-Sadiq's last sentence (Amali al-Saduq) -> the Zuhr of Ashura, prayed under arrows behind a human shield.

**Persuasion arc (the requested journey):** movement I reframes the prayer from tax to gift; movement II from monologue to answered conversation; movement III from ritual to the thing people died defending. The reader is carried from "why does this matter" to "this is the most valuable thing I own."

**Identity moves:**
1. **The engine inversion** - first ascending dive: six fixed "descent" strings (plus the hint icon) become per-dive configurable (defaults unchanged for the four shipped dives); `stageNoun`/`stageWord` = "Name" (place-bar reads "Name II · The Conversation").
2. Third use of the `response` beat, and the first where the reply is to **the reader** (not a prophet): the hadith qudsi of the divided Fatiha, Uyun Akhbar al-Rida.
3. One new interactive beat, **`sujud`** ("The Last Rung"): press and hold - the held stillness IS the prostration; a point of light sinks to the earth-line, the turn label reads "STAY - THIS IS THE NEAREST POINT", and the verse (96:19) resolves while still held. The dive that climbs ends by going down.
4. **Series patterns consciously broken** (per Shukr audit finding 16's request for the next dive): the close is NOT a Sahifa-Sajjad dua and drops the "not asked of you... Only this:" formula - it is the **Tasbih of Fatima**, the Prophet's gift to his daughter (first Fatima presence in the series); the dua note ends "Begin tonight."

**Karbala summit newly earned:** the Zuhr prayer of Ashura is a scene no shipped dive has used (Yaqin: the radiant face + Zaynab's court; Sabr: the Last Night + last prostration; Tawakkul: the dawn address + trust dua; Shukr: the eve-of-Ashura praise). No scene-level echo: this is noon, mid-battle - a fifth, untouched hour of that day.

Decisions from Q&A: topic Salah (user-requested, not the catalog's next roadmap entry); "Three Names / Ascent" spine over "The Audience" and "One Day, Five Lights" alternatives; new `sujud` beat over the plain `reflectionPrompt` (both were mocked; user chose A); Tasbih-of-Fatima close; **English-first** content (string literals; UR/AR later), matching all shipped dives.

## 2. Architecture

1. **Modify** `Thaqalayn/Models/DeepDive.swift`:
   - Add five per-dive journey-verb strings with house defaults (existing dives untouched):
     `var descendCta: String = "Descend"` (open-beat bob), `var beginCta: String = "Begin the descent"` (orientation bob), `var mapLine: String = "The map for everything below."` (threshold subline), `var stageWord: String = "Movement"` (act-card big label + place-bar noun), `var endLine: String = "The descent ends."` (amin block), plus the orientation scroll-hint pair `var scrollHint: String = "Scroll to sink deeper"` / `var scrollHintIcon: String = "arrow.down"` (added post-ship 2026-07-28 when the fixed hint surfaced in the simulator pass).
   - Add `case sujud(...)` to `DeepDiveSection` (+ act mapping = 4, grouped with reflectionPrompt/release/count/dua/closing).
2. **Modify** `Thaqalayn/Views/DeepDive/DeepDiveView.swift` - swap the five hardcoded strings for the dive's fields; add `sujudPage` renderer + hold/sink state; `placeInfo` entry; reset sujud state in the Amin block's "Begin again" and invalidate its timer there and in `.onDisappear`.
3. **Create** `Thaqalayn/Content/SalahDeepDive.swift` - `extension DeepDive { static let salah }` (content in section 4). Synced folders: no pbxproj edit.
4. **Modify** `Thaqalayn/Services/DeepDiveCatalog.swift` - NEW descriptor after `shukr` (this dive is not a roadmap placeholder): id `salah`, title `Salah · Prayer` (UR "نماز", AR "الصلاة"), titleAr `صَلَاة`, sfSymbol `stairs`, subtitle "An ascent through three names - Qur'an to Karbala" (UR: "تین ناموں میں چڑھتا ایک سفر - قرآن سے کربلا تک", AR: "صعودٌ عبر ثلاثة أسماء - من القرآن إلى كربلاء"), `available: true, dive: .salah`, `coverAssetName: "SalahCover"` - cover art generated 2026-07-28 via Higgsfield (nano_banana 4:5 still, 2K upscale, house style: monumental stone stairway rising into an emerald starry night, lantern-gold base light; master at `assets/premium-art/covers/cover_salah.png`, bundled 1170x1463 JPG in `SalahCover.imageset`). A `KawtharCover` was produced the same way in the same session for the Kawthar surah experience (glowing river through dark dunes).
5. **Modify** `Thaqalayn/Models/WhatsNewItem.swift` - add `deepDives-salah` announcement (EN/UR/AR), CTA "Begin the ascent" / "صعود کا آغاز کریں" / "ابدأ الصعود", `releaseDate` = placeholder (adjust at ship).

Premium gating, veil, audio (VerseRecitationButton / DuaListenButton), reading scale: engine-level, no per-dive code.

## 3. The `sujud` beat (engine addition)

```swift
/// The interactive close of a dive built on prayer and nearness. The reader presses
/// and holds - the held stillness IS the prostration: a point of light sinks to the
/// earth-line while the screen draws close, and the verse resolves while still held.
/// Lifting the finger afterward is the rising from sujud, into the closing dua.
case sujud(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
           arabic: String, translation: LocalizedText, reference: String,
           note: LocalizedText, nextLabel: LocalizedText)
```

Renderer behavior (`sujudPage`), following the release/count recipe exactly:
- **Idle:** ✦ mark, serif prompt ("Go down - and draw near."), italic subline, a thin gold ring (~120pt) with a small bright core resting at its TOP, a faint horizontal earth-line beneath the ring; label "PRESS AND HOLD - GO DOWN".
- **Holding:** soft haptic on touch-down; the core sinks from the ring's top to its bottom over ~2.2s (linear), the ring warming and brightening as it descends. When the core reaches the bottom while still held: light haptic, label swaps to goldBright "STAY - THIS IS THE NEAREST POINT".
- **Resolve:** after ~2s more of continued hold (or on lift after the turn): success haptic; burst-glow crossfade into Arabic `وَاسْجُدْ وَاقْتَرِبْ` (goldBright, glow), translation, reference, hairline, note, and the bob (nextLabel) into the dua. Lifting early (before the turn) resets the core gently to the top.
- Honors `reduceMotion` (no sink animation; simple state swaps) and reading scale on subline/note/translation (NOT the prompt or fixed labels).
- "Begin again" (Amin block) resets all sujud state alongside `saidAmin`/`openDepths`; any timer invalidated there and in `.onDisappear`.
- `placeInfo`: `("The Last Rung", acts.count)` - all dots filled.
- Fixed renderer strings (EN-only for now): "PRESS AND HOLD - GO DOWN" / "STAY - THIS IS THE NEAREST POINT".

## 4. Full content (source of truth for transcription)

16 beats. Voice matches the four shipped dives: spare literary prose, " - " never an em dash, plain English spelling (house diacritics rule), curly quotes only inside quoted speech. Qur'an Arabic in plain (non-Uthmani) orthography; verse beats anchor a single ayah for recitation (96:19 and 14:37 shown as excerpts per the Sabr 12:86 precedent).

Metadata: id `salah` · titleEn `Salah` · titleAr `صَلَاة` · subtitle `Prayer - an ascent through three names` · sfSymbol `stairs` · estMinutes 5 · stageNoun `Name` · stageWord `Name` · descendCta `Ascend` · beginCta `Begin the ascent` · mapLine `The map for everything above.` · endLine `The ascent ends.` · scrollHint `Scroll to climb higher` (icon `arrow.up`)

Acts: 1 المِعْرَاج al-Mi'raj "The Ascent" · 2 المُنَاجَاة al-Munajat "The Conversation" · 3 القُرْبَان al-Qurban "The Offering".

### 01 - `open`
- kicker: A DEEP DIVE · titleAr: صَلَاة · titleEn: Salah · subtitle: Prayer
- line: An ascent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - where the prayer was given, what it truly is, and what it is worth.

### 02 - `orientation`
- eyebrow: Before you climb
- promise: The tradition gave the prayer three names - the ascent, the conversation, the offering. The climb ahead passes through all three.
- leaveWith: You'll leave seeing the five prayers differently - and with a gift from the Prophet's ﷺ family to carry into every one.

### 03 - `depths` - "The Three Names" (act 0)
- tag: The Three Names · reference: al-Faqih · Uyun al-Rida · Nahj al-Balagha
- items:
  1. المِعْرَاج · al-Mi'raj · The Ascent · "Given above the seven heavens, on the night the Prophet ﷺ rose past them - and carried down for you." · ref nil · embodies: the Prophet ﷺ who carried it down
  2. المُنَاجَاة · al-Munajat · The Conversation · "To stand and speak - and be spoken back to." · ref nil · embodies: the servant who is answered
  3. القُرْبَان · al-Qurban · The Offering · "What draws near to Him - guarded, whatever it costs." · ref nil · embodies: the family who paid its price

### 04 - `act` I (connector nil, bridge nil)
- line: It begins at the top. Every revelation came down to the Prophet ﷺ - once, he went up. What he carried back down from that night above the heavens was this - and the name never left it: the tradition still calls the prayer the believer's ascent.

### 05 - `narration` - "The Night of Fifty" (act 1)
- source: Imam Ali ibn al-Husayn · Man la yahduruh al-Faqih
- body: On the night the Prophet ﷺ was taken up through the heavens, fifty prayers were written upon his people. He would not ask his Lord for less - it was Musa, whom he had passed among the heavens, who pressed him: go back, ask him to lighten it. And when fifty had become five, the word came down: “They are five, worth fifty. The word is not changed with Me.”
- reflection: This is its birth: not a burden imposed, but a mercy pleaded down - with the full reward left attached. Five, carrying fifty. The prayer arrived as a gift twice over.

### 06 - `verse` - Ta-Ha 20:14 (act 1, tag "What It Is For")
- arabic: إِنَّنِي أَنَا اللَّهُ لَا إِلَٰهَ إِلَّا أَنَا فَاعْبُدْنِي وَأَقِمِ الصَّلَاةَ لِذِكْرِي
- translation: "Indeed I - I am God; there is no god but Me. So worship Me, and establish the prayer for My remembrance."
- reference: Ta-Ha · 20 : 14
- reflection: Musa, alone in the sacred valley, called by a Voice out of a fire. The command that follows “I am God” is worship - and the one act it names is the prayer. For My remembrance: not because He forgets you, but because you forget Him. Five times a day, the forgetting is interrupted.

### 07 - `act` II (connector "You have seen where it was given.", bridge nil)
- line: Now - stand inside it. The second name means the intimate conversation. You thought you were reciting into silence - the tradition says the one who prays is conversing with his Lord. And He answers back.

### 08 - `narration` - "Before Whom You Stand" (act 2)
- source: Imam Ali ibn al-Husayn · al-Irshad of al-Mufid
- body: When Imam Ali ibn al-Husayn, the fourth Imam, made the ablution before prayer, his face would turn pale. His family asked: what is this that comes over you? He said: "Do you know before Whom I am preparing to stand?"
- reflection: He was not afraid of the prayer - he was awake to it. The words are the same ones you say. The difference is that he knew Who was listening.

### 09 - `response` - He Answers (act 2)
- replyingTo: To the servant who stands and says: All praise belongs to God, Lord of the worlds
- arabic: حَمِدَنِي عَبْدِي
- words: "I have divided the Opening of the Book between Me and My servant - half is Mine, half is his, and his is what he asks. When he begins with My name: it is binding on Me to complete his affairs. When he praises Me: My servant has praised Me."
- source: The hadith qudsi of the Fatiha · Uyun Akhbar al-Rida of al-Saduq
- reflection: The Opening of the Book - the Fatiha you recite in every prayer - was never a monologue. You spoke one half; He answered the other, line for line, even the ones you rushed half-asleep. You have never once prayed unanswered.

### 10 - `verse` - al-Alaq 96:19 (act 2, tag "The Nearest Point")
- arabic: وَاسْجُدْ وَاقْتَرِبْ
- (Excerpt of the ayah per the Sabr 12:86 precedent - the full verse opens "No - do not obey him"; recitation plays the full verse.)
- translation: "Prostrate - and draw near."
- reference: al-Alaq · 96 : 19
- reflection: Imam al-Rida said: a servant is never nearer to God than in prostration - and he named this verse as the proof. The ladder runs inverted: its highest rung is the floor. The world calls it lowering yourself. The prayer calls it arriving.

### 11 - `act` III (connector "You have heard Him answer - and felt how near He lets you come.") + bridge al-Baqarah 2:238
- line: Now - the costly name. The prayer, said Imam Ali, is the offering of every God-conscious soul. An offering is weighed by what it costs the hands that bring it.
- bridge: surah 2 ayah 238 · حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ · "Guard the prayers - and the middle prayer - and stand before God devoutly." · al-Baqarah · 2 : 238

### 12 - `verse` - Ibrahim 14:37 (act 3, tag "What Ibrahim Paid")
- arabic: رَبَّنَا إِنِّي أَسْكَنتُ مِن ذُرِّيَّتِي بِوَادٍ غَيْرِ ذِي زَرْعٍ عِندَ بَيْتِكَ الْمُحَرَّمِ رَبَّنَا لِيُقِيمُوا الصَّلَاةَ
- (Excerpt; recitation plays the full verse.)
- translation: "Our Lord, I have settled some of my descendants in a valley without cultivation, by Your sacred House - our Lord, that they may establish the prayer."
- reference: Ibrahim · 14 : 37
- reflection: A wife and an infant, left in a dead valley - and the reason he gives God is the prayer. Makkah, the House, the direction you face five times a day: a city exists because one man thought the prayer worth that much.

### 13 - `narration` - "The Last Sentence" (act 3)
- source: Imam Ja'far al-Sadiq, at his death · al-Amali of al-Saduq
- body: As Imam Ja'far al-Sadiq, the sixth Imam, lay dying, he opened his eyes and said: gather to me every relative of mine. When they had assembled, he looked at them and said: “Our intercession will not reach one who takes the prayer lightly.”
- reflection: A dying man spends his last sentence on the heaviest thing he knows. Intercession - the Imams' pleading before God for their own - was the inheritance of that room; and he tied it to the prayer, held at its full weight.

### 14 - `climax` - "The Prayer Under Arrows" (act 3)
- source: Imam al-Husayn to Abu Thumama, noon of Ashura · Tarikh al-Tabari · al-Luhuf of Ibn Tawus
- arabic: ذَكَرْتَ الصَّلَاةَ، جَعَلَكَ اللَّهُ مِنَ الْمُصَلِّينَ الذَّاكِرِينَ
- translation: "You remembered the prayer - may God place you among the praying, the remembering."
- body: Noon on Ashura - the tenth of Muharram, on the plain of Karbala. Most of Imam Husayn's men already lie dead when Abu Thumama, one of his last companions, notices the sun at its height: I would love to meet my Lord having prayed this one last prayer. They ask for the fighting to pause while they pray; it does not pause. So the prayer is prayed under the arrows. Sa'id ibn Abdullah stands in front of the Imam, taking them with his own body, and falls at last with thirteen arrows in him: O God - convey my greeting to Your Prophet, and tell him what I met of the pain of these wounds.
- reflection: God's own law would have excused a delay - a battlefield is reason enough. But the third name is the offering, and they held it up on time, at the price of a man. On that plain, nobody thought the prayer was a ritual. It was the thing being defended.

### 15 - `sujud` - "The Last Rung" (NEW beat)
- tag: The Last Rung
- prompt: Go down - and draw near.
- subline: Press and hold - and let the stillness stand in for the sajdah, the prostration.
- arabic: وَاسْجُدْ وَاقْتَرِبْ
- translation: Prostrate - and draw near.
- reference: al-Alaq · 96 : 19
- note: The nearest point is yours five times a day. What they guarded under arrows asks of you only a floor, a forehead, and the willingness to arrive.
- nextLabel: And one gift
- (fixed renderer strings: "PRESS AND HOLD - GO DOWN" / "STAY - THIS IS THE NEAREST POINT")
- (Deliberate in-dive reuse of 96:19, per the Tawakkul precedent of 40:44 in beat 09 + the release.)

### 16 - `dua` - "The Gift After Every Prayer" (Tasbih of Fatima)
- tag: The Gift After Every Prayer
- intro: After the summit - one gift to carry home. When the hand-mill had blistered the hands of Fatima, the Prophet's ﷺ daughter, her husband Imam Ali sent her to ask her father for a servant. Instead of a servant, her father came to them himself: shall I not teach you both something better?
- arabic: اللَّهُ أَكْبَرُ، وَالْحَمْدُ لِلَّهِ، وَسُبْحَانَ اللَّهِ
- translation: "God is greater - thirty-four times. All praise belongs to God - thirty-three. Glory be to God - thirty-three."
- source: The Prophet's ﷺ gift to Fatima al-Zahra · Man la yahduruh al-Faqih
- note: Say it after every prayer, before you rise from your place. Imam al-Sadiq called it dearer than a thousand rak'ahs - a thousand cycles of prayer - each day, and said that whoever keeps it is forgiven. One hundred small words, the whole ascent walked again. Begin tonight.
- close: The prayer is yours to keep.

## 5. Sourcing & verification (done 2026-07-28, two research passes)

| Item | Source | Status |
|------|--------|--------|
| Ayat 20:14, 96:19, 2:238, 14:37 | Qur'an | Text checked against app `quran_data.json` (plain orthography per house style; recitation anchored per single ayah; 96:19 and 14:37 shown as excerpts per Sabr 12:86 precedent). |
| The Night of Fifty (beat 05) | Man la yahduruh al-Faqih 1:126 h603 (Zayd b. Ali asks Imam al-Sajjad) + 1:125 h602; Ilal al-Sharai p132 b112; al-Tawhid p176; Wasail 4:16-17 | Verified verbatim: the Prophet «لا يقترح على ربه ولا يراجعه»; Musa's urging; «إنها خمس بخمسين ما يبدل القول لدي». NOTE: the Shia matn is "خمس بخمسين" (five worth fifty) - the "five and fifty" phrasing is Bukhari's and is NOT used. |
| Divided Fatiha (beat 09) | Uyun Akhbar al-Rida vol 1, Bab 28 (hadith qudsi via the Imams from Amir al-Mu'minin from the Prophet) | Verified verbatim: «قسمت فاتحة الكتاب بيني وبين عبدي فنصفها لي ونصفها لعبدي ولعبدي ما سأل... بدأ عبدي باسمي وحق علي أن أتمم له أموره... حمدني عبدي...». NOTE: the Shia text divides "فاتحة الكتاب" (the Opening of the Book), not "الصلاة" - beat copy says "the Opening of the Book". |
| Wudu pallor (beat 08) | al-Irshad of al-Mufid 2:142-143 (also al-Manaqib 4:148, Bihar 46:73 h16) | Verified verbatim: «كان علي بن الحسين إذا توضأ اصفر لونه فيقول له أهله: ما هذا الذي يغشاك؟ فيقول: أتدرون لمن أتأهب للقيام بين يديه». |
| Nearest in sajdah + 96:19 (beat 10) | al-Kafi 3:264 h3, kitab al-salat, bab fadl al-salat - **Imam al-Rida** | Verified verbatim: «أقرب ما يكون العبد من الله عز وجل وهو ساجد وذلك قوله عز وجل واسجد واقترب» - the verse tie is in the matn itself. (Faqih 1:134 h628 has al-Sadiq's mursal version.) |
| "Offering of every God-conscious" (beat 11 line) | Nahj al-Balagha, hikma 136 (Subhi al-Salih; 131/133 in other numberings) - Imam Ali; also al-Kafi 3:265 h6 (there from Imam al-Rida) | Verified verbatim: «الصلاة قربان كل تقي». Beat attributes to Imam Ali per Nahj. |
| The Last Sentence (beat 13) | al-Amali of al-Saduq p391 h10; al-Mahasin of al-Barqi p80 h6; Iqab al-A'mal p272; Wasail 4:26-27 h4423 (Abu Basir from Umm Hamida) | Verified verbatim: «اجمعوا كل من بيني وبينه قرابة... إن شفاعتنا لا تنال مستخفا بالصلاة». **Correction applied:** the gathered-relatives scene is NOT in al-Kafi - al-Kafi 3:270 h15 is the short father-to-son version (to Imam al-Kadhim). Beat cites al-Amali. |
| Zuhr of Ashura (beat 14) | Abu Thumama exchange + salat al-khawf: Tarikh al-Tabari 5:439-441 (Abu Mikhnaf) + Bihar 45:21. Sa'id's shielding, dying dua, 13 arrows: al-Luhuf p66 / Bihar 45:21 (NOT in Tabari - verified negative) | Verified verbatim: «ذكرت الصلاة جعلك الله من المصلين الذاكرين، نعم هذا أول وقتها... سلوهم أن يكفوا عنا حتى نصلي»; Luhuf: Zuhayr + Sa'id ordered in front with half the remaining men, salat al-khawf; Sa'id «اللهم العنهم لعن عاد وثمود، اللهم أبلغ نبيك عني السلام وأبلغه ما لقيت من ألم الجراح...» + «فوجد به ثلاثة عشر سهما». **Correction applied:** the "أوفيت؟ / نعم أنت أمامي في الجنة" exchange belongs to Amr ibn Qaraza al-Ansari (Luhuf p64, Bihar 45:22), NOT Sa'id - popular conflation, kept out; Sa'id's verified dying words used instead. Abu Thumama's nisba is al-Sa'idi (الصائدي), not "al-Saidawi" - beat uses first name only. |
| Tasbih of Fatima (beat 16) | Origin: Man la yahduruh al-Faqih 1:320-321 h947 (blistered hands, «أفلا أعلمكما ما هو خير لكما من الخادم»). Merit + order: al-Kafi 3:342 h6 («قبل أن يثني رجليه من صلاة الفريضة غفر الله له وليبدأ بالتكبير»), h9 (34 takbir, 33 tahmid, 33 tasbih), h15 («أحب إلي من صلاة ألف ركعة في كل يوم») | Verified verbatim. **Correction applied:** the origin story is NOT in al-Kafi (3:342-343 read in full) - beat cites al-Faqih. Order confirmed: Allahu akbar 34 first. |

**Nothing reused from Yaqin/Sabr/Tawakkul/Shukr.** No verse overlaps (ledger checked across all four content files + design docs). No Karbala scene-level echo: the Zuhr prayer is a new hour of Ashura (noon), distinct from the eve (Sabr/Shukr), the dawn (Tawakkul/Yaqin's morning), and the court (Yaqin). Closing devotion breaks the Sahifa run (#20/#28/#37 + Muhaj): the Tasbih of Fatima, from al-Faqih/al-Kafi. The `response` beat parallels Tawakkul (Dawud) and Shukr (Musa) with a deliberate variation: the reply is to the reader's own Fatiha.

**Deliberately NOT used (available to future dives):** 29:45 (prayer restrains - Friday-sermon register), 2:45 (sabr-and-salah - Sabr's territory), 74:42-43 (the people of Saqar - threat register), 23:1-2, 70:19-23, 107:4-5, 19:59; Habib ibn Mazahir's retort at the prayer (Tabari sequences his death BEFORE the prayer; the taunter's identity is confused across sources - Husayn b. Tamim in Tabari vs b. Numayr in Bihar); the Amr ibn Qaraza "have I been faithful?" exchange (Luhuf p64 - **reserved: a future dive on wafa/loyalty could summit on it**); Munajat Sha'baniyya (candidate close, held back - fits a future Rida or Dhikr dive); the al-Kafi 3:270 father-to-son deathbed version.

## 6. Catalog + What's New

- Catalog: NEW `salah` descriptor after `shukr` (see section 2.4). `coverAssetName: nil` until SalahCover art is produced (follow-up; premium-art pipeline).
- WhatsNew `deepDives-salah` (sfSymbol `stairs`, destination `.deepDive("salah")`, trilingual copy, CTA "Begin the ascent" / "صعود کا آغاز کریں" / "ابدأ الصعود", `releaseDate` placeholder - adjust at ship time).

## 7. Out of scope

- Urdu/Arabic dive content (EN-first; localize later like the others).
- SalahCover art asset (follow-up; catalog ships with `coverAssetName: nil`).
- No persistence of the sujud interaction; no new audio assets.
- Remaining placeholder dives (Ikhlas, Taqwa, Rida) untouched. The al-Insan feeding narrative remains reserved for Ikhlas.

## 8. Audit outcome (2026-07-28)

Four flag-only auditors run per the `/theme-deep-dive` skill (A flow/ledger, B theology/sourcing, C readability, D voice/reverence), in two waves of two. Consolidated: 1 Blocker + 17 Should-fix + 4 Polish buckets. **The Blocker and all 17 Should-fix items were approved and applied** to `SalahDeepDive.swift`; section 4 above reflects the post-audit content. Highlights of what changed:

- 1 (Blocker): climax reflection "Heaven itself would have excused a battlefield" (readable as a false fiqh claim) -> "God's own law would have excused a delay - a battlefield is reason enough."
- 2: Imam Husayn, Karbala, and Ashura are now named in the climax body; the headline quote is attributed in the source line ("Imam al-Husayn to Abu Thumama"); Abu Thumama roled ("one of his last companions").
- 3: "He would not haggle with his Lord" -> "He would not ask his Lord for less"; commercial cluster thinned (tax->burden, wage->reward).
- 4: dua intro mis-parse fixed (her father IS the Prophet ﷺ, stated in-text); "her husband Imam Ali".
- 5: "No arrows required" -> "What they guarded under arrows asks of you only a floor, a forehead, and the willingness to arrive."
- 6: "your stillness is the sajdah" -> "let the stillness stand in for the sajdah, the prostration" (also un-restates the payoff).
- 7-18: climax sentence stack broken up; "half a dialogue" -> "was never a monologue" with Fatiha glossed; burning-bush scene named + "first command" precision (worship first, prayer the named act); Musa placed in the heavens + divine word quoted; Imams named in bodies with ordinals as gloss; intercession glossed; Ahl al-Bayt glossed in the open line; "five prayers changed" -> "seeing the five prayers differently"; rak'ahs glossed; beat-10 attribution led with the speaker; the naming move made explicit in act I; act III connector folds in nearness; threshold "line by line" spoiler softened; depths map "the Beloved" -> "the Prophet ﷺ" and the superlative dropped.

**Declined - known, accepted (Polish, items 19-22):** the two adjacent Musa scenes stay unwelded; "It begins at the top" keeps its unresolved inversion hook; "his is what he asks", "What draws near to Him", unnamed Hajar/Isma'il, no in-dive gloss for "the middle prayer", "pleaded down" idiom; consistency nits ("Uyun al-Rida" short form in the threshold reference, "hadith qudsi" as a source-line term, quote-mark treatment in the climax body, counts living in the tasbih translation, no clause crediting the Imams for the tasbih's after-prayer placement). Recorded-only: ladder-image echo with Shukr's response reflection (vary next time one of the two is touched), the optional wusta-=-Zuhr tafsir link on the 2:238 bridge (available to a future pass), "yours to keep" close cadence (kept - it completes the series formula deliberately).
