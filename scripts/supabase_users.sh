#!/usr/bin/env bash
# supabase_users.sh — list app users (signups) and their premium status.
#
# Joins auth.users (Auth Admin API) with public.user_preferences.is_premium.
# Reads SUPABASE_URL + SUPABASE_SECRET_KEY (service-role secret) from the repo .env.
#
# Usage:
#   scripts/supabase_users.sh                  summary + 20 most recent signups
#   scripts/supabase_users.sh --all            summary + every user (newest first)
#   scripts/supabase_users.sh --days 7         summary + signups in the last 7 days
#   scripts/supabase_users.sh 7                shorthand for --days 7
#   scripts/supabase_users.sh ali@example.com  look up user(s) by email substring
#
# Note: is_premium is the app's synced StoreKit flag (may include sandbox/comped
# accounts), not a guaranteed paying App Store subscriber.

set -euo pipefail

usage() {
  awk 'NR>=2 && /^#/ { sub(/^# ?/, ""); print; next } NR>=2 { exit }' "$0"
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"
[ -f "$ENV_FILE" ] || { echo "error: $ENV_FILE not found" >&2; exit 1; }

# Pull only the Supabase vars from .env (don't execute arbitrary lines).
SUPABASE_URL=""; SUPABASE_SECRET_KEY=""; SUPABASE_SERVICE_ROLE_KEY=""; SUPABASE_SERVICE_KEY=""
while IFS='=' read -r k v; do
  case "$k" in
    SUPABASE_URL)               SUPABASE_URL="$v" ;;
    SUPABASE_SECRET_KEY)        SUPABASE_SECRET_KEY="$v" ;;
    SUPABASE_SERVICE_ROLE_KEY)  SUPABASE_SERVICE_ROLE_KEY="$v" ;;
    SUPABASE_SERVICE_KEY)       SUPABASE_SERVICE_KEY="$v" ;;
  esac
done < <(grep -E '^[A-Za-z_]+=' "$ENV_FILE" || true)

KEY="${SUPABASE_SECRET_KEY:-${SUPABASE_SERVICE_ROLE_KEY:-${SUPABASE_SERVICE_KEY:-}}}"
[ -n "$SUPABASE_URL" ] || { echo "error: SUPABASE_URL missing in $ENV_FILE" >&2; exit 1; }
[ -n "$KEY" ]         || { echo "error: SUPABASE_SECRET_KEY (or SERVICE_ROLE key) missing in $ENV_FILE" >&2; exit 1; }
command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 1; }

# --- parse args ---
MODE="recent"; FILTER=""; DAYS=0; LABEL="20 most recent signups"
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --all)     MODE="all";  LABEL="all users (newest first)" ;;
  --days)    MODE="days"; DAYS="${2:-30}"; LABEL="signups in the last ${DAYS} days" ;;
  "")        : ;;
  *)
    if [[ "${1}" =~ ^[0-9]+$ ]]; then
      MODE="days"; DAYS="${1}"; LABEL="signups in the last ${DAYS} days"
    else
      MODE="lookup"; FILTER="${1}"; LABEL="users matching \"${FILTER}\""
    fi ;;
esac

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- fetch auth users (paginated) ---
: > "$TMP/users.ndjson"
page=1
while :; do
  resp="$(curl -s -w '\n%{http_code}' \
    "$SUPABASE_URL/auth/v1/admin/users?per_page=1000&page=$page" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"
  code="${resp##*$'\n'}"; body="${resp%$'\n'*}"
  [ "$code" = "200" ] || { echo "error: Auth Admin API returned HTTP $code" >&2; printf '%s' "$body" | head -c 400 >&2; echo >&2; exit 1; }
  n="$(printf '%s' "$body" | jq '.users | length')"
  printf '%s' "$body" | jq -c '.users[]' >> "$TMP/users.ndjson"
  [ "$n" -lt 1000 ] && break
  page=$((page + 1))
done
jq -s '.' "$TMP/users.ndjson" > "$TMP/users.json"

# --- fetch premium flags (paginated) ---
: > "$TMP/prefs.ndjson"
offset=0
while :; do
  resp="$(curl -s -w '\n%{http_code}' \
    "$SUPABASE_URL/rest/v1/user_preferences?select=user_id,is_premium,bookmark_limit,created_at,updated_at&limit=1000&offset=$offset" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"
  code="${resp##*$'\n'}"; body="${resp%$'\n'*}"
  [ "$code" = "200" ] || { echo "error: user_preferences returned HTTP $code" >&2; printf '%s' "$body" | head -c 400 >&2; echo >&2; exit 1; }
  n="$(printf '%s' "$body" | jq 'length')"
  printf '%s' "$body" | jq -c '.[]' >> "$TMP/prefs.ndjson"
  [ "$n" -lt 1000 ] && break
  offset=$((offset + 1000))
done
jq -s '.' "$TMP/prefs.ndjson" > "$TMP/prefs.json"

# --- summary ---
echo "Supabase users — ${SUPABASE_URL#https://}"
echo
jq -rn --slurpfile u "$TMP/users.json" --slurpfile p "$TMP/prefs.json" '
  def pt: sub("\\.[0-9]+";"") | fromdateiso8601;
  ($p[0] | map({key:.user_id, value:.is_premium}) | from_entries) as $pm |
  ($u[0] | map(. + {premium: ($pm[.id] // false)}))               as $U  |
  (now) as $n |
  ($U|length) as $tot | ([$U[]|select(.premium)]|length) as $prem |
  def win($s): [$U[]|select((.created_at|pt) > ($n-$s))]|length;
  def winp($s): [$U[]|select((.created_at|pt) > ($n-$s))|select(.premium)]|length;
  "Total users:   \($tot)",
  "Premium:       \($prem)  (\(if $tot>0 then ($prem*100/$tot|floor) else 0 end)%)",
  "Free:          \($tot-$prem)",
  "Signups 24h:   \(win(86400))",
  "Signups 7d:    \(win(604800))  (premium: \(winp(604800)))",
  "Signups 30d:   \(win(2592000))  (premium: \(winp(2592000)))",
  "Orphan prefs:  \([$p[0][].user_id] - [$U[].id] | length)  (deleted accounts w/ leftover rows)"
'

# --- table ---
echo
echo "Showing: ${LABEL}"
jq -rn --slurpfile u "$TMP/users.json" --slurpfile p "$TMP/prefs.json" \
   --arg mode "$MODE" --arg filter "$FILTER" --argjson days "$DAYS" '
  def pt: sub("\\.[0-9]+";"") | fromdateiso8601;
  def fmt: pt | strftime("%Y-%m-%d %H:%M");
  ($p[0] | map({key:.user_id, value:.is_premium}) | from_entries) as $pm |
  (now) as $n |
  $u[0] | map(. + {premium: ($pm[.id] // false)})
    | sort_by(.created_at) | reverse
    | (if   $mode=="all"    then .
       elif $mode=="days"   then map(select((.created_at|pt) > ($n - ($days*86400))))
       elif $mode=="lookup" then map(select(.email!=null and (.email|ascii_downcase|contains($filter|ascii_downcase))))
       else .[0:20] end)
    | .[]
    | [ (.created_at|fmt),
        (if .premium then "PREMIUM" else "free" end),
        (.app_metadata.provider // (.identities[0].provider) // "?"),
        (.last_sign_in_at | if .==null then "never" else fmt end),
        (.email // (if .is_anonymous then "(anonymous)" else "(no email)" end)) ]
    | @tsv' > "$TMP/rows.tsv"

if [ ! -s "$TMP/rows.tsv" ]; then
  echo "(no matching users)"
else
  { printf 'SIGNED_UP\tTIER\tPROVIDER\tLAST_SEEN\tEMAIL\n'; cat "$TMP/rows.tsv"; } \
    | column -t -s "$(printf '\t')"
fi
