# Validate Single Tafsir File In Thaqalayn/Thaqalayn/Data

Validate a specific tafsir file to ensure Arabic translations are complete.

**Argument**: `$ARGUMENTS` - The surah number (e.g., `33`) or full filename (e.g., `tafsir_33.json`)

## Task

Run validation on the specified tafsir file `Thaqalayn/Thaqalayn/Data/tafsir_$ARGUMENTS.json` to check:

1. **Every verse** in the surah has Arabic translations
2. **All 5 Arabic layers** are present and non-empty for every verse:
   - `layer1_ar` (Foundation)
   - `layer2_ar` (Classical Shia)
   - `layer3_ar` (Contemporary)
   - `layer4_ar` (Ahlul Bayt)
   - `layer5_ar` (Comparative)

## Validation Script

Run this Python script to validate:

```python
import json
import os
import re
import sys

os.chdir('/Users/muhammadimranali/Documents/development/thaqalyn')

# Parse argument - accept surah number or full filename
arg = "$ARGUMENTS".strip()

# Extract surah number from argument
if arg.endswith('.json'):
    # Full filename provided (e.g., tafsir_33.json)
    match = re.search(r'tafsir_(\d+)\.json', arg)
    if match:
        surah_num = int(match.group(1))
    else:
        print(f"ERROR: Invalid filename format: {arg}")
        print("Expected format: tafsir_<N>.json (e.g., tafsir_33.json)")
        sys.exit(1)
else:
    # Just the surah number
    try:
        surah_num = int(arg)
    except ValueError:
        print(f"ERROR: Invalid argument: {arg}")
        print("Provide either a surah number (e.g., 33) or filename (e.g., tafsir_33.json)")
        sys.exit(1)

tafsir_file = f'Thaqalayn/Thaqalayn/Data/tafsir_{surah_num}.json'

if not os.path.exists(tafsir_file):
    print(f"ERROR: File not found: {tafsir_file}")
    sys.exit(1)

arabic_layers = ['layer1_ar', 'layer2_ar', 'layer3_ar', 'layer4_ar', 'layer5_ar']

with open(tafsir_file, 'r') as f:
    data = json.load(f)

verse_keys = sorted([k for k in data.keys() if k.isdigit()], key=int)
total_verses = len(verse_keys)
total_arabic_layers = 0
issues = []

for verse_key in verse_keys:
    verse = data[verse_key]

    # Check Arabic layers
    for layer in arabic_layers:
        content = verse.get(layer, '')
        if not content or len(content.strip()) == 0:
            issues.append(f"Verse {verse_key}: Empty {layer}")
        else:
            total_arabic_layers += 1

print(f"=== Arabic Tafsir Validation: Surah {surah_num} ===\n")
print(f"File: {tafsir_file}")
print(f"Total verses: {total_verses}")
print(f"Arabic layers found: {total_arabic_layers}")
print(f"Expected Arabic layers (verses x 5): {total_verses * 5}")
print()

if issues:
    print(f"Found {len(issues)} issues:\n")
    for issue in issues:
        print(f"  - {issue}")
else:
    print("COMPLETE!")
    print("   - Every verse has Arabic translations")
    print("   - All 5 Arabic layers populated for every verse")
```

## Usage Examples

- `/validate-arabic-tafsir-file 33` - Validate Surah 33 (Al-Ahzab)
- `/validate-arabic-tafsir-file tafsir_1.json` - Validate Surah 1 (Al-Fatiha)
- `/validate-arabic-tafsir-file 114` - Validate Surah 114 (An-Nas)
