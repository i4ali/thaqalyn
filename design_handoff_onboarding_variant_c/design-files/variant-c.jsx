// Variant C — "Native"
// Matches the actual app's warm, inviting aesthetic:
// soft lavender→peach gradient bg, pastel chip icons, big friendly
// bold sans titles, rounded white cards, peach gradient CTA.

const VC = {
  // surfaces
  bgTop: '#F1E9F4',         // pale lavender
  bgMid: '#F8E5D2',         // pale peach
  bgBottom: '#FAF2E8',      // cream
  card: '#FFFFFF',
  cardSoft: 'rgba(255,255,255,0.6)',
  // ink
  ink: '#1F1612',
  ink2: '#5C4D44',
  ink3: '#A0907F',
  hair: 'rgba(31,22,18,0.07)',
  hairSoft: 'rgba(31,22,18,0.04)',
  // chips (pastel bg + saturated icon color)
  chipPeach: '#FCE0CC',   iconPeach: '#C66829',
  chipPlum:  '#EAD8F0',   iconPlum:  '#8C539F',
  chipMint:  '#D6EADF',   iconMint:  '#3B8459',
  chipSky:   '#D8E8F4',   iconSky:   '#3D78B2',
  chipButter:'#F8EAC9',   iconButter:'#B5862A',
  chipRose:  '#F4D8D8',   iconRose:  '#C25656',
  chipMauve: '#E6DDE9',   iconMauve: '#7B6688',
  // accents
  accent: '#E89464',
  accentDeep: '#C66829',
  accentBright: '#F5A877',
  accentSoft: '#FBE0CB',
  // text
  sans: '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", system-ui, sans-serif',
  arabic: '"Amiri", "Scheherazade New", serif',
};

// shared shell — soft warm gradient bg
function VCShell({ children, tilt = 'lavender' }) {
  // tilt = 'lavender' | 'peach' | 'mauve' — slight per-screen hue shift
  const gradients = {
    lavender: `linear-gradient(180deg, ${VC.bgTop} 0%, #F5E8E5 55%, ${VC.bgBottom} 100%)`,
    peach:    `linear-gradient(180deg, #F5E6E6 0%, ${VC.bgMid} 55%, ${VC.bgBottom} 100%)`,
    mauve:    `linear-gradient(180deg, #ECE3F2 0%, #F2E6E8 55%, ${VC.bgBottom} 100%)`,
    sage:     `linear-gradient(180deg, #E6EEEB 0%, #F0EBE2 55%, ${VC.bgBottom} 100%)`,
  };
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      color: VC.ink, fontFamily: VC.sans, background: gradients[tilt] || gradients.lavender,
    }}>
      {/* soft top glow */}
      <div style={{
        position: 'absolute', top: '-10%', left: '50%', transform: 'translateX(-50%)',
        width: 500, height: 400, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(232,148,100,0.18), transparent 60%)',
        filter: 'blur(8px)', pointerEvents: 'none',
      }} />
      {children}
    </div>
  );
}

// Status bar
function VCStatus({ time = '9:41' }) {
  const c = VC.ink;
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: 44,
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '14px 22px 0', color: c, fontWeight: 600, fontSize: 15, zIndex: 20,
    }}>
      <span>{time}</span>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="17" height="11" viewBox="0 0 17 11"><rect x="0" y="7" width="3" height="4" rx="0.6" fill={c}/><rect x="4.5" y="5" width="3" height="6" rx="0.6" fill={c}/><rect x="9" y="3" width="3" height="8" rx="0.6" fill={c}/><rect x="13.5" y="1" width="3" height="10" rx="0.6" fill={c}/></svg>
        <svg width="15" height="11" viewBox="0 0 17 12"><path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/><circle cx="8.5" cy="10.5" r="1.4" fill={c}/></svg>
        <svg width="24" height="11" viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="20" height="9" rx="1.5" fill={c}/><path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

// Skip pill (top-right)
function VCSkip() {
  return (
    <div style={{
      position: 'absolute', top: 56, right: 22, zIndex: 15,
      padding: '8px 16px', borderRadius: 999,
      background: 'rgba(255,255,255,0.7)',
      backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)',
      fontSize: 14, fontWeight: 600, color: VC.ink2,
      boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
    }}>Skip</div>
  );
}

// Page indicator (bottom, native style)
function VCDots({ index = 0, total = 11 }) {
  return (
    <div style={{
      position: 'absolute', left: '50%', transform: 'translateX(-50%)',
      bottom: 24, padding: '8px 12px', borderRadius: 999,
      background: 'rgba(255,255,255,0.6)',
      backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)',
      display: 'flex', gap: 7, alignItems: 'center', zIndex: 10,
    }}>
      {[...Array(total)].map((_, i) => {
        const a = i === index;
        return (
          <div key={i} style={{
            width: a ? 8 : 6, height: a ? 8 : 6, borderRadius: '50%',
            background: a ? VC.ink : 'rgba(31,22,18,0.2)',
          }} />
        );
      })}
    </div>
  );
}

// Chip icon (the pastel rounded-square icon style native to the app)
function VCChip({ chip, color, children, size = 56, radius = 18 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: radius,
      background: chip, color,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>
      {children}
    </div>
  );
}

// Soft glowing hero badge (a chip with a halo)
function VCHero({ chip, color, glow, children }) {
  return (
    <div style={{ position: 'relative', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{
        position: 'absolute', inset: -22, borderRadius: '50%',
        background: `radial-gradient(circle, ${glow || color}38, transparent 65%)`,
        filter: 'blur(6px)',
      }} />
      <VCChip chip={chip} color={color} size={88} radius={28}>
        {children}
      </VCChip>
    </div>
  );
}

// Icon set
function VCIcon({ name, size = 24, stroke = 2, color = 'currentColor', fill = 'none' }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill, stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'book':    return <svg {...p}><path d="M4 5a2 2 0 0 1 2-2h12v16H6a2 2 0 0 0-2 2V5z"/><path d="M4 19a2 2 0 0 1 2-2h12"/></svg>;
    case 'spark':   return <svg {...p} fill={color}><path d="M12 2l2 6 6 2-6 2-2 6-2-6-6-2 6-2 2-6z"/><path d="M19 14l1 3 3 1-3 1-1 3-1-3-3-1 3-1 1-3z" opacity="0.7"/></svg>;
    case 'bell':    return <svg {...p}><path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2H4.5L6 16z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>;
    case 'heart':   return <svg {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/></svg>;
    case 'moon':    return <svg {...p}><path d="M20 14.5A8 8 0 0 1 9.5 4 8 8 0 1 0 20 14.5z"/></svg>;
    case 'flame':   return <svg {...p}><path d="M12 3c1 4 4 5 4 9a4 4 0 1 1-8 0c0-2 1-3 1-5 1 1 1 2 3-4z"/></svg>;
    case 'crown':   return <svg {...p}><path d="M3 8l4 4 5-7 5 7 4-4-2 11H5L3 8z"/></svg>;
    case 'scales':  return <svg {...p}><path d="M12 4v16M5 20h14"/><path d="M5 9l3 7H2l3-7zM19 9l3 7h-6l3-7z"/></svg>;
    case 'play':    return <svg {...p} fill={color} stroke="none"><path d="M7 5l12 7-12 7V5z"/></svg>;
    case 'arrow':   return <svg {...p}><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>;
    case 'check':   return <svg {...p} strokeWidth={2.4}><path d="M5 12l4 4 10-10"/></svg>;
    case 'star':    return <svg {...p}><path d="M12 3l2.7 6.2L21 10l-5 4.5L17.5 21 12 17.5 6.5 21 8 14.5 3 10l6.3-0.8L12 3z"/></svg>;
    case 'globe':   return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/></svg>;
    case 'columns': return <svg {...p}><path d="M4 21h16M4 9l8-5 8 5M6 21V10M10 21V10M14 21V10M18 21V10"/></svg>;
    case 'user':    return <svg {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c1-5 5-7 8-7s7 2 8 7"/></svg>;
    case 'userplus':return <svg {...p}><circle cx="9" cy="8" r="4"/><path d="M2 21c1-5 4-7 7-7s6 2 7 7"/><path d="M18 8v6M15 11h6"/></svg>;
    case 'apple':   return <svg viewBox="0 0 24 24" width={size} height={size} fill={color}><path d="M16.4 12.7c0-2.4 2-3.6 2.1-3.7-1.1-1.7-2.9-1.9-3.5-1.9-1.5-.2-2.9.9-3.7.9-.8 0-1.9-.9-3.2-.8-1.6 0-3.2.9-4 2.4-1.7 3-.4 7.3 1.2 9.7.8 1.2 1.8 2.5 3 2.4 1.2 0 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4.9-1.4 1.3-2.7 1.3-2.8-.1 0-2.6-1-2.6-3.8zM14 5.2c.7-.8 1.1-2 1-3.2-1 .1-2.2.6-2.9 1.5-.6.7-1.2 2-1.1 3.1 1.1.1 2.3-.6 3-1.4z"/></svg>;
    case 'cal':     return <svg {...p}><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></svg>;
    case 'brain':   return <svg {...p}><path d="M9 6c-2 0-3 2-3 3v6c0 2 1 4 3 4M15 6c2 0 3 2 3 3v6c0 2-1 4-3 4M9 6c0-2 1-3 3-3s3 1 3 3M9 12h6M9 16h6"/></svg>;
    case 'chart':   return <svg {...p}><rect x="4" y="11" width="4" height="9"/><rect x="10" y="7" width="4" height="13"/><rect x="16" y="3" width="4" height="17"/></svg>;
    case 'trophy':  return <svg {...p}><path d="M8 4h8v5a4 4 0 0 1-8 0V4z"/><path d="M5 6H2v2a3 3 0 0 0 3 3M19 6h3v2a3 3 0 0 1-3 3M9 14h6M8 20h8M12 14v6"/></svg>;
    case 'mountain':return <svg {...p}><path d="M3 20l5-9 4 6 3-5 6 8H3z"/></svg>;
    case 'water':   return <svg {...p}><path d="M12 3s-6 7-6 12a6 6 0 0 0 12 0c0-5-6-12-6-12z"/></svg>;
    default: return null;
  }
}

// Bottom CTA — peach gradient pill, full-width
function VCCta({ children, icon = null, secondary = false, ghost = false }) {
  if (ghost) return (
    <div style={{
      padding: '15px 0', textAlign: 'center', fontSize: 15, fontWeight: 600, color: VC.ink2,
    }}>{children}</div>
  );
  if (secondary) return (
    <div style={{
      background: VC.card, color: VC.ink, borderRadius: 18, padding: '17px 0',
      textAlign: 'center', fontSize: 15.5, fontWeight: 700,
      border: `1px solid ${VC.hair}`, boxShadow: '0 1px 3px rgba(0,0,0,0.03)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
    }}>{icon}{children}</div>
  );
  return (
    <div style={{
      background: `linear-gradient(180deg, ${VC.accentBright}, ${VC.accentDeep})`,
      color: '#fff', borderRadius: 18, padding: '17px 0', textAlign: 'center',
      fontSize: 15.5, fontWeight: 700,
      boxShadow: '0 10px 24px rgba(198,104,41,0.35), inset 0 1px 0 rgba(255,255,255,0.3)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
    }}>{icon}{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────────
// C1 — Welcome / Hadith of Thaqalayn
// ─────────────────────────────────────────────────────────────────
function C1_Cover() {
  return (
    <VCShell tilt="peach">
      <VCStatus />
      <VCSkip />

      {/* Hero arabic mark */}
      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <div style={{
            position: 'absolute', inset: '-30%', borderRadius: '50%',
            background: 'radial-gradient(circle, rgba(232,148,100,0.34), transparent 65%)',
            filter: 'blur(10px)',
          }} />
          <div style={{
            position: 'relative',
            fontFamily: VC.arabic, fontSize: 96, fontWeight: 700, color: VC.ink,
            letterSpacing: -2, lineHeight: 1,
          }}>ثقلين</div>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 246, left: 0, right: 0, textAlign: 'center',
        fontSize: 11.5, fontWeight: 700, letterSpacing: 3.4, color: VC.iconPeach, textTransform: 'uppercase',
      }}>The Two Weighty Things</div>

      <div style={{
        position: 'absolute', top: 290, left: 28, right: 28, textAlign: 'center',
      }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          Welcome to Thaqalayn
        </div>
        <div style={{ marginTop: 10, fontSize: 15, color: VC.ink2, lineHeight: 1.45, maxWidth: 290, margin: '10px auto 0' }}>
          The Quran and the wisdom of the Ahlul Bayt, made for everyday companionship.
        </div>
      </div>

      {/* Hadith card */}
      <div style={{
        position: 'absolute', top: 432, left: 22, right: 22,
        background: VC.card, borderRadius: 24, padding: 22,
        boxShadow: '0 10px 30px rgba(60,40,20,0.07)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
          <VCChip chip={VC.chipPeach} color={VC.iconPeach} size={32} radius={10}>
            <VCIcon name="spark" size={15} stroke={2.2} />
          </VCChip>
          <div style={{ fontSize: 11.5, fontWeight: 700, letterSpacing: 2, color: VC.iconPeach, textTransform: 'uppercase' }}>
            Hadith of Thaqalayn
          </div>
        </div>

        <div style={{
          fontFamily: VC.arabic, fontSize: 20, lineHeight: 1.85,
          color: VC.ink, direction: 'rtl', textAlign: 'center',
        }}>
          إنّي تاركٌ فيكم الثقلين<br/>
          كتاب الله وعترتي أهلَ بيتي
        </div>

        <div style={{ height: 1, background: VC.hair, margin: '14px 0' }} />

        <div style={{ fontSize: 14, lineHeight: 1.45, color: VC.ink2, textAlign: 'center' }}>
          “I am leaving among you two weighty things — the Book of Allah and the people of my household.”
        </div>

        <div style={{
          marginTop: 12, textAlign: 'center',
          fontSize: 11, fontWeight: 600, letterSpacing: 1.5, color: VC.ink3, textTransform: 'uppercase',
        }}>— Prophet Muhammad ﷺ</div>
      </div>

      {/* CTA */}
      <div style={{ position: 'absolute', left: 22, right: 22, bottom: 78 }}>
        <VCCta icon={<VCIcon name="arrow" size={14} stroke={2.6} color="#fff" />}>Begin the journey</VCCta>
      </div>
      <VCDots index={0} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C2 — Promise
// ─────────────────────────────────────────────────────────────────
function C2_Promise() {
  const features = [
    { chip: VC.chipPeach,  ic: VC.iconPeach,  icon: 'book',    title: 'Complete Quranic text', sub: 'with English & Urdu translation' },
    { chip: VC.chipPlum,   ic: VC.iconPlum,   icon: 'spark',   title: '5 layers of commentary', sub: 'authentic Shia scholarship' },
    { chip: VC.chipButter, ic: VC.iconButter, icon: 'bell',    title: 'Daily verses',           sub: 'aligned with the Islamic calendar' },
    { chip: VC.chipRose,   ic: VC.iconRose,   icon: 'heart',   title: 'Sync bookmarks',         sub: 'across iPhone, iPad and the web' },
  ];
  return (
    <VCShell tilt="lavender">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPeach} color={VC.iconPeach} glow={VC.accent}>
          <VCIcon name="book" size={38} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          Wisdom at your fingertips
        </div>
        <div style={{ marginTop: 10, fontSize: 14.5, color: VC.ink2, lineHeight: 1.45, maxWidth: 300, margin: '10px auto 0' }}>
          Everything you need to read, reflect, and grow — in one calm companion.
        </div>
      </div>

      {/* feature rows */}
      <div style={{
        position: 'absolute', top: 392, left: 22, right: 22,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        {features.map((f, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 14,
            background: VC.card, borderRadius: 18, padding: '12px 14px',
            boxShadow: '0 2px 8px rgba(60,40,20,0.04)',
            border: `1px solid ${VC.hairSoft}`,
          }}>
            <VCChip chip={f.chip} color={f.ic} size={42} radius={12}>
              <VCIcon name={f.icon} size={20} stroke={2} />
            </VCChip>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14.5, fontWeight: 700, color: VC.ink, letterSpacing: -0.2 }}>{f.title}</div>
              <div style={{ fontSize: 12, color: VC.ink3, marginTop: 1 }}>{f.sub}</div>
            </div>
          </div>
        ))}
      </div>

      <VCDots index={1} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C3 — Five Layers
// ─────────────────────────────────────────────────────────────────
function C3_Layers() {
  const layers = [
    { chip: VC.chipSky,    ic: VC.iconSky,    icon: 'columns', name: 'Foundation',   sub: 'Simple explanations & history' },
    { chip: VC.chipPlum,   ic: VC.iconPlum,   icon: 'book',    name: 'Classical Shia',  sub: 'Tabatabai, Tabrisi, al-Tusi' },
    { chip: VC.chipMint,   ic: VC.iconMint,   icon: 'globe',   name: 'Contemporary', sub: 'Modern & scientific perspectives' },
    { chip: VC.chipPeach,  ic: VC.iconPeach,  icon: 'star',    name: 'Ahlul Bayt',   sub: 'Hadith from the 14 Infallibles' },
    { chip: VC.chipMauve,  ic: VC.iconMauve,  icon: 'scales',  name: 'Comparative',  sub: 'Balanced Shia & Sunni scholarship' },
  ];
  return (
    <VCShell tilt="mauve">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPlum} color={VC.iconPlum} glow="#9764A8">
          <VCIcon name="columns" size={36} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          5 Layers of Wisdom
        </div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>Tap each layer to explore</div>
      </div>

      {/* layer rows */}
      <div style={{
        position: 'absolute', top: 350, left: 22, right: 22,
        display: 'flex', flexDirection: 'column', gap: 8,
      }}>
        {layers.map((l, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 14,
            background: VC.card, borderRadius: 18, padding: '12px 14px',
            boxShadow: '0 2px 8px rgba(60,40,20,0.04)',
            border: `1px solid ${VC.hairSoft}`,
          }}>
            <VCChip chip={l.chip} color={l.ic} size={42} radius={12}>
              <VCIcon name={l.icon} size={20} stroke={2} />
            </VCChip>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: VC.ink, letterSpacing: -0.2 }}>{l.name}</div>
              <div style={{ fontSize: 12, color: VC.ink3, marginTop: 1 }}>{l.sub}</div>
            </div>
            <div style={{ color: VC.ink3 }}>
              <VCIcon name="arrow" size={14} stroke={2.4} />
            </div>
          </div>
        ))}
      </div>

      <VCDots index={2} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C4 — Daily Companion
// ─────────────────────────────────────────────────────────────────
function C4_Daily() {
  return (
    <VCShell tilt="peach">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPeach} color={VC.iconPeach} glow={VC.accent}>
          <VCIcon name="bell" size={38} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          Your Daily Companion
        </div>
        <div style={{ marginTop: 10, fontSize: 14.5, color: VC.ink2 }}>
          Start each day with a meaningful verse
        </div>
      </div>

      {/* verse card */}
      <div style={{
        position: 'absolute', top: 358, left: 22, right: 22,
        background: VC.card, borderRadius: 22, padding: 20,
        boxShadow: '0 10px 26px rgba(60,40,20,0.06)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
          <div>
            <div style={{ fontSize: 11.5, fontWeight: 700, letterSpacing: 1.6, color: VC.ink3, textTransform: 'uppercase' }}>Verse of the Day</div>
            <div style={{ fontSize: 16, fontWeight: 700, color: VC.ink, marginTop: 2, letterSpacing: -0.2 }}>Dhul-Qaʿdah</div>
          </div>
          <VCChip chip={VC.chipButter} color={VC.iconButter} size={32} radius={10}>
            <VCIcon name="star" size={15} stroke={2} fill={VC.iconButter} color={VC.iconButter} />
          </VCChip>
        </div>

        <div style={{
          fontFamily: VC.arabic, fontSize: 22, lineHeight: 1.85,
          color: VC.ink, direction: 'rtl', textAlign: 'right',
          paddingBottom: 12, borderBottom: `1px solid ${VC.hair}`,
        }}>
          وَأَذِّن فِي ٱلنَّاسِ بِٱلْحَجِّ يَأْتُوكَ رِجَالًا
        </div>

        <div style={{ marginTop: 14, fontSize: 14, lineHeight: 1.45, color: VC.ink2 }}>
          “And proclaim to the people the pilgrimage; they will come to you on foot and on every lean camel.”
        </div>

        <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ fontSize: 12, color: VC.ink3, fontWeight: 600 }}>Surah 22, Verse 27</div>
          <div style={{
            padding: '6px 12px', borderRadius: 999, background: VC.chipPeach, color: VC.iconPeach,
            fontSize: 11, fontWeight: 700, letterSpacing: 0.3,
          }}>Call to pilgrimage</div>
        </div>
      </div>

      {/* secondary info */}
      <div style={{ position: 'absolute', left: 22, right: 22, top: 612, display: 'flex', alignItems: 'center', gap: 12 }}>
        <VCChip chip={VC.chipMauve} color={VC.iconMauve} size={32} radius={9}>
          <VCIcon name="cal" size={15} stroke={2} />
        </VCChip>
        <div style={{ flex: 1, fontSize: 12.5, color: VC.ink2, lineHeight: 1.4 }}>
          Verses are carefully selected for each Islamic month, so scripture meets you in season.
        </div>
      </div>

      {/* CTA */}
      <div style={{ position: 'absolute', left: 22, right: 22, bottom: 78 }}>
        <VCCta icon={<VCIcon name="bell" size={15} stroke={2} color="#fff" />}>Enable Daily Verses</VCCta>
      </div>

      <VCDots index={3} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C5 — Gems
// ─────────────────────────────────────────────────────────────────
function C5_Gems() {
  return (
    <VCShell tilt="lavender">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipButter} color={VC.iconButter} glow="#C49431">
          <VCIcon name="spark" size={40} stroke={2} fill={VC.iconButter} color={VC.iconButter} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>Gems</div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>Precious insights unveiled</div>
      </div>

      {/* verse card */}
      <div style={{
        position: 'absolute', top: 348, left: 22, right: 22,
        background: VC.card, borderRadius: 22, padding: 20,
        boxShadow: '0 10px 26px rgba(60,40,20,0.06)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <div style={{
            width: 36, height: 36, borderRadius: '50%',
            background: `linear-gradient(135deg, ${VC.iconPlum}, ${VC.iconSky})`,
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, fontWeight: 800, letterSpacing: -0.5,
          }}>255</div>
          <div style={{ fontSize: 16, fontWeight: 800, color: VC.ink, letterSpacing: -0.3 }}>Al-Baqarah 255</div>
        </div>

        <div style={{
          fontFamily: VC.arabic, fontSize: 22, lineHeight: 1.8,
          color: VC.ink, direction: 'rtl', textAlign: 'right',
        }}>
          ٱلْقَيُّومُ ٱلْحَىُّ لَا إِلَٰهَ إِلَّا هُوَ ٱللَّهُ
        </div>

        {/* gem tags */}
        <div style={{ marginTop: 14, display: 'flex', flexWrap: 'wrap', gap: 7 }}>
          {[
            { label: 'The Throne Verse', icon: 'crown', chip: VC.chipPlum,   ic: VC.iconPlum },
            { label: 'The Ever-Living',  icon: 'spark', chip: VC.chipMint,   ic: VC.iconMint },
            { label: 'Cosmic Owners…',   icon: 'globe', chip: VC.chipSky,    ic: VC.iconSky },
            { label: 'The Kursi',        icon: 'star',  chip: VC.chipButter, ic: VC.iconButter },
          ].map((t, i) => (
            <div key={i} style={{
              display: 'inline-flex', alignItems: 'center', gap: 6,
              padding: '6px 11px', borderRadius: 999,
              background: t.chip, color: t.ic,
              fontSize: 11.5, fontWeight: 700,
            }}>
              <VCIcon name={t.icon} size={12} stroke={2.2} fill={t.ic === VC.iconButter ? t.ic : 'none'} />
              {t.label}
            </div>
          ))}
        </div>
      </div>

      {/* insight card */}
      <div style={{
        position: 'absolute', top: 568, left: 22, right: 22,
        background: VC.card, borderRadius: 18, padding: 16,
        boxShadow: '0 6px 18px rgba(60,40,20,0.04)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <VCChip chip={VC.chipPlum} color={VC.iconPlum} size={26} radius={8}>
            <VCIcon name="crown" size={13} stroke={2.2} />
          </VCChip>
          <div style={{ fontSize: 10.5, fontWeight: 800, letterSpacing: 1.8, color: VC.iconPlum, textTransform: 'uppercase' }}>The Throne Verse</div>
        </div>
        <div style={{ fontSize: 13, color: VC.ink2, lineHeight: 1.5 }}>
          The greatest verse in the Quran — describing Allah's absolute sovereignty, knowledge, and power over all creation.
        </div>
      </div>

      <VCDots index={4} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C6 — Quiz
// ─────────────────────────────────────────────────────────────────
function C6_Quiz() {
  const options = [
    { k: 'A', t: 'The physical throne of Allah' },
    { k: 'B', t: "Allah's knowledge and authority", correct: true },
    { k: 'C', t: 'A type of angel' },
    { k: 'D', t: 'The heavens' },
  ];
  return (
    <VCShell tilt="mauve">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPlum} color={VC.iconPlum} glow="#9764A8">
          <VCIcon name="brain" size={36} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          Test Your Knowledge
        </div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>Quizzes for every surah</div>
      </div>

      {/* quiz card */}
      <div style={{
        position: 'absolute', top: 354, left: 22, right: 22,
        background: VC.card, borderRadius: 22, padding: '18px 18px 20px',
        boxShadow: '0 10px 26px rgba(60,40,20,0.06)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ textAlign: 'center', marginBottom: 14 }}>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '5px 11px', borderRadius: 999,
            background: VC.chipSky, color: VC.iconSky,
            fontSize: 12, fontWeight: 700, letterSpacing: 0.3,
          }}>
            <VCIcon name="columns" size={12} stroke={2.2} /> Foundation
          </div>
        </div>

        <div style={{ fontSize: 17, fontWeight: 700, lineHeight: 1.3, color: VC.ink, textAlign: 'center', letterSpacing: -0.2 }}>
          What does 'Kursi' represent in Ayat al-Kursi?
        </div>

        <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {options.map(o => {
            const c = o.correct;
            return (
              <div key={o.k} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '12px 14px', borderRadius: 14,
                background: c ? VC.chipPeach : '#FBF6EE',
                border: `1.5px solid ${c ? VC.accent : VC.hair}`,
              }}>
                <div style={{
                  width: 28, height: 28, borderRadius: '50%',
                  background: c ? VC.accent : 'rgba(255,255,255,0.7)',
                  color: c ? '#fff' : VC.ink2,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 13, fontWeight: 800,
                }}>{c ? <VCIcon name="check" size={14} stroke={2.6} color="#fff" /> : o.k}</div>
                <div style={{ fontSize: 13.5, fontWeight: 600, color: VC.ink, flex: 1 }}>{o.t}</div>
              </div>
            );
          })}
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 68, textAlign: 'center',
        fontSize: 13, color: VC.ink3, fontWeight: 500,
      }}>
        Deepen your understanding through reflection
      </div>

      <VCDots index={5} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C7 — Quiz Result
// ─────────────────────────────────────────────────────────────────
function C7_Result() {
  return (
    <VCShell tilt="mauve">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPlum} color={VC.iconPlum} glow="#9764A8">
          <VCIcon name="brain" size={36} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          Test Your Knowledge
        </div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>Quizzes for every surah</div>
      </div>

      {/* result card */}
      <div style={{
        position: 'absolute', top: 354, left: 22, right: 22,
        background: VC.card, borderRadius: 24, padding: '22px 20px 24px',
        boxShadow: '0 16px 36px rgba(140,83,159,0.18)',
        border: `1.5px solid ${VC.chipPlum}`,
      }}>
        {/* book emblem */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 16 }}>
          <div style={{ position: 'relative', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{
              position: 'absolute', inset: -12, borderRadius: '50%',
              background: 'radial-gradient(circle, rgba(151,100,168,0.30), transparent 65%)',
              filter: 'blur(6px)',
            }} />
            <VCChip chip={VC.chipPlum} color={VC.iconPlum} size={72} radius={24}>
              <VCIcon name="book" size={34} stroke={2} />
            </VCChip>
          </div>
        </div>

        <div style={{ textAlign: 'center', fontSize: 24, fontWeight: 800, color: VC.ink, letterSpacing: -0.4 }}>Scholar Level</div>
        <div style={{ marginTop: 4, textAlign: 'center', fontFamily: VC.arabic, fontSize: 24, color: VC.iconPlum }}>عالم</div>

        {/* score */}
        <div style={{
          marginTop: 16, textAlign: 'center',
          display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 2,
        }}>
          <span style={{
            fontSize: 80, fontWeight: 800, color: VC.iconPlum, letterSpacing: -3, lineHeight: 1,
            background: `linear-gradient(180deg, ${VC.iconPlum}, #6F3F88)`,
            WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text',
          }}>9</span>
          <span style={{ fontSize: 28, color: VC.ink3, fontWeight: 700 }}>/10</span>
        </div>

        <div style={{ marginTop: 4, textAlign: 'center', fontSize: 14, color: VC.ink2 }}>Excellent understanding!</div>

        {/* stat strip */}
        <div style={{ marginTop: 18, display: 'flex', gap: 8 }}>
          {[
            { v: '12',  l: 'Quizzes' },
            { v: '87%', l: 'Avg score' },
            { v: '5',   l: 'Surahs' },
          ].map((s, i) => (
            <div key={i} style={{
              flex: 1, padding: '10px 6px', borderRadius: 14, background: '#FAF4F7',
              textAlign: 'center', border: `1px solid ${VC.hairSoft}`,
            }}>
              <div style={{ fontSize: 18, fontWeight: 800, color: VC.iconPlum, letterSpacing: -0.4 }}>{s.v}</div>
              <div style={{ fontSize: 10, fontWeight: 600, color: VC.ink3, letterSpacing: 0.6, marginTop: 1, textTransform: 'uppercase' }}>{s.l}</div>
            </div>
          ))}
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 28, right: 28, bottom: 70, textAlign: 'center',
        fontSize: 13, color: VC.ink3, fontWeight: 500,
      }}>
        Deepen your understanding through reflection
      </div>

      <VCDots index={6} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C8 — Track Progress
// ─────────────────────────────────────────────────────────────────
function C8_Track() {
  return (
    <VCShell tilt="sage">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipMint} color={VC.iconMint} glow="#3B8459">
          <VCIcon name="check" size={40} stroke={2.6} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>
          Track Your Progress
        </div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>
          Master the Quran, verse by verse
        </div>
      </div>

      {/* bismillah card */}
      <div style={{
        position: 'absolute', top: 354, left: 22, right: 22,
        background: VC.card, borderRadius: 22, padding: 18,
        boxShadow: '0 10px 26px rgba(60,40,20,0.06)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <div style={{
            width: 32, height: 32, borderRadius: '50%',
            background: `linear-gradient(135deg, ${VC.iconPlum}, ${VC.iconSky})`,
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, fontWeight: 800,
          }}>1</div>
          <div style={{ display: 'flex', gap: 14, alignItems: 'center', color: VC.ink3 }}>
            <VCIcon name="play" size={14} color={VC.ink2} />
            <VCIcon name="heart" size={16} stroke={1.8} color={VC.ink3} />
            <div style={{ width: 20, height: 20, borderRadius: 6, background: VC.chipMint, color: VC.iconMint, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <VCIcon name="check" size={12} stroke={2.4} />
            </div>
          </div>
        </div>

        <div style={{
          fontFamily: VC.arabic, fontSize: 26, lineHeight: 1.7,
          color: VC.ink, direction: 'rtl', textAlign: 'center', marginTop: 12, marginBottom: 12,
        }}>
          بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
        </div>

        <div style={{ fontSize: 13.5, color: VC.ink2, textAlign: 'center', lineHeight: 1.4 }}>
          In the name of Allah, the Most Gracious, the Most Merciful.
        </div>
      </div>

      {/* surah progress card */}
      <div style={{
        position: 'absolute', top: 568, left: 22, right: 22,
        background: VC.card, borderRadius: 18, padding: 16,
        border: `1px solid ${VC.hairSoft}`,
        boxShadow: '0 4px 14px rgba(60,40,20,0.04)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <div>
            <div style={{ fontSize: 14, fontWeight: 700, color: VC.ink, letterSpacing: -0.2 }}>Al-Baqarah · The Cow</div>
            <div style={{ fontSize: 11, color: VC.ink3, marginTop: 1 }}>last read 4 minutes ago</div>
          </div>
          <div style={{ fontSize: 18, fontWeight: 800, color: VC.iconMint, letterSpacing: -0.4 }}>53%</div>
        </div>
        <div style={{ height: 8, background: '#F0EAE0', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ width: '53%', height: '100%', background: `linear-gradient(90deg, ${VC.iconMint}, #56A879)`, borderRadius: 999 }} />
        </div>
      </div>

      <VCDots index={7} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C9 — Stay Motivated
// ─────────────────────────────────────────────────────────────────
function C9_Motivate() {
  const features = [
    { chip: VC.chipSky,    ic: VC.iconSky,    icon: 'chart',  title: 'Track Your Progress', sub: 'See your daily verse count and reading streaks' },
    { chip: VC.chipPeach,  ic: VC.iconPeach,  icon: 'flame',  title: 'Build Streaks',       sub: 'Read daily to maintain your streak' },
    { chip: VC.chipButter, ic: VC.iconButter, icon: 'trophy', title: 'Earn Badges',         sub: 'Complete surahs and hit milestones' },
  ];
  return (
    <VCShell tilt="peach">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPeach} color={VC.iconPeach} glow={VC.accent}>
          <VCIcon name="flame" size={38} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>Stay Motivated</div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>Build your reading streak and earn badges</div>
      </div>

      {/* feature rows */}
      <div style={{
        position: 'absolute', top: 354, left: 22, right: 22,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        {features.map((f, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 14,
            background: VC.card, borderRadius: 18, padding: '14px 14px',
            boxShadow: '0 2px 8px rgba(60,40,20,0.04)',
            border: `1px solid ${VC.hairSoft}`,
          }}>
            <VCChip chip={f.chip} color={f.ic} size={48} radius={14}>
              <VCIcon name={f.icon} size={22} stroke={2} />
            </VCChip>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: VC.ink, letterSpacing: -0.2 }}>{f.title}</div>
              <div style={{ fontSize: 12, color: VC.ink3, marginTop: 2, lineHeight: 1.35 }}>{f.sub}</div>
            </div>
          </div>
        ))}
      </div>

      {/* CTA */}
      <div style={{ position: 'absolute', left: 22, right: 22, bottom: 96 }}>
        <VCCta icon={<VCIcon name="bell" size={15} stroke={2} color="#fff" />}>Enable Progress Reminders</VCCta>
        <div style={{ marginTop: 10, textAlign: 'center', fontSize: 12, color: VC.ink3 }}>
          You can always enable this later in Settings
        </div>
      </div>

      <VCDots index={8} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C10 — Special Seasons
// ─────────────────────────────────────────────────────────────────
function C10_Seasons() {
  return (
    <VCShell tilt="mauve">
      <VCStatus />
      <VCSkip />

      <div style={{ position: 'absolute', top: 110, left: 0, right: 0, textAlign: 'center' }}>
        <VCHero chip={VC.chipPlum} color={VC.iconPeach} glow="#E89464">
          <VCIcon name="moon" size={40} stroke={2} />
        </VCHero>
      </div>

      <div style={{ position: 'absolute', top: 246, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 30, fontWeight: 800, color: VC.ink, lineHeight: 1.1, letterSpacing: -0.6 }}>Special Seasons</div>
        <div style={{ marginTop: 8, fontSize: 14.5, color: VC.ink2 }}>Unique experiences for blessed months</div>
      </div>

      {/* Ramadan card */}
      <div style={{
        position: 'absolute', top: 348, left: 22, right: 22,
        background: VC.card, borderRadius: 20, padding: 16,
        boxShadow: '0 8px 20px rgba(60,40,20,0.05)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
          <VCChip chip={VC.chipPeach} color={VC.iconPeach} size={44} radius={14}>
            <VCIcon name="moon" size={22} stroke={2} />
          </VCChip>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 17, fontWeight: 800, color: VC.ink, letterSpacing: -0.3 }}>Ramadan Journey</div>
            <div style={{
              display: 'inline-flex', marginTop: 4, padding: '3px 9px', borderRadius: 999,
              background: `linear-gradient(180deg, #C764D5, #9A48A8)`, color: '#fff',
              fontSize: 10.5, fontWeight: 700, letterSpacing: 0.4,
            }}>Seasonal</div>
          </div>
        </div>

        {[
          { icon: '✨', text: 'Daily duas from Mafatih al-Jinan',     ic: VC.iconButter, chip: VC.chipButter, sym: 'spark' },
          { icon: '📜', text: 'Curated Quranic verses with tafsir',  ic: VC.iconButter, chip: VC.chipButter, sym: 'book' },
          { icon: '💭', text: 'Reflections and spiritual guidance',  ic: VC.iconButter, chip: VC.chipButter, sym: 'heart' },
          { icon: '✓',  text: 'Track your 30-day progress',          ic: VC.iconButter, chip: VC.chipButter, sym: 'check' },
        ].map((b, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 10, padding: '7px 0',
          }}>
            <VCChip chip={b.chip} color={b.ic} size={22} radius={6}>
              <VCIcon name={b.sym} size={12} stroke={2.2} />
            </VCChip>
            <div style={{ fontSize: 13, color: VC.ink2, fontWeight: 500 }}>{b.text}</div>
          </div>
        ))}
      </div>

      {/* future card */}
      <div style={{
        position: 'absolute', top: 558, left: 22, right: 22,
        background: VC.card, borderRadius: 20, padding: 16,
        boxShadow: '0 8px 20px rgba(60,40,20,0.05)',
        border: `1px solid ${VC.hairSoft}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 8 }}>
          <VCChip chip={VC.chipSky} color={VC.iconSky} size={44} radius={14}>
            <VCIcon name="cal" size={22} stroke={2} />
          </VCChip>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 16, fontWeight: 800, color: VC.ink, letterSpacing: -0.3 }}>More Coming Soon</div>
            <div style={{
              display: 'inline-flex', marginTop: 4, padding: '3px 9px', borderRadius: 999,
              background: `linear-gradient(180deg, #5BA6F0, ${VC.iconSky})`, color: '#fff',
              fontSize: 10.5, fontWeight: 700, letterSpacing: 0.4,
            }}>Future</div>
          </div>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 4 }}>
          {[
            { name: 'Muharram',    ic: VC.iconSky,  chip: VC.chipSky,  sym: 'water' },
            { name: 'Dhul-Hijjah', ic: VC.iconSky,  chip: VC.chipSky,  sym: 'mountain' },
            { name: 'Rajab',       ic: VC.iconSky,  chip: VC.chipSky,  sym: 'spark' },
            { name: 'Holy nights', ic: VC.iconSky,  chip: VC.chipSky,  sym: 'star' },
          ].map((p, i) => (
            <div key={i} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5,
              padding: '5px 10px', borderRadius: 999,
              background: p.chip, color: p.ic, fontSize: 11.5, fontWeight: 700,
            }}>
              <VCIcon name={p.sym} size={11} stroke={2.2} /> {p.name}
            </div>
          ))}
        </div>
      </div>

      <VCDots index={9} />
    </VCShell>
  );
}

// ─────────────────────────────────────────────────────────────────
// C11 — Begin Your Journey
// ─────────────────────────────────────────────────────────────────
function C11_Begin() {
  return (
    <VCShell tilt="peach">
      <VCStatus />

      {/* small mark */}
      <div style={{ position: 'absolute', top: 88, left: 0, right: 0, textAlign: 'center' }}>
        <div style={{
          fontFamily: VC.arabic, fontSize: 44, color: VC.iconPeach,
          textShadow: '0 0 30px rgba(232,148,100,0.4)',
        }}>ثقلين</div>
      </div>

      <div style={{ position: 'absolute', top: 172, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 34, fontWeight: 800, color: VC.ink, lineHeight: 1.05, letterSpacing: -0.8 }}>
          Begin Your Journey
        </div>
        <div style={{ marginTop: 12, fontSize: 14.5, color: VC.ink2, lineHeight: 1.45, maxWidth: 300, margin: '12px auto 0' }}>
          Sync your reading progress and bookmarks across all your devices.
        </div>
      </div>

      {/* CTAs */}
      <div style={{
        position: 'absolute', left: 22, right: 22, top: 330,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        <VCCta icon={<VCIcon name="book" size={16} stroke={2} color="#fff" />}>Continue as Guest</VCCta>
        <VCCta secondary icon={<VCIcon name="userplus" size={16} stroke={2} color={VC.ink} />}>Create Account</VCCta>
        <VCCta secondary icon={<VCIcon name="user" size={16} stroke={2} color={VC.ink} />}>Sign In</VCCta>
      </div>

      {/* benefits card */}
      <div style={{
        position: 'absolute', left: 22, right: 22, top: 558,
        background: VC.card, borderRadius: 18, padding: '14px 16px',
        boxShadow: '0 4px 14px rgba(60,40,20,0.04)',
        border: `1px solid ${VC.hairSoft}`,
        textAlign: 'center',
      }}>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 8, marginBottom: 8,
        }}>
          <VCChip chip={VC.chipMint} color={VC.iconMint} size={24} radius={7}>
            <VCIcon name="heart" size={12} stroke={2.4} />
          </VCChip>
          <div style={{ fontSize: 12.5, fontWeight: 700, color: VC.ink, letterSpacing: 0.3 }}>Account Benefits</div>
        </div>
        <div style={{ fontSize: 12.5, color: VC.ink3, lineHeight: 1.5 }}>
          Sync bookmarks across devices and save your reading progress.
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 28, right: 28, bottom: 56, textAlign: 'center',
        fontSize: 11, color: VC.ink3,
      }}>
        By continuing you agree to our <span style={{ color: VC.ink2, textDecoration: 'underline' }}>Terms</span> and <span style={{ color: VC.ink2, textDecoration: 'underline' }}>Privacy</span>.
      </div>
    </VCShell>
  );
}

// export
Object.assign(window, {
  C1_Cover, C2_Promise, C3_Layers, C4_Daily, C5_Gems, C6_Quiz,
  C7_Result, C8_Track, C9_Motivate, C10_Seasons, C11_Begin,
});
