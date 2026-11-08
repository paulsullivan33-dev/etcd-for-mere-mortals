#!/bin/sh
# Leases: (A) grant, attach a key, revoke by hand, key is gone.
#         (B) grant a short lease, attach a key, let it expire, key is gone.
# Times are measured with date +%s around each wait.
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
C="$LAB/bin/etcdctl --endpoints=127.0.0.1:18085"

echo "PART A - revoke by hand"
OUT=$($C lease grant 30); echo "lease grant 30 -> $OUT"
LEASE=$(echo "$OUT" | awk '{print $2}')
$C put services/heartbeat/node-a alive --lease="$LEASE"
echo "attached: put services/heartbeat/node-a alive --lease=$LEASE"
$C get services/heartbeat/node-a
$C lease timetolive "$LEASE" --keys
$C lease revoke "$LEASE"
echo "after revoke, get returns:"
$C get services/heartbeat/node-a; echo "(empty above = key gone, exit $?)"

echo
echo "PART B - let a 10 second lease expire"
OUT=$($C lease grant 10); echo "lease grant 10 -> $OUT"
LEASE=$(echo "$OUT" | awk '{print $2}')
$C put services/heartbeat/node-b alive --lease="$LEASE"
echo "attached: put services/heartbeat/node-b alive --lease=$LEASE"
$C get services/heartbeat/node-b
START=$(date +%s)
echo "waiting for expiry, polling once a second (start epoch $START)..."
while true; do
  V=$($C get services/heartbeat/node-b --print-value-only)
  NOW=$(date +%s)
  if [ -z "$V" ]; then echo "key gone after $((NOW-START))s"; break; fi
  echo "  t+$((NOW-START))s: still alive"
  sleep 1
  if [ $((NOW-START)) -gt 30 ]; then echo "ERROR: key still present after 30s"; exit 1; fi
done
$C lease timetolive "$LEASE" || true
