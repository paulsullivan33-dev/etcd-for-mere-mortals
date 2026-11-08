#!/bin/sh
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
"$LAB/stop-member.sh" m1 || true
"$LAB/stop-member.sh" m2 || true
"$LAB/stop-member.sh" m3 || true
