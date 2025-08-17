#!/usr/bin/env python3
"""
HTML Generator for Tafsir JSON Files
Creates a readable HTML page with English and Urdu tafsir side-by-side
"""

import json
import sys
from pathlib import Path

def generate_html(json_file_path):
    """Generate HTML file from tafsir JSON"""
    
    # Load the JSON file
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: File {json_file_path} not found")
        return False
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {json_file_path}")
        return False
    
    # Extract surah number from filename
    file_name = Path(json_file_path).stem
    surah_number = file_name.replace('tafsir_', '')
    
    # Get verses (top-level keys that are digits)
    verses = {k: v for k, v in data.items() if k.isdigit()}
    
    if not verses:
        print("No verses found in the file")
        return False
    
    # Generate HTML content
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tafsir - Surah {surah_number}</title>
    <style>
        body {{
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }}
        
        h1 {{
            text-align: center;
            color: #2c3e50;
            margin-bottom: 30px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }}
        
        .verse-container {{
            margin-bottom: 40px;
            border: 2px solid #e3f2fd;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }}
        
        .verse-header {{
            background: linear-gradient(45deg, #4a90e2, #357abd);
            color: white;
            padding: 15px;
            font-size: 1.3em;
            font-weight: bold;
            text-align: center;
        }}
        
        .layer-container {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
        }}
        
        .layer-section {{
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
        }}
        
        .layer-section:nth-child(even) {{
            background-color: #f8f9fa;
        }}
        
        .layer-title {{
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
            padding: 8px 12px;
            border-radius: 5px;
            font-size: 1.1em;
        }}
        
        .layer1 {{ background: linear-gradient(45deg, #e8f5e8, #c8e6c9); }}
        .layer2 {{ background: linear-gradient(45deg, #fff3e0, #ffcc80); }}
        .layer3 {{ background: linear-gradient(45deg, #e3f2fd, #90caf9); }}
        .layer4 {{ background: linear-gradient(45deg, #f3e5f5, #ce93d8); }}
        
        .english-text {{
            margin-bottom: 15px;
            text-align: left;
            line-height: 1.7;
            color: #2c3e50;
        }}
        
        .urdu-text {{
            direction: rtl;
            text-align: right;
            font-family: 'Noto Nastaliq Urdu', 'Arial Unicode MS', sans-serif;
            font-size: 1.1em;
            line-height: 1.8;
            color: #1a237e;
            border-right: 3px solid #4a90e2;
            padding-right: 15px;
        }}
        
        .layer-icons {{
            display: inline-block;
            margin-right: 8px;
        }}
        
        @media (max-width: 768px) {{
            .layer-container {{
                grid-template-columns: 1fr;
            }}
            
            .container {{
                padding: 15px;
            }}
            
            h1 {{
                font-size: 2em;
            }}
        }}
        
        @import url('https://fonts.googleapis.com/css2?family=Noto+Nastaliq+Urdu:wght@400;700&display=swap');
    </style>
</head>
<body>
    <div class="container">
        <h1>📖 Tafsir - Surah {surah_number}</h1>
        
"""
    
    # Add each verse
    for verse_num in sorted(verses.keys(), key=int):
        verse_data = verses[verse_num]
        html_content += f"""
        <div class="verse-container">
            <div class="verse-header">
                🌟 Verse {verse_num}
            </div>
"""
        
        # Add each layer
        layers = [
            ('layer1', '🏛️ Foundation Layer', 'layer1'),
            ('layer2', '📚 Classical Shia Layer', 'layer2'),
            ('layer3', '🌍 Contemporary Layer', 'layer3'),
            ('layer4', '⭐ Ahlul Bayt Layer', 'layer4')
        ]
        
        for layer_key, layer_title, layer_class in layers:
            if layer_key in verse_data:
                english_text = verse_data[layer_key]
                urdu_key = f"{layer_key}_urdu"
                urdu_text = verse_data.get(urdu_key, "Urdu translation not available")
                
                html_content += f"""
            <div class="layer-container">
                <div class="layer-section">
                    <div class="layer-title {layer_class}">
                        <span class="layer-icons">{layer_title.split()[0]}</span>
                        {layer_title}
                    </div>
                    <div class="english-text">{english_text}</div>
                </div>
                <div class="layer-section">
                    <div class="layer-title {layer_class}">
                        <span class="layer-icons">🌙</span>
                        {layer_title} - اردو
                    </div>
                    <div class="urdu-text">{urdu_text}</div>
                </div>
            </div>
"""
        
        html_content += "        </div>\n"
    
    # Close HTML
    html_content += """
    </div>
</body>
</html>"""
    
    # Save HTML file
    output_file = json_file_path.replace('.json', '.html')
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html_content)
        print(f"✅ HTML file generated: {output_file}")
        return True
    except Exception as e:
        print(f"Error saving HTML file: {e}")
        return False

def main():
    """Main function"""
    if len(sys.argv) != 2:
        print("Usage: python generate_tafsir_html.py <tafsir_file.json>")
        print("Example: python generate_tafsir_html.py tafsir_1.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    
    if not Path(json_file).exists():
        print(f"Error: File {json_file} does not exist")
        sys.exit(1)
    
    if not json_file.endswith('.json'):
        print("Error: File must be a JSON file")
        sys.exit(1)
    
    print("Generating HTML file...")
    success = generate_html(json_file)
    
    if success:
        print("🎉 HTML generation completed successfully!")
    else:
        print("❌ HTML generation failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()