# "Inside the Surah - al-Maida" - Master Script (English)

**Status:** APPROVED (Gate 2), implemented in `Thaqalayn/Content/SurahMaidaDive.swift`, and revised per the Stage 5 four-auditor audit (flow, sourcing/Arabic, readability, voice). The Swift file is the shipped source of truth; this doc mirrors its final copy. English-first; UR/AR deferred.
**Surah:** 5 (al-Maida), 120 verses. Gating: PREMIUM (default). Placement: catalog entry after al-Nisa (surahNumber 5).
**Framing:** The Covenant - a bond made (5:1, 5:7), a bond broken (5:12-13), a bond sealed and the faith completed at Ghadir (5:51, 55, 67, and 5:3). A focused thematic slice of a long legal surah, not full coverage.
**Depth:** 16 beats, est. 12 min. Build-to-a-peak shape (closest to al-Fatiha), not a three-station ladder.

## House-style + build notes
- **Plain English spelling, NO diacritics** (repo CLAUDE.md): Ma'ida, wilaya, Ali, Ghadir Khumm, al-Mizan, naqib, Ahl al-Bayt, ruku, mawla, awliya, waliyyukum. Straight apostrophes only, between letters. Real Arabic script (titleAr / verse arabic / act Arabic) is untouched.
- **No em dashes** anywhere - only " - ".
- **No spoilers**: Ghadir / the completion unfold in-flow in Movement III. Orientation and dividers tease the arc (made / broken / sealed) without naming Ghadir or the ring.
- **No threshold map** (`.depths`) - thematic argument, not a plot; a map would flatten and spoil.
- **Close is `.closing`** (not `.dua`), so no Listen button is required.
- **Qur'an Arabic**: every `.verse(arabic:)` pulled verbatim via `pull_arabic.py` at implementation. The `.climax` Arabic is the byte-exact **completion-clause substring** of 5:3 (sliced programmatically from quran_data.json, not hand-typed), the same technique as Yusuf's climax quoting only a clause of 12:90.

## Sourcing notes (every narration / tafsir claim)
- **5:1 `'uqud`** covers every bond up to the primordial covenant; the greatest bond is the covenant with the Prophet and his family - **Imam al-Baqir (a)**; al-Mizan (Tabatabai). App tafsir_5 layer2 + layer4.
- **5:7 `sami'na wa ata'na`** vs. the "we hear and disobey" recorded of some before; the covenant renewed in every prayer - al-Mizan, Majma al-Bayan (Tabrisi). layer2.
- **5:12 twelve `naqibs` -> twelve Imams** parallel; the condition is to believe in the messengers AND support them (`'azzartumuhum`) - **Imam al-Baqir & Imam al-Sadiq (a)**; al-Mizan. layer2 + layer4.
- **5:13** breaking the covenant, hardened hearts, distortion of the words; framed as a mirror-warning, closing on "pardon them - God loves the doers of good" - al-Mizan. layer2 + layer4.
- **5:51 `awliya`** = primary guardianship / allegiance, explicitly NOT a ban on kindness, fairness, or normal dealings (which God commands elsewhere in the same sura) - al-Mizan; **the Imams (a) in al-Kafi**. layer2 + layer4.
- **5:55 the ring in ruku** = **Imam Ali (a)**; singular `waliyyukum` = one unbroken authority descending from God through His Messenger; the promise of 5:56 (`hizb Allah`) folded into the reflection - al-Kafi, al-Amali, al-Mizan, Majma al-Bayan; **Imams al-Baqir & al-Sadiq (a)**. layer2 + layer4.
- **5:67 -> Ghadir**: "deliver... or you have delivered nothing"; "God will protect you from the people"; the Prophet halted the caravan - al-Mizan, Majma al-Bayan. layer2 + layer4.
- **Ghadir sermon** "man kuntu mawlahu fa-Ali-un mawlahu", with "Allahumma wali man walahu wa 'adi man 'adahu" - narrated in **both** traditions (Shia: al-Kafi, al-Amali of al-Saduq/al-Tusi; Sunni: Musnad Ahmad, Sunan al-Tirmidhi, al-Nasa'i, al-Hakim's Mustadrak). Widely graded mutawatir.
- **5:3 completion at Ghadir** (18 Dhul-Hijjah); the Prophet's takbir "for the perfection of religion... and Ali's wilaya after me" - al-Mizan (which notes even Ibn Jarir al-Tabari narrated the Ghadir timing). layer2 + layer4.
- **5:114-115 the table** (close only) - a sign / festival sent to settle the disciples' hearts, with a warning for whoever denies it after - al-Mizan. layer2.
- **Hadith al-Thaqalayn** echo in the climax reflection ("the Book, and the household that would never leave it") - the app's namesake; mutawatir.

---

## DeepDive meta
- **id:** `surah-maida`
- **titleEn:** al-Maida
- **titleAr:** الْمَائِدَة
- **subtitle:** The Table Spread - a bond made, broken, and sealed
- **sfSymbol:** link
- **estMinutes:** 12

## Acts (movements)
1. **al-'Ahd** (الْعَهْد) - "The Bond" (verses 5:1, 5:7)
2. **al-Naqd** (النَّقْض) - "The Breaking" (verses 5:12-13)
3. **al-Ikmal** (الْإِكْمَال) - "The Completion" (verses 5:51, 5:55, 5:67, Ghadir, 5:3)

---

## Beat 1 - OPEN
- **kicker:** INSIDE THE SURAH
- **titleAr:** الْمَائِدَة
- **titleEn:** al-Maida
- **subtitle:** The Table Spread
- **line:** One of the last surahs to be revealed, in the final months of the Prophet's ﷺ life. It does not begin with a story. It begins with a command - fulfill your bonds - and it does not rest until the last bond of the faith is sealed. This is the surah of the covenant kept.

## Beat 2 - ORIENTATION
- **eyebrow:** Before you begin
- **promise:** It takes its name from a table sent down from heaven, a story near its end. But its heart is a single word from its very first line: bonds. This is the surah of your covenant with God - the promise you made Him, the promise a people before you made and broke, and the final promise that completed the faith itself.
- **leaveWith:** You will leave having traced one bond across the whole surah - made, broken, and finally sealed - and understanding why the Ahl al-Bayt said the day it was sealed was the day your religion was completed.

## Beat 3 - ACT I divider (al-'Ahd / The Bond)
- **act:** 1
- **connector:** nil
- **line:** Every bond you have ever given carries weight before God. But the one this surah reaches for first is the oldest you carry - the promise your soul made to Him before you were born, simply by being His. Fulfilling your bonds begins all the way back there.
- **bridge:** nil

## Beat 4 - VERSE 5:1 (Fulfill Your Bonds)
- **act:** 1  **tag:** Fulfill Your Bonds  **surah/ayah:** 5:1  **reference:** al-Maida · 5 : 1
- **arabic:** بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓا۟ أَوْفُوا۟ بِٱلْعُقُودِ ۚ أُحِلَّتْ لَكُم بَهِيمَةُ ٱلْأَنْعَٰمِ إِلَّا مَا يُتْلَىٰ عَلَيْكُمْ غَيْرَ مُحِلِّى ٱلصَّيْدِ وَأَنتُمْ حُرُمٌ ۗ إِنَّ ٱللَّهَ يَحْكُمُ مَا يُرِيدُ
- **translation:** O you who have believed, fulfill your bonds. Lawful to you are the grazing livestock, except what is recited to you - game being forbidden while you stand in the sanctity of pilgrimage. Indeed, Allah ordains what He wills.
- **reflection:** The word is 'uqud - every tie that binds: a promise, a contract, a pledge given to God. Al-Mizan reads it as widely as the word will stretch, all the way back to the first covenant every soul made with its Creator. And the Ahl al-Bayt named the greatest bond of all: Imam al-Baqir (a) taught that your covenant with the Prophet ﷺ and his household is part of faith itself. Then notice what God does next. The moment He says keep your bonds, He begins to bind you, naming what is lawful and what is not. The surah is already doing the very thing it just asked of you.

## Beat 5 - VERSE 5:7 (We Hear and We Obey)
- **act:** 1  **tag:** We Hear and We Obey  **surah/ayah:** 5:7  **reference:** al-Maida · 5 : 7
- **arabic:** وَٱذْكُرُوا۟ نِعْمَةَ ٱللَّهِ عَلَيْكُمْ وَمِيثَٰقَهُ ٱلَّذِى وَاثَقَكُم بِهِۦٓ إِذْ قُلْتُمْ سَمِعْنَا وَأَطَعْنَا ۖ وَٱتَّقُوا۟ ٱللَّهَ ۚ إِنَّ ٱللَّهَ عَلِيمٌۢ بِذَاتِ ٱلصُّدُورِ
- **translation:** And remember the favor of Allah upon you, and His covenant that bound you when you said, "We hear, and we obey." And be mindful of Allah. Indeed, Allah knows what is within the breasts.
- **reflection:** Here is the promise itself, in the three words the believers said back to God: we hear, and we obey. Sami'na wa ata'na. Set it beside what the Qur'an records of some who came before, who said instead, "we hear, and we disobey." The distance between those two answers is a whole religion. The commentators stress this is not a promise made once and set aside - you renew it in every prayer, every time you submit to a command you would rather refuse. And the verse closes by naming the test: God knows what is within the breasts. The pledge is not kept by the tongue. It is kept by the heart behind it.

## Beat 6 - ACT II divider (al-Naqd / The Breaking)
- **act:** 2
- **connector:** You have given God your word - we hear, and we obey.
- **line:** But a covenant is only worth the keeping of it. And so, before the surah seals your bond, it holds a mirror up to you. It shows you a people who once stood exactly where you stand - bound to God, and handed leaders to guide them - and who let both slip through their hands.
- **bridge:** nil

## Beat 7 - VERSE 5:12 (Twelve Were Appointed)
- **act:** 2  **tag:** Twelve Were Appointed  **surah/ayah:** 5:12  **reference:** al-Maida · 5 : 12
- **arabic:** ۞ وَلَقَدْ أَخَذَ ٱللَّهُ مِيثَٰقَ بَنِىٓ إِسْرَٰٓءِيلَ وَبَعَثْنَا مِنْهُمُ ٱثْنَىْ عَشَرَ نَقِيبًۭا ۖ وَقَالَ ٱللَّهُ إِنِّى مَعَكُمْ ۖ لَئِنْ أَقَمْتُمُ ٱلصَّلَوٰةَ وَءَاتَيْتُمُ ٱلزَّكَوٰةَ وَءَامَنتُم بِرُسُلِى وَعَزَّرْتُمُوهُمْ وَأَقْرَضْتُمُ ٱللَّهَ قَرْضًا حَسَنًۭا لَّأُكَفِّرَنَّ عَنكُمْ سَيِّـَٔاتِكُمْ وَلَأُدْخِلَنَّكُمْ جَنَّٰتٍۢ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَٰرُ ۚ فَمَن كَفَرَ بَعْدَ ذَٰلِكَ مِنكُمْ فَقَدْ ضَلَّ سَوَآءَ ٱلسَّبِيلِ
- **translation:** And Allah had already taken the covenant of the Children of Israel, and We raised up among them twelve leaders. And Allah said, "I am with you. If you establish the prayer and give the alms, and believe in My messengers and support them, and lend to Allah a goodly loan, I will surely blot out your sins and admit you into gardens beneath which rivers flow. But whoever among you denies after that has strayed from the even path."
- **reflection:** God does not bind a people and then leave them to find their own way. He took Israel's covenant and, in the same moment, raised up twelve naqibs - twelve leaders, one for each tribe, to guard the bond and keep the people to it. The condition He set was exact: not only to believe in His messengers, but to support them. Faith and allegiance, together. Imam al-Baqir and Imam al-Sadiq (a) taught that this was a pattern, not an accident: as God gave Israel twelve leaders, He gave this community - this ummah - twelve Imams. A covenant with God has never been faith alone. It has always come with the guides He appoints to carry it. And the verse ends with a warning: whoever denies after that has strayed from the path. The bond and the leaders were one gift. To let go of one was to lose both.

## Beat 8 - VERSE 5:13 (The Bond Broken)
- **act:** 2  **tag:** The Bond Broken  **surah/ayah:** 5:13  **reference:** al-Maida · 5 : 13
- **arabic:** فَبِمَا نَقْضِهِم مِّيثَٰقَهُمْ لَعَنَّٰهُمْ وَجَعَلْنَا قُلُوبَهُمْ قَٰسِيَةًۭ ۖ يُحَرِّفُونَ ٱلْكَلِمَ عَن مَّوَاضِعِهِۦ ۙ وَنَسُوا۟ حَظًّۭا مِّمَّا ذُكِّرُوا۟ بِهِۦ ۚ وَلَا تَزَالُ تَطَّلِعُ عَلَىٰ خَآئِنَةٍۢ مِّنْهُمْ إِلَّا قَلِيلًۭا مِّنْهُمْ ۖ فَٱعْفُ عَنْهُمْ وَٱصْفَحْ ۚ إِنَّ ٱللَّهَ يُحِبُّ ٱلْمُحْسِنِينَ
- **translation:** So for their breaking of their covenant, We cursed them and made their hearts hard. They distort the words from their places, and they have forgotten a portion of what they were reminded of... But pardon them and overlook. Indeed, Allah loves those who do good.
- **reflection:** Notice what breaking the bond actually does. It is not only a punishment sent from outside - it is a hardening that sets in within. The heart turns hard. The words of revelation get bent away from their meaning. And a portion of the message is simply forgotten, the inconvenient part first. Al-Mizan notes the cruelty of it: a hardened heart finds the next sin easier than the last, so the breaking feeds itself. Read this as the mirror it is meant to be. Nothing here is owed to one people alone; it is what waits for any covenant left untended, including yours. And notice where the verse turns at its close - pardon them, and overlook. Even here, God bends the believer back toward mercy, not contempt.

## Beat 9 - ACT III divider (al-Ikmal / The Completion)
- **act:** 3
- **connector:** You have seen a covenant kept by God, and broken by men.
- **line:** Now the surah turns and asks you the question it has been circling all along. Every bond needs someone you are bound to. So: who is your wali - your guardian, the one whose authority you stand under, the one you give your allegiance to? The surah does not leave you to guess.
- **bridge:** nil

## Beat 10 - VERSE 5:51 (Where Allegiance Lies)
- **act:** 3  **tag:** Where Allegiance Lies  **surah/ayah:** 5:51  **reference:** al-Maida · 5 : 51
- **arabic:** ۞ يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ لَا تَتَّخِذُوا۟ ٱلْيَهُودَ وَٱلنَّصَٰرَىٰٓ أَوْلِيَآءَ ۘ بَعْضُهُمْ أَوْلِيَآءُ بَعْضٍۢ ۚ وَمَن يَتَوَلَّهُم مِّنكُمْ فَإِنَّهُۥ مِنْهُمْ ۗ إِنَّ ٱللَّهَ لَا يَهْدِى ٱلْقَوْمَ ٱلظَّٰلِمِينَ
- **translation:** O you who have believed, do not take the Jews and the Christians as guardians. They are guardians of one another. And whoever among you allies with them is of them. Indeed, Allah does not guide the wrongdoing people.
- **reflection:** This verse is easy to misread, so read it exactly as the Ahl al-Bayt did. The word again is awliya, the plural of wali - and it does not mean friends, or neighbors, or the people you trade and deal justly with. Al-Mizan is precise: a wali is the one you take as your guardian and protector, the authority you stand under and hand your final allegiance to. The Imams (a), in al-Kafi, stress what the verse is not - it does not cancel kindness, fairness, or good treatment, which God commands elsewhere in this same surah. What it forbids is handing the guardianship of your faith to anyone standing outside its covenant. And it leaves one question hanging in the air: then to whom does that guardianship belong?

## Beat 11 - VERSE 5:55 (The Ring in Ruku)
- **act:** 3  **tag:** The Ring in Ruku  **surah/ayah:** 5:55  **reference:** al-Maida · 5 : 55
- **arabic:** إِنَّمَا وَلِيُّكُمُ ٱللَّهُ وَرَسُولُهُۥ وَٱلَّذِينَ ءَامَنُوا۟ ٱلَّذِينَ يُقِيمُونَ ٱلصَّلَوٰةَ وَيُؤْتُونَ ٱلزَّكَوٰةَ وَهُمْ رَٰكِعُونَ
- **translation:** Your guardian is only Allah, and His Messenger, and those who believe - those who establish the prayer and give the alms while they are bowing.
- **reflection:** Here is the answer, and the surah refuses to leave it abstract. A beggar came into the mosque of the Prophet ﷺ and asked for help, and no one rose. Ali (a) was in the middle of his prayer, bowing in ruku. Without breaking his prayer, he lifted his hand and let the man take the ring from his finger. And this verse came down: your guardian is Allah, and His Messenger, and the one who gives the poor their due even while he bows before God. Imam al-Baqir and Imam al-Sadiq (a) both said, plainly, that it was revealed about Ali (a). Now look at the word the verse chooses for guardian: waliyyukum. It names three - God, His Messenger, and this believer - yet it keeps guardian singular. Not your guardians. Your guardian, one word, for all three. Al-Mizan explains why: the authority is one, and it runs in a single line - from God, to His Messenger, to the man God chooses. And the very next verse makes it a promise: stand with them, and you stand with the party of God, the side that in the end prevails.

## Beat 12 - VERSE 5:67 (Deliver It)
- **act:** 3  **tag:** Deliver It  **surah/ayah:** 5:67  **reference:** al-Maida · 5 : 67
- **arabic:** ۞ يَٰٓأَيُّهَا ٱلرَّسُولُ بَلِّغْ مَآ أُنزِلَ إِلَيْكَ مِن رَّبِّكَ ۖ وَإِن لَّمْ تَفْعَلْ فَمَا بَلَّغْتَ رِسَالَتَهُۥ ۚ وَٱللَّهُ يَعْصِمُكَ مِنَ ٱلنَّاسِ ۗ إِنَّ ٱللَّهَ لَا يَهْدِى ٱلْقَوْمَ ٱلْكَٰفِرِينَ
- **translation:** O Messenger, deliver what has been sent down to you from your Lord. And if you do not, then you have not delivered His message. And Allah will protect you from the people. Indeed, Allah does not guide the disbelieving people.
- **reflection:** Near the end of his life, God gives His Messenger ﷺ a command of terrifying weight. Deliver what has been sent down to you. And then the line that stops you: if you do not deliver this, you have delivered nothing at all. Not one piece of the message left undone - without this, the whole message counts as never delivered. Everything he had given his life to carry now rested on this one thing still to be said. And God adds a promise that tells you how hard it would be to say: I will protect you from the people. Al-Mizan asks the only question that matters here. What single announcement could weigh as much as the entire revelation? Whatever it was, the Prophet ﷺ did not hesitate. He was on the road home from his final pilgrimage when the command came.

## Beat 13 - NARRATION (Ghadir Khumm)
- **act:** 3  **tag:** Ghadir Khumm  **source:** The Prophet Muhammad ﷺ · Ghadir Khumm (narrated in both traditions)
- **body:** He did not wait to reach Medina. Tens of thousands were returning from the Farewell Pilgrimage when, at a stopping place called Ghadir Khumm, in the heat of the day, the Prophet ﷺ halted the whole caravan. He called back those who had gone ahead and waited for those behind, until all of them were gathered. A pulpit was raised from the saddles of the camels. He praised God, and told them he would soon be leaving them. Then he took Ali (a) by the hand and raised it high, and said: "He whose mawla I am - whose guardian and master I am - this Ali is his mawla." And he prayed over him: "O God, befriend the one who befriends him, and stand against the one who stands against him." It is among the most widely narrated moments in all of Islam, carried down in the books of the Shia and the Sunni alike.
- **reflection:** This was the thing that could not be left unsaid. The Qur'an had shown it quietly: a guardian named by the ring he gave in prayer. Now the Prophet ﷺ declared it aloud, in the open, before the whole community, because God had told him the message was not complete without it. The bond made in the first verse of the surah had found its keeper. And in the very next moment, heaven answered.

## Beat 14 - CLIMAX (The Religion Completed) [5:3, completion clause]
- **act:** 3  **tag:** The Religion Completed  **source:** al-Maida · 5 : 3
- **arabic:** (byte-exact completion-clause substring of 5:3, sliced from quran_data.json at build) ٱلْيَوْمَ يَئِسَ ٱلَّذِينَ كَفَرُوا۟ مِن دِينِكُمْ فَلَا تَخْشَوْهُمْ وَٱخْشَوْنِ ۚ ٱلْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ وَأَتْمَمْتُ عَلَيْكُمْ نِعْمَتِى وَرَضِيتُ لَكُمُ ٱلْإِسْلَٰمَ دِينًۭا
- **translation:** This day those who disbelieve have despaired of your religion, so do not fear them, but fear Me. This day I have perfected for you your religion, and completed My favor upon you, and approved for you Islam as a religion.
- **body:** The moment the Prophet ﷺ lowered his hand at Ghadir, these words came down - the last piece of a revelation twenty-three years in the sending down. Read them slowly against everything you have seen. This day those who disbelieve have despaired of your religion. Despaired - why now? Because they had been waiting for Islam to die with the one who carried it. With no leader left, it would go out - the way an untended fire dies once its fuel is gone. And now they saw that it would not. It had been given a line of guides to carry it past his lifetime. So He says it at last: This day I have perfected for you your religion, and completed My favor upon you. Al-Mizan reads the timing exactly - a religion cannot be called complete while the question of who leads it after the Prophet ﷺ is left open. The final brick of the faith was the guardianship sealed that afternoon.
- **reflection:** This is the soul of the surah. The bond commanded in its first verse, and broken by the people in its mirror, was sealed here - not as one more law among its laws, but as the keystone that holds every other in place. When God said this day I have perfected your religion, He meant there was nothing left to add. The faith was whole. It had its Book, and it had the household that would never leave it.

## Beat 15 - REFLECTION PROMPT
- **tag:** Return
- **prompt:** What bond will you keep?
- **placeholder:** The pledge to hear and obey, an allegiance, a promise made to God…
- **subline:** That pledge is not ancient history. You renew it - we hear, and we obey - every time you stand to pray, every time you keep a promise you would rather break. Before you go, name the one bond you most need to keep.
- **nextLabel:** One last thing

## Beat 16 - CLOSING
- **tag:** The Close
- **titleAr:** الْمَائِدَة
- **essence:** The surah is named for none of this. It is named for a table - the meal the disciples of Jesus (a) begged heaven to send them, as a sign to settle their hearts and let them believe. Every bond in this surah is that same mercy: heaven settling a heart with a sign. The last and greatest of them was a hand raised in the desert, at Ghadir.
- **line:** You have followed the spine of al-Maida. Now read the whole of it in its own words - the table and the bond, the law and the mercy - and let the surah that God called the completion of your faith open before you in full.
