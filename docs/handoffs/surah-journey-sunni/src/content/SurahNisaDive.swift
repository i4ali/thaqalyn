//
//  SurahNisaDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Nisa" experience. Rendered by
//  DeepDiveView; see docs/plans/surah-experience/nisa-script.md (approved master copy).
//
//  Fresh rewrite from scratch (the earlier al-Nisa experience was withdrawn in
//  v7.4 (77) for comprehension; see commit f35b980 for the old text). Written plain:
//  short sentences, one idea per beat.
//
//  Slice, not full coverage: al-Nisa is 176 verses, so this dive takes the spine of
//  rights and authority - the charter and rights of the unguarded (4:1, 4:10, 4:19),
//  hinged at the Trust verse (4:58) into authority and obedience (4:59, 4:65), and
//  climaxing at the company of the favored (4:69), followed by a post-climax echo
//  narration that lands the Fatiha connection on its own screen (audit: two payoffs
//  must not stack on one beat). Structure is a TWO-movement diptych (no coda): the one
//  natural joint is 4:58, which holds both panels in a single line. Close beats carry
//  act: 4 (standard). Renders as "Depth N of 2" (dive.acts.count).
//
//  English-only for now: every LocalizedText is a bare string literal (ur/ar fall back
//  to English via LocalizedText.text(for:)). Qur'an Arabic is verbatim from
//  quran_data.json (patched in programmatically; verified via scripts/pull_arabic.py).
//  NOTE: the 4:1 arabic drops the Basmala prefix that quran_data.json glues onto every
//  surah's first verse (cut at the space boundary; the remainder is byte-identical to
//  the data file's tail). Same precedent as Fatiha's BOM strip on 1:1.
//
//  Sourcing is Shia and verified: al-Mizan (Tabatabai), Majma al-Bayan (Tabrisi),
//  al-Kafi (the Imamate as the trust, 4:58), Kamal al-Din (Jabir and the twelve, 4:59),
//  Bihar al-Anwar (the Father of Orphans), and the Thawban occasion under 4:69.
//

import SwiftUI

extension DeepDive {
    static let surahNisa: DeepDive = DeepDive(
        id: "surah-nisa",
        titleEn: "al-Nisa",
        titleAr: "النِّسَاء",
        subtitle: "The Women - the rights God wrote for the unguarded, and the hands He trusted to guard them",
        sfSymbol: "figure.2.and.child.holdinghands",
        estMinutes: 11,
        acts: [
            ActInfo(number: 1, ar: "الْمُسْتَضْعَفُون", tr: "al-Mustad'afun", name: "The Unguarded"),
            ActInfo(number: 2, ar: "الْأَمَانَة", tr: "al-Amana", name: "The Trust"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "النِّسَاء",
                titleEn: "al-Nisa",
                subtitle: "The Women",
                line: "The longest surahs carry the heaviest matters - law, war, inheritance, judgment. This one carries all of them: one hundred and seventy-six verses, the constitution of a newborn community. Of all the names it could have carried, God named it al-Nisa, The Women. Why would the great book of rights be named for the people its world gave no rights at all? Come inside and see."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "Remember the world these verses entered. A daughter could be buried alive on the day she was born. A widow passed to her husband's heirs like a piece of his furniture. An orphan's guardian could simply take the child's inheritance. Into that world God sent down a surah that, page after page, takes the side of the ones nobody defended. And then it turns and asks the question every law raises and no law can answer for itself: rights are written on paper - but whose hands can be trusted to guard them?",
                leaveWith: "You will leave knowing why the surah of the weak becomes the surah of the Trust - and one verse near its heart will hand you, by name, the answer to a prayer you have been praying every day of your life."
            ),
            .act(
                act: 1, connector: nil,
                line: "The surah opens with no throne and no army. It opens with the people no one would fight for - the daughter, the orphan, the widow - and it does something no code of law had ever done for them: it makes their protection the measure of the whole community. But first, before a single right is written, God levels the ground those rights will stand on.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "One Soul", surah: 4, ayah: 1,
                arabic: "يَٰٓأَيُّهَا ٱلنَّاسُ ٱتَّقُوا۟ رَبَّكُمُ ٱلَّذِى خَلَقَكُم مِّن نَّفْسٍۢ وَٰحِدَةٍۢ وَخَلَقَ مِنْهَا زَوْجَهَا وَبَثَّ مِنْهُمَا رِجَالًۭا كَثِيرًۭا وَنِسَآءًۭ ۚ وَٱتَّقُوا۟ ٱللَّهَ ٱلَّذِى تَسَآءَلُونَ بِهِۦ وَٱلْأَرْحَامَ ۚ إِنَّ ٱللَّهَ كَانَ عَلَيْكُمْ رَقِيبًۭا",
                translation: "O mankind, be mindful of your Lord, who created you from one soul, and created from it its mate, and spread from the two of them many men and women. And be mindful of God, in whose name you ask of one another, and of the wombs. Indeed God is ever watching over you.",
                reference: "al-Nisa · 4 : 1",
                reflection: "Before the surah gives anyone a right, it tells everyone where they came from: one soul. Every man and every woman ever born is cut from the same single self - no one from a higher kind of human, no one from a lower. Whatever the world does to the weak, it does to its own flesh. Then notice what God sets beside His own name: “be mindful of God - and of the wombs.” Mindfulness of Him, and care for your own kin, in a single breath. And the verse ends on the word the whole surah will stand under: Raqib. Watching. Every orphan's coin, every woman's dowry, every quiet injustice inside a household - watched."
            ),
            .verse(
                act: 1, tag: "Fire in Their Bellies", surah: 4, ayah: 10,
                arabic: "إِنَّ ٱلَّذِينَ يَأْكُلُونَ أَمْوَٰلَ ٱلْيَتَٰمَىٰ ظُلْمًا إِنَّمَا يَأْكُلُونَ فِى بُطُونِهِمْ نَارًۭا ۖ وَسَيَصْلَوْنَ سَعِيرًۭا",
                translation: "Indeed, those who consume the property of orphans unjustly are only swallowing fire into their bellies, and they will burn in a blazing flame.",
                reference: "al-Nisa · 4 : 10",
                reflection: "The orphan is the surah's test case: someone who owns something and can defend nothing. No parent to object, no witness who cares - the easiest person on earth to rob. So listen to how the verse speaks. It does not say the thief will one day be punished with fire. It says he is eating fire now - the stolen wealth in his stomach already is the flame, whether he feels it yet or not. Al-Mizan, the great commentary of Allamah Tabatabai, reads it just so: the punishment is not added to the sin later, the way a sentence follows a crime. The sin and its fire are one thing, and the Day of Judgment will only uncover it. And Imam al-Ridha (alayhi al-salam) gave the reason the verse speaks this fiercely: the orphan cannot defend himself, so God takes the case Himself. Where no advocate stands, He stands."
            ),
            .verse(
                act: 1, tag: "Not Yours to Inherit", surah: 4, ayah: 19,
                arabic: "يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ لَا يَحِلُّ لَكُمْ أَن تَرِثُوا۟ ٱلنِّسَآءَ كَرْهًۭا ۖ وَلَا تَعْضُلُوهُنَّ لِتَذْهَبُوا۟ بِبَعْضِ مَآ ءَاتَيْتُمُوهُنَّ إِلَّآ أَن يَأْتِينَ بِفَٰحِشَةٍۢ مُّبَيِّنَةٍۢ ۚ وَعَاشِرُوهُنَّ بِٱلْمَعْرُوفِ ۚ فَإِن كَرِهْتُمُوهُنَّ فَعَسَىٰٓ أَن تَكْرَهُوا۟ شَيْـًۭٔا وَيَجْعَلَ ٱللَّهُ فِيهِ خَيْرًۭا كَثِيرًۭا",
                translation: "O you who believe, it is not lawful for you to inherit women against their will. And do not press them so as to take back part of what you gave them, unless they commit a clear indecency. And live with them in kindness. For if you dislike them - it may be that you dislike a thing in which God has placed abundant good.",
                reference: "al-Nisa · 4 : 19",
                reflection: "In the world before these words, a widow was part of the estate: when a man died, his heirs inherited his wife the way they inherited his tent. This verse ends that with one line - a woman is a person, never property. She is no one's to own, and no one may pressure her out of her own dowry. Then the verse goes further than any court could: “live with them in kindness.” Be good to her, as law. The Ahl al-Bayt taught that the best of believers are the best to their wives. And for the marriage grown cold, one strange mercy: the thing you dislike may be the very place God has hidden abundant good."
            ),
            .narration(
                act: 1, tag: "The Father of Orphans",
                source: "Imam Ali ibn Abi Talib (alayhi al-salam) · accounts in Bihar al-Anwar",
                body: "These verses had a face. In Kufa, after dark, a man moved between the poorest doorways with a sack of food on his back - bread, dates, flour - and was gone before anyone could thank him. He was the caliph. One day he met a widow hauling a waterskin on her shoulder; he carried it home for her, and heard her story: a soldier's wife, left with orphans and nothing else. He came back with food, cooked for her children and fed them with his own hand, and played with them until they laughed. And as he fired the oven for her bread and leaned toward its heat, he said to himself: “Taste this, Ali - taste the fire. This is for the one who fails the widow and the orphan.” Those who knew him said he treated every orphan like his own; he called himself the father of orphans. Only after his death, when the night deliveries stopped, did Kufa learn whose back had carried them.",
                reflection: "This is what the first half of the surah looks like when it walks around: the strongest hand in the community put at the service of its weakest members. The verse said the one who robs an orphan is swallowing fire - and here is the man who held his own face toward the flame just to remember it. Keep him in view. The surah is about to ask what kind of hands can be trusted with other people's lives, and you have just watched the answer feed a widow's children."
            ),
            .act(
                act: 2,
                connector: "You have watched God write rights for people the world had written off.",
                line: "But a right on a page protects no one. Every right the surah has given is, in the end, placed in someone else's hands - the orphan's gold, the widow's freedom, the wife's dignity. The Qur'an has a word for that: amana, a trust. And now the surah lifts its eyes from the household to the community and asks the question all of these rights hang on. Whose hands can hold a trust - and who judges between the strong and the weak when they disagree?",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Trusts", surah: 4, ayah: 58,
                arabic: "۞ إِنَّ ٱللَّهَ يَأْمُرُكُمْ أَن تُؤَدُّوا۟ ٱلْأَمَٰنَٰتِ إِلَىٰٓ أَهْلِهَا وَإِذَا حَكَمْتُم بَيْنَ ٱلنَّاسِ أَن تَحْكُمُوا۟ بِٱلْعَدْلِ ۚ إِنَّ ٱللَّهَ نِعِمَّا يَعِظُكُم بِهِۦٓ ۗ إِنَّ ٱللَّهَ كَانَ سَمِيعًۢا بَصِيرًۭا",
                translation: "Indeed, God commands you to render the trusts back to their owners, and, when you judge between people, to judge with justice. How excellent is what God counsels you. Indeed God is ever Hearing, Seeing.",
                reference: "al-Nisa · 4 : 58",
                reflection: "Al-Mizan pauses on how vast this word is. Amanat - the trusts - is not only the coin left in your safekeeping: it is the orphan's estate, a secret, a skill, knowledge, an office - anything whose owner has no choice but to trust another's hands with it. Render it back, says God, and when you judge between people, judge with justice - the whole surah so far, folded into one verse. And the Ahl al-Bayt read in it the deepest layer of all: the greatest trust ever placed in human hands is leadership over people. Authority, in this Book, is not a prize for the strong. It is an amana - and it has owners."
            ),
            .verse(
                act: 2, tag: "Those in Authority", surah: 4, ayah: 59,
                arabic: "يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓا۟ أَطِيعُوا۟ ٱللَّهَ وَأَطِيعُوا۟ ٱلرَّسُولَ وَأُو۟لِى ٱلْأَمْرِ مِنكُمْ ۖ فَإِن تَنَٰزَعْتُمْ فِى شَىْءٍۢ فَرُدُّوهُ إِلَى ٱللَّهِ وَٱلرَّسُولِ إِن كُنتُمْ تُؤْمِنُونَ بِٱللَّهِ وَٱلْيَوْمِ ٱلْءَاخِرِ ۚ ذَٰلِكَ خَيْرٌۭ وَأَحْسَنُ تَأْوِيلًا",
                translation: "O you who believe, obey God, and obey the Messenger, and those vested with authority from among you. And if you dispute over anything, refer it to God and the Messenger, if you believe in God and the Last Day. That is best, and finest in outcome.",
                reference: "al-Nisa · 4 : 59",
                reflection: "Here is the chain of the Trust: obey God, obey the Messenger, and the Ulul-Amr - those vested with authority - from among you. Now follow al-Mizan's argument, one step at a time. The verse commands obedience to these men with no conditions, in the very same breath as obedience to the Prophet ﷺ himself. But imagine such a leader one day commands a sin. God has already said: obey him. God's own command would then be a command to disobey God - and that is impossible. So the verse quietly demands something enormous: whoever the Ulul-Amr are, they must be hands God has kept from error, the way He kept His Prophet. Which leaves one question. Who are they? A companion asked it the day these words came down."
            ),
            .narration(
                act: 2, tag: "Jabir's Question",
                source: "The Prophet Muhammad ﷺ · Kamal al-Din of Shaykh al-Saduq",
                body: "Jabir ibn Abdullah al-Ansari heard the verse and asked: “Messenger of God, we know God, and we know His Messenger. But who are these possessors of authority whose obedience God has joined to yours?” And the Prophet ﷺ answered, naming his successors (alayhim al-salam) one by one: “They are my successors, Jabir - the Imams of the Muslims after me. The first of them is Ali ibn Abi Talib, then Hasan, then Husayn, then Ali son of Husayn, then Muhammad son of Ali - you will live to see him, Jabir; when you meet him, give him my salam - then Ja'far son of Muhammad, then Musa, then Ali, then Muhammad, then Ali, then Hasan, and then the one who carries my own name, who will vanish from the sight of his people, and who will fill the earth with justice as it was filled with wrong.” Decades later, an old man met a boy in Medina and said: “Your grandfather the Messenger of God sends you his salam.” The boy was Muhammad al-Baqir (alayhi al-salam). Jabir had kept the trust.",
                reflection: "Look at what the surah of trusts has just done. It began with the people justice forgot. And its chain of command ends with the Imam God keeps hidden - kept for the day justice returns to those very people. His whole task is to fill the earth with exactly what this surah demanded from its first page. This is what al-Kafi calls the Imamate: a trust, delivered by each Imam to the Imam after him - never seized, and never once dropped. The rights of the weak and the question of who leads were never two subjects. They are one trust."
            ),
            .verse(
                act: 2, tag: "The Judge of the Heart", surah: 4, ayah: 65,
                arabic: "فَلَا وَرَبِّكَ لَا يُؤْمِنُونَ حَتَّىٰ يُحَكِّمُوكَ فِيمَا شَجَرَ بَيْنَهُمْ ثُمَّ لَا يَجِدُوا۟ فِىٓ أَنفُسِهِمْ حَرَجًۭا مِّمَّا قَضَيْتَ وَيُسَلِّمُوا۟ تَسْلِيمًۭا",
                translation: "But no, by your Lord - they do not believe until they make you the judge in whatever breaks out between them, and then find within themselves no resistance to what you have decided, and surrender completely.",
                reference: "al-Nisa · 4 : 65",
                reflection: "God swears an oath - “no, by your Lord” - and then defines faith by something no court could ever check. It does not say: they believe once they accept the verdict. Three rising steps, al-Mizan says: they bring their dispute to you, they accept what you decide, and then - the step no judge on earth can see - they find no tightness in their chests about it, and hand themselves over. Faith, in this surah, is not the outward yes. It is the heart's yes. Imam al-Sadiq (alayhi al-salam) taught that the judgment seat did not empty when the Prophet ﷺ left this world: the same surrender is owed to the ones he named to carry his trust. Obedience here was never about power. It is about whether your heart trusts God's chosen hands more than its own preferences."
            ),
            .climax(
                act: 2, tag: "The Company", source: "al-Nisa · 4 : 69",
                arabic: "وَمَن يُطِعِ ٱللَّهَ وَٱلرَّسُولَ فَأُو۟لَٰٓئِكَ مَعَ ٱلَّذِينَ أَنْعَمَ ٱللَّهُ عَلَيْهِم مِّنَ ٱلنَّبِيِّۦنَ وَٱلصِّدِّيقِينَ وَٱلشُّهَدَآءِ وَٱلصَّٰلِحِينَ ۚ وَحَسُنَ أُو۟لَٰٓئِكَ رَفِيقًۭا",
                translation: "And whoever obeys God and the Messenger - they will be with those God has favored: the prophets, and the truthful, and the martyrs, and the righteous. And what excellent companions they are.",
                body: "There was a servant the Prophet ﷺ had freed, named Thawban, who loved him the way a man loves air. One day he appeared thin and gray, grief all over his face. “What is wrong, Thawban?” “Nothing hurts me, Messenger of God - only that when I do not see you, I miss you until I see you again. And then I remembered the next world, and I was afraid. Even if I reach Paradise, you will be raised high among the prophets - and I will never see you again.” The Prophet ﷺ said nothing. Then this verse came down. Whoever obeys God and the Messenger will be with those God has favored - the prophets, the truthful, the martyrs, the righteous. Not near them. Not within sight of them. With them - and what excellent companions they are.",
                reflection: "The Ahl al-Bayt complete the promise with a saying of the Prophet ﷺ: a person is with the one they love. Thawban's fear is answered - and answered for every soul that has ever loved someone too high to reach. Obedience closes the distance that love alone cannot close."
            ),
            .narration(
                act: 2, tag: "The Words You Know",
                source: "al-Fatiha · 1 : 6-7 · al-Mizan",
                body: "Now hold the verse to the light and read its first words once more: alladhina an'ama Allahu alayhim - those God has favored. You have said these words before. You said them today. In every prayer of your life, you have asked: ihdina al-sirat al-mustaqim, sirat alladhina an'amta alayhim - guide us on the straight path, the path of those You have favored. In al-Fatiha you beg, day after day, to walk with a company the prayer never names. Here they are. This is the verse where God names them: the prophets, the truthful, the martyrs, the righteous - the company waiting at the end of the straight path.",
                reflection: "The path and the company were never two separate requests. Walk the path, and you arrive among the company. The surah that opened with the unguarded ends its climb inside the best-guarded company there is - and all along it has been teaching you how to enter: guard what is placed in your hands, and stay close to the hands God guards."
            ),
            .reflectionPrompt(
                tag: "The Return",
                prompt: "What has God placed in your hands?",
                placeholder: "A child, a parent, someone's money, someone's heart, a duty, a truth…",
                subline: "You have walked both halves of the surah - the rights God wrote for the unguarded, and the trusted hands He set over those rights to guard them. Somewhere in your life, you are the hands this surah is talking about. Someone weaker than you lives inside your power; something that is not yours is in your keeping. Name it. That is your amana.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "النِّسَاء",
                essence: "The surah where God took the side of the ones nobody defended - and named the hands He trusts to defend them.",
                line: "Near its final lines, the surah says: a proof has come to you from your Lord, and He has sent down to you a clear light. The Prophet ﷺ left that proof and that light in the keeping of two things - the Book of God, and his household, who never part. Read al-Nisa now in its own words, unhurried - the rights, the Trust, the company - and the next time the world asks you why the mightiest surah is named for the weakest, you will know."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Nisa experience") {
    DeepDiveView(dive: .surahNisa, onClose: {})
}
#endif
