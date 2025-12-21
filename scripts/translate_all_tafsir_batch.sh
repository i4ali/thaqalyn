#!/bin/bash

# Batch Translation Script for All Tafsir Files
# Translates tafsir_1.json through tafsir_114.json to a target language
#
# Usage:
#   ./translate_all_tafsir_batch.sh <language> [start_surah] [end_surah]
#
# Examples:
#   ./translate_all_tafsir_batch.sh ar              # Translate all 114 surahs to Arabic
#   ./translate_all_tafsir_batch.sh fr 1 10         # Translate surahs 1-10 to French
#   ./translate_all_tafsir_batch.sh ur 50 114       # Translate surahs 50-114 to Urdu

set -e  # Exit on error

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <language> [start_surah] [end_surah]"
    echo ""
    echo "Supported languages:"
    echo "  ar - Arabic"
    echo "  fr - French"
    echo "  ur - Urdu"
    echo "  tr - Turkish"
    echo "  id - Indonesian"
    echo "  fa - Persian/Farsi"
    echo "  ms - Malay"
    echo "  bn - Bengali"
    echo "  hi - Hindi"
    echo "  es - Spanish"
    echo "  de - German"
    echo "  ru - Russian"
    echo "  zh-cn - Chinese (Simplified)"
    echo ""
    echo "Examples:"
    echo "  $0 ar              # Translate all 114 surahs to Arabic"
    echo "  $0 fr 1 10         # Translate surahs 1-10 to French"
    echo "  $0 ur 50 114       # Translate surahs 50-114 to Urdu"
    exit 1
fi

LANGUAGE=$1
START_SURAH=${2:-1}
END_SURAH=${3:-114}

# Validate surah range
if [ $START_SURAH -lt 1 ] || [ $START_SURAH -gt 114 ]; then
    echo "Error: Start surah must be between 1 and 114"
    exit 1
fi

if [ $END_SURAH -lt 1 ] || [ $END_SURAH -gt 114 ]; then
    echo "Error: End surah must be between 1 and 114"
    exit 1
fi

if [ $START_SURAH -gt $END_SURAH ]; then
    echo "Error: Start surah cannot be greater than end surah"
    exit 1
fi

# Paths
DATA_DIR="Thaqalayn/Thaqalayn/Data"
SCRIPT_PATH="scripts/translate_tafsir.py"

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Error: Virtual environment .venv not found"
    echo "Please create it first: python3 -m venv .venv"
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate

# Check if googletrans is installed
if ! python3 -c "import googletrans" 2>/dev/null; then
    echo "Error: googletrans not installed"
    echo "Please install it: pip install googletrans==4.0.0-rc1"
    exit 1
fi

echo "============================================================"
echo "Batch Tafsir Translation"
echo "============================================================"
echo "Language: $LANGUAGE"
echo "Surah range: $START_SURAH - $END_SURAH"
echo "Total surahs: $((END_SURAH - START_SURAH + 1))"
echo "============================================================"
echo ""

# Track statistics
TOTAL_SURAHS=$((END_SURAH - START_SURAH + 1))
COMPLETED=0
FAILED=0
SKIPPED=0
START_TIME=$(date +%s)

# Create log file
LOG_FILE="translation_log_${LANGUAGE}_$(date +%Y%m%d_%H%M%S).txt"
echo "Logging to: $LOG_FILE"
echo ""

# Function to format time
format_time() {
    local seconds=$1
    printf "%02d:%02d:%02d" $((seconds/3600)) $((seconds%3600/60)) $((seconds%60))
}

# Loop through surahs
for surah in $(seq $START_SURAH $END_SURAH); do
    TAFSIR_FILE="$DATA_DIR/tafsir_${surah}.json"

    echo "[$((surah - START_SURAH + 1))/$TOTAL_SURAHS] Processing Surah $surah..."

    # Check if file exists
    if [ ! -f "$TAFSIR_FILE" ]; then
        echo "  ⚠️  File not found: $TAFSIR_FILE (skipping)"
        echo "SKIPPED: Surah $surah - File not found" >> "$LOG_FILE"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Run translation
    if python3 "$SCRIPT_PATH" "$TAFSIR_FILE" "$LANGUAGE" >> "$LOG_FILE" 2>&1; then
        echo "  ✅ Completed"
        echo "SUCCESS: Surah $surah" >> "$LOG_FILE"
        COMPLETED=$((COMPLETED + 1))
    else
        echo "  ❌ Failed (check log for details)"
        echo "FAILED: Surah $surah" >> "$LOG_FILE"
        FAILED=$((FAILED + 1))
    fi

    # Show progress
    ELAPSED=$(($(date +%s) - START_TIME))
    AVG_TIME=$((ELAPSED / (surah - START_SURAH + 1)))
    REMAINING_SURAHS=$((END_SURAH - surah))
    ETA=$((AVG_TIME * REMAINING_SURAHS))

    echo "  Progress: $COMPLETED completed, $FAILED failed, $SKIPPED skipped"
    echo "  Elapsed: $(format_time $ELAPSED) | ETA: $(format_time $ETA)"
    echo ""
done

# Final summary
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

echo "============================================================"
echo "Batch Translation Complete!"
echo "============================================================"
echo "Language: $LANGUAGE"
echo "Surah range: $START_SURAH - $END_SURAH"
echo ""
echo "Results:"
echo "  ✅ Completed: $COMPLETED"
echo "  ❌ Failed: $FAILED"
echo "  ⚠️  Skipped: $SKIPPED"
echo "  📊 Total: $TOTAL_SURAHS"
echo ""
echo "Time: $(format_time $TOTAL_TIME)"
echo "Log file: $LOG_FILE"
echo "============================================================"

# Exit with error if any failed
if [ $FAILED -gt 0 ]; then
    exit 1
fi
