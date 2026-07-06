//
//  YaqinDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Yaqīn" deep dive - a descent through the three depths
//  of certainty (ʿIlm / ʿAyn / Ḥaqq al-Yaqīn). Ported from MajlisYaqeen.jsx and
//  rendered by DeepDiveView.
//

import SwiftUI

extension DeepDive {
    static let yaqin: DeepDive = DeepDive(
        id: "yaqin",
        titleEn: "Yaqīn",
        titleAr: "يَقِين",
        subtitle: "Certainty - a descent through three depths",
        sfSymbol: "eye",
        estMinutes: 5,
        acts: [
            ActInfo(number: 1, ar: "عِلْمُ الْيَقِين", tr: "'Ilm al-Yaqīn", name: "The Knowing"),
            ActInfo(number: 2, ar: "عَيْنُ الْيَقِين", tr: "'Ayn al-Yaqīn", name: "The Witnessing"),
            ActInfo(number: 3, ar: "حَقُّ الْيَقِين", tr: "Ḥaqq al-Yaqīn", name: "The Living"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "يَقِين",
                titleEn: "Yaqīn",
                subtitle: "Certainty",
                line: "A descent through the Qur’an and the Ahl al-Bayt - in three depths."
            ),

            // 02. Before you descend - how this works + the promise
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three depths of certainty lie below - to know it, to see it, to live it.",
                leaveWith: "You'll leave with a map of certainty - and a prayer to deepen your own."
            ),

            // 03. Movement I - The Question (al-Takāthur 102:5)
            .verse(
                act: 1,
                tag: "The Question",
                surah: 102,
                ayah: 5,
                arabic: "كَلَّا لَوْ تَعْلَمُونَ عِلْمَ الْيَقِينِ",
                translation: "No - if only you knew with the knowledge of certainty…",
                reference: "al-Takāthur · 102 : 5",
                reflection: "Before certainty can be lived, it must be understood. The Qur’an says it arrives in depths - three of them."
            ),

            // 04. Movement I - The Three Depths
            .depths(
                act: 1,
                tag: "The Three Depths",
                reference: "al-Takāthur · al-Wāqiʿah",
                items: [
                    Depth(
                        ar: "عِلْمُ الْيَقِين",
                        tr: "‘Ilm al-Yaqīn",
                        label: "Knowledge of Certainty",
                        desc: "To know the fire exists - by the smoke on the horizon.",
                        reference: nil,
                        embodies: "where we begin"
                    ),
                    Depth(
                        ar: "عَيْنُ الْيَقِين",
                        tr: "‘Ayn al-Yaqīn",
                        label: "Eye of Certainty",
                        desc: "To see the fire with your own eyes.",
                        reference: "102:7",
                        embodies: "the prophets who saw"
                    ),
                    Depth(
                        ar: "حَقُّ الْيَقِين",
                        tr: "Ḥaqq al-Yaqīn",
                        label: "Truth of Certainty",
                        desc: "To stand within the flame itself.",
                        reference: "56:95",
                        embodies: "the family who lived it"
                    ),
                ]
            ),

            // 05. Movement II - opening card (thread: KNOW -> SEE)
            .act(
                act: 2,
                connector: "You have known it by proof.",
                line: "Now - see it. The Qur’an did not leave the prophets to merely believe; it let them witness, with their own eyes.",
                bridge: nil
            ),

            // 06. Movement II - Ibrahīm Asks to See (al-Baqarah 2:260)
            .verse(
                act: 2,
                tag: "Ibrahīm Asks to See",
                surah: 2,
                ayah: 260,
                arabic: "قَالَ أَوَلَمْ تُؤْمِن ۖ قَالَ بَلَىٰ وَلَٰكِن لِّيَطْمَئِنَّ قَلْبِي",
                translation: "“Do you not believe?” He said: “Yes - but so that my heart may be at rest.”",
                reference: "al-Baqarah · 2 : 260",
                reflection: "Even the Friend of God, who already believed, longed to witness. He is asking to move from the first depth to the second."
            ),

            // 07. Movement II - And Then He Sees (al-Anbiyāʾ 21:69)
            .verse(
                act: 2,
                tag: "And Then He Sees",
                surah: 21,
                ayah: 69,
                arabic: "قُلْنَا يَا نَارُ كُونِي بَرْدًا وَسَلَامًا عَلَىٰ إِبْرَاهِيمَ",
                translation: "We said: “O fire - be coolness and peace upon Ibrahīm.”",
                reference: "al-Anbiyāʾ · 21 : 69",
                reflection: "He had asked to witness. Now, cast into the flames, he does - and the fire itself submits to his certainty."
            ),

            // 08. Movement II - A Mother Acts On It (al-Qaṣaṣ 28:7)
            .verse(
                act: 2,
                tag: "A Mother Acts On It",
                surah: 28,
                ayah: 7,
                arabic: "فَإِذَا خِفْتِ عَلَيْهِ فَأَلْقِيهِ فِي الْيَمِّ وَلَا تَخَافِي",
                translation: "When you fear for him, cast him into the river - and do not fear.",
                reference: "al-Qaṣaṣ · 28 : 7",
                reflection: "To lay your child upon the water on nothing but God’s word - certainty is no longer a thought. It has become an act."
            ),

            // 09. Movement III - opening card with bridge verse (thread: SEE -> LIVE)
            .act(
                act: 3,
                connector: "You have seen it in the prophets.",
                line: "Now - live it. For most, certainty comes only at death. But one family was asked to stand inside the flame - while still alive.",
                bridge: BridgeVerse(
                    surah: 15,
                    ayah: 99,
                    arabic: "وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ",
                    translation: "And worship your Lord until certainty comes to you.",
                    reference: "al-Ḥijr · 15 : 99"
                )
            ),

            // 10. Movement III - The Morning of ʿĀshūrāʾ
            .narration(
                act: 3,
                tag: "The Morning of ʿĀshūrāʾ",
                source: "Radiance at Karbalāʾ - narrated of Hilāl ibn Nāfiʿ",
                body: "They said that as the arrows fell thicker upon them, the face of Ḥusayn only grew more luminous and calm - so much so that those who looked on were struck by its light.",
                reflection: "The closer the meeting with the Beloved, the brighter the certainty. This is no longer witnessing from the outside - it is standing within the very fire the depths spoke of."
            ),

            // 11. Movement III - The Court (Sayyida Zaynab)
            .climax(
                act: 3,
                tag: "The Court",
                source: "Sayyida Zaynab, in the court of Ibn Ziyād - Kufa",
                arabic: "مَا رَأَيْتُ إِلَّا جَمِيلًا",
                translation: "I saw nothing but beauty.",
                body: "After the sons. After the brothers. After the tents burned and the caravan was driven in chains - she stood in the court of the tyrant and said she had witnessed nothing but beauty.",
                reflection: "This is Ḥaqq al-Yaqīn - the truth of certainty. Not the absence of grief, but the certainty that sees the divine beauty through it."
            ),

            // 12. The Close - reflection prompt
            .reflectionPrompt(
                tag: "Return",
                prompt: "Where is your yaqīn?",
                placeholder: "Faith, a decision, a loss, the unseen ahead…"
            ),

            // 13. The Close - a prayer for certainty
            .dua(
                tag: "A Prayer for Certainty",
                intro: "After all of it - one prayer, from the family you just stood beside.",
                arabic: "وَبَلِّغْ بِإِيمَانِي أَكْمَلَ الْإِيمَانِ، وَاجْعَلْ يَقِينِي أَفْضَلَ الْيَقِينِ",
                translation: "“Bring my faith to the most perfect faith, and make my certainty the most excellent certainty.”",
                source: "Imam ʿAlī ibn al-Ḥusayn · al-Ṣaḥīfa al-Sajjādiyya",
                note: "The son of Ḥusayn - present at Karbalā, the one who lived to carry it. He witnessed certainty’s severest trial, and still asked God to deepen his own."
            ),
        ]
    )
}
