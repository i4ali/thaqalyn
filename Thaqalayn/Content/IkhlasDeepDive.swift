//
//  IkhlasDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Ikhlas" deep dive - The Unmixing: a descent through the three
//  purities (al-Niyya / al-Tasfiya / al-Mukhlas), walking the root kh-l-s from the active
//  mukhlisin (98:5) through the passive mukhlasin (15:40). Summit: the three nights of
//  Surah al-Insan. Interactive close: the `extinguish` beat "The Last Light". Rendered by
//  DeepDiveView; see docs/plans/2026-07-29-ikhlas-deep-dive-design.md.
//

import SwiftUI

extension DeepDive {
    static let ikhlas: DeepDive = DeepDive(
        id: "ikhlas",
        titleEn: "Ikhlas",
        titleAr: "إِخْلَاص",
        subtitle: "Sincerity - a descent through three purities",
        sfSymbol: "drop.fill",
        estMinutes: 5,
        stageNoun: "Purity",
        stageWord: "Purity",
        acts: [
            ActInfo(number: 1, ar: "النِّيَّة", tr: "al-Niyya", name: "The Address"),
            ActInfo(number: 2, ar: "التَّصْفِيَة", tr: "al-Tasfiya", name: "The Straining"),
            ActInfo(number: 3, ar: "المُخْلَص", tr: "al-Mukhlas", name: "The Purified"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "إِخْلَاص",
                titleEn: "Ikhlas",
                subtitle: "Sincerity",
                line: "A descent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - tracing whom the deed is for, how it is guarded from other eyes, and whose hand finishes the purifying."
            ),

            // 02. Before you descend
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three purities lie below - the address every deed carries, the straining that keeps it clean, and the purity only He can finish.",
                leaveWith: "You'll leave with a map of sincerity - and a prayer that gathers all your scattered deeds into one."
            ),

            // 03. Threshold - The Three Purities
            .depths(
                act: 0,
                tag: "The Three Purities",
                reference: "al-Kafi · al-Hijr 15:40",
                items: [
                    Depth(
                        ar: "النِّيَّة",
                        tr: "al-Niyya",
                        label: "The Address",
                        desc: "Every deed travels to the one it was done for. Before the hands move, the heart has already addressed it.",
                        reference: nil,
                        embodies: "the heart that chooses its Witness"
                    ),
                    Depth(
                        ar: "التَّصْفِيَة",
                        tr: "al-Tasfiya",
                        label: "The Straining",
                        desc: "To keep the deed clean of every eye but His - even after it is done.",
                        reference: nil,
                        embodies: "the hand that hides its gift"
                    ),
                    Depth(
                        ar: "المُخْلَص",
                        tr: "al-Mukhlas",
                        label: "The Purified",
                        desc: "When the purifying passes out of your hands - and what He seals, no whisper can reach.",
                        reference: "15:40",
                        embodies: "the family He purified"
                    ),
                ]
            ),

            // 04. Purity I - The Address
            .act(
                act: 1,
                connector: nil,
                line: "It begins before the deed does. Two people kneel in the same row, give the same coin, say the same words - and the two deeds do not arrive at the same door. What separates them was settled earlier, in silence: whom it was for.",
                bridge: nil
            ),

            // 05. Purity I - The One Command (al-Bayyina 98:5)
            .verse(
                act: 1,
                tag: "The One Command",
                surah: 98,
                ayah: 5,
                arabic: "وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ",
                translation: "And they were not commanded except to worship God, making the religion pure for Him alone.",
                reference: "al-Bayyina · 98 : 5",
                reflection: "Not commanded except to worship - as if every command ever sent folds into this one. And the word is mukhlisin - the ones doing the purifying; its singular is mukhlis, the one who purifies. An active word: at this depth, the purifying is yours to do. Hold that word - before this descent reaches its floor, a single vowel of it will turn."
            ),

            // 06. Purity I - The Soul of the Deed (al-Kafi)
            .narration(
                act: 1,
                tag: "The Soul of the Deed",
                source: "The Messenger of God ﷺ · al-Kafi, the chapter of intention",
                body: "The intention of the believer, said the Prophet ﷺ, is better than his deed. And every doer acts upon his intention.",
                reflection: "Better than the deed - because the deed is only the body, and the intention is its soul. Imam al-Sadiq went further: the intention is the deed. The hands build the visible half; whom it was for is the half that decides."
            ),

            // 07. Purity II - The Straining
            .act(
                act: 2,
                connector: "You have addressed the deed.",
                line: "Now - guard it. The deed takes a moment; keeping it His is the long work. The wish to be seen does not come first - it comes after, quietly, for the deed you have already done.",
                bridge: nil
            ),

            // 08. Purity II - The Stone Left Bare (al-Baqarah 2:264)
            .verse(
                act: 2,
                tag: "The Stone Left Bare",
                surah: 2,
                ayah: 264,
                arabic: "فَمَثَلُهُ كَمَثَلِ صَفْوَانٍ عَلَيْهِ تُرَابٌ فَأَصَابَهُ وَابِلٌ فَتَرَكَهُ صَلْدًا",
                translation: "[The one who spends his wealth to be seen by people -] his likeness is a smooth stone with soil upon it: a downpour struck it, and left it bare.",
                reference: "al-Baqarah · 2 : 264",
                reflection: "The soil was real - the coin was given, the deed was done. But it lay on rock, not in ground. One hard rain, and nothing had ever taken root: a deed done for eyes has no earth under it."
            ),

            // 09. Purity II - The Ledger That Moves (al-Kafi)
            .narration(
                act: 2,
                tag: "The Ledger That Moves",
                source: "Imam Muhammad al-Baqir · al-Kafi, the chapter on riya",
                body: "Keeping the deed, said the Imam, is harder than the deed. He was asked: what is keeping the deed? He said: a man gives, spending for God alone, who has no partner, and it is recorded as a secret. Then he mentions it - and the secret is erased, rewritten as a deed done openly. He mentions it again - and that too is erased, rewritten as riya: a deed done to be seen.",
                reflection: "Nothing changed but the telling - and the telling moved the deed, ledger by ledger, from His eyes toward theirs. Some deeds stay pure the way secrets stay secrets: untold."
            ),

            // 10. Purity II - He Answers (hadith qudsi, al-Kafi)
            .response(
                act: 2,
                replyingTo: "To the one who worked for Him - and for other eyes too",
                arabic: "أَنَا خَيْرُ شَرِيكٍ",
                words: "I am the best of partners: whoever joins another with Me in a deed he does, I do not accept it - except what was purely Mine.",
                source: "His word, related by Imam Ja'far al-Sadiq · al-Kafi",
                reflection: "Every partner on earth quarrels over the shares. He does not - He withdraws. A deed with two addresses is not split with Him; He takes none of it, and leaves all of it to the other address. Only the undivided arrives."
            ),

            // 11. Purity III - The Purified + bridge al-Zumar 39:3
            .act(
                act: 3,
                connector: "You have strained what is yours to strain.",
                line: "Now - the turn. The first purity gave you mukhlis: the one who purifies. The Qur'an keeps a second word, one vowel away - mukhlas: the one who has been purified. From active to passive, on a single vowel - and no one can make himself into the second word. At this depth the purifying changes hands.",
                bridge: BridgeVerse(
                    surah: 39,
                    ayah: 3,
                    arabic: "أَلَا لِلَّهِ الدِّينُ الْخَالِصُ",
                    translation: "Truly - to God belongs the religion made pure.",
                    reference: "al-Zumar · 39 : 3"
                )
            ),

            // 12. Purity III - The Whisperer's Exception (al-Hijr 15:40)
            .verse(
                act: 3,
                tag: "The Whisperer's Exception",
                surah: 15,
                ayah: 40,
                arabic: "إِلَّا عِبَادَكَ مِنْهُمُ الْمُخْلَصِينَ",
                translation: "[Iblis swore: I will make evil fair to them on earth, and I will mislead them, all of them -] except, among them, Your servants - the purified.",
                reference: "al-Hijr · 15 : 40",
                reflection: "Iblis does not say: except the careful, or the strong-willed. He names the one place his feet cannot enter - the mukhlasin, the ones God has purified. The whisperer trades in audiences: be seen, be praised, be remembered. A heart emptied of every audience but One has walked out of his market."
            ),

            // 13. Purity III - The Forty Days (al-Kafi)
            .narration(
                act: 3,
                tag: "The Forty Days",
                source: "Imam Muhammad al-Baqir · al-Kafi, the chapter of ikhlas",
                body: "When a servant keeps his faith pure for God forty days, said the Imam, God turns his heart from the world - shows him the world's sickness and its cure - and sets wisdom firm in his heart, and lets his tongue speak it.",
                reflection: "The forty days are yours. Everything after them is His - the sight, the wisdom, the clean spring the words rise from. You bring the purifying you can manage; He answers with the purifying you cannot. Mukhlis is a labor. Mukhlas is a gift."
            ),

            // 14. Purity III - The Three Nights (al-Insan summit)
            .climax(
                act: 3,
                tag: "The Three Nights",
                source: "The household of the Prophet ﷺ · al-Insan 76:9 · Majma' al-Bayan · al-Amali of al-Saduq",
                arabic: "إِنَّمَا نُطْعِمُكُمْ لِوَجْهِ اللَّهِ لَا نُرِيدُ مِنكُمْ جَزَاءً وَلَا شُكُورًا",
                translation: "“We feed you only for the Face of God - we desire from you no repayment, and no thanks.”",
                body: "Hasan and Husayn lie ill, and the household vows three fasts for their healing - Ali, Fatima, and Fidda who serves them. The boys recover; the fasting begins.\n\nAli brings home three measures of barley, and Fatima grinds one each day and bakes it. At sunset a poor man calls at the door. The second sunset, an orphan. The third, a captive. Three nights the whole meal is given away at the door; three nights the family breaks its fast on water. On the fourth day Ali brings the boys to their grandfather - and the Prophet ﷺ sees the hunger in their faces, and weeps. Then the angel Jibril comes down with a surah.",
                reflection: "They refused even thanks from the ones they fed - and some early commentators say the family never spoke these words aloud at all: God knew what was in their hearts, and spoke it for them. The family kept the secret; He proclaimed it in a surah recited to the end of time. A deed so hidden, only He could tell the story."
            ),

            // 15. The Last Light (new interactive beat)
            .extinguish(
                tag: "The Last Light",
                prompt: "Who else were you doing it for?",
                subline: "The praiser, the critic, the rival - the audience you carry in your head. Small lights, each one an eye. Put them out, one by one.",
                arabic: "كُلُّ شَيْءٍ هَالِكٌ إِلَّا وَجْهَهُ",
                translation: "Everything perishes - except His Face.",
                reference: "al-Qasas · 28 : 88",
                note: "Every audience files out in the end. The gaze you could not put out was the first one on your deed - and the only one that keeps it.",
                nextLabel: "And one prayer"
            ),

            // 16. The Close - A Prayer of One Litany (Dua Kumayl)
            .dua(
                tag: "A Prayer of One Litany",
                intro: "After the stone, after the three nights - one prayer, in the voice of the first Imam, taught one night to Kumayl ibn Ziyad: that the scattered deeds become one.",
                arabic: "أَنْ تَجْعَلَ أَوْقَاتِي مِنَ اللَّيْلِ وَالنَّهَارِ بِذِكْرِكَ مَعْمُورَةً، وَبِخِدْمَتِكَ مَوْصُولَةً، وَأَعْمَالِي عِنْدَكَ مَقْبُولَةً، حَتَّىٰ تَكُونَ أَعْمَالِي وَأَوْرَادِي كُلُّهَا وِرْدًا وَاحِدًا، وَحَالِي فِي خِدْمَتِكَ سَرْمَدًا",
                translation: "“That You make my times, by night and by day, filled with Your remembrance, joined to Your service, my works accepted with You - until my works and my litanies become all one litany, and my state in Your service everlasting.”",
                source: "Imam Ali · Dua Kumayl - Misbah al-Mutahajjid of al-Tusi",
                note: "A whole lifetime, gathered to a single address. Begin smaller tonight: one deed with the door shut and no one told - aimed, start to finish, at the One who was watching before you began.",
                close: "The intention is yours to keep."
            ),
        ]
    )
}
