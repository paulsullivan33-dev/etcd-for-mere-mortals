#!/bin/sh
# Watch demonstration: start a watch in the background, change the key
# twice from the foreground, then show what the watch printed.
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
EP="127.0.0.1:18085"
OUT="$LAB/transcripts/watch-events.tmp"
rm -f "$OUT"
"$LAB/bin/etcdctl" --endpoints="$EP" put services/web-frontend/status starting >/dev/null
# The watch: --prefix would watch a tree; a single key here.
timeout 12 "$LAB/bin/etcdctl" --endpoints="$EP" watch services/web-frontend/status > "$OUT" 2>&1 &
WPID=$!
sleep 2
echo "watch is running in the background (shell pid $WPID); now changing the key twice:"
"$LAB/bin/etcdctl" --endpoints="$EP" put services/web-frontend/status ready
sleep 1
"$LAB/bin/etcdctl" --endpoints="$EP" put services/web-frontend/status draining
sleep 1
"$LAB/bin/etcdctl" --endpoints="$EP" del services/web-frontend/status
wait $WPID || true
echo "--- what the watch printed ---"
cat "$OUT"
rm -f "$OUT"
