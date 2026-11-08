# Quorum, measured

Outcome: you have watched chapter 1's
rule happen, in numbers — the cluster
serving through one loss, refusing
through two, and recovering with its
data intact. This is the chapter the
whole guide is built around.

**Quorum** is the smallest number of
members that counts as a majority: for
three members, two. Everything below is
one driver script,
`etcd-lab/drivers/t05-quorum.sh`, and
one transcript,
`etcd-lab/transcripts/t05-quorum.txt`.
Read them together; the chapter quotes
the transcript's own numbers.

## Baseline: three of three

All endpoints healthy, a test key
written and read back:

```
127.0.0.1:18085 is healthy: successfully committed proposal
services/quorum-check/state = before-any-failure
```

## One member stops: the cluster shrugs

The driver stops m3 — politely, with the
stop script, the way a machine failing
politely would look from outside:

```
stopped m3
127.0.0.1:18085 is healthy ...
127.0.0.1:18086 is healthy ...
put services/quorum-check/state one-member-down
  -> OK in 95ms
get -> one-member-down
```

Two members remain, and two of three is
a majority, so commits still commit. The
write took 95 ms in this run — most of
that is client and process overhead on a
small sandbox, not the agreement itself
(the committed-proposal probes above
report single-digit to tens of
milliseconds on loopback). The point is
not the number; it is that there *is* a
number, an ordinary successful one,
while a third of the cluster is dead.

## A second member stops: the refusal

The driver stops m2 as well. One member,
m1, remains: running fine, data on disk,
nobody to agree with. Then:

```
endpoint health (m1 alone):
  127.0.0.1:18085 is unhealthy: failed to commit proposal: context deadline exceeded
  Error: unhealthy cluster   (exit 1)

attempt a WRITE with a 5 second command timeout:
  Error: context deadline exceeded   (put exit 1)

attempt a READ with a 5 second command timeout:
  Error: context deadline exceeded   (get exit 1)
```

Three honest observations. First, the
survivor does not crash, corrupt, or
guess: it waits, unable to commit, until
the client gives up. Second, **the read
refuses too**, and that surprises people.
etcd's default read is *linearizable*: it
answers only with values the cluster has
committed, and verifying that is itself
work a lone member cannot do. (A
weaker, possibly stale read mode exists
in the API for callers who accept it;
the lab did not use it, and the default
behaviour is the one to internalise.)
Third, the error is a timeout, not a
sentence — the client cannot distinguish
"no quorum" from "very slow" from where
it sits, which is why the guide names the
cause in the text and the transcript
proves it with the setup either side of
the failure.

And the failed write? It did not stick.
When the cluster recovered, the value
was still `one-member-down` — never
`should-not-stick`. A refused write
leaves no residue.

## Recovery

Both members restart with the same
script that created them — data
directories intact, so they rejoin as
`existing` members:

```
started m2 ... state existing
started m3 ... state existing
all healthy again after 0s
endpoint status: raft term 4 (was 2), raft index 51 on all three
get services/quorum-check/state -> one-member-down
put services/quorum-check/state recovered -> OK
```

The term climbing from 2 to 4 is the
elections that happened while members
came and went, recorded honestly in the
log's own bookkeeping. The identical
raft index on all three rows is the
agreement restored: three copies, one
history, including the write made while
the cluster was a member down.

## The lesson, stated plainly

A three-member etcd cluster tolerates
exactly one loss. That is not a flaw in
this deployment; it is arithmetic —
majority of 3 is 2, majority of 2
survivors is fine, 1 is not. Five
members tolerate two losses. And chapter
15 draws the corollary people get wrong:
two members tolerate *zero* losses,
because majority of 2 is 2 — which is
why a two-member cluster is worse than
one careful single member, not better.

Check: re-run the driver yourself and
match each stage to the transcript. If
your numbers differ, that is expected;
if your *outcomes* differ — a write
succeeding at one member of three, or
failing at two — something is wrong
with the cluster, and chapter 16 is the
next stop.
