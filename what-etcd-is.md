# What etcd is

By the end of this chapter you can say
what problem etcd solves, and state the
one rule that explains both its strength
and its most surprising behaviour — a
healthy machine refusing to answer you.

## The argument etcd ends

Picture three copies of a program on
three machines. They must agree on small
facts: *I am the leader for this job.
The cache is at this address. Worker B
checked in a minute ago.* If each copy
keeps those facts in a local file, the
copies drift. Machines crash mid-write,
networks split, and soon two programs
each believe they are the leader.

**etcd** ends the argument by moving the
facts into a store built for agreement.
It is a **key-value store**: you save a
value under a name (a **key**) and read
it back by that name. `services/cache/endpoint`
might hold `cache-01.example.test:6379`.
What makes etcd different from a simple
file or a quick database is *where* the
store lives: on several machines at
once, as a **cluster** of **members**,
each holding a full copy, with a strict
procedure for keeping the copies
identical. That procedure is a consensus
algorithm called **Raft**, sketched in
chapter 2. etcd is free and open source,
and it is best known as the store inside
Kubernetes, which keeps its whole state
there — but nothing about it requires
Kubernetes, and this guide runs it
bare, on its own.

## The rule: agreement first, answers second

Every write to etcd travels to the
cluster's leader, is copied to the other
members, and is only reported as done
once a **majority** — more than half —
of the members hold it. Only then does
any member answer questions about it.
So:

> **etcd agrees with itself before it
> answers you. A write only counts as
> true once a majority of members hold
> it, which is why the cluster would
> rather refuse than disagree.**

Refusal is the rule working, not
failing. This guide's lab ran three
members and stopped them one at a time
(chapter 9, transcript
`etcd-lab/transcripts/t05-quorum.txt`).
One down: a write still succeeded, in
95 ms, because 2 of 3 is a majority.
Two down: the one surviving member was
perfectly healthy as a program, yet it
refused both a write and a read with
`Error: context deadline exceeded` —
alone, it could not know whether its
copy was the agreed one, so it said
nothing rather than risk saying
something the cluster had not agreed.
When the other two came back, the value
written during the one-member outage
was still there, and writes worked
again. Majority, refusal, recovery:
that sequence is etcd in one lesson.

The rule also explains the shapes etcd
comes in. Clusters run with odd numbers
of members — 1, 3, 5 — because a
majority must be winnable; chapter 15
shows why 2 members are *worse* than 1.
And it explains the cost: a write waits
for other machines, so distance between
members is time added to every write.

## What people keep in it

Small, precious, slow-changing facts:
which node leads, where services live
(**service discovery**, chapters 6 and
13), configuration a fleet must share,
locks and elections between programs,
and heartbeats that prove a worker is
alive (chapter 8). Not bulk data —
chapter 15 is firm about that. etcd is
the notebook on the shared desk, not
the warehouse.

Check: state the rule in your own
words, and say what a three-member
cluster does when two members stop —
and why refusing is the correct answer.
If you can, the rest of the guide is
detail.
