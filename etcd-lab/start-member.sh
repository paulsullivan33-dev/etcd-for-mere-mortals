#!/bin/sh
# Start one member of the 3-member lab cluster.
# Usage: ./start-member.sh m1|m2|m3
# Ports (all on 127.0.0.1 only):
#   m1 client 18085 peer 18185
#   m2 client 18086 peer 18186
#   m3 client 18087 peer 18187
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN="$LAB/bin/etcd"
NAME=${1:?usage: start-member.sh m1|m2|m3}
case "$NAME" in
  m1) CLIENT=18085; PEER=18185 ;;
  m2) CLIENT=18086; PEER=18186 ;;
  m3) CLIENT=18087; PEER=18187 ;;
  *) echo "unknown member $NAME" >&2; exit 2 ;;
esac
mkdir -p "$LAB/data" "$LAB/logs" "$LAB/pids"
if [ -f "$LAB/pids/$NAME.pid" ] && kill -0 "$(cat "$LAB/pids/$NAME.pid")" 2>/dev/null; then
  echo "$NAME already running (pid $(cat "$LAB/pids/$NAME.pid"))"
  exit 0
fi
if [ -d "$LAB/data/$NAME.etcd" ]; then STATE=existing; else STATE=new; fi
CLUSTER="m1=http://127.0.0.1:18185,m2=http://127.0.0.1:18186,m3=http://127.0.0.1:18187"
nohup "$BIN" \
  --name "$NAME" \
  --data-dir "$LAB/data/$NAME.etcd" \
  --listen-client-urls "http://127.0.0.1:$CLIENT" \
  --advertise-client-urls "http://127.0.0.1:$CLIENT" \
  --listen-peer-urls "http://127.0.0.1:$PEER" \
  --initial-advertise-peer-urls "http://127.0.0.1:$PEER" \
  --initial-cluster "$CLUSTER" \
  --initial-cluster-token etcd-lab-token \
  --initial-cluster-state "$STATE" \
  > "$LAB/logs/$NAME.log" 2>&1 &
echo $! > "$LAB/pids/$NAME.pid"
echo "started $NAME pid $! client 127.0.0.1:$CLIENT peer 127.0.0.1:$PEER state $STATE"
