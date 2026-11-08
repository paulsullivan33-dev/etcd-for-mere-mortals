# The moving parts

Outcome: a map of the parts inside every
etcd cluster — members, a leader, a log,
revisions, and two ports per member — so
later chapters' words have somewhere to
land.

## Members and the cluster

An etcd **cluster** is a set of
**members**, each a running `etcd`
process with its own data directory on
its own machine (or, in this guide's
lab, in its own folder on one machine).
Every member holds a complete copy of
the store. Members are named — the
lab's are `m1`, `m2`, `m3` — and each
has a long hexadecimal ID the cluster
assigns, which the member list shows
(chapter 4).

## The leader and the Raft log

Members are equal in what they hold,
not in what they do. One member is the
**leader**. All writes go through it.
The leader appends each change to a
shared ordered record — the **log** —
and copies the entry to the followers.
When a majority have the entry, it is
**committed**: permanent, and safe to
answer from. This is the **Raft**
consensus algorithm doing exactly what
chapter 1's rule promises.

Leadership is temporary. If the leader
stops, the remaining members hold an
**election** in a numbered round called
a **term**, and a new leader emerges —
provided a majority is still alive to
vote. The lab's endpoint status showed
term 2 on day one; after members were
stopped and restarted the term was 4,
and a deliberate leadership transfer
(chapter 10) raised it to 5. A rising
term is normal history, not damage.
Each log entry also has a position, the
**raft index**; healthy members agree
on it exactly, which is a quick health
signal in `endpoint status`.

## Revisions: the store has a memory

Separately from the Raft log, the
key-value store itself counts changes
with a single cluster-wide **revision**
number that climbs with every write.
Each key remembers the revision at
which it was created and last modified,
plus its own **version** — how many
times that key itself has been written.
Chapter 5 reads all three numbers off a
real key. Because history is kept, you
can read a key *as of* an old revision —
until **compaction** throws old history
away (chapter 12).

## Two ports per member

Each member listens twice. The **client
port** is where programs and `etcdctl`
talk: put, get, watch. The **peer port**
is where members talk to each other:
log copying, elections, health. The lab
keeps them 100 apart — client ports
18085–18087, peer ports 18185–18187, all
on 127.0.0.1 — so a firewall question or
a confusion between them is always
checkable against the member list, which
prints both addresses for every member.

## The three programs

The release ships three binaries.
`etcd` is the server. `etcdctl` is the
command-line client this guide drives
(chapter 3 captured its full command
list; transcript
`etcd-lab/transcripts/t00-help.txt`
groups them into key-value, cluster
maintenance, concurrency, and
authentication commands). `etcdutl` is
an offline tool that works on files —
snapshot inspection and restore —
without a running cluster (chapter 11).

Check: name a member's two ports and
what each is for, and say which number
— term, index, or revision — counts
changes to the key-value store itself.
