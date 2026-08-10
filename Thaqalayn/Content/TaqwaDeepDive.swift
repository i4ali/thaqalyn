//
//  TaqwaDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Taqwa" deep dive - The Three Walls: a descent through one guarding
//  awareness posted three times, each deeper in (al-Khawf / al-Wara' / al-Muraqaba), from the
//  root و-ق-ي (to place a guard between the soul and harm). Summit: al-Hurr al-Riyahi, the free
//  man of Karbala - taqwa as emancipation (Nahj al-Balagha, Sermon 230). Interactive close: the
//  new `door` beat "The Open Door", where the hand that does not move is the whole of it. Rendered
//  by DeepDiveView; see docs/plans/2026-08-07-taqwa-deep-dive-design.md.
//
//  English-first (bare LocalizedText string literals); UR/AR are a later pass.
//

import SwiftUI

extension DeepDive {
    static let taqwa: DeepDive = DeepDive(
        id: "taqwa",
        titleEn: "Taqwa",
        titleAr: "تَقْوَىٰ",
        subtitle: "God-consciousness - a descent through three guards",
        sfSymbol: "shield",
        estMinutes: 5,
        stageNoun: "Guard",
        stageWord: "Guard",
        acts: [
            ActInfo(number: 1, ar: "الخَوْف", tr: "al-Khawf", name: "The Fear"),
            ActInfo(number: 2, ar: "الوَرَع", tr: "al-Wara'", name: "The Scruple"),
            ActInfo(number: 3, ar: "المُرَاقَبَة", tr: "al-Muraqaba", name: "The Watch"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "تَقْوَىٰ",
                titleEn: "Taqwa",
                subtitle: "God-consciousness",
                line: "A descent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - following a single guarding awareness as it moves inward: from the hand, to the heart, to the depth where no fear is left but Him."
            ),

            // 02. Before you descend
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three guards lie below - one at the forbidden, one at the doubtful, and one that keeps the heart for Him alone.",
                leaveWith: "You'll leave with a map of taqwa - and a prayer for the nights the guard is hardest to keep."
            ),

            // 03. Threshold - The Three Guards
            .depths(
                act: 0,
                tag: "The Three Guards",
                reference: "al-Kafi · Al Imran 3:102",
                items: [
                    Depth(
                        ar: "الخَوْف",
                        tr: "al-Khawf",
                        label: "The Fear",
                        desc: "To guard the hand from the forbidden - because the Fire is real, and He is watching.",
                        reference: nil,
                        embodies: "the servant who dreads the Fire"
                    ),
                    Depth(
                        ar: "الوَرَع",
                        tr: "al-Wara'",
                        label: "The Scruple",
                        desc: "To draw back even from the doubtful - keeping a clear margin between yourself and the edge.",
                        reference: nil,
                        embodies: "the hand that lets the doubtful go"
                    ),
                    Depth(
                        ar: "المُرَاقَبَة",
                        tr: "al-Muraqaba",
                        label: "The Watch",
                        desc: "To keep the heart for Him alone - to fear Him as He deserves, until no smaller fear can command you.",
                        reference: "3:102",
                        embodies: "the servant who feared none but God"
                    ),
                ]
            ),

            // 04. Guard I - The Fear (movement card)
            .act(
                act: 1,
                connector: nil,
                line: "It begins at the edge of the forbidden. Taqwa's first work is a plain one, and the whole of it is a No: the hand stopped before the thing it wanted, because He sees, and the Fire is not a story told to children.",
                bridge: nil
            ),

            // 05. Guard I - Guard Yourselves (al-Tahrim 66:6)
            .verse(
                act: 1,
                tag: "Guard Yourselves",
                surah: 66,
                ayah: 6,
                arabic: "يَا أَيُّهَا الَّذِينَ آمَنُوا قُوا أَنفُسَكُمْ وَأَهْلِيكُمْ نَارًا",
                translation: "“O you who believe - guard yourselves and your families against a Fire.”",
                reference: "al-Tahrim · 66 : 6",
                reflection: "The command is the word itself: qu - guard, shield, put something between yourself and the Fire. Taqwa is not, first of all, a feeling. It is a wall you raise, one refusal at a time, around the soul you were lent and the people set in your care."
            ),

            // 06. Guard I - The Open Door (al-Kafi) - seeds the interactive close
            .narration(
                act: 1,
                tag: "The Open Door",
                source: "Imam Ja'far al-Sadiq · al-Kafi, the chapter of obedience and taqwa",
                body: "A little deed with taqwa, said Imam al-Sadiq, is worth more than many deeds without it. Picture two men. One keeps an open, generous house - yet when a door to the forbidden swings open before him, he walks through. The other has none of that giving - but when the same door opens, he will not step through it.",
                reflection: "The first man's good is real, and still it drains away: one unguarded door empties the house behind it. Taqwa is not the size of what you do. It is what you refuse to do when the door swings open and no one alive would know."
            ),

            // 07. Guard II - The Scruple (movement card)
            .act(
                act: 2,
                connector: "You have guarded against the forbidden.",
                line: "Now - guard the doubtful. The forbidden is marked, and refusing it is the easy half. The long work of taqwa is the grey edge: the thing that might be wrong, that you could explain away - and that you leave anyway, to keep clear air between yourself and the fall.",
                bridge: nil
            ),

            // 08. Guard II - Look to Tomorrow (al-Hashr 59:18)
            .verse(
                act: 2,
                tag: "Look to Tomorrow",
                surah: 59,
                ayah: 18,
                arabic: "يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَلْتَنظُرْ نَفْسٌ مَّا قَدَّمَتْ لِغَدٍ",
                translation: "“O you who believe - be mindful of God, and let every soul look to what it has sent ahead for tomorrow.”",
                reference: "al-Hashr · 59 : 18",
                reflection: "Every deed is already travelling ahead of you, to a tomorrow you will have to meet - so the doubtful ones are worth a second look before you send them on. The next verse names the opposite: those who forgot God, so He made them forget themselves."
            ),

            // 09. Guard II - The Hardest Worship (al-Kafi)
            .narration(
                act: 2,
                tag: "The Hardest Worship",
                source: "Imam al-Baqir and Imam al-Sadiq · al-Kafi, the chapter of scrupulousness",
                body: "Shield your religion with wara' - scrupulous restraint - said Imam al-Sadiq. And Imam al-Baqir said: the most strenuous worship of all is wara'.",
                reflection: "The worship others can see is the standing in prayer, the fasting, the giving. Wara' is the worship no one sees: the deal declined, the word swallowed, the glance turned away. It guards not the deed but the doer - and the tradition calls it the hardest worship there is."
            ),

            // 10. Guard III - The Watch (movement card) + bridge Al Imran 3:102
            .act(
                act: 3,
                connector: "You have guarded against the doubtful.",
                line: "Now - the innermost guard. Two walls stand: the forbidden refused, the doubtful released. Yet a heart can keep both and still be crowded - with the self, with the fear of who is watching, with a hundred small fears. This last guard is not a cage. Imam Ali called taqwa emancipation from every bondage: fear God as He deserves, and no smaller fear can own you.",
                bridge: BridgeVerse(
                    surah: 3,
                    ayah: 102,
                    arabic: "اتَّقُوا اللَّهَ حَقَّ تُقَاتِهِ",
                    translation: "Be mindful of God as He truly deserves.",
                    reference: "Al Imran · 3 : 102"
                )
            ),

            // 11. Guard III - What Reaches Him (al-Hajj 22:37)
            .verse(
                act: 3,
                tag: "What Reaches Him",
                surah: 22,
                ayah: 37,
                arabic: "لَن يَنَالَ اللَّهَ لُحُومُهَا وَلَا دِمَاؤُهَا وَلَكِن يَنَالُهُ التَّقْوَى مِنكُمْ",
                translation: "“Neither their flesh nor their blood reaches God - but the taqwa from you, that reaches Him.”",
                reference: "al-Hajj · 22 : 37",
                reflection: "Said of the offerings of the pilgrimage: the meat feeds the poor, the blood soaks the sand - none of it climbs to God. Only the taqwa in the heart that gave them arrives. Strip away every outward act, and this is the one thing He receives: not what your hands did, but what you were guarding while they did it."
            ),

            // 12. Guard III - He Answers (hadith qudsi)
            .response(
                act: 3,
                replyingTo: "To the one who feared Him here, and wondered if the fear would ever lift",
                arabic: "وَعِزَّتِي وَجَلَالِي، لَا أَجْمَعُ عَلَى عَبْدِي خَوْفَيْنِ، وَلَا أَجْمَعُ لَهُ أَمْنَيْنِ، مَنْ خَافَنِي فِي الدُّنْيَا آمَنْتُهُ يَوْمَ الْقِيَامَةِ",
                words: "“By My might and My majesty - I will not join two fears upon My servant, nor two securities. Whoever feared Me in the world, I make him secure on the Day of Resurrection.”",
                source: "A hadith qudsi - the word of God · al-Jawahir al-Saniyya · Bihar al-Anwar",
                reflection: "The fear taqwa asks of you was never meant to last forever. It is a trade: carry it here, where it can still turn you back - and He carries you there, where fear can change nothing. The God-fearing turn out to be the least frightened of all, at the end."
            ),

            // 13. Guard III - The Free Man (climax / summit: al-Hurr)
            .climax(
                act: 3,
                tag: "The Free Man",
                source: "Al-Hurr ibn Yazid al-Riyahi, the morning of Ashura · al-Irshad of al-Mufid · Tarikh al-Tabari",
                arabic: "أُخَيِّرُ نَفْسِي بَيْنَ الْجَنَّةِ وَالنَّارِ، فَلَا أَخْتَارُ عَلَى الْجَنَّةِ شَيْئًا",
                translation: "“I am giving my own soul the choice - between the Garden and the Fire. And I will choose nothing over the Garden.”",
                body: "He came as the enemy's commander - a thousand horsemen at his back, sent to cut Imam Husayn off in the waterless plain of Karbala. When his own men rode up parched, it was Husayn who gave water to them and to their horses. On the morning of Ashura, the day of the battle, the ranks drawn, a shudder took him. Are you afraid? a man asked. No, he said - I am standing between Paradise and the Fire, and choosing. Then he turned his horse and crossed to Husayn's side.",
                reflection: "His name was al-Hurr - the free. He had served the tyrant out of fear of the tyrant; taqwa is the fear that ends every smaller fear, and it freed him with one hour left to spend. He was martyred that day for Husayn. The accounts of Karbala remember that Husayn knelt beside his body and called him by his name: You are free, as your mother named you - free in this world and the next."
            ),

            // 14. The Open Door (new interactive beat) - restraint; al-Nazi'at 79:40-41
            .door(
                tag: "The Open Door",
                prompt: "What keeps opening in front of you?",
                subline: "The thing you could reach, that no one would see you take. Here it comes - warm, easy, close. Taqwa is the hand that does not move. Let it pass.",
                arabic: "وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِ وَنَهَى النَّفْسَ عَنِ الْهَوَى فَإِنَّ الْجَنَّةَ هِيَ الْمَأْوَى",
                translation: "“But as for the one who feared the standing before his Lord, and held the soul back from its craving - the Garden, that is the refuge.”",
                reference: "al-Nazi'at · 79 : 40-41",
                note: "You did nothing - and the nothing was the whole of it. Every step before this asked you to act; this one asked you to hold still - like the man who would not step through the open door. That stillness, kept when no one is watching, is taqwa.",
                nextLabel: "And one prayer"
            ),

            // 15. The Close - A Prayer in Fear (al-Sahifa al-Sajjadiyya, Supplication 50)
            .dua(
                tag: "A Prayer in Fear",
                intro: "After the three guards, after the free man - one prayer, in the voice of the fourth Imam: his own supplication in fear, where the dread of being wholly seen turns, in the end, into the hope of being held.",
                arabic: "فَارْحَمْنِي يَا أَرْحَمَ الرَّاحِمِينَ، وَتَجَاوَزْ عَنِّي يَا ذَا الْجَلَالِ وَالْإِكْرَامِ، وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ",
                translation: "“So have mercy on me, O Most Merciful of the merciful. Pardon me, O Possessor of majesty and honour. And turn to me - You, You are the Ever-relenting, the Compassionate.”",
                source: "Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Supplication 50 (His Supplication in Fear)",
                note: "The whole guard, in the end, rests on one fact: you are seen. Let that be your fear tonight - and then your peace. The sight you could never escape is the same Mercy you were running toward.",
                close: "The guard is yours to keep."
            ),
        ]
    )
}
