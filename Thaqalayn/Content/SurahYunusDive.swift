//
//  SurahYunusDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - Yunus" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/yunus-script.md.
//  Revised per the Stage 5 four-auditor audit (flow, sourcing/Arabic, readability,
//  voice & reverence).
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). A later translation pass
//  replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically, never hand-typed, to survive
//  the byte-for-byte check). No dua beat; ends on .closing, which hands off to
//  reading the full surah.
//
//  Spine: the timing of turning back. God defers judgment on purpose (10:11); people
//  give a perfect yes in the storm and take it back on the shore (Movement I); an
//  invitation stands open the whole time, and some answer it in fair weather
//  (Movement II, with the wali hadith qudsi as its summit); and the surah closes on
//  two mirrored scenes - Pharaoh's yes one wave too late, refused with a single
//  word, "Now?" (10:91), and the people of Yunus, the only city in history whose
//  turn came in time (climax 10:98). The surah is named for the exception - the
//  name itself is the payoff, revealed only at the climax.
//
//  Sourcing is Shia and verified: al-Mizan (Tabatabai), Majma al-Bayan (Tabrisi),
//  and Ahl al-Bayt narrations - Imam al-Baqir on 10:58 (fadl = the Messenger,
//  rahma = Ali, Majma al-Bayan) and Imam al-Rida's wilaya reading (al-Kafi); the
//  hadith qudsi on the wali (al-Kafi 2:352, al-Kafi's own wording); Imam al-Kazim's
//  seawater counsel to Hisham (Tuhaf al-Uqul); Imam al-Rida on Pharaoh's refused
//  iman (Uyun Akhbar al-Rida); the repentance ladder (al-Kafi 2:440, al-Sadiq from
//  the Prophet); the Nineveh account (Majma al-Bayan under 10:98, verified elements
//  only); Abu Basir's question to Imam al-Sadiq on the lifted decree (Ilal
//  al-Shara'i, via Nur al-Thaqalayn); the recitation merit (Thawab al-A'mal).
//  Honorifics on the Prophet ﷺ and the Imams (a). The Gabriel-mud narration at
//  10:90 is deliberately omitted.
//

import SwiftUI

extension DeepDive {
    static let surahYunus: DeepDive = DeepDive(
        id: "surah-yunus",
        titleEn: "Yunus",
        titleAr: "يُونُس",
        subtitle: "Jonah - how late is too late to turn back to God?",
        sfSymbol: "water.waves",
        estMinutes: 13,
        acts: [
            ActInfo(number: 1, ar: "رِيحٌ عَاصِفٌ", tr: "Rih Asif", name: "The Storm Wind"),
            ActInfo(number: 2, ar: "دَارُ السَّلَام", tr: "Dar al-Salam", name: "The Invitation"),
            ActInfo(number: 3, ar: "آلْآنَ", tr: "Al'ana", name: "Now?"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "يُونُس",
                titleEn: "Yunus",
                subtitle: "Jonah",
                line: "This surah has one hundred and nine verses - and the prophet it is named for appears in exactly one of them, near the very end, without saying a word. Why would the Qur'an give a whole surah the name of someone it barely mentions? The answer waits at the bottom of the descent, and it belongs to his people more than to him. Between here and there, the surah asks everyone in it the same question. By the end, it will be asking you."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "Yunus was revealed in Mecca, in the hardest years of the Prophet's ﷺ mission - and it is a surah about time. It watches people say yes to God at every moment a yes can be said: in fair weather, in the middle of the storm, and at the very last wave. And underneath everything, it keeps asking one question: when does a yes still count? God is patient - the sky does not fall the moment we deserve it to. But this surah is honest about what that patience is for, and about the moment the window it holds open closes.",
                leaveWith: "You will leave knowing the difference between the yes a storm forces out of you and the yes given freely while the sky is clear. And you will finally know why this surah, of all surahs, carries the name of Yunus."
            ),

            // ── Movement I · Rih Asif (The Storm Wind) ────────────────────────
            .act(
                act: 1, connector: nil,
                line: "Begin with a question you have surely asked: why does God wait? People do wrong in broad daylight, and nothing happens. The surah's first answer is that the waiting is not neglect. It is mercy, holding a window open. First watch what His patience is for. Then watch what we do inside it.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "If He Hastened", surah: 10, ayah: 11,
                arabic: "۞ وَلَوْ يُعَجِّلُ ٱللَّهُ لِلنَّاسِ ٱلشَّرَّ ٱسْتِعْجَالَهُم بِٱلْخَيْرِ لَقُضِىَ إِلَيْهِمْ أَجَلُهُمْ ۖ فَنَذَرُ ٱلَّذِينَ لَا يَرْجُونَ لِقَآءَنَا فِى طُغْيَٰنِهِمْ يَعْمَهُونَ",
                translation: "If Allah were to hasten evil for people the way they seek to hasten the good, their term would already have been fulfilled. But We leave those who do not look for the meeting with Us wandering blindly in their transgression.",
                reference: "Yunus · 10 : 11",
                reflection: "People pray for good and want it now. And when they are angry, they ask for harm just as fast - Tabrisi, in his commentary, gives an example every family knows: a parent loses their temper and says to a child, “may you be ruined.” Nobody means it. The verse says plainly what would happen if such prayers were granted at the speed we make them: our term would already be over. Not one of us would be left. Al-Mizan - Tabatabai's great commentary - puts the difference in one line: our asking runs on haste and ignorance; His answering is built on wisdom. So the punishment the deniers dare Him to send is not late. It is withheld - on purpose, with a purpose. Every hour you have ever been given is this verse, still holding the window open."
            ),
            .verse(
                act: 1, tag: "Sincere in the Storm", surah: 10, ayah: 22,
                arabic: "هُوَ ٱلَّذِى يُسَيِّرُكُمْ فِى ٱلْبَرِّ وَٱلْبَحْرِ ۖ حَتَّىٰٓ إِذَا كُنتُمْ فِى ٱلْفُلْكِ وَجَرَيْنَ بِهِم بِرِيحٍۢ طَيِّبَةٍۢ وَفَرِحُوا۟ بِهَا جَآءَتْهَا رِيحٌ عَاصِفٌۭ وَجَآءَهُمُ ٱلْمَوْجُ مِن كُلِّ مَكَانٍۢ وَظَنُّوٓا۟ أَنَّهُمْ أُحِيطَ بِهِمْ ۙ دَعَوُا۟ ٱللَّهَ مُخْلِصِينَ لَهُ ٱلدِّينَ لَئِنْ أَنجَيْتَنَا مِنْ هَٰذِهِۦ لَنَكُونَنَّ مِنَ ٱلشَّٰكِرِينَ",
                translation: "It is He who carries you over land and sea - until, when you are in ships sailing with a fair wind, rejoicing in it, a storm wind comes, and the waves come at them from every side, and they are certain they are surrounded. Then they call on Allah, sincere to Him in devotion: “If You save us from this, we will surely be among the thankful.”",
                reference: "Yunus · 10 : 22",
                reflection: "Halfway through, the verse changes who it is speaking to. It begins with you - “He carries you over land and sea” - and the moment the storm hits, it speaks of them, as if you were watching the ship from above. Under the waves, everything false is thrown off. No idol is called on in a sinking ship. The storm strips away every support people lean on, and what remains, in every human being, calls on God alone. The verse's word for it is mukhlisin - sincere, nothing else mixed in - the Qur'an's highest word for a pure heart, spoken here of drowning men. So the question was never whether you believe. The storm settles that. The question is the shore - because the very next verse says that the moment He saves them, they return to wronging the earth (10:23), as if no one had ever called out at all."
            ),
            .verse(
                act: 1, tag: "The Shore Is Not Safe", surah: 10, ayah: 24,
                arabic: "إِنَّمَا مَثَلُ ٱلْحَيَوٰةِ ٱلدُّنْيَا كَمَآءٍ أَنزَلْنَٰهُ مِنَ ٱلسَّمَآءِ فَٱخْتَلَطَ بِهِۦ نَبَاتُ ٱلْأَرْضِ مِمَّا يَأْكُلُ ٱلنَّاسُ وَٱلْأَنْعَٰمُ حَتَّىٰٓ إِذَآ أَخَذَتِ ٱلْأَرْضُ زُخْرُفَهَا وَٱزَّيَّنَتْ وَظَنَّ أَهْلُهَآ أَنَّهُمْ قَٰدِرُونَ عَلَيْهَآ أَتَىٰهَآ أَمْرُنَا لَيْلًا أَوْ نَهَارًۭا فَجَعَلْنَٰهَا حَصِيدًۭا كَأَن لَّمْ تَغْنَ بِٱلْأَمْسِ ۚ كَذَٰلِكَ نُفَصِّلُ ٱلْءَايَٰتِ لِقَوْمٍۢ يَتَفَكَّرُونَ",
                translation: "The life of this world is like water We send down from the sky: the plants of the earth drink it in, all that people and cattle eat - until, when the earth has taken on its ornament and is made beautiful, and its people are certain they have mastery over it, Our command comes to it by night or by day, and We make it a mown field, as if it had not flourished yesterday. Thus do We detail the signs for people who reflect.",
                reference: "Yunus · 10 : 24",
                reflection: "Why do we take the yes back the moment we reach the shore? Because the shore feels solid. So the surah paints the shore. A land drinks the rain until it is heavy with harvest. The verse says the earth puts on its zukhruf - its gold ornament - and its people grow certain, at last, that it is theirs. Then, “by night or by day,” it is a mown field, cut flat, as if yesterday had never happened. Calm water is not evil. It is dangerous for a different reason: it makes you forget everything the storm taught you. Imam al-Kazim (a) said this world is like seawater: the more a thirsty man drinks of it, the thirstier he becomes, until it kills him. The storm-yes was sincere. That was never its flaw. It was tied to the weather - and the surah now shows you a yes tied to something that does not change."
            ),

            // ── Movement II · Dar al-Salam (The Invitation) ───────────────────
            .act(
                act: 2,
                connector: "You have seen the yes that only a storm can pull out, and the shore that quietly takes it back.",
                line: "Now hear what stands over every storm and every shore alike. While people bargain with Him wave by wave - save me, and I will be thankful - God is doing something no storm had to prompt. He is inviting. And listen to the name He gave the home He invites you to. The people in the ship were begging for safety. The house He holds open is called Peace.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Standing Invitation", surah: 10, ayah: 25,
                arabic: "وَٱللَّهُ يَدْعُوٓا۟ إِلَىٰ دَارِ ٱلسَّلَٰمِ وَيَهْدِى مَن يَشَآءُ إِلَىٰ صِرَٰطٍۢ مُّسْتَقِيمٍۢ",
                translation: "And Allah invites to the Home of Peace, and guides whom He wills to a straight path.",
                reference: "Yunus · 10 : 25",
                reflection: "Tabrisi pauses on where this verse sits: directly after the harvest that vanished overnight. The order is deliberate. First God shows you that every shore is temporary. Then, before the unease can even settle, He opens the one place that is not - and He does not wait to be asked. The verse gives two gifts, not one. The invitation goes out to everyone: no storm required, no crisis needed; it is simply there, open, addressed to you now. The guidance is the second gift: for those who accept, He does not only show the road, He helps you walk it. The storm made people call out to Him once. The invitation asks for something harder, and better: come while the sky is clear."
            ),
            .verse(
                act: 2, tag: "The Command to Rejoice", surah: 10, ayah: 58,
                arabic: "قُلْ بِفَضْلِ ٱللَّهِ وَبِرَحْمَتِهِۦ فَبِذَٰلِكَ فَلْيَفْرَحُوا۟ هُوَ خَيْرٌۭ مِّمَّا يَجْمَعُونَ",
                translation: "Say: In the bounty of Allah and in His mercy - in that let them rejoice. It is better than all they amass.",
                reference: "Yunus · 10 : 58",
                reflection: "A verse just before this one names what has already been sent while the window stands open: counsel from your Lord, a healing for what is in the breasts - for the heart - a guidance, and a mercy (10:57). This is not the rescue people scream for in the storm. It is a cure for the forgetting itself - the disease the storm only briefly interrupts. And then comes a command the Qur'an gives almost nowhere else: rejoice. Not in what you have gathered. In His bounty and His mercy - and the verse says plainly that this is better than everything people pile up. The Ahl al-Bayt, the Prophet's ﷺ household, told us what the two words point to. Imam al-Baqir (a) said: the bounty of Allah is the Messenger of Allah ﷺ, and His mercy is Ali ibn Abi Talib (a). And Imam al-Rida (a) read the verse's ending the same way: rejoicing in the wilaya of Muhammad ﷺ and his family - the bond of love and following that ties you to them - is better than anything they amass. God's answer to a drowning world did not come as a change in the weather. It came as people: the Book in the hands of His Messenger ﷺ, and the household never parted from it."
            ),
            .verse(
                act: 2, tag: "No Fear, No Grief", surah: 10, ayah: 62,
                arabic: "أَلَآ إِنَّ أَوْلِيَآءَ ٱللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ",
                translation: "Unquestionably, the friends of Allah - no fear shall be upon them, nor shall they grieve.",
                reference: "Yunus · 10 : 62",
                reflection: "Here is what a person becomes when the yes is not hostage to the weather. The surah calls them awliya Allah, the friends of God, and the next verse says exactly who they are: those who believed, and stayed aware of Him (10:63) - in the calm, not only in the waves. Then look at what the verse takes away from them: fear, and grief. Exactly the two things the sea poured into everyone else. The people in the ship were full of both; the friends of God are free of both. Their yes was given long before any storm could demand it, so there is nothing left for the weather to take. And their reward does not wait for Paradise: Imam al-Baqir (a) said the glad tidings promised them in this life (10:64) include the true dream a believer sees. The waves still come to the friends of God. The fear does not."
            ),
            .narration(
                act: 2, tag: "The Friendship",
                source: "Hadith Qudsi · al-Kafi",
                body: "In al-Kafi, the oldest of the Shia hadith collections, God Himself describes what this friendship is. First a warning: “Whoever humiliates a friend of Mine has declared war on Me.” Then a promise, and it is among the most intimate lines in all the hadith: “My servant keeps drawing near to Me with voluntary acts until I love him - and when I love him, I am the hearing with which he hears and the sight with which he sees.” A servant walks toward God through small acts no law demanded of him - and the nearness does not stay one-sided. It becomes love. And when it does, nothing of that servant's hearing or seeing is left outside God's care.",
                reflection: "Now the verse you just read makes plain sense. What could a storm threaten, when the eyes that watch it and the ears that hear it are kept by the One who sends and stills every wind? No fear upon them, and they do not grieve - not because the waves spare the friends of God, but because nothing the waves can reach is theirs alone anymore."
            ),

            // ── Movement III · Al'ana (Now?) ──────────────────────────────────
            .act(
                act: 3,
                connector: "You have seen the invitation that stands over every storm, and the friends who answered it while the sky was clear.",
                line: "But the surah will not let the question stay comfortable. An invitation that stands open must also have a moment when it closes - and the surah's final stretch walks into that moment twice. Once it follows an army into the sea. Once it stands over a city, under a sky already going dark. Two peoples, out of time. Only one of them is spared.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "The Last Wave", surah: 10, ayah: 90,
                arabic: "۞ وَجَٰوَزْنَا بِبَنِىٓ إِسْرَٰٓءِيلَ ٱلْبَحْرَ فَأَتْبَعَهُمْ فِرْعَوْنُ وَجُنُودُهُۥ بَغْيًۭا وَعَدْوًا ۖ حَتَّىٰٓ إِذَآ أَدْرَكَهُ ٱلْغَرَقُ قَالَ ءَامَنتُ أَنَّهُۥ لَآ إِلَٰهَ إِلَّا ٱلَّذِىٓ ءَامَنَتْ بِهِۦ بَنُوٓا۟ إِسْرَٰٓءِيلَ وَأَنَا۠ مِنَ ٱلْمُسْلِمِينَ",
                translation: "And We brought the Children of Israel across the sea, and Pharaoh and his hosts pursued them in tyranny and enmity - until, when the drowning overtook him, he said: “I believe that there is no god but the One the Children of Israel believe in, and I am of those who submit.”",
                reference: "Yunus · 10 : 90",
                reflection: "Look closely at what Pharaoh has just watched: the sea standing open like a corridor, an entire people walking through it on dry ground. He has seen, with his own eyes, exactly Who is acting. And he rides in anyway - “in tyranny and enmity” - as if the miracle were one more thing he could conquer. Then the water closes. And out of the drowning comes a declaration of faith - a full one, on its face: no god but Him, and I submit. But listen to it once more. Even now, he does not quite address God. He had spent a lifetime saying “I am your highest lord” (79:24); at the end, the only way he can name God is as somebody else's - “the One the Children of Israel believe in.” He has no words of his own left for surrender. It is the storm-yes from the beginning of the surah, said one wave too late. And this time, an answer comes back."
            ),
            .verse(
                act: 3, tag: "Now?", surah: 10, ayah: 91,
                arabic: "ءَآلْـَٰٔنَ وَقَدْ عَصَيْتَ قَبْلُ وَكُنتَ مِنَ ٱلْمُفْسِدِينَ",
                translation: "Now? When you disobeyed before, and were one of the corrupters?",
                reference: "Yunus · 10 : 91",
                reflection: "One word in Arabic - Al'ana. “Now?” Imam al-Rida (a) was asked why this faith was refused, and answered: because he believed at the sight of doom, and faith at the sight of doom is not accepted. Al-Mizan explains why. When the punishment is already upon you and there is no way out, saying yes is not a decision anymore; it is forced out of you - and faith that is forced is not faith. So where exactly does the line fall? In al-Kafi, Imam al-Sadiq (a) relates the answer from the Prophet ﷺ: whoever repents a year before his death is accepted. Then he said: a year is much - a month is enough. A month is much - a week. A week is much - a day. And then, the final measure: whoever repents before he sees death, Allah accepts his repentance. The window stays open the whole length of a life. Pharaoh did not run out of mercy. He ran out of moments in which a yes could still mean anything."
            ),
            .verse(
                act: 3, tag: "The Body", surah: 10, ayah: 92,
                arabic: "فَٱلْيَوْمَ نُنَجِّيكَ بِبَدَنِكَ لِتَكُونَ لِمَنْ خَلْفَكَ ءَايَةًۭ ۚ وَإِنَّ كَثِيرًۭا مِّنَ ٱلنَّاسِ عَنْ ءَايَٰتِنَا لَغَٰفِلُونَ",
                translation: "So today We save you - in your body - that you may be a sign for those after you. And indeed many among the people are heedless of Our signs.",
                reference: "Yunus · 10 : 92",
                reflection: "There is mercy in the wording, and there is severity, and they are the same words. God uses the very thing Pharaoh begged for: “We save you.” Then He completes the sentence: “in your body” - the only part of Pharaoh left that could still be saved. Tafsir al-Qummi, one of the earliest Shia commentaries, narrates that the sea was commanded to cast the body onto the shore, so that the people he had enslaved could look at him, lifeless, and be certain. Al-Mizan draws the quiet lesson from those two words: a human being is more than a body, and the rest of Pharaoh - the part that mattered - had already gone where rescue could not reach. So the king who called himself the highest lord was kept and preserved as a sign for whoever came after; three thousand years later, the body is still here, and the empire is not. But the verse ends by turning to everyone else: “many among the people are heedless of Our signs.” Pharaoh became a sign for those after him because he could not read his own in time. One city, far from Egypt, was about to read theirs."
            ),
            .narration(
                act: 3, tag: "The City That Turned",
                source: "Majma al-Bayan (Tabrisi) · under 10 : 98",
                body: "Far from Egypt, in the city of Nineveh, another people had reached the end of their term. Their prophet, Yunus (a), had warned them; they had refused; and he had left them - the Qur'an tells that story in its own place. Now the punishment was no longer only a warning. It was visible: a darkness gathering over the city. Majma al-Bayan, the great commentary of Tabrisi, tells what they did with their final hours. They looked for their prophet, and he was gone. And so, with no messenger left to plead for them, an entire city turned at once. They poured out onto the open plain - men, women, children, even their animals. They put on rough sackcloth. They separated every mother from her child, human and beast alike, until the crying of the young and the calling of the mothers rose and mingled into one sound. It is related that their repentance ran so deep that a man would pull a wrongly taken stone out of the very foundation of his own house to give it back. And they wept, and believed, and begged their Lord - with the darkness still overhead.",
                reflection: "Hold the two scenes side by side, because the surah built them to be held together. Pharaoh under the water, past the point of return - and Nineveh under the cloud, one step before it. Both had refused for years. Both turned only when they saw. The difference between them is a single question of time: the punishment had already overtaken Pharaoh, and it had not yet fallen on Nineveh. One verse now waits to tell you what that difference meant - and what it has to do with the name this surah carries."
            ),
            .climax(
                act: 3, tag: "The Only City", source: "Yunus · 10 : 98",
                arabic: "فَلَوْلَا كَانَتْ قَرْيَةٌ ءَامَنَتْ فَنَفَعَهَآ إِيمَٰنُهَآ إِلَّا قَوْمَ يُونُسَ لَمَّآ ءَامَنُوا۟ كَشَفْنَا عَنْهُمْ عَذَابَ ٱلْخِزْىِ فِى ٱلْحَيَوٰةِ ٱلدُّنْيَا وَمَتَّعْنَٰهُمْ إِلَىٰ حِينٍۢ",
                translation: "Why was there not a single city that believed, and its faith benefited it - except the people of Yunus? When they believed, We lifted from them the punishment of disgrace in the life of this world, and gave them enjoyment for a time.",
                body: "The verse asks a grieving question, and carves out one exception: why was there not a single city that believed in time... except the people of Yunus. Al-Mizan explains what makes them the exception. Every other people in this surah waited until the punishment was upon them - and by then, saying yes was no longer a choice. The people of Yunus believed while they could still have said no, and that is why their faith was allowed to count. Then comes one of the most astonishing sentences in the Qur'an: We lifted from them the punishment. The decree was real. The darkness was already overhead. And it was turned aside - dispersed onto the mountains, the narrations say - because a city turned back to God, weeping, while there was still time. When Abu Basir asked Imam al-Sadiq (a) why they alone were spared this way, he answered: it was in God's knowledge that He would turn it away from them, for their repentance. “Allah erases what He wills, and makes firm what He wills” (13:39). Not every decree is sealed. Some are written conditionally - hinged on what you will do. And now, at last, the name. Of everything in these one hundred and nine verses, the surah is named for Yunus (a) - the prophet of the one city whose turning was accepted. As if the name itself were the message: it has been done. It can be done. The window is real.",
                reflection: "Every scene of the surah has been aimed here. The patience of the opening - this is what it was holding the window open for. The storm-yes that dried up on the shore - offered earlier, and freely, this is what it could have become. The “Now?” that closed over Pharaoh - for you, that same window is still open. The surah of the too-late yes is named, deliberately, for the just-in-time one. And what it asks of you is both gentle and severe: you are not reading about cities. You are one. If there is a turning you have been postponing for a better season, the decree over it is still conditional - still hinged on what you will do."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "Which yes are you saving for a storm?",
                placeholder: "A prayer, an apology, a habit, a debt, a return you keep postponing…",
                subline: "You have walked the whole argument. God's patience, holding the window open. The yes the waves forced out, and the shore that took it back. The invitation to the Home of Peace. The friends who answered while the sky was clear. And two peoples who answered late: one under the water, one under the cloud. The difference between them was time. Before you go, name the turning you have been saving for a harder day - while the word “now” still belongs to you.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "يُونُس",
                essence: "The surah's last verse turns to the Prophet ﷺ: “Be patient, until Allah judges - and He is the best of judges” (10:109). The surah opened with God's patience, holding the sky back; it closes by asking patience of you, until He judges. Between His patience and yours there is a window - and one city that used it.",
                line: "Imam al-Sadiq (a) taught that for whoever recites Surah Yunus even once every two or three months, it need never be feared that he is among the ignorant - and on the Day of Resurrection he will be among those drawn near. Read it now in its own words, all one hundred and nine verses - and hear the question it keeps asking, while it is still being asked gently."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah Yunus experience") {
    DeepDiveView(dive: .surahYunus, onClose: {})
}
#endif
