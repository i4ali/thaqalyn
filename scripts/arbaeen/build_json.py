#!/usr/bin/env python3
"""
Build Thaqalayn/Data/arbaeen_journey.json (the 8-station "Arbaeen - The Return" journey).

English narrative + devotional identity are authored here; the full 78-segment
Ziyarat of Arbaeen (for the Station 8 "read full" sheet) is pulled VERBATIM from the
research file so it is never retyped by hand. Urdu fields are set equal to English for
now (safe fallback) - a real Urdu pass replaces them later.
"""
import json
import re
import pathlib

DEVO = pathlib.Path(
    "/private/tmp/claude-501/-Users-muhammadimranali-Documents-development-thaqalyn/"
    "733e2423-f7f9-44f1-b35d-3b4aac005cc3/scratchpad/arbaeen-research/devotional.md"
)
OUT = pathlib.Path(
    "/Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Data/arbaeen_journey.json"
)

# --- Full Ziyarat of Arbaeen: extract segments 1..78 verbatim from PART 1 of the research ---
text = DEVO.read_text(encoding="utf-8")
part1 = text.split("# PART 2")[0]
ar_segs = [s.strip() for s in re.findall(r"\*\*AR:\*\*\s*(.+)", part1)]
en_segs = [s.strip() for s in re.findall(r"\*\*EN:\*\*\s*(.+)", part1)]
FULL_AR = " ".join(ar_segs)
FULL_EN = " ".join(en_segs)
assert len(ar_segs) >= 70, f"expected the full ziyarat (~78 segs), got {len(ar_segs)}"

# --- Optional Urdu overrides (from the urdu-translator pass); English is the fallback ---
URDU_PATH = pathlib.Path(
    "/private/tmp/claude-501/-Users-muhammadimranali-Documents-development-thaqalyn/"
    "733e2423-f7f9-44f1-b35d-3b4aac005cc3/scratchpad/arbaeen-research/urdu_overrides.json"
)
URDU = json.loads(URDU_PATH.read_text(encoding="utf-8")) if URDU_PATH.exists() else {}

STATIONS = [
    {
        "theme": "The Morning After",
        "themeArabic": "مَا بَعْدَ عَاشُورَاء",
        "icon": "sunrise",
        "dua_ar": "فَلَأَنْدُبَنَّكَ صَبَاحًا وَمَسَاءً، وَلَأَبْكِيَنَّ لَكَ بَدَلَ الدُّمُوعِ دَمًا، حَسْرَةً عَلَيْكَ وَتَأَسُّفًا عَلَىٰ مَا دَهَاكَ وَتَلَهُّفًا",
        "dua_tr": "Fa-la-andubannaka ṣabāḥan wa masāʾā, wa la-abkiyanna laka badala l-dumūʿi damā, ḥasratan ʿalayka wa taʾassufan ʿalā mā dahāka wa talahhufā",
        "dua_en": "I will lament you morning and evening, and weep for you blood in place of tears, in anguish and sorrow for all that befell you.",
        "dua_src": "Ziyārat al-Nāḥiya al-Muqaddasa",
        "verses": [
            (2, 155, "The verse of the patient: God tests “with fear and hunger and loss,” then bids glad tidings to the steadfast - Karbala is that trial, its survivors the ṣābirīn."),
            (2, 156, "Their answer to catastrophe - “Indeed we belong to God, and to Him we return” - spoken over the unburied bodies."),
        ],
        "tafsir": "By the morning of the eleventh, Ashura’s silence had a sound: burning tents, the wail of children, the clank of the sick Imam’s chains. The bodies lay unburied as the women were seated on bare camels and driven away. Passing her brother’s body, Zaynab (AS) cried out to her grandfather: “This is Husayn, in the open, smeared with blood.” The battle was over; the harder work - keeping Karbala from being buried in silence - had begun.",
        "reflection": "We assume the test is the loss itself. The survivors reveal a second test that comes after: to carry the truth of what happened when silence would be easier. Their patience is not passivity - it is a refusal to let Husayn be forgotten.",
    },
    {
        "theme": "The Road to Kufa",
        "themeArabic": "الطَّرِيقُ إِلَى الْكُوفَة",
        "icon": "figure.walk",
        "dua_ar": "اللَّهُمَّ لَا طَاقَةَ لِي بِالْجَهْدِ، وَلَا صَبْرَ لِي عَلَى الْبَلَاءِ، وَلَا قُوَّةَ لِي عَلَى الْفَقْرِ، فَلَا تَحْظُرْ عَلَيَّ رِزْقِي",
        "dua_tr": "Allāhumma lā ṭāqata lī bi’l-jahd, wa lā ṣabra lī ʿala’l-balāʾ, wa lā quwwata lī ʿala’l-faqr, fa-lā taḥẓur ʿalayya rizqī",
        "dua_en": "O God, I have no endurance for effort, no patience in affliction, no strength to bear poverty; so withhold not from me my provision.",
        "dua_src": "al-Ṣaḥīfa al-Sajjādiyya · Supplication 22",
        "verses": [
            (3, 186, "“You will be tested in your wealth and your selves, and you will hear much hurt” - the abuse hurled at the captives on the road, met with patience."),
            (2, 153, "“Seek help in patience and prayer” - the only provisions the caravan carried."),
        ],
        "tafsir": "The heads went ahead on spears; the family of the Prophet came behind, unveiled, on bare-backed camels, the sick Imam in an iron collar. When a Kufan woman leaned from her window and learned who they were, she wept and threw down cloths to cover them. This is the ordeal the Qur’an names - to be tested and to “hear much hurt,” and to answer it not with despair but with patience and prayer.",
        "reflection": "Bearing witness is rarely dramatic. Sometimes it is only refusing to look away, or covering another’s shame with your own cloak. The road to Kufa asks what small dignity we can still offer when we ourselves have lost everything.",
    },
    {
        "theme": "The Voice That Would Not Break",
        "themeArabic": "خُطْبَةُ زَيْنَب",
        "icon": "quote.bubble",
        "dua_ar": "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي",
        "dua_tr": "Rabbi-shraḥ lī ṣadrī, wa yassir lī amrī, waḥlul ʿuqdatan min lisānī, yafqahū qawlī",
        "dua_en": "My Lord, expand for me my breast, and ease for me my task, and untie the knot from my tongue, that they may understand my speech.",
        "dua_src": "Qur’an 20:25–28 · the prayer of Musa (AS)",
        "verses": [
            (16, 91, "“Fulfil the covenant of God when you have pledged it, and break not your oaths” - the very pledge Kufa made to Husayn, then broke."),
            (16, 92, "“Be not like her who unravels her yarn after it was strong” - the exact image Zaynab (AS) flung at Kufa in her sermon."),
        ],
        "tafsir": "In Kufa - the city that had invited Husayn and then abandoned him - the captives were paraded before weeping crowds. Then Zaynab raised her hand and “even the camel-bells fell still.” She turned their tears into a mirror: “You are like her who unravels her yarn after it was strong” - the image of the Qur’an itself - people who spun a covenant and then tore it apart. Before Ibn Ziyad, asked how she found what God had done, she answered: “I saw nothing but beauty.”",
        "reflection": "Grief can collapse a person into silence, or be forged into speech that outlives the sword. Zaynab had no army and no freedom - only her voice. It was enough to keep Karbala from being erased. What truth are we staying silent about?",
    },
    {
        "theme": "The Long Road to Sham",
        "themeArabic": "الطَّرِيقُ إِلَى الشَّام",
        "icon": "sun.dust",
        "dua_ar": "يَا مَنْ تُحَلُّ بِهِ عُقَدُ الْمَكَارِهِ، وَيَا مَنْ يُفْثَأُ بِهِ حَدُّ الشَّدَائِدِ، وَيَا مَنْ يُلْتَمَسُ مِنْهُ الْمَخْرَجُ إِلَىٰ رَوْحِ الْفَرَجِ",
        "dua_tr": "Yā man tuḥallu bihi ʿuqadu’l-makārih, wa yā man yufthaʾu bihi ḥaddu’l-shadāʾid, wa yā man yultamasu minhu’l-makhraju ilā rawḥi’l-faraj",
        "dua_en": "O You by whom the knots of adversity are untied, O You by whom the edge of hardships is blunted, O You from whom is sought the way out to the ease of relief.",
        "dua_src": "al-Ṣaḥīfa al-Sajjādiyya · Supplication 7",
        "verses": [
            (2, 214, "“Do you suppose you will enter the Garden without the trial of those before you? … God’s help is near” - endurance as the gateway, relief at its edge."),
            (39, 10, "“The patient will be paid their reward in full, without measure.”"),
        ],
        "tafsir": "From Kufa the captives were driven weeks across the desert, entering Damascus on the first of Safar to drums and celebration. The sources spare us a tidy itinerary and give only the hardship: heat, exhaustion, humiliation, the sick Imam bound through all of it. The Qur’an had asked whether anyone supposes they will enter the Garden without the trial of those before them - and promised, at the edge of endurance, that God’s help is near.",
        "reflection": "The long road is its own test - not a single blow but a weariness that will not end. Endurance, offered to God, becomes worship. “I have no patience in affliction,” the Imam prays - and in that honest helplessness casts himself on God alone.",
    },
    {
        "theme": "The Court of Yazid",
        "themeArabic": "مَجْلِسُ يَزِيد",
        "icon": "building.columns",
        "dua_ar": "قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَن تَشَاءُ وَتَنزِعُ الْمُلْكَ مِمَّن تَشَاءُ وَتُعِزُّ مَن تَشَاءُ وَتُذِلُّ مَن تَشَاءُ ۖ بِيَدِكَ الْخَيْرُ ۖ إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
        "dua_tr": "Quli’llāhumma Mālika’l-mulki tu’ti’l-mulka man tashāʾu wa tanziʿu’l-mulka mimman tashāʾu wa tuʿizzu man tashāʾu wa tudhillu man tashāʾ, bi-yadika’l-khayr, innaka ʿalā kulli shayʾin qadīr",
        "dua_en": "Say: O God, Master of all sovereignty, You give sovereignty to whom You will and strip sovereignty from whom You will; You honour whom You will and abase whom You will. In Your hand is all good. Indeed You have power over all things.",
        "dua_src": "Qur’an 3:26",
        "verses": [
            (3, 178, "“Let not the disbelievers think Our respite is good for them; We only respite them to increase in sin” - the verse Zaynab (AS) recited to Yazid on his throne."),
            (14, 42, "“Think not God unaware of what the wrongdoers do; He only delays them” - her warning that his triumph was a reprieve, not approval."),
        ],
        "tafsir": "In Yazid’s court the family stood bound by a single rope while he struck Husayn’s lips with a cane and recited pagan verse gloating over the House of the Prophet. Zaynab rose: “Do you think that by taking us captive you have shamed us?” She recited that the wrongdoer’s respite only lets him increase in sin, and that the slain of God are not dead but living. Then the young Imam took the pulpit: “I am the son of Mecca and Mina, the son of Muhammad the Chosen.”",
        "reflection": "Tyranny wants its victims silent and small. The answer of the Ahl al-Bayt was to speak - to name themselves before the very throne that tried to erase them. Sovereignty, Zaynab reminded the court, is God’s to give and to strip. Thrones end; the truth spoken before them does not.",
    },
    {
        "theme": "The Ruin of Damascus",
        "themeArabic": "خَرِبَةُ الشَّام",
        "icon": "moon.stars",
        "dua_ar": "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
        "dua_tr": "Rabbanā afrigh ʿalaynā ṣabran wa thabbit aqdāmanā wanṣurnā ʿala’l-qawmi’l-kāfirīn",
        "dua_en": "Our Lord, pour upon us patience, make firm our feet, and give us victory over the disbelieving people.",
        "dua_src": "Qur’an 2:250",
        "verses": [
            (12, 86, "“I complain of my grief and sorrow only to God” - Yaqub’s words, and the posture of the captives’ mourning in the ruin of Sham."),
            (94, 6, "“Indeed, with hardship comes ease” - the promise, doubled, for a sorrow that felt endless."),
        ],
        "tafsir": "Yazid lodged the family in a ruin exposed to heat and cold, and there they mourned Husayn openly. The grief did not stay hidden: as the days passed, the people of Sham began to learn who these captives were, and the city’s mood turned until Yazid feared for himself. (A beloved later tradition places the death of a small daughter of Husayn here; it is treasured in the mourning gatherings, though it is not found in the earliest sources.) Grief, carried to God, became a summons even Damascus could not ignore.",
        "reflection": "There is a sorrow that curdles into despair, and a sorrow that is poured out before God and becomes light. The captives’ mourning was not weakness; it was the seed that turned a hostile city. “I complain of my grief only to God” - and God answered through a watching people.",
    },
    {
        "theme": "The Turn Homeward",
        "themeArabic": "الْعَوْدَة",
        "icon": "arrow.uturn.left",
        "dua_ar": "لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
        "dua_tr": "Lā ilāha illā anta subḥānaka innī kuntu mina’l-ẓālimīn",
        "dua_en": "There is no god but You; glory be to You. Indeed, I was among the wrongdoers.",
        "dua_src": "Qur’an 21:87 · the prayer of Yunus (AS)",
        "verses": [
            (21, 88, "“We answered him and delivered him from grief; thus do We deliver the believers” - Yunus’s rescue, and the caravan’s release."),
            (65, 3, "“Whoever relies upon God, He is sufficient for him … God will accomplish His purpose” - the way out that opened homeward."),
        ],
        "tafsir": "Fearing the turning mood, Yazid released the family, returned their looted belongings, and sent them under escort toward Medina. Reaching Iraq, they asked the guide to lead them by way of Karbala. The tyrant who meant to break them now sped them home - and the road bent, as it always would, back toward Husayn’s grave. (Tradition relates that the caravan reached the grave on Arbaeen itself; scholars differ on the dating, so we hold it gently.)",
        "reflection": "Deliverance rarely looks like victory in the moment. Here it looked like a weary caravan turning, of its own longing, back toward a grave. The covenant was not signed in triumph but in return - choosing, again and again, to come back to Husayn.",
    },
    {
        "theme": "Arbaeen: Jabir at the Grave",
        "themeArabic": "الْأَرْبَعِين",
        "icon": "hands.sparkles",
        "dua_ar": "السَّلَامُ عَلَىٰ وَلِيِّ اللَّهِ وَحَبِيبِهِ، السَّلَامُ عَلَىٰ خَلِيلِ اللَّهِ وَنَجِيبِهِ، السَّلَامُ عَلَىٰ صَفِيِّ اللَّهِ وَابْنِ صَفِيِّهِ، السَّلَامُ عَلَى الْحُسَيْنِ الْمَظْلُومِ الشَّهِيدِ، السَّلَامُ عَلَىٰ أَسِيرِ الْكُرُبَاتِ وَقَتِيلِ الْعَبَرَاتِ",
        "dua_tr": "As-salāmu ʿalā waliyyi’llāhi wa ḥabībih, as-salāmu ʿalā khalīli’llāhi wa najībih, as-salāmu ʿalā ṣafiyyi’llāhi wa’bni ṣafiyyih, as-salāmu ʿala’l-Ḥusayni’l-maẓlūmi’sh-shahīd, as-salāmu ʿalā asīri’l-kurubāti wa qatīli’l-ʿabarāt",
        "dua_en": "Peace be upon the intimate friend of God and His beloved. Peace be upon the close friend of God and His chosen one. Peace be upon the pure one of God and the son of His pure one. Peace be upon al-Husayn, the wronged, the martyred. Peace be upon the captive of agonies and the slain over whom tears are shed.",
        "dua_src": "Ziyārat al-Arbaʿīn · from Imam al-Ṣādiq (AS)",
        "full": True,
        "verses": [
            (3, 169, "“Think not those slain in the way of God dead; they are alive, provided for by their Lord” - the ground of the ziyarat: the pilgrim greets a living Husayn."),
            (89, 28, "“Return to your Lord, well-pleased and pleasing to Him” - the Return that Arbaeen names, the soul’s homecoming to God."),
        ],
        "tafsir": "On the fortieth day, an old and near-blind companion of the Prophet - Jabir ibn Abdullah al-Ansari - came with Atiyya to the grave: the first pilgrim of Husayn. He bathed in the Euphrates, perfumed himself, and walked “taking no step but in the remembrance of God,” then fell upon the grave crying “Ya Husayn!” When Atiyya asked how they could share in the martyrs’ reward, Jabir answered with the Prophet’s words: “Whoever loves a people is raised with them.” What Jabir began that day, millions have never stopped.",
        "reflection": "“Think not them dead,” says the Qur’an; “they are alive.” The Ziyarat of Arbaeen is spoken to a Husayn who hears. Loyalty is measured not on the day of the tragedy, but forty days later - when the crowds have gone home and only the faithful return. Jabir asks, across the centuries: will you still come?",
    },
]


def build_day(i, s):
    u = URDU.get(f"station{i}", {})
    vnotes = u.get("verseNotes") or []
    dua = {
        "arabic": s["dua_ar"],
        "transliteration": s["dua_tr"],
        "english": s["dua_en"],
        "source": s["dua_src"],
        "englishUr": u.get("duaEnglish", s["dua_en"]),
        "sourceUr": u.get("duaSource", s["dua_src"]),
    }
    if s.get("full"):
        dua["fullArabic"] = FULL_AR
        dua["fullEnglish"] = FULL_EN
    verses = [
        {
            "id": f"station{i}_v{j + 1}",
            "surahNumber": v[0],
            "verseNumber": v[1],
            "relevanceNote": v[2],
            "relevanceNoteUr": vnotes[j] if j < len(vnotes) else v[2],
        }
        for j, v in enumerate(s["verses"])
    ]
    return {
        "id": f"station{i}",
        "dayNumber": i,
        "theme": s["theme"],
        "themeArabic": s["themeArabic"],
        "icon": s["icon"],
        "dua": dua,
        "verses": verses,
        "tafsirFocus": s["tafsir"],
        "reflection": s["reflection"],
        "themeUr": u.get("theme", s["theme"]),
        "tafsirFocusUr": u.get("tafsirFocus", s["tafsir"]),
        "reflectionUr": u.get("reflection", s["reflection"]),
    }


data = {"days": [build_day(i + 1, s) for i, s in enumerate(STATIONS)]}
OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"wrote {OUT}")
print(f"  stations: {len(data['days'])}")
print(f"  full ziyarat segments embedded: {len(ar_segs)} AR / {len(en_segs)} EN")
