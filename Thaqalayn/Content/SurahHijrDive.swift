//
//  SurahHijrDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Hijr" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/hijr-script.md.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically, never hand-typed, to survive
//  the byte-for-byte check).
//
//  Spine: security inverted. In the loudest years of Mecca's mockery ("you are
//  mad - bring us the angels," 15:6-7), the surah sorts the world into what is
//  guarded and what only feels guarded: the dhikr (15:9), the sky (15:17), the
//  measured treasuries (15:21), His servants (15:42) - against the mockers'
//  storehouses and the carved walls of the surah's namesake, Ashab al-Hijr, who
//  felt aminin inside rock and fell to a shriek at dawn (15:82-83). The surah
//  speaks aminin exactly twice: on the carved houses, and at the door of Paradise
//  (15:46). Four movements from the surah's own joints (1-25 / 26-50 / 51-84 /
//  85-99); climax at the tenderest diagnosis in the Qur'an (15:97-99). No dua
//  beat; ends on .closing, which hands off to reading the full surah.
//
//  Sourcing is Shia, traced at script stage through primary-source relays
//  (Tafsir al-Safi relaying al-Qummi / al-Ayyashi / al-Kafi / Uyun / al-Ihtijaj /
//  Majma al-Bayan): the Ibn Abbas oath report under 15:72 (Majma al-Bayan 3:342);
//  al-Qummi's "distinction over the prophets" (15:72); the five mockers named and
//  their one-day endings (al-Qummi; Ayyashi from al-Baqir (a); al-Ihtijaj from
//  Amir al-Mu'minin (a)); the concealment years "and Ali with him, and Khadija"
//  (Kamal al-Din; Ayyashi); the proclamation standing on al-Hijr (al-Qummi);
//  Imam Ali (a) on al-safh al-jamil (Majma al-Bayan); the Fatiha as the Seven (Uyun
//  from Amir al-Mu'minin (a); Ayyashi from al-Sadiq (a); Majma from Ali, al-Baqir
//  and al-Sadiq (a)); "We are the mathani" (al-Baqir (a), al-Tawhid/Ayyashi, with
//  al-Saduq's gloss); 15:47 "He meant none but you" (al-Kafi; Ayyashi); the
//  seven gates as levels (Amir al-Mu'minin (a), Majma); the mutawassimun
//  (al-Kafi); the sabr narration under 15:97 (al-Kafi); refuge in prayer (Majma);
//  yaqin = death (consensus gloss); the Ibrahim+Hijr Friday merit (Thawab
//  al-A'mal). Al-Mizan verified verbatim on 15:9 (the preservation bahth, ila
//  al-abad) and 15:21 (khaza'in); the 15:42 "no power to compel" gloss is
//  Tabrisi's (Majma al-Bayan) - al-Mizan reads the sultan differently and is not
//  cited there. Revised per the Stage 5 four-auditor audit (flow, sourcing/
//  Arabic, readability, voice & reverence) - blocker and should-fix bands applied.
//  Honorifics on the Prophet ﷺ and the Imams (a).
//

import SwiftUI

extension DeepDive {
    static let surahHijr: DeepDive = DeepDive(
        id: "surah-hijr",
        titleEn: "al-Hijr",
        titleAr: "الْحِجْر",
        subtitle: "The Rock City - what can mockery touch, and what can it never reach?",
        sfSymbol: "mountain.2",
        estMinutes: 16,
        acts: [
            ActInfo(number: 1, ar: "الذِّكْر", tr: "al-Dhikr", name: "The Guarded Word"),
            ActInfo(number: 2, ar: "سُلْطَان", tr: "al-Sultan", name: "The Bounded Enemy"),
            ActInfo(number: 3, ar: "الصَّيْحَة", tr: "al-Sayha", name: "The Shriek at Dawn"),
            ActInfo(number: 4, ar: "الصَّفْح", tr: "al-Safh", name: "The Pardon"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "الْحِجْر",
                titleEn: "al-Hijr",
                subtitle: "The Rock City",
                line: "North of Medina, on the old caravan road to Syria, there is a valley where whole houses are carved into the faces of the mountains - doorways, columns, inner rooms, cut straight out of living rock by people who wanted, more than anything, to be safe. The Qur'an named this surah after that valley: al-Hijr. Its people appear in only five of its ninety-nine verses. But the question they died holding fills every one: what does it actually take to be safe? The surah asks it in the loudest years of Mecca's mockery, about a man the whole town was laughing at - and it answers with the only kind of safety that has never once been breached."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "Al-Hijr speaks from the years when the mockery in Mecca was at its cruelest. They called the Prophet ﷺ mad to his face. They demanded he produce angels. And they went home each night to full storehouses and solid walls, certain that whatever this was, it would pass. The surah takes their laughter seriously enough to answer it - not by defending the mocked man, but by walking through everything in creation and sorting it in two: what is guarded, and what only feels guarded. A Word no hand can reach. A sky under watch. An enemy on a leash. And city after confident city that a single morning shout was enough to end. Then, with fifteen verses left, the surah turns to the Prophet ﷺ himself - and to anyone who has ever held something precious in a world that laughs at it - and it keeps its gentlest sentence for its last three verses.",
                leaveWith: "You will leave knowing where safety actually lives - and carrying a prescription, three lines long, that heaven sent down on the night the mockery finally got through."
            ),

            // ── Movement I · al-Dhikr (The Guarded Word) ──────────────────────
            .act(
                act: 1, connector: nil,
                line: "“O you upon whom the dhikr has been sent down - you are mad.” That is the town's opening word to the Prophet ﷺ in this surah, and they follow it with a demand: why do you not bring us the angels, if you are one of the truthful? The surah does not begin by defending him. It begins by granting the demand - hypothetically - just to show what it was worth.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "The Dazzled Eyes", surah: 15, ayah: 15,
                arabic: "لَقَالُوٓا۟ إِنَّمَا سُكِّرَتْ أَبْصَٰرُنَا بَلْ نَحْنُ قَوْمٌۭ مَّسْحُورُونَ",
                translation: "They would say, “Our eyes have only been intoxicated. Rather, we are a people bewitched.”",
                reference: "al-Hijr · 15 : 15",
                reflection: "The demand sounded reasonable: show us one angel, and we will believe. So the surah runs the experiment further than they dared to ask. Not an angel appearing - a gate opened for them in heaven itself, and they themselves climbing through it, on and up, all day long (15:14). Direct experience. Nothing reported, nothing secondhand, nothing to dismiss. And the verse already knows what they would say at the top: our eyes have only been sukkirat - made drunk, sealed over the way drink seals a man's eyes. No - we have been bewitched. Al-Mizan, Tabatabai's great commentary, draws out what the thought experiment proves: with hearts so set, they would fault their own eyes before they would trust what they saw. A heart that has already decided cannot be argued out by evidence, because evidence was never its problem. They did not lack a sign; they lacked the willingness a sign requires. Hold on to the strange word they chose for their own eyes - drunk. And notice the mercy hidden inside the refusal: angels, an earlier verse says, come down only with the final truth - “and then they would not be reprieved” (15:8). The sign they kept demanding was the end of their own time to choose. Every day it did not come was a day held open for them."
            ),
            .verse(
                act: 1, tag: "The Guarded Word", surah: 15, ayah: 9,
                arabic: "إِنَّا نَحْنُ نَزَّلْنَا ٱلذِّكْرَ وَإِنَّا لَهُۥ لَحَٰفِظُونَ",
                translation: "Indeed, it is We who sent down the Reminder, and indeed, it is We who will guard it.",
                reference: "al-Hijr · 15 : 9",
                reflection: "Now hear the sentence the mockery was answered with. Listen to how it is built in the Arabic: inna nahnu - We, We Ourselves - sent down the dhikr, and We, la-hafizun, are surely its guardians. Emphasis stacked on emphasis, like a seal pressed twice. In those years the Prophet ﷺ could protect almost nothing. Not his followers - some were tortured in the open. Not his own standing - the town called him mad. But the one thing in Mecca that no hand could touch was the very thing they were laughing at. Al-Mizan attaches to this verse one of its longest studies, arguing what the verse promises: this Book would be kept from every addition, every loss, every rewriting - kept as it was sent, to the end of time. Fourteen centuries later, you are holding the result. Empires that mocked it are excavation sites; the Word is recited tonight, letter for letter, by millions who have never met each other. And al-Mizan marks how far the promise reaches: it is made for this Book alone, and it runs without limit. So notice what was never promised. Not the Prophet's ﷺ comfort. Not the believers' safety. Only one thing was guaranteed: the Word. The surah has begun quietly sorting the world in two - and the mockers' laughter landed on the unguarded side."
            ),
            .verse(
                act: 1, tag: "The Treasuries", surah: 15, ayah: 21,
                arabic: "وَإِن مِّن شَىْءٍ إِلَّا عِندَنَا خَزَآئِنُهُۥ وَمَا نُنَزِّلُهُۥٓ إِلَّا بِقَدَرٍۢ مَّعْلُومٍۢ",
                translation: "And there is not a thing but that with Us are its treasuries, and We do not send it down except in a known measure.",
                reference: "al-Hijr · 15 : 21",
                reflection: "The guarding is wider than the Book. The surah lifts your eyes: We set constellations in the sky and beautified it for those who look - and We guarded it from every outcast devil; whatever steals close to listen is chased off by a visible flame (15:16-18). Even the sky is patrolled. Then comes this verse, and al-Mizan pauses over it as one of the most far-reaching sentences in the Qur'an. Everything - not most things, anything that can be called a thing - exists first with Him, in treasuries without walls or limits. What arrives in your world is a pouring-out of those treasuries, and it arrives only bi-qadarin ma'lum - in a known measure, fitted and weighed. The next verse gives the homeliest example: winds carrying rain, water sent down for you to drink - “and you are not its keepers” (15:22). You store nothing, ultimately. You receive. Now set this against the town's arithmetic. The mockers measured the Prophet ﷺ by what he visibly held - no wealth, no army, no sons in council - and measured themselves by their storehouses. This verse quietly reverses the audit: every storehouse in Mecca was a trickle from treasuries that belonged entirely to the One they mocked, sent down in a measure He set, stoppable at a word. They were not rich men laughing at a poor one. They were tenants laughing at the beloved of the One who owned it all."
            ),

            // ── Movement II · al-Sultan (The Bounded Enemy) ───────────────────
            .act(
                act: 2,
                connector: "The Word is guarded. The sky is patrolled. And everything that arrives here descends, measured, from treasuries no hand can raid.",
                line: "But the surah is not finished with mockery - it wants to show you where mockery was born. Long before Mecca laughed at a prophet, someone looked at the first human being, before he had drawn a breath, and refused to see anything worth honoring. The surah walks back to the oldest contempt in creation - and to the exact sentence that bounds its power.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Breath", surah: 15, ayah: 29,
                arabic: "فَإِذَا سَوَّيْتُهُۥ وَنَفَخْتُ فِيهِ مِن رُّوحِى فَقَعُوا۟ لَهُۥ سَٰجِدِينَ",
                translation: "“And when I have proportioned him and breathed into him of My spirit, then fall down to him in prostration.”",
                reference: "al-Hijr · 15 : 29",
                reflection: "Listen to how God tells the story of your making. The raw material is named without flattery - clay, from an altered black mud - and the surah repeats that humble origin three times, as if to make sure no one misses it. Then the sentence turns: and I breathed into him min ruhi - of My spirit. Imam al-Baqir (a) was careful with that phrase: the ruh is created - not a fragment of God. He joined it to His own name because He chose it above every other spirit, the way He chose one house among houses to call My house, and one messenger among messengers to call My friend (al-Tawhid; al-Kafi). The clay is mentioned three times and signed by no one. The breath is mentioned once, and He signs it. And that once was enough to command every angel in existence to fall down before the creature formed of clay. All of them prostrated - except one. “Never,” Iblis says, “would I prostrate to a human You created from clay, from an altered black mud” (15:33). Hear his method, because it has not changed since: he describes the human accurately - and only halfway. Clay, mud, dust: all true. The breath: never mentioned again. Mockery has worked exactly this way ever since - look at a creature of clay and breath, and report only the clay. When Mecca said “just a man like us,” they were not wrong about the clay. They were blind to what had been breathed into the man. So was the first mocker. It cost him everything."
            ),
            .verse(
                act: 2, tag: "No Authority", surah: 15, ayah: 42,
                arabic: "إِنَّ عِبَادِى لَيْسَ لَكَ عَلَيْهِمْ سُلْطَٰنٌ إِلَّا مَنِ ٱتَّبَعَكَ مِنَ ٱلْغَاوِينَ",
                translation: "“Indeed, over My servants you have no authority - except the deviators who follow you.”",
                reference: "al-Hijr · 15 : 42",
                reflection: "Cast out, Iblis asks for time - and is given it, “until the Day of the appointed time” (15:38). Even the enemy's leash is written in this surah's language: a known measure, a set term. Then he takes his oath: because You have put me in error, I will make everything on earth beautiful to them, and I will mislead them all (15:39). But he cannot finish the oath without conceding an exception: except Your mukhlasin servants - the ones You have made pure (15:40). Mid-threat, the enemy admits there is territory he cannot enter. And God answers with the sentence this whole movement was built to reach: My servants - over them you have no sultan. No authority, Tabrisi explains in Majma al-Bayan, means no power to compel: he cannot move your hand, cannot make you take a single step. All he was ever given is decoration - he beautifies, suggests, whispers - and he gains a hold only over “those who follow you”: the door opens from your side or not at all. Between the oath and its answer stands one more verse, and it may be the most unexpected line in the scene: “This is a path to Me - straight” (15:41). Even here, with the enemy freshly sworn against you, God is giving directions home. Take stock of what this scene has actually shown you: a tempter, yes - real, patient, ancient. And bounded on every side: reprieved only to a day already set, armed only with suggestion, forbidden the ones made pure. You have spent your life being told to fear him. The surah shows him fenced."
            ),
            .verse(
                act: 2, tag: "Brothers, Facing Each Other", surah: 15, ayah: 47,
                arabic: "وَنَزَعْنَا مَا فِى صُدُورِهِم مِّنْ غِلٍّ إِخْوَٰنًا عَلَىٰ سُرُرٍۢ مُّتَقَٰبِلِينَ",
                translation: "And We will remove whatever is in their breasts of rancor - brothers, on couches, facing one another.",
                reference: "al-Hijr · 15 : 47",
                reflection: "The scene closes by showing where each road ends. For those who follow him: Jahannam, “and it has seven gates - for every gate a portion assigned” (15:44). Amir al-Mu'minin (a) described those gates as levels, one set upon another (Majma al-Bayan) - even the fire is administered, portioned, exact. And for the God-conscious: gardens and springs, and a greeting spoken to them at the door - “Enter it in peace - aminin, secure” (15:46). Then this verse tells you what happens just inside that door, and it may not be what you expected. Before the rivers are mentioned, before any delight, God performs a removal: We strip out - naza'na - whatever rancor was still in their breasts. The word is ghill: the old grudge, the wound that half-healed, the residue a lifetime of being human leaves between people. Paradise, this verse says, is not only a place you are let into. It is something done to what you carry in. And only then the picture completes: brothers, on couches, mutaqabilin - facing one another. No one seated behind anyone. No one watching another's back with an old question still alive in his chest. And of this very verse, Imam al-Sadiq (a) swore to those with him: “You, by Allah - He meant none but you” (al-Kafi). The removal has names on its list. The mockers' brotherhood in this surah is a mob at a door, rejoicing. This is the other door, and the other brotherhood."
            ),

            // ── Movement III · al-Sayha (The Shriek at Dawn) ──────────────────
            .act(
                act: 3,
                connector: "The enemy is real - and fenced. The two ends stand open. And at one of the two doors, the greeting is peace.",
                line: "Between those two doors, God hands His Prophet ﷺ a message to deliver, and its order matters. Mercy comes first, and He names it twice - the Forgiving, the Merciful. The warning comes after, and never on its own: and that My punishment is the painful punishment (15:50). Now the surah stops arguing and starts telling stories - three visits, told almost entirely in doorways and dawns. Guests arrive at a prophet's tent. A mob arrives at a prophet's door. And a shout arrives over a city that had carved itself safe.",
                bridge: BridgeVerse(
                    surah: 15, ayah: 49,
                    arabic: "۞ نَبِّئْ عِبَادِىٓ أَنِّىٓ أَنَا ٱلْغَفُورُ ٱلرَّحِيمُ",
                    translation: "Inform My servants that it is I who am the Forgiving, the Merciful.",
                    reference: "al-Hijr · 15 : 49"
                )
            ),
            .verse(
                act: 3, tag: "Who Despairs?", surah: 15, ayah: 56,
                arabic: "قَالَ وَمَن يَقْنَطُ مِن رَّحْمَةِ رَبِّهِۦٓ إِلَّا ٱلضَّآلُّونَ",
                translation: "He said, “And who despairs of the mercy of his Lord except those astray?”",
                reference: "al-Hijr · 15 : 56",
                reflection: "The first visit is to Ibrahim (a). Strangers enter and say: Peace. He answers with an old desert honesty: we are afraid of you (15:52). The strangers had refused to touch the food he set out - the Qur'an tells that part elsewhere (11:70) - and in his world, a guest who would not eat had come to do harm. Fear not, they say, and hand him the impossible: good news of a boy, and a learned one - to a man whom old age had already touched. His question is not doubt; it is wonder asking how: do you give me this news now that age has come over me? We give it to you in truth, they answer - so do not be of the despairing. And Ibrahim's (a) reply has outlived every ruin in this surah: and who despairs of the mercy of his Lord, except the astray? Hear where that sentence places despair. Not among the moods. Not among the understandable weaknesses. Among the dalun - the ones who have wandered off the road. The commentators explain the logic: despair is never really a statement about your prospects; it is a statement about your knowledge of Him. Whoever knows the width of His mercy and the completeness of His power has nothing left to build a despair out of. To give up on Him is to have lost the way to Him - it is a location, not a feeling. Mark this verse well, and mark who says it. In the verses ahead you will stand in cities God chose not to save. The surah wants Ibrahim's (a) sentence already in your hand when you get there."
            ),
            .verse(
                act: 3, tag: "By Your Life", surah: 15, ayah: 72,
                arabic: "لَعَمْرُكَ إِنَّهُمْ لَفِى سَكْرَتِهِمْ يَعْمَهُونَ",
                translation: "By your life, they were wandering blind in their intoxication.",
                reference: "al-Hijr · 15 : 72",
                reflection: "The same messengers walk on to Lut (a), and the story arrives at its worst hour. The city's men come to his house “rejoicing” - a mob happy about what it intends (15:67). He pleads: these are my guests; do not disgrace me in them. Fear God. And they answer with the entitlement of the long-unpunished: did we not forbid you from taking anyone in? A prophet of God, inside his own walls, unable to protect his own door. And exactly there - at the lowest point of a prophet's helplessness - God halts the story to swear an oath: la-'amruka. By your life. In the entire Qur'an, God swears by His own creations many times - the dawn, the fig, the star - but by the life of a human being, only here, and only his. Ibn Abbas said: God never created a soul more honored to Him than Muhammad ﷺ, and I have never heard Him swear by anyone's life but his (Majma al-Bayan). Al-Qummi calls it a distinction given to him above all the prophets. Notice when it was given: while one mocked prophet's story touched bottom, God turned to another mocked prophet and swore by his life. The mocked, in this Book, are the sworn-by. And hear what the oath asserts: they are wandering blind in their sakra - their drunkenness. The mockers of Mecca had chosen that word themselves: even shown an open gate in heaven, they said, our eyes would only have been made drunk (15:15). The Qur'an takes them at their word. The drunkenness was real; it was just never in their eyes."
            ),
            .verse(
                act: 3, tag: "The Readers of Ruins", surah: 15, ayah: 75,
                arabic: "إِنَّ فِى ذَٰلِكَ لَءَايَٰتٍۢ لِّلْمُتَوَسِّمِينَ",
                translation: "Indeed in that are signs for those who discern.",
                reference: "al-Hijr · 15 : 75",
                reflection: "Then it is dawn again. The shriek seized them at sunrise; the city was turned upside down; and stones of baked clay came down like weather (15:73-74). The family who feared God had walked out by night, before it came, told not to look back. And over the ruin the surah writes one line: in that are signs li-l-mutawassimin - for those who can read a ruin and tell what happened there. The next verse adds something quietly unsettling: the cities lie “on a road still traveled” (15:76). This was not archaeology to the first listeners. Quraysh's own caravans rode past those ruins on the way to Syria - the mockers of Mecca were commuting through the evidence. Amir al-Mu'minin (a) said: the Messenger of Allah ﷺ was the one who reads the signs, and I after him, and the Imams from my progeny after me (al-Kafi). And the Prophet ﷺ taught: beware the discernment of the believer, for he looks with the light of Allah (Majma al-Bayan). The road you are traveling has people on it who know how to read it. The question is only ever which caravan you ride with."
            ),
            .verse(
                act: 3, tag: "Carved Secure", surah: 15, ayah: 82,
                arabic: "وَكَانُوا۟ يَنْحِتُونَ مِنَ ٱلْجِبَالِ بُيُوتًا ءَامِنِينَ",
                translation: "And they used to carve houses out of the mountains, feeling secure.",
                reference: "al-Hijr · 15 : 82",
                reflection: "Now the surah arrives at the people it is named for. Ashab al-Hijr - the people of the rock valley: Thamud, who turned away from every sign given to them (15:80-81), and whose engineering outlived them by thousands of years. The verse hands them a single epitaph: they carved houses out of the mountains, aminin - feeling secure. The commentators unfold what the carving had bought them: walls no thief could tunnel through, no enemy could pull down, no storm could shake. Rock does not burn, does not flood, does not fall. They had audited every danger they could imagine and engineered away each one - every danger except the one that mattered, which no audit of theirs could see. And you have heard that word before. One movement ago, at the door of the gardens: “Enter it in peace - aminin” (15:46). In all ninety-nine verses, the surah speaks the word aminin - secure - exactly twice: once spoken by God at a door He opens, once felt by people inside walls they cut themselves. That pair is the whole teaching of this surah, laid side by side: security granted, and security carved. The difference showed at dawn. “The shriek seized them in the morning - and nothing that they had earned availed them” (15:83-84): not the flawless walls, the commentators note, not the amassed wealth, not the numbers. One sound, and the safest address in Arabia became a warning on a trade route. And if these ruins tempt you toward despair - about the age, about someone you love - keep hold of Ibrahim's (a) sentence from the first visit: despair is the astray road, not the realistic one. The ruins are not evidence against His mercy. They are evidence against the walls. The surah is not against your longing to be safe - it honors that longing too much to let you spend it on rock. It is named for the people who settled for the counterfeit, so that you would ask, in time, where the real thing is given."
            ),

            // ── Movement IV · Sadruk (Your Chest) ─────────────────────────────
            .act(
                act: 4,
                connector: "Three visits have ended. Good news walked into one tent; a shout at sunrise ended two cities; and the carved aminin fell at dawn, while the granted one still stands at the door of the gardens.",
                line: "Now the surah does what it has not done in eighty-four verses: it turns away from the mockers entirely. No more arguments, no more ruins. What remains is God speaking directly to His mocked Prophet ﷺ - fifteen verses that read like a hand laid on a shoulder. They begin: “The Hour is coming - so forgive, with gracious forgiveness” (15:85). Imam Ali (a) defined that forgiveness in four words: pardon, without reproach (Majma al-Bayan). And then God sets before the Prophet ﷺ what he actually owns.",
                bridge: nil
            ),
            .verse(
                act: 4, tag: "The Seven", surah: 15, ayah: 87,
                arabic: "وَلَقَدْ ءَاتَيْنَٰكَ سَبْعًۭا مِّنَ ٱلْمَثَانِى وَٱلْقُرْءَانَ ٱلْعَظِيمَ",
                translation: "And We have certainly given you seven of the oft-repeated, and the great Qur'an.",
                reference: "al-Hijr · 15 : 87",
                reflection: "Count what the mockers held: the caravans, the storehouses, the seats in council - everything the surah calls “what We have let them enjoy.” Against all of it, God names for His Prophet ﷺ what he holds, in a single line: We have given you seven of the mathani, and the great Qur'an. The Prophet ﷺ himself opened this verse, in words Amir al-Mu'minin (a) preserved: “Allah said to me: O Muhammad, We have given you seven of the mathani and the great Qur'an - He singled out His favor to me with the Opening of the Book, and set it opposite the great Qur'an” (Uyun Akhbar al-Rida). The Seven are al-Fatiha: seven verses, counting Bismillah, called al-mathani - the doubled - because, Imam al-Sadiq (a) explained, they are repeated in every pair of rak'ahs; no prayer in the world stands without them (Tafsir al-Ayyashi; Majma al-Bayan carries the same from Ali, al-Baqir and al-Sadiq (a)). Weigh the scale this verse has built. On one side, everything Mecca's rich were loaned to enjoy for a while. On the other, one man. God did not lend him anything - He gave. He gave him the small surah He Himself set opposite the whole Qur'an, and the Qur'an with it. If you have walked the al-Fatiha descent, you know what makes the Seven heavier than they look: it is the surah He answers, line by line, every time you pray it. The mockers owned Mecca's mornings. The mocked man was given the words that have opened every believing morning since. And a deeper reading waited in his household: “We are the mathani,” said Imam al-Baqir (a) - and al-Saduq explains: we are the ones the Prophet ﷺ paired with the Qur'an, and commanded his community to hold to both (al-Tawhid; Tafsir al-Ayyashi). The doubled, never to be separated - the very two weights this app is named for."
            ),
            .verse(
                act: 4, tag: "Do Not Stretch Your Eyes", surah: 15, ayah: 88,
                arabic: "لَا تَمُدَّنَّ عَيْنَيْكَ إِلَىٰ مَا مَتَّعْنَا بِهِۦٓ أَزْوَٰجًۭا مِّنْهُمْ وَلَا تَحْزَنْ عَلَيْهِمْ وَٱخْفِضْ جَنَاحَكَ لِلْمُؤْمِنِينَ",
                translation: "Do not extend your eyes toward what We have given some of them to enjoy, and do not grieve over them - and lower your wing to the believers.",
                reference: "al-Hijr · 15 : 88",
                reflection: "The gift comes with an instruction, and it is aimed at the eyes. La tamuddanna aynayk - do not stretch your eyes toward what they were given to enjoy. When this verse came down, the Prophet ﷺ taught what stretched eyes cost: whoever keeps his gaze on what is in another's hands, his worry grows great, and his rage is never healed (al-Qummi). He lived the verse as plainly as it is written - Tabrisi records that he would not so much as rest his eyes on the attractions of this world (Majma al-Bayan). And do not grieve over them, the verse adds - over the mockers themselves, still spending their loan. Then the instruction turns warm: wakhfid janahaka - lower your wing to the believers, the way a bird settles it over its own. Stop measuring yourself against the people laughing at you; spread what you carry over the people walking with you. A man who holds the Seven and the Qur'an has no reason left to envy a caravan."
            ),
            .verse(
                act: 4, tag: "Proclaim", surah: 15, ayah: 94,
                arabic: "فَٱصْدَعْ بِمَا تُؤْمَرُ وَأَعْرِضْ عَنِ ٱلْمُشْرِكِينَ",
                translation: "So proclaim openly what you are commanded, and turn away from the polytheists.",
                reference: "al-Hijr · 15 : 94",
                reflection: "For five years - some reports say three - the mission had lived indoors. Imam al-Sadiq (a) describes those years in one aching line: the Messenger of Allah ﷺ stayed hidden, afraid, “and Ali (a) with him, and Khadija (a)” (Kamal al-Din). The whole faith of the final Prophet ﷺ, behind one shut door, in a city of mockers. Then this verse. Fasda' - the verb means to crack something open, the way dawn cracks the night. Proclaim it so it splits the town. The reports set a scene around its coming down (al-Ihtijaj, from Amir al-Mu'minin (a)): the chiefs of the mockers gave the Prophet ﷺ an ultimatum - recant by noon, or die. He went into his house grieved and shut the door on their words. Within the hour, Jibril (a) came down from God: He sends you salam, and He says - crack forth with what you are commanded. And the mockers? “We are sufficient for you against the mockers” (15:95). “They were standing in front of me just now,” the Prophet ﷺ said. “You have been spared them,” Jibril (a) answered. There were five, and al-Qummi names each one - al-Walid ibn al-Mughira, al-As ibn Wa'il, the two Aswads, al-Harith - and Amir al-Mu'minin (a) recounted their endings: in a single day, each by a different death, and the reports place the same dying sentence on their lips: “The Lord of Muhammad has killed me” (al-Ihtijaj). God did not ask His Prophet ﷺ to fight them. He asked him to speak - and made the mockers His own affair. Then the Prophet ﷺ walked out to the Kaaba. He stood, al-Qummi records, upon al-Hijr - the low stone wall at its side. Even the ground he proclaimed from carried this surah's name. And he called out: O Quraysh, O Arabs: I call you to testify that there is no god but Allah, and that I am the Messenger of Allah. The town answered with the only word it had ever had for him: Muhammad has gone mad. The town's opening insult, returned word for word to his face - and this time it changed nothing at all. The whisper years were over. The mockery had not ended; it had stopped mattering."
            ),
            .climax(
                act: 4, tag: "We Know", source: "al-Hijr · 15 : 97-99",
                arabic: "وَلَقَدْ نَعْلَمُ أَنَّكَ يَضِيقُ صَدْرُكَ بِمَا يَقُولُونَ",
                translation: "And We certainly know that your chest tightens at what they say.",
                body: "Ninety-six verses of guarded skies, bounded enemies, fallen cities, answered mockers - and now, at the very end, God says the quietest thing in the surah. We know. We certainly know - la-qad na'lamu - that your chest tightens at what they say. Stop on what this sentence is not. It is not a rebuke: no “how can a prophet feel this?” It is not a dismissal: no “rise above it.” The Lord of the treasuries, who has spent this whole surah proving that nothing escapes His measure, turns that same total knowledge toward the chest of one man - and tells him, in the surah's quietest words, that He knows. Imam al-Sadiq (a) tells the story behind it: God had commanded His Prophet ﷺ to patience and gentleness, and he was patient - until they struck at him with enormities, and his chest closed, and then this came down (al-Kafi). The tightness was not a crack in his faith. It was the cost of carrying a guarded Word through an unguarded world - and heaven answered it not with an argument, but with a prescription, three lines long. Fa-sabbih bi-hamdi rabbik: glorify with the praise of your Lord - give the weight words, and give the words to Him. Wa-kun mina al-sajidin: be of those in sujud - the position in which a human being holds nothing, defends nothing, and cannot fall further. Tabrisi records what this looked like in the Prophet's ﷺ life: whenever a matter grieved him, he took refuge in the prayer (Majma al-Bayan). Not after trying everything else - as the reflex itself. And then the last line of the surah, the far end of the prescription: wa-'bud rabbaka hatta ya'tiyaka al-yaqin. Worship your Lord until al-yaqin comes to you - and the commentators are unanimous about that final word: the certainty is death. Not “worship until you feel certain,” as if devotion were a course to complete. Until the certain thing arrives - the one appointment this surah of measured terms has been counting toward all along. It is the word this app's oldest descent is named for, and here it stands as the Qur'an's definition of a lifetime: the distance you cross in His service, between this tight-chested night and the morning the yaqin comes.",
                reflection: "Now every thread the surah opened closes into one answer. Where does safety live? Not in the carved walls - you watched them fall at a shout. Not in the storehouses - they were always His treasuries, on loan by measure. It lives where the surah's two unbreached guarantees stand: the Word He guards, and the servants over whom the enemy was given no authority. The prescription is how you take up residence: tasbih, sujud, service - until the yaqin. He never promised His Prophet ﷺ that the laughing would stop. He promised him something the laughing could not reach - and then He swore by his life. The Prophet ﷺ outlived every one of his mockers. The tight chest carried the guarded Word the whole way home."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "What tightens your chest - and can you carry it into sujud tonight?",
                placeholder: "A mockery, a fear, a place you keep trying to carve safe...",
                subline: "You came down through a surah that sorted the whole world in two: what is guarded, and what only feels guarded. The Word was guarded; the walls were not. The enemy was fenced; the mockers were answered by God Himself. And at the bottom of the descent stood the gentlest sentence in it: We know. Before you go, name the thing you have been trying to carve into safety - and the tightness you could bring to Him instead, the way His Prophet ﷺ was taught to: praise, sujud, service, until the yaqin.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "الْحِجْر",
                essence: "The surah named for houses carved into mountains never condemns the longing to be safe. It relocates it. Everything its people carved is a ruin on a trade route; everything God undertook to guard is still standing - the Word, recited tonight on every continent, and the servants no enemy was ever given power over. Between the two aminin of this surah runs its whole teaching: one was carved, and it fell at dawn. One is granted, at a door where the greeting is peace.",
                line: "Imam al-Sadiq (a) taught that whoever recites Surah Ibrahim and Surah al-Hijr together in a two-rak'ah prayer every Friday will never be struck by poverty, madness, or affliction (Thawab al-A'mal). If you have walked the Ibrahim descent, you have heard that promise before - these two surahs are a pair: the planted word, and the guarded one. Read al-Hijr now in its own words, all ninety-nine verses - the guarded sky, the fenced enemy, the three visits, the seven gates and the seven verses - and when you reach the last line, read it as what this descent has shown it to be: not a command only, but a promise that He will be worth worshipping every single day between tonight and the yaqin."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Hijr experience") {
    DeepDiveView(dive: .surahHijr, onClose: {})
}
#endif
