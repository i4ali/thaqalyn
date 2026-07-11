//
//  YaqinDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Yaqin" deep dive - a descent through the three depths
//  of certainty (Ilm / Ayn / Haqq al-Yaqin). Ported from MajlisYaqeen.jsx and
//  rendered by DeepDiveView. Prose is trilingual (EN / UR / AR); Qur'an Arabic,
//  references, and surah/ayah numbers are language-neutral.
//
//  GENERATED from scratchpad/deepdive-l10n (yaqin_source/ur/ar.json). Edit translations
//  there and regenerate, or edit inline - either is fine.
//

import SwiftUI

extension DeepDive {
    static let yaqin: DeepDive = DeepDive(
        id: "yaqin",
        titleEn: "Yaqin",
        titleAr: "يَقِين",
        subtitle: LocalizedText(en: "Certainty - a descent through three depths", ur: "یقین - تین گہرائیوں میں اترتا ایک سفر", ar: "اليقين - نزولٌ عبر ثلاثة أعماق"),
        sfSymbol: "eye",
        estMinutes: 5,
        acts: [
            ActInfo(number: 1, ar: "عِلْمُ الْيَقِين", tr: "'Ilm al-Yaqin", name: LocalizedText(en: "The Knowing", ur: "جاننا", ar: "المعرفة")),
            ActInfo(number: 2, ar: "عَيْنُ الْيَقِين", tr: "'Ayn al-Yaqin", name: LocalizedText(en: "The Witnessing", ur: "دیکھنا", ar: "المشاهدة")),
            ActInfo(number: 3, ar: "حَقُّ الْيَقِين", tr: "Haqq al-Yaqin", name: LocalizedText(en: "The Living", ur: "جینا", ar: "المعايشة")),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: LocalizedText(en: "A DEEP DIVE", ur: "ایک گہرا مطالعہ", ar: "غوص عميق"),
                titleAr: "يَقِين",
                titleEn: "Yaqin",
                subtitle: LocalizedText(en: "Certainty", ur: "یقین", ar: "اليقين"),
                line: LocalizedText(en: "A descent through the Qur'an and the Ahl al-Bayt - in three depths.", ur: "قرآن اور اہل بیتؑ کی معیت میں ایک سفر - تین گہرائیوں کے اندر اترتا ہوا۔", ar: "نزولٌ عبر القرآن الكريم وأهل البيت عليهم السلام - في ثلاثة أعماق.")
            ),

            // 02. Before you descend
            .orientation(
                eyebrow: LocalizedText(en: "Before you descend", ur: "اترنے سے پہلے", ar: "قبل أن تنزل"),
                promise: LocalizedText(en: "Three depths of certainty lie below - to know it, to see it, to live it.", ur: "نیچے یقین کی تین گہرائیاں موجود ہیں - اسے جاننا، اسے دیکھنا، اور اسے جینا۔", ar: "ثلاثةُ أعماقٍ من اليقين تكمن أدناه - أن تعرفه، وأن تراه، وأن تحياه."),
                leaveWith: LocalizedText(en: "You'll leave with a map of certainty - and a prayer to deepen your own.", ur: "آپ یہاں سے یقین کا ایک نقشہ لے کر جائیں گے - اور ایک ایسی دعا بھی، جو آپ کے اپنے یقین کو مزید گہرا کر دے۔", ar: "ستخرج بخريطةٍ لليقين - ودعاءٍ يعمّق يقينَك أنت.")
            ),

            // 02b. Threshold - The Three Depths (overview map, before the descent)
            .depths(
                act: 0, tag: LocalizedText(en: "The Three Depths", ur: "تین گہرائیاں", ar: "الأعماق الثلاثة"), reference: "al-Takathur · al-Waqi'ah",
                items: [
                    Depth(ar: "عِلْمُ الْيَقِين", tr: "‘Ilm al-Yaqin", label: LocalizedText(en: "Knowledge of Certainty", ur: "علم الیقین", ar: "عِلْمُ اليَقِين"), desc: LocalizedText(en: "To know the fire exists - by the smoke on the horizon.", ur: "آگ کا وجود جاننا - افق پر اٹھتے دھوئیں سے۔", ar: "أن تعلم أنّ النار موجودة - من الدخان المتصاعد في الأفق."), reference: nil, embodies: LocalizedText(en: "the mind that reasons", ur: "غور و فکر کرنے والا ذہن", ar: "العقل الذي يستدلّ")),
                    Depth(ar: "عَيْنُ الْيَقِين", tr: "‘Ayn al-Yaqin", label: LocalizedText(en: "Eye of Certainty", ur: "عین الیقین", ar: "عَيْنُ اليَقِين"), desc: LocalizedText(en: "To see the fire with your own eyes.", ur: "آگ کو اپنی آنکھوں سے دیکھنا۔", ar: "أن ترى النار بعينك."), reference: "102:7", embodies: LocalizedText(en: "the prophets who saw", ur: "وہ انبیاءؑ جنہوں نے دیکھا", ar: "الأنبياء الذين رأوا")),
                    Depth(ar: "حَقُّ الْيَقِين", tr: "Haqq al-Yaqin", label: LocalizedText(en: "Truth of Certainty", ur: "حق الیقین", ar: "حَقُّ اليَقِين"), desc: LocalizedText(en: "To stand within the flame itself.", ur: "خود شعلے کے اندر کھڑا ہونا۔", ar: "أن تقف داخل اللهب نفسه."), reference: "56:95", embodies: LocalizedText(en: "the family who lived it", ur: "وہ خاندان جس نے اسے جیا", ar: "الأسرة التي عاشته")),
                ]
            ),

            // 03. Movement I - The Knowing (movement card)
            .act(act: 1, connector: nil, line: LocalizedText(en: "It begins in the mind. Before certainty can be witnessed or lived, it must first be known - reasoned out and held as true, though the eyes have not yet seen.", ur: "یہ ذہن سے شروع ہوتا ہے۔ یقین کو دیکھنے یا جینے سے پہلے، اسے پہلے جاننا ضروری ہے - عقل سے سمجھا جائے اور سچ تسلیم کیا جائے، اگرچہ آنکھوں نے ابھی اسے دیکھا نہ ہو۔", ar: "يبدأ اليقينُ في العقل. فقبل أن يُشاهَد أو يُعاش، لا بدّ أن يُعرَف أولاً - أن يُستدلّ عليه ويُعتقَد صدقُه، وإن لم تره العينُ بعد."), bridge: nil),

            // 04. Movement I - The Question (al-Takathur 102:5)
            .verse(
                act: 1, tag: LocalizedText(en: "The Question", ur: "سوال", ar: "السؤال"), surah: 102, ayah: 5,
                arabic: "كَلَّا لَوْ تَعْلَمُونَ عِلْمَ الْيَقِينِ",
                translation: LocalizedText(en: "No - if only you knew with the knowledge of certainty…", ur: "ہرگز نہیں! کاش تم علمِ یقین کے ساتھ جان لیتے…", ar: ""),
                reference: "al-Takathur · 102 : 5",
                reflection: LocalizedText(en: "Before certainty can be lived, it must be understood. The Qur'an says it arrives in depths - three of them.", ur: "یقین کو جینے سے پہلے، اسے سمجھنا ضروری ہے۔ قرآن کہتا ہے کہ یہ گہرائیوں کی صورت میں آتا ہے - اور یہ گہرائیاں تین ہیں۔", ar: "قبل أن يُعاش اليقين، لا بدّ أن يُفهَم. يخبرنا القرآن أنه يأتي في أعماق - ثلاثة أعماق.")
            ),

            // 06. Movement I - Ibrahim Reasons His Way (al-An'am 6:76)
            .verse(
                act: 1, tag: LocalizedText(en: "Ibrahim Reasons His Way", ur: "ابراہیمؑ عقل سے راہ پاتے ہیں", ar: "إبراهيم عليه السلام يهتدي بالاستدلال"), surah: 6, ayah: 76,
                arabic: "فَلَمَّا جَنَّ عَلَيْهِ اللَّيْلُ رَأَىٰ كَوْكَبًا ۖ قَالَ هَٰذَا رَبِّي ۖ فَلَمَّا أَفَلَ قَالَ لَا أُحِبُّ الْآفِلِينَ",
                translation: LocalizedText(en: "When night covered him, he saw a star. He said, “This is my Lord.” But when it set, he said, “I love not those that set.”", ur: "پھر جب رات نے اسے ڈھانپ لیا تو انہوں نے ایک ستارہ دیکھا۔ انہوں نے کہا، “یہ میرا رب ہے۔” پھر جب وہ غروب ہو گیا تو انہوں نے کہا، “میں غروب ہونے والوں سے محبت نہیں رکھتا۔”", ar: ""),
                reference: "al-An'am · 6 : 76",
                reflection: LocalizedText(en: "God showed him the kingdom of the heavens and the earth, 'that he might be of those of certainty.' Star, moon, sun - each one sets, until Ibrahim turns his face to the One who never does: the smoke on the horizon that proves the fire.", ur: "اللہ نے انہیں آسمانوں اور زمین کی بادشاہت دکھائی، ‘تاکہ وہ یقین رکھنے والوں میں سے ہو جائیں۔’ ستارہ، چاند، سورج - ہر ایک غروب ہو جاتا ہے، یہاں تک کہ حضرت ابراہیمؑ اپنا رخ اس ذات کی طرف موڑ لیتے ہیں جو کبھی غروب نہیں ہوتی: وہی افق پر اٹھتا دھواں جو آگ کے ہونے کی دلیل ہے۔", ar: "أرى اللهُ إبراهيمَ عليه السلام ملكوتَ السماوات والأرض 'وَلِيَكُونَ مِنَ الْمُوقِنِينَ'. النجمُ والقمرُ والشمسُ - كلٌّ منها يأفل ويغيب، حتى يُولّي إبراهيمُ عليه السلام وجهَه نحو مَن لا يأفل أبداً: الدخانُ في الأفق الذي يدلّ على النار.")
            ),

            // 07. Movement II - opening card
            .act(act: 2, connector: LocalizedText(en: "You have known it by proof.", ur: "آپ نے اسے دلیل کے ذریعے جان لیا ہے۔", ar: "لقد عرفتَه بالبرهان."), line: LocalizedText(en: "Now - see it. The Qur'an did not leave the prophets or those God chose to merely believe; it let them witness, with their own eyes.", ur: "اب - اسے دیکھیے۔ قرآن نے انبیاءؑ اور اللہ کے برگزیدہ بندوں کو محض ایمان لانے پر نہیں چھوڑا؛ بلکہ انہیں اپنی آنکھوں سے مشاہدہ کرنے دیا۔", ar: "والآن - شاهِدْه. لم يترك القرآنُ الأنبياءَ ولا مَن اصطفاهم اللهُ على مجرد الإيمان؛ بل جعلهم يشهدون بأعينهم."), bridge: nil),

            // 08. Movement II - Ibrahim Asks to See (al-Baqarah 2:260)
            .verse(
                act: 2, tag: LocalizedText(en: "Ibrahim Asks to See", ur: "ابراہیمؑ دیکھنے کی درخواست کرتے ہیں", ar: "إبراهيم عليه السلام يطلب أن يرى"), surah: 2, ayah: 260,
                arabic: "قَالَ أَوَلَمْ تُؤْمِن ۖ قَالَ بَلَىٰ وَلَٰكِن لِّيَطْمَئِنَّ قَلْبِي",
                translation: LocalizedText(en: "“Do you not believe?” He said: “Yes - but so that my heart may be at rest.”", ur: "“کیا تم ایمان نہیں رکھتے؟” انہوں نے کہا: “کیوں نہیں - مگر یہ چاہتا ہوں کہ میرا دل مطمئن ہو جائے۔”", ar: ""),
                reference: "al-Baqarah · 2 : 260",
                reflection: LocalizedText(en: "Even the Friend of God, who already believed, longed to witness. He is asking to move from the first depth to the second.", ur: "اللہ کے خلیل بھی، جو پہلے سے ایمان رکھتے تھے، مشاہدے کے آرزو مند تھے۔ وہ پہلی گہرائی سے دوسری گہرائی کی طرف بڑھنے کی درخواست کر رہے ہیں۔", ar: "حتى خليلُ اللهِ عليه السلام، الذي كان مؤمناً بالفعل، تاق إلى المشاهدة. إنه يطلب الانتقال من العمق الأول إلى الثاني.")
            ),

            // 09. Movement II - And Then He Sees (al-Anbiya 21:69)
            .verse(
                act: 2, tag: LocalizedText(en: "And Then He Sees", ur: "اور پھر وہ دیکھتے ہیں", ar: "ثم يرى"), surah: 21, ayah: 69,
                arabic: "قُلْنَا يَا نَارُ كُونِي بَرْدًا وَسَلَامًا عَلَىٰ إِبْرَاهِيمَ",
                translation: LocalizedText(en: "We said: “O fire - be coolness and peace upon Ibrahim.”", ur: "ہم نے فرمایا: “اے آگ! تو ابراہیمؑ پر ٹھنڈک اور سلامتی بن جا۔”", ar: ""),
                reference: "al-Anbiya · 21 : 69",
                reflection: LocalizedText(en: "He had asked to witness. Now, cast into the flames, he does - and the fire itself submits to his certainty.", ur: "انہوں نے مشاہدے کی درخواست کی تھی۔ اب، آگ میں ڈالے جانے کے بعد، وہ مشاہدہ کر رہے ہیں - اور خود آگ ان کے یقین کے سامنے سرِ تسلیم خم کر دیتی ہے۔", ar: "لقد طلب أن يشهد. والآن، وهو يُلقى في اللهب، يشهد - والنارُ نفسُها تستسلم ليقينه.")
            ),

            // 10. Movement II - The Mother of Musa (al-Qasas 28:7)
            .verse(
                act: 2, tag: LocalizedText(en: "The Mother of Musa", ur: "موسیٰؑ کی والدہ", ar: "أمّ موسى عليه السلام"), surah: 28, ayah: 7,
                arabic: "فَإِذَا خِفْتِ عَلَيْهِ فَأَلْقِيهِ فِي الْيَمِّ وَلَا تَخَافِي",
                translation: LocalizedText(en: "When you fear for him, cast him into the river - and do not fear.", ur: "جب تجھے اس کے بارے میں خوف ہو تو اسے دریا میں ڈال دے - اور خوف نہ کر۔", ar: ""),
                reference: "al-Qasas · 28 : 7",
                reflection: LocalizedText(en: "To lay her infant upon the water on nothing but God's word - certainty is no longer a thought. It has become an act.", ur: "اپنے شیرخوار بچے کو محض اللہ کے کلام پر بھروسہ کرتے ہوئے پانی کے سپرد کر دینا - یہاں یقین محض ایک خیال نہیں رہتا۔ یہ ایک عمل بن جاتا ہے۔", ar: "أن تضع رضيعَها على الماء بمجرد كلمةِ الله - لم يعد اليقينُ حينئذٍ فكرةً، بل أصبح فعلاً.")
            ),

            // 11. Movement III - opening card with bridge verse
            .act(
                act: 3, connector: LocalizedText(en: "You have seen it in the prophets.", ur: "آپ نے اسے انبیاءؑ میں دیکھ لیا ہے۔", ar: "لقد رأيتَه في الأنبياء."), line: LocalizedText(en: "Now - live it. For most, certainty comes only at death. But one family, the Prophet's own household, was asked to stand inside the flame - while still alive.", ur: "اب - اسے جیئے۔ اکثر لوگوں کے لیے یقین موت کے وقت ہی آتا ہے۔ لیکن ایک خاندان سے - خود رسول اللہﷺ کے اہل بیتؑ سے - یہ طلب کیا گیا کہ وہ زندہ رہتے ہوئے ہی شعلے کے اندر کھڑے ہوں۔", ar: "والآن - عِشْه. فعند أكثر الناس، لا يأتي اليقينُ إلا عند الموت. غير أنّ أسرةً واحدة، هي أهلُ بيت النبي صلى الله عليه وآله وسلم أنفسهم، طُلب منها أن تقف داخل اللهب - وهي على قيد الحياة."),
                bridge: BridgeVerse(
                    surah: 15, ayah: 99,
                    arabic: "وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ",
                    translation: LocalizedText(en: "And worship your Lord until certainty comes to you.", ur: "اور اپنے رب کی عبادت کرتے رہو یہاں تک کہ تمہارے پاس یقین آ جائے۔", ar: ""),
                    reference: "al-Hijr · 15 : 99"
                )
            ),

            // 12. Movement III - The Morning of Ashura
            .narration(
                act: 3, tag: LocalizedText(en: "The Morning of Ashura", ur: "عاشورہ کی صبح", ar: "صباح عاشوراء"), source: LocalizedText(en: "Radiance at Karbala - narrated of Hilal ibn Nafi", ur: "کربلا کی تابانی - ہلال بن نافع سے مروی", ar: "إشراقٌ في كربلاء - رُوي عن هلال بن نافع"),
                body: LocalizedText(en: "They said that as the arrows fell thicker upon them, the face of Husayn only grew more luminous and calm - so much so that those who looked on were struck by its light.", ur: "کہا گیا ہے کہ جوں جوں تیر ان پر کثرت سے برستے گئے، امام حسینؑ کا چہرہ اور بھی روشن اور پرسکون ہوتا گیا - یہاں تک کہ دیکھنے والے اس کے نور سے مبہوت رہ گئے۔", ar: "قالوا إنه كلما اشتدّ وقعُ السهام عليهم، ازداد وجهُ الحسين عليه السلام إشراقاً وسكينةً - حتى إنّ مَن نظر إليه بُهر بنوره."),
                reflection: LocalizedText(en: "The closer the meeting with the Beloved, the brighter the certainty. This is no longer witnessing from the outside - it is standing within the very fire the depths spoke of.", ur: "محبوبِ حقیقی سے ملاقات جتنی قریب آتی، یقین اتنا ہی روشن ہوتا جاتا۔ یہ اب باہر سے مشاہدہ کرنا نہیں رہا - یہ خود اسی آگ کے اندر کھڑا ہونا ہے جس کا ذکر تینوں گہرائیوں میں ہوا۔", ar: "كلما اقترب اللقاءُ بالمحبوب، ازداد اليقينُ تألقاً. لم تعد هذه مشاهدةً من الخارج - إنها الوقوفُ داخل النار نفسِها التي تحدثت عنها الأعماقُ.")
            ),

            // 13. Movement III - The Court (Sayyida Zaynab)
            .climax(
                act: 3, tag: LocalizedText(en: "The Court", ur: "دربار", ar: "المجلس"), source: LocalizedText(en: "Sayyida Zaynab, in the court of Ibn Ziyad - Kufa", ur: "سیدہ زینبؑ، ابن زیاد کے دربار میں - کوفہ", ar: "السيدة زينب عليها السلام، في مجلس ابن زياد - الكوفة"),
                arabic: "مَا رَأَيْتُ إِلَّا جَمِيلًا",
                translation: LocalizedText(en: "I saw nothing but beauty.", ur: "میں نے سوائے خوبصورتی کے کچھ نہیں دیکھا۔", ar: ""),
                body: LocalizedText(en: "After the sons. After the brothers. After the tents burned and the caravan was driven in chains - she stood in the court of the tyrant and said she had witnessed nothing but beauty.", ur: "بیٹوں کے بعد۔ بھائیوں کے بعد۔ خیمے جلائے جانے اور قافلے کو زنجیروں میں جکڑ کر لے جانے کے بعد - وہ ظالم کے دربار میں کھڑی ہوئیں اور فرمایا کہ انہوں نے سوائے خوبصورتی کے کچھ نہیں دیکھا۔", ar: "بعد فقد الأبناء. بعد فقد الإخوة. بعد أن أُحرقت الخيام وسِيق الركبُ مكبّلاً بالأغلال - وقفت في مجلس الطاغية، وقالت: ما رأت إلا جميلاً."),
                reflection: LocalizedText(en: "This is Haqq al-Yaqin - the truth of certainty. Not the absence of grief, but the certainty that sees the divine beauty through it.", ur: "یہی حق الیقین ہے - یقین کی حقیقت۔ یہ غم کی عدم موجودگی نہیں، بلکہ وہ یقین ہے جو غم کے اندر سے بھی الٰہی خوبصورتی کو دیکھ لیتا ہے۔", ar: "هذا هو حَقُّ اليَقِين. ليس غيابَ الحزن، بل اليقينُ الذي يرى الجمالَ الإلهي من خلاله.")
            ),

            // 14. The Close - reflection prompt
            .reflectionPrompt(tag: LocalizedText(en: "Return", ur: "واپسی", ar: "العودة"), prompt: LocalizedText(en: "Where is your yaqin?", ur: "آپ کا یقین کہاں ہے؟", ar: "أين يَقِينُكَ؟"), placeholder: LocalizedText(en: "Faith, a decision, a loss, the unseen ahead…", ur: "ایمان، کوئی فیصلہ، کوئی نقصان، سامنے کا اَن دیکھا…", ar: "الإيمان، قرارٌ، فقدٌ، الغيب الذي ينتظر…"),
                subline: LocalizedText(
                    en: "You've descended all three depths - knowing, witnessing, living. The map is yours. Before the prayer, name the certainty you long for.",
                    ur: "آپ تینوں گہرائیوں میں اتر چکے ہیں - جاننا، دیکھنا، جینا۔ نقشہ اب آپ کا ہے۔ دعا سے پہلے، اُس یقین کا نام لیں جس کی آپ کو تلاش ہے۔",
                    ar: "لقد نزلتَ الأعماق الثلاثة - أن تعلم، أن ترى، أن تعيش. الخريطة لك. قبل الدعاء، سمِّ اليقين الذي تشتاق إليه."),
                nextLabel: LocalizedText(en: "And one prayer", ur: "اور ایک دعا", ar: "ودعاءٌ واحد")),

            // 15. The Close - a prayer for certainty
            .dua(
                tag: LocalizedText(en: "A Prayer for Certainty", ur: "یقین کے لیے ایک دعا", ar: "دعاءٌ لليقين"), intro: LocalizedText(en: "After all of it - one prayer, from the family you just stood beside.", ur: "اس سب کے بعد - ایک دعا، اسی خاندان کی طرف سے جس کے ساتھ آپ ابھی کھڑے تھے۔", ar: "بعد كل هذا - دعاءٌ واحد، من الأسرة التي وقفتَ بجوارها للتو."),
                arabic: "وَبَلِّغْ بِإِيمَانِي أَكْمَلَ الْإِيمَانِ، وَاجْعَلْ يَقِينِي أَفْضَلَ الْيَقِينِ",
                translation: LocalizedText(en: "“Bring my faith to the most perfect faith, and make my certainty the most excellent certainty.”", ur: "“میرے ایمان کو کامل ترین ایمان تک پہنچا دے، اور میرے یقین کو بہترین یقین بنا دے۔”", ar: ""),
                source: LocalizedText(en: "Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya", ur: "امام علی ابن الحسینؑ · الصحیفہ السجادیہ", ar: "الإمام علي بن الحسين عليه السلام · الصحيفة السجادية"),
                note: LocalizedText(en: "The son of Husayn - present at Karbala, the one who lived to carry it. He witnessed certainty's severest trial, and still asked God to deepen his own.", ur: "امام حسینؑ کے فرزند - جو کربلا میں موجود تھے اور زندہ رہ کر اسے آگے لے جانے والے تھے۔ انہوں نے یقین کی سب سے سخت آزمائش کا مشاہدہ کیا، اور پھر بھی اللہ سے اپنے یقین کو مزید گہرا کرنے کی دعا مانگی۔", ar: "ابنُ الحسين عليه السلام - كان حاضراً في كربلاء، وهو مَن عاش ليحمل أمانتَها. شهد أقسى اختبارٍ لليقين، ومع ذلك سأل اللهَ أن يزيد يقينَه عمقاً."),
                close: "The certainty is yours to keep."
            ),
        ]
    )
}
