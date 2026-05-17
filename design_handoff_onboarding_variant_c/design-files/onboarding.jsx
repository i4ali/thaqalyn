// Onboarding redesign — 11 screens for althaqalayn
// Aesthetic: editorial, restrained, Arabic typography as hero,
// warm parchment + ink, single peach accent. No emoji chips.

const PHONE_W = 372;
const PHONE_H = 806;

// ── Tokens ──────────────────────────────────────────────────────
const OB = {
  // surfaces
  paper: '#F6EFE0',         // warm parchment
  paperDeep: '#EFE6D4',     // a touch deeper
  card: '#FFFCF4',          // softly raised
  ink: '#1B1410',           // near-black warm
  ink2: '#5A4A3F',
  ink3: '#8A7B6E',
  hair: 'rgba(27,20,16,0.10)',
  hairSoft: 'rgba(27,20,16,0.06)',
  // accents
  accent: '#D17A48',        // peach
  accentDeep: '#B25E2E',
  accentSoft: '#F3D8BF',
  sage: '#6C8A6F',
  plum: '#8A6B82',
  // dark surfaces
  inkBg: '#1A130F',
  inkBgWarm: '#241814',
  // type
  sans: '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", system-ui, sans-serif',
  serif: '"Instrument Serif", "Cormorant Garamond", "Times New Roman", serif',
  arabic: '"Amiri", "Scheherazade New", serif',
};

// ── Status bar ──────────────────────────────────────────────────
function ObStatus({ dark = false, time = '9:41' }) {
  const c = dark ? '#fff' : OB.ink;
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: 44,
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '14px 22px 0', color: c, fontFamily: OB.sans,
      fontWeight: 600, fontSize: 15, zIndex: 20,
    }}>
      <span>{time}</span>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="17" height="11" viewBox="0 0 17 11"><rect x="0" y="7" width="3" height="4" rx="0.6" fill={c}/><rect x="4.5" y="5" width="3" height="6" rx="0.6" fill={c}/><rect x="9" y="3" width="3" height="8" rx="0.6" fill={c}/><rect x="13.5" y="1" width="3" height="10" rx="0.6" fill={c}/></svg>
        <svg width="15" height="11" viewBox="0 0 17 12"><path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/><path d="M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z" fill={c}/><circle cx="8.5" cy="10.5" r="1.4" fill={c}/></svg>
        <svg width="24" height="11" viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="20" height="9" rx="1.5" fill={c}/><path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

// ── Page indicator (bottom dots) ────────────────────────────────
function ObDots({ total = 11, index = 0, dark = false }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 22,
      display: 'flex', justifyContent: 'center', gap: 6, zIndex: 10,
    }}>
      {[...Array(total)].map((_, i) => {
        const active = i === index;
        return (
          <div key={i} style={{
            width: active ? 22 : 6, height: 6, borderRadius: 999,
            background: active
              ? (dark ? '#fff' : OB.ink)
              : (dark ? 'rgba(255,255,255,0.25)' : 'rgba(27,20,16,0.18)'),
            transition: 'all 0.2s',
          }} />
        );
      })}
    </div>
  );
}

// ── Top chrome (brand mark + skip) ──────────────────────────────
function ObTopChrome({ dark = false, showSkip = true, step = 1, total = 11 }) {
  const c = dark ? 'rgba(255,255,255,0.7)' : OB.ink2;
  return (
    <div style={{
      position: 'absolute', top: 52, left: 22, right: 22,
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      zIndex: 15,
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        color: c, fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 2.4,
      }}>
        <span style={{
          width: 22, height: 22, borderRadius: 6,
          background: dark ? 'rgba(255,255,255,0.08)' : 'rgba(27,20,16,0.06)',
          border: `1px solid ${dark ? 'rgba(255,255,255,0.14)' : OB.hair}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: dark ? '#fff' : OB.ink, fontFamily: OB.serif, fontStyle: 'italic',
          fontSize: 13, letterSpacing: 0, fontWeight: 400,
        }}>t</span>
        <span>THAQALAYN</span>
      </div>
      {showSkip && (
        <div style={{
          color: c, fontFamily: OB.sans, fontSize: 14, fontWeight: 500,
        }}>
          Skip
        </div>
      )}
    </div>
  );
}

// ── Tiny icon set ───────────────────────────────────────────────
function ObIcon({ name, size = 18, stroke = 1.6, color = 'currentColor' }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'book': return <svg {...p}><path d="M4 5a2 2 0 0 1 2-2h12v16H6a2 2 0 0 0-2 2V5z"/><path d="M4 19a2 2 0 0 1 2-2h12"/></svg>;
    case 'spark': return <svg {...p}><path d="M12 3l1.8 5L18 9.5l-4.2 1.5L12 16l-1.8-5L6 9.5 10.2 8 12 3z"/></svg>;
    case 'bell': return <svg {...p}><path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2H4.5L6 16z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>;
    case 'heart': return <svg {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/></svg>;
    case 'compass': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M15 9l-2 5-5 2 2-5 5-2z" fill={color}/></svg>;
    case 'moon': return <svg {...p}><path d="M20 14.5A8 8 0 0 1 9.5 4 8 8 0 1 0 20 14.5z"/></svg>;
    case 'leaf': return <svg {...p}><path d="M5 19c0-9 6-15 15-15 0 9-6 15-15 15z"/><path d="M5 19l7-7"/></svg>;
    case 'flame': return <svg {...p}><path d="M12 3c1 4 4 5 4 9a4 4 0 1 1-8 0c0-2 1-3 1-5 1 1 1 2 3-4z"/></svg>;
    case 'crown': return <svg {...p}><path d="M3 8l4 4 5-7 5 7 4-4-2 11H5L3 8z"/></svg>;
    case 'scales': return <svg {...p}><path d="M12 4v16M5 20h14"/><path d="M5 9l3 7H2l3-7zM19 9l3 7h-6l3-7z"/></svg>;
    case 'play': return <svg {...p} fill={color} stroke="none"><path d="M7 5l12 7-12 7V5z"/></svg>;
    case 'arrow': return <svg {...p}><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>;
    case 'check': return <svg {...p} strokeWidth={2.2}><path d="M5 12l4 4 10-10"/></svg>;
    case 'star': return <svg {...p}><path d="M12 3l2.7 6.2L21 10l-5 4.5L17.5 21 12 17.5 6.5 21 8 14.5 3 10l6.3-0.8L12 3z"/></svg>;
    case 'pen': return <svg {...p}><path d="M4 20l4-1 11-11-3-3L5 16l-1 4z"/></svg>;
    case 'globe': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/></svg>;
    case 'columns': return <svg {...p}><path d="M4 21h16M4 9l8-5 8 5M6 21V10M10 21V10M14 21V10M18 21V10"/></svg>;
    case 'chev': return <svg {...p}><path d="M9 6l6 6-6 6"/></svg>;
    case 'plus': return <svg {...p}><path d="M12 5v14M5 12h14"/></svg>;
    case 'user': return <svg {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c1-5 5-7 8-7s7 2 8 7"/></svg>;
    case 'apple': return <svg viewBox="0 0 24 24" width={size} height={size} fill={color}><path d="M16.4 12.7c0-2.4 2-3.6 2.1-3.7-1.1-1.7-2.9-1.9-3.5-1.9-1.5-.2-2.9.9-3.7.9-.8 0-1.9-.9-3.2-.8-1.6 0-3.2.9-4 2.4-1.7 3-.4 7.3 1.2 9.7.8 1.2 1.8 2.5 3 2.4 1.2 0 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4.9-1.4 1.3-2.7 1.3-2.8-.1 0-2.6-1-2.6-3.8zM14 5.2c.7-.8 1.1-2 1-3.2-1 .1-2.2.6-2.9 1.5-.6.7-1.2 2-1.1 3.1 1.1.1 2.3-.6 3-1.4z"/></svg>;
    default: return null;
  }
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 1 — Cover / Hadith of Thaqalayn (dark, editorial)
// ─────────────────────────────────────────────────────────────────
function S1_Cover() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.inkBg, color: '#fff', fontFamily: OB.sans,
    }}>
      {/* atmospheric glow */}
      <div style={{
        position: 'absolute', top: '12%', left: '50%', transform: 'translateX(-50%)',
        width: 520, height: 520, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(209,122,72,0.42), transparent 60%)',
        filter: 'blur(8px)',
      }} />
      {/* subtle stars */}
      {[...Array(14)].map((_, i) => (
        <div key={i} style={{
          position: 'absolute',
          top: `${((i*47)+7)%96}%`, left: `${((i*79)+11)%100}%`,
          width: i%4===0 ? 2.5 : 1.2, height: i%4===0 ? 2.5 : 1.2,
          borderRadius: '50%', background: '#fff',
          opacity: 0.12 + ((i%5)*0.04),
        }} />
      ))}

      <ObStatus dark />
      <ObTopChrome dark step={1} />

      {/* Arabic logotype — large, centered */}
      <div style={{
        position: 'absolute', top: 130, left: 0, right: 0,
        display: 'flex', justifyContent: 'center', alignItems: 'center',
      }}>
        <div style={{
          fontFamily: OB.arabic, fontSize: 96, fontWeight: 700,
          color: '#fff', textShadow: '0 0 40px rgba(209,122,72,0.5)',
          letterSpacing: -2, lineHeight: 1,
        }}>ثقلين</div>
      </div>

      {/* English transliteration small */}
      <div style={{
        position: 'absolute', top: 260, left: 0, right: 0, textAlign: 'center',
        fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 4,
        color: 'rgba(255,255,255,0.55)', textTransform: 'uppercase',
      }}>The Two Weighty Things</div>

      {/* divider */}
      <div style={{
        position: 'absolute', top: 296, left: '50%', transform: 'translateX(-50%)',
        width: 36, height: 1, background: OB.accent,
      }} />

      {/* Arabic hadith */}
      <div style={{
        position: 'absolute', top: 332, left: 28, right: 28, textAlign: 'center',
        fontFamily: OB.arabic, fontSize: 22, lineHeight: 1.85,
        color: '#fff', direction: 'rtl',
      }}>
        إنّي تاركٌ فيكم الثقلين:<br/>
        كتاب الله وعترتي أهلَ بيتي
      </div>

      {/* English translation — editorial */}
      <div style={{
        position: 'absolute', top: 488, left: 36, right: 36, textAlign: 'center',
        fontFamily: OB.serif, fontStyle: 'italic',
        fontSize: 21, lineHeight: 1.4, color: 'rgba(255,255,255,0.92)',
        letterSpacing: -0.2,
      }}>
        “I am leaving among you two weighty things — the Book of Allah, and my progeny, the people of my household.”
      </div>

      {/* attribution */}
      <div style={{
        position: 'absolute', top: 678, left: 0, right: 0, textAlign: 'center',
        fontFamily: OB.sans, fontSize: 12, fontWeight: 500, letterSpacing: 1.6,
        color: 'rgba(255,255,255,0.45)', textTransform: 'uppercase',
      }}>— Prophet Muhammad ﷺ</div>

      {/* CTA */}
      <div style={{
        position: 'absolute', left: 22, right: 22, bottom: 64,
      }}>
        <div style={{
          background: '#fff', color: OB.ink, borderRadius: 999,
          padding: '15px 0', textAlign: 'center', fontSize: 15, fontWeight: 700,
          fontFamily: OB.sans, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          Begin <ObIcon name="arrow" size={15} stroke={2.2} />
        </div>
      </div>

      <ObDots total={11} index={0} dark />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 2 — Promise: Wisdom at your fingertips
// ─────────────────────────────────────────────────────────────────
function S2_Promise() {
  const features = [
    { icon: 'book',    label: 'Complete Quran with English translation' },
    { icon: 'columns', label: 'Five layers of authentic Shia commentary' },
    { icon: 'bell',    label: 'Daily verses aligned with the Islamic calendar' },
    { icon: 'heart',   label: 'Sync bookmarks and progress across devices' },
  ];
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={2} />

      {/* Arabic hero */}
      <div style={{
        position: 'absolute', top: 116, left: 0, right: 0, textAlign: 'center',
      }}>
        <div style={{
          fontFamily: OB.arabic, fontSize: 88, fontWeight: 700, color: OB.ink,
          letterSpacing: -2, lineHeight: 1,
        }}>ثقلين</div>
        <div style={{
          marginTop: 14, fontFamily: OB.sans, fontSize: 10.5, fontWeight: 700, letterSpacing: 3,
          color: OB.ink3, textTransform: 'uppercase',
        }}>Thaqalayn · ثَقَلَيْن</div>
      </div>

      {/* Editorial headline */}
      <div style={{
        position: 'absolute', top: 296, left: 32, right: 32, textAlign: 'center',
      }}>
        <div style={{
          fontFamily: OB.serif, fontSize: 32, lineHeight: 1.15,
          color: OB.ink, letterSpacing: -0.5,
        }}>
          <span style={{ fontStyle: 'italic' }}>Two</span> teachings,
          <br />one quiet companion.
        </div>
        <div style={{
          marginTop: 14, fontFamily: OB.sans, fontSize: 14.5, lineHeight: 1.5,
          color: OB.ink2, maxWidth: 290, margin: '14px auto 0',
        }}>
          The Quran and the wisdom of the Ahlul Bayt — drawn from authentic Shia scholarship.
        </div>
      </div>

      {/* feature list */}
      <div style={{
        position: 'absolute', top: 502, left: 28, right: 28,
        display: 'flex', flexDirection: 'column', gap: 0,
      }}>
        {features.map((f, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 14,
            padding: '13px 0',
            borderBottom: i < features.length - 1 ? `1px solid ${OB.hair}` : 'none',
          }}>
            <div style={{
              width: 34, height: 34, borderRadius: 10,
              border: `1px solid ${OB.hair}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: OB.accent,
            }}>
              <ObIcon name={f.icon} size={16} stroke={1.7} />
            </div>
            <div style={{ fontSize: 13.5, color: OB.ink, fontWeight: 500, flex: 1, lineHeight: 1.35 }}>
              {f.label}
            </div>
          </div>
        ))}
      </div>

      <ObDots total={11} index={1} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 3 — Five Layers of Wisdom
// ─────────────────────────────────────────────────────────────────
function S3_Layers() {
  const layers = [
    { n: 'I',   name: 'Foundation',  desc: 'Simple explanations and historical context', icon: 'columns', color: OB.ink2 },
    { n: 'II',  name: 'Classical',   desc: 'Tabatabai, Tabrisi, traditional scholars',   icon: 'book',    color: OB.plum },
    { n: 'III', name: 'Contemporary',desc: 'Modern perspectives & scientific insight',   icon: 'globe',   color: OB.sage },
    { n: 'IV',  name: 'Ahlul Bayt',  desc: 'Hadith from the fourteen infallibles',       icon: 'star',    color: OB.accent },
    { n: 'V',   name: 'Comparative', desc: 'Balanced Shia and Sunni scholarship',        icon: 'scales',  color: OB.ink2 },
  ];
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={3} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          The Wisdom Stack
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          <span style={{ fontStyle: 'italic' }}>Five</span> layers,<br/>one verse at a time.
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: OB.ink2, lineHeight: 1.5, maxWidth: 300 }}>
          Tap any verse and unfold commentary from foundation to comparative — each lens hand-picked.
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 350, left: 22, right: 22,
        display: 'flex', flexDirection: 'column', gap: 0,
        background: OB.card, borderRadius: 18,
        border: `1px solid ${OB.hairSoft}`,
        boxShadow: '0 1px 0 rgba(255,255,255,0.6) inset, 0 8px 20px rgba(60,40,20,0.05)',
        overflow: 'hidden',
      }}>
        {layers.map((l, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 14,
            padding: '14px 16px',
            borderBottom: i < layers.length-1 ? `1px solid ${OB.hairSoft}` : 'none',
          }}>
            <div style={{
              width: 30, fontFamily: OB.serif, fontStyle: 'italic',
              fontSize: 18, color: l.color, textAlign: 'center',
              letterSpacing: 0.5,
            }}>{l.n}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: OB.ink, letterSpacing: -0.2 }}>{l.name}</div>
              <div style={{ fontSize: 11.5, color: OB.ink3, marginTop: 1 }}>{l.desc}</div>
            </div>
            <div style={{ color: l.color, opacity: 0.7 }}>
              <ObIcon name={l.icon} size={16} stroke={1.7} />
            </div>
          </div>
        ))}
      </div>

      <ObDots total={11} index={2} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 4 — Daily Companion (Verse of the Day)
// ─────────────────────────────────────────────────────────────────
function S4_Daily() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={4} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          Verse of the Day
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          A <span style={{ fontStyle: 'italic' }}>quiet</span> meeting,<br/>every morning.
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: OB.ink2, lineHeight: 1.5, maxWidth: 300 }}>
          Verses chosen for each month of the Islamic calendar — so the season meets you in scripture.
        </div>
      </div>

      {/* Verse card */}
      <div style={{
        position: 'absolute', top: 348, left: 22, right: 22,
        background: OB.card, borderRadius: 22, padding: 22,
        border: `1px solid ${OB.hairSoft}`,
        boxShadow: '0 12px 28px rgba(60,40,20,0.06)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: OB.accentSoft, color: OB.accentDeep, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ObIcon name="moon" size={14} stroke={1.8} />
            </div>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 2, color: OB.accentDeep, textTransform: 'uppercase' }}>Dhul-Qaʿdah</div>
          </div>
          <div style={{ color: OB.accent }}><ObIcon name="star" size={16} stroke={1.7} /></div>
        </div>

        <div style={{
          fontFamily: OB.arabic, fontSize: 24, lineHeight: 1.85,
          color: OB.ink, direction: 'rtl', textAlign: 'right',
          marginTop: 8, marginBottom: 14,
        }}>
          وَأَذِّن فِي ٱلنَّاسِ بِٱلْحَجِّ يَأْتُوكَ رِجَالًا
        </div>

        <div style={{ fontFamily: OB.serif, fontStyle: 'italic', fontSize: 17, lineHeight: 1.4, color: OB.ink, letterSpacing: -0.1 }}>
          “And proclaim to the people the pilgrimage; they will come to you on foot and on every lean camel.”
        </div>

        <div style={{
          marginTop: 14, paddingTop: 12, borderTop: `1px solid ${OB.hairSoft}`,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <div style={{ fontSize: 11.5, color: OB.ink3, fontWeight: 600, letterSpacing: 0.4 }}>
            Surah 22 · Verse 27
          </div>
          <div style={{ fontSize: 11, color: OB.accent, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 4 }}>
            Read tafsir <ObIcon name="arrow" size={11} stroke={2.4} />
          </div>
        </div>
      </div>

      {/* enable reminder bar */}
      <div style={{
        position: 'absolute', left: 22, right: 22, bottom: 78,
        background: OB.ink, color: '#fff', borderRadius: 16,
        padding: '14px 18px', display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <div style={{ width: 32, height: 32, borderRadius: 10, background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <ObIcon name="bell" size={15} stroke={1.8} color="#fff" />
        </div>
        <div style={{ flex: 1, fontSize: 13, fontWeight: 600 }}>Enable daily verses</div>
        <div style={{ fontSize: 12, color: OB.accent, fontWeight: 700 }}>Allow</div>
      </div>

      <ObDots total={11} index={3} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 5 — Gems
// ─────────────────────────────────────────────────────────────────
function S5_Gems() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={5} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          Gems
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          Hidden <span style={{ fontStyle: 'italic' }}>jewels</span>,<br/>quietly unveiled.
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: OB.ink2, lineHeight: 1.5, maxWidth: 300 }}>
          The greatest verses come with a curated essay — what they mean, why they matter, and the names they have carried for centuries.
        </div>
      </div>

      {/* feature card — Ayat al-Kursi */}
      <div style={{
        position: 'absolute', top: 360, left: 22, right: 22,
        background: OB.card, borderRadius: 22, padding: 22,
        border: `1px solid ${OB.hairSoft}`,
        boxShadow: '0 12px 28px rgba(60,40,20,0.06)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <div style={{
            width: 40, height: 40, borderRadius: 10,
            background: OB.ink, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: OB.serif, fontStyle: 'italic', fontSize: 15,
          }}>2:255</div>
          <div>
            <div style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: -0.2 }}>Al-Baqarah 255</div>
            <div style={{ fontSize: 11, color: OB.ink3, marginTop: 1, letterSpacing: 0.4, fontWeight: 600 }}>Ayat al-Kursi</div>
          </div>
        </div>

        <div style={{
          fontFamily: OB.arabic, fontSize: 22, lineHeight: 1.8,
          color: OB.ink, direction: 'rtl', textAlign: 'right',
          paddingBottom: 14, borderBottom: `1px solid ${OB.hairSoft}`,
        }}>
          ٱلْقَيُّومُ لَا تَأْخُذُهُۥ سِنَةٌ وَلَا نَوْمٌ
        </div>

        {/* gem tags — three names */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 14 }}>
          {[
            { label: 'The Throne Verse', icon: 'crown', color: OB.plum },
            { label: 'The Ever-Living', icon: 'spark', color: OB.sage },
            { label: 'Cosmic Sovereignty', icon: 'globe', color: OB.ink2 },
            { label: 'Al-Kursi', icon: 'star', color: OB.accent },
          ].map((t, i) => (
            <div key={i} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5,
              padding: '6px 10px', borderRadius: 999,
              border: `1px solid ${OB.hair}`,
              fontSize: 11.5, fontWeight: 600, color: t.color,
            }}>
              <ObIcon name={t.icon} size={11} stroke={2} />
              {t.label}
            </div>
          ))}
        </div>

        {/* insight blockquote */}
        <div style={{ marginTop: 16, paddingLeft: 12, borderLeft: `2px solid ${OB.accent}` }}>
          <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2, color: OB.accentDeep, textTransform: 'uppercase' }}>Core Insight</div>
          <div style={{ marginTop: 5, fontFamily: OB.serif, fontStyle: 'italic', fontSize: 14, lineHeight: 1.4, color: OB.ink }}>
            “The greatest verse in the Quran — describing Allah's absolute sovereignty, knowledge, and power over all creation.”
          </div>
        </div>
      </div>

      <ObDots total={11} index={4} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 6 — Test Your Knowledge (quiz)
// ─────────────────────────────────────────────────────────────────
function S6_Quiz() {
  const options = [
    { key: 'A', text: "The physical throne of Allah", state: 'idle' },
    { key: 'B', text: "Allah's knowledge and authority", state: 'correct' },
    { key: 'C', text: "A type of angel", state: 'idle' },
    { key: 'D', text: "The heavens", state: 'idle' },
  ];
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={6} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          Test Your Knowledge
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 36, lineHeight: 1.05, letterSpacing: -0.8 }}>
          <span style={{ fontStyle: 'italic' }}>Read,</span> reflect,<br/>then prove it.
        </div>
      </div>

      {/* quiz card */}
      <div style={{
        position: 'absolute', top: 280, left: 22, right: 22,
        background: OB.card, borderRadius: 22, padding: '20px 20px 22px',
        border: `1px solid ${OB.hairSoft}`,
        boxShadow: '0 12px 28px rgba(60,40,20,0.06)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '4px 10px', borderRadius: 999,
            background: OB.accentSoft, color: OB.accentDeep,
            fontSize: 10.5, fontWeight: 700, letterSpacing: 1.4, textTransform: 'uppercase',
          }}>
            <ObIcon name="columns" size={11} stroke={2} /> Foundation
          </div>
          <div style={{ fontSize: 11, fontWeight: 700, color: OB.ink3, fontFamily: OB.sans }}>3 / 10</div>
        </div>

        <div style={{ fontFamily: OB.serif, fontSize: 22, lineHeight: 1.25, color: OB.ink, letterSpacing: -0.3 }}>
          What does <span style={{ fontStyle: 'italic' }}>Kursī</span> represent in Ayat al-Kursi?
        </div>

        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {options.map((o) => {
            const correct = o.state === 'correct';
            return (
              <div key={o.key} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '12px 14px', borderRadius: 14,
                border: `1.5px solid ${correct ? OB.accent : OB.hair}`,
                background: correct ? OB.accentSoft : 'transparent',
              }}>
                <div style={{
                  width: 26, height: 26, borderRadius: 8,
                  background: correct ? OB.accent : 'transparent',
                  border: correct ? 'none' : `1px solid ${OB.hair}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: OB.serif, fontStyle: 'italic',
                  color: correct ? '#fff' : OB.ink2, fontSize: 14, fontWeight: 500,
                }}>{correct ? <ObIcon name="check" size={14} stroke={2.4} color="#fff" /> : o.key}</div>
                <div style={{ fontSize: 14, fontWeight: 600, color: OB.ink, flex: 1 }}>
                  {o.text}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 70, textAlign: 'center',
        fontSize: 13, color: OB.ink3, fontStyle: 'italic', fontFamily: OB.serif,
      }}>
        Deepen your understanding through reflection.
      </div>

      <ObDots total={11} index={5} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 7 — Quiz Result (dark, punctuation)
// ─────────────────────────────────────────────────────────────────
function S7_Result() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.inkBg, color: '#fff', fontFamily: OB.sans,
    }}>
      <div style={{
        position: 'absolute', top: '24%', left: '50%', transform: 'translateX(-50%)',
        width: 460, height: 460, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(209,122,72,0.35), transparent 60%)',
        filter: 'blur(8px)',
      }} />

      <ObStatus dark />
      <ObTopChrome dark step={7} />

      <div style={{ position: 'absolute', top: 130, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: 'rgba(255,255,255,0.55)', textTransform: 'uppercase' }}>
          Quiz Complete · Al-Baqarah
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          <span style={{ fontStyle: 'italic' }}>Excellent</span><br/>understanding.
        </div>
      </div>

      {/* huge score display */}
      <div style={{
        position: 'absolute', top: 312, left: 0, right: 0, textAlign: 'center',
      }}>
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <span style={{
            fontFamily: OB.serif, fontSize: 220, lineHeight: 0.85, fontWeight: 400,
            color: '#fff', letterSpacing: -10,
          }}>9</span>
          <span style={{
            position: 'absolute', right: -54, top: 36,
            fontFamily: OB.serif, fontStyle: 'italic', fontSize: 36,
            color: 'rgba(255,255,255,0.45)',
          }}>/10</span>
        </div>
      </div>

      {/* level badge */}
      <div style={{
        position: 'absolute', top: 532, left: 0, right: 0, textAlign: 'center',
      }}>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 14,
          padding: '10px 22px', borderRadius: 999,
          border: '1px solid rgba(255,255,255,0.18)',
          background: 'rgba(255,255,255,0.05)',
          backdropFilter: 'blur(10px)',
        }}>
          <div style={{ fontFamily: OB.arabic, fontSize: 22, color: OB.accent }}>عالم</div>
          <div style={{ width: 1, height: 18, background: 'rgba(255,255,255,0.2)' }} />
          <div style={{ fontFamily: OB.sans, fontSize: 12, fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase', color: '#fff' }}>Scholar level</div>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 596, left: 36, right: 36, textAlign: 'center',
      }}>
        <div style={{
          fontFamily: OB.serif, fontStyle: 'italic', fontSize: 18, lineHeight: 1.4,
          color: 'rgba(255,255,255,0.7)',
        }}>
          “Knowledge deepens when shared — your reflection today seeds tomorrow's certainty.”
        </div>
      </div>

      {/* stat row */}
      <div style={{
        position: 'absolute', left: 22, right: 22, bottom: 92,
        display: 'flex', gap: 8,
      }}>
        {[
          { v: '12', l: 'Quizzes' },
          { v: '87%', l: 'Avg score' },
          { v: '5', l: 'Surahs done' },
        ].map((s, i) => (
          <div key={i} style={{
            flex: 1, padding: '12px 8px', borderRadius: 14,
            border: '1px solid rgba(255,255,255,0.12)',
            textAlign: 'center',
          }}>
            <div style={{ fontFamily: OB.serif, fontSize: 24, color: '#fff', letterSpacing: -0.5 }}>{s.v}</div>
            <div style={{ marginTop: 2, fontSize: 10.5, color: 'rgba(255,255,255,0.5)', letterSpacing: 1, textTransform: 'uppercase', fontWeight: 600 }}>{s.l}</div>
          </div>
        ))}
      </div>

      <ObDots total={11} index={6} dark />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 8 — Track Your Progress
// ─────────────────────────────────────────────────────────────────
function S8_Track() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={8} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          Track Your Progress
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          The Quran,<br/><span style={{ fontStyle: 'italic' }}>verse</span> by verse.
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: OB.ink2, lineHeight: 1.5, maxWidth: 300 }}>
          Mark each verse as you go. Bookmark, replay, and pick up exactly where you left off.
        </div>
      </div>

      {/* verse row preview */}
      <div style={{
        position: 'absolute', top: 360, left: 22, right: 22,
        background: OB.card, borderRadius: 18, padding: 16,
        border: `1px solid ${OB.hairSoft}`,
        boxShadow: '0 10px 26px rgba(60,40,20,0.05)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
          <div style={{
            width: 30, height: 30, borderRadius: 8,
            background: OB.ink, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: OB.serif, fontSize: 14, fontStyle: 'italic',
          }}>1</div>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <div style={{ width: 30, height: 30, borderRadius: 999, border: `1px solid ${OB.hair}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: OB.ink2 }}>
              <ObIcon name="play" size={11} />
            </div>
            <div style={{ width: 30, height: 30, borderRadius: 999, border: `1px solid ${OB.hair}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: OB.ink2 }}>
              <ObIcon name="heart" size={13} stroke={1.8} />
            </div>
            <div style={{
              width: 30, height: 30, borderRadius: 9, background: OB.accent, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <ObIcon name="check" size={14} stroke={2.4} color="#fff" />
            </div>
          </div>
        </div>

        <div style={{
          fontFamily: OB.arabic, fontSize: 26, lineHeight: 1.7,
          textAlign: 'center', color: OB.ink, direction: 'rtl',
          marginTop: 8, marginBottom: 12,
        }}>
          بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
        </div>

        <div style={{
          fontFamily: OB.serif, fontStyle: 'italic', fontSize: 14, lineHeight: 1.4,
          textAlign: 'center', color: OB.ink2,
        }}>
          “In the name of Allah, the Most Gracious, the Most Merciful.”
        </div>
      </div>

      {/* surah progress bar */}
      <div style={{
        position: 'absolute', top: 590, left: 22, right: 22,
        background: OB.card, borderRadius: 16, padding: 14,
        border: `1px solid ${OB.hairSoft}`,
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
          <div style={{ fontSize: 13.5, fontWeight: 700 }}>Al-Baqarah · The Cow</div>
          <div style={{ fontSize: 12, color: OB.ink3, fontWeight: 600 }}>153 / 286</div>
        </div>
        <div style={{ height: 6, background: OB.hairSoft, borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ width: '53%', height: '100%', background: OB.accent, borderRadius: 999 }} />
        </div>
        <div style={{ marginTop: 8, fontSize: 11, color: OB.ink3, fontWeight: 600 }}>
          53% complete · last read 4 minutes ago
        </div>
      </div>

      <ObDots total={11} index={7} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 9 — Stay Motivated (streaks)
// ─────────────────────────────────────────────────────────────────
function S9_Motivate() {
  // 7-day mini calendar
  const days = ['M','T','W','T','F','S','S'];
  const filled = [1,1,1,1,1,1,0]; // 6 of 7
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      <ObStatus />
      <ObTopChrome step={9} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          Stay Motivated
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          A <span style={{ fontStyle: 'italic' }}>little</span> light,<br/>kept burning daily.
        </div>
      </div>

      {/* streak hero */}
      <div style={{
        position: 'absolute', top: 290, left: 22, right: 22,
        background: OB.ink, borderRadius: 22, padding: 22,
        color: '#fff', overflow: 'hidden', position: 'absolute',
      }}>
        <div style={{
          position: 'absolute', top: -40, right: -40,
          width: 200, height: 200, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(209,122,72,0.5), transparent 60%)',
        }} />
        <div style={{ position: 'relative' }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 2, color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase' }}>Current streak</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 6 }}>
            <div style={{ fontFamily: OB.serif, fontSize: 84, lineHeight: 1, color: '#fff', letterSpacing: -3 }}>12</div>
            <div style={{ fontFamily: OB.serif, fontStyle: 'italic', fontSize: 22, color: 'rgba(255,255,255,0.6)' }}>days</div>
          </div>

          {/* 7-day strip */}
          <div style={{ display: 'flex', gap: 6, marginTop: 18 }}>
            {days.map((d, i) => (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5 }}>
                <div style={{
                  width: '100%', aspectRatio: '1/1', borderRadius: 9,
                  background: filled[i] ? OB.accent : 'rgba(255,255,255,0.06)',
                  border: filled[i] ? 'none' : '1px solid rgba(255,255,255,0.12)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {filled[i] ? <ObIcon name="check" size={13} stroke={2.5} color="#fff" /> : null}
                </div>
                <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(255,255,255,0.45)' }}>{d}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* three stat row */}
      <div style={{
        position: 'absolute', top: 540, left: 22, right: 22,
        display: 'flex', gap: 8,
      }}>
        {[
          { v: '247', l: 'Verses read',   icon: 'book'  },
          { v: '8',   l: 'Badges earned', icon: 'star'  },
          { v: '3',   l: 'Surahs done',   icon: 'check' },
        ].map((s, i) => (
          <div key={i} style={{
            flex: 1, padding: 14, borderRadius: 16,
            background: OB.card, border: `1px solid ${OB.hairSoft}`,
            boxShadow: '0 4px 14px rgba(60,40,20,0.04)',
          }}>
            <div style={{ color: OB.accent, marginBottom: 6 }}>
              <ObIcon name={s.icon} size={15} stroke={1.8} />
            </div>
            <div style={{ fontFamily: OB.serif, fontSize: 26, letterSpacing: -0.5 }}>{s.v}</div>
            <div style={{ fontSize: 10.5, color: OB.ink3, fontWeight: 600, letterSpacing: 0.4 }}>{s.l}</div>
          </div>
        ))}
      </div>

      <div style={{
        position: 'absolute', left: 22, right: 22, bottom: 70,
        textAlign: 'center', fontSize: 12.5, color: OB.ink3,
      }}>
        You can enable progress reminders later in Settings.
      </div>

      <ObDots total={11} index={8} />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 10 — Special Seasons (warm dark)
// ─────────────────────────────────────────────────────────────────
function S10_Seasons() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.inkBgWarm, color: '#fff', fontFamily: OB.sans,
    }}>
      <div style={{
        position: 'absolute', top: '8%', right: '-10%',
        width: 380, height: 380, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(209,122,72,0.32), transparent 60%)',
        filter: 'blur(6px)',
      }} />
      {[...Array(12)].map((_, i) => (
        <div key={i} style={{
          position: 'absolute',
          top: `${((i*47)+11)%70}%`, left: `${((i*79)+17)%100}%`,
          width: i%3===0 ? 2.5 : 1.4, height: i%3===0 ? 2.5 : 1.4,
          borderRadius: '50%', background: '#fff',
          opacity: 0.12 + ((i%5)*0.04),
        }} />
      ))}

      <ObStatus dark />
      <ObTopChrome dark step={10} />

      <div style={{ position: 'absolute', top: 124, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: 'rgba(255,255,255,0.55)', textTransform: 'uppercase' }}>
          Special Seasons
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 38, lineHeight: 1.05, letterSpacing: -0.8 }}>
          For the <span style={{ fontStyle: 'italic' }}>blessed</span><br/>months ahead.
        </div>
      </div>

      {/* Ramadan featured card */}
      <div style={{
        position: 'absolute', top: 308, left: 22, right: 22,
        background: 'rgba(255,255,255,0.06)', borderRadius: 22,
        border: '1px solid rgba(255,255,255,0.10)',
        backdropFilter: 'blur(10px)', padding: 22,
        overflow: 'hidden',
      }}>
        {/* crescent decoration */}
        <div style={{
          position: 'absolute', top: -28, right: -10,
          width: 110, height: 110, borderRadius: '50%',
          background: 'rgba(232,148,100,0.12)',
        }} />
        <div style={{
          position: 'absolute', top: -18, right: 0,
          width: 90, height: 90, borderRadius: '50%',
          background: OB.inkBgWarm,
          boxShadow: 'inset 14px 6px 0 0 rgba(232,148,100,0.4)',
        }} />

        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 6,
          padding: '4px 10px', borderRadius: 999, background: OB.accent, color: '#fff',
          fontSize: 10.5, fontWeight: 700, letterSpacing: 1.6, textTransform: 'uppercase',
          marginBottom: 14,
        }}>
          <ObIcon name="moon" size={11} stroke={2} color="#fff" /> Seasonal
        </div>
        <div style={{ fontFamily: OB.serif, fontStyle: 'italic', fontSize: 28, letterSpacing: -0.5 }}>Ramadan Journey</div>
        <div style={{ marginTop: 6, fontSize: 13, color: 'rgba(255,255,255,0.7)', lineHeight: 1.45 }}>
          Daily duas from Mafatih al-Jinan, curated verses with tafsir, and a 30-day reflection track.
        </div>

        <div style={{
          marginTop: 16, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.10)',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.55)', fontWeight: 600 }}>Arrives 1 Ramadan</div>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 6,
            color: OB.accent, fontSize: 12, fontWeight: 700,
          }}>
            Preview <ObIcon name="arrow" size={11} stroke={2.4} />
          </div>
        </div>
      </div>

      {/* upcoming list */}
      <div style={{
        position: 'absolute', top: 562, left: 28, right: 28,
      }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2.4, color: 'rgba(255,255,255,0.45)', textTransform: 'uppercase', marginBottom: 10 }}>
          Coming this year
        </div>
        {[
          { name: 'Muharram',      sub: 'Commemorations & Ashura'    },
          { name: 'Dhul-Hijjah',   sub: 'Hajj season & ten days'     },
          { name: 'Rajab & Shaʿban', sub: 'Preparations for Ramadan' },
        ].map((s, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '11px 0',
            borderBottom: i < 2 ? '1px solid rgba(255,255,255,0.08)' : 'none',
          }}>
            <div style={{ fontFamily: OB.serif, fontStyle: 'italic', fontSize: 16, color: OB.accent, width: 18 }}>·</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>{s.name}</div>
              <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.5)' }}>{s.sub}</div>
            </div>
          </div>
        ))}
      </div>

      <ObDots total={11} index={9} dark />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// SLIDE 11 — Begin Your Journey (sign up)
// ─────────────────────────────────────────────────────────────────
function S11_Begin() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: OB.paper, color: OB.ink, fontFamily: OB.sans,
    }}>
      {/* subtle glow */}
      <div style={{
        position: 'absolute', top: '32%', left: '50%', transform: 'translateX(-50%)',
        width: 460, height: 460, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(209,122,72,0.16), transparent 60%)',
        filter: 'blur(8px)',
      }} />

      <ObStatus />
      <ObTopChrome step={11} showSkip={false} />

      <div style={{ position: 'absolute', top: 124, left: 28, right: 28 }}>
        <div style={{ fontFamily: OB.sans, fontSize: 11, fontWeight: 700, letterSpacing: 3, color: OB.accentDeep, textTransform: 'uppercase' }}>
          One last step
        </div>
        <div style={{ marginTop: 12, fontFamily: OB.serif, fontSize: 44, lineHeight: 1.0, letterSpacing: -1.2 }}>
          Begin your<br/><span style={{ fontStyle: 'italic' }}>journey.</span>
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: OB.ink2, lineHeight: 1.5, maxWidth: 300 }}>
          Save bookmarks, sync reading progress, and carry the Quran with you on any device.
        </div>
      </div>

      {/* CTAs */}
      <div style={{
        position: 'absolute', left: 22, right: 22, top: 366,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        <div style={{
          background: OB.ink, color: '#fff', borderRadius: 16,
          padding: '16px 0', textAlign: 'center', fontSize: 15, fontWeight: 700,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
        }}>
          <ObIcon name="apple" size={18} color="#fff" />
          Continue with Apple
        </div>
        <div style={{
          background: '#fff', color: OB.ink, borderRadius: 16,
          padding: '16px 0', textAlign: 'center', fontSize: 15, fontWeight: 700,
          border: `1px solid ${OB.hair}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
        }}>
          <ObIcon name="user" size={16} stroke={1.8} color={OB.ink} />
          Create account with email
        </div>

        <div style={{
          display: 'flex', alignItems: 'center', gap: 12, margin: '6px 0',
        }}>
          <div style={{ flex: 1, height: 1, background: OB.hair }} />
          <div style={{ fontSize: 11, color: OB.ink3, letterSpacing: 1.5, fontWeight: 600, textTransform: 'uppercase' }}>or</div>
          <div style={{ flex: 1, height: 1, background: OB.hair }} />
        </div>

        <div style={{
          background: 'transparent', color: OB.ink2, borderRadius: 16,
          padding: '13px 0', textAlign: 'center', fontSize: 14, fontWeight: 600,
        }}>
          Continue as guest
        </div>
      </div>

      {/* benefits */}
      <div style={{
        position: 'absolute', left: 28, right: 28, bottom: 96,
        textAlign: 'center',
      }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2.4, color: OB.accentDeep, textTransform: 'uppercase', marginBottom: 8 }}>
          Account benefits
        </div>
        <div style={{ fontSize: 12.5, color: OB.ink3, lineHeight: 1.5 }}>
          Sync bookmarks across iPhone, iPad, and the web — and never lose your reading progress.
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 50, textAlign: 'center',
        fontSize: 10.5, color: OB.ink3, letterSpacing: 0.3,
      }}>
        By continuing you agree to our <span style={{ textDecoration: 'underline' }}>Terms</span> and <span style={{ textDecoration: 'underline' }}>Privacy Policy</span>.
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// Phone frame
// ─────────────────────────────────────────────────────────────────
function PhoneFrame({ children }) {
  return (
    <div style={{
      width: PHONE_W, height: PHONE_H, borderRadius: 50, overflow: 'hidden',
      background: '#000', boxShadow: '0 30px 60px rgba(40,20,10,0.18)',
      border: '8px solid #1a1410', position: 'relative',
    }}>
      <div style={{ position: 'absolute', inset: 0, borderRadius: 42, overflow: 'hidden' }}>
        {children}
      </div>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 10, left: '50%', transform: 'translateX(-50%)',
        width: 110, height: 32, borderRadius: 999, background: '#000', zIndex: 50,
      }} />
    </div>
  );
}

// Export variant A screens + phone frame to global scope so the
// app entrypoint and variant B can reuse the frame.
Object.assign(window, {
  S1_Cover, S2_Promise, S3_Layers, S4_Daily, S5_Gems, S6_Quiz,
  S7_Result, S8_Track, S9_Motivate, S10_Seasons, S11_Begin,
  PhoneFrame, PHONE_W, PHONE_H,
});
