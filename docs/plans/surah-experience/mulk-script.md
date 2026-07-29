# Inside the Surah - al-Mulk · MASTER SCRIPT

**Status:** DRAFT for approval (Gate 2). English-only (ur/ar deferred, like the Fatiha/Yusuf
dives). Qur'an Arabic is verbatim from `quran_data.json` (pulled via
`scripts/pull_arabic.py`). No em dashes; plain English spelling (house style). No dua/ziyarat
beats, so no Listen button required. No `.depths` map (deliberate - a sovereignty hymn, not a
narrative). Spine: the three **directions of looking** (Up / Ahead / Around), each anchored to
one of the surah's own keywords (Futur / Ghayb / Man).

---

## META

- **id:** `surah-mulk`
- **titleEn:** al-Mulk
- **titleAr:** الْمُلْك
- **subtitle:** The Kingdom - the surah that guards the grave
- **sfSymbol:** `crown`
- **estMinutes:** 11
- **acts:**
  1. ar `الْفُطُور` · tr `al-Futur` · name **No Flaw Above**
  2. ar `الْغَيْب` · tr `al-Ghayb` · name **The Unseen Account**
  3. ar `مَن` · tr `Man` · name **Who Holds It Up**

**Beat count:** 17 (~11 min). Shape: `.open` → `.orientation` → I (3 verses) → II (3 verses)
→ III (bridge + 2 verses + `.climax`) → `.narration` payoff → `.reflectionPrompt` → `.closing`.

---

## 1 · `.open` (act 0)

- **kicker:** INSIDE THE SURAH
- **titleAr:** الْمُلْك
- **titleEn:** al-Mulk
- **subtitle:** The Kingdom
- **line:**
> Thirty verses the Ahl al-Bayt taught you to say every night, in the last waking moments before sleep - and sleep is the small death you practice every evening. They called this surah al-Munjiyah, the Rescuer, and al-Mani'a, the Shield: the one that comes to your grave and argues for you until you are forgiven. Meet it now, while you can still answer back.

## 2 · `.orientation` (act 0)

- **eyebrow:** Before you begin
- **promise:**
> al-Mulk is the Qur'an's great hymn to God's sovereignty, and it opens by telling you Whose hand holds everything: biyadihi'l-mulk, in His hand is the kingdom. Then it does the one thing the mind cannot argue with. It tells you to look. Look up, at a sky with no crack in it. Look ahead, at the two ends every soul is walking toward. Look around you, at the bird held on the air by nothing, at the water under your feet. Every direction gives back the same answer.
- **leaveWith:**
> You will leave knowing why the Ahl al-Bayt had you recite this surah every night before sleep - and how a surah that begins with the far galaxies can end at the swallow of water in your throat, so that you never again mistake the ordinary world for something that holds itself up.

---

## MOVEMENT I · No Flaw Above (act 1) - الْفُطُور

### 3 · `.act` (act 1, connector: nil)

- **line:**
> The surah does not open with a command, or a threat. It opens with a blessing - tabaraka, He is abounding, overflowing, a source that never once runs dry - and in the same breath it names two things His hand is holding: the whole kingdom, and your own death. Then, gently, it lifts your eyes to the sky.

### 4 · `.verse` (act 1) - 67:1

- **tag:** In His Hand
- **arabic:** `بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ تَبَٰرَكَ ٱلَّذِى بِيَدِهِ ٱلْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَىْءٍۢ قَدِيرٌ`
  *(stored with the basmala prefix in quran_data.json; kept verbatim for the byte-check. The reflection reads from `tabaraka`.)*
- **translation:** Blessed is He in whose hand is the kingdom, and He is powerful over all things.
- **reference:** al-Mulk · 67 : 1
- **reflection:**
> One phrase, and the whole surah is only its proof: biyadihi'l-mulk, in His hand is the kingdom. Not a kingdom He wound up and walked away from. al-Mizan reads tabaraka as a blessing that never thins out, unlike anything created, which only ever spends itself down. And mulk here is total: Tabrisi notes the wording leaves no room for a partner, no second hand anywhere on the reins. Everything that comes after this - the heavens, the birds, the water - is this one sentence, shown to you instead of said.

### 5 · `.verse` (act 1) - 67:2

- **tag:** Death, Then Life
- **arabic:** `ٱلَّذِى خَلَقَ ٱلْمَوْتَ وَٱلْحَيَوٰةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًۭا ۚ وَهُوَ ٱلْعَزِيزُ ٱلْغَفُورُ`
- **translation:** He who created death and life to test you - which of you is best in deed - and He is the Mighty, the Forgiving.
- **reference:** al-Mulk · 67 : 2
- **reflection:**
> Notice the order: death before life. al-Mizan says it is named first on purpose, to wake a sleeping heart - and notice that death is created, a made thing, a door God built, not a wall where you simply stop. And the test is not who piles up the most. Imam al-Sadiq was asked what "best in deed" means and answered that it is not the most deeds, but the most right: the deed done in awe of Him, wanting no eye on it but His. Your whole life is one question, and the question is about sincerity, not quantity.

### 6 · `.verse` (act 1) - 67:3 *(the LOOK challenge; verse 4 folded into the reflection)*

- **tag:** Look Again
- **arabic:** `ٱلَّذِى خَلَقَ سَبْعَ سَمَٰوَٰتٍۢ طِبَاقًۭا ۖ مَّا تَرَىٰ فِى خَلْقِ ٱلرَّحْمَٰنِ مِن تَفَٰوُتٍۢ ۖ فَٱرْجِعِ ٱلْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍۢ`
- **translation:** He who created seven heavens in layers. You see no flaw in the creation of the Most Merciful. So return your gaze: do you see any cracks?
- **reference:** al-Mulk · 67 : 3
- **reflection:**
> This is the surah's first proof, and it is not an argument. It is a dare. Look, it says - go hunt the sky for one crack, one seam where the Most Merciful's work does not hold. al-Mizan notes the command to "return your gaze" trains the eye, from a glance into real searching. And the next verse gives the honest result: return your gaze twice more, and yanqalib ilayka al-basar, the sight comes back to you khasi', beaten, and hasir, worn out - not because you did not look hard enough, but because there was nothing there to find. The eye that truly searches His creation always comes home defeated. That defeat is where seeing begins.

---

## MOVEMENT II · The Unseen Account (act 2) - الْغَيْب

### 7 · `.act` (act 2)

- **connector:** You have looked up, and hunted the whole sky, and found no flaw in His kingdom.
- **line:**
> But the looking was never idle. The same surah that showed you a flawless heaven now shows you what the seeing is for: two ends, and every soul walking toward one of them. First it takes you to the gate of the Fire, where a question is waiting for everyone thrown in. As each crowd arrives, its keepers ask them the same thing, over and over: did no one ever come to warn you?

### 8 · `.verse` (act 2) - 67:10

- **tag:** If Only We Had Listened
- **arabic:** `وَقَالُوا۟ لَوْ كُنَّا نَسْمَعُ أَوْ نَعْقِلُ مَا كُنَّا فِىٓ أَصْحَٰبِ ٱلسَّعِيرِ`
- **translation:** And they will say, "Had we only listened, or used our minds, we would not be among the companions of the Blaze."
- **reference:** al-Mulk · 67 : 10
- **reflection:**
> Their whole ruin in one sentence - and notice they do not confess a sin of the hands. They name two doors they would not open. al-Mizan reads them as the two ways truth reaches a person: sam', listening, taking in what is sent from above, and 'aql, reasoning, following the mind God already put in you. They were given both. They used neither. It is the most human regret there is: not that the road was hidden, but that they refused to look at it.

### 9 · `.verse` (act 2) - 67:12 *(the hinge)*

- **tag:** Who Fear Him Unseen
- **arabic:** `إِنَّ ٱلَّذِينَ يَخْشَوْنَ رَبَّهُم بِٱلْغَيْبِ لَهُم مَّغْفِرَةٌۭ وَأَجْرٌۭ كَبِيرٌۭ`
- **translation:** Indeed, those who fear their Lord in the unseen - for them is forgiveness and a great reward.
- **reference:** al-Mulk · 67 : 12
- **reflection:**
> Here is the other end, and it turns on one phrase: bi'l-ghayb, in the unseen. al-Mizan opens it three ways at once - to be in awe of the Lord who is Himself unseen, to fear Him about the unseen things He promised, and to fear Him even where no other eye can see you. Hold onto this line. It is the quiet hinge of the whole surah, and the reason that, at the very end, this surah comes to your grave. The grave is the unseen made total. The one who learned to hold God real while He could not be seen is the one who will not be afraid there.

### 10 · `.verse` (act 2) - 67:14 *(verse 13 folded into the reflection)*

- **tag:** Would the Maker Not Know?
- **arabic:** `أَلَا يَعْلَمُ مَنْ خَلَقَ وَهُوَ ٱللَّطِيفُ ٱلْخَبِيرُ`
- **translation:** Would the One who created not know? And He is the Subtle, the All-Aware.
- **reference:** al-Mulk · 67 : 14
- **reflection:**
> The verse just before this one says: keep your words secret or say them out loud, it is all the same to Him, for He knows what sits inside the chest. And then this: would the Maker of a thing not know the thing He made? He is al-Latif, so fine a knower that He reaches what you hide even from yourself, and al-Khabir, aware of all of it. So the unseen runs both ways. He is hidden from you; you are not hidden from Him for a single second. To fear Him unseen is only to live as if this were true - because it is.

---

## MOVEMENT III · Who Holds It Up (act 3) - مَن

### 11 · `.act` (act 3, with bridge verse 67:15)

- **connector:** You have stood at both ends now, and found the eye that fears Him where no one is watching.
- **line:**
> So the surah brings the looking all the way down - to the ground under your feet, and the things you lean on without a word of thanks. It begins to ask a question, again and again, and the question always has the same shape: who? Who could be an army for you against Him? Who would feed you if He closed His hand? Are you even sure the ground will keep holding you up?
- **bridge (67:15):**
  - **arabic:** `هُوَ ٱلَّذِى جَعَلَ لَكُمُ ٱلْأَرْضَ ذَلُولًۭا فَٱمْشُوا۟ فِى مَنَاكِبِهَا وَكُلُوا۟ مِن رِّزْقِهِۦ ۖ وَإِلَيْهِ ٱلنُّشُورُ`
  - **translation:** It is He who made the earth soft for you - so walk its shoulders and eat of His provision - and to Him is the resurrection.
  - **reference:** al-Mulk · 67 : 15

### 12 · `.verse` (act 3) - 67:19

- **tag:** None But the Merciful
- **arabic:** `أَوَلَمْ يَرَوْا۟ إِلَى ٱلطَّيْرِ فَوْقَهُمْ صَٰٓفَّٰتٍۢ وَيَقْبِضْنَ ۚ مَا يُمْسِكُهُنَّ إِلَّا ٱلرَّحْمَٰنُ ۚ إِنَّهُۥ بِكُلِّ شَىْءٍۭ بَصِيرٌ`
- **translation:** Have they not seen the birds above them, spreading their wings and folding them? Nothing holds them up but the Most Merciful. Indeed He sees all things.
- **reference:** al-Mulk · 67 : 19
- **reflection:**
> Look up again - not at the far heavens this time, but at the bird over the street. Wings open, wings close, and in between it simply hangs there on the air. What holds it? The surah answers before you can say the word gravity: nothing holds it but al-Rahman. Not al-Qahhar, the Overpowerer - al-Rahman, the Merciful, because al-Mizan notes that the very law keeping that bird aloft is an act of tenderness. And He holds it not once, but in every passing instant. The One who will not let the bird drop for a moment is the One holding you.

### 13 · `.verse` (act 3) - 67:23

- **tag:** He Gave You the Eyes
- **arabic:** `قُلْ هُوَ ٱلَّذِىٓ أَنشَأَكُمْ وَجَعَلَ لَكُمُ ٱلسَّمْعَ وَٱلْأَبْصَٰرَ وَٱلْأَفْـِٔدَةَ ۖ قَلِيلًۭا مَّا تَشْكُرُونَ`
- **translation:** Say: it is He who brought you into being, and made for you hearing, and sight, and hearts. How little you give thanks.
- **reference:** al-Mulk · 67 : 23
- **reflection:**
> The whole surah has been saying one word - look, look again, do they not see - and here it turns the looking back on itself. The eyes you have been searching the sky with: He made them. The hearing that took in every warning, the heart that was meant to understand it: His, handed to you. al-Mizan notes they are listed in the order a life wakes up in - first sound, then sight, then the understanding heart. And the verse ends not with a threat but almost with a sigh: how little you give thanks. The gift was the very instrument for seeing the Giver.

### 14 · `.climax` (act 3) - 67:30 *(the surah's final verse)*

- **tag:** The Last Question
- **source:** al-Mulk · 67 : 30
- **arabic:** `قُلْ أَرَءَيْتُمْ إِنْ أَصْبَحَ مَآؤُكُمْ غَوْرًۭا فَمَن يَأْتِيكُم بِمَآءٍۢ مَّعِينٍۭ`
- **translation:** Say: have you considered - if one morning your water had sunk away beyond reach, who then could bring you flowing water?
- **body:**
> The surah began at the top of everything - the kingdom, the seven heavens, the far lamps of the night. Watch where it chooses to end. Not on a throne. On a mouthful of water. Say: what if you woke tomorrow and the water had simply gone down - sunk past every well and pump and root, beyond anything a hand could reach? Who brings it back? The whole argument - the galaxies, the flawless sky, the birds, the two ends - narrows here to the glass beside your bed, held one inch from vanishing, by the same hand that holds the kingdom.
- **reflection:**
> This is biyadihi'l-mulk brought so close you can drink it. And it is not lost on the heart that the household who understood this surah best were themselves kept from the water at Karbala, and stayed, even thirsty, inside the hand that holds it. From the furthest star to the water in your throat: one hand. The surah has just spent thirty verses teaching you to see it.

---

## CLOSE (act 4)

### 15 · `.narration` (act 3) - the grave-protection payoff

- **tag:** The Rescuer
- **source:** Imam al-Baqir (a) · and the Prophet Muhammad ﷺ
- **body:**
> So now you know what this surah is, and why the Ahl al-Bayt taught you to recite it every night. The Prophet ﷺ said he would love for this surah to be in the heart of every believer. Imam al-Baqir called it al-Mani'a, the Shield, and said it stands between its reciter and the punishment of the grave - and that whoever recites it in the night has done much, and done well. This is why they named it al-Munjiyah, the Rescuer: the surah that comes and pleads for its companion in the dark until he is forgiven. And you can see now why this surah, and not another. It is the one that spent itself teaching you to fear Him in the unseen - so that when the seen world is taken away, and only the unseen is left, you are already at home in it.
- **reflection:**
> You do not recite al-Mulk at night to finish a page. You recite it to send on ahead of you the one voice that will still be speaking for you when your own has stopped.

### 16 · `.reflectionPrompt` (act 4)

- **tag:** Return
- **prompt:** Where have you stopped seeing His hand?
- **placeholder:** the sky, your own breath, the water, the people still here…
- **subline:**
> al-Mulk is a cure for the eye that has gone blind to the ordinary - the sky it stopped noticing, the water it thanks no one for, the next breath it assumes will just arrive. Before you go, name the one thing you will look at tonight as what it actually is: held, this very second, in His hand.
- **nextLabel:** One last thing

### 17 · `.closing` (act 4)

- **tag:** The Close
- **titleAr:** الْمُلْك
- **essence:** Thirty verses that teach the eye to see the kingdom behind the ordinary - and then wait at the grave to speak for the one who learned.
- **line:**
> You have said it, perhaps, a hundred nights without once hearing it. Read it now in its own words, slowly, all thirty verses - not as a page to get through, but as the guardian you are placing, tonight, at your own grave.

---

## SOURCES (all Shia)

| Beat | Source | Reference |
|---|---|---|
| 67:1 | Tabatabai, *al-Mizan* (tabaraka = inexhaustible blessing); Tabrisi, *Majma al-Bayan* (no partner in sovereignty) | tafsir_67.json layer 2 |
| 67:2 | *al-Mizan* (death named first; death as created doorway); Imam al-Sadiq (a), *al-Kafi* v.2 p.16 ("best in deed" = most correct/sincere, not most numerous) | layer 2 + layer 4; al-Kafi web-verified |
| 67:3 (+4) | *al-Mizan* (repeated gaze trains the eye; the sight returns khasi'/hasir, finding no flaw) | layer 2 |
| 67:10 | *al-Mizan* (sam' = revelation received, 'aql = reason - the two wasted paths) | layer 2 |
| 67:12 | *al-Mizan* (fearing Him bi'l-ghayb, three senses at once) | layer 2 |
| 67:14 (+13) | *al-Mizan* (al-Latif / al-Khabir; He knows what is in the breasts) | layer 2 |
| 67:15 | *al-Mizan* (earth made tame; provision as continuous divine giving; to Him the resurrection) | layer 2 |
| 67:19 | *al-Mizan* / *Majma al-Bayan* (named al-Rahman - flight is mercy; moment-to-moment sustenance) | layer 2 |
| 67:23 | *al-Mizan* (hearing/sight/hearts in the order a life wakes; a trust one is questioned about, cf. Q17:36) | layer 2 |
| 67:30 | *al-Mizan* (the surah returns to dependence for basic existence; water sunk beyond reach). Karbala/water resonance: Imam Husayn (a) denied water yet spiritually alive | layer 2 + layer 4 |
| Narration (grave) | Imam al-Baqir (a): al-Mani'a / shield against the grave's punishment; "whoever recites it in a night has done much and done well." Prophet ﷺ: "I would love for this surah to be in the heart of every believer," and the surah that argues for its reciter in the grave (al-Munjiyah). Reported in the surah's fadl narrations (*Majma al-Bayan*); corroborated via academyofislam.com (Shia). | virtue-of-the-surah reports |

**Sourcing note for the audit:** the grave-protection narration's *content* and attribution to
Imam al-Baqir (a) / the Prophet ﷺ are verified against a Shia source (Academy for Learning
Islam) and the app's own layer-4. The primary classical locus is the surah's faḍāʾil section in
*Majma al-Bayan* (Tabrisi). If a more precise primary citation (e.g. *Thawab al-Aʿmal*, al-Saduq)
is wanted, pin it before ship - do not overstate the book in the beat's `source` field.
