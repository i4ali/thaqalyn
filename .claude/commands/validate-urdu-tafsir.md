# Validate Urdu Tafsir

Validate all Urdu tafsir files in `new_tafsir/` directory to ensure completeness.

## Task

Run a comprehensive validation of all `new_tafsir/tafsir_*_ur.json` files to check:

1. **All 114 surahs** have corresponding Urdu tafsir files
2. **Every verse** in each surah has a translation (compare against English `tafsir_*.json` files)
3. **All 5 layers** are present and non-empty for every verse:
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

ur_files = glob.glob('new_tafsir/tafsir_*_ur.json')

def get_surah_num(path):
    match = re.search(r'tafsir_(\d+)_ur\.json', path)
    return int(match.group(1)) if match else 0

ur_files = sorted([f for f in ur_files if get_surah_num(f) > 0], key=get_surah_num)

layers = ['layer1_urdu', 'layer2_urdu', 'layer3_urdu', 'layer4_urdu', 'layer5_urdu']

total_surahs = 0
total_verses = 0
total_layers = 0
issues = []

for ur_file in ur_files:
    surah_num = get_surah_num(ur_file)

    en_file = f'new_tafsir/tafsir_{surah_num}.json'
    if not os.path.exists(en_file):
        issues.append(f"Surah {surah_num}: No English file found")
        continue

    with open(en_file, 'r') as f:
        en_data = json.load(f)

    with open(ur_file, 'r') as f:
        ur_data = json.load(f)

    total_surahs += 1

    en_verses = set(k for k in en_data.keys() if k.isdigit())
    ur_verses = set(k for k in ur_data.keys() if k.isdigit())

    missing_verses = en_verses - ur_verses
    if missing_verses:
        issues.append(f"Surah {surah_num}: Missing {len(missing_verses)} verses: {sorted([int(v) for v in missing_verses])}")

    for verse_key in ur_verses:
        total_verses += 1
        verse = ur_data[verse_key]
        for layer in layers:
            content = verse.get(layer, '')
            if not content or len(content.strip()) == 0:
                issues.append(f"Surah {surah_num}:{verse_key}: Empty {layer}")
            else:
                total_layers += 1

print(f"=== Urdu Tafsir Validation Report ===\n")
print(f"Surahs checked: {total_surahs}")
print(f"Total verses: {total_verses}")
print(f"Total layer translations: {total_layers}")
print(f"Expected layers (verses x 5): {total_verses * 5}")
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
    print("   - Every verse has translations")
    print("   - All 5 layers populated for every verse")
```

## Expected Output

When all translations are complete:
- Surahs checked: 114
- Total verses: 6236
- Total layer translations: 31180
- Expected layers: 31180

## If Issues Found

If missing verses or empty layers are found, use the `urdu-translator` agent to fix them:

```
Translate English tafsir layers to Urdu for Surah X, verses Y-Z.
Source: new_tafsir/tafsir_X.json
Target: new_tafsir/tafsir_X_ur.json
```
