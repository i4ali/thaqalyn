# Merge Urdu Tafsir Parts Into Main Tafsir File

Merges partial Urdu tafsir files from `new_tafsir/` into the main tafsir JSON for a given surah.

**Argument**: `$ARGUMENTS` - The surah number (e.g., `31`)

## Task

1. Find all files matching `new_tafsir/tafsir_<N>_v*_ur.json`
2. Merge them into `new_tafsir/tafsir_<N>_ur.json` (sorted by verse number)
3. Copy the `layer1_urdu` – `layer5_urdu` fields into each verse of `Thaqalayn/Thaqalayn/Data/tafsir_<N>.json`
4. Report the result

## Script

Run this Python script:

```python
import json
import os
import re
import sys
import glob

os.chdir('/Users/muhammadimranali/Documents/development/thaqalyn')

arg = "$ARGUMENTS".strip()
try:
    surah_num = int(arg)
except ValueError:
    print(f"ERROR: Invalid argument: {arg}")
    print("Provide a surah number (e.g., 31)")
    sys.exit(1)

# Step 1: Find partial files
pattern = f'new_tafsir/tafsir_{surah_num}_v*_ur.json'
part_files = sorted(glob.glob(pattern))

if not part_files:
    print(f"ERROR: No partial files found matching: {pattern}")
    sys.exit(1)

print(f"Found {len(part_files)} partial file(s):")
for f in part_files:
    print(f"  {f}")

# Step 2: Merge into a single dict, sorted by verse number
merged = {}
for path in part_files:
    with open(path, encoding='utf-8') as f:
        data = json.load(f)
    merged.update(data)

merged = {str(k): merged[str(k)] for k in sorted(int(k) for k in merged)}

merged_path = f'new_tafsir/tafsir_{surah_num}_ur.json'
with open(merged_path, 'w', encoding='utf-8') as f:
    json.dump(merged, f, ensure_ascii=False, indent=2)

print(f"\nMerged {len(merged)} verses → {merged_path}")
print(f"Verses: {sorted(int(k) for k in merged)}")

# Step 3: Copy urdu layers into main tafsir file
tafsir_path = f'Thaqalayn/Thaqalayn/Data/tafsir_{surah_num}.json'
if not os.path.exists(tafsir_path):
    print(f"\nERROR: Main tafsir file not found: {tafsir_path}")
    sys.exit(1)

with open(tafsir_path, encoding='utf-8') as f:
    tafsir = json.load(f)

urdu_keys = ['layer1_urdu', 'layer2_urdu', 'layer3_urdu', 'layer4_urdu', 'layer5_urdu']
updated = 0
missing = []

for verse_num, urdu_data in merged.items():
    if verse_num not in tafsir:
        missing.append(verse_num)
        continue
    for key in urdu_keys:
        if key in urdu_data:
            tafsir[verse_num][key] = urdu_data[key]
    updated += 1

with open(tafsir_path, 'w', encoding='utf-8') as f:
    json.dump(tafsir, f, ensure_ascii=False, indent=2)

print(f"\nUpdated {updated} verses in {tafsir_path}")
if missing:
    print(f"WARNING: Verses in urdu file not found in main tafsir: {missing}")
else:
    print("Done.")
```

## Usage Examples

- `/merge-urdu-tafsir 31` - Merge all `new_tafsir/tafsir_31_v*_ur.json` parts into `tafsir_31.json`
- `/merge-urdu-tafsir 32` - Merge Surah 32 parts
