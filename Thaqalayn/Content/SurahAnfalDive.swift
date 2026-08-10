//
//  SurahAnfalDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Anfal" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/anfal-script.md.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically from pull_arabic.py output,
//  never hand-typed, to survive the byte-for-byte check). No dua beat; ends on
//  .closing, which hands off to reading the full surah.
//
//  Spine: re-attribution. al-Anfal takes Islam's first great victory (Badr) and hands
//  it back to God cause by cause - the gains are not your reward (Movement I), the
//  courage and the very throw were not your doing (Movement II, climax 8:17), and even
//  the brotherhood was His gift (Movement III) - so the winners live loosely, unified,
//  and inclined to peace. A focused thematic slice of a 75-verse discourse, not full
//  coverage. Climax lands at the END of Movement II; Movement III is the denouement.
//
//  Sourcing is Shia and verified: al-Mizan (Tabatabai), Majma al-Bayan (Tabrisi), and
//  Ahl al-Bayt narrations - Imam al-Sadiq on aslihu dhata baynikum (8:1); Imam al-Baqir
//  on dhi al-qurba = the descendants of Fatima (8:41) and ma yuhyikum = the wilaya
//  (8:24, Tafsir al-Ayyashi); Imam Ali on the night before Badr and acting while
//  witnessing God as the doer (8:9, 8:17, Nahj al-Balagha). The handful-of-dust throw
//  is the sira / Majma al-Bayan account (the throw is in 8:17; the miraculous reach is
//  the traditional narration). Honorifics on the Prophet Muhammad ﷺ and the Imams (a).
//

import SwiftUI

extension DeepDive {
    static let surahAnfal: DeepDive = DeepDive(
        id: "surah-anfal",
        titleEn: "al-Anfal",
        titleAr: "الْأَنْفَال",
        subtitle: "The Spoils of War - the day a victory was handed back to God",
        sfSymbol: "hand.raised.fill",
        estMinutes: 12,
        acts: [
            ActInfo(number: 1, ar: "الْأَنْفَال", tr: "al-Anfal", name: "The Gains"),
            ActInfo(number: 2, ar: "يَوْمُ الْفُرْقَان", tr: "Yawm al-Furqan", name: "The Day of Distinction"),
            ActInfo(number: 3, ar: "مَا يُحْيِيكُمْ", tr: "Ma Yuhyikum", name: "What Gives You Life"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "الْأَنْفَال",
                titleEn: "al-Anfal",
                subtitle: "The Spoils of War",
                line: "Three hundred and thirteen men, lightly armed, stood in the valley of Badr against an army nearly a thousand strong. Before the day was out the impossible had happened - the small band had won, and the young faith had survived its first battle. And the first thing some of the victors did was argue over who had earned the spoils. The surah that came down in answer carries their name. Come and see what God says to a people the morning after they win."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "The surah takes its name from al-anfal, the spoils of war - but its real subject is much larger than loot. It is the victory itself, and one startling claim about it: that it was never yours. This surah lifts the win off human shoulders cause by cause - the gains, the courage, even the hand that threw the decisive blow - and hands it back to the One it belonged to all along.",
                leaveWith: "You will leave having watched the proudest thing a person can hold - a battle won against all odds - being handed back to God, piece by piece. And you will know how a people who understand that are asked to live: loosely attached to what they gain, unbroken in their unity, and quick to answer an offer of peace."
            ),

            // ── Movement I · al-Anfal (The Gains) ─────────────────────────────
            .act(
                act: 1, connector: nil,
                line: "A miracle had just occurred, and the talk turned to loot. It is a very human thing - the danger passes, and the heart reaches for what it can hold. God does not rebuke the impulse. He does something quieter and deeper: He takes the spoils out of their hands entirely, and with that begins to teach them who had really won the day.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "Whose Are the Spoils", surah: 8, ayah: 1,
                arabic: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ يَسْـَٔلُونَكَ عَنِ ٱلْأَنفَالِ ۖ قُلِ ٱلْأَنفَالُ لِلَّهِ وَٱلرَّسُولِ ۖ فَٱتَّقُوا۟ ٱللَّهَ وَأَصْلِحُوا۟ ذَاتَ بَيْنِكُمْ ۖ وَأَطِيعُوا۟ ٱللَّهَ وَرَسُولَهُۥٓ إِن كُنتُم مُّؤْمِنِينَ",
                translation: "They ask you about the spoils. Say, “The spoils belong to Allah and the Messenger.” So fear Allah, and set right what is between you, and obey Allah and His Messenger, if you are believers.",
                reference: "al-Anfal · 8 : 1",
                reflection: "The word God chooses is not ghanaim - the ordinary word for battle booty - but anfal. It means a gift: something given over and above, freely, not as a wage owed. Al-Mizan catches the whole lesson in that one word: the spoils were never a wage the fighters had earned; they were a gift, and a gift belongs to the Giver to place where He wills. So He places them - they belong to God and the Messenger. Then look at what He asks for before a single thing is divided: not a fair split, but fear of God, and “set right what is between you.” Imam al-Sadiq (a) taught that mending the discord between believers comes before the property, because a bond broken over money is the real loss, not the money. The first thing the victory is asked to produce is not wealth. It is a mended community."
            ),
            .verse(
                act: 1, tag: "Who Really Wins", surah: 8, ayah: 2,
                arabic: "إِنَّمَا ٱلْمُؤْمِنُونَ ٱلَّذِينَ إِذَا ذُكِرَ ٱللَّهُ وَجِلَتْ قُلُوبُهُمْ وَإِذَا تُلِيَتْ عَلَيْهِمْ ءَايَٰتُهُۥ زَادَتْهُمْ إِيمَٰنًۭا وَعَلَىٰ رَبِّهِمْ يَتَوَكَّلُونَ",
                translation: "The believers are only those whose hearts tremble when Allah is mentioned, and when His verses are recited to them, they grow in faith, and upon their Lord they rely.",
                reference: "al-Anfal · 8 : 2",
                reflection: "Right after the spoils, the surah stops to say who these victors actually are - and it names nothing you would expect of soldiers. Not their courage, not their strength, not their skill with a sword. It names a heart that trembles at the mention of God, a faith that grows every time His words are heard, and a trust that leans on the Lord instead of the self. Tabrisi reads the three as a rising order: first the heart stirs, then the mind's conviction deepens, then the whole self hands itself over in reliance. The men who won at Badr did not win because they were strong. They won because they were the kind of people who lean on God - and the next movement will show you exactly what that leaning called down."
            ),
            .verse(
                act: 1, tag: "The Sacred Fifth", surah: 8, ayah: 41,
                arabic: "۞ وَٱعْلَمُوٓا۟ أَنَّمَا غَنِمْتُم مِّن شَىْءٍۢ فَأَنَّ لِلَّهِ خُمُسَهُۥ وَلِلرَّسُولِ وَلِذِى ٱلْقُرْبَىٰ وَٱلْيَتَٰمَىٰ وَٱلْمَسَٰكِينِ وَٱبْنِ ٱلسَّبِيلِ إِن كُنتُمْ ءَامَنتُم بِٱللَّهِ وَمَآ أَنزَلْنَا عَلَىٰ عَبْدِنَا يَوْمَ ٱلْفُرْقَانِ يَوْمَ ٱلْتَقَى ٱلْجَمْعَانِ ۗ وَٱللَّهُ عَلَىٰ كُلِّ شَىْءٍۢ قَدِيرٌ",
                translation: "And know that whatever you gain, a fifth of it belongs to Allah, and to the Messenger, and to the near of kin, and the orphans, and the needy, and the traveler - if you have believed in Allah and in what We sent down upon Our servant on the Day of Distinction, the day the two armies met. And Allah is Powerful over all things.",
                reference: "al-Anfal · 8 : 41",
                reflection: "The opening said the spoils are God's. Now the surah says exactly how He gives them back: keep four parts, and set one fifth aside - for God, for the Messenger, for the near of kin, and for the orphan, the needy, and the stranded traveler. This is khums. And the phrase carrying the most weight is “the near of kin,” dhi al-qurba. Imam al-Baqir and Imam al-Sadiq (a) taught that these are the household of the Prophet ﷺ, the descendants of Fatima (a). By God's own command, a portion of every gain is reserved for the family He purified. Even here, in a plain ruling about property, the surah is quietly pointing at them. And notice what it calls the day of the battle - yawm al-furqan, the Day of Distinction, the day truth was finally told apart from falsehood. The spoils were never the point of Badr. The sorting of true from false was."
            ),

            // ── Movement II · Yawm al-Furqan (The Day of Distinction) ─────────
            .act(
                act: 2,
                connector: "You have seen the gains lifted out of human hands, and the winners named not for their strength but for their trembling hearts.",
                line: "So how did a few frightened, outnumbered people win at all? The surah takes you back to the night before the battle, and the morning of it, and answers with something no army ever plans for.",
                bridge: BridgeVerse(
                    surah: 8, ayah: 26,
                    arabic: "وَٱذْكُرُوٓا۟ إِذْ أَنتُمْ قَلِيلٌۭ مُّسْتَضْعَفُونَ فِى ٱلْأَرْضِ تَخَافُونَ أَن يَتَخَطَّفَكُمُ ٱلنَّاسُ فَـَٔاوَىٰكُمْ وَأَيَّدَكُم بِنَصْرِهِۦ وَرَزَقَكُم مِّنَ ٱلطَّيِّبَٰتِ لَعَلَّكُمْ تَشْكُرُونَ",
                    translation: "And remember when you were few, deemed weak in the land, fearing that people would snatch you away - and He sheltered you, and strengthened you with His help, and provided you with good things, that you might be grateful.",
                    reference: "al-Anfal · 8 : 26"
                )
            ),
            .verse(
                act: 2, tag: "You Cried Out", surah: 8, ayah: 9,
                arabic: "إِذْ تَسْتَغِيثُونَ رَبَّكُمْ فَٱسْتَجَابَ لَكُمْ أَنِّى مُمِدُّكُم بِأَلْفٍۢ مِّنَ ٱلْمَلَٰٓئِكَةِ مُرْدِفِينَ",
                translation: "When you cried to your Lord for help, and He answered you, “I am reinforcing you with a thousand angels, following one after another.”",
                reference: "al-Anfal · 8 : 9",
                reflection: "Before the fighting there was only fear, and a cry. The word for it, tastaghithun, is not calm prayer - it is the scream of someone drowning, the plea you make when no one on earth can save you. And it was the Prophet ﷺ whose cry rose above them all. Imam Ali (a), who was there, remembered the night before Badr: the Prophet ﷺ standing through the dark in prayer, his hands raised, weeping, begging God for the help He had promised. And this came from the one man most certain that God would keep His word - because a plea like that is not doubt. It is the purest form of trust: everything depends on Him, and I know it. Then the answer came - a thousand angels, rank behind rank. You cried; He answered. The victory had already begun, and not one sword had yet been raised."
            ),
            .verse(
                act: 2, tag: "The Gift of Calm", surah: 8, ayah: 11,
                arabic: "إِذْ يُغَشِّيكُمُ ٱلنُّعَاسَ أَمَنَةًۭ مِّنْهُ وَيُنَزِّلُ عَلَيْكُم مِّنَ ٱلسَّمَآءِ مَآءًۭ لِّيُطَهِّرَكُم بِهِۦ وَيُذْهِبَ عَنكُمْ رِجْزَ ٱلشَّيْطَٰنِ وَلِيَرْبِطَ عَلَىٰ قُلُوبِكُمْ وَيُثَبِّتَ بِهِ ٱلْأَقْدَامَ",
                translation: "When He covered you with sleep as a security from Him, and sent down upon you rain from the sky, to purify you by it, and to remove from you the evil of Satan, and to fasten your hearts, and to make your feet firm.",
                reference: "al-Anfal · 8 : 11",
                reflection: "Think what should have happened the night before a battle you expect to lose: no one sleeps. Yet God laid a strange calm over the camp, a drowsiness the verse calls “a security from Him,” and they slept. Then, before dawn, rain - and Tabrisi records everything it did at once. It gave them water to wash and pray with. It settled the loose sand under the Muslims' feet so they would not slip, and turned the enemy's slope to mud. And it lifted the night's fear, the whisper that they were walking into their deaths. Even the steadiness they carried into that morning was not courage they had summoned. It was a calm sent down on them while they slept. Their feet were made firm before they ever took a step."
            ),
            .narration(
                act: 2, tag: "The Handful of Dust",
                source: "The Battle of Badr · Majma al-Bayan (Tabrisi) and the sira",
                body: "When the two lines finally faced each other, the Prophet ﷺ bent and took a handful of dust from the floor of the valley. He cast it toward the massed ranks of the Quraysh and said, “May the faces be disfigured.” The traditions say the throw carried impossibly far - that the dust reached the eyes and face of every man in the enemy army. A single handful of dirt, thrown by one man, finding a thousand soldiers at once.",
                reflection: "On its own it is almost nothing: a handful of dust against an army, the last gesture of a man with no weapon left. That is exactly why the surah chose it. Keep your eyes on that small, poor gesture. In a moment the Qur'an will lift it up and show you it was carrying something no handful of dust could ever carry on its own."
            ),
            .climax(
                act: 2, tag: "You Did Not Throw", source: "al-Anfal · 8 : 17",
                arabic: "فَلَمْ تَقْتُلُوهُمْ وَلَٰكِنَّ ٱللَّهَ قَتَلَهُمْ ۚ وَمَا رَمَيْتَ إِذْ رَمَيْتَ وَلَٰكِنَّ ٱللَّهَ رَمَىٰ ۚ وَلِيُبْلِىَ ٱلْمُؤْمِنِينَ مِنْهُ بَلَآءً حَسَنًا ۚ إِنَّ ٱللَّهَ سَمِيعٌ عَلِيمٌۭ",
                translation: "So you did not kill them, but Allah killed them. And you did not throw when you threw, but Allah threw. And that He might test the believers with a good test from Himself. Indeed, Allah is Hearing, Knowing.",
                body: "Here is the whole surah, gathered into a single line. You did not throw when you threw, but Allah threw. Read it slowly, because at first it seems to contradict itself. It does not deny that the Prophet ﷺ threw - “when you threw” says plainly that he did. It denies that the throw was his own doing. The hand was human; the power that carried it was God's. And what is said of that handful of dust is said of the entire battle in the same breath: you did not kill them, but Allah killed them. Every blow that landed, every enemy that fell - the effort was truly yours, and the outcome was entirely His. Al-Mizan calls this the meeting point of two truths people usually tear apart: that your actions are genuinely your own - the choice is yours, and so is the responsibility - and yet the power behind them, and the outcome they reach, are God's, not your own. You were not bystanders at Badr. You fought with everything you had. And still, not one thing that happened was yours.",
                reflection: "This is why the surah began by taking the spoils out of their hands. If the throw was not yours, the victory was not yours, and the reward that came with it was never a wage you had earned. Imam Ali (a) fought at the front of that battle and struck down its champions. He is remembered for fighting with his whole strength while knowing, the whole time, that the strength was on loan. And that is the freedom hidden in this verse: when the outcome was never yours to carry, you are free to pour yourself out completely, and leave the result to the only One who was ever going to decide it."
            ),

            // ── Movement III · Ma Yuhyikum (What Gives You Life) ──────────────
            .act(
                act: 3,
                connector: "You have watched the whole victory handed back to God - the spoils, the calm, the courage, and the very hand that struck the blow.",
                line: "So this is the question the last stretch of the surah keeps returning to: if the win was never yours, how do you carry it? A people who know their strength is on loan do not live like conquerors. They live a particular way - and the surah names it, one command at a time.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "What Gives You Life", surah: 8, ayah: 24,
                arabic: "يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱسْتَجِيبُوا۟ لِلَّهِ وَلِلرَّسُولِ إِذَا دَعَاكُمْ لِمَا يُحْيِيكُمْ ۖ وَٱعْلَمُوٓا۟ أَنَّ ٱللَّهَ يَحُولُ بَيْنَ ٱلْمَرْءِ وَقَلْبِهِۦ وَأَنَّهُۥٓ إِلَيْهِ تُحْشَرُونَ",
                translation: "O you who believe, respond to Allah and to the Messenger when He calls you to that which gives you life. And know that Allah comes between a person and his heart, and that to Him you will be gathered.",
                reference: "al-Anfal · 8 : 24",
                reflection: "The first command to the victors is not about the enemy at all. It is about coming alive. Respond when He calls you to what gives you life - as though, until you answer, you are not yet fully living. Al-Mizan explains that the life meant here is not the beating of a heart; it is the life of the soul, the difference between a person awake to God and one who is merely breathing. And the Ahl al-Bayt named where that call leads. Imam al-Baqir (a) taught that the wilaya is among the things “that give you life” - love of, and loyalty to, the household of the Prophet ﷺ, the guides God appointed to keep the way open. Then comes the reason to answer now, not later: Allah comes between a person and his heart. The heart you keep meaning to change may not always stay yours to change. Respond while the door is still open."
            ),
            .verse(
                act: 3, tag: "Or Your Strength Departs", surah: 8, ayah: 46,
                arabic: "وَأَطِيعُوا۟ ٱللَّهَ وَرَسُولَهُۥ وَلَا تَنَٰزَعُوا۟ فَتَفْشَلُوا۟ وَتَذْهَبَ رِيحُكُمْ ۖ وَٱصْبِرُوٓا۟ ۚ إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ",
                translation: "And obey Allah and His Messenger, and do not dispute with one another, lest you lose heart and your strength depart. And be patient. Indeed, Allah is with the patient.",
                reference: "al-Anfal · 8 : 46",
                reflection: "Remember how the surah opened: a quarrel over the spoils, and God's first instruction was “set right what is between you.” Now He says why disunity is so dangerous. Do not dispute, or you will lose heart and your strength will depart. The word for strength is rih - literally your wind, the wind in your sails. Argue among yourselves, the verse warns, and the wind simply dies; the force that was carrying you is gone. And here is its sharp edge: that force was never your own muscle in the first place. It was the help of God, given to a people who stood together. Divide, and you do not merely weaken yourselves - you send away the very thing that won Badr. Then one last word: be patient. Unity is not a mood that comes over you; it is something you take hold of, on purpose, in the moment every instinct says to break."
            ),
            .verse(
                act: 3, tag: "Incline to Peace", surah: 8, ayah: 61,
                arabic: "۞ وَإِن جَنَحُوا۟ لِلسَّلْمِ فَٱجْنَحْ لَهَا وَتَوَكَّلْ عَلَى ٱللَّهِ ۚ إِنَّهُۥ هُوَ ٱلسَّمِيعُ ٱلْعَلِيمُ",
                translation: "And if they incline to peace, then incline to it, and rely upon Allah. Indeed, He is the Hearing, the Knowing.",
                reference: "al-Anfal · 8 : 61",
                reflection: "You might expect a battle surah to end by glorifying the fight. It does the opposite. A few verses earlier, God tells the believers to prepare their full strength, to be ready, to let no weakness invite an attack. And then this: the moment the enemy leans toward peace, lean toward it too. Strength and peace are not opposites here - you build the one so that you are free to choose the other. Imam Ali (a) taught that the truly strong person is the one who can make peace, not the one who must always fight. And the verse leaves you a companion for the risk it is asking of you: rely upon Allah. Peace is a gamble, because the other side may be lying. Make it anyway, the verse says - and put the outcome where you have just learned it always was, in His hands."
            ),
            .verse(
                act: 3, tag: "What Money Could Not Buy", surah: 8, ayah: 63,
                arabic: "وَأَلَّفَ بَيْنَ قُلُوبِهِمْ ۚ لَوْ أَنفَقْتَ مَا فِى ٱلْأَرْضِ جَمِيعًۭا مَّآ أَلَّفْتَ بَيْنَ قُلُوبِهِمْ وَلَٰكِنَّ ٱللَّهَ أَلَّفَ بَيْنَهُمْ ۚ إِنَّهُۥ عَزِيزٌ حَكِيمٌۭ",
                translation: "And He brought their hearts together. Had you spent all that is on the earth, you could not have brought their hearts together, but Allah brought them together. Indeed, He is Mighty, Wise.",
                reference: "al-Anfal · 8 : 63",
                reflection: "This is the last thing the surah lifts out of human hands, and it may be the most surprising. The army that won at Badr was built from the Aws and the Khazraj - two tribes of Medina who had spent generations killing each other, blood feud upon blood feud. Islam did not merely stop the fighting. It made them brothers, sharing homes and wealth. And God says it plainly: you could not have done this. Had you spent every coin on earth, you could not have bought your way to it, because love between old enemies is not for sale. Money can buy an alliance; it cannot soften a heart. Only God does that. So the unity you were commanded to protect earlier turns out to be a gift you had already been given. Even the brotherhood was His."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "What are you calling your own?",
                placeholder: "A success, a talent, a victory, a thing you are proud of…",
                subline: "The whole surah has done one thing: taken a victory apart to show that the gains, the courage, the decisive blow, even the bond between the fighters - none of it was theirs. Before you go, name the thing in your own life you are quietly proud of, the win you have been carrying as yours. Then try setting it down where Badr says it always belonged.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "الْأَنْفَال",
                essence: "The surah is named for the spoils - the one thing in the whole story that turned out not to matter. And it ends somewhere else entirely: on the believers who left everything to follow the truth, and the ones who took them in, “allies of one another.” That bond was what the victory was really for. Not the loot. The brotherhood it built.",
                line: "You have followed the spine of al-Anfal - the gains, the day of distinction, and the life it asks of you. Now read the whole surah in its own words, and watch a battle turn, verse by verse, into a lesson about whose hands you were in the entire time."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Anfal experience") {
    DeepDiveView(dive: .surahAnfal, onClose: {})
}
#endif
