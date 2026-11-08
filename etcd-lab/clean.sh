#!/bin/sh
# Stop the cluster and delete every member's data directory.
# The next start-cluster.sh then forms a brand-new cluster.
set -eu
LAB=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
"$LAB/stop-cluster.sh" || true
rm -rf "$LAB/data" "$LAB/pids"
echo "data and pid files removed; logs kept in $LAB/logs"
