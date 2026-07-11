//
//  SurahFatihaDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Surah - al-Fatiha" experience. Rendered by
//  DeepDiveView; see docs/superpowers/specs/2026-07-07-surah-experience-design.md
//  and docs/plans/surah-experience/fatiha-script.md (approved master copy).
//
//  English-only for now: every LocalizedText is a bare string literal, so ur/ar
//  are nil and fall back to English (LocalizedText.text(for:)). A later translation
//  pass replaces the literals with LocalizedText(en:ur:ar:). Qur'an Arabic is
//  verbatim from quran_data.json (BOM stripped on 1:1). No dua beat; ends on
//  .closing, which hands off to reading the full surah.
//
//  Narrations are Shia-sourced: the division hadith qudsi is from Uyun Akhbar
//  al-Rida (via Tafsir Nur al-Thaqalayn); the closing narration is Hadith al-Thaqalayn.
//

import SwiftUI

extension DeepDive {
    static let surahFatiha: DeepDive = DeepDive(
        id: "surah-fatiha",
        titleEn: "al-Fatiha",
        titleAr: "الْفَاتِحَة",
        subtitle: "The Opening - the prayer God taught you to pray",
        sfSymbol: "book.closed",
        estMinutes: 11,
        acts: [
            ActInfo(number: 1, ar: "الْحَمْد", tr: "al-Hamd", name: "The Praise"),
            ActInfo(number: 2, ar: "الِالْتِفَات", tr: "al-Iltifat", name: "The Turn"),
            ActInfo(number: 3, ar: "الصِّرَاط", tr: "al-Sirat", name: "The Path"),
        ],
        sections: [
            .open(
                kicker: "INSIDE THE SURAH",
                titleAr: "الْفَاتِحَة",
                titleEn: "al-Fatiha",
                subtitle: "The Opening",
                line: "Seven short verses. You have said them more times than any other words in your life - at the start of every prayer, every rak'ah, since the day you learned to pray. This is the surah you know entirely by heart. Here is the chance to finally hear it."
            ),
            .orientation(
                eyebrow: "Before you begin",
                promise: "They called it Umm al-Kitab, the Mother of the Book, and al-Sab al-Mathani, the seven oft-repeated verses God paired with the whole Qur'an. No prayer is complete without it. And it is built as a conversation: first you praise Him, then you turn to face Him, then you ask Him for the one thing you most need.",
                leaveWith: "You will leave knowing al-Fatiha not as an opening you rush through, but as the prayer God Himself taught you to pray - and knowing what He says back to you, line by line, every time you stand before Him."
            ),
            .act(
                act: 1, connector: nil,
                line: "Before you ask God for anything, al-Fatiha slows you down to remember who He is. Four names, four faces of the One you are about to speak to: the Merciful, the Lord, the Compassionate, the King of the Last Day. This is the half of the prayer that belongs to Him.",
                bridge: nil
            ),
            .verse(
                act: 1, tag: "In His Name", surah: 1, ayah: 1,
                arabic: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                translation: "In the name of Allah, the All-Merciful, the Ever-Merciful.",
                reference: "al-Fatiha · 1 : 1",
                reflection: "The Ahl al-Bayt counted this as the first verse of the surah, not a heading before it - so you open by leaning on His name, not your own strength. And the very first thing He tells you about Himself is mercy, said two ways: al-Rahman, the mercy that reaches every creature alive, and al-Rahim, the mercy kept for those who turn back to Him. Imam Ali said His mercy runs ahead of His wrath. You begin here."
            ),
            .verse(
                act: 1, tag: "All Praise", surah: 1, ayah: 2,
                arabic: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ",
                translation: "All praise is for Allah, Lord of all the worlds.",
                reference: "al-Fatiha · 1 : 2",
                reflection: "Not shukr, thanks for a gift received, but hamd - praise for who He is, whether or not you were given anything today. And Rabb means more than Maker: it is the One who raises a thing from a seed to its fullness and never once walks away from what He made. Imam al-Baqir said this is its meaning - a Lord who does not create and abandon, but sustains every world, seen and unseen, breath by breath."
            ),
            .verse(
                act: 1, tag: "Mercy, Again", surah: 1, ayah: 3,
                arabic: "ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                translation: "The All-Merciful, the Ever-Merciful.",
                reference: "al-Fatiha · 1 : 3",
                reflection: "He has just named Himself Lord of all the worlds - and before He names Himself King of the Day of Judgment in the very next breath, He says mercy again. Twice. Al-Mizan reads the repetition as deliberate: lest you ever imagine His power is cold, He tells you that the One who owns the Day of Reckoning rules it by mercy first. The throne of the universe is not a throne of fear."
            ),
            .verse(
                act: 1, tag: "King of the Day", surah: 1, ayah: 4,
                arabic: "مَٰلِكِ يَوْمِ ٱلدِّينِ",
                translation: "Master of the Day of Judgment.",
                reference: "al-Fatiha · 1 : 4",
                reflection: "And yet mercy is not the whole of it. He is also Malik - not an abstract power but a personal King who owns that Day, when every other crown is laid down and only His remains. Al-Mizan notes the word is personal on purpose: you will not stand before a system, but before Someone who knows you by name. Mercy and justice, held in one hand. This is the God you have been praising - and here the surah turns."
            ),
            .response(
                act: 1, replyingTo: "to your praise · 1 : 1-4",
                arabic: "حَمِدَنِي عَبْدِي",
                words: "“My servant has praised Me, extolled Me, and glorified Me.”",
                source: "Hadith Qudsi · Uyun Akhbar al-Rida",
                reflection: "In a hadith qudsi, God says He divided this prayer between Himself and His servant. This is the first half, answered: the praise you thought rose and vanished into the air was heard, and given back to you, name by name."
            ),
            .act(
                act: 2,
                connector: "You have praised Him by every name - the Merciful, the Lord, the King of the Day.",
                line: "And now something changes. For four verses you spoke about God, in the third person, as if describing Someone far off. Here the surah does what al-Mizan calls the heart of the whole prayer: it turns, and you stop speaking about Him and begin speaking to Him.",
                bridge: nil
            ),
            .verse(
                act: 2, tag: "Face to Face", surah: 1, ayah: 5,
                arabic: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
                translation: "It is You we worship, and it is You we ask for help.",
                reference: "al-Fatiha · 1 : 5",
                reflection: "Iyyaka - You, and none but You - placed first, so worship can point nowhere else. And notice the order: worship before help. Al-Mizan calls this the secret of the verse - you do not come to God as a customer with a request, but as a servant in love, and only then ask. Notice too that it is “we,” not “I”: you never pray al-Fatiha alone, but standing inside the whole community of those who bow. This is the line God kept for Himself and His servant together."
            ),
            .response(
                act: 2, replyingTo: "to the meeting point · 1 : 5",
                arabic: "بَيْنِي وَبَيْنَ عَبْدِي",
                words: "“This is between Me and My servant - and My servant shall have what he asked.”",
                source: "Hadith Qudsi · Uyun Akhbar al-Rida",
                reflection: "The one line He kept for the two of you together. And before you have even finished asking, the promise: you shall have what you asked."
            ),
            .act(
                act: 3,
                connector: "You have met Him face to face, and pledged Him your worship and your need.",
                line: "Now, in the last third of the prayer, you ask. Out of everything a soul could beg for - wealth, healing, relief, rescue - al-Fatiha teaches you to ask first for the one thing every other good depends on: to be shown the way.",
                bridge: nil
            ),
            .verse(
                act: 3, tag: "Guide Us", surah: 1, ayah: 6,
                arabic: "ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ",
                translation: "Guide us to the straight path -",
                reference: "al-Fatiha · 1 : 6",
                reflection: "You already believe. You already pray. So why ask to be guided, every single day? Because al-Mizan says guidance is not only being shown the road once - it is tawfiq, the quiet help to actually walk it, against your own pride and distraction and fatigue. The straight path is not information you were handed; it is a step you take again this morning. Even the faithful must keep asking. Especially them."
            ),
            .verse(
                act: 3, tag: "Whose Footsteps", surah: 1, ayah: 7,
                arabic: "صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ",
                translation: "the path of those You have blessed - not of those who earned Your anger, nor of those who went astray.",
                reference: "al-Fatiha · 1 : 7",
                reflection: "And the path is not an abstraction - it has been walked. God names its travelers elsewhere: the prophets, the truthful, the martyrs, the righteous. You are asking to be set in their footsteps, and kept from two ways of losing the road: those who knew the truth and refused it out of pride, and those who drifted from it without ever looking. Knowledge alone is not enough. It has to be married to humility."
            ),
            .response(
                act: 3, replyingTo: "to your plea · 1 : 6-7",
                arabic: "لِعَبْدِي مَا سَأَلَ",
                words: "“This is for My servant - and My servant shall have what he asked.”",
                source: "Hadith Qudsi · Uyun Akhbar al-Rida",
                reflection: "You asked to be shown the way, and the answer came before the asking was done: what you asked for is yours. And what He gives, He now names."
            ),
            .narration(
                act: 3, tag: "The Straight Path",
                source: "The Prophet Muhammad ﷺ · Hadith al-Thaqalayn",
                body: "When you ask for the straight path, what exactly are you asking for? On his return from his final pilgrimage, the Prophet gave the answer: “I am leaving among you two weighty things - the Book of God, and my family, my Ahl al-Bayt. Hold fast to them both, and you will never go astray after me, for the two will never part until they return to me at the Fountain.” The path you beg for at every prayer is the Qur'an and the household that never leaves it.",
                reflection: "This is why the surah has you ask, and does not simply tell. To want the straight path is already to be turning toward the two He left, so that no one who reaches for them would ever have to walk alone."
            ),
            .climax(
                act: 3, tag: "The Answer", source: "al-Baqara · 2 : 2",
                arabic: "ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًۭى لِّلْمُتَّقِينَ",
                translation: "This is the Book, without doubt, a guidance for the God-conscious.",
                body: "Stop and see what al-Fatiha just did. It ended not with a statement but with a plea: guide us. And then turn the page. The very next words of the Qur'an - the opening of Surat al-Baqara - answer it: “This is the Book, without doubt, a guidance.” You asked to be shown the way, and God's reply is the whole rest of the Book in your hands. Al-Fatiha is the question. The Qur'an is the answer.",
                reflection: "This is the soul of the surah: a prayer God taught you to pray, so that He could answer it - every time you open the Book, every time you rise to pray. The asking and the giving are the same motion."
            ),
            .reflectionPrompt(
                tag: "Return",
                prompt: "Which line will you finally mean?",
                placeholder: "His name, the praise, the turn, or the one request…",
                subline: "You have walked the whole conversation - the praise that is His, the turn where you meet Him, the plea that is yours. The next time you stand to pray, you are not reciting an opening. You are having this exact conversation. Before you go, name the line you most need to mean today.",
                nextLabel: "One last thing"
            ),
            .closing(
                tag: "The Close",
                titleAr: "الْفَاتِحَة",
                essence: "Seven verses God taught you to pray - so that even when you have no words of your own, you always know how to find Him.",
                line: "You have said al-Fatiha all your life. Read it now in its own words, unhurried, as if for the first time - and let the Opening open the Book, the way it opens every prayer."
            ),
        ]
    )
}

#if DEBUG
#Preview("Surah al-Fatiha experience") {
    DeepDiveView(dive: .surahFatiha, onClose: {})
}
#endif
