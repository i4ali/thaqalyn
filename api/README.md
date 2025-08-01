# Thaqalyn API

Backend API for Thaqalyn - AI-powered Shia Quranic Commentary app.

## Architecture

This is a stateless Node.js API designed to run on Vercel's serverless platform, following the Phase 1 MVP requirements:

- **No database required** - pure stateless functions
- **OpenAI GPT-4 integration** for authentic Shia commentary generation
- **4-layer commentary system** with specialized prompts
- **Cost-optimized** with rate limiting and caching recommendations

## Endpoints

### GET /api/surahs
Returns the complete list of 114 Quran surahs with metadata.

### POST /api/tafsir/generate
Generates AI-powered Shia commentary for a specific verse and layer.

**Request:**
```json
{
  "surah": 1,
  "ayah": 1,
  "layer": 1
}
```

**Response:**
```json
{
  "content": "Generated commentary text...",
  "sources": ["tabatabai", "contemporary"],
  "generated_at": "2024-01-01T12:00:00Z",
  "confidence_score": 0.85,
  "metadata": {
    "model_used": "gpt-4",
    "token_count": 245,
    "processing_time": 1500
  }
}
```

## Commentary Layers

1. **Foundation (🏛️)** - Simple explanations, historical context
2. **Classical Shia Commentary (📚)** - Tabatabai, Tabrisi perspectives  
3. **Contemporary Insights (🌍)** - Modern scholars, applications
4. **Ahlul Bayt Wisdom (⭐)** - Hadith, spiritual dimensions

## Deployment

### Local Development
```bash
npm install
vercel dev
```

### Production (Vercel)
```bash
vercel --prod
```

### Environment Variables
- `OPENAI_API_KEY` - Required for GPT-4 API access

## Cost Optimization

- Aggressive client-side caching (implemented in iOS app)
- 500 token limit per request
- Rate limiting to prevent abuse
- Optimized prompts for concise, high-quality responses

Estimated cost: ~$50-100/month for MVP usage levels.