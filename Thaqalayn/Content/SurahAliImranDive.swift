//
//  SurahAliImranDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - Al Imran" experience. Rendered by
//  DeepDiveView; see docs/plans/surah-experience/ali-imran-script.md (approved master copy).
//
//  Slice, not full coverage: Al Imran is 200 verses, so this dive takes the narrative
//  heart that names the surah (3:33-61) - the chosen, purified house of Imran (Maryam),
//  and the Mubahala that answers it. Structure is a TWO-movement diptych (no coda): one
//  chosen house rhymed against another. The slice has one natural hinge - the dispute over
//  Isa that summons the Mubahala - so three movements would only pad; the election
//  principle (3:33) opens Movement I rather than standing as a thin movement of its own.
//  Close beats carry act: 4 (standard). Renders as "Depth N of 2" (dive.acts.count).
//
//  English-only for now: every LocalizedText is a bare string literal (ur/ar fall back
//  to English via LocalizedText.text(for:)). Qur'an Arabic is verbatim from
//  quran_data.json (verified byte-for-byte via scripts/pull_arabic.py).
//
//  Sourcing is Shia and verified: al-Mizan (Tabatabai), Majma al-Bayan (Tabrisi), and
//  narrations of the Ahl al-Bayt (Imam al-Sadiq, Imam al-Baqir, Imam al-Rida - alayhim
//  al-salam); the Mubahala, the four-women, and the tathir hadiths are cross-tradition
//  (Sahih Muslim, Musnad Ahmad).
//

import SwiftUI

extension DeepDive {
    static let surahAliImran: DeepDive = DeepDive(
        id: "surah-ali-imran",
        titleEn: "Al Imran",
        titleAr: "آلِ عِمْرَان",
        subtitle: "The Family of Imran - how God carries His truth through the households He chooses and purifies",
        sfSymbol: "person.3.sequence.fill",
        estMinutes: 11,
        acts: [
            ActInfo(number: 1, ar: "آلُ عِمْرَان", tr: "Al Imran", name: "The Chosen House"),
            ActInfo(number: 2, ar: "الْمُبَاهَلَة", tr: "al-Mubahala", name: "The Ordeal"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "آلِ عِمْرَان",
                titleEn: "Al Imran",
                subtitle: "The Family of Imran",
                line: "God named only a few of His surahs after a family, and this is the longest of them. It opens the door of a house He chose before its children were born, purified with His own hand, and fed with fruit out of season. And it does not end there. When the truth itself was one day put on trial, this surah answered with the faces of another house entirely. Come inside."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "The surah takes its name from Imran, the father of Maryam (alayha al-salam), and it rests on a single daring idea: that God carries His truth through households He Himself chooses and makes pure. You will watch Him do exactly that in the house of Imran - a girl chosen before her birth, kept spotless, sustained by miracles in the corner where she prayed. And then you will watch what happened when the truth that house carried was denied to God’s face.",
                leaveWith: "You will leave knowing this surah’s quiet secret: that the surest proof God ever offered of His own truth was not an army and not a wonder, but a small circle of faces He had chosen and purified - and you will know exactly whose they were."
            ),
            .act(
                act: 1, connector: nil,
                line: "The surah does not open with a story. It opens with a law - the law the whole chapter runs on. Before God shows you a single family, He tells you how He works: He chooses. Not everyone, and never at random, but particular souls and particular houses, lifted above the worlds to carry what He entrusts to no one else. Watch that law take flesh.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "God Chose", surah: 3, ayah: 33,
                arabic: "۞ إِنَّ ٱللَّهَ ٱصْطَفَىٰٓ ءَادَمَ وَنُوحًۭا وَءَالَ إِبْرَٰهِيمَ وَءَالَ عِمْرَٰنَ عَلَى ٱلْعَٰلَمِينَ",
                translation: "Indeed, God chose Adam, and Noah, and the family of Abraham, and the family of Imran above all the worlds -",
                reference: "Al Imran · 3 : 33",
                reflection: "The foundation stone of the surah: istifa, God’s choosing. Al-Mizan is careful with the word “family” - it never meant every child of a bloodline, but only the ones in it who were worthy of it, pure and wholly surrendered. And the next verse calls them dhurriyyatan ba'duha min ba'd, “one of another”: not scattered favorites but a single unbroken chain, each link passing the light to the next. Imam al-Sadiq (alayhi al-salam) taught that this chain, followed to its end, arrives at the family of Muhammad ﷺ. Hold that thought. The house you are about to enter is not the last one God chose."
            ),
            .verse(
                act: 1, tag: "The Vow", surah: 3, ayah: 35,
                arabic: "إِذْ قَالَتِ ٱمْرَأَتُ عِمْرَٰنَ رَبِّ إِنِّى نَذَرْتُ لَكَ مَا فِى بَطْنِى مُحَرَّرًۭا فَتَقَبَّلْ مِنِّىٓ ۖ إِنَّكَ أَنتَ ٱلسَّمِيعُ ٱلْعَلِيمُ",
                translation: "When the wife of Imran said, “My Lord, I have vowed to You what is in my womb, dedicated to Your service. So accept it from me. Indeed You are the Hearing, the Knowing.”",
                reference: "Al Imran · 3 : 35",
                reflection: "The chosen house does not begin with a child. It begins with a mother’s surrender. Imran’s wife - the traditions call her Hannah - vows the baby in her womb to God’s service before she knows its face, before she even knows if it is the son she was promised. Al-Mizan notes that such children were dedicated to serve at the Temple, and that this was expected to be a boy. She does not bargain, and she does not wait to see what she is getting. She hands over the first and the best, sight unseen. This is how a house becomes worthy of being chosen: someone inside it gives God everything before God has shown His hand."
            ),
            .verse(
                act: 1, tag: "Fruit Out of Season", surah: 3, ayah: 37,
                arabic: "فَتَقَبَّلَهَا رَبُّهَا بِقَبُولٍ حَسَنٍۢ وَأَنۢبَتَهَا نَبَاتًا حَسَنًۭا وَكَفَّلَهَا زَكَرِيَّا ۖ كُلَّمَا دَخَلَ عَلَيْهَا زَكَرِيَّا ٱلْمِحْرَابَ وَجَدَ عِندَهَا رِزْقًۭا ۖ قَالَ يَٰمَرْيَمُ أَنَّىٰ لَكِ هَٰذَا ۖ قَالَتْ هُوَ مِنْ عِندِ ٱللَّهِ ۖ إِنَّ ٱللَّهَ يَرْزُقُ مَن يَشَآءُ بِغَيْرِ حِسَابٍ",
                translation: "So her Lord accepted her with a beautiful acceptance, and made her grow in a beautiful way, and placed her in the care of Zakariyya. Whenever Zakariyya entered upon her in the prayer-niche, he found provision with her. He said, “O Maryam, from where is this to you?” She said, “It is from God. Indeed God provides for whom He wills without measure.”",
                reference: "Al Imran · 3 : 37",
                reflection: "A girl is born where a boy was awaited, and God accepts her “with a beautiful acceptance” - the expectation had been human; the choosing was His. She grows up inside the mihrab, the prayer-niche, and Zakariyya (alayhi al-salam) keeps finding food beside her that no hand had carried in - summer fruit in the dead of winter, the commentators say. “From where is this to you?” “It is from God, who provides without measure.” Her mother had begged God’s refuge for her and her offspring from Satan, and the Prophet ﷺ said that Maryam and her son were the only two ever born whom Satan could not touch. Imam al-Baqir (alayhi al-salam) said the angels themselves spoke with her. This is what a purified soul looks like from the outside: fed by a hand no one else can see."
            ),
            .verse(
                act: 1, tag: "Chosen and Purified", surah: 3, ayah: 42,
                arabic: "وَإِذْ قَالَتِ ٱلْمَلَٰٓئِكَةُ يَٰمَرْيَمُ إِنَّ ٱللَّهَ ٱصْطَفَىٰكِ وَطَهَّرَكِ وَٱصْطَفَىٰكِ عَلَىٰ نِسَآءِ ٱلْعَٰلَمِينَ",
                translation: "And when the angels said, “O Maryam, God has chosen you and purified you, and chosen you above the women of the worlds.”",
                reference: "Al Imran · 3 : 42",
                reflection: "Now the surah says outright what the mihrab had only hinted. The angels come to Maryam (alayha al-salam) with three declarations in a row: God has chosen you, purified you, and chosen you above all the women of the worlds. Al-Mizan reads them as three rising stages - selection, purification, preference. Rest on the middle one: tahharaki, He has made you pure. It is a rare thing for God to say of any human being, and He says it here of a woman. Keep the word - tahhara, purified. God declares this purification of only one other household in all the Qur'an, and this surah is quietly carrying the word toward them."
            ),
            .narration(
                act: 1, tag: "The Four",
                source: "The Prophet Muhammad ﷺ · Musnad Ahmad",
                body: "When the angels named Maryam the best of the women of the worlds, they left a question hanging in the air: who else stands in that rank? The Prophet ﷺ answered it, by name. “The best of the women of all the worlds are four,” he said: “Maryam bint Imran, Asiya bint Muzahim the wife of Pharaoh, Khadija bint Khuwaylid, and Fatima bint Muhammad.” It is a narration kept in the books of Shia and Sunni alike.",
                reflection: "Hold the four names together and a bridge appears across six hundred years. Among the four greatest women God ever raised, the Prophet ﷺ named his own daughter, Fatima (alayha al-salam), in the same breath as Maryam. Remember her name. Before the surah closes, it is going to need it."
            ),
            .act(
                act: 2,
                connector: "You have watched God choose a house and purify a daughter within it, and name her among the four best women ever to live.",
                line: "Now the surah turns to the child that house was given, and to the storm that gathered around him. For men would take this servant of God and lift him into the place of God - and when they would not let the error go, God did something He did for no other dispute in the whole Qur'an. He called for an ordeal.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "A Word from Him", surah: 3, ayah: 45,
                arabic: "إِذْ قَالَتِ ٱلْمَلَٰٓئِكَةُ يَٰمَرْيَمُ إِنَّ ٱللَّهَ يُبَشِّرُكِ بِكَلِمَةٍۢ مِّنْهُ ٱسْمُهُ ٱلْمَسِيحُ عِيسَى ٱبْنُ مَرْيَمَ وَجِيهًۭا فِى ٱلدُّنْيَا وَٱلْءَاخِرَةِ وَمِنَ ٱلْمُقَرَّبِينَ",
                translation: "When the angels said, “O Maryam, God gives you good news of a word from Him: his name is the Messiah, Isa son of Maryam, honored in this world and the Hereafter, and among those brought near.”",
                reference: "Al Imran · 3 : 45",
                reflection: "The child is announced as a kalima, a word from God. Al-Mizan explains why: Isa (alayhi al-salam) came to be by God’s bare command “Be,” with no father, so that his very existence is God’s creative word given a body. Now count the honors the verse heaps on him - the Messiah, honored in both worlds, among those brought near - and then notice the one thing it never says: that he is God. A word from Him is not Him. The highest and nearest of servants is a servant still. This single phrase already holds the whole of the coming storm: everything men would argue about Isa, the Qur'an settled here, in four words."
            ),
            .verse(
                act: 2, tag: "Like Adam", surah: 3, ayah: 59,
                arabic: "إِنَّ مَثَلَ عِيسَىٰ عِندَ ٱللَّهِ كَمَثَلِ ءَادَمَ ۖ خَلَقَهُۥ مِن تُرَابٍۢ ثُمَّ قَالَ لَهُۥ كُن فَيَكُونُ",
                translation: "Indeed, the likeness of Isa before God is as the likeness of Adam. He created him from dust, then said to him, “Be,” and he was.",
                reference: "Al Imran · 3 : 59",
                reflection: "Here is God’s argument, laid before the Christians of Najran who had come to Medina certain that Isa (alayhi al-salam) was divine. It is, al-Mizan says, a decisive proof: if you do not call Adam a god - and Adam had neither father nor mother, shaped straight from dust - how can a birth from a mother alone make Isa one? Imam al-Rida (alayhi al-salam) put exactly this question to Christian scholars in his own day. A miraculous birth was never meant to point at the child and say “God.” It points past him, at the One who said “Be.” The wonder is a signpost to the Maker, never a rival beside Him."
            ),
            .climax(
                act: 2, tag: "Whom He Brought", source: "Al Imran · 3 : 61",
                arabic: "فَمَنْ حَآجَّكَ فِيهِ مِنۢ بَعْدِ مَا جَآءَكَ مِنَ ٱلْعِلْمِ فَقُلْ تَعَالَوْا۟ نَدْعُ أَبْنَآءَنَا وَأَبْنَآءَكُمْ وَنِسَآءَنَا وَنِسَآءَكُمْ وَأَنفُسَنَا وَأَنفُسَكُمْ ثُمَّ نَبْتَهِلْ فَنَجْعَل لَّعْنَتَ ٱللَّهِ عَلَى ٱلْكَٰذِبِينَ",
                translation: "So whoever disputes with you about him after the knowledge that has come to you, say: “Come, let us call our sons and your sons, our women and your women, ourselves and yourselves; then let us pray earnestly, and place the curse of God upon the liars.”",
                body: "The delegation from Najran heard the argument, and still would not yield. So came the challenge in the verse: if you are so certain, let each side bring the dearest souls they have - their sons, their women, their very selves - stand together, and call down the curse of God on whichever side is lying. It is the gravest dare in the Qur'an, and God set it down only here. On the morning it was to happen, all of Medina watched to see whom the Prophet ﷺ would bring, for a man stakes only his most beloved when he swears his life before God. He brought four. He came out with Ali, with Fatima, and with their two sons Hasan and Husayn (alayhim al-salam), gathered them close, and said: “O God, these are my family.” The bishop of Najran looked at the five faces and turned to his people: “I see faces that, were they to ask God to move a mountain, He would move it for them. Do not contest them.” They withdrew, and paid a treaty instead. Not one word of the curse was ever needed.",
                reflection: "See what the surah has quietly done. It carries the name of the family of Imran, and at its very summit it has unveiled the family of Muhammad ﷺ. When the oneness of God had to be staked on something, God did not reach for a sword or a wonder - He reached for a purified household, the very shape the surah opened with. The rank the angels gave Maryam is worn now by Fatima (alayha al-salam); one chosen house has answered another across six hundred years. In the end, the proof of the truth was a family God had made pure."
            ),
            .narration(
                act: 2, tag: "Our Selves",
                source: "Imam Muhammad al-Baqir (alayhi al-salam) · Tafsir al-Mizan; Ayat al-Tathir (33:33)",
                body: "Return to the exact words God chose: “our sons, and our women, and our selves.” The sons the Prophet ﷺ brought were Hasan and Husayn; the woman was Fatima. But he brought no second man to stand as “our selves,” anfusana - only Ali (alayhi al-salam). God’s own verse had set Ali in the place of the Prophet’s very self. Imam al-Baqir (alayhi al-salam) said the two were one soul in two bodies. And now recall the word you have carried since the prayer-niche: purified. On days like this the Prophet ﷺ would gather these same five beneath his cloak, and God sent down over them: “God only desires to remove all impurity from you, People of the House, and to purify you completely.” The very word spoken of Maryam, tahhara, spoken now of them - a verse kept, like the Mubahala itself, in the books of Shia and Sunni together.",
                reflection: "This is why the ordeal is the surah’s summit, and not merely its victory. The word “purified,” first breathed over a girl in her prayer-niche, has traveled the whole length of the surah to come to rest on the family beneath the cloak. The Prophet ﷺ said he was leaving two weighty things among us - the Book of God, and his household - and that the two would never part. This surah has been naming them both from its first page: the truth, and the purified house God chose to carry it."
            ),
            .reflectionPrompt(
                tag: "The Return",
                prompt: "Whose house are you holding to?",
                placeholder: "The Book, the household, a name you reach for when the truth is disputed…",
                subline: "You have walked from one chosen house to another - from Maryam in her prayer-niche to the five beneath the cloak. The whole claim of the surah is that God never left you to find the truth alone: He left it in a Book and in a purified family, and told you to hold to both and never let go. Before you leave, name what you are holding to.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "آلِ عِمْرَان",
                essence: "God chooses households and makes them pure, so that His truth would never stand in the world without a family to carry it.",
                line: "You have seen the pattern drawn twice now - the house of Imran, and the house of Muhammad ﷺ. Read the surah now in its own words, unhurried, and watch the same hand that fed Maryam (alayha al-salam) in her niche reach all the way to the cloak."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah Al Imran experience") {
    DeepDiveView(dive: .surahAliImran, onClose: {})
}
#endif
