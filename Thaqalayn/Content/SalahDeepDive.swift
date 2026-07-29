//
//  SalahDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Salah" deep dive - the first ASCENDING dive: a climb
//  through the tradition's three names for the prayer (al-Mi'raj / al-Munajat /
//  al-Qurban), summiting at the Zuhr prayer of Ashura. Rendered by DeepDiveView;
//  see docs/plans/2026-07-28-salah-deep-dive-design.md.
//
//  Identity beats: the engine's journey verbs invert (Ascend / Begin the ascent /
//  The ascent ends), the `response` page answers the reader's own Fatiha (Uyun
//  Akhbar al-Rida), and the interactive `sujud` close was added for this dive.
//

import SwiftUI

extension DeepDive {
    static let salah: DeepDive = DeepDive(
        id: "salah",
        titleEn: "Salah",
        titleAr: "صَلَاة",
        subtitle: "Prayer - an ascent through three names",
        sfSymbol: "stairs",
        estMinutes: 5,
        stageNoun: "Name",
        descendCta: "Ascend",
        beginCta: "Begin the ascent",
        mapLine: "The map for everything above.",
        stageWord: "Name",
        endLine: "The ascent ends.",
        scrollHint: "Scroll to climb higher",
        scrollHintIcon: "arrow.up",
        acts: [
            ActInfo(number: 1, ar: "المِعْرَاج", tr: "al-Mi'raj", name: "The Ascent"),
            ActInfo(number: 2, ar: "المُنَاجَاة", tr: "al-Munajat", name: "The Conversation"),
            ActInfo(number: 3, ar: "القُرْبَان", tr: "al-Qurban", name: "The Offering"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "صَلَاة",
                titleEn: "Salah",
                subtitle: "Prayer",
                line: "An ascent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - where the prayer was given, what it truly is, and what it is worth."
            ),

            // 02. Before you climb - how this works + the promise
            .orientation(
                eyebrow: "Before you climb",
                promise: "The tradition gave the prayer three names - the ascent, the conversation, the offering. The climb ahead passes through all three.",
                leaveWith: "You'll leave seeing the five prayers differently - and with a gift from the Prophet's ﷺ family to carry into every one."
            ),

            // 03. Threshold - The Three Names (overview map, before the climb)
            .depths(
                act: 0,
                tag: "The Three Names",
                reference: "al-Faqih · Uyun al-Rida · Nahj al-Balagha",
                items: [
                    Depth(
                        ar: "المِعْرَاج",
                        tr: "al-Mi'raj",
                        label: "The Ascent",
                        desc: "Given above the seven heavens, on the night the Prophet ﷺ rose past them - and carried down for you.",
                        reference: nil,
                        embodies: "the Prophet ﷺ who carried it down"
                    ),
                    Depth(
                        ar: "المُنَاجَاة",
                        tr: "al-Munajat",
                        label: "The Conversation",
                        desc: "To stand and speak - and be spoken back to.",
                        reference: nil,
                        embodies: "the servant who is answered"
                    ),
                    Depth(
                        ar: "القُرْبَان",
                        tr: "al-Qurban",
                        label: "The Offering",
                        desc: "An offering to draw near to Him - guarded, whatever it costs.",
                        reference: nil,
                        embodies: "the family who paid its price"
                    ),
                ]
            ),

            // 04. Name I - The Ascent (movement card)
            .act(
                act: 1,
                connector: nil,
                line: "It begins at the top. Every revelation came down to the Prophet ﷺ - once, he went up. What he carried back down from that night above the heavens was this - and the name held: the tradition still calls the prayer the believer's ascent.",
                bridge: nil
            ),

            // 05. Name I - The Night of Fifty (the Mi'raj origin)
            .narration(
                act: 1,
                tag: "The Night of Fifty",
                source: "Imam Ali ibn al-Husayn · Man la yahduruh al-Faqih",
                body: "On the night the Prophet ﷺ was taken up through the heavens, fifty prayers were written upon his people. He would not ask his Lord for less - it was Musa, whom he had passed among the heavens, who pressed him to go back and ask that the number be lightened. And when fifty had become five, the word came down: “They are five, worth fifty. The word is not changed with Me.”",
                reflection: "This is its birth: not a burden imposed, but a mercy pleaded down - with the full reward left attached. Five, carrying fifty. The prayer arrived as a gift twice over."
            ),

            // 06. Name I - What It Is For (Ta-Ha 20:14)
            .verse(
                act: 1,
                tag: "What It Is For",
                surah: 20,
                ayah: 14,
                arabic: "إِنَّنِي أَنَا اللَّهُ لَا إِلَٰهَ إِلَّا أَنَا فَاعْبُدْنِي وَأَقِمِ الصَّلَاةَ لِذِكْرِي",
                translation: "Indeed I - I am God; there is no god but Me. So worship Me, and establish the prayer for My remembrance.",
                reference: "Ta-Ha · 20 : 14",
                reflection: "Musa, alone in the sacred valley, called by a Voice out of a fire. The command that follows “I am God” is worship - and the one act it names is the prayer. For My remembrance: not because He forgets you, but because you forget Him. Five times a day, the forgetting is interrupted."
            ),

            // 07. Name II - opening card (thread: GIVEN -> STAND INSIDE IT)
            .act(
                act: 2,
                connector: "You have seen where it was given.",
                line: "Now - stand inside it. The second name means the intimate conversation. You thought you were reciting into silence - the tradition says the one who prays is conversing with his Lord. And He answers back.",
                bridge: nil
            ),

            // 08. Name II - Before Whom You Stand (Imam Zayn al-Abidin)
            .narration(
                act: 2,
                tag: "Before Whom You Stand",
                source: "Imam Ali ibn al-Husayn · al-Irshad of al-Mufid",
                body: "When Imam Ali ibn al-Husayn, the fourth Imam, made the ablution before prayer, his face would turn pale. His family asked: what is this that comes over you? He said: “Do you know before Whom I am preparing to stand?”",
                reflection: "He was not afraid of the prayer - he was awake to it. The words are the same ones you say. The difference is that he knew Who was listening."
            ),

            // 09. Name II - He Answers (the divided Fatiha, Uyun Akhbar al-Rida)
            .response(
                act: 2,
                replyingTo: "To the servant who stands and says: All praise belongs to God, Lord of the worlds",
                arabic: "حَمِدَنِي عَبْدِي",
                words: "“I have divided the Opening of the Book between Me and My servant - half is Mine, half is his, and his is what he asks. When he begins with My name: it is binding on Me to complete his affairs. When he praises Me: My servant has praised Me.”",
                source: "The hadith qudsi of the Fatiha · Uyun Akhbar al-Rida of al-Saduq",
                reflection: "The Opening of the Book - the Fatiha you recite in every prayer - was never a monologue. You spoke one half; He answered the other, line for line, even the ones you rushed half-asleep. You have never once prayed unanswered."
            ),

            // 10. Name II - The Nearest Point (al-Alaq 96:19, excerpt)
            .verse(
                act: 2,
                tag: "The Nearest Point",
                surah: 96,
                ayah: 19,
                arabic: "وَاسْجُدْ وَاقْتَرِبْ",
                translation: "Prostrate - and draw near.",
                reference: "al-Alaq · 96 : 19",
                reflection: "Imam al-Rida said: a servant is never nearer to God than in prostration - and he named this verse as the proof. The ladder runs inverted: its highest rung is the floor. The world calls it lowering yourself. The prayer calls it arriving."
            ),

            // 11. Name III - opening card with bridge verse (thread: ANSWERED -> THE COST)
            .act(
                act: 3,
                connector: "You have heard Him answer - and felt how near He lets you come.",
                line: "Now - the costly name. The prayer, said Imam Ali, is the offering of every God-conscious soul. An offering is weighed by what it costs the one who brings it.",
                bridge: BridgeVerse(
                    surah: 2,
                    ayah: 238,
                    arabic: "حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ",
                    translation: "Guard the prayers - and the middle prayer - and stand before God devoutly.",
                    reference: "al-Baqarah · 2 : 238"
                )
            ),

            // 12. Name III - What Ibrahim Paid (Ibrahim 14:37, excerpt)
            .verse(
                act: 3,
                tag: "What Ibrahim Paid",
                surah: 14,
                ayah: 37,
                arabic: "رَبَّنَا إِنِّي أَسْكَنتُ مِن ذُرِّيَّتِي بِوَادٍ غَيْرِ ذِي زَرْعٍ عِندَ بَيْتِكَ الْمُحَرَّمِ رَبَّنَا لِيُقِيمُوا الصَّلَاةَ",
                translation: "Our Lord, I have settled some of my descendants in a valley without cultivation, by Your sacred House - our Lord, that they may establish the prayer.",
                reference: "Ibrahim · 14 : 37",
                reflection: "A wife and an infant, left in a dead valley - and the reason he gives God is the prayer. Makkah, the House, the direction you face five times a day: a city exists because one man thought the prayer worth that much."
            ),

            // 13. Name III - The Last Sentence (Imam al-Sadiq's deathbed)
            .narration(
                act: 3,
                tag: "The Last Sentence",
                source: "Imam Ja'far al-Sadiq, in his final moments · al-Amali of al-Saduq",
                body: "In his final moments, Imam Ja'far al-Sadiq, the sixth Imam, opened his eyes and said: gather to me every relative of mine. When they had assembled, he looked at them and said: “Our intercession will not reach one who takes the prayer lightly.”",
                reflection: "A man spends his last sentence on the heaviest thing he knows. Intercession - the Imams' pleading before God for their own - was the inheritance of that room; and he tied it to the prayer, held at its full weight."
            ),

            // 14. Name III - The Prayer Under Arrows (Zuhr of Ashura)
            .climax(
                act: 3,
                tag: "The Prayer Under Arrows",
                source: "Imam al-Husayn to Abu Thumama, noon of Ashura · Tarikh al-Tabari · al-Luhuf of Ibn Tawus",
                arabic: "ذَكَرْتَ الصَّلَاةَ، جَعَلَكَ اللَّهُ مِنَ الْمُصَلِّينَ الذَّاكِرِينَ",
                translation: "“You remembered the prayer - may God place you among the praying, the remembering.”",
                body: "Noon on Ashura - the tenth of Muharram, on the plain of Karbala. Most of Imam Husayn's men already lie dead when Abu Thumama, one of his last companions, notices the sun at its height: I would love to meet my Lord having prayed this one last prayer. They ask for the fighting to pause while they pray; it does not pause. So the prayer is prayed under the arrows. Sa'id ibn Abdullah stands in front of the Imam, taking them with his own body, and falls at last with thirteen arrows in him: O God - convey my greeting to Your Prophet, and tell him what I met of the pain of these wounds.",
                reflection: "God's own law would have excused a delay - a battlefield is reason enough. But the third name is the offering, and they held it up on time, at the price of a man. On that plain, nobody thought the prayer was a ritual. It was the thing being defended."
            ),

            // 15. The Last Rung (interactive sujud close)
            .sujud(
                tag: "The Last Rung",
                prompt: "Go down - and draw near.",
                subline: "Press and hold - and let the stillness stand in for the sajdah, the prostration.",
                arabic: "وَاسْجُدْ وَاقْتَرِبْ",
                translation: "Prostrate - and draw near.",
                reference: "al-Alaq · 96 : 19",
                note: "The nearest point is yours five times a day. What they guarded under arrows asks of you only a floor, a forehead, and the willingness to arrive.",
                nextLabel: "And one gift"
            ),

            // 16. The Close - the Tasbih of Fatima
            .dua(
                tag: "The Gift After Every Prayer",
                intro: "After the summit - one gift to carry home. When the hand-mill had blistered the hands of Fatima, the Prophet's ﷺ daughter, her husband Imam Ali sent her to ask her father for a servant. Instead of a servant, her father came to them himself: shall I not teach you both something better?",
                arabic: "اللَّهُ أَكْبَرُ، وَالْحَمْدُ لِلَّهِ، وَسُبْحَانَ اللَّهِ",
                translation: "“God is greater - thirty-four times. All praise belongs to God - thirty-three. Glory be to God - thirty-three.”",
                source: "The Prophet's ﷺ gift to Fatima al-Zahra · Man la yahduruh al-Faqih",
                note: "Say it after every prayer, before you rise from your place. Imam al-Sadiq called it dearer than a thousand rak'ahs - a thousand cycles of prayer - each day, and said that whoever keeps it is forgiven. One hundred small words, the whole ascent walked again. Begin tonight.",
                close: "The prayer is yours to keep."
            ),
        ]
    )
}
