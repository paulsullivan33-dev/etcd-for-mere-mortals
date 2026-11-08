# Watching keys

Outcome: a watch set on a key fires —
in front of you, from a transcript where
it really happened — when another
command changes that key, and again when
the key is deleted.

## Asking to be told

Reading is asking once. A **watch** is
asking to be told: "notify me every time
this key changes, from now on." Programs
use watches to learn that configuration
moved, a leader fell, or a service
registered — without polling in a loop,
asking *has it changed yet?* every few
seconds.

The lab's demonstration is a driver
script, `etcd-lab/drivers/t03-watch.sh`,
and its transcript
(`etcd-lab/transcripts/t03-watch.txt`)
holds the whole event sequence. The
shape of the test matters: the watch ran
**in the background**, and a different
forefront process made the changes. Two
actors, one event stream — that is the
real arrangement, reproduced small:

```
(etcdctl watch services/web-frontend/status running in background)
$ etcdctl put services/web-frontend/status ready
$ etcdctl put services/web-frontend/status draining
$ etcdctl del services/web-frontend/status
```

What the watch printed, in order:

```
PUT
services/web-frontend/status
ready
PUT
services/web-frontend/status
draining
DELETE
services/web-frontend/status
```

Each event names its kind — `PUT` or
`DELETE` — the key, and for a put, the
new value. A delete carries no value:
there is nothing left to carry. The
watch in the lab ended by its 12-second
timeout wrapper; a program's watch runs
until it cancels it or the connection
breaks, and reconnecting watches resume
from a revision, so events that happened
during a disconnection can be replayed
rather than lost (resumption is
described from the documentation — the
lab's watch was never disconnected).

## Watching a branch

`watch --prefix services/` watches every
key under the branch at once — the
natural partner to chapter 6's prefix
read. The pattern real programs use is
the pair together: prefix-read the
current state once, note the header
revision, then open a prefix watch from
that revision. State, then changes,
with no gap between them. That pairing
is assembled into a working registry
reader in chapter 13.

One honesty note about ordering: a watch
reports events in revision order, and
every member of the cluster would report
the same stream — watched events are
committed events, already agreed before
they are announced. A watch never tells
you something the cluster later takes
back.

Check: repeat the lab's shape — watch in
one terminal, put twice and delete once
from another — and match the printed
events to your actions, kind by kind.
