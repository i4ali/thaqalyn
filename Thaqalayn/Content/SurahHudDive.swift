//
//  SurahHudDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - Hud" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/hud-script.md.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically via pull_arabic.py, never
//  hand-typed, to survive the byte-for-byte check). No dua beat; ends on .closing.
//
//  Spine: the surah the Prophet ﷺ said grayed his hair ("Hud and its sisters have
//  grayed me" - Abu Juhayfa's report, carried in Nur al-Thaqalayn; al-Khisal p. 199
//  records the exchange with four surahs named). The dive hunts for the weight:
//  Nuh's 950-year stand and the son the wave took (Movement I, closed by the
//  safina hadith); the namesake Hud's bare stand and the forelock creed, handed
//  to Shu'ayb's "remainder" and, by Kamal al-Din 1:330-331, to the Qa'im (aj)
//  (Movement II); then the surah turns to its first reader with fa-staqim
//  (11:112) - the verse Ibn Abbas called the hardest ever sent down on him (Majma
//  al-Bayan under 11:112) - with its guardrails 11:113-114 (Movement III). The
//  climax is NOT the famous verse: it is 11:120, "We make firm your heart" - the
//  surah that grayed him is the same surah sent to steady him.
//
//  Sourcing is Shia and verified, audit-corrected (see the script's sourcing
//  notes): al-Mizan (Tabatabai) under 11:112/11:120 verbatim; Majma al-Bayan
//  (Tabrisi) under 11:38/11:86/11:112 ("wa la tatghaw" as excess-and-deficiency
//  is Tabrisi's point, not al-Mizan's)/11:120. Safina: al-Hakim's Mustadrak h.
//  3365 (Abu Dharr at the Ka'ba door, ending "drowns") kept distinct from the
//  Uyun Akhbar al-Rida 2:27 recension through the Imams' chain (ending "thrust
//  into the Fire"). Nuh's son: the al-Washsha exchange, Ma'ani al-Akhbar p. 106
//  (Uyun carries a shorter recension). 11:113: pairing verse verbatim from
//  al-Mizan; the touch-for-the-lean narration from Imam al-Sadiq (a), Tafsir
//  al-Ayyashi via al-Mizan's riwa'i; the Karbala reading given in the dive's own
//  voice, not the tradition's. Kamal al-Din 1:330-331 (Baqiyyatullah); Thawab
//  al-A'mal p. 106 (Friday merit, al-Baqir (a)); the "Gird up" report named as a
//  mursal of al-Hasan al-Basri relayed by Tabatabai from al-Durr al-Manthur. The
//  causal link between 11:112 and the graying is attributed to Ibn Abbas, never
//  staged as the Prophet's ﷺ own explanation; the dream-anecdote is omitted.
//

import SwiftUI

extension DeepDive {
    static let surahHud: DeepDive = DeepDive(
        id: "surah-hud",
        titleEn: "Hud",
        titleAr: "هُود",
        subtitle: "Hud - the surah the Prophet ﷺ said turned his hair gray",
        sfSymbol: "figure.stand",
        estMinutes: 16,
        acts: [
            ActInfo(number: 1, ar: "السَّفِينَة", tr: "al-Safina", name: "The Ark"),
            ActInfo(number: 2, ar: "النَّاصِيَة", tr: "al-Nasiya", name: "The Forelock"),
            ActInfo(number: 3, ar: "الْأَمْر", tr: "al-Amr", name: "The Command"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "هُود",
                titleEn: "Hud",
                subtitle: "The Surah of Those Who Stood",
                line: "They noticed it before he said anything: gray, beginning to show in the hair of the Messenger of Allah ﷺ. And when he was finally asked about it, he did not name a grief, and he did not name an enemy. He named a surah. “Hud and its sisters have grayed me.” This is that surah. Somewhere in its one hundred and twenty-three verses is something heavy enough to show in a prophet's hair - and it is not where you expect. Descend, and find it."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "Hud came down in Mecca, in the hardest stretch of the Prophet's ﷺ years there - straight after Surah Yunus in the order of revelation. Most surahs arrived in pieces, over years; al-Mizan, Tabatabai's great commentary, holds that this one came down all at once, a single descent. On its surface it is a gallery of prophets: Nuh, Hud, Salih, Ibrahim, Lut, Shu'ayb, Musa - seven stories, each of one man sent to a people who did not want him. But notice what the Prophet ﷺ did not say about this surah. He did not say it saddened him. He said it grayed him - and gray is not what stories leave behind. It is what a burden leaves behind. Somewhere in here, something is being asked. Of him - and of whoever reads it after him.",
                leaveWith: "You will leave knowing which verse his companions said was the heaviest that ever came down on him. And one thing more: near its end, this surah quietly says what it was sent to do - and almost everyone walks past it. The weight is famous. The other thing is easy to miss."
            ),

            // ── Movement I · al-Safina (The Ark) ──────────────────────────────
            .act(
                act: 1, connector: nil,
                line: "Before any story, the surah looks at its first reader. Mecca wanted a spectacle. Why has no treasure been sent down to him? Where is his angel? What it got instead was a warner - and it mocked him. The surah does not hide what this costs. It says the revelation was pressing on his chest. Not that he would ever leave out a word of it - the question in the verse is aimed at the deniers and their demands, not at him - but carrying it, among these people, had a weight. Hold that image - because God's first answer to it is not a comfort. It is the story of the man who was mocked longer than anyone in history.",
                bridge: BridgeVerse(
                    surah: 11, ayah: 12,
                    arabic: "فَلَعَلَّكَ تَارِكٌۢ بَعْضَ مَا يُوحَىٰٓ إِلَيْكَ وَضَآئِقٌۢ بِهِۦ صَدْرُكَ أَن يَقُولُوا۟ لَوْلَآ أُنزِلَ عَلَيْهِ كَنزٌ أَوْ جَآءَ مَعَهُۥ مَلَكٌ ۚ إِنَّمَآ أَنتَ نَذِيرٌۭ ۚ وَٱللَّهُ عَلَىٰ كُلِّ شَىْءٍۢ وَكِيلٌ",
                    translation: "Then would you perhaps leave out part of what is revealed to you, and is your chest straitened by it, because they say, “Why has no treasure been sent down to him, or an angel come with him?” You are only a warner - and Allah is Guardian over all things.",
                    reference: "Hud · 11 : 12"
                )
            ),
            .verse(
                act: 1, tag: "Built in the Open", surah: 11, ayah: 38,
                arabic: "وَيَصْنَعُ ٱلْفُلْكَ وَكُلَّمَا مَرَّ عَلَيْهِ مَلَأٌۭ مِّن قَوْمِهِۦ سَخِرُوا۟ مِنْهُ ۚ قَالَ إِن تَسْخَرُوا۟ مِنَّا فَإِنَّا نَسْخَرُ مِنكُمْ كَمَا تَسْخَرُونَ",
                translation: "And he set to building the ark - and every time chiefs of his people passed by him, they mocked him. He said, “If you mock us, we will mock you just as you mock.”",
                reference: "Hud · 11 : 38",
                reflection: "By the time this verse opens, Nuh has been calling his people for nine hundred and fifty years - the Qur'an gives the number itself (29:14) - and the narrations put those who believed with him at around eighty. Around eighty, in nine and a half centuries. Now he is commanded to build a ship on dry land, nowhere near water. Tabrisi, in his great commentary Majma al-Bayan, describes what followed: the chiefs of his people walking past in groups, laughing at an old man building a boat with no sea in sight. Notice what the mockery is really aimed at. Not the wood - the obedience: a command followed in plain daylight while the promise behind it is still invisible. And notice the answer: you are laughing now; we will laugh later, when the water comes and you see what your laughing was worth. And he lays the next plank. Whatever God has asked you to build in full view of people who find it ridiculous - a prayer, a veil, a refusal - it has a patron story, and this is it."
            ),
            .verse(
                act: 1, tag: "The Boarding", surah: 11, ayah: 41,
                arabic: "۞ وَقَالَ ٱرْكَبُوا۟ فِيهَا بِسْمِ ٱللَّهِ مَجْر۪ىٰهَا وَمُرْسَىٰهَآ ۚ إِنَّ رَبِّى لَغَفُورٌۭ رَّحِيمٌۭ",
                translation: "And he said, “Board it. In the name of Allah is its course and its anchorage. Indeed, my Lord is Forgiving, Merciful.”",
                reference: "Hud · 11 : 41",
                reflection: "One sentence covers the whole voyage: bismillahi majraha wa mursaha - in the name of Allah is its running and its coming to rest. Tabatabai pauses here in al-Mizan: the ark was built by hand, plank by plank, to God's own specification - and yet Nuh hangs its sailing and its stopping on the Name, not the nails. That is the believer's whole relationship to means - to tools, effort, plans, everything your hands can actually hold: use them fully, trust none of them. Then listen to the two names the sentence ends on, spoken while the water is rising on a doomed world: Forgiving, Merciful. For everyone aboard, even the flood is wrapped in mercy. The door of that ark is the starkest line ever drawn. Inside it, everything moves in God's name. Outside it, nothing has anything to set against the water but itself. Remember this boarding - who steps on, and in whose name it sails - because the surah is about to show you the one who refused to step on."
            ),
            .verse(
                act: 1, tag: "The Wave Between", surah: 11, ayah: 43,
                arabic: "قَالَ سَـَٔاوِىٓ إِلَىٰ جَبَلٍۢ يَعْصِمُنِى مِنَ ٱلْمَآءِ ۚ قَالَ لَا عَاصِمَ ٱلْيَوْمَ مِنْ أَمْرِ ٱللَّهِ إِلَّا مَن رَّحِمَ ۚ وَحَالَ بَيْنَهُمَا ٱلْمَوْجُ فَكَانَ مِنَ ٱلْمُغْرَقِينَ",
                translation: "He said, “I will take shelter on a mountain that will protect me from the water.” He said, “There is no protector today from the command of Allah, except for him on whom He has mercy.” And the wave came between them, and he was among the drowned.",
                reference: "Hud · 11 : 43",
                reflection: "The verse before this one is a father shouting over a storm. The ark is riding waves like mountains when Nuh sights his son standing apart, and calls: “O my son, ride with us, and do not be with the disbelievers” (11:42). The boy's answer is the whole tragedy in one line: I will take shelter on a mountain. He has just watched water swallow the plains, and he still believes altitude will save him. Tabatabai names the error exactly: trust in material means - the mountain is high, the water is high, so let height answer height. What the boy cannot see is that today the question is not high or low. It is inside the Name or outside it. His father's reply closes the question, gently: nothing protects today except mercy. Then the Qur'an gives the separation a single clause, and its restraint is the ache of it: and the wave came between them. Not “he drowned” - not yet. First the between. Anyone who has watched someone they love choose the mountain knows exactly how wide that wave is."
            ),
            .verse(
                act: 1, tag: "Not of Your Family", surah: 11, ayah: 46,
                arabic: "قَالَ يَٰنُوحُ إِنَّهُۥ لَيْسَ مِنْ أَهْلِكَ ۖ إِنَّهُۥ عَمَلٌ غَيْرُ صَٰلِحٍۢ ۖ فَلَا تَسْـَٔلْنِ مَا لَيْسَ لَكَ بِهِۦ عِلْمٌ ۖ إِنِّىٓ أَعِظُكَ أَن تَكُونَ مِنَ ٱلْجَٰهِلِينَ",
                translation: "He said, “O Nuh, he is not of your family. Indeed, his was conduct other than righteous. So do not ask of Me that of which you have no knowledge. I admonish you, lest you be among the ignorant.”",
                reference: "Hud · 11 : 46",
                reflection: "When the water went down, Nuh called to his Lord with a father's last appeal: my son is of my family, and Your promise is true (11:45). The answer redraws the word “family” forever: he is not of your family - his conduct was other than righteous. Centuries later, Imam al-Rida (a) put this verse to one of his companions: how do you read it? The companion answered with the reading some had adopted - that the boy was not truly Nuh's son at all. The Imam refused it: “Not at all - he was his son. But when he disobeyed Allah, Allah severed him from his father. So it is with us: whoever of us does not obey Allah is not of us. And you - if you obey Allah, you are of us, the Ahl al-Bayt.” Al-Saduq preserves the exchange in Ma'ani al-Akhbar, and the last sentence is addressed to you. A prophet's own son could be severed from him by disobedience. And by obedience, you can belong to the household of Muhammad ﷺ."
            ),
            .narration(
                act: 1, tag: "The Ark Still Has a Name",
                source: "The Prophet ﷺ · Uyun Akhbar al-Rida",
                body: "Long after the flood, an old companion stood holding the door of the Ka'ba and called to the people: whoever knows me knows me; whoever does not - I am Abu Dharr. Then he told them what he had heard from the Messenger of Allah ﷺ: “The likeness of my Ahl al-Bayt among you is the likeness of the Ark of Nuh: whoever boards it is saved, and whoever stays behind from it drowns.” That scene is preserved by al-Hakim, one of the great Sunni hadith masters, in his Mustadrak, and he graded the hadith sahih - authentic. The Imams themselves handed the same hadith down - Uyun Akhbar al-Rida carries it through their own chain, with an ending of its own severity: whoever stays behind from the ark is thrust into the Fire. One flood ended. The choice at the door of the ark did not. Every age has its rising water - and the Prophet ﷺ told this community, by name, where its ark is.",
                reflection: "This is why the surah made you watch the boarding so closely: who stepped on, and who trusted a mountain instead. The son's ruin was not hatred of his father. It was the quiet belief that there was more than one way to be safe. There was one ark then. There is one now."
            ),

            // ── Movement II · al-Nasiya (The Forelock) ────────────────────────
            .act(
                act: 2,
                connector: "You have watched the longest stand in history, what it cost the one who held it - and the name his ark still carries.",
                line: "Now the surah begins, deliberately, to repeat itself. After Nuh comes Hud; after Hud, Salih; then Ibrahim's strange visitors, then Lut, then Shu'ayb, then Musa - seven messengers in one surah, each ringed by his own people saying no. The repetition is not repetition for its own sake. It is variation - and the surah is named for the starkest variant of all. Nuh at least had the ark: a rescue you could touch, a hull between him and the water. The prophet called Hud had nothing - no vessel, no sign, no shelter anywhere in sight. One man, before the strongest nation of its age, armed with a single sentence about who holds whom. Watch what standing looks like when everything but God is stripped away.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Forelock", surah: 11, ayah: 56,
                arabic: "إِنِّى تَوَكَّلْتُ عَلَى ٱللَّهِ رَبِّى وَرَبِّكُم ۚ مَّا مِن دَآبَّةٍ إِلَّا هُوَ ءَاخِذٌۢ بِنَاصِيَتِهَآ ۚ إِنَّ رَبِّى عَلَىٰ صِرَٰطٍۢ مُّسْتَقِيمٍۢ",
                translation: "“Indeed, I have placed my trust in Allah, my Lord and your Lord. There is no creature that moves but He holds it by its forelock. Indeed, my Lord is on a straight path.”",
                reference: "Hud · 11 : 56",
                reflection: "To feel this verse, restore its scene. Hud stands alone before Aad, a people so sure of their own strength that their only explanation for him was that one of their gods had struck him with harm (11:54). His reply is among the boldest sentences a lone man speaks anywhere in the Qur'an: I call Allah to witness - and you witness too - that I am clear of everything you worship besides Him. So plot against me, all of you together, then give me no respite (11:54-55). Tabatabai says that dare does two jobs at once. It is an argument: if their gods had any power at all, an unprotected man who renounces every one of them and invites their worst should be destroyed - and he stands untouched, so the gods are nothing. And it is a miracle: a whole nation wanted him gone, and never could touch him. Then Hud gives the secret away, and it is this verse: there is no creature but He holds it by its forelock - the old Arabic image for complete mastery, because whoever holds a forelock steers the head. Every warrior of Aad, every idol, every plot: each one already steered by the Lord Hud trusts. Fear needs a second power - something outside His hold that could still reach you. Hud counted the powers in the world and came to one. There was no second."
            ),
            .verse(
                act: 2, tag: "The Remainder", surah: 11, ayah: 86,
                arabic: "بَقِيَّتُ ٱللَّهِ خَيْرٌۭ لَّكُمْ إِن كُنتُم مُّؤْمِنِينَ ۚ وَمَآ أَنَا۠ عَلَيْكُم بِحَفِيظٍۢ",
                translation: "“What remains from Allah is better for you, if you are believers. And I am not a keeper over you.”",
                reference: "Hud · 11 : 86",
                reflection: "The stand keeps being handed on. Salih takes it up before Thamud; then Lut, in a city that had turned every decency upside down; until it reaches Shu'ayb in Madyan - a trading people who had made cheating the scales a way of life. His counsel to them gathers into one strange, beautiful phrase: baqiyyatullah - what remains from Allah - is better for you. On the surface it is a trader's arithmetic, and Majma al-Bayan works it out. One pile is small, earned honestly, and God's blessing is on it. The other is tall, with cheating mixed in. The small pile is worth more, because it is the only one that lasts. But listen to what the phrase covers beyond a marketplace. Everything gained by bending - the position kept by a flattering silence, the margin made by the small dishonesty - belongs to the pile that does not remain. What remains from Allah is exactly what you kept by standing straight. Madyan answered Shu'ayb the way Aad had answered Hud: we see you are weak among us; were it not for your clan, we would stone you (11:91). The ones who stand are always outnumbered. The arithmetic has never once been wrong."
            ),
            .narration(
                act: 2, tag: "The Remnant of God",
                source: "Imam al-Baqir (a) · Kamal al-Din",
                body: "Shu'ayb's phrase was not left in the marketplace. Shaykh al-Saduq's Kamal al-Din is his great book on the awaited Imam. In it, Imam al-Baqir (a) describes the day the line of those who stood becomes visible again. The Qa'im - the Mahdi (aj), the one who will rise - emerges, and leans his back against the Ka'ba. Three hundred and thirteen men gather to him. And the first thing he utters is this verse: “What remains from Allah is better for you, if you are believers.” Then he says: “I am the Remnant of Allah in His earth, His caliph and His proof over you.” And no Muslim greets him except with the words: Peace be upon you, O Remnant of Allah in His earth. Of everything in the Qur'an, the first words the Mahdi (aj) speaks to the world are Shu'ayb's line - from this surah. Every prophet in Hud stood, and was scorned for standing. And out of every stand, God kept a remainder. The Twelfth Imam is that remainder: the whole procession, distilled into the one who still stands.",
                reflection: "You have been reading the surah of the lonely stand as history. It is a lineage - and it is not finished. Around eighty believed with Nuh; three hundred and thirteen will gather at the Ka'ba. Between those two small companies stands every believer who ever held a small stand in an unbelieving hour - which is to say: that line runs to you."
            ),

            // ── Movement III · al-Amr (The Command) ───────────────────────────
            .act(
                act: 3,
                connector: "You have walked the procession - the ark that cost a son, the forelock creed of a man alone, the remainder that outlasts every scorn.",
                line: "And here the stories stop. After Musa, the surah turns back to where it began: its first reader. It opened by looking at him - the mockery around him, the revelation pressing on his chest - and then answered him with a hundred verses of the ones who stood before. Now it looks at him again, and this time it does not console. It commands. Remember what you came down here to find: the weight that showed in his hair. You have seen the surah's floods, its buried cities, a father watching the wave take his son - and none of that was the weight. What grayed him is a command. In Arabic it is a single word, and it is next.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "Stand Firm", surah: 11, ayah: 112,
                arabic: "فَٱسْتَقِمْ كَمَآ أُمِرْتَ وَمَن تَابَ مَعَكَ وَلَا تَطْغَوْا۟ ۚ إِنَّهُۥ بِمَا تَعْمَلُونَ بَصِيرٌۭ",
                translation: "So stand firm, as you have been commanded - you, and those who turn [to Allah] with you - and do not overstep. Indeed, He sees whatever you do.",
                reference: "Hud · 11 : 112",
                reflection: "Fa-staqim kama umirt. Stand firm, as you have been commanded. Tabatabai writes that the verse carries an unmistakable severity of tone - a command with no softening word of mercy anywhere inside it. Istiqama means uprightness - standing straight. Al-Mizan gives it a sharp test: a thing is upright when it does the whole job it exists for. A wall is upright when it holds the roof. A religion is upright when it is held with nothing crooked in it, nothing added, nothing shaved away, no hour exempt - in public, and in the last private room of the heart, until death. That alone might age a man. But the verse has not finished: wa man taba ma'ak - and those who turn with you. Majma al-Bayan spells out the reach: the command covers everyone who turned to God at his hand. He is not asked merely to stand; he is asked to stand at the head of everyone standing - a whole community's uprightness gathered into a single address, with his name on it. And the demand still is not finished: wa la tatghaw - and do not overstep. Tabrisi reads it plainly: do not fall short of the line, and do not push past it either - even obedience must not swell beyond what was commanded. Perfectly straight; all of you together; and not one step past the line. Read it once more, slowly. Then look at what it did to the man it was sent to."
            ),
            .narration(
                act: 3, tag: "The Gray",
                source: "Ibn Abbas · Majma al-Bayan, under 11:112",
                body: "The question was finally asked to his face: gray has hurried to you, O Messenger of Allah. He answered: “Hud and its sisters have grayed me.” That is the wording in the report of Abu Juhayfa; in al-Khisal, al-Saduq records the exchange with four surahs named. And Ibn Abbas, the great commentator of the first generation, pointed to the verse behind the answer. No verse, he said, ever came down on the Messenger of Allah ﷺ that was harder or heavier on him than this one. That, said Ibn Abbas, is why he named Hud. Tabrisi preserves the report in Majma al-Bayan, right under this verse. And a mursal report - one with an incomplete chain - from al-Hasan al-Basri, which Tabatabai relays from al-Durr al-Manthur, adds one detail from the days this verse arrived: he said “Gird up, gird up” - and he was not seen laughing after.",
                reflection: "Be careful not to misread the gray. Enmity did not put it there; he had carried enmity for years. Grief did not put it there; he had buried, one after another, those closest to him. It appeared under a command - because enmity and grief ask a man to endure, and fa-staqim asks him to be perfectly upright, every remaining hour, at the head of every soul who stands behind him. Maybe you have been the one others stand behind - in a family, in a faith, in a room where your spine is the one the others borrow. If so, you have felt the faintest shadow of what this command asks. He carried the whole of it, so that the path would stay open. And the surah has one more thing to tell you about how he carried it."
            ),
            .verse(
                act: 3, tag: "Do Not Lean", surah: 11, ayah: 113,
                arabic: "وَلَا تَرْكَنُوٓا۟ إِلَى ٱلَّذِينَ ظَلَمُوا۟ فَتَمَسَّكُمُ ٱلنَّارُ وَمَا لَكُم مِّن دُونِ ٱللَّهِ مِنْ أَوْلِيَآءَ ثُمَّ لَا تُنصَرُونَ",
                translation: "And do not incline toward those who do wrong, or the Fire will touch you - and you would have no protectors besides Allah, and then you would not be helped.",
                reference: "Hud · 11 : 113",
                reflection: "Almost no one abandons the straight path by turning around on it. The real failure is the thing this verse forbids: rukun - a lean. Tabatabai reads the two verses as a pair: the one before this told you not to be among the wrongdoers; this one goes further - do not even incline toward them. And the punishment is measured to match: for the wrong itself, the Fire; for the lean, its touch. The Ahl al-Bayt kept the warning exactly there - Imam al-Sadiq (a) said of this verse: it was not made an eternity in the Fire, but the Fire will touch you - so do not lean toward them. What does a lean look like? Rarely like joining. It is resting some of your weight where wrong is being done: the warming smile toward power that should be refused, the approval read in your silence, the comfort taken under a shade that injustice built. Read in that light, Karbala is this verse obeyed to the end: Imam al-Husayn (a), refusing to rest one ounce of his weight on injustice, whatever the refusal cost. Standing straight, it turns out, is not a private virtue. Every straight thing in a bent world is load-bearing. Lean on nothing that is falling."
            ),
            .verse(
                act: 3, tag: "The Repair", surah: 11, ayah: 114,
                arabic: "وَأَقِمِ ٱلصَّلَوٰةَ طَرَفَىِ ٱلنَّهَارِ وَزُلَفًۭا مِّنَ ٱلَّيْلِ ۚ إِنَّ ٱلْحَسَنَٰتِ يُذْهِبْنَ ٱلسَّيِّـَٔاتِ ۚ ذَٰلِكَ ذِكْرَىٰ لِلذَّٰكِرِينَ",
                translation: "And establish the prayer at the two ends of the day and in the first hours of the night. Indeed, good deeds take away the evil deeds. That is a reminder for those who remember.",
                reference: "Hud · 11 : 114",
                reflection: "The command came with no softening word inside it - but the surah did not leave it bare. Two verses on, the one who must stand is given what will hold him up: prayer, set at the two ends of the day and into the night. And then a sentence of pure relief: inna al-hasanat yudhhibna al-sayyi'at - good deeds take the evil ones away. Understand who that sentence is for. The command to stand was addressed to him, and to everyone who turns with him - and for us, in that company, stumbling is not a possibility but a certainty. So the same surah that demands unbroken straightness builds the mercy into the schedule: the day washed at both ends, the stumble lifted away by the good deed that follows it. Istiqama is not a tightrope that one slip ends. It is a road with mercy set along it at fixed hours, and the next hour of mercy is never far away. Be patient, the following verse adds, for Allah does not let the reward of the doers of good be lost (11:115). The standing is demanded. The stumbling is provided for. That pair is the mercy of this whole religion."
            ),
            .climax(
                act: 3, tag: "The Steadying", source: "Hud · 11 : 120",
                arabic: "وَكُلًّۭا نَّقُصُّ عَلَيْكَ مِنْ أَنۢبَآءِ ٱلرُّسُلِ مَا نُثَبِّتُ بِهِۦ فُؤَادَكَ ۚ وَجَآءَكَ فِى هَٰذِهِ ٱلْحَقُّ وَمَوْعِظَةٌۭ وَذِكْرَىٰ لِلْمُؤْمِنِينَ",
                translation: "And each thing We relate to you of the tidings of the messengers is that by which We make your heart firm. And in this there has come to you the truth, and an admonition, and a reminder for the believers.",
                body: "Three verses from the surah's end, God tells His Prophet ﷺ why the stories were sent. Nuthabbitu bihi fu'adak: that We may make your heart firm. Not, first, to warn the nations. Not to complete a record. The seven stories of this surah were, before everything else, for the heart of the one who had to recite them: Nuh outlasting nine hundred and fifty years of laughter, sent down to a man being laughed at in Mecca - so he would know that mockery has been outlasted before. Hud daring a whole nation with no protector but God, sent to a man standing alone against his own city. Story by story, stand by stand, poured into the heart that would have to make the longest stand of all. Tathbit is the Arabic name for this - the steadying, the making-firm of a heart. Tabatabai's description of it is exact: it cuts anxiety off at the root. And Tabrisi, in Majma al-Bayan, says these stories were sent to strengthen your heart, set your soul at ease, and make you firmer under your people's harm. Now hold the two truths of this surah side by side. This surah grayed him: the command in it is as heavy as Ibn Abbas said. And this surah steadied him: it was built, story by story, to hold up the very heart it was handed to. Both are true, and they are not in tension. The same revelation that said stand firm had spent a hundred verses first showing him that no one who ever stood was left to stand alone.",
                reflection: "And the address did not expire in Mecca. You have your own fa-staqim - the place where uprightness is being asked of you and nobody is applauding - and you now hold what the Prophet ﷺ was given for his: this surah. When your stand wavers, the answer is not to grip harder. It is to come back down here - to the builder still laying planks while they laughed, to the lone man and the forelock, to the Remnant who still stands. God steadies hearts today by the same means He steadied His Prophet's ﷺ: with the news of the ones who stood before you."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "Where are you being asked to stand right now?",
                placeholder: "A truth you keep softening, a practice you keep dropping, a no that needs to stay a no…",
                subline: "You have walked the whole descent. The chest that tightened, and the ark built through laughter. The wave that came between a father and a son, and the family that obedience makes. The creed of the man who stood alone, and the Remnant who still stands. And the command that grayed the Prophet ﷺ - with the steadying folded into the same surah. Before you go, name your standing place. This surah was sent to hold hearts up in exactly that spot.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "هُود",
                essence: "The surah that commanded the hardest standing ends by naming the only support a standing thing is allowed: “To Allah belongs the unseen of the heavens and the earth, and to Him the whole matter returns - so worship Him, and rely upon Him” (11:123). You were forbidden to lean on what is bent. You were never asked to stand without leaning at all.",
                line: "Imam al-Baqir (a) taught that whoever recites Surah Hud every Friday will be raised on the Day of Rising in the company of the prophets, and no sin he committed will be held up against him on that Day - Thawab al-A'mal. The company of the prophets: the exact company this surah has just walked you through. Read it now in its own words, all one hundred and twenty-three verses - and let it steady your heart as it was sent down to steady his ﷺ."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah Hud experience") {
    DeepDiveView(dive: .surahHud, onClose: {})
}
#endif
