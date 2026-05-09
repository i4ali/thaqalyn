// Dark theme — full app mocks (Home, Today, Surah Detail, Explore, Progress)
// Inspired by the "Verse Hero" direction: dark warm-black surfaces,
// peach accent #E89464, soft warm glow, sparse stars, glass surfaces.

const PHONE_W = 360;
const PHONE_H = 780;

const D = {
  // Surfaces
  bg: '#120D0A',          // base near-black warm
  bgTop: '#1B1410',       // gradient top
  bgGlow: '#3A2118',      // accent glow center
  surface: 'rgba(255,255,255,0.06)',   // glass card
  surface2: 'rgba(255,255,255,0.04)',  // recessed
  border: 'rgba(255,255,255,0.10)',
  borderStrong: 'rgba(255,255,255,0.16)',
  divider: 'rgba(255,255,255,0.07)',
  // Ink
  ink: '#FFFFFF',
  ink2: 'rgba(255,255,255,0.72)',
  ink3: 'rgba(255,255,255,0.48)',
  ink4: 'rgba(255,255,255,0.32)',
  // Accents
  accent: '#E89464',
  accentDeep: '#D17A48',
  accentSoft: 'rgba(232,148,100,0.14)',
  // Semantic (muted for dark)
  green: '#5BC58A',
  red: '#F47875',
  blue: '#6FA5E8',
  yellow: '#F2C969',
  lilac: '#B8A6D9',
  // Fonts
  font: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", "SF Pro", system-ui, sans-serif',
  arabic: '"Amiri", "Scheherazade New", "Times New Roman", serif',
};

// Shared dark screen background
function DarkBg({ children, glowOpacity = 0.32, stars = 18 }) {
  return (
    <div style={{ width: '100%', height: '100%', position: 'relative', overflow: 'hidden', fontFamily: D.font, color: D.ink, background: D.bg }}>
      {/* base radial */}
      <div style={{ position: 'absolute', inset: 0, background: `radial-gradient(120% 80% at 50% 5%, ${D.bgTop} 0%, ${D.bg} 55%, #0B0705 100%)` }} />
      {/* warm glow */}
      <div style={{ position: 'absolute', top: -100, left: -60, width: 360, height: 360, borderRadius: '50%', background: `radial-gradient(circle, rgba(232,148,100,${glowOpacity}), transparent 65%)`, filter: 'blur(2px)' }} />
      <div style={{ position: 'absolute', bottom: -160, right: -100, width: 360, height: 360, borderRadius: '50%', background: `radial-gradient(circle, rgba(184,166,217,0.16), transparent 65%)` }} />
      {/* stars */}
      {[...Array(stars)].map((_, i) => (
        <div key={i} style={{
          position: 'absolute',
          top: `${(i * 47) % 90}%`, left: `${(i * 79) % 100}%`,
          width: i % 3 === 0 ? 2.5 : 1.5, height: i % 3 === 0 ? 2.5 : 1.5,
          borderRadius: '50%', background: '#fff', opacity: 0.10 + ((i % 5) * 0.05),
        }} />
      ))}
      <div style={{ position: 'relative', zIndex: 1, height: '100%' }}>{children}</div>
    </div>
  );
}

function Icon({ name, size = 20, stroke = 1.8 }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'home': return <svg {...p}><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></svg>;
    case 'sparkle': return <svg {...p}><path d="M12 3l1.8 4.6L18 9l-4.2 1.4L12 15l-1.8-4.6L6 9l4.2-1.4L12 3z"/><path d="M19 16l.7 1.7L21 18l-1.3.3L19 20l-.7-1.7L17 18l1.3-.3L19 16z"/></svg>;
    case 'rings': return <svg {...p}><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5.5"/></svg>;
    case 'sun': return <svg {...p}><path d="M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5.6 5.6 4.2 4.2M19.8 19.8l-1.4-1.4M5.6 18.4l-1.4 1.4M19.8 4.2l-1.4 1.4"/></svg>;
    case 'moon': return <svg {...p}><path d="M20 14.5A8 8 0 0 1 9.5 4 8 8 0 1 0 20 14.5z"/></svg>;
    case 'play': return <svg {...p} fill="currentColor" stroke="none"><path d="M7 5l12 7-12 7V5z"/></svg>;
    case 'pause': return <svg {...p} fill="currentColor" stroke="none"><rect x="6" y="5" width="4" height="14"/><rect x="14" y="5" width="4" height="14"/></svg>;
    case 'arrow': return <svg {...p}><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>;
    case 'arrowL': return <svg {...p}><path d="M19 12H5"/><path d="M11 6l-6 6 6 6"/></svg>;
    case 'search': return <svg {...p}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>;
    case 'bell': return <svg {...p}><path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2H4.5L6 16z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>;
    case 'bookmark': return <svg {...p}><path d="M6 3h12v18l-6-4-6 4V3z"/></svg>;
    case 'leaf': return <svg {...p}><path d="M5 19c0-9 6-15 15-15 0 9-6 15-15 15z"/><path d="M5 19l7-7"/></svg>;
    case 'quote': return <svg {...p}><path d="M7 7h4v4H7zM7 11c0 3 1 4 3 5"/><path d="M15 7h4v4h-4zM15 11c0 3 1 4 3 5"/></svg>;
    case 'heart': return <svg {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/></svg>;
    case 'chevR': return <svg {...p}><path d="M9 6l6 6-6 6"/></svg>;
    case 'check': return <svg {...p}><path d="M5 12l4 4 10-10"/></svg>;
    case 'list': return <svg {...p}><path d="M4 6h16M4 12h16M4 18h16"/></svg>;
    case 'compass': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5 5-2z" fill="currentColor"/></svg>;
    case 'volume': return <svg {...p}><path d="M5 9v6h4l5 4V5L9 9H5z"/><path d="M16 8a5 5 0 0 1 0 8"/></svg>;
    case 'settings': return <svg {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1A1.7 1.7 0 0 0 9 19.4a1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1A1.7 1.7 0 0 0 4.6 9a1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/></svg>;
    case 'flame': return <svg {...p}><path d="M12 3c1 4 4 5 4 9a4 4 0 1 1-8 0c0-2 1-3 1-5 1 1 1 2 3-4z"/></svg>;
    case 'badge': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M9 12l2 2 4-4"/></svg>;
    default: return null;
  }
}

function StatusBar({ time = '9:41' }) {
  const c = '#fff';
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 24px 6px', color: c, fontWeight: 600, fontSize: 14 }}>
      <span>{time}</span>
      <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
        <svg width="16" height="10" viewBox="0 0 16 10"><rect x="0" y="6" width="3" height="4" rx="0.6" fill={c}/><rect x="4.5" y="4" width="3" height="6" rx="0.6" fill={c}/><rect x="9" y="2" width="3" height="8" rx="0.6" fill={c}/><rect x="13.5" y="0" width="3" height="10" rx="0.6" fill={c}/></svg>
        <svg width="14" height="10" viewBox="0 0 17 12"><path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/><path d="M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.1 5.2 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z" fill={c}/><circle cx="8.5" cy="10.5" r="1.5" fill={c}/></svg>
        <svg width="22" height="11" viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="20" height="9" rx="1.5" fill={c}/><path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

function TabBar({ active = 'today' }) {
  const items = [
    { id: 'home',     label: 'Home',     icon: 'home' },
    { id: 'today',    label: 'Today',    icon: 'sun' },
    { id: 'explore',  label: 'Explore',  icon: 'sparkle' },
    { id: 'progress', label: 'Progress', icon: 'rings' },
  ];
  return (
    <div style={{ position: 'absolute', left: 12, right: 12, bottom: 14, display: 'flex', justifyContent: 'center', pointerEvents: 'none' }}>
      <div style={{
        display: 'flex', gap: 4, padding: '8px 12px',
        background: 'rgba(20,14,10,0.78)', border: `1px solid ${D.border}`,
        borderRadius: 999, backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
        boxShadow: '0 8px 24px rgba(0,0,0,0.45)',
      }}>
        {items.map(it => {
          const a = it.id === active;
          return (
            <div key={it.id} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              padding: '6px 12px', minWidth: 56, color: a ? D.accent : D.ink3,
            }}>
              <div style={{
                background: a ? D.accentSoft : 'transparent',
                borderRadius: 999, padding: '4px 10px', display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name={it.icon} size={20} stroke={2} />
              </div>
              <div style={{ fontSize: 10.5, fontWeight: 600, marginTop: 2 }}>{it.label}</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// Common pill / chip helpers
function GlassPill({ children, style = {} }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '6px 11px', borderRadius: 999,
      background: D.surface, border: `1px solid ${D.border}`, color: D.ink2,
      fontSize: 12, fontWeight: 600, ...style,
    }}>{children}</div>
  );
}

function StreakPill({ value }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: '6px 11px', borderRadius: 999,
      background: D.surface, border: `1px solid ${D.border}`,
      color: D.accent, fontWeight: 700, fontSize: 13,
    }}>
      <span>🔥</span><span>{value}</span>
    </div>
  );
}

function CircleBtn({ children, size = 38, onClick, style = {} }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 999,
      background: D.surface, border: `1px solid ${D.border}`,
      display: 'flex', alignItems: 'center', justifyContent: 'center', color: D.ink, ...style,
    }}>{children}</div>
  );
}

// ============================================================
// 1. HOME — surah list (dark)
// ============================================================
function ScreenHome() {
  const surahs = [
    { n: 1,  en: 'Al-Fātiḥa',   tr: 'The Opening',         ar: 'سُورَةُ ٱلْفَاتِحَةِ', verses: 7,   place: 'Meccan',  pct: 42 },
    { n: 2,  en: 'Al-Baqara',   tr: 'The Cow',             ar: 'سُورَةُ البَقَرَةِ',  verses: 286, place: 'Medinan', pct: 53 },
    { n: 3,  en: 'Aal-i-Imrān', tr: 'Family of Imran',     ar: 'سُورَةُ آلِ عِمْرَانَ', verses: 200, place: 'Medinan' },
    { n: 4,  en: 'An-Nisāʾ',    tr: 'The Women',           ar: 'سُورَةُ النِّسَاءِ',  verses: 176, place: 'Medinan' },
  ];
  return (
    <DarkBg>
      <StatusBar />
      {/* Header */}
      <div style={{ padding: '6px 22px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
          <div style={{ width: 38, height: 38, borderRadius: 999, background: `linear-gradient(135deg, ${D.accent}, ${D.accentDeep})`, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 14 }}>Y</div>
          <div style={{ display: 'flex', gap: 8 }}>
            <StreakPill value={12} />
            <CircleBtn><Icon name="bell" size={17}/></CircleBtn>
          </div>
        </div>
        <div style={{ fontSize: 14, color: D.ink2, fontWeight: 500 }}>Assalāmu ʿalaykum 🌙</div>
        <div style={{ fontSize: 30, fontWeight: 800, letterSpacing: -0.5, marginTop: 2 }}>The Holy Quran</div>

        {/* Search */}
        <div style={{
          marginTop: 16, display: 'flex', alignItems: 'center', gap: 10,
          background: D.surface, border: `1px solid ${D.border}`,
          borderRadius: 14, padding: '12px 14px', color: D.ink3,
        }}>
          <Icon name="search" size={17}/>
          <span style={{ fontSize: 14 }}>Search surahs…</span>
        </div>
      </div>

      {/* Q&A banner */}
      <div style={{ margin: '14px 18px 0' }}>
        <div style={{
          background: `linear-gradient(135deg, rgba(232,148,100,0.18), rgba(184,166,217,0.10))`,
          border: `1px solid ${D.border}`,
          borderRadius: 18, padding: '14px 14px 14px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
            <div style={{ width: 38, height: 38, borderRadius: 12, background: D.accent, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 18 }}>?</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>Questions & Answers</div>
              <div style={{ fontSize: 11.5, color: D.ink3, marginTop: 1 }}>Quranic answers to life&apos;s biggest questions</div>
            </div>
            <Icon name="chevR" size={16}/>
          </div>
        </div>
      </div>

      {/* List */}
      <div style={{ padding: '14px 18px 100px', display: 'flex', flexDirection: 'column', gap: 10, overflow: 'auto', maxHeight: 'calc(100% - 320px)' }}>
        {surahs.map(s => (
          <div key={s.n} style={{
            background: D.surface, border: `1px solid ${D.border}`, borderRadius: 18,
            padding: 14, display: 'flex', alignItems: 'center', gap: 12,
            backdropFilter: 'blur(14px)', WebkitBackdropFilter: 'blur(14px)',
          }}>
            <div style={{
              width: 44, height: 44, borderRadius: 999,
              background: D.accentSoft, color: D.accent, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 800, fontSize: 16, border: `1px solid ${D.border}`,
            }}>{s.n}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 700 }}>{s.en}</div>
              <div style={{ fontSize: 11.5, color: D.ink3, marginTop: 1 }}>{s.tr}</div>
              <div style={{ display: 'flex', gap: 10, fontSize: 10.5, color: D.ink4, marginTop: 5 }}>
                <span>📖 {s.verses} verses</span>
                <span>📍 {s.place}</span>
                {s.pct && <span style={{ color: D.green, fontWeight: 700 }}>📗 {s.pct}%</span>}
              </div>
            </div>
            <div style={{ fontFamily: D.arabic, fontSize: 18, color: D.ink2, textAlign: 'right' }}>{s.ar}</div>
          </div>
        ))}
      </div>

      <TabBar active="home" />
    </DarkBg>
  );
}

// ============================================================
// 2. TODAY — verse hero + continue card
// ============================================================
function ScreenToday() {
  return (
    <DarkBg glowOpacity={0.36}>
      <StatusBar />
      <div style={{ padding: '6px 22px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.5, color: D.ink3 }}>MON · 15 RABI&apos; AL-AWWAL</div>
          <div style={{ fontSize: 26, fontWeight: 800, letterSpacing: -0.5, marginTop: 4 }}>Today</div>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <StreakPill value={12}/>
          <CircleBtn><Icon name="bell" size={17}/></CircleBtn>
        </div>
      </div>

      <div style={{ padding: '32px 28px 0' }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '5px 11px', borderRadius: 999, border: `1px solid ${D.borderStrong}`, color: D.ink2, fontSize: 11, fontWeight: 700, letterSpacing: 1.3, marginBottom: 22 }}>
          <span style={{ color: D.accent }}>✦</span> VERSE OF THE DAY
        </div>
        <div style={{
          fontFamily: D.arabic, fontSize: 32, lineHeight: 1.7, textAlign: 'right', direction: 'rtl',
          color: '#fff', textShadow: '0 0 32px rgba(232,148,100,0.32)', marginBottom: 18,
        }}>
          وَمَن يَتَوَكَّلْ عَلَى ٱللَّهِ فَهُوَ حَسْبُهُۥ
        </div>
        <div style={{ fontSize: 16, lineHeight: 1.5, color: D.ink2, fontStyle: 'italic', letterSpacing: -0.1 }}>
          “And whoever places their trust in Allah — He is sufficient for them.”
        </div>
        <div style={{ fontSize: 12.5, color: D.ink3, marginTop: 10, fontWeight: 600, letterSpacing: 0.3 }}>At-Talaq · 65:3</div>

        <div style={{ display: 'flex', gap: 8, marginTop: 22 }}>
          <button style={{ flex: 1, background: D.accent, color: '#fff', border: 0, borderRadius: 14, padding: '14px 0', fontWeight: 700, fontSize: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
            <Icon name="play" size={13}/> Listen · 0:42
          </button>
          <button style={{ width: 50, background: D.surface, color: '#fff', border: `1px solid ${D.border}`, borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="bookmark" size={18}/>
          </button>
          <button style={{ width: 50, background: D.surface, color: '#fff', border: `1px solid ${D.border}`, borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="leaf" size={18}/>
          </button>
        </div>
      </div>

      {/* Continue card */}
      <div style={{ position: 'absolute', left: 14, right: 14, bottom: 88, background: D.surface, border: `1px solid ${D.border}`, borderRadius: 22, padding: 14, backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: D.accent, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 16 }}>2</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1.2, color: D.ink3 }}>CONTINUE</div>
            <div style={{ fontSize: 15, fontWeight: 700, marginTop: 1 }}>Al-Baqara · v.153</div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: D.accent }}>53%</div>
            <div style={{ width: 60, height: 4, background: 'rgba(255,255,255,0.10)', borderRadius: 999, marginTop: 4, overflow: 'hidden' }}>
              <div style={{ width: '53%', height: '100%', background: D.accent }}/>
            </div>
          </div>
          <div style={{ width: 36, height: 36, borderRadius: 999, background: '#fff', color: D.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: 4 }}>
            <Icon name="arrow" size={16} stroke={2.4}/>
          </div>
        </div>
      </div>

      <TabBar active="today"/>
    </DarkBg>
  );
}

// ============================================================
// 3. SURAH DETAIL — verse reader
// ============================================================
function ScreenSurah() {
  return (
    <DarkBg glowOpacity={0.22} stars={10}>
      <StatusBar />
      {/* Top header */}
      <div style={{ padding: '4px 18px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <CircleBtn><Icon name="arrowL" size={17} stroke={2.2}/></CircleBtn>
          <div style={{ display: 'flex', gap: 8 }}>
            <CircleBtn><Icon name="search" size={17}/></CircleBtn>
            <CircleBtn><Icon name="settings" size={17}/></CircleBtn>
          </div>
        </div>

        {/* Surah hero */}
        <div style={{ textAlign: 'center', marginTop: 18 }}>
          <div style={{ fontFamily: D.arabic, fontSize: 36, color: '#fff', lineHeight: 1.2, textShadow: '0 0 24px rgba(232,148,100,0.3)' }}>سُورَةُ البَقَرَةِ</div>
          <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.4, marginTop: 6 }}>Al-Baqara</div>
          <div style={{ fontSize: 12, color: D.ink3, marginTop: 2 }}>The Cow · Medinan · 286 verses</div>

          {/* progress + actions */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: 6, marginTop: 14 }}>
            <GlassPill style={{ color: D.accent }}>📖 v.153 / 286</GlassPill>
            <GlassPill>53%</GlassPill>
          </div>
        </div>

        {/* Action row */}
        <div style={{ display: 'flex', gap: 8, marginTop: 16 }}>
          <button style={{ flex: 1, background: D.accent, color: '#fff', border: 0, borderRadius: 12, padding: '11px 0', fontWeight: 700, fontSize: 13, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
            <Icon name="play" size={12}/> Play surah
          </button>
          <button style={{ background: D.surface, border: `1px solid ${D.border}`, color: D.ink, borderRadius: 12, padding: '11px 14px', fontWeight: 700, fontSize: 13, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon name="badge" size={13}/> Quiz
          </button>
        </div>
      </div>

      {/* Verses */}
      <div style={{ padding: '18px 18px 100px', display: 'flex', flexDirection: 'column', gap: 14, overflow: 'auto', maxHeight: 'calc(100% - 360px)' }}>
        {/* Active verse */}
        <div style={{
          background: 'linear-gradient(180deg, rgba(232,148,100,0.10), rgba(232,148,100,0.04))',
          border: `1px solid rgba(232,148,100,0.32)`,
          borderRadius: 22, padding: 16,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 28, height: 28, borderRadius: 999, background: D.accent, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 12 }}>153</div>
              <div style={{ fontSize: 11, color: D.ink3, fontWeight: 600, letterSpacing: 0.3 }}>NOW READING</div>
            </div>
            <div style={{ display: 'flex', gap: 6, color: D.ink2 }}>
              <Icon name="bookmark" size={16}/>
              <Icon name="volume" size={16}/>
            </div>
          </div>
          <div style={{ fontFamily: D.arabic, fontSize: 24, lineHeight: 1.9, textAlign: 'right', direction: 'rtl', color: '#fff' }}>
            يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱسْتَعِينُوا۟ بِٱلصَّبْرِ وَٱلصَّلَوٰةِ ۚ إِنَّ ٱللَّهَ مَعَ ٱلصَّـٰبِرِينَ
          </div>
          <div style={{ fontSize: 13.5, color: D.ink2, lineHeight: 1.55, marginTop: 12 }}>
            “O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
            <GlassPill style={{ fontSize: 11 }}><span style={{color:D.accent}}>📜</span> Tafsir</GlassPill>
            <GlassPill style={{ fontSize: 11 }}>Quick overview</GlassPill>
            <GlassPill style={{ fontSize: 11 }}>Notes</GlassPill>
          </div>
        </div>

        {/* Next verses (compact) */}
        {[154, 155].map(v => (
          <div key={v} style={{ background: D.surface, border: `1px solid ${D.border}`, borderRadius: 18, padding: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <div style={{ width: 24, height: 24, borderRadius: 999, background: D.surface2, color: D.ink2, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, border: `1px solid ${D.border}` }}>{v}</div>
              <Icon name="bookmark" size={14} stroke={1.6}/>
            </div>
            <div style={{ fontFamily: D.arabic, fontSize: 20, lineHeight: 1.85, textAlign: 'right', direction: 'rtl', color: D.ink2 }}>
              {v === 154
                ? 'وَلَا تَقُولُوا۟ لِمَن يُقْتَلُ فِى سَبِيلِ ٱللَّهِ أَمْوَٰتٌۢ ۚ بَلْ أَحْيَآءٌۭ'
                : 'وَلَنَبْلُوَنَّكُم بِشَىْءٍۢ مِّنَ ٱلْخَوْفِ وَٱلْجُوعِ'}
            </div>
            <div style={{ fontSize: 12.5, color: D.ink3, marginTop: 8 }}>
              {v === 154 ? '“Do not say of those slain in Allah\u2019s path: \u201CThey are dead\u201D — rather, they are alive…”' : '“We will surely test you with something of fear and hunger…”'}
            </div>
          </div>
        ))}
      </div>

      <TabBar active="home"/>
    </DarkBg>
  );
}

// ============================================================
// 4. EXPLORE — feature tiles
// ============================================================
function ScreenExplore() {
  const tiles = [
    { title: 'Questions & Answers',   sub: '120+ topics',   icon: 'sparkle', color: D.accent },
    { title: 'Prophetic Stories',     sub: '25 stories',    icon: 'book',     color: D.lilac },
    { title: 'Du\u2019as',            sub: '60 supplications',icon: 'quote',  color: D.green },
    { title: 'Life Moments',          sub: 'Verses for moments',icon: 'heart',color: D.red },
    { title: 'Prophetic Parallels',   sub: 'Cross-references',  icon: 'compass', color: D.blue },
    { title: 'Fasting Verses',        sub: 'Themed study',  icon: 'moon',     color: D.yellow },
  ];
  return (
    <DarkBg>
      <StatusBar />
      <div style={{ padding: '6px 22px 0' }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.5, color: D.ink3 }}>BROWSE BY THEME</div>
        <div style={{ fontSize: 30, fontWeight: 800, letterSpacing: -0.5, marginTop: 4 }}>Explore</div>
      </div>

      {/* Featured carousel card */}
      <div style={{ margin: '16px 18px 0' }}>
        <div style={{
          background: 'linear-gradient(135deg, rgba(232,148,100,0.32), rgba(184,166,217,0.18))',
          border: `1px solid ${D.border}`,
          borderRadius: 20, padding: 18, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ position: 'absolute', top: -40, right: -30, width: 160, height: 160, borderRadius: '50%', background: 'rgba(255,255,255,0.06)' }}/>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.3, color: D.accent }}>✦ FEATURED THIS WEEK</div>
          <div style={{ fontSize: 19, fontWeight: 800, marginTop: 8, letterSpacing: -0.3 }}>The 99 Names of Allah</div>
          <div style={{ fontSize: 12.5, color: D.ink2, marginTop: 4, maxWidth: 240 }}>A guided study of Asmā\u02BCu\u2019l-Ḥusnā with verse references.</div>
          <button style={{ marginTop: 14, background: '#fff', color: D.bg, border: 0, borderRadius: 999, padding: '8px 14px', fontWeight: 700, fontSize: 12, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            Begin <Icon name="arrow" size={12}/>
          </button>
        </div>
      </div>

      {/* Tile grid */}
      <div style={{ padding: '14px 18px 100px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, overflow: 'auto', maxHeight: 'calc(100% - 320px)' }}>
        {tiles.map((t, i) => (
          <div key={i} style={{
            background: D.surface, border: `1px solid ${D.border}`, borderRadius: 18,
            padding: 14, height: 116, display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 11,
              background: `${t.color}26`, color: t.color,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              border: `1px solid ${t.color}33`,
            }}>
              <Icon name={t.icon} size={18}/>
            </div>
            <div>
              <div style={{ fontSize: 13.5, fontWeight: 700, lineHeight: 1.2 }}>{t.title}</div>
              <div style={{ fontSize: 11, color: D.ink3, marginTop: 3 }}>{t.sub}</div>
            </div>
          </div>
        ))}
      </div>

      <TabBar active="explore"/>
    </DarkBg>
  );
}

// ============================================================
// 5. PROGRESS — activity rings
// ============================================================
function Ring({ pct, size, stroke, color }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  return (
    <svg width={size} height={size} style={{ position: 'absolute', inset: 0, margin: 'auto' }}>
      <circle cx={size/2} cy={size/2} r={r} stroke={`${color}33`} strokeWidth={stroke} fill="none"/>
      <circle cx={size/2} cy={size/2} r={r} stroke={color} strokeWidth={stroke} fill="none"
        strokeDasharray={c} strokeDashoffset={c * (1 - pct/100)}
        strokeLinecap="round" transform={`rotate(-90 ${size/2} ${size/2})`}
        style={{ filter: `drop-shadow(0 0 8px ${color}88)` }}/>
    </svg>
  );
}

function ScreenProgress() {
  return (
    <DarkBg glowOpacity={0.22}>
      <StatusBar />
      <div style={{ padding: '6px 22px 0' }}>
        <div style={{ fontSize: 30, fontWeight: 800, letterSpacing: -0.5 }}>Your Progress</div>
        <div style={{ fontSize: 13.5, color: D.ink3, marginTop: 2 }}>Track your Quran journey</div>
      </div>

      {/* Rings card */}
      <div style={{ margin: '20px 18px 0', background: D.surface, border: `1px solid ${D.border}`, borderRadius: 24, padding: 20, height: 280, position: 'relative' }}>
        <div style={{ position: 'relative', width: 220, height: 220, margin: '0 auto' }}>
          <Ring pct={28}  size={220} stroke={14} color={D.red}/>
          <Ring pct={62}  size={184} stroke={14} color={D.green}/>
          <Ring pct={45}  size={148} stroke={14} color={D.blue}/>
          <Ring pct={78}  size={112} stroke={14} color={D.yellow}/>
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textShadow: '0 0 20px rgba(0,0,0,0.5)' }}>
            <div style={{ fontSize: 32, fontWeight: 800, color: '#fff', letterSpacing: -0.5 }}>14%</div>
            <div style={{ fontSize: 12, color: D.ink3 }}>Quran</div>
          </div>
        </div>
      </div>

      {/* Legend */}
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '14px 26px 0', fontSize: 11.5, color: D.ink2 }}>
        {[['Quran',D.red],['Surahs',D.green],['Quizzes',D.blue],['Ramadan',D.yellow]].map(([l, c]) => (
          <div key={l} style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <div style={{ width: 7, height: 7, borderRadius: 999, background: c, boxShadow: `0 0 8px ${c}aa` }}/>
            <span style={{ fontWeight: 600 }}>{l}</span>
          </div>
        ))}
      </div>

      {/* Stat tiles */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, padding: '14px 18px 100px' }}>
        {[
          { icon: 'book', color: D.red, n: '847', l: 'Verses Read', s: 'of 6,236' },
          { icon: 'badge', color: D.green, n: '12', l: 'Surahs Complete', s: 'of 114' },
          { icon: 'sparkle', color: D.blue, n: '34', l: 'Quizzes Done', s: '92% avg' },
          { icon: 'flame', color: D.yellow, n: '12', l: 'Day streak', s: 'Best: 27' },
        ].map((t, i) => (
          <div key={i} style={{ background: D.surface, border: `1px solid ${D.border}`, borderRadius: 18, padding: 14 }}>
            <div style={{ width: 28, height: 28, borderRadius: 9, background: `${t.color}26`, color: t.color, border: `1px solid ${t.color}33`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name={t.icon} size={15}/>
            </div>
            <div style={{ fontSize: 26, fontWeight: 800, marginTop: 10, letterSpacing: -0.5 }}>{t.n}</div>
            <div style={{ fontSize: 12.5, fontWeight: 700, marginTop: 0 }}>{t.l}</div>
            <div style={{ fontSize: 11, color: D.ink3, marginTop: 1 }}>{t.s}</div>
          </div>
        ))}
      </div>

      <TabBar active="progress"/>
    </DarkBg>
  );
}

// ── Phone wrapper ────────────────────────────────────────────────
function Phone({ children }) {
  return (
    <div style={{
      width: PHONE_W, height: PHONE_H, borderRadius: 44, overflow: 'hidden',
      background: '#000', boxShadow: '0 30px 60px rgba(0,0,0,0.45)',
      border: '8px solid #0a0807', position: 'relative',
    }}>
      <div style={{ position: 'absolute', inset: 0, borderRadius: 36, overflow: 'hidden' }}>{children}</div>
      <div style={{ position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)', width: 110, height: 26, borderRadius: 999, background: '#000', zIndex: 50 }}/>
    </div>
  );
}

function App() {
  return (
    <DesignCanvas title="althaqalayn · Dark theme" subtitle="Verse-Hero direction extended across the app">
      <DCSection id="dark" title="Dark theme · all screens" subtitle="Same warm-black aesthetic, peach accent, glass surfaces.">
        <DCArtboard id="home"     label="Home"          width={PHONE_W + 16} height={PHONE_H + 16}><Phone><ScreenHome/></Phone></DCArtboard>
        <DCArtboard id="today"    label="Today"         width={PHONE_W + 16} height={PHONE_H + 16}><Phone><ScreenToday/></Phone></DCArtboard>
        <DCArtboard id="surah"    label="Surah Detail"  width={PHONE_W + 16} height={PHONE_H + 16}><Phone><ScreenSurah/></Phone></DCArtboard>
        <DCArtboard id="explore"  label="Explore"       width={PHONE_W + 16} height={PHONE_H + 16}><Phone><ScreenExplore/></Phone></DCArtboard>
        <DCArtboard id="progress" label="Progress"      width={PHONE_W + 16} height={PHONE_H + 16}><Phone><ScreenProgress/></Phone></DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
