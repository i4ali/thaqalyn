//
//  SurahNahlDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Nahl" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/nahl-script.md.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically, never hand-typed, to survive
//  the byte-for-byte check).
//
//  Spine: the Surah of Blessings (Surat al-Ni'am, a name carried from Qatada
//  onward) - the Qur'an's great inventory of gifts, asking one question: what do
//  you do with a gift you cannot count? The hinge is 16:83, "they RECOGNIZE the
//  favor of Allah, then they deny it" - kufr laid bare as ingratitude, covering
//  what you already know. The surah is named not for the pouring but for a
//  receiver: the bee, the one creature shown receiving wahy and obeying it
//  perfectly, whose gift leaves her body as healing for others. Two buried
//  word-pairs pay off in-flow: an'um occurs exactly twice in the whole Qur'an,
//  both here (16:112 denied / 16:121 Ibrahim grateful), and mutma'inn exactly
//  twice in the surah (16:106 a tortured heart at rest / 16:112 a fed town at
//  rest on its provisions). Four movements from the surah's own waves (pour /
//  deny / the bee / outcomes), with one announced rewind at Movement III, since
//  the surah interleaves its denial verses inside the second blessing wave.
//  Climax pulled from mid-surah (16:97) to the summit - house precedent: the
//  Ibrahim dive's outside-the-surah climax. No threshold map (hymn-catalogue,
//  not narrative); no dua beat, so no Listen button is owed - ends on .closing,
//  which hands off to reading the full surah.
//
//  Sourcing is Shia, traced at script stage through primary-source relays:
//  16:97 = al-qana'a from Amir al-Mu'minin (a) (Nahj al-Balagha, hikma 229),
//  with Majma al-Bayan's parallel marfu' to the Prophet ﷺ and the same gloss
//  from Tafsir al-Qummi via Nur al-Thaqalayn 3:83-84 no. 214 (mursal - NOT a
//  report from Imam al-Sadiq (a), as an earlier draft had it); the Ammar torture report and the Prophet's ﷺ words under
//  16:106 (Majma al-Bayan); the daughters/sons bookkeeping and the newborn-girl
//  saying (al-Kafi, Kitab al-Aqiqa, bab fadl al-banat); the Prophet ﷺ rising for
//  Fatima (a) (Bihar al-Anwar 43:40, from Manaqib Ibn Shahrashub); honey as shifa
//  (al-Kafi, Kitab al-At'ima, bab al-asal); the wilaya reading of 16:83 (al-Kafi,
//  Kitab al-Hujja, bab nukat wa nutaf min al-tanzil) with Amir al-Mu'minin's (a)
//  "we are the ni'ma" under 14:28 (al-Kafi, Kitab al-Hujja); the Tharthar town
//  (Tafsir al-Qummi, with the fuller telling in al-Kafi, bab fadl al-khubz);
//  ju'ar as the ox's bellow and the forgiven-shortfall reading of 16:18 (Majma
//  al-Bayan), set beside al-Mizan's distinct and deeper reading of the same
//  ending; the surah merit from Imam al-Baqir (a) (Thawab al-A'mal). Al-Mizan is
//  cited only where verified verbatim (16:18's two names, 16:112 as a general
//  mathal). Note the in-app tafsir_16.json is WRONG in two places this dive
//  deliberately diverges from: it has al-Mizan identifying the town of 16:112 as
//  Mecca (al-Mizan actually reads it as a general mathal), and it credits Majma's
//  qana'a gloss to Imam Ali (a) (Majma carries it from al-Hasan and Wahb, marfu'
//  to the Prophet ﷺ, and never names Ali). Revised per the Stage 5 four-auditor
//  audit (flow, sourcing/Arabic, readability, voice & reverence) - blocker and
//  should-fix bands applied. Honorifics on the Prophet ﷺ and the Imams (a).
//

import SwiftUI

extension DeepDive {
    static let surahNahl: DeepDive = DeepDive(
        id: "surah-nahl",
        titleEn: "al-Nahl",
        titleAr: "النَّحْل",
        subtitle: "The Bee - what do you do with a gift you cannot count?",
        sfSymbol: "hexagon.fill",
        estMinutes: 15,
        acts: [
            ActInfo(number: 1, ar: "النِّعَم", tr: "al-Ni'am", name: "The Pouring"),
            ActInfo(number: 2, ar: "الْجُحُود", tr: "al-Juhud", name: "The Denial"),
            ActInfo(number: 3, ar: "النَّحْل", tr: "al-Nahl", name: "The Bee"),
            ActInfo(number: 4, ar: "الْبَاقِي", tr: "al-Baqi", name: "What Remains"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "النَّحْل",
                titleEn: "al-Nahl",
                subtitle: "The Bee",
                line: "Somewhere in the middle of this surah, between oceans and mountains and the stars men steer by, the Qur'an pauses over an insect smaller than your thumbnail - and names the whole surah after her. Al-Nahl is the Qur'an's great inventory of gifts: warmth, milk, honey, rain, spouses, children, homes, the evening beauty of herds coming home. Near its start it issues a quiet challenge: try to count what you have been given. You will fail. A hundred and twenty-eight verses later you understand why the count was never the point - and why, out of everything in the catalogue, the surah chose to carry the name of the smallest thing in it."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "From the earliest generations this surah has carried a second name: the Surah of Blessings - so thick with gifts that people simply called it that. But al-Nahl is not a list; it is a test hidden in a list. Again and again it pours - cattle, rain, seas, fruit, shade, garments - and then turns, mid-pour, to watch what the receivers do with it all. Some cry to God in the storm and forget Him on the shore. Some are handed a gift and call it a disgrace. And tucked into the exact middle of the pouring, the surah stops over one small creature who receives her instructions perfectly - and gives back more than she was ever given. This descent follows the gift the whole way down: how it arrives, how it is denied, how it is received rightly, and where each of those two roads finally ends.",
                leaveWith: "You will leave carrying the Qur'an's two-word promise of a good life, the one-word key the Ahl al-Bayt gave for it, and the reason a whole surah of the Qur'an carries the name of an insect."
            ),

            // ── Movement I · al-Ni'am (The Pouring) ───────────────────────────
            .act(
                act: 1, connector: nil,
                line: "The inventory opens the way no merchant's would. Not with gold, not with land, but with animals - and the first blessing it names is warmth: “And the grazing herds - He created them; for you in them is warmth, and benefits, and from them you eat” (16:5). Plain animal heat, the thing that kept a desert night survivable. The catalogue has begun. And its very next line enters something in the ledger that no accountant would ever think to count.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "The Gift Beyond Need", surah: 16, ayah: 6,
                arabic: "وَلَكُمْ فِيهَا جَمَالٌ حِينَ تُرِيحُونَ وَحِينَ تَسْرَحُونَ",
                translation: "And for you in them is beauty, when you bring them home in the evening and when you drive them out to pasture.",
                reference: "al-Nahl · 16 : 6",
                reflection: "Jamal. Beauty. In the middle of an inventory of survival - warmth, food, transport - God enters the sight of the herd coming home at dusk, dust hanging in the low sun, and counts it among your provisions. He did not only make the animal useful; He made the look of it good, and then told you it was for you. Sit with what that says about the Giver. Usefulness alone would have met every need. He gave past need - and the verse's timing is precise: the beauty is named at the homecoming hour and the setting-out hour, the two moments a herdsman actually stands and watches. Then come the animals that carry your loads “to a land you could not have reached except with hardship to yourselves - indeed your Lord is Kind, Merciful” (16:7). Then horses, mules and donkeys “for you to ride, and as adornment” (16:8) - zina, a second word for beauty. And that verse ends with an open door: “and He creates what you do not know.” An inventory with beauty in it, and a final line left open. Already you can feel what the next verse makes explicit: a list like this was never going to be totaled."
            ),
            .verse(
                act: 1, tag: "The Uncountable", surah: 16, ayah: 18,
                arabic: "وَإِن تَعُدُّوا۟ نِعْمَةَ ٱللَّهِ لَا تُحْصُوهَآ ۗ إِنَّ ٱللَّهَ لَغَفُورٌۭ رَّحِيمٌۭ",
                translation: "And if you try to count the blessing of Allah, you will not number it. Indeed Allah is Forgiving, Merciful.",
                reference: "al-Nahl · 16 : 18",
                reflection: "Take the challenge seriously for a moment. Start with this breath - but a breath needs lungs, lungs need blood, blood needs a heart that has beaten since before you knew you had one. Every blessing you name unpacks into a thousand you did not, and each of those into a thousand more. The count does not just take long; it fails in principle. Now hear how the verse ends - because a counting verse should end “so pay what you owe,” and this one ends with two names of mercy. Tabrisi reads it in Majma al-Bayan as the gentlest possible reckoning. He is Forgiving toward the shortfall in your thanks - the shortfall the failed count just proved. And He is Merciful in that the gifts keep coming anyway. In one line you were shown that the debt cannot be paid, and that it is already forgiven. And al-Mizan hears something deeper still, calling this one of the subtlest and most precise of reasonings: the blessings are uncountable because He is Forgiving and Merciful. His forgiveness, at root, means covering: it veils the flaw in every created thing. His mercy fills in every lack. So when you look at the whole, there is nothing left that is not gift. The catalogue has no bottom because those two names have no bottom. Either way, the sentence has quietly done what this whole surah is built to do: it has moved your eyes off the gifts, and onto the Giver."
            ),
            .verse(
                act: 1, tag: "Where Every Voice Goes", surah: 16, ayah: 53,
                arabic: "وَمَا بِكُم مِّن نِّعْمَةٍۢ فَمِنَ ٱللَّهِ ۖ ثُمَّ إِذَا مَسَّكُمُ ٱلضُّرُّ فَإِلَيْهِ تَجْـَٔرُونَ",
                translation: "And whatever blessing is with you - it is from Allah. Then, when harm touches you, to Him you cry out.",
                reference: "al-Nahl · 16 : 53",
                reflection: "Two halves, and a whole theology of the gift between them. The first half closes every loophole: ma bikum min ni'ma - whatever blessing is with you, however it arrived, whoever's hands it passed through - it is from Allah. Not most of it. Whatever is with you. And the second half proves that, deep down, you already know. The word is taj'arun, and Tabrisi's language note in Majma al-Bayan preserves its origin: ju'ar is the bellow of the ox - the animal crying out from hunger or pain. The same herds that opened the catalogue. When harm touches, the polish drops off a human being, and the voice underneath - king's or herdsman's, believer's or mocker's - goes to one address only, as instinctively as cattle lowing in the dark. Pain does not create faith; it uncovers it. The exposure comes one verse later: “then, when He removes the harm from you, at once a party of you assigns partners to their Lord” (16:54). The same throat that cried to Him alone now credits the rescue elsewhere. There is the crack in the receiving - recognition working perfectly under pressure, and buried again the moment the pressure lifts. The surah now follows that crack down into the dark."
            ),

            // ── Movement II · al-Juhud (The Denial) ───────────────────────────
            .act(
                act: 2,
                connector: "The catalogue stands open: warmth, beauty, the uncountable - and in every storm, the voice that knows exactly where to cry.",
                line: "But a gift only becomes gratitude in the hands that receive it - and the surah now turns to watch the hands. What it records next is the inventory's dark twin: the ways a blessing can be recognized and refused in the same motion. It begins in the one place refusal should be impossible - at the news of a child.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Gift Called Shame", surah: 16, ayah: 58,
                arabic: "وَإِذَا بُشِّرَ أَحَدُهُم بِٱلْأُنثَىٰ ظَلَّ وَجْهُهُۥ مُسْوَدًّۭا وَهُوَ كَظِيمٌۭ",
                translation: "And when one of them is given news of a girl, his face darkens, and he chokes down his grief.",
                reference: "al-Nahl · 16 : 58",
                reflection: "Listen to the words the Qur'an chooses. The man is given bushra - the word for good news, the word the angels themselves use - and his face goes black. The next verse walks his logic to its end: he hides from his own people “because of the evil of what he was given good news of,” weighing two options - keep her in humiliation, or press her into the dust (16:59). The verse's verdict is spoken over the weighing itself: “Evil is what they decide.” Why does this scene belong in the Surah of Blessings, and not merely in a catalogue of cruelties? Because heaven and the man are looking at the same child. Heaven calls her a gift. His arithmetic - honor, expense, alliance, war - books her as a liability. Same object; two ledgers. That is ingratitude in its purest form: not failing to receive, but receiving and renaming. The household of the Prophet ﷺ kept the true ledger in the open. When a man's face changed at the news of a newborn girl in his presence, the Prophet ﷺ said: “The earth carries her, the sky shades her, and Allah provides for her - she is a fragrant flower for you to smell” (al-Kafi). And Imam al-Sadiq (a) reversed the old arithmetic in a single line: “Sons are na'im - bounty - and daughters are hasanat: Allah questions about the na'im, and rewards for the hasanat” (al-Kafi). Both of his words grow from the same root as ni'ma, this surah's own word for a blessing. And the ranking is exact: a merit earns you reward, a bounty gets asked about. This whole descent is watching blessings be questioned. And the community saw the true ledger lived: when Fatima (a) entered, the Prophet ﷺ would rise from his place, kiss her head, and seat her where he himself had been sitting (Bihar al-Anwar, from Manaqib Ibn Shahrashub). The men of Jahiliyya - the age of ignorance before Islam - hid from their people at the news of a daughter. The master of creation ﷺ rose to his feet, before the whole gathering, at the arrival of his daughter. Before you file this scene under history: every generation buries some gift it is ashamed to be seen holding. The shapes change. The darkened face is very old."
            ),
            .verse(
                act: 2, tag: "The Gifts at Your Table", surah: 16, ayah: 72,
                arabic: "وَٱللَّهُ جَعَلَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَٰجًۭا وَجَعَلَ لَكُم مِّنْ أَزْوَٰجِكُم بَنِينَ وَحَفَدَةًۭ وَرَزَقَكُم مِّنَ ٱلطَّيِّبَٰتِ ۚ أَفَبِٱلْبَٰطِلِ يُؤْمِنُونَ وَبِنِعْمَتِ ٱللَّهِ هُمْ يَكْفُرُونَ",
                translation: "And Allah has made for you, from your own selves, spouses, and made for you from your spouses children and grandchildren, and provided you with good things. Is it falsehood they believe in, and the blessing of Allah they deny?",
                reference: "al-Nahl · 16 : 72",
                reflection: "The catalogue comes indoors. From your own selves, spouses - companionship cut from your own kind. From the spouses, children. From the children, hafada - grandchildren, the gift that arrives through two generations of prior gifts, each one unasked. These are not blessings you hold; they are blessings you live inside - the faces at your table. And then the verse turns and asks its question with the surah's signature verb: is it falsehood they place their trust in, “while the blessing of Allah they deny?” The verb is yakfurun. Kufr. Hear what this surah does to that word. Its root means to cover - the Arabs called the farmer a kafir because he covers the seed with soil. It is a different root from the one behind God's forgiveness two beats ago, but the same picture: something laid over something else. Kufr, in the grammar of al-Nahl, is not first of all an opinion about whether God exists; it is a treatment of what God has given. To live inside the spouse, the child, the provision - and route the acknowledgment to idols, to fortune, to yourself - is to pull soil over a favor you are standing in. The surah has one more verse on this, and it is the coldest and clearest sentence in it."
            ),
            .verse(
                act: 2, tag: "Recognized, Then Denied", surah: 16, ayah: 83,
                arabic: "يَعْرِفُونَ نِعْمَتَ ٱللَّهِ ثُمَّ يُنكِرُونَهَا وَأَكْثَرُهُمُ ٱلْكَٰفِرُونَ",
                translation: "They recognize the blessing of Allah - then they deny it. And most of them are the disbelievers.",
                reference: "al-Nahl · 16 : 83",
                reflection: "This is the hinge of the surah, and perhaps the Qur'an's cleanest anatomy of disbelief. Mark the order of the verbs. Ya'rifuna - they recognize - comes first. The people this verse describes are not ignorant of the favor; recognition is the first thing stated about them. The denial, yunkiruna, is performed on top of the knowing - a cover pulled over an acknowledged light. And then the verse closes the circuit the last beat opened: “and most of them are al-kafirun” - the coverers. The Qur'an's word for disbelief and its word for ingratitude are the same word. This verse is where the two meanings turn out to be one thing. Both are the same refusal: you know something, and you will not let that knowledge tie you to the One it points to. Nobody in Mecca disputed that the rain fell and the herds gave milk; the dispute was only ever about acknowledging the Hand. And the household of the Prophet ﷺ read this verse into their own story. Al-Kafi relays from Imam al-Sadiq (a), from his fathers. The verse of wilaya had come down - wilaya, meaning who holds authority over you, whose command you stand under: “Your wali is only Allah, and His Messenger, and those who believe...” (5:55). And some said openly: we know Muhammad is truthful in what he says - but we will not obey Ali in what he commands us. And this verse came down about them: they recognize the blessing of Allah, then they deny it - “they recognize,” the Imam said, “meaning the wilaya of Ali ibn Abi Talib (a) - and most of them are deniers of the wilaya” (al-Kafi). Under a sister verse, Amir al-Mu'minin (a) himself said it from the other side: “We are the ni'ma which Allah has bestowed upon His servants, and through us triumphs whoever triumphs on the Day of Rising” (al-Kafi, under 14:28). The greatest entry in the catalogue, in this reading, was never rain or milk. It is guidance walking among you - and it can be recognized, and covered, exactly like any other gift. Recognition, the surah is teaching, is not the finish line of faith; it is the starting line of the test. And note the verse's last mercy: most of them. Not all. There is another kind of receiver, and the surah has been keeping her in the middle of the catalogue this whole time."
            ),

            // ── Movement III · al-Nahl (The Bee) ──────────────────────────────
            .act(
                act: 3,
                connector: "A gift can be renamed a shame. The faces at the table can be lived with and denied. Recognition itself can wear a cover.",
                line: "Now the descent must do something it has not done yet: go back. Seventeen verses back - back past even the table you were just sitting at - into the middle of the catalogue the deniers walked straight through, because the surah hid its own name there, between the rain and the fruit. And around that name it built a quiet sequence, held together by one repeated word: butun. Bellies. Three times, three hidden interiors, three things brought out. Watch what a body yields up when the receiving is right.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "Milk Out of the Dark", surah: 16, ayah: 66,
                arabic: "وَإِنَّ لَكُمْ فِى ٱلْأَنْعَٰمِ لَعِبْرَةًۭ ۖ نُّسْقِيكُم مِّمَّا فِى بُطُونِهِۦ مِنۢ بَيْنِ فَرْثٍۢ وَدَمٍۢ لَّبَنًا خَالِصًۭا سَآئِغًۭا لِّلشَّٰرِبِينَ",
                translation: "And indeed, in the grazing herds there is a lesson for you: We give you drink from what is in their bellies - from between waste and blood - pure milk, easy for those who drink.",
                reference: "al-Nahl · 16 : 66",
                reflection: "The surah calls it an ibra - a lesson - before it calls it a drink. Consider where milk comes from. Inside the animal's body it forms min bayni farthin wa dam - between digestive waste on one side and blood on the other. And it comes out khalis: pure, untouched by either neighbour. Sa'igh, too: it goes down easy. Every morning, in every herd, an extraction is performed that no one watches: out of an interior nobody would call promising, something white, clean and nourishing is drawn - daily, silently, and never once mixed. Here is the lesson the surah loaded into it: no origin is too low for what He chooses to bring out of it. The last movement showed you what human hands do with clean gifts - darken at them, deny them. This verse shows what God brings out of a place no one would have called promising: purity, in the Surah of Blessings, is not something that lies ready-made. It is drawn out. Hold the image of that first belly. The next receiver takes the same miracle one step further - what she yields is not only pure. It heals."
            ),
            .verse(
                act: 3, tag: "Revelation, Received", surah: 16, ayah: 68,
                arabic: "وَأَوْحَىٰ رَبُّكَ إِلَى ٱلنَّحْلِ أَنِ ٱتَّخِذِى مِنَ ٱلْجِبَالِ بُيُوتًۭا وَمِنَ ٱلشَّجَرِ وَمِمَّا يَعْرِشُونَ",
                translation: "And your Lord revealed to the bee: take for yourself houses in the mountains, and in the trees, and in what they build.",
                reference: "al-Nahl · 16 : 68",
                reflection: "The verb here is awha - the verb of revelation, the same word the Qur'an uses for what descends on prophets - and here it is spoken to an insect. The commentators are careful: this is not the revelation of a Book but guidance woven directly into her nature - yet the choice of the word is the point. The surah wants you to see one Lord instructing all His receivers, great and small, and it lets you read her instructions: take your houses in the mountains, in the trees, in what people build. Eat from all the fruits. Then travel the paths of your Lord, dhululan - made humble, roads worn smooth by obedience (16:69). Every command spoken to her carries the feminine ending: ittakhidhi, kuli, usluki - take, eat, travel, each one closing on the -i Arabic uses when it speaks to a woman. The surah addresses its smallest receiver as she, one movement after grown men darkened at the news of a girl. The surah does not comment on the pairing; it only leaves it where you can see it. And then the output: “from their bellies comes a drink of varying colors, in which there is healing for people” (16:69). She is given flowers, and what she gives back is shifa - not for herself; lil-nas, for people. She keeps almost none of what she makes. The Imams kept prescribing her output for centuries: “People have never sought cure in anything like honey,” said Imam al-Sadiq (a), and Amir al-Mu'minin (a) taught - quoting this very verse - that a taste of honey is a healing from every illness (al-Kafi). That is the mark of the right receiver, and the reason the Surah of Blessings carries her name and not the name of the ocean or the stars: of everything in the catalogue, she is the one shown taking her Lord's instructions line by line - and the gift, passing through her, becomes healing for someone else."
            ),
            .verse(
                act: 3, tag: "The Third Belly", surah: 16, ayah: 78,
                arabic: "وَٱللَّهُ أَخْرَجَكُم مِّنۢ بُطُونِ أُمَّهَٰتِكُمْ لَا تَعْلَمُونَ شَيْـًۭٔا وَجَعَلَ لَكُمُ ٱلسَّمْعَ وَٱلْأَبْصَٰرَ وَٱلْأَفْـِٔدَةَ ۙ لَعَلَّكُمْ تَشْكُرُونَ",
                translation: "And Allah brought you out of the bellies of your mothers knowing nothing; and He made for you hearing, and sight, and hearts - that perhaps you would be grateful.",
                reference: "al-Nahl · 16 : 78",
                reflection: "The third belly is your mother's, and the thing that emerged from it was you. Note the one phrase the Qur'an attaches: la ta'lamuna shay'a - knowing nothing at all. The bee left her cell already knowing the paths; the calf found the udder within the hour. You alone, of all the receivers in the catalogue, arrived unfinished - and were handed three instruments instead of instincts: hearing, sight, and af'ida, the hearts that weigh what the senses bring in. Then the verse states, in one phrase, what the equipment is for: la'allakum tashkurun - that perhaps you would be grateful. Not “that you might survive.” Not “that you might achieve.” The ear, the eye and the heart are issued, this verse says, for gratitude - the ear to hear the Word, the eye to read the catalogue, the heart to trace every gift in it back to its Giver. Now stand the three bellies side by side, as the surah has quietly arranged them. Out of the first came milk - pure. Out of the second came healing - for others. Out of the third came you, knowing nothing - and what finally leaves your life is the only one of the three still being decided. The bee had no choice in her obedience; that is why the Qur'an calls her paths humbled, and why no bee is ever praised for them. You were given a Book and a choice. That is the entire difference between instinct and worship - and the reason your gratitude, unlike hers, can be counted as worship."
            ),

            // ── Movement IV · al-Baqi (What Remains) ──────────────────────────
            .act(
                act: 4,
                connector: "Out of three bellies: milk, then healing, then you - the one still unfinished.",
                line: "The surah has shown the gift, and the two ways of receiving it. What remains is to show where the two roads end - and it does this the way it does everything: with lives, not lectures. Three lives now. A man whose own community said he had left the faith. A city fed from every direction at once. And one old man, standing alone.",
                bridge: BridgeVerse(
                    surah: 16, ayah: 96,
                    arabic: "مَا عِندَكُمْ يَنفَدُ ۖ وَمَا عِندَ ٱللَّهِ بَاقٍۢ ۗ وَلَنَجْزِيَنَّ ٱلَّذِينَ صَبَرُوٓا۟ أَجْرَهُم بِأَحْسَنِ مَا كَانُوا۟ يَعْمَلُونَ",
                    translation: "What is with you runs out; and what is with Allah remains. And We will surely pay those who were patient their wage by the best of what they used to do.",
                    reference: "al-Nahl · 16 : 96"
                )
            ),
            .verse(
                act: 4, tag: "What Cannot Be Confiscated", surah: 16, ayah: 106,
                arabic: "مَن كَفَرَ بِٱللَّهِ مِنۢ بَعْدِ إِيمَٰنِهِۦٓ إِلَّا مَنْ أُكْرِهَ وَقَلْبُهُۥ مُطْمَئِنٌّۢ بِٱلْإِيمَٰنِ وَلَٰكِن مَّن شَرَحَ بِٱلْكُفْرِ صَدْرًۭا فَعَلَيْهِمْ غَضَبٌۭ مِّنَ ٱللَّهِ وَلَهُمْ عَذَابٌ عَظِيمٌۭ",
                translation: "Whoever disbelieves in Allah after his faith - except one who is compelled, while his heart is at rest with faith - but whoever opens his breast wide to disbelief, upon them is wrath from Allah, and theirs is a great punishment.",
                reference: "al-Nahl · 16 : 106",
                reflection: "Mecca, the torture years. Majma al-Bayan records the scene under this verse: a handful of believers with no tribe to shield them - Ammar, his father Yasir, his mother Sumayya, with Bilal, Khabbab and Suhayb - seized and tortured in the open. Ammar's father and mother were killed; among the reports Majma al-Bayan gathers is one that remembers them as the first two martyrs of this faith. And Ammar - broken over their bodies - gave the torturers with his tongue the words they demanded. The whisper ran through the community: Ammar has disbelieved. The Prophet's ﷺ answer was immediate: “Never. Ammar is filled with faith from his crown to his feet - faith is mingled with his flesh and his blood.” Then Ammar himself came, weeping. “What is behind you?” the Prophet ﷺ asked. “Evil, O Messenger of Allah - I did not stop until I spoke against you, and praised their gods.” And the Prophet ﷺ, wiping Ammar's eyes, said: “If they return to you - give them again what you said” (Majma al-Bayan). And heaven wrote the pardon into the Book permanently: illa man ukriha - except one compelled - wa qalbuhu mutma'innun bil-iman - while his heart is at rest with faith. From this verse the school of the Ahl al-Bayt draws the ruling of taqiyya: when tyranny forces the tongue, the tongue's words are not held against him, so long as the heart stands. But hear the word the verse chose for that standing heart: mutma'inn - at rest, settled, unshaken. Everything confiscatable had been confiscated from this man: father, mother, safety, and finally the words of his own mouth. What was left was the one thing no hand can reach: a heart at rest with its faith. The verse then names the real crime, and it is not Ammar's: “whoever opens his breast wide to disbelief” - sharaha bil-kufri sadra, denial welcomed in, given the whole chest. In this surah's reckoning of a life, what counts is kept in the chest - and no torturer has ever reached it."
            ),
            .verse(
                act: 4, tag: "The Garment of Hunger", surah: 16, ayah: 112,
                arabic: "وَضَرَبَ ٱللَّهُ مَثَلًۭا قَرْيَةًۭ كَانَتْ ءَامِنَةًۭ مُّطْمَئِنَّةًۭ يَأْتِيهَا رِزْقُهَا رَغَدًۭا مِّن كُلِّ مَكَانٍۢ فَكَفَرَتْ بِأَنْعُمِ ٱللَّهِ فَأَذَٰقَهَا ٱللَّهُ لِبَاسَ ٱلْجُوعِ وَٱلْخَوْفِ بِمَا كَانُوا۟ يَصْنَعُونَ",
                translation: "And Allah presents a parable: a town that was safe, at rest, its provision coming to it in plenty from every place - then it denied the blessings of Allah, so Allah made it taste the garment of hunger and fear for what its people had been doing.",
                reference: "al-Nahl · 16 : 112",
                reflection: "Aminatan mutma'inna - safe, and at rest. Stop on that second word, because you have heard it before. One movement ago it described a heart: the tortured man, stripped of everything, mutma'inn with faith. Here it describes a city: fed from every direction, mutma'inna on its provisions. In all one hundred and twenty-eight verses, the surah speaks this word exactly twice - once for a man who had nothing but God, once for a town that had everything but gratitude. That pair is the movement's whole question, laid side by side: what is your rest actually resting on? The town's answer was its supply lines - rizq raghad, provision in easy plenty, min kulli makan, from every place; every trade wind blew inward. Then comes the surah's signature verb, in a rare plural form: fa-kafarat bi-an'umi Allah - the town covered over God's an'um, His assembled blessings. And the sentence that follows is dressed in a deliberately impossible image: God made the town taste the garment of hunger and fear - deprivation you swallow and wear at once, inside and out, at the table and at the door. The reports give the parable a face. Al-Kafi relays from Imam al-Sadiq (a) a people who lived on a river called the Tharthar. Their land was fertile, their goods overflowed. Bread grew so cheap that they used it to clean their children - it was softer, they said - until a mountain of thrown-away bread stood among them. They had covered over God's an'um. So He held back the river, and the rain with it. Famine drove them back to that same mountain, to weigh out on scales the bread they had discarded (al-Kafi, bab fadl al-khubz; Tafsir al-Qummi places the story under this verse). And al-Mizan is careful to keep the parable's door open: the surah presents the town as a mathal, a pattern - not one address on a map, but every address that ever mistook the plenty for the ground. Notice exactly what was repossessed: amn and itmi'nan - safety and rest, the two things the town believed its abundance had purchased. Ingratitude did not merely lose the town its extras. It lost the town the very ground it thought it stood on - because rest built on the gifts falls when the gifts are lifted, and the gifts were only ever a loan. The difference was never in what they held."
            ),
            .verse(
                act: 4, tag: "The Grateful Man", surah: 16, ayah: 121,
                arabic: "شَاكِرًۭا لِّأَنْعُمِهِ ۚ ٱجْتَبَىٰهُ وَهَدَىٰهُ إِلَىٰ صِرَٰطٍۢ مُّسْتَقِيمٍۢ",
                translation: "Grateful for His blessings - He chose him, and guided him to a straight path.",
                reference: "al-Nahl · 16 : 121",
                reflection: "After the town, one man. “Indeed Ibrahim was an umma” - the verse before this one says it without blinking: he was a nation, one man counted as a whole people - “devoutly obedient to Allah, turning wholly to Him, and he was not of those who assign partners” (16:120). A whole city of receivers has just fallen, counted as one ungrateful thing. Now one man is counted as an entire people. And this verse gives the reason in its opening word - the reason the surah has been building toward for a hundred and twenty verses: shakiran li-an'umihi. Grateful for His an'um - that rare plural again. In the entire Qur'an, the word an'um occurs exactly twice - and both times are in this surah, nine verses apart: a town that denied the an'um, and a man who was grateful for them. The Surah of Blessings has run its full experiment and posted both results side by side: nations, in this Book, are not counted by census. A denying multitude summed to zero; a grateful man summed to an umma. And the verbs arrive in an order worth sitting with: shakiran... ijtabahu... hadahu. Grateful - so He chose him, and guided him to a straight path. The gratitude is listed before the choosing. It was not a receipt Ibrahim (a) signed after being chosen. It was the ground the choosing grew out of. And then the surah turns to its own first listener: “Then We revealed to you: follow the milla of Ibrahim, turning wholly to God” (16:123) - his milla, his way. The Prophet ﷺ - standing in a city drowning in gifts it denied, a city this movement may have just described - is told: your lineage is not this town. It is the grateful man. And through him, neither is yours."
            ),
            .climax(
                act: 4, tag: "The Two-Word Promise",
                source: "al-Nahl · 16 : 97",
                arabic: "مَنْ عَمِلَ صَٰلِحًۭا مِّن ذَكَرٍ أَوْ أُنثَىٰ وَهُوَ مُؤْمِنٌۭ فَلَنُحْيِيَنَّهُۥ حَيَوٰةًۭ طَيِّبَةًۭ ۖ وَلَنَجْزِيَنَّهُمْ أَجْرَهُم بِأَحْسَنِ مَا كَانُوا۟ يَعْمَلُونَ",
                translation: "Whoever does righteousness, man or woman, while they are a believer - We will surely give them to live a good life; and We will surely pay them their wage by the best of what they used to do.",
                body: "One question is left, and it has been under every beat of this descent. The surah counted what cannot be counted. It watched a gift pressed into the dust and a favor denied at the table. It followed milk and honey out of dark interiors, and stood a tortured heart beside a fed city. All of it circles a single thing the surah has not yet said plainly. What, then, is the good life? What would it mean to have actually received? The answer was given back before Ammar, back before the town - and the descent saved it for the summit. You read its twin at the door of this movement: 16:96 promised the wage. This verse names the life. To anyone who works righteousness with faith standing in the chest, God makes a promise in His most emphatic grammar - fa-la-nuhyiyannahu - then We will surely, surely give him to live... hayatan tayyiba. A good life. Two words - and no third word saying rich, or easy, or long. Centuries of readers have asked what exactly He promised. Amir al-Mu'minin (a) was asked directly, and Nahj al-Balagha preserves his answer, one word long: “Hiya al-qana'a.” It is contentment. Tabrisi relays the same reading lifted all the way to the Prophet ﷺ, and Tafsir al-Qummi glosses it the same way: contentment with what God has provided (Nahj al-Balagha, hikma 229; Majma al-Bayan; Nur al-Thaqalayn).",
                reflection: "One word, and the whole surah locks into place. The town had the provisions - easy plenty, from every place - and it starved, because the good life was never in the plenty. Ammar had nothing left at all, and his heart was at rest - because the good life was already in the chest. Qana'a is not settling for less; it is the heart's agreement with the Giver - the gift received all the way down, traced back to its Source, and finally rested in. This is why the count at the top of the surah was designed to fail. You were never meant to finish counting the gifts; you were meant to look up from the counting and find the Giver - and the heart that finds Him is the only one that stops needing the total. And the promise carries one more mercy, easy to miss: min dhakarin aw untha - man or woman, both spelled out, in a surah that watched a father's face darken at the news of a girl. The door of the good life is written open to her by name. The good life is not the sum of what reaches you. It is the rest of a heart that knows Who it all reaches you from."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "The Return",
                prompt: "Which gift have you recognized - but never once carried back to Him?",
                placeholder: "A person, an ability, a rescue you filed under luck...",
                subline: "You came down through a surah that pours without pausing and watches what the receivers do. You watched recognition wear a cover, and you watched the smallest receiver in the Book turn her gift into healing for others. The count is unfinishable - the surah proved that in one verse - but the thanks can begin anywhere, tonight, with one gift. Name it. Then hand it back to the Giver in plain words, the way the bee walks her Lord's paths: simply, and without keeping the sweetness for yourself. That handing back is where the contentment the summit promised begins.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "Before You Go",
                titleAr: "النَّحْل",
                essence: "The Surah of Blessings is named for the smallest receiver in it - and that is its teaching in a single choice. The size of the gift was never the point; the receiving was. Kufr, in this surah's grammar, is pulling soil over a favor you have already recognized. Iman - faith - is the bee's way: take what He gives, walk His paths humbled, and let what leaves you heal somebody. And the good life He promises at the summit is not the uncountable catalogue - it is the heart that traced the catalogue home, and rested.",
                line: "Imam al-Baqir (a) taught that whoever recites Surah al-Nahl every month is spared debt in this world and seventy kinds of affliction - and his dwelling will be in the Garden of Eden, the heart of the Gardens (Thawab al-A'mal). Read it now in its own order, all one hundred and twenty-eight verses - the full catalogue this descent could only sample, the verse that tells you to ask the people of remembrance (16:43), the verse of justice and ihsan - doing beautiful good - that closes Friday sermons across the world (16:90), the woman who unravels her own spun thread (16:92). And when you reach the final verses, listen for a word you may remember. Al-Hijr closed by telling His Prophet ﷺ: We know your chest tightens - yadiqu sadruka - at what they say. Al-Nahl ends with the same word, carried one step further: “Do not grieve over them, and do not be in dayq - in tightness - at what they scheme” (16:127). And then the surah hands him, and you, its last and largest gift - the one entry in the catalogue that contains every other: “Indeed, Allah is with those who are mindful of Him, and those who do good” (16:128). There, He knew. Here, He is with. The Surah of Blessings saves the Giver's own company for its final line."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Nahl experience") {
    DeepDiveView(dive: .surahNahl, onClose: {})
}
#endif
