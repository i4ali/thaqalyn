//
//  SurahIbrahimDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - Ibrahim" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/ibrahim-script.md.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically via pull_arabic.py, never
//  hand-typed, to survive the byte-for-byte check; 14:1 keeps its Bismillah prefix
//  as shipped, precedent SurahAnfalDive 8:1). No dua beat; ends on .closing, which
//  hands off to reading the full surah.
//
//  Spine: the weight of a word. Movement I - the two promises: God's speech (the
//  Book with work to do 14:1, the mother tongue 14:4, the oath-bound proclamation
//  14:7) against Satan's confessed counterfeit (14:22). Movement II - the two
//  trees: the rooted word (14:24-25), the uprooted word (14:26), the firm word
//  that answers in the grave (14:27), and the al-Kafi narration naming the tree
//  part by part (root = the Prophet, branch = Ali, boughs = the Imams, fruit =
//  their knowledge, leaves = the believers). Movement III - the valley: Ibrahim's
//  prayer as the parable's living proof, held spoiler-clean until the climax
//  (2:129), where all four receipts land together and the name is explained.
//
//  Sourcing is Shia and verified (revised per the Stage 5 four-auditor audit):
//  al-Mizan (Tabatabai) and Majma al-Bayan (Tabrisi) throughout; the tree
//  narration with its birth/death leaf couplet from Imam al-Sadiq (a), al-Kafi
//  1:428 (Kitab al-Hujja, via Nur al-Thaqalayn under 14:24); the grave-questioning
//  reading of 14:27 (Majma al-Bayan with the narrations; four questions incl.
//  religion and Imam per al-Kafi); hearts-incline = the prayer of Ibrahim, Imam
//  Ali (a) (al-Ihtijaj); "We are the remnant of that progeny", Imam al-Baqir (a)
//  (Majma al-Bayan under 14:37); "I am the prayer of my father Ibrahim" (al-Amali
//  of al-Tusi); the recitation merit from Thawab al-A'mal (al-Saduq). Honorifics
//  on the Prophet ﷺ and the Imams (a).
//

import SwiftUI

extension DeepDive {
    static let surahIbrahim: DeepDive = DeepDive(
        id: "surah-ibrahim",
        titleEn: "Ibrahim",
        titleAr: "إِبْرَاهِيم",
        subtitle: "Abraham - what one word planted in dead ground can become",
        sfSymbol: "tree",
        estMinutes: 13,
        acts: [
            ActInfo(number: 1, ar: "وَعْدُ الْحَقِّ", tr: "Wa'd al-Haqq", name: "The Promise of Truth"),
            ActInfo(number: 2, ar: "الشَّجَرَتَانِ", tr: "al-Shajaratan", name: "The Two Trees"),
            ActInfo(number: 3, ar: "الْوَادِي", tr: "al-Wadi", name: "The Valley"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "إِبْرَاهِيم",
                titleEn: "Ibrahim",
                subtitle: "Abraham",
                line: "Fifty-two verses - and the prophet they are named for arrives only near the end: an old man standing in a valley where nothing grows, doing the one thing he does in this entire surah. Speaking. No fire made cool for him, no idols smashed - the famous stories are all elsewhere. Here there are only his words, spoken into empty air. That is not an accident. This is the surah that weighs words - God's, Satan's, and yours. By the end of it you will know what it costs to say a word with nothing under it, and what one sentence can become when it is planted in dead ground."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "Surah Ibrahim was revealed in Mecca, in the years when the Prophet ﷺ owned nothing but words - no army, no treasury, no protection; only verses, recited against a city of stone gods. And the surah stakes everything on a single claim: a word is not breath that vanishes. Words are the most durable things in the world. Every kingdom of falsehood ever built began as one, and so did every lasting good. The surah hands you a scale for weighing them: it shows you what God does with speech, what Satan does with it, and then a picture worth keeping for life - one that turns every word you have ever spoken into something growing, or something already falling.",
                leaveWith: "You will leave knowing which of your words die in the air and which will outlive you. You will know the one word that can hold you at the hardest moment there is. And you will know why a surah about words carries the name of Ibrahim."
            ),

            // ── Movement I · Wa'd al-Haqq (The Promise of Truth) ──────────────
            .act(
                act: 1, connector: nil,
                line: "Everything in this surah begins with God speaking. Its first image is not a prophet or a people but a Book, coming down - words sent from heaven to earth with work to do. So watch what God uses words for. In this movement He tells you where His Book is taking you, how He makes sure you can understand it, and what His promises are made of. And then, at the movement's end, you will hear the other voice - the only other promiser there has ever been.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "Out of the Darknesses", surah: 14, ayah: 1,
                arabic: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الٓر ۚ كِتَٰبٌ أَنزَلْنَٰهُ إِلَيْكَ لِتُخْرِجَ ٱلنَّاسَ مِنَ ٱلظُّلُمَٰتِ إِلَى ٱلنُّورِ بِإِذْنِ رَبِّهِمْ إِلَىٰ صِرَٰطِ ٱلْعَزِيزِ ٱلْحَمِيدِ",
                translation: "Alif, Lam, Ra. A Book We have sent down to you, that you may bring mankind out of the darknesses into the light, by permission of their Lord - to the path of the Almighty, the Praiseworthy.",
                reference: "Ibrahim · 14 : 1",
                reflection: "Listen to the grammar the commentators pause on: the darknesses are plural, the light is singular. There are a thousand ways to be lost - superstition, despair, tyranny, the self - and one way to be found. And notice who the sentence is addressed to. God does not say the Book will bring people out on its own; He says to His Prophet ﷺ: a Book We sent down to you, so that you may bring them out. A word, even God's word, travels through a person. The Ahl al-Bayt taught that this is the permanent shape of guidance - the Book and its carriers together, the light in the hands of those appointed to hold it. From its first verse, the surah is telling you what it believes about words: they are not information. They are the rope thrown down into every dark place a human being can fall."
            ),
            .verse(
                act: 1, tag: "In Your Own Tongue", surah: 14, ayah: 4,
                arabic: "وَمَآ أَرْسَلْنَا مِن رَّسُولٍ إِلَّا بِلِسَانِ قَوْمِهِۦ لِيُبَيِّنَ لَهُمْ ۖ فَيُضِلُّ ٱللَّهُ مَن يَشَآءُ وَيَهْدِى مَن يَشَآءُ ۚ وَهُوَ ٱلْعَزِيزُ ٱلْحَكِيمُ",
                translation: "And We never sent a messenger except speaking the tongue of his own people, to make things clear for them. Then Allah leaves astray whom He wills and guides whom He wills, and He is the Almighty, the All-Wise.",
                reference: "Ibrahim · 14 : 4",
                reflection: "God has never spoken over anyone's head. Every messenger He ever sent came speaking the tongue of his own people: the market language, the mother tongue, the words they thought in. The verse gives the reason - li-yubayyina lahum, so that he could make it plain to them. Al-Mizan, Tabatabai's great commentary, draws out what this says about God: revelation is not interested in dazzling you from a height. It wants to be understood, and it will come all the way down to where you live to make sure it is. The Book that could split the sky arrives sounding like your own people talking. And Imam Ali (a) drew the edge hidden inside that tenderness: once God has spoken to a people in their own tongue, the proof is complete - no one can ever say, I could not have known. The word has already found you where you are. What remains is what you answer."
            ),
            .verse(
                act: 1, tag: "The Proclaimed Promise", surah: 14, ayah: 7,
                arabic: "وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِى لَشَدِيدٌۭ",
                translation: "And when your Lord proclaimed: If you are grateful, I will surely increase you. But if you are ungrateful - My punishment is truly severe.",
                reference: "Ibrahim · 14 : 7",
                reflection: "The verse opens with a word for a formal, public announcement: ta'adhdhana. This is not casual speech. It is a proclamation - God declaring it openly, in the first person, so that no one can ever say it was never said. Now listen to the two halves, because they are not symmetrical. The promise is spoken with the heaviest emphasis Arabic can carry: la-azidannakum, I will surely, surely increase you - the emphasis of a binding oath. The warning beside it does not say “I will punish you.” It turns instead to a statement about the punishment itself: My punishment is severe. The promise is the half He bound Himself to. Al-Mizan reads the verse as a law of creation: gratitude widens the channel through which more arrives - more provision, and more of what matters above provision: understanding, faith, nearness. This is what God does with words. He binds Himself by them, and what He has bound Himself to does not fail."
            ),
            .verse(
                act: 1, tag: "The Other Promiser", surah: 14, ayah: 22,
                arabic: "وَقَالَ ٱلشَّيْطَٰنُ لَمَّا قُضِىَ ٱلْأَمْرُ إِنَّ ٱللَّهَ وَعَدَكُمْ وَعْدَ ٱلْحَقِّ وَوَعَدتُّكُمْ فَأَخْلَفْتُكُمْ ۖ وَمَا كَانَ لِىَ عَلَيْكُم مِّن سُلْطَٰنٍ إِلَّآ أَن دَعَوْتُكُمْ فَٱسْتَجَبْتُمْ لِى ۖ فَلَا تَلُومُونِى وَلُومُوٓا۟ أَنفُسَكُم ۖ مَّآ أَنَا۠ بِمُصْرِخِكُمْ وَمَآ أَنتُم بِمُصْرِخِىَّ ۖ إِنِّى كَفَرْتُ بِمَآ أَشْرَكْتُمُونِ مِن قَبْلُ ۗ إِنَّ ٱلظَّٰلِمِينَ لَهُمْ عَذَابٌ أَلِيمٌۭ",
                translation: "And Satan will say, when the matter has been decided: “Allah promised you the promise of truth. And I promised you - and betrayed you. I had no authority over you, except that I called you, and you answered me. So do not blame me; blame yourselves. I cannot come to your rescue, and you cannot come to mine. I reject your making me a partner with Allah before. Indeed, for the wrongdoers there is a painful punishment.”",
                reference: "Ibrahim · 14 : 22",
                reflection: "When everything is settled and nothing can be changed, Satan stands up and speaks - the only extended speech the Qur'an ever lets him address to human beings, and every line of it is a confession. He weighs the two promises himself: God's was the promise of truth; mine, I broke. Then the admission the whole surah has been waiting for: I had no authority over you - except that I called you, and you answered me. That is the entire arsenal of the enemy of mankind, disclosed in one line: an invitation. No chains, no force, not one sin in history compelled. Al-Mizan finds here a clear indication of human freedom: temptation can only propose; it holds no power over the one it calls. And then watch him abandon them at the one moment they most need anyone - al-Mizan reads this line as the bond itself being severed: I cannot come to your rescue. The god they had obeyed for a lifetime abandons them in the middle of his own speech, and turns the blame on his worshippers. Weigh the two promises now, side by side, the way that Day will weigh them. One was an oath from the One who cannot lie. The other was a voice with nothing behind it - and every temptation you will meet this week is exactly that size: a call, waiting to see what you answer."
            ),

            // ── Movement II · al-Shajaratan (The Two Trees) ───────────────────
            .act(
                act: 2,
                connector: "You have heard the two promises - the one sealed with an oath, and the one its own maker called a lie.",
                line: "So why did one word hold and the other collapse? What was underneath them? The surah answers with a picture - one of the most beloved in the whole Qur'an. It asks you to stop thinking of words as sounds, and start thinking of them as living things. Every word ever spoken - creed, promise, prayer, lie - is a seed in the ground. And there are only two kinds of tree.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Living Word", surah: 14, ayah: 24,
                arabic: "أَلَمْ تَرَ كَيْفَ ضَرَبَ ٱللَّهُ مَثَلًۭا كَلِمَةًۭ طَيِّبَةًۭ كَشَجَرَةٍۢ طَيِّبَةٍ أَصْلُهَا ثَابِتٌۭ وَفَرْعُهَا فِى ٱلسَّمَآءِ",
                translation: "Have you not seen how Allah sets forth a parable? A good word is like a good tree: its root is firm, and its branch reaches into the sky.",
                reference: "Ibrahim · 14 : 24",
                reflection: "Hold any word you carry up against this tree. First, the root: does it grip something real - or only fashion, fear, whatever is being said this year? Al-Mizan says that at its base the good word is the word of tawhid: there is no god but God. That sentence grips the deepest fact there is, and every true word after it roots into the same ground. Second, the branch: a rooted word does not stay at ground level. It lifts the one who holds it - his hopes rise, his conduct rises, his company rises. And third - the next verse finishes the picture - it gives its fruit at every season, by its Lord's permission (14:25). Not in summer only. A true word feeds its holder in ease and in calamity, in youth and on a deathbed. Everything else you own is seasonal: harvests fail, markets turn, strength runs out. One kind of possession bears in every weather. And the quiet phrase - by its Lord's permission - keeps even that harvest from turning into pride. The tree does not fruit because you are clever. It fruits because He lets it."
            ),
            .verse(
                act: 2, tag: "The Uprooted Word", surah: 14, ayah: 26,
                arabic: "وَمَثَلُ كَلِمَةٍ خَبِيثَةٍۢ كَشَجَرَةٍ خَبِيثَةٍ ٱجْتُثَّتْ مِن فَوْقِ ٱلْأَرْضِ مَا لَهَا مِن قَرَارٍۢ",
                translation: "And the parable of a rotten word is a rotten tree, torn up from the face of the earth - it has nowhere to stand.",
                reference: "Ibrahim · 14 : 26",
                reflection: "Now put Satan's confession back into the parable, and read it as a tree. The verse never says the rotten tree is small. It can be tall, leafy, impressive - covering a city, filling an age. The verse says something else about it. It was ijtuththat - torn out whole, roots and all. And ma laha min qarar: it has nowhere to stand. Falsehood's problem is not volume. Tabrisi, in his commentary Majma al-Bayan, puts it plainly: the rotten tree has no steadiness and no permanence - the wind takes it - and a rotten word gives its holder nothing that lasts. Al-Mizan gives the reason underneath: there is no soil in reality for a false word to grip. That is why the empire of the great promiser fell in one push the moment the matter was decided. It looked enormous. It had no roots. When Satan said “I had no authority over you,” he was describing this very tree - from the inside. And the warning turns gently toward us. Think of the lie a reputation leans on. The story a grudge keeps telling. The identity built out of what others think. None of them has a root. They are not standing - they are only falling slowly."
            ),
            .verse(
                act: 2, tag: "The Word That Holds You", surah: 14, ayah: 27,
                arabic: "يُثَبِّتُ ٱللَّهُ ٱلَّذِينَ ءَامَنُوا۟ بِٱلْقَوْلِ ٱلثَّابِتِ فِى ٱلْحَيَوٰةِ ٱلدُّنْيَا وَفِى ٱلْءَاخِرَةِ ۖ وَيُضِلُّ ٱللَّهُ ٱلظَّٰلِمِينَ ۚ وَيَفْعَلُ ٱللَّهُ مَا يَشَآءُ",
                translation: "Allah makes firm those who believe, with the firm word, in the life of this world and in the Hereafter. And Allah leads the wrongdoers astray; and Allah does what He wills.",
                reference: "Ibrahim · 14 : 27",
                reflection: "Here is what a rooted word does for the one who holds it: it holds him up. Yuthabbitu - He makes them firm. God Himself does the steadying, and the verse names what He steadies them with: the firm word. In this life, that is the grip that keeps a believer standing through trial and doubt and grief. But the verse adds: and in the Hereafter - and Tabrisi, following the narrations, reads that as the grave. The Ahl al-Bayt taught that every soul is questioned there: Who is your Lord? What is your religion? Who is your prophet? Who is your Imam? - asked when wealth, name, and the body's strength have all been left behind. What answers in that hour is not quick thinking. It is the word you actually held - held until it rooted - and it is God Himself steadying you by it. Now set this beside what you saw at the end of the last movement. Satan deserts his followers at the moment of their greatest need: I cannot come to your rescue. The good word is the opposite kind of companion. It is the one possession that lies down in the grave beside you - and speaks when you cannot."
            ),
            .narration(
                act: 2, tag: "The Tree Has a Name",
                source: "Imam Ja'far al-Sadiq (a) · al-Kafi",
                body: "In al-Kafi, the earliest of the four canonical Shia hadith collections, Imam Ja'far al-Sadiq (a) was asked about this parable - which word, which tree? He answered by naming it part by part: The Messenger of Allah ﷺ is its root. Amir al-Mu'minin Ali (a) is its branch. The Imams from their progeny are its boughs. The knowledge of the Imams is its fruit. And their believing followers - the ones who hold to them - are its leaves. Then the narration adds one line more: when a believer is born, a leaf opens on the tree; and when a believer dies, a leaf falls from it.",
                reflection: "The parable, it turns out, is not an abstraction. God grew the good word into a family. A root that feeds everything: the Prophet ﷺ. The branch that carries the root's strength upward: Ali (a). The boughs that spread it across the centuries: the Imams. Fruit in every season: their knowledge, ripening for every generation that reaches for it. And look where the narration places you. Not outside the tree, admiring it - among its leaves, alive the way a leaf is alive: by staying attached. This is the word the movement has been describing all along, standing in the world as a household. Whoever holds to it is holding the firm word - the one that answers in the grave."
            ),

            // ── Movement III · al-Wadi (The Valley) ───────────────────────────
            .act(
                act: 3,
                connector: "You know the two trees now - and you have seen the good word standing in the world as a household, with the believers for its leaves.",
                line: "The word has been named. Now the surah shows you where it was planted - and who planted it. It carries you back four thousand years, to a dry valley of rock where nothing grows and nothing ever had. An old man is standing in it. He has no army and no city. Those he loves most in the world, he left in the shade of the valley's rocks. On this day he has nothing at all but words. Watch what he plants in the dead ground.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "Even the Friend of God", surah: 14, ayah: 35,
                arabic: "وَإِذْ قَالَ إِبْرَٰهِيمُ رَبِّ ٱجْعَلْ هَٰذَا ٱلْبَلَدَ ءَامِنًۭا وَٱجْنُبْنِى وَبَنِىَّ أَن نَّعْبُدَ ٱلْأَصْنَامَ",
                translation: "And when Ibrahim said: “My Lord, make this city secure, and keep me and my sons away from worshipping idols.”",
                reference: "Ibrahim · 14 : 35",
                reflection: "Two wonders sit in this one verse. The first: he says this city - over a place that is barely a settlement in a waste of rock. Al-Mizan hears in these words the later of two prayers. He had prayed over this ground before, on a day when there was nothing here at all to point at: my Lord, make this a city, secure. Now, standing on the same ground, he can say this city - and he asks again. Ibrahim's prayers are not sighs released once into the air. He tends this valley in prayer the way a farmer tends a field - the same words, returned to, year after year. The second wonder is stranger: keep me and my sons away from worshipping idols. This is the man who took an axe to the idols of his people and was thrown into a fire for it - and in old age he still does not trust even himself with shirk, with letting anything stand in God's place. Al-Mizan stops here: guidance, even a prophet's, is never a possession. It is a gift renewed moment by moment, and the surest way to keep it is to keep asking for it. And Imam al-Sadiq (a) widened the word for us: an idol is not only stone. It is anything obeyed against God - and the man safest from every idol is the one who, in his old age, is still praying not to bow to one."
            ),
            .verse(
                act: 3, tag: "Planted in Dead Ground", surah: 14, ayah: 37,
                arabic: "رَّبَّنَآ إِنِّىٓ أَسْكَنتُ مِن ذُرِّيَّتِى بِوَادٍ غَيْرِ ذِى زَرْعٍ عِندَ بَيْتِكَ ٱلْمُحَرَّمِ رَبَّنَا لِيُقِيمُوا۟ ٱلصَّلَوٰةَ فَٱجْعَلْ أَفْـِٔدَةًۭ مِّنَ ٱلنَّاسِ تَهْوِىٓ إِلَيْهِمْ وَٱرْزُقْهُم مِّنَ ٱلثَّمَرَٰتِ لَعَلَّهُمْ يَشْكُرُونَ",
                translation: "“Our Lord, I have settled some of my descendants in a valley without cultivation, by Your sacred House - our Lord, that they may establish the prayer. So make hearts among the people incline toward them, and provide them with fruits, that they might be grateful.”",
                reference: "Ibrahim · 14 : 37",
                reflection: "Hear how plainly he lays it before his Lord: I have settled my own family in a valley that cannot feed them. He does not soften it. And then he gives the reason, and it is the hinge of the whole prayer: rabbana li-yuqimu al-salah - our Lord, so that they may establish the prayer. Al-Mizan pauses on the order of values: he chose nearness to God's House over harvest, worship over livelihood - and then asked God to supply everything the choice cost. So the requests come, and they are impossible on their face. Provide them with fruits - in ground where nothing grows. Tabrisi points out how the provision is asked for: not out of the valley's soil, but carried in from outside, along the trade routes of the world - as if the valley were meant to be fed by everywhere else. Then the stranger request: make hearts among the people incline toward them. The Arabic is physical: af'ida is the word for the innermost core of the heart, and tahwi is a diving, swooping motion - hearts plunging toward the empty valley like birds dropping out of the sky. He is asking God to redirect love itself. Last of all, the purpose beneath it all: that they might be grateful. He asks for the fruit so that it can be turned into thanks - what is given, returned as thanks - a request laid along the grain of the promise you heard in Movement I: if you are grateful, I will surely increase you."
            ),
            .verse(
                act: 3, tag: "Accept My Prayer", surah: 14, ayah: 40,
                arabic: "رَبِّ ٱجْعَلْنِى مُقِيمَ ٱلصَّلَوٰةِ وَمِن ذُرِّيَّتِى ۚ رَبَّنَا وَتَقَبَّلْ دُعَآءِ",
                translation: "“My Lord, make me an establisher of the prayer, and from my descendants too. Our Lord - and accept my supplication.”",
                reference: "Ibrahim · 14 : 40",
                reflection: "The last part of his prayer turns inward. After the city, the fruits, the hearts, he asks for the thing underneath them all: make me an establisher of the prayer. Al-Mizan explains the phrase - muqim al-salah is not simply someone who prays. He is someone who keeps prayer standing: praying with presence, and keeping prayer alive in the people who come after him. Which is why Ibrahim adds: and from my descendants. Imam al-Baqir (a) taught that this line belongs on our own tongues daily - even the ability to stand and pray is a gift you must pray for; pray for your prayer. Then Ibrahim does the last humble thing a supplicant can do. Having asked for everything, he asks for the prayer itself to be received: rabbana wa-taqabbal du'a - our Lord, accept my prayer. One answer he already holds in his hands: a moment earlier in this same prayer, he thanks God for Isma'il and Ishaq, granted to him in old age, and calls his Lord the Hearer of supplication (14:39). But about the valley - the city, the fruits, the hearts - the surah shows him nothing. An old man. A dead valley. A handful of sentences, hanging in the empty air. Every parable in this descent has promised that a good word cannot die. Here is the good word, planted in the worst ground on earth. Was it accepted?"
            ),
            .climax(
                act: 3, tag: "The Answered Valley", source: "al-Baqara · 2 : 129",
                arabic: "رَبَّنَا وَٱبْعَثْ فِيهِمْ رَسُولًۭا مِّنْهُمْ يَتْلُوا۟ عَلَيْهِمْ ءَايَٰتِكَ وَيُعَلِّمُهُمُ ٱلْكِتَٰبَ وَٱلْحِكْمَةَ وَيُزَكِّيهِمْ ۚ إِنَّكَ أَنتَ ٱلْعَزِيزُ ٱلْحَكِيمُ",
                translation: "“Our Lord, and raise up in their midst a messenger from among them, who will recite to them Your verses, and teach them the Book and the wisdom, and purify them. Indeed, You are the Almighty, the All-Wise.”",
                body: "The Qur'an kept the rest of what he prayed. In another surah, Ibrahim stands at this same spot raising the foundations of the House with Isma'il - and he asks the empty valley for one thing more: a messenger, to rise from it.",
                reflection: "Now stand in that valley today, and count. He asked for a secure city: Mecca stands - and al-Mizan notes how completely: even in the lawless centuries before Islam, men who fought everywhere else laid their weapons down inside it. He asked for fruits in ground that grows nothing: provision has poured into that barren valley every single day for four thousand years. He asked for hearts: at this hour, on every continent, millions of faces are turned toward that bare valley, and pilgrims who have seen every beautiful city on earth weep at the sight of a place with nothing in it. Imam Ali (a) named what moves beneath that geography: the hearts of the people incline to us, he said - and that is the prayer of Ibrahim. If you find love for the Prophet's ﷺ household in your own chest, you did not put it there. It is Ibrahim's sentence, still landing, four thousand years on. Last, he asked for a messenger from his own descendants - and from that valley, from his line, rose Muhammad ﷺ. “I am the prayer of my father Ibrahim,” he said. And Imam al-Baqir (a) sealed it: We are the remnant of that progeny; Ibrahim's prayer was for us in particular. That tree - its root the Messenger ﷺ, its leaves the believers - is growing on the exact spot where Ibrahim planted his words. And now, at last, the name. The surah that weighs every word in existence is named for the man who proved its parable: the good word really is a good tree. His was planted in the most barren ground on earth, and it has never once missed a season. So take the measure of your own words. The du'a you say over a sleeping child; the prayer you keep praying through a barren season, with no sign of harvest; the word of truth you hold when it costs you - these are seeds of the same species, and what is planted with God in dead ground is never wasted. It grows while you are gone, and what becomes of it may not be yours to watch. Ibrahim never saw the caravans, the pilgrims, the Messenger ﷺ rising from his line. He planted anyway, and asked for the planting to be received. And whatever your own life is refusing to grow right now, your ground is not more barren than his was."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "What word will you plant?",
                placeholder: "A du'a for your children, a promise to God, a word of truth to hold onto…",
                subline: "You have walked the whole descent. The two promises - the oath God bound Himself to, and the call with nothing behind it. The two trees - the rooted word, and the tall one already severed. The word that holds you when everything else is left behind. And the valley, where one man planted a handful of sentences in dead ground and asked for them to be received. Before you go, name the word you will plant - the prayer you are willing to keep praying without needing to watch it grow.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "إِبْرَاهِيم",
                essence: "In its very last verse, the surah says what it is: “This is a message delivered to mankind” (14:52). Balagh - a message carried the whole way to its destination, handed to the entire human race. The surah that taught you what words are ends by telling you what it is. A good word, sent down so it could be planted in you. Its root is firm. Its branch is in the sky.",
                line: "Imam al-Sadiq (a) taught that whoever recites Surah Ibrahim and Surah al-Hijr together in a two-rak'ah prayer every Friday will not be struck by poverty, madness, or affliction - Thawab al-A'mal. Read the surah now in its own words, all fifty-two verses. This descent walked its spine - the promises, the sermon of the defeated promiser, the two trees, and the prayer from the valley - and more waits inside it: the Days of God, the counted blessings, the warnings. Read it as what it says it is: seed."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah Ibrahim experience") {
    DeepDiveView(dive: .surahIbrahim, onClose: {})
}
#endif
