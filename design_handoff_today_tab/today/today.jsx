// Today screen mocks — 3 variations for althaqalayn

const PHONE_W = 360;
const PHONE_H = 780;

// ── Brand tokens (from app screenshots) ─────────────────────────
const T = {
  bg1: '#F2EBF6',
  bg2: '#FFF7EE',
  ink: '#221C18',
  ink2: '#5A4A40',
  ink3: '#9A8C82',
  card: '#FFFFFF',
  accent: '#E89464',
  accentDeep: '#D17A48',
  accentSoft: '#FCE6D5',
  green: '#3FB16A',
  red: '#F25F5C',
  blue: '#3D88E0',
  yellow: '#F6C84C',
  lilac: '#B8A6D9',
  font: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", "SF Pro", system-ui, sans-serif',
  arabic: '"Amiri", "Scheherazade New", "Times New Roman", serif',
};

// Shared bg gradient — matches the app
const screenBg = {
  width: '100%', height: '100%',
  background: `linear-gradient(180deg, ${T.bg1} 0%, ${T.bg2} 100%)`,
  position: 'relative', overflow: 'hidden',
  fontFamily: T.font, color: T.ink,
};

// Tiny SF-style line icon — uses currentColor
function Icon({ name, size = 20, stroke = 1.8 }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'home': return <svg {...p}><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></svg>;
    case 'sparkle': return <svg {...p}><path d="M12 3l1.8 4.6L18 9l-4.2 1.4L12 15l-1.8-4.6L6 9l4.2-1.4L12 3z"/><path d="M19 16l.7 1.7L21 18l-1.3.3L19 20l-.7-1.7L17 18l1.3-.3L19 16z"/></svg>;
    case 'rings': return <svg {...p}><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5.5"/></svg>;
    case 'moon': return <svg {...p}><path d="M20 14.5A8 8 0 0 1 9.5 4 8 8 0 1 0 20 14.5z"/></svg>;
    case 'sun': return <svg {...p}><path d="M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5.6 5.6 4.2 4.2M19.8 19.8l-1.4-1.4M5.6 18.4l-1.4 1.4M19.8 4.2l-1.4 1.4"/></svg>;
    case 'play': return <svg {...p} fill="currentColor" stroke="none"><path d="M7 5l12 7-12 7V5z"/></svg>;
    case 'arrow': return <svg {...p}><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>;
    case 'flame': return <svg {...p}><path d="M12 3c1 4 4 5 4 9a4 4 0 1 1-8 0c0-2 1-3 1-5 1 1 1 2 3-4z"/></svg>;
    case 'book': return <svg {...p}><path d="M4 5a2 2 0 0 1 2-2h12v16H6a2 2 0 0 0-2 2V5z"/><path d="M4 19a2 2 0 0 1 2-2h12"/></svg>;
    case 'bookmark': return <svg {...p}><path d="M6 3h12v18l-6-4-6 4V3z"/></svg>;
    case 'bell': return <svg {...p}><path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2H4.5L6 16z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>;
    case 'quote': return <svg {...p}><path d="M7 7h4v4H7zM7 11c0 3 1 4 3 5"/><path d="M15 7h4v4h-4zM15 11c0 3 1 4 3 5"/></svg>;
    case 'leaf': return <svg {...p}><path d="M5 19c0-9 6-15 15-15 0 9-6 15-15 15z"/><path d="M5 19l7-7"/></svg>;
    case 'compass': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5 5-2z" fill="currentColor"/></svg>;
    case 'heart': return <svg {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/></svg>;
    case 'check': return <svg {...p}><path d="M5 12l4 4 10-10"/></svg>;
    case 'pause': return <svg {...p} fill="currentColor" stroke="none"><rect x="6" y="5" width="4" height="14"/><rect x="14" y="5" width="4" height="14"/></svg>;
    case 'list': return <svg {...p}><path d="M4 6h16M4 12h16M4 18h16"/></svg>;
    case 'plus': return <svg {...p}><path d="M12 5v14M5 12h14"/></svg>;
    case 'chevR': return <svg {...p}><path d="M9 6l6 6-6 6"/></svg>;
    default: return null;
  }
}

// Status bar — minimal iOS look
function StatusBar({ time = '9:41', dark = false }) {
  const c = dark ? '#fff' : T.ink;
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 24px 6px', color: c, fontWeight: 600, fontSize: 14, letterSpacing: 0.1 }}>
      <span>{time}</span>
      <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
        <svg width="16" height="10" viewBox="0 0 16 10"><rect x="0" y="6" width="3" height="4" rx="0.6" fill={c}/><rect x="4.5" y="4" width="3" height="6" rx="0.6" fill={c}/><rect x="9" y="2" width="3" height="8" rx="0.6" fill={c}/><rect x="13.5" y="0" width="3" height="10" rx="0.6" fill={c}/></svg>
        <svg width="14" height="10" viewBox="0 0 17 12"><path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/><path d="M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.1 5.2 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z" fill={c}/><circle cx="8.5" cy="10.5" r="1.5" fill={c}/></svg>
        <svg width="22" height="11" viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="20" height="9" rx="1.5" fill={c}/><path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

// Bottom tab bar with Today selected
function TabBar({ active = 'today', dark = false }) {
  const items = [
    { id: 'home',    label: 'Home',    icon: 'home' },
    { id: 'today',   label: 'Today',   icon: 'sun' },
    { id: 'explore', label: 'Explore', icon: 'sparkle' },
    { id: 'progress',label: 'Progress',icon: 'rings' },
  ];
  return (
    <div style={{ position: 'absolute', left: 12, right: 12, bottom: 14, display: 'flex', justifyContent: 'center', pointerEvents: 'none' }}>
      <div style={{
        display: 'flex', gap: 4, padding: '8px 12px', background: dark ? 'rgba(30,24,20,0.85)' : 'rgba(255,255,255,0.92)',
        borderRadius: 999, backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
        boxShadow: '0 8px 24px rgba(60,40,30,0.12), 0 0 0 1px rgba(0,0,0,0.04)',
      }}>
        {items.map(it => {
          const a = it.id === active;
          return (
            <div key={it.id} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
              padding: '6px 12px', minWidth: 56,
              color: a ? T.accent : (dark ? 'rgba(255,255,255,0.55)' : T.ink2),
            }}>
              <div style={{
                background: a ? T.accentSoft : 'transparent',
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

// ── Common shared elements ──────────────────────────────────────
function HijriPill({ children }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '6px 12px', borderRadius: 999, background: '#fff', border: '1px solid rgba(0,0,0,0.05)',
      color: T.ink2, fontSize: 12, fontWeight: 600, letterSpacing: 0.2,
      boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
    }}>{children}</div>
  );
}

function StreakBadge({ value }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5, padding: '6px 11px', borderRadius: 999,
      background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
      color: T.accentDeep, fontWeight: 700, fontSize: 13,
    }}>
      <span style={{ color: '#F58A2B' }}>🔥</span>
      <span>{value}</span>
    </div>
  );
}

// =================================================================
// VARIATION A — Card Stack
// =================================================================
function VariationA() {
  return (
    <div style={screenBg}>
      <StatusBar />

      {/* Header */}
      <div style={{ padding: '8px 22px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 }}>
          <HijriPill>15 RABI&apos; AL-AWWAL · MON</HijriPill>
          <div style={{ display: 'flex', gap: 8 }}>
            <StreakBadge value={12} />
          </div>
        </div>

        <div style={{ fontSize: 14, color: T.ink2, fontWeight: 500, marginBottom: 2 }}>Assalāmu ʿalaykum, Yusuf 🌙</div>
        <div style={{ fontSize: 32, fontWeight: 800, letterSpacing: -0.6, lineHeight: 1.1 }}>Today</div>
      </div>

      {/* Daily message banner */}
      <div style={{ margin: '20px 18px 0', position: 'relative' }}>
        <div style={{
          background: `linear-gradient(135deg, #F4B188 0%, ${T.accent} 60%, ${T.accentDeep} 100%)`,
          borderRadius: 22, padding: '18px 18px 18px 18px', color: '#fff', position: 'relative', overflow: 'hidden',
          boxShadow: '0 12px 28px rgba(209,122,72,0.28)',
        }}>
          {/* decorative crescent */}
          <div style={{ position: 'absolute', top: -30, right: -30, width: 120, height: 120, borderRadius: '50%', background: 'rgba(255,255,255,0.12)' }} />
          <div style={{ position: 'absolute', top: -20, right: -10, width: 110, height: 110, borderRadius: '50%', background: 'transparent', boxShadow: 'inset 16px 8px 0 0 rgba(255,255,255,0.18)' }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8, opacity: 0.92 }}>
            <Icon name="sparkle" size={14} stroke={2.4} />
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.3 }}>A REMINDER FOR TODAY</div>
          </div>
          <div style={{ fontSize: 19, fontWeight: 700, lineHeight: 1.3, letterSpacing: -0.2, maxWidth: 270 }}>
            “Verily, with hardship comes ease.”
          </div>
          <div style={{ fontSize: 12.5, opacity: 0.85, marginTop: 6 }}>Surah Ash-Sharh · 94:6</div>
        </div>
      </div>

      {/* Continue reading hero */}
      <div style={{ margin: '14px 18px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', padding: '0 4px 8px' }}>
          <div style={{ fontSize: 13, fontWeight: 700, color: T.ink2, letterSpacing: 0.4, textTransform: 'uppercase' }}>Continue reading</div>
          <div style={{ fontSize: 12, color: T.ink3 }}>4 min ago</div>
        </div>
        <div style={{
          background: '#fff', borderRadius: 22, padding: 16,
          boxShadow: '0 6px 18px rgba(60,40,30,0.06), 0 0 0 1px rgba(0,0,0,0.03)',
        }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center', marginBottom: 12 }}>
            <div style={{
              width: 48, height: 48, borderRadius: 14, background: T.accentSoft,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: T.accentDeep, fontWeight: 800, fontSize: 18,
            }}>2</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 16, fontWeight: 700 }}>Al-Baqara</div>
              <div style={{ fontSize: 12, color: T.ink3 }}>Verse 153 of 286 · The Cow</div>
            </div>
            <div style={{ fontFamily: T.arabic, fontSize: 22, color: T.ink }}>البقرة</div>
          </div>

          {/* Verse preview */}
          <div style={{ background: '#FBF6F0', borderRadius: 14, padding: '14px 14px 12px', marginBottom: 12 }}>
            <div style={{ fontFamily: T.arabic, fontSize: 19, lineHeight: 1.7, textAlign: 'right', color: T.ink, direction: 'rtl' }}>
              يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱسْتَعِينُوا۟ بِٱلصَّبْرِ وَٱلصَّلَوٰةِ
            </div>
            <div style={{ fontSize: 12.5, color: T.ink2, lineHeight: 1.5, marginTop: 8 }}>
              “O you who have believed, seek help through patience and prayer…”
            </div>
          </div>

          {/* Progress + CTA */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ flex: 1 }}>
              <div style={{ height: 6, background: '#F1ECE6', borderRadius: 999, overflow: 'hidden' }}>
                <div style={{ width: '53%', height: '100%', background: T.accent, borderRadius: 999 }} />
              </div>
              <div style={{ fontSize: 11, color: T.ink3, marginTop: 4, fontWeight: 600 }}>53% complete</div>
            </div>
            <button style={{
              border: 0, background: T.ink, color: '#fff', borderRadius: 999, padding: '10px 16px',
              fontWeight: 700, fontSize: 13, display: 'flex', alignItems: 'center', gap: 6, cursor: 'pointer',
            }}>
              <Icon name="play" size={12} /> Resume
            </button>
          </div>
        </div>
      </div>

      {/* Mini cards row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, margin: '12px 18px 0' }}>
        <div style={{ background: '#fff', borderRadius: 18, padding: 14, boxShadow: '0 4px 14px rgba(60,40,30,0.05)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: '#FFF1E2', color: T.accentDeep, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="quote" size={15} />
            </div>
            <div style={{ fontSize: 12, fontWeight: 700, color: T.ink2 }}>Du&apos;a of the day</div>
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, lineHeight: 1.3 }}>For ease in difficulty</div>
          <div style={{ fontSize: 11, color: T.ink3, marginTop: 2 }}>30 sec</div>
        </div>
        <div style={{ background: '#fff', borderRadius: 18, padding: 14, boxShadow: '0 4px 14px rgba(60,40,30,0.05)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: '#E8F4ED', color: '#2E8B53', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="leaf" size={15} />
            </div>
            <div style={{ fontSize: 12, fontWeight: 700, color: T.ink2 }}>Reflection</div>
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, lineHeight: 1.3 }}>What does sabr mean to you?</div>
          <div style={{ fontSize: 11, color: T.ink3, marginTop: 2 }}>Tap to journal</div>
        </div>
      </div>

      <TabBar active="today" />
    </div>
  );
}

// =================================================================
// VARIATION B — Verse Hero (full-bleed, poetic)
// =================================================================
function VariationB() {
  return (
    <div style={{ ...screenBg, background: '#1A1410' }}>
      <StatusBar dark />

      {/* Hero verse — dark, atmospheric, full-bleed */}
      <div style={{ position: 'absolute', inset: 0, zIndex: 0 }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(120% 80% at 50% 10%, #3A2118 0%, #1A1410 60%, #110B08 100%)' }} />
        {/* warm accent glow */}
        <div style={{ position: 'absolute', top: -80, left: -40, width: 320, height: 320, borderRadius: '50%', background: 'radial-gradient(circle, rgba(232,148,100,0.32), transparent 65%)' }} />
        {/* subtle stars */}
        {[...Array(18)].map((_, i) => (
          <div key={i} style={{
            position: 'absolute',
            top: `${(i * 47) % 70}%`, left: `${(i * 79) % 100}%`,
            width: i % 3 === 0 ? 3 : 2, height: i % 3 === 0 ? 3 : 2,
            borderRadius: '50%', background: '#fff', opacity: 0.15 + ((i % 4) * 0.06),
          }} />
        ))}
      </div>

      <div style={{ position: 'relative', zIndex: 1, color: '#fff', height: '100%', display: 'flex', flexDirection: 'column' }}>
        {/* Header */}
        <div style={{ padding: '6px 22px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.5, color: 'rgba(255,255,255,0.55)' }}>MONDAY · 15 RABI&apos; AL-AWWAL</div>
            <div style={{ fontSize: 26, fontWeight: 800, letterSpacing: -0.5, marginTop: 4 }}>Today</div>
          </div>
          <div style={{
            width: 38, height: 38, borderRadius: 999, background: 'rgba(255,255,255,0.08)',
            border: '1px solid rgba(255,255,255,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: '#fff',
          }}>
            <Icon name="bell" size={18} />
          </div>
        </div>

        {/* Verse of the day */}
        <div style={{ padding: '32px 28px 0', flex: 1 }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '5px 11px', borderRadius: 999, border: '1px solid rgba(255,255,255,0.18)', color: 'rgba(255,255,255,0.85)', fontSize: 11, fontWeight: 700, letterSpacing: 1.3, marginBottom: 22 }}>
            <span style={{ color: T.accent }}>✦</span> VERSE OF THE DAY
          </div>

          <div style={{
            fontFamily: T.arabic, fontSize: 32, lineHeight: 1.7, textAlign: 'right', direction: 'rtl',
            color: '#fff', textShadow: '0 0 30px rgba(232,148,100,0.25)',
            marginBottom: 18,
          }}>
            وَمَن يَتَوَكَّلْ عَلَى ٱللَّهِ فَهُوَ حَسْبُهُۥ
          </div>

          <div style={{ fontSize: 16, lineHeight: 1.5, color: 'rgba(255,255,255,0.92)', fontStyle: 'italic', fontWeight: 400, letterSpacing: -0.1 }}>
            “And whoever places their trust in Allah — He is sufficient for them.”
          </div>
          <div style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.5)', marginTop: 10, fontWeight: 600, letterSpacing: 0.3 }}>
            At-Talaq · 65:3
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 22 }}>
            <button style={{ flex: 1, background: T.accent, color: '#fff', border: 0, borderRadius: 14, padding: '14px 0', fontWeight: 700, fontSize: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, cursor: 'pointer' }}>
              <Icon name="play" size={13} /> Listen · 0:42
            </button>
            <button style={{ width: 50, background: 'rgba(255,255,255,0.08)', color: '#fff', border: '1px solid rgba(255,255,255,0.14)', borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
              <Icon name="bookmark" size={18} />
            </button>
            <button style={{ width: 50, background: 'rgba(255,255,255,0.08)', color: '#fff', border: '1px solid rgba(255,255,255,0.14)', borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
              <Icon name="leaf" size={18} />
            </button>
          </div>
        </div>

        {/* Continue reading — pulled up, light surface */}
        <div style={{
          margin: '0 14px 88px', background: 'rgba(255,255,255,0.06)',
          border: '1px solid rgba(255,255,255,0.10)', borderRadius: 22, padding: 14,
          backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{
              width: 44, height: 44, borderRadius: 12, background: T.accent,
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 800, fontSize: 16,
            }}>2</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1.2, color: 'rgba(255,255,255,0.5)' }}>CONTINUE</div>
              <div style={{ fontSize: 15, fontWeight: 700, color: '#fff', marginTop: 1 }}>Al-Baqara · v.153</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: T.accent }}>53%</div>
              <div style={{ width: 60, height: 4, background: 'rgba(255,255,255,0.1)', borderRadius: 999, marginTop: 4, overflow: 'hidden' }}>
                <div style={{ width: '53%', height: '100%', background: T.accent }} />
              </div>
            </div>
            <div style={{ width: 36, height: 36, borderRadius: 999, background: '#fff', color: T.ink, display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: 4 }}>
              <Icon name="arrow" size={16} stroke={2.4} />
            </div>
          </div>
        </div>
      </div>

      <TabBar active="today" dark />
    </div>
  );
}

// =================================================================
// VARIATION C — Story Feed
// =================================================================
function VariationC() {
  return (
    <div style={screenBg}>
      <StatusBar />

      {/* Header */}
      <div style={{ padding: '4px 20px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontSize: 13, color: T.ink2, fontWeight: 600 }}>Monday, May 9</div>
            <div style={{ fontSize: 28, fontWeight: 800, letterSpacing: -0.5, marginTop: 2 }}>Today</div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <div style={{
              padding: '7px 12px', borderRadius: 999, background: '#fff',
              boxShadow: '0 1px 3px rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: 6,
              fontSize: 12, fontWeight: 700, color: T.accentDeep,
            }}>
              <span>🔥</span> 12 day streak
            </div>
          </div>
        </div>
      </div>

      {/* Story strip — daily intentions / habits */}
      <div style={{ display: 'flex', gap: 10, padding: '16px 20px 4px', overflowX: 'auto' }}>
        {[
          { label: 'Today', sub: 'Verse', color: T.accent, ring: true, icon: 'sparkle' },
          { label: 'Fajr', sub: '5:12', color: T.lilac, done: true, icon: 'moon' },
          { label: 'Dhuhr', sub: '12:34', color: T.yellow, done: true, icon: 'sun' },
          { label: 'Asr', sub: '4:08', color: T.blue, icon: 'sun' },
          { label: 'Maghrib', sub: '7:22', color: T.accentDeep, icon: 'sun' },
        ].map((s, i) => (
          <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5, flexShrink: 0 }}>
            <div style={{
              width: 56, height: 56, borderRadius: '50%',
              padding: s.ring ? 2.5 : 0,
              background: s.ring ? `conic-gradient(${T.accent} 0deg, ${T.accent} 290deg, rgba(0,0,0,0.06) 290deg)` : 'transparent',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <div style={{
                width: '100%', height: '100%', borderRadius: '50%',
                background: '#fff', boxShadow: '0 2px 6px rgba(0,0,0,0.05)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: s.color, position: 'relative',
              }}>
                <Icon name={s.icon} size={22} stroke={2} />
                {s.done && (
                  <div style={{ position: 'absolute', bottom: -2, right: -2, width: 18, height: 18, borderRadius: '50%', background: T.green, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid #fff' }}>
                    <Icon name="check" size={10} stroke={3} />
                  </div>
                )}
              </div>
            </div>
            <div style={{ fontSize: 11, fontWeight: 700, color: T.ink, lineHeight: 1.1 }}>{s.label}</div>
            <div style={{ fontSize: 9.5, color: T.ink3, marginTop: -3 }}>{s.sub}</div>
          </div>
        ))}
      </div>

      {/* Inspiration — rotating */}
      <div style={{ margin: '12px 18px 0' }}>
        <div style={{
          background: '#fff', borderRadius: 20, padding: '16px 16px 14px',
          boxShadow: '0 4px 14px rgba(60,40,30,0.05)',
          borderLeft: `4px solid ${T.accent}`,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
            <div style={{ fontSize: 10.5, fontWeight: 800, letterSpacing: 1.3, color: T.accentDeep }}>✦ A LIGHT FOR TODAY</div>
            <div style={{ display: 'flex', gap: 3 }}>
              {[0,1,2,3,4].map(i => <div key={i} style={{ width: 5, height: 5, borderRadius: '50%', background: i === 0 ? T.accent : '#E5DDD3' }} />)}
            </div>
          </div>
          <div style={{ fontSize: 16, fontWeight: 700, lineHeight: 1.35, letterSpacing: -0.2 }}>
            Trust is a quiet language —<br />the heart speaks it best in patience.
          </div>
          <div style={{ fontSize: 11.5, color: T.ink3, marginTop: 8, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span>Inspired by 65:3</span>
            <span style={{ color: T.accent, fontWeight: 700 }}>Read more →</span>
          </div>
        </div>
      </div>

      {/* Continue reading row */}
      <div style={{ margin: '12px 18px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0 4px 8px', alignItems: 'center' }}>
          <div style={{ fontSize: 12.5, fontWeight: 700, color: T.ink2, letterSpacing: 0.4, textTransform: 'uppercase' }}>Pick up where you left off</div>
        </div>
        <div style={{ background: '#fff', borderRadius: 18, padding: 14, display: 'flex', alignItems: 'center', gap: 12, boxShadow: '0 3px 12px rgba(60,40,30,0.05)' }}>
          <div style={{
            width: 44, height: 56, borderRadius: 8, background: `linear-gradient(160deg, ${T.accentSoft}, ${T.accent})`,
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 800, fontSize: 16, position: 'relative',
            boxShadow: '0 2px 6px rgba(209,122,72,0.3)',
          }}>
            2
            <div style={{ position: 'absolute', bottom: -4, right: -4, padding: '2px 5px', borderRadius: 6, background: T.ink, color: '#fff', fontSize: 8.5, fontWeight: 800, letterSpacing: 0.2 }}>153</div>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 14.5, fontWeight: 700 }}>Al-Baqara · The Cow</div>
            <div style={{ fontSize: 11.5, color: T.ink3, marginTop: 1 }}>Verse 153 · 4 minutes ago</div>
            <div style={{ height: 4, background: '#F2EBE3', borderRadius: 999, marginTop: 7, overflow: 'hidden' }}>
              <div style={{ width: '53%', height: '100%', background: T.accent }} />
            </div>
          </div>
          <div style={{ width: 36, height: 36, borderRadius: 999, background: T.ink, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="play" size={13} />
          </div>
        </div>
      </div>

      {/* Suggested cards */}
      <div style={{ margin: '14px 18px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0 4px 8px' }}>
          <div style={{ fontSize: 12.5, fontWeight: 700, color: T.ink2, letterSpacing: 0.4, textTransform: 'uppercase' }}>For you today</div>
          <div style={{ fontSize: 12, color: T.ink3 }}>3 items</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div style={{ background: '#fff', borderRadius: 14, padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 11 }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: '#E8F4ED', color: '#2E8B53', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="leaf" size={17} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13.5, fontWeight: 700 }}>Reflection prompt</div>
              <div style={{ fontSize: 11, color: T.ink3 }}>What does tawakkul look like in your week?</div>
            </div>
            <Icon name="chevR" size={16} />
          </div>
          <div style={{ background: '#fff', borderRadius: 14, padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 11 }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: '#FFF1E2', color: T.accentDeep, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="quote" size={17} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13.5, fontWeight: 700 }}>Du&apos;a · Ease in difficulty</div>
              <div style={{ fontSize: 11, color: T.ink3 }}>30 sec · Audio + transliteration</div>
            </div>
            <Icon name="chevR" size={16} />
          </div>
        </div>
      </div>

      <TabBar active="today" />
    </div>
  );
}

// ── Render ──────────────────────────────────────────────────────
function Phone({ children }) {
  return (
    <div style={{
      width: PHONE_W, height: PHONE_H, borderRadius: 44, overflow: 'hidden',
      background: '#000', boxShadow: '0 30px 60px rgba(40,20,10,0.18)',
      border: '8px solid #1a1410', position: 'relative',
    }}>
      <div style={{ position: 'absolute', inset: 0, borderRadius: 36, overflow: 'hidden' }}>
        {children}
      </div>
      {/* notch */}
      <div style={{ position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)', width: 110, height: 26, borderRadius: 999, background: '#000', zIndex: 50 }} />
    </div>
  );
}

function App() {
  return (
    <DesignCanvas title="althaqalayn · Today tab" subtitle="Three concepts for picking up reading + a daily uplifting message">
      <DCSection id="today" title="Today screen — concepts" subtitle="Each phone is a tappable artboard. Click ⤢ to focus.">
        <DCArtboard id="A" label="A · Card Stack" width={PHONE_W + 16} height={PHONE_H + 16}>
          <Phone><VariationA /></Phone>
        </DCArtboard>
        <DCArtboard id="B" label="B · Verse Hero (dark)" width={PHONE_W + 16} height={PHONE_H + 16}>
          <Phone><VariationB /></Phone>
        </DCArtboard>
        <DCArtboard id="C" label="C · Story Feed" width={PHONE_W + 16} height={PHONE_H + 16}>
          <Phone><VariationC /></Phone>
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
