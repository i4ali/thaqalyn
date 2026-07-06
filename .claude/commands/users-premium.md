---
description: List Supabase app users (signups) and their premium status
argument-hint: "[email-substring | N (days) | --days N | --all]"
allowed-tools: Bash(bash scripts/supabase_users.sh:*)
---

Run the project's Supabase users + premium report and present it cleanly.

!`bash scripts/supabase_users.sh $ARGUMENTS`

Using the script output above:

- Render the summary counts as a short bulleted list (total users, premium, free, recent-signup windows, orphan prefs).
- Render the user rows as a Markdown table with columns **Signed up · Tier · Provider · Last seen · Email**, prefixing each PREMIUM row with 🟡.
- If no arguments were passed, note that this defaults to the **20 most recent signups**, and that they can pass an **email substring**, a **number of days** (e.g. `7`), `--days N`, or `--all`.
- If the output is an error (missing key / non-200 / no rows), surface it plainly and remind them the script reads `SUPABASE_URL` + `SUPABASE_SECRET_KEY` from `.env`.

Caveats to keep in mind when reporting:
- `is_premium` comes from `public.user_preferences` — it's the app's **synced StoreKit flag** (may include sandbox / TestFlight / comped accounts), not a guaranteed paying App Store subscriber.
- This is the owner's own user data (emails = PII); do **not** send it to any external service.
