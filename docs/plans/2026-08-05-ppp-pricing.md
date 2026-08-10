# PPP-Adjusted Pricing - Lifetime Unlock (`com.thaqalayn.premium.tafsir`)

**Date:** 2026-08-05
**Metric:** Purchasing Power Parity (PPP), applied via World Bank income-group buckets.
**Anchor:** US base price = **$19.99** (one-time non-consumable, "unlock all 114 surahs").
**Problem this fixes:** Apple's auto-pricing converts your $19.99 base to other storefronts using **foreign-exchange rate + local tax only**. It ignores purchasing power, so users in Pakistan, India, Egypt, Bangladesh, Nigeria, etc. see a price that is "FX-fair" but far too high relative to local incomes. This doc lowers those storefronts to a locally-fair level.

---

## The price ladder (4 buckets)

| Bucket (World Bank income group) | % of US | Price point | Why |
|---|---|---|---|
| **High income** | 100% | **$19.99** | US, Canada, W. Europe, Gulf, Japan, Korea, Australia. Leave Apple's default (FX + tax) as-is. |
| **Upper-middle income** | 50% | **$9.99** | China, Turkey, Malaysia, Brazil, Mexico, Iraq, Azerbaijan, Kazakhstan, Russia, South Africa. |
| **Lower-middle income** | 35% | **$6.99** | **The workhorse tier for this app:** India, Pakistan, Egypt, Bangladesh, Nigeria, Indonesia, Philippines, Morocco, Lebanon. |
| **Low income** | 20% | **$3.99** | Afghanistan, Yemen, Sudan, Ethiopia, DRC, most low-income sub-Saharan Africa. |

This ladder is **softened PPP**, not raw PPP (see next section). Round `.99` points are used because they exist in every storefront's price-point list.

---

## Why "softened," not raw PPP

Raw PPP (scaling price to each country's actual GNI-per-capita ratio vs the US) collapses too far:

| Bucket | Raw PPP would suggest | This doc uses | Reason for softening |
|---|---|---|---|
| Upper-middle | ~$5 (25%) | **$9.99** (50%) | App buyers skew wealthier than the national median. |
| Lower-middle | ~$2 (10%) | **$6.99** (35%) | Below ~$5 the Apple cut + FX noise make it barely worth listing. |
| Low income | ~$0.60 (3%) | **$3.99** (20%) | Apple price-point floors; anchoring/psychology; keep it a "real" purchase. |

So this is: **~4x fairer than Apple's default** (which charges everyone ~100%), but **more revenue-protective than raw PPP** (which would give it away). It's the same shape Steam / Spotify / Netflix use.

**If you want to dial it:** more aggressive (more buyers, less per-buyer) = move toward raw PPP, e.g. $6.99 / $4.99 / $2.99. More conservative = $12.99 / $8.99 / $5.99. The buckets and the workflow below stay identical; only the three lower numbers change.

---

## Country -> bucket mapping (key markets for this app)

Bolded = large actual or potential Shia audience, so these matter most.

**High income ($19.99 - leave as default):**
United States, Canada, United Kingdom, Ireland, all EU/EEA, Switzerland, Norway,
**Saudi Arabia, UAE, Qatar, Kuwait, Bahrain, Oman**, Israel, Japan, South Korea,
Singapore, Hong Kong, Taiwan, Australia, New Zealand, Brunei.

**Upper-middle income ($9.99):**
China, **Turkey**, Malaysia, Thailand, **Iraq**, **Azerbaijan**, Kazakhstan,
Russia, Brazil, Mexico, Argentina, Colombia, South Africa, Georgia, Armenia, Jordan, Botswana.
- *Iraq:* World Bank rates it upper-middle (oil GNI), but on-the-ground willingness-to-pay is lower. Consider dropping Iraq to the $6.99 tier given the audience.

**Lower-middle income ($6.99 - the workhorse tier):**
**India, Pakistan, Egypt, Bangladesh, Nigeria**, Indonesia, Philippines, Vietnam,
Morocco, Algeria, Tunisia, **Lebanon**, Kenya, Ghana, Bolivia, Sri Lanka, Nepal, Uzbekistan, Kyrgyzstan.
- *Indonesia:* recently reclassified upper-middle by the World Bank, but app WTP sits closer to this tier - list it here.
- *Lebanon:* reclassified down to lower-middle after the 2019+ collapse.

**Low income ($3.99):**
**Afghanistan, Yemen**, Sudan, Ethiopia, DR Congo, Somalia, South Sudan, Chad, Niger, Mali, Burkina Faso, Mozambique, Uganda, Tajikistan.

---

## Local-currency reference (approximate)

FX moves daily and Apple's price points are **discrete and tax-inclusive**, so treat these as "does this look right" checks, not exact figures - Apple's dropdown shows the real current point per storefront. Two shortcuts:
- **Gulf currencies (SAR, AED, QAR) are USD-pegged**, so they don't drift.
- **Several Middle East / Africa storefronts transact directly in USD**, so the price *is* the dollar figure (marked "USD storefront" below).

**High income - target $19.99**

| Country | Approx. local price |
|---|---|
| United States | $19.99 |
| Canada | C$27.99 |
| Eurozone | €21.99 |
| United Kingdom | £19.99 |
| Australia | A$32.99 |
| Japan | ¥3,000 |
| Saudi Arabia | SR 74.99 |
| UAE | AED 72.99 |

**Upper-middle - target $9.99**

| Country | Approx. local price |
|---|---|
| China | ¥68 |
| Turkey | ₺349 |
| Malaysia | RM 42.90 |
| Brazil | R$49.90 |
| Mexico | MX$189 |
| Azerbaijan | ₼16.99 |
| South Africa | R179 |
| Iraq | $9.99 (USD storefront) |

**Lower-middle - target $6.99**

| Country | Approx. local price |
|---|---|
| India | ₹599 |
| Pakistan | Rs 1,900 |
| Egypt | E£ 349 |
| Bangladesh | ৳ 799 |
| Indonesia | Rp 109,000 |
| Nigeria | ₦ 10,900 |
| Philippines | ₱ 399 |
| Lebanon | $6.99 (USD storefront) |

**Low income - target $3.99**

Most low-income storefronts (**Afghanistan, Yemen**, Sudan, Ethiopia, DR Congo, Somalia, etc.) transact in **USD**, so the price is simply **$3.99** - just pick the $3.99 point directly. The few that use a local currency (e.g. Tanzania, Uganda) still map to roughly the $3.99 equivalent; use Apple's shown figure.

> **Russia** appears in the upper-middle list above, but Apple **suspended new product/App Store sales in Russia (March 2022)**. Treat it like Iran - likely not sellable; verify in your storefront list before relying on it.

---

## Storefronts you CANNOT sell to (relevant to this audience)

The App Store is **unavailable** in these countries due to US sanctions, so they will not appear in your storefront list and no price can be set:

- **Iran** - the single largest Shia-majority country. Not addressable via the App Store at all.
- **Syria**, **Cuba**, **North Korea**, **Crimea**, and (intermittently) **Sudan**.

Worth remembering when reasoning about your total addressable market: a large slice of the natural audience for this app cannot transact on the App Store regardless of price. (Android / direct web would be the only route there - out of scope for this doc.)

---

## How to enter it in App Store Connect

There is **no "apply to income group" button** - Apple makes you set price per storefront. You do it once:

1. **App Store Connect -> your app -> Monetization -> In-App Purchases -> "Premium Tafsir"** (`com.thaqalayn.premium.tafsir`).
2. Under **Pricing**, confirm the base (United States) is **$19.99**. Apple has auto-filled all other storefronts from this by FX + tax.
3. Click **Edit prices**. Apple shows the full storefront list, each with its current price point and the USD-equivalent (your proceeds).
4. For every country in the **Upper-middle** list, change its price point to the local equivalent of **$9.99**. Apple's dropdown shows the USD figure next to each local point - pick the nearest one at/just below $9.99.
5. Repeat for the **Lower-middle** list -> nearest local point to **$6.99**.
6. Repeat for the **Low income** list -> nearest local point to **$3.99**.
7. Leave every **High income** storefront untouched (Apple's default = full price).
8. Save. Changes take effect within a few hours; existing owners are unaffected (one-time purchase).

**Note - USD storefronts:** Several smaller storefronts (parts of the Middle East and Africa) transact directly in USD, so the price point *is* the dollar figure - just pick $9.99 / $6.99 / $3.99 directly.

**Local-currency sanity checks:** see the **Local-currency reference** section above - it lists approximate local prices for the key markets in all four buckets. Pick the nearest point Apple actually offers.

---

## Two things that make low prices more viable

1. **Apple Small Business Program** - if you earn under $1M/yr (almost certainly), enroll to pay **15% commission instead of 30%**. At $6.99 that lifts your proceeds from ~$4.89 to ~$5.94. Enroll once in App Store Connect; it applies to every storefront and makes the whole PPP ladder pay off.
2. **Re-check annually** - the World Bank updates income-group classifications every July; a couple of countries shift each year (Indonesia, Lebanon, Iraq have all moved recently). Skim the list once a year.

---

## When you add the annual subscription

Your strategy notes point toward adding an **annual + lifetime** split. When you do, apply the **same four-bucket percentages** to the annual price:
- e.g. annual $14.99 US -> UM $7.99, LM $4.99, Low $2.99.
The bucket-to-country mapping above is reusable verbatim; only the base number changes.
