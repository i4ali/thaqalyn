# Tawakkul Deep Dive - Design Spec

**Date:** 2026-07-16
**Status:** Approved (visual mock: `docs/mockups/tawakkul_mock.png` + `tawakkul_mock.html`)
**Feature:** The third immersive "Deep Dive" (after Yaqin and Sabr), on **Tawakkul** (reliance), shown in the Journeys tab. Premium-gated (veiled preview), like Sabr.

---

## 1. Summary & identity

Ship **Tawakkul - The Handing Over**: a single-sitting descent through **three motions of the trusting hand**, summiting at the morning of Ashura. Unlike Yaqin (depths of knowing) and Sabr (stations of bearing), Tawakkul lives in the hands: you do your part, then you hand the outcome over.

**Spine (approved): "The Handing Over."**

- **Movement I - al-'Azm (العَزْم) - "The Doing":** tawakkul is not passivity; resolve and take the means first (3:159).
- **Movement II - al-Tafwid (التَّفْوِيض) - "The Handing Over":** when the means run out, place the outcome in His hands (26:62, 40:44).
- **Movement III - al-Kifaya (الكِفَايَة) - "The Sufficiency":** whoever relies on Him, He is sufficient (65:3) -> Karbala.

**Honest turn at the summit:** at Karbala no sea split and no fire cooled - sufficiency is not always rescue; the trust was never placed in the outcome, but in Him.

**Two identity moves:**
1. First theme-dive use of the existing `response` beat ("He answers") - God's revelation to Dawud (al-Kafi).
2. One new interactive beat, **`release`** ("The Release"), replacing the standard `reflectionPrompt`: the reader presses and holds a ring (the grip), it fills, the label turns to "Now - let go", and lifting the finger IS the release - resolving into "I entrust my affair to God" (40:44).

Decisions from Q&A: engine additions allowed where content earns them; Karbala summit; **English-first** content (string literals; UR/AR later), matching how Sabr shipped.

## 2. Architecture

1. **Modify** `Thaqalayn/Models/DeepDive.swift` - add `case release(...)` to `DeepDiveSection` (+ its `act` mapping = 4).
2. **Modify** `Thaqalayn/Views/DeepDive/DeepDiveView.swift` - add `releasePage` renderer + hold/release state; add `placeInfo` entry; reset release state in the Amin block's "Begin again".
3. **Create** `Thaqalayn/Content/TawakkulDeepDive.swift` - `extension DeepDive { static let tawakkul }` (content in section 4). Synced folders: no pbxproj edit.
4. **Modify** `Thaqalayn/Services/DeepDiveCatalog.swift` - flip `tawakkul` to `available: true, dive: .tawakkul`, subtitle -> "A descent through three motions - Qur'an to Karbala" (UR: "تین حرکتوں میں اترتا ایک سفر - قرآن سے کربلا تک", AR: "نزولٌ عبر ثلاث حركات - من القرآن إلى كربلاء").
5. **Modify** `Thaqalayn/Models/WhatsNewItem.swift` - add `deepDives-tawakkul` announcement (EN/UR/AR).

Premium gating, veil, audio (VerseRecitationButton / DuaListenButton), reading scale: already handled by the engine. `TawakkulCover` asset already exists.

## 3. The `release` beat (engine addition)

```swift
/// The interactive close of a dive built on entrustment. The reader names what they
/// are gripping (in their heart), presses and holds the ring - that is the grip -
/// and the lifting of the finger IS the release, resolving into the entrusting verse.
case release(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
             arabic: String, translation: LocalizedText, reference: String,
             note: LocalizedText, nextLabel: LocalizedText)
```

Renderer behavior (`releasePage`):
- **Idle:** ✦ mark, serif prompt ("What are you gripping?"), italic subline, a thin gold ring (~120pt) with a small bright core, label "PRESS AND HOLD - THAT IS THE GRIP".
- **Holding:** finger down starts a ~2.2s linear ring fill (Circle trim), core grows/brightens, soft haptic on touch-down. When the fill completes while still holding: label swaps to "NOW - LET GO" (light haptic).
- **Released:** if the finger lifts after the fill completed -> success haptic, burst-glow crossfade into: Arabic `أُفَوِّضُ أَمْرِي إِلَى اللَّهِ` (goldBright, glow), translation, reference, note, and the bob (nextLabel) into the dua. Lifting early resets the ring gently.
- Honors `reduceMotion` (no burst/fill animation; simple state swaps) and reading scale on prompt/subline/note.
- "Begin again" (Amin block) resets the release state alongside `saidAmin`/`openDepths`.
- `placeInfo`: `("The Release", acts.count)` - all dots filled.

## 4. Full content (source of truth for transcription)

15 beats. Voice matches Yaqin/Sabr: spare literary prose, " - " never em dash, plain English spelling (house diacritics rule), curly quotes in quoted speech. Qur'an Arabic in the same plain (non-Uthmani) orthography the other dives use; verse beats anchor on a single ayah for recitation.

Metadata: id `tawakkul` · titleEn `Tawakkul` · titleAr `تَوَكُّل` · subtitle `Reliance - a descent through three motions` · sfSymbol `hands.and.sparkles` · estMinutes 5.

### 01 - `open`
- kicker: A DEEP DIVE · titleAr: تَوَكُّل · titleEn: Tawakkul · subtitle: Reliance
- line: A descent through the Qur'an and the Ahl al-Bayt - what the hands must do, and what they must let go.

### 02 - `orientation`
- eyebrow: Before you descend
- promise: Three motions of reliance lie below - to do your part, to hand the outcome over, and to be carried.
- leaveWith: You'll leave with a map of reliance - and a prayer that hands your affair to the One who holds it.

### 03 - `depths` - "The Three Motions" (act 0)
- tag: The Three Motions · reference: Al Imran 3:159 · al-Talaq 65:3
- items:
  1. العَزْم · al-'Azm · The Doing · "To rise and take the means - resolve, work, tie the camel." · ref nil · embodies: the hand that works
  2. التَّفْوِيض · al-Tafwid · The Handing Over · "When the means end, to place the outcome in His hands - and keep walking." · ref 40:44 · embodies: the hand that releases
  3. الكِفَايَة · al-Kifaya · The Sufficiency · "To be carried by the One you trusted - whose answer is Himself." · ref 65:3 · embodies: the family who was carried

### 04 - `act` I (connector nil, bridge nil)
- line: It begins in the hands. Tawakkul is not the folding of arms - it is the work done fully, then signed over to the One who holds the result.

### 05 - `verse` - Al Imran 3:159 (act 1, tag "Resolve, Then Rely")
- arabic: فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ ۚ إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ
- translation: "And when you have resolved, rely upon God. Indeed God loves those who rely."
- reference: Al Imran · 3 : 159
- reflection: The order of the verse is the whole teaching. Consult them, the Prophet is told; then resolve; then rely. Trust is what the resolved hand does with the outcome - not what the idle hand does instead of the work.

### 06 - `narration` - "The Unanswered Prayer" (act 1)
- source: Imam Ja'far al-Sadiq · al-Kafi, on seeking livelihood
- body: Four there are, said the Imam, whose prayer returns to them unanswered. One is the man who sits at home and says, "O Lord, provide for me" - and is told: have I not commanded you to seek?
- reflection: Tawakkul that skips the work is not trust - it is a request that God do your part, when He has already asked it of you.

### 07 - `act` II (connector "You have done what is yours.", bridge nil)
- line: Now - the harder motion. Open the hand. Trust is proven not while the means still work, but at the moment they end: the sea in front, the army behind.

### 08 - `verse` - al-Shu'ara 26:62 (act 2, tag "The Sea in Front")
- arabic: قَالَ كَلَّا ۖ إِنَّ مَعِيَ رَبِّي سَيَهْدِينِ
- translation: "He said: Never - indeed my Lord is with me; He will guide me."
- reference: al-Shu'ara · 26 : 62
- reflection: Pharaoh's army behind, the water ahead. "We are overtaken!" cry his people. The sea has not yet split when Musa answers - trust speaks before the way appears.

### 09 - `verse` - Ghafir 40:44 (act 2, tag "The Entrusted Affair")
- arabic: وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ ۚ إِنَّ اللَّهَ بَصِيرٌ بِالْعِبَادِ
- translation: "And I entrust my affair to God. Indeed God is ever seeing of His servants."
- reference: Ghafir · 40 : 44
- reflection: A lone believer in Pharaoh's court, his warning finished, hands the consequence over. The very next verse answers him: so God protected him from the evils they plotted.

### 10 - `act` III (connector "You have opened the hand.") + bridge al-Talaq 65:3
- line: Now - what receives it. On the other side of the release is not a void but a Trustee - and His promise is not always the outcome you asked for. It is Himself.
- bridge: surah 65 ayah 3 · وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ · "And whoever relies upon God - He is sufficient for him." · al-Talaq · 65 : 3

### 11 - `response` - He Answers (act 3)
- replyingTo: To the one who lets go of every rope but His
- arabic: جَعَلْتُ لَهُ الْمَخْرَجَ مِنْ بَيْنِهِنَّ
- words: "No servant of Mine takes refuge in Me rather than in My creation - I know it from his intention - but that if the heavens and the earth and all within them plotted against him, I would make for him a way out from among them all."
- source: His revelation to Dawud · al-Kafi
- reflection: Not that the plot stops - but that the way out is His to make. And the hand that grips creation instead finds the ropes of the heavens cut.

### 12 - `verse` - al-A'raf 7:196 (act 3, tag "The Verse He Answered With")
- arabic: إِنَّ وَلِيِّيَ اللَّهُ الَّذِي نَزَّلَ الْكِتَابَ ۖ وَهُوَ يَتَوَلَّى الصَّالِحِينَ
- translation: "Indeed my Protector is God, who sent down the Book - and He takes care of the righteous."
- reference: al-A'raf · 7 : 196
- reflection: Dawn at Karbala. The army is arrayed, and the histories record Husayn ending his address to it with this verse. He does not count their swords - he names his Protector.

### 13 - `climax` - "The Trust in Every Distress" (act 3)
- source: Imam al-Husayn, the morning of Ashura - al-Irshad of al-Mufid
- arabic: اللَّهُمَّ أَنْتَ ثِقَتِي فِي كُلِّ كَرْبٍ، وَرَجَائِي فِي كُلِّ شِدَّةٍ
- translation: "O God, You are my trust in every distress, and my hope in every hardship."
- body: As the army closed in, he raised his hands - not for rescue, but to name the One who held him: You are, in everything that befalls me, my confidence and my strength.
- reflection: No sea split that morning; no fire cooled. And the trust did not break - because it had never been placed in the outcome. It was placed in Him.

### 14 - `release` - "The Release" (NEW beat)
- tag: The Release
- prompt: What are you gripping?
- subline: A decision, a diagnosis, a debt, a child. Name it in your heart - you have carried it long enough.
- arabic: أُفَوِّضُ أَمْرِي إِلَى اللَّهِ
- translation: I entrust my affair to God.
- reference: Ghafir · 40 : 44
- note: It is in His hands now - the hands that do not drop what they hold.
- nextLabel: And one prayer
- (fixed renderer strings: "PRESS AND HOLD - THAT IS THE GRIP" / "NOW - LET GO")

### 15 - `dua` - "A Prayer of Fleeing to Him"
- intro: After the sea, after Karbala - one prayer, in the voice of the fourth Imam: the whole descent in two lines.
- arabic: اللَّهُمَّ إِنِّي أَخْلَصْتُ بِانْقِطَاعِي إِلَيْكَ، وَأَقْبَلْتُ بِكُلِّي عَلَيْكَ
- translation: "My God, I have cut myself off from all but You, and turned toward You with the whole of myself."
- source: Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Dua 28
- note: The great entrustings are not asked of you this morning. Only this: one grip loosened, one affair signed over to the One who does not drop what He holds.
- close: The trust is yours to keep.

## 5. Sourcing & verification (done 2026-07-16)

| Item | Source | Status |
|------|--------|--------|
| Ayat 3:159, 26:62, 40:44(-45), 65:3, 7:196 | Qur'an | Text checked against app `quran_data.json` (plain orthography per Yaqin/Sabr house style; recitation anchored per single ayah). |
| Four whose prayer is unanswered (beat 06) | al-Kafi (bab seeking rizq) / Da'awat al-Rawandi, from Imam al-Sadiq | Verified: man at home saying "يا رب ارزقني" told "ألم آمرك بالطلب". |
| Revelation to Dawud (beat 11) | al-Kafi, from Imam al-Sadiq | Verified verbatim: «ما اعتصم بي عبد من عبادي دون أحد من خلقي عرفت ذلك من نيته ثم تكيده السماوات والأرض ومن فيهن إلا جعلت له المخرج من بينهن…». |
| Morning-of-Ashura address ending 10:71 + 7:196 (beat 12) | Maqtal histories (al-Tabari et al.) | Verified; beat cites the ayah, prose says "the histories record". |
| "You are my trust in every distress" (beat 13) | al-Irshad of al-Mufid, vol 2 (~p. 96) | Verified: «اللهم أنت ثقتي في كل كرب ورجائي في كل شدة وأنت لي في كل أمر نزل بي ثقة وعدة». |
| Sahifa Dua 28 opening (beat 15) | al-Sahifa al-Sajjadiyya #28 (fleeing to God) | Verified: «اللهم إني أخلصت بانقطاعي إليك وأقبلت بكلي عليك». |

**Nothing reused from Yaqin/Sabr.** Explicitly avoided: Ibrahim's fire, the mother of Musa (Yaqin); Ya'qub, Ismail, Ayyub, the Last Night, the last prostration (Sabr). Sahifa duas differ (#20 Yaqin, #28 here).

## 6. Catalog + What's New

- Catalog `tawakkul`: `available: true`, `dive: .tawakkul`, subtitle per section 2. Title/titleAr/sfSymbol/cover unchanged.
- WhatsNew `deepDives-tawakkul` (sfSymbol `hands.and.sparkles`, destination `.deepDive("tawakkul")`, trilingual copy, "Begin the descent" CTA).

## 7. Out of scope

- Urdu/Arabic dive content (EN-first; localize later like Sabr).
- No persistence of the release interaction; no new audio assets.
- Remaining placeholder dives (Shukr, Ikhlas, Taqwa, Rida) untouched.
