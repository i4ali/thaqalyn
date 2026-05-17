// Onboarding app — composes Variant A and Variant B from window globals
// and renders them into a design canvas.

function OnboardingApp() {
  const W = window.PHONE_W;
  const H = window.PHONE_H;
  const Frame = window.PhoneFrame;

  const variantA = [
    { id: 'a01', label: '01 · Welcome',         C: window.S1_Cover },
    { id: 'a02', label: '02 · Promise',         C: window.S2_Promise },
    { id: 'a03', label: '03 · Five Layers',     C: window.S3_Layers },
    { id: 'a04', label: '04 · Daily Companion', C: window.S4_Daily },
    { id: 'a05', label: '05 · Gems',            C: window.S5_Gems },
    { id: 'a06', label: '06 · Quiz',            C: window.S6_Quiz },
    { id: 'a07', label: '07 · Result',          C: window.S7_Result },
    { id: 'a08', label: '08 · Track Progress',  C: window.S8_Track },
    { id: 'a09', label: '09 · Stay Motivated',  C: window.S9_Motivate },
    { id: 'a10', label: '10 · Seasons',         C: window.S10_Seasons },
    { id: 'a11', label: '11 · Begin Journey',   C: window.S11_Begin },
  ];

  const variantC = [
    { id: 'c01', label: '01 · Welcome',         C: window.C1_Cover },
    { id: 'c02', label: '02 · Promise',         C: window.C2_Promise },
    { id: 'c03', label: '03 · Five Layers',     C: window.C3_Layers },
    { id: 'c04', label: '04 · Daily Companion', C: window.C4_Daily },
    { id: 'c05', label: '05 · Gems',            C: window.C5_Gems },
    { id: 'c06', label: '06 · Quiz',            C: window.C6_Quiz },
    { id: 'c07', label: '07 · Result',          C: window.C7_Result },
    { id: 'c08', label: '08 · Track Progress',  C: window.C8_Track },
    { id: 'c09', label: '09 · Stay Motivated',  C: window.C9_Motivate },
    { id: 'c10', label: '10 · Seasons',         C: window.C10_Seasons },
    { id: 'c11', label: '11 · Begin Journey',   C: window.C11_Begin },
  ];

  const variantB = [
    { id: 'b01', label: '01 · Welcome',         C: window.B1_Cover },
    { id: 'b02', label: '02 · Promise',         C: window.B2_Promise },
    { id: 'b03', label: '03 · Five Layers',     C: window.B3_Layers },
    { id: 'b04', label: '04 · Daily Companion', C: window.B4_Daily },
    { id: 'b05', label: '05 · Gems',            C: window.B5_Gems },
    { id: 'b06', label: '06 · Quiz',            C: window.B6_Quiz },
    { id: 'b07', label: '07 · Result',          C: window.B7_Result },
    { id: 'b08', label: '08 · Track Progress',  C: window.B8_Track },
    { id: 'b09', label: '09 · Stay Motivated',  C: window.B9_Motivate },
    { id: 'b10', label: '10 · Seasons',         C: window.B10_Seasons },
    { id: 'b11', label: '11 · Begin Journey',   C: window.B11_Begin },
  ];

  return (
    <DesignCanvas
      title="althaqalayn · Onboarding"
      subtitle="Two complete variants of the 11-screen onboarding flow."
    >
      <DCSection
        id="variant-a"
        title="Variant A · Parchment"
        subtitle="Editorial light, warm parchment + ink, Instrument Serif italic, restrained line icons."
      >
        {variantA.map(s => (
          <DCArtboard
            key={s.id} id={s.id} label={s.label}
            width={W + 16} height={H + 16}
            data-screen-label={'A · ' + s.label}
          >
            <Frame><s.C /></Frame>
          </DCArtboard>
        ))}
      </DCSection>

      <DCSection
        id="variant-c"
        title="Variant C · Native"
        subtitle="Faithful to the app's warm-inviting vocabulary: soft lavender→peach gradients, pastel chip icons, friendly bold sans — elevated with better hierarchy."
      >
        {variantC.map(s => (
          <DCArtboard
            key={s.id} id={s.id} label={s.label}
            width={W + 16} height={H + 16}
            data-screen-label={'C · ' + s.label}
          >
            <Frame><s.C /></Frame>
          </DCArtboard>
        ))}
      </DCSection>

      <DCSection
        id="variant-b"
        title="Variant B · Lantern"
        subtitle="Warm-dark glass, display sans, brighter amber, gamified visuals — same flow, different mood."
      >
        {variantB.map(s => (
          <DCArtboard
            key={s.id} id={s.id} label={s.label}
            width={W + 16} height={H + 16}
            data-screen-label={'B · ' + s.label}
          >
            <Frame><s.C /></Frame>
          </DCArtboard>
        ))}
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<OnboardingApp />);
