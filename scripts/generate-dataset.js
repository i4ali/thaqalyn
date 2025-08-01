#!/usr/bin/env node

/**
 * Thaqalyn Data Generation Script
 * 
 * This script generates the complete dataset for the Thaqalyn app:
 * 1. Fetches all Quran text (Arabic + English) from AlQuran.cloud
 * 2. Generates 4 layers of AI commentary for all verses using OpenAI
 * 3. Exports structured JSON files for iOS app integration
 */

const fs = require('fs').promises;
const path = require('path');

// Configuration
const OUTPUT_DIR = path.join(__dirname, '../data');
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

if (!OPENAI_API_KEY) {
    console.error('❌ OPENAI_API_KEY environment variable is required');
    process.exit(1);
}

// Commentary layer definitions
const COMMENTARY_LAYERS = {
    1: {
        name: "Foundation",
        emoji: "🏛️",
        description: "Simple explanations, historical context",
        prompt: "Provide a simple, foundational explanation of this Quranic verse suitable for beginners. Include basic historical context if relevant. Keep it concise and accessible."
    },
    2: {
        name: "Classical Shia Commentary", 
        emoji: "📚",
        description: "Tabatabai, Tabrisi perspectives",
        prompt: "Provide classical Shia commentary on this Quranic verse, drawing from scholars like Tabatabai (Al-Mizan) and Tabrisi (Majma' al-Bayan). Focus on traditional Shia interpretations and theological insights."
    },
    3: {
        name: "Contemporary Insights",
        emoji: "🌍", 
        description: "Modern scholars, scientific correlations",
        prompt: "Provide contemporary insights on this Quranic verse, including perspectives from modern Islamic scholars and any relevant scientific correlations or modern-day applications of its teachings."
    },
    4: {
        name: "Ahlul Bayt Wisdom",
        emoji: "⭐",
        description: "Hadith from 14 Infallibles, theological concepts",
        prompt: "Provide commentary on this Quranic verse focusing on teachings from the Ahlul Bayt (the 14 Infallibles in Shia Islam). Include relevant hadith, theological concepts, and spiritual insights from this tradition."
    }
};

/**
 * Fetch all Quran text from AlQuran.cloud API
 */
async function fetchQuranText() {
    console.log('📖 Fetching complete Quran text...');
    
    const surahs = [];
    const verses = [];
    
    for (let surahId = 1; surahId <= 114; surahId++) {
        try {
            console.log(`  📄 Fetching Surah ${surahId}...`);
            
            // Fetch Arabic text and English translation in parallel
            const [arabicResponse, translationResponse] = await Promise.all([
                fetch(`https://api.alquran.cloud/v1/surah/${surahId}`),
                fetch(`https://api.alquran.cloud/v1/surah/${surahId}/en.sahih`)
            ]);
            
            if (!arabicResponse.ok || !translationResponse.ok) {
                throw new Error(`Failed to fetch Surah ${surahId}`);
            }
            
            const arabicData = await arabicResponse.json();
            const translationData = await translationResponse.json();
            
            if (arabicData.code !== 200 || translationData.code !== 200) {
                throw new Error(`API error for Surah ${surahId}`);
            }
            
            // Store surah metadata
            const surahInfo = arabicData.data;
            surahs.push({
                id: surahInfo.number,
                name: surahInfo.name,
                englishName: surahInfo.englishName,
                englishNameTranslation: surahInfo.englishNameTranslation,
                numberOfAyahs: surahInfo.numberOfAyahs,
                revelationType: surahInfo.revelationType
            });
            
            // Store verses
            for (let i = 0; i < arabicData.data.ayahs.length; i++) {
                const arabicAyah = arabicData.data.ayahs[i];
                const translationAyah = translationData.data.ayahs[i];
                
                verses.push({
                    id: `${surahId}:${arabicAyah.numberInSurah}`,
                    surahId: surahId,
                    ayahNumber: arabicAyah.numberInSurah,
                    arabicText: arabicAyah.text.trim(),
                    translation: translationAyah ? translationAyah.text.trim() : '',
                    transliteration: null
                });
            }
            
            // Small delay to be respectful to API
            await new Promise(resolve => setTimeout(resolve, 100));
            
        } catch (error) {
            console.error(`❌ Error fetching Surah ${surahId}:`, error.message);
            throw error;
        }
    }
    
    console.log(`✅ Fetched ${surahs.length} surahs and ${verses.length} verses`);
    return { surahs, verses };
}

/**
 * Generate commentary for a single verse using OpenAI
 */
async function generateVerseCommentary(verse, layer) {
    const layerInfo = COMMENTARY_LAYERS[layer];
    
    const prompt = `
Verse: ${verse.arabicText}
Translation: ${verse.translation}
Surah: ${verse.surahId}, Ayah: ${verse.ayahNumber}

${layerInfo.prompt}

Please provide a thoughtful, scholarly commentary of 2-3 paragraphs. Focus on accuracy and depth while being accessible to modern readers.
`;

    try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${OPENAI_API_KEY}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                model: 'gpt-4',
                messages: [
                    {
                        role: 'system',
                        content: 'You are a knowledgeable Islamic scholar specializing in Quranic commentary with deep understanding of Shia Islamic tradition and classical tafsir literature.'
                    },
                    {
                        role: 'user', 
                        content: prompt
                    }
                ],
                max_tokens: 500,
                temperature: 0.7
            })
        });

        if (!response.ok) {
            throw new Error(`OpenAI API error: ${response.status} ${response.statusText}`);
        }

        const data = await response.json();
        return {
            verseId: verse.id,
            surah: verse.surahId,
            ayah: verse.ayahNumber,
            layer: layer,
            layerName: layerInfo.name,
            content: data.choices[0].message.content.trim(),
            generatedAt: new Date().toISOString(),
            sources: [layerInfo.description]
        };

    } catch (error) {
        console.error(`❌ Error generating commentary for ${verse.id}, layer ${layer}:`, error.message);
        throw error;
    }
}

/**
 * Generate all commentary for all verses
 */
async function generateAllCommentary(verses) {
    console.log(`📝 Generating commentary for ${verses.length} verses across 4 layers...`);
    console.log(`📊 Total API calls needed: ${verses.length * 4} calls`);
    
    const commentary = {
        1: [], // Foundation
        2: [], // Classical Shia
        3: [], // Contemporary 
        4: []  // Ahlul Bayt
    };
    
    let totalCalls = 0;
    const totalNeeded = verses.length * 4;
    
    for (const verse of verses) {
        console.log(`📖 Processing Surah ${verse.surahId}:${verse.ayahNumber}...`);
        
        for (let layer = 1; layer <= 4; layer++) {
            try {
                const layerCommentary = await generateVerseCommentary(verse, layer);
                commentary[layer].push(layerCommentary);
                
                totalCalls++;
                console.log(`  ✅ Layer ${layer} (${COMMENTARY_LAYERS[layer].emoji} ${COMMENTARY_LAYERS[layer].name}) - ${totalCalls}/${totalNeeded}`);
                
                // Rate limiting: 1 call per second to stay within OpenAI limits
                await new Promise(resolve => setTimeout(resolve, 1000));
                
            } catch (error) {
                console.error(`❌ Failed to generate layer ${layer} for ${verse.id}`);
                throw error;
            }
        }
    }
    
    console.log(`✅ Generated ${totalCalls} commentary entries`);
    return commentary;
}

/**
 * Save all data to JSON files
 */
async function saveDataFiles(surahs, verses, commentary) {
    console.log('💾 Saving data files...');
    
    // Ensure output directory exists
    await fs.mkdir(OUTPUT_DIR, { recursive: true });
    
    // Save surahs
    await fs.writeFile(
        path.join(OUTPUT_DIR, 'surahs.json'),
        JSON.stringify({
            success: true,
            count: surahs.length,
            generated_at: new Date().toISOString(),
            data: surahs
        }, null, 2)
    );
    console.log('✅ Saved surahs.json');
    
    // Save verses  
    await fs.writeFile(
        path.join(OUTPUT_DIR, 'verses.json'),
        JSON.stringify({
            success: true,
            count: verses.length,
            generated_at: new Date().toISOString(),
            data: verses
        }, null, 2)
    );
    console.log('✅ Saved verses.json');
    
    // Save commentary by layer
    for (let layer = 1; layer <= 4; layer++) {
        await fs.writeFile(
            path.join(OUTPUT_DIR, `commentary-layer${layer}.json`),
            JSON.stringify({
                success: true,
                layer: layer,
                layerInfo: COMMENTARY_LAYERS[layer],
                count: commentary[layer].length,
                generated_at: new Date().toISOString(),
                data: commentary[layer]
            }, null, 2)
        );
        console.log(`✅ Saved commentary-layer${layer}.json`);
    }
    
    // Save combined dataset summary
    const summary = {
        success: true,
        generated_at: new Date().toISOString(),
        stats: {
            surahs: surahs.length,
            verses: verses.length,
            commentaryEntries: Object.values(commentary).reduce((sum, layer) => sum + layer.length, 0),
            layers: Object.keys(COMMENTARY_LAYERS).length
        },
        layers: COMMENTARY_LAYERS,
        files: [
            'surahs.json',
            'verses.json', 
            'commentary-layer1.json',
            'commentary-layer2.json', 
            'commentary-layer3.json',
            'commentary-layer4.json'
        ]
    };
    
    await fs.writeFile(
        path.join(OUTPUT_DIR, 'dataset-summary.json'),
        JSON.stringify(summary, null, 2)
    );
    console.log('✅ Saved dataset-summary.json');
}

/**
 * Main execution function
 */
async function main() {
    try {
        console.log('🚀 Starting Thaqalyn dataset generation...\n');
        
        // Step 1: Fetch Quran text
        const { surahs, verses } = await fetchQuranText();
        
        // Step 2: Generate commentary (this will take a while!)
        const commentary = await generateAllCommentary(verses);
        
        // Step 3: Save all data
        await saveDataFiles(surahs, verses, commentary);
        
        console.log('\n🎉 Dataset generation complete!');
        console.log(`📁 Output directory: ${OUTPUT_DIR}`);
        console.log(`📊 Generated ${surahs.length} surahs, ${verses.length} verses, and ${Object.values(commentary).reduce((sum, layer) => sum + layer.length, 0)} commentary entries`);
        
    } catch (error) {
        console.error('💥 Dataset generation failed:', error.message);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = { main, fetchQuranText, generateAllCommentary, saveDataFiles };