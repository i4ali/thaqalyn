//
//  SurahTawbaDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Tawba" experience. Rendered by
//  DeepDiveView; approved master script: docs/plans/surah-experience/tawba-script.md.
//
//  English-first for now: every LocalizedText is a bare string literal, so ur/ar
//  fall back to English (LocalizedText.text(for:)). Qur'an Arabic is verbatim
//  from quran_data.json (substituted programmatically from pull_arabic.py output,
//  never hand-typed, to survive the byte-for-byte check). 9:1 genuinely carries no
//  Bismillah prefix - the data enacts the opening beat. No dua beat; ends on
//  .closing, which hands off to reading the full surah.
//
//  Spine: the mercy that moved. The only surah with no Bismillah is the one God
//  named for His own turning back. Three movements track the surah's inward-moving
//  gaze - the severance of the covenant-breakers outside (I), the sifting and
//  confession of the community itself (II), and the return, where the mechanism of
//  tawba is revealed (III, climax 9:118: He turned to them so that they might turn).
//  The final verse beat (9:128) resolves the opening question: the pair Ra'uf Rahim,
//  spoken of God at 9:117, rests on the Prophet ﷺ on the surah's last page.
//
//  Sourcing is Shia and verified (revised per the Stage 5 audit): al-Mizan
//  (Tabatabai), Majma al-Bayan (Tabrisi), and Ahl al-Bayt narrations - Imam Ali
//  on the withheld Bismillah (aman/sword; Majma al-Bayan 5/6-7, also al-Qurtubi
//  under 9:1); the Bara'a proclamation carried by Ali ("a man from my family" -
//  al-Tirmidhi 3090, Musnad Ahmad; Majma al-Bayan); Imam al-Baqir's maxim on the
//  repentant at 9:11 (al-Kafi); Tabrisi's exegetes' rule on 'asa at 9:102; Imam
//  al-Sadiq on charity into the hand of the Lord first (al-Kafi); al-Mizan on the
//  double turning of 9:118 and on 9:117 as raising, not pardon; Imam al-Rida
//  naming the sadiqin as the Imams (al-Kafi 1/208); Tabrisi on the two-names
//  observation at 9:128. Honorifics on the Prophet Muhammad ﷺ and the Imams (a).
//

import SwiftUI

extension DeepDive {
    static let surahTawba: DeepDive = DeepDive(
        id: "surah-tawba",
        titleEn: "al-Tawba",
        titleAr: "التَّوْبَة",
        subtitle: "The Repentance - the surah with no Bismillah, named for the door God holds open",
        sfSymbol: "door.left.hand.open",
        estMinutes: 12,
        acts: [
            ActInfo(number: 1, ar: "الْبَرَاءَة", tr: "al-Bara'a", name: "The Severance"),
            ActInfo(number: 2, ar: "الِاعْتِرَاف", tr: "al-I'tiraf", name: "The Confession"),
            ActInfo(number: 3, ar: "التَّوْبَة", tr: "al-Tawba", name: "The Return"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "التَّوْبَة",
                titleEn: "al-Tawba",
                subtitle: "The Repentance",
                line: "Every surah of the Qur'an opens with the same words: In the name of Allah, the All-Merciful, the Ever-Merciful. Every surah except one. This one. No Bismillah stands at its door - the name of mercy is simply missing, and it is missing on purpose. Yet of all the names the sternest surah in His Book could carry, it carries the gentlest: al-Tawba, the Return. A surah that begins without mercy, named for the way back into it. Something is hidden in that contradiction. Come and find where the mercy went."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "This surah carries two names. The first is Bara'a, the Severance - its opening word, a public breaking of ties with those who had broken every treaty they signed. The second is al-Tawba, the Return - the name it is remembered by. The road between those two names is the surah itself, and this descent walks it: through an ultimatum, a battlefield, a mosque pillar, and fifty days of silence. Watch one thing as you go: every time this surah builds a wall, look closely, and you will find a door in it.",
                leaveWith: "You will leave knowing why this surah - the only one without the Bismillah - carries the name of the return, and you will never again read its severity without seeing the doors. And near the end, the word tawba will show you what it really means. It is not what most of us think repentance is."
            ),

            // ── Movement I · al-Bara'a (The Severance) ────────────────────────
            .act(
                act: 1, connector: nil,
                line: "The ninth year after the Prophet's ﷺ migration to Medina. Mecca has surrendered, but across Arabia the old treaties lie in pieces - broken by tribes who signed them, waited, and struck when it suited them. Into that landscape falls this surah, and its opening is not an address. It is a proclamation, to be carried to the greatest gathering in Arabia and read aloud. Ibn Abbas would later ask Imam Ali (a) why no Bismillah stands over it. He answered: Bismillah is security, and Bara'a came down with the sword. The words of shelter were lifted from the door. Now watch who was sent to lift them - and what God leaves standing even here.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "The Severance", surah: 9, ayah: 1,
                arabic: "بَرَآءَةٌۭ مِّنَ ٱللَّهِ وَرَسُولِهِۦٓ إِلَى ٱلَّذِينَ عَٰهَدتُّم مِّنَ ٱلْمُشْرِكِينَ",
                translation: "A severance from Allah and His Messenger to those of the polytheists with whom you made a treaty.",
                reference: "al-Tawba · 9 : 1",
                reflection: "No Bismillah, no preamble - the first word is bara'a, severance, and the surah is already in motion. In Arabia, a treaty was a bond of protection. Al-Mizan, Tabatabai's great commentary, is precise about what happens here: God is withdrawing that protection. Not from every idolater - only from those the verse itself names, the ones you made treaties with, who made a habit of breaking them. Tabrisi, in his commentary Majma al-Bayan, records the years of patience behind this one sentence: truce after truce signed, and truce after truce broken. And now notice a strange gentleness inside the hardest opening in the Qur'an. The withdrawal comes with notice. The very next verse grants the treaty-breakers four months to travel the land untouched - time to go home, take counsel, and choose. Even the breaking is done the way a covenant is done: declared openly, to their faces, with a road left open. This is not vengeance. It is justice - and justice keeps doors."
            ),
            .narration(
                act: 1, tag: "A Man From Me",
                source: "The proclamation of Bara'a · Musnad Ahmad, al-Tirmidhi; Majma al-Bayan",
                body: "When these verses came down, the Hajj caravan had already left. The Prophet ﷺ had sent Abu Bakr at its head, carrying the opening of Bara'a to read to the pilgrims. Then revelation came: this proclamation could be delivered only by the Prophet himself, or by a man from him. So the Prophet ﷺ called Ali (a), mounted him on his own camel, and sent him after the caravan. Ali (a) overtook Abu Bakr on the road and took the verses from him, and at Mina, in the days of the pilgrimage, he stood before the largest gathering Arabia knew and proclaimed the severance, tribe by tribe. The Prophet's ﷺ own words explained why: it is not fitting that anyone should deliver this except a man from my family.",
                reflection: "The words that dissolved every false covenant in Arabia could not travel in just any hands. God's own honor was in them. They had to be carried by someone who stood in the Prophet's ﷺ place: a man from him. Both Shia and Sunni books preserve this account, and we have never stopped hearing what it quietly settled. Here was a task that belonged to the Prophet's ﷺ own station. He could not carry it himself. And there was exactly one man it could be handed to. Hold on to that. Near the end of this surah, God will tell you in one short command what that man and his family are to you."
            ),
            .verse(
                act: 1, tag: "Your Brothers", surah: 9, ayah: 11,
                arabic: "فَإِن تَابُوا۟ وَأَقَامُوا۟ ٱلصَّلَوٰةَ وَءَاتَوُا۟ ٱلزَّكَوٰةَ فَإِخْوَٰنُكُمْ فِى ٱلدِّينِ ۗ وَنُفَصِّلُ ٱلْءَايَٰتِ لِقَوْمٍۢ يَعْلَمُونَ",
                translation: "But if they repent, and establish the prayer, and give the zakat, then they are your brothers in religion. And We make the verses clear for a people who know.",
                reference: "al-Tawba · 9 : 11",
                reflection: "The four months were a road out. This verse is the road back in. The same voice that severed every tie now says: if they repent. The Arabic word is tabu - if they turn back. And if they do, the past is not merely pardoned. They become your brothers. Al-Mizan pauses on that word: not tolerated, not admitted on probation, but brothers in full. Tabrisi points out how shocking this was in the Arabia of that day, where blood and tribe decided everything: yesterday's treaty-breaker becomes family overnight. Imam al-Baqir (a) put the principle in one line: the one who repents of a sin is as one with no sin at all. Read this verse beside the severance, and the shape of the whole surah shows itself for the first time. The cutting was never the point. The cutting is what makes the door visible. And a wall with an open door in it is not really a wall. It is a threshold, waiting to be crossed."
            ),

            // ── Movement II · al-I'tiraf (The Confession) ─────────────────────
            .act(
                act: 2,
                connector: "You have watched the severance fall on those outside who broke every covenant - and found, inside the ultimatum, a door called brotherhood.",
                line: "Now the surah does something the first movement did not prepare you for. It turns from the enemies of the community to the community itself - to an army swollen with confidence, and to believers who failed a test everyone saw them fail. The blade that cut outward begins to cut inward, and it passes closer to where you stand. So do the doors.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "The Day of Hunayn", surah: 9, ayah: 25,
                arabic: "لَقَدْ نَصَرَكُمُ ٱللَّهُ فِى مَوَاطِنَ كَثِيرَةٍۢ ۙ وَيَوْمَ حُنَيْنٍ ۙ إِذْ أَعْجَبَتْكُمْ كَثْرَتُكُمْ فَلَمْ تُغْنِ عَنكُمْ شَيْـًۭٔا وَضَاقَتْ عَلَيْكُمُ ٱلْأَرْضُ بِمَا رَحُبَتْ ثُمَّ وَلَّيْتُم مُّدْبِرِينَ",
                translation: "Allah has already helped you on many fields - and on the day of Hunayn, when your great numbers pleased you, but they availed you nothing, and the earth, for all its vastness, grew narrow for you; then you turned your backs and fled.",
                reference: "al-Tawba · 9 : 25",
                reflection: "At Badr they were three hundred and thirteen and certain of nothing but God. At Hunayn, six years later, they marched twelve thousand strong, and someone said the words every army wants to believe: we cannot be beaten today, not with numbers like these. Tabrisi tells what the valley did to that boast: an ambush in the narrows, arrows out of the dark, and the great army broke and ran. Al-Mizan names the exact wound, and it is in the verse itself: your great numbers pleased you. The trust had slid quietly off God and onto the count of men, and God let the count of men fail, so they could feel the difference. Only a handful stood their ground around the Prophet ﷺ that morning, Imam Ali (a) foremost among them, and on those few God sent down sakina, a stillness from Him - and the day turned. But keep the verse's strangest phrase: the earth, for all its vastness, grew narrow. This surah will say those words once more, about different men in a different kind of narrowness - and when the words return, you will understand why they were spoken here first."
            ),
            .verse(
                act: 2, tag: "Then God Turns", surah: 9, ayah: 27,
                arabic: "ثُمَّ يَتُوبُ ٱللَّهُ مِنۢ بَعْدِ ذَٰلِكَ عَلَىٰ مَن يَشَآءُ ۗ وَٱللَّهُ غَفُورٌۭ رَّحِيمٌۭ",
                translation: "Then Allah turns, after that, to whom He wills. And Allah is Forgiving, Merciful.",
                reference: "al-Tawba · 9 : 27",
                reflection: "Two verses after the rout, a sentence that changes the whole surah - though you could read past it and never notice. Then Allah turns. The verb is yatubu, the verb the surah itself is named for, and here God is the one doing the turning. In the verses you have read so far, the turning belonged to people: if they turn, they are your brothers. Here the direction reverses. And look who this verse was for: Tabrisi records that men of Hawazin - the very army that ambushed the Muslims at Hunayn - later came to Islam and were taken in. Al-Mizan adds that “whom He wills” does not mean God chooses at random; His will follows the sincerity of a heart, and no history of enmity puts a heart out of His reach. So the surah named al-Tawba has just shown you, almost in passing, whose motion its name describes. Hold that lightly for now. The surah is not done with this verb."
            ),
            .verse(
                act: 2, tag: "The Honest Failures", surah: 9, ayah: 102,
                arabic: "وَءَاخَرُونَ ٱعْتَرَفُوا۟ بِذُنُوبِهِمْ خَلَطُوا۟ عَمَلًۭا صَٰلِحًۭا وَءَاخَرَ سَيِّئًا عَسَى ٱللَّهُ أَن يَتُوبَ عَلَيْهِمْ ۚ إِنَّ ٱللَّهَ غَفُورٌۭ رَّحِيمٌ",
                translation: "And others have confessed their sins; they mixed a righteous deed with another that was evil. It may be that Allah will turn to them. Indeed, Allah is Forgiving, Merciful.",
                reference: "al-Tawba · 9 : 102",
                reflection: "The march to Tabuk was the community's hardest summons - endless distance, killing heat, a year of drought, and the empire of the Romans waiting at the far end. Some believers simply did not go. No conspiracy, no secret disbelief; comfort won. When the army came back, this surah sifted everyone who had stayed behind. The hypocrites came with polished excuses and were abandoned to their lies. But there were others, and this verse is theirs. They confessed. No excuse offered, no story: we failed, and we know it. Hear how God describes them - they mixed a righteous deed with an evil one. Al-Mizan says this is most believers at most hours of their lives: not saints, not hypocrites, a weave of both, ashamed and still hoping. And Tabrisi records the exegetes' rule about the verse's “it may be”: from God it is not doubt - it is worded this way to hold the confessors between hope and fear, so that hope never hardens into taking mercy for granted. If you have ever wondered where people like us appear in the Qur'an - neither heroes nor traitors, just honest about having failed - it is here. And look: the door again. It may be that Allah will turn to them."
            ),
            .narration(
                act: 2, tag: "The Pillar",
                source: "The confessors of Tabuk · Majma al-Bayan (Tabrisi), under 9:102",
                body: "The traditions tell what happened next, and they remember one confessor above the rest: Abu Lubaba. He walked to the mosque of the Prophet ﷺ, bound himself to a pillar, and swore he would not untie himself until God accepted his repentance. Days passed. People asked the Prophet ﷺ to release him, and he refused: I will not release him until I am commanded to. Then the verses of acceptance came down, and the Prophet ﷺ went to the pillar and loosed him with his own hands. In the Prophet's ﷺ Mosque in Medina, a pillar still carries the name of what a bound man waited for beside it: the Pillar of Repentance.",
                reflection: "Notice what Abu Lubaba understood about tawba. He did not explain his failure away, and he did not slip quietly back into the ranks hoping no one would bring it up. He made his return as visible as his fault had been, tied himself where the whole city could see, and put the untying in God's hands alone. And God let him wait - long enough for the waiting itself to do its work - then sent down the verses of acceptance, and sent His Prophet ﷺ to open the knot. Keep this picture: a man bound to a pillar, unable to free himself, waiting for heaven to move first. You will see it again before the surah ends, drawn larger."
            ),
            .verse(
                act: 2, tag: "The One Who Takes", surah: 9, ayah: 104,
                arabic: "أَلَمْ يَعْلَمُوٓا۟ أَنَّ ٱللَّهَ هُوَ يَقْبَلُ ٱلتَّوْبَةَ عَنْ عِبَادِهِۦ وَيَأْخُذُ ٱلصَّدَقَٰتِ وَأَنَّ ٱللَّهَ هُوَ ٱلتَّوَّابُ ٱلرَّحِيمُ",
                translation: "Do they not know that it is Allah who accepts repentance from His servants and takes the charities, and that Allah - He is the Ever-Turning, the Merciful?",
                reference: "al-Tawba · 9 : 104",
                reflection: "The confessors brought money too. Take it, they begged, and purify us with it. The verse just before this one told the Prophet ﷺ to do exactly that: take a charity from their wealth to cleanse them, and pray over them, because his prayer would be a rest for them. But this verse lifts the whole scene higher. It asks: do they not know who it is that accepts repentance from His servants, and who takes the charities? Allah does. He takes them Himself. Imam al-Sadiq (a) taught, in words preserved in al-Kafi, that charity falls into the hand of the Lord before it falls into the hand of the servant. The coin you pass to a beggar crosses a hidden threshold on its way. Then the verse names God in a way that answers everyone who fails more than once: al-Tawwab. In Arabic the shape of the word means an act done over and over - the Ever-Turning, the One who turns back again and again and again. Anyone who has broken the same promise twice knows the fear underneath: surely there is a limit; surely the door closes in the end. Al-Mizan reads this verse as God's answer to exactly that fear. He is not the God of one return. He is the God of the return after the return after that."
            ),

            // ── Movement III · al-Tawba (The Return) ──────────────────────────
            .act(
                act: 3,
                connector: "The sifting has moved from the enemies outside to the believers themselves. And every cut has opened a door: brotherhood for the ones cut off, a turning even for the army that ambushed them at Hunayn, an unbound pillar for a confessor.",
                line: "One circle remains, the innermost. Not everyone who stayed behind was sorted that day: three cases were left open, suspended between heaven and the community. For them the surah reserves its deepest trial and its greatest verse - the story that gave the surah its name. And notice whom the verse at this gate begins with: God turns even to His Prophet ﷺ, who had no sin to turn from. For the sinless, al-Mizan explains, God's turning is not pardon but raising - each station above the last. Now enter slowly, and meet the three.",
                bridge: BridgeVerse(
                    surah: 9, ayah: 117,
                    arabic: "لَّقَد تَّابَ ٱللَّهُ عَلَى ٱلنَّبِىِّ وَٱلْمُهَٰجِرِينَ وَٱلْأَنصَارِ ٱلَّذِينَ ٱتَّبَعُوهُ فِى سَاعَةِ ٱلْعُسْرَةِ مِنۢ بَعْدِ مَا كَادَ يَزِيغُ قُلُوبُ فَرِيقٍۢ مِّنْهُمْ ثُمَّ تَابَ عَلَيْهِمْ ۚ إِنَّهُۥ بِهِمْ رَءُوفٌۭ رَّحِيمٌۭ",
                    translation: "Allah has turned to the Prophet, and the Muhajirun and the Ansar who followed him in the hour of hardship, after the hearts of a group of them had almost swerved; then He turned to them. Indeed He is to them Most Kind, Merciful.",
                    reference: "al-Tawba · 9 : 117"
                )
            ),
            .narration(
                act: 3, tag: "Fifty Days",
                source: "The three left behind · Majma al-Bayan and al-Mizan, under 9:118; Ka'b's own account in the Sahihayn",
                body: "When the army came home from Tabuk, the hypocrites hurried to the Prophet ﷺ with their invented excuses, and he accepted the words and left their hearts to God. Then came three men - Ka'b ibn Malik, Murara ibn al-Rabi, and Hilal ibn Umayya - and they did the one thing no one else had dared. They told the truth: we had no excuse. We simply stayed behind. The Prophet ﷺ did not curse them, and did not clear them. Their case was left suspended, waiting on heaven - and the community was commanded to turn away from them. No greeting in the street, no word in the mosque, no glance. When their wives asked whether they too should withdraw, the Prophet ﷺ said no - only that their husbands should not come near them. For fifty days, three truthful men lived among their own people like ghosts. Ka'b remembered, years later, climbing a garden wall to greet a cousin he loved, and receiving only silence.",
                reflection: "Fifty days is long enough for a punishment to stop feeling like anger and start feeling like teaching. Everyone knew the three were believers. And their fault, set beside the lies being told freely in the same streets, was that they had been honest. That is exactly the point. The hypocrites escaped into their excuses and were lost inside them. The three were held in the fire precisely because they were worth refining. Now listen to what those days did inside them - because the whole surah has been building toward the sentence that comes next."
            ),
            .climax(
                act: 3, tag: "No Refuge but Him", source: "al-Tawba · 9 : 118",
                arabic: "وَعَلَى ٱلثَّلَٰثَةِ ٱلَّذِينَ خُلِّفُوا۟ حَتَّىٰٓ إِذَا ضَاقَتْ عَلَيْهِمُ ٱلْأَرْضُ بِمَا رَحُبَتْ وَضَاقَتْ عَلَيْهِمْ أَنفُسُهُمْ وَظَنُّوٓا۟ أَن لَّا مَلْجَأَ مِنَ ٱللَّهِ إِلَّآ إِلَيْهِ ثُمَّ تَابَ عَلَيْهِمْ لِيَتُوبُوٓا۟ ۚ إِنَّ ٱللَّهَ هُوَ ٱلتَّوَّابُ ٱلرَّحِيمُ",
                translation: "And [He turned] to the three who were left behind - until, when the earth, for all its vastness, grew narrow for them, and their own souls grew narrow around them, and they knew for certain that there is no refuge from Allah except to Him - then He turned to them, so that they might turn. Indeed, Allah - He is the Ever-Turning, the Merciful.",
                body: "Read what the fifty days did. The earth, for all its vastness, grew narrow for them. Those are the very words this surah used for the army fleeing at Hunayn - but those men were running from arrows. These three could not run at all, because what pressed on them was everywhere. Then the verse goes somewhere stranger: their own souls grew narrow around them. The last shelter a person has is himself, his own inner room - and even that closed. Al-Mizan reads the design in it: God removed every refuge, one by one - the city, the faces, finally the self - until a single truth was left standing, and they knew it with certainty: there is no refuge from Allah except to Him. Not from Him to somewhere safe - from Him, to Him. When you run from God, there is only one place left to run: God. Every road away from Him turns, and leads back into His mercy. And then come the words the surah is named for: thumma taba alayhim li-yatubu. Then He turned to them - so that they might turn. Read it twice. Their repentance did not come first. His turning came first, and their turning was the thing it made possible.",
                reflection: "Al-Mizan reads God's turning in this verse as double. He turned to the three at the beginning - moving them to repent, holding them upright through the fifty days - and He turned to them at the end, accepting the repentance He Himself had carried them into. Your tawba, in other words, travels between two of His: like a child's first steps, which happen inside a watchfulness that was there before the child ever stood. This is the secret the surah's name has been keeping. We say tawba and picture our own trembling walk back to God. The surah says: before you ever turned toward Him, He had already turned toward you - the very desire to return, whenever it comes, is His mercy already arrived. And the Qur'an keeps a quiet grammar around this secret: whenever it speaks of the turn that comes down upon a person, taba alayhi, the one turning is God - every single time. We only ever turn to Him. The turn that descends is His alone. Al-Tawwab, the Ever-Turning. First, and last."
            ),
            .verse(
                act: 3, tag: "With the Truthful", surah: 9, ayah: 119,
                arabic: "يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱتَّقُوا۟ ٱللَّهَ وَكُونُوا۟ مَعَ ٱلصَّٰدِقِينَ",
                translation: "O you who believe, be wary of Allah, and be with the truthful.",
                reference: "al-Tawba · 9 : 119",
                reflection: "The first verse after the three are received back is a command, and it is not an order to strive harder on your own. Be with the truthful. Truthfulness is what saved the three; it was the one line separating them from the hypocrites, who lied and were lost. But al-Mizan sees a second lesson in the story: no one keeps to the road back alone. Wariness of God is not something you can hold up by yourself. It needs company - someone beside you whose truth does not bend. And the household of the Prophet ﷺ tells us who that company is. Imam al-Rida (a) was asked who the truthful of this verse are, and answered: the truthful are the Imams - and the truly truthful are so by obeying them. Not simply people who avoid lying, but people in whom truth and self are one thing. And notice what the command quietly promises: God would not tell you to stand with such people unless such people were always in the world to be found. You met the first of them at the opening of this surah - Ali (a), carrying Bara'a to the pilgrims, because only a man from the Prophet ﷺ could. The surah of the return, having brought you back through the door, leaves you one instruction for the rest of the road. Do not walk it alone. Stand with them."
            ),
            .verse(
                act: 3, tag: "The Missing Words", surah: 9, ayah: 128,
                arabic: "لَقَدْ جَآءَكُمْ رَسُولٌۭ مِّنْ أَنفُسِكُمْ عَزِيزٌ عَلَيْهِ مَا عَنِتُّمْ حَرِيصٌ عَلَيْكُم بِٱلْمُؤْمِنِينَ رَءُوفٌۭ رَّحِيمٌۭ",
                translation: "There has certainly come to you a Messenger from your own selves. Heavy upon him is your suffering; deeply he cares for you; to the believers he is Most Kind, Merciful.",
                reference: "al-Tawba · 9 : 128",
                reflection: "You have reached the last page of the surah whose doorway was left without the Name - and look what is written on it. Ra'uf. Rahim. Most Kind, Merciful. A few verses ago the surah used this same pair of words about God Himself, when He turned to the Prophet ﷺ and those who followed him in the hour of hardship. Now it sets them on a man. Tabrisi records the old marvel at this verse: to no prophet but this one did God give two of His own names. And look at the man they crown. He comes from your own selves, so he knows your weakness from the inside. Your suffering sits heavy on his heart. He watches over you the way only someone who loves you watches. Imam Ali (a) remembered him weeping through the night, begging forgiveness for his community. So the question you have carried since the opening is answered. The mercy was never taken out of this surah. It was moved - out of the doorway, into the heart of a man. A surah of swords and severances, and the last thing it says about the Prophet ﷺ is that your pain is heavy for him to carry. Ask one last time where the mercy went, and the surah answers: it walked among you the whole time, in a man with a name and a face."
            ),

            // ── The Return ────────────────────────────────────────────────────
            .reflectionPrompt(
                tag: "Return",
                prompt: "Where have you decided the door is shut?",
                placeholder: "A prayer you stopped, a wrong you never named, a return you keep postponing…",
                subline: "Somewhere in your life is a place where you have quietly decided it is too late - a door you ruled shut from His side, and stopped standing in front of. Name it. And here is what this surah says about you and that door: He turned toward you before you ever turned around.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "التَّوْبَة",
                essence: "One surah begins without the name of mercy, and its name is mercy's furthest reach: God's own turning, first, toward the people who failed Him.",
                line: "You have walked from Bara'a to al-Tawba, from the severance to the return, and found a door in every wall. Now read the whole surah in its own words - the ultimatum, the battles, the excuses, the three - and listen for the turning underneath it all. It ends with the Messenger who carries your pain, and leaves you one last sentence to take with you: Sufficient for me is Allah. There is no god but He. Upon Him I rely, and He is the Lord of the Great Throne."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Tawba experience") {
    DeepDiveView(dive: .surahTawba, onClose: {})
}
#endif
