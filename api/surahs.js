// /api/surahs.js - Static surah list endpoint
const cors = require('cors');

// Complete list of 114 surahs
const SURAHS = [
  { id: 1, name: "الفاتحة", transliteration: "Al-Fatihah", translation: "The Opening", type: "Meccan", numberOfAyahs: 7, revelationOrder: 5 },
  { id: 2, name: "البقرة", transliteration: "Al-Baqarah", translation: "The Cow", type: "Medinan", numberOfAyahs: 286, revelationOrder: 87 },
  { id: 3, name: "آل عمران", transliteration: "Ali 'Imran", translation: "Family of Imran", type: "Medinan", numberOfAyahs: 200, revelationOrder: 89 },
  { id: 4, name: "النساء", transliteration: "An-Nisa", translation: "The Women", type: "Medinan", numberOfAyahs: 176, revelationOrder: 92 },
  { id: 5, name: "المائدة", transliteration: "Al-Ma'idah", translation: "The Table Spread", type: "Medinan", numberOfAyahs: 120, revelationOrder: 112 },
  { id: 6, name: "الأنعام", transliteration: "Al-An'am", translation: "The Cattle", type: "Meccan", numberOfAyahs: 165, revelationOrder: 55 },
  { id: 7, name: "الأعراف", transliteration: "Al-A'raf", translation: "The Heights", type: "Meccan", numberOfAyahs: 206, revelationOrder: 39 },
  { id: 8, name: "الأنفال", transliteration: "Al-Anfal", translation: "The Spoils of War", type: "Medinan", numberOfAyahs: 75, revelationOrder: 88 },
  { id: 9, name: "التوبة", transliteration: "At-Tawbah", translation: "The Repentance", type: "Medinan", numberOfAyahs: 129, revelationOrder: 113 },
  { id: 10, name: "يونس", transliteration: "Yunus", translation: "Jonah", type: "Meccan", numberOfAyahs: 109, revelationOrder: 51 },
  { id: 11, name: "هود", transliteration: "Hud", translation: "Hud", type: "Meccan", numberOfAyahs: 123, revelationOrder: 52 },
  { id: 12, name: "يوسف", transliteration: "Yusuf", translation: "Joseph", type: "Meccan", numberOfAyahs: 111, revelationOrder: 53 },
  { id: 13, name: "الرعد", transliteration: "Ar-Ra'd", translation: "The Thunder", type: "Medinan", numberOfAyahs: 43, revelationOrder: 96 },
  { id: 14, name: "إبراهيم", transliteration: "Ibrahim", translation: "Abraham", type: "Meccan", numberOfAyahs: 52, revelationOrder: 72 },
  { id: 15, name: "الحجر", transliteration: "Al-Hijr", translation: "The Rocky Tract", type: "Meccan", numberOfAyahs: 99, revelationOrder: 54 },
  { id: 16, name: "النحل", transliteration: "An-Nahl", translation: "The Bee", type: "Meccan", numberOfAyahs: 128, revelationOrder: 70 },
  { id: 17, name: "الإسراء", transliteration: "Al-Isra", translation: "The Night Journey", type: "Meccan", numberOfAyahs: 111, revelationOrder: 50 },
  { id: 18, name: "الكهف", transliteration: "Al-Kahf", translation: "The Cave", type: "Meccan", numberOfAyahs: 110, revelationOrder: 69 },
  { id: 19, name: "مريم", transliteration: "Maryam", translation: "Mary", type: "Meccan", numberOfAyahs: 98, revelationOrder: 44 },
  { id: 20, name: "طه", transliteration: "Ta-Ha", translation: "Ta-Ha", type: "Meccan", numberOfAyahs: 135, revelationOrder: 45 },
  { id: 21, name: "الأنبياء", transliteration: "Al-Anbiya", translation: "The Prophets", type: "Meccan", numberOfAyahs: 112, revelationOrder: 73 },
  { id: 22, name: "الحج", transliteration: "Al-Hajj", translation: "The Pilgrimage", type: "Medinan", numberOfAyahs: 78, revelationOrder: 103 },
  { id: 23, name: "المؤمنون", transliteration: "Al-Mu'minun", translation: "The Believers", type: "Meccan", numberOfAyahs: 118, revelationOrder: 74 },
  { id: 24, name: "النور", transliteration: "An-Nur", translation: "The Light", type: "Medinan", numberOfAyahs: 64, revelationOrder: 102 },
  { id: 25, name: "الفرقان", transliteration: "Al-Furqan", translation: "The Criterion", type: "Meccan", numberOfAyahs: 77, revelationOrder: 42 },
  { id: 26, name: "الشعراء", transliteration: "Ash-Shu'ara", translation: "The Poets", type: "Meccan", numberOfAyahs: 227, revelationOrder: 47 },
  { id: 27, name: "النمل", transliteration: "An-Naml", translation: "The Ant", type: "Meccan", numberOfAyahs: 93, revelationOrder: 48 },
  { id: 28, name: "القصص", transliteration: "Al-Qasas", translation: "The Stories", type: "Meccan", numberOfAyahs: 88, revelationOrder: 49 },
  { id: 29, name: "العنكبوت", transliteration: "Al-Ankabut", translation: "The Spider", type: "Meccan", numberOfAyahs: 69, revelationOrder: 85 },
  { id: 30, name: "الروم", transliteration: "Ar-Rum", translation: "The Romans", type: "Meccan", numberOfAyahs: 60, revelationOrder: 84 },
  { id: 31, name: "لقمان", transliteration: "Luqman", translation: "Luqman", type: "Meccan", numberOfAyahs: 34, revelationOrder: 57 },
  { id: 32, name: "السجدة", transliteration: "As-Sajdah", translation: "The Prostration", type: "Meccan", numberOfAyahs: 30, revelationOrder: 75 },
  { id: 33, name: "الأحزاب", transliteration: "Al-Ahzab", translation: "The Confederates", type: "Medinan", numberOfAyahs: 73, revelationOrder: 90 },
  { id: 34, name: "سبأ", transliteration: "Saba", translation: "Sheba", type: "Meccan", numberOfAyahs: 54, revelationOrder: 58 },
  { id: 35, name: "فاطر", transliteration: "Fatir", translation: "Originator", type: "Meccan", numberOfAyahs: 45, revelationOrder: 43 },
  { id: 36, name: "يس", transliteration: "Ya-Sin", translation: "Ya-Sin", type: "Meccan", numberOfAyahs: 83, revelationOrder: 41 },
  { id: 37, name: "الصافات", transliteration: "As-Saffat", translation: "Those Who Set The Ranks", type: "Meccan", numberOfAyahs: 182, revelationOrder: 56 },
  { id: 38, name: "ص", transliteration: "Sad", translation: "The Letter Sad", type: "Meccan", numberOfAyahs: 88, revelationOrder: 38 },
  { id: 39, name: "الزمر", transliteration: "Az-Zumar", translation: "The Troops", type: "Meccan", numberOfAyahs: 75, revelationOrder: 59 },
  { id: 40, name: "غافر", transliteration: "Ghafir", translation: "The Forgiver", type: "Meccan", numberOfAyahs: 85, revelationOrder: 60 },
  { id: 41, name: "فصلت", transliteration: "Fussilat", translation: "Explained In Detail", type: "Meccan", numberOfAyahs: 54, revelationOrder: 61 },
  { id: 42, name: "الشورى", transliteration: "Ash-Shuraa", translation: "The Consultation", type: "Meccan", numberOfAyahs: 53, revelationOrder: 62 },
  { id: 43, name: "الزخرف", transliteration: "Az-Zukhruf", translation: "The Ornaments Of Gold", type: "Meccan", numberOfAyahs: 89, revelationOrder: 63 },
  { id: 44, name: "الدخان", transliteration: "Ad-Dukhan", translation: "The Smoke", type: "Meccan", numberOfAyahs: 59, revelationOrder: 64 },
  { id: 45, name: "الجاثية", transliteration: "Al-Jathiyah", translation: "The Crouching", type: "Meccan", numberOfAyahs: 37, revelationOrder: 65 },
  { id: 46, name: "الأحقاف", transliteration: "Al-Ahqaf", translation: "The Wind-Curved Sandhills", type: "Meccan", numberOfAyahs: 35, revelationOrder: 66 },
  { id: 47, name: "محمد", transliteration: "Muhammad", translation: "Muhammad", type: "Medinan", numberOfAyahs: 38, revelationOrder: 95 },
  { id: 48, name: "الفتح", transliteration: "Al-Fath", translation: "The Victory", type: "Medinan", numberOfAyahs: 29, revelationOrder: 111 },
  { id: 49, name: "الحجرات", transliteration: "Al-Hujurat", translation: "The Rooms", type: "Medinan", numberOfAyahs: 18, revelationOrder: 106 },
  { id: 50, name: "ق", transliteration: "Qaf", translation: "The Letter Qaf", type: "Meccan", numberOfAyahs: 45, revelationOrder: 34 },
  { id: 51, name: "الذاريات", transliteration: "Adh-Dhariyat", translation: "The Winnowing Winds", type: "Meccan", numberOfAyahs: 60, revelationOrder: 67 },
  { id: 52, name: "الطور", transliteration: "At-Tur", translation: "The Mount", type: "Meccan", numberOfAyahs: 49, revelationOrder: 76 },
  { id: 53, name: "النجم", transliteration: "An-Najm", translation: "The Star", type: "Meccan", numberOfAyahs: 62, revelationOrder: 23 },
  { id: 54, name: "القمر", transliteration: "Al-Qamar", translation: "The Moon", type: "Meccan", numberOfAyahs: 55, revelationOrder: 37 },
  { id: 55, name: "الرحمن", transliteration: "Ar-Rahman", translation: "The Beneficent", type: "Medinan", numberOfAyahs: 78, revelationOrder: 97 },
  { id: 56, name: "الواقعة", transliteration: "Al-Waqi'ah", translation: "The Inevitable", type: "Meccan", numberOfAyahs: 96, revelationOrder: 46 },
  { id: 57, name: "الحديد", transliteration: "Al-Hadid", translation: "The Iron", type: "Medinan", numberOfAyahs: 29, revelationOrder: 94 },
  { id: 58, name: "المجادلة", transliteration: "Al-Mujadila", translation: "The Pleading Woman", type: "Medinan", numberOfAyahs: 22, revelationOrder: 105 },
  { id: 59, name: "الحشر", transliteration: "Al-Hashr", translation: "The Exile", type: "Medinan", numberOfAyahs: 24, revelationOrder: 101 },
  { id: 60, name: "الممتحنة", transliteration: "Al-Mumtahanah", translation: "She That Is To Be Examined", type: "Medinan", numberOfAyahs: 13, revelationOrder: 91 },
  { id: 61, name: "الصف", transliteration: "As-Saff", translation: "The Ranks", type: "Medinan", numberOfAyahs: 14, revelationOrder: 109 },
  { id: 62, name: "الجمعة", transliteration: "Al-Jumu'ah", translation: "The Congregation", type: "Medinan", numberOfAyahs: 11, revelationOrder: 110 },
  { id: 63, name: "المنافقون", transliteration: "Al-Munafiqun", translation: "The Hypocrites", type: "Medinan", numberOfAyahs: 11, revelationOrder: 104 },
  { id: 64, name: "التغابن", transliteration: "At-Taghabun", translation: "The Mutual Disillusion", type: "Medinan", numberOfAyahs: 18, revelationOrder: 108 },
  { id: 65, name: "الطلاق", transliteration: "At-Talaq", translation: "The Divorce", type: "Medinan", numberOfAyahs: 12, revelationOrder: 99 },
  { id: 66, name: "التحريم", transliteration: "At-Tahrim", translation: "The Prohibition", type: "Medinan", numberOfAyahs: 12, revelationOrder: 107 },
  { id: 67, name: "الملك", transliteration: "Al-Mulk", translation: "The Sovereignty", type: "Meccan", numberOfAyahs: 30, revelationOrder: 77 },
  { id: 68, name: "القلم", transliteration: "Al-Qalam", translation: "The Pen", type: "Meccan", numberOfAyahs: 52, revelationOrder: 2 },
  { id: 69, name: "الحاقة", transliteration: "Al-Haqqah", translation: "The Reality", type: "Meccan", numberOfAyahs: 52, revelationOrder: 78 },
  { id: 70, name: "المعارج", transliteration: "Al-Ma'arij", translation: "The Ascending Stairways", type: "Meccan", numberOfAyahs: 44, revelationOrder: 79 },
  { id: 71, name: "نوح", transliteration: "Nuh", translation: "Noah", type: "Meccan", numberOfAyahs: 28, revelationOrder: 71 },
  { id: 72, name: "الجن", transliteration: "Al-Jinn", translation: "The Jinn", type: "Meccan", numberOfAyahs: 28, revelationOrder: 40 },
  { id: 73, name: "المزمل", transliteration: "Al-Muzzammil", translation: "The Enshrouded One", type: "Meccan", numberOfAyahs: 20, revelationOrder: 3 },
  { id: 74, name: "المدثر", transliteration: "Al-Muddaththir", translation: "The Cloaked One", type: "Meccan", numberOfAyahs: 56, revelationOrder: 4 },
  { id: 75, name: "القيامة", transliteration: "Al-Qiyamah", translation: "The Resurrection", type: "Meccan", numberOfAyahs: 40, revelationOrder: 31 },
  { id: 76, name: "الإنسان", transliteration: "Al-Insan", translation: "The Man", type: "Medinan", numberOfAyahs: 31, revelationOrder: 98 },
  { id: 77, name: "المرسلات", transliteration: "Al-Mursalat", translation: "The Emissaries", type: "Meccan", numberOfAyahs: 50, revelationOrder: 33 },
  { id: 78, name: "النبأ", transliteration: "An-Naba", translation: "The Tidings", type: "Meccan", numberOfAyahs: 40, revelationOrder: 80 },
  { id: 79, name: "النازعات", transliteration: "An-Nazi'at", translation: "Those Who Drag Forth", type: "Meccan", numberOfAyahs: 46, revelationOrder: 81 },
  { id: 80, name: "عبس", transliteration: "Abasa", translation: "He Frowned", type: "Meccan", numberOfAyahs: 42, revelationOrder: 24 },
  { id: 81, name: "التكوير", transliteration: "At-Takwir", translation: "The Overthrowing", type: "Meccan", numberOfAyahs: 29, revelationOrder: 7 },
  { id: 82, name: "الانفطار", transliteration: "Al-Infitar", translation: "The Cleaving", type: "Meccan", numberOfAyahs: 19, revelationOrder: 82 },
  { id: 83, name: "المطففين", transliteration: "Al-Mutaffifin", translation: "The Defrauding", type: "Meccan", numberOfAyahs: 36, revelationOrder: 86 },
  { id: 84, name: "الانشقاق", transliteration: "Al-Inshiqaq", translation: "The Splitting Open", type: "Meccan", numberOfAyahs: 25, revelationOrder: 83 },
  { id: 85, name: "البروج", transliteration: "Al-Buruj", translation: "The Mansions Of The Stars", type: "Meccan", numberOfAyahs: 22, revelationOrder: 27 },
  { id: 86, name: "الطارق", transliteration: "At-Tariq", translation: "The Morning Star", type: "Meccan", numberOfAyahs: 17, revelationOrder: 36 },
  { id: 87, name: "الأعلى", transliteration: "Al-A'la", translation: "The Most High", type: "Meccan", numberOfAyahs: 19, revelationOrder: 8 },
  { id: 88, name: "الغاشية", transliteration: "Al-Ghashiyah", translation: "The Overwhelming", type: "Meccan", numberOfAyahs: 26, revelationOrder: 68 },
  { id: 89, name: "الفجر", transliteration: "Al-Fajr", translation: "The Dawn", type: "Meccan", numberOfAyahs: 30, revelationOrder: 10 },
  { id: 90, name: "البلد", transliteration: "Al-Balad", translation: "The City", type: "Meccan", numberOfAyahs: 20, revelationOrder: 35 },
  { id: 91, name: "الشمس", transliteration: "Ash-Shams", translation: "The Sun", type: "Meccan", numberOfAyahs: 15, revelationOrder: 26 },
  { id: 92, name: "الليل", transliteration: "Al-Layl", translation: "The Night", type: "Meccan", numberOfAyahs: 21, revelationOrder: 9 },
  { id: 93, name: "الضحى", transliteration: "Ad-Duhaa", translation: "The Morning Hours", type: "Meccan", numberOfAyahs: 11, revelationOrder: 11 },
  { id: 94, name: "الشرح", transliteration: "Ash-Sharh", translation: "The Relief", type: "Meccan", numberOfAyahs: 8, revelationOrder: 12 },
  { id: 95, name: "التين", transliteration: "At-Tin", translation: "The Fig", type: "Meccan", numberOfAyahs: 8, revelationOrder: 28 },
  { id: 96, name: "العلق", transliteration: "Al-Alaq", translation: "The Clot", type: "Meccan", numberOfAyahs: 19, revelationOrder: 1 },
  { id: 97, name: "القدر", transliteration: "Al-Qadr", translation: "The Power", type: "Meccan", numberOfAyahs: 5, revelationOrder: 25 },
  { id: 98, name: "البينة", transliteration: "Al-Bayyinah", translation: "The Clear Proof", type: "Medinan", numberOfAyahs: 8, revelationOrder: 100 },
  { id: 99, name: "الزلزلة", transliteration: "Az-Zalzalah", translation: "The Earthquake", type: "Medinan", numberOfAyahs: 8, revelationOrder: 93 },
  { id: 100, name: "العاديات", transliteration: "Al-Adiyat", translation: "The Courser", type: "Meccan", numberOfAyahs: 11, revelationOrder: 14 },
  { id: 101, name: "القارعة", transliteration: "Al-Qari'ah", translation: "The Calamity", type: "Meccan", numberOfAyahs: 11, revelationOrder: 30 },
  { id: 102, name: "التكاثر", transliteration: "At-Takathur", translation: "The Rivalry In World Increase", type: "Meccan", numberOfAyahs: 8, revelationOrder: 16 },
  { id: 103, name: "العصر", transliteration: "Al-Asr", translation: "The Declining Day", type: "Meccan", numberOfAyahs: 3, revelationOrder: 13 },
  { id: 104, name: "الهمزة", transliteration: "Al-Humazah", translation: "The Traducer", type: "Meccan", numberOfAyahs: 9, revelationOrder: 32 },
  { id: 105, name: "الفيل", transliteration: "Al-Fil", translation: "The Elephant", type: "Meccan", numberOfAyahs: 5, revelationOrder: 19 },
  { id: 106, name: "قريش", transliteration: "Quraysh", translation: "Quraysh", type: "Meccan", numberOfAyahs: 4, revelationOrder: 29 },
  { id: 107, name: "الماعون", transliteration: "Al-Ma'un", translation: "The Small Kindnesses", type: "Meccan", numberOfAyahs: 7, revelationOrder: 17 },
  { id: 108, name: "الكوثر", transliteration: "Al-Kawthar", translation: "The Abundance", type: "Meccan", numberOfAyahs: 3, revelationOrder: 15 },
  { id: 109, name: "الكافرون", transliteration: "Al-Kafirun", translation: "The Disbelievers", type: "Meccan", numberOfAyahs: 6, revelationOrder: 18 },
  { id: 110, name: "النصر", transliteration: "An-Nasr", translation: "The Divine Support", type: "Medinan", numberOfAyahs: 3, revelationOrder: 114 },
  { id: 111, name: "المسد", transliteration: "Al-Masad", translation: "The Palm Fiber", type: "Meccan", numberOfAyahs: 5, revelationOrder: 6 },
  { id: 112, name: "الإخلاص", transliteration: "Al-Ikhlas", translation: "The Sincerity", type: "Meccan", numberOfAyahs: 4, revelationOrder: 22 },
  { id: 113, name: "الفلق", transliteration: "Al-Falaq", translation: "The Dawn", type: "Meccan", numberOfAyahs: 5, revelationOrder: 20 },
  { id: 114, name: "الناس", transliteration: "An-Nas", translation: "Mankind", type: "Meccan", numberOfAyahs: 6, revelationOrder: 21 }
];

// CORS middleware
const corsHandler = cors({
  origin: ['http://localhost:3000', 'https://thaqalyn-api.vercel.app'],
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization', 'User-Agent'],
});

export default function handler(req, res) {
  return corsHandler(req, res, () => {
    if (req.method !== 'GET') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
      res.status(200).json({
        success: true,
        data: SURAHS,
        count: SURAHS.length,
        generated_at: new Date().toISOString()
      });
    } catch (error) {
      console.error('Error in /api/surahs:', error);
      res.status(500).json({ 
        error: 'Internal server error',
        message: error.message 
      });
    }
  });
}