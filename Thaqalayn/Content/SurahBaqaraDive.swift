//
//  SurahBaqaraDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Baqara" experience. Rendered by
//  DeepDiveView; see docs/plans/surah-experience/baqara-script.md (approved master copy).
//
//  Slice, not full coverage: al-Baqara is 286 verses, so this dive takes one narrative
//  slice - the story that names the surah (2:67-74) - read as a mirror, with Ibrahim's
//  submission (2:131) as the answering foil. Structure is TWO movements + a label-less
//  coda (the story has one natural hinge, the reveal at 2:72; Ibrahim is a foil, not a
//  third act). The coda beats carry act: 3, which is not declared in `acts:`, so
//  DeepDiveView.placeInfo returns nil and they render with no "Movement" chrome.
//
//  English-only for now: every LocalizedText is a bare string literal (ur/ar fall back
//  to English via LocalizedText.text(for:)). Qur'an Arabic is verbatim from
//  quran_data.json (patched in programmatically to survive the byte-for-byte check).
//
//  Sourcing is Shia and verified: al-Mizan (Tabatabai), Majma al-Bayan (Tabrisi), and
//  narrations of the Ahl al-Bayt (Imam al-Sadiq, Imam al-Kazim - alayhim al-salam).
//

import SwiftUI

extension DeepDive {
    static let surahBaqara: DeepDive = DeepDive(
        id: "surah-baqara",
        titleEn: "al-Baqara",
        titleAr: "الْبَقَرَة",
        subtitle: "The Cow - why the mightiest surah bears so plain a name",
        sfSymbol: "hands.sparkles.fill",
        estMinutes: 11,
        acts: [
            ActInfo(number: 1, ar: "السُّؤَال", tr: "al-Su'al", name: "The Asking"),
            ActInfo(number: 2, ar: "الْآيَة", tr: "al-Aya", name: "The Sign"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "الْبَقَرَة",
                titleEn: "al-Baqara",
                subtitle: "The Cow",
                line: "Two hundred and eighty-six verses - the longest surah in the Qur'an, a whole world of law, covenant, and guidance. And of every name it could have carried, God gave it this one: al-Baqara, The Cow. Why would the mightiest chapter of the Book be named after a single, strange command to slaughter a cow?"
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "The answer is a story, one of the strangest in the Qur'an. God gives the Children of Israel a command so simple a child could obey it in an afternoon. And instead of obeying, they talk. They question, they qualify, they ask again, until the easiest thing in the world has become nearly impossible. And that, it turns out, is the whole point.",
                leaveWith: "You will leave seeing why this small, strange episode names the greatest surah in the Book - because it was never really about a cow. It is a mirror held up to every one of us. And one short verse, a few pages on, will land as the answer to everything the cow lays bare."
            ),
            .act(
                act: 1, connector: nil,
                line: "It begins with a prophet and a plain command. Musa comes to his people with a single instruction from God: slaughter a cow. No cow in particular. Any cow would do. What happens next is not rebellion, and not open refusal. It is something quieter, and far more familiar. They begin to ask questions.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "A Plain Command", surah: 2, ayah: 67,
                arabic: "وَإِذْ قَالَ مُوسَىٰ لِقَوْمِهِۦٓ إِنَّ ٱللَّهَ يَأْمُرُكُمْ أَن تَذْبَحُوا۟ بَقَرَةًۭ ۖ قَالُوٓا۟ أَتَتَّخِذُنَا هُزُوًۭا ۖ قَالَ أَعُوذُ بِٱللَّهِ أَنْ أَكُونَ مِنَ ٱلْجَٰهِلِينَ",
                translation: "And when Moses said to his people, “God commands you to slaughter a cow,” they said, “Are you making fun of us?” He said, “I seek refuge in God from being one of the ignorant.”",
                reference: "al-Baqara · 2 : 67",
                reflection: "Notice their very first response to a command from God: not “how?” but “are you mocking us?” Majma al-Bayan reads their offense as the tell of a sick heart. They could not imagine that so plain a thing might carry any wisdom, so they assumed it must be a joke. And notice Musa. He does not argue, and he does not defend God, who needs no defense. He simply seeks refuge from being one of the ignorant, because to meet a command of God with ridicule, Imam al-Sadiq (alayhi al-salam) taught, is itself where ignorance begins."
            ),
            .verse(
                act: 1, tag: "What Kind?", surah: 2, ayah: 68,
                arabic: "قَالُوا۟ ٱدْعُ لَنَا رَبَّكَ يُبَيِّن لَّنَا مَا هِىَ ۚ قَالَ إِنَّهُۥ يَقُولُ إِنَّهَا بَقَرَةٌۭ لَّا فَارِضٌۭ وَلَا بِكْرٌ عَوَانٌۢ بَيْنَ ذَٰلِكَ ۖ فَٱفْعَلُوا۟ مَا تُؤْمَرُونَ",
                translation: "They said, “Call on your Lord for us, to make clear what it is.” He said, “He says it is a cow neither old nor young, but middling between the two, so do what you are commanded.”",
                reference: "al-Baqara · 2 : 68",
                reflection: "The command was already complete. Any cow would have done. But instead of picking up the knife, they ask for a specification, and God answers: a cow of middle age. Al-Mizan draws out the quiet point that governs the whole story - had they slaughtered any cow the moment they were told, it would already be finished. Their question was not a sin. It simply opened a door, and once the door was open, each answer narrowed the road behind them. Hear, too, how they speak: “your Lord,” not “our Lord.” Already a small step back, as though God were Musa's business and not their own."
            ),
            .verse(
                act: 1, tag: "What Color?", surah: 2, ayah: 69,
                arabic: "قَالُوا۟ ٱدْعُ لَنَا رَبَّكَ يُبَيِّن لَّنَا مَا لَوْنُهَا ۚ قَالَ إِنَّهُۥ يَقُولُ إِنَّهَا بَقَرَةٌۭ صَفْرَآءُ فَاقِعٌۭ لَّوْنُهَا تَسُرُّ ٱلنَّٰظِرِينَ",
                translation: "They said, “Call on your Lord for us, to show us her color.” He said, “He says she is a yellow cow, bright in color, pleasing to those who look at her.”",
                reference: "al-Baqara · 2 : 69",
                reflection: "Now the color, a detail that has nothing to do with the command and everything to do with delay. And the answer tightens again: not just yellow, but a vivid, flawless yellow, pleasing to the eye - in their world, a rare and costly animal. When they went on to say, “all cows look alike to us, and if God wills, we shall be guided,” even their piety had become a way to keep asking while sounding humble. Imam al-Sadiq (alayhi al-salam) named the principle underneath it all: God gives people the difficulty they go looking for."
            ),
            .verse(
                act: 1, tag: "The Last Question", surah: 2, ayah: 71,
                arabic: "قَالَ إِنَّهُۥ يَقُولُ إِنَّهَا بَقَرَةٌۭ لَّا ذَلُولٌۭ تُثِيرُ ٱلْأَرْضَ وَلَا تَسْقِى ٱلْحَرْثَ مُسَلَّمَةٌۭ لَّا شِيَةَ فِيهَا ۚ قَالُوا۟ ٱلْـَٰٔنَ جِئْتَ بِٱلْحَقِّ ۚ فَذَبَحُوهَا وَمَا كَادُوا۟ يَفْعَلُونَ",
                translation: "He said, “He says she is a cow not broken to plow the earth or water the field, sound, with no mark upon her.” They said, “Now you have brought the truth.” So they slaughtered her, though they almost did not.",
                reference: "al-Baqara · 2 : 71",
                reflection: "One command has become five conditions, and now only a single cow in all the land can meet them: never worked, never blemished, flawless. Hear what they say when the description is finally narrow enough - “now you have brought the truth,” as if every true answer before this had somehow not been. And then the verse's quietest and most devastating phrase: they slaughtered her, but they almost did not. Even cornered, with no question left to ask, obedience came hard. Al-Mizan notes they obeyed at last not because their hearts had softened, but because they had simply run out of excuses."
            ),
            .narration(
                act: 1, tag: "The Price",
                source: "Majma al-Bayan (Tabrisi); narrations of the Ahl al-Bayt",
                body: "There is a tradition about the one cow that finally fit. It belonged, they say, to a young man whose late father had left it to him and to his mother, the whole of their inheritance. When the people came desperate to buy it, he would not sell without his mother's leave, again and again, however high they raised the price. In the end they paid for that single cow its own weight in gold. The command had cost them a fortune, and every coin of it was a price they had set themselves, question by question.",
                reflection: "This is the strange arithmetic of resistance. The cow God asked for was free; the cow their questions built was ruinous. Nothing had changed but them. And so the surah lets us watch, in slow motion, a thing we would rather not see in ourselves: how often the weight of a command is not in the command at all, but in our search for a way around it."
            ),
            .act(
                act: 2,
                connector: "You have watched a simple command swell into a fortune, and a free thing become the hardest thing in the world.",
                line: "And now the surah does something you do not expect. It stops the story, turns, and speaks straight to them, to tell them what all of this was really for. Because none of them knew. Not while they argued over the color of a cow. There was something buried beneath this whole episode, and God is about to bring it up into the light.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Reveal", surah: 2, ayah: 72,
                arabic: "وَإِذْ قَتَلْتُمْ نَفْسًۭا فَٱدَّٰرَْٰٔتُمْ فِيهَا ۖ وَٱللَّهُ مُخْرِجٌۭ مَّا كُنتُمْ تَكْتُمُونَ",
                translation: "And when you killed a soul and cast the blame on one another over it, God was to bring out what you were hiding.",
                reference: "al-Baqara · 2 : 72",
                reflection: "Here is the floor giving way. There had been a murder. Al-Mizan and the narrations of the Ahl al-Bayt fill in what the verse compresses: a wealthy man killed by a relative who wanted his inheritance, the body left where it would fall on another tribe, and then the killer himself loudest among those crying for justice. A community was tearing itself apart with accusation, and no one could find the truth. This was the crisis under everything. The cow was never a riddle. It was God's answer to a murder, and they had spent all their questions delaying it."
            ),
            .verse(
                act: 2, tag: "Thus God Gives Life", surah: 2, ayah: 73,
                arabic: "فَقُلْنَا ٱضْرِبُوهُ بِبَعْضِهَا ۚ كَذَٰلِكَ يُحْىِ ٱللَّهُ ٱلْمَوْتَىٰ وَيُرِيكُمْ ءَايَٰتِهِۦ لَعَلَّكُمْ تَعْقِلُونَ",
                translation: "So We said, “Strike him with part of it.” Thus does God give life to the dead, and shows you His signs, that you might understand.",
                reference: "al-Baqara · 2 : 73",
                reflection: "They struck the dead man with a piece of the very cow they had so resented buying, and he lived. Long enough, the Ahl al-Bayt narrate, to name the one who had killed him, and then he returned to death. In a single instant, three things were done at once: a murder solved, a victim vindicated, and a whole people shown, with their own eyes, that God brings the dead back to life. The command they had treated as a joke turned out to hold justice for the murdered and a proof of the Resurrection in the same hand. “That you might understand.” The cow was always pointing past itself, at the God who can undo even death."
            ),
            .verse(
                act: 2, tag: "Harder Than Stone", surah: 2, ayah: 74,
                arabic: "ثُمَّ قَسَتْ قُلُوبُكُم مِّنۢ بَعْدِ ذَٰلِكَ فَهِىَ كَٱلْحِجَارَةِ أَوْ أَشَدُّ قَسْوَةًۭ ۚ وَإِنَّ مِنَ ٱلْحِجَارَةِ لَمَا يَتَفَجَّرُ مِنْهُ ٱلْأَنْهَٰرُ ۚ وَإِنَّ مِنْهَا لَمَا يَشَّقَّقُ فَيَخْرُجُ مِنْهُ ٱلْمَآءُ ۚ وَإِنَّ مِنْهَا لَمَا يَهْبِطُ مِنْ خَشْيَةِ ٱللَّهِ ۗ وَمَا ٱللَّهُ بِغَٰفِلٍ عَمَّا تَعْمَلُونَ",
                translation: "Then, after all that, your hearts hardened until they were like stones, or harder still. For there are stones from which rivers burst; and some that split so the water runs out; and some that fall down in awe of God. And God is not unaware of what you do.",
                reference: "al-Baqara · 2 : 74",
                reflection: "You would think a people who had just watched the dead sit up and speak could never doubt again. And the verse tells us: their hearts hardened. This is the most frightening line in the whole passage, because it says a miracle is not enough - that a heart can witness God's power directly and still turn to stone. Then God shames that stone with real stone: rock splits and rivers pour from it; boulders tremble and fall down for fear of Him. Even the mountains answer their Maker. Imam al-Sadiq and Imam Ali (alayhim al-salam) named what buries a heart so deep: a pile-up of sins, and a long forgetting of death. The danger was never that they lacked proof. It was that they had stopped letting anything in."
            ),
            .climax(
                act: 3, tag: "One Word", source: "al-Baqara · 2 : 131",
                arabic: "إِذْ قَالَ لَهُۥ رَبُّهُۥٓ أَسْلِمْ ۖ قَالَ أَسْلَمْتُ لِرَبِّ ٱلْعَٰلَمِينَ",
                translation: "When his Lord said to him, “Submit,” he said, “I have submitted to the Lord of all the worlds.”",
                body: "Hold the cow in your mind - the questions, the delay, the hardening - and now turn a few pages on, to the same surah, a different man, a different command. God says to Ibrahim one word: aslim. Submit. And before the word is even cold, Ibrahim answers: aslamtu. I have submitted, to the Lord of all the worlds. No “submit to what?” No “submit in what color?” One word from God, and one word back. This is the entire distance between a heart of stone and a heart alive, and the surah has set them side by side on purpose.",
                reflection: "The Children of Israel were asked once and answered with question after question, then obeyed grudgingly. Ibrahim was asked once and had already said yes. Al-Mizan calls his answer the very meaning of islam: not a ritual you perform, but a self you hand over. Everything the cow exposed - the flinching, the bargaining, the hunt for the exit - Ibrahim simply does not do. He is living proof that obedience was always the shortest road. It was only ever our questions that made it long."
            ),
            .narration(
                act: 3, tag: "Still Addressing You",
                source: "Narrations of the Ahl al-Bayt - Imam al-Sadiq, Imam al-Kazim (alayhim al-salam)",
                body: "Imam Ja'far al-Sadiq (alayhi al-salam) taught that when Ibrahim said “I have submitted,” he was not speaking for himself alone. He was speaking for everyone who would ever walk his path, the Prophet Muhammad ﷺ and the pure Imams among them. And Imam al-Kazim (alayhi al-salam) said the command has never once fallen silent: aslim, submit, is still being spoken, to you, now. The only thing the surah leaves open is which of the two answers will be yours.",
                reflection: "This is why the cow names the surah, and not the covenant, or the law, or the throne. Because al-Baqara is not telling you a curious old story about a people who argued with a prophet. It is holding up a mirror and asking, gently: when God asks something of you, and you already know the answer, why are you still asking questions?"
            ),
            .reflectionPrompt(
                tag: "The Return",
                prompt: "Where are you still asking questions?",
                placeholder: "A command you already understand, a change you keep qualifying, a step you keep putting off…",
                subline: "You have watched a free command turn ruinous, a murder undone by a mercy no one saw coming, and one man who simply said yes. Somewhere in your own life is a thing you already know God asks of you, and a set of questions you keep asking to postpone it. Name it. That is your cow.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "الْبَقَرَة",
                essence: "A whole surah named after a cow, to teach the one thing a prophet's people learned the hardest way: obedience was always the shortest road.",
                line: "That is the mirror hidden inside al-Baqara. Read the story now in its own words - the command, the questions, the sign, the stone - and then Ibrahim's single, sufficient word. And the next time God asks something plain of you, may you be the one who has already said: I have submitted."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Baqara experience") {
    DeepDiveView(dive: .surahBaqara, onClose: {})
}
#endif
