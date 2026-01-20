# Plan: Generate Complete Quran Tafsir (114 Surahs) - Revised v2

## Overview

Generate comprehensive 5-layer Shia tafsir commentary for all 114 surahs using Claude agents. Total: **31,180 commentaries** (6,236 verses × 5 layers).

**Lesson Learned v1**: 5 agents with ~1,200 verses each was too large.
**Lesson Learned v2**: 50-100 verses per agent still caused partial completions and token limits.
**Lesson Learned v3**: 30 verses per agent with 10 parallel agents caused resource issues.
**Current Approach**: **15 verses per agent**, **2 agents max in parallel** for reliable completion.

---

## Confirmed Requirements

| Requirement | Decision |
|-------------|----------|
| Scope | English only (layer1-5) |
| Model | Claude Sonnet 4.5 (`model: "sonnet"`) |
| Output | `new_tafsir/tafsir_{surah}_v{start}-{end}.json` |
| **Chunk size** | **15 verses per agent** |
| **Parallel agents** | **2 max at a time** |
| Web search | Once per verse (shared across 5 layers) |

---

## JSON Output Format Reference

Each verse should be formatted as follows. Use this as the canonical example:

```json
{
  "206": {
    "layer1": "",
    "layer2": "",
    "layer3": "",
    "layer4": "",
    "layer5": ""
  }
}
```

### Format Requirements:
- **Keys**: Verse number as string (e.g., `"206"`)
- **Layers**: `layer1` through `layer5` as properties
- **Content**: Each layer should be 150-250 words of flowing prose
- **No line breaks**: Each layer is a single paragraph string
- **Escape quotes**: Use single quotes within text or escape double quotes

---

## New Wave Structure (15 verses per agent, 2 parallel)

### Estimated Agents per Surah
| Surah | Verses | Agents Needed |
|-------|--------|---------------|
| 1 | 7 | 1 |
| 2 | 286 | 20 |
| 3 | 200 | 14 |
| 4 | 176 | 12 |
| 5 | 120 | 8 |
| 6 | 165 | 11 |
| 7 | 206 | 14 |
| ... | ... | ... |
| **Total** | **6,236** | **~416 agents** |

### Wave Size
- **2 agents per wave** (parallel execution)
- **~208 waves total** to complete all 114 surahs
- **Estimated time per wave**: 15-30 minutes

---

## Execution Process

### For Each Wave:
1. Launch 2 agents in parallel (single message with 2 Task tool calls)
2. Each agent:
   - Reads `quran_data.json` for verse data
   - For each verse (max 15):
     - Uses WebSearch once per verse
     - Generates all 5 layers (150-250 words each)
   - Writes JSON file immediately
3. Wait for wave completion
4. Validate generated files (check JSON validity, verse count)
5. Note any gaps for retry
6. Launch next wave

### File Naming Convention
- Complete surah: `tafsir_{surah}.json`
- Partial range: `tafsir_{surah}_v{start}-{end}.json`
- After all parts complete: Merge into single `tafsir_{surah}.json`

---

## Critical Files

| File | Purpose |
|------|---------|
| `tafsir_prompts.md` | Layer 1-5 prompt templates |
| `Thaqalayn/Thaqalayn/Data/quran_data.json` | Verse data source |
| `new_tafsir/*.json` | Output files |

---

## Merge Script (for combining partial files)

```python
import json
import os

def merge_surah(surah_num, output_dir="new_tafsir"):
    """Merge all partial files for a surah into one complete file."""
    merged = {}
    pattern = f"tafsir_{surah_num}_v"

    for f in os.listdir(output_dir):
        if f.startswith(pattern) and f.endswith('.json'):
            with open(os.path.join(output_dir, f)) as file:
                data = json.load(file)
                merged.update(data)

    # Sort by verse number
    sorted_merged = {str(k): merged[str(k)] for k in sorted([int(x) for x in merged.keys()])}

    output_file = os.path.join(output_dir, f"tafsir_{surah_num}.json")
    with open(output_file, 'w') as f:
        json.dump(sorted_merged, f, ensure_ascii=False, indent=2)

    print(f"Merged {len(sorted_merged)} verses into {output_file}")
    return sorted_merged

# Usage: merge_surah(2)  # Merges all Surah 2 parts
```

---

## Current Progress (Updated: 2026-01-09)

### Completed Surahs (10 surahs, 1,414 verses)

| Surah | Name | Verses | Status |
|-------|------|--------|--------|
| 1 | Al-Faatiha | 7 | ✅ Complete |
| 2 | Al-Baqara | 286 | ✅ Complete |
| 3 | Aal-i-Imraan | 200 | ✅ Complete |
| 4 | An-Nisaa | 176 | ✅ Complete |
| 5 | Al-Maaida | 120 | ✅ Complete |
| 6 | Al-An'aam | 165 | ✅ Complete |
| 7 | Al-A'raaf | 206 | ✅ Complete |
| 8 | Al-Anfaal | 75 | ✅ Complete |
| 9 | At-Tawba | 129 | ✅ Complete |
| 65 | At-Talaaq | 12 | ✅ Complete |

### Partially Complete

| Surah | Name | Verses | Done | Missing |
|-------|------|--------|------|---------|
| 10 | Yunus | 109 | 103 | 104-109 (6 verses) |

### Remaining Surahs (103 surahs, 4,716 verses)

| Surah Range | Surahs | Total Verses | Agents Needed |
|-------------|--------|--------------|---------------|
| 11-64 | 54 | 3,529 | ~236 |
| 66-114 | 49 | 1,181 | ~79 |
| **Total** | **103** | **4,710** + 6 gaps | **~315** |

---

## Remaining Work Breakdown

### Priority 1: Complete Surah 10
- Missing verses: 104-109 (6 verses)
- Agents needed: 1

### Priority 2: Surahs 11-30 (Large surahs first)

| Surah | Name | Verses | Agents |
|-------|------|--------|--------|
| 11 | Hud | 123 | 9 |
| 12 | Yusuf | 111 | 8 |
| 13 | Ar-Ra'd | 43 | 3 |
| 14 | Ibrahim | 52 | 4 |
| 15 | Al-Hijr | 99 | 7 |
| 16 | An-Nahl | 128 | 9 |
| 17 | Al-Israa | 111 | 8 |
| 18 | Al-Kahf | 110 | 8 |
| 19 | Maryam | 98 | 7 |
| 20 | Taa-Haa | 135 | 9 |
| 21 | Al-Anbiyaa | 112 | 8 |
| 22 | Al-Hajj | 78 | 6 |
| 23 | Al-Muminoon | 118 | 8 |
| 24 | An-Noor | 64 | 5 |
| 25 | Al-Furqaan | 77 | 6 |
| 26 | Ash-Shu'araa | 227 | 16 |
| 27 | An-Naml | 93 | 7 |
| 28 | Al-Qasas | 88 | 6 |
| 29 | Al-Ankaboot | 69 | 5 |
| 30 | Ar-Room | 60 | 4 |
| **Subtotal** | | **1,996** | **143** |

### Priority 3: Surahs 31-64

| Surah | Name | Verses | Agents |
|-------|------|--------|--------|
| 31 | Luqman | 34 | 3 |
| 32 | As-Sajda | 30 | 2 |
| 33 | Al-Ahzaab | 73 | 5 |
| 34 | Saba | 54 | 4 |
| 35 | Faatir | 45 | 3 |
| 36 | Yaseen | 83 | 6 |
| 37 | As-Saaffaat | 182 | 13 |
| 38 | Saad | 88 | 6 |
| 39 | Az-Zumar | 75 | 5 |
| 40 | Ghafir | 85 | 6 |
| 41 | Fussilat | 54 | 4 |
| 42 | Ash-Shura | 53 | 4 |
| 43 | Az-Zukhruf | 89 | 6 |
| 44 | Ad-Dukhaan | 59 | 4 |
| 45 | Al-Jaathiya | 37 | 3 |
| 46 | Al-Ahqaf | 35 | 3 |
| 47 | Muhammad | 38 | 3 |
| 48 | Al-Fath | 29 | 2 |
| 49 | Al-Hujuraat | 18 | 2 |
| 50 | Qaaf | 45 | 3 |
| 51 | Adh-Dhaariyat | 60 | 4 |
| 52 | At-Tur | 49 | 4 |
| 53 | An-Najm | 62 | 5 |
| 54 | Al-Qamar | 55 | 4 |
| 55 | Ar-Rahmaan | 78 | 6 |
| 56 | Al-Waaqia | 96 | 7 |
| 57 | Al-Hadid | 29 | 2 |
| 58 | Al-Mujaadila | 22 | 2 |
| 59 | Al-Hashr | 24 | 2 |
| 60 | Al-Mumtahana | 13 | 1 |
| 61 | As-Saff | 14 | 1 |
| 62 | Al-Jumu'a | 11 | 1 |
| 63 | Al-Munaafiqoon | 11 | 1 |
| 64 | At-Taghaabun | 18 | 2 |
| **Subtotal** | | **1,533** | **117** |

### Priority 4: Surahs 66-114 (Short surahs)

| Surah | Name | Verses | Agents |
|-------|------|--------|--------|
| 66 | At-Tahrim | 12 | 1 |
| 67 | Al-Mulk | 30 | 2 |
| 68 | Al-Qalam | 52 | 4 |
| 69 | Al-Haaqqa | 52 | 4 |
| 70 | Al-Ma'aarij | 44 | 3 |
| 71 | Nooh | 28 | 2 |
| 72 | Al-Jinn | 28 | 2 |
| 73 | Al-Muzzammil | 20 | 2 |
| 74 | Al-Muddaththir | 56 | 4 |
| 75 | Al-Qiyaama | 40 | 3 |
| 76 | Al-Insaan | 31 | 3 |
| 77 | Al-Mursalaat | 50 | 4 |
| 78 | An-Naba | 40 | 3 |
| 79 | An-Naazi'aat | 46 | 4 |
| 80 | Abasa | 42 | 3 |
| 81 | At-Takwir | 29 | 2 |
| 82 | Al-Infitaar | 19 | 2 |
| 83 | Al-Mutaffifin | 36 | 3 |
| 84 | Al-Inshiqaaq | 25 | 2 |
| 85 | Al-Burooj | 22 | 2 |
| 86 | At-Taariq | 17 | 2 |
| 87 | Al-A'laa | 19 | 2 |
| 88 | Al-Ghaashiya | 26 | 2 |
| 89 | Al-Fajr | 30 | 2 |
| 90 | Al-Balad | 20 | 2 |
| 91 | Ash-Shams | 15 | 1 |
| 92 | Al-Lail | 21 | 2 |
| 93 | Ad-Dhuhaa | 11 | 1 |
| 94 | Ash-Sharh | 8 | 1 |
| 95 | At-Tin | 8 | 1 |
| 96 | Al-Alaq | 19 | 2 |
| 97 | Al-Qadr | 5 | 1 |
| 98 | Al-Bayyina | 8 | 1 |
| 99 | Az-Zalzala | 8 | 1 |
| 100 | Al-Aadiyaat | 11 | 1 |
| 101 | Al-Qaari'a | 11 | 1 |
| 102 | At-Takaathur | 8 | 1 |
| 103 | Al-Asr | 3 | 1 |
| 104 | Al-Humaza | 9 | 1 |
| 105 | Al-Fil | 5 | 1 |
| 106 | Quraish | 4 | 1 |
| 107 | Al-Maa'un | 7 | 1 |
| 108 | Al-Kawthar | 3 | 1 |
| 109 | Al-Kaafiroon | 6 | 1 |
| 110 | An-Nasr | 3 | 1 |
| 111 | Al-Masad | 5 | 1 |
| 112 | Al-Ikhlaas | 4 | 1 |
| 113 | Al-Falaq | 5 | 1 |
| 114 | An-Naas | 6 | 1 |
| **Subtotal** | | **1,169** | **88** |

---

## Summary Statistics

| Category | Verses | Percentage |
|----------|--------|------------|
| Completed | 1,414 | 22.7% |
| Partial (Surah 10) | 103 | 1.7% |
| Missing from Surah 10 | 6 | 0.1% |
| Remaining | 4,713 | 75.5% |
| **Total** | **6,236** | **100%** |

### Estimated Remaining Work
- **Agents needed**: ~315
- **Waves (2 agents/wave)**: ~158 waves
- **Execution strategy**: Continue with 2 parallel agents per wave
