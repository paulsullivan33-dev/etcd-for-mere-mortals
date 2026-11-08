# Troubleshooting

Outcome: the failures this guide either
caused on purpose or met by accident,
each matched to its cause and its fix —
in the order you are likely to meet
them.

## "Error: context deadline exceeded" on every command

**Cause, most likely:** the cluster has
no quorum. Chapter 9 produced this exact
error for a write, a read, and a health
check with two of three members stopped:
the survivor cannot commit, so clients
wait until their timeout and report the
waiting, not the reason.

**Diagnose:** `endpoint status` and
`endpoint health` against each member
separately; count how many members'
processes are actually up (`member list`
needs a quorum too, so its failure is
also evidence). **Fix:** bring members
back — the data directories remember
everything; the lab's recovery needed no
repair step at all. If a member's data
is truly lost, restore from snapshot
(chapter 11) rather than letting it
rejoin empty.

## A write that worked yesterday refuses today: NOSPACE

**Cause:** the store hit its quota
(2.1 GB by default). etcd raises a
`NOSPACE` alarm and refuses writes to
protect itself. **Fix, in order:**
compact (`etcdctl compact <current
revision>`), defrag every member
(`etcdctl defrag`), then clear the
alarm (`etcdctl alarm disarm`). Chapter
12 covers the first two steps with
numbers. Deletes and lease expiries
free logical space but the file still
needs the defrag step to shrink.

## "required revision has been compacted"

**Cause:** you — or a watcher resuming —
asked for history that compaction has
discarded. The lab produced it by
reading `--rev=18` after compacting to
22. **Fix:** none, for that revision:
re-read the current state (a plain `get`,
no `--rev`), take the header revision
from the answer, and continue from
there. Then compact less aggressively,
or more often in smaller steps, so the
window readers need survives.

## The key that vanished

**Cause, usually:** a lease. Check
before suspecting deletion:
`lease timetolive <id> --keys` names the
keys riding on a lease, and a key put
with `--lease` dies with it — chapter
8's measured 10 seconds. Programs also
forget they used a short TTL during
testing. A vanished key with no lease
history points to a `del` — by your
code, or by a watcher's reaction you
set up and forgot.

## "unhealthy cluster" from one member only

**Cause:** that member is up but cannot
reach a quorum of peers — peer ports
blocked, advertise addresses wrong
(chapter 4 warned most first-cluster
failures live there), or the other
members genuinely down. **Diagnose:**
ask the *other* endpoints; if they
report healthy, the cluster is fine and
this member's peer path is the fault.
Check that the peer URLs in the member
list are addresses the members can dial
from where they run.

## move-leader rejects the member ID

**Cause:** wrong spelling. The lab hit
both wrong forms: `0x`-prefixed hex
("invalid syntax") and decimal ("value
out of range"). **Fix:** copy the ID
exactly as `member list` prints it —
hexadecimal, no prefix (chapter 10).

## A member will not start: "cluster ID mismatch" or state errors

**Cause, commonly:** starting an old
data directory with `--initial-cluster-state
new`, mixing tokens between clusters, or
pointing a fresh directory at a cluster
that has never heard of this member.
**Fix:** match state to reality
(`existing` for a directory with
history), keep the token identical on
every member of one cluster, and add
genuinely new members with `member add`
first so the roster expects them.

## Warnings about ETCDCTL_API

**Cause:** an old tutorial's export,
meaningless — and noisy — in 3.7.
**Fix:** unset it. The full story is in
chapter 3.

Check: pick the symptom nearest your
own last etcd surprise and trace it to
the chapter that demonstrated the
mechanism. Every fix above corresponds
to a behaviour a transcript in this
guide forced to happen on purpose.
