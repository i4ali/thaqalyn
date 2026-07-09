# "Inside the Sūrah - al-Baqara" - Master Script (English)

**Status:** APPROVED (English); built in `Thaqalayn/Content/SurahBaqaraDive.swift`; Stage-5 audit fixes applied (honorifics Yūsuf-style, "weight in gold", 2:74 dual attribution, page direction, "question after question"). UR/AR deferred (bare string literals).
**Surah:** 2 (al-Baqara), 286 verses. Gating: Premium (default). Placement: in the hub.
**Slice:** NOT full coverage. One narrative slice - the story that names the sūrah (2:67-74) - read as a mirror, with Ibrāhīm's submission (2:131) as the answering foil.
**Framing:** *Why "The Cow"?* Obedience was always the shortest road. A simple command becomes ruinous because they went looking for the exit; the reveal (a hidden murder, a resurrection sign) lands in-flow at 2:72; then stone hearts; then, one page on, the other way - Ibrāhīm's one-word "I submit."
**Structure:** **2 movements + a coda** (the story has one natural hinge - the reveal at 2:72 - and Ibrāhīm is a foil, not a third act). The renderer was generalized (`dive.acts.count`, no hardcoded "3") so this renders honestly as "Depth N of 2," with the coda beats label-less.
**Depth:** 16 beats, est. 11 min.

## Sourcing notes (every narration / tafsir claim)
- **The cow narrative (2:67-73)** - Qurʾān + **al-Mīzān** (Ṭabāṭabāʾī) and **Majmaʿ al-Bayān** (Ṭabrisī) → app tafsir layer2 (2:67-73).
- **The "mocking" response reveals a sick heart; Mūsā seeks refuge rather than defend God** → Majmaʿ al-Bayān; **Imam Jaʿfar al-Ṣādiq (ʿalayhi al-salām)** → app tafsir layer4 (2:67).
- **Any cow would have sufficed; each question narrowed the command; "your Lord" not "our Lord" shows distance** → al-Mīzān / Majmaʿ al-Bayān → app tafsir layer2 (2:68-71).
- **"Allah gives people the difficulty they seek"** → **Imam al-Ṣādiq (ʿalayhi al-salām)** → app tafsir layer4 (2:68-69).
- **They obeyed only when out of excuses ("they almost did not")** → al-Mīzān → app tafsir layer2 (2:71).
- **The Price narration** - the qualifying cow belonged to a young man; his late father had left it to him and his mother; he would not sell without his mother's leave; bought for its weight in gold (a variant reads "its hide filled with gold") → **Majmaʿ al-Bayān** + Ahl al-Bayt narrations → app tafsir layer2/layer4 (2:71). *Riwāyāt vary in detail (some say a righteous orphan); the constant is "its weight / hide in gold." Told as a tradition ("they say"), not asserted as certain.* **[Auditor B to verify wording at Stage 5.]**
- **The murder** - a wealthy man killed by a relative for his inheritance; the body cast onto another tribe; the killer loudest among the accusers → al-Mīzān + **Imam al-Ṣādiq (ʿalayhi al-salām)** → app tafsir layer2/layer4 (2:72).
- **The revival** - struck with part of the cow, the dead man named his killer, then died again; the murder solved and Resurrection proven in one act → al-Mīzān, Majmaʿ al-Bayān, Ahl al-Bayt → app tafsir layer2/layer4 (2:73).
- **Hearts harder than stone; miracles do not soften a heart buried under sins and forgetfulness of death** → **Imam al-Ṣādiq / Imam ʿAlī (ʿalayhim al-salām)** → app tafsir layer4 (2:74).
- **Ibrāhīm's "aslamtu" is the very definition of islām - a self handed over, not a ritual** → al-Mīzān → app tafsir layer2 (2:131).
- **Ibrāhīm spoke for all who follow his path - the Prophet ﷺ and the pure Imams** → **Imam al-Ṣādiq (ʿalayhi al-salām)** → app tafsir layer4 (2:131).
- **The command "submit" still addresses every believer** → **Imam Mūsā al-Kāẓim (ʿalayhi al-salām)** → app tafsir layer4 (2:131).
- Honorifics: the Prophet Muḥammad ﷺ; prophets Mūsā, Ibrāhīm; Imams (ʿalayhi al-salām). **No em dashes.** Qurʾān Arabic verbatim from quran_data.json (pulled via `scripts/pull_arabic.py`).

---

## DeepDive meta
- **id:** `surah-baqara`
- **titleEn:** al-Baqara
- **titleAr:** الْبَقَرَة
- **subtitle:** The Cow - why the mightiest sūrah bears so plain a name
- **sfSymbol:** hands.sparkles.fill
- **estMinutes:** 11

## Acts (movements) - two, plus a label-less coda
1. **al-Suʾāl** (السُّؤَال) - "The Asking" (verses 67-71)
2. **al-Āya** (الآيَة) - "The Sign" (verses 72-74)
- *Coda (no movement label): Ibrāhīm 2:131. Beats carry `act: 3` but `3` is not declared in `acts:`, so `placeInfo` returns nil and they render with no "Movement" chrome.*

---

## Beat 1 - OPEN
- **kicker:** INSIDE THE SŪRAH
- **titleAr:** الْبَقَرَة
- **titleEn:** al-Baqara
- **subtitle:** The Cow
- **line:** Two hundred and eighty-six verses - the longest sūrah in the Qurʾān, a whole world of law, covenant, and guidance. And of every name it could have carried, God gave it this one: al-Baqara, The Cow. Why would the mightiest chapter of the Book be named after a single, strange command to slaughter a cow?

## Beat 2 - ORIENTATION
- **eyebrow:** Before you begin
- **promise:** The answer is a story, one of the strangest in the Qurʾān. God gives the Children of Israel a command so simple a child could obey it in an afternoon. And instead of obeying, they talk. They question, they qualify, they ask again, until the easiest thing in the world has become nearly impossible. And that, it turns out, is the whole point.
- **leaveWith:** You will leave seeing why this small, strange episode names the greatest sūrah in the Book - because it was never really about a cow. It is a mirror held up to every one of us. And one short verse, a few pages on, will land as the answer to everything the cow lays bare.

## Beat 3 - ACT I divider (al-Suʾāl / The Asking)
- **act:** 1
- **connector:** nil
- **line:** It begins with a prophet and a plain command. Mūsā comes to his people with a single instruction from God: slaughter a cow. No cow in particular. Any cow would do. What happens next is not rebellion, and not open refusal. It is something quieter, and far more familiar. They begin to ask questions.
- **bridge:** nil

## Beat 4 - VERSE 2:67 (A Plain Command)
- **act:** 1  **tag:** A Plain Command  **surah/ayah:** 2:67  **reference:** al-Baqara · 2 : 67
- **arabic:** وَإِذْ قَالَ مُوسَىٰ لِقَوْمِهِۦٓ إِنَّ ٱللَّهَ يَأْمُرُكُمْ أَن تَذْبَحُوا۟ بَقَرَةًۭ ۖ قَالُوٓا۟ أَتَتَّخِذُنَا هُزُوًۭا ۖ قَالَ أَعُوذُ بِٱللَّهِ أَنْ أَكُونَ مِنَ ٱلْجَٰهِلِينَ
- **translation:** And when Moses said to his people, "God commands you to slaughter a cow," they said, "Are you making fun of us?" He said, "I seek refuge in God from being one of the ignorant."
- **reflection:** Notice their very first response to a command from God: not "how?" but "are you mocking us?" Majmaʿ al-Bayān reads their offense as the tell of a sick heart. They could not imagine that so plain a thing might carry any wisdom, so they assumed it must be a joke. And notice Mūsā. He does not argue, and he does not defend God, who needs no defense. He simply seeks refuge from being one of the ignorant, because to meet a command of God with ridicule, Imam al-Ṣādiq (ʿalayhi al-salām) taught, is itself where ignorance begins.

## Beat 5 - VERSE 2:68 (What Kind?)
- **act:** 1  **tag:** What Kind?  **surah/ayah:** 2:68  **reference:** al-Baqara · 2 : 68
- **arabic:** قَالُوا۟ ٱدْعُ لَنَا رَبَّكَ يُبَيِّن لَّنَا مَا هِىَ ۚ قَالَ إِنَّهُۥ يَقُولُ إِنَّهَا بَقَرَةٌۭ لَّا فَارِضٌۭ وَلَا بِكْرٌ عَوَانٌۢ بَيْنَ ذَٰلِكَ ۖ فَٱفْعَلُوا۟ مَا تُؤْمَرُونَ
- **translation:** They said, "Call on your Lord for us, to make clear what it is." He said, "He says it is a cow neither old nor young, but middling between the two, so do what you are commanded."
- **reflection:** The command was already complete. Any cow would have done. But instead of picking up the knife, they ask for a specification, and God answers: a cow of middle age. Al-Mīzān draws out the quiet point that governs the whole story - had they slaughtered any cow the moment they were told, it would already be finished. Their question was not a sin. It simply opened a door, and once the door was open, each answer narrowed the road behind them. Hear, too, how they speak: "your Lord," not "our Lord." Already a small step back, as though God were Mūsā's business and not their own.

## Beat 6 - VERSE 2:69 (What Color?)
- **act:** 1  **tag:** What Color?  **surah/ayah:** 2:69  **reference:** al-Baqara · 2 : 69
- **arabic:** قَالُوا۟ ٱدْعُ لَنَا رَبَّكَ يُبَيِّن لَّنَا مَا لَوْنُهَا ۚ قَالَ إِنَّهُۥ يَقُولُ إِنَّهَا بَقَرَةٌۭ صَفْرَآءُ فَاقِعٌۭ لَّوْنُهَا تَسُرُّ ٱلنَّٰظِرِينَ
- **translation:** They said, "Call on your Lord for us, to show us her color." He said, "He says she is a yellow cow, bright in color, pleasing to those who look at her."
- **reflection:** Now the color, a detail that has nothing to do with the command and everything to do with delay. And the answer tightens again: not just yellow, but a vivid, flawless yellow, pleasing to the eye - in their world, a rare and costly animal. When they went on to say, "all cows look alike to us, and if God wills, we shall be guided," even their piety had become a way to keep asking while sounding humble. Imam al-Ṣādiq (ʿalayhi al-salām) named the principle underneath it all: God gives people the difficulty they go looking for.

## Beat 7 - VERSE 2:71 (The Last Question)
- **act:** 1  **tag:** The Last Question  **surah/ayah:** 2:71  **reference:** al-Baqara · 2 : 71
- **arabic:** قَالَ إِنَّهُۥ يَقُولُ إِنَّهَا بَقَرَةٌۭ لَّا ذَلُولٌۭ تُثِيرُ ٱلْأَرْضَ وَلَا تَسْقِى ٱلْحَرْثَ مُسَلَّمَةٌۭ لَّا شِيَةَ فِيهَا ۚ قَالُوا۟ ٱلْـَٰٔنَ جِئْتَ بِٱلْحَقِّ ۚ فَذَبَحُوهَا وَمَا كَادُوا۟ يَفْعَلُونَ
- **translation:** He said, "He says she is a cow not broken to plow the earth or water the field, sound, with no mark upon her." They said, "Now you have brought the truth." So they slaughtered her, though they almost did not.
- **reflection:** One command has become five conditions, and now only a single cow in all the land can meet them: never worked, never blemished, flawless. Hear what they say when the description is finally narrow enough - "now you have brought the truth," as if every true answer before this had somehow not been. And then the verse's quietest and most devastating phrase: they slaughtered her, but they almost did not. Even cornered, with no question left to ask, obedience came hard. Al-Mīzān notes they obeyed at last not because their hearts had softened, but because they had simply run out of excuses.

## Beat 8 - NARRATION (The Price)
- **act:** 1  **tag:** The Price
- **source:** Majmaʿ al-Bayān (Ṭabrisī); narrations of the Ahl al-Bayt
- **body:** There is a tradition about the one cow that finally fit. It belonged, they say, to a young man whose late father had left it to him and to his mother, the whole of their inheritance. When the people came desperate to buy it, he would not sell without his mother's leave, again and again, however high they raised the price. In the end they paid for that single cow its own weight in gold. The command had cost them a fortune, and every coin of it was a price they had set themselves, question by question.
- **reflection:** This is the strange arithmetic of resistance. The cow God asked for was free; the cow their questions built was ruinous. Nothing had changed but them. And so the sūrah lets us watch, in slow motion, a thing we would rather not see in ourselves: how often the weight of a command is not in the command at all, but in our search for a way around it.

## Beat 9 - ACT II divider (al-Āya / The Sign)
- **act:** 2
- **connector:** You have watched a simple command swell into a fortune, and a free thing become the hardest thing in the world.
- **line:** And now the sūrah does something you do not expect. It stops the story, turns, and speaks straight to them, to tell them what all of this was really for. Because none of them knew. Not while they argued over the color of a cow. There was something buried beneath this whole episode, and God is about to bring it up into the light.
- **bridge:** nil

## Beat 10 - VERSE 2:72 (The Reveal)
- **act:** 2  **tag:** The Reveal  **surah/ayah:** 2:72  **reference:** al-Baqara · 2 : 72
- **arabic:** وَإِذْ قَتَلْتُمْ نَفْسًۭا فَٱدَّٰرَْٰٔتُمْ فِيهَا ۖ وَٱللَّهُ مُخْرِجٌۭ مَّا كُنتُمْ تَكْتُمُونَ
- **translation:** And when you killed a soul and cast the blame on one another over it, God was to bring out what you were hiding.
- **reflection:** Here is the floor giving way. There had been a murder. Al-Mīzān and the narrations of the Ahl al-Bayt fill in what the verse compresses: a wealthy man killed by a relative who wanted his inheritance, the body left where it would fall on another tribe, and then the killer himself loudest among those crying for justice. A community was tearing itself apart with accusation, and no one could find the truth. This was the crisis under everything. The cow was never a riddle. It was God's answer to a murder, and they had spent all their questions delaying it.

## Beat 11 - VERSE 2:73 (Thus God Gives Life)
- **act:** 2  **tag:** Thus God Gives Life  **surah/ayah:** 2:73  **reference:** al-Baqara · 2 : 73
- **arabic:** فَقُلْنَا ٱضْرِبُوهُ بِبَعْضِهَا ۚ كَذَٰلِكَ يُحْىِ ٱللَّهُ ٱلْمَوْتَىٰ وَيُرِيكُمْ ءَايَٰتِهِۦ لَعَلَّكُمْ تَعْقِلُونَ
- **translation:** So We said, "Strike him with part of it." Thus does God give life to the dead, and shows you His signs, that you might understand.
- **reflection:** They struck the dead man with a piece of the very cow they had so resented buying, and he lived. Long enough, the Ahl al-Bayt narrate, to name the one who had killed him, and then he returned to death. In a single instant, three things were done at once: a murder solved, a victim vindicated, and a whole people shown, with their own eyes, that God brings the dead back to life. The command they had treated as a joke turned out to hold justice for the murdered and a proof of the Resurrection in the same hand. "That you might understand." The cow was always pointing past itself, at the God who can undo even death.

## Beat 12 - VERSE 2:74 (Harder Than Stone)
- **act:** 2  **tag:** Harder Than Stone  **surah/ayah:** 2:74  **reference:** al-Baqara · 2 : 74
- **arabic:** ثُمَّ قَسَتْ قُلُوبُكُم مِّنۢ بَعْدِ ذَٰلِكَ فَهِىَ كَٱلْحِجَارَةِ أَوْ أَشَدُّ قَسْوَةًۭ ۚ وَإِنَّ مِنَ ٱلْحِجَارَةِ لَمَا يَتَفَجَّرُ مِنْهُ ٱلْأَنْهَٰرُ ۚ وَإِنَّ مِنْهَا لَمَا يَشَّقَّقُ فَيَخْرُجُ مِنْهُ ٱلْمَآءُ ۚ وَإِنَّ مِنْهَا لَمَا يَهْبِطُ مِنْ خَشْيَةِ ٱللَّهِ ۗ وَمَا ٱللَّهُ بِغَٰفِلٍ عَمَّا تَعْمَلُونَ
- **translation:** Then, after all that, your hearts hardened until they were like stones, or harder still. For there are stones from which rivers burst; and some that split so the water runs out; and some that fall down in awe of God. And God is not unaware of what you do.
- **reflection:** You would think a people who had just watched the dead sit up and speak could never doubt again. And the verse tells us: their hearts hardened. This is the most frightening line in the whole passage, because it says a miracle is not enough - that a heart can witness God's power directly and still turn to stone. Then God shames that stone with real stone: rock splits and rivers pour from it; boulders tremble and fall down for fear of Him. Even the mountains answer their Maker. Imam al-Ṣādiq and Imam ʿAlī (ʿalayhim al-salām) named what buries a heart so deep: a pile-up of sins, and a long forgetting of death. The danger was never that they lacked proof. It was that they had stopped letting anything in.

## Beat 13 - CLIMAX 2:131 (coda - One Word)
- **act:** 3  **tag:** One Word  **source:** al-Baqara · 2 : 131
- **arabic:** إِذْ قَالَ لَهُۥ رَبُّهُۥٓ أَسْلِمْ ۖ قَالَ أَسْلَمْتُ لِرَبِّ ٱلْعَٰلَمِينَ
- **translation:** When his Lord said to him, "Submit," he said, "I have submitted to the Lord of all the worlds."
- **body:** Hold the cow in your mind - the questions, the delay, the hardening - and now turn a few pages on, to the same sūrah, a different man, a different command. God says to Ibrāhīm one word: aslim. Submit. And before the word is even cold, Ibrāhīm answers: aslamtu. I have submitted, to the Lord of all the worlds. No "submit to what?" No "submit in what color?" One word from God, and one word back. This is the entire distance between a heart of stone and a heart alive, and the sūrah has set them side by side on purpose.
- **reflection:** The Children of Israel were asked once and answered with question after question, then obeyed grudgingly. Ibrāhīm was asked once and had already said yes. Al-Mīzān calls his answer the very meaning of islām: not a ritual you perform, but a self you hand over. Everything the cow exposed - the flinching, the bargaining, the hunt for the exit - Ibrāhīm simply does not do. He is living proof that obedience was always the shortest road. It was only ever our questions that made it long.

## Beat 14 - NARRATION (coda - Still Addressing You)
- **act:** 3  **tag:** Still Addressing You
- **source:** Narrations of the Ahl al-Bayt - Imam al-Ṣādiq, Imam al-Kāẓim (ʿalayhim al-salām)
- **body:** Imam Jaʿfar al-Ṣādiq (ʿalayhi al-salām) taught that when Ibrāhīm said "I have submitted," he was not speaking for himself alone. He was speaking for everyone who would ever walk his path, the Prophet Muḥammad ﷺ and the pure Imams among them. And Imam al-Kāẓim (ʿalayhi al-salām) said the command has never once fallen silent: aslim, submit, is still being spoken, to you, now. The only thing the sūrah leaves open is which of the two answers will be yours.
- **reflection:** This is why the cow names the sūrah, and not the covenant, or the law, or the throne. Because al-Baqara is not telling you a curious old story about a people who argued with a prophet. It is holding up a mirror and asking, gently: when God asks something of you, and you already know the answer, why are you still asking questions?

## Beat 15 - REFLECTION PROMPT (The Return)
- **tag:** The Return
- **prompt:** Where are you still asking questions?
- **placeholder:** A command you already understand, a change you keep qualifying, a step you keep putting off…
- **subline:** You have watched a free command turn ruinous, a murder undone by a mercy no one saw coming, and one man who simply said yes. Somewhere in your own life is a thing you already know God asks of you, and a set of questions you keep asking to postpone it. Name it. That is your cow.
- **nextLabel:** One last thing

## Beat 16 - CLOSING (The Close)
- **tag:** The Close
- **titleAr:** الْبَقَرَة
- **essence:** A whole sūrah named after a cow, to teach the one thing a prophet's people learned the hardest way: obedience was always the shortest road.
- **line:** That is the mirror hidden inside al-Baqara. Read the story now in its own words - the command, the questions, the sign, the stone - and then Ibrāhīm's single, sufficient word. And the next time God asks something plain of you, may you be the one who has already said: I have submitted.
