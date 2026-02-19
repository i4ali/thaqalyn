# Validate Tafsir JSON Structure In Thaqalayn/Thaqalayn/Data For Given Surah Number

Validate a tafsir file to ensure it has the correct JSON object structure with all required keys.

**Argument**: `$ARGUMENTS` - The surah number (e.g., `33`) or full filename (e.g., `tafsir_33.json`)

## Task

Run validation on the specified tafsir file `Thaqalayn/Thaqalayn/Data/tafsir_$ARGUMENTS.json` to check:

1. **Top-level structure**: Only numeric verse keys (no metadata or other keys)
2. **All 15 layer keys** present for every verse:
   - English: `layer1`, `layer2`, `layer3`, `layer4`, `layer5`
   - Arabic: `layer1_ar`, `layer2_ar`, `layer3_ar`, `layer4_ar`, `layer5_ar`
   - Urdu: `layer1_urdu`, `layer2_urdu`, `layer3_urdu`, `layer4_urdu`, `layer5_urdu`
3. **quickOverview** present for every verse with `concepts` array
4. **Each concept** in quickOverview has all required keys:
   - Base: `id`, `title`, `icon`, `colorHex`, `coreInsight`, `whyItMatters`, `position`, `arabicHighlight`
   - Urdu: `title_urdu`, `coreInsight_urdu`, `whyItMatters_urdu`
   - Arabic: `title_ar`, `coreInsight_ar`, `whyItMatters_ar`

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
    match = re.search(r'tafsir_(\d+)\.json', arg)
    if match:
        surah_num = int(match.group(1))
    else:
        print(f"ERROR: Invalid filename format: {arg}")
        print("Expected format: tafsir_<N>.json (e.g., tafsir_33.json)")
        sys.exit(1)
else:
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

# Required keys for each verse
LAYER_KEYS = [
    'layer1', 'layer2', 'layer3', 'layer4', 'layer5',
    'layer1_ar', 'layer2_ar', 'layer3_ar', 'layer4_ar', 'layer5_ar',
    'layer1_urdu', 'layer2_urdu', 'layer3_urdu', 'layer4_urdu', 'layer5_urdu',
]
VERSE_KEYS = LAYER_KEYS + ['quickOverview']

# Required keys for each concept in quickOverview
CONCEPT_BASE_KEYS = ['id', 'title', 'icon', 'colorHex', 'coreInsight', 'whyItMatters', 'position', 'arabicHighlight']
CONCEPT_URDU_KEYS = ['title_urdu', 'coreInsight_urdu', 'whyItMatters_urdu']
CONCEPT_AR_KEYS = ['title_ar', 'coreInsight_ar', 'whyItMatters_ar']
CONCEPT_KEYS = CONCEPT_BASE_KEYS + CONCEPT_URDU_KEYS + CONCEPT_AR_KEYS

with open(tafsir_file, 'r') as f:
    data = json.load(f)

issues = []

# Check top-level keys are only numeric
non_numeric_keys = [k for k in data.keys() if not k.isdigit()]
if non_numeric_keys:
    issues.append(f"Top-level: Found non-verse keys: {non_numeric_keys}")

verse_keys = sorted([k for k in data.keys() if k.isdigit()], key=int)
total_verses = len(verse_keys)

for verse_key in verse_keys:
    verse = data[verse_key]

    # Check verse is a dict
    if not isinstance(verse, dict):
        issues.append(f"Verse {verse_key}: Not a dictionary object")
        continue

    # Check all required verse keys
    for key in VERSE_KEYS:
        if key not in verse:
            issues.append(f"Verse {verse_key}: Missing key '{key}'")

    # Check for unexpected keys
    expected_keys = set(VERSE_KEYS)
    actual_keys = set(verse.keys())
    unexpected = actual_keys - expected_keys
    if unexpected:
        issues.append(f"Verse {verse_key}: Unexpected keys: {list(unexpected)}")

    # Validate quickOverview structure
    if 'quickOverview' in verse:
        qo = verse['quickOverview']

        if not isinstance(qo, dict):
            issues.append(f"Verse {verse_key}: quickOverview is not a dictionary")
        elif 'concepts' not in qo:
            issues.append(f"Verse {verse_key}: quickOverview missing 'concepts' array")
        elif not isinstance(qo['concepts'], list):
            issues.append(f"Verse {verse_key}: quickOverview.concepts is not an array")
        else:
            concepts = qo['concepts']
            if len(concepts) == 0:
                issues.append(f"Verse {verse_key}: quickOverview.concepts is empty")

            for i, concept in enumerate(concepts):
                if not isinstance(concept, dict):
                    issues.append(f"Verse {verse_key}: concept[{i}] is not a dictionary")
                    continue

                # Check all required concept keys
                for key in CONCEPT_KEYS:
                    if key not in concept:
                        issues.append(f"Verse {verse_key}: concept[{i}] missing key '{key}'")

print(f"=== Tafsir Structure Validation: Surah {surah_num} ===")
print()
print(f"File: {tafsir_file}")
print(f"Total verses: {total_verses}")
print()

if issues:
    print(f"Found {len(issues)} issues:")
    print()
    for issue in issues[:50]:  # Limit output to first 50 issues
        print(f"  - {issue}")
    if len(issues) > 50:
        print(f"  ... and {len(issues) - 50} more issues")
else:
    print("VALID STRUCTURE!")
    print("   - All verses have correct keys")
    print("   - All 15 layer keys present")
    print("   - quickOverview with concepts present")
    print("   - All concept keys validated")
```

## Usage Examples

- `/validate-tafsir-structure 33` - Validate Surah 33 (Al-Ahzab)
- `/validate-tafsir-structure tafsir_1.json` - Validate Surah 1 (Al-Fatiha)
- `/validate-tafsir-structure 114` - Validate Surah 114 (An-Nas)
