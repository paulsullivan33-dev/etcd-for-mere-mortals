# Limits

Outcome: the boundaries stated before
they surprise you — what a coordination
store refuses to be, why its clusters
come in odd numbers, and the price its
one rule charges on every write.

## It is a coordination store, not a database

etcd holds small facts that must be
agreed, not records that must be kept.
Values are expected to be small (the
default ceiling on a single request is
about 1.5 MB, and sane values are
closer to a few hundred bytes — an
address, a status, a small setting).
The whole store has a quota — 2.1 GB in
the lab's default build, shown in every
`endpoint status` — and a cluster that
fills it stops taking writes. There are
no queries over values, no joins, no
"find keys whose value matches": chapter
6's prefix scan is the whole search
engine, by design. Work that needs any
of those things belongs in a database,
with etcd — if at all — beside it
holding the handful of facts the
database's own fleet must agree on.

## Odd numbers, and why two is worse than one

Majority arithmetic runs this guide:
3 members tolerate 1 loss, 5 tolerate
2. Even numbers buy nothing — 4 members
also tolerate only 1 loss before falling
below their majority of 3, while paying
for an extra member on every write. And
2 is the trap: a majority of 2 is 2, so
a two-member cluster tolerates **zero**
losses; either member stopping stops the
cluster (chapter 9's refusal, with one
fewer machine). A single member, by
contrast, is always its own majority —
it cannot disagree with itself, it just
has no backup. So: 1 for a lab or a
job that accepts the risk, 3 for
production, 5 for production that must
survive maintenance during a failure.
Never 2.

## Losing quorum is refusal, by design

Below a majority the cluster does not
degrade gracefully to read-only or to
best-effort. It refuses, reads included,
until the majority returns — chapter 9
measured both refusals. Plan operations
around that truth: take one member down
at a time, let it rejoin and catch up
before touching the next, and never let
maintenance windows overlap on two
members of three. Anything that cannot
tolerate that refusal does not have an
etcd problem; it has an architecture
that assumed agreement was free.

## Distance is time, on every write

A write commits when a majority hold
it, and the message must physically
travel to those members and back. On
loopback the lab's writes were
milliseconds. Across a building, more.
Across regions, tens of milliseconds at
best, added to **every** write, forever.
That is why etcd clusters are placed in
one site (or one cloud region), why
members scattered across continents are
an anti-pattern, and why the leader's
location matters (chapter 10): the rule
cannot be tuned away, only paid. The
corresponding read cost can be relaxed
with serializable (possibly stale) reads
for callers who accept them — a real
option in the API, not run in this lab,
and never the default you should assume.

## Small print, honestly

History costs space until compaction
(chapter 12), and compaction is a
commitment — compacted revisions are
unrecoverable, watchers holding them
must reset. Watches are streams, not
queues: a consumer disconnected through
more history than compaction retained
must re-read and resynchronise.
Authentication and TLS exist and were
not used here; a cluster on a shared
network without them is trusting the
network entirely. And etcd's excellent
fit for hundreds of keys is a poor fit
for hundreds of thousands of watchers
or values churning many times a second —
coordination is low-rate work, and the
tool is shaped for it.

Check: for your own use case, answer
three questions — are the values small,
is the write rate low, and can the
members live close together? Three yeses
fit etcd; any no points elsewhere, and
now you know where.
