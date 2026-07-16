import { useState, useEffect, useRef } from 'react';

// ————————————————————————————————————————————————
//  THE DESCENT — Topic: Yaqīn (certainty)
//  Three movements, each a depth of certainty (ʿIlm → ʿAyn → Ḥaqq),
//  closing on a dua for yaqīn from Imam Zayn al-ʿĀbidīn — Ḥusayn's
//  son, who survived Karbalā. The tradition hands you the words.
// ————————————————————————————————————————————————

const GOLD = '#c9a55c';
const GOLD_BRIGHT = '#e3c37e';
const CREAM = '#ece7db';
const MUTE = '#8f9a8c';
const FAINT = '#5c665d';

const FONT_AR = "'Amiri', 'Scheherazade New', serif";
const FONT_DISPLAY = "'Cormorant Garamond', Georgia, serif";
const FONT_UI = "'Inter', system-ui, -apple-system, sans-serif";

const DUA_AR = 'وَبَلِّغْ بِإِيمَانِي أَكْمَلَ الْإِيمَانِ، وَاجْعَلْ يَقِينِي أَفْضَلَ الْيَقِينِ';
const DUA_TR = '“Bring my faith to the most perfect faith, and make my certainty the most excellent certainty.”';

const ACTS = {
  1: { ar: 'عِلْمُ الْيَقِين', tr: '‘Ilm al-Yaqīn', name: 'The Knowing' },
  2: { ar: 'عَيْنُ الْيَقِين', tr: '‘Ayn al-Yaqīn', name: 'The Witnessing' },
  3: { ar: 'حَقُّ الْيَقِين', tr: 'Ḥaqq al-Yaqīn', name: 'The Living' },
};
const ROMAN = ['', 'I', 'II', 'III'];

const depths = [
  { ar: 'عِلْمُ الْيَقِين', tr: '‘Ilm al-Yaqīn', label: 'Knowledge of Certainty', desc: 'To know the fire exists — by the smoke on the horizon.', embod: 'where we begin' },
  { ar: 'عَيْنُ الْيَقِين', tr: '‘Ayn al-Yaqīn', label: 'Eye of Certainty', desc: 'To see the fire with your own eyes.', ref: '102:7', embod: 'the prophets who saw' },
  { ar: 'حَقُّ الْيَقِين', tr: 'Ḥaqq al-Yaqīn', label: 'Truth of Certainty', desc: 'To stand within the flame itself.', ref: '56:95', embod: 'the family who lived it' },
];

const sections = [
  {
    type: 'open', kicker: 'A MAJLIS', arabicTitle: 'يَقِين', title: 'Yaqīn',
    subtitle: 'Certainty', line: 'A descent through the Qur’an and the Ahl al-Bayt — in three depths.',
  },

  // ——— MOVEMENT I · The Knowing ———
  {
    type: 'verse', act: 1, tag: 'The Question',
    arabic: 'كَلَّا لَوْ تَعْلَمُونَ عِلْمَ الْيَقِينِ',
    ref: 'al-Takāthur · 102 : 5',
    translation: 'No — if only you knew with the knowledge of certainty…',
    reflection: 'Before certainty can be lived, it must be understood. The Qur’an says it arrives in depths — three of them.',
  },
  { type: 'depths', act: 1, tag: 'The Three Depths', ref: 'al-Takāthur · al-Wāqiʿah' },

  // ——— MOVEMENT II · The Witnessing ———
  {
    type: 'act', act: 2,
    line: 'The Qur’an did not leave the prophets to merely believe. It let them see — with their own eyes.',
  },
  {
    type: 'verse', act: 2, tag: 'Ibrahīm Asks to See',
    arabic: 'قَالَ أَوَلَمْ تُؤْمِن ۖ قَالَ بَلَىٰ وَلَٰكِن لِّيَطْمَئِنَّ قَلْبِي',
    ref: 'al-Baqarah · 2 : 260',
    translation: '“Do you not believe?” He said: “Yes — but so that my heart may be at rest.”',
    reflection: 'Even the Friend of God, who already believed, longed to witness. He is asking to move from the first depth to the second.',
  },
  {
    type: 'verse', act: 2, tag: 'And Then He Sees',
    arabic: 'قُلْنَا يَا نَارُ كُونِي بَرْدًا وَسَلَامًا عَلَىٰ إِبْرَاهِيمَ',
    ref: 'al-Anbiyāʾ · 21 : 69',
    translation: 'We said: “O fire — be coolness and peace upon Ibrahīm.”',
    reflection: 'He had asked to witness. Now, cast into the flames, he does — and the fire itself submits to his certainty.',
  },
  {
    type: 'verse', act: 2, tag: 'A Mother Acts On It',
    arabic: 'فَإِذَا خِفْتِ عَلَيْهِ فَأَلْقِيهِ فِي الْيَمِّ وَلَا تَخَافِي',
    ref: 'al-Qaṣaṣ · 28 : 7',
    translation: 'When you fear for him, cast him into the river — and do not fear.',
    reflection: 'To lay your child upon the water on nothing but God’s word — certainty is no longer a thought. It has become an act.',
  },

  // ——— MOVEMENT III · The Living ———
  {
    type: 'act', act: 3, bridge: true,
    arabic: 'وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ',
    ref: 'al-Ḥijr · 15 : 99',
    translation: 'And worship your Lord until certainty comes to you.',
    line: 'For most, this certainty comes only at death. But one family was asked to stand inside the flame — while still alive.',
  },
  {
    type: 'narration', act: 3, tag: 'The Morning of ʿĀshūrāʾ', ref: 'Karbalā — as narrated',
    body: 'They said that as the arrows fell thicker, the face of Ḥusayn only grew more luminous. When they asked how, he spoke of the nearness of the Beloved — that the closer the meeting, the brighter the certainty.',
    reflection: 'This is no longer witnessing from the outside. This is standing within the very fire the depths spoke of.',
  },
  {
    type: 'climax', act: 3, tag: 'The Court', ref: 'Sayyida Zaynab — as narrated',
    arabic: 'مَا رَأَيْتُ إِلَّا جَمِيلًا', translation: '“I saw nothing but beauty.”',
    body: 'After the sons. After the brothers. After the tents burned and the caravan was driven in chains — she stood before the throne and said she had witnessed nothing but beauty.',
    reflection: 'This is Ḥaqq al-Yaqīn — the truth of certainty. Not the absence of grief, but the certainty that sees the divine beauty through it.',
  },

  // ——— THE CLOSE ———
  { type: 'reflection', tag: 'Return' },
  { type: 'dua', tag: 'A Prayer for Certainty' },
];

const firstOfAct = {};
sections.forEach((s, i) => { if (s.act && !(s.act in firstOfAct)) firstOfAct[s.act] = i; });

const BG_STOPS = [
  [0.0, '#0f1712'], [0.32, '#0b110d'], [0.55, '#070a08'],
  [0.72, '#040605'], [0.82, '#020403'], [0.9, '#06100b'], [1.0, '#0b140f'],
];
const VIG_STOPS = [[0, 0.32], [0.55, 0.6], [0.82, 0.94], [1, 0.5]];

function lerpColor(a, b, t) {
  const A = a.replace('#', '').match(/.{2}/g).map(x => parseInt(x, 16));
  const B = b.replace('#', '').match(/.{2}/g).map(x => parseInt(x, 16));
  const c = A.map((v, i) => Math.round(v + (B[i] - v) * t));
  return `rgb(${c[0]},${c[1]},${c[2]})`;
}
function interp(p, stops, isColor) {
  for (let i = 0; i < stops.length - 1; i++) {
    if (p >= stops[i][0] && p <= stops[i + 1][0]) {
      const t = (p - stops[i][0]) / (stops[i + 1][0] - stops[i][0]);
      return isColor ? lerpColor(stops[i][1], stops[i + 1][1], t) : stops[i][1] + (stops[i + 1][1] - stops[i][1]) * t;
    }
  }
  return stops[stops.length - 1][1];
}

function Equalizer() {
  return (
    <span style={{ display: 'inline-flex', gap: 3, alignItems: 'center', height: 12 }}>
      {[0, 1, 2, 3, 4].map(i => (
        <span key={i} style={{ width: 2.5, height: 12, background: GOLD_BRIGHT, borderRadius: 2, transformOrigin: 'center', animation: `eq 850ms ease-in-out ${i * 110}ms infinite` }} />
      ))}
    </span>
  );
}

function ReciteButton({ active, onClick }) {
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 9, marginTop: 26, padding: '9px 16px', cursor: 'pointer',
      background: active ? 'rgba(227,195,126,0.10)' : 'rgba(255,255,255,0.025)',
      border: `1px solid ${active ? 'rgba(227,195,126,0.4)' : 'rgba(201,165,92,0.22)'}`,
      borderRadius: 999, color: active ? GOLD_BRIGHT : GOLD,
      font: `500 0.72rem ${FONT_UI}`, letterSpacing: '0.14em', textTransform: 'uppercase', transition: 'all 400ms ease',
    }}>
      {active ? <Equalizer /> : <span style={{ fontSize: 9, transform: 'translateX(1px)' }}>▶</span>}
      {active ? 'Reciting' : 'Recite'}
    </button>
  );
}

// gentle tap that blooms outward — used only for the closing Āmīn
function AminTap({ onTap }) {
  const [pulses, setPulses] = useState([]);
  const tap = () => {
    const id = Math.random();
    setPulses(p => [...p, id]);
    onTap && onTap();
    setTimeout(() => setPulses(p => p.filter(x => x !== id)), 1500);
  };
  return (
    <div style={{ textAlign: 'center' }}>
      <button onClick={tap} style={{ position: 'relative', background: 'none', border: 'none', cursor: 'pointer', padding: '10px 8px' }}>
        {pulses.map(id => <span key={id} style={{ position: 'absolute', left: '50%', top: '50%', width: 56, height: 56, marginLeft: -28, marginTop: -28, borderRadius: '50%', border: `1px solid ${GOLD_BRIGHT}`, animation: 'ripple 1500ms ease-out forwards', pointerEvents: 'none' }} />)}
        <span style={{ font: `400 clamp(1.7rem,7vw,2.2rem) ${FONT_AR}`, color: GOLD_BRIGHT, direction: 'rtl', textShadow: '0 0 20px rgba(227,195,126,0.2)' }}>آمِين</span>
      </button>
      <div style={{ font: `500 0.66rem ${FONT_UI}`, letterSpacing: '0.18em', textTransform: 'uppercase', color: GOLD, opacity: 0.7, marginTop: 8 }}>Tap to say Āmīn</div>
    </div>
  );
}

function Eyebrow({ act, shown }) {
  return (
    <div style={{
      opacity: shown ? 1 : 0, transition: 'opacity 900ms ease',
      font: `600 0.6rem ${FONT_UI}`, letterSpacing: '0.24em', textTransform: 'uppercase',
      color: GOLD, marginBottom: 12, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    }}>
      <span style={{ opacity: 0.55 }}>{ROMAN[act]}</span>
      <span style={{ width: 3, height: 3, borderRadius: '50%', background: GOLD, opacity: 0.5 }} />
      {ACTS[act].tr}
    </div>
  );
}

export default function MajlisYaqeen() {
  const scrollRef = useRef(null);
  const activeRef = useRef(0);
  const [progress, setProgress] = useState(0);
  const [active, setActive] = useState(0);
  const [visited, setVisited] = useState(() => new Set([0]));
  const [reciting, setReciting] = useState(null);
  const [openDepths, setOpenDepths] = useState(() => new Set());
  const [reflection, setReflection] = useState('');
  const [sealed, setSealed] = useState(false);
  const [amin, setAmin] = useState(false);

  const [motes] = useState(() =>
    Array.from({ length: 16 }, () => ({ left: Math.random() * 100, size: 1 + Math.random() * 1.8, dur: 16 + Math.random() * 20, delay: -Math.random() * 30, op: 0.06 + Math.random() * 0.16 }))
  );

  useEffect(() => {
    const l = document.createElement('link');
    l.rel = 'stylesheet';
    l.href = 'https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400&family=Inter:wght@300;400;500;600&display=swap';
    document.head.appendChild(l);
    return () => { document.head.removeChild(l); };
  }, []);

  const onScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    const max = el.scrollHeight - el.clientHeight;
    setProgress(max > 0 ? el.scrollTop / max : 0);
    const idx = Math.round(el.scrollTop / el.clientHeight);
    if (idx !== activeRef.current) {
      const lo = Math.min(idx, activeRef.current), hi = Math.max(idx, activeRef.current);
      setVisited(prev => { const n = new Set(prev); for (let i = lo; i <= hi; i++) n.add(i); return n; });
      activeRef.current = idx; setActive(idx); setReciting(null);
    }
  };

  const goTo = (i) => { const el = scrollRef.current; if (el) el.scrollTo({ top: i * el.clientHeight, behavior: 'smooth' }); };
  const restart = () => { setAmin(false); setSealed(false); setReflection(''); goTo(0); };

  const bg = interp(progress, BG_STOPS, true);
  const vig = interp(progress, VIG_STOPS, false);

  const reveal = (shown, delay = 0) => ({
    opacity: shown ? 1 : 0,
    transform: shown ? 'translateY(0)' : 'translateY(26px)',
    transition: `opacity 1000ms cubic-bezier(.2,.7,.2,1) ${delay}ms, transform 1000ms cubic-bezier(.2,.7,.2,1) ${delay}ms`,
  });

  const curType = sections[active]?.type;
  const curAct = curType === 'open' ? 0 : (curType === 'reflection' || curType === 'dua') ? 4 : (sections[active]?.act ?? 0);

  return (
    <div style={{ position: 'fixed', inset: 0, background: bg, transition: 'background 700ms linear', overflow: 'hidden' }}>
      <style>{`
        @keyframes eq { 0%,100%{transform:scaleY(0.35)} 50%{transform:scaleY(1)} }
        @keyframes bob { 0%,100%{transform:translateY(0);opacity:.5} 50%{transform:translateY(7px);opacity:1} }
        @keyframes rise { from{transform:translateY(8vh)} to{transform:translateY(-108vh)} }
        @keyframes breathe { 0%,100%{opacity:.5} 50%{opacity:.9} }
        @keyframes ripple { from{transform:scale(1);opacity:.7} to{transform:scale(2.1);opacity:0} }
        html{ font-size:125%; }
        .mjl-scroll{ scrollbar-width:none; -ms-overflow-style:none; }
        .mjl-scroll::-webkit-scrollbar{ display:none; }
        .depth-card:focus-visible, button:focus-visible, textarea:focus-visible{ outline:2px solid ${GOLD_BRIGHT}; outline-offset:3px; }
        @media (prefers-reduced-motion: reduce){ *{ animation:none !important; transition-duration:200ms !important; } }
      `}</style>

      {/* rising light-motes */}
      <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 1 }}>
        {motes.map((m, i) => (
          <span key={i} style={{ position: 'absolute', bottom: -20, left: `${m.left}%`, width: m.size, height: m.size, borderRadius: '50%', background: GOLD_BRIGHT, opacity: m.op, filter: 'blur(0.3px)', animation: `rise ${m.dur}s linear ${m.delay}s infinite` }} />
        ))}
      </div>

      {/* vignette */}
      <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 2, background: `radial-gradient(120% 90% at 50% 42%, transparent 30%, rgba(0,0,0,${vig}) 100%)`, transition: 'background 700ms linear' }} />

      {/* top progress hairline */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 2, zIndex: 20, background: 'rgba(255,255,255,0.04)' }}>
        <div style={{ height: '100%', width: `${progress * 100}%`, background: `linear-gradient(90deg, ${GOLD}, ${GOLD_BRIGHT})`, transition: 'width 200ms linear' }} />
      </div>

      {/* scroll body */}
      <div ref={scrollRef} onScroll={onScroll} className="mjl-scroll" style={{ position: 'relative', zIndex: 10, height: '100%', overflowY: 'scroll', scrollSnapType: 'y mandatory', WebkitOverflowScrolling: 'touch' }}>
        {sections.map((s, i) => {
          const shown = visited.has(i);
          return (
            <section key={i} style={{ scrollSnapAlign: 'start', minHeight: '100%', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', padding: '44px 30px 86px', boxSizing: 'border-box' }}>

              {/* OPENING */}
              {s.type === 'open' && (
                <div style={{ maxWidth: 460 }}>
                  <div style={reveal(shown, 0)}><div style={{ font: `500 0.72rem ${FONT_UI}`, letterSpacing: '0.42em', color: GOLD, marginBottom: 34 }}>{s.kicker}</div></div>
                  <div style={reveal(shown, 250)}><div style={{ font: `700 clamp(3rem,17vw,5rem) ${FONT_AR}`, color: GOLD_BRIGHT, lineHeight: 1, marginBottom: 18 }}>{s.arabicTitle}</div></div>
                  <div style={reveal(shown, 500)}>
                    <div style={{ font: `500 clamp(2rem,10vw,2.9rem) ${FONT_DISPLAY}`, color: CREAM, letterSpacing: '0.02em' }}>{s.title}</div>
                    <div style={{ font: `400 0.8rem ${FONT_UI}`, letterSpacing: '0.34em', textTransform: 'uppercase', color: MUTE, marginTop: 8 }}>{s.subtitle}</div>
                  </div>
                  <div style={reveal(shown, 780)}>
                    <div style={{ width: 34, height: 1, background: 'rgba(201,165,92,0.5)', margin: '32px auto' }} />
                    <p style={{ font: `italic 400 1.12rem ${FONT_DISPLAY}`, color: '#b9c1b3', lineHeight: 1.6, maxWidth: 320, margin: '0 auto' }}>{s.line}</p>
                  </div>
                  <div style={{ ...reveal(shown, 1100), marginTop: 50 }}>
                    <div style={{ font: `400 0.66rem ${FONT_UI}`, letterSpacing: '0.3em', textTransform: 'uppercase', color: FAINT, marginBottom: 8 }}>Descend</div>
                    <div style={{ animation: 'bob 2s ease-in-out infinite', color: GOLD, fontSize: 18 }}>⌄</div>
                  </div>
                </div>
              )}

              {/* VERSE */}
              {s.type === 'verse' && (
                <div style={{ maxWidth: 480, width: '100%' }}>
                  <Eyebrow act={s.act} shown={shown} />
                  <div style={{ ...reveal(shown, 60), font: `500 0.68rem ${FONT_UI}`, letterSpacing: '0.3em', textTransform: 'uppercase', color: CREAM, marginBottom: 34 }}>{s.tag}</div>
                  <div onClick={() => setReciting(reciting === i ? null : i)} style={{ ...reveal(shown, 240), cursor: 'pointer', font: `400 clamp(1.7rem,7.4vw,2.5rem) ${FONT_AR}`, color: reciting === i ? GOLD_BRIGHT : CREAM, lineHeight: 2, direction: 'rtl', padding: '0 4px', textShadow: reciting === i ? '0 0 26px rgba(227,195,126,0.35)' : 'none', transition: 'color 600ms ease, text-shadow 600ms ease' }}>{s.arabic}</div>
                  <div style={{ ...reveal(shown, 640), font: `italic 400 1.24rem ${FONT_DISPLAY}`, color: '#cdd3c6', lineHeight: 1.55, marginTop: 30, maxWidth: 400, marginInline: 'auto' }}>{s.translation}</div>
                  <div style={{ ...reveal(shown, 640), font: `400 0.7rem ${FONT_UI}`, letterSpacing: '0.16em', color: GOLD, opacity: 0.8, marginTop: 18 }}>{s.ref}</div>
                  <div style={reveal(shown, 1000)}>
                    <div style={{ width: 26, height: 1, background: 'rgba(201,165,92,0.32)', margin: '30px auto 24px' }} />
                    <p style={{ font: `300 0.98rem ${FONT_UI}`, color: MUTE, lineHeight: 1.75, maxWidth: 340, margin: '0 auto' }}>{s.reflection}</p>
                    <ReciteButton active={reciting === i} onClick={() => setReciting(reciting === i ? null : i)} />
                  </div>
                </div>
              )}

              {/* THREE DEPTHS — the map */}
              {s.type === 'depths' && (
                <div style={{ maxWidth: 460, width: '100%' }}>
                  <Eyebrow act={s.act} shown={shown} />
                  <div style={{ ...reveal(shown, 60), font: `500 clamp(1.5rem,7vw,1.9rem) ${FONT_DISPLAY}`, color: CREAM, marginBottom: 4 }}>{s.tag}</div>
                  <p style={{ ...reveal(shown, 150), font: `italic 400 0.98rem ${FONT_DISPLAY}`, color: MUTE, marginBottom: 26 }}>The map for everything below. Touch each to descend.</p>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                    {depths.map((d, di) => {
                      const open = openDepths.has(di);
                      return (
                        <button key={di} className="depth-card" onClick={() => setOpenDepths(prev => { const n = new Set(prev); n.has(di) ? n.delete(di) : n.add(di); return n; })}
                          style={{ ...reveal(shown, 300 + di * 160), textAlign: 'right', cursor: 'pointer', width: '100%', background: open ? 'rgba(227,195,126,0.06)' : 'rgba(255,255,255,0.022)', border: `1px solid ${open ? 'rgba(227,195,126,0.34)' : 'rgba(201,165,92,0.16)'}`, borderRadius: 16, padding: '18px 20px', transition: 'all 450ms ease' }}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', flexDirection: 'row-reverse' }}>
                            <span style={{ font: `700 1.5rem ${FONT_AR}`, color: open ? GOLD_BRIGHT : GOLD, direction: 'rtl' }}>{d.ar}</span>
                            <span style={{ textAlign: 'left' }}>
                              <span style={{ display: 'block', font: `500 0.92rem ${FONT_DISPLAY}`, color: CREAM, letterSpacing: '0.03em' }}>{ROMAN[di + 1]} · {d.tr}</span>
                              <span style={{ display: 'block', font: `300 0.68rem ${FONT_UI}`, letterSpacing: '0.06em', color: MUTE, marginTop: 2 }}>{d.label}</span>
                            </span>
                          </div>
                          <div style={{ overflow: 'hidden', maxHeight: open ? 120 : 0, opacity: open ? 1 : 0, transition: 'all 500ms cubic-bezier(.2,.7,.2,1)' }}>
                            <div style={{ height: 1, background: 'rgba(201,165,92,0.22)', margin: '14px 0 12px' }} />
                            <p style={{ textAlign: 'left', font: `italic 400 1.02rem ${FONT_DISPLAY}`, color: '#cdd3c6', lineHeight: 1.5 }}>{d.desc}{d.ref && <span style={{ font: `400 0.66rem ${FONT_UI}`, color: GOLD, letterSpacing: '0.1em', marginLeft: 8 }}>{d.ref}</span>}</p>
                            <p style={{ textAlign: 'left', font: `500 0.66rem ${FONT_UI}`, letterSpacing: '0.12em', textTransform: 'uppercase', color: GOLD, marginTop: 10 }}>→ {d.embod}</p>
                          </div>
                        </button>
                      );
                    })}
                  </div>
                  <p style={{ ...reveal(shown, 900), font: `300 0.84rem ${FONT_UI}`, color: FAINT, marginTop: 24, lineHeight: 1.6 }}>You will descend through all three. Watch the prophets be shown the second — and the Ahl al-Bayt live the third.</p>
                </div>
              )}

              {/* MOVEMENT CARD */}
              {s.type === 'act' && (
                <div style={{ maxWidth: 470 }}>
                  <div style={{ ...reveal(shown, 0), font: `600 0.64rem ${FONT_UI}`, letterSpacing: '0.4em', textTransform: 'uppercase', color: GOLD, marginBottom: 18 }}>Movement</div>
                  <div style={{ ...reveal(shown, 150), font: `400 clamp(3.4rem,20vw,5.5rem) ${FONT_DISPLAY}`, color: 'rgba(227,195,126,0.28)', lineHeight: 0.9, marginBottom: 10 }}>{ROMAN[s.act]}</div>
                  <div style={{ ...reveal(shown, 320), font: `700 clamp(1.9rem,9vw,2.7rem) ${FONT_AR}`, color: GOLD_BRIGHT, direction: 'rtl', lineHeight: 1.6, marginBottom: 8 }}>{ACTS[s.act].ar}</div>
                  <div style={{ ...reveal(shown, 320), font: `500 1.35rem ${FONT_DISPLAY}`, color: CREAM }}>{ACTS[s.act].tr}</div>
                  <div style={{ ...reveal(shown, 320), font: `400 0.72rem ${FONT_UI}`, letterSpacing: '0.28em', textTransform: 'uppercase', color: MUTE, marginTop: 6 }}>{ACTS[s.act].name}</div>

                  {s.bridge && (
                    <div style={{ ...reveal(shown, 560), margin: '28px auto 0', maxWidth: 380, padding: '18px 20px', borderRadius: 14, background: 'rgba(255,255,255,0.02)', border: '1px solid rgba(201,165,92,0.16)' }}>
                      <div style={{ font: `400 1.35rem ${FONT_AR}`, color: CREAM, direction: 'rtl', lineHeight: 1.9 }}>{s.arabic}</div>
                      <div style={{ font: `italic 400 1.02rem ${FONT_DISPLAY}`, color: '#cdd3c6', marginTop: 10 }}>{s.translation}</div>
                      <div style={{ font: `400 0.66rem ${FONT_UI}`, letterSpacing: '0.14em', color: GOLD, opacity: 0.8, marginTop: 8 }}>{s.ref}</div>
                    </div>
                  )}

                  <div style={reveal(shown, s.bridge ? 850 : 560)}>
                    <div style={{ width: 26, height: 1, background: 'rgba(201,165,92,0.32)', margin: '26px auto 22px' }} />
                    <p style={{ font: `italic 400 1.12rem ${FONT_DISPLAY}`, color: '#b9c1b3', lineHeight: 1.6, maxWidth: 340, margin: '0 auto' }}>{s.line}</p>
                    <div style={{ marginTop: 36, animation: 'bob 2s ease-in-out infinite', color: GOLD, fontSize: 16 }}>⌄</div>
                  </div>
                </div>
              )}

              {/* NARRATION — ʿĀshūrāʾ */}
              {s.type === 'narration' && (
                <div style={{ maxWidth: 470 }}>
                  <Eyebrow act={s.act} shown={shown} />
                  <div style={{ ...reveal(shown, 60), font: `500 0.68rem ${FONT_UI}`, letterSpacing: '0.3em', textTransform: 'uppercase', color: CREAM, marginBottom: 30 }}>{s.tag}</div>
                  <p style={{ ...reveal(shown, 250), font: `400 1.32rem ${FONT_DISPLAY}`, color: CREAM, lineHeight: 1.72, letterSpacing: '0.01em' }}>{s.body}</p>
                  <div style={{ ...reveal(shown, 800), font: `400 0.7rem ${FONT_UI}`, letterSpacing: '0.16em', color: GOLD, opacity: 0.75, marginTop: 26 }}>{s.ref}</div>
                  <div style={reveal(shown, 1050)}>
                    <div style={{ width: 26, height: 1, background: 'rgba(201,165,92,0.3)', margin: '28px auto 22px' }} />
                    <p style={{ font: `italic 400 1.05rem ${FONT_DISPLAY}`, color: MUTE, lineHeight: 1.6, maxWidth: 330, margin: '0 auto' }}>{s.reflection}</p>
                  </div>
                </div>
              )}

              {/* CLIMAX — Zaynab */}
              {s.type === 'climax' && (
                <div style={{ maxWidth: 480 }}>
                  <Eyebrow act={s.act} shown={shown} />
                  <div style={{ ...reveal(shown, 60), font: `500 0.68rem ${FONT_UI}`, letterSpacing: '0.3em', textTransform: 'uppercase', color: CREAM, marginBottom: 26 }}>{s.tag}</div>
                  <p style={{ ...reveal(shown, 200), font: `300 1.02rem ${FONT_UI}`, color: '#a7b0a3', lineHeight: 1.75, maxWidth: 360, margin: '0 auto 32px' }}>{s.body}</p>
                  <div onClick={() => setReciting(reciting === i ? null : i)} style={{ ...reveal(shown, 650), cursor: 'pointer', font: `700 clamp(2.1rem,9vw,3rem) ${FONT_AR}`, color: GOLD_BRIGHT, direction: 'rtl', lineHeight: 1.8, textShadow: reciting === i ? '0 0 34px rgba(227,195,126,0.5)' : '0 0 20px rgba(227,195,126,0.18)', transition: 'text-shadow 600ms ease' }}>{s.arabic}</div>
                  <div style={{ ...reveal(shown, 1000), font: `italic 500 1.42rem ${FONT_DISPLAY}`, color: CREAM, marginTop: 22 }}>{s.translation}</div>
                  <div style={{ ...reveal(shown, 1000), font: `400 0.7rem ${FONT_UI}`, letterSpacing: '0.16em', color: GOLD, opacity: 0.8, marginTop: 16 }}>{s.ref}</div>
                  <div style={reveal(shown, 1350)}>
                    <div style={{ width: 26, height: 1, background: 'rgba(201,165,92,0.32)', margin: '28px auto 22px' }} />
                    <p style={{ font: `300 0.98rem ${FONT_UI}`, color: MUTE, lineHeight: 1.75, maxWidth: 340, margin: '0 auto' }}>{s.reflection}</p>
                    <ReciteButton active={reciting === i} onClick={() => setReciting(reciting === i ? null : i)} />
                  </div>
                </div>
              )}

              {/* RETURN — reflection */}
              {s.type === 'reflection' && (
                <div style={{ maxWidth: 440, width: '100%' }}>
                  <div style={{ ...reveal(shown, 0), color: GOLD, fontSize: 20, marginBottom: 22, animation: 'breathe 3.5s ease-in-out infinite' }}>✦</div>
                  <h2 style={{ ...reveal(shown, 150), font: `500 clamp(1.9rem,8vw,2.5rem) ${FONT_DISPLAY}`, color: CREAM, lineHeight: 1.2, margin: 0 }}>Where is your yaqīn?</h2>
                  <p style={{ ...reveal(shown, 350), font: `italic 400 1.06rem ${FONT_DISPLAY}`, color: '#a7b0a3', lineHeight: 1.6, marginTop: 16 }}>You descended through knowing, through witnessing, through living. Before you rise — name the certainty you long for.</p>
                  {!sealed ? (
                    <div style={{ ...reveal(shown, 620), marginTop: 24 }}>
                      <textarea value={reflection} onChange={e => setReflection(e.target.value)} placeholder="Faith, a decision, a loss, the unseen ahead…" rows={3} style={{ width: '100%', boxSizing: 'border-box', resize: 'none', background: 'rgba(255,255,255,0.03)', border: '1px solid rgba(201,165,92,0.2)', borderRadius: 14, padding: '14px 16px', color: CREAM, font: `300 1rem ${FONT_UI}`, lineHeight: 1.6 }} />
                      <button onClick={() => reflection.trim() && setSealed(true)} style={{ width: '100%', marginTop: 12, padding: '13px', cursor: reflection.trim() ? 'pointer' : 'default', background: reflection.trim() ? 'rgba(227,195,126,0.12)' : 'rgba(255,255,255,0.02)', border: `1px solid ${reflection.trim() ? 'rgba(227,195,126,0.4)' : 'rgba(201,165,92,0.14)'}`, borderRadius: 999, color: reflection.trim() ? GOLD_BRIGHT : FAINT, font: `500 0.74rem ${FONT_UI}`, letterSpacing: '0.18em', textTransform: 'uppercase', transition: 'all 400ms ease' }}>Hold this thought</button>
                      <p style={{ font: `300 0.68rem ${FONT_UI}`, color: FAINT, marginTop: 14, lineHeight: 1.5 }}>Kept only on your device.</p>
                    </div>
                  ) : (
                    <div style={{ marginTop: 28 }}>
                      <div style={{ width: 30, height: 1, background: 'rgba(201,165,92,0.5)', margin: '0 auto 20px' }} />
                      <p style={{ font: `italic 400 1.24rem ${FONT_DISPLAY}`, color: CREAM, lineHeight: 1.6 }}>“{reflection}”</p>
                    </div>
                  )}
                  <div style={{ ...reveal(shown, 900), marginTop: 34 }}>
                    <div style={{ font: `400 0.64rem ${FONT_UI}`, letterSpacing: '0.24em', textTransform: 'uppercase', color: FAINT, marginBottom: 8 }}>And one prayer</div>
                    <div style={{ animation: 'bob 2s ease-in-out infinite', color: GOLD, fontSize: 16 }}>⌄</div>
                  </div>
                </div>
              )}

              {/* DUA — the close */}
              {s.type === 'dua' && (
                <div style={{ maxWidth: 480 }}>
                  <div style={{ ...reveal(shown, 0), font: `600 0.64rem ${FONT_UI}`, letterSpacing: '0.34em', textTransform: 'uppercase', color: GOLD, marginBottom: 22 }}>{s.tag}</div>
                  <p style={{ ...reveal(shown, 150), font: `italic 400 1.04rem ${FONT_DISPLAY}`, color: '#a7b0a3', lineHeight: 1.6, maxWidth: 340, margin: '0 auto 8px' }}>After all of it — one prayer, from the family you just stood beside.</p>
                  <div style={{ ...reveal(shown, 380), font: `400 clamp(1.6rem,6.8vw,2.15rem) ${FONT_AR}`, color: CREAM, direction: 'rtl', lineHeight: 2, marginTop: 26, textShadow: '0 0 22px rgba(227,195,126,0.14)' }}>{DUA_AR}</div>
                  <div style={{ ...reveal(shown, 720), font: `italic 400 1.2rem ${FONT_DISPLAY}`, color: '#cdd3c6', lineHeight: 1.55, marginTop: 26, maxWidth: 400, marginInline: 'auto' }}>{DUA_TR}</div>
                  <div style={{ ...reveal(shown, 720), font: `400 0.72rem ${FONT_UI}`, letterSpacing: '0.1em', color: GOLD, opacity: 0.85, marginTop: 16 }}>Imam ʿAlī ibn al-Ḥusayn · al-Ṣaḥīfa al-Sajjādiyya</div>
                  <div style={{ ...reveal(shown, 980) }}>
                    <div style={{ width: 26, height: 1, background: 'rgba(201,165,92,0.3)', margin: '26px auto 20px' }} />
                    <p style={{ font: `300 0.96rem ${FONT_UI}`, color: MUTE, lineHeight: 1.75, maxWidth: 350, margin: '0 auto' }}>The son of Ḥusayn — present at Karbalā, the one who lived to carry it. He witnessed certainty’s severest trial, and still asked God to deepen his own.</p>
                  </div>
                  <div style={{ ...reveal(shown, 1250), marginTop: 30 }}>
                    {!amin ? (
                      <AminTap onTap={() => setAmin(true)} />
                    ) : (
                      <div>
                        <div style={{ font: `italic 500 1.5rem ${FONT_DISPLAY}`, color: GOLD_BRIGHT }}>Āmīn.</div>
                        <p style={{ font: `300 0.92rem ${FONT_UI}`, color: MUTE, marginTop: 14, lineHeight: 1.6 }}>The descent ends. The certainty is yours to keep.</p>
                        <button onClick={restart} style={{ marginTop: 28, padding: '11px 22px', cursor: 'pointer', background: 'transparent', border: '1px solid rgba(201,165,92,0.24)', borderRadius: 999, color: GOLD, font: `400 0.7rem ${FONT_UI}`, letterSpacing: '0.16em', textTransform: 'uppercase' }}>Begin again</button>
                      </div>
                    )}
                  </div>
                </div>
              )}
            </section>
          );
        })}
      </div>

      {/* persistent depth stepper */}
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 20, display: (curAct === 0 || curAct >= 4) ? 'none' : 'flex', justifyContent: 'center', paddingBottom: 20, paddingTop: 34, background: 'linear-gradient(to top, rgba(2,4,3,0.6), transparent)', pointerEvents: 'none' }}>
        <div style={{ display: 'flex', alignItems: 'center', pointerEvents: 'auto' }}>
          {[1, 2, 3].map((a, idx) => {
            const state = a < curAct ? 'past' : a === curAct ? 'current' : 'upcoming';
            return (
              <div key={a} style={{ display: 'flex', alignItems: 'center' }}>
                {idx > 0 && <div style={{ width: 24, height: 1, background: a <= curAct ? 'rgba(201,165,92,0.55)' : 'rgba(201,165,92,0.18)', transition: 'background 500ms', margin: '0 2px', marginBottom: 16 }} />}
                <button onClick={() => goTo(firstOfAct[a])} aria-label={`${ACTS[a].tr} — ${ACTS[a].name}`} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, background: 'none', border: 'none', cursor: 'pointer', padding: '2px 6px' }}>
                  <span style={{ width: state === 'current' ? 9 : 6, height: state === 'current' ? 9 : 6, borderRadius: '50%', background: state === 'upcoming' ? 'transparent' : (state === 'current' ? GOLD_BRIGHT : GOLD), border: state === 'upcoming' ? '1px solid rgba(201,165,92,0.4)' : 'none', boxShadow: state === 'current' ? `0 0 10px ${GOLD}` : 'none', transition: 'all 400ms' }} />
                  <span style={{ font: `${state === 'current' ? 600 : 400} 0.6rem ${FONT_UI}`, letterSpacing: '0.08em', color: state === 'current' ? GOLD_BRIGHT : state === 'past' ? GOLD : FAINT, transition: 'color 400ms', whiteSpace: 'nowrap' }}>{ACTS[a].tr}</span>
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
