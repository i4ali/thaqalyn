#!/usr/bin/env python3
"""
Validate Tafsir JSON Schema

This script validates all tafsir_x.json files (1-114) against the expected schema.
Generates an HTML report for easy viewing.
"""

import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple

# Required keys for each verse entry
REQUIRED_VERSE_KEYS = {
    "layer1", "layer1_ar", "layer1_urdu",
    "layer2", "layer2_ar", "layer2_urdu",
    "layer3", "layer3_ar", "layer3_urdu",
    "layer4", "layer4_ar", "layer4_urdu",
    "layer5", "layer5_ar", "layer5_urdu",
    "quickOverview"
}

# Required keys for each concept in quickOverview
REQUIRED_CONCEPT_KEYS = {
    "id", "title", "title_ar", "title_urdu",
    "icon", "colorHex", "position",
    "coreInsight", "coreInsight_ar", "coreInsight_urdu",
    "whyItMatters", "whyItMatters_ar", "whyItMatters_urdu",
    "arabicHighlight"
}

DATA_DIR = Path("Thaqalayn/Thaqalayn/Data")
REPORT_FILE = "tafsir_schema_report.html"


def validate_concept(concept: Dict, verse_key: str, concept_idx: int) -> List[Dict]:
    """Validate a single concept object in quickOverview."""
    errors = []

    if not isinstance(concept, dict):
        errors.append({"verse": verse_key, "concept": concept_idx, "issue": "Not a dictionary"})
        return errors

    concept_keys = set(concept.keys())
    missing_keys = REQUIRED_CONCEPT_KEYS - concept_keys

    if missing_keys:
        errors.append({"verse": verse_key, "concept": concept_idx, "issue": f"Missing keys: {sorted(missing_keys)}"})

    for key in REQUIRED_CONCEPT_KEYS:
        if key in concept and not isinstance(concept[key], str):
            errors.append({"verse": verse_key, "concept": concept_idx, "issue": f"'{key}' should be string, got {type(concept[key]).__name__}"})

    return errors


def validate_quick_overview(quick_overview: Dict, verse_key: str) -> List[Dict]:
    """Validate the quickOverview structure."""
    errors = []

    if not isinstance(quick_overview, dict):
        errors.append({"verse": verse_key, "concept": "-", "issue": f"quickOverview should be object, got {type(quick_overview).__name__}"})
        return errors

    if "concepts" not in quick_overview:
        errors.append({"verse": verse_key, "concept": "-", "issue": "quickOverview missing 'concepts' array"})
        return errors

    concepts = quick_overview["concepts"]
    if not isinstance(concepts, list):
        errors.append({"verse": verse_key, "concept": "-", "issue": f"quickOverview.concepts should be array, got {type(concepts).__name__}"})
        return errors

    if len(concepts) == 0:
        errors.append({"verse": verse_key, "concept": "-", "issue": "quickOverview.concepts is empty"})

    for idx, concept in enumerate(concepts):
        errors.extend(validate_concept(concept, verse_key, idx))

    return errors


def validate_verse(verse_data: Dict, verse_key: str) -> List[Dict]:
    """Validate a single verse entry."""
    errors = []

    if not isinstance(verse_data, dict):
        errors.append({"verse": verse_key, "concept": "-", "issue": "Not a dictionary"})
        return errors

    verse_keys = set(verse_data.keys())
    missing_keys = REQUIRED_VERSE_KEYS - verse_keys
    if missing_keys:
        errors.append({"verse": verse_key, "concept": "-", "issue": f"Missing keys: {sorted(missing_keys)}"})

    layer_keys = [k for k in REQUIRED_VERSE_KEYS if k != "quickOverview"]
    for key in layer_keys:
        if key in verse_data and not isinstance(verse_data[key], str):
            errors.append({"verse": verse_key, "concept": "-", "issue": f"'{key}' should be string, got {type(verse_data[key]).__name__}"})

    if "quickOverview" in verse_data:
        errors.extend(validate_quick_overview(verse_data["quickOverview"], verse_key))

    return errors


def validate_file(filepath: Path) -> Tuple[int, bool, List[Dict]]:
    """Validate a single tafsir JSON file. Returns (verse_count, is_valid, errors)."""
    errors = []

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        return 0, False, [{"verse": "-", "concept": "-", "issue": f"JSON parse error: {e}"}]
    except Exception as e:
        return 0, False, [{"verse": "-", "concept": "-", "issue": f"Read error: {e}"}]

    if not isinstance(data, dict):
        return 0, False, [{"verse": "-", "concept": "-", "issue": f"Root should be object, got {type(data).__name__}"}]

    if len(data) == 0:
        return 0, False, [{"verse": "-", "concept": "-", "issue": "File is empty (no verses)"}]

    for verse_key, verse_data in data.items():
        errors.extend(validate_verse(verse_data, verse_key))

    return len(data), len(errors) == 0, errors


def generate_html_report(results: Dict) -> str:
    """Generate an HTML report from validation results."""

    total_files = results["total_files"]
    valid_files = results["valid_files"]
    invalid_files = results["invalid_files"]
    missing_files = results["missing_files"]
    files_with_errors = results["files_with_errors"]
    timestamp = results["timestamp"]

    is_all_valid = invalid_files == 0 and len(missing_files) == 0
    status_class = "success" if is_all_valid else "error"
    status_text = "ALL FILES VALID" if is_all_valid else f"{invalid_files} files with errors"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tafsir Schema Validation Report</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e4e4e4;
            min-height: 100vh;
            padding: 2rem;
        }}
        .container {{ max-width: 1200px; margin: 0 auto; }}
        h1 {{
            font-size: 2rem;
            margin-bottom: 0.5rem;
            color: #fff;
        }}
        .timestamp {{ color: #888; margin-bottom: 2rem; font-size: 0.9rem; }}

        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }}
        .stat-card {{
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid rgba(255,255,255,0.1);
        }}
        .stat-card h3 {{ color: #888; font-size: 0.85rem; text-transform: uppercase; margin-bottom: 0.5rem; }}
        .stat-card .value {{ font-size: 2rem; font-weight: 700; }}
        .stat-card .value.success {{ color: #4ade80; }}
        .stat-card .value.error {{ color: #f87171; }}
        .stat-card .value.warning {{ color: #fbbf24; }}
        .stat-card .value.neutral {{ color: #60a5fa; }}

        .status-banner {{
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            font-weight: 600;
            font-size: 1.1rem;
        }}
        .status-banner.success {{ background: rgba(74, 222, 128, 0.15); border: 1px solid #4ade80; color: #4ade80; }}
        .status-banner.error {{ background: rgba(248, 113, 113, 0.15); border: 1px solid #f87171; color: #f87171; }}

        .section {{ margin-bottom: 2rem; }}
        .section h2 {{
            font-size: 1.25rem;
            margin-bottom: 1rem;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }}
        .section h2::before {{
            content: '';
            width: 4px;
            height: 1.25rem;
            background: #60a5fa;
            border-radius: 2px;
        }}

        .file-card {{
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 12px;
            margin-bottom: 0.5rem;
            overflow: hidden;
        }}
        .file-header {{
            background: rgba(248, 113, 113, 0.1);
            padding: 0.75rem 1.25rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            user-select: none;
            transition: background 0.2s;
        }}
        .file-header:hover {{ background: rgba(248, 113, 113, 0.2); }}
        .file-header h3 {{ color: #f87171; font-size: 0.95rem; display: flex; align-items: center; gap: 0.5rem; }}
        .file-header h3::before {{
            content: '▶';
            font-size: 0.7rem;
            transition: transform 0.2s;
        }}
        .file-card.expanded .file-header h3::before {{ transform: rotate(90deg); }}
        .file-content {{
            display: none;
            border-top: 1px solid rgba(255,255,255,0.08);
        }}
        .file-card.expanded .file-content {{ display: block; }}
        .error-count {{
            background: #f87171;
            color: #1a1a2e;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }}
        .controls {{
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }}
        .control-btn {{
            padding: 0.5rem 1rem;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 6px;
            color: #e4e4e4;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.2s;
        }}
        .control-btn:hover {{ background: rgba(255,255,255,0.2); }}

        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        th, td {{
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }}
        th {{
            background: rgba(255,255,255,0.03);
            color: #888;
            font-size: 0.75rem;
            text-transform: uppercase;
            font-weight: 600;
        }}
        td {{ font-size: 0.9rem; }}
        tr:hover {{ background: rgba(255,255,255,0.02); }}
        .issue-text {{ color: #fbbf24; }}

        .missing-list {{
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }}
        .missing-item {{
            background: rgba(251, 191, 36, 0.15);
            border: 1px solid #fbbf24;
            color: #fbbf24;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-size: 0.85rem;
        }}

        .empty-state {{
            text-align: center;
            padding: 3rem;
            color: #888;
        }}
        .empty-state .icon {{ font-size: 3rem; margin-bottom: 1rem; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>📋 Tafsir Schema Validation Report</h1>
        <p class="timestamp">Generated: {timestamp}</p>

        <div class="status-banner {status_class}">
            {("✅ " if is_all_valid else "❌ ")}{status_text}
        </div>

        <div class="summary">
            <div class="stat-card">
                <h3>Files Checked</h3>
                <div class="value neutral">{total_files}/114</div>
            </div>
            <div class="stat-card">
                <h3>Valid Files</h3>
                <div class="value success">{valid_files}</div>
            </div>
            <div class="stat-card">
                <h3>Invalid Files</h3>
                <div class="value {"error" if invalid_files > 0 else "success"}">{invalid_files}</div>
            </div>
            <div class="stat-card">
                <h3>Missing Files</h3>
                <div class="value {"warning" if len(missing_files) > 0 else "success"}">{len(missing_files)}</div>
            </div>
        </div>
"""

    if missing_files:
        html += """
        <div class="section">
            <h2>Missing Files</h2>
            <div class="missing-list">
"""
        for f in missing_files:
            html += f'                <span class="missing-item">{f}</span>\n'
        html += """            </div>
        </div>
"""

    if files_with_errors:
        html += """
        <div class="section">
            <h2>Files with Schema Violations</h2>
            <div class="controls">
                <button class="control-btn" onclick="expandAll()">Expand All</button>
                <button class="control-btn" onclick="collapseAll()">Collapse All</button>
            </div>
"""
        for filename, errors in sorted(files_with_errors.items(), key=lambda x: int(x[0].split('_')[1].split('.')[0])):
            html += f"""
            <div class="file-card" onclick="this.classList.toggle('expanded')">
                <div class="file-header">
                    <h3>{filename}</h3>
                    <span class="error-count">{len(errors)} issue{"s" if len(errors) != 1 else ""}</span>
                </div>
                <div class="file-content" onclick="event.stopPropagation()">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 80px;">Verse</th>
                                <th style="width: 80px;">Concept</th>
                                <th>Issue</th>
                            </tr>
                        </thead>
                        <tbody>
"""
            for error in errors:
                html += f"""                            <tr>
                                <td>{error["verse"]}</td>
                                <td>{error["concept"]}</td>
                                <td class="issue-text">{error["issue"]}</td>
                            </tr>
"""
            html += """                        </tbody>
                    </table>
                </div>
            </div>
"""
        html += """        </div>
"""
    else:
        html += """
        <div class="section">
            <div class="empty-state">
                <div class="icon">🎉</div>
                <p>No schema violations found!</p>
            </div>
        </div>
"""

    html += """
        <script>
            function expandAll() {
                document.querySelectorAll('.file-card').forEach(card => card.classList.add('expanded'));
            }
            function collapseAll() {
                document.querySelectorAll('.file-card').forEach(card => card.classList.remove('expanded'));
            }
        </script>
    </div>
</body>
</html>
"""
    return html


def main():
    print("Validating tafsir files...")

    total_files = 0
    valid_files = 0
    invalid_files = 0
    files_with_errors: Dict[str, List[Dict]] = {}
    missing_files = []

    for surah_num in range(1, 115):
        filename = f"tafsir_{surah_num}.json"
        filepath = DATA_DIR / filename

        if not filepath.exists():
            missing_files.append(filename)
            continue

        total_files += 1
        verse_count, is_valid, errors = validate_file(filepath)

        if is_valid:
            valid_files += 1
        else:
            invalid_files += 1
            files_with_errors[filename] = errors

    results = {
        "total_files": total_files,
        "valid_files": valid_files,
        "invalid_files": invalid_files,
        "missing_files": missing_files,
        "files_with_errors": files_with_errors,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

    html_report = generate_html_report(results)
    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write(html_report)

    print(f"Report generated: {REPORT_FILE}")
    print(f"Files checked: {total_files}/114")
    print(f"Valid: {valid_files}, Invalid: {invalid_files}, Missing: {len(missing_files)}")

    return 0 if (invalid_files == 0 and not missing_files) else 1


if __name__ == "__main__":
    exit(main())
