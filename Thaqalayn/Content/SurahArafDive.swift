//
//  SurahArafDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-A'raf" experience. Rendered by
//  DeepDiveView; see docs/plans/surah-experience/araf-script.md (approved master copy).
//
//  English-only for now: every LocalizedText is a bare string literal, so ur/ar are
//  nil and fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim from
//  quran_data.json (pulled with scripts/pull_arabic.py, then byte-synced from the data
//  file so it matches the mushaf bytes exactly - not NFC). No dua beat; ends on .closing,
//  which hands off to reading the full surah.
//
//  Spine: the Covenant of Alast (7:172) - the pledge every soul gave before birth, kept
//  or broken across the surah, with prostration as the body of the "yes" (Iblis refuses
//  it, the magicians fall into it, Bal'am bows to the earth, 7:206 closes on it).
//  Sourcing is Shia: al-Mizan (Tabatabai), Nahj al-Balagha (the Qasi'a sermon), and the
//  Ahl al-Bayt narrations on the men of the Heights and the covenant (al-Kafi /
//  Tafsir al-Qummi, cited in al-Mizan).
//

import SwiftUI

extension DeepDive {
    static let surahAraf: DeepDive = DeepDive(
        id: "surah-araf",
        titleEn: "al-A'raf",
        titleAr: "الْأَعْرَاف",
        subtitle: "The Heights - the one question the whole surah is asking",
        sfSymbol: "mountain.2",
        estMinutes: 13,
        acts: [
            ActInfo(number: 1, ar: "الْإِبَاء", tr: "al-Iba'", name: "The Refusal"),
            ActInfo(number: 2, ar: "التَّذْكِرَة", tr: "al-Tadhkira", name: "The Reminder"),
            ActInfo(number: 3, ar: "النِّسْيَان", tr: "al-Nisyan", name: "The Forgetting"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "الْأَعْرَاف",
                titleEn: "al-A'raf",
                subtitle: "The Heights",
                line: "Two hundred and six verses, the longest of the Meccan surahs. And of everything inside it, it is named after a wall - a wall set between the Garden and the Fire, with men on its heights who know, by sight alone, every soul that passes. This is a surah about being recognized. And underneath all of its stories runs a single question, one you have already answered."
            ),
            .orientation(
                eyebrow: "Before you descend",
                promise: "Below runs the widest sweep in the Qur'an: the first refusal in all of creation, messenger after messenger sent to peoples who would not listen, Musa against Pharaoh, a nation saved and a nation lost. It can read like a hundred separate stories. It is not. It is one story, told again and again - a promise made, and then either kept or broken.",
                leaveWith: "You will leave knowing the one question the whole surah is really asking - a question your soul was asked before you were born, and answered with a single word. And you will hear how everything else in these two hundred verses is only that word, said again, or taken back."
            ),
            .act(
                act: 1, connector: nil,
                line: "Before a single human being was ever tested, a test was already given - not to us, but to the ones made of fire and light. God gave one command, and every one of them bowed - except one. The first “no” ever spoken was not spoken by a man. And the one who spoke it did not leave quietly. He made a vow.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "I Am Better", surah: 7, ayah: 12,
                arabic: "قَالَ مَا مَنَعَكَ أَلَّا تَسْجُدَ إِذْ أَمَرْتُكَ ۖ قَالَ أَنَا۠ خَيْرٌۭ مِّنْهُ خَلَقْتَنِى مِن نَّارٍۢ وَخَلَقْتَهُۥ مِن طِينٍۢ",
                translation: "God said, “What prevented you from prostrating when I commanded you?” He said, “I am better than him. You created me from fire and created him from clay.”",
                reference: "al-A'raf · 7 : 12",
                reflection: "Notice what the refusal is made of. Not doubt, not weakness - pride. Iblis does not deny that God commanded him; he simply weighs himself against Adam (a) and decides he comes out higher. In the sermon known as al-Qasi'a, Imam Ali names this the first pride ever taken in what one is made of, and the Imams teach that Iblis was the first to reason his way around a clear command. Every “I am better than him” spoken since is an echo of this one: pride in blood, in wealth, in knowledge. He was asked only to bow. He chose to fall instead."
            ),
            .verse(
                act: 1, tag: "From Every Side", surah: 7, ayah: 17,
                arabic: "ثُمَّ لَءَاتِيَنَّهُم مِّنۢ بَيْنِ أَيْدِيهِمْ وَمِنْ خَلْفِهِمْ وَعَنْ أَيْمَٰنِهِمْ وَعَن شَمَآئِلِهِمْ ۖ وَلَا تَجِدُ أَكْثَرَهُمْ شَٰكِرِينَ",
                translation: "“Then I will come at them from before them and from behind them, and from their right and their left, and You will not find most of them grateful.”",
                reference: "al-A'raf · 7 : 17",
                reflection: "First he says, “I will sit in wait for them on Your straight path” (7:16) - not off the road, but on it, where the faithful are already walking. Then this: from all four sides at once. In one reading the commentators give, each direction is its own attack. From the front, he makes you love this world and dread death; from behind, he makes you forget your sins and put off repentance; from the right, he makes worship feel heavy; from the left, he makes sin look sweet. This is the enemy the rest of the surah is about, and he has one aim: to reach the promise buried inside you and work it loose."
            ),
            .verse(
                act: 1, tag: "He Sees You", surah: 7, ayah: 27,
                arabic: "يَٰبَنِىٓ ءَادَمَ لَا يَفْتِنَنَّكُمُ ٱلشَّيْطَٰنُ كَمَآ أَخْرَجَ أَبَوَيْكُم مِّنَ ٱلْجَنَّةِ يَنزِعُ عَنْهُمَا لِبَاسَهُمَا لِيُرِيَهُمَا سَوْءَٰتِهِمَآ ۗ إِنَّهُۥ يَرَىٰكُمْ هُوَ وَقَبِيلُهُۥ مِنْ حَيْثُ لَا تَرَوْنَهُمْ ۗ إِنَّا جَعَلْنَا ٱلشَّيَٰطِينَ أَوْلِيَآءَ لِلَّذِينَ لَا يُؤْمِنُونَ",
                translation: "O children of Adam, do not let Satan tempt you as he drove your parents out of the Garden, stripping from them their garment to show them their nakedness. He sees you, he and his tribe, from where you do not see them. We have made the devils allies of those who do not believe.",
                reference: "al-A'raf · 7 : 27",
                reflection: "Here the surah turns and looks straight at you. The one who refused to bow has done this before - his whispering stripped the first two human beings of their garment and drove them from the Garden itself. And the warning carries a chill: he watches you from where you cannot watch him. Just above this, God has called the finest clothing “the garment of God-consciousness” (7:26). So the real contest of the whole surah is named early and quietly: a hidden enemy who wants that garment off you, one thread at a time. Your part in the story has already begun."
            ),
            .act(
                act: 2,
                connector: "You have met the first refusal, and the enemy who swore to reach you from every side.",
                line: "So God did not leave the children of Adam to face him alone. He began to send reminders - a man from among each people, sent to a town that had forgotten, carrying one sentence. The same sentence, every time. Watch what the towns do with it.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Same Word", surah: 7, ayah: 59,
                arabic: "لَقَدْ أَرْسَلْنَا نُوحًا إِلَىٰ قَوْمِهِۦ فَقَالَ يَٰقَوْمِ ٱعْبُدُوا۟ ٱللَّهَ مَا لَكُم مِّنْ إِلَٰهٍ غَيْرُهُۥٓ إِنِّىٓ أَخَافُ عَلَيْكُمْ عَذَابَ يَوْمٍ عَظِيمٍۢ",
                translation: "We sent Noah to his people, and he said, “O my people, worship God; you have no god other than Him. Indeed, I fear for you the punishment of a tremendous Day.”",
                reference: "al-A'raf · 7 : 59",
                reflection: "“You have no god other than Him.” Read on in the surah and you will hear the very same words handed to the next messenger, and the next: Hud (a) says it to his people, Salih (a) says it to his, Shu'ayb (a) says it to his. One message, town after town, as though the Qur'an were holding a single sentence up to the light from every angle. And town after town calls its messenger a liar, and the flood, the wind, the earthquake come for them. In his commentary al-Mizan, Tabatabai notes this is the whole point of the repetition: the reminder never changes, only the answer does. Each people is simply being asked to keep the promise. Most will not."
            ),
            .verse(
                act: 2, tag: "They Fell Down", surah: 7, ayah: 120,
                arabic: "وَأُلْقِىَ ٱلسَّحَرَةُ سَٰجِدِينَ",
                translation: "And the magicians fell down in prostration.",
                reference: "al-A'raf · 7 : 120",
                reflection: "Then, in the middle of the surah's greatest confrontation, the pattern breaks. Pharaoh has gathered his finest magicians to humiliate Musa (a); they have already bargained for a reward and a place near the throne (7:113-114). They throw their ropes, Musa throws his staff, and in a single instant these men - who know exactly how their own illusions are made - see something that is no illusion. And mid-performance, the hired sorcerers fall into prostration: “We believe in the Lord of the worlds, the Lord of Musa and Harun” (7:121-122). Hold this against the surah's opening scene. There, one creature was ordered to prostrate and would not. Here, no one orders these men at all, and they cannot hold themselves back from it."
            ),
            .verse(
                act: 2, tag: "By Dusk", surah: 7, ayah: 126,
                arabic: "وَمَا تَنقِمُ مِنَّآ إِلَّآ أَنْ ءَامَنَّا بِـَٔايَٰتِ رَبِّنَا لَمَّا جَآءَتْنَا ۚ رَبَّنَآ أَفْرِغْ عَلَيْنَا صَبْرًۭا وَتَوَفَّنَا مُسْلِمِينَ",
                translation: "“You resent us only because we believed in the signs of our Lord when they came to us. Our Lord, pour patience upon us, and take us in death as those who have submitted.”",
                reference: "al-A'raf · 7 : 126",
                reflection: "Pharaoh's response is instant and monstrous: he will cut off their hands and feet on opposite sides and crucify them all (7:124). And these men, believers for the length of one afternoon, do not flinch. “To our Lord we are returning,” they tell him (7:125), and then they turn from Pharaoh to God and ask only for patience, and to be taken while still holding the promise. They had walked into that courtyard as paid magicians when the sun rose; before it set they were martyrs. This is the other answer a soul can give - not the town's slow “no,” but a whole life handed over in a single hour. The promise, kept at the highest price there is."
            ),
            .act(
                act: 3,
                connector: "You have heard the promise refused by whole cities, and kept by sorcerers in an afternoon.",
                line: "But there is a harder way to lose it than never listening. It is to be handed everything - the message, the miracle, the rescue, the knowledge - and to let it slip through your fingers anyway. The last descent is into the ones who should have kept the promise best of all, and did not.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "Under the Mountain", surah: 7, ayah: 171,
                arabic: "۞ وَإِذْ نَتَقْنَا ٱلْجَبَلَ فَوْقَهُمْ كَأَنَّهُۥ ظُلَّةٌۭ وَظَنُّوٓا۟ أَنَّهُۥ وَاقِعٌۢ بِهِمْ خُذُوا۟ مَآ ءَاتَيْنَٰكُم بِقُوَّةٍۢ وَٱذْكُرُوا۟ مَا فِيهِ لَعَلَّكُمْ تَتَّقُونَ",
                translation: "And when We raised the mountain above them as if it were a canopy, and they were certain it would fall upon them: “Take what We have given you with strength, and remember what is in it, that you may be mindful.”",
                reference: "al-A'raf · 7 : 171",
                reflection: "This is Bani Israel, the Children of Israel, just carried out of Pharaoh's reach through a parted sea. Now they stand under a whole mountain lifted over their heads, promising to hold fast to what God has given. You could not ask for a more vivid moment of “yes.” And yet, only a few verses earlier in the same surah, while Musa is away on the mountain, these same people melt their gold into a calf and bow to it (7:148). A promise made beneath a mountain, broken at its foot, before the man who carried it had even come back down. To be saved is not the same as to stay faithful. They had seen more than almost anyone alive. It was not enough."
            ),
            .verse(
                act: 3, tag: "The One Who Let Go", surah: 7, ayah: 175,
                arabic: "وَٱتْلُ عَلَيْهِمْ نَبَأَ ٱلَّذِىٓ ءَاتَيْنَٰهُ ءَايَٰتِنَا فَٱنسَلَخَ مِنْهَا فَأَتْبَعَهُ ٱلشَّيْطَٰنُ فَكَانَ مِنَ ٱلْغَاوِينَ",
                translation: "And recite to them the news of the one to whom We gave Our signs, but he stripped himself out of them; so Satan followed after him, and he became one of the lost.",
                reference: "al-A'raf · 7 : 175",
                reflection: "The surah tells of a man the tafsir names Bal'am ibn Ba'ura. God had given him real knowledge of His signs, and then he “stripped himself out of them” - the way you shrug off a coat. The verse's own word for it is insalakha. This was not a man who never knew; it was a man who knew, and let it go, for the favor of a ruler. The next verse turns the image terrible. Had God willed, He would have raised him high by that knowledge, but instead “he clung to the earth and followed his own desire,” until his likeness became “that of a dog: chase it, it pants; leave it, it pants” (7:176). That clinging has a name, akhlada ila al-ard: a bowing downward, toward the dust, instead of toward God. Iblis fell through pride; the towns through heedlessness; Bal'am fell with his eyes wide open, still holding the very thing that could have lifted him."
            ),
            .verse(
                act: 3, tag: "On the Heights", surah: 7, ayah: 46,
                arabic: "وَبَيْنَهُمَا حِجَابٌۭ ۚ وَعَلَى ٱلْأَعْرَافِ رِجَالٌۭ يَعْرِفُونَ كُلًّۢا بِسِيمَىٰهُمْ ۚ وَنَادَوْا۟ أَصْحَٰبَ ٱلْجَنَّةِ أَن سَلَٰمٌ عَلَيْكُمْ ۚ لَمْ يَدْخُلُوهَا وَهُمْ يَطْمَعُونَ",
                translation: "And between them is a partition, and on the Heights are men who know each one by his mark. And they call out to the companions of the Garden, “Peace be upon you” - who have not yet entered it, though they long to.",
                reference: "al-A'raf · 7 : 46",
                reflection: "Here, at last, is the wall the surah is named for - the place where all that falling and holding is finally seen. On one side the Garden, on the other the Fire, and between them a height, with men upon it who know every single soul on sight - not by name, but by a mark each person carries. They call peace down to the saved; they turn toward the lost and say, “what did all your gathering profit you?” (7:48). Who are these men, standing high enough to see both ends of everything at once? The narrations of the Prophet's ﷺ household give the answer: they are the Prophet ﷺ and the guides from his family, the ones by whom people are known and set apart, so that no one they do not recognize can cross over. Which leaves only the question the whole surah has been circling toward. What is the mark? By what, exactly, are you known?"
            ),
            .climax(
                act: 3, tag: "Am I Not Your Lord", source: "al-A'raf · 7 : 172",
                arabic: "وَإِذْ أَخَذَ رَبُّكَ مِنۢ بَنِىٓ ءَادَمَ مِن ظُهُورِهِمْ ذُرِّيَّتَهُمْ وَأَشْهَدَهُمْ عَلَىٰٓ أَنفُسِهِمْ أَلَسْتُ بِرَبِّكُمْ ۖ قَالُوا۟ بَلَىٰ ۛ شَهِدْنَآ ۛ أَن تَقُولُوا۟ يَوْمَ ٱلْقِيَٰمَةِ إِنَّا كُنَّا عَنْ هَٰذَا غَٰفِلِينَ",
                translation: "And when your Lord brought forth from the children of Adam, from their loins, their descendants, and made them bear witness over themselves: “Am I not your Lord?” They said, “Yes - we bear witness.” This, lest you should say on the Day of Resurrection, “We were unaware of this.”",
                body: "Now go all the way back, before every scene you have descended through. Before Bal'am, before the mountain, before the magicians, before the messengers - back before you had a body at all. The surah says your Lord gathered every soul that would ever live and asked each one a single question: Am I not your Lord? And every soul, yours among them, answered with one word - bala. Yes. This is the mark. This is the promise the whole surah has been watching people keep and break. The scholars call it the covenant of Alast, and al-Mizan says it is written into the deepest layer of who you are, which is why the messengers never bring anything foreign; they only wake a knowledge already in you. And notice why the pledge was taken at all: so that no one could ever stand on the Last Day and plead that they simply forgot. As for the household on the Heights - the narrations say the pledge that day was not to His lordship alone, but to the guidance He would send: His Prophet ﷺ and the guides who now stand on the wall and know you by whether you kept your word.",
                reflection: "So the surah was never a gallery of other people. Every one of them was answering a question you have also already answered: Iblis's “no,” the towns' “no,” the magicians' sudden “yes,” Bani Israel's broken “yes,” Bal'am's slow letting-go. You said yes once, before you can remember. The whole of your life is the second time you are asked."
            ),
            .reflectionPrompt(
                tag: "Return",
                prompt: "Where are you keeping your yes - and where is it slipping?",
                placeholder: "A prayer, a promise, a person, a habit you know is loosening the thread…",
                subline: "You have walked the whole descent - the first refusal, the reminder carried town to town, the promise kept in an afternoon and broken beneath a mountain, and the one question underneath all of it. You already said yes. Before you go, name the place in your life where you are still keeping it, and the place where it is quietly slipping away.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "الْأَعْرَاف",
                essence: "Every soul once answered “yes.” A whole life is the chance to answer it again - and the answer has a shape: to bow to God, and to nothing else.",
                line: "The surah ends where it began: at the choice to bow. Its very last words describe the ones nearest to God, the exact opposite of the one who would not bow: “they are not too proud to worship Him, and they exalt Him, and to Him they prostrate” (7:206). When the Qur'an is recited, the surah says, listen (7:204). So read al-A'raf now in its own words, and let it ask you its question again."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-A'raf experience") {
    DeepDiveView(dive: .surahAraf, onClose: {})
}
#endif
