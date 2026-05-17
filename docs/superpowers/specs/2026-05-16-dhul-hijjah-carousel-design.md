# Dhul-Hijjah Journey — Promotional Carousel Spec

**Date:** 2026-05-16
**Status:** Approved (design), pending implementation plan
**Deliverable:** 5-slide social carousel promoting the app's Dhul-Hijjah Journey feature

---

## 1. Goal

Drive App Store installs of **Thaqalayn** by promoting the **Dhul-Hijjah Journey** feature
ahead of/during Hajj season, using an urgency-led "don't waste the best 10 days"
angle.

Target platforms: Instagram / TikTok carousel (and reusable on other feeds).

## 2. Feature Being Promoted

The Dhul-Hijjah Journey (commit `3147740`) is a 10-day guided journey through the
first ten days of Dhul-Hijjah, mirroring the app's Ramadan Journey pattern. Each
day has a theme, an Arabic dua (with transliteration + English + source), Quran
verses with relevance notes, a tafsir focus, and a reflection prompt. Day 1 is
free; days 2–10 are premium. The journey peaks at **Day 9 — Day of Arafah** and
**Day 10 — Eid al-Adha**.

Day themes: The Blessed Ten · Remembrance · Repentance · Pure Monotheism ·
Sacrifice & Charity · The Submission of Ibrahim · The Call of Hajj · Day of
Tarwiyah · The Day of Arafah · Eid al-Adha.

Content source for any Arabic: `Thaqalayn/Data/hajj_journey.json`
(Mafatih al-Jinan amaal + Du'a Arafah of Imam al-Husayn AS).

## 3. Creative Direction

| Decision | Choice |
|----------|--------|
| Core angle | "You're about to waste the best 10 days of the year" — urgency / problem→solution |
| Format | 5 slides: Hook → 3 pillars → CTA |
| Aesthetic | Dark & dramatic: deep night-sky / black backgrounds, glowing gold typography, minimal abstract accents |
| Aspect ratio | 4:5 portrait, **1080 × 1350 px**, PNG |
| CTA | Download Thaqalayn (App Store) — app mockup + App Store badge |

## 4. Slide-by-Slide Content

> Copy below is the approved working copy. Exact Arabic/hadith wording is gated by
> Section 6 before rendering.

**Slide 1 — Hook**
- Headline: *"You're about to waste the best 10 days of the year."*
- Subtext: "The first ten days of Dhul-Hijjah"
- Visual: night sky over a distant Kaaba silhouette, faint glow on the horizon.

**Slide 2 — Pillar 1: Why these days matter**
- Hadith (English): *"There are no days in which righteous deeds are more beloved
  to Allah than these ten days."* — attributed to the Prophet ﷺ
- Verified Arabic of the hadith beneath it (see Section 6).
- Visual: light breaking through dark clouds.

**Slide 3 — Pillar 2: What you'd miss**
- Body: "Fasting · dhikr · repentance · **the Day of Arafah** — the day of
  forgiveness. Most of us let them slip by, unaware."
- Visual: hanging lanterns in darkness.

**Slide 4 — Pillar 3: How the app carries you**
- Body: "The **Dhul-Hijjah Journey** walks you through all 10 days — a dua,
  verses, and a reflection for each, building to Arafah and Eid al-Adha."
- Visual: dawn desert / first light (the journey's arc toward Eid).

**Slide 5 — CTA**
- Headline: *"Don't do these 10 days alone."*
- Action: "Download Thaqalayn" + app icon mockup + App Store badge.
- Visual: dark background, brand glow.

## 5. Production Pipeline

1. **Backgrounds (Nano Banana Pro):** generate 5 dark, atmospheric, abstract
   backgrounds at 1080×1350 (4:5). Constraints: **no text, no faces, no figures**;
   reverent, cinematic, dark with a single warm/gold light source. Use the
   project's existing Nano Banana image-generation path (OpenRouter).
2. **Typography composite (Python / PIL):** overlay all text — English + verified
   Arabic — onto the backgrounds for pixel-accurate, theologically-correct
   rendering. Text is **never AI-generated**. Gold treatment: brand `#E67A3C`
   graduating to a brighter gold for the glow; light cream for body text on dark.
3. **Slide 5 composite:** add the real app icon (`appicon.png` /
   `Thaqalayn/Assets.xcassets/AppIcon.appiconset/icon-1024.png`) and a standard
   App Store badge.
4. **Output:** 5 sequentially named PNGs in a new `dhul_hijjah_carousel/` folder
   (e.g. `slide_1.png` … `slide_5.png`).

## 6. Theological / Accuracy Gate (blocking)

- **Arabic is never AI-generated.** All Arabic glyphs are composited from vetted
  text only.
- Quran/dua Arabic, if used, is taken verbatim from
  `Thaqalayn/Data/hajj_journey.json`.
- For the **Slide 2 hadith**, a well-attested Arabic wording will be drafted and
  **shown to the user for explicit approval before any slide is rendered**.
- Honorifics: ﷺ for the Prophet, (AS) where applicable; respectful tone
  throughout; no depiction of sacred figures or faces.

## 7. Non-Goals (YAGNI)

- No video / Kling (dropped — carousel only).
- No animation or motion.
- No per-day breakdown slides (10-day detail intentionally collapsed into
  Pillar 3).
- No in-app changes; this is a marketing asset only.
- No automated posting/scheduling to social platforms.

## 8. Success Criteria

- 5 PNGs, exactly 1080×1350, in `dhul_hijjah_carousel/`.
- Slide order reads as Hook → 3 pillars → CTA and is legible at feed size.
- All Arabic verified and user-approved before render; no AI-rendered Arabic.
- Slide 5 contains a recognizable Thaqalayn app mockup + App Store badge.
- Visual style is consistently dark & dramatic with gold typography across all 5.
