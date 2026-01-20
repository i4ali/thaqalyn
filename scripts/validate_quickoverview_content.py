#!/usr/bin/env python3
"""
Validate QuickOverview Content Quality

This script validates QuickOverview concepts in tafsir files, ensuring:
1. No required field is empty
2. Arabic fields (_ar) contain actual Arabic text
3. Urdu fields (_urdu) contain actual Urdu/Arabic script text

Generates an HTML report for easy viewing.
"""

import json
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple

DATA_DIR = Path("Thaqalayn/Thaqalayn/Data")
REPORT_FILE = "quickoverview_content_report.html"

# Required fields in each concept
REQUIRED_FIELDS = [
    "id", "title", "title_ar", "title_urdu",
    "icon", "colorHex", "position",
    "coreInsight", "coreInsight_ar", "coreInsight_urdu",
    "whyItMatters", "whyItMatters_ar", "whyItMatters_urdu",
    "arabicHighlight"
]

# Fields that must contain Arabic script
ARABIC_FIELDS = ["title_ar", "coreInsight_ar", "whyItMatters_ar", "arabicHighlight"]

# Fields that must contain Urdu (Arabic script)
URDU_FIELDS = ["title_urdu", "coreInsight_urdu", "whyItMatters_urdu"]


def contains_arabic(text: str, min_ratio: float = 0.1) -> bool:
    """Check if text contains Arabic characters."""
    if not text or not text.strip():
        return False

    arabic_pattern = re.compile(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]')
    arabic_chars = arabic_pattern.findall(text)

    total_chars = len(text.replace(" ", "").replace("\n", ""))
    if total_chars == 0:
        return False

    ratio = len(arabic_chars) / total_chars
    return ratio >= min_ratio


def contains_urdu(text: str, min_ratio: float = 0.1) -> bool:
    """Check if text contains Urdu characters (uses Arabic script)."""
    return contains_arabic(text, min_ratio)


def is_empty(value) -> bool:
    """Check if a value is empty or None."""
    if value is None:
        return True
    if isinstance(value, str):
        return len(value.strip()) == 0
    return False


def validate_concept(concept: Dict, surah: int, verse: str, concept_idx: int) -> List[Dict]:
    """Validate a single concept's content quality."""
    errors = []
    concept_id = concept.get("id", f"concept_{concept_idx}")

    # Check for empty fields
    for field in REQUIRED_FIELDS:
        if field not in concept:
            errors.append({
                "surah": surah,
                "verse": verse,
                "concept": concept_id,
                "field": field,
                "issue": "Missing field",
                "type": "missing"
            })
        elif is_empty(concept[field]):
            errors.append({
                "surah": surah,
                "verse": verse,
                "concept": concept_id,
                "field": field,
                "issue": "Empty value",
                "type": "empty"
            })

    # Check Arabic fields contain Arabic text
    for field in ARABIC_FIELDS:
        if field in concept and not is_empty(concept[field]):
            if not contains_arabic(concept[field]):
                preview = concept[field][:60] + "..." if len(concept[field]) > 60 else concept[field]
                errors.append({
                    "surah": surah,
                    "verse": verse,
                    "concept": concept_id,
                    "field": field,
                    "issue": f"No Arabic text found",
                    "preview": preview,
                    "type": "wrong_language"
                })

    # Check Urdu fields contain Urdu/Arabic script
    for field in URDU_FIELDS:
        if field in concept and not is_empty(concept[field]):
            if not contains_urdu(concept[field]):
                preview = concept[field][:60] + "..." if len(concept[field]) > 60 else concept[field]
                errors.append({
                    "surah": surah,
                    "verse": verse,
                    "concept": concept_id,
                    "field": field,
                    "issue": f"No Urdu text found",
                    "preview": preview,
                    "type": "wrong_language"
                })

    return errors


def validate_file(filepath: Path, surah_num: int) -> Tuple[int, int, List[Dict]]:
    """Validate a single tafsir file's quickOverview content."""
    errors = []
    concepts_checked = 0
    concepts_with_errors = 0

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        return 0, 0, [{"surah": surah_num, "verse": "-", "concept": "-", "field": "-", "issue": f"File error: {e}", "type": "file_error"}]

    for verse_key, verse_data in data.items():
        if not isinstance(verse_data, dict):
            continue

        quick_overview = verse_data.get("quickOverview")
        if not quick_overview:
            continue

        concepts = quick_overview.get("concepts", [])
        if not isinstance(concepts, list):
            continue

        for idx, concept in enumerate(concepts):
            concepts_checked += 1
            concept_errors = validate_concept(concept, surah_num, verse_key, idx)
            if concept_errors:
                concepts_with_errors += 1
                errors.extend(concept_errors)

    return concepts_checked, concepts_with_errors, errors


def generate_html_report(results: Dict) -> str:
    """Generate an HTML report from validation results."""

    total_files = results["total_files_with_qo"]
    total_concepts = results["total_concepts"]
    concepts_with_errors = results["concepts_with_errors"]
    all_errors = results["all_errors"]
    timestamp = results["timestamp"]

    # Group errors by type
    missing_errors = [e for e in sum(all_errors.values(), []) if e["type"] == "missing"]
    empty_errors = [e for e in sum(all_errors.values(), []) if e["type"] == "empty"]
    language_errors = [e for e in sum(all_errors.values(), []) if e["type"] == "wrong_language"]

    is_all_valid = concepts_with_errors == 0
    status_class = "success" if is_all_valid else "error"
    status_text = "ALL CONTENT VALID" if is_all_valid else f"{concepts_with_errors} concepts with issues"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QuickOverview Content Validation Report</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e4e4e4;
            min-height: 100vh;
            padding: 2rem;
        }}
        .container {{ max-width: 1400px; margin: 0 auto; }}
        h1 {{
            font-size: 2rem;
            margin-bottom: 0.5rem;
            color: #fff;
        }}
        .timestamp {{ color: #888; margin-bottom: 2rem; font-size: 0.9rem; }}

        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }}
        .stat-card {{
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 1.25rem;
            border: 1px solid rgba(255,255,255,0.1);
        }}
        .stat-card h3 {{ color: #888; font-size: 0.8rem; text-transform: uppercase; margin-bottom: 0.5rem; }}
        .stat-card .value {{ font-size: 1.75rem; font-weight: 700; }}
        .stat-card .value.success {{ color: #4ade80; }}
        .stat-card .value.error {{ color: #f87171; }}
        .stat-card .value.warning {{ color: #fbbf24; }}
        .stat-card .value.neutral {{ color: #60a5fa; }}
        .stat-card .value.purple {{ color: #a78bfa; }}

        .status-banner {{
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            font-weight: 600;
            font-size: 1.1rem;
        }}
        .status-banner.success {{ background: rgba(74, 222, 128, 0.15); border: 1px solid #4ade80; color: #4ade80; }}
        .status-banner.error {{ background: rgba(248, 113, 113, 0.15); border: 1px solid #f87171; color: #f87171; }}

        .tabs {{
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }}
        .tab {{
            padding: 0.75rem 1.25rem;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 0.9rem;
        }}
        .tab:hover {{ background: rgba(255,255,255,0.1); }}
        .tab.active {{ background: #60a5fa; color: #1a1a2e; border-color: #60a5fa; }}
        .tab .count {{
            background: rgba(0,0,0,0.2);
            padding: 0.15rem 0.5rem;
            border-radius: 10px;
            margin-left: 0.5rem;
            font-size: 0.8rem;
        }}

        .tab-content {{ display: none; }}
        .tab-content.active {{ display: block; }}

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
        td {{ font-size: 0.85rem; }}
        tr:hover {{ background: rgba(255,255,255,0.02); }}

        .issue-missing {{ color: #f87171; }}
        .issue-empty {{ color: #fbbf24; }}
        .issue-language {{ color: #a78bfa; }}

        .preview {{
            font-size: 0.8rem;
            color: #888;
            max-width: 300px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }}

        .badge {{
            display: inline-block;
            padding: 0.2rem 0.6rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
        }}
        .badge-missing {{ background: rgba(248, 113, 113, 0.2); color: #f87171; }}
        .badge-empty {{ background: rgba(251, 191, 36, 0.2); color: #fbbf24; }}
        .badge-language {{ background: rgba(167, 139, 250, 0.2); color: #a78bfa; }}

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
        <h1>🔍 QuickOverview Content Validation Report</h1>
        <p class="timestamp">Generated: {timestamp}</p>

        <div class="status-banner {status_class}">
            {("✅ " if is_all_valid else "❌ ")}{status_text}
        </div>

        <div class="summary">
            <div class="stat-card">
                <h3>Files with QO</h3>
                <div class="value neutral">{total_files}</div>
            </div>
            <div class="stat-card">
                <h3>Concepts Checked</h3>
                <div class="value neutral">{total_concepts}</div>
            </div>
            <div class="stat-card">
                <h3>Concepts with Issues</h3>
                <div class="value {"error" if concepts_with_errors > 0 else "success"}">{concepts_with_errors}</div>
            </div>
            <div class="stat-card">
                <h3>Missing Fields</h3>
                <div class="value {"error" if len(missing_errors) > 0 else "success"}">{len(missing_errors)}</div>
            </div>
            <div class="stat-card">
                <h3>Empty Fields</h3>
                <div class="value {"warning" if len(empty_errors) > 0 else "success"}">{len(empty_errors)}</div>
            </div>
            <div class="stat-card">
                <h3>Wrong Language</h3>
                <div class="value {"purple" if len(language_errors) > 0 else "success"}">{len(language_errors)}</div>
            </div>
        </div>
"""

    if all_errors:
        html += """
        <div class="tabs">
            <div class="tab active" onclick="showTab('all')">All Issues<span class="count">""" + str(sum(len(e) for e in all_errors.values())) + """</span></div>
            <div class="tab" onclick="showTab('missing')">Missing<span class="count">""" + str(len(missing_errors)) + """</span></div>
            <div class="tab" onclick="showTab('empty')">Empty<span class="count">""" + str(len(empty_errors)) + """</span></div>
            <div class="tab" onclick="showTab('language')">Wrong Language<span class="count">""" + str(len(language_errors)) + """</span></div>
        </div>

        <div id="tab-all" class="tab-content active">
            <div class="section">
                <h2>All Issues by File</h2>
                <div class="controls">
                    <button class="control-btn" onclick="expandAll()">Expand All</button>
                    <button class="control-btn" onclick="collapseAll()">Collapse All</button>
                </div>
"""
        for filename, errors in sorted(all_errors.items(), key=lambda x: int(x[0].split('_')[1].split('.')[0])):
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
                                    <th>Verse</th>
                                    <th>Concept</th>
                                    <th>Field</th>
                                    <th>Issue</th>
                                    <th>Preview</th>
                                </tr>
                            </thead>
                            <tbody>
"""
            for error in errors:
                badge_class = f"badge-{error['type'].replace('wrong_', '')}"
                issue_class = f"issue-{error['type'].replace('wrong_', '')}"
                preview = error.get("preview", "-")
                html += f"""                                <tr>
                                    <td>{error["verse"]}</td>
                                    <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;">{error["concept"]}</td>
                                    <td><span class="badge {badge_class}">{error["field"]}</span></td>
                                    <td class="{issue_class}">{error["issue"]}</td>
                                    <td class="preview">{preview}</td>
                                </tr>
"""
            html += """                            </tbody>
                        </table>
                    </div>
                </div>
"""
        html += """            </div>
        </div>
"""

        # Missing fields tab
        html += """
        <div id="tab-missing" class="tab-content">
            <div class="section">
                <h2>Missing Fields</h2>
"""
        if missing_errors:
            html += """                <table>
                    <thead>
                        <tr><th>Surah</th><th>Verse</th><th>Concept</th><th>Field</th></tr>
                    </thead>
                    <tbody>
"""
            for e in missing_errors:
                html += f"""                        <tr><td>{e["surah"]}</td><td>{e["verse"]}</td><td>{e["concept"]}</td><td class="issue-missing">{e["field"]}</td></tr>
"""
            html += """                    </tbody>
                </table>
"""
        else:
            html += """                <div class="empty-state"><div class="icon">✅</div><p>No missing fields!</p></div>
"""
        html += """            </div>
        </div>
"""

        # Empty fields tab
        html += """
        <div id="tab-empty" class="tab-content">
            <div class="section">
                <h2>Empty Fields</h2>
"""
        if empty_errors:
            html += """                <table>
                    <thead>
                        <tr><th>Surah</th><th>Verse</th><th>Concept</th><th>Field</th></tr>
                    </thead>
                    <tbody>
"""
            for e in empty_errors:
                html += f"""                        <tr><td>{e["surah"]}</td><td>{e["verse"]}</td><td>{e["concept"]}</td><td class="issue-empty">{e["field"]}</td></tr>
"""
            html += """                    </tbody>
                </table>
"""
        else:
            html += """                <div class="empty-state"><div class="icon">✅</div><p>No empty fields!</p></div>
"""
        html += """            </div>
        </div>
"""

        # Wrong language tab
        html += """
        <div id="tab-language" class="tab-content">
            <div class="section">
                <h2>Wrong Language Content</h2>
"""
        if language_errors:
            html += """                <table>
                    <thead>
                        <tr><th>Surah</th><th>Verse</th><th>Concept</th><th>Field</th><th>Preview</th></tr>
                    </thead>
                    <tbody>
"""
            for e in language_errors:
                html += f"""                        <tr><td>{e["surah"]}</td><td>{e["verse"]}</td><td>{e["concept"]}</td><td class="issue-language">{e["field"]}</td><td class="preview">{e.get("preview", "-")}</td></tr>
"""
            html += """                    </tbody>
                </table>
"""
        else:
            html += """                <div class="empty-state"><div class="icon">✅</div><p>All language content is correct!</p></div>
"""
        html += """            </div>
        </div>
"""
    else:
        html += """
        <div class="section">
            <div class="empty-state">
                <div class="icon">🎉</div>
                <p>All QuickOverview content is valid!</p>
            </div>
        </div>
"""

    html += """
        <script>
            function showTab(tabName) {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                document.querySelector(`.tab[onclick="showTab('${tabName}')"]`).classList.add('active');
                document.getElementById('tab-' + tabName).classList.add('active');
            }
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
    print("Validating QuickOverview content...")

    total_files_with_qo = 0
    total_concepts = 0
    total_concepts_with_errors = 0
    all_errors: Dict[str, List[Dict]] = {}

    for surah_num in range(1, 115):
        filename = f"tafsir_{surah_num}.json"
        filepath = DATA_DIR / filename

        if not filepath.exists():
            continue

        concepts_checked, concepts_with_errors, errors = validate_file(filepath, surah_num)

        if concepts_checked > 0:
            total_files_with_qo += 1
            total_concepts += concepts_checked
            total_concepts_with_errors += concepts_with_errors

            if errors:
                all_errors[filename] = errors

    results = {
        "total_files_with_qo": total_files_with_qo,
        "total_concepts": total_concepts,
        "concepts_with_errors": total_concepts_with_errors,
        "all_errors": all_errors,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

    html_report = generate_html_report(results)
    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write(html_report)

    print(f"Report generated: {REPORT_FILE}")
    print(f"Files with QuickOverview: {total_files_with_qo}")
    print(f"Concepts checked: {total_concepts}")
    print(f"Concepts with issues: {total_concepts_with_errors}")

    return 0 if total_concepts_with_errors == 0 else 1


if __name__ == "__main__":
    exit(main())
