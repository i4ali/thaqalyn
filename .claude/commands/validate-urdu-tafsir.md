# Validate All Urdu Tafsir In Thaqalayn/Thaqalayn/Data

Validate all tafsir files in `Thaqalayn/Thaqalayn/Data/` directory to ensure Urdu translations are complete.

## Task

Run a comprehensive validation of all `Thaqalayn/Thaqalayn/Data/tafsir_*.json` files to check:

1. **All 114 surahs** have corresponding tafsir files
2. **Every verse** in each surah has Urdu translations
3. **All 5 Urdu layers** are present and non-empty for every verse:
   - `layer1_urdu` (Foundation)
   - `layer2_urdu` (Classical Shia)
   - `layer3_urdu` (Contemporary)
   - `layer4_urdu` (Ahlul Bayt)
   - `layer5_urdu` (Comparative)

## Validation Script

Run this Python script to validate:

```python
import json
import glob
import os
import re

os.chdir('/Users/muhammadimranali/Documents/development/thaqalyn')

tafsir_files = glob.glob('Thaqalayn/Thaqalayn/Data/tafsir_*.json')

def get_surah_num(path):
    match = re.search(r'tafsir_(\d+)\.json', path)
    return int(match.group(1)) if match else 0

tafsir_files = sorted([f for f in tafsir_files if get_surah_num(f) > 0], key=get_surah_num)

urdu_layers = ['layer1_urdu', 'layer2_urdu', 'layer3_urdu', 'layer4_urdu', 'layer5_urdu']
english_layers = ['layer1', 'layer2', 'layer3', 'layer4', 'layer5']

total_surahs = 0
total_verses = 0
total_urdu_layers = 0
issues = []

for tafsir_file in tafsir_files:
    surah_num = get_surah_num(tafsir_file)

    with open(tafsir_file, 'r') as f:
        data = json.load(f)

    total_surahs += 1

    verse_keys = [k for k in data.keys() if k.isdigit()]

    for verse_key in verse_keys:
        total_verses += 1
        verse = data[verse_key]

        # Check Urdu layers
        for layer in urdu_layers:
            content = verse.get(layer, '')
            if not content or len(content.strip()) == 0:
                issues.append(f"Surah {surah_num}:{verse_key}: Empty {layer}")
            else:
                total_urdu_layers += 1

print(f"=== Urdu Tafsir Validation Report ===\n")
print(f"Surahs checked: {total_surahs}")
print(f"Total verses: {total_verses}")
print(f"Total Urdu layer translations: {total_urdu_layers}")
print(f"Expected Urdu layers (verses x 5): {total_verses * 5}")
print()

if issues:
    print(f"Found {len(issues)} issues:\n")
    for issue in issues[:50]:
        print(f"  {issue}")
    if len(issues) > 50:
        print(f"  ... and {len(issues) - 50} more issues")
else:
    print("ALL COMPLETE!")
    print("   - All 114 surahs present")
    print("   - Every verse has Urdu translations")
    print("   - All 5 Urdu layers populated for every verse")
```

## Expected Output

When all translations are complete:
- Surahs checked: 114
- Total verses: 6236
- Total Urdu layer translations: 31180
- Expected Urdu layers: 31180

