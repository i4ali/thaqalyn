// Variant B — "Lantern"
// Warm-dark glass aesthetic. SF Pro Display (heavy/tight). Brighter amber.
// Gamified visuals. Big numbers. Sparse stars + radial glows.

const VB = {
  bg: '#0F0907',
  bgLayer: '#1B100B',
  bg2: '#070403',
  glass: 'rgba(255,255,255,0.06)',
  glass2: 'rgba(255,255,255,0.04)',
  glassBorder: 'rgba(255,255,255,0.10)',
  glassBorderStrong: 'rgba(255,255,255,0.16)',
  ink: '#FFFFFF',
  ink2: 'rgba(255,255,255,0.78)',
  ink3: 'rgba(255,255,255,0.55)',
  ink4: 'rgba(255,255,255,0.32)',
  accent: '#F2A671',
  accentDeep: '#D17A48',
  accentBright: '#FFB985',
  accentSoft: 'rgba(242,166,113,0.16)',
  gold: '#E9C880',
  teal: '#7BB8B5',
  rose: '#E89B9B',
  lilac: '#B4A6E6',
  green: '#7BD08A',
  sans: '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", system-ui, sans-serif',
  arabic: '"Amiri", "Scheherazade New", serif',
};

// shared shell — warm-dark backdrop w/ glow + stars
function VBShell({ children, glow = 0.36, glowX = '50%', glowY = '10%', glowColor = '#F2A671', stars = 18 }) {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      color: VB.ink, fontFamily: VB.sans, background: VB.bg,
    }}>
      {/* radial atmosphere */}
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(140% 90% at 50% 0%, ${VB.bgLayer} 0%, ${VB.bg} 55%, ${VB.bg2} 100%)`,
      }} />
      {/* accent glow */}
      <div style={{
        position: 'absolute', top: glowY, left: glowX, transform: 'translate(-50%,-30%)',
        width: 520, height: 520, borderRadius: '50%',
        background: `radial-gradient(circle, ${glowColor}${Math.round(glow*255).toString(16).padStart(2,'0')}, transparent 65%)`,
        filter: 'blur(8px)', pointerEvents: 'none',
      }} />
      {/* cool secondary glow bottom */}
      <div style={{
        position: 'absolute', bottom: -200, right: -120,
        width: 360, height: 360, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(180,166,230,0.10), transparent 65%)',
        pointerEvents: 'none',
      }} />
      {/* stars */}
      {[...Array(stars)].map((_, i) => (
        <div key={i} style={{
          position: 'absolute',
          top: `${((i*47)+7)%96}%`, left: `${((i*79)+11)%100}%`,
          width: i%4===0 ? 2.5 : 1.2, height: i%4===0 ? 2.5 : 1.2,
          borderRadius: '50%', background: '#fff',
          opacity: 0.12 + ((i%5)*0.04),
          boxShadow: i%4===0 ? '0 0 4px rgba(255,255,255,0.6)' : 'none',
        }} />
      ))}
      {/* film grain */}
      <div style={{
        position: 'absolute', inset: 0, mixBlendMode: 'overlay', opacity: 0.14, pointerEvents: 'none',
        backgroundImage: `url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='240' height='240'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%25' height='100%25' filter='url(%23n)' opacity='0.5'/></svg>")`,
      }} />
      {children}
    </div>
  );
}

// status bar (dark)
function VBStatus({ time = '9:41' }) {
  const c = '#fff';
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

// glass progress pill at the top
function VBProgress({ step = 1, total = 11, showSkip = true }) {
  const pct = (step / total) * 100;
  return (
    <div style={{
      position: 'absolute', top: 52, left: 22, right: 22,
      display: 'flex', alignItems: 'center', gap: 12, zIndex: 15,
    }}>
      <div style={{
        flex: 1, padding: '7px 14px', borderRadius: 999,
        background: 'rgba(255,255,255,0.06)',
        border: `1px solid ${VB.glassBorder}`,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1.6, color: VB.ink3 }}>
          {String(step).padStart(2,'0')} <span style={{ color: VB.ink4 }}>/ {total}</span>
        </div>
        <div style={{ flex: 1, height: 4, background: 'rgba(255,255,255,0.08)', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ width: `${pct}%`, height: '100%', background: `linear-gradient(90deg, ${VB.accent}, ${VB.accentBright})`, borderRadius: 999 }} />
        </div>
      </div>
      {showSkip && (
        <div style={{
          padding: '7px 14px', borderRadius: 999,
          background: 'rgba(255,255,255,0.06)',
          border: `1px solid ${VB.glassBorder}`,
          backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
          fontSize: 12, fontWeight: 600, color: VB.ink2,
        }}>Skip</div>
      )}
    </div>
  );
}

// dots indicator (small, at bottom)
function VBDots({ index = 0, total = 11 }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 22,
      display: 'flex', justifyContent: 'center', gap: 5, zIndex: 10,
    }}>
      {[...Array(total)].map((_, i) => {
        const a = i === index;
        return (
          <div key={i} style={{
            width: a ? 18 : 5, height: 5, borderRadius: 999,
            background: a ? VB.accent : 'rgba(255,255,255,0.18)',
          }} />
        );
      })}
    </div>
  );
}

// icon set (reuses ObIcon shapes — same paths)
function VBIcon({ name, size = 18, stroke = 1.6, color = 'currentColor', fill = 'none' }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill, stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'book': return <svg {...p}><path d="M4 5a2 2 0 0 1 2-2h12v16H6a2 2 0 0 0-2 2V5z"/><path d="M4 19a2 2 0 0 1 2-2h12"/></svg>;
    case 'spark': return <svg {...p}><path d="M12 3l1.8 5L18 9.5l-4.2 1.5L12 16l-1.8-5L6 9.5 10.2 8 12 3z"/></svg>;
    case 'bell': return <svg {...p}><path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2H4.5L6 16z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>;
    case 'heart': return <svg {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/></svg>;
    case 'moon': return <svg {...p}><path d="M20 14.5A8 8 0 0 1 9.5 4 8 8 0 1 0 20 14.5z"/></svg>;
    case 'flame': return <svg {...p}><path d="M12 3c1 4 4 5 4 9a4 4 0 1 1-8 0c0-2 1-3 1-5 1 1 1 2 3-4z"/></svg>;
    case 'crown': return <svg {...p}><path d="M3 8l4 4 5-7 5 7 4-4-2 11H5L3 8z"/></svg>;
    case 'scales': return <svg {...p}><path d="M12 4v16M5 20h14"/><path d="M5 9l3 7H2l3-7zM19 9l3 7h-6l3-7z"/></svg>;
    case 'play': return <svg {...p} fill={color} stroke="none"><path d="M7 5l12 7-12 7V5z"/></svg>;
    case 'arrow': return <svg {...p}><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>;
    case 'check': return <svg {...p} strokeWidth={2.4}><path d="M5 12l4 4 10-10"/></svg>;
    case 'star': return <svg {...p}><path d="M12 3l2.7 6.2L21 10l-5 4.5L17.5 21 12 17.5 6.5 21 8 14.5 3 10l6.3-0.8L12 3z"/></svg>;
    case 'globe': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/></svg>;
    case 'columns': return <svg {...p}><path d="M4 21h16M4 9l8-5 8 5M6 21V10M10 21V10M14 21V10M18 21V10"/></svg>;
    case 'user': return <svg {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c1-5 5-7 8-7s7 2 8 7"/></svg>;
    case 'apple': return <svg viewBox="0 0 24 24" width={size} height={size} fill={color}><path d="M16.4 12.7c0-2.4 2-3.6 2.1-3.7-1.1-1.7-2.9-1.9-3.5-1.9-1.5-.2-2.9.9-3.7.9-.8 0-1.9-.9-3.2-.8-1.6 0-3.2.9-4 2.4-1.7 3-.4 7.3 1.2 9.7.8 1.2 1.8 2.5 3 2.4 1.2 0 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4.9-1.4 1.3-2.7 1.3-2.8-.1 0-2.6-1-2.6-3.8zM14 5.2c.7-.8 1.1-2 1-3.2-1 .1-2.2.6-2.9 1.5-.6.7-1.2 2-1.1 3.1 1.1.1 2.3-.6 3-1.4z"/></svg>;
    case 'wave': return <svg {...p}><path d="M2 12c2-6 4-6 6 0s4 6 6 0 4-6 6 0 4 6 6 0"/></svg>;
    default: return null;
  }
}

// glass tile — square icon tile
function VBGlassTile({ children, size = 44, accent = VB.accent }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 13,
      background: VB.accentSoft, color: accent,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      border: `1px solid ${VB.glassBorder}`,
      backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)',
    }}>{children}</div>
  );
}

// ────────────────────────────────────────────────────────────────
// B1 — Cover
// ────────────────────────────────────────────────────────────────
function B1_Cover() {
  return (
    <VBShell glow={0.5} glowY="20%" stars={26}>
      <VBStatus />

      <div style={{ position: 'absolute', top: 52, left: 0, right: 0, textAlign: 'center', color: VB.ink3, fontSize: 11, fontWeight: 700, letterSpacing: 3 }}>
        THAQALAYN
      </div>

      {/* huge Arabic logotype */}
      <div style={{
        position: 'absolute', top: 150, left: 0, right: 0, textAlign: 'center',
      }}>
        <div style={{
          fontFamily: VB.arabic, fontSize: 130, fontWeight: 700, color: '#fff',
          textShadow: `0 0 60px rgba(242,166,113,0.65), 0 0 20px rgba(242,166,113,0.3)`,
          letterSpacing: -3, lineHeight: 1,
        }}>ثقلين</div>
      </div>

      {/* tagline */}
      <div style={{
        position: 'absolute', top: 332, left: 28, right: 28, textAlign: 'center',
      }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3.4, color: VB.gold, textTransform: 'uppercase' }}>
          The Two Weighty Things
        </div>
      </div>

      {/* divider with gold accent */}
      <div style={{
        position: 'absolute', top: 372, left: '50%', transform: 'translateX(-50%)',
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <div style={{ width: 30, height: 1, background: 'rgba(255,255,255,0.2)' }} />
        <div style={{ width: 4, height: 4, borderRadius: '50%', background: VB.gold }} />
        <div style={{ width: 30, height: 1, background: 'rgba(255,255,255,0.2)' }} />
      </div>

      {/* Arabic hadith */}
      <div style={{
        position: 'absolute', top: 412, left: 28, right: 28, textAlign: 'center',
        fontFamily: VB.arabic, fontSize: 22, lineHeight: 1.85,
        color: '#fff', direction: 'rtl',
      }}>
        إنّي تاركٌ فيكم الثقلين<br/>
        كتاب الله وعترتي أهلَ بيتي
      </div>

      {/* English translation */}
      <div style={{
        position: 'absolute', top: 558, left: 32, right: 32, textAlign: 'center',
        fontSize: 16, lineHeight: 1.45, color: VB.ink2, fontWeight: 400, letterSpacing: -0.1,
      }}>
        I am leaving among you two weighty things — the Book of Allah and the people of my household.
      </div>

      {/* attribution */}
      <div style={{
        position: 'absolute', top: 670, left: 0, right: 0, textAlign: 'center',
        fontSize: 11, fontWeight: 600, letterSpacing: 2, color: VB.ink4, textTransform: 'uppercase',
      }}>— Prophet Muhammad ﷺ</div>

      {/* CTA */}
      <div style={{
        position: 'absolute', left: 22, right: 22, bottom: 56,
      }}>
        <div style={{
          background: `linear-gradient(180deg, ${VB.accentBright}, ${VB.accentDeep})`,
          color: '#fff', borderRadius: 999, padding: '17px 0', textAlign: 'center',
          fontSize: 15, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          boxShadow: '0 14px 32px rgba(209,122,72,0.5), inset 0 1px 0 rgba(255,255,255,0.3)',
        }}>
          Enter the journey <VBIcon name="arrow" size={15} stroke={2.4} />
        </div>
      </div>
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B2 — Promise
// ────────────────────────────────────────────────────────────────
function B2_Promise() {
  const features = [
    { icon: 'book',    label: 'Complete Quran',      sub: 'Arabic, English & Urdu' },
    { icon: 'columns', label: 'Five layers',         sub: 'Authentic Shia tafsir' },
    { icon: 'bell',    label: 'Daily verses',        sub: 'Aligned with Islamic calendar' },
    { icon: 'heart',   label: 'Synced bookmarks',    sub: 'Across all your devices' },
  ];
  return (
    <VBShell glow={0.36} glowY="-2%">
      <VBStatus />
      <VBProgress step={2} />

      {/* small Arabic at top */}
      <div style={{ position: 'absolute', top: 124, left: 0, right: 0, textAlign: 'center' }}>
        <div style={{ fontFamily: VB.arabic, fontSize: 44, color: VB.accent, textShadow: '0 0 30px rgba(242,166,113,0.4)' }}>ثقلين</div>
      </div>

      <div style={{ position: 'absolute', top: 220, left: 28, right: 28 }}>
        <div style={{ fontSize: 32, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.8 }}>
          The Quran and the Ahlul Bayt — <span style={{ color: VB.accent }}>at your fingertips.</span>
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: VB.ink3, lineHeight: 1.5 }}>
          Built on authentic Shia scholarship. Crafted for daily companionship.
        </div>
      </div>

      {/* feature grid (2x2 glass cards) */}
      <div style={{
        position: 'absolute', top: 432, left: 22, right: 22,
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10,
      }}>
        {features.map((f, i) => (
          <div key={i} style={{
            background: VB.glass, borderRadius: 18, padding: 14,
            border: `1px solid ${VB.glassBorder}`,
            backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
          }}>
            <VBGlassTile size={36}><VBIcon name={f.icon} size={16} stroke={1.8} /></VBGlassTile>
            <div style={{ marginTop: 12, fontSize: 14, fontWeight: 700, color: '#fff', letterSpacing: -0.2 }}>{f.label}</div>
            <div style={{ marginTop: 2, fontSize: 11.5, color: VB.ink3, lineHeight: 1.35 }}>{f.sub}</div>
          </div>
        ))}
      </div>

      {/* CTA */}
      <div style={{ position: 'absolute', left: 22, right: 22, bottom: 60 }}>
        <div style={{
          background: '#fff', color: VB.bg, borderRadius: 999,
          padding: '15px 0', textAlign: 'center', fontSize: 14.5, fontWeight: 700,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          Continue <VBIcon name="arrow" size={14} stroke={2.4} color={VB.bg} />
        </div>
      </div>
      <VBDots index={1} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B3 — Five Layers (stacked offset cards)
// ────────────────────────────────────────────────────────────────
function B3_Layers() {
  const layers = [
    { n: '01', name: 'Foundation',   desc: 'History & simple meaning',           color: VB.teal, icon: 'columns' },
    { n: '02', name: 'Classical',    desc: 'Tabatabai · Tabrisi · al-Tusi',      color: VB.lilac, icon: 'book' },
    { n: '03', name: 'Contemporary', desc: 'Modern & scientific perspectives',   color: VB.green, icon: 'globe' },
    { n: '04', name: 'Ahlul Bayt',   desc: 'Hadith from the 14 Infallibles',     color: VB.accent, icon: 'star' },
    { n: '05', name: 'Comparative',  desc: 'Balanced Shia & Sunni scholarship',  color: VB.rose, icon: 'scales' },
  ];
  return (
    <VBShell glow={0.32} glowY="0%">
      <VBStatus />
      <VBProgress step={3} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.accent, textTransform: 'uppercase' }}>The Wisdom Stack</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          Five lenses on<br/>every verse.
        </div>
      </div>

      {/* stacked cards */}
      <div style={{ position: 'absolute', top: 264, left: 18, right: 18 }}>
        {layers.map((l, i) => (
          <div key={i} style={{
            position: 'relative',
            background: VB.glass,
            border: `1px solid ${VB.glassBorder}`,
            borderRadius: 18, padding: '14px 16px',
            backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
            marginBottom: 9,
            display: 'flex', alignItems: 'center', gap: 14,
            transform: `translateX(${i*3}px)`,
            boxShadow: '0 4px 14px rgba(0,0,0,0.3)',
          }}>
            <div style={{
              width: 42, height: 42, borderRadius: 12,
              background: `${l.color}22`,
              border: `1px solid ${l.color}55`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: l.color,
            }}>
              <VBIcon name={l.icon} size={17} stroke={1.8} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
                <span style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1.6, color: l.color }}>{l.n}</span>
                <span style={{ fontSize: 15, fontWeight: 700, color: '#fff', letterSpacing: -0.2 }}>{l.name}</span>
              </div>
              <div style={{ fontSize: 11.5, color: VB.ink3, marginTop: 1 }}>{l.desc}</div>
            </div>
            <VBIcon name="arrow" size={14} stroke={2} color={VB.ink4} />
          </div>
        ))}
      </div>

      <VBDots index={2} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B4 — Daily Companion
// ────────────────────────────────────────────────────────────────
function B4_Daily() {
  return (
    <VBShell glow={0.4} glowY="0%">
      <VBStatus />
      <VBProgress step={4} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.accent, textTransform: 'uppercase' }}>Today · Dhul-Qaʿdah 15</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          A meaningful verse,<br/>every sunrise.
        </div>
      </div>

      {/* hero verse card */}
      <div style={{
        position: 'absolute', top: 262, left: 18, right: 18,
        background: `linear-gradient(160deg, rgba(242,166,113,0.16) 0%, rgba(255,255,255,0.04) 60%)`,
        border: `1px solid ${VB.glassBorderStrong}`,
        borderRadius: 24, padding: 22,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
        overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', top: -40, right: -30, width: 160, height: 160, borderRadius: '50%', background: 'radial-gradient(circle, rgba(242,166,113,0.3), transparent 60%)' }} />

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 7, padding: '5px 10px', borderRadius: 999, background: 'rgba(0,0,0,0.25)', border: `1px solid ${VB.glassBorder}` }}>
            <VBIcon name="moon" size={11} stroke={2} color={VB.accent} />
            <span style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1.4, color: '#fff' }}>VERSE OF THE DAY</span>
          </div>
          <VBIcon name="star" size={16} stroke={1.6} color={VB.gold} fill={VB.gold} />
        </div>

        <div style={{
          fontFamily: VB.arabic, fontSize: 24, lineHeight: 1.85,
          color: '#fff', direction: 'rtl', textAlign: 'right',
          marginTop: 18, marginBottom: 14,
        }}>
          وَأَذِّن فِي ٱلنَّاسِ بِٱلْحَجِّ يَأْتُوكَ رِجَالًا
        </div>

        <div style={{ fontSize: 15, lineHeight: 1.45, color: VB.ink2, letterSpacing: -0.1 }}>
          “And proclaim to the people the pilgrimage; they will come to you on foot and on every lean camel.”
        </div>

        {/* audio + meta */}
        <div style={{
          marginTop: 18, padding: 12, borderRadius: 14,
          background: 'rgba(0,0,0,0.3)', border: `1px solid ${VB.glassBorder}`,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: '50%',
            background: VB.accent, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 4px 14px rgba(242,166,113,0.5)',
          }}>
            <VBIcon name="play" size={13} color="#fff" />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, fontWeight: 700 }}>Surah 22 · Verse 27</div>
            <div style={{ fontSize: 10.5, color: VB.ink3, marginTop: 1 }}>Recited by Mishary Rashid · 0:42</div>
          </div>
          <VBIcon name="wave" size={20} stroke={1.6} color={VB.accent} />
        </div>
      </div>

      <div style={{ position: 'absolute', left: 22, right: 22, bottom: 60 }}>
        <div style={{
          background: 'rgba(255,255,255,0.08)', color: '#fff', borderRadius: 999,
          padding: '14px 0', textAlign: 'center', fontSize: 14, fontWeight: 700,
          border: `1px solid ${VB.glassBorder}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)',
        }}>
          <VBIcon name="bell" size={14} stroke={1.8} /> Notify me each morning
        </div>
      </div>

      <VBDots index={3} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B5 — Gems
// ────────────────────────────────────────────────────────────────
function B5_Gems() {
  const gems = [
    { name: 'The Throne Verse', icon: 'crown', color: VB.gold },
    { name: 'The Ever-Living',  icon: 'spark', color: VB.green },
    { name: 'Cosmic Sovereignty', icon: 'globe', color: VB.teal },
    { name: 'Al-Kursi',         icon: 'star',  color: VB.accent },
  ];
  return (
    <VBShell glow={0.32} glowY="0%" glowColor="#B4A6E6">
      <VBStatus />
      <VBProgress step={5} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.lilac, textTransform: 'uppercase' }}>Gems</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          Precious insights,<br/><span style={{ color: VB.lilac }}>quietly unveiled.</span>
        </div>
      </div>

      {/* featured verse */}
      <div style={{
        position: 'absolute', top: 260, left: 18, right: 18,
        background: VB.glass, border: `1px solid ${VB.glassBorder}`,
        borderRadius: 22, padding: 20,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: 14 }}>
          <div style={{
            width: 42, height: 42, borderRadius: 12,
            background: `linear-gradient(135deg, ${VB.lilac}, #8E7DC5)`,
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 13, fontWeight: 800, letterSpacing: -0.3,
          }}>2:255</div>
          <div>
            <div style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: -0.2 }}>Al-Baqarah 255</div>
            <div style={{ fontSize: 10.5, color: VB.ink3, marginTop: 1, letterSpacing: 1, fontWeight: 600, textTransform: 'uppercase' }}>Ayat al-Kursi</div>
          </div>
        </div>

        <div style={{
          fontFamily: VB.arabic, fontSize: 22, lineHeight: 1.85,
          color: '#fff', direction: 'rtl', textAlign: 'right',
          paddingBottom: 16, borderBottom: `1px solid ${VB.glassBorder}`,
        }}>
          ٱلْقَيُّومُ لَا تَأْخُذُهُۥ سِنَةٌ وَلَا نَوْمٌ
        </div>

        {/* gem tags 2x2 */}
        <div style={{ marginTop: 14, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 7 }}>
          {gems.map((g, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 7,
              padding: '9px 11px', borderRadius: 12,
              background: 'rgba(0,0,0,0.3)',
              border: `1px solid ${g.color}33`,
            }}>
              <VBIcon name={g.icon} size={13} stroke={2} color={g.color} />
              <span style={{ fontSize: 11.5, fontWeight: 600, color: '#fff' }}>{g.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* insight */}
      <div style={{
        position: 'absolute', top: 562, left: 22, right: 22,
        padding: '14px 16px', borderRadius: 16,
        background: 'rgba(180,166,230,0.08)',
        border: `1px solid rgba(180,166,230,0.20)`,
      }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2, color: VB.lilac, textTransform: 'uppercase', marginBottom: 6 }}>
          Why it matters
        </div>
        <div style={{ fontSize: 13, lineHeight: 1.5, color: VB.ink2 }}>
          Understanding Allah's complete authority brings peace and removes the fear of creation.
        </div>
      </div>

      <VBDots index={4} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B6 — Quiz
// ────────────────────────────────────────────────────────────────
function B6_Quiz() {
  const options = [
    { key: 'A', text: 'The physical throne of Allah' },
    { key: 'B', text: "Allah's knowledge and authority", correct: true },
    { key: 'C', text: 'A type of angel' },
    { key: 'D', text: 'The heavens' },
  ];
  return (
    <VBShell glow={0.28} glowColor="#7BB8B5" glowY="0%">
      <VBStatus />
      <VBProgress step={6} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.teal, textTransform: 'uppercase' }}>Test Your Knowledge</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          Read. Reflect.<br/><span style={{ color: VB.teal }}>Then prove it.</span>
        </div>
      </div>

      {/* quiz card */}
      <div style={{
        position: 'absolute', top: 286, left: 18, right: 18,
        background: VB.glass, border: `1px solid ${VB.glassBorderStrong}`,
        borderRadius: 22, padding: '20px 20px 22px',
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '5px 10px', borderRadius: 999,
            background: `${VB.teal}22`,
            border: `1px solid ${VB.teal}44`,
            fontSize: 10.5, fontWeight: 700, letterSpacing: 1.4, color: VB.teal, textTransform: 'uppercase',
          }}>
            <VBIcon name="columns" size={11} stroke={2} /> Foundation
          </div>
          <div style={{ fontSize: 11, fontWeight: 700, color: VB.ink3 }}>3 / 10</div>
        </div>

        <div style={{ fontSize: 20, fontWeight: 700, lineHeight: 1.25, color: '#fff', letterSpacing: -0.3 }}>
          What does <span style={{ color: VB.accent }}>Kursī</span> represent in Ayat al-Kursi?
        </div>

        <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {options.map(o => {
            const c = o.correct;
            return (
              <div key={o.key} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '12px 14px', borderRadius: 14,
                background: c ? `${VB.accent}22` : 'rgba(0,0,0,0.25)',
                border: `1.5px solid ${c ? VB.accent : VB.glassBorder}`,
              }}>
                <div style={{
                  width: 26, height: 26, borderRadius: 8,
                  background: c ? VB.accent : 'rgba(255,255,255,0.06)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: c ? '#fff' : VB.ink3, fontSize: 12, fontWeight: 800,
                }}>{c ? <VBIcon name="check" size={14} stroke={2.6} color="#fff"/> : o.key}</div>
                <div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff', flex: 1 }}>{o.text}</div>
              </div>
            );
          })}
        </div>
      </div>

      <VBDots index={5} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B7 — Quiz Result — celebration
// ────────────────────────────────────────────────────────────────
function B7_Result() {
  return (
    <VBShell glow={0.6} glowY="35%" glowColor="#FFB985" stars={28}>
      <VBStatus />
      <VBProgress step={7} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.gold, textTransform: 'uppercase' }}>Quiz Complete</div>
        <div style={{ marginTop: 8, fontSize: 24, fontWeight: 800, letterSpacing: -0.4 }}>Excellent understanding</div>
      </div>

      {/* circular ring with score */}
      <div style={{
        position: 'absolute', top: 220, left: '50%', transform: 'translateX(-50%)',
        width: 240, height: 240,
      }}>
        <svg width="240" height="240" viewBox="0 0 240 240" style={{ position: 'absolute', inset: 0 }}>
          <defs>
            <linearGradient id="ringGrad" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor="#FFB985" />
              <stop offset="100%" stopColor="#D17A48" />
            </linearGradient>
          </defs>
          <circle cx="120" cy="120" r="106" stroke="rgba(255,255,255,0.06)" strokeWidth="14" fill="none"/>
          <circle cx="120" cy="120" r="106"
            stroke="url(#ringGrad)" strokeWidth="14" fill="none"
            strokeLinecap="round"
            strokeDasharray={`${2*Math.PI*106*0.9} ${2*Math.PI*106}`}
            transform="rotate(-90 120 120)"
            style={{ filter: 'drop-shadow(0 0 20px rgba(242,166,113,0.5))' }}
          />
        </svg>
        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
            <span style={{ fontSize: 100, fontWeight: 800, color: '#fff', letterSpacing: -4, lineHeight: 1 }}>9</span>
            <span style={{ fontSize: 24, color: VB.ink3, fontWeight: 600 }}>/10</span>
          </div>
          <div style={{ marginTop: 4, fontSize: 11, fontWeight: 700, letterSpacing: 2.4, color: VB.accent, textTransform: 'uppercase' }}>90% correct</div>
        </div>
      </div>

      {/* scholar badge */}
      <div style={{
        position: 'absolute', top: 504, left: '50%', transform: 'translateX(-50%)',
        display: 'inline-flex', alignItems: 'center', gap: 14,
        padding: '11px 22px', borderRadius: 999,
        background: 'rgba(255,255,255,0.06)',
        border: `1px solid ${VB.glassBorder}`,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        <div style={{ fontFamily: VB.arabic, fontSize: 22, color: VB.accent }}>عالم</div>
        <div style={{ width: 1, height: 18, background: 'rgba(255,255,255,0.18)' }} />
        <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase' }}>Scholar Level</div>
      </div>

      {/* mini stats */}
      <div style={{
        position: 'absolute', left: 22, right: 22, top: 584,
        display: 'flex', gap: 8,
      }}>
        {[
          { v: '12',  l: 'Quizzes' },
          { v: '87%', l: 'Avg score' },
          { v: '5',   l: 'Surahs' },
        ].map((s, i) => (
          <div key={i} style={{
            flex: 1, padding: '12px 8px', borderRadius: 14,
            background: VB.glass, border: `1px solid ${VB.glassBorder}`,
            textAlign: 'center', backdropFilter: 'blur(10px)',
          }}>
            <div style={{ fontSize: 22, fontWeight: 800, color: '#fff', letterSpacing: -0.5 }}>{s.v}</div>
            <div style={{ fontSize: 10, fontWeight: 600, color: VB.ink3, letterSpacing: 0.8, marginTop: 2, textTransform: 'uppercase' }}>{s.l}</div>
          </div>
        ))}
      </div>

      <VBDots index={6} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B8 — Track Progress
// ────────────────────────────────────────────────────────────────
function B8_Track() {
  // 6x4 surah grid mockup
  const cells = [...Array(24)].map((_, i) => {
    if (i < 5) return 'done';
    if (i < 8) return 'reading';
    return 'todo';
  });
  return (
    <VBShell glow={0.32} glowColor="#7BD08A" glowY="0%">
      <VBStatus />
      <VBProgress step={8} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.green, textTransform: 'uppercase' }}>Your Journey</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          The Quran,<br/><span style={{ color: VB.green }}>verse by verse.</span>
        </div>
      </div>

      {/* hero stat */}
      <div style={{
        position: 'absolute', top: 252, left: 18, right: 18,
        background: `linear-gradient(135deg, rgba(123,208,138,0.16), rgba(255,255,255,0.03))`,
        border: `1px solid ${VB.glassBorder}`,
        borderRadius: 22, padding: 18,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2, color: VB.ink3, textTransform: 'uppercase' }}>Verses read</div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
              <span style={{ fontSize: 56, fontWeight: 800, color: '#fff', letterSpacing: -2, lineHeight: 1 }}>847</span>
              <span style={{ fontSize: 14, color: VB.ink3, fontWeight: 600 }}>/ 6,236</span>
            </div>
            <div style={{ marginTop: 6, fontSize: 12, color: VB.green, fontWeight: 700 }}>13.6% of the Quran ↗</div>
          </div>
          <div style={{
            padding: '6px 10px', borderRadius: 999,
            background: 'rgba(123,208,138,0.18)', color: VB.green,
            fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase',
            display: 'flex', alignItems: 'center', gap: 5,
          }}>
            <VBIcon name="flame" size={11} stroke={2} /> 12d streak
          </div>
        </div>

        {/* progress bar */}
        <div style={{ marginTop: 14, height: 6, background: 'rgba(255,255,255,0.08)', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ width: '13.6%', height: '100%', background: `linear-gradient(90deg, ${VB.green}, #5BB075)`, borderRadius: 999 }} />
        </div>
      </div>

      {/* surah grid */}
      <div style={{ position: 'absolute', top: 444, left: 22, right: 22 }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2, color: VB.ink3, textTransform: 'uppercase', marginBottom: 10 }}>
          Surahs (24 of 114)
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 5 }}>
          {cells.map((c, i) => {
            const bg = c === 'done' ? VB.green
              : c === 'reading' ? VB.accent
              : 'rgba(255,255,255,0.08)';
            const border = c === 'todo' ? `1px solid ${VB.glassBorder}` : 'none';
            return (
              <div key={i} style={{
                aspectRatio: '1/1', borderRadius: 7, background: bg, border,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 9, fontWeight: 800, color: c === 'todo' ? VB.ink4 : '#fff',
              }}>{i+1}</div>
            );
          })}
        </div>

        <div style={{ display: 'flex', gap: 14, marginTop: 14, fontSize: 10.5, color: VB.ink3 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <div style={{ width: 9, height: 9, borderRadius: 2, background: VB.green }} /> Done
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <div style={{ width: 9, height: 9, borderRadius: 2, background: VB.accent }} /> Reading
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <div style={{ width: 9, height: 9, borderRadius: 2, background: 'rgba(255,255,255,0.1)', border: `1px solid ${VB.glassBorder}` }} /> To go
          </div>
        </div>
      </div>

      <VBDots index={7} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B9 — Stay Motivated
// ────────────────────────────────────────────────────────────────
function B9_Motivate() {
  const days = ['M','T','W','T','F','S','S'];
  const filled = [1,1,1,1,1,1,0];
  const badges = [
    { name: 'First Verse',  icon: 'spark', earned: true,  color: VB.accent },
    { name: '7-Day Streak', icon: 'flame', earned: true,  color: VB.rose },
    { name: 'Scholar',      icon: 'crown', earned: true,  color: VB.gold },
    { name: 'Night Reader', icon: 'moon',  earned: false, color: VB.lilac },
    { name: 'Hafiz',        icon: 'book',  earned: false, color: VB.teal },
    { name: 'Reflector',    icon: 'star',  earned: false, color: VB.green },
  ];
  return (
    <VBShell glow={0.42} glowColor="#FFB985" glowY="0%">
      <VBStatus />
      <VBProgress step={9} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.accent, textTransform: 'uppercase' }}>Stay Motivated</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          Build the habit.<br/><span style={{ color: VB.accent }}>Earn the light.</span>
        </div>
      </div>

      {/* streak hero */}
      <div style={{
        position: 'absolute', top: 252, left: 18, right: 18,
        background: `linear-gradient(135deg, rgba(242,166,113,0.22), rgba(232,155,155,0.10))`,
        border: `1px solid ${VB.glassBorderStrong}`,
        borderRadius: 22, padding: 20,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
          <span style={{ fontSize: 72, fontWeight: 800, color: '#fff', letterSpacing: -3, lineHeight: 1 }}>12</span>
          <div>
            <div style={{ fontSize: 14, fontWeight: 700, color: '#fff' }}>Day streak</div>
            <div style={{ fontSize: 11.5, color: VB.ink3, marginTop: 1 }}>Personal best · keep going</div>
          </div>
          <div style={{ marginLeft: 'auto', fontSize: 32 }}>🔥</div>
        </div>

        {/* week strip */}
        <div style={{ marginTop: 16, display: 'flex', gap: 6 }}>
          {days.map((d, i) => (
            <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5 }}>
              <div style={{
                width: '100%', aspectRatio: '1/1', borderRadius: 9,
                background: filled[i] ? `linear-gradient(180deg, ${VB.accentBright}, ${VB.accentDeep})` : 'rgba(0,0,0,0.3)',
                border: filled[i] ? 'none' : `1px solid ${VB.glassBorder}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: filled[i] ? '0 4px 12px rgba(242,166,113,0.4)' : 'none',
              }}>
                {filled[i] ? <VBIcon name="check" size={13} stroke={2.6} color="#fff" /> : null}
              </div>
              <div style={{ fontSize: 10, fontWeight: 700, color: VB.ink4 }}>{d}</div>
            </div>
          ))}
        </div>
      </div>

      {/* badges */}
      <div style={{ position: 'absolute', top: 470, left: 22, right: 22 }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2, color: VB.ink3, textTransform: 'uppercase', marginBottom: 10 }}>
          Badges · 3 of 12 earned
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 8 }}>
          {badges.map((b, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <div style={{
                width: '100%', aspectRatio: '1/1', borderRadius: 12,
                background: b.earned ? `${b.color}26` : 'rgba(255,255,255,0.04)',
                border: `1px solid ${b.earned ? `${b.color}55` : VB.glassBorder}`,
                color: b.earned ? b.color : VB.ink4,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                filter: b.earned ? 'none' : 'grayscale(0.5)',
              }}>
                <VBIcon name={b.icon} size={18} stroke={1.8} />
              </div>
              <div style={{ fontSize: 9, fontWeight: 600, color: b.earned ? VB.ink2 : VB.ink4, textAlign: 'center', lineHeight: 1.15 }}>{b.name}</div>
            </div>
          ))}
        </div>
      </div>

      <VBDots index={8} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B10 — Special Seasons
// ────────────────────────────────────────────────────────────────
function B10_Seasons() {
  return (
    <VBShell glow={0.4} glowY="0%" glowColor="#B4A6E6">
      <VBStatus />
      <VBProgress step={10} />

      <div style={{ position: 'absolute', top: 116, left: 28, right: 28 }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 3, color: VB.lilac, textTransform: 'uppercase' }}>Blessed Seasons</div>
        <div style={{ marginTop: 10, fontSize: 30, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.6 }}>
          The calendar<br/><span style={{ color: VB.lilac }}>meets the verse.</span>
        </div>
      </div>

      {/* Ramadan featured hero — full-width visual card */}
      <div style={{
        position: 'absolute', top: 252, left: 18, right: 18, height: 280,
        background: `linear-gradient(160deg, #2A1F40 0%, #1A1430 60%, #100A20 100%)`,
        border: `1px solid ${VB.glassBorderStrong}`,
        borderRadius: 24, padding: 20,
        overflow: 'hidden',
      }}>
        {/* crescent illustration */}
        <div style={{
          position: 'absolute', top: -20, right: -20, width: 160, height: 160, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(180,166,230,0.45), transparent 60%)',
          filter: 'blur(4px)',
        }} />
        <div style={{
          position: 'absolute', top: 24, right: 30,
          width: 80, height: 80, borderRadius: '50%',
          background: VB.lilac,
          boxShadow: '0 0 40px rgba(180,166,230,0.6)',
        }} />
        <div style={{
          position: 'absolute', top: 16, right: 22,
          width: 80, height: 80, borderRadius: '50%',
          background: '#100A20',
        }} />
        {/* stars */}
        {[...Array(8)].map((_, i) => (
          <div key={i} style={{
            position: 'absolute',
            top: `${10 + (i*11)%50}%`, right: `${5 + (i*13)%55}%`,
            width: i%2===0 ? 3 : 1.5, height: i%2===0 ? 3 : 1.5,
            borderRadius: '50%', background: '#fff',
            opacity: 0.4 + (i%3)*0.2,
            boxShadow: i%2===0 ? '0 0 6px rgba(255,255,255,0.8)' : 'none',
          }} />
        ))}

        <div style={{ position: 'relative', height: '100%', display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
          <div style={{
            display: 'inline-flex', alignSelf: 'flex-start', alignItems: 'center', gap: 6,
            padding: '5px 11px', borderRadius: 999,
            background: 'rgba(180,166,230,0.22)',
            border: `1px solid ${VB.lilac}55`,
            fontSize: 10.5, fontWeight: 700, letterSpacing: 1.6, color: VB.lilac, textTransform: 'uppercase',
            marginBottom: 12,
          }}>
            <VBIcon name="moon" size={11} stroke={2} /> Featured · in 28 days
          </div>
          <div style={{ fontSize: 32, fontWeight: 800, letterSpacing: -0.8, lineHeight: 1, color: '#fff' }}>Ramadan Journey</div>
          <div style={{ marginTop: 8, fontSize: 13, color: 'rgba(255,255,255,0.7)', lineHeight: 1.45, maxWidth: 270 }}>
            Daily duas from Mafatih al-Jinan, curated verses with tafsir, and a 30-day reflection track.
          </div>
        </div>
      </div>

      {/* upcoming list */}
      <div style={{ position: 'absolute', top: 558, left: 22, right: 22 }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 2, color: VB.ink3, textTransform: 'uppercase', marginBottom: 8 }}>
          Coming this year
        </div>
        {[
          { name: 'Muharram',         sub: 'Commemorations & Ashura',       color: VB.rose },
          { name: 'Dhul-Hijjah',      sub: 'Hajj season & the ten days',    color: VB.accent },
          { name: 'Rajab & Shaʿban',  sub: 'Preparations for Ramadan',      color: VB.teal },
        ].map((s, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '10px 0',
            borderBottom: i < 2 ? `1px solid ${VB.glassBorder}` : 'none',
          }}>
            <div style={{ width: 6, height: 6, borderRadius: '50%', background: s.color, boxShadow: `0 0 8px ${s.color}` }} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13.5, fontWeight: 700, color: '#fff' }}>{s.name}</div>
              <div style={{ fontSize: 11, color: VB.ink3 }}>{s.sub}</div>
            </div>
          </div>
        ))}
      </div>

      <VBDots index={9} />
    </VBShell>
  );
}

// ────────────────────────────────────────────────────────────────
// B11 — Begin Your Journey
// ────────────────────────────────────────────────────────────────
function B11_Begin() {
  return (
    <VBShell glow={0.5} glowY="20%" stars={22}>
      <VBStatus />
      <VBProgress step={11} showSkip={false} />

      <div style={{
        position: 'absolute', top: 140, left: 0, right: 0, textAlign: 'center',
      }}>
        <div style={{ fontFamily: VB.arabic, fontSize: 56, color: VB.accent, textShadow: '0 0 30px rgba(242,166,113,0.5)', letterSpacing: -1.5 }}>ثقلين</div>
      </div>

      <div style={{ position: 'absolute', top: 244, left: 28, right: 28, textAlign: 'center' }}>
        <div style={{ fontSize: 36, fontWeight: 800, lineHeight: 1.05, letterSpacing: -0.8 }}>
          Begin your <span style={{ color: VB.accent }}>journey</span>.
        </div>
        <div style={{ marginTop: 12, fontSize: 14, color: VB.ink3, lineHeight: 1.5, maxWidth: 280, margin: '12px auto 0' }}>
          Save bookmarks, sync your reading progress, and carry the Quran with you everywhere.
        </div>
      </div>

      {/* CTAs */}
      <div style={{
        position: 'absolute', left: 22, right: 22, top: 416,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        <div style={{
          background: `linear-gradient(180deg, ${VB.accentBright}, ${VB.accentDeep})`,
          color: '#fff', borderRadius: 16, padding: '17px 0',
          textAlign: 'center', fontSize: 15, fontWeight: 700,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          boxShadow: '0 14px 32px rgba(209,122,72,0.45), inset 0 1px 0 rgba(255,255,255,0.25)',
        }}>
          <VBIcon name="apple" size={18} color="#fff" /> Continue with Apple
        </div>
        <div style={{
          background: 'rgba(255,255,255,0.08)', color: '#fff', borderRadius: 16,
          padding: '17px 0', textAlign: 'center', fontSize: 15, fontWeight: 700,
          border: `1px solid ${VB.glassBorder}`,
          backdropFilter: 'blur(10px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
        }}>
          <VBIcon name="user" size={16} stroke={1.8} /> Create account with email
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '6px 0' }}>
          <div style={{ flex: 1, height: 1, background: VB.glassBorder }} />
          <div style={{ fontSize: 10.5, color: VB.ink4, letterSpacing: 1.6, fontWeight: 700, textTransform: 'uppercase' }}>or</div>
          <div style={{ flex: 1, height: 1, background: VB.glassBorder }} />
        </div>

        <div style={{
          color: VB.ink2, textAlign: 'center',
          padding: '13px 0', fontSize: 14, fontWeight: 600,
        }}>
          Continue as guest
        </div>
      </div>

      {/* benefits */}
      <div style={{ position: 'absolute', left: 28, right: 28, bottom: 70, textAlign: 'center' }}>
        <div style={{ fontSize: 11, color: VB.ink4, lineHeight: 1.5 }}>
          By continuing you agree to our <span style={{ color: VB.ink2, textDecoration: 'underline' }}>Terms</span> and <span style={{ color: VB.ink2, textDecoration: 'underline' }}>Privacy Policy</span>.
        </div>
      </div>
    </VBShell>
  );
}

// export
Object.assign(window, {
  B1_Cover, B2_Promise, B3_Layers, B4_Daily, B5_Gems, B6_Quiz,
  B7_Result, B8_Track, B9_Motivate, B10_Seasons, B11_Begin,
});
