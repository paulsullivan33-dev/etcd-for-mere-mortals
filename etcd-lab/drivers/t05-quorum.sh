#!/bin/sh
# The quorum lesson, measured:
#   3 members up -> write works
#   stop ONE (m3) -> 2 of 3 remain, a majority -> write still works
#   stop a SECOND (m2) -> 1 of 3 remains, no majority -> write and read refuse
#   restart both -> cluster recovers, data written earlier is still there
set -u
LAB=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ALL="127.0.0.1:18085,127.0.0.1:18086,127.0.0.1:18087"
C="$LAB/bin/etcdctl"

step() { echo; echo "=== $1 ==="; }

step "baseline: all three members up"
$C --endpoints="$ALL" endpoint health
$C --endpoints="$ALL" put services/quorum-check/state before-any-failure
$C --endpoints="$ALL" get services/quorum-check/state

step "stop ONE member (m3)"
"$LAB/stop-member.sh" m3
sleep 2
$C --endpoints="127.0.0.1:18085,127.0.0.1:18086" endpoint health
S=$(date +%s%N)
$C --endpoints="127.0.0.1:18085,127.0.0.1:18086" put services/quorum-check/state one-member-down
E=$(date +%s%N); echo "put with 2 of 3 up: OK in $(( (E-S)/1000000 ))ms"
$C --endpoints="127.0.0.1:18085" get services/quorum-check/state

step "stop a SECOND member (m2): only 1 of 3 remains, no majority"
"$LAB/stop-member.sh" m2
sleep 3
echo "endpoint health for the survivor, m1 alone:"
$C --endpoints="127.0.0.1:18085" endpoint health || echo "(health check failed, exit $?)"
echo "attempt a WRITE with a 5 second command timeout:"
timeout 20 $C --endpoints="127.0.0.1:18085" --command-timeout=5s put services/quorum-check/state should-not-stick; echo "(put exit $?)"
echo "attempt a READ with a 5 second command timeout:"
timeout 20 $C --endpoints="127.0.0.1:18085" --command-timeout=5s get services/quorum-check/state; echo "(get exit $?)"

step "bring both members back"
"$LAB/start-member.sh" m2
"$LAB/start-member.sh" m3
i=0
while [ $i -lt 30 ]; do
  if $C --endpoints="$ALL" endpoint health >/dev/null 2>&1; then echo "all healthy again after ${i}s"; break; fi
  i=$((i+1)); sleep 1
done
$C --endpoints="$ALL" endpoint health
$C --endpoints="$ALL" endpoint status -w table
echo "the value written while one member was down is still there:"
$C --endpoints="$ALL" get services/quorum-check/state
echo "and new writes work again:"
$C --endpoints="$ALL" put services/quorum-check/state recovered
$C --endpoints="$ALL" get services/quorum-check/state
