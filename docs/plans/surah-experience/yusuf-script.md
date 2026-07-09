# Sūrah Yūsuf - Surah Experience: English Master Script (DRAFT for approval)

Drafted from `yusuf-brief.md` (full 111-verse distillation). This is the English master; Urdu + Arabic
translations are added in Task 9 only AFTER you approve this. Qur'anic Arabic is substituted verbatim from
`quran_data.json` (verified byte-for-byte); display translations are hand-written and may be trimmed,
but the recited Arabic is the full ayah. No em dashes. No dua beat.

## Decisions for you to confirm at this gate

1. **Narration source (beat 14).** The forgiveness narration is attributed in our tafsir data only to
   "Imam Jaʿfar al-Ṣādiq" with no book named. The design spec and prior research cite it as **ʿIlal
   al-Sharāʾiʿ**. Options: (i) `source: "Imam Jaʿfar al-Ṣādiq"` (exactly our data), or (ii)
   `source: "Imam Jaʿfar al-Ṣādiq · ʿIlal al-Sharāʾiʿ"` (stronger, from external verified research; the
   book is NOT in our app data). Draft currently uses (i). Tell me which you want.
2. **Faḍīla in the orientation (beat 2).** I included the Ahl al-Bayt teaching that whoever keeps to the
   sūrah's recitation is raised in Yūsuf's beauty (attributed to Imam al-Ṣādiq in our data, no book).
   Keep it, soften it, or drop it?
3. **estMinutes = 12.** A rough reading/listening estimate (Ṣabr uses 5 for 14 beats; this is longer and
   richer, with 8 recitations). Adjust if you prefer.
4. **12:53 attribution.** Our tafsir reads "the soul commands to evil" (12:53) as Yūsuf's own humility
   (not Zulaykha's). Beat 11 follows our data. Flagging since there is a classical alternative reading.

## DeepDive metadata
- id: `surah-yusuf`
- titleEn: `Yūsuf`
- titleAr: `يُوسُف`
- subtitle: `The best of stories - a dream, a pit, and the long road home`
- sfSymbol: `moon.stars`
- estMinutes: `12`
- acts:
  1. ar `الرُّؤْيَا` · tr `al-Ruʾyā` · name **The Dream**
  2. ar `الْبَلَاء` · tr `al-Balāʾ` · name **The Test**
  3. ar `اللِّقَاء` · tr `al-Liqāʾ` · name **The Reunion**

---

## Beat 1 - open
- kicker: **INSIDE THE SŪRAH**
- titleAr: `يُوسُف`
- titleEn: `Yūsuf`
- subtitle: **The Best of Stories**
- line: A boy tells his father a dream, and his father tells him to keep it secret. So begins the best of stories - the long descent from a well in the dark to a throne in Egypt, and the God who was there the whole way down.

## Beat 2 - orientation
- eyebrow: **Before you descend**
- promise: This is the sūrah God sent down in the Year of Sorrow, to console His Prophet after he lost Khadīja and Abū Ṭālib - and He called it the best of stories. Below lies its whole arc: the dream, the well, the palace, the prison, the throne, and the reunion.
- leaveWith: You will leave understanding the soul of the sūrah - that God-consciousness and beautiful patience carry a person from the bottom of a well to the throne - and why the Ahl al-Bayt taught that whoever keeps to its recitation is raised in the light of Yūsuf.

## Beat 3 - act I divider (The Dream)
- act: 1
- connector: (none)
- line: It begins in a father's love and a night vision. A boy is favored, a dream is given, and a jealousy is kindled that will cast him down into the dark - where the story, and God's plan, truly begin.
- bridge: (none)

## Beat 4 - verse (The Dream)
- act: 1
- tag: **The Dream**
- surah/ayah: 12:4
- arabic: `إِذْ قَالَ يُوسُفُ لِأَبِيهِ يَٰٓأَبَتِ إِنِّى رَأَيْتُ أَحَدَ عَشَرَ كَوْكَبًۭا وَٱلشَّمْسَ وَٱلْقَمَرَ رَأَيْتُهُمْ لِى سَٰجِدِينَ`
- translation: When Joseph said to his father, "O my father, I saw eleven stars, and the sun and the moon - I saw them prostrating to me."
- reference: `Yūsuf · 12 : 4`
- reflection: One dream, and the whole sūrah is set in motion. The Ahl al-Bayt read the prostrating stars as a sign of spiritual rank, not worldly power, and said the believers are like stars that borrow their light from the suns of the prophets. Hold this dream the way Yaʿqūb told his son to hold it: a promise from God that will not come true for forty years.

## Beat 5 - depths (The Map of the Sūrah)
- act: 1
- tag: **The Map of the Sūrah**
- reference: `Yūsuf · 12`
- items:
  1. ar `الْجُبّ` · tr `al-Jubb` · label **The Well** · desc "Thrown into the dark by his own brothers, then raised out of it into the house of Egypt's ruler." · reference `12:15` · embodies "loss that becomes the road"
  2. ar `السِّجْن` · tr `al-Sijn` · label **The Prison** · desc "Cast down again by a lie he would not answer with sin, then raised from the cell to the throne." · reference `12:33` · embodies "the pit that becomes power"
  3. ar `اللِّقَاء` · tr `al-Liqāʾ` · label **The Reunion** · desc "Long years of famine and grief, and then the family gathered and the childhood dream made real." · reference `12:100` · embodies "separation that becomes home"

## Beat 6 - verse (Into the Well)
- act: 1
- tag: **Into the Well**
- surah/ayah: 12:15
- arabic: `فَلَمَّا ذَهَبُوا۟ بِهِۦ وَأَجْمَعُوٓا۟ أَن يَجْعَلُوهُ فِى غَيَٰبَتِ ٱلْجُبِّ ۚ وَأَوْحَيْنَآ إِلَيْهِ لَتُنَبِّئَنَّهُم بِأَمْرِهِمْ هَٰذَا وَهُمْ لَا يَشْعُرُونَ`
- translation: So when they took him away and agreed to cast him into the bottom of the well... We revealed to him, "You will surely tell them of this deed of theirs, when they do not perceive who you are."
- reference: `Yūsuf · 12 : 15`
- reflection: At the very bottom - betrayed, alone, a child in the dark - the first voice he hears is God's. Not rescue, but a promise: one day you will stand before them, and they will not know you. Imam ʿAlī said God is nearest to His servant in the hardest hour. The well was not the end of the dream. It was the first step into it.

## Beat 7 - verse (Beautiful Patience)
- act: 1
- tag: **Beautiful Patience**
- surah/ayah: 12:18
- arabic: `وَجَآءُو عَلَىٰ قَمِيصِهِۦ بِدَمٍۢ كَذِبٍۢ ۚ قَالَ بَلْ سَوَّلَتْ لَكُمْ أَنفُسُكُمْ أَمْرًۭا ۖ فَصَبْرٌۭ جَمِيلٌۭ ۖ وَٱللَّهُ ٱلْمُسْتَعَانُ عَلَىٰ مَا تَصِفُونَ`
- translation: And they brought his shirt stained with false blood. He said, "Rather, your souls have enticed you to something. So beautiful patience. And God is the One whose help is sought against what you describe."
- reference: `Yūsuf · 12 : 18`
- reflection: The shirt is whole, untorn by any wolf, and Yaʿqūb knows at once. Yet he does not rage. He says ṣabrun jamīl, beautiful patience. The Ahl al-Bayt defined it as patience that complains to no one but God. Not a heart that does not break - a grief carried to the right door.

## Beat 8 - act II divider (The Test)
- act: 2
- connector: You have watched him fall into the well, and heard God promise he would rise.
- line: Now a second pit, and a subtler one: the ruler's house, its comfort, its temptation, and a prison that will hide, inside its walls, the next turn of God's plan.
- bridge: (none)

## Beat 9 - verse (The Proof of His Lord)
- act: 2
- tag: **The Proof of His Lord**
- surah/ayah: 12:24
- arabic: `وَلَقَدْ هَمَّتْ بِهِۦ ۖ وَهَمَّ بِهَا لَوْلَآ أَن رَّءَا بُرْهَٰنَ رَبِّهِۦ ۚ كَذَٰلِكَ لِنَصْرِفَ عَنْهُ ٱلسُّوٓءَ وَٱلْفَحْشَآءَ ۚ إِنَّهُۥ مِنْ عِبَادِنَا ٱلْمُخْلَصِينَ`
- translation: And she certainly desired him, and he would have desired her - had he not seen the proof of his Lord. So it was, that We might turn away from him evil and indecency. Indeed, he was among Our chosen servants.
- reference: `Yūsuf · 12 : 24`
- reflection: The most delicate verse in the sūrah, and the Ahl al-Bayt read it exactly: he saw the proof of his Lord, and so he never inclined at all. This is ʿiṣma - not a chain that holds a prophet back, but a purity so complete that sin finds no foothold. He was of the mukhlaṣīn, the ones God has purified for Himself.

## Beat 10 - verse (Prison, Not Sin)
- act: 2
- tag: **Prison, Not Sin**
- surah/ayah: 12:33
- arabic: `قَالَ رَبِّ ٱلسِّجْنُ أَحَبُّ إِلَىَّ مِمَّا يَدْعُونَنِىٓ إِلَيْهِ ۖ وَإِلَّا تَصْرِفْ عَنِّى كَيْدَهُنَّ أَصْبُ إِلَيْهِنَّ وَأَكُن مِّنَ ٱلْجَٰهِلِينَ`
- translation: He said, "My Lord, prison is dearer to me than that to which they call me. And if You do not turn their scheming away from me, I may incline to them and be of the ignorant."
- reference: `Yūsuf · 12 : 33`
- reflection: A prophet who will not pretend he is safe from himself. He does not say "I am too pure to fall." He says: keep me from it, or I might. Imam al-Bāqir said the angels marveled that he chose the darkness of a prison over the darkness of sin. Strength is not never being tempted. It is knowing which darkness to fear.

## Beat 11 - verse (The Soul That Commands)
- act: 2
- tag: **The Soul That Commands**
- surah/ayah: 12:53
- arabic: `۞ وَمَآ أُبَرِّئُ نَفْسِىٓ ۚ إِنَّ ٱلنَّفْسَ لَأَمَّارَةٌۢ بِٱلسُّوٓءِ إِلَّا مَا رَحِمَ رَبِّىٓ ۚ إِنَّ رَبِّى غَفُورٌۭ رَّحِيمٌۭ`
- translation: "And I do not absolve my own self. Indeed, the soul is ever commanding to evil, except those on whom my Lord has mercy. Indeed, my Lord is Forgiving, Merciful."
- reference: `Yūsuf · 12 : 53`
- reflection: Even now, cleared of all blame and about to be raised to power, Yūsuf will not flatter himself. From this verse the Ahl al-Bayt drew the whole map of the self: the soul that commands evil, the soul that reproaches itself, and at last the soul at peace - and no one crosses that ground by their own strength, but only by the mercy of their Lord.

## Beat 12 - act III divider (The Reunion) with bridge
- act: 3
- connector: You have seen him tested, kept pure, and raised at last to the throne.
- line: Now the famine he foretold drives them back to Egypt: the brothers who sold him, standing before him for bread, not knowing the minister is the boy from the well. And an old father, still waiting, still refusing to despair.
- bridge: 12:87
  - arabic: `يَٰبَنِىَّ ٱذْهَبُوا۟ فَتَحَسَّسُوا۟ مِن يُوسُفَ وَأَخِيهِ وَلَا تَا۟يْـَٔسُوا۟ مِن رَّوْحِ ٱللَّهِ ۖ إِنَّهُۥ لَا يَا۟يْـَٔسُ مِن رَّوْحِ ٱللَّهِ إِلَّا ٱلْقَوْمُ ٱلْكَٰفِرُونَ`
  - translation: "...and do not despair of God's relief. Indeed, no one despairs of God's relief except the disbelieving people."
  - reference: `Yūsuf · 12 : 87`

## Beat 13 - verse (No Blame Upon You Today)
- act: 3
- tag: **No Blame Upon You Today**
- surah/ayah: 12:92
- arabic: `قَالَ لَا تَثْرِيبَ عَلَيْكُمُ ٱلْيَوْمَ ۖ يَغْفِرُ ٱللَّهُ لَكُمْ ۖ وَهُوَ أَرْحَمُ ٱلرَّٰحِمِينَ`
- translation: He said, "No blame upon you today. May God forgive you, and He is the most merciful of the merciful."
- reference: `Yūsuf · 12 : 92`
- reflection: He holds all the power now, and every right to revenge. Instead: no blame today. Not "I will try, in time, to forgive" - the door is thrown open the very moment it can be. And even his forgiveness he hands upward: may God forgive you. Mercy, at the exact instant it costs the most.

## Beat 14 - narration (The Strength to Forgive)
- act: 3
- tag: **The Strength to Forgive**
- source: `Imam Jaʿfar al-Ṣādiq`   [see decision 1 - may become "Imam Jaʿfar al-Ṣādiq · ʿIlal al-Sharāʾiʿ"]
- body: Standing at the height of his power over the very brothers who had thrown him into the well, Yūsuf forgave them completely. Imam Jaʿfar al-Ṣādiq taught that this was not weakness but the highest form of strength - the strength to overcome the self's own hunger for revenge. The soul that once "commands to evil" is answered, at the last, by a mercy that asks nothing back.
- reflection: To forgive from weakness is only to be unable to strike. To forgive from the throne - holding every power to punish, and setting it down - is the victory the whole sūrah has been climbing toward.

## Beat 15 - verse (The Dream Fulfilled)
- act: 3
- tag: **The Dream Fulfilled**
- surah/ayah: 12:100
- arabic: `وَرَفَعَ أَبَوَيْهِ عَلَى ٱلْعَرْشِ وَخَرُّوا۟ لَهُۥ سُجَّدًۭا ۖ وَقَالَ يَٰٓأَبَتِ هَٰذَا تَأْوِيلُ رُءْيَٰىَ مِن قَبْلُ قَدْ جَعَلَهَا رَبِّى حَقًّۭا ۖ وَقَدْ أَحْسَنَ بِىٓ إِذْ أَخْرَجَنِى مِنَ ٱلسِّجْنِ وَجَآءَ بِكُم مِّنَ ٱلْبَدْوِ مِنۢ بَعْدِ أَن نَّزَغَ ٱلشَّيْطَٰنُ بَيْنِى وَبَيْنَ إِخْوَتِىٓ ۚ إِنَّ رَبِّى لَطِيفٌۭ لِّمَا يَشَآءُ ۚ إِنَّهُۥ هُوَ ٱلْعَلِيمُ ٱلْحَكِيمُ`
- translation: "...and they fell down before him in prostration. And he said, 'O my father, this is the meaning of my vision of long ago. My Lord has made it real. He was good to me when He brought me out of the prison and brought you from the desert, after Satan had sown discord between me and my brothers...'"
- reference: `Yūsuf · 12 : 100`
- reflection: Forty years later, the eleven and the sun and the moon bow down - exactly as the boy had dreamed. And notice how he tells it: he says God brought him out of the prison, and never once out of the well; he blames Satan for the rift, and names no brother. Even the memory, he tells with mercy.

## Beat 16 - climax (Why It All Held)
- act: 3
- tag: **Why It All Held**
- source: `Yūsuf · 12 : 90`
- arabic: `إِنَّهُۥ مَن يَتَّقِ وَيَصْبِرْ فَإِنَّ ٱللَّهَ لَا يُضِيعُ أَجْرَ ٱلْمُحْسِنِينَ`
- translation: Indeed, whoever is mindful of God and is patient - God does not let the reward of those who do good be lost.
- body: When his brothers finally ask, "Are you really Yūsuf?", he gives them the meaning of everything: God has favored us. And then the line that holds the whole sūrah together - whoever is mindful of God and patient, God does not let the reward of the doers of good be lost. The dream, the well, the slavery, the prison, the long wait: none of it was wasted. Not one hour of it.
- reflection: This is the soul of the sūrah. Beautiful patience is not the absence of pain. It is the certainty that God is keeping an account no darkness can erase. Every pit was a road. Every year was counted.

## Beat 17 - reflectionPrompt
- tag: **Return**
- prompt: What is the well you are in?
- placeholder: A loss, a long wait, an injustice, a door that will not open...
- subline: You have walked the whole descent - the dream, the well, the prison, the reunion. Yūsuf's story says no faithful patience is ever wasted. Before you go, name the pit you are in, and the dream you are being asked to keep trusting.
- nextLabel: One last thing

## Beat 18 - closing
- tag: **The Close**
- titleAr: `يُوسُف`
- essence: At the summit of all his power, Yūsuf asked God for one thing only: to die in submission, and to be joined with the righteous.
- line: That is where the best of stories comes to rest - not on a throne, but on a heart that gave every rise back to God. Read the sūrah now in its own words, and let the dream unfold in full.
- (primary action: Read the full sūrah, opens Sūrah 12)
