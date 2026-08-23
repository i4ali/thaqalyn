#!/usr/bin/env python3
"""Assemble special_duas.json (Duas & Ziyarat) from the raw duas.org extractions."""
import json, os, re, unicodedata

S = os.path.dirname(os.path.abspath(__file__))

def load(f):
    d = json.loads(open(os.path.join(S, f)).read())
    return json.loads(d) if isinstance(d, str) else d

# ---- transliteration -> house style (plain english, no diacritics) ----
MACRON = {'ā':'a','ī':'i','ū':'u','Ā':'A','Ī':'I','Ū':'U','ē':'e','ō':'o'}
UNDERDOT = {'ḥ':'h','ṣ':'s','ḍ':'d','ṭ':'t','ẓ':'z','Ḥ':'H','Ṣ':'S','Ḍ':'D','Ṭ':'T','Ẓ':'Z','ṛ':'r','ḷ':'l','ṃ':'m','ṇ':'n'}
def house_translit(s):
    if not s: return s
    s = unicodedata.normalize('NFC', s)
    for k,v in MACRON.items(): s = s.replace(k,v)
    for k,v in UNDERDOT.items(): s = s.replace(k,v)
    # ayn/hamza half-rings -> apostrophe between letters else drop
    for ch in ['ʿ','ʾ','`','ʼ','ʻ']:
        s = re.sub(r'(?<=[A-Za-z])'+re.escape(ch)+r'(?=[A-Za-z])', "'", s)
        s = s.replace(ch, '')
    s = re.sub(r'\s+', ' ', s).strip()
    # capitalize first alpha
    for i,c in enumerate(s):
        if c.isalpha():
            s = s[:i] + c.upper() + s[i+1:]
            break
    return s

BISMILLAH_AR = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
def fill_bismillah(seg):
    if 'بِسْمِ' in seg.get('ar','') and (not seg.get('tr') or not seg.get('en')):
        seg['tr'] = seg.get('tr') or "Bismillahir rahmanir rahim"
        seg['en'] = seg.get('en') or "In the Name of Allah, the All-Merciful, the All-Compassionate"
    return seg

def clean_segments(segs):
    out = []
    for s in segs:
        ar = (s.get('ar') or '').strip()
        if not ar: continue
        seg = {'ar': ar, 'tr': house_translit(s.get('tr') or ''), 'en': (s.get('en') or '').strip()}
        fill_bismillah(seg)
        out.append(seg)
    return out

# ---- load raw ----
raw = {
    'kumayl':   load('dua_kumayl.json'),
    'ashura':   load('ziyarat_ashura.json'),
    'tawassul': load('tawassul_duasorg.json'),
    'nudba':    load('dua_nudba.json'),
    'ahad':     load('dua_ahad.json'),
    'faraj':    load('dua_faraj.json'),
}

seg = {k: clean_segments(v['segments']) for k,v in raw.items()}

# ---- Faraj: keep only the short dua (drop leading blank, keep through 'ya arham...for the sake of Muhammad') ----
# raw faraj segments 1..16 are the canonical short dua; clean_segments dropped blanks so recompute from raw
faraj_raw = raw['faraj']['segments']
faraj_short = clean_segments(faraj_raw[1:17])   # segs 1..16 inclusive
seg['faraj'] = faraj_short

# ---- Ashura: the raw scrape opens with the basmala twice (segs 0 and 1, two
# Unicode spellings of the same line). Keep seg 0 (proper Quranic orthography,
# house tr/en filled by fill_bismillah) and drop the duplicate.
a = seg['ashura']
if len(a) > 1 and 'بِسْمِ' in a[0]['ar'] and 'بِسْمِ' in a[1]['ar']:
    del a[1]

# ---- Ashura: insert inline notes at the mapped positions (highest index first) ----
ashura_notes = [
    (106, "Repeat the following La'n (invocation against the oppressors) one hundred times, or once:"),
    (112, "Repeat the following Salam one hundred times, or once:"),
    (121, "Then say:"),
    (129, "Then prostrate and say:"),
]
for idx, text in sorted(ashura_notes, key=lambda x: -x[0]):
    if 0 <= idx <= len(a):
        a.insert(idx, {'note': text})
seg['ashura'] = a

# ---- metadata per dua ----
META = {
 'kumayl': dict(
    titleEn="Dua Kumayl", titleAr="دُعَاءُ كُمَيْل", titleUr="دعائے کمیل",
    whenEn="Thursday nights",
    attributionEn="Imam Ali (as) - taught to Kumayl ibn Ziyad",
    purposeEn="Forgiveness of sins",
    introEn="Taught by Imam Ali (as) to his companion Kumayl ibn Ziyad and recited on Thursday nights, this is among the most beloved supplications in Shia devotion - an outpouring for mercy and the forgiveness of sins.",
    audioUrl="https://mp3.duas.org/kumayl.mp3", reciterEn=None),
 'ashura': dict(
    titleEn="Ziyarat Ashura", titleAr="زِيَارَةُ عَاشُورَاء", titleUr="زیارتِ عاشورا",
    whenEn="Daily, and on the Day of Ashura",
    attributionEn="Imam Hussain (as) - narrated from Imam al-Baqir (as)",
    purposeEn="Renewing one's stand with Karbala; removing calamities",
    introEn="The ziyarat of Imam Hussain (as), greeting the martyrs of Karbala and renewing one's allegiance to them. It is recited especially on the Day of Ashura and throughout the year.",
    audioUrl="https://mp3.duas.org/ziyarat-ashura-imam-hussain.mp3", reciterEn=None),
 'tawassul': dict(
    titleEn="Dua Tawassul", titleAr="دُعَاءُ التَّوَسُّل", titleUr="دعائے توسل",
    whenEn="Tuesday nights",
    attributionEn="Imam Hasan al-Askari (as)",
    purposeEn="Seeking nearness to Allah through the Ahl al-Bayt (as)",
    introEn="A supplication of seeking nearness to Allah through the fourteen Infallibles, from the Holy Prophet (S) to the Imam of our time (atfs), calling on them to intercede. It is often recited on Tuesday nights.",
    audioUrl="https://mp3.duas.org/Misc%20Duas/2_Tawassul.mp3", reciterEn=None),
 'nudba': dict(
    titleEn="Dua Nudba", titleAr="دُعَاءُ النُّدْبَة", titleUr="دعائے ندبہ",
    whenEn="Friday mornings and the four Eids",
    attributionEn="Narrated from Imam al-Sadiq (as)",
    purposeEn="Longing for the reappearance of Imam al-Mahdi (atfs)",
    introEn="A lament for the awaited Imam al-Mahdi (atfs), recited on Friday mornings and the four Eids, voicing the believer's longing for the promised reappearance.",
    audioUrl="https://mp3.duas.org/Nudba_AbdulHayyQambar.mp3", reciterEn="Abdul Hayy Qambar"),
 'ahad': dict(
    titleEn="Dua al-Ahd", titleAr="دُعَاءُ الْعَهْد", titleUr="دعائے عہد",
    whenEn="Every morning after Fajr",
    attributionEn="Imam al-Sadiq (as)",
    purposeEn="A pledge of allegiance to Imam al-Mahdi (atfs)",
    introEn="A morning pledge of allegiance to Imam al-Mahdi (atfs). It is narrated that whoever recites it for forty mornings is counted among the helpers of the awaited Imam.",
    audioUrl="https://mp3.duas.org/dua_ahad_ali_fani.mp3", reciterEn="Ali Fani"),
 'faraj': dict(
    titleEn="Dua al-Faraj", titleAr="دُعَاءُ الْفَرَج", titleUr="دعائے فرج",
    whenEn="Anytime of hardship",
    attributionEn="Narrated for the time of occultation",
    purposeEn="Relief from hardship and hastening the reappearance",
    introEn="A short, urgent plea for relief in times of hardship, calling upon the Prophet, Imam Ali (as), and the Patron of the Age (atfs) - 'Ilahi azuma al-bala' (My Lord, the affliction has grown great).",
    audioUrl=None, reciterEn=None),
}

# Faraj deferred: duas.org has no clean standalone recitation (only bundled in a namaz).
# Its data is assembled above and ready to re-add when we source a good stream.
ORDER = ['kumayl','ashura','tawassul','nudba','ahad']
duas = []
for k in ORDER:
    m = META[k]
    duas.append({
        'id': k,
        'titleEn': m['titleEn'], 'titleAr': m['titleAr'], 'titleUr': m['titleUr'],
        'whenEn': m['whenEn'], 'attributionEn': m['attributionEn'], 'purposeEn': m['purposeEn'],
        'introEn': m['introEn'],
        'audioUrl': m['audioUrl'], 'reciterEn': m['reciterEn'],
        'sourceCreditEn': "Text and recitation courtesy of Duas.org",
        'segments': seg[k],
    })

out = {'duas': duas}
outpath = os.path.join(S, 'special_duas.json')
with open(outpath, 'w') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)

# ---- verification ----
print("WROTE", outpath)
for d in duas:
    segs = d['segments']
    notes = [s for s in segs if 'note' in s]
    body = [s for s in segs if 'ar' in s]
    print(f"\n{d['id']:9s} title='{d['titleEn']}' when='{d['whenEn']}' audio={'yes' if d['audioUrl'] else 'NO(TTS)'}")
    print(f"   segments={len(segs)} (body={len(body)}, notes={len(notes)})")
    print(f"   first: AR={body[0]['ar'][:30]} | TR={body[0]['tr'][:34]} | EN={body[0]['en'][:34]}")
    print(f"   last:  AR={body[-1]['ar'][:30]} | EN={body[-1]['en'][:40]}")
    if notes:
        for i,s in enumerate(segs):
            if 'note' in s: print(f"     note@{i}: {s['note'][:60]}")
