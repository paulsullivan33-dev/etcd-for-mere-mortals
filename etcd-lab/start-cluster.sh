#!/bin/sh
# Start all three members, then wait until every endpoint reports healthy.
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
"$LAB/start-member.sh" m1
"$LAB/start-member.sh" m2
"$LAB/start-member.sh" m3
EP="127.0.0.1:18085,127.0.0.1:18086,127.0.0.1:18087"
i=0
while [ $i -lt 30 ]; do
  if "$LAB/bin/etcdctl" --endpoints="$EP" endpoint health >/dev/null 2>&1; then
    echo "all three endpoints healthy after ${i}s"
    "$LAB/bin/etcdctl" --endpoints="$EP" endpoint health
    exit 0
  fi
  i=$((i+1)); sleep 1
done
echo "cluster did not become healthy within 30s" >&2
exit 1
