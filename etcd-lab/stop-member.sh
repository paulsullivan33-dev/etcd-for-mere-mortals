#!/bin/sh
# Stop one member by the pid recorded at start. Usage: ./stop-member.sh m1|m2|m3
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
NAME=${1:?usage: stop-member.sh m1|m2|m3}
PIDFILE="$LAB/pids/$NAME.pid"
if [ ! -f "$PIDFILE" ]; then echo "$NAME: no pid file"; exit 0; fi
PID=$(cat "$PIDFILE")
if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  i=0; while kill -0 "$PID" 2>/dev/null && [ $i -lt 10 ]; do i=$((i+1)); sleep 1; done
  echo "stopped $NAME pid $PID"
else
  echo "$NAME pid $PID was not running"
fi
rm -f "$PIDFILE"
