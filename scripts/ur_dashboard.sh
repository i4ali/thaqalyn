#!/bin/zsh
# Open the live Urdu translation status dashboard (scripts/passage_ur_dashboard.py).
# Starts the local server in the background if it is not already up, then opens
# the page in the default browser. The page re-reads the data on every refresh.
#
#   scripts/ur_dashboard.sh         start (if needed) and open
#   scripts/ur_dashboard.sh stop    stop the server

ROOT=${0:A:h:h}
PORT=${UR_DASHBOARD_PORT:-8765}
URL="http://127.0.0.1:$PORT"

if [[ $1 == stop ]]; then
  pkill -f "passage_ur_dashboard.py --serve" && echo "dashboard stopped" || echo "dashboard was not running"
  exit 0
fi

if ! curl -s -o /dev/null "$URL"; then
  nohup python3 "$ROOT/scripts/passage_ur_dashboard.py" --serve --port "$PORT" \
    > "$ROOT/passages_work/ur_dashboard_server.log" 2>&1 < /dev/null &
  disown
  for _ in {1..20}; do curl -s -o /dev/null "$URL" && break; sleep 0.25; done
fi

curl -s -o /dev/null "$URL" || { echo "dashboard failed to start, see passages_work/ur_dashboard_server.log"; exit 1; }
echo "$URL"
open "$URL"
