# "Inside the Surah - Ya-Sin" - Master Script (English)

**Status:** APPROVED (English), built in `Thaqalayn/Content/SurahYasinDive.swift`; audit fixes applied. UR/AR deferred (a later pass).
**Surah:** 36 (Ya-Sin), 83 verses, Meccan. Gating: PREMIUM (all dives except al-Fatiha).
**Placement:** fills the existing "coming soon" stub in `SurahExperienceCatalog` (surahNumber 36).
**Framing:** *The surah that wakes a sleeping heart.* Ya-Sin is the heart of the Qur'an, and the
surah read at the bedside of the dying. Its one steady concern is the heart fallen asleep - to the
messengers (I), to a story of one who woke (II), to the signs all around it (III) - until the
morning it is woken by force (IV). The recurring question the reader carries: *are you awake?*
**Shape:** a mixed sermon, not a narrative. **Four movements** derived from the surah's real joints;
**no `.depths` map** (a symphony of scenes, not a plot - like al-Mulk); no `.response`/`.refrain`;
standard `.closing`. **No `.dua` beat, so no Listen button is required anywhere.**
**Depth:** 18 beats, est. 12 min.

## Sourcing notes (every narration / fadila claim) - all present in the app's own `tafsir_36.json`
- **"The heart of the Qur'an is Ya-Sin" / it illumines the heart / Fatima al-Zahra (a) recited it** -
  the Prophet ﷺ & Ahl al-Bayt, via **Thawab al-A'mal** (al-Saduq) & **Majma al-Bayan** (Tabrisi); layer 4 (36:1).
- **Read at the bedside of the dying** - long-standing practice ("recite Ya-Sin over your dying"),
  in Shia rites of ihtidar; kept gently framed. **→ flag for Auditor B to confirm the precise attribution.**
- **The walls a heart builds / three refusals form a barrier / the heart as a darkening mirror** -
  al-Mizan (Tabatabai) + Imam al-Baqir (a) + the Prophet ﷺ; layer 2/4 (36:9).
- **"People are asleep, and when they die they wake"** - Imam Ali (a); layer 4 (36:12). The spine anchor.
- **Imam Mubin = Imam Ali (a)** ("the Imam in whom God gathered the knowledge of everything") -
  Imam al-Baqir (a), classically **Basa'ir al-Darajat** (al-Saffar), via Nur al-Thaqalayn; layer 4 (36:12).
- **Habib al-Najjar, the one who ran** (farthest = spiritually nearest; a carpenter; believed in secret) -
  al-Mizan, Tabrisi, al-Qummi; layer 2/4 (36:20). **Hurr at Karbala** as the same run - Ahl al-Bayt; layer 4 (36:20).
- **Martyr enters Paradise at once / "would that my people knew" = no resentment / the Prophet ﷺ at Uhud
  "guide my people, they do not know"** - al-Mizan & Ahl al-Bayt; layer 2/4 (36:26-27).
- **The dead earth is also the dead heart, revived by guidance** - Imam al-Sadiq (a); layer 4 (36:33).
- **The sun bows beneath the Throne and asks permission to rise** - Imam al-Sadiq (a); layer 4 (36:38).
- **Death-as-sleep, the grave a bed (marqad), resurrection an awakening** - al-Mizan; layer 2 (36:52).
- **"Salam" = the summit of Paradise, God's own greeting, above every delight** - al-Mizan; layer 2 (36:58).
- **The bone / "the second making is no harder than the first, if not easier"** - Imam Ali (a) & al-Sadiq (a); layer 4 (36:77-79).
- **"Be" said "with no voice heard and no time passing"; malakut = true ownership; "to Him you return"** -
  Imam Ali (a) & al-Sadiq (a); layer 2/4 (36:82-83). **Textual echo:** Habib's *"to Him you are returned"* (36:22) → the close (36:83).
- No em dashes anywhere. Qur'an Arabic verbatim from `quran_data.json` (pulled via `pull_arabic.py`).
  Plain English spelling, no transliteration diacritics (house style).

## Notes / deliberate cuts
- **36:65** (sealed mouths, testifying limbs) was considered for Movement IV and **cut**, to keep the
  final movement a clean ascent - waking (52) → peace (58) → "Be" (climax) - instead of dipping into
  judgment between the two highs.
- Movement I runs slightly fuller (2 verses + the Imam Mubin narration); Movement IV carries the climax.
  Each movement was pressure-tested against the force-fit tell - none is padding.

---

## DeepDive meta
- **id:** `surah-yasin`
- **titleEn:** Ya-Sin
- **titleAr:** يسٓ
- **subtitle:** The heart of the Qur'an - the surah that wakes a sleeping heart
- **sfSymbol:** heart
- **estMinutes:** 12

## Acts (movements)
1. **al-Ghafla** (الْغَفْلَة) - "The Sleeping Heart" (36:1-12)
2. **Sa'a** (سَعَىٰ) - "The One Who Ran" (36:13-27)
3. **al-Aya** (الْآيَة) - "The Signs Around You" (36:33-40)
4. **al-Ba'th** (الْبَعْث) - "The Waking" (36:51-83)

---

## Beat 1 - OPEN
- **kicker:** INSIDE THE SURAH
- **titleAr:** يسٓ
- **titleEn:** Ya-Sin
- **subtitle:** The Heart of the Qur'an
- **line:** For as long as anyone can remember, this is the surah the believers have recited at the bedside of the dying - read softly to walk a departing soul gently home. The Prophet ﷺ called it the heart of the Qur'an. Sit with it now, while you are still awake to hear what it is trying to say to you.

## Beat 2 - ORIENTATION
- **eyebrow:** Before you begin
- **promise:** The Prophet ﷺ said that everything has a heart, and the heart of the Qur'an is Ya-Sin - and Fatima al-Zahra (a) is remembered for reciting it often, for the peace it brought her soul. It is a Meccan surah with one quiet concern running underneath everything it says: the human heart that has fallen asleep. Asleep to the messengers sent to it, asleep to the signs all around it, asleep even to the wonder of its own body. Ya-Sin has come to wake it.
- **leaveWith:** You will leave knowing why they called this surah the heart of the Qur'an, and why it is the one read at the edge of death - carrying its single question with you. Not “can God raise the dead?” but something closer to home: are you awake to the God who made you, and who watches over every step you take?

## Beat 3 - ACT I divider (al-Ghafla / The Sleeping Heart)
- **act:** 1  **connector:** nil
- **line:** The surah opens with an oath - by the wise Qur'an - and a truth sworn upon it: you, Muhammad ﷺ, are truly one of the messengers, sent on a straight road. Notice what that settles before anything else. The message is sound. The road is straight. So when it fails to land, the surah turns your eyes not to the words but to the one hearing them - and shows you a heart that has walled itself in.
- **bridge:** 36:3
  - **arabic:** إِنَّكَ لَمِنَ ٱلْمُرْسَلِينَ
  - **translation:** Indeed you are among the messengers,
  - **reference:** Ya-Sin · 36 : 3

## Beat 4 - VERSE 36:9 (The Walls)
- **act:** 1  **tag:** The Walls  **reference:** Ya-Sin · 36 : 9
- **arabic:** وَجَعَلْنَا مِنۢ بَيْنِ أَيْدِيهِمْ سَدًّۭا وَمِنْ خَلْفِهِمْ سَدًّۭا فَأَغْشَيْنَٰهُمْ فَهُمْ لَا يُبْصِرُونَ
- **translation:** And We have set a barrier before them and a barrier behind them, and covered them over, so they do not see.
- **reflection:** Walled in front, walled behind, a cover drawn down over the eyes. But al-Mizan, Tabatabai's great commentary on the Qur'an, is careful with the blame: God did not build these walls to trap an innocent man. Each wall is one the person laid himself, brick by brick, every time he saw the truth and turned away. Imam al-Baqir (a) said that when someone looks straight at the truth and refuses it three times, a barrier settles in between. The Prophet ﷺ put it another way: the heart is a clear mirror, and each sin leaves one dark spot, until nothing gets through. This is not someone who cannot find God. It is someone who has slowly stopped being able to see Him - and no longer even feels the dark closing in.

## Beat 5 - VERSE 36:12 (Nothing Is Lost)
- **act:** 1  **tag:** Nothing Is Lost  **reference:** Ya-Sin · 36 : 12
- **arabic:** إِنَّا نَحْنُ نُحْىِ ٱلْمَوْتَىٰ وَنَكْتُبُ مَا قَدَّمُوا۟ وَءَاثَٰرَهُمْ ۚ وَكُلَّ شَىْءٍ أَحْصَيْنَٰهُ فِىٓ إِمَامٍۢ مُّبِينٍۢ
- **translation:** Indeed, it is We who bring the dead to life, and We write down what they have sent ahead and the traces they leave behind. Everything We have counted up in a clear register.
- **reflection:** Even while the heart sleeps, nothing it does is falling into nowhere. Every deed sent ahead, every trace left behind - a word that outlived you, a habit you passed on - all of it written, none of it lost. And here the surah says the thing it will keep saying: We bring the dead to life. Imam Ali (a) said it in one line that holds the whole surah: “People are asleep, and when they die they wake.” That is the key to everything below. This life is the sleep. Death is the morning. Ya-Sin is the voice trying to wake you before the alarm goes off on its own.

## Beat 6 - NARRATION (The Clear Register) [Imam Mubin = Imam Ali]
- **act:** 1  **tag:** The Clear Register  **source:** Imam al-Baqir (a) · Basa'ir al-Darajat
- **body:** That last phrase hides something. "A clear register" is, in the Arabic, an *imam mubin* - a clear Imam. When the verse came down, two men stood and asked the Prophet ﷺ what this register was. The Torah? No. The Gospel? No. The Qur'an itself? No. Then Imam Ali (a) rose, and the Prophet ﷺ turned to him and said: it is this one - the Imam in whom God has gathered the knowledge of everything. So the place where nothing is ever lost is not only ink on a page. The Ahl al-Bayt taught that it is kept, whole and living, in the Imam - the one heart left wide awake among a sleeping people.
- **reflection:** It fits the surah exactly. A world that forgets still leaves its full account somewhere - and that somewhere is a living guide, awake on behalf of everyone who slept. To hold fast to him is to be remembered, completely, by the one heart that never once dozed off.

## Beat 7 - ACT II divider (Sa'a / The One Who Ran)
- **act:** 2  **connector:** You have seen the walls a heart can build, and the record that misses nothing.
- **line:** Now the surah tells a story - the only real story it tells - to show you the exact opposite of a sleeping heart. A town, three messengers sent to it, and a people who will not listen. And then, from the far edge of the city, one man who was wide awake comes running.
- **bridge:** nil

## Beat 8 - VERSE 36:20 (From the Edge of the City)
- **act:** 2  **tag:** From the Edge of the City  **reference:** Ya-Sin · 36 : 20
- **arabic:** وَجَآءَ مِنْ أَقْصَا ٱلْمَدِينَةِ رَجُلٌۭ يَسْعَىٰ قَالَ يَٰقَوْمِ ٱتَّبِعُوا۟ ٱلْمُرْسَلِينَ
- **translation:** And from the farthest end of the city a man came running. He said, "O my people, follow the messengers.
- **reflection:** He runs. That one word tells you everything about a heart that is awake: it cannot sit still while the truth is being attacked. Al-Mizan notices where he comes from - the farthest edge of the city. The crowds packed near the messengers were the most asleep of all; this man, farthest away in the streets, was the nearest in his heart. Tradition remembers him as Habib the carpenter, a simple working man who had believed in secret, until they threatened the messengers and he could not stay quiet a moment longer. The Ahl al-Bayt saw that same run again at Karbala, in Hurr - who rode over to Imam Husayn (a) the instant he knew where the truth was, though it cost him everything. An awake heart runs toward the truth. It never quite learned how to walk.

## Beat 9 - VERSE 36:26 (Enter Paradise)
- **act:** 2  **tag:** Enter Paradise  **reference:** Ya-Sin · 36 : 26
- **arabic:** قِيلَ ٱدْخُلِ ٱلْجَنَّةَ ۖ قَالَ يَٰلَيْتَ قَوْمِى يَعْلَمُونَ
- **translation:** It was said, "Enter Paradise." He said, "Oh, that my people only knew
- **reflection:** They kill him for it. And the very next words are not his scream but his welcome: Enter Paradise. Al-Mizan notes he did not wait for the Last Day like everyone else - the door opened the instant he fell, the way it does for those who die on the truth. And what is the first thing he says inside? Not one word about the men who killed him. Only this ache: if only my people knew how my Lord has forgiven me, and set me among the honored. He wants them to have what he now has. The Prophet ﷺ prayed the very same way when his own people bloodied him at Uhud: "O God, guide my people, for they do not know." An awake heart, even standing inside Paradise, cannot stop loving the ones still asleep.

## Beat 10 - ACT III divider (al-Aya / The Signs Around You)
- **act:** 3  **connector:** One heart woke, and ran, and would not stop loving even those who struck it down.
- **line:** But most hearts are not moved by a story. So the surah changes tack. It stops arguing and simply starts pointing - at the ground under your feet, at the sky over your head - as if to say: you wanted a sign? You are standing in a whole field of them. Look.
- **bridge:** nil

## Beat 11 - VERSE 36:33 (The Dead Earth)
- **act:** 3  **tag:** The Dead Earth  **reference:** Ya-Sin · 36 : 33
- **arabic:** وَءَايَةٌۭ لَّهُمُ ٱلْأَرْضُ ٱلْمَيْتَةُ أَحْيَيْنَٰهَا وَأَخْرَجْنَا مِنْهَا حَبًّۭا فَمِنْهُ يَأْكُلُونَ
- **translation:** And a sign for them is the dead earth. We bring it to life, and bring out from it grain, and from it they eat.
- **reflection:** Here is the sign closest to your feet. Every winter the ground goes hard and brown and finished, and every spring it is green again - a small resurrection you have watched your whole life and stopped noticing. The surah says: that is exactly what will happen to you. But Imam al-Sadiq (a) turned the verse inward as well. The dead earth, he said, is also the hardened heart - and the same rain that greens a field is the guidance that brings a dead heart back to life. So the sign cuts two ways at once. God revives the ground to promise He can revive your body, and He sends down the Qur'an to prove He can revive your heart.

## Beat 12 - VERSE 36:38 (Even the Sun)
- **act:** 3  **tag:** Even the Sun  **reference:** Ya-Sin · 36 : 38
- **arabic:** وَٱلشَّمْسُ تَجْرِى لِمُسْتَقَرٍّۢ لَّهَا ۚ ذَٰلِكَ تَقْدِيرُ ٱلْعَزِيزِ ٱلْعَلِيمِ
- **translation:** And the sun runs its course to a resting place appointed for it. That is the measuring of the Mighty, the All-Knowing.
- **reflection:** Look up now, at the one thing in the sky nobody can ignore. The sun is not wandering loose; it runs a course measured out for it, to a resting place it was assigned, and it has never once been late. Imam al-Sadiq (a) said that even the sun, before it rises, bows low beneath the Throne and asks permission to come up again. Sit with that picture. The blazing center of our sky is a servant - obedient, on time, awake to its Lord every single dawn. The whole of creation is up and in its place. Only the human heart sleeps in, and calls its sleep freedom.

## Beat 13 - ACT IV divider (al-Ba'th / The Waking)
- **act:** 4  **connector:** The earth wakes every spring, and the sun wakes every dawn, exactly on command.
- **line:** So the surah brings you at last to the one morning you keep pushing out of your mind - the morning you wake. The mockers kept asking, "when is this promise coming?" Here is the answer: a single blast on the Horn, and all the dead are on their feet, streaming out of their graves toward their Lord.
- **bridge:** 36:51
  - **arabic:** وَنُفِخَ فِى ٱلصُّورِ فَإِذَا هُم مِّنَ ٱلْأَجْدَاثِ إِلَىٰ رَبِّهِمْ يَنسِلُونَ
  - **translation:** And the Horn will be blown, and at once they will rush from their graves to their Lord.
  - **reference:** Ya-Sin · 36 : 51

## Beat 14 - VERSE 36:52 (Who Woke Us)
- **act:** 4  **tag:** Who Woke Us  **reference:** Ya-Sin · 36 : 52
- **arabic:** قَالُوا۟ يَٰوَيْلَنَا مَنۢ بَعَثَنَا مِن مَّرْقَدِنَا ۜ ۗ هَٰذَا مَا وَعَدَ ٱلرَّحْمَٰنُ وَصَدَقَ ٱلْمُرْسَلُونَ
- **translation:** They will say, "Oh, no - who has raised us from our sleeping place? This is what the Most Merciful promised, and the messengers told the truth."
- **reflection:** Listen to the word they reach for at the end of the world: our sleeping place. *Marqad* - the bed you lie down in for a nap. Even standing at their own resurrection, some part of them knows the truth of it: death was only ever a sleep, and this is the waking from it. Al-Mizan says the whole scene turns on that one image - the grave a bed, the Horn an alarm, resurrection a person simply sitting up. And in the same breath, the answer comes back to their cry: this is what the Merciful promised. Not the Overpowering, not the Avenging. The Merciful. Even the morning they dreaded is handed to them by the gentlest of His names.

## Beat 15 - VERSE 36:58 (A Word from a Merciful Lord)
- **act:** 4  **tag:** A Word from a Merciful Lord  **reference:** Ya-Sin · 36 : 58
- **arabic:** سَلَٰمٌۭ قَوْلًۭا مِّن رَّبٍّۢ رَّحِيمٍۢ
- **translation:** "Peace" - a word from a Merciful Lord.
- **reflection:** For those who woke while it was still today, the surah has just shown Paradise: gardens, cool shade, fruit, whatever they ask for. And then, over all of it, one word - worth more than the whole garden put together. Salam. Peace. And notice who says it: not an angel, not a servant, but the Lord Himself, greeting them directly. Al-Mizan says this single word is the summit of Paradise, higher than any river or fruit, because the deepest thing a soul was ever hungry for is not a reward at all. It is this: to be known, and welcomed, by the One who made it. Everything the awake heart ever ran toward was leading here - to being spoken to, in peace, by God.

## Beat 16 - CLIMAX (Be) [36:82, resting toward 36:83]
- **act:** 4  **tag:** Be  **source:** Ya-Sin · 36 : 82-83
- **arabic:** إِنَّمَآ أَمْرُهُۥٓ إِذَآ أَرَادَ شَيْـًٔا أَن يَقُولَ لَهُۥ كُن فَيَكُونُ
- **translation:** His command, when He wills a thing, is only to say to it "Be" - and it is.
- **body:** The surah has one last sleeper to wake: the man who is sure the whole thing is impossible. He comes to the Prophet ﷺ holding a crumbled old bone, snaps it apart in his hand and laughs - who is going to bring this back to life? And the surah answers him almost gently, almost surprised: does he really not remember? We made him from a single drop, from very nearly nothing. And now here he stands, a whole arguing man - and he has forgotten the one fact that answers his own question. Say: the One who made it the first time will give it life again. Imam Ali (a) said the return is no harder than the first making - the resurrection will be as the beginning was. And Imam al-Sadiq (a) named why it is even easier: this time, the pattern already exists. And then the surah lifts the whole matter to its root, in six words that hold up the sky:
- **reflection:** "Be," and it is. Imam Ali (a) said God speaks it "with no voice heard and no time passing." That is the God the sleeping heart forgot - not a distant clockmaker, but a will so complete that the instant He wants a thing, it is already made. And the surah's very last breath sets you inside that hand: glory to the One who holds the dominion of all things, and to Him you are returning. Habib knew it at the very start - "to Him you are returned," he told his people before they killed him. The whole surah has been one long shake of the shoulder, saying the same thing: wake up. You are already on your way home.

## Beat 17 - REFLECTION PROMPT
- **tag:** Return
- **prompt:** What has your heart gone to sleep to?
- **placeholder:** a sign you stopped seeing, a truth you keep turning from, someone you stopped running toward…
- **subline:** Ya-Sin is one long, gentle shake of the shoulder - the dead earth, the running sun, the man who woke, the morning every soul is walking toward. Its whole hope is that you wake now, on your own, while waking is still a choice. Before you go, name the one place your heart has quietly fallen asleep - and the first small step toward opening your eyes to it.
- **nextLabel:** One last thing

## Beat 18 - CLOSING
- **tag:** The Close
- **titleAr:** يسٓ
- **essence:** They call it the heart of the Qur'an because it does to the heart what the whole Qur'an came to do - it wakes it. And they read it over the dying because a heart that learned to wake in life has nothing to fear from the morning it is woken for good.
- **line:** You know now why it is read at the last breath, and why it is called the heart. Read it once through in its own words, unhurried - not as a page for the dying, but as the voice that keeps a living heart awake.
