# etcd for Mere Mortals

A group of programs often needs one
small fact that all of them can trust:
which machine is the leader, where the
cache lives this hour, whether a worker
is still alive. Each program keeping its
own copy ends in an argument. **etcd**
is the shared notebook they agree to
use instead: a small **key-value store**
— a list of named values — that runs on
several machines at once and keeps every
copy identical.

One rule governs everything it does,
and this guide states it in chapter 1
and keeps pointing back to it: **etcd
agrees with itself before it answers
you. A write only counts as true once a
majority of its members hold it — so
when the cluster cannot reach a
majority, it would rather refuse your
request than risk disagreeing with
itself.** That is not a limitation
bolted on. It is the whole product, and
chapter 9 measures it: with one of
three members stopped, a write still
succeeded in 95 milliseconds; with two
stopped, both a write and a read were
refused, on purpose, by design.

The lab behind this guide ran the real
thing, in full: **etcd 3.7.3**, the
official release tarball from the etcd
project's GitHub releases, as a genuine
**three-member cluster** on one machine
— three separate processes, three
separate data directories, three client
ports (127.0.0.1 ports 18085, 18086 and
18087) and three peer ports. Against it
the lab listed the members and found
the leader; put, got and deleted keys
and read their revisions; read a whole
prefix at once; started a watch in the
background and captured it firing on two
changes and a delete; granted leases,
watched a key live and die with its
lease — gone after a measured
10 seconds; stopped members one at a
time until the cluster refused, then
brought them back and found the data
intact; saved a snapshot and restored
it into a fresh directory; compacted
the history and proved old revisions
were gone; and moved leadership from
one member to another, after discovering
the hard way which spelling of the
member ID that command accepts.

What the lab did not run — a cluster
spread across real machines, TLS and
user accounts, adding a fourth member —
is described from the project's own
documentation and labelled
documented-only. `criteria.md` keeps
the full ledger.

## What this guide covers

- [**What etcd is**](what-etcd-is.md) —
  the shared notebook, and the one rule
- [**The moving parts**](the-moving-parts.md) —
  members, the leader, the log, revisions,
  and the two ports every member owns
- [**Installing etcd**](installing-etcd.md) —
  the release file the lab used and the
  version check every install must pass
- [**Bringing up a cluster**](bringing-up-a-cluster.md) —
  three members from one binary, scripted,
  with health and leader checks
- [**Putting, getting and deleting**](putting-getting-deleting.md) —
  keys, values, and the three revision
  numbers every key carries
- [**Prefix reads**](prefix-reads.md) —
  reading a whole branch at once, and the
  service registry it makes possible
- [**Watching keys**](watching-keys.md) —
  a watch that fires for real, on puts
  and on a delete
- [**Leases and heartbeats**](leases-and-heartbeats.md) —
  keys that die on their own, measured
- [**Quorum, measured**](quorum-measured.md) —
  stopping members one at a time until
  the cluster refuses, then recovery
- [**Membership and leadership**](membership-and-leadership.md) —
  the member list and moving the leader
- [**Snapshots and restore**](snapshots-and-restore.md) —
  a whole cluster in one file, and back
- [**Compaction and defragmentation**](compaction-and-defragmentation.md) —
  history you can throw away, and the
  space that follows it
- [**Real jobs**](real-jobs.md) — a
  service registry assembled from the
  parts: lease, prefix read, watch
- [**The neighbours**](the-neighbours.md) —
  Consul, ZooKeeper, and the store inside
  Kubernetes
- [**Limits**](limits.md) — a coordination
  store, not a database; odd numbers for
  a reason; distance costs time
- [**Troubleshooting**](troubleshooting.md) —
  the refused write, the expired lease,
  the compacted revision
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Writing programs against etcd's client
libraries, running it under Kubernetes,
or operating it across data centres.
Authentication and TLS are named where
they belong and left to the project's
documentation; the lab is a loopback
cluster with no secrets in it. Nothing
here stores application data at scale —
chapter 15 explains why that work
belongs to a real database.

## How to use this guide

Read chapter 1 for the rule and chapter
2 for the map of parts; chapter 4 gets
a real three-member cluster running,
and chapter 9 is the one to have read
before you ever trust — or fear — a
stopped member. The lab lives in
`etcd-lab/`: the start and stop scripts
at its root, the driver scripts in
`etcd-lab/drivers/`, the snapshot in
`etcd-lab/snapshots/`, and every claim's
evidence in `etcd-lab/transcripts/`;
its distilled commands are
`examples/commands.txt` and its notes
`examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Text Processing for Mere Mortals](https://paulsullivan33-dev.github.io/text-processing-for-mere-mortals/)
- [Vim for Mere Mortals](https://paulsullivan33-dev.github.io/vim-for-mere-mortals/)
- [Markdown for Mere Mortals](https://paulsullivan33-dev.github.io/markdown-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/etcd-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/etcd-for-mere-mortals/blob/main/LICENSE-CODE).
