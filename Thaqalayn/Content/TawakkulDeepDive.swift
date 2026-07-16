//
//  TawakkulDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Tawakkul" deep dive - a descent through three motions of
//  the trusting hand (al-'Azm / al-Tafwid / al-Kifaya), summiting at the morning of
//  Ashura. Rendered by DeepDiveView; see docs/plans/2026-07-16-tawakkul-deep-dive-design.md.
//
//  Identity beats: the `response` page (God's revelation to Dawud - first theme dive
//  to use it) and the interactive `release` close, added for this dive.
//

import SwiftUI

extension DeepDive {
    static let tawakkul: DeepDive = DeepDive(
        id: "tawakkul",
        titleEn: "Tawakkul",
        titleAr: "تَوَكُّل",
        subtitle: "Reliance - a descent through three motions",
        sfSymbol: "hands.and.sparkles",
        estMinutes: 5,
        acts: [
            ActInfo(number: 1, ar: "العَزْم", tr: "al-'Azm", name: "The Doing"),
            ActInfo(number: 2, ar: "التَّفْوِيض", tr: "al-Tafwid", name: "The Handing Over"),
            ActInfo(number: 3, ar: "الكِفَايَة", tr: "al-Kifaya", name: "The Sufficiency"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "تَوَكُّل",
                titleEn: "Tawakkul",
                subtitle: "Reliance",
                line: "A descent through the Qur’an and the Ahl al-Bayt - what the hands must do, and what they must let go."
            ),

            // 02. Before you descend - how this works + the promise
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three motions of reliance lie below - to do your part, to hand the outcome over, and to be carried.",
                leaveWith: "You’ll leave with a map of reliance - and a prayer that hands your affair to the One who holds it."
            ),

            // 03. Threshold - The Three Motions (overview map, before the descent)
            .depths(
                act: 0,
                tag: "The Three Motions",
                reference: "Al Imran 3:159 · al-Talaq 65:3",
                items: [
                    Depth(
                        ar: "العَزْم",
                        tr: "al-'Azm",
                        label: "The Doing",
                        desc: "To rise and take the means - resolve, work, tie the camel.",
                        reference: nil,
                        embodies: "the hand that works"
                    ),
                    Depth(
                        ar: "التَّفْوِيض",
                        tr: "al-Tafwid",
                        label: "The Handing Over",
                        desc: "When the means end, to place the outcome in His hands - and keep walking.",
                        reference: "40:44",
                        embodies: "the hand that releases"
                    ),
                    Depth(
                        ar: "الكِفَايَة",
                        tr: "al-Kifaya",
                        label: "The Sufficiency",
                        desc: "To be carried by the One you trusted - whose answer is Himself.",
                        reference: "65:3",
                        embodies: "the family who was carried"
                    ),
                ]
            ),

            // 04. Movement I - The Doing (movement card)
            .act(
                act: 1,
                connector: nil,
                line: "It begins in the hands. Tawakkul is not the folding of arms - it is the work done fully, then signed over to the One who holds the result.",
                bridge: nil
            ),

            // 05. Movement I - Resolve, Then Rely (Al Imran 3:159)
            .verse(
                act: 1,
                tag: "Resolve, Then Rely",
                surah: 3,
                ayah: 159,
                arabic: "فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ ۚ إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ",
                translation: "“And when you have resolved, rely upon God. Indeed God loves those who rely.”",
                reference: "Al Imran · 3 : 159",
                reflection: "The order of the verse is the whole teaching. Consult them, the Prophet is told; then resolve; then rely. Trust is what the resolved hand does with the outcome - not what the idle hand does instead of the work."
            ),

            // 06. Movement I - The Unanswered Prayer (Imam al-Sadiq)
            .narration(
                act: 1,
                tag: "The Unanswered Prayer",
                source: "Imam Ja'far al-Sadiq · al-Kafi, on seeking livelihood",
                body: "Four there are, said the Imam, whose prayer returns to them unanswered. One is the man who sits at home and says, “O Lord, provide for me” - and is told: have I not commanded you to seek?",
                reflection: "Tawakkul that skips the work is not trust - it is a request that God do your part, when He has already asked it of you."
            ),

            // 07. Movement II - opening card (thread: DO -> HAND OVER)
            .act(
                act: 2,
                connector: "You have done what is yours.",
                line: "Now - the harder motion. Open the hand. Trust is proven not while the means still work, but at the moment they end: the sea in front, the army behind.",
                bridge: nil
            ),

            // 08. Movement II - The Sea in Front (al-Shu'ara 26:62, Musa)
            .verse(
                act: 2,
                tag: "The Sea in Front",
                surah: 26,
                ayah: 62,
                arabic: "قَالَ كَلَّا ۖ إِنَّ مَعِيَ رَبِّي سَيَهْدِينِ",
                translation: "“He said: Never - indeed my Lord is with me; He will guide me.”",
                reference: "al-Shu'ara · 26 : 62",
                reflection: "Pharaoh’s army behind, the water ahead. “We are overtaken!” cry his people. The sea has not yet split when Musa answers - trust speaks before the way appears."
            ),

            // 09. Movement II - The Entrusted Affair (Ghafir 40:44, the believer of Pharaoh's house)
            .verse(
                act: 2,
                tag: "The Entrusted Affair",
                surah: 40,
                ayah: 44,
                arabic: "وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ ۚ إِنَّ اللَّهَ بَصِيرٌ بِالْعِبَادِ",
                translation: "“And I entrust my affair to God. Indeed God is ever seeing of His servants.”",
                reference: "Ghafir · 40 : 44",
                reflection: "A lone believer in Pharaoh’s court, his warning finished, hands the consequence over. The very next verse answers him: so God protected him from the evils they plotted."
            ),

            // 10. Movement III - opening card with bridge verse (thread: HAND OVER -> BE CARRIED)
            .act(
                act: 3,
                connector: "You have opened the hand.",
                line: "Now - what receives it. On the other side of the release is not a void but a Trustee - and His promise is not always the outcome you asked for. It is Himself.",
                bridge: BridgeVerse(
                    surah: 65,
                    ayah: 3,
                    arabic: "وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ",
                    translation: "And whoever relies upon God - He is sufficient for him.",
                    reference: "al-Talaq · 65 : 3"
                )
            ),

            // 11. Movement III - He Answers (revelation to Dawud, al-Kafi)
            .response(
                act: 3,
                replyingTo: "To the one who lets go of every rope but His",
                arabic: "جَعَلْتُ لَهُ الْمَخْرَجَ مِنْ بَيْنِهِنَّ",
                words: "“No servant of Mine takes refuge in Me rather than in My creation - I know it from his intention - but that if the heavens and the earth and all within them plotted against him, I would make for him a way out from among them all.”",
                source: "His revelation to Dawud · al-Kafi",
                reflection: "Not that the plot stops - but that the way out is His to make. And the hand that grips creation instead finds the ropes of the heavens cut."
            ),

            // 12. Movement III - The Verse He Answered With (al-A'raf 7:196, morning of Ashura)
            .verse(
                act: 3,
                tag: "The Verse He Answered With",
                surah: 7,
                ayah: 196,
                arabic: "إِنَّ وَلِيِّيَ اللَّهُ الَّذِي نَزَّلَ الْكِتَابَ ۖ وَهُوَ يَتَوَلَّى الصَّالِحِينَ",
                translation: "“Indeed my Protector is God, who sent down the Book - and He takes care of the righteous.”",
                reference: "al-A'raf · 7 : 196",
                reflection: "Dawn at Karbala. The army is arrayed, and the histories record Husayn ending his address to it with this verse. He does not count their swords - he names his Protector."
            ),

            // 13. Movement III - The Trust in Every Distress (Imam al-Husayn)
            .climax(
                act: 3,
                tag: "The Trust in Every Distress",
                source: "Imam al-Husayn, the morning of Ashura - al-Irshad of al-Mufid",
                arabic: "اللَّهُمَّ أَنْتَ ثِقَتِي فِي كُلِّ كَرْبٍ، وَرَجَائِي فِي كُلِّ شِدَّةٍ",
                translation: "“O God, You are my trust in every distress, and my hope in every hardship.”",
                body: "As the army closed in, he raised his hands - not for rescue, but to name the One who held him: You are, in everything that befalls me, my confidence and my strength.",
                reflection: "No sea split that morning; no fire cooled. And the trust did not break - because it had never been placed in the outcome. It was placed in Him."
            ),

            // 14. The Close - the release (interactive entrusting)
            .release(
                tag: "The Release",
                prompt: "What are you gripping?",
                subline: "A decision, a diagnosis, a debt, a child. Name it in your heart - you have carried it long enough.",
                arabic: "أُفَوِّضُ أَمْرِي إِلَى اللَّهِ",
                translation: "I entrust my affair to God.",
                reference: "Ghafir · 40 : 44",
                note: "It is in His hands now - the hands that do not drop what they hold.",
                nextLabel: "And one prayer"
            ),

            // 15. The Close - a prayer of fleeing to Him (Imam al-Sajjad)
            .dua(
                tag: "A Prayer of Fleeing to Him",
                intro: "After the sea, after Karbala - one prayer, in the voice of the fourth Imam: the whole descent in two lines.",
                arabic: "اللَّهُمَّ إِنِّي أَخْلَصْتُ بِانْقِطَاعِي إِلَيْكَ، وَأَقْبَلْتُ بِكُلِّي عَلَيْكَ",
                translation: "“My God, I have cut myself off from all but You, and turned toward You with the whole of myself.”",
                source: "Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Dua 28",
                note: "The great entrustings are not asked of you this morning. Only this: one grip loosened, one affair signed over to the One who does not drop what He holds.",
                close: "The trust is yours to keep."
            ),
        ]
    )
}
