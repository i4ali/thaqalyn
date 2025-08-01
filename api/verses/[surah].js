// /api/verses/[surah].js - Dynamic verse endpoint using AlQuran.cloud API
const cors = require('cors');

// CORS middleware
const corsHandler = cors({
  origin: ['http://localhost:3000', 'https://thaqalyn-api.vercel.app'],
  methods: ['GET'],
  allowedHeaders: ['Content-Type', 'Authorization', 'User-Agent'],
});

// Fetch verses from AlQuran.cloud API
async function fetchVersesFromAPI(surahId) {
  const arabicUrl = `https://api.alquran.cloud/v1/surah/${surahId}`;
  const translationUrl = `https://api.alquran.cloud/v1/surah/${surahId}/en.sahih`;
  
  try {
    // Fetch Arabic text and English translation in parallel
    const [arabicResponse, translationResponse] = await Promise.all([
      fetch(arabicUrl),
      fetch(translationUrl)
    ]);

    if (!arabicResponse.ok || !translationResponse.ok) {
      throw new Error('Failed to fetch verse data from external API');
    }

    const arabicData = await arabicResponse.json();
    const translationData = await translationResponse.json();

    if (arabicData.code !== 200 || translationData.code !== 200) {
      throw new Error('External API returned error response');
    }

    // Combine Arabic and translation data
    const verses = arabicData.data.ayahs.map((ayah, index) => {
      const translationAyah = translationData.data.ayahs[index];
      
      return {
        ayahNumber: ayah.numberInSurah,
        arabicText: ayah.text,
        translation: translationAyah ? translationAyah.text : '',
        transliteration: null, // AlQuran.cloud doesn't provide transliteration
        surahId: surahId,
        id: `${surahId}:${ayah.numberInSurah}`
      };
    });

    return verses;
  } catch (error) {
    console.error('Error fetching from AlQuran.cloud API:', error);
    throw error;
  }
}

export default function handler(req, res) {
  return corsHandler(req, res, async () => {
    if (req.method !== 'GET') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    const { surah } = req.query;
    const surahId = parseInt(surah);

    // Validate surah ID
    if (!surahId || surahId < 1 || surahId > 114) {
      return res.status(400).json({ 
        error: 'Invalid surah ID',
        message: 'Surah ID must be between 1 and 114' 
      });
    }

    try {
      const verses = await fetchVersesFromAPI(surahId);
      
      res.status(200).json({
        success: true,
        surahId: surahId,
        verses: verses,
        count: verses.length,
        generated_at: new Date().toISOString(),
        source: 'AlQuran.cloud API'
      });
    } catch (error) {
      console.error('Error in /api/verses/[surah]:', error);
      
      // Return error - no fallback data per user request
      res.status(500).json({ 
        error: 'Verses not available',
        message: 'Unable to retrieve verses at this time. Please try again later.',
        source: 'External API failure'
      });
    }
  });
}