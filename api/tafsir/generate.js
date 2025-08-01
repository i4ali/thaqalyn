// /api/tafsir/generate.js - LLM-powered tafsir generation
const { OpenAI } = require('openai');
const cors = require('cors');

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// CORS middleware
const corsHandler = cors({
  origin: ['http://localhost:3000', 'https://thaqalyn-api.vercel.app'],
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization', 'User-Agent'],
});

// Layer-specific system prompts for Shia tafsir
const LAYER_PROMPTS = {
  1: {
    title: "Foundation",
    systemPrompt: `You are an Islamic scholar specializing in Shia Quranic commentary. Generate Foundation layer commentary that provides:
1. Simple, modern language explanation suitable for general audiences
2. Historical context (Asbab al-Nuzul) when relevant
3. Basic meanings of key Arabic words and concepts
4. Contemporary relevance and practical applications

Keep the tone accessible, respectful, and educational. Focus on core meanings and universal principles.`,
    sources: ["basic_tafsir", "contemporary"]
  },
  2: {
    title: "Classical Shia Commentary", 
    systemPrompt: `You are a Shia Islamic scholar expert in classical commentaries. Generate Classical layer commentary drawing from:
1. Allamah Tabatabai's al-Mizan fi Tafsir al-Quran
2. Sheikh Tabrisi's Majma al-Bayan fi Tafsir al-Quran
3. Traditional Shia scholarly consensus and methodology
4. Historical Shia interpretations and jurisprudential implications

Maintain scholarly rigor while being accessible. Reference classical sources appropriately.`,
    sources: ["tabatabai", "tabrisi", "classical_shia"]
  },
  3: {
    title: "Contemporary Insights",
    systemPrompt: `You are a contemporary Shia scholar bridging classical knowledge with modern understanding. Generate Contemporary layer commentary featuring:
1. Insights from modern Shia scholars (Makarem Shirazi, Fadlallah, etc.)
2. Scientific correlations and modern applications where appropriate
3. Social justice themes and contemporary ethical implications
4. Interfaith dialogue perspectives while maintaining Shia authenticity

Balance traditional wisdom with contemporary relevance and scholarly precision.`,
    sources: ["makarem_shirazi", "contemporary_scholars", "modern_applications"]
  },
  4: {
    title: "Ahlul Bayt Wisdom",
    systemPrompt: `You are a scholar of Ahlul Bayt traditions specializing in the deepest spiritual dimensions. Generate Ahlul Bayt layer commentary including:
1. Relevant hadith and narrations from the 14 Infallibles (Prophet & 12 Imams)
2. Unique Shia theological concepts (Wilayah, Imamah, divine guidance)
3. Spiritual, mystical, and esoteric dimensions of the verses
4. Practical applications in Shia spiritual practice and daily life

Draw from authentic narrations while explaining deeper spiritual meanings accessible to sincere seekers.`,
    sources: ["ahlul_bayt_narrations", "imam_ali", "imam_sadiq", "spiritual_dimensions"]
  }
};

export default function handler(req, res) {
  return corsHandler(req, res, async () => {
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    const startTime = Date.now();

    try {
      const { surah, ayah, layer, language = 'en' } = req.body;

      // Validate input
      if (!surah || !ayah || !layer) {
        return res.status(400).json({
          error: 'Missing required parameters',
          required: ['surah', 'ayah', 'layer']
        });
      }

      if (layer < 1 || layer > 4) {
        return res.status(400).json({
          error: 'Invalid layer',
          message: 'Layer must be between 1 and 4'
        });
      }

      if (!process.env.OPENAI_API_KEY) {
        return res.status(500).json({
          error: 'API configuration error',
          message: 'OpenAI API key not configured'
        });
      }

      const layerConfig = LAYER_PROMPTS[layer];
      
      // Create user prompt with verse context
      const userPrompt = `Generate ${layerConfig.title} commentary for Surah ${surah}, Verse ${ayah}.

Context: This is for the Thaqalyn app, providing authentic Shia Islamic commentary in English for modern Muslim audiences.

Requirements:
- Length: 150-300 words
- Language: Clear, scholarly English
- Perspective: Authentically Shia while being accessible
- Tone: Respectful, educational, and spiritually enriching

Please provide commentary that would be valuable for someone studying this verse from a Shia Islamic perspective.`;

      // Call OpenAI API
      const completion = await openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: layerConfig.systemPrompt
          },
          {
            role: "user", 
            content: userPrompt
          }
        ],
        max_tokens: 500,
        temperature: 0.7,
        frequency_penalty: 0.1,
        presence_penalty: 0.1
      });

      const content = completion.choices[0]?.message?.content;
      
      if (!content) {
        throw new Error('No content generated from OpenAI');
      }

      const processingTime = Date.now() - startTime;

      // Return structured response
      res.status(200).json({
        content: content.trim(),
        sources: layerConfig.sources,
        generated_at: new Date().toISOString(),
        confidence_score: 0.85, // Could be calculated based on model certainty
        metadata: {
          model_used: "gpt-4",
          token_count: completion.usage?.total_tokens || null,
          processing_time: processingTime
        }
      });

    } catch (error) {
      console.error('Error in /api/tafsir/generate:', error);
      
      // Handle specific OpenAI errors
      if (error.code === 'insufficient_quota') {
        return res.status(429).json({
          error: 'API quota exceeded',
          message: 'Please try again later'
        });
      }
      
      if (error.code === 'rate_limit_exceeded') {
        return res.status(429).json({
          error: 'Rate limit exceeded', 
          message: 'Please try again in a moment'
        });
      }

      res.status(500).json({
        error: 'Failed to generate commentary',
        message: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
      });
    }
  });
}