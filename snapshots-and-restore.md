# Snapshots and restore

Outcome: the whole state of the cluster
captured in one file you can inspect
offline — and restored into a fresh data
directory, with an honest line drawn
between what the lab proved and what a
full disaster rehearsal would add.

## Saving: one command, one file

A **snapshot** is a complete copy of the
store at a moment, taken from any one
member — one is enough, because every
member holds the whole agreed state:

```
$ etcdctl snapshot save snapshots/lab-snapshot.db
... fetched snapshot, endpoint: 127.0.0.1:18085, size: 25 kB
Snapshot saved at snapshots/lab-snapshot.db
```

(transcript
`etcd-lab/transcripts/t06-snapshot.txt`.)
The log lines show the mechanics: a
temporary `.part` file, the snapshot
streamed from the endpoint, then saved.
Twenty-five kilobytes held the lab's
entire cluster — three services, its
history, everything — which is chapter
15's "small" made tangible.

## Inspecting: etcdutl works offline

`etcdutl` reads the file with no cluster
running and no cluster needed:

```
$ etcdutl snapshot status snapshots/lab-snapshot.db --write-out=table
│ 4db478b7 │ 17 │ 3 │ 25 kB │ 3.7.0 │
   HASH      REVISION  TOTAL KEYS  TOTAL SIZE  VERSION
```

A hash (so two snapshots can be compared
without opening them), the revision the
snapshot was taken at, the key count, and
the size. Notice: 3 keys, though the lab
had written far more than three things by
then — a snapshot holds the *live* state
at its revision, not every key that ever
existed. Deleted keys and expired leases
are absent, correctly.

## Restoring: a data directory, reborn

Restore turns the file back into a
member's data directory:

```
$ etcdutl snapshot restore snapshots/lab-snapshot.db \
    --data-dir data-restored/m1.etcd --name m1 \
    --initial-cluster m1=http://127.0.0.1:18185,... \
    --initial-cluster-token etcd-lab-token \
    --initial-advertise-peer-urls http://127.0.0.1:18185
... restored snapshot, wal-dir ..., snap-dir ...
```

The transcript shows the result on
disk: a fresh `member/snap/db`, one
`.snap` file, one `.wal` file — a data
directory in exactly the shape chapter
4's live members keep. The restore
restates the membership (name, cluster
string, token) because a restored member
is founding a cluster from the snapshot,
and must be told who its peers will be.

What the lab did **not** do: start the
restored directory and run a cluster
from it. The restore step is verified —
file in, valid data directory out,
inspected on disk — but "we rebuilt the
service from backup and it served
traffic" is a stronger claim than this
lab earned, so criteria.md files the
full restart-from-snapshot under
documented-only, where it is described
from the project's own recovery
documentation. The distinction matters:
in a real disaster you restore *every*
member from the same snapshot (or start
one and re-add the rest), never mix a
restored member into survivors holding
a different history — that way lies a
cluster that cannot agree, which is the
one thing etcd exists to prevent.

Check: save a snapshot of your lab
cluster, read its status with `etcdutl`,
and restore it into a scratch directory.
Confirm the three files appear, and that
the revision in the status table matches
the cluster's revision at save time.
