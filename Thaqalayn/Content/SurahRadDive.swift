//
//  SurahRadDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Ra'd" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/rad-script.md.
//  Revised per the Stage 5 four-auditor audit (flow, sourcing/Arabic, readability,
//  voice & reverence) - all bands applied.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically, never hand-typed, to survive
//  the byte-for-byte check).
//
//  Spine: the demand for a sign ("Why has no sign been sent down to him?"),
//  answered three times over - the sky already speaks (thunder as praise, 13:13);
//  truth arrives as water, not spectacle (the flood and the foam, 13:17); and what
//  the demand was thirsting for is given quietly - a heart at rest (13:28), a
//  decree that listens (13:39), and a person: the guide promised unnamed at the
//  surah's door (13:7) and named at its seal (climax 13:43). No dua beat; ends on
//  .closing, which hands off to reading the full surah.
//
//  Sourcing is Shia and audit-verified against primary sources: al-Mizan
//  (Tabatabai - 13:4 one water, 13:7 law of the guide, 13:13 tasbih via 17:44,
//  13:14, 13:17 capacity, 13:28 heart's rest and dhikr wider than formulas,
//  13:31 unspoken jawab, 13:39 two registers); Majma al-Bayan (Tabrisi - the
//  Prophet's ﷺ thunder response under 13:13, the angel reading, the 13:31 sabab
//  with corrected demands, valleys-as-hearts from Ibn Abbas under 13:17);
//  Nahj al-Balagha Khutba 50 (truth/falsehood mixing, 13:17); Tafsir al-Ayyashi
//  under 13:28 (al-Sadiq (a): "By Muhammad ﷺ hearts find rest"); al-Kafi
//  (Kitab al-Du'a: al-Kazim (a) on du'a and the decree, sahih; Kitab al-Tawhid
//  bab al-bada: al-Sadiq (a) "not magnified by anything like bada"; Kitab
//  al-Hujja ch. 35 h. 6 and ch. 10 h. 2: al-Baqir (a) under 13:43 and to Burayd
//  under 13:7); Ma'ani al-Akhbar (Abu Sa'id al-Khudri asks the Prophet ﷺ about
//  27:40 and 13:43); the 13:7 revelation report "I am the warner and Ali is the
//  guide after me" (Majma al-Bayan via Ibn Abbas; Sunni parallels: al-Tabari,
//  Tha'labi, al-Durr al-Manthur); the recitation merit (Thawab al-A'mal, with
//  Majma al-Bayan's trimmed form). Honorifics on the Prophet ﷺ and the Imams (a).
//

import SwiftUI

extension DeepDive {
    static let surahRad: DeepDive = DeepDive(
        id: "surah-rad",
        titleEn: "al-Ra'd",
        titleAr: "الرَّعْد",
        subtitle: "The Thunder - where is the sign you have been asking for?",
        sfSymbol: "cloud.bolt.rain",
        estMinutes: 13,
        acts: [
            ActInfo(number: 1, ar: "الرَّعْد", tr: "al-Ra'd", name: "The Answering Sky"),
            ActInfo(number: 2, ar: "الزَّبَد", tr: "al-Zabad", name: "The Foam"),
            ActInfo(number: 3, ar: "الطُّمَأْنِينَة", tr: "al-Tuma'nina", name: "The Rest"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "الرَّعْد",
                titleEn: "al-Ra'd",
                subtitle: "The Thunder",
                line: "The Qur'an could have named this surah for anything. It named it for a sound - the crack in the sky that makes every living thing flinch. Inside it, people keep demanding one thing of the Prophet ﷺ: a sign. Something loud enough, undeniable enough, that doubt would simply end. Most of us have wanted it too: one unmistakable answer from heaven. This surah is God's reply to that longing. And the first thing it says about the thunder is that the sound you flinch from is not what you think it is. Neither is the sign you are waiting for."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "Al-Ra'd speaks from the hardest years of the Prophet's ﷺ mission - years when he had the verses and little else: no army behind him, no state, no wonder to produce when they called for one. So the question kept coming: if this is really from God, why has no sign come down? The surah takes that question more seriously than the people asking it. And it answers three times over - each answer quieter and closer than the one before. First with the sky. Then with water. Then with something standing closer than anyone thought to look. And at its door the surah makes one promise it does not fulfill until its very last verse.",
                leaveWith: "You will leave knowing why the sign you have asked for was never refused - it was answered, in a quieter way than anyone was watching for. And you will know the name the surah waits all forty-three verses to say out loud."
            ),

            // ── Movement I · al-Ra'd (The Answering Sky) ──────────────────────
            .act(
                act: 1, connector: nil,
                line: "“Why has no sign been sent down to him from his Lord?” Show us something. Split the sky, and we will believe. The surah's first answer is not an argument. It points - at the ground under their feet, at the sky over their heads - and begins to count what is already speaking.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "One Water", surah: 13, ayah: 4,
                arabic: "وَفِى ٱلْأَرْضِ قِطَعٌۭ مُّتَجَٰوِرَٰتٌۭ وَجَنَّٰتٌۭ مِّنْ أَعْنَٰبٍۢ وَزَرْعٌۭ وَنَخِيلٌۭ صِنْوَانٌۭ وَغَيْرُ صِنْوَانٍۢ يُسْقَىٰ بِمَآءٍۢ وَٰحِدٍۢ وَنُفَضِّلُ بَعْضَهَا عَلَىٰ بَعْضٍۢ فِى ٱلْأُكُلِ ۚ إِنَّ فِى ذَٰلِكَ لَءَايَٰتٍۢ لِّقَوْمٍۢ يَعْقِلُونَ",
                translation: "And in the earth are neighboring plots, and gardens of grapevines, and crops, and palm trees - twinned from one root, and standing alone - watered with one water; and We favor some of them over others in fruit. Surely in that are signs for a people who reason.",
                reference: "al-Ra'd · 13 : 4",
                reflection: "Start where the surah starts counting - not in the heavens, in a garden. Neighboring plots, side by side. Vines, grain, date palms. Some of the palms are twins - sinwan - two trunks rising out of one root. And all of it, the verse says, watered with one water. Same soil, same rain, same sun - and one palm comes up sweet while its twin comes up poor. Al-Mizan, Tabatabai's great commentary, pauses exactly here: the verse names “one water” on purpose. If water, soil, and light decided everything, neighbors would be identical. A will chooses the difference, fruit by fruit - a will at work in every orchard, closer to each tree than the rain is. And notice how the verse ends. The one before it closed “for a people who reflect”; this one closes “for a people who reason” - the surah is asking more of you as it goes, from looking to thinking. They asked for one sign to be sent down. The surah begins with a garden where a thousand are already growing."
            ),
            .verse(
                act: 1, tag: "The Thunder", surah: 13, ayah: 13,
                arabic: "وَيُسَبِّحُ ٱلرَّعْدُ بِحَمْدِهِۦ وَٱلْمَلَٰٓئِكَةُ مِنْ خِيفَتِهِۦ وَيُرْسِلُ ٱلصَّوَٰعِقَ فَيُصِيبُ بِهَا مَن يَشَآءُ وَهُمْ يُجَٰدِلُونَ فِى ٱللَّهِ وَهُوَ شَدِيدُ ٱلْمِحَالِ",
                translation: "And the thunder glorifies His praise, and the angels too, in awe of Him. And He sends the thunderbolts and strikes with them whom He wills - while they dispute about Allah. And He is severe in might.",
                reference: "al-Ra'd · 13 : 13",
                reflection: "Here is the verse the surah is named for. To every human nervous system, thunder means threat. The verse says: what you are hearing is praise. The thunder glorifies Him, and the angels with it, in awe. Al-Mizan grounds it in the Qur'an's own words: “There is nothing that does not glorify His praise - but you do not understand their glorification” (17:44). Everything that exists praises Him by the sheer fact of existing; the thunder's roar is that silent praise made audible to ears like ours. Majma al-Bayan, Tabrisi's commentary, records another reading: the thunder is the voice of an angel driving the clouds - the sound of the sky being worked. And the verse just before this one says the lightning is shown to you “in fear and hope” (13:12): the same flash that can kill announces the rain that feeds. Then the verse turns. He sends the thunderbolts and strikes whom He wills - while they dispute about Allah. The whole sky is at work and worshipping - and underneath it, one creature, the only one given language, uses it to argue. It is reported that the Prophet ﷺ, when thunder broke, would answer it: “Glory be to Him whom the thunder glorifies with His praise” (Majma al-Bayan). Not flinching - replying."
            ),
            .verse(
                act: 1, tag: "The Empty Palms", surah: 13, ayah: 14,
                arabic: "لَهُۥ دَعْوَةُ ٱلْحَقِّ ۖ وَٱلَّذِينَ يَدْعُونَ مِن دُونِهِۦ لَا يَسْتَجِيبُونَ لَهُم بِشَىْءٍ إِلَّا كَبَٰسِطِ كَفَّيْهِ إِلَى ٱلْمَآءِ لِيَبْلُغَ فَاهُ وَمَا هُوَ بِبَٰلِغِهِۦ ۚ وَمَا دُعَآءُ ٱلْكَٰفِرِينَ إِلَّا فِى ضَلَٰلٍۢ",
                translation: "To Him belongs the call of truth. And those they call on besides Him answer them with nothing - except as one who stretches his palms toward water so it may reach his mouth, and it will never reach it. The call of the disbelievers is only lost.",
                reference: "al-Ra'd · 13 : 14",
                reflection: "To Him belongs da'wat al-haqq - the call of truth: when He is called, calling means something. Then the verse looks at every other call, and gives it the Qur'an's most haunting image of futility. A man kneels at the water's edge. He stretches out both palms and beckons - come up, reach my mouth. The water does not move. It is not refusing him; it cannot hear him. Al-Mizan points at where the tragedy actually is: not that the idol says no - a no would at least be an answer - but that there is no one there at all to hear him. And the posture is timeless: a human being, kneeling before something that cannot hear, asking it for what it cannot give. Every age has its beckoned water. So look at what the surah has counted so far. The orchards point back to their Maker. The thunder is praising Him. All of creation answers Him - and whatever is called on instead answers nothing at all. Which brings the surah back to their demand: if the sky is already speaking and every idol is deaf, what kind of sign is left to ask for? The surah's reply is one verse long, and it is not a wonder."
            ),
            .verse(
                act: 1, tag: "For Every People", surah: 13, ayah: 7,
                arabic: "وَيَقُولُ ٱلَّذِينَ كَفَرُوا۟ لَوْلَآ أُنزِلَ عَلَيْهِ ءَايَةٌۭ مِّن رَّبِّهِۦٓ ۗ إِنَّمَآ أَنتَ مُنذِرٌۭ ۖ وَلِكُلِّ قَوْمٍ هَادٍ",
                translation: "And those who disbelieve say: Why has no sign been sent down to him from his Lord? You are only a warner - and for every people there is a guide.",
                reference: "al-Ra'd · 13 : 7",
                reflection: "Now go back - to the surah's seventh verse, where the demand was first met head-on. Look closely at what the answer is not. No mountain moves. No sky splits. Instead, God names two roles. You are only a warner - that is the Prophet's ﷺ office: to stand before a people and sound the warning. And for every people there is a guide - that, al-Mizan says, is a law of history: no people, in any land or any age, is ever left without one. A warner to wake you; a guide to walk you home. The warner they could see - he was standing in front of them, reciting this very verse. But the guide - the verse names no one. It gives one Arabic word, and places it last: hadin - a guide. Not the guide. Not a name. Not where to look. The surah keeps that name for its very last verse. So carry the question down with you, the way the first listeners had to: if the warner was standing in front of them - then who, standing where, is the guide?"
            ),

            // ── Movement II · al-Zabad (The Foam) ─────────────────────────────
            .act(
                act: 2,
                connector: "The sky has answered: one water becomes a thousand different fruits, and the thunder over your head is praise. And the demand for a sign was met with a promise - a warner, and a guide.",
                line: "But an honest question is still standing, and the surah does not look away from it. If truth is this surrounded by witnesses - why does it keep losing? Why do the loudest voices, the biggest lies, the emptiest people seem to run every age? The surah answers with the thing thunder has been promising all along. Rain.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Flood", surah: 13, ayah: 17,
                arabic: "أَنزَلَ مِنَ ٱلسَّمَآءِ مَآءًۭ فَسَالَتْ أَوْدِيَةٌۢ بِقَدَرِهَا فَٱحْتَمَلَ ٱلسَّيْلُ زَبَدًۭا رَّابِيًۭا ۚ وَمِمَّا يُوقِدُونَ عَلَيْهِ فِى ٱلنَّارِ ٱبْتِغَآءَ حِلْيَةٍ أَوْ مَتَٰعٍۢ زَبَدٌۭ مِّثْلُهُۥ ۚ كَذَٰلِكَ يَضْرِبُ ٱللَّهُ ٱلْحَقَّ وَٱلْبَٰطِلَ ۚ فَأَمَّا ٱلزَّبَدُ فَيَذْهَبُ جُفَآءًۭ ۖ وَأَمَّا مَا يَنفَعُ ٱلنَّاسَ فَيَمْكُثُ فِى ٱلْأَرْضِ ۚ كَذَٰلِكَ يَضْرِبُ ٱللَّهُ ٱلْأَمْثَالَ",
                translation: "He sends down water from the sky, and riverbeds flow, each to its measure, and the flood carries a swelling foam - and from what they smelt in the fire, seeking ornaments or tools, comes a foam like it. Thus does Allah set forth truth and falsehood. As for the foam, it goes off as scum; and as for what benefits people, it remains in the earth. Thus does Allah set forth the parables.",
                reference: "al-Ra'd · 13 : 17",
                reflection: "Watch the parable move. Rain falls on dry hills, and the dead riverbeds come alive - each one flowing to its own measure: a great valley takes a river, a narrow one takes a stream. Al-Mizan draws the law beneath the image: what descends from God is one, and every vessel receives by the measure of its own capacity. The older commentators said it plainly - the valleys are hearts (Majma al-Bayan, from Ibn Abbas). One rain, and every heart carries what it has made room for. Then look at the surface. The flood churns up foam - zabad - swollen, glittering, riding on top. From the bank, the foam is all you can see of the river, and it makes all the noise. The verse draws the same picture a second way, from the metalworker's fire: melt gold or silver, and a scum rises there too - on top, again, and shining. Then God states the law. The foam goes off as scum, tossed aside. And what benefits people remains in the earth. Not what glitters. Not what is loud. What benefits. Imam Ali (a) says in Nahj al-Balagha that falsehood on its own could never deceive a seeker; it survives by being mixed into truth - foam riding on water. So stop measuring the age by its surface, where the foam is winning. Measure by what will still be here after the flood has passed."
            ),
            .verse(
                act: 2, tag: "Moving Mountains", surah: 13, ayah: 31,
                arabic: "وَلَوْ أَنَّ قُرْءَانًۭا سُيِّرَتْ بِهِ ٱلْجِبَالُ أَوْ قُطِّعَتْ بِهِ ٱلْأَرْضُ أَوْ كُلِّمَ بِهِ ٱلْمَوْتَىٰ ۗ بَل لِّلَّهِ ٱلْأَمْرُ جَمِيعًا ۗ أَفَلَمْ يَا۟يْـَٔسِ ٱلَّذِينَ ءَامَنُوٓا۟ أَن لَّوْ يَشَآءُ ٱللَّهُ لَهَدَى ٱلنَّاسَ جَمِيعًۭا ۗ وَلَا يَزَالُ ٱلَّذِينَ كَفَرُوا۟ تُصِيبُهُم بِمَا صَنَعُوا۟ قَارِعَةٌ أَوْ تَحُلُّ قَرِيبًۭا مِّن دَارِهِمْ حَتَّىٰ يَأْتِىَ وَعْدُ ٱللَّهِ ۚ إِنَّ ٱللَّهَ لَا يُخْلِفُ ٱلْمِيعَادَ",
                translation: "And if there were a Qur'an by which mountains were moved, or the earth were torn open, or the dead were made to speak - no, to Allah belongs the matter entirely. Have the believers not realized that had Allah willed, He would have guided all mankind together? And disaster will not cease to strike those who disbelieve for what they have done, or to land close to their homes, until the promise of Allah comes. Surely Allah does not fail the appointment.",
                reference: "al-Ra'd · 13 : 31",
                reflection: "They came back with a proposal - Majma al-Bayan preserves the scene. A delegation of Quraysh, Abdullah ibn Abi Umayya among them, stood before the Prophet ﷺ and named their price. Move these mountains of Mecca back, they said, so this narrow valley opens up for planting. Give us springs and rivers in it. Subject the wind to us, so we can ride it to Syria and be back in a day. Raise your forefather Qusayy, so the dead can vouch for you. Do that, and we will believe. The verse gives them their scene for a moment - suppose there were a recitation that could drive mountains, tear the earth open, make the dead speak - then cuts the supposing off in four words: to Allah belongs the matter entirely. Al-Mizan reads the unspoken half of the sentence: even that Qur'an would not have guided them. Guidance was never a function of the size of the sign. Then the verse turns, not to the deniers but to the believers, with a question that comes very close to home: have the believers not realized that had Allah willed, He would have guided all mankind together? The overwhelming display was always available - one irresistible sign, and every knee on earth bends - and He willed otherwise, once and for all. A yes forced out of you is not faith; it is surrender under compulsion, and He did not make hearts in order to compel them. He wants the heart that turns to Him while saying no was still an option. The loud sign is the foam. The Book is the water. Stop waiting for the answer to arrive louder than everything else. It was never going to come that way - and that was decided long before you asked."
            ),
            .verse(
                act: 2, tag: "From Every Gate", surah: 13, ayah: 24,
                arabic: "سَلَٰمٌ عَلَيْكُم بِمَا صَبَرْتُمْ ۚ فَنِعْمَ عُقْبَى ٱلدَّارِ",
                translation: "Peace be upon you for what you patiently endured. How excellent is the final home.",
                reference: "al-Ra'd · 13 : 24",
                reflection: "The foam is the loud thing that goes. So who is the water - the part that stays? The surah has just described them, in the four verses before this one (13:20-23), and the portrait is strikingly quiet. They keep their covenant with Allah. They keep the ties He commanded to be kept - family first. They fear their Lord, and the evil of the reckoning. They endure, seeking nothing but His Face. They hold the prayer. They give, secretly and openly. They push evil back with good. Not one loud thing in the list - no conquest, no spectacle, nothing that would make the news of any age. Then comes the scene those verses were building: the Gardens of Eden, “and the angels enter upon them from every gate” (13:23), saying one sentence: Peace be upon you for what you patiently endured. Al-Mizan notices where the angels come in - from every gate, because these people held on at every gate of life: patience in obedience, patience away from sin, patience under affliction. And listen to the verse's last words: how excellent is uqba al-dar - the home at the end, still standing when everything loud has passed. The surah has already taught you the word for people like this. What benefits, remains."
            ),

            // ── Movement III · al-Tuma'nina (The Rest) ────────────────────────
            .act(
                act: 3,
                connector: "The flood has passed, and you have seen what it leaves: the foam gone as scum, the patient welcomed at every gate - and the loud sign refused, once and for all.",
                line: "But everything promised so far waits at the end of the road - the gates, the greeting, the lasting home. What about tonight? What does a person actually hold, here and now, once they stop waiting for the loud sign and start seeing the quiet ones? The surah answers with its two quietest verses.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "Hearts Find Rest", surah: 13, ayah: 28,
                arabic: "ٱلَّذِينَ ءَامَنُوا۟ وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ ٱللَّهِ ۗ أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ",
                translation: "Those who believe, and whose hearts find rest in the remembrance of Allah. Truly, in the remembrance of Allah do hearts find rest.",
                reference: "al-Ra'd · 13 : 28",
                reflection: "You have met this verse before - on a wall, a pendant, a shared image. Here is the home it comes from. One verse earlier, the old demand surfaces one last time - why has no sign been sent down? - and the reply turns inward: “He guides to Himself whoever turns back” (13:27). The sign was never going to be sent down to you. You were going to be walked home. And this verse tells you what the walk feels like from inside: hearts - tatma'innu - find rest. Settle. Stop bracing. In dhikr - in the remembrance of Allah. Al-Mizan explains why: the heart was built to be near one thing only, and it will not settle anywhere else. Finite things cannot quiet it - not because they are bad, but because they are small. And this remembrance, al-Mizan adds, is wider than the counted formulas: it is whatever brings Him back to your mind at all. A narration under this verse goes further still. Imam al-Sadiq (a) said: “By Muhammad ﷺ hearts find rest; he is the remembrance of Allah” (Tafsir al-Ayyashi). Even the rest arrives through a person. Now go back to the man at the water's edge - palms out, beckoning what could not hear him. The surah built him so you would meet this verse. Every heart is stretched toward something, and most of what we stretch toward cannot reach our mouths. This is the verse where the water reaches."
            ),
            .verse(
                act: 3, tag: "The Pen Still Moves", surah: 13, ayah: 39,
                arabic: "يَمْحُوا۟ ٱللَّهُ مَا يَشَآءُ وَيُثْبِتُ ۖ وَعِندَهُۥٓ أُمُّ ٱلْكِتَٰبِ",
                translation: "Allah erases what He wills, and confirms - and with Him is the Mother of the Book.",
                reference: "al-Ra'd · 13 : 39",
                reflection: "One more gift, for tonight rather than the end of the road. The verse before this one closes: “for every term there is a Book” (13:38) - everything written, everything appointed. If that were the whole truth, prayer would be reading aloud to a finished page. Then comes this: Allah erases what He wills, and confirms - and with Him is Umm al-Kitab, the Mother of the Book. Tabrisi and Tabatabai describe two different books. One is the Mother of the Book, God's own knowledge. It never changes; nothing surprises Him. The other is the record that touches your life in time - how long you live, what reaches you, what is on its way toward you this year. That one is written with an “if” in it, and He erases and rewrites it in response to what you do. The Prophet's ﷺ household returned to this teaching again and again, because so much of how a believer lives rests on it. “Supplication turns back the affliction even after it has been decreed, when nothing remains but for it to be carried out,” said Imam al-Kazim (a) (al-Kafi). “Allah does not change what is in a people until they change what is in themselves” (13:11) - the same law, written across a whole nation. The tradition has a name for all of this: bada - that He really does still erase and confirm. Imam al-Sadiq (a) said: “Allah has not been magnified by anything like bada” (al-Kafi). If you have walked the Yunus descent, this is the verse that stood beneath its climax. A turning tonight is not commentary on a closed book. For your page, He is still writing."
            ),
            .climax(
                act: 3, tag: "The Witness", source: "al-Ra'd · 13 : 43",
                arabic: "وَيَقُولُ ٱلَّذِينَ كَفَرُوا۟ لَسْتَ مُرْسَلًۭا ۚ قُلْ كَفَىٰ بِٱللَّهِ شَهِيدًۢا بَيْنِى وَبَيْنَكُمْ وَمَنْ عِندَهُۥ عِلْمُ ٱلْكِتَٰبِ",
                translation: "And those who disbelieve say: You are not a messenger. Say: Sufficient is Allah as witness between me and you - and whoever has knowledge of the Book.",
                body: "The surah's last verse. The deniers spend their final line on the bluntest dismissal they have left - you are not a messenger - and God gives His Prophet ﷺ one final word to carry: Say: sufficient is Allah as witness between me and you. Kafa - sufficient. That alone would have been enough. But the verse does not stop. After the witness of Allah - after that - it names a second: and whoever has knowledge of the Book. Listen to how precisely the Qur'an speaks. Sulayman (a) had a minister who brought the Queen of Sheba's throne across the world in the blink of an eye. Of him the Qur'an says he had “knowledge from the Book” (27:40) - a portion of it. One portion, and the earth folded under a throne. Here, there is no “from.” Knowledge of the Book. All of it. And who is that? Abu Sa'id al-Khudri asked the Prophet ﷺ this very question, about both verses. About the first, the Prophet ﷺ said: that was the successor of my brother Sulayman (a). And about this verse he said: “That is my brother - Ali ibn Abi Talib” (Ma'ani al-Akhbar). The surah has been holding this question open since its seventh verse: “You are only a warner - and for every people there is a guide.” When that verse came down, the Prophet ﷺ said - in a report carried by Shia and Sunni tradition alike: “I am the warner, and Ali is the guide after me. O Ali, by you those who are guided will be guided.” And under this last verse, Imam al-Baqir (a) said: “It is us who are meant - and Ali is the first of us, and the best of us after the Prophet ﷺ” (al-Kafi). When his companion Burayd asked him about the verse of the warner and the guide, he answered: “The Messenger of Allah ﷺ is the warner, and in every age there is one of us who guides people to what he brought - the guides after him are Ali, then the successors, one after another” (al-Kafi). So this is where the surah has been leading all along. They kept asking the sky for a wonder. The answer was standing beside the Prophet ﷺ the entire time - not a spectacle above their heads; a man on the earth, carrying the whole Book. The warner at the surah's door. The witness at its seal. And in every age after - never absent - a guide.",
                reflection: "Now the three answers close into one. The sky was already speaking - you needed ears, not thunder. The truth was already flowing - you needed a valley, not a flood. And the guide was already standing there - you needed to look beside the Prophet ﷺ, not above him. Nothing the askers demanded was refused. It had already been given - quietly, and in person. So the question this surah leaves with you was never whether God answers. It is whether you have been recognizing the answers that were never loud."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "Where has He already answered you quietly?",
                placeholder: "A person, a verse, a rescue, a rest you did not earn…",
                subline: "You came in carrying the oldest question: why no sign? You leave knowing what the surah did with it. The thunder was praise. The foam was loud, and it is gone; the water stayed. The decree still bends toward whoever turns. And the guide was never missing. Before you go, name one quiet answer in your own life that you had counted as no answer.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "الرَّعْد",
                essence: "The surah named for the loudest sound in the sky keeps its deepest verse for the quietest thing on earth: a heart at rest in the remembrance of God. The thunder was never the sign. It was the announcement that rain is coming.",
                line: "Imam al-Sadiq (a) taught three things about this surah. Whoever recites it often will never be struck by lightning. The believer who recites it enters Paradise without being called to account. And he will be given leave to intercede for his family and his brothers (Thawab al-A'mal). Read it now in its own words, all forty-three verses - and the next time the sky cracks open above you, you will know what it is saying."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Ra'd experience") {
    DeepDiveView(dive: .surahRad, onClose: {})
}
#endif
