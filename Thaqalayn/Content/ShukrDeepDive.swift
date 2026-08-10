//
//  ShukrDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Shukr" deep dive - a descent through the three tongues
//  of thanks (al-Qalb / al-Lisan / al-Jawarih). Rendered by DeepDiveView; see
//  docs/plans/2026-07-17-shukr-deep-dive-design.md.
//

import SwiftUI

extension DeepDive {
    static let shukr: DeepDive = DeepDive(
        id: "shukr",
        titleEn: "Shukr",
        titleAr: "شُكْر",
        subtitle: "Gratitude - a descent through three tongues",
        sfSymbol: "hands.clap",
        estMinutes: 5,
        stageNoun: "Tongue",
        acts: [
            ActInfo(number: 1, ar: "القَلْب", tr: "al-Qalb", name: "The Recognizing"),
            ActInfo(number: 2, ar: "اللِّسَان", tr: "al-Lisan", name: "The Saying"),
            ActInfo(number: 3, ar: "الجَوَارِح", tr: "al-Jawarih", name: "The Doing"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "شُكْر",
                titleEn: "Shukr",
                subtitle: "Gratitude",
                line: "A descent through the Qur'an and the Ahl al-Bayt - what the heart must see, what the tongue must say, what the body must answer."
            ),

            // 02. Before you descend
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three tongues of thanks lie below - the heart that recognizes, the tongue that praises, and the limbs that answer.",
                leaveWith: "You'll leave with a map of gratitude - and a prayer that hands the rest back to Him."
            ),

            // 03. Threshold - The Three Tongues
            .depths(
                act: 0,
                tag: "The Three Tongues",
                reference: "al-Kafi · Saba 34:13",
                items: [
                    Depth(
                        ar: "القَلْب",
                        tr: "al-Qalb",
                        label: "The Recognizing",
                        desc: "To see the gift as gift - and the Giver behind it. Thanks begins before a word is said.",
                        reference: nil,
                        embodies: "the heart that sees the Giver"
                    ),
                    Depth(
                        ar: "اللِّسَان",
                        tr: "al-Lisan",
                        label: "The Saying",
                        desc: "To speak the praise aloud - and tell of the blessing.",
                        reference: "93:11",
                        embodies: "the tongue that praises"
                    ),
                    Depth(
                        ar: "الجَوَارِح",
                        tr: "al-Jawarih",
                        label: "The Doing",
                        desc: "To answer the gift with the body - to stand, to serve, to give.",
                        reference: "34:13",
                        embodies: "the family who answered with everything"
                    ),
                ]
            ),

            // 04. Movement I - The Recognizing
            .act(
                act: 1,
                connector: nil,
                line: "It begins behind the ribs. Before gratitude has words, it is a kind of seeing - the gift caught in the act of arriving, and the Giver's hand still on it.",
                bridge: nil
            ),

            // 05. Movement I - The First Gifts (al-Nahl 16:78)
            .verse(
                act: 1,
                tag: "The First Gifts",
                surah: 16,
                ayah: 78,
                arabic: "وَاللَّهُ أَخْرَجَكُم مِّن بُطُونِ أُمَّهَاتِكُمْ لَا تَعْلَمُونَ شَيْئًا وَجَعَلَ لَكُمُ السَّمْعَ وَالْأَبْصَارَ وَالْأَفْئِدَةَ لَعَلَّكُمْ تَشْكُرُونَ",
                translation: "And God brought you out of your mothers' wombs knowing nothing - and He made for you hearing, and sight, and hearts, that you might give thanks.",
                reference: "al-Nahl · 16 : 78",
                reflection: "You arrived owning nothing - not even the knowing. Hearing, sight, a heart: the verse lists the first gifts, then names what they were for. Gratitude is not an ornament on the equipment. It is what the equipment was issued for."
            ),

            // 06. Movement I - The Thanks of the Heart (al-Kafi)
            .narration(
                act: 1,
                tag: "The Thanks of the Heart",
                source: "Imam Ja'far al-Sadiq · al-Kafi, the book of thanks",
                body: "When God grants a servant a blessing, said the Imam, and he recognizes it with his heart - he has already given its thanks.",
                reflection: "Thanks is born before a word is spoken - in the heart, where the gift is seen and the Giver named. Born, not finished - two tongues remain."
            ),

            // 07. Movement II - The Saying
            .act(
                act: 2,
                connector: "You have seen the Giver.",
                line: "Now - say it. What the heart knows in silence, the tongue brings into the open: the blessing told, the Giver named aloud.",
                bridge: nil
            ),

            // 08. Movement II - The Covenant of Increase (Ibrahim 14:7)
            .verse(
                act: 2,
                tag: "The Covenant of Increase",
                surah: 14,
                ayah: 7,
                arabic: "وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
                translation: "And when your Lord proclaimed: If you give thanks, I will surely increase you.",
                reference: "Ibrahim · 14 : 7",
                reflection: "Proclaimed - not whispered. Thanks is the one debt that grows by being paid: thank Him, and He gives you more to thank for. And the increase is not always more of the gift. Sometimes it is more of the seeing."
            ),

            // 09. Movement II - Tell of It (al-Duha 93:11)
            .verse(
                act: 2,
                tag: "Tell of It",
                surah: 93,
                ayah: 11,
                arabic: "وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ",
                translation: "And as for the blessing of your Lord - tell of it.",
                reference: "al-Duha · 93 : 11",
                reflection: "Four words, spoken first to the Prophet - an orphan who had just been given everything. Gratitude has a voice - not the boast that forgets the Giver, but the telling that names Him: this came from my Lord."
            ),

            // 10. Movement II - He Answers (Musa, al-Kafi)
            .response(
                act: 2,
                replyingTo: "To Musa, who asked: how shall I thank You, when even my thanks is itself Your gift?",
                arabic: "الْآنَ شَكَرْتَنِي حِينَ عَلِمْتَ أَنَّ ذَلِكَ مِنِّي",
                words: "Now you have thanked Me - now that you know that even the thanks is from Me.",
                source: "His words to Musa · al-Kafi",
                reflection: "The ladder of thanks has no top rung - every thanks is another gift, owing another thanks. He does not ask you to reach the top. He asks you to know where the ladder stands."
            ),

            // 11. Movement III - The Doing + bridge 34:13
            .act(
                act: 3,
                connector: "You have said it.",
                line: "Now - past the saying. The command to the most gifted house on earth was not to say thanks but to work it. In the end, thanks is something the body does.",
                bridge: BridgeVerse(
                    surah: 34,
                    ayah: 13,
                    arabic: "اعْمَلُوا آلَ دَاوُودَ شُكْرًا وَقَلِيلٌ مِّنْ عِبَادِيَ الشَّكُورُ",
                    translation: "Work, O family of Dawud, in thanks - and few of My servants are deeply grateful.",
                    reference: "Saba · 34 : 13"
                )
            ),

            // 12. Movement III - The Grateful Servant (al-Kafi)
            .narration(
                act: 3,
                tag: "The Grateful Servant",
                source: "The Messenger of God ﷺ · narrated from Imam al-Baqir, al-Kafi",
                body: "The Prophet ﷺ stood in the night prayer on the tips of his toes, until standing itself was a labor. He was asked: but you are already forgiven - everything past, everything to come - why this? He said: “Shall I not be a grateful servant?”",
                reflection: "Forgiveness did not retire his worship - it changed what the worship was. No longer a plea; a thank-you. The most truthful tongue on earth was not enough for him. He thanked with his feet."
            ),

            // 13. Movement III - The Thanks That Returns (al-Insan 76:22)
            .verse(
                act: 3,
                tag: "The Thanks That Returns",
                surah: 76,
                ayah: 22,
                arabic: "إِنَّ هَٰذَا كَانَ لَكُمْ جَزَاءً وَكَانَ سَعْيُكُم مَّشْكُورًا",
                translation: "Indeed this is a reward for you - and your striving has been thanked.",
                reference: "al-Insan · 76 : 22",
                reflection: "Spoken in the surah given to the Prophet's own house - the family who fed the hungry for three nights and asked nothing back. Read it slowly: God, who needs nothing, thanks. The thanks you send up does not vanish. It returns."
            ),

            // 14. Movement III - The Praise in the Dark (eve of Ashura)
            .climax(
                act: 3,
                tag: "The Praise in the Dark",
                source: "Imam al-Husayn, the eve of Ashura - al-Irshad of al-Mufid",
                arabic: "أُثْنِي عَلَى اللَّهِ أَحْسَنَ الثَّنَاءِ، وَأَحْمَدُهُ عَلَى السَّرَّاءِ وَالضَّرَّاءِ",
                translation: "“I praise God with the best of praise, and I thank Him in ease and in hardship.”",
                body: "The army is across the plain and the morning is known. He gathers his family and companions at nightfall - and opens with praise: for prophethood, for the Qur'an. For hearing, and sight, and hearts.",
                reflection: "Hearing, sight, hearts - the first gifts, where this descent began. He named them in thanks on the last night they would be his. Anyone can give thanks for the gift. He thanked the Giver while the gifts were being taken."
            ),

            // 15. The Count (new interactive beat)
            .count(
                tag: "The Count",
                prompt: "Count what He has given you.",
                subline: "He counted his blessings on the night they were being taken. Yours are still in your hands - this breath, your sight, a person who loves you. Tap: one blessing at a time.",
                arabic: "وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا",
                translation: "And if you count the blessings of God, you cannot number them.",
                reference: "al-Nahl · 16 : 18",
                note: "The count was never going to finish. It was only ever going to point - at the One whose giving outruns it.",
                nextLabel: "And one prayer"
            ),

            // 16. The Close - a prayer of the unfinished thanks (Sahifa 37)
            .dua(
                tag: "A Prayer of the Unfinished Thanks",
                intro: "After the heart, the tongue, the limbs - after Karbala - one prayer, in the voice of the fourth Imam: the confession that thanks never reaches its end.",
                arabic: "اللَّهُمَّ إِنَّ أَحَدًا لَا يَبْلُغُ مِنْ شُكْرِكَ غَايَةً إِلَّا حَصَلَ عَلَيْهِ مِنْ إِحْسَانِكَ مَا يُلْزِمُهُ شُكْرًا",
                translation: "“O God, no one ever reaches an end in thanking You - for with every thanks, more of Your goodness settles upon him, and binds him to thank You again.”",
                source: "Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Dua 37",
                note: "The full count is not asked of you tonight. Only this: one blessing seen, one alhamdulillah said aloud - and the rest left to the One who accepts the little and gives the much.",
                close: "The thanks is yours to keep."
            ),
        ]
    )
}
