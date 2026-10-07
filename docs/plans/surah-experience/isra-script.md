# "Inside the Surah - al-Isra" - Master Script (English)

**Status:** APPROVED (Gate 2, 2026-10-02) and SHIPPED to code. Blueprint (Gate 1) approved 2026-10-02. Stage 5 four-auditor audit (2026-10-02) applied - blocker and should-fix bands - and the FINAL COPY below is regenerated from the same source as `Thaqalayn/Content/SurahIsraDive.swift`, so the two match.
**Surah:** 17 (al-Isra, also called Bani Isra'il), 111 verses, Meccan. Gating: PREMIUM (default). Placement: catalog entry at surahNumber 17 (after al-Nahl).
**Framing:** a surah about height. It opens at the highest point any human has been taken ("Glory be to Him who carried His servant by night") and closes with "magnify Him," after showing the people of knowledge falling to the ground in prostration. Al-Mizan names the surah's dominant note as tasbih (it opens with subhan, repeats it at 43, 93, 108) and remarks on its design: it opens with tasbih and closes with takbir. The spine question: who is truly high, and how does a servant rise? The false heights (a people's "great height" of arrogance, the strut that cannot match the mountains, Iblis refusing to bow) stand against the one true Height, and against the lowly postures by which a servant actually rises (the lowered wing, the night vigil, the fall into prostration). The climax reveals, through Imam al-Kazim (a), what the surah never tells: at the summit of the Night Journey the Prophet ﷺ fell on his face saying "Glory be to my Lord, the Most High" - the origin of the prayer's opening takbirs and of the sujud dhikr.
**Depth:** 21 beats, est. 15 min. FOUR movements from the surah's own joints: 1-8 (the Night Journey and the Children of Israel) / 22-44 (the commandments and the One who is High) / 61-82 (Iblis, the honor of Adam's children, the night vigil) / 90-111 (the demanded ascent, the knowers' prostration, the closing takbir). No rewind; the dive follows the surah's order.

## Controlling textual facts (verified against quran_data.json)
- **'uluwwan kabira** (a great height) occurs exactly twice in the entire Qur'an, both here: 17:4 (the Children of Israel's arrogance) and 17:43 (God's exaltation). Planted at 17:4, paid off at 17:43.
- **subhan** occurs four times in the surah: 17:1 (Him), 17:43 (Him), 17:93 (my Lord - the Prophet ﷺ), 17:108 (our Lord - the knowers). Then 17:111 commands "and say... magnify Him." Planted lightly from 17:1, counted at 17:93, paid off at 17:109.
- **yakhirruna lil-adhqan** (they fall upon their chins) occurs only at 17:107 and 17:109 in the entire Qur'an.
- **k-r-m** (honor): 17:23 (karim), 17:62 (karramta, Iblis), 17:70 (karramna, God). Majma al-Bayan explicitly reads 17:70 as God's answer to 17:62.
- **qada**: 17:4 (qadayna - declared, by informing; al-Mizan via al-Raghib) and 17:23 (qada rabbuka - a command). The echo was dropped from the copy at audit: it implied God decreed the arrogance, and it was never paid off.
- **al-A'la** (the Most High, in the sujud dhikr) shares the root '-l-w with 'uluw.

## House-style + design notes
- Plain English spelling, NO diacritics; no em dashes anywhere - only " - ".
- **No spoilers:** the orientation promises only that the descent will reveal what happened at the top of the Night Journey and why you repeat it in prayer. The seven veils, the fall at the summit and al-A'la stay in the climax. 'uluwwan kabira is planted at 17:4 with "remember these two words" and counted only at 17:43.
- **No threshold map** (not a plot). Close is `.closing` - no dua beat, so no Listen button is owed; verse beats carry the standard recitation button.
- **`.response` reuse** (only al-Fatiha uses it so far): after the climax, God's reply to the angel's adhan that night (Tafsir al-Qummi): «صدق عبدي أن محمداً عبدي ورسولي» - "Muhammad is My servant and My messenger." Rebuilt at audit around this SECOND reply (the first, "I am greater", answers the angel, and readers took it as answering the Prophet ﷺ). It closes the 'abd (servant) thread of 17:1 and answers 17:93's "a human being, a messenger". The angel is named in `replyingTo`. Anchor Arabic is hadith, hand-authored, not byte-checked.
- **Overlap with other dives, handled:** al-Hijr covered Iblis's contempt for clay (15:33) and "no authority" (15:42); this dive takes the distinct angle of the resented honor (karramta) and does not use 17:65. Al-Hijr's 15:88 "lower your wing to the believers" is a different addressee (parents here).
- **The al-Husayn (a) reading of 17:4** is one framed paragraph inside the 17:4 beat, presented as al-Mizan presents such reports: an application (tatbiq) to this umma, not a replacement for the verse's meaning.
- Honorifics: the Prophet ﷺ; (a) for the Imams, prophets, and Jibril where named.

## Sourcing notes - verification status
Verified 2026-10-02 against the Arabic primary-source blocks gathered in `passages_work/17/*/sources.json` (al-Mizan, Majma al-Bayan, Tafsir al-Qummi, al-Burhan, Tafsir al-Safi), plus web confirmation where noted.

- **Surah's tasbih frame** - VERIFIED, al-Mizan opening of 17:1: «يغلب فيها جانب التسبيح على جانب التحميد كما بدأت به... وكرر ذلك... الآية 43... الآية 93... الآية 108». And under 17:111: «ومن لطيف الصنعة في السورة افتتاح أول آية منها بالتسبيح واختتام آخر آية منها بالتكبير».
- **17:1 subhan = tanzih, asra, li-nuriyahu, al-Sami' al-Basir** - VERIFIED, al-Mizan: subhan here is tanzih (context, not ta'ajjub); asra = to take by night; li-nuriyahu is the purpose; «إنه هو السميع البصير تعليل... وقد سمع من مقال عبده ورأى من حاله ما استدعى أن يكرمه هذا الإكرام».
- **No place for God; why the ascent** - VERIFIED, Imam al-Kazim (a) via Yunus ibn Abd al-Rahman, al-Saduq (al-Burhan [14]; 'Ilal al-Shara'i per web check): «إن الله لا يوصف بمكان، ولا يجري عليه زمان، ولكنه عز وجل أراد أن يشرف به ملائكته وسكان سماواته، ويكرمهم بمشاهدته، ويريه من عجائب عظمته ما يخبر به بعد هبوطه».
- **Leading the prophets, "wa la fakhr"** - VERIFIED, Tafsir al-Qummi, Ali ibn Ibrahim from his father from Ibn Abi Umayr from Hisham ibn Salim from al-Sadiq (a) (also in al-Mizan's bahth riwa'i and al-Burhan [1]): «فوجدنا إبراهيم وموسى وعيسى فيمن شاء الله من أنبياء الله... ولا أشك إلا وجبرئيل سيتقدمنا فلما استووا أخذ جبرئيل بعضدي فقدمني وأممتهم ولا فخر».
- **17:4 'uluw = istikbar** - VERIFIED, Majma: «ولتعلن علواً كبيراً أي ولتستكبرن ولتظلمن الناس ظلماً عظيماً والعلو نظير العتو هنا وهو الجرأة على الله تعالى».
- **17:4 applied to al-Husayn (a)** - VERIFIED, al-Kafi (al-Rawda) via al-Burhan: «قتل علي بن أبي طالب وطعن الحسن ... ولتعلن علوا كبيرا قال قتل الحسين»; also Kamil al-Ziyarat (Ibn Qulawayh, Salih ibn Sahl) via al-Mizan. Al-Mizan's framing: «مسوقة لتطبيق ما يجري في هذه الأمة من الحوادث على ما جرى منها في بني إسرائيل تصديقاً لما تواتر عن النبي... حذو النعل بالنعل... وليست الروايات واردة في تفسير الآيات».
- **17:23-24 parents** - VERIFIED, al-Kafi (Abu Wallad al-Hannat from al-Sadiq (a); also al-Faqih): «لا تملأ عينيك من النظر إليهما إلا برحمة ورقة ولا ترفع صوتك فوق أصواتهما ولا يديك فوق أيديهما ولا تتقدم قدامهما»; uff: al-Kafi (Hadid ibn Hakim and Ibn Abi al-Bilad from al-Sadiq (a)): «لو علم الله شيئا أدنى من أف لنهى عنه».
- **17:37** - VERIFIED, al-Mizan: marah; pride shows in deeds, words, standing and sitting, and above all in walking («في أفعاله وأقواله وقيامه وقعوده وخاصة في مشيه») - corrected at audit (the copy had said pride hides in words); «كناية عن أن فعالك هذا... وهم تتوهمه فإن هناك ما هو أقوى منك... وما هو أطول منك... فاعترف بذلك أنك وضيع مهين»; mulk, 'izza, sultana, qudra, su'dud, mal = «أمور وهمية لا حقيقة لها وراء الإدراك الإنساني سخر الله النفوس للتصديق بها... لتعمير النشأة».
- **17:43-44** - VERIFIED, al-Mizan: 17:43 tanzih from partners and from His rule passing to another; tasbih of all things is real (qali haqiqi), each thing reveals by its need its Lord's freedom from need; «العلم سار في الموجودات». Narrations: al-Kafi (Dawud al-Raqqi from al-Sadiq (a)) «تنقض الجدر تسبيحها» (also al-Ayyashi); al-Ayyashi (al-Sakuni) the Prophet ﷺ forbade branding or striking animals' faces «فإنها تسبح بحمد ربها».
- **17:62** - VERIFIED, al-Mizan: Iblis understood the honor from the command to bow («فهم التفضيل من أمر السجدة»); ihtinak root = putting a rope in the lower jaw to lead («حنك الدابة بحبلها... والظاهر أن المعنى الأخير هو الأصل»).
- **17:70** - VERIFIED, Majma: «لمّا تقدَّم قول إبليس هذا الذي كرَّمت عليّ ذكر سبحانه بعد ذلك تكرمة لبني آدم»; al-Mizan: imtinan mixed with reproach, addressed to all humans including disbelievers; takrim = intrinsic (nafsi), tafdil = relative (idafi).
- **17:78-79** - VERIFIED, al-Mizan: qur'an al-fajr witnessed by angels of night and day (narrations of both schools agree); tahajjud = waking after sleep; maqam mahmud = the station all creation praises = the great intercession, «وقد اتفقت على هذا التفسير الروايات من طرق الفريقين». Majma: «عسى من الله واجبة».
- **17:93** - VERIFIED, al-Mizan: subhana rabbi first declares God above the implied delegation of divine power to the Prophet ﷺ; bashar answers the demand as from his own power, rasul answers it as from delegated power.
- **17:107-109** - VERIFIED, al-Mizan: the chin is the part of the face nearest the ground in falling to prostrate; the REPEATED fall with weeping = khudu' (body), and "it increases them in khushu'" = khushu' (heart). (Corrected at audit: the copy had assigned body-humility to the first fall.) Al-Kafi (via al-Mizan): one whose forehead is ailing places his chin on the ground «إن الله عز وجل يقول ويخرون للأذقان سجداً».
- **Seven veils, seven takbirs, ruku' and sujud dhikr** - VERIFIED, Imam al-Kazim (a) via Hisham ibn al-Hakam, al-Saduq, 'Ilal al-Shara'i (al-Burhan [12]; Wasa'il al-Shi'a, bab istihbab iftitah al-salat bi-sab' takbirat): «فلما أسري بالنبي... رفع له حجاب من حجبه فكبر... حتى بلغ سبع حجب وكبر سبع تكبيرات... فلما ذكر ما رأى من عظمة الله ارتعدت فرائصه فابترك على ركبتيه وأخذ يقول: سبحان ربي العظيم وبحمده. فلما اعتدل من ركوعه قائما، نظر إليه في موضع أعلى من ذلك الموضع، خر على وجهه وهو يقول: سبحان ربي الأعلى وبحمده. فلما قالها سبع مرات سكن ذلك الرعب، فلذلك جرت به السنة». The question as asked is why seven opening takbirs are *best* (afdal). Rendering note: «نظر إليه في موضع أعلى» - the antecedent of إليه is «ما رأى من عظمة الله»; rendered "he saw that greatness in a station higher still" (corrected at audit from "looked again, from a station higher than before", which moved the height onto his vantage point). «ابترك على ركبتيه» = "bowed, bracing himself upon his knees"; «سكن ذلك الرعب» = "his trembling subsided".
- **"I fell down in prostration"** - VERIFIED, Tafsir al-Qummi (same al-Sadiq (a) narration): «ثم غشيتني صبابة فخررت ساجداً».
- **The adhan answered** - VERIFIED, Tafsir al-Qummi (same narration): «ثم سمعت الأذان فإذا ملك يؤذن لم ير في السماء قبل تلك الليلة فقال: الله أكبر الله أكبر فقال الله صدق عبدي أنا أكبر... أشهد أن محمداً رسول الله... فقال الله صدق عبدي أن محمداً عبدي ورسولي».
- **"Greater than can be described"** - VERIFIED, al-Kafi from al-Sadiq (a) (via Tafsir al-Safi; al-Mizan cites it under 17:111): «الله أكبر من أي شيء؟ فقال: من كل شيء، فقال: حددته، فقال الرجل: كيف أقول؟ قال: قل الله أكبر من أن يوصف». Al-Mizan: the takbir is left unqualified after the description and tanzih, so it is «تكبير من كل وصف».
- **Three takbirs after 17:111** - VERIFIED via Tafsir al-Safi: «وفي التهذيب عنه عليه السلام أنه أمر من قرأ هذه الآية أن يكبر ثلاثاً».
- **Surah merit** - VERIFIED via Tafsir al-Safi: «وفي ثواب الأعمال والمجمع والعياشي عن الصادق عليه السلام من قرأ سورة بني إسرائيل في كل ليلة جمعة لم يمت حتى يدرك القائم ويكون من أصحابه».
- **17:109 as a recommended sajda** - Shia fiqh: the four 'aza'im (32, 41, 53, 96) are obligatory; 17:109 is among the eleven recommended. Copy says "recommended".

## DeepDive meta
- **id:** `surah-isra` · **titleEn:** al-Isra · **titleAr:** الْإِسْرَاء
- **subtitle:** The Night Journey - how does a servant rise?
- **sfSymbol:** sparkles · **estMinutes:** 15

## Acts
1. **al-Isra** (الْإِسْرَاء) - "The Journey by Night" (17:1, narration, 17:4)
2. **al-Khafd** (الْخَفْض) - "The Lowered Wing" (17:24, 17:37, 17:43)
3. **al-Karama** (الْكَرَامَة) - "The Honor" (17:62, 17:70, 17:79)
4. **al-Sujud** (السُّجُود) - "The Prostration" (17:93, 17:109; climax 17:111; response)

---

# FINAL COPY

## Beat 1 - OPEN
- **kicker:** INSIDE THE SURAH
- **titleAr:** الْإِسْرَاء
- **titleEn:** al-Isra
- **subtitle:** The Night Journey
- **line:** One night in Mecca, before he migrated to Medina, the Prophet ﷺ was taken from the Sacred Mosque to the Farthest Mosque in Jerusalem, and from there up through the heavens - higher than any human being has ever been brought. This surah opens with that night. Near its end, it shows people falling to the ground in prostration, weeping. Between that height and that fall, al-Isra asks one question: who is truly high - and how does a servant rise?

## Beat 2 - ORIENTATION
- **eyebrow:** Before you begin
- **promise:** The Imams called this surah Bani Isra'il, the Children of Israel; it is also called al-Isra, the Night Journey. Its first word is subhan - glory be to Him - a word that declares God far above anything unworthy of Him. Allama Tabatabai, in his great commentary al-Mizan, observes that in this surah glorification outweighs praise, and that the word returns again and again. Alongside it, the surah keeps setting two kinds of height side by side: the height people try to seize for themselves, and the height that is given. You will meet a nation that raised itself high, a man who walks proudly across the earth, and an enemy who refused to bow. And through it all, the surah keeps returning to one servant, carried by night - and to the lowly postures it asks of everyone else.
- **leaveWith:** You will learn what happened at the very top of the Night Journey - something the surah itself never tells. And you will see why its words return every time you stand to pray.

## Beat 3 - ACT I DIVIDER
- **connector:** (none)
- **line:** The surah does not open with an argument or a command. It opens with a night. Before it says anything about where the journey went, it tells you about the One who carried him - and about the servant He carried.

## Beat 4 - VERSE 17:1
- **tag:** Carried by Night
- **arabic:** [17:1 - injected verbatim]
- **translation:** Glory be to Him who carried His servant by night from the Sacred Mosque to the Farthest Mosque, whose surroundings We have blessed, to show him some of Our signs. Indeed, He is the All-Hearing, the All-Seeing.
- **reference:** al-Isra · 17 : 1
- **reflection:** It opens with subhan: glory be to Him. Before a single detail of the night, the verse declares God far above anything unworthy of Him - that, al-Mizan explains, is what subhan means here. It matters, because a journey upward could make you picture God in a place at the top of the sky. Imam al-Kazim (a) was asked exactly this: why take the Prophet ﷺ up through the heavens, when God is not in a place? He answered that God is not described by place, and time does not pass over Him. Rather, God wanted to honor His angels and the dwellers of His heavens by letting them see the Prophet ﷺ, and to show the Prophet ﷺ wonders of His greatness, so that he could tell people of them when he came back down ('Ilal al-Shara'i). Then the verb: He carried him by night. The Prophet ﷺ did not make this journey by his own power; he was taken. Then the name: bi-'abdihi, His servant. At the greatest honor any human has ever received, God does not call him Messenger or Prophet. He calls him servant. And the signs were not put on display for a crowd; they were shown to one servant. Why this servant? The verse ends with the answer: He is the All-Hearing, the All-Seeing. Al-Mizan reads it as the reason - God had heard His servant's words and seen how he was, and found him worthy of this honor. Hold on to the first word, subhan. The surah will say it again.

## Beat 5 - NARRATION
- **tag:** And No Boast
- **source:** Imam Ja'far al-Sadiq (a) · Tafsir al-Qummi
- **body:** Imam al-Sadiq (a) relates the Prophet's ﷺ own account of that night. At Bayt al-Maqdis, the Farthest Mosque, he tied his mount to the ring where the prophets used to tie theirs, and went in with Jibril (a) beside him. Inside were Ibrahim, Musa and 'Isa (a), among the prophets God had gathered there. The prayer was called. “I had no doubt that Jibril would step forward to lead us,” the Prophet ﷺ said. “But when they had formed their rows, Jibril took me by the arm and put me in front, and I led them in prayer - and no boast.”
- **reflection:** Wa la fakhr - and no boast. He stood in front of the greatest men God ever sent, and when he told of it, he added “and no boast,” so that no one would mistake it for pride. He did not step forward; he was put forward. That is the surah's first picture of true height: a rank so high that the prophets prayed behind him - and he claimed nothing for himself. Keep this mosque in mind. A few verses later, the surah returns to it - and shows people entering it in a very different way.

## Beat 6 - VERSE 17:4
- **tag:** A Great Height
- **arabic:** [17:4 - injected verbatim]
- **translation:** And We declared to the Children of Israel in the Book: “You will surely cause corruption in the land twice, and you will surely rise to a great height of arrogance.”
- **reference:** al-Isra · 17 : 4
- **reflection:** Right after the Night Journey, the surah turns to the Children of Israel - the people for whom that same Farthest Mosque had been holy. God had told them, in their own Book, what they would do: twice they would spread corruption in the land, and they would rise to 'uluwwan kabira - a great height. The scholar Tabrisi, in his commentary Majma al-Bayan, explains what kind of height this is: arrogance, oppressing people, boldness against God. Both times, God sent against them servants of His, of fierce might, and the second time those armies would “enter the mosque as they entered it the first time” (17:7). So one mosque has seen two kinds of entry: a servant carried in by night, saying “no boast” - and armies breaking in on a people who had raised themselves high. The Imams heard a warning in this for their own community. Imam al-Sadiq (a) applied these verses to the Muslim umma: the two corruptions were the killing of Imam Ali (a) and the wounding of Imam al-Hasan (a), and the great height of arrogance was the killing of Imam al-Husayn (a) (al-Kafi; Kamil al-Ziyarat). Al-Mizan explains that such reports do not change what the verses are about. They show the same pattern returning in this community, as the Prophet ﷺ said it would follow what the Children of Israel did, step by step. Remember these two words: 'uluwwan kabira, a great height. You will hear them once more.

## Beat 7 - ACT II DIVIDER
- **connector:** A servant carried up by night - and a nation that raised itself high, and was broken.
- **line:** Now the surah turns from history to you. In the middle of al-Isra there is a series of commandments. The surah itself calls them “the wisdom your Lord has revealed to you” (17:39). Read them with this surah's question in mind, and you notice how many of them are about how high you hold yourself. They begin at home.

## Beat 8 - VERSE 17:24
- **tag:** The Lowered Wing
- **arabic:** [17:24 - injected verbatim]
- **translation:** And lower to them the wing of humility, out of mercy, and say: “My Lord, have mercy on them, as they raised me when I was small.”
- **reference:** al-Isra · 17 : 24
- **reflection:** The commandment begins in the verse before: “Your Lord has decreed that you worship none but Him, and that you be good to your parents” (17:23). When your parents grow old in your care, do not say to them uff - the small sound people make when they are irritated. Imam al-Sadiq (a) said that if God had known any word smaller than uff, He would have forbidden that too (al-Kafi). Then this verse: lower to them the wing of humility. A bird lowers its wing to shelter what is beneath it. You are asked to do the same. The verse calls it the wing of dhull - lowliness. Imam al-Sadiq (a) explained what it looks like in a home. When you look at them, look only with mercy and tenderness. Do not raise your voice above their voices, or your hand above their hands. And do not walk ahead of them (al-Kafi). Voice, hand, step - in each one, you choose to be lower. The verse ends with a prayer that holds your parents' whole story in one line: “as they raised me when I was small.” There was a time you could not hold up your own head, and they held it for you. Now that they have grown old, the surah asks you to lower yourself before them.

## Beat 9 - VERSE 17:37
- **tag:** The Height of the Mountains
- **arabic:** [17:37 - injected verbatim]
- **translation:** And do not walk on the earth in arrogance. You will never tear open the earth, and you will never reach the mountains in height.
- **reference:** al-Isra · 17 : 37
- **reflection:** From the home, the surah steps outside and watches how you walk. Marah is the proud, showy walk of someone pleased with himself. Al-Mizan explains why the verse names walking: pride shows in a person's deeds and words, in how he stands and sits - and above all in his stride. Then the verse answers that pride in two plain sentences: you will never tear open the earth beneath your feet, and you will never reach the height of the mountains, however high you hold your head. Al-Mizan draws out the point: the show of power is an illusion. There is something stronger than you under your feet, and something taller than you all around you - so admit how small you are. And he widens it to every height people chase: rule, honor, power, rank, wealth. These, he says, are real only in people's minds. God lets people rely on them so that life on earth can go on - but they are not the height they seem. A nation rose to “a great height” and was broken. A man lifts his chin in pride and still cannot reach the mountains. A few verses later, the surah tells you who alone is high.

## Beat 10 - VERSE 17:43
- **tag:** The Only High One
- **arabic:** [17:43 - injected verbatim]
- **translation:** Glory be to Him, and high is He above what they say - a great height.
- **reference:** al-Isra · 17 : 43
- **reflection:** Here is the surah's second subhan - and here, again, are two words you have heard before. 'Uluwwan kabira, a great height. In the entire Qur'an this phrase appears exactly twice, and both are in this surah. The first time, it was a nation's arrogance: “you will surely rise to a great height of arrogance” (17:4). Here, it belongs to God alone: high is He above what they say, a great height. The surah has set the two side by side. One great height was seized, and it was broken. The other is not seized by anyone; it is simply His. Then the next verse opens your eyes to all of creation: “The seven heavens and the earth and whoever is in them glorify Him. There is not a thing but glorifies Him with praise - but you do not understand their glorification” (17:44). Al-Mizan insists this praise is real, not a figure of speech. Imam al-Sadiq (a) gave an example you can hear: the creak of a wall is its glorification (al-Kafi). And the Prophet ﷺ forbade striking an animal on its face, “for it glorifies its Lord with praise” (Tafsir al-Ayyashi). So the mountains no proud man can match in height are already glorifying Him. The earth beneath his feet is praising. In all that praising creation, the only ones who hold themselves high against Him are the ones who choose to - and the first who chose it is where the surah turns next.

## Beat 11 - ACT III DIVIDER
- **connector:** Two great heights side by side: one seized and broken, one that belongs to God alone - and all creation glorifying Him.
- **line:** The human story began with a question of honor. God honored a creature of clay, and one being could not bear to see it. The surah takes you back to that first refusal - and then shows where honor is meant to lead.

## Beat 12 - VERSE 17:62
- **tag:** The Honor He Resented
- **arabic:** [17:62 - injected verbatim]
- **translation:** He said: “Do You see this one whom You have honored above me? If You give me respite until the Day of Resurrection, I will surely bring his descendants under my bridle - all but a few.”
- **reference:** al-Isra · 17 : 62
- **reflection:** The scene opens a verse earlier. God commands the angels to bow to Adam (a), and they bow - all except Iblis. “Shall I bow,” he says, “to one You created from clay?” (17:61). If you have taken the al-Hijr journey, you have already heard his contempt for the clay. Here the surah lets you hear what lies beneath it. Listen to his words: “this one You have honored above me.” In Arabic, “You have honored” is karramta. Iblis does not deny that Adam was honored. That is his complaint. Al-Mizan explains that he understood the honor from the command itself: if God tells you to bow to someone, He is telling you that person stands higher than you. And Iblis would not lower himself, because he believed he was the higher one. Then he swears his revenge: “I will surely bring his descendants under my bridle.” The Arabic verb, ahtanikanna, comes from hanak, the lower jaw. Al-Mizan gives its root meaning: to put a rope through an animal's jaw and lead it wherever one wishes. The one who refused to lower himself before Adam vows to lead Adam's children by the bridle. He refused one act of lowering - a single prostration - and lost everything. And he did not want to fall alone. God answers a few verses later. He does not argue with Iblis about clay. He simply speaks the very word Iblis resented.

## Beat 13 - VERSE 17:70
- **tag:** We Have Honored
- **arabic:** [17:70 - injected verbatim]
- **translation:** And We have certainly honored the children of Adam, and carried them on land and sea, and provided them with good things, and preferred them over much of what We have created.
- **reference:** al-Isra · 17 : 70
- **reflection:** Iblis said karramta: You have honored him. Here God says it Himself: karramna, We have honored. Tabrisi draws the connection in Majma al-Bayan: after Iblis said “this one You have honored above me,” God then sets out how He has honored the children of Adam. And see whom the verse includes - not only prophets, not only believers, but every child of Adam. Al-Mizan points out that it speaks even to those who deny God. It holds out a gift with a gentle rebuke: it reminds them how much He has given, and how they forget Him. Al-Mizan also separates two things the verse says. “We have honored” is a dignity that belongs to you just for being human - it compares you with no one. “We preferred” is a comparison with other creatures. The honor comes first, and it is not a ranking; it is a gift. That is what Iblis could not see: he turned honor into a ladder, with himself at the top. And notice one verb in the middle: hamalnahum, We carried them, on land and sea. The surah opened with God carrying His servant by night. Here He carries every child of Adam. In this surah, no one climbs to an honorable height. They are carried there. But honor is not the end of the story. The surah now shows how the highest station of all is reached - and once again, it happens at night.

## Beat 14 - VERSE 17:79
- **tag:** Raised by Night
- **arabic:** [17:79 - injected verbatim]
- **translation:** And for part of the night, rise from sleep and pray with it, as something extra for you. It may be that your Lord will raise you to a praised station.
- **reference:** al-Isra · 17 : 79
- **reflection:** The surah's first picture of height was a night: the servant carried up in the dark. Here the night returns, this time as a command. The verse commands tahajjud: to rise from sleep and stand in prayer - not staying up late, but getting up after you have slept, while the house is dark. It is given to the Prophet ﷺ as nafila, a prayer beyond the obligatory ones. And then the promise: it may be that your Lord will raise you to a praised station. Tabrisi notes that when God says “it may be,” the promise is certain. What is this praised station? Al-Mizan says it is the great intercession on the Day of Resurrection, when the Prophet ﷺ will plead with God for others. All of creation will praise that station, because all of creation will benefit from it. Shia and Sunni narrations, from the Prophet ﷺ and the Imams of his household (a), agree on this. So the highest station any human will hold is reached through the darkest hours of the night, by a servant standing alone in prayer. And it is a station where he does not rise alone: he lifts others with him.

## Beat 15 - ACT IV DIVIDER
- **connector:** God gave every child of Adam the honor Iblis resented - and its highest station is reached by standing in prayer at night.
- **line:** But the people of Mecca wanted a different kind of height. Near the end of the surah, they set out their demands to the Prophet ﷺ. Make a spring gush from the ground for us. Have a garden of palms and vines, with rivers running through it. Bring the sky down on us in pieces. Bring God and the angels before us, face to face. Have a house of gold (17:90-93). And then their last demand - the one this whole surah has been waiting for.

## Beat 16 - VERSE 17:93
- **tag:** Climb Into the Sky
- **arabic:** [17:93 - injected verbatim]
- **translation:** “…or until you have a house of gold, or you climb up into the sky - and we will not believe in your climbing until you bring down to us a book we can read.” Say: “Glory be to my Lord! Am I anything but a human being, a messenger?”
- **reference:** al-Isra · 17 : 93
- **reflection:** The surah opened with a night when God carried His servant beyond the sky. Now the mockers demand that ascent as a show: go up while we watch - and even the climb, they say, will not be enough unless you bring down a book we can read. The answer God gives His Prophet ﷺ begins with the surah's third subhan, and this time it is on the Prophet's ﷺ own lips: qul subhana rabbi - say, Glory be to my Lord. The first two times, the word was spoken of Him; now a messenger says it of his own Lord. Al-Mizan explains why it comes first. Their demand assumed that God's power had been handed to the Prophet ﷺ, to perform wonders on request. Before anything else, he declares his Lord far above handing His power over like that. Then he answers with two words, and al-Mizan shows that each one answers something they might have meant. Bashar: I am a human being - and a human being has no such power of his own. Rasul: I am a messenger - and a messenger's work is to deliver the message, not to command heaven. So the one who had been carried beyond the sky answers his mockers by calling himself a human being. The surah began by calling him a servant; here he speaks of himself with the same humility. The ascent was never his to perform. It was God's to give.

## Beat 17 - VERSE 17:109
- **tag:** Falling Down, Weeping
- **arabic:** [17:109 - injected verbatim]
- **translation:** And they fall down upon their chins, weeping, and it increases them in humility.
- **reference:** al-Isra · 17 : 109
- **reflection:** Two verses earlier, the surah turns away from the mockers. “Say: believe in it, or do not believe,” it tells them (17:107). Then it points to another kind of person: those who were given knowledge before the Qur'an came. When it is recited to them, they fall down upon their chins in prostration, and they say: “Glory be to our Lord - the promise of our Lord is surely fulfilled” (17:108). Then this verse: they fall down again, weeping, and it increases them in khushu', humility. The phrase “they fall down upon their chins” appears in only these two verses of the whole Qur'an. Al-Mizan explains the image: the chin is the part of the face nearest the ground as a person falls into prostration. And he explains why the verse repeats itself. Falling down again, now weeping, shows the humility of the body. “It increases them in humility” adds the humility of the heart. Now count the subhans. The surah has said the word four times. Twice it was spoken of Him (17:1, 17:43). Then the Prophet ﷺ said it of his own Lord (17:93). Now a whole company of believers says it together - glory be to our Lord - with their faces on the ground. The glorification has passed from words about God, to a messenger's lips, to a community in prostration. There is one person left for it to reach: you. The surah's last verse turns to you.

## Beat 18 - CLIMAX 17:111
- **tag:** Magnify Him
- **source:** al-Isra · 17 : 111
- **arabic:** [17:111 - injected verbatim]
- **translation:** And say: “Praise be to Allah, who has not taken a son, and has no partner in sovereignty, and has no protector out of weakness.” And magnify Him with a great magnifying.
- **body:** The surah's last verse turns to you with two commands: say al-hamdu lillah, and kabbirhu takbira - magnify Him, by declaring that He is greater: Allahu akbar. Al-Mizan points to the surah's design: it opened with glorification, and it closes with takbir. It began with a journey, but it never told you what happened at its summit. A narration from Imam al-Kazim (a) fills in that summit. He was asked why it is best to open the prayer with seven takbirs, and why we say “Glory be to my Lord, the Great” when we bow, and “Glory be to my Lord, the Most High” when we prostrate. He answered: God created seven heavens, seven earths, and seven veils. When the Prophet ﷺ was taken up on the Night Journey and came near to his Lord, one veil was lifted for him, and he said Allahu akbar. Another was lifted, and he said it again, and so on, until seven veils had been lifted and he had said seven takbirs. That is why the prayer opens with seven. Then, as he remembered the greatness of God that he had seen, he trembled before it and bowed, bracing himself upon his knees, saying: Subhana rabbiya al-'azimi wa bi-hamdih - Glory be to my Lord, the Great, and with His praise. When he rose upright from his bowing, he saw that greatness in a station higher still, and he fell down in prostration, saying: Subhana rabbiya al-a'la wa bi-hamdih - Glory be to my Lord, the Most High, and with His praise. When he had said it seven times, his trembling subsided - and so it became the practice of the prayer ('Ilal al-Shara'i). That is what took place at the summit of the Night Journey. At the highest point a human being has ever been carried, the Prophet ﷺ fell down in prostration.
- **reflection:** Now the threads of the surah meet in one posture. In Arabic, al-A'la, “the Most High,” comes from the same root as 'uluwwan, the “height” in “a great height.” The surah showed you a nation that seized a great height and was broken. Then it gave the words “a great height” to God alone. And the name of that height is spoken from the ground: you say “the Most High” with your forehead down, at the lowest point your body can reach. Here the glorification reaches you at last. Glory be to Him, glory be to Him, glory be to my Lord, glory be to our Lord - and now, in your own prostration, the word is on your lips. And the takbir itself? The verse simply says “magnify Him” - it sets nothing beside Him to compare. A man once said Allahu akbar in front of Imam al-Sadiq (a). “Greater than what?” the Imam asked. “Than everything,” the man said. “You have set a limit on Him,” said the Imam. The man asked, “Then how should I say it?” The Imam said: “Say: Allah is greater than can be described” (al-Kafi). So this is the surah's answer to its question. Who is truly high? He is - beyond every description. How does a servant rise? The way the Prophet ﷺ did at the summit of his ascent: by falling down in prostration. And every time you pray, you speak the words first spoken that night: the takbir as the prayer begins, the glorification in the bow, and then, with your forehead on the ground, Glory be to my Lord, the Most High.

## Beat 19 - RESPONSE
- **replyingTo:** to the angel's adhan · the Night Journey
- **arabic:** صَدَقَ عَبْدِي، إِنَّ مُحَمَّدًا عَبْدِي وَرَسُولِي
- **words:** “My servant has spoken the truth: Muhammad is My servant and My messenger.”
- **source:** Imam Ja'far al-Sadiq (a) · Tafsir al-Qummi
- **reflection:** On that same night, the Prophet ﷺ heard an angel call the adhan in heaven - an angel never seen there before - and God answered each line. When the angel said “Allahu akbar,” God answered: My servant has spoken the truth - I am greater. When the angel said “I bear witness that Muhammad is the Messenger of Allah,” God answered with these words. At 17:93, pressed by mockers, the Prophet ﷺ called himself “a human being, a messenger.” In heaven, God names him: My servant, and My messenger. Servant comes first - the name the surah gave him in its very first verse, at the height of his honor.

## Beat 20 - REFLECTION PROMPT
- **tag:** The Return
- **prompt:** Where are you trying to climb by yourself?
- **placeholder:** A voice I raise at home, a rank I keep chasing, a prayer I keep putting off...
- **subline:** You have just walked through a surah that sets two kinds of height side by side: the height people seize, and the height that is given. At the summit of the Night Journey, the one carried highest of all fell down in prostration. Before you go, name the place where you are trying to rise on your own. Then name one way to go lower instead: a voice you could soften, a step you could let someone else take first, a night you could rise to pray.
- **nextLabel:** One last thing

## Beat 21 - CLOSING
- **tag:** The Close
- **titleAr:** الْإِسْرَاء
- **essence:** Al-Isra opens with glorification and closes with takbir, and between the two it sorts every kind of height. The heights people seize - by arrogance, by a proud walk, by demanding signs - are broken, or shown never to reach the mountains. The only great height belongs to God. And a servant rises the way the Prophet ﷺ did: carried, not climbing - and at the summit, falling down in prostration to say, Glory be to my Lord, the Most High.
- **line:** Imam al-Sadiq (a) taught that whoever recites Surat Bani Isra'il every Friday night - the night before Friday - will not die until he meets al-Qa'im (a), the awaited Imam al-Mahdi, and is among his companions (Thawab al-A'mal). Now read the whole surah in its own words, all 111 verses. You will find much this journey could not cover: every person's deeds fastened to their own neck (17:13), the rest of the commandments, the Qur'an sent down as healing and mercy (17:82), the question about the spirit (17:85), and Musa's (a) nine clear signs (17:101). When you reach 17:109, you reach a verse of prostration, where it is recommended to bring your forehead to the ground. And when you reach the last verse, do what Imam al-Sadiq (a) taught whoever recites it: say Allahu akbar three times (Tahdhib al-Ahkam).
