# "Inside the Surah - al-An'am" - Master Script (English)

**Status:** APPROVED (Gate 2), implemented in `Thaqalayn/Content/SurahAnamDive.swift`, and revised per the Stage 5 four-auditor audit (flow & learnings, theology/sourcing/Arabic, readability, voice & reverence - full-pass fixes applied). The Swift file is the shipped source of truth; this doc mirrors its final copy. English-first; UR/AR deferred.
**Surah:** 6 (al-An'am), 165 verses, Meccan, among the Sab' Tiwal (the seven longest). Gating: PREMIUM (default). Placement: catalog entry at surahNumber 6 (between al-Maida and Yusuf).
**Framing:** No partner, no share. al-An'am is the Qur'an's great sustained argument for the oneness of God, aimed not at atheists but at people who already grant God made everything and still hand a share of their lives to others. It is named "The Cattle" because that shirk showed its face most nakedly in the pagan practice of splitting a herd - "this for God, this for our partners" (6:136) - and the whole surah refuses the split, landing on "my prayer, my living, my dying, all His, no partner" (6:162-163). Ibrahim watching every rival light set (6:76-79) is the reasoning engine in the middle. A focused thematic spine of a long surah, not full coverage.
**Depth:** 16 beats, est. 12 min. Build-to-a-peak / argument shape (closest to al-Maida), not a three-station ladder and not a narrative map.

## House-style + build notes
- **Plain English spelling, NO diacritics** (repo CLAUDE.md): al-An'am, al-Mizan, Tabatabai, Tabrisi, Majma al-Bayan, Nur al-Thaqalayn, Thawab al-A'mal, Ibrahim, hanif, tawhid, shirk, mushrikin, malakut, Ahl al-Bayt, Imam al-Sadiq, Imam al-Rida, bara'a, awwal al-muslimin. Straight apostrophes only, between letters. Real Arabic script (titleAr / verse arabic / act Arabic) is untouched.
- **No em dashes** anywhere - only " - ".
- **No spoilers**: the name-reveal (why "The Cattle") lands in-flow at 6:136, one beat before the climax refuses the split. Orientation *poses* the name-question (as al-Baqara did with the cow) but never answers it. (Audit fix: the Movement III divider no longer depicts the herd-split image, so the reveal keeps its surprise.)
- **No threshold map** (`.depths`) - this is an argument, not a plot; a map would flatten and pre-empt. The three movement dividers carry the arc.
- **Close is `.closing`** (not `.dua`), so no Listen button is required.
- **Qur'an Arabic**: every `.verse(arabic:)` and `BridgeVerse(arabic:)` pulled verbatim via `pull_arabic.py` and re-patched programmatically post-authoring (the initial paste drifted to NFC; re-patch restores the byte-exact tanzil form from quran_data.json). 6:1 keeps its stored basmala prefix for the byte-check; the reflection reads from *al-hamdu lillah*. The `.climax` Arabic is 6:162 and 6:163 joined with a single space (both short full verses).

## Sourcing notes (every narration / tafsir claim)
- **Open narration** - al-An'am came down all at once (not piecemeal like most surahs), escorted by seventy thousand angels making tasbih/tahlil/takbir, who glorify God on the reciter's behalf until the Day of Resurrection: **Thawab al-A'mal** (al-Saduq, from **Imam al-Sadiq a**) and **Tafsir Nur al-Thaqalayn** (from **Imam al-Rida a**); also **Majma al-Bayan** (Tabrisi). The surah is named for the livestock of vv. 136-150 (wikishia; Majma al-Bayan). *(Audit: verified.)*
- **6:1** - darknesses (plural) vs light (singular) = falsehood is many, truth is one; the surah opens with praise then the charge (*thumma... ya'diluna*, "and yet they set up equals"), addressed to those who already acknowledge the Creator - al-Mizan (Tabatabai), Majma al-Bayan. App tafsir_6 layer2.
- **6:12** - *kataba ala nafsihi al-rahma*, God binding Himself to mercy by His own choice, not external obligation; the certainty of the gathering - al-Mizan. layer2. Translation now renders the verse's full tail ("those who have lost their souls do not believe"), matching the displayed Arabic.
- **6:75-79 (Ibrahim)** - the star/moon/sun is Ibrahim's *method of proof*, not his own doubt (he was already muwahhid); *hadha rabbi* is rhetorical amazement; the ascending order star -> moon -> sun proves size/brightness is irrelevant to divinity; *bara'a* = clean dissociation - al-Mizan (Tabatabai). The malakut vision (6:75) as God showing Ibrahim the inner reality so he would be of those with certainty - al-Mizan. **Audit correction:** *hanif* (leaning off every false lord) is **al-Mizan**; the observation that 6:79's two-part turn (turning-toward, then turning-away) mirrors the shape of the shahada is **Tabrisi / Majma al-Bayan** (not al-Mizan) - and is now stated in verse order (toward, then away). **Audit correction:** "real love rests only on what does not change/vanish" is kept generic to **the Ahl al-Bayt / the Imams** (the app's layer4 attributes it to "the Imams," not specifically Imam al-Sadiq). layer2 + layer4.
- **6:102-103** - the argument's verdict (*so worship Him*); *idrak* = to encompass/grasp, not merely see, so no vision contains Him though He contains all vision; al-Latif (subtle beyond every sense), al-Khabir (aware of the inner reality) - al-Mizan, Majma al-Bayan. **Audit fix (reverence):** the reflection no longer gives God a spatial "angle" or an implied bodily "eye"; it mirrors the verse's own *yudriku* ("takes in / encompasses"). layer2 + layer4.
- **6:136 (the name)** - the pagan split of crops and cattle between God and their "partners," rigged so the idols' share always won; shirk's self-contradiction laid bare - al-Mizan (Tabatabai); Tabrisi details the Bahira/Sa'iba consecration customs. layer2.
- **6:162-163 (climax)** - prayer -> sacrifice -> living -> dying arranged from ritual act to the totality of a life; tawhid lived, not merely believed; *la sharika lah* answering the *shuraka* of the name-verse; *awwal al-muslimin* = foremost in the fullness of submission (**audit tweak:** "not *merely* first in time," since al-Mizan allows both the temporal and the rank sense) - al-Mizan. **Imam al-Baqir (a)**: the Muslim's daily declaration of intent; **Imam al-Sadiq (a)**: praying purely for His sake. layer2 + layer4.
- **6:122 (close echo)** - *mawt* = the heart's distance from the Source; the life and the light God gives = revelation and guidance to walk among people by; contrasted with layers of darkness with no way out - al-Mizan; **Imam al-Sadiq (a)** (the light as Qur'an, Prophet, and the guiding Imams). The closing also names two epithets from 6:95-96 (the One who splits the seed, the One who splits the dawn) as God's own names, so the reader can place them. layer2 + layer4.

---

## DeepDive meta
- **id:** `surah-anam`
- **titleEn:** al-An'am
- **titleAr:** الْأَنْعَام
- **subtitle:** The Cattle - no partner, and no share
- **sfSymbol:** sun.and.horizon.fill
- **estMinutes:** 12

## Acts (movements)
1. **al-Hamd** (الْحَمْد) - "The One You Praise" (verses 6:1, 6:12)
2. **al-Uful** (الْأُفُول) - "Everything That Sets" (verses 6:75 bridge, 6:76, 6:77, 6:78, 6:79)
3. **La Sharik** (لَا شَرِيك) - "No Partner, No Share" (verses 6:102 bridge, 6:103, 6:136, climax 6:162-163)

---

## Beat 1 - OPEN
- **kicker:** INSIDE THE SURAH
- **titleAr:** الْأَنْعَام
- **titleEn:** al-An'am
- **subtitle:** The Cattle
- **line:** One hundred and sixty-five verses, and unlike almost every other surah, they came down all at once - a single descent so weighty that the Ahl al-Bayt said seventy thousand angels came down alongside it, glorifying God. It is one of the mightiest arguments for the oneness of God in the whole Qur'an. And of every name it could have carried, God gave it this one: al-An'am, The Cattle. Why would the Book's great case for God alone be named after livestock?

## Beat 2 - ORIENTATION
- **eyebrow:** Before you begin
- **promise:** This surah is one long, patient argument, and it is not aimed at people who deny God. It is aimed at people who already believe He made the world - and who then turn around and give a share of their lives to something else. That was the shirk of Mecca, and it is quieter, and closer to home, than statues. You will watch the surah take it apart the way its most beautiful passage does: through one man, alone under the night sky, who refuses to call anything his lord until he finds the One that stays.
- **leaveWith:** You will leave knowing why the Qur'an's great argument for the oneness of God is named after cattle. And you will see why, after a hundred and sixty verses of proof, the only honest answer it leaves in your hands is not a share of your life. It is all of it.

## Beat 3 - ACT I divider (al-Hamd / The One You Praise)
- **act:** 1
- **connector:** nil
- **line:** The surah does not open with a story, or a threat, or even a command. It opens with praise - and then, in the very same breath, with an accusation. Because the people it is speaking to are not strangers to God. They know exactly who made the sky over their heads. That knowledge, and what they do with it, is where the whole surah begins.
- **bridge:** nil

## Beat 4 - VERSE 6:1 (Praise, and the Charge)
- **act:** 1  **tag:** Praise, and the Charge  **surah/ayah:** 6:1  **reference:** al-An'am · 6 : 1
- **arabic:** بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ٱلْحَمْدُ لِلَّهِ ٱلَّذِى خَلَقَ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ وَجَعَلَ ٱلظُّلُمَٰتِ وَٱلنُّورَ ۖ ثُمَّ ٱلَّذِينَ كَفَرُوا۟ بِرَبِّهِمْ يَعْدِلُونَ
- **translation:** Praise be to God, who created the heavens and the earth and made the darknesses and the light. Yet those who disbelieve set up equals to their Lord.
- **reflection:** Read it slowly, because the whole surah is folded into this one sentence. First the praise: God made the heavens and the earth, and He made the darkness and the light. Notice, as al-Mizan does, that "darkness" is plural and "light" is singular. Falsehood comes in a thousand forms; the truth is only ever one. Then the turn, on the hinge of a single word: thumma, and yet. And yet, after all of that, those who disbelieve set up equals to their Lord. Not strangers who never heard of Him. People who grant that He made everything, and still line others up beside Him. That is the exact charge the surah will spend a hundred and sixty verses answering. You already know who all of this belongs to. Why do you keep looking elsewhere?

## Beat 5 - VERSE 6:12 (He Wrote Mercy on Himself)
- **act:** 1  **tag:** He Wrote Mercy on Himself  **surah/ayah:** 6:12  **reference:** al-An'am · 6 : 12
- **arabic:** قُل لِّمَن مَّا فِى ٱلسَّمَٰوَٰتِ وَٱلْأَرْضِ ۖ قُل لِّلَّهِ ۚ كَتَبَ عَلَىٰ نَفْسِهِ ٱلرَّحْمَةَ ۚ لَيَجْمَعَنَّكُمْ إِلَىٰ يَوْمِ ٱلْقِيَٰمَةِ لَا رَيْبَ فِيهِ ۚ ٱلَّذِينَ خَسِرُوٓا۟ أَنفُسَهُمْ فَهُمْ لَا يُؤْمِنُونَ
- **translation:** Say: to whom belongs all that is in the heavens and the earth? Say: to God. He has decreed mercy upon Himself. He will surely gather you to the Day of Resurrection, of which there is no doubt. Those who have lost their own souls, they will not believe.
- **reflection:** The surah asks its own question and answers it in the same breath, refusing to let you look away: everything, all of it, in the heavens and the earth, belongs to God. But watch what it says He did with all that ownership. He wrote mercy upon Himself - kataba ala nafsihi al-rahma. al-Mizan stops on the phrase, because the wording is astonishing: God binding Himself, by His own hand, to be merciful. Not mercy He might grant or refuse as He chooses, but mercy He has made a law over His own self. So the God this surah is arguing you back toward is not a cold first cause, a maker who set the world spinning and walked away. He is the Owner of all things who chose to owe you kindness. This is the One you have been giving away in pieces.

## Beat 6 - ACT II divider (al-Uful / Everything That Sets)
- **act:** 2
- **connector:** You have granted it already - the heavens and the earth, the darkness and the light, all of it His.
- **line:** So the surah shows you how to reason your way from there to Him. And it does not do it with a lecture. It does it with a boy, alone as the night comes down, who looks up at everything his people bow to and decides to test each one with a single quiet question: does it stay? And underneath what his eyes could see, the surah says, God was showing him what things are really made of.
- **bridge:** 6:75 - *arabic:* وَكَذَٰلِكَ نُرِىٓ إِبْرَٰهِيمَ مَلَكُوتَ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضِ وَلِيَكُونَ مِنَ ٱلْمُوقِنِينَ  ·  *translation:* And thus did We show Ibrahim the kingdom of the heavens and the earth, that he would be among those who have certainty.  ·  *reference:* al-An'am · 6 : 75

## Beat 7 - VERSE 6:76 (The Star)
- **act:** 2  **tag:** The Star  **surah/ayah:** 6:76  **reference:** al-An'am · 6 : 76
- **arabic:** فَلَمَّا جَنَّ عَلَيْهِ ٱلَّيْلُ رَءَا كَوْكَبًۭا ۖ قَالَ هَٰذَا رَبِّى ۖ فَلَمَّآ أَفَلَ قَالَ لَآ أُحِبُّ ٱلْءَافِلِينَ
- **translation:** When the night covered him, he saw a star. He said, "This is my lord." But when it set, he said, "I love not those that set."
- **reflection:** First a star, the brightest point in the dark - and the people of Ibrahim (alayhi al-salam) worshipped exactly these, the lights of the night sky. "This is my lord," he says. Then the star does what every star does: it slips down the sky and is gone. And Ibrahim draws his first line: la uhibbu al-afilin, I love not the things that set. Read him carefully. al-Mizan insists Ibrahim is not doubting and not searching - he already believes. He is running the argument out loud, for a people who never thought to run it themselves. And notice the word he reaches for: not "I do not worship" the things that set, but "I do not love" them. The Ahl al-Bayt taught that real love can only rest on what does not change and does not vanish - which is why a heart made for God can chase the setting lights its whole life and never, for one moment, feel held.

## Beat 8 - VERSE 6:77 (The Moon)
- **act:** 2  **tag:** The Moon  **surah/ayah:** 6:77  **reference:** al-An'am · 6 : 77
- **arabic:** فَلَمَّا رَءَا ٱلْقَمَرَ بَازِغًۭا قَالَ هَٰذَا رَبِّى ۖ فَلَمَّآ أَفَلَ قَالَ لَئِن لَّمْ يَهْدِنِى رَبِّى لَأَكُونَنَّ مِنَ ٱلْقَوْمِ ٱلضَّآلِّينَ
- **translation:** When he saw the moon rising, he said, "This is my lord." But when it set, he said, "If my Lord does not guide me, I shall surely be among the people who go astray."
- **reflection:** Now something larger. The moon does not merely prick the dark like a star; it floods it, it rules the whole night sky. Surely this. "This is my lord." And the moon sets too. But listen to how his words have deepened. He is no longer only naming what fails - he is reaching past all of it, toward a Lord who could actually guide him: if my Lord does not guide me, I will be lost. al-Mizan hears the sign in that phrase "my Lord" - he is speaking of Someone he already knows, Someone plainly not up there among the setting lights. The bigger light failed the very same test as the small one. Size was never the question. And the One he is reaching for is not in the sky at all.

## Beat 9 - VERSE 6:78 (The Sun)
- **act:** 2  **tag:** The Sun  **surah/ayah:** 6:78  **reference:** al-An'am · 6 : 78
- **arabic:** فَلَمَّا رَءَا ٱلشَّمْسَ بَازِغَةًۭ قَالَ هَٰذَا رَبِّى هَٰذَآ أَكْبَرُ ۖ فَلَمَّآ أَفَلَتْ قَالَ يَٰقَوْمِ إِنِّى بَرِىٓءٌۭ مِّمَّا تُشْرِكُونَ
- **translation:** When he saw the sun rising, he said, "This is my lord; this is greater." But when it set, he said, "O my people, I am free of what you associate with God."
- **reflection:** And now the greatest light there is. The sun does not share the sky with anything; it blots out the very stars and moon he has just watched fail. "This is my lord, this is greater" - he grants it everything, the whole claim his people would make for the highest god they knew. And then the sun, too, goes down. That is the end of the ladder. There is no bigger light left to try. And so Ibrahim turns from the sky to the people standing beside him and says it plainly: I am free of all of it. Bara'a, al-Mizan calls this word - not a disagreement, but a clean break, a washing of the hands. He has taken their worship all the way to its top rung, and shown them the top rung sets like all the rest.

## Beat 10 - VERSE 6:79 (The Turn)
- **act:** 2  **tag:** The Turn  **surah/ayah:** 6:79  **reference:** al-An'am · 6 : 79
- **arabic:** إِنِّى وَجَّهْتُ وَجْهِىَ لِلَّذِى فَطَرَ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ حَنِيفًۭا ۖ وَمَآ أَنَا۠ مِنَ ٱلْمُشْرِكِينَ
- **translation:** I have turned my face to the One who originated the heavens and the earth, inclining to truth, and I am not of those who associate partners with Him.
- **reflection:** Here is the other half, the half the whole night was building toward. It is not enough to walk away from the setting things; you have to turn toward something. And Ibrahim turns his face toward the One who made the whole sky he had been scanning, not toward anything hanging inside it. Wajjahtu wajhi, he says: I have set my whole face toward Him. The surah calls him a hanif, and al-Mizan lingers on the word: not merely someone who believes in one God, but someone leaning away from every false lord at once, the way a green thing leans toward light. Tabrisi hears something more in his words - the very shape of the testimony you speak to enter Islam: the turning toward, "my face to Him alone," and the turning away, "I am not of those who associate." Ibrahim reached God by refusing everything that sets. And this, the surah is telling you, is not just his story. It is the method. It is what the surah wants from you.

## Beat 11 - ACT III divider (La Sharik / No Partner, No Share)
- **act:** 3
- **connector:** You have watched every lord the eye can find rise, dazzle, and go down.
- **line:** So the surah gathers the whole argument into a single verdict - that is God, your Lord, so worship Him - and then it does something you might not expect. Having lifted your eyes to a God greater than the sun, it will bring them back down to earth, to the most ordinary scene imaginable, and show you what turning away from Him actually looks like in a human hand. It is smaller, and sadder, than you would think.
- **bridge:** 6:102 - *arabic:* ذَٰلِكُمُ ٱللَّهُ رَبُّكُمْ ۖ لَآ إِلَٰهَ إِلَّا هُوَ ۖ خَٰلِقُ كُلِّ شَىْءٍۢ فَٱعْبُدُوهُ ۚ وَهُوَ عَلَىٰ كُلِّ شَىْءٍۢ وَكِيلٌۭ  ·  *translation:* That is God, your Lord. There is no god but He, the Creator of all things, so worship Him. And He is Guardian over all things.  ·  *reference:* al-An'am · 6 : 102

## Beat 12 - VERSE 6:103 (No Eye Catches Him)
- **act:** 3  **tag:** No Eye Catches Him  **surah/ayah:** 6:103  **reference:** al-An'am · 6 : 103
- **arabic:** لَّا تُدْرِكُهُ ٱلْأَبْصَٰرُ وَهُوَ يُدْرِكُ ٱلْأَبْصَٰرَ ۖ وَهُوَ ٱللَّطِيفُ ٱلْخَبِيرُ
- **translation:** No vision can grasp Him, but He grasps all vision. And He is the Subtle, the All-Aware.
- **reflection:** Before the surah shows you the field, it makes sure you have not misunderstood the God you are being turned toward. Ibrahim set his face to Him - but do not imagine, even for a moment, that He is one more thing hanging in the sky, a brighter sun you could point to. No vision can grasp Him, la tudrikuhu al-absar; He grasps all vision. al-Mizan is careful with the word here: it is not "see" but "encompass," to get your eyes fully around a thing. You cannot fit God inside your sight the way you fit a star, a moon, a sun. It runs the other way entirely. He is the One who sees you, this very second, though your eyes will never once turn and take Him in. al-Latif, so fine He slips beneath every sense; al-Khabir, aware of the whole of you. Those setting lights, your eye could take them in. This One takes in all of you.

## Beat 13 - VERSE 6:136 (A Share for God)
- **act:** 3  **tag:** A Share for God  **surah/ayah:** 6:136  **reference:** al-An'am · 6 : 136
- **arabic:** وَجَعَلُوا۟ لِلَّهِ مِمَّا ذَرَأَ مِنَ ٱلْحَرْثِ وَٱلْأَنْعَٰمِ نَصِيبًۭا فَقَالُوا۟ هَٰذَا لِلَّهِ بِزَعْمِهِمْ وَهَٰذَا لِشُرَكَآئِنَا ۖ فَمَا كَانَ لِشُرَكَآئِهِمْ فَلَا يَصِلُ إِلَى ٱللَّهِ ۖ وَمَا كَانَ لِلَّهِ فَهُوَ يَصِلُ إِلَىٰ شُرَكَآئِهِمْ ۗ سَآءَ مَا يَحْكُمُونَ
- **translation:** They assign to God a share of the crops and cattle He created, saying, "This is for God" - so they claim - "and this is for our partners." But what is for their partners does not reach God, while what is for God does reach their partners. Evil is what they decide.
- **reflection:** And here, at last, is why this surah is named for livestock. Watch the scene it draws. A man stands over his own field and his own herd - grain God grew, cattle God made - and he divides it into two. This pile is for God. This pile is for the others we serve beside Him. al-Mizan draws out the sheer smallness of it: they even rigged the split, so that whatever got mixed between the two heaps ended up in the idols' share, never God's. This is shirk with its mask off. Not some grand rival theology - a farmer short-changing God out of a handful of his own herd. And that is the surah's quiet, devastating point. When you set anything at all beside God, this is what you have actually done: taken the One who owns the heavens and the earth, the One no eye can even contain, and handed Him a share. As though He were one more creditor in the village, to be paid His slice and no more.

## Beat 14 - CLIMAX 6:162-163 (No Partner, No Share)
- **act:** 3  **tag:** No Partner, No Share  **source:** al-An'am · 6 : 162-163
- **arabic:** (6:162 and 6:163 joined with a single space) قُلْ إِنَّ صَلَاتِى وَنُسُكِى وَمَحْيَاىَ وَمَمَاتِى لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ لَا شَرِيكَ لَهُۥ ۖ وَبِذَٰلِكَ أُمِرْتُ وَأَنَا۠ أَوَّلُ ٱلْمُسْلِمِينَ
- **translation:** Say: my prayer, my sacrifice, my living and my dying are for God, the Lord of all the worlds. He has no partner. This I have been commanded, and I am the first of those who submit.
- **body:** A hundred and sixty verses of argument, and now the surah hands you the whole of it to say in a single breath. Not a share. Look at what it refuses to divide: my prayer - and my sacrifice - and my living - and my dying. The four corners of a life, from the words you whisper in worship to the last breath you will ever draw, and every ordinary hour in between. All of it, turned one direction: lillahi rabbi al-alamin, for God, the Lord of all the worlds. And then the hammer, the phrase that answers the entire surah: la sharika lah. He has no partner. The very word the farmer used - shuraka, our partners, our other shareholders - struck clean out of existence. There is no second pile. There never was one.
- **reflection:** This is Ibrahim's turning, now placed in your own mouth - and it goes further than his did. He turned his face; here you hand over your face, and your prayer, and your work, and your death. The people of Mecca gave God a portion and kept the rest for themselves and their idols. The believer gives Him everything and keeps back nothing - and finds, in the handing over, that nothing at all is lost, because it was all His to begin with. "I am the first of those who submit," awwal al-muslimin: not merely first in time, al-Mizan says, but first in fullness, the most complete in the surrender. That is where a hundred and sixty verses of proof were always leading. One life. Wholly His. No partner. No share.

## Beat 15 - REFLECTION PROMPT
- **tag:** The Return
- **prompt:** Where are you still giving God a share?
- **placeholder:** an hour of the week, a corner of your income, a part of your heart kept for something else…
- **subline:** The farmers of Mecca split their herd - a portion for God, a portion for the things they served beside Him. The modern split is quieter, and harder to see: the God we praise on the day of prayer, and the things we actually arrange our whole lives around the other six days. Before you go, name the share you have been keeping back. That, and not a field of goats, is your cattle.
- **nextLabel:** One last thing

## Beat 16 - CLOSING
- **tag:** The Close
- **titleAr:** الْأَنْعَام
- **essence:** This is the Qur'an's great argument for the oneness of God, and it wears the name of livestock. That is where a whole people's shirk showed its face most plainly: a herd split between the Maker and His rivals, when the only honest answer was that all of it, always, was His.
- **line:** The surah has a name for what it does to a person who finally stops dividing. It says such a one was dead, and God gave him life, and gave him a light to walk by among the people. So read al-An'am now in its own words. The star, the moon, the sun. And the names it gives their Maker: the One who splits the seed open, the One who splits the dawn from the dark. Let the surah bring you out of a darkness you did not know you were standing in, and into a light you can carry home. No partner. No share.
