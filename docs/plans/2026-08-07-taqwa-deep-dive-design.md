# Taqwa Deep Dive - Design: "The Three Walls"

- **Date:** 2026-08-07
- **Status:** Approved at Gate 1 (spine) and Gate 2 (design). Ready to implement.
- **Skill:** `/theme-deep-dive`. Reference dives: Yaqin/Sabr/Tawakkul/Shukr/Salah/Ikhlas.
- **Mock:** `docs/mockups/taqwa_mock.html` / `.png` (15 beats + 3 states of the new `door` beat).
- **Scope:** English-first (bare `LocalizedText` string literals; UR/AR a later pass). This
  doc is the **single source of truth**; implementers transcribe strings verbatim, never rewrite.

---

## 1. Summary & Identity

Taqwa's root **و-ق-ي** (waqa / wiqaya) means *to place a guard/shield between the soul and
harm*. The dive is **one guarding awareness, posted three times, each deeper in** - the
classical three degrees of taqwa (Imam al-Sadiq): guard against the **forbidden**, then the
**doubtful** (wara'), then keep the heart **for Him alone** (haqqa tuqatih / muraqaba). The
heart is a fortress (Nahj al-Balagha's *hisn*); the guard draws inward wall by wall.

The turn that lifts taqwa above "restriction": Imam Ali's teaching that **taqwa is
emancipation from every bondage** (Nahj al-Balagha, Sermon 230) - *fear that frees*. The
summit enacts it: **al-Hurr al-Riyahi**, the enemy commander whose fear of God outweighed
his fear of the tyrant, freed with an hour left to live.

- **Spine identity (unique vs shipped):** the *guard / fortress* (vs depths / stations /
  motions / tongues / names / purities). Matches the catalog art (`shield`) and the catalog
  line "the awareness that guards the heart."
- **Direction:** descent (the guard drawing inward). Station noun **"Guard"**. ~5 min, 15 beats.
- **Ladder note (optional flavor):** al-Kafi H1535 places taqwa one rung below yaqin - this
  dive sits beneath the shipped Yaqin dive on the same ascent.

### The four identity moves
1. **The guard/fortress spine** - an image no shipped dive owns.
2. **Fear that frees** - reframes taqwa from cage to liberation; climaxes on the man named "the Free."
3. **The `response` beat's 5th recipient** - a *hadith qudsi* answering the God-fearing
   (fear here → security there), setting up al-Hurr's trade.
4. **"The Open Door" (new `door` beat)** - the series' first inversion: every prior interactive
   close *rewards acting* (tap/press/hold); this makes **withholding the gesture**. Pays off the
   beat-6 "open door" narration.

---

## 2. Architecture (beat map)

15 beats. Orientation (beat 02) uses identical chrome to the shipped dives (omitted from mock).

| # | Beat | Act | Tag / role | Anchor |
|---|---|---|---|---|
| 1 | `open` | 0 | Cover | تَقْوَىٰ / Taqwa / God-consciousness |
| 2 | `orientation` | 0 | Before you descend | promise + leaveWith |
| 3 | `depths` | 0 | "The Three Guards" (map) | al-Khawf / al-Wara' / al-Muraqaba |
| 4 | `act` I | 1 | al-Khawf / The Fear (connector nil) | - |
| 5 | `verse` | 1 | "Guard Yourselves" | 66:6 (excerpt) |
| 6 | `narration` | 1 | "The Open Door" (seeds close) | al-Sadiq, al-Kafi (obedience & taqwa) |
| 7 | `act` II | 2 | al-Wara' / The Scruple (connector) | - |
| 8 | `verse` | 2 | "Look to Tomorrow" | 59:18 (excerpt) |
| 9 | `narration` | 2 | "The Hardest Worship" | al-Baqir & al-Sadiq, al-Kafi (wara') |
| 10 | `act` III + bridge | 3 | al-Muraqaba / The Watch (connector) | bridge 3:102 (excerpt) |
| 11 | `verse` | 3 | "What Reaches Him" | 22:37 (excerpt) |
| 12 | `response` | 3 | "He Answers" (hadith qudsi) | al-Jawahir al-Saniyya · Bihar v.67 |
| 13 | `climax` | 3 | "The Free Man" (summit) | al-Hurr · al-Irshad 2 · al-Tabari 5 |
| 14 | `door` | 4 | "The Open Door" (NEW interactive) | 79:40-41 |
| 15 | `dua` | 4 | "A Prayer in Fear" + Amin | Sahifa Sajjadiyya #50 |

**Summit echo (declared deliberate):** five shipped dives summit at Karbala. Taqwa also
summits at Karbala **but on a figure used by none of them (al-Hurr) and a lens used by none
(taqwa-as-freedom / repentance)**. This satisfies the re-visit rule; the freedom doctrine
also stands independently on Nahj 230.

---

## 3. New beat: `door` ("The Open Door") - engine spec

The only earned interactive close for taqwa: the gesture is **restraint**. A warm "forbidden"
opening drifts across; **not touching it** is the whole of it. Full code lives in the
implementation plan; this is the behavioral contract.

**Model** (`DeepDive.swift`) - same 8-field shape as `release`/`count`/`sujud`/`extinguish`:
```swift
case door(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
          arabic: String, translation: LocalizedText, reference: String,
          note: LocalizedText, nextLabel: LocalizedText)
```
Add `.door` to the act-4 group in the computed `act`:
```swift
case .reflectionPrompt, .release, .count, .sujud, .extinguish, .door, .dua, .closing: return 4
```

**Renderer states** (`doorPage`, mirroring `extinguishPage`):
- **idle:** ✦ mark; serif prompt (fixed size); scaled italic subline; the warm door glow
  resting near center; uppercased gold instruction **"Do not touch it - let it pass"**.
- **active (drifting):** the door glow drifts across (SwiftUI offset animation over
  `driftDuration ≈ 4.5s`; reduceMotion: static glow, no drift). Prompt dims; a thin gold
  "restraint" progress line fills as the glow crosses; instruction swaps to goldBright
  **"Hold still - it is passing"**.
- **resolved:** glowing Arabic (79:40-41) + translation + reference + hairline + note +
  `bob(nextLabel)`, with the radial goldBright background - identical to the other resolved beats.

**Interaction & haptics:**
- Drift begins on the beat's first `reveal`/appear (a `doorTimer` schedules `resolveDoor` after
  `driftDuration`); `.soft` haptic when the drift starts.
- **Reaching (a tap on the glow) before resolve = the failure:** invalidate the timer, `.light`
  haptic, flash a brief "It opens again" reset, animate the glow back to start, and restart the
  drift. No harsh penalty - taqwa is a practice, not a trap.
- **Withholding to completion = success:** at drift end, `.success` notification haptic, resolve
  to the verse.
- reduceMotion: no drift/reset animation (state swaps only); a `driftDuration ≈ 3.5s` static hold
  still resolves, tap still resets. Reading scale `s` applies to subline/note/translation, NOT
  to the fixed prompt/labels.

**Wiring parity with the other interactive beats:**
- `placeInfo`: `case .door(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)`
- content switch: `case let .door(_, prompt, subline, arabic, translation, reference, note, nextLabel): doorPage(...)`
- **Reset in `aminBlock` "Begin again":** invalidate `doorTimer`; reset `doorStarted`,
  `doorProgress`, `doorReached`, `doorDone`.
- `onDisappear { doorTimer?.invalidate(); doorTimer = nil }`.
- Fixed renderer strings ("Do not touch it - let it pass", "Hold still - it is passing", "It
  opens again") are EN-only literals for now (localization debt tracked with the UR/AR pass).
- The exhaustive `content` switch means `DeepDive.swift` + `DeepDiveView.swift` are ONE atomic
  commit - the project will not compile between them. Never add a `default:` to that switch.

---

## 4. Full per-beat content (TRANSCRIPTION SOURCE OF TRUTH)

English is authored plain (no transliteration diacritics; straight apostrophe for ayn/hamza
between letters). No em dashes anywhere (" - " only). Arabic is plain (non-Uthmani) orthography.

### DeepDive metadata
- `id: "taqwa"`
- `titleEn: "Taqwa"`
- `titleAr: "تَقْوَىٰ"`
- `subtitle: "God-consciousness - a descent through three guards"`
- `sfSymbol: "shield"`
- `estMinutes: 5`
- `stageNoun: "Guard"`
- (all other tuning defaults: `stageWord "Movement"`, `descendCta "Descend"`,
  `beginCta "Begin the descent"`, `mapLine "The map for everything below."`,
  `endLine "The descent ends."`, `scrollHint "Scroll to sink deeper"`, `scrollHintIcon "arrow.down"`)

### acts
```
ActInfo(number: 1, ar: "الخَوْف",     tr: "al-Khawf",     name: "The Fear")
ActInfo(number: 2, ar: "الوَرَع",     tr: "al-Wara'",     name: "The Scruple")
ActInfo(number: 3, ar: "المُرَاقَبَة", tr: "al-Muraqaba",  name: "The Watch")
```

### Beat 1 - `open`
- kicker: `A DEEP DIVE`
- titleAr: `تَقْوَىٰ`
- titleEn: `Taqwa`
- subtitle: `God-consciousness`
- line: `A descent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - following one guard as it draws inward: from the hand, to the heart, to the ground where no fear is left but Him.`

### Beat 2 - `orientation`
- eyebrow: `Before you descend`
- promise: `Three guards lie below - one at the forbidden, one at the doubtful, and one that keeps the heart for Him alone.`
- leaveWith: `You'll leave with a map of taqwa - and a prayer for the nights the guard is hardest to keep.`

### Beat 3 - `depths` ("The Three Guards")
- tag: `The Three Guards`
- reference: `al-Kafi · Al Imran 3:102`
- items:
  1. `Depth(ar: "الخَوْف", tr: "al-Khawf", label: "The Fear", desc: "To guard the hand from the forbidden - because the Fire is real, and He is watching.", reference: nil, embodies: "the servant who dreads the Fire")`
  2. `Depth(ar: "الوَرَع", tr: "al-Wara'", label: "The Scruple", desc: "To draw back even from the doubtful - keeping a clear margin between yourself and the edge.", reference: nil, embodies: "the hand that lets the doubtful go")`
  3. `Depth(ar: "المُرَاقَبَة", tr: "al-Muraqaba", label: "The Watch", desc: "To keep the heart for Him alone - to fear Him as He deserves, until no smaller fear can command you.", reference: "3:102", embodies: "the free man who feared none but God")`

### Beat 4 - `act` I (al-Khawf)
- act: 1, connector: nil, bridge: nil
- line: `It begins at the edge of the forbidden. Taqwa's first work is a plain one, and the whole of it is a No: the hand stopped before the thing it wanted, because Someone sees, and the Fire is not a story told to children.`

### Beat 5 - `verse` 66:6
- act: 1, tag: `Guard Yourselves`, surah: 66, ayah: 6
- arabic: `يَا أَيُّهَا الَّذِينَ آمَنُوا قُوا أَنفُسَكُمْ وَأَهْلِيكُمْ نَارًا`
- translation: `"O you who believe - guard yourselves and your families against a Fire."`
- reference: `al-Tahrim · 66 : 6`
- reflection: `The command is the word itself: qu - guard, shield, put something between them and the Fire. Taqwa is not first a feeling. It is a wall you raise, one refusal at a time, around the soul you were lent and the people set in your care.`

### Beat 6 - `narration` "The Open Door"
- act: 1, tag: `The Open Door`
- source: `Imam Ja'far al-Sadiq · al-Kafi, the chapter of obedience and taqwa`
- body: `A little deed with taqwa, said Imam al-Sadiq, is worth more than a great deal without it. Picture two men. One keeps an open, generous house - yet when a door to the forbidden swings open before him, he walks through. The other has none of that giving - but when the same door opens, he will not step through it.`
- reflection: `The first man's good is real, and still it drains away: one unguarded door empties the house behind it. Taqwa is not the size of what you do. It is what you refuse to do when the door swings open and no one alive would know.`

### Beat 7 - `act` II (al-Wara')
- act: 2, connector: `You have guarded against the forbidden.`, bridge: nil
- line: `Now - guard the doubtful. The forbidden is marked, and refusing it is the easy half. The long work of taqwa is the grey edge: the thing that might be wrong, that you could explain away - and that you leave anyway, to keep clear air between yourself and the fall.`

### Beat 8 - `verse` 59:18
- act: 2, tag: `Look to Tomorrow`, surah: 59, ayah: 18
- arabic: `يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَلْتَنظُرْ نَفْسٌ مَّا قَدَّمَتْ لِغَدٍ`
- translation: `"O you who believe - be mindful of God, and let every soul look to what it has sent ahead for tomorrow."`
- reference: `al-Hashr · 59 : 18`
- reflection: `Every deed is already travelling ahead of you, to a tomorrow you will have to meet. The next verse names the opposite: those who forgot God, so He made them forget themselves. To guard the self, you have to remember it is going somewhere.`

### Beat 9 - `narration` "The Hardest Worship"
- act: 2, tag: `The Hardest Worship`
- source: `Imam al-Baqir and Imam al-Sadiq · al-Kafi, the chapter of scrupulousness`
- body: `Shield your religion with wara', said Imam al-Sadiq - scrupulous restraint. And Imam al-Baqir said: the most strenuous worship of all is wara'.`
- reflection: `The worship others can see is the standing, the fasting, the giving. Wara' is the worship no one sees: the deal declined, the word swallowed, the glance turned away. It guards not the deed but the doer - and the tradition calls it the hardest worship there is.`

### Beat 10 - `act` III (al-Muraqaba) + bridge 3:102
- act: 3, connector: `You have guarded against the doubtful.`
- line: `Now - the innermost guard. Two walls stand: the forbidden refused, the doubtful released. Yet a heart can keep both and still be crowded - with the self, with other eyes, with a hundred small fears. This last guard is not a cage. Their imam called taqwa emancipation from every bondage: fear God as He deserves, and no smaller fear can own you.`
- bridge: `BridgeVerse(surah: 3, ayah: 102, arabic: "اتَّقُوا اللَّهَ حَقَّ تُقَاتِهِ", translation: "Be mindful of God as He truly deserves.", reference: "Al Imran · 3 : 102")`

### Beat 11 - `verse` 22:37
- act: 3, tag: `What Reaches Him`, surah: 22, ayah: 37
- arabic: `لَن يَنَالَ اللَّهَ لُحُومُهَا وَلَا دِمَاؤُهَا وَلَكِن يَنَالُهُ التَّقْوَى مِنكُمْ`
- translation: `"Neither their flesh nor their blood reaches God - but the taqwa from you, that reaches Him."`
- reference: `al-Hajj · 22 : 37`
- reflection: `Said of the offerings of the pilgrimage: the meat feeds the poor, the blood soaks the sand - none of it climbs to God. Only the taqwa in the heart that gave them arrives. Strip away every outward act, and this is the one thing He receives: not what your hands did, but what you were guarding while they did it.`

### Beat 12 - `response` (hadith qudsi)
- act: 3
- replyingTo: `To the one who feared Him here, and wondered if the fear would ever lift`
- arabic: `وَعِزَّتِي وَجَلَالِي، لَا أَجْمَعُ عَلَى عَبْدِي خَوْفَيْنِ، وَلَا أَجْمَعُ لَهُ أَمْنَيْنِ`
- words: `"By My might and My majesty - I will not join two fears upon My servant, nor two securities. Whoever feared Me in the world, I make secure on the Day they are raised."`
- source: `A hadith qudsi - the word of God · al-Jawahir al-Saniyya · Bihar al-Anwar`
- reflection: `The fear taqwa asks of you was never meant to last forever. It is a trade: carry it here, where it can still turn you back - and He carries you there, where fear can change nothing. The God-fearing turn out to be the least frightened of all, at the end.`

### Beat 13 - `climax` "The Free Man" (summit)
- act: 3, tag: `The Free Man`
- source: `Al-Hurr ibn Yazid al-Riyahi, the morning of Ashura · al-Irshad of al-Mufid · Tarikh al-Tabari`
- arabic: `أُخَيِّرُ نَفْسِي بَيْنَ الْجَنَّةِ وَالنَّارِ، فَلَا أَخْتَارُ عَلَى الْجَنَّةِ شَيْئًا`
- translation: `"I am giving my own soul the choice - between the Garden and the Fire. And I will choose nothing over the Garden."`
- body: `He came as the enemy's commander - a thousand horsemen at his back, sent to pen Husayn in this waterless place. When his own men rode up parched, it was Husayn who gave them, and their horses, water to drink. On the morning of Ashura, the ranks drawn, a shudder took him. Are you afraid? a man asked. No, he said - I am standing between Paradise and the Fire, and choosing.`
- reflection: `His name was al-Hurr - the free. He had served the tyrant out of fear of the tyrant; taqwa is the fear that ends every smaller fear, and it freed him with one hour left to spend. He died that day for Husayn - who, the maqtal remembers, bent over him and called him by his name: free, as your mother named you, in this world and the next.`

### Beat 14 - `door` "The Open Door" (NEW interactive)
- tag: `The Open Door`
- prompt: `What keeps opening in front of you?`
- subline: `The thing you could reach, that no one would see you take. Here it comes - warm, easy, close. Taqwa is the hand that does not move. Let it pass.`
- arabic: `وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِ وَنَهَى النَّفْسَ عَنِ الْهَوَى فَإِنَّ الْجَنَّةَ هِيَ الْمَأْوَى`
- translation: `"But as for the one who feared the standing before his Lord, and held the soul back from its craving - the Garden, that is the refuge."`
- reference: `al-Nazi'at · 79 : 40-41`
- note: `You did nothing - and the nothing was the whole of it. Every descent before this asked you to act. This one asked you to hold still. That stillness, kept when the door swings open and no one is watching, is taqwa.`
- nextLabel: `And one prayer`

### Beat 15 - `dua` "A Prayer in Fear" + close
- tag: `A Prayer in Fear`
- intro: `After the three guards, after the free man - one prayer, in the voice of the fourth Imam: his own supplication in fear, where the dread of being wholly seen turns, at the last, into the hope of being held.`
- arabic: `فَارْحَمْنِي يَا أَرْحَمَ الرَّاحِمِينَ، وَتَجَاوَزْ عَنِّي يَا ذَا الْجَلَالِ وَالْإِكْرَامِ، وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ`
- translation: `"So have mercy on me, O Most Merciful of the merciful. Pardon me, O Possessor of majesty and honour. And turn to me - You, You are the Ever-relenting, the Compassionate."`
- source: `Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Supplication 50 (His Supplication in Fear)`
- note: `The whole guard, in the end, rests on one fact: you are seen. Let that be your fear tonight - and then your peace. The Eye you could never escape is the same Mercy you were running toward.`
- close: `The taqwa is yours to keep.`

---

## 5. Sourcing table (verification status)

| Beat | Source | Status / note |
|---|---|---|
| 5, 8, 10, 11, 14 | Qur'an 66:6, 59:18, 3:102, 22:37, 79:40-41 - from `quran_data.json`, transcribed to plain orthography, excerpted mid-ayah (Sabr 12:86 precedent) | **Verified** char-by-char; full ayah still plays in recitation |
| 6 | Imam al-Sadiq, al-Kafi (bab al-ta'a wa'l-taqwa: "a little deed with taqwa..."; the open-door illustration) | **Verified** (al-Kafi vol. 2) |
| 9 | Imam al-Sadiq ("shield your religion with wara'") + Imam al-Baqir ("wara' is the most intense worship"), al-Kafi (bab al-wara') | **Verified** (al-Kafi vol. 2) |
| 10 (card line) | Nahj al-Balagha, Sermon 230: "taqwa is... emancipation from every bondage" (عتق من كل ملكة) | **Verified verbatim** |
| 12 | Hadith qudsi "I will not join two fears...": **Prophetic transmission, NOT from an Imam**; in al-Jawahir al-Saniyya (al-Hurr al-Amili) and Bihar al-Anwar v.67 | **Verified**; framed as hadith qudsi with **no Imam attribution**. NOT in al-Kafi's khawf/raja' chapter (checked) - do not cite al-Kafi. Exact Bihar folio left uncited (edition-dependent). |
| 13 | al-Hurr: interception + water to his men/horses + accepted repentance = **al-Irshad 2:78-101**; the "Paradise or the Fire" line (on-screen Arabic) = **al-Tabari 5:427 / Ansab**. | **Verified** |
| 13 (reflection) | The freedom-naming ("free, as your mother named you...") = **later maqtal tradition, Bihar 44:319 / al-Khwarizmi** - NOT al-Irshad, NOT al-Tabari. | **Verified as tradition**; worded "the maqtal remembers" so it never claims al-Irshad. |
| 15 | Sahifa Sajjadiyya **#50** "His Supplication in Fear," closing line (50.7) | **Verified** (Chittick, *Psalms of Islam*) |

**Open items (flag if ever printing a folio):** exact Bihar page for the qudsi (v.67, edition-dependent) and al-Jawahir hadith number - left uncited by design.

---

## 6. Catalog change + What's New (exact copy)

### `DeepDiveCatalog.swift` - flip the Taqwa descriptor
- `available: true, dive: .taqwa`
- Replace `subtitle` with the sibling pattern:
  - en: `A descent through three guards - Qur'an to Karbala`
  - ur: `تین پہروں میں اترتا ایک سفر - قرآن سے کربلا تک`
  - ar: `نزولٌ عبر ثلاثة حُرّاس - من القرآن إلى كربلاء`
- `title`, `titleAr`, `sfSymbol` ("shield"), `coverAssetName` ("TaqwaCover") already exist - leave.

### `WhatsNewItem.swift` - add `deepDives-taqwa` (newest-first ordering)
- id: `deepDives-taqwa`
- sfSymbol: `shield`
- destination: `.deepDive("taqwa")`
- title: en `New Deep Dive` / ur `نیا گہرا غوطہ` / ar `غوصٌ عميقٌ جديد`
- blurb:
  - en: `Taqwa: a descent through three guards - fear, scruple, and the watch that keeps the heart for Him alone. It summits on al-Hurr, the free man of Karbala, and closes on a new beat where the hand that does not move is the whole of it.`
  - ur: `تقویٰ: تین پہروں میں اترتا ایک سفر - خوف، ورع، اور وہ نگہبانی جو دل کو صرف اُسی کے لیے رکھے۔ اختتام کربلا کے آزاد مرد حُر پر، اور ایک نئے مرحلے کے ساتھ جہاں نہ ہلنے والا ہاتھ ہی سب کچھ ہے۔`
  - ar: `التقوى: نزولٌ عبر ثلاثة حُرّاس - الخوف، والورع، والمراقبة التي تحفظ القلب له وحده. يتوّج بقصة الحُرّ، حُرّ كربلاء، ويُختم بمشهدٍ جديد تكون فيه اليدُ التي لا تتحرّك هي كلَّ شيء.`
- cta: en `Begin the descent` / ur `نزول کا آغاز کریں` / ar `ابدأ النزول`
- **releaseDate: PLACEHOLDER = ship date (currently 2026-08-07); adjust at ship.** Order newest-first in the file.

---

## 7. Deliberately NOT used / reserved honored / known-accepted

- **Zero verse overlap** with the six shipped dives (checked against the no-reuse ledger).
- **Karbala summit re-visit** is deliberate: new figure (al-Hurr, unused) + new lens
  (freedom/repentance) - declared here per the re-visit rule.
- **Closing dua** is Sahifa #50 (the spent ones are #20/#28/#37). **Munajat Sha'baniyya left
  reserved** for a future Rida/Dhikr dive; **Amr ibn Qaraza left reserved** for a wafa/loyalty dive.
- **"Worship of the free" hadith (Nahj 237 / al-Kafi 2:84) deliberately left banked** for a
  future worship/love dive - Taqwa uses only Sermon 230's *distinct* taqwa-emancipation line.
- **No organ triad** (avoided Shukr's al-Qalb/al-Lisan/al-Jawarih).
- **New interactive mechanic** (`door`) - none of the five shipped mechanics reused.
- **Known-accepted:** the freedom-naming is maqtal-tradition (kept in reflection prose, framed
  honestly); the qudsi's exact Bihar folio is uncited by choice.

## 8. Localization
English-first. UR/AR for the 15 beats is a later pass (Sabr/Tawakkul/Shukr/Salah/Ikhlas
precedent). Catalog subtitle + What's New are authored trilingual now (card chrome). The
`door` beat's fixed renderer strings are EN-only until the UR/AR pass.

## 9. Audit outcome (Stage 5) - applied 2026-08-07
Four auditors ran (A flow/shape/ledger, B theology/sourcing/Arabic, C readability, D
voice/reverence), all on Opus. **Verdict: ship-ready. The no-reuse ledger, all sourcing, and
all Qur'an/hadith Arabic verified clean.** User approved "all recommended" fixes + the closing
line "The guard is yours to keep." Build re-verified green after fixes.

**Applied deltas (these are the FINAL shipped strings; §4 above shows the pre-audit draft):**
- **Blocker (D):** dua note "The Eye you could never escape" → "The **sight** you could never escape" (crude anthropomorphism of God / tanzih).
- Beat 13 reflection → "He was martyred that day for Husayn. The accounts of Karbala remember that Husayn knelt beside his body and called him by his name: You are free, as your mother named you - free in this world and the next." (was unglossed "maqtal" + subject-splitting aside + unmarked person-switch + "bent over"/"died" for a martyr).
- Beat 10 line: "Their imam" → "**Imam Ali**"; "with other eyes" → "with the fear of who is watching".
- Beat 13 body: "sent to **pen** Husayn" → "sent to **cut Imam Husayn off**"; "gave them, and their horses, water to drink" → "gave water to them and to their horses"; "the morning of Ashura" → "the morning of Ashura, the day of the battle".
- Beat 12 response: Arabic extended with the resolution clause «...مَنْ خَافَنِي فِي الدُّنْيَا آمَنْتُهُ يَوْمَ الْقِيَامَةِ»; English → "I make him secure on the Day of Resurrection" (Arabic now matches the English's promise).
- Beat 3 depths: embodies "the free man who feared none but God" → "the **servant** who feared none but God" (de-spoiler the al-Hurr summit).
- Beat 8 reflection: re-pointed from muraqaba-drift to wara'/scruple ("...the doubtful deeds are worth a second look before you let them travel on ahead...").
- Metadata: added `stageWord: "Guard"` (act cards now read "GUARD I", not "MOVEMENT I").
- Closing line: "The taqwa is yours to keep." → "**The guard is yours to keep.**" (keeps the series cadence + spine noun; resolves the possession-vs-striving overreach).
- Polish: open "one guard as it draws inward" → "a single guarding awareness as it moves inward"; beat 4 "Someone sees" → "He sees"; beat 5 "between them and the Fire. Taqwa is not first a feeling" → "between yourself and the Fire. Taqwa is not, first of all, a feeling"; beat 9 "the standing" → "the standing in prayer"; beat 14 note "Every descent before this" → "Every step before this... like the man who would not step through the open door" (echoes beat 6); beat 15 intro "at the last" → "in the end".

**Known, accepted (auditor items NOT applied):**
- "It is a trade" (beat 12 reflection) kept - defensible via the Qur'an's own tijara metaphor.
- Third guard name ("The Watch" / al-Muraqaba) vs its "fear that frees" content - kept as the deliberate turn; reconciled in the dua note.
- Karbala dawn-hour echo with Tawakkul's climax - declared deliberate (new figure + new lens).
- The fourth-Imam Sahifa close returns (4 of 7 dives) - Sahifa #50 is unused and thematically exact; taste-level only.
- Beat 12 reflection does not unpack the "nor two securities" mirror - the beat's point is the primary fear→security direction.

**Sourcing correction (Auditor B) to §5:** the al-Hurr freedom-naming is better-attested than the
§5 caveat states - Wikishia cites **al-Irshad 2:100-101 and Ansab al-Ashraf 2:475-479** for the
post-martyrdom naming, not only late maqtal (Bihar 44:319). The beat still hedges it ("The accounts
of Karbala remember"), so it **under**-claims - safe either way.
