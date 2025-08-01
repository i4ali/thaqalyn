#!/usr/bin/env node

/**
 * Test Script - Generate Small Dataset
 * 
 * Generates commentary for just Al-Fatihah (7 verses) to test the process
 * before running on the complete Quran
 */

const { fetchQuranText, generateAllCommentary, saveDataFiles } = require('./generate-dataset');

async function testSmallDataset() {
    try {
        console.log('🧪 Testing with small dataset (Al-Fatihah only)...\n');
        
        // Fetch just Al-Fatihah (Surah 1)
        console.log('📖 Fetching Al-Fatihah...');
        
        const arabicResponse = await fetch('https://api.alquran.cloud/v1/surah/1');
        const translationResponse = await fetch('https://api.alquran.cloud/v1/surah/1/en.sahih');
        
        const arabicData = await arabicResponse.json();
        const translationData = await translationResponse.json();
        
        // Create test dataset
        const testSurahs = [{
            id: 1,
            name: arabicData.data.name,
            englishName: arabicData.data.englishName,
            englishNameTranslation: arabicData.data.englishNameTranslation,
            numberOfAyahs: arabicData.data.numberOfAyahs,
            revelationType: arabicData.data.revelationType
        }];
        
        const testVerses = arabicData.data.ayahs.map((ayah, index) => ({
            id: `1:${ayah.numberInSurah}`,
            surahId: 1,
            ayahNumber: ayah.numberInSurah,
            arabicText: ayah.text.trim(),
            translation: translationData.data.ayahs[index]?.text.trim() || '',
            transliteration: null
        }));
        
        console.log(`✅ Test dataset: ${testSurahs.length} surah, ${testVerses.length} verses`);
        console.log(`📊 Will generate ${testVerses.length * 4} commentary entries\n`);
        
        // Generate commentary
        const commentary = await generateAllCommentary(testVerses);
        
        // Save test files
        await saveDataFiles(testSurahs, testVerses, commentary);
        
        console.log('\n🎉 Test dataset generation complete!');
        console.log('📁 Check the ./data directory for generated files');
        console.log('\n💡 If this looks good, run: npm run generate');
        
    } catch (error) {
        console.error('💥 Test failed:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    testSmallDataset();
}

module.exports = { testSmallDataset };