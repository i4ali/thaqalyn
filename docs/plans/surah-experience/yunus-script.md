# "Inside the Surah - Yunus" - Master Script (English)

**Status:** APPROVED (Gate 2), implemented in `Thaqalayn/Content/SurahYunusDive.swift`, and revised per the Stage 5 four-auditor audit (flow, sourcing/Arabic, readability, voice & reverence). The Swift file is the shipped source of truth; this doc mirrors its final copy. English-first; UR/AR deferred.
**Surah:** 10 (Yunus), 109 verses, Meccan. Gating: PREMIUM (default). Placement: catalog entry at surahNumber 10 (between al-Tawba and Yusuf), coverAssetName "YunusCover".
**Framing:** The timing of turning back. God defers judgment on purpose (10:11); people give a perfect yes in the storm and take it back on the shore (Movement I); an invitation stands open the whole time, and some answer it in fair weather (Movement II, with the wali hadith qudsi as its summit narration); and the surah ends its argument with two mirrored scenes - Pharaoh's yes one wave too late, refused with a single word, "Now?" (10:90-92), and the people of Yunus, the only city in history whose collective turn came before the sky fell (climax 10:98). The surah is named for the exception - the name itself is the payoff, revealed only at the climax. A focused thematic slice of a 109-verse discourse, not full coverage (the Nuh panel, the Musa panel, and the Quran's self-defense passages are deliberately off-slice).
**Depth:** 19 beats, est. 13 min. Three movements derived from the slice's natural joints: the storm-yes / the standing invitation / the two endings. Climax is a "quiet" verse (10:98), built up to by the drowning beats and the Nineveh narration. The controlling metaphor is the WINDOW (God's patience holding it open); door language is deliberately avoided (the adjacent al-Tawba dive owns the door).

## House-style + build notes
- **Plain English spelling, NO diacritics** (repo CLAUDE.md). Straight apostrophes only, between letters. Real Arabic script (titleAr / verse arabic / act Arabic) untouched.
- **No em dashes** anywhere - only " - ".
- **No spoilers:** the open and orientation tease the name-mystery (a prophet who appears in one verse, silent - why is the surah his?) without answering it. Post-audit, the open no longer says "no other city ever managed" or "the one exception" - the answer lands only at the climax. The Act III divider says "Two peoples, out of time. Only one of them is answered" without naming which.
- **No threshold map** (`.depths`) - an argument, not a plot.
- **Close is `.closing`** (not `.dua`), so no Listen button is required. No dua/ziyarat Arabic anywhere in the dive.
- **Qur'an Arabic:** every `.verse(arabic:)` and the `.climax` arabic substituted programmatically from `quran_data.json` (byte-identical; never hand-typed or transcript-copied - NFC drift broke the first attempt). No bridge verses.
- **Movement III label:** the persistent "MOVEMENT III · NOW?" bar sits over the Nineveh narration and the climax by conscious decision - at the climax, "Now?" re-reads as addressed to the reader.
- **House follow-up (not this dive):** `climaxPage` in DeepDiveView renders no recitation control, so climax verses (here 10:98) cannot be heard in any dive.

## Sourcing notes (every narration / tafsir claim; post-audit corrections marked ►)
- **10:11** He does not hasten evil the way people hasten after good; His way is built on wisdom, theirs on ignorance/haste; the respite is deliberate - al-Mizan. The angry parent's curse ("O Allah, curse him...") spoken in anger and vexation, given as the example - Majma al-Bayan (Tabrisi); the dive's "may you be ruined" is a household paraphrase. VERIFIED.
- **10:22-23** the you-to-they turn (iltifat) - noted by al-Mizan and Tabrisi at 10:22. ► The fitra-exposed-by-crisis reading is stated EDITORIALLY (unattributed) - al-Mizan's comment on 10:22 is brief ("the meaning is plain"); the developed fitra reading belongs to al-Amthal (Makarem Shirazi). 10:23's "return to wronging the earth" cited by verse number in the reflection. mukhlisin named and glossed in-line.
- **10:24** zukhruf glossed as gold ornament (not "jewelry"). ► Seawater simile is **Imam al-Kazim (a)**, his counsel to Hisham ibn al-Hakam - **Tuhaf al-Uqul p. 396** (the app's tafsir JSON mislabels it as al-Baqir; corrected).
- **10:25** ► the placement point (invitation directly after the vanished harvest) and the two-gifts reading are **Tabrisi's - Majma al-Bayan under 10:25** (not al-Mizan, as first drafted). VERIFIED.
- **10:57-58** the four gifts of 10:57 folded into the 10:58 reflection (Quran-only; "what is in the breasts" glossed as the heart). **Imam al-Baqir (a): "The bounty of Allah is the Messenger of Allah ﷺ, and His mercy is Ali ibn Abi Talib (a)" - Majma al-Bayan under 10:58** (also via Ibn Abbas). **Imam al-Rida (a): the rejoicing is in the wilaya of Muhammad ﷺ and the family of Muhammad, "better than what they amass" - al-Kafi** (Nur al-Thaqalayn under 10:58). wilaya glossed in-line ("the bond of love and following"). VERIFIED VERBATIM. (Do NOT print the fadl-equals-Quran variant.)
- **10:62-64** criterion of 10:63 folded in. **Imam al-Baqir (a): the bushra of this world (10:64) includes the true dream the believer sees - Majma al-Bayan under 10:64.** VERIFIED.
- **The Friendship narration (Movement II summit)** - **Hadith qudsi, al-Kafi vol. 2, p. 352** (Kitab al-Iman wa-l-Kufr): "Whoever humiliates (ahana) a friend of Mine has declared war on Me... My servant keeps drawing near to Me with voluntary acts until I love him - and when I love him, I am the hearing with which he hears and the sight with which he sees." Al-Kafi's own wording ("humiliates", NOT Bukhari's "shows enmity"); the warning and the nawafil promise are the SAME hadith, so the ellipsis is legitimate. VERIFIED.
- **10:90** Pharaoh pursues after watching the sea part; the declaration's shape (a Lord named only as somebody else's) observed editorially, NO tafsir attribution; 79:24 quoted for "I am your highest lord". Translation uses "disobeyed" for عصيت (standard). VERIFIED SAFE.
- **10:91** **Imam al-Rida (a): "he believed at the sight of doom, and faith at the sight of doom is not accepted" - Uyun Akhbar al-Rida** (Nur al-Thaqalayn under 10:90). Coerced vs free faith - al-Mizan (10:91 and 10:99). **The repentance ladder: whoever repents a year before death... a month... a week... a day... "whoever repents before he sees death, Allah accepts his repentance" - Imam al-Sadiq (a) from the Prophet ﷺ, al-Kafi vol. 2, p. 440.** VERIFIED VERBATIM. ► The al-Baqir throat-gesture hadith (same chapter, h.3) is NOT used: its actual content is a closing ruling ("no repentance for the one who knew"), and the first draft had fused it with h.1's merciful sentiment - the fused composite was removed entirely. (Also do NOT print the unverifiable "arrow returned to the bow" image, the "three things rejected" narration, or "ghargharah" wording with an al-Kafi citation.)
- **10:92** the sea commanded to cast his body onto the shore so they saw him dead - Tafsir al-Qummi (Nur al-Thaqalayn under 10:92). "In your body" implying the man is more than the body - al-Mizan (verified verbatim). ► The mummy line softened to "three thousand years later, the body is still here, and the empire is not" (modern observation, no tafsir attribution, no zinger construction). The final clause re-aimed to close the signs-thread and bridge into Nineveh. (The Gabriel-mud narration is attested - Majma via Qummi, with a Sunni parallel - but contested; OMITTED by design.)
- **Nineveh narration (10:98)** - the punishment visible overhead, the missing prophet, the whole city out on the open plain with women, children, and animals, sackcloth, every mother separated from her child (human and beast), the mingled crying, faith and repentance declared, the punishment lifted - **Majma al-Bayan under 10:98, verified elements only**. Restitution (a man pulling a wrongly taken stone from his own foundation) - Ibn Mas'ud's report, cited by Tabrisi in the same passage. "Dispersed onto the mountains" - Tafsir al-Qummi / Tafsir al-Ayyashi narrations. ► Yunus's (a) absence now owned in one clause ("he had left them - the Qur'an tells that story in its own place"). VERIFIED. (Do NOT print the king-descending detail or "forty days" - not in Majma.)
- **10:98 climax** - the people of Yunus as the only community that believed while belief was still a free act (iman ikhtiyari), before the punishment arrived - al-Mizan under 10:98 (verified verbatim). ► **Abu Basir asked Imam al-Sadiq (a)** why they alone were spared; answer: "It was in Allah's knowledge that He would turn it away from them for their repentance" - **Ilal al-Shara'i, via Nur al-Thaqalayn under 10:98** (Imam now named). The conditional decree anchored on 13:39 ("Allah erases what He wills, and makes firm what He wills") - stated with the verse, NOT attributed to al-Mizan. The surah-named-for-the-exception point - editorial. VERIFIED.
- **Closing merit** - **Imam al-Sadiq (a): whoever recites Surah Yunus every two or three months, "it need never be feared that he is among the ignorant (al-jahilin), and on the Day of Resurrection he will be among those drawn near (al-muqarrabin)" - Thawab al-A'mal (Shaykh al-Saduq).** ► "the ignorant" (jahilin), not "the heedless". VERIFIED VERBATIM.

---

## DeepDive meta
- **id:** `surah-yunus`
- **titleEn:** Yunus
- **titleAr:** يُونُس
- **subtitle:** Jonah - how late is too late to turn back to God?
- **sfSymbol:** water.waves
- **estMinutes:** 13

## Acts (movements)
1. **Rih Asif** (رِيحٌ عَاصِفٌ) - "The Storm Wind" (verses 10:11, 10:22, 10:24)
2. **Dar al-Salam** (دَارُ السَّلَام) - "The Invitation" (verses 10:25, 10:58, 10:62; the Friendship narration)
3. **Al'ana** (آلْآنَ) - "Now?" (verses 10:90, 10:91, 10:92; the Nineveh narration; climax 10:98)

---

## Beat 1 - OPEN
- **kicker:** INSIDE THE SURAH
- **titleAr:** يُونُس
- **titleEn:** Yunus
- **subtitle:** Jonah
- **line:** This surah has one hundred and nine verses - and the prophet it is named for appears in exactly one of them, near the very end, without saying a word. Why would the Qur'an give a whole surah the name of someone it barely mentions? The answer waits at the bottom of the descent, and it belongs to his people more than to him. Between here and there, the surah asks everyone in it the same question. By the end, it will be asking you.

## Beat 2 - ORIENTATION
- **eyebrow:** Before you begin
- **promise:** Yunus was revealed in Mecca, in the hardest years of the Prophet's ﷺ mission - and it is a surah about time. It watches people say yes to God at every moment a yes can be said: in fair weather, in the middle of the storm, and at the very last wave. And underneath everything, it keeps asking one question: when does a yes still count? God is patient - the sky does not fall the moment we deserve it to. But this surah is honest about what that patience is for, and about the moment the window it holds open closes.
- **leaveWith:** You will leave knowing the difference between the yes a storm forces out of you and the yes given freely while the sky is clear. And you will finally know why this surah, of all surahs, carries the name of Yunus.

## Beat 3 - ACT I divider (Rih Asif / The Storm Wind)
- **act:** 1  **connector:** nil  **bridge:** nil
- **line:** Begin with a question you have surely asked: why does God wait? People do wrong in broad daylight, and nothing happens. The surah's first answer is that the waiting is not neglect. It is mercy, holding a window open. First watch what His patience is for. Then watch what we do inside it.

## Beat 4 - VERSE 10:11 (If He Hastened)
- **act:** 1  **tag:** If He Hastened  **reference:** Yunus · 10 : 11
- **arabic:** (byte-synced from quran_data.json - see Swift file)
- **translation:** If Allah were to hasten evil for people the way they seek to hasten the good, their term would already have been fulfilled. But We leave those who do not look for the meeting with Us wandering blindly in their transgression.
- **reflection:** People pray for good and want it now. And when they are angry, they ask for harm just as fast - Tabrisi, in his commentary, gives an example every family knows: a parent loses their temper and says to a child, "may you be ruined." Nobody means it. The verse says plainly what would happen if such prayers were granted at the speed we make them: our term would already be over. Not one of us would be left. Al-Mizan - Tabatabai's great commentary - puts the difference in one line: our asking runs on haste and ignorance; His answering is built on wisdom. So the punishment the deniers dare Him to send is not late. It is withheld - on purpose, with a purpose. Every hour you have ever been given is this verse, still holding the window open.

## Beat 5 - VERSE 10:22 (Sincere in the Storm)
- **act:** 1  **tag:** Sincere in the Storm  **reference:** Yunus · 10 : 22
- **arabic:** (byte-synced from quran_data.json)
- **translation:** It is He who carries you over land and sea - until, when you are in ships sailing with a fair wind, rejoicing in it, a storm wind comes, and the waves come at them from every side, and they are certain they are surrounded. Then they call on Allah, sincere to Him in devotion: "If You save us from this, we will surely be among the thankful."
- **reflection:** Halfway through, the verse changes who it is speaking to. It begins with you - "He carries you over land and sea" - and the moment the storm hits, it speaks of them, as if you were watching the ship from above. Under the waves, everything false is thrown off. No idol is called on in a sinking ship. The storm strips away every support people lean on, and what remains, in every human being, calls on God alone. The verse's word for it is mukhlisin - sincere, nothing else mixed in - the Qur'an's highest word for a pure heart, spoken here of drowning men. So the question was never whether you believe. The storm settles that. The question is the shore - because the very next verse says that the moment He saves them, they return to wronging the earth (10:23), as if no one had ever called out at all.

## Beat 6 - VERSE 10:24 (The Shore Is Not Safe)
- **act:** 1  **tag:** The Shore Is Not Safe  **reference:** Yunus · 10 : 24
- **arabic:** (byte-synced from quran_data.json)
- **translation:** The life of this world is like water We send down from the sky: the plants of the earth drink it in, all that people and cattle eat - until, when the earth has taken on its ornament and is made beautiful, and its people are certain they have mastery over it, Our command comes to it by night or by day, and We make it a mown field, as if it had not flourished yesterday. Thus do We detail the signs for people who reflect.
- **reflection:** Why do we take the yes back the moment we reach the shore? Because the shore feels solid. So the surah paints the shore. A land drinks the rain until it is heavy with harvest. The verse says the earth puts on its zukhruf - its gold ornament - and its people grow certain, at last, that it is theirs. Then, "by night or by day," it is a mown field, cut flat, as if yesterday had never happened. Calm water is not evil. It is dangerous for a different reason: it convinces you the storm taught you nothing. Imam al-Kazim (a) said this world is like seawater: the more a thirsty man drinks of it, the thirstier he becomes, until it kills him. The storm-yes was sincere. That was never its flaw. It was tied to the weather - and the surah now shows you a yes tied to something that does not change.

## Beat 7 - ACT II divider (Dar al-Salam / The Invitation)
- **act:** 2  **bridge:** nil
- **connector:** You have seen the yes that only a storm can pull out, and the shore that quietly takes it back.
- **line:** Now hear what stands over every storm and every shore alike. While people bargain with Him wave by wave - save me, and I will be thankful - God is doing something no storm had to prompt. He is inviting. And listen to the name He gave the home He invites you to. The people in the ship were begging for safety. The house He holds open is called Peace.

## Beat 8 - VERSE 10:25 (The Standing Invitation)
- **act:** 2  **tag:** The Standing Invitation  **reference:** Yunus · 10 : 25
- **arabic:** (byte-synced from quran_data.json)
- **translation:** And Allah invites to the Home of Peace, and guides whom He wills to a straight path.
- **reflection:** Tabrisi pauses on where this verse sits: directly after the harvest that vanished overnight. The order is deliberate. First God shows you that every shore is temporary. Then, before the unease can even settle, He opens the one place that is not - and He does not wait to be asked. The verse gives two gifts, not one. The invitation goes out to everyone: no storm required, no crisis needed; it is simply there, open, addressed to you now. The guidance is the second gift: for those who accept, He does not only show the road, He helps you walk it. The storm made people call out to Him once. The invitation asks for something harder, and better: come while the sky is clear.

## Beat 9 - VERSE 10:58 (The Command to Rejoice)
- **act:** 2  **tag:** The Command to Rejoice  **reference:** Yunus · 10 : 58
- **arabic:** (byte-synced from quran_data.json)
- **translation:** Say: In the bounty of Allah and in His mercy - in that let them rejoice. It is better than all they amass.
- **reflection:** A verse just before this one names what has already been sent while the window stands open: counsel from your Lord, a healing for what is in the breasts - for the heart - a guidance, and a mercy (10:57). Not the rescue people scream for in the storm: a cure for the forgetting itself, the thing the storm only briefly interrupts. And then comes a command the Qur'an gives almost nowhere else: rejoice. Not in what you have gathered. In His bounty and His mercy - and the verse says plainly that this is better than everything people pile up. The Ahl al-Bayt, the Prophet's ﷺ household, told us what the two words point to. Imam al-Baqir (a) said: the bounty of Allah is the Messenger of Allah ﷺ, and His mercy is Ali ibn Abi Talib (a). And Imam al-Rida (a) read the verse's ending the same way: rejoicing in the wilaya of Muhammad ﷺ and his family - the bond of love and following that ties you to them - is better than anything they amass. God's answer to a drowning world did not come as a change in the weather. It came as people: the Book in the hands of His Messenger ﷺ, and the household never parted from it.

## Beat 10 - VERSE 10:62 (No Fear, No Grief)
- **act:** 2  **tag:** No Fear, No Grief  **reference:** Yunus · 10 : 62
- **arabic:** (byte-synced from quran_data.json)
- **translation:** Unquestionably, the friends of Allah - no fear shall be upon them, nor shall they grieve.
- **reflection:** Here is what a person becomes when the yes is not hostage to the weather. The surah calls them awliya Allah, the friends of God, and the next verse says exactly who they are: those who believed, and stayed aware of Him (10:63) - in the calm, not only in the waves. Then look at what the verse takes away from them: fear, and grief. Exactly the two things the sea poured into everyone else. The people in the ship were full of both; the friends of God are free of both. Their yes was given long before any storm could demand it, so there is nothing left for the weather to take. And their reward does not wait for Paradise: Imam al-Baqir (a) said the glad tidings promised them in this life (10:64) include the true dream a believer sees. The waves still come to the friends of God. The fear does not.

## Beat 11 - NARRATION (The Friendship)
- **act:** 2  **tag:** The Friendship  **source:** Hadith Qudsi · al-Kafi
- **body:** In al-Kafi, the oldest of the Shia hadith collections, God Himself describes what this friendship is. First a warning: "Whoever humiliates a friend of Mine has declared war on Me." Then a promise, and it is among the most intimate lines in all the hadith: "My servant keeps drawing near to Me with voluntary acts until I love him - and when I love him, I am the hearing with which he hears and the sight with which he sees." A servant walks toward God through small acts no law demanded of him - and the nearness does not stay one-sided. It becomes love. And when it does, nothing of that servant's hearing or seeing is left outside God's care.
- **reflection:** Now the verse you just read makes plain sense. What could a storm threaten, when the eyes that watch it and the ears that hear it are kept by the One who sends and stills every wind? No fear upon them, and they do not grieve - not because the waves spare the friends of God, but because nothing the waves can reach is theirs alone anymore.

## Beat 12 - ACT III divider (Al'ana / Now?)
- **act:** 3  **bridge:** nil
- **connector:** You have seen the invitation that stands over every storm, and the friends who answered it while the sky was clear.
- **line:** But the surah will not let the question stay comfortable. An invitation that stands open must also have a moment when it closes - and the surah's final stretch walks into that moment twice. Once it follows an army into the sea. Once it stands over a city, under a sky already going dark. Two peoples, out of time. Only one of them is answered.

## Beat 13 - VERSE 10:90 (The Last Wave)
- **act:** 3  **tag:** The Last Wave  **reference:** Yunus · 10 : 90
- **arabic:** (byte-synced from quran_data.json)
- **translation:** And We brought the Children of Israel across the sea, and Pharaoh and his hosts pursued them in tyranny and enmity - until, when the drowning overtook him, he said: "I believe that there is no god but the One the Children of Israel believe in, and I am of those who submit."
- **reflection:** Look closely at what Pharaoh has just watched: the sea standing open like a corridor, an entire people walking through it on dry ground. He has seen, with his own eyes, exactly Who is acting. And he rides in anyway - "in tyranny and enmity" - as if the miracle were one more thing he could conquer. Then the water closes. And out of the drowning comes a declaration of faith - a full one, on its face: no god but Him, and I submit. But listen to it once more. Even now, he does not quite address God. He had spent a lifetime saying "I am your highest lord" (79:24); at the end, the only way he can name God is as somebody else's - "the One the Children of Israel believe in." He has no words of his own left for surrender. It is the storm-yes from the beginning of the surah, said one wave too late. And this time, an answer comes back.

## Beat 14 - VERSE 10:91 (Now?)
- **act:** 3  **tag:** Now?  **reference:** Yunus · 10 : 91
- **arabic:** (byte-synced from quran_data.json)
- **translation:** Now? When you disobeyed before, and were one of the corrupters?
- **reflection:** One word in Arabic - Al'ana. "Now?" Imam al-Rida (a) was asked why this faith was refused, and answered: because he believed at the sight of doom, and faith at the sight of doom is not accepted. Al-Mizan explains why. When the punishment is already upon you and there is no way out, saying yes is not a decision anymore; it is forced out of you - and faith that is forced is not faith. So where exactly does the line fall? In al-Kafi, Imam al-Sadiq (a) relates the answer from the Prophet ﷺ: whoever repents a year before his death is accepted. Then he said: a year is much - a month is enough. A month is much - a week. A week is much - a day. And then, the final measure: whoever repents before he sees death, Allah accepts his repentance. The window stays open the whole length of a life. Pharaoh did not run out of mercy. He ran out of moments in which a yes could still mean anything.

## Beat 15 - VERSE 10:92 (The Body)
- **act:** 3  **tag:** The Body  **reference:** Yunus · 10 : 92
- **arabic:** (byte-synced from quran_data.json)
- **translation:** So today We save you - in your body - that you may be a sign for those after you. And indeed many among the people are heedless of Our signs.
- **reflection:** There is mercy in the wording, and there is severity, and they are the same words. God uses the very thing Pharaoh begged for: "We save you." Then He completes the sentence: "in your body" - the only part of Pharaoh left that could still be saved. Tafsir al-Qummi, one of the earliest Shia commentaries, narrates that the sea was commanded to cast the body onto the shore, so that the people he had enslaved could look at him, lifeless, and be certain. Al-Mizan draws the quiet lesson from those two words: a human being is more than a body, and the rest of Pharaoh - the part that mattered - had already gone where rescue could not reach. So the king who called himself the highest lord was kept and preserved as a sign for whoever came after; three thousand years later, the body is still here, and the empire is not. But the verse ends by turning to everyone else: "many among the people are heedless of Our signs." Pharaoh became a sign for those after him because he could not read his own in time. One city, far from Egypt, was about to read theirs.

## Beat 16 - NARRATION (The City That Turned)
- **act:** 3  **tag:** The City That Turned  **source:** Majma al-Bayan (Tabrisi) · under 10 : 98
- **body:** Far from Egypt, in the city of Nineveh, another people had reached the end of their term. Their prophet, Yunus (a), had warned them; they had refused; and he had left them - the Qur'an tells that story in its own place. Now the punishment was no longer only a warning. It was visible: a darkness gathering over the city. Majma al-Bayan, the great commentary of Tabrisi, tells what they did with their final hours. They looked for their prophet, and he was gone. And so, with no messenger left to plead for them, an entire city turned at once. They poured out onto the open plain - men, women, children, even their animals. They put on rough sackcloth. They separated every mother from her child, human and beast alike, until the crying of the young and the calling of the mothers rose and mingled into one sound. It is related that their repentance ran so deep that a man would pull a wrongly taken stone out of the very foundation of his own house to give it back. And they wept, and believed, and begged their Lord - with the darkness still overhead.
- **reflection:** Hold the two scenes side by side, because the surah built them to be held together. Pharaoh under the water, past the point of return - and Nineveh under the cloud, one step before it. Both had refused for years. Both turned only when they saw. The difference between them is a single question of time: the punishment had already overtaken Pharaoh, and it had not yet fallen on Nineveh. One verse now waits to tell you what that difference meant - and what it has to do with the name this surah carries.

## Beat 17 - CLIMAX (The Only City) [10:98]
- **act:** 3  **tag:** The Only City  **source:** Yunus · 10 : 98
- **arabic:** (byte-synced from quran_data.json)
- **translation:** Why was there not a single city that believed, and its faith benefited it - except the people of Yunus? When they believed, We lifted from them the punishment of disgrace in the life of this world, and gave them enjoyment for a time.
- **body:** The verse asks a grieving question, and carves out one exception: why was there not a single city that believed in time... except the people of Yunus. Al-Mizan explains what makes them the exception. Every other people in this surah waited until the punishment was upon them - and by then, saying yes was no longer a choice. The people of Yunus believed while they could still have said no, and that is why their faith was allowed to count. Then comes one of the most astonishing sentences in the Qur'an: We lifted from them the punishment. The decree was real. The darkness was already overhead. And it was turned aside - dispersed onto the mountains, the narrations say - because a city turned back to God, weeping, while there was still time. When Abu Basir asked Imam al-Sadiq (a) why they alone were spared this way, he answered: it was in God's knowledge that He would turn it away from them, for their repentance. "Allah erases what He wills, and makes firm what He wills" (13:39). Not every decree is sealed. Some are written conditionally - hinged on what you will do. And now, at last, the name. Of everything in these one hundred and nine verses, the surah is named for Yunus (a) - the prophet of the one city whose turning was accepted. As if the name itself were the message: it has been done. It can be done. The window is real.
- **reflection:** Every scene of the surah has been aimed here. The patience of the opening - this is what it was holding the window open for. The storm-yes that dried up on the shore - offered earlier, and freely, this is what it could have become. The "Now?" that closed over Pharaoh - for you, that same window is still open. The surah of the too-late yes is named, deliberately, for the just-in-time one. And what it asks of you is both gentle and severe: you are not reading about cities. You are one. If there is a turning you have been postponing for a better season, the decree over it is still conditional - still hinged on what you will do.

## Beat 18 - REFLECTION PROMPT
- **tag:** Return
- **prompt:** Which yes are you saving for a storm?
- **placeholder:** A prayer, an apology, a habit, a debt, a return you keep postponing...
- **subline:** You have walked the whole argument. God's patience, holding the window open. The yes the waves forced out, and the shore that took it back. The invitation to the Home of Peace. The friends who answered while the sky was clear. And two peoples who answered late: one under the water, one under the cloud. The difference between them was time. Before you go, name the turning you have been saving for a harder day - while the word "now" still belongs to you.
- **nextLabel:** One last thing

## Beat 19 - CLOSING
- **tag:** The Close
- **titleAr:** يُونُس
- **essence:** The surah's last verse turns to the Prophet ﷺ: "Be patient, until Allah judges - and He is the best of judges" (10:109). The surah opened with God's patience, holding the sky back; it closes by asking patience of you, until He judges. Between His patience and yours there is a window - and one city that used it.
- **line:** Imam al-Sadiq (a) taught that for whoever recites Surah Yunus even once every two or three months, it need never be feared that he is among the ignorant - and on the Day of Resurrection he will be among those drawn near. Read it now in its own words, all one hundred and nine verses - and hear the question it keeps asking, while it is still being asked gently.
