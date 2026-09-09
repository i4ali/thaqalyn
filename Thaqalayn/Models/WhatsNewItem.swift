//
//  WhatsNewItem.swift
//  Thaqalayn
//
//  One "What's New" feature announcement plus the static registry that feeds the
//  Today-tab spotlight. Mirrors DeepDiveDescriptor.all / JourneyCatalog: adding an
//  announcement is a pure content addition here. No backend.
//

import Foundation

/// Where tapping a What's New card takes the user.
enum WhatsNewDestination: Equatable {
    /// Open an immersive deep dive by id (lives in the Journey hub, tab 4).
    case deepDive(String)
    /// Open an "Inside the Surah" experience by id (lives in the Journey hub, tab 4).
    case surahExperience(String)
    /// Present the Daily Reflection widget explainer sheet (setup + location capture).
    case widgetExplainer
    /// Open the Duas & Ziyarat library (Explore tab feature), presented over Today.
    case duasZiyarat
    /// Open a journey's narrated Listen player directly (the id must be a FREE/bundled journey,
    /// e.g. "yaqin" - the showcase is opened without a paywall pass).
    case journeyListen(String)
    /// Open a surah in the passage reader at passage `index` (1-based ruku index),
    /// through the `thaqalayn://passage` deep link (Quran tab, tab 1).
    case passage(surah: Int, index: Int)
    // Reserved for later: case journey(String), case tab(Int)
}

/// One feature announcement. English copy only.
struct WhatsNewItem: Identifiable, Equatable {
    let id: String
    let sfSymbol: String
    let releaseDate: Date
    let destination: WhatsNewDestination
    let title: String
    let blurb: String
    let cta: String
}

enum WhatsNewCatalog {
    /// Author in any order; the manager sorts newest-first by releaseDate.
    static let all: [WhatsNewItem] = [
        WhatsNewItem(
            id: "passage-bookmarks",
            sfSymbol: "heart.text.square",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 9, day: 9).date ?? .distantPast, // placeholder - set at ship time (later than passages-baqarah so this card surfaces first)
            destination: .passage(surah: 2, index: 1),
            title: "Bookmark whole passages",
            blurb: "Save a passage, not only a verse. Swipe a passage in any surah, or tap the heart at the top of the passage, and it joins your bookmarks with its title and verse range.",
            cta: "Try it in al-Baqarah"
        ),
        WhatsNewItem(
            id: "passages-baqarah",
            sfSymbol: "text.book.closed",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 9, day: 5).date ?? .distantPast, // placeholder - set at ship time (later than nahl's so this card surfaces first)
            destination: .passage(surah: 2, index: 1),
            title: "Understanding, passage by passage",
            blurb: "Al-Baqarah now opens as passages. Read the verses, then Understand the passage: an essay, verse notes, narrations and their sources, all tappable.",
            cta: "Open al-Baqarah"
        ),
        WhatsNewItem(
            id: "journey-listen",
            sfSymbol: "headphones",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 28).date ?? .distantPast, // placeholder - set at ship time (after the ODR wiring + device pass), latest so this card surfaces first
            destination: .journeyListen("yaqin"),
            title: "Listen to a Journey",
            blurb: "Every Deep Dive and Surah journey can now be heard, not only read. A narrator carries you through the whole journey from start to finish, with the Quran verses and closing duas woven in as real recitation. Tap the headphones on a journey, let the screen dim, and simply listen. Free for Yaqin and al-Fatiha.",
            cta: "Listen now"
        ),
        WhatsNewItem(
            id: "duas-ziyarat",
            sfSymbol: "text.book.closed.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 26).date ?? .distantPast, // placeholder - set at ship time (later than the widget's so this card surfaces first)
            destination: .duasZiyarat,
            title: "Duas & Ziyarat",
            blurb: "The great supplications of Shia devotion, now with recitation - Dua Kumayl for Thursday nights, Ziyarat Ashura, Tawassul, Nudba, and Dua al-Ahd. Read each one line by line in Arabic, transliteration, and translation, and as the recitation plays, every word glows gold the moment it is recited - tap any line to jump there.",
            cta: "Open the library"
        ),
        WhatsNewItem(
            id: "widget-daily-reflection",
            sfSymbol: "square.grid.2x2.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 25).date ?? .distantPast, // placeholder - set at ship time (later than rad's so this card surfaces first)
            destination: .widgetExplainer,
            title: "The Daily Reflection Widget",
            blurb: "One verse that unfolds through your day, right on your Home Screen: the verse in the morning, a hidden gem after midday, a doorway into a journey or deep dive, and the five prayer times on Shia (Ja'fari) timings. Add it once and let the day carry you.",
            cta: "Set it up"
        ),
        WhatsNewItem(
            id: "surahExperience-nahl",
            sfSymbol: "hexagon.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 30).date ?? .distantPast, // placeholder - set at ship time (later than hijr's so this card surfaces first)
            destination: .surahExperience("surah-nahl"),
            title: "Inside the Surah",
            blurb: "Surah al-Nahl - the Surah of Blessings, which dares you to count what you have been given and then shows you why the count was never the point. Descend through beauty entered into the ledger, a gift renamed a shame, three bellies and the smallest receiver in the Book - down to a two-word promise of a good life, and the one word the Ahl al-Bayt gave as its key.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-hijr",
            sfSymbol: "mountain.2",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 25).date ?? .distantPast, // placeholder - set at ship time (later than rad's so this card surfaces first)
            destination: .surahExperience("surah-hijr"),
            title: "Inside the Surah",
            blurb: "Surah al-Hijr - named for a people who carved their safety into mountains. Descend through the mockery of Mecca and the Word God swore to guard, the first sneer in creation and the fence around the enemy, three visits that end at dawn - down to the gentlest sentence in the Qur'an, and the three-line prescription it comes with.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-rad",
            sfSymbol: "cloud.bolt.rain",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 24).date ?? .distantPast, // placeholder - set at ship time (later than ibrahim's so this card surfaces first)
            destination: .surahExperience("surah-rad"),
            title: "Inside the Surah",
            blurb: "Surah al-Ra'd - the surah named for thunder, answering the oldest demand: if God is real, why no sign? Descend through the sky that was praising all along, the flood whose glittering foam vanishes while the water stays, and the verse where hearts finally find rest - down to a final verse that waited forty-three verses to say a name.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-ibrahim",
            sfSymbol: "tree",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 23).date ?? .distantPast, // placeholder - set at ship time (later than hud's so this card surfaces first)
            destination: .surahExperience("surah-ibrahim"),
            title: "Inside the Surah",
            blurb: "Surah Ibrahim - the surah that weighs words. Descend through God's oath-bound promise, the sermon in which Satan confesses his empire was only an invitation, and the parable of the two trees - down to an old man in a barren valley, planting a handful of sentences in dead ground, and the count of what they became.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-hud",
            sfSymbol: "figure.stand",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 22).date ?? .distantPast, // placeholder - set at ship time (later than yunus's so this card surfaces first)
            destination: .surahExperience("surah-hud"),
            title: "Inside the Surah",
            blurb: "Surah Hud - when the Prophet ﷺ was asked why gray had come to his hair so early, he answered with the name of this surah. Descend through the ark built through years of laughter, the wave that came between a father and his son, and the lone man who dared a whole nation to do its worst - down to the one-word command that carried all that weight, and the quiet verse that reveals what the surah was really sent to do to a heart.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-yunus",
            sfSymbol: "water.waves",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 21).date ?? .distantPast, // placeholder - set at ship time (later than tawba's so this card surfaces first)
            destination: .surahExperience("surah-yunus"),
            title: "Inside the Surah",
            blurb: "Surah Yunus - one hundred and nine verses, named for a prophet who appears in just one of them. Descend through the storm-prayer that evaporates on the shore, the standing invitation to the Home of Peace, and the yes that came one wave too late - and learn why this surah, of all surahs, carries the name of Yunus.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-tawba",
            sfSymbol: "door.left.hand.open",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 20).date ?? .distantPast, // placeholder - set at ship time (later than kisa's so this card surfaces first)
            destination: .surahExperience("surah-tawba"),
            title: "Inside the Surah",
            blurb: "Surah al-Tawba - the only surah with no Bismillah, and the one named for God's own turning back. Walk from Bara'a to al-Tawba - an ultimatum, a battlefield, a mosque pillar, fifty days of silence - and watch a door open in every wall the surah builds, until you find where the missing mercy went.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "deepDives-kisa",
            sfSymbol: "moon.stars.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 19).date ?? .distantPast, // placeholder - set at ship time (must stay later than taqwa's so this card surfaces first)
            destination: .deepDive("kisa"),
            title: "New Deep Dive: Under the Cloak",
            blurb: "The story of Hadith al-Kisa, told in Fatima al-Zahra's own voice - the arrivals one by one, heaven naming the five, and the promise to every gathering that retells it. Ends with a new salawat close: five lights, five names.",
            cta: "Enter the gathering"
        ),
        WhatsNewItem(
            id: "deepDives-taqwa",
            sfSymbol: "shield",
            // PLACEHOLDER ship date - adjust to the actual release at ship time.
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 18).date ?? .distantPast,
            destination: .deepDive("taqwa"),
            title: "New Deep Dive",
            blurb: "Taqwa - God-consciousness. A descent through three guards, from the fear that halts the hand to the watch that keeps the heart for Him alone - summiting on al-Hurr, the free man of Karbala, and closing on a new beat where the hand that does not move is the whole of it.",
            cta: "Begin the descent"
        ),
        WhatsNewItem(
            id: "deepDives-ikhlas",
            sfSymbol: "drop.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 17).date ?? .distantPast,
            destination: .deepDive("ikhlas"),
            title: "New Deep Dive",
            blurb: "Ikhlas - The Unmixing. A descent through three purities, from the address every deed carries to the three hidden nights of Surah al-Insan - ending with one light that will not go out.",
            cta: "Begin the descent"
        ),
        WhatsNewItem(
            id: "surahExperience-anfal",
            sfSymbol: "hand.raised.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 16).date ?? .distantPast,
            destination: .surahExperience("surah-anfal"),
            title: "Inside the Surah",
            blurb: "Surah al-Anfal - the surah of Badr, Islam's first battle, and the startling claim it makes about that victory: it was never yours. Watch the spoils, the courage, and even the handful of dust that broke the enemy handed back to God, cause by cause - 'you did not throw when you threw, but Allah threw' - until a battle turns into a lesson in whose hands you were in the whole time.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-araf",
            sfSymbol: "mountain.2",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 15).date ?? .distantPast,
            destination: .surahExperience("surah-araf"),
            title: "Inside the Surah",
            blurb: "Surah al-A'raf - the second-longest surah in the Qur'an, named after a wall between the Garden and the Fire, with men on its heights who know every soul by sight. Beneath all its stories runs one question, asked before you were born: 'Am I not your Lord?' - and every soul answered yes. Watch that yes refused by Iblis, kept by Pharaoh's magicians in a single hour, broken by those who knew best, and discover the question was always yours to answer again.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-anam",
            sfSymbol: "sun.and.horizon.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 14).date ?? .distantPast,
            destination: .surahExperience("surah-anam"),
            title: "Inside the Surah",
            blurb: "Surah al-An'am - the Qur'an's great argument for the oneness of God, named, of all things, after cattle. Watch Ibrahim reason past every setting light to the One who never sets, until the surah asks the only question left: why are you still giving God a mere share of a life that is wholly His? No partner, no share.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-maida",
            sfSymbol: "link",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 13).date ?? .distantPast,
            destination: .surahExperience("surah-maida"),
            title: "Inside the Surah",
            blurb: "Surah al-Maida - one of the last surahs revealed, and the surah of the covenant. Trace a single bond across it: the pledge you gave God, a people before you who broke theirs and lost the leaders sent to guide them, and the day the religion was completed - a hand raised at Ghadir, and heaven's word that nothing was left to add.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "deepDives-salah",
            sfSymbol: "stairs",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 12).date ?? .distantPast,
            destination: .deepDive("salah"),
            title: "New Deep Dive",
            blurb: "Salah - The Believer's Ascent. The first dive that climbs: three names of the prayer, from the night fifty were made five, through the answered Fatiha, to the prayer under arrows at Karbala - closing with Fatima's gift.",
            cta: "Begin the ascent"
        ),
        WhatsNewItem(
            id: "surahExperience-kawthar",
            sfSymbol: "drop.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 8).date ?? .distantPast,
            destination: .surahExperience("surah-kawthar"),
            title: "Inside the Surah",
            blurb: "Surah al-Kawthar - the shortest surah in the Qur'an, sent down to answer a single insult. They called the Prophet cut off; God answered with abundance itself: a river at the end of the world, and a gift wearing a face the mockers never thought to count.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-yasin",
            sfSymbol: "heart",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 7).date ?? .distantPast,
            destination: .surahExperience("surah-yasin"),
            title: "Inside the Surah",
            blurb: "Surah Ya-Sin - the heart of the Qur'an, and the surah read over the dying. Its whole labor is to wake a sleeping heart: the one who ran, the signs all around you, and the morning every soul is raised - met now, while waking is still a choice.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-mulk",
            sfSymbol: "crown",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 6).date ?? .distantPast,
            destination: .surahExperience("surah-mulk"),
            title: "Inside the Surah",
            blurb: "Surah al-Mulk - the Kingdom, and the surah that guards the grave. It proves Whose hand holds everything by teaching the eye to look: up at a flawless sky, out at the bird held aloft by nothing, down at the water beneath your feet.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-rahman",
            sfSymbol: "water.waves",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 5).date ?? .distantPast,
            destination: .surahExperience("surah-rahman"),
            title: "Inside the Surah",
            blurb: "Surah al-Rahman - the bride of the Qur'an asks one question thirty-one times. Walk its four registers of favors, and answer the question yourself, in the very words the Ahl al-Bayt taught.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "deepDives-shukr",
            sfSymbol: "hands.clap",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 4).date ?? .distantPast,
            destination: .deepDive("shukr"),
            title: "New Deep Dive",
            blurb: "Shukr - Gratitude. A descent through the three tongues of thanks, from the first gifts to the praise in the dark of Ashura eve - ending with a count you will lose on purpose.",
            cta: "Begin the descent"
        ),
        WhatsNewItem(
            id: "deepDives-tawakkul",
            sfSymbol: "hands.and.sparkles",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 3).date ?? .distantPast,
            destination: .deepDive("tawakkul"),
            title: "New Deep Dive",
            blurb: "Tawakkul - Reliance. A descent through three motions of the trusting hand, from the parted sea to the morning of Ashura - ending with a release you perform with your own hand.",
            cta: "Begin the descent"
        ),
        WhatsNewItem(
            id: "surahExperience-nisa",
            sfSymbol: "figure.2.and.child.holdinghands",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 2).date ?? .distantPast,
            destination: .surahExperience("surah-nisa"),
            title: "Inside the Surah",
            blurb: "Surah al-Nisa - why the mightiest book of rights is named The Women. From the orphan's coin to the seat of authority, one trust runs through it all - and one verse names the company promised to those who guard it.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-ali-imran",
            sfSymbol: "person.3.sequence.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 1).date ?? .distantPast,
            destination: .surahExperience("surah-ali-imran"),
            title: "Inside the Surah",
            blurb: "Surah Al Imran - how God carries His truth through the households He chooses and purifies. From Maryam, chosen and purified in her prayer-niche, to the day God let His Prophet ﷺ stake the truth itself on a single purified household.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-baqara",
            sfSymbol: "hands.sparkles.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 30).date ?? .distantPast,
            destination: .surahExperience("surah-baqara"),
            title: "Inside the Surah",
            blurb: "Surah al-Baqara - why the mightiest surah is named after a cow. An immersive descent through a command, the questions that made it heavy, and the sign that answered it all.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-fatiha",
            sfSymbol: "book.closed",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 27).date ?? .distantPast,
            destination: .surahExperience("surah-fatiha"),
            title: "Inside the Surah",
            blurb: "Surah al-Fatiha - the prayer beneath every prayer. Walk the opening you know by heart as a conversation with God, and hear what He says back, line by line.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "surahExperience-yusuf",
            sfSymbol: "moon.stars",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 20).date ?? .distantPast,
            destination: .surahExperience("surah-yusuf"),
            title: "Inside the Surah",
            blurb: "Surah Yusuf - an immersive journey through the most beautiful of stories, from the dream to the reunion.",
            cta: "Begin the journey"
        ),
        WhatsNewItem(
            id: "deepDives-sabr",
            sfSymbol: "hourglass",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 13).date ?? .distantPast,
            destination: .deepDive("sabr"),
            title: "New Deep Dive",
            blurb: "Sabr - Patience. An immersive descent through three stations of the heart, from the patient prophets to Karbala.",
            cta: "Begin the descent"
        ),
        WhatsNewItem(
            id: "deepDives-yaqin",
            sfSymbol: "eye",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 6).date ?? .distantPast,
            destination: .deepDive("yaqin"),
            title: "Deep Dives",
            blurb: "Yaqin - Certainty. An immersive descent through three depths, from Qur'an to Karbala.",
            cta: "Begin the descent"
        )
    ]

    static func byId(_ id: String) -> WhatsNewItem? { all.first { $0.id == id } }
}
